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
using System.Threading.Tasks;
using WebUtilsLib;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;
using static System.Net.Mime.MediaTypeNames;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace InfProject.Controllers;

[Authorize(Roles = "Administrator")]
public class AdminTypeController : Controller
{
    // Claim name to CRUD in types
    public const string ClaimNameToCRUDTypes = "CRUDTypes"; // must be set to "1" for users who are allowed to CRUD types
    private readonly IValidator<Models.TypeInfo> validator;
    private readonly ILogger<AdminTypeController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;
    private readonly IWebHostEnvironment webHostEnvironment;
    private readonly ICompositeViewEngine viewEngine;

    public AdminTypeController(IValidator<Models.TypeInfo> validator, ILogger<AdminTypeController> logger, IConfiguration config, DataContext dataContext, IWebHostEnvironment webHostEnvironment, ICompositeViewEngine viewEngine)
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
    public async Task<IActionResult> Index()
    {
        var list = await dataContext.GetTypes();
        return View(list);
    }


    [HttpPost]
    public async Task<IActionResult> Delete([FromForm] int typeId)
    {
        // TempData["Err"] = $"Delete type is considered dangerous, so not implemented (make manual changes in DB)";
        int rowsAffected = 0;
        try
        {
            if (!HttpContext.User.IsInRole(UserGroups.Administrator) || !HttpContext.User.HasClaim(ClaimNameToCRUDTypes, "1"))
            {
                throw new Exception("CRUD on types is dasabled for you, please contact the instance owner to assign a claim");
            }
            rowsAffected = await dataContext.DeleteType(typeId);
            TempData["Suc"] = $"Type delete successful";
            logger.LogInformation($"Type deleted [TypeId={typeId}, rowsAffected={rowsAffected}]");
        }
        catch (Exception ex)
        {
            TempData["Err"] = $"Error deleting type: {ex.Message}";
            logger.LogError($"Error dataContext.DeleteType {ex.ToStringForLog()} [TypeId={typeId}, rowsAffected={rowsAffected}]");
            var list = await dataContext.GetTypes();
            return View("Index", list);
        }
        return Redirect($"/admintype/");
    }

    public async Task<IActionResult> NewItem([FromRoute(Name = "id")] bool isHierarchical)
    {
        Models.TypeInfo dbType = new Models.TypeInfo() { IsHierarchical = isHierarchical, TableName = isHierarchical ? "RubricInfo" : "ObjectInfo" };
        ViewBag.controllerContext = ControllerContext;
        ViewBag.viewEngine = viewEngine;
        return View("EditItem", dbType);
    }

    public async Task<IActionResult> EditItem([FromRoute(Name = "id")] int idType)
    {
        Models.TypeInfo dbType = await dataContext.GetType(idType);
        if (dbType == null) {
            return NotFound($"Type with id {idType} not found");
        }
        ViewBag.controllerContext = ControllerContext;
        ViewBag.viewEngine = viewEngine;
        return View(dbType);
    }

    
    [HttpPost]
    public async Task<IActionResult> UpdateInsert([FromForm] Models.TypeInfo type)
    {
        //string returl = Request.Form["returl"];
        Models.TypeInfo dbType = type.TypeId!=0 ? await dataContext.GetType(type.TypeId) : new Models.TypeInfo();
        try
        {
            if (!HttpContext.User.IsInRole(UserGroups.Administrator) || !HttpContext.User.HasClaim(ClaimNameToCRUDTypes, "1"))
            {
                throw new Exception("CRUD on types is dasabled for you, please contact the instance owner to assign a claim");
            }

            // IValidator<ObjectInfo>
            ValidationResult result = await validator.ValidateAsync(type);
            if (!result.IsValid)
            {
                result.AddToModelState(this.ModelState);    // Copy the validation results into ModelState.
                TempData["Err"] = $"Error validating model (TypeInfo): {result}";
                return View("EditItem", type);
            }

            // UPDATE / INSERT in database
            if (type.TableName == "RubricInfo")
            {
                type.IsHierarchical = true;
                type.TypeIdForRubric = null;
            }
            else
            {
                type.IsHierarchical = false;
            }
            if (dbType.TypeId != 0)
            {
                int rowsAffected = await dataContext.UpdateType(type);
                TempData["Suc"] = $"Update successful";
                logger.LogInformation($"Update successful [TypeId={type.TypeId}]");
            }
            else {
                int typeId = await dataContext.InsertType(type);
                TempData["Suc"] = $"Insert successful";
                logger.LogInformation($"Insert successful [TypeId={type.TypeId}]");
            }
        }
        catch (Exception ex)
        {
            TempData["Err"] = $"Error {(type.TypeId == 0 ? "inserting" : "updating")} type: {ex.Message}";
            logger.LogError($"Error dataContext.ObjectInfo_UpdateInsert {ex.ToStringForLog()} [type={type}]");
            return View("EditItem", type);
        }
        // return Redirect($"/adminobject/manualedit/{typeId}");
        //if (!string.IsNullOrEmpty(returl))
        //    return Redirect(returl);
        return RedirectToRoute(new { controller = "AdminType", action = "EditItem", id = type.TypeId });
    }
    
}