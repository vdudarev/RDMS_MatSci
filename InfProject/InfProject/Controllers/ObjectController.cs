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
using System.IO.Pipelines;
using System.Reflection;
using System.Runtime.InteropServices.JavaScript;
using System.Security.Claims;
using System.Security.Policy;
using System.Text;
using System.Threading.Tasks;
using TypeValidationLibrary;
using WebUtilsLib;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;
using static System.Net.Mime.MediaTypeNames;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace InfProject.Controllers;

[Route("object")]
public class ObjectController : Controller
{
    private readonly IValidator<ObjectInfo> validator;
    private readonly ILogger<ObjectController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;
    private readonly IWebHostEnvironment webHostEnvironment;
    private readonly ICompositeViewEngine viewEngine;

    public ObjectController(IValidator<ObjectInfo> validator, ILogger<ObjectController> logger, IConfiguration config, DataContext dataContext, IWebHostEnvironment webHostEnvironment, ICompositeViewEngine viewEngine)
    {
        this.validator = validator;
        this.logger = logger;
        this.config = config;
        this.dataContext = dataContext;
        this.webHostEnvironment = webHostEnvironment;
        this.viewEngine = viewEngine;
    }

    /// <summary>
    /// redirect to object by it's ObjectId
    /// </summary>
    /// <param name="id">ObjectId</param>
    /// <param name="typeId">optional TypeId (if >0, then considered)</param>
    /// <returns></returns>
    [HttpGet("id/{id}")]
    public async Task<IActionResult> Id([FromRoute] int id, [FromQuery] int typeId)
    {
        ObjectInfo obj = await dataContext.ObjectInfo_Get(id, typeId);
        if (obj == null || string.IsNullOrEmpty(obj.ObjectNameUrl)) {
            //return NotFound($"Can not find object by id: {id}");
            TempData["Err"] = $"Can not find object by id: {id}{(typeId != 0 ? $" [typeId={typeId}]" : string.Empty)}";
            return Redirect("/");
        }
        return Redirect($"/object/{obj?.ObjectNameUrl}");
    }


    /// <summary>
    /// redirect to object by it's ExternalId
    /// </summary>
    /// <param name="id">ExternalId</param>
    /// <param name="typeId">optional TypeId (if >0, then considered)</param>
    /// <returns></returns>
    [HttpGet("externalid/{id}")]
    public async Task<IActionResult> ExternalId([FromRoute] int id, [FromQuery] int typeId=0)
    {
        ObjectInfo obj = await dataContext.ObjectInfo_GetByExternalId(id, typeId);
        if (obj == null || string.IsNullOrEmpty(obj.ObjectNameUrl))
        {
            //return NotFound($"Can not find object by id: {id}");
            TempData["Err"] = $"Can not find object by external id: {id}{(typeId!=0 ? $" [typeId={typeId}]" : string.Empty)}";
            return Redirect("/");
        }
        return Redirect($"/object/{obj?.ObjectNameUrl}");
    }


    [HttpGet("{url}")]
    public async Task<IActionResult> Index([FromRoute] string url) {
        ObjectInfo o = await dataContext.GetObjectByUrl(url);
        if (o == null || o.ObjectId == 0)
        {
            return NotFound($"Can not find object by url: {url}");
        }
        if (HttpContext.IsReadDenied(o.AccessControl, (int)o._createdBy))
        {
            return this.RedirectToLoginOrAccessDenied(HttpContext);
        }
        (ObjectInfo obj, Models.TypeInfo dbType) = await dataContext.ObjectInfo_GetVirtualWrapper(o.ObjectId);
        return View("Object", (obj, dbType, ControllerContext, viewEngine));
    }


    /// <summary>
    /// Validate file for Object Id through the schema in DB
    /// </summary>
    /// <param name="id">Object Id</param>
    /// <returns>JSON or access error</returns>
    [HttpGet("validate/{id}")]
    public async Task<IActionResult> Validate([FromRoute] int id)
    {

        var obj = await dataContext.ObjectInfo_Get(id);
        if (HttpContext.IsReadDenied(obj.AccessControl, (int)obj._createdBy) && !HttpContext.User.HasClaim(AdminObjectController.ClaimNameToShowAllObjects, "1"))
        {
            return this.RedirectToLoginOrAccessDenied(HttpContext);
        }
        string relFileName = obj.ObjectFilePath;
        string absFileName = string.IsNullOrEmpty(relFileName) ? null : config.MapStorageFile(relFileName);

        // currently any existing file is valid for any existing type...
        var type = await dataContext.GetType(obj.TypeId);
        TypeValidatorResult vr = type.ValidateFile(absFileName);
        return Json(vr);
    }


    /// <summary>
    /// Validate file for Object Id through the schema in DB and, if successful, reloads data from the file
    /// </summary>
    /// <param name="id">Object Id</param>
    /// <returns>JSON or access error</returns>
    [HttpPost("reload/{id}")]
    public async Task<IActionResult> Reload([FromRoute] int id)
    {
        int userId = HttpContext.GetUserId();
        // access rights are checked inside of ValidationAndUploadDatabaseValues.UploadDatabaseValues
        (TypeValidatorResult vr, TypeValidatorResult reloadResult) = await ValidationAndUploadDatabaseValues.UploadDatabaseValues(HttpContext, dataContext, config, userId, id);
        var ret = new ObjectReloadResult() { objectId = id, result = vr, reloadResult = reloadResult };
        return Json(ret);
    }

}