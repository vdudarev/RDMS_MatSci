using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using System.Data.SqlClient;
using System.Data;
using Dapper;
using WebUtilsLib;
using InfProject.DBContext;
using Microsoft.AspNetCore.Identity.UI.Services;
using Microsoft.AspNetCore.Identity;
using IdentityManagerUI.Models;

namespace InfProject.Controllers;

// /integration/externalid/10259/?typeid=6
[Route("integration")]
public class IntegrationController : Controller
{
    private readonly UserManager<ApplicationUser> userManager;
    private readonly ILogger<IntegrationController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;
    private readonly IWebHostEnvironment webHostEnvironment;
    private readonly IEmailSender mailSender;
    private readonly SmtpConfiguration smtpConfig;

    public IntegrationController(UserManager<ApplicationUser> userManager, ILogger<IntegrationController> logger, IConfiguration config, DataContext dataContext, IWebHostEnvironment webHostEnvironment, IEmailSender mailSender, SmtpConfiguration smtpConfig)
    {
        this.userManager = userManager;
        this.logger = logger;
        this.config = config;
        this.dataContext = dataContext;
        this.webHostEnvironment = webHostEnvironment;
        this.mailSender = mailSender;
        this.smtpConfig = smtpConfig;
    }

    /// <summary>
    /// redirect to object by it's ExternalId
    /// </summary>
    /// <param name="id">ExternalId</param>
    /// <param name="typeId">optional TypeId (if >0, then considered)</param>
    /// <returns></returns>
    [HttpGet("externalid/{id}")]
    public async Task<IActionResult> ExternalId([FromRoute] int id, [FromQuery] int typeId)
    {
        var connectionStrings = config.GetSection("ConnectionStrings").GetChildren();
        Dictionary<string, string> dicConnectionStrings = new Dictionary<string, string>();
        List<dynamic> list = new List<dynamic>();
        foreach (var connectionString in connectionStrings)
        {
            string name = connectionString.Key;
            string value = connectionString.Value;
            if (!name.StartsWith("InfDB")) {
                continue;
            }
            if (dicConnectionStrings.TryGetValue(value, out string key)) // see above (already was done)
            {
                continue;
            }
            dicConnectionStrings.Add(value, name);

            // real processing with connection string
            using (IDbConnection connection = new SqlConnection(value))
            {
                string sql = @"SELECT OI.TenantId, TenantUrl, TenantName, TypeId, ObjectId, ObjectName, ObjectNameUrl, _created, ExternalID
FROM dbo.ObjectInfo as OI
INNER JOIN dbo.Tenant as TI ON TI.TenantId=OI.TenantId
WHERE ExternalId=@externalId";
                if (typeId != 0)
                {
                    sql += " AND TypeId=@typeId";
                }
                var res = await connection.QueryAsync<dynamic>(sql, new { externalId = id, typeId });
                //if (res.Count > 0) {
                    list.AddRange(res);
                //}
            }
        }
        if (!list.Any())    { // no elements
            TempData["Err"] = $"Can not find object by external id: {id}{(typeId != 0 ? $" [typeId={typeId}]" : string.Empty)}";
            return Redirect("/");
        }
        if (list.Count == 1) { // single element
            return Redirect($"https://{list[0].TenantUrl}/object/{list[0].ObjectNameUrl}");
        }
        // several elements (multiple choice)
        list = list.OrderByDescending(x=> x._created).ToList();
        return View("Index", list);
    }
}