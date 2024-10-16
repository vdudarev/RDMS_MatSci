using Azure.Core.GeoJson;
using FluentValidation;
using FluentValidation.AspNetCore;
using FluentValidation.Results;
using InfProject.DBContext;
using InfProject.Models;
using InfProject.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using Microsoft.CodeAnalysis;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using System;
using System.Data;
using System.Diagnostics.Metrics;
using System.Reflection;
using System.Runtime.InteropServices.JavaScript;
using System.Security.Claims;
using System.Text;
using System.IO;
using WebUtilsLib;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;
using static System.Net.Mime.MediaTypeNames;
using static System.Runtime.InteropServices.JavaScript.JSType;
using static InfProject.Models.ObjectLinks;
using System.Net;
using System.Security.Cryptography;
using TypeValidationLibrary;
using Newtonsoft.Json.Linq;
using System.Text.Json;
using System.Security.AccessControl;
using OfficeOpenXml.FormulaParsing.Excel.Functions.Text;
using Microsoft.Extensions.Hosting;

namespace InfProject.Controllers;

[Authorize(Roles = "PowerUser,Administrator")]
[RequestFormLimits(ValueCountLimit = 10240)]
public class UploadFilesController : Controller
{
    private readonly IValidator<ObjectInfo> validator;
    private readonly ILogger<UploadFilesController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;
    private readonly IWebHostEnvironment webHostEnvironment;
    private readonly ICompositeViewEngine viewEngine;

    public UploadFilesController(IValidator<ObjectInfo> validator, ILogger<UploadFilesController> logger, IConfiguration config, DataContext dataContext, IWebHostEnvironment webHostEnvironment, ICompositeViewEngine viewEngine)
    {
        this.validator = validator;
        this.logger = logger;
        this.config = config;
        this.dataContext = dataContext;
        this.webHostEnvironment = webHostEnvironment;
        this.viewEngine = viewEngine;
    }

    /// <summary>
    /// select TYPE to edit
    /// </summary>
    /// <returns></returns>
    public async Task<IActionResult> Index() {
        int userId = HttpContext.GetUserId();
        string folder = config.MapStorageFile(config.GetRelativeFolderNameTemporary(dataContext.TenantId, userId));
        if (!Directory.Exists(folder))
        {
            Directory.CreateDirectory(folder);
        }
        var dir = new DirectoryInfo(folder);
        var files = dir.GetFiles();
        return View(files);
    }


    /// <summary>
    /// set return context
    /// </summary>
    private void SetSessionReturnContext() {
        string idrStr = Request.Form["idr"];
        int.TryParse(idrStr, out int idr);
        HttpContext.Session.SetInt32("idr", idr);

        string idoStr = Request.Form["ido"];
        int.TryParse(idoStr, out int ido);
        HttpContext.Session.SetInt32("ido", ido);

        string returl = Request.Form["returl"];
        HttpContext.Session.SetString("returl", returl ?? string.Empty);
    }


    [HttpPost]
    public async Task<IActionResult> StageFilesInit()
    {
        SetSessionReturnContext();
        // int userId = HttpContext.GetUserId();
        return Json(new { result = "ok" });
    }



    // [HttpPost] // does not work in VS Kestrel (IIS up to 2 Gb)
    // [HttpPost, DisableRequestSizeLimit] // does not work in VS Kestrel (IIS up to 2 Gb)
    // [HttpPost, DisableRequestSizeLimit, RequestFormLimits(MultipartBodyLengthLimit = long.MaxValue, ValueLengthLimit = int.MaxValue)] // Works in VS Kestrel (IIS up to 2 Gb)
    // [HttpPost, DisableRequestSizeLimit, RequestSizeLimit(long.MaxValue), RequestFormLimits(MultipartBodyLengthLimit = long.MaxValue)] // Works in VS Kestrel (IIS up to 2 Gb)
    // [HttpPost, RequestSizeLimit(long.MaxValue), RequestFormLimits(MultipartBodyLengthLimit = long.MaxValue)] // WARNING: Increasing the MaxRequestBodySize conflicts with the max value for IIS limit maxAllowedContentLength. HTTP requests that have a content length greater than maxAllowedContentLength will still be rejected by IIS. You can disable the limit by either removing or setting the maxAllowedContentLength value to a higher limit. 
    [HttpPost, RequestSizeLimit(int.MaxValue), RequestFormLimits(MultipartBodyLengthLimit = int.MaxValue)]
    public async Task<IActionResult> StageFiles(List<IFormFile> fileupload)
    {
        // SetSessionReturnContext();
        int userId = HttpContext.GetUserId();
        try
        {
            // dataContext.TenantId;

            // possible File Upload
            await UploadFiles(userId, fileupload);
            TempData["Suc"] = $"Files staged successfully, please adjust (if required) and confirm";
        }
        catch (Exception ex)
        {
            TempData["Err"] = $"Error StageFiles({ex.GetType()}): {ex.Message}";
            logger.LogError($"Error StageFiles {ex.ToStringForLog()} [userId={userId}]");
            return View("Index");
        }
        return RedirectToRoute(new { controller = "UploadFiles", action = "Index" });
    }


    private async Task UploadFiles(int userId, List<IFormFile> fileupload, string filename = null)
    {
        // long fileSize = 0;
        if (fileupload is not null && fileupload.Count > 0)
        {
            string folder = config.GetRelativeFolderNameTemporary(dataContext.TenantId, userId);
            if (!Directory.Exists(config.MapStorageFile(folder)))
            {
                Directory.CreateDirectory(config.MapStorageFile(folder));
            }

            foreach (IFormFile file in fileupload) {
                var formFile = file;

                // if (formFile is not { Length: > 0 }) return null;

                if (string.IsNullOrEmpty(filename)) {
                    filename = formFile.FileName;
                }
                string relativeFileName = Path.Combine(folder, filename);
                string filePath = config.MapStorageFile(relativeFileName);
                await using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await formFile.CopyToAsync(stream);
                    // fileSize = formFile.Length;
                }
            }
        }
    }

    /// <summary>
    /// 2024-07 new CHUNKED upload to overcome platform limitations
    /// </summary>
    /// <param name="chunk">IFormFile - file from form</param>
    /// <param name="fileName">file name</param>
    /// <param name="chunkNumber">chunk number 1..N</param>
    /// <param name="totalChunks">N - total chunks</param>
    /// <returns></returns>
    [HttpPost]
    public async Task<IActionResult> UploadChunk([FromForm] IFormFile chunk, [FromForm] string fileName, [FromForm] int chunkNumber, [FromForm] int totalChunks)
    {
        if (chunk == null || chunk.Length == 0) {
            return BadRequest("No chunk uploaded.");
        }
        int userId = HttpContext.GetUserId();

        // Save the chunk/file
        await UploadFiles(userId, new List<IFormFile>() { chunk },
            filename: totalChunks==1 && chunkNumber==1 ? fileName : $"{fileName}.part-{chunkNumber}");


        // Check if all chunks are uploaded
        string folder = config.GetRelativeFolderNameTemporary(dataContext.TenantId, userId);
        string absFolder = config.MapStorageFile(folder);
        var allChunksUploaded = true;
        for (int i = 1; i <= totalChunks; i++)
        {
            if (!System.IO.File.Exists(Path.Combine(absFolder, $"{fileName}.part-{i}")))
            {
                allChunksUploaded = false;
                break;
            }
        }

        if (allChunksUploaded)
        {
            var finalFilePath = Path.Combine(absFolder, fileName);

            // Combine all chunks into the final file
            /*await*/ using (var finalFileStream = new FileStream(finalFilePath, FileMode.Create))
            {
                for (int i = 1; i <= totalChunks; i++)
                {
                    var partFilePath = Path.Combine(absFolder, $"{fileName}.part-{i}");
                    /*await*/ using (var partFileStream = new FileStream(partFilePath, FileMode.Open))
                    {
                        /*await*/ partFileStream.CopyTo(finalFileStream);
                    }
                    // System.IO.File.Delete(partFilePath); // Delete the part file after merging
                }
            }
            for (int i = 1; i <= totalChunks; i++) {
                var partFilePath = Path.Combine(absFolder, $"{fileName}.part-{i}");
                System.IO.File.Delete(partFilePath); // Delete the part file after merging
            }
            // all chunks are uploaded and resulting file is formed
            return Ok(new { completed = true, fileName });
        }
        // the current chunk completed but not the whole file
        return Ok(new { completed = (totalChunks == 1 && chunkNumber == 1), fileName });
    }


    /// <summary>
    /// Validate staged file through the schema in DB
    /// </summary>
    /// <param name="typeId">Type Id</param>
    /// <param name="fileName">filename only (no path) - path is the current user directory</param>
    /// <param name="objectName">name of the object to create (object name should be unique within type tenant)</param>
    /// <returns></returns>
    [HttpPost]
    public async Task<JsonResult> Validate(int typeId, string fileName, string objectName) {
        int userId = HttpContext.GetUserId();
        if (typeId <= 0) {
            return Json(new TypeValidatorResult() { Code = 1, Message = $"typeId is undefined [{fileName}]" });
        }
        var type = await dataContext.GetType(typeId);
        string folder = config.MapStorageFile(config.GetRelativeFolderNameTemporary(dataContext.TenantId, userId));
        string path = string.IsNullOrEmpty(fileName) ? string.Empty : Path.Combine(folder, fileName);   // non-existent files are checked via type.FileRequired
        TypeValidatorResult vr = type.ValidateFile(path);
        if (vr) {   // ok - check objectName
            int? objectId = await dataContext.GetObjectByTypeAndObjectName(typeId, objectName);
            if (objectId.HasValue && objectId.Value!=0)
            {
                vr = new TypeValidatorResult() { Code = 1, Message = $"Object Name \"{objectName}\" is not unique [typeId={typeId}, ObjectId={objectId.Value}]" };
            }
        }
        return Json(vr);
    }


    /// <summary>
    /// Validated and GetDataValues
    /// </summary>
    /// <param name="typeId"></param>
    /// <param name="fileName"></param>
    /// <returns></returns>
    [HttpPost]
    [Obsolete("No context")]
    public async Task<IActionResult> GetDataValues(int typeId, string fileName)
    {
        int userId = HttpContext.GetUserId();
        string folder = config.MapStorageFile(config.GetRelativeFolderNameTemporary(dataContext.TenantId, userId));
        string path = Path.Combine(folder, fileName);
        string msg = string.Empty;  // ok, valid
        if (typeId <= 0)
        {
            return Json(new TypeValidatorResult() { Code = 1, Message = $"typeId is undefined [{fileName}]" });
        }
        // currently any existing file is valid for any existing type...
        var type = await dataContext.GetType(typeId);
        var vr = type.ValidateFileAndGetDataValues(path, null); // TODO: no context
        return Json(vr.data);
    }



    /// <summary>
    /// Delete stecified file from staging
    /// </summary>
    /// <param name="fileName"></param>
    /// <returns></returns>
    [HttpPost]
    public async Task<IActionResult> DeleteStagedFile(string fileName) {
        int userId = HttpContext.GetUserId();
        if (fileName.Contains('\\') || fileName.Contains('/')) { // relative file paths are disabled (security)
            TempData["Err"] = $"File name is wrong [{fileName}]";
        }
        else
        {
            try
            {
                string folder = config.MapStorageFile(config.GetRelativeFolderNameTemporary(dataContext.TenantId, userId));
                string path = Path.Combine(folder, fileName);
                int res = 0;    // ok
                string msg = string.Empty;  // ok, valid
                if (System.IO.File.Exists(path))
                {
                    System.IO.File.Delete(path);
                    TempData["Suc"] = $"File {fileName} deleted successfully";
                }
            }
            catch (Exception ex)
            {
                TempData["Err"] = $"Error DeleteStagedFile({ex.GetType()}): {ex.Message}";
                logger.LogError($"Error DeleteStagedFile {ex.ToStringForLog()} [userId={userId}]");
            }
        }
        return RedirectToRoute(new { controller = "UploadFiles", action = "Index" });
    }

    /// <summary>
    /// Delete all staged files
    /// </summary>
    /// <param name="fileName"></param>
    /// <returns></returns>
    [HttpPost]
    public async Task<IActionResult> DeleteAllStagedFiles()
    {
        int userId = HttpContext.GetUserId();
        try
        {
            string folder = config.MapStorageFile(config.GetRelativeFolderNameTemporary(dataContext.TenantId, userId));


            DirectoryInfo di = new DirectoryInfo(folder);
            foreach (FileInfo file in di.GetFiles())
            {
                file.Delete();
            }
            TempData["Suc"] = $"Files were deleted successfully";
        }
        catch (Exception ex)
        {
            TempData["Err"] = $"Error DeleteAllStagedFiles({ex.GetType()}): {ex.Message}";
            logger.LogError($"Error DeleteAllStagedFiles {ex.ToStringForLog()} [userId={userId}]");
        }
        return RedirectToRoute(new { controller = "UploadFiles", action = "Index" });
    }


    /// <summary>
    /// throws exception if one of the files is not correct
    /// </summary>
    /// <param name="count">numver of files to upload</param>
    /// <exception cref="Exception"></exception>
    private async void CheckDataBeforeCreateObjectsFromStagedFiles(int userId, string folder, int count) {
        // traverse all files
        for (int i = 0; i < count; i++)
        {
            string fileName = Request.Form[$"file{i}"];
            string path = Path.Combine(folder, fileName);
            string name = Request.Form[$"name{i}"];
            int.TryParse(Request.Form[$"TypeId{i}"], out int typeId);
            int.TryParse(Request.Form[$"sortcode{i}"], out int sortcode);
            if (!System.IO.File.Exists(path))
            {
                throw new Exception($"File {fileName} not found [i={i}]");
            }
            if (typeId < 1)
            {
                throw new Exception($"Type not defined [i={i}]");
            }
            if (string.IsNullOrEmpty(name))
            {
                throw new Exception($"Name not defined [i={i}]");
            }

            // check correspondence of file to type - exception if format is wrong
            var type = await dataContext.GetType(typeId);
            var vr = type.ValidateFileAndGetDataValues(path, null); // TODO: insert context if possible
            if (!vr.res) {
                throw new Exception($"File verification {vr} [{fileName}]");
            }
        }
    }


    [HttpPost]
    public async Task<IActionResult> CreateObjectsFromStagedFiles()
    {
        int userId = HttpContext.GetUserId();
        try
        {
            string folder = config.MapStorageFile(config.GetRelativeFolderNameTemporary(dataContext.TenantId, userId));
            DateTime dt = DateTime.Now;
            int.TryParse(Request.Form["count"], out int count); // files count
            int.TryParse(Request.Form["linkTypeObjectId"], out int linkTypeObjectId); // LinkTypeObjectId
            List<Action> actions = new List<Action>();
            CheckDataBeforeCreateObjectsFromStagedFiles(userId, folder, count); // check all data before object creation
            int.TryParse(Request.Form["obj.AccessControl"], out int accessControl);
            int.TryParse(Request.Form["obj.RubricId"], out int rubricId);
            List<int> createdIds = new List<int>();    // created objects identifiers
            using (SHA256 sha256 = SHA256.Create()) {
                for (int i = 0; i < count; i++)
                {
                    string fileName = Request.Form[$"file{i}"];
                    string path = Path.Combine(folder, fileName);
                    string name = Request.Form[$"name{i}"];
                    int.TryParse(Request.Form[$"TypeId{i}"], out int typeId);
                    int.TryParse(Request.Form[$"sortcode{i}"], out int sortcode);

                    ObjectInfo obj = new ObjectInfo()
                    {
                        TenantId = dataContext.TenantId,
                        TypeId = typeId,
                        AccessControl = (AccessControl)accessControl,
                        RubricId = rubricId,
                        _createdBy = userId,
                        _created = dt,
                        _updatedBy = userId,
                        _updated = dt,
                        ObjectName = name,
                        SortCode = sortcode
                    };

                    // create object (all preliminary checks are done in CheckDataBeforeCreateObjectsFromStagedFiles)
                    (int newObjectId, Action act) = await CreateObjectFromStagedFile(sha256, obj, path, fileName, i); // check all data before object creation
                    actions.Add(act);
                    createdIds.Add(newObjectId);
                }
            }

            // insert new links (if any) for created items: 
            // createdIds
            List<(int ObjectId, int LinkedObjectId, int SortCode, int LinkTypeObjectId)> list = new List<(int ObjectId, int LinkedObjectId, int SortCode, int LinkTypeObjectId)>();
            foreach (var val in Request.Form["assoc"])
            {
                int.TryParse(val, out int mainObjId);
                if (mainObjId < 1)
                    continue;
                foreach (var createdId in createdIds)
                {
                    list.Add((mainObjId, createdId, 0, linkTypeObjectId));
                }
            }
            int rowsAffected = await dataContext.ObjectLinkObject_LinksInsertForStagedFiles(userId, list);

            // execute actions for all objects (Object_UpdateInsertDatabaseValues)
            foreach (var act in actions) {
                act?.Invoke();  // could be exceptions
            }

            TempData["Suc"] = $"Succeessfully created ({count} object(s))";
        }
        catch (Exception ex)
        {
            TempData["Err"] = $"Error CreateObjectsFromStagedFiles({ex.GetType()}): {ex.Message}";
            logger.LogError($"Error CreateObjectsFromStagedFiles {ex.ToStringForLog()} [userId={userId}]");
        }
        string returl = WebUtility.UrlDecode(HttpContext.Session.GetString("returl"));
        if (!string.IsNullOrEmpty(returl))
            return Redirect(returl);
        return RedirectToRoute(new { controller = "UploadFiles", action = "Index" });
    }


    private async Task<(int, Action)> CreateObjectFromStagedFile(SHA256 sha256, ObjectInfo obj, string path, string fileName, int index)
    {
        Type t = null!;
        dynamic dObj = null!;
        ObjectInfo newObject = null!;
        Models.TypeInfo dbType = await dataContext.GetType(obj.TypeId);
        if (dbType.TableName != "ObjectInfo")
        {
            dObj = ReflectionUtils.GetObjectFromRequest(obj, tableName: dbType.TableName, requestCollection: HttpContext.Request.Form, index);
            t = Type.GetType($"InfProject.Models.{dbType.TableName}");
            // IValidator<Sample> validatorNested
        }

        // IValidator<ObjectInfo>
        ValidationResult result = await validator.ValidateAsync(obj);
        if (!result.IsValid)    // check all data before object creation
        {
            result.AddToModelState(this.ModelState);    // Copy the validation results into ModelState.
            throw new Exception($"Error validating model (ObjectInfo): {result} [{obj}, {index}]");
        }

        var vr = dbType.ValidateFileAndGetDataValues(path, null); // TODO: insert context if possible
        if (!vr.res) {
            throw new Exception($"Error validating custom model for file: {vr} [{fileName}]");
        }

        if (dbType.TableName != "ObjectInfo")
        { // further checks
          // IValidator<Sample>
            Type it = typeof(IValidator<>);
            Type[] typeArgs = { t };
            Type constructed = it.MakeGenericType(typeArgs);
            dynamic validatorNested = HttpContext.RequestServices.GetService(constructed);
            if (validatorNested != null)
            {
                result = validatorNested.Validate(dObj);
                if (!result.IsValid)
                {
                    result.AddToModelState(this.ModelState);    // Copy the validation results into ModelState.
                    throw new Exception($"Error validating model ({dbType.TableName}): {result} [{obj}, {index}]");
                }
            }
        }

        // UPDATE / INSERT in database
        if (dbType.TableName == "ObjectInfo")
        {
            newObject = await dataContext.ObjectInfo_UpdateInsert(obj);
        }
        else
        {
            MethodInfo methodInfo = typeof(DataContext).GetMethod("ObjectInfo_UpdateInsertVirtual");
            MethodInfo genericMethodInfo = methodInfo.MakeGenericMethod(t);
            dynamic res = genericMethodInfo.Invoke(dataContext, new object[] { dObj });
            newObject = res.Result;
        }
        obj.ObjectId = newObject.ObjectId;
        if (obj.ObjectId < 1)
        {
            throw new Exception("ObjectId is not set (object creation error?)");
        }

        logger.LogInformation($"Insert successfull for object [{ReflectionUtils.GetIdName(dbType.TableName)}={newObject.ObjectId}]");

        // possible File Upload
        string folder = config.GetRelativeFolderNameForObject(obj);
        if (!Directory.Exists(config.MapStorageFile(folder)))
        {
            Directory.CreateDirectory(config.MapStorageFile(folder));
        }
        string relPathNew = folder + "/" + fileName;    // Path.Combine(folder, fileName);
        string dest = config.MapStorageFile(relPathNew);
        if (System.IO.File.Exists(dest)) {
            System.IO.File.Delete(dest);
        }
        System.IO.File.Move(path, dest);
        string hash = WebUtilsLib.HashUtils.CalculateHash(sha256, dest);

        int rowsAffected = await dataContext.ObjectInfo_UpdateObjectFilePath(obj.ObjectId, relPathNew, hash);
        // analyse rowsAffected == 1
        obj.ObjectFilePath = relPathNew;

        return (obj.ObjectId, () => {
            // SAVE DATA from file to Object (Properties, etc)
            DateTime dt = ((DateTime)obj._created).AddMilliseconds(-100);   // just to make sure, than nothing is deleted unattended on quick updates with the same time (TODO: sync times with SQL server - could be a problems if SQL Server in on other VM with non-synchronized time)

            // essential to add properties for an object after it was connected with links (see above)
            string formUpdateInsert_PropertiesFromForm = HttpContext.Request.Form["UpdateInsert_PropertiesFromForm"];  // <input type="hidden" name="UpdateInsert_PropertiesFromForm" value="1" />
            if (string.CompareOrdinal(formUpdateInsert_PropertiesFromForm, "1") == 0 && dbType.GetSettingsIncludePropertiesForm())
            {
                // update properties!
                (int updatedInserted, int deleted, string log) = PropertiesUtils.UpdateInsert_PropertiesFromForm(obj.ObjectId, HttpContext, dataContext, $"i{index}").Result;
                logger.LogInformation(log);
                logger.LogInformation($"Properties values are saved, UpdateInsert_PropertiesFromForm [ObjectId={obj.ObjectId}, updated&inserted={updatedInserted}, deleted={deleted}]");
            }

            try
            {
                int v = dataContext.Object_UpdateInsertDatabaseValues(vr.data, dt, (int)obj._createdBy, newObject).Result;
                int rowsAffected = v;
                logger.LogInformation($"Save data successfull for object [{rowsAffected} row(s), {ReflectionUtils.GetIdName(dbType.TableName)}={newObject.ObjectId}]");
            }
            catch (Exception ex)
            {
                logger.LogError($"Error CreateObjectFromStagedFile {ex.ToStringForLog()} [{ReflectionUtils.GetIdName(dbType.TableName)}={newObject.ObjectId}; path={path}]");
            }
        });
    }



}