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
public class AdminObjectLinkRubricController : Controller
{
    // Claim name to enlist all the objects in the list of a certain type (to validate objects - Azadeh's use case)
    public const string ClaimNameToShowAllObjects = "AdminObject_EnlistAllObjects";
    // UploadDatabaseValues priviledge for all objects (to extract data automatically from files and update database content - Azadeh's use case)
    public const string ClaimNameToUploadDatabaseValuesForAllObjects = "AdminObject_UploadDatabaseValuesAllObjects";

    private readonly IValidator<ObjectInfo> validator;
    private readonly ILogger<AdminObjectLinkRubricController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;
    private readonly IWebHostEnvironment webHostEnvironment;
    private readonly ICompositeViewEngine viewEngine;
    private readonly IEmailSender mailSender;

    public AdminObjectLinkRubricController(IValidator<ObjectInfo> validator, ILogger<AdminObjectLinkRubricController> logger, IConfiguration config, DataContext dataContext, IWebHostEnvironment webHostEnvironment, ICompositeViewEngine viewEngine, IEmailSender mailSender)
    {
        this.validator = validator;
        this.logger = logger;
        this.config = config;
        this.dataContext = dataContext;
        this.webHostEnvironment = webHostEnvironment;
        this.viewEngine = viewEngine;
        this.mailSender = mailSender;
    }


    [HttpPost]
    public async Task<IActionResult> Adjust([FromForm] ObjectInfo obj, int mode, int objectid, int rubricid, int sortcode, int objectlinkrubricid)
    {
        string returl = Request.Form["returl"];
        int rowsAffected = 0;
        try
        {
            ObjectLinkRubric objOld = await HttpContext.GetObjectLinkRubricAndCheckWriteAccess(dataContext, objectlinkrubricid);   // Exception if no access
            int userId = HttpContext.GetUserId();
            if (mode == 1) {
                // UPDATE
                rowsAffected = await dataContext.ObjectLinkRubric_UpdateSortCode(objectlinkrubricid, objectid, rubricid, sortcode, userId);
                TempData["Suc"] = $"Update successful";
                logger.LogInformation($"Update successful [ObjectLinkRubricId={objectlinkrubricid}]");
            }
            else if (mode == 2) {
                rowsAffected = await dataContext.ObjectLinkRubric_Delete(objectlinkrubricid, objectid, rubricid);
                TempData["Suc"] = $"Delete successful";
                logger.LogInformation($"Delete successful [ObjectLinkRubricId={objectlinkrubricid}]");
            }
        }
        catch (Exception ex)
        {
            TempData["Err"] = $"Error {(mode == 1 ? "updating" : "deleting")} ObjectLinkRubric(mode={mode}): {ex.Message}";
            logger.LogError($"Error dataContext.ObjectLinkRubric_UpdateSortCode/ObjectLinkRubric_Delete {ex.ToStringForLog()} [mode={mode}, ObjectLinkRubricId={objectlinkrubricid}]");
        }
        // return Redirect($"/adminobject/manualedit/{typeId}");
        if (!string.IsNullOrEmpty(returl))
        {
            returl = WebUtility.UrlDecode(returl);
            return Redirect(returl);
        }
        RubricInfo ri = await dataContext.GetRubricById(rubricid);
        string url = ri.RubricNameUrl;
        return RedirectToRoute(new { controller = "Rubric", action = "Index", url = url });
    }


    [HttpPost]
    public async Task<IActionResult> AddLinksCSV(int rubricId, string objectIdCSV)
    {
        string returl = Request.Form["returl"];
        int rowsAffected = 0;
        int objectId = 0;
        try
        {
            int userId = HttpContext.GetUserId();
            string[] objects = objectIdCSV.Split(',', StringSplitOptions.RemoveEmptyEntries);
            foreach (string idString in objects)
            {
                if (int.TryParse(idString, out objectId)) {
                    rowsAffected = await dataContext.ObjectLinkRubric_AddOrUpdateLink(rubricId, objectId, sortCode: 0, userId);
                }
            }
            TempData["Suc"] = $"{objects.Length} link(s) processed successfully";
        }
        catch (Exception ex)
        {
            TempData["Err"] = $"Error AddLinksCSV: {ex.Message}";
            logger.LogError($"Error dataContext.ObjectLinkRubric_AddOrUpdateLink {ex.ToStringForLog()} [objectId={objectId}]");
        }
        if (!string.IsNullOrEmpty(returl))
        {
            returl = WebUtility.UrlDecode(returl);
            return Redirect(returl);
        }
        return RedirectToRoute(new { controller = "Home", action = "Index" });
    }
}