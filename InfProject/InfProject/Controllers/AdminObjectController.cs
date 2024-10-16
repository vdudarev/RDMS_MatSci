using Azure.Core;
using Azure.Core.GeoJson;
using FluentValidation;
using FluentValidation.AspNetCore;
using FluentValidation.Results;
using InfProject.DBContext;
using InfProject.Models;
using InfProject.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity.UI.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using Microsoft.CodeAnalysis;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using Newtonsoft.Json;
using System;
using System.Data;
using System.Diagnostics.Metrics;
using System.Net;
using System.Reflection;
using System.Runtime.InteropServices.JavaScript;
using System.Security.Claims;
using System.Security.Policy;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using TypeValidationLibrary;
using WebUtilsLib;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;
using static System.Net.Mime.MediaTypeNames;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace InfProject.Controllers;

[Authorize(Roles = "PowerUser,Administrator")]
public class AdminObjectController : Controller
{
    // Claim name to enlist all the objects in the list of a certain type (to validate objects - Azadeh's use case)
    public const string ClaimNameToShowAllObjects = "AdminObject_EnlistAllObjects";
    // UploadDatabaseValues priviledge for all objects (to extract data automatically from files and update database content - Azadeh's use case)
    public const string ClaimNameToUploadDatabaseValuesForAllObjects = "AdminObject_UploadDatabaseValuesAllObjects";

    private readonly IValidator<ObjectInfo> validator;
    private readonly ILogger<AdminObjectController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;
    private readonly IWebHostEnvironment webHostEnvironment;
    private readonly ICompositeViewEngine viewEngine;
    private readonly IEmailSender mailSender;

    public AdminObjectController(IValidator<ObjectInfo> validator, ILogger<AdminObjectController> logger, IConfiguration config, DataContext dataContext, IWebHostEnvironment webHostEnvironment, ICompositeViewEngine viewEngine, IEmailSender mailSender)
    {
        this.validator = validator;
        this.logger = logger;
        this.config = config;
        this.dataContext = dataContext;
        this.webHostEnvironment = webHostEnvironment;
        this.viewEngine = viewEngine;
        this.mailSender = mailSender;
    }

    /// <summary>
    /// select TYPE to edit
    /// </summary>
    /// <returns></returns>
    public async Task<IActionResult> Index() {

        var list = await dataContext.GetTypesFlatWithCount();
        return View(list);
    }


    /// <summary>
    /// enlist type's items in a list (respecting the access level)
    /// </summary>
    /// <param name="idType"></param>
    /// <returns></returns>
    public async Task<IActionResult> List([FromRoute(Name = "id")] int idType)
    {
        Models.TypeInfo type = await dataContext.GetType(idType);
        var userId = HttpContext.GetUserId();
        int isAdmin = HttpContext.User.IsInRole(UserGroups.Administrator) ? -1 : 0;
        if (isAdmin == 0 && HttpContext.User.HasClaim(ClaimNameToShowAllObjects, "1")) {
            isAdmin = 1;
        }
        var list = await dataContext.ObjectInfo_GetList_AccessControlModify(idType, isAdmin, userId);
        return View((type, list));
    }



    public async Task<IActionResult> NewItem([FromRoute(Name = "id")] int idType)
    {
        ObjectInfo obj;
        var dbType = await dataContext.GetType(idType);
        if (dbType.TableName == "ObjectInfo")
        {
            obj = new ObjectInfo() { TenantId = dataContext.TenantId, TypeId = idType, AccessControl = dataContext.Tenant.AccessControl };
        }
        else
        {  // for complex inherited objects
            Type t = Type.GetType($"InfProject.Models.{dbType.TableName}");
            dynamic dObj = Activator.CreateInstance(t);
            // dObj <- obj
            dObj.TenantId = dataContext.TenantId;
            dObj.TypeId = idType;
            dObj.AccessControl = dataContext.Tenant.AccessControl;
            obj = dObj;
        }
        ViewBag.dbType = dbType;
        ViewBag.controllerContext = ControllerContext;
        ViewBag.viewEngine = viewEngine;
        return View("EditItem", obj);
    }

    public async Task<IActionResult> EditItem([FromRoute(Name = "id")] int idObject)
    {
        (ObjectInfo obj, Models.TypeInfo dbType) = await dataContext.ObjectInfo_GetVirtualWrapper(idObject);
        if (obj == null) {
            return NotFound($"Object with id {idObject} not found [dbType?.TableName={dbType?.TableName}]");
        }
        ViewBag.dbType = dbType;
        ViewBag.controllerContext = ControllerContext;
        ViewBag.viewEngine = viewEngine;
        return View(obj);   // View((obj, dbType, ControllerContext, viewEngine)); // troubles with Model (fieldNames) in asp-for
    }

    public async Task<IActionResult> EditLinks([FromRoute(Name = "id")] int idObject)
    {
        (ObjectInfo obj, Models.TypeInfo dbType) = await dataContext.ObjectInfo_GetVirtualWrapper(idObject);
        if (obj == null)
        {
            return NotFound($"Object with id {idObject} not found [{dbType.TableName}]");
        }
        ViewBag.dbType = dbType;
        ViewBag.controllerContext = ControllerContext;
        ViewBag.viewEngine = viewEngine;
        return View(obj);   // View((obj, dbType, ControllerContext, viewEngine)); // troubles with Model (fieldNames) in asp-for
    }

    [HttpPost, DisableRequestSizeLimit, RequestFormLimits(MultipartBodyLengthLimit = Int32.MaxValue, ValueLengthLimit = Int32.MaxValue)]
    public async Task<IActionResult> UpdateInsert([FromForm] ObjectInfo obj, List<IFormFile> fileupload, [FromForm] int deletefile = 0)
    {
        string returl = Request.Form["returl"];
        // "parent" ObjectId to make an association
        int.TryParse(Request.Form["ido"].ToString() ?? string.Empty, out int ido);
        int? linkTypeObjectId = null;
        if (Request.Form.ContainsKey("linkTypeObjectId")) {
            int.TryParse(Request.Form["linkTypeObjectId"].ToString() ?? string.Empty, out int i);
            linkTypeObjectId = i;
        }
        Type t = null!;
        dynamic dObj = null!;
        ObjectInfo newObject = null!;
        Models.TypeInfo dbType = await dataContext.GetType(obj.TypeId);
        ViewBag.dbType = dbType;
        ViewBag.controllerContext = ControllerContext;
        ViewBag.viewEngine = viewEngine;

        try
        {
            ObjectInfo objOld = await HttpContext.GetObjectAndCheckWriteAccess(dataContext, obj.ObjectId);   // Exception if no access
            obj.TenantId = dataContext.TenantId;
            int userId = HttpContext.GetUserId();
            obj._createdBy = userId;
            obj._updatedBy = userId;
            DateTime dt = DateTime.Now.AddMilliseconds(-100);   // just to make sure, than nothing is deleted unattended on quick updates with the same time (TODO: sync times with SQL server - could be a problems if SQL Server in on other VM with non-synchronized time)
            obj._created = dt;
            obj._updated = dt;

            if (dbType.TableName != "ObjectInfo") {
                dObj = ReflectionUtils.GetObjectFromRequest(obj, tableName: dbType.TableName, requestCollection: HttpContext.Request.Form, index: null);
                t = Type.GetType($"InfProject.Models.{dbType.TableName}");
                // IValidator<Sample> validatorNested
            }

            // 2023-01-02    - When validation is ok - make all VALID
            foreach (var item in this.ModelState)
            {
                item.Value.Errors.Clear();
                item.Value.ValidationState = Microsoft.AspNetCore.Mvc.ModelBinding.ModelValidationState.Valid;
            }

            // IValidator<ObjectInfo>
            ValidationResult result = await validator.ValidateAsync(obj);
            if (!result.IsValid)
            {
                result.AddToModelState(this.ModelState);    // Copy the validation results into ModelState.
                TempData["Err"] = $"Error validating model (ObjectInfo): {result}";
                return View("EditItem", dObj != null ? dObj as ObjectInfo : obj);
            }
            if (dbType.TableName != "ObjectInfo") { // further checks
                // IValidator<Sample>
                Type it = typeof(IValidator<>);
                Type[] typeArgs = { t };
                Type constructed = it.MakeGenericType(typeArgs);
                dynamic validatorNested = HttpContext.RequestServices.GetService(constructed);
                if (validatorNested != null) {
                    result = validatorNested.Validate(dObj);
                    if (!result.IsValid)
                    {
                        result.AddToModelState(this.ModelState);    // Copy the validation results into ModelState.
                        TempData["Err"] = $"Error validating model ({dbType.TableName}): {result}";
                        return View("EditItem", dObj);
                    }
                }
            }

            string? oldObjectFilePath = objOld?.ObjectFilePath; // /tenantT/classC/assignments/assignmentA/userU";
            if (deletefile == 1)
            {  // file delete upon request!
                obj.ObjectFilePath = null;
                // dObj.ObjectFilePath = null;
                if (!string.IsNullOrEmpty(oldObjectFilePath) && System.IO.File.Exists(config.MapStorageFile(oldObjectFilePath)))
                {
                    System.IO.File.Delete(config.MapStorageFile(oldObjectFilePath));
                }
                obj.ObjectFileHash = null;
                // dObj.ObjectFileHash = null;
            }


            // UPDATE / INSERT in database
            if (dbType.TableName == "ObjectInfo")
            {
                newObject = await dataContext.ObjectInfo_UpdateInsert(obj);
            }
            else {
                MethodInfo methodInfo = typeof(DataContext).GetMethod("ObjectInfo_UpdateInsertVirtual");
                MethodInfo genericMethodInfo = methodInfo.MakeGenericMethod(t);
                dynamic res = genericMethodInfo.Invoke(dataContext, new object[] { dObj });
                newObject = res.Result;
            }

            // update links
            await UpdateInsertByRequest_ObjectLinkRubric(newObject.ObjectId, newObject.RubricId ?? 0, userId);

            // essential to add properties for an object after it was connected with links (see above)
            string formUpdateInsert_PropertiesFromForm = Request.Form["UpdateInsert_PropertiesFromForm"];  // <input type="hidden" name="UpdateInsert_PropertiesFromForm" value="1" />
            if (string.CompareOrdinal(formUpdateInsert_PropertiesFromForm, "1") == 0 && dbType.GetSettingsIncludePropertiesForm()) {
                // update properties!
                (int updatedInserted, int deleted, string log) = await PropertiesUtils.UpdateInsert_PropertiesFromForm(newObject.ObjectId, HttpContext, dataContext);
                logger.LogInformation(log);
                logger.LogInformation($"Properties values are saved, UpdateInsert_PropertiesFromForm [ObjectId={newObject.ObjectId}, updated&inserted={updatedInserted}, deleted={deleted}]");
            }

            if (obj.ObjectId == 0)
            {
                TempData["Suc"] = $"Insert successful";
                logger.LogInformation($"Insert successful [{ReflectionUtils.GetIdName(dbType.TableName)}={newObject.ObjectId}]");
            }
            else
            {
                TempData["Suc"] = $"Update successful";
                logger.LogInformation($"Update successful [{ReflectionUtils.GetIdName(dbType.TableName)}={newObject.ObjectId}]");
            }
            obj.ObjectId = newObject.ObjectId;
            int rowsAffected = 0, isValid = 0;
            if (ido != 0) {  // "parent" object defined
                // make an association with "parent" object
                rowsAffected = await dataContext.ObjectLinkObject_LinkAdd(ido, obj.ObjectId, userId, SortCode: null, linkTypeObjectId);  // cur.object => "parent" object
            }

            // possible File Upload

            (string uploadedRelativeFileName, string hash) = await UploadFile(newObject, fileupload);
            if (!string.IsNullOrEmpty(uploadedRelativeFileName)) {  // file Uploaded
                var newPath = config.MapStorageFile(uploadedRelativeFileName);
                try
                {
                    var context = await dataContext.ExtractContext(newObject);
                    var fileValidationResult = dbType.ValidateFileAndGetDataValues(newPath, context);    // verification
                    if (fileValidationResult.res) // ok => write to DB
                    {
                        rowsAffected = await dataContext.ObjectInfo_UpdateObjectFilePath(newObject.ObjectId, uploadedRelativeFileName, hash);
                        // analyse rowsAffected == 1
                        obj.ObjectFilePath = uploadedRelativeFileName;
                        isValid = 1;


                        // SAVE DATA from file to Object (Properties, etc)
                        rowsAffected = await dataContext.Object_UpdateInsertDatabaseValues(fileValidationResult.data, dt, userId, obj);

                        if (!string.IsNullOrEmpty(oldObjectFilePath) &&     // possible File Delete (to clean up old data)
                            string.Compare(oldObjectFilePath, uploadedRelativeFileName, ignoreCase: true) != 0
                            && System.IO.File.Exists(config.MapStorageFile(oldObjectFilePath)))
                        {
                            System.IO.File.Delete(config.MapStorageFile(oldObjectFilePath));
                        }
                    }
                    else { // fail
                        TempData["Suc"] = string.Empty;
                        TempData["Err"] = "File verification " + fileValidationResult + (string.IsNullOrEmpty(objOld?.ObjectFilePath) ? " [no file attached]" : " [previous file version is retained]");
                        if (System.IO.File.Exists(newPath)){
                            System.IO.File.Delete(newPath);
                        }
                    }
                }
                catch (Exception ex)
                {
                    TempData["Suc"] = string.Empty;
                    TempData["Err"] = $"Error {(obj.ObjectId == 0 ? "inserting" : "updating")} file({dbType?.TableName}): {ex.Message}";
                    logger.LogError($"Error dataContext.ObjectInfo_UpdateInsert: {TempData["Err"]} {ex.ToStringForLog()} [obj={obj}, dObj={dObj}]");
                    if (isValid == 0 && string.Compare(oldObjectFilePath, uploadedRelativeFileName, ignoreCase: true) != 0
                        && System.IO.File.Exists(newPath)) {
                        System.IO.File.Delete(newPath);
                    }
                }
            }
            obj.ObjectId = newObject.ObjectId;
        }
        catch (Exception ex)
        {
            TempData["Err"] = $"Error {(obj.ObjectId == 0 ? "inserting" : "updating")} object({dbType?.TableName}): {ex.Message}";
            logger.LogError($"Error dataContext.ObjectInfo_UpdateInsert {ex.ToStringForLog()} [obj={obj}, dObj={dObj}]");
            return View("EditItem", dObj!=null ? dObj : obj);
        }
        // return Redirect($"/adminobject/manualedit/{typeId}");
        if (!string.IsNullOrEmpty(returl))
        {
            returl = WebUtility.UrlDecode(returl);
            return Redirect(returl);
        }
        return RedirectToRoute(new { controller = "AdminObject", action = "EditItem", id = newObject.ObjectId });
    }


    private async Task UpdateInsertByRequest_ObjectLinkRubric(int objectId, int rubricId, int userId) {
        string updateLinkRubric = Request?.Form["updateLinkRubric"];
        if (updateLinkRubric != "1")
            return;
        string idRubricStr, sc;
        int idRubric, sortCode;
        // get all rubrics from the form
        int[] rubrics = new int[Request.Form["LinkRubricSelect"].Count];
        for (int i = 0; i < rubrics.Length; i++) {
            idRubricStr = Request.Form["LinkRubricSelect"][i];
            int.TryParse(idRubricStr, out rubrics[i]);
        }

        // delete all links for object
        await dataContext.ObjectLinkRubric_DeleteForObject(objectId, skipRubrics: rubrics);
        for (int i = 0; i < rubrics.Length; i++)
        {
            sc = Request?.Form[$"sortCode{rubrics[i]}"];    // optional
            int.TryParse(sc, out sortCode);
            if (rubrics[i] == rubricId)
                continue;
            await dataContext.ObjectLinkRubric_AddOrUpdateLink(rubricId: rubrics[i], objectId, sortCode, userId);
        }
    }


    private async Task<(string?, string? hash)> UploadFile(ObjectInfo obj, List<IFormFile> fileupload)
    {
        string? relativeFileName = null;
        string? hash = null;
        long fileSize = 0;
        if (fileupload is not null && fileupload.Count > 0)
        {
            if (fileupload.Count != 1)
            {
                throw new Exception($"Single file is required! [fileupload.Count={fileupload.Count}]");
            }

            var formFile = fileupload[0];

            string folder = config.GetRelativeFolderNameForObject(obj);
            // if (formFile is not { Length: > 0 }) return null;
            if (!Directory.Exists(config.MapStorageFile(folder)))
            {
                Directory.CreateDirectory(config.MapStorageFile(folder));
            }

            relativeFileName = Path.Combine(folder, formFile.FileName);
            string filePath = config.MapStorageFile(relativeFileName);
            await using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await formFile.CopyToAsync(stream);
                fileSize = formFile.Length;
            }
            hash = HashUtils.GetHash(filePath);
            relativeFileName = relativeFileName.Replace('\\', '/');
        }
        obj.ObjectFilePath = relativeFileName;
        obj.ObjectFileHash = hash;
        return (relativeFileName, hash);
    }


    [HttpPost]
    public async Task<IActionResult> Delete([FromForm] int objectId, [FromForm] int typeId) {
        string returl = Request.Form["returl"];
        try
        {
            ObjectInfo objOld = await HttpContext.GetObjectAndCheckWriteAccess(dataContext, objectId);   // Exception if no access
            int rowsAffected = await dataContext.ObjectInfo_Delete(objectId);
            TempData["Suc"] = $"Delete successful [{rowsAffected} row(s)]";
            logger.LogInformation($"Delete successful [ObjectId={objectId}, {rowsAffected} row(s) affected]");
        }
        catch (Exception ex)
        {
            TempData["Err"] = $"Error deleting object: {ex.Message}";
            logger.LogError($"Error dataContext.ObjectInfo_Delete {ex.ToStringForLog()}");
        }
        // return Redirect($"/adminobject/manualedit/{typeId}");
        if (!string.IsNullOrEmpty(returl))
        {
            returl = WebUtility.UrlDecode(returl);
            return Redirect(returl);
        }
        return RedirectToRoute(new { controller = "AdminObject", action = "List", id = typeId });
    }


    /// <summary>
    /// call from js function AssocSave() in /dragdrop.js
    ///     queryData = { "ObjectId": app.objectId, LinkTypeObjectId: $("#linkTypeObjectId").val(), Links: [{ "LinkedObjectId": id1, "SortCode": 10 }, { "LinkedObjectId": id2, "SortCode": 20 }] };
    /// </summary>
    /// <param name="objectLinks"></param>
    /// <returns></returns>
    [HttpPost]
    public async Task<IActionResult> LinksUpdate([FromBody] ObjectLinks objectLinks) {
        List<ObjectInfoLinked> rows = null;
        try
        {
            // All PowerUsers can update!
            // ObjectInfo objOld = await HttpContext.GetObjectAndCheckWriteAccess(dataContext, objectLinks.ObjectId);   // Exception if no access
            int userId = HttpContext.GetUserId();
            rows = await dataContext.ObjectLinkObject_LinksUpdate(userId, objectLinks);
            logger.LogInformation($"LinksUpdate successful [ObjectId={objectLinks.ObjectId}, {rows.Count} row(s)]");
        }
        catch (Exception ex)
        {
            logger.LogError($"Error dataContext.ObjectLinkObject_LinksUpdate {ex.ToStringForLog()}");
            return Json(new { error = ex.Message });
        }
        // return Redirect($"/adminobject/manualedit/{typeId}");
        return Json(rows);
    }


    /// <summary>
    /// Validated and GetDataValues
    /// </summary>
    /// <param name="objectId"></param>
    /// <returns></returns>
    [HttpPost]
    public async Task<IActionResult> GetDataValues(int objectId)
    {
        // HttpUtils.Log = x => logger.LogInformation(x);
        if (objectId == 0)
        {
            return Json(new TypeValidatorResult() { Code = 1, Message = $"objectId is undefined [{objectId}]" });
        }
        ObjectInfo obj = await dataContext.ObjectInfo_Get(objectId);
        Models.TypeInfo type = await dataContext.GetType(obj.TypeId);
        string? absolutePath = string.IsNullOrEmpty(obj.ObjectFilePath) ? null : config.MapStorageFile(obj.ObjectFilePath);
        Context context = await dataContext.ExtractContext(obj);
        (TypeValidatorResult res, DBUtils.DatabaseValues data) vr = type.ValidateFileAndGetDataValues(absolutePath, context);
        // HttpUtils.Log = null!;
        return Json(vr.data);
    }


    /// <summary>
    /// Delete all properties for object
    /// </summary>
    /// <param name="objectId"></param>
    /// <returns>JSON</returns>
    [HttpPost]
    public async Task<IActionResult> DeleteProperties(int objectId)
    {
        if (objectId == 0)
        {
            return Json(new TypeValidatorResult() { Code = 1, Message = $"objectId is undefined [{objectId}]" });
        }
        int rowsAffected = await dataContext.Property_Delete(objectId);
        var vr = new TypeValidatorResult() { Code = 0, Warning = $"{rowsAffected} properties deleted [ObjectId={objectId}]" };
        return Json(vr);
    }

    /// <summary>
    /// Delete all associated objects for an object
    /// </summary>
    /// <param name="objectId"></param>
    /// <returns>JSON</returns>
    [HttpPost]
    public async Task<IActionResult> DeleteAssocObjects(int objectId)
    {
        if (objectId == 0)
        {
            return Json(new TypeValidatorResult() { Code = 1, Message = $"objectId is undefined [{objectId}]" });
        }
        int rowsAffected = await dataContext.ObjectInfo_DeleteNestedObjects(objectId);
        var vr = new TypeValidatorResult() { Code = 0, Warning = $"{rowsAffected} objects deleted [associated with ObjectId={objectId}]" };
        return Json(vr);
    }

}