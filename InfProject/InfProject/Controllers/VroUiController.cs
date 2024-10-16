using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using System.Data.SqlClient;
using System.Data;
using System.Diagnostics;
using InfProject.Models;
using InfProject.Utils;
using Dapper;
using WebUtilsLib;
using InfProject.DBContext;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity.UI.Services;
using Microsoft.AspNetCore.Identity;
using IdentityManagerUI.Models;
using System.Text;
using Azure.Core.GeoJson;
using System.Security.Cryptography;
using InfProject.DTO;
using OfficeOpenXml.FormulaParsing.Excel.Functions.Engineering;
using TypeValidationLibrary;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace InfProject.Controllers;

[Authorize(Roles = "User,PowerUser,Administrator")]
public class VroUiController : Controller
{
    // Claim name to use Vro UI
    public const string ClaimNameToUseVroUi = "VroUi";

    static List<string> views;

    private static object _lock = new object();
    private List<string> GetViews() {
        if (views == null)
        {
            lock (_lock)
            {
                if (views == null)
                {
                    views = dataContext.GetList_ExecDevelopment<string>("SELECT [name] FROM sys.objects WHERE type = 'V' and schema_id = (select schema_id from Sys.schemas where name='vro') Order by [name]",
                        null, GetVroConnectionString()).Result;
                }
            }
        }
        return views;
    }


    /// <summary>
    /// checks access to Vro UI
    /// </summary>
    /// <param name="HttpContext"></param>
    /// <param name="claimName"></param>
    /// <returns>true = has access; false - no access</returns>
    public static bool HasAccess(HttpContext HttpContext, string claimName)
    {
        var access = HttpContext.User.HasClaim(claimName);
        return access;
    }


    private readonly UserManager<ApplicationUser> userManager;
    private readonly ILogger<VroUiController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;
    private readonly IHttpContextAccessor httpContextAccessor;

    public VroUiController(UserManager<ApplicationUser> userManager, ILogger<VroUiController> logger, IConfiguration config, DataContext dataContext, IHttpContextAccessor httpContextAccessor)
    {
        this.userManager = userManager;
        this.logger = logger;
        this.config = config;
        this.dataContext = dataContext;
        this.httpContextAccessor = httpContextAccessor;
    }

    public IActionResult Index() {
        var connectionString = GetVroConnectionString();
        (string sql, string connectionString, DataTable dt, string error, List<string> views) model = (string.Empty, connectionString, null, null, GetViews());
        return View(model);
    }


    
    public async Task<FileResult> ExecuteCsv(string sql) {
        var connectionString = GetVroConnectionString();
        (DataTable dt, string error) = await ExecWithAccessCheck(sql, connectionString);
        if (dt != null)
        {
            string fileName = "sqlresult.csv";
            string delimiter = ",";
            string csv = DataTable2CSV.GetCSVfromDataTable(delimiter, dt, includeHeaders: true, changeEndL2Space: true);
            byte[] fileBytes = Encoding.UTF8.GetBytes(csv);
            return File(fileBytes, "text/csv", fileName); // this is the key!
        }
        else {
            string fileName = "error.txt";
            byte[] fileBytes = Encoding.UTF8.GetBytes(error);
            return File(fileBytes, "text/plain", fileName); // this is the key!
        }
    }

    public async Task<IActionResult> Execute(string sql)
    {
        var connectionString = GetVroConnectionString();
        (DataTable dt, string error) = await ExecWithAccessCheck(sql, connectionString);
        (string sql, string connectionString, DataTable dt, string error, List<string> views) model = (sql, connectionString, dt, error, GetViews());
        return View("Index", model);
    }


    private async Task<(DataTable dt, string error)> ExecWithAccessCheck(string sql, string connectionString) {
        DataTable dt = null;
        string error = null;
        try
        {
            if (!HttpContext.User.HasClaim(ClaimNameToUseVroUi)) {
                throw new Exception("You don't have access to this functionality");
            }
            dt = await DataContext.GetTable_ExecDevelopment(sql, connectionString);
        }
        catch (Exception ex) {
            error = ex.GetType() + " " + ex.Message;
        }
        return (dt, error);
    }


    public static async Task<DataTable> Exec(string sql, string connectionString)
    {
        DataTable dt = await DataContext.GetTable_ExecDevelopment(sql, connectionString);
        return dt;
    }


    private string GetVroConnectionString() {
        var sourceConnectionString = dataContext.GetConnectionString(config, httpContextAccessor);
        (string connectionString, string databaseName) = GetVroConnectionString(sourceConnectionString, config);
        return connectionString;
    }

    public static (string connectionString, string databaseName) GetVroConnectionString(string sourceConnectionString, IConfiguration config) {
        var builder = new SqlConnectionStringBuilder(sourceConnectionString);
        builder.UserID = config["VRO:SqlUserName"];
        builder.Password = config["VRO:UserPassword"];
        var connectionString = builder.ToString();
        return (connectionString, builder.InitialCatalog);
    }

}