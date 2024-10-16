using Azure.Core.GeoJson;
using Dapper;
using FluentValidation;
using FluentValidation.AspNetCore;
using FluentValidation.Results;
using InfProject.DBContext;
using InfProject.Models;
using InfProject.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.CodeAnalysis;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics.Metrics;
using System.Globalization;
using System.Reflection;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using WebUtilsLib;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;
using static System.Net.Mime.MediaTypeNames;
using static System.Runtime.InteropServices.JavaScript.JSType;
using static WebUtilsLib.DBUtils;

namespace InfProject.Controllers;

[Authorize(Roles = "PowerUser,Administrator")]
public class AdminPropertyController : Controller
{
    private readonly ILogger<AdminPropertyController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;
    private readonly IWebHostEnvironment webHostEnvironment;

    public AdminPropertyController(ILogger<AdminPropertyController> logger, IConfiguration config, DataContext dataContext, IWebHostEnvironment webHostEnvironment)
    {
        this.logger = logger;
        this.config = config;
        this.dataContext = dataContext;
        this.webHostEnvironment = webHostEnvironment;
    }


    /// <summary>
    /// inserts or updates properties values from admin interface
    /// </summary>
    /// <param name="mode">mode: 'BigString', 'String', 'Int', 'Float'</param>
    /// <param name="propertyId"></param>
    /// <param name="objectId"></param>
    /// <param name="sortCode"></param>
    /// <param name="propertyName"></param>
    /// <param name="value"></param>
    /// <param name="valueEpsilon"></param>
    /// <param name="comment"></param>
    /// <returns></returns>
    [HttpPost]
    public async Task<IActionResult> UpdateInsert(string mode, int propertyId, int objectId, int sortCode, string propertyName, int row, string value, string valueEpsilon, string comment, int sourceObjectId)
    {
        ObjectInfo objOld = await HttpContext.GetObjectAndCheckWriteAccess(dataContext, objectId);   // Exception if no access
        int userId = HttpContext.GetUserId();
        if (string.Compare(mode, "Int", true)==0  || string.Compare(mode, "Float", true) == 0) {
            value = LocalizationUtils.AdjustNumberString(value);
            valueEpsilon = LocalizationUtils.AdjustNumberString(valueEpsilon);
        }
        var par = new
        {
            PropertyId = propertyId,    // VIC Revised 2023-05-11               0,
            ObjectId = objectId,
            SortCode = sortCode,
            _created = DateTime.Now,
            _createdBy = userId,
            _updated = DateTime.Now,
            _updatedBy = userId,
            Row = row,
            Value = value,
            ValueEpsilon = valueEpsilon,
            PropertyName = propertyName,
            Comment = comment,
            SourceObjectId = sourceObjectId
        };
        ObjectInfo obj = await dataContext.ObjectInfo_Get(objectId);
        if (obj == null || obj.ObjectId < 1)
        {
            TempData["Err"] = $"Object not found [objectId={objectId}]";
            return RedirectToRoute(new { controller = "AdminObject", action = "EditItem", id = objectId });
        }
        string actMode = "insert/update";
        try
        {
            var parameters = new DynamicParameters(par);
            parameters.Add("TenantId", dataContext.TenantId, DbType.Int32, direction: ParameterDirection.Input);
            parameters.Add("PropertyId", propertyId /* VIC Revised 2023-05-11               0 */, DbType.Int32, direction: ParameterDirection.InputOutput);
            parameters.Add("retval", 0, DbType.Int32, direction: ParameterDirection.ReturnValue);
            parameters.Add("DeleteOnNullValues", false, DbType.Boolean, direction: ParameterDirection.Input);

            // UPDATE / INSERT in database
            PropertyType pType = (PropertyType)Enum.Parse(typeof(PropertyType), mode);
            int newPropertyId = await dataContext.Property_UpdateInsert(pType, parameters); // negative on update / positive on insert
            actMode = newPropertyId > 0 ? "insert" : "update";
            newPropertyId = Math.Abs(newPropertyId);    
            TempData["Suc"] = $"Property {actMode} successful";
            logger.LogInformation($"Property {actMode} successful [mode={mode}, ObjectId={objectId}, PropertyId={newPropertyId}, SourceObjectId={sourceObjectId}]");
        }
        catch (Exception ex)
        {
            TempData["Err"] = $"Error {actMode} property in object: {ex.ToStringForLog()}";
            logger.LogError($"Error dataContext.Property_UpdateInsert {ex.ToStringForLog()} [{par}]");
            return RedirectToRoute(new { controller = "AdminObject", action = "EditItem", id = objectId });
        }
        return RedirectToRoute(new { controller = "AdminObject", action = "EditItem", id = objectId });
    }


    [HttpPost]
    public async Task<IActionResult> Delete(string mode, int propertyId, int objectId)
    {
        try
        {
            ObjectInfo obj = await HttpContext.GetObjectAndCheckWriteAccess(dataContext, objectId);   // Exception if no access
            if (obj == null || obj.ObjectId < 1)
            {
                TempData["Err"] = $"Object not found [objectId={objectId}]";
                return RedirectToRoute(new { controller = "AdminObject", action = "EditItem", id = objectId });
            }
            int rowsAffected = await dataContext.Property_Delete(mode, propertyId);
            TempData["Suc"] = $"Property deleted successfully";
            logger.LogInformation($"Property deleted successfully [mode={mode}, ObjectId={objectId}, PropertyId={propertyId}]");
        }
        catch (Exception ex)
        {
            TempData["Err"] = $"Error deleting property in object: {ex.ToStringForLog()}";
            logger.LogError($"Error dataContext.Property_Delete {ex.ToStringForLog()} [mode={mode}, ObjectId={objectId}, PropertyId={propertyId}]");
            return RedirectToRoute(new { controller = "AdminObject", action = "EditItem", id = objectId });
        }
        return RedirectToRoute(new { controller = "AdminObject", action = "EditItem", id = objectId });
    }



}