using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using System.Data.SqlClient;
using System.Data;
using System.Diagnostics;
using Dapper;
using System.Reflection;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using InfProject.DBContext;
using InfProject.Models;
using InfProject.Utils;
using WebUtilsLib;

namespace InfProject.Controllers;

public class AjaxController : Controller
{
    private readonly ILogger<AjaxController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;

    public AjaxController(ILogger<AjaxController> logger, IConfiguration config, DataContext dataContext)
    {
        this.logger = logger;
        this.config = config;
        this.dataContext = dataContext;
    }

    [HttpPost]
    public async Task<IActionResult> SearchObjectList([FromForm] string query, [FromForm] int typeId, [FromForm] int objectId)
    {
        var data = await dataContext.ObjectInfo_Find(query, typeId, objectId);
        return Json(data);
    }

    [HttpGet]
    public async Task<IActionResult> GetUsers()
    {
        // value: item.id,
        // text: `${item.project}) ${item.name} [${item.email}]`
        var data = await dataContext.GetUserListActive();
        return Json(data.Select(x => new { id=x.Id, name=x.Name, email=x.Email, project=x.Project }).OrderBy(x => $"{x.project} {x.name}"));
    }


    [HttpGet]
    public async Task<IActionResult> GetRubricText([FromQuery] int rubricid)
    {
        // value: item.id,
        // text: `${item.project}) ${item.name} [${item.email}]`
        var text = await dataContext.GetRubricText(rubricid);
        return Json(new { text });
    }

    [HttpGet]
    public async Task<IActionResult> GetObjectLinkRubricByObject([FromQuery] int objectid)
    {
        IEnumerable<ObjectLinkRubric> list = await dataContext.GetObjectLinkRubricByObject(objectid);
        return Json(new { ObjectLinkRubric = list });
    }

    [HttpGet]
    public async Task<IActionResult> GetSortCode_ObjectLinkRubric([FromQuery] int objectid, [FromQuery] int rubricid)
    {
        var list = await dataContext.GetList_ExecDevelopment<ObjectLinkRubric>("select top 1 * FROM dbo.ObjectLinkRubric WHERE RubricId=@rubricid AND ObjectId=@objectid",
            new { rubricid, objectid });
        ObjectLinkRubric res = list.Count>0 ? list[0] : null;
        string error = string.Empty;
        if (res == null) {
            error = "404 - not found";
        }
        if (string.IsNullOrEmpty(error) && HttpContext.IsWriteDenied(AccessControl.Public, (int)res._createdBy)) {
            error = "access denied (other user created the link)";
        }
        return Json(new { ObjectLinkRubric = res, error });
    }

    /// <summary>
    /// Get Object Information as JSON object
    /// </summary>
    /// <param name="objectId">ObjectId - has a priority</param>
    /// <param name="url">ObjectUrl - used if ObjectId==0</param>
    /// <returns>JSON</returns>
    [HttpGet]
    public async Task<IActionResult> GetObject([FromQuery] int objectId, [FromQuery] string url)
    {
        // https://mdi.matinf.pro/ajax/getobject?objectid=1
        // https://mdi.matinf.pro/ajax/getobject?objectid=2
        ObjectInfo o;
        if (objectId != 0)
        {
            o = await dataContext.ObjectInfo_Get(objectId);
        }
        else
        {
            o = await dataContext.GetObjectByUrl(url);
        }
        if (o == null || o.ObjectId == 0)
        {
            return NotFound($"Can not find object ({objectId}, {url})");
        }
        if (HttpContext.IsReadDenied(o.AccessControl, (int)o._createdBy))
        {
            return this.RedirectToLoginOrAccessDenied(HttpContext);
        }
        string sql = $@"select * from dbo.ObjectInfo WHERE ObjectId=@ObjectId FOR JSON AUTO";
        string json = await dataContext.GetList_ExecDevelopmentScalar<string>(sql, new { o.ObjectId });
        string origin = Request.Query["origin"];
        if (!string.IsNullOrEmpty(origin))
        {
            Response.Headers.Add("Access-Control-Allow-Origin", origin);
        }
        if (string.IsNullOrEmpty(json)) {
            json = "[]";
        }
        return Content(json, "application/json");
    }

    /// <summary>
    /// Get Object Properties as JSON object
    /// </summary>
    /// <param name="objectId">ObjectId - has a priority</param>
    /// <param name="url">ObjectUrl - used if ObjectId==0</param>
    /// <returns>JSON</returns>
    [HttpGet]
    public async Task<IActionResult> GetObjectProperties([FromQuery] int objectId, [FromQuery] string url)
    {
        // https://mdi.matinf.pro/ajax/getobjectproperties?objectid=1
        // https://mdi.matinf.pro/ajax/getobjectproperties?objectid=2
        ObjectInfo o;
        if (objectId != 0)
        {
            o = await dataContext.ObjectInfo_Get(objectId);
        }
        else
        {
            o = await dataContext.GetObjectByUrl(url);
        }
        if (o == null || o.ObjectId == 0)
        {
            return NotFound($"Can not find object ({objectId}, {url})");
        }
        if (HttpContext.IsReadDenied(o.AccessControl, (int)o._createdBy))
        {
            return this.RedirectToLoginOrAccessDenied(HttpContext);
        }
        string sql = $@"select * from dbo.fn_GetObjectProperties(@ObjectId) order by SortCode FOR JSON AUTO";
        string json = await dataContext.GetList_ExecDevelopmentScalar<string>(sql, new { o.ObjectId });
        string origin = Request.Query["origin"];
        if (!string.IsNullOrEmpty(origin))
        {
            Response.Headers.Add("Access-Control-Allow-Origin", origin);
        }
        if (string.IsNullOrEmpty(json)) {
            json = "[]";
        }
        return Content(json, "application/json");
    }



    /// <summary>
    /// gets the current state of the request (so far only IsUserAuthentificated for user )
    /// /ajax/getstate
    /// </summary>
    /// <returns></returns>
    [HttpGet]
    public async Task<JsonResult> GetState()
    {
        return new JsonResult(new
        {
            IsUserAuthentificated = Request.Cookies[".AspNetCore.Identity.Application"] != null
        });
    }
}
