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

namespace InfProject.Controllers;

[Authorize(Roles = "PowerUser,Administrator")]
[Route("typevalidation")]
public class TypeValidationController : Controller
{
    private readonly IValidator<ObjectInfo> validator;
    private readonly ILogger<TypeValidationController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;
    private readonly IWebHostEnvironment webHostEnvironment;
    private readonly ICompositeViewEngine viewEngine;

    public TypeValidationController(IValidator<ObjectInfo> validator, ILogger<TypeValidationController> logger, IConfiguration config, DataContext dataContext, IWebHostEnvironment webHostEnvironment, ICompositeViewEngine viewEngine)
    {
        this.validator = validator;
        this.logger = logger;
        this.config = config;
        this.dataContext = dataContext;
        this.webHostEnvironment = webHostEnvironment;
        this.viewEngine = viewEngine;
    }


    #region Validation

    // FAILS on large arrays - .net bug...
    // public async Task<IActionResult> ValidateBatch([FromForm]int [] objectIds) {

    [HttpPost("validatebatch")]
    public async Task<IActionResult> ValidateBatch()
    {
        Request.EnableBuffering();  // important, otherwise can't seek input stream
        Stream req = Request.Body;
        if (req.CanSeek)
        {
            // Reset the position to zero to read from the beginning.
            req.Seek(0, System.IO.SeekOrigin.Begin);
        }
        string csv = null;
        using (var reader = new StreamReader(req, Encoding.UTF8))
        {
            csv = reader.ReadToEndAsync().Result;
        }
        int[] objectIds = csv == null ? new int[0] : csv.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries).Select(x => int.Parse(x)).ToArray();
        List<ObjectValidationResult> res = new List<ObjectValidationResult>();
        string relFileName, absFileName;
        Models.TypeInfo type = null;
        TypeValidatorResult vr;
        if (objectIds == null) {
            return Json(new { batch = res });
        }
        foreach (int objectId in objectIds)
        {
            var obj = await dataContext.ObjectInfo_Get(objectId);
            if (HttpContext.IsReadDenied(obj.AccessControl, (int)obj._createdBy))
            {
                vr = new TypeValidatorResult(403, "access denied");
            }
            else
            {
                if (type == null || type.TypeId != obj.TypeId)
                {
                    type = await dataContext.GetType(obj.TypeId);
                }
                relFileName = obj.ObjectFilePath;
                if (string.IsNullOrEmpty(obj.ObjectFilePath))
                {
                    if (type.FileRequired)
                    {
                        vr = new TypeValidatorResult() { Code = 404, Message = $"required file is not defined [ObjectFilePath is empty]" };
                    }
                    else
                    {
                        vr = new TypeValidatorResult(); // ok
                    }
                }
                else {
                    absFileName = config.MapStorageFile(relFileName);
                    vr = type.ValidateFile(absFileName);
                }
            }
            res.Add(new ObjectValidationResult() { objectId = objectId, result = vr });
        }
        return Json(new { batch = res });
    }



    // FAILS on large arrays - .net bug...
    // public async Task<IActionResult> ReloadBatch([FromForm]int [] objectIds) {

    [HttpPost("reloadbatch")]
    public async Task<IActionResult> ReloadBatch()
    {
        Request.EnableBuffering();  // important, otherwise can't seek input stream
        Stream req = Request.Body;
        if (req.CanSeek)
        {
            // Reset the position to zero to read from the beginning.
            req.Seek(0, System.IO.SeekOrigin.Begin);
        }
        string csv = null;
        using (var reader = new StreamReader(req, Encoding.UTF8))
        {
            csv = reader.ReadToEndAsync().Result;
        }
        int[] objectIds = csv == null ? new int[0] : csv.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries).Select(x => int.Parse(x)).ToArray();
        List<ObjectReloadResult> res = new List<ObjectReloadResult>();
        string absFileName;
        Models.TypeInfo type = null;
        TypeValidatorResult vr;
        TypeValidatorResult reloadResult;
        int i=0, objectId=0, rowsAffected;
        int userId = HttpContext.GetUserId();
        if (objectIds == null) {
            return Json(new { batch = res });
        }
        try
        {
            for (i = 0; i < objectIds.Length; i++)
            {
                objectId = objectIds[i];
                (vr, reloadResult) = await ValidationAndUploadDatabaseValues.UploadDatabaseValues(HttpContext, dataContext, config, userId, objectId);
                res.Add(new ObjectReloadResult() { objectId = objectId, result = vr, reloadResult = reloadResult });
            }
        }
        catch (Exception ex)
        {

            throw new Exception($"ReloadBatch exception({ex.GetType()}): {ex.Message} [objectId={objectId}, i={i}, objectIds.Length={objectIds.Length}] {ex.StackTrace}", ex);
        }
        return Json(new { batch = res });
    }
    #endregion



}