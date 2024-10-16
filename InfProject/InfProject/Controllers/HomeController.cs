using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using System.Data.SqlClient;
using System.Data;
using System.Diagnostics;
using InfProject.Models;
using InfProject.Utils;
using Dapper;
using InfProject.DBContext;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.AspNetCore.Diagnostics;

namespace InfProject.Controllers;

[AllowAnonymous]
public class HomeController : Controller
{
    private readonly ILogger<HomeController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;

    public HomeController(ILogger<HomeController> logger, IConfiguration config, DataContext dataContext)
    {
        this.logger = logger;
        this.config = config;
        this.dataContext = dataContext;
    }


    public IActionResult Index() => View();
    public IActionResult Privacy() => View();
    public IActionResult Doc() => View();

    //[Route("robots.txt")]
    //public IActionResult RobotsTxt() => View();
    public IActionResult TermsOfService() => View();

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }

    [Route("/StatusCode/{status:int}")]
    public IActionResult Status(int status)
    {
        string reasonPhrase = ReasonPhrases.GetReasonPhrase(status);
        string OriginalPathAndQuery = string.Empty;
        var statusCodeReExecuteFeature =
            HttpContext.Features.Get<IStatusCodeReExecuteFeature>();
        if (statusCodeReExecuteFeature is not null)
        {
            OriginalPathAndQuery = string.Join(
                statusCodeReExecuteFeature.OriginalPathBase,
                statusCodeReExecuteFeature.OriginalPath,
                statusCodeReExecuteFeature.OriginalQueryString);
        }
        logger.LogError("{status} error ({reasonPhrase}) occured on page {OriginalPathAndQuery}", status, reasonPhrase, OriginalPathAndQuery);
        return View((status, reasonPhrase));
    }
}