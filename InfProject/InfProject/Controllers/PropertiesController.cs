using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using System.Data.SqlClient;
using System.Data;
using System.Diagnostics;
using InfProject.Models;
using InfProject.Utils;
using InfProject.DBContext;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using OfficeOpenXml;
using static WebUtilsLib.DBUtils;
using System.IO;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Dapper;
using static System.Runtime.InteropServices.JavaScript.JSType;
using System.Text;
using WebUtilsLib;
using Microsoft.AspNetCore.Http.HttpResults;
using System;
using Microsoft.CodeAnalysis.Elfie.Model.Structures;
using OfficeOpenXml.Style;
using System.Drawing;
using Microsoft.IdentityModel.Tokens;
using FluentValidation;
using System.ComponentModel.DataAnnotations;
using System.Net;
using System.Reflection;
using Azure.Core.GeoJson;
using System.Runtime.InteropServices.JavaScript;
using Azure.Core;

namespace InfProject.Controllers;

//[Authorize(Roles = "User,PowerUser,Administrator")]
[RequestFormLimits(ValueCountLimit = 1000000)]
public class PropertiesController : Controller
{
    private readonly ILogger<PropertiesController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;
    private readonly IWebHostEnvironment webHostEnvironment;

    public PropertiesController(ILogger<PropertiesController> logger, IConfiguration config, DataContext dataContext, IWebHostEnvironment webHostEnvironment)
    {
        this.logger = logger;
        this.config = config;
        this.dataContext = dataContext;
        this.webHostEnvironment = webHostEnvironment;
    }




    // #region Excel Download / Upload


    /// <summary>
    /// Download all non-table properties (row is null)
    /// </summary>
    /// <returns>Excel file</returns>
    // [HttpGet("{id:int}")]
    public async Task<IActionResult> DownloadTemplate([FromRoute] int id)
    {
        var type = await dataContext.GetType(id);
        if (type == null || type.TypeId<1)
        {
            return StatusCode(StatusCodes.Status404NotFound, "not found");
        }
        List<PropertyValue> listAll = await dataContext.Property_GetTemplatePropertiesForType(id);
        if (listAll.Count == 0) {
            return Content($"<html><h3>Empty template</h3><p>No properties defined as a non-table template (with Row=NULL use properties in object named \"_Template\")</p></html>", "text/html");
        }
        listAll.ForEach(x => x.Value = null);
        System.Data.DataTable dt = WebUtilsLib.DBUtils.FeedNonTablePropertiesFromList(listAll);
        var ms = await ExcelUtils.GetMemoryStream(dt, "NonTableProperties", ws => {
            int colCount = ws.Dimension.End.Column;  //get Column Count
            int rowCount = ws.Dimension.End.Row;     //get row count
            ws.Cells[1, 4].Style.Font.Bold = false;
            for (int row = 2; row <= rowCount; row++)   // start with second row where data starts
            {
                string type = ws.Cells[row, 1].Value?.ToString();
                string comment = ws.Cells[row, 5].Value?.ToString();
                if (string.CompareOrdinal(comment, "SEPARATOR") == 0)
                {
                    ws.Cells[row, 1].Value = null;
                    // name
                    ws.Cells[row, 2].Style.Font.Bold = true;
                    // value
                    ws.Cells[row, 3].Style.Fill.PatternType = ExcelFillStyle.Solid;
                    ws.Cells[row, 3].Style.Fill.BackgroundColor.SetColor(Color.LightGray);
                    // epsilon
                    ws.Cells[row, 4].Style.Fill.PatternType = ExcelFillStyle.Solid;
                    ws.Cells[row, 4].Style.Fill.BackgroundColor.SetColor(Color.LightGray);
                    // comment
                    ws.Cells[row, 5].Value = null;
                }
                else {
                    if (type != "Float") {
                        // epsilon
                        ws.Cells[row, 4].Style.Fill.PatternType = ExcelFillStyle.Solid;
                        ws.Cells[row, 4].Style.Fill.BackgroundColor.SetColor(Color.LightGray);
                    }
                }
            }


        });
        string contentType = "application/vnd.ms-excel";
        //Send the File to Download.
        return new FileStreamResult(ms, contentType) { FileDownloadName = type.TypeName.DeleteHtmlTags().ToLower().Replace(" ","_") + "_template.xlsx" };
    }


    /// <summary>
    /// Download all non-table properties (Row is null)
    /// </summary>
    /// <param name="id">ObjectId</param>
    /// <param name="includetemplate"></param>
    /// <returns>Excel file</returns>
    public async Task<IActionResult> DownloadPropertiesExcel([FromRoute] int id, [FromQuery] bool includetemplate = false)
    {
        ObjectInfo obj = await dataContext.ObjectInfo_Get(id);
        if (obj == null) {
            return StatusCode(StatusCodes.Status404NotFound, "not found");

        }
        if (HttpContext.IsReadDenied(obj.AccessControl, (int)obj._createdBy))
        {
            return this.RedirectToLoginOrAccessDenied(HttpContext);
        }
        List<dynamic> listAll = null;
        if (includetemplate) {  // outer join with template!
            listAll = await dataContext.Property_GetPropertiesAllUnionForObject_Join_Template(obj.ObjectId, obj.TypeId);
        }
        else {
            listAll = await dataContext.Property_GetPropertiesAllUnionForObject(obj.ObjectId);
        }
        var listAllnoTable = listAll.Where(x => x.Row == null).ToList();
        // map
        List<PropertyValue> listTyped = listAllnoTable.Select(x => new PropertyValue() {
            PropertyId = x.PropertyId ?? 0,
            PropertyType = (PropertyType)Enum.Parse(typeof(PropertyType), x.PropertyType),
            PropertyName = x.PropertyName,
            Value = x.Value,
            ValueEpsilon = x.ValueEpsilon,
            SortCode = x.SortCode,
            Row = x.Row,
            Comment = x.Comment,
            SourceObjectId = x.SourceObjectId}).ToList();
        DataTable dt = WebUtilsLib.DBUtils.FeedNonTablePropertiesFromList(listTyped);
        if (dt.Rows.Count == 0) {    // header row "Type", "Name", "Value", "Epsilon", "Comment" is always present
            var type = await dataContext.GetType(obj.TypeId);
            return Content($"<html><h3>Nothing to download (empty table)</h3><a href=\"/properties/downloadtemplate/{obj.TypeId}\">To get an Excel template for non-table properties of type \"{type.TypeName}\" download file</a>.</html>", "text/html");
        }
        var ms = await ExcelUtils.GetMemoryStream(dt, "NonTableProperties");

        string contentType = "application/vnd.ms-excel";
        //Send the File to Download.
        return new FileStreamResult(ms, contentType) { FileDownloadName = obj.ObjectName.DeleteHtmlTags() + ".xlsx" };
    }



    [HttpPost]
    public async Task<IActionResult> UploadPropertiesExcel([FromRoute] int id, List<IFormFile> fileupload)
    {
        ObjectInfo obj = await dataContext.ObjectInfo_Get(id);
        if (obj == null)
        {
            return StatusCode(StatusCodes.Status404NotFound, "not found");
        }
        if (HttpContext.IsWriteDenied(obj.AccessControl, (int)obj._createdBy))
        {
            return this.RedirectToLoginOrAccessDenied(HttpContext);
        }
        int deleted = 0, updated = 0, inserted = 0;
        int row = 0;
        if (fileupload is null)
        {
            TempData["Err"] = $"Error: fileupload is null";
        }
        else if (fileupload.Count != 1)
        {
            TempData["Err"] = $"Error: single Excel file is required";
        }
        else
        {
            IFormFile formFile = fileupload[0];
            try
            {
                int colCount = 0;  //get Column Count
                int rowCount = 0;     //get row count

                using (var package = new ExcelPackage(formFile.OpenReadStream()))
                {
                    ExcelWorksheet worksheet = package.Workbook.Worksheets[0];
                    colCount = worksheet.Dimension.End.Column;  //get Column Count
                    rowCount = worksheet.Dimension.End.Row;     //get row count
                    int userId = HttpContext.GetUserId();
                    DateTime dt = DateTime.Now.AddMilliseconds(-100);   // just to make sure, than nothing is deleted unattended on quick updates with the same time (TODO: sync times with SQL server - could be a problems if SQL Server in on other VM with non-synchronized time)

                    List<PropertyValue> listAll = await dataContext.Property_GetTemplatePropertiesForType(obj.TypeId);

                    // (Dictionary<string, PropertyType> dicTypes, string[] columns) = await GetTableSpecification(worksheet, obj.TypeId);
                    // dt.Rows.Add("Type", "Name", "Value", "Epsilon", "Comment");
// PropertyFloatId as PropertyId, 'Float' as PropertyType, [Row], 
//  ObjectId, SortCode, _created, _createdBy, _updated, _updatedBy, CAST([Value] as varchar(max)) as [Value], ValueEpsilon, PropertyName, Comment
                    if (string.CompareOrdinal(worksheet.Cells[1, 1].Value?.ToString(), "Type")!=0 ||
                        string.CompareOrdinal(worksheet.Cells[1, 2].Value?.ToString(), "Name")!= 0 ||
                        string.CompareOrdinal(worksheet.Cells[1, 3].Value?.ToString(), "Value")!= 0 ||
                        string.CompareOrdinal(worksheet.Cells[1, 4].Value?.ToString(), "Epsilon")!= 0 ||
                        string.CompareOrdinal(worksheet.Cells[1, 5].Value?.ToString(), "Comment")!= 0 ||
                        string.CompareOrdinal(worksheet.Cells[1, 6].Value?.ToString(), "SourceObjectId") != 0) {
                        throw new Exception ($"Excel file must contain first row with columns: \"Type\", \"Name\", \"Value\", \"Epsilon\", \"Comment\", \"SourceObjectId\"");
                    }

                    for (row = 2; row <= rowCount; row++)   // start with second row where data starts
                    {
                        string typeStr = worksheet.Cells[row, 1].Value?.ToString();
                        string name = worksheet.Cells[row, 2].Value?.ToString();
                        object valueExcel = worksheet.Cells[row, 3].Value;
                        double? epsilon = null;
                        double eps;
                        if (double.TryParse(worksheet.Cells[row, 4].Value?.ToString(), out eps)) {
                            epsilon = eps;
                        }
                        string comment = worksheet.Cells[row, 5].Value?.ToString();

                        string sourceObjectIdStr = worksheet.Cells[row, 6].Value?.ToString();
                        int.TryParse(sourceObjectIdStr, out int sourceObjectId);

                        PropertyValue? propTemplate = listAll.Find(x => string.Compare(x.PropertyName, name) == 0);
                        PropertyType type;
                        if (propTemplate == null)
                        {
                            // throw new Exception($"Property is unknown, i.e. not found in _Template object: [row={row}, name=\"{name}\"]");
                            type = (PropertyType)Enum.Parse(typeof(PropertyType), typeStr);
                        }
                        else {
                            type = propTemplate.PropertyType;
                        }

                        if (!string.IsNullOrEmpty(valueExcel?.ToString())) {
                            int sortCode = propTemplate==null ? 0 : (int)propTemplate.SortCode;

                            PropertyValue value = new PropertyValue()
                            {
                                PropertyType = type,
                                PropertyName = name,
                                Value = valueExcel,
                                ValueEpsilon = epsilon,
                                SortCode = sortCode,
                                Row = null,
                                Comment = comment,
                                SourceObjectId = sourceObjectId
                            };
                            int newPropertyId = await dataContext.Property_UpdateInsert(value, dt, userId, obj.ObjectId);
                        }
                    }
                    // clean up previous properties by date 
                    await dataContext.Property_DeleteNonTableBefore(obj.ObjectId, dt);
                }
                TempData["Suc"] = $"Excel upload and object non-table properties update successful for {rowCount-1} rows";
            }
            catch (Exception ex)
            {
                TempData["Err"] = $"Error UploadPropertiesExcel: {ex.Message} [row: {row}]";
                logger.LogError($"Error UploadPropertiesExcel {ex.ToStringForLog()} [row: {row}; {obj}]");
            }
        }
        return RedirectToRoute(new { controller = "Object", action = obj.ObjectNameUrl });
    }



    // #endregion // Excel Download / Upload


    /// <summary>
    /// Edit form for all object non table properties according to template
    /// </summary>
    /// <param name="id">ObjectId</param>
    /// <returns></returns>
    [HttpGet]
    public async Task<IActionResult> EditItem([FromRoute] int id) {
        ObjectInfo obj = await dataContext.ObjectInfo_Get(id);
        if (obj == null)
        {
            return StatusCode(StatusCodes.Status404NotFound, "not found");
        }
        if (HttpContext.IsWriteDenied(obj.AccessControl, (int)obj._createdBy))
        {
            return this.RedirectToLoginOrAccessDenied(HttpContext);
        }
        return View(obj);
    }




    [HttpPost]
    public async Task<IActionResult> UpdateInsert([FromForm] int objectId)
    {
        ObjectInfo obj = await dataContext.ObjectInfo_Get(objectId);
        if (obj == null)
        {
            return StatusCode(StatusCodes.Status404NotFound, "not found");
        }
        string returl = Request.Form["returl"];
        //Type t = null!;
        //dynamic dObj = null!;
        //ObjectInfo newObject = null!;
        //Models.TypeInfo dbType = await dataContext.GetType(obj.TypeId);

        try
        {
            (int updatedInserted, int deleted, string log) = await PropertiesUtils.UpdateInsert_PropertiesFromForm(objectId, HttpContext, dataContext);

            logger.LogInformation(log);
            TempData["Suc"] = $"Properties values are saved successfully [updated&inserted={updatedInserted}, deleted={deleted}]";
            logger.LogInformation($"Properties values are saved [ObjectId={objectId}, updated&inserted={updatedInserted}, deleted={deleted}]");
        }
        catch (Exception ex)
        {
            TempData["Err"] = $"Error updating properties for object (ObjectId={objectId}): {ex.Message}";
            logger.LogError($"Error dataContext.Property_UpdateInsert {ex.ToStringForLog()} [ObjectId={objectId}]");
            return View("EditItem", obj);
        }
        if (!string.IsNullOrEmpty(returl))
        {
            returl = WebUtility.UrlDecode(returl);
            return Redirect(returl);
        }
        return RedirectToRoute(new { controller = "Properties", action = "EditItem", id = objectId });
    }

    /// <summary>
    /// returns HTML-form to embed via AJAX in batch upload form
    /// /properties/ajaxgetpropertiesform?objectFormPrefix=i5&typeId=59
    /// </summary>
    /// <param name="objectFormPrefix">unique prefix for the form (iN)</param>
    /// <param name="typeId">TypeId of the type to find a template (if SettingsJson.IncludePropertiesForm==1)</param>
    /// <returns>HTML</returns>
    [HttpGet]
    public async Task<IActionResult> AjaxGetPropertiesForm([FromQuery] string objectFormPrefix, [FromQuery] int typeId) {
        return View((objectFormPrefix, typeId));
    }
}