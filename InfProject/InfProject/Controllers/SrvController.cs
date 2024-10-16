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
using Microsoft.EntityFrameworkCore.Metadata.Internal;

namespace InfProject.Controllers;

[Authorize(Policy = "RequireAdministratorRole")]
public class SrvController : Controller
{
    private readonly UserManager<ApplicationUser> userManager;
    private readonly ILogger<SrvController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;
    private readonly IWebHostEnvironment webHostEnvironment;
    private readonly IEmailSender mailSender;
    private readonly SmtpConfiguration smtpConfig;

    public SrvController(UserManager<ApplicationUser> userManager, ILogger<SrvController> logger, IConfiguration config, DataContext dataContext, IWebHostEnvironment webHostEnvironment, IEmailSender mailSender, SmtpConfiguration smtpConfig)
    {
        this.userManager = userManager;
        this.logger = logger;
        this.config = config;
        this.dataContext = dataContext;
        this.webHostEnvironment = webHostEnvironment;
        this.mailSender = mailSender;
        this.smtpConfig = smtpConfig;
    }

    public IActionResult Index() {
        var obj = new { First = "first", Second = "second" };
        var obj2 = new { First2 = "first22", Second2 = "second22" };
        logger.LogInformation("We have to write {obj} and later we write {obj2} !", obj, obj2);
        return View((webHostEnvironment, config, mailSender, smtpConfig, userManager));
    }


    public static async Task RecalculateFileHashMain(bool allTenants, DataContext dataContext, Func<string, string> mapStorageFile, Action<string> errLogger, Action<string>? pulseLog = null) {
        int objectId = 0;
        int updated=0;
        int errCount = 0;
        string ObjectFilePath = string.Empty;
        string ObjectNameUrl = string.Empty;
        StringBuilder sbErr = new StringBuilder();

        List<dynamic> files = await dataContext.ObjectInfo_GetFilesAndHashes(allTenants);
        pulseLog?.Invoke($"Selected {files.Count} entries");
        using (SHA256 sha256 = SHA256.Create())
        {
            for (int i = 0; i < files.Count; i++)
            {
                objectId = files[i].ObjectId;
                int TenantId = files[i].TenantId;
                ObjectNameUrl = files[i].ObjectNameUrl;
                ObjectFilePath = files[i].ObjectFilePath;
                string ObjectFileHash = files[i].ObjectFileHash;
                string hash = null;
                if (!string.IsNullOrEmpty(ObjectFilePath))
                {
                    string filePathFull = mapStorageFile(ObjectFilePath);
                    hash = WebUtilsLib.HashUtils.CalculateHash(sha256, filePathFull);
                }

                if (string.CompareOrdinal(hash, ObjectFileHash) != 0)
                { // update hash
                    try
                    {
                        await dataContext.ObjectInfo_UpdateObjectFileHash(objectId, hash);
                        updated++;
                    }
                    catch (Exception ex)
                    {
                        errCount++;
                        if (sbErr.Length > 0)
                            sbErr.Append("<br/>");
                        string st = $"Error dataContext.ObjectInfo_UpdateObjectFileHash: {ex.Message} [ObjectId={objectId}, ObjectFilePath={ObjectFilePath}, ObjectNameUrl={ObjectNameUrl}]";
                        sbErr.AppendLine(st);
                        errLogger?.Invoke(st);
                        pulseLog?.Invoke(st);
                    }
                }
                if (i % 100 == 0) {
                    pulseLog?.Invoke($"Pulse {DateTime.Now}: {i+1}/{files.Count} done");
                }
            }
        }
        pulseLog?.Invoke($"RecalculateFileHashMain done (entries: {files.Count}): errors: {errCount}, updated: {updated}");
    }


    /// <summary>
    /// Output wafer
    /// </summary>
    /// <returns>View with wafer</returns>
    [HttpPost]
    public async Task<IActionResult> RecalculateFileHash()
    {
        bool allTenants;
        bool.TryParse(Request.Form["allTenants"], out allTenants);
        string sbErr = string.Empty;
        try
        {
            await RecalculateFileHashMain(allTenants, dataContext, config.MapStorageFile, (string s) => logger.LogError(s));
            TempData["Suc"] = $"Hash recalculated successfully [allTenants={allTenants}]";
            logger.LogInformation($"Hash recalculated successfully [allTenants={allTenants}]");
        }
        catch (Exception ex)
        {
            sbErr = $"<br/>Error RecalculateFileHash: {ex.Message} [TenantId={dataContext.Tenant.TenantId}, allTenants={allTenants}]";
            logger.LogError($"Error RecalculateFileHash {ex.ToStringForLog()} [TenantId={dataContext.Tenant.TenantId}, allTenants={allTenants}]");
        }
        TempData["Err"] = sbErr;
        return Redirect("/srv/");
    }

    /// <summary>
    /// Sends email
    /// </summary>
    /// <param name="email"></param>
    /// <param name="subject"></param>
    /// <param name="htmlMessage"></param>
    /// <returns></returns>
    [HttpPost]
    public async Task<JsonResult> SendMail(string email, string subject, string htmlMessage) {
        try
        {
            await mailSender.SendEmailAsync(email, subject, htmlMessage);
        }
        catch (Exception ex)
        {
            return Json(new { status = ex.GetType().ToString(), message = ex.Message });
        }
        return Json(new { status = "ok", message = "" });
    }



    /// <summary>
    /// Executes SQL on all databases
    /// </summary>
    /// <param name="sql">SQL script to execute</param>
    /// <returns></returns>
    [HttpPost]
    public async Task<IActionResult> ExecSQLAll(string sql)
    {
        string name = string.Empty, value = string.Empty, sqlCurrent = string.Empty;
        int res;
        try
        {
            // Execute SQL on all databases

            var connectionStrings = config.GetSection("ConnectionStrings").GetChildren();
            Dictionary<string, string> dic = new Dictionary<string, string>();

            foreach (var connectionString in connectionStrings)
            {
                name = connectionString.Key;
                value = connectionString.Value;
                if(name.StartsWith("InfDB"))
                {
                    if (dic.TryGetValue(value, out string key))
                    {
                        continue;
                    }
                    dic.Add(value, name);
                    using (IDbConnection connection = new SqlConnection(value)) {
                        string[] sqlArray = $"{Environment.NewLine}{sql}{Environment.NewLine}".Split($"{Environment.NewLine}GO{Environment.NewLine}", StringSplitOptions.RemoveEmptyEntries);
                        foreach (var item in sqlArray)
                        {
                            sqlCurrent = item;
                            res = await connection.ExecuteAsync(sqlCurrent);
                        }
                    }
                }
            }
            TempData["Suc"] = $"SQL execution successful";
        }
        catch (Exception ex)
        {
            TempData["Err"] = $"Error ExecSQLAll: {ex.Message} [name={name}; value={value}; {sql}]";
            logger.LogError($"Error ExecSQLAll {ex.ToStringForLog()} [name={name}; value={value}; {sql}]");
        }
        return RedirectToRoute(new { controller = "Srv", action = "Index" });
    }



    /// <summary>
    /// Output wafer
    /// </summary>
    /// <returns>View with wafer</returns>
    public async Task<IActionResult> Wafer()
	{
	    return View();
	}

}