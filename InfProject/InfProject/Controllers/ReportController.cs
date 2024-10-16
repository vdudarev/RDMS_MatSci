using Azure.Core.GeoJson;
using Dapper;
using FluentValidation;
using FluentValidation.AspNetCore;
using FluentValidation.Results;
using Humanizer;
using InfProject.DBContext;
using InfProject.Models;
using InfProject.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Build.Evaluation;
using Microsoft.CodeAnalysis;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Data;
using System.Diagnostics.Metrics;
using System.Reflection;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using WebUtilsLib;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;
using static System.Net.Mime.MediaTypeNames;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace InfProject.Controllers;

[Authorize(Roles = "User,PowerUser,Administrator")]
public class ReportController : Controller
{
    private readonly IValidator<ObjectInfo> validator;
    private readonly ILogger<ReportController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;
    private readonly IWebHostEnvironment webHostEnvironment;

    public ReportController(IValidator<ObjectInfo> validator, ILogger<ReportController> logger, IConfiguration config, DataContext dataContext, IWebHostEnvironment webHostEnvironment)
    {
        this.validator = validator;
        this.logger = logger;
        this.config = config;
        this.dataContext = dataContext;
        this.webHostEnvironment = webHostEnvironment;
    }

    /// <summary>
    /// Users report
    /// </summary>
    /// <returns></returns>
    //[HttpGet("users")]
    public async Task<IActionResult> Users()
    {
        DataTable dt = await dataContext.GetTable_ExecDevelopment(@"select
	U.Id as UserId, U.Email,
	[dbo].[fn_GetUserClaimCSV](U.Id, 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name') as [Name],	-- cName.ClaimValue as [Name], 
	[dbo].[fn_GetUserRolesCSV](U.Id) as Roles, 
	-- [dbo].[fn_GetUserClaimCSV](U.Id, 'NDA') as Nda,	-- IIF(cNda.ClaimValue=1, 1, 0) as Nda, 
    CAST(IIF( CONVERT(INT, CASE WHEN IsNumeric([dbo].[fn_GetUserClaimCSV](U.Id, 'NDA')) = 1 THEN [dbo].[fn_GetUserClaimCSV](U.Id, 'NDA') ELSE 0 END) <> 0, 1, 0) as bit) as NDA, 
	[dbo].[fn_GetUserClaimCSV](U.Id, 'Project') as Project	-- cProject.ClaimValue as Project, 
from dbo.AspNetUsers as U
--LEFT OUTER JOIN AspNetUserClaims as cNda ON U.Id=cNda.UserId AND cNda.ClaimType='NDA'
--LEFT OUTER JOIN AspNetUserClaims as cProject ON U.Id=cProject.UserId AND cProject.ClaimType='Project'
--LEFT OUTER JOIN AspNetUserClaims as cName ON U.Id=cName.UserId AND cName.ClaimType='http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'
ORDER BY U.Id
");
        TableView obj = new TableView(dt) { Title = "Users report" };
        return View("Table", obj);
    }

    private async Task<List<WCSampleShort>> GetSamplesEmptyFull(int userid)
    {
        int accessControl = 0;  //  HttpContext.GetWCAccessControlInt();   // set AccessControl
        var res = await dataContext.GetList_ExecDevelopment<WCSampleShort>(@$"select * FROM dbo.[fn_CompactSamples]({dataContext.TenantId})
WHERE /*AccessControl<=@accessControl AND*/ DepositionCount=0 AND CharacterizationCount=0
{(userid == 0 ? "-- " : string.Empty)} AND _createdBy=@userid
ORDER BY ProjectId DESC", new { userid, accessControl });
        return res;
    }

    private async Task<List<WCSampleShort>> GetSamplesEmpty(int userid)
    {
        int accessControl = 0;  //  HttpContext.GetWCAccessControlInt();   // set AccessControl
        var res = await dataContext.GetList_ExecDevelopment<WCSampleShort>(@$"select * FROM dbo.[fn_CompactSamples]({dataContext.TenantId})
WHERE /*AccessControl<=@accessControl AND*/ (DepositionCount=0 OR CharacterizationCount=0)
{(userid == 0 ? "-- " : string.Empty)} AND _createdBy=@userid
ORDER BY ProjectId DESC", new { userid, accessControl });
        return res;
    }


    private async Task<List<dynamic>> GetSamplesDocByMonth(int userid)
    {
        var res = await dataContext.GetList_ExecDevelopment<dynamic>(@$"select FORMAT(Created, 'yyyy-MM') as x, count(ProjectId) as y, SUM(DepositionCount) as yDep, SUM(CharacterizationCount) as yChar
FROM dbo.[fn_CompactSamples]({dataContext.TenantId})
{(userid==0 ? "-- " : string.Empty)} WHERE _createdBy=@userid
GROUP BY FORMAT(Created, 'yyyy-MM')
ORDER BY x", new { userid });
        return res;
    }
    

    private async Task<List<dynamic>> GetSamplesByMonth(int userid)
    {
        var res = await dataContext.GetList_ExecDevelopment<dynamic>(@$"select FORMAT(Created, 'yyyy-MM') as x, count(ProjectId) as y
FROM dbo.[fn_CompactSamples]({dataContext.TenantId})
{(userid == 0 ? "-- " : string.Empty)} WHERE _createdBy=@userid
GROUP BY FORMAT(Created, 'yyyy-MM')
ORDER BY x", new { userid });
        return res;
    }

    private async Task<List<dynamic>> GetSamplesByYear(int userid)
    {
        var res = await dataContext.GetList_ExecDevelopment<dynamic>(@$"select YEAR(Created) as x, count(ProjectId) as y
FROM dbo.[fn_CompactSamples]({dataContext.TenantId})
{(userid == 0 ? "-- " : string.Empty)} WHERE _createdBy=@userid
GROUP BY YEAR(Created)
ORDER BY x", new { userid });
        return res;
    }

    private async Task<List<dynamic>> GetSamplesBySubstrate(int userid)
    {
        var res = await dataContext.GetList_ExecDevelopment<dynamic>(@$"select SubstrateId as x, SubstrateMaterial as xLabel, count(ProjectId) as y
FROM dbo.[fn_CompactSamples]({dataContext.TenantId})
{(userid == 0 ? "-- " : string.Empty)} WHERE _createdBy=@userid
GROUP BY SubstrateId, SubstrateMaterial
ORDER BY SubstrateMaterial", new { userid });
        return res;
    }


    private async Task<List<dynamic>> GetSamplesByElement(int userid)
    {
        string sql = @$"select El.ElementId as x, El.ElementName as xLabel, count(q.ProjectId) as y FROM 
(select ProjectId, [Elements], E.value from dbo.[fn_CompactSamples]({dataContext.TenantId}) as S
CROSS APPLY {dataContext.GetSTRING_SPLIT}(substring([Elements], 2, LEN([Elements])-2),'-') as E
{(userid == 0 ? "-- " : string.Empty)} WHERE _createdBy=@userid
) as q
INNER JOIN dbo.ElementInfo as El on El.ElementName = q.value
GROUP BY El.ElementId, El.ElementName
ORDER BY El.ElementId";
        var res = await dataContext.GetList_ExecDevelopment<dynamic>(sql, new { userid });
        return res;
    }


    private async Task<List<dynamic>> GetSamplesByField(string FieldName = "SubstrateMaterial", string filter = " AND SubstrateId<>0 ", int userid = 0)
    {
        if (filter == null)
            filter = string.Empty;
        if (userid != 0)
            filter += " AND _createdBy = @userid ";

        var res = await dataContext.GetList_ExecDevelopment<dynamic>(@$"select {FieldName} as x, count(ProjectId) as y
FROM dbo.Samples WHERE 1=1 {filter}
GROUP BY {FieldName}
ORDER BY x", new { userid });
        return res;
    }
    

    public async Task<IActionResult> SamplesEmptyFull([FromQuery] int userid = 0)
    {
        var users = await dataContext.GetUserListAll(); // dataContext.GetAvailablePersons(null),
        return View("SamplesEmpty",
            (
            await GetSamplesEmptyFull(userid),
            users,
            userid,
            "full"
            ));
    }

    public async Task<IActionResult> SamplesEmpty([FromQuery] int userid = 0)
    {
        var users = await dataContext.GetUserListAll(); // dataContext.GetAvailablePersons(null),
        return View("SamplesEmpty",
            (
            await GetSamplesEmpty(userid),
            users,
            userid,
            "weak"
            ));
    }


    public async Task<IActionResult> SamplesDocByMonth([FromQuery] int userid = 0)
    {
        var users = await dataContext.GetUserListAll(); // dataContext.GetAvailablePersons(null),
        return View(
            (
            await GetSamplesDocByMonth(userid),
            users,
            userid
            ));
    }

    public async Task<IActionResult> SamplesByMonth([FromQuery] int userid = 0)
    {
        var users = await dataContext.GetUserListAll(); // dataContext.GetAvailablePersons(null),
        return View(//"SamplesBy",
            (
            await GetSamplesByMonth(userid),
            users,
            userid
            ));
    }

    public async Task<IActionResult> SamplesByYear([FromQuery] int userid = 0)
    {
        var users = await dataContext.GetUserListAll(); // dataContext.GetAvailablePersons(null),
        return View(//"SamplesBy",
            (
            await GetSamplesByYear(userid),
            users,
            userid
            ));
    }
    
    public async Task<IActionResult> SamplesBySubstrate([FromQuery] int userid = 0)
    {
        var users = await dataContext.GetUserListAll(); // dataContext.GetAvailablePersons(null),
        return View((
            await GetSamplesBySubstrate(userid),
            users,
            userid,
            "substrate"));
    }


    public async Task<IActionResult> SamplesByElement([FromQuery] int userid = 0)
    {
        var users = await dataContext.GetUserListAll(); // dataContext.GetAvailablePersons(null),
        return View((
            await GetSamplesByElement(userid),
            users,
            userid,
            "element"));
    }

    public async Task<IActionResult> SamplesBy([FromQuery] int userid = 0)
    {
        var users = await dataContext.GetUserListAll(); // dataContext.GetAvailablePersons(null),
        return View((
            await GetSamplesByField("SubstrateMaterial", string.Empty, userid),
            users,
            userid,
            "substrate"));
    }





    public async Task<IActionResult> ObjectsStatistics([FromQuery] int userid = 0)
    {
        var users = await dataContext.GetUserListAll(); // dataContext.GetAvailablePersons(null),
        int rubricCount = await dataContext.GetList_ExecDevelopmentScalar<int>(@$"select count(RubricId) as RubricCount from dbo.RubricInfo
WHERE TenantId={dataContext.TenantId}
{(userid == 0 ? "-- " : string.Empty)} AND _createdBy=@userid", new { userid });
        int objectLinkCount = await dataContext.GetList_ExecDevelopmentScalar<int>(@$"select count(ObjectLinkObjectId) as ObjectLinkCount from dbo.ObjectLinkObject
WHERE ObjectId IN (select ObjectId from dbo.ObjectInfo WHERE TenantId={dataContext.TenantId})
{(userid == 0 ? "-- " : string.Empty)} AND _createdBy=@userid", new { userid });
        var res = await dataContext.GetList_ExecDevelopment<dynamic>(@$"select TI.TypeId, TI.TypeName, TI.TypeComment, count(OI.ObjectId) as ObjectCount
from dbo.ObjectInfo as OI
INNER JOIN dbo.TypeInfo as TI ON TI.TypeId=OI.TypeId
WHERE OI.TenantId={dataContext.TenantId}
{(userid == 0 ? "-- " : string.Empty)} AND OI._createdBy=@userid
GROUP BY ROLLUP((TI.TypeId, TI.TypeName, TI.TypeComment))
ORDER BY ObjectCount desc, TI.TypeName desc", new { userid });
        return View((
            res,
            users,
            userid,
            rubricCount,
            objectLinkCount));
    }


    public async Task<IActionResult> UsersStatistics([FromQuery] int userid = 0)
    {
        return View();
    }

    public async Task<IActionResult> RequestsForSynthesis() => View();
    public async Task<IActionResult> IdeasAndPlans() => View();
    public async Task<IActionResult> UnclassifiedSamples() => View();
}