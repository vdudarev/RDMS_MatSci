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
using static NuGet.Client.ManagedCodeConventions;
using static System.Net.Mime.MediaTypeNames;
using static System.Runtime.InteropServices.JavaScript.JSType;
using static TypeValidationLibrary.TypeValidator_EDX_CSV;
using static WebUtilsLib.DBUtils;

namespace InfProject.Controllers;

public class SearchController : Controller
{
    private readonly ILogger<SearchController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;
    private readonly ICompositeViewEngine viewEngine;

    public SearchController(ILogger<SearchController> logger, IConfiguration config, DataContext dataContext, ICompositeViewEngine viewEngine)
    {
        this.logger = logger;
        this.config = config;
        this.dataContext = dataContext;
        this.viewEngine = viewEngine;
    }

    public async Task<IActionResult> Index() {
        Filter filter = new Filter();
        AccessControlFilter accessControlFilter = HttpContext.GetAccessControlFilter();
        filter.AccessFilter = accessControlFilter;
        var taskAvailableElements = dataContext.GetAvailableElements(filter);
        Task<List<WebAppUser>> taskAvailableUsers = dataContext.GetAvailableUsers(filter);
        await Task.WhenAll(taskAvailableElements, taskAvailableUsers);
        List<string> elements = taskAvailableElements.Result;
        List<WebAppUser> users = taskAvailableUsers.Result;
        return View((elements, users));
    }


    [HttpPost]
    public async Task<JsonResult> Search([FromForm] Filter filter)
    {
        AccessControlFilter accessControlFilter = HttpContext.GetAccessControlFilter();
        filter.AccessFilter = accessControlFilter;
        //string system = string.Join('-', filter.Elements);
        Task<List<string>> taskElements = dataContext.GetAvailableElements(filter);
        Task<List<WebAppUser>> taskUsers = dataContext.GetAvailableUsers(filter);
        List<ObjectInfo> listObjects = null!;
        List<Sample> listSamples = null!;
        Task<string> taskHtml = null!;
        int objectCount = 0;
        if (filter.ContainsChemicalSystem) {    // we need additionally: chemical system + arity
            listSamples = await dataContext.SearchByFilter<Sample>(SearchStoredProcedure_Filter.GetSample_Filter, filter);
            objectCount = listSamples.Count;
            taskHtml = this.RenderViewAsync("pObjectList", (listSamples as IEnumerable<ObjectInfo>, listSamples.Count), partial: true);
        }
        else {  // usual schema
            listObjects = await dataContext.SearchByFilter<ObjectInfo>(SearchStoredProcedure_Filter.GetObjectInfo_Filter, filter);
            objectCount = listObjects.Count;
            taskHtml = this.RenderViewAsync("pObjectList", (listObjects as IEnumerable<ObjectInfo>, listObjects.Count), partial: true);
        }
        await Task.WhenAll(taskElements, taskUsers, taskHtml);
        var retObj = new
        {
            objectCount = objectCount,
            objectListHtml = taskHtml.Result,
            availableElements = taskElements.Result,
            availablePersons = taskUsers.Result
        };
        return Json(retObj);
    }

    [HttpPost]
    public async Task<JsonResult> GetPropertyNames(PropertyType propertyType, int typeId) {
        var list = await dataContext.Property_GetPropertyNameByType(propertyType, typeId);
        return Json(list);
    }

    public class SearchPropertyAjax {
        public string Type { get; set; }
        public string Name { get; set; }
        public dynamic MinValue { get; set; }
        public dynamic MaxValue { get; set; }
    }



    public class ObjectResponse {
        public int ObjectId { get; set; }
        public SearchPropertyAjax[] Values { get; set; }
    }

    public class EnrichPropertiesResponse {
        public SearchPropertyAjax[] properties { get; set; }
        public int[] objectIds { get; set; }
        public ObjectResponse[] Values { get; set; }
    }

    [HttpPost]
    public async Task<JsonResult> EnrichProperties(SearchPropertyAjax[] properties, int[] objectIds)
    {
        //var list = new { properties, objectIds };
        EnrichPropertiesResponse resp = new EnrichPropertiesResponse() { properties = properties, objectIds = objectIds };
        List<ObjectResponse> values = new List<ObjectResponse>();
        foreach (int objectId in objectIds)
        {
            ObjectResponse r = new ObjectResponse() { ObjectId = objectId };
            List<SearchPropertyAjax> props = new List<SearchPropertyAjax>();
            foreach (SearchPropertyAjax prop in properties)
            {
                PropertyType pType = (PropertyType)Enum.Parse(typeof(PropertyType), prop.Type);
                // Type t = DBUtils.GetTypeByPropertyType(pType);
                List<(dynamic min, dynamic max)> res = await dataContext.GetList_ExecDevelopment<(dynamic min, dynamic max)>($"select MIN([Value]) as MinValue, MAX([Value]) as MaxValue from dbo.Property{pType} WHERE ObjectId=@objectId and PropertyName=@PropertyName", new { objectId, PropertyName = prop.Name });
                props.Add(new SearchPropertyAjax() { Type = prop.Type, Name = prop.Name, MinValue = res[0].min, MaxValue = res[0].max });
            }
            r.Values = props.ToArray();
            values.Add(r);
        }
        resp.Values = values.ToArray();
        return Json(resp);
    }

}