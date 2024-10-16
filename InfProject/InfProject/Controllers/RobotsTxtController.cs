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
[Route("robots.txt")]
public class RobotsTxtController : Controller
{
    private readonly ILogger<RobotsTxtController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;

    public RobotsTxtController(ILogger<RobotsTxtController> logger, IConfiguration config, DataContext dataContext)
    {
        this.logger = logger;
        this.config = config;
        this.dataContext = dataContext;
    }

    public IActionResult Index() {
        HttpContext.Response.ContentType = "text/plain";
        return View();
    }
}