using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using System.Data.SqlClient;
using System.Data;
using System.Diagnostics;
using InfProject.Models;
using InfProject.Utils;
using WebUtilsLib;
using InfProject.DBContext;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Serilog.Parsing;
using Microsoft.AspNetCore.Identity;
using System.Security.Claims;
using System.Net;

namespace InfProject.Controllers;

[Authorize(Roles = "PowerUser,Administrator")]
public class AdminTreeController : Controller
{
    private readonly ILogger<AdminTreeController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;
    private readonly IWebHostEnvironment webHostEnvironment;

    public AdminTreeController(ILogger<AdminTreeController> logger, IConfiguration config, DataContext dataContext, IWebHostEnvironment webHostEnvironment)
    {
        this.logger = logger;
        this.config = config;
        this.dataContext = dataContext;
        this.webHostEnvironment = webHostEnvironment;
    }


    public async Task<IActionResult> Index() {

        // var list = await dataContext.GetTypesHierarchical();
        var list = await dataContext.GetTypesHierarchicalWithCount();
        return View(list);
    }



    public async Task<IActionResult> ManualEdit([FromRoute(Name = "id")] int idType)
    {
        var type = await dataContext.GetType(idType);
        AccessControlFilter accessControlFilter = HttpContext.GetAccessControlFilter();
        var list = await dataContext.GetList_RubricTree_AccessControl(idType, accessControlFilter);
        return View((type, list));
    }

    [HttpPost]
    public async Task<IActionResult> UpdateInsert([FromForm] RubricInfo rubric, string text)
    {
        string returl = Request.Form["returl"];
        try
        {
            RubricInfo rOld = rubric.RubricId!=0 ? await dataContext.GetRubricById(rubric.RubricId) : new RubricInfo();  // read old
            if (rOld.RubricId == 0) { // add
                if (!HttpContext.User.IsInRole(UserGroups.PowerUser) && !HttpContext.User.IsInRole(UserGroups.Administrator))
                    throw new UnauthorizedAccessException("User is not PowerUser or Administrator");
            }
            else if (!HttpContext.User.IsInRole(UserGroups.Administrator)) { // update and not admin!
                if (!HttpContext.User.IsInRole(UserGroups.PowerUser))
                    throw new UnauthorizedAccessException("User is not PowerUser or Administrator");
                if (HttpContext.IsWriteDenied(rOld.AccessControl, (int)rOld._createdBy))
                    throw new UnauthorizedAccessException("User can not update this item");
            }
            rubric.TenantId = dataContext.TenantId;
            int userId = HttpContext.GetUserId();
            rubric._createdBy = userId;
            rubric._updatedBy = userId;
            rubric._created = DateTime.Now;
            rubric._updated = DateTime.Now;
            RubricInfo newRubric = await dataContext.RubricInfo_UpdateInsert(rubric);

            // Important (no protection here: considering that all security checks were successfull for the upper code)
            await dataContext.RubricInfoAdds_Update(newRubric.RubricId, text);

            if (rubric.RubricId == 0) {
                rubric.RubricId = newRubric.RubricId;
                TempData["Suc"] = $"Insert successful";
                logger.LogInformation($"Insert successful [RubricId={newRubric.RubricId}]");
            }
            else {
                TempData["Suc"] = $"Update successful";
                logger.LogInformation($"Update successful [RubricId={newRubric.RubricId}]");
            }
        }
        catch (Exception ex)
        {
            TempData["Err"] = $"Error {(rubric.RubricId == 0 ? "inserting" : "updating")} rubric: {ex.Message}";
            logger.LogError($"Error dataContext.RubricInfo_UpdateInsert {ex.ToStringForLog()} [{rubric}]");
        }
        // return Redirect($"/admintree/manualedit/{typeId}");
        if (!string.IsNullOrEmpty(returl)) {
            returl = WebUtility.UrlDecode(returl);
            return Redirect(returl);
        }
        return RedirectToRoute(new { controller = "AdminTree", action = "ManualEdit", id = rubric.TypeId });
    }


    [HttpPost]
    public async Task<IActionResult> Delete([FromForm] int rubricId, [FromForm] int typeId) {
        string returl = Request.Form["returl"];
        try
        {
            RubricInfo rOld = await dataContext.GetRubricById(rubricId);
            if (!HttpContext.User.IsInRole(UserGroups.Administrator))
            {   // update and not admin!
                if (!HttpContext.User.IsInRole(UserGroups.PowerUser))
                    throw new UnauthorizedAccessException("User is not PowerUser or Administrator");
                if (HttpContext.IsWriteDenied(rOld.AccessControl, (int)rOld._createdBy))
                    throw new UnauthorizedAccessException("User can not delete this item");
            }
            int rowsAffected = await dataContext.RubricInfo_Delete(rubricId);
            TempData["Suc"] = $"Delete successful [{rowsAffected} row(s)]";
            logger.LogInformation($"Delete successful [RubricId={rubricId}, {rowsAffected} row(s) affected]");
        }
        catch (Exception ex)
        {
            TempData["Err"] = $"Error deleting rubric: {ex.Message}";
            logger.LogError($"Error dataContext.RubricInfo_Delete {ex.ToStringForLog()}");
        }
        // return Redirect($"/admintree/manualedit/{typeId}");
        if (!string.IsNullOrEmpty(returl))
        {
            returl = WebUtility.UrlDecode(returl);
            return Redirect(returl);
        }
        return RedirectToRoute(new { controller = "AdminTree", action = "ManualEdit", id = typeId });
    }


    #region Test rejected

    /// <summary>
    /// Test with gijgo Grid Edit - rejected (too complex to maintain)
    /// </summary>
    /// <param name="idType"></param>
    /// <returns></returns>
    public async Task<IActionResult> ViewTree([FromRoute(Name = "id")] int idType)
    {
        dynamic type = await dataContext.GetItem_Development(tableName: "TypeInfo", filter: $"TypeId={idType}");
        return View((type, string.Empty));
    }


    public async Task<IActionResult> GetTreeData([FromRoute(Name = "id")] int idType)
    {
        var list = await dataContext.GetList_ExecDevelopment<dynamic>($"SELECT * FROM dbo.RubricInfo WHERE TenantId={dataContext.TenantId} AND TypeId={idType} ORDER BY RubricPath ASC");
        return Json(new { records = list, total = list.Count });
    }
    #endregion  // Test rejected
}