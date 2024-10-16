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

namespace InfProject.Controllers;

//[Authorize(Roles = "User,PowerUser,Administrator")]
public class PropertiesTableController : Controller
{
    private readonly ILogger<PropertiesTableController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;
    private readonly IWebHostEnvironment webHostEnvironment;

    public PropertiesTableController(ILogger<PropertiesTableController> logger, IConfiguration config, DataContext dataContext, IWebHostEnvironment webHostEnvironment)
    {
        this.logger = logger;
        this.config = config;
        this.dataContext = dataContext;
        this.webHostEnvironment = webHostEnvironment;
    }




    // #region Excel Download / Upload


    /// <summary>
    /// Download all table properties (row>0)
    /// </summary>
    /// <returns>Excel file</returns>
    // [HttpGet("{id:int}")]
    public async Task<IActionResult> DownloadTableTemplate([FromRoute] int id)
    {
        var type = await dataContext.GetType(id);
        if (type == null || type.TypeId<1)
        {
            return StatusCode(StatusCodes.Status404NotFound, "not found");
        }
        List<dynamic> listAll = await dataContext.Property_GetTemplateTablePropertiesForType(id);
        if (listAll.Count == 0) {
            return Content($"<html><h3>Empty template</h3><p>No properties defined as a template for table (with Row=-1 use properties in object named \"_Template\")</p></html>", "text/html");
        }
        System.Data.DataTable dt = WebUtilsLib.DBUtils.FeedTableTemplate(listAll);
        var ms = await ExcelUtils.GetMemoryStream(dt, "TableProperties");
        string contentType = "application/vnd.ms-excel";
        //Send the File to Download.
        return new FileStreamResult(ms, contentType) { FileDownloadName = type.TypeName.DeleteHtmlTags().ToLower().Replace(" ","_") + "_tabletemplate.xlsx" };
    }


    /// <summary>
    /// Download all table properties (row>0)
    /// </summary>
    /// <returns>Excel file</returns>
    // [HttpGet("{id:int}")]
    public async Task<IActionResult> DownloadTablePropertiesExcel([FromRoute] int id)
    {
        ObjectInfo obj = await dataContext.ObjectInfo_Get(id);
        if (obj == null) {
            return StatusCode(StatusCodes.Status404NotFound, "not found");

        }
        if (HttpContext.IsReadDenied(obj.AccessControl, (int)obj._createdBy))
        {
            return this.RedirectToLoginOrAccessDenied(HttpContext);
        }
        List<dynamic> listAll = await dataContext.Property_GetPropertiesAllUnionForObject(obj.ObjectId);
        System.Data.DataTable dt = WebUtilsLib.DBUtils.FeedTablePropertiesFromList(listAll);
        if (dt.Rows.Count == 0) {
            var type = await dataContext.GetType(obj.TypeId);
            return Content($"<html><h3>Nothing to download (empty table)</h3><a href=\"/propertiestable/downloadtabletemplate/{obj.TypeId}\">To get an Excel template for table properties of type \"{type.TypeName}\" download file</a>.</html>", "text/html");
        }
        var ms = await ExcelUtils.GetMemoryStream(dt, "TableProperties");

        string contentType = "application/vnd.ms-excel";
        //Send the File to Download.
        return new FileStreamResult(ms, contentType) { FileDownloadName = obj.ObjectName.DeleteHtmlTags() + "_table.xlsx" };
    }



    [HttpPost]
    public async Task<IActionResult> UploadTablePropertiesExcel([FromRoute] int id, List<IFormFile> fileupload)
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
                    (Dictionary<string, PropertyType> dicTypes, string[] columns) = await GetTableSpecification(worksheet, obj.TypeId);

                    for (row = 2; row <= rowCount; row++)   // start with second row where data starts
                    {
                        for (int col = 1; col <= colCount; col++)
                        {
                            // Console.WriteLine(" Row:" + row + " column:" + col + " Value:" + worksheet.Cells[row, col].Value?.ToString().Trim());
                            //var par = new
                            //{
                            //    ObjectId = obj.ObjectId,
                            //    SortCode = row == 2 ? col : 0,
                            //    _created = dt,
                            //    _createdBy = userId,
                            //    _updated = dt,
                            //    _updatedBy = userId,
                            //    Row = row-1,
                            //    Value = worksheet.Cells[row, col].Value,
                            //    ValueEpsilon = DBNull.Value,
                            //    PropertyName = columns[col - 1],
                            //    Comment = DBNull.Value
                            //};

                            PropertyValue value = new PropertyValue() { 
                                PropertyType = dicTypes[columns[col - 1]],
                                PropertyName = columns[col - 1],
                                Value = worksheet.Cells[row, col].Value,
                                ValueEpsilon = null,
                                SortCode = col * 10,    // row == 2 ? col*10 : 0, 
                                Row = row - 1,
                                Comment = null,
                                SourceObjectId = obj.ObjectId
                            };
                            int newPropertyId = await dataContext.Property_UpdateInsert(value, dt, userId, obj.ObjectId);

                            // Enum.GetValues(typeof(PropertyType)).Cast<PropertyType>()
                        }
                    }
                    // clean up previous properties by date 
                    await dataContext.Property_DeleteTableBefore(obj.ObjectId, dt);
                }
                TempData["Suc"] = $"Excel upload and object table properties update successful for {rowCount-1} rows and {colCount} columns";
            }
            catch (Exception ex)
            {
                TempData["Err"] = $"Error UploadTablePropertiesExcel: {ex.Message} [row: {row}]";
                logger.LogError($"Error UploadTablePropertiesExcel {ex.ToStringForLog()} [row: {row}; {obj}]");
            }
        }
        return RedirectToRoute(new { controller = "Object", action = obj.ObjectNameUrl });
    }


    /// <summary>
    /// discovery Excel table structure and align it with properties types for object of given type from database
    /// </summary>
    /// <param name="worksheet"></param>
    /// <param name="objectType"></param>
    /// <returns></returns>
    /// <exception cref="ArgumentException"></exception>
    private async Task<(Dictionary<string, PropertyType> dicTypes, string[] columns)> GetTableSpecification(ExcelWorksheet worksheet, int objectType)
    {
        //Row:1 column: 1 Value: CrystalSystem
        //Row:1 column: 2 Value: E
        //Row:1 column: 3 Value: IsCalculated
        //Row:1 column: 4 Value: ReferenceId
        //Row:1 column: 5 Value: SpaceGroup
        //Row:1 column: 6 Value: Temperature

        List<dynamic> propertyNamesType = await dataContext.Property_GetPropertyNameByType(objectType);   // List<dynamic> == List<PropertyType, PropertyName>
        // List<dynamic> propertyNamesAll = await dataContext.Property_GetPropertyNameByType(objectType);   // List<dynamic> == List<PropertyType, PropertyName>
        int row = 1;
        int colCount = worksheet.Dimension.End.Column;  //get Column Count

        Dictionary<string, PropertyType> dicTypes = new Dictionary<string, PropertyType>();
        string[] columns = new string[colCount];
        for (int col = 1; col <= colCount; col++)
        {
            columns[col - 1] = worksheet.Cells[row, col].Value?.ToString().Trim();
            Console.WriteLine(" Row:" + row + " column:" + col + " Value:" + columns[col - 1]);
            if (string.IsNullOrEmpty(columns[col - 1]))
            {
                throw new ArgumentException($"Column {col} should have a name");
            }
            PropertyType t = GetPropertyTypeByName(propertyNamesType, propertyNamesType/*propertyNamesAll*/, columns[col - 1]);
            if (t == 0)
            {
                throw new ArgumentException($"Unable to find type for column \"{columns[col - 1]}\". Please create within a tenant at least one property with this name manually to set up property type");
            }
            if (dicTypes.ContainsKey(columns[col - 1])) {
                throw new ArgumentException($"Duplicate column name \"{columns[col - 1]}\" found. Please revise your data!");
            }
            dicTypes.Add(columns[col - 1], t);  // will throw an exception if column names are not unique! Which is good by design!
        }
        return (dicTypes, columns);
    }

    /// <summary>
    /// searches property with name "propertyName" (case-insensitive) in propertyNamesType and then in propertyNamesAll
    /// </summary>
    /// <param name="propertyNamesType">first precedence list to search</param>
    /// <param name="propertyNamesAll">second precedence list to search</param>
    /// <param name="propertyName">case-insensitive string</param>
    /// <returns>0 - not found; otherwise PropertyType</returns>
    private static PropertyType GetPropertyTypeByName(List<dynamic> propertyNamesType, List<dynamic> propertyNamesAll, string propertyName)   // List<dynamic> == List<PropertyType, PropertyName>
    {
        // first priority: search within object Type
        foreach (var item in propertyNamesType) 
        {
            if (string.Compare(item.PropertyName, propertyName, true) == 0)
                return (PropertyType)Enum.Parse(typeof(PropertyType), item.PropertyType);
        }
        // second priority (attempt): search within all tenant (regardless type)
        if (propertyNamesType == propertyNamesAll) {
            return 0;   // not found
        }
        foreach (var item in propertyNamesAll)
        {
            if (string.Compare(item.PropertyName, propertyName, true) == 0)
                return (PropertyType)Enum.Parse(typeof(PropertyType), item.PropertyType);
        }
        return 0;   // not found
    }


    // #endregion // Excel Download / Upload

}