using Azure.Core;
using FluentValidation;
using FluentValidation.AspNetCore;
using FluentValidation.Results;
using InfProject.DBContext;
using InfProject.Models;
using InfProject.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using Microsoft.CodeAnalysis.Elfie.Diagnostics;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Data;
using System.Net;
using System.Reflection;
using System.Text;
using System.Web;
using TypeValidationLibrary;
using WebUtilsLib;
using static System.Runtime.InteropServices.JavaScript.JSType;
using static WebUtilsLib.DBUtils;

namespace InfProject.Controllers;

[Authorize(Roles = "User,PowerUser,Administrator")]
public class CustomController : Controller
{
    private readonly IValidator<ObjectInfo> validator;
    private readonly ILogger<CustomController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;
    private readonly IWebHostEnvironment webHostEnvironment;
    private readonly ICompositeViewEngine viewEngine;

    public CustomController(IValidator<ObjectInfo> validator, ILogger<CustomController> logger, IConfiguration config, DataContext dataContext, IWebHostEnvironment webHostEnvironment, ICompositeViewEngine viewEngine)
    {
        this.validator = validator;
        this.logger = logger;
        this.config = config;
        this.dataContext = dataContext;
        this.webHostEnvironment = webHostEnvironment;
        this.viewEngine = viewEngine;
    }

    #region Sample

    public async Task<IActionResult> EditSample([FromRoute(Name = "id")] int idObject)
    {
        //string returl = Request.Query["returl"];
        string idrSt = Request.Query["idr"];
        int.TryParse(idrSt, out int idr);
        RubricInfo? rubric = idr != 0 ? await dataContext.GetRubricById(idr) : new RubricInfo();
        //(ObjectInfo obj, Models.TypeInfo dbType) = await dataContext.ObjectInfo_GetVirtualWrapper(idObject);
        ObjectInfo objBare = await dataContext.ObjectInfo_Get(idObject, DataContext.SampleTypeId);  // find object
        SampleFull obj = idObject != 0 && objBare != null && !string.IsNullOrEmpty(objBare?.ObjectNameUrl)
            ? (await dataContext.ObjectInfo_GetVirtual<Sample>(idObject)).ToSampleFull(dataContext) // await dataContext.ObjectInfo_Get(idObject)
            : new SampleFull(new Sample(), substrateObjectId: 0, type: SampleFull.SampleType.MaterialsLibrary, waferId: null) { TenantId = dataContext.TenantId, TypeId = DataContext.SampleTypeId /* Sample */, RubricId = rubric?.RubricId ?? 0, AccessControl = dataContext.Tenant.AccessControl };
        //ViewBag.dbType = dbType;
        ViewBag.controllerContext = ControllerContext;
        ViewBag.viewEngine = viewEngine;
        return View(obj);
    }

    /// <summary>
    /// create a new processing step for a sample (effective this is a new sample with the samе SampleID == ExternalId)
    /// </summary>
    /// <param name="ObjectId">parent object ObjectId</param>
    /// <param name="AddProcessingStepDescription">description for a new sample</param>
    /// <returns>redirects to edit of a new sample</returns>
    [HttpPost]
    public async Task<IActionResult> SampleAddProcessingStep(
        [FromForm(Name = "ObjectId")] int objectId,
        [FromForm(Name = "AddProcessingStepDescription")] string description)
    {
        int newSampleId = 0;
        int userId = HttpContext.GetUserId();
        try
        {
            newSampleId = await dataContext.SampleAddProcessingStep(objectId, description, userId);
            TempData["Suc"] = $"Sample add processing step successful";
            logger.LogInformation($"Sample add processing step successful [parentObjectId={objectId}, newObjectId={newSampleId}]");
        }
        catch (Exception ex)
        {
            TempData["Err"] = $"Error adding processing step : {ex.Message}";
            logger.LogError($"Error dataContext.SampleAddProcessingStep {ex.ToStringForLog()} [parentObjectId={objectId}]");
        }
        return RedirectToRoute(new { controller = "Custom", action = "EditSample", id = newSampleId });
    }


    /// <summary>
    /// create a new processing step for a sample (effective this is a new sample with the samе SampleID == ExternalId)
    /// </summary>
    /// <param name="ObjectId">parent object ObjectId</param>
    /// <param name="AddProcessingStepDescription">description for a new sample</param>
    /// <param name="PiecesCount">number of subsamples</param>
    /// <returns>redirects to edit of a new sample</returns>
    [HttpPost]
    public async Task<IActionResult> SampleSplitIntoPieces(
        [FromForm(Name = "ObjectId")] int objectId,
        [FromForm(Name = "SplitIntoPiecesDescription")] string description,
        [FromForm(Name = "PiecesCount")] int piecesCount)
    {
        int newSampleId = 0;
        int userId = HttpContext.GetUserId();
        try
        {
            newSampleId = await dataContext.SampleSplitIntoPieces(objectId, description, userId, piecesCount);
            TempData["Suc"] = $"Sample split successful";
            logger.LogInformation($"Sample split successful [parentObjectId={objectId}, newObjectId={newSampleId}]");
        }
        catch (Exception ex)
        {
            TempData["Err"] = $"Error splitting sample : {ex.Message}";
            logger.LogError($"Error dataContext.SampleSplitIntoPieces {ex.ToStringForLog()} [parentObjectId={objectId}]");
        }
        return RedirectToRoute(new { controller = "Custom", action = "EditSample", id = newSampleId });
    }



    [HttpPost]
    public async Task<IActionResult> UpdateSample([FromForm] /*ObjectInfo*/ SampleFull obj, List<IFormFile> fileupload, [FromForm] int deletefile = 0)
    {
        int substrateObjectId = int.Parse(Request.Form["SubstrateObjectId"]);
        string returl = Request.Form["returl"];
        Type t = null!;
        dynamic dObj = null!;
        /*ObjectInfo*/
        SampleFull newObject = null!;
        Models.TypeInfo dbType = await dataContext.GetType(obj.TypeId);
        dbType = (Models.TypeInfo)dbType.Clone();   // CLONE (otherwise will affect ahile types list)
        dbType.TableName = "SampleFull";
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

            if (dbType.TableName != "ObjectInfo")
            {
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
                return View("EditSample", dObj != null ? dObj as ObjectInfo : obj);
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
                        TempData["Err"] = $"Error validating model ({dbType.TableName}): {result}";
                        return View("EditSample", dObj);
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
            //if (dbType.TableName == "ObjectInfo")
            //{
            //    newObject = await dataContext.ObjectInfo_UpdateInsert(obj);
            //}
            //else {
            MethodInfo methodInfo = typeof(DataContext).GetMethod("ObjectInfo_UpdateInsertVirtual");
            MethodInfo genericMethodInfo = methodInfo.MakeGenericMethod(t);
            dynamic res = genericMethodInfo.Invoke(dataContext, new object[] { dObj });
            newObject = res.Result;
            //}

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

            // possible File Upload

            (string uploadedRelativeFileName, string hash) = await UploadFile(newObject, fileupload);
            int rowsAffected = 0, isValid = 0;
            if (!string.IsNullOrEmpty(uploadedRelativeFileName))
            {  // file Uploaded
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
                    else
                    { // fail
                        TempData["Suc"] = string.Empty;
                        TempData["Suc"] = string.Empty;
                        TempData["Err"] = "File verification " + fileValidationResult + (string.IsNullOrEmpty(objOld?.ObjectFilePath) ? " [no file attached]" : " [previous file version is retained]");
                        if (System.IO.File.Exists(newPath))
                        {
                            System.IO.File.Delete(newPath);
                        }
                    }
                }
                catch (Exception ex)
                {
                    TempData["Suc"] = string.Empty;
                    TempData["Err"] = $"Error {(obj.ObjectId == 0 ? "inserting" : "updating")} file({dbType?.TableName}): {ex.Message}";
                    logger.LogError($"Error dataContext.ObjectInfo_UpdateInsert {TempData["Err"]} {ex.ToStringForLog()} [obj={obj}, dObj={dObj}]");
                    if (isValid == 0 && string.Compare(oldObjectFilePath, uploadedRelativeFileName, ignoreCase: true) != 0
                        && System.IO.File.Exists(newPath))
                    {
                        System.IO.File.Delete(newPath);
                    }
                }
            }
            obj.ObjectId = newObject.ObjectId;



            // Fix NAME
            // await dataContext.FinalizeSample(newObject.ObjectId, $"{newObject.ExternalId} sample ");
            await dataContext.FinalizeSampleName(newObject.ObjectId, $"{newObject.ExternalId} ");
        }
        catch (Exception ex)
        {
            TempData["Err"] = $"Error {(obj.ObjectId == 0 ? "inserting" : "updating")} object({dbType?.TableName}): {ex.Message}";
            logger.LogError($"Error dataContext.ObjectInfo_UpdateInsert {ex.ToStringForLog()} [obj={obj}, dObj={dObj}]");
            return View("EditSample", dObj != null ? dObj : obj);
        }
        // return Redirect($"/adminobject/manualedit/{typeId}");
        if (!string.IsNullOrEmpty(returl))
        {
            returl = WebUtility.UrlDecode(returl);
            return Redirect(returl);
        }
        return RedirectToRoute(new { controller = "Custom", action = "EditSample", id = newObject.ObjectId });
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

    #endregion

    #region SynthesisPrint support

    public class GetPrintersObject
    {
        public string[] printers;
    }



    private static readonly object lockObject = new object();
    public static string[] printers = null;
    /// <summary>
    /// printers list from external application
    /// </summary>
    public string[] Printers
    {
        get
        {
            if (printers != null)
            {
                return printers;
            }
            lock (lockObject)
            {
                // read settings "External:LabelPrinter:PrinterListUrl"
                string url = config.GetValue<string>("External:LabelPrinter:PrinterListUrl") ?? string.Empty;
                if (string.IsNullOrEmpty(url))
                {
                    return printers = Array.Empty<string>();
                }

                string printersJson = null, printersJsonFromService = null;
                // cache
                string fullPrintersFilePath = config.MapStorageFile($"/tenant{dataContext.TenantId}/printers.json");
                FileInfo fi = new FileInfo(fullPrintersFilePath);
                if (fi.Exists)  // read from cache
                {
                    printersJson = System.IO.File.ReadAllText(fullPrintersFilePath, System.Text.Encoding.UTF8);
                    if (fi.LastWriteTime.AddDays(3) < DateTime.Now)
                    {   // cache expired => update
                        try
                        {
                            printersJson = printersJsonFromService = HttpUtils.GetStringByHttpGet(url).Result;
                        }
                        catch (Exception ex)
                        {
                            logger.LogError($"Error 1 CustomController.Printers.GetStringByHttpGet {ex.ToStringForLog()} [url={url}]");
                        }
                    }
                }
                else
                {  // need to get printers from service
                    try
                    {
                        printersJson = printersJsonFromService = HttpUtils.GetStringByHttpGet(url).Result;
                    }
                    catch (Exception ex)
                    {
                        logger.LogError($"Error 2 CustomController.Printers.GetStringByHttpGet {ex.ToStringForLog()} [url={url}]");
                    }
                }
                GetPrintersObject prn = JsonConvert.DeserializeObject<GetPrintersObject>(printersJson);
                printers = prn.printers;    // here we have deserialized printers list
                if (!string.IsNullOrEmpty(printersJsonFromService))
                {
                    System.IO.File.WriteAllText(fullPrintersFilePath, printersJsonFromService, System.Text.Encoding.UTF8);    // save cache
                }
                return printers;
            }
        }
    }

    /// <summary>
    /// get printers list
    /// </summary>
    /// <returns></returns>
    public async Task<IActionResult> GetPrinters()
    {
        //string[] printers = {"IC", "IAN", "ZGH" };    // debug
        string[] printers = Printers;
        return Json(printers);
    }


    private string GetPrintUrlFromSettings()
    {
        string url = config.GetValue<string>("External:LabelPrinter:PrintUrl") ?? string.Empty;
        return url;
    }

    // read settings "ExternalPrintUrl" and return it as json
    public async Task<IActionResult> GetPrintUrl()
    {
        string url = GetPrintUrlFromSettings();
        return Json(new { url });
    }

    /// <summary>
    /// Response from WebApi (methos print)
    /// </summary>
    public class PrintResponse
    {
        public bool success;
        public string reason;
        public string description;

        public TypeValidatorResult GetTypeValidatorResult()
        {
            return new TypeValidatorResult(code: success ? 0 : 500, message: reason, warning: description);
        }
    }

    /// <summary>
    /// prints label on a label printer and return json (aka validation)
    /// </summary>
    /// <param name="objectId"></param>
    /// <param name="externalId"></param>
    /// <param name="printer"></param>
    /// <returns></returns>
    [HttpPost]
    public async Task<IActionResult> Print(int objectId, int externalId, string printer)
    {
        TypeValidatorResult vr = null;
        string retString = null;
        try
        {
            string url = GetPrintUrlFromSettings();
            if (string.IsNullOrEmpty(url))
            {
                return Json(new TypeValidatorResult(400, $"Settings Key External:LabelPrinter:PrintUrl is null or empty", null));
            }
            string json = await GetJsonDocumentForPrint(objectId, externalId);  // get json with a single synthesis document
            if (string.IsNullOrEmpty(json))
            {
                return Json(new TypeValidatorResult(400, $"GetJsonDocumentForPrint is null or empty [objectId={objectId}, externalId={externalId}]", null));
            }
            //string strData = $"printer={HttpUtility.UrlEncode(printer)}&json={HttpUtility.UrlEncode(json)}";
            string strData = json;
            byte[] data = Encoding.UTF8.GetBytes(strData);
            retString = await HttpUtils.GetStringByHttpPost($"{url}?printer={HttpUtility.UrlEncode(printer)}", data, "application/json"
                /*"application/octet-stream""application/x-www-form-urlencoded"*/);
            PrintResponse prnResponse = JsonConvert.DeserializeObject<PrintResponse>(retString);
            vr = prnResponse.GetTypeValidatorResult();
        }
        catch (Exception ex)
        {
            logger.LogError($"Error CustomController.Print {ex.ToStringForLog()} [objectId={objectId}, externalId={externalId}, retString={retString}]");
            return Json(new TypeValidatorResult(500, ex.Message, string.Empty));
        }
        return Json(vr);
    }


    /// <summary>
    /// Get Json (for printing labels) 
    /// UPDATE: now if we have several synthesis documents - we search for a synthesis document with "Int" property "Main4Printing" set to 1.
    /// OBSOLETE: for the first (we consider ObjectId ASC) synthesis document (TypeId=DataContext.SynthesisTypeId) for the sample (TypeId=DataContext.SampleTypeId) identified either by ObjectId or ExternalId
    /// </summary>
    /// <param name="objectId">ObjectId - priority over ExternalId (if ObjectId!=0)</param>
    /// <param name="externalId">ExternalId = aka SampleID - used if ObjectId is not set (i.e. != 0)</param>
    /// <returns>Json</returns>
    private async Task<string> GetJsonDocumentForPrint(int objectId, int externalId)
    {
        IActionResult ar = await GetJsonForPrint(objectId, externalId);
        switch (ar)
        {
            case NotFoundObjectResult notFoundObjectResult:
                throw new FileNotFoundException(notFoundObjectResult?.Value?.ToString());
            case NotFoundResult notFoundResult:
                return notFoundResult.ToString();
            case RedirectResult redirectResult:
            case RedirectToRouteResult redirectToRouteResult:
            case RedirectToActionResult redirectToActionResult:
            case ObjectResult objectResult:
            case StatusCodeResult statusCodeResult when statusCodeResult.StatusCode == 404:
                return null;
            case JsonResult jsonResult:
                return jsonResult.Value as string;
            case ContentResult contentResult:
                return contentResult.Content;
            default:
                return null;
        }
    }


    /// <summary>
    /// Get Json (for printing labels) for the first (we consider ObjectId ASC) synthesis document (TypeId=DataContext.SynthesisTypeId) for the sample (TypeId=DataContext.SampleTypeId) identified either by ObjectId or ExternalId
    /// </summary>
    /// <param name="objectId">ObjectId - priority over ExternalId (if ObjectId!=0)</param>
    /// <param name="externalId">ExternalId = aka SampleID - used if ObjectId is not set (i.e. != 0)</param>
    /// <returns>Json</returns>
    [HttpGet]
    public async Task<IActionResult> GetJsonForPrint(int objectId, int externalId)
    {
        /*
            select ParentObjectId, ParentExternalId, count(ChildObjectId) as cnt
            from vObjectLinkObject
            WHERE ParentTypeId=6 and ChildTypeId=18
            group by  ParentObjectId, ParentExternalId
            having count(ChildObjectId)>1
            order by cnt desc
        */
        // https://mdi.matinf.pro/custom/getjsonforprint?externalid=10374 - new example
        // https://mdi.matinf.pro/custom/getjsonforprint?externalid=4450 - 3 doc
        // https://mdi.matinf.pro/custom/getjsonforprint?objectid=0&externalid=1192 - 1 doc
        // https://mdi.matinf.pro/custom/getjsonforprint?objectid=0&externalid=5323 - 1 doc
        // https://mdi.matinf.pro/custom/getjsonforprint?objectid=0&externalid=1662 - 15 doc (empty)
        // https://mdi.matinf.pro/custom/getjsonforprint?objectid=0&externalid=6784 - 12 doc (not empty)
        ObjectInfo o = null, oSynth = null;
        Sample oSample = null;

        // try to find objectId if neccesary
        if (objectId == 0)
        {
            o = await dataContext.ObjectInfo_GetByExternalId(externalId, DataContext.SampleTypeId);
            objectId = o?.ObjectId ?? 0;
        }
        if (objectId != 0)
        {
            oSample = await dataContext.ObjectInfo_GetVirtual<Sample>(objectId);
        }
        if (oSample == null || objectId == 0)
        {
            return NotFound($"Can not find sample object (objectId={objectId}, externalId={externalId})");
        }

        // here we know ObjectId of the sample => let's detect the first synthesis document id (we consider ChildObjectId)
        int synthesisObjectId = await dataContext.GetList_ExecDevelopmentScalar<int>($@"DECLARE @count as int, @MinChildObjectId as int;
select @count = count(ChildObjectId), @MinChildObjectId = MIN(ChildObjectId) 
FROM dbo.vObjectLinkObject fs where ParentTypeId=@SampleTypeId and ChildTypeId=@SynthesisTypeId and ParentObjectId=@id;
-- PRINT '0. count='+CAST(@count as varchar(16)) + '; @MinChildObjectId' + CAST(@MinChildObjectId as varchar(16))
if @count>1	-- several synthesis documents => Find a document with Int Main4Printing=1
begin
	SET @count=0;
	SET @MinChildObjectId=0;
	select @MinChildObjectId=MIN(fs.ChildObjectId), @count=count(fs.ChildObjectId)
	FROM dbo.vObjectLinkObject fs
	LEFT OUTER JOIN dbo.PropertyInt as P ON P.ObjectId=fs.ChildObjectId AND P.PropertyName='Main4Printing'
		where fs.ParentTypeId=@SampleTypeId and fs.ChildTypeId=@SynthesisTypeId and fs.ParentObjectId=@id 
            AND P.[Value]=1
	GROUP BY fs.ChildObjectId;
-- PRINT '1. count='+CAST(@count as varchar(16)) + '; @MinChildObjectId' + CAST(@MinChildObjectId as varchar(16))
	if @count=0
		SELECT -1 as [Result];	-- several synth documents, but no Int Main4Printing=1 property
end
ELSE
begin
	if @count=1
	begin 
		select @MinChildObjectId as [Result];
	end
	else
	begin	-- no synthesis documents found
		SELECT 0 as [Result];
	end
END", new { id = objectId, DataContext.SampleTypeId, DataContext.SynthesisTypeId });
        if (synthesisObjectId == -1)
        {
            return NotFound($"You should add an integer \"Main4Printing\" property with a value==1 for main synthesis document for printing");
        }
        oSynth = await dataContext.ObjectInfo_Get(synthesisObjectId, DataContext.SynthesisTypeId);
        if (oSynth == null || synthesisObjectId == 0)
        {
            return NotFound($"Can not find sample synthesis (synthesisObjectId={synthesisObjectId})");
        }
        if (HttpContext.IsReadDenied(oSynth.AccessControl, (int)oSynth._createdBy))
        {
            return this.RedirectToLoginOrAccessDenied(HttpContext);
        }
        string system = oSample.Elements?.Trim('-');
        int sampleId = (int)oSample.ExternalId;
        int waferId = await dataContext.GetList_ExecDevelopmentScalar<int>($@"select TOP 1 [Value] FROM dbo.PropertyInt WHERE ObjectId=@objectId AND PropertyName='Wafer ID'", new { objectId });
        string creator = dataContext.GetUser((int)oSample._createdBy).Result.Name;
        RubricInfo rubric = await dataContext.GetRubricById((int)oSample.RubricId);
        //string[] rubrics = rubric.RubricPath.Split(new char[] { '}' }, StringSplitOptions.RemoveEmptyEntries);
        //string first_level_project = rubrics.Length > 0 ? rubrics[0] : null;
        //string last_level_project = rubrics.Length > 0 ? rubrics[rubrics.Length-1] : null;
        int substrateObjectId = await dataContext.GetList_ExecDevelopmentScalar<int>($@"select TOP 1 ChildObjectId as SynthesisObjectId FROM dbo.vObjectLinkObject fs
where ParentTypeId=@SampleTypeId and ChildTypeId=@SubstrateTypeId and ParentObjectId=@id
ORDER BY ChildObjectId", new { id = objectId, DataContext.SampleTypeId, DataContext.SubstrateTypeId });
        ObjectInfo substrateObj = await dataContext.ObjectInfo_Get(substrateObjectId, DataContext.SubstrateTypeId);
        string substrate = substrateObj?.ObjectName;
        string sample_description = oSample.ObjectDescription;
        // Model.Elements = Model.Elements?.Trim('-');
        /*
        {
          "system": "Ag-Au-Pd-Pt-Ru",
          "sample-id": 10437,
          "wafer-id": 0,
          "first-level-project": "CRC 1625",
          "last-level-project": "Ag-Au-Pd-Pt-Ru",
          "creator": "Natalia Pukhareva",
          "process-id": "240702-K8-3",
          "substrate": "Sapphire",
          "process-temperature": 20,
          "sample-description": "Permutation of 0010268, 15nm Ta layer, 3 mTorr",
          "chamber": "K8",
          "targets": {
            "2": "Au",
            "3": "Ag",
            "4": "Pt",
            "5": "Ru",
            "6": "Pd",
            "7": "Ta"
          }
        }
        */

        string sql = $@"SET NOCOUNT ON;
DECLARE @json varchar(max) = (Select * FROM (
SELECT 'system' as [name], @system as [value] UNION ALL
SELECT 'sample-id' as [name], @sampleId as [value] UNION ALL
SELECT 'wafer-id' as [name], @waferId as [value] UNION ALL
SELECT 'project' as [name], @project as [value] UNION ALL
SELECT 'creator' as [name], @creator as [value] UNION ALL
SELECT 'substrate' as [name], @substrate as [value] UNION ALL
SELECT 'sample-description' as [name], @sample_description as [value] UNION ALL
SELECT TOP 1 'general process parameters => chamber' as [name], SUBSTRING(@name, PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9]-K_-[0-9]%', @name)+7, 2) as [value] FROM dbo.fn_GetObjectProperties(@id) 
				WHERE PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9]-K_-[0-9]%', @name)>0 AND NOT EXISTS (select PropertyStringId FROM dbo.PropertyString WHERE PropertyName='general process parameters => chamber' AND ObjectId=@id)
			UNION
			SELECT TOP 1 'general process parameters => process id' as [name], SUBSTRING(@name, PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9]-K_-[0-9]%', @name), 11) as [value] FROM dbo.fn_GetObjectProperties(@id) 
				WHERE PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9]-K_-[0-9]%', @name)>0
			UNION
			SELECT PropertyName as [name], [Value] FROM dbo.fn_GetObjectProperties(@id) 
) innerQ-- order by name
for json auto);
SET NOCOUNT OFF;
SELECT @json as [Json]";
        string json = await dataContext.GetList_ExecDevelopmentScalar<string>(sql, new
        {
            id = synthesisObjectId,
            name = oSynth.ObjectName,
            system,
            sampleId = sampleId.ToString(),
            waferId = waferId.ToString(),
            creator,
            substrate,
            sample_description,
            project = rubric.RubricPath
        });
        return Content(json, "application/json");
    }

    #endregion


    #region Synthesis support
    /// <summary>
    /// Get Json for combined synthesis documents (TypeId=DataContext.SynthesisTypeId) for the sample (TypeId=DataContext.SampleTypeId) identified either by ObjectId or ExternalId
    /// </summary>
    /// <param name="objectId">ObjectId - priority over ExternalId (if ObjectId!=0)</param>
    /// <param name="externalId">ExternalId = aka SampleID - used if ObjectId is not set (i.e. != 0)</param>
    /// <returns>Json</returns>
    [HttpGet]
    public async Task<IActionResult> GetSynthesisJsonForSample(int objectId, int externalId)
    {
        /*
            select ParentObjectId, ParentExternalId, count(ChildObjectId) as cnt
            from vObjectLinkObject
            WHERE ParentTypeId=6 and ChildTypeId=18
            group by  ParentObjectId, ParentExternalId
            having count(ChildObjectId)>1
            order by cnt desc
        */
        // https://mdi.matinf.pro/custom/getsynthesisjsonforsample?externalid=4450 - 3 doc
        // https://mdi.matinf.pro/custom/getsynthesisjsonforsample?objectid=0&externalid=1192 - 1 doc
        // https://mdi.matinf.pro/custom/getsynthesisjsonforsample?objectid=0&externalid=5323 - 1 doc
        // https://mdi.matinf.pro/custom/getsynthesisjsonforsample?objectid=0&externalid=1662 - 15 doc (empty)
        // https://mdi.matinf.pro/custom/getsynthesisjsonforsample?objectid=0&externalid=6784 - 12 doc (not empty)
        // https://mdi.matinf.pro/custom/getsynthesisjsonforsample?objectid=0&externalid=10562 - 2 doc (1 is empty)
        ObjectInfo o;
        if (objectId != 0)
        {
            o = await dataContext.ObjectInfo_Get(objectId, DataContext.SampleTypeId);
        }
        else
        {
            o = await dataContext.ObjectInfo_GetByExternalId(externalId, DataContext.SampleTypeId);
        }
        if (o == null || o.ObjectId == 0)
        {
            return NotFound($"Can not find object ({objectId}, {externalId})");
        }
        if (HttpContext.IsReadDenied(o.AccessControl, (int)o._createdBy))
        {
            return this.RedirectToLoginOrAccessDenied(HttpContext);
        }
        string sql = $@"SET NOCOUNT ON;
DECLARE @json varchar(max) = (Select ObjectId=ChildObjectId, ObjectName = fs.ChildObjectName, 
      Parameters = (
		SELECT [name], [type], [value], [sortcode], [comment] FROM (
			SELECT TOP 1 'general process parameters => chamber' as [name], 'String' as [type], SUBSTRING(fs.ChildObjectName, PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9]-K_-[0-9]%', fs.ChildObjectName)+7, 2) as [value], -2 as [sortcode], 'calculated additionally' as [comment]
                -- FROM dbo.fn_GetObjectProperties(fs.LinkedObjectId) WHERE PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9]-K_-[0-9]%', fs.ChildObjectName)>0 AND NOT EXISTS (select PropertyStringId FROM dbo.PropertyString WHERE PropertyName='general process parameters => chamber' AND ObjectId=fs.LinkedObjectId)
				FROM dbo.vObjectLinkObject WHERE ObjectLinkObjectId=fs.ObjectLinkObjectId AND PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9]-K_-[0-9]%', fs.ChildObjectName)>0 AND NOT EXISTS (select PropertyStringId FROM dbo.PropertyString WHERE PropertyName='general process parameters => chamber' AND ObjectId=fs.LinkedObjectId)
			UNION
			SELECT TOP 1 'general process parameters => process id' as [name], 'String' as [type], SUBSTRING(fs.ChildObjectName, PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9]-K_-[0-9]%', fs.ChildObjectName), 11) as [value], -1 as [sortcode], 'calculated additionally' as [comment]
                -- FROM dbo.fn_GetObjectProperties(fs.LinkedObjectId) WHERE PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9]-K_-[0-9]%', fs.ChildObjectName)>0
				FROM dbo.vObjectLinkObject WHERE ObjectLinkObjectId=fs.ObjectLinkObjectId AND PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9]-K_-[0-9]%', fs.ChildObjectName)>0
			UNION
			SELECT PropertyName as [name], PropertyType as [type], [Value], SortCode as [sortcode], Comment as [comment] FROM dbo.fn_GetObjectProperties(fs.LinkedObjectId) 
			) innerQ ORDER BY [sortcode]
			FOR JSON AUTO
		)
FROM dbo.vObjectLinkObject fs
where ParentTypeId=@SampleTypeId and ChildTypeId=@SynthesisTypeId and Parent{(objectId != 0 ? "ObjectId" : "ExternalId")}=@id
ORDER BY ObjectId
  For JSON path, without_array_wrapper);
SET NOCOUNT OFF;
SELECT @json as [Json]";
        int id = objectId != 0 ? objectId : externalId;
        string json = await dataContext.GetList_ExecDevelopmentScalar<string>(sql, new { id, DataContext.SampleTypeId, DataContext.SynthesisTypeId });
        json = $"{{ \"ProcessingStep\": [{json}]}}";
        string origin = Request.Query["origin"];
        if (!string.IsNullOrEmpty(origin))
        {
            Response.Headers.Add("Access-Control-Allow-Origin", origin);
        }
        return Content(json, "application/json");
    }



    public class SynthObjects
    {
        public List<ObjProp> ProcessingStep { get; set; } = new List<ObjProp>();
    }

    public class ObjProp
    {
        public int ObjectId;
        public List<PropValue> Parameters { get; set; } = new List<PropValue>();
    }

    public class PropValue
    {
        public string name { get; set; }
        public string type { get; set; }
        public string value { get; set; }
        public int sortcode { get; set; }
        public string comment { get; set; }
        public override string ToString() => $"{type}) {name} = {value} [{sortcode}, {comment}]";
    }


    /// <summary>
    /// Updates Json for combined synthesis documents (TypeId=DataContext.SynthesisTypeId) for the sample (TypeId=DataContext.SampleTypeId) identified either by ObjectId or ExternalId
    /// </summary>
    /// <param name="objectId">ObjectId - priority over ExternalId (if ObjectId!=0)</param>
    /// <param name="externalId">ExternalId = aka SampleID - used if ObjectId is not set (i.e. != 0)</param>
    /// <param name="jsonObj">SynthObjects</param>
    /// <returns>Json</returns>
    [HttpPost]
    public async Task<IActionResult> UpdateSynthesisJsonForSample(int objectId, int externalId, /*SynthObjects jsonObj*/ string jsonObj)
    {
        TypeValidatorResult vr = null;
        try
        {
            if (objectId == 0 && externalId == 0)
            {
                return new JsonResult(new TypeValidatorResult(400, "objectId and externalId are not set [objectId == 0 && externalId==0]"));
            }
            if (string.IsNullOrEmpty(jsonObj))
            {
                return new JsonResult(new TypeValidatorResult(400, "jsonObj is null or empty [string.IsNullOrEmpty(jsonObj)]"));
            }

            JObject jsonData = JObject.Parse(jsonObj);
            ObjectInfo o;
            if (objectId != 0)
            {
                o = await dataContext.ObjectInfo_Get(objectId, DataContext.SampleTypeId);
            }
            else
            {
                o = await dataContext.ObjectInfo_GetByExternalId(externalId, DataContext.SampleTypeId);
            }
            if (o == null || o.ObjectId == 0)
            {
                return NotFound($"Can not find object ({objectId}, {externalId})");
            }
            int userId = HttpContext.GetUserId();
            if (HttpContext.IsWriteDenied(o.AccessControl, (int)o._createdBy))
            {
                return this.RedirectToLoginOrAccessDenied(HttpContext);
            }
            vr = await dataContext.UpdateSynthesisBatch(userId, o, jsonData);
        }
        catch (Exception ex)
        {
            vr = new TypeValidatorResult(500, $"{ex.GetType()} {ex.Message}", ex.StackTrace);
            logger.LogError($"Error CustomController.UpdateSynthesisJsonForSample {ex.ToStringForLog()} [objectId={objectId}, externalId={externalId}, jsonObj={jsonObj}]");
        }
        return new JsonResult(vr);
    }
    #endregion
}