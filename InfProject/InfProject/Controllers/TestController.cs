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

[Authorize]
public class TestController : Controller
{
    private readonly UserManager<ApplicationUser> userManager;
    private readonly ILogger<TestController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;
    private readonly IWebHostEnvironment webHostEnvironment;
    private readonly IEmailSender mailSender;
    private readonly SmtpConfiguration smtpConfig;

    public TestController(UserManager<ApplicationUser> userManager, ILogger<TestController> logger, IConfiguration config, DataContext dataContext, IWebHostEnvironment webHostEnvironment, IEmailSender mailSender, SmtpConfiguration smtpConfig)
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
        return View();
    }


}