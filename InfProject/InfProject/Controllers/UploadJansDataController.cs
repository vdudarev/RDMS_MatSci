using Azure.Core;
using Azure.Core.GeoJson;
using FluentValidation;
using FluentValidation.AspNetCore;
using FluentValidation.Results;
using InfProject.DBContext;
using InfProject.Models;
using InfProject.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity.UI.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using Microsoft.Extensions.Primitives;
using System.Collections.ObjectModel;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using WebUtilsLib;

namespace InfProject.Controllers;

[Authorize(Roles = "Administrator")]
public class UploadJansDataController : Controller
{

    private readonly IValidator<ObjectInfo> validator;
    private readonly ILogger<UploadJansDataController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;
    private readonly IWebHostEnvironment webHostEnvironment;
    private readonly ICompositeViewEngine viewEngine;
    private readonly IEmailSender mailSender;

    public UploadJansDataController(IValidator<ObjectInfo> validator, ILogger<UploadJansDataController> logger, IConfiguration config, DataContext dataContext, IWebHostEnvironment webHostEnvironment, ICompositeViewEngine viewEngine, IEmailSender mailSender)
    {
        this.validator = validator;
        this.logger = logger;
        this.config = config;
        this.dataContext = dataContext;
        this.webHostEnvironment = webHostEnvironment;
        this.viewEngine = viewEngine;
        this.mailSender = mailSender;
    }

    public async Task<IActionResult> Index() => View();

    public async Task<IActionResult> Test() {
        var testCases = new List<string>
            {
                "C11H22O12",
                "Al2O3",
                "O3",
                "C",
                "H2O"
            };
        StringBuilder sb = new StringBuilder();
        foreach (string testCase in testCases)
        {
            sb.AppendFormat("Testing {0}\r\n", testCase);
            var formula = FormulaFromString(testCase);
            foreach (var element in formula)
            {
                sb.AppendFormat("{0} : {1}\r\n", element.Element, element.Quantity);
            }
            sb.AppendLine();
        }

        /* Produced the following output

        Testing C11H22O12
        C : 11
        H : 22
        O : 12

        Testing Al2O3
        Al : 2
        O : 3

        Testing O3
        O : 3

        Testing C
        C : 1

        Testing H2O
        H : 2
        O : 1

        */
        Console.WriteLine(sb);
        ViewBag.ret = sb.ToString();
        return View(viewName: "Index");
    }



    [HttpPost]
    public async Task<IActionResult> UploadData(string pathToSrcFolder, string projectRubricPath)
    {
        int rowsAffected = 0;
        int objectId = 0;
        int nestLevel = 0;
        ViewBag.ret = "";
        try
        {
            int userId = HttpContext.GetUserId();
            var ret = await UploadDataRecursive(pathToSrcFolder, projectRubricPath, nestLevel);
            ViewBag.ret = ret;
            // @"C:\RUB\!WORK\DEMI\Data_JackKirkPedersen"
            TempData["Suc"] = $"UploadData processed successfully";
        }
        catch (Exception ex)
        {
            ViewBag.ret = TempData["Err"] = $"Error UploadData: {ex.Message}";
            logger.LogError($"Error UploadJansDataController.UploadData {ex.ToStringForLog()} [objectId={objectId}]");
        }
        return View(viewName: "Index");
    }

    private async Task<string> UploadDataRecursive(string pathToSrcFolder, string projectRubricPath, int nestLevel)
    {
        StringBuilder sb = new StringBuilder();
        sb.AppendLine($"<div class=\"border ms-{nestLevel}\">");
        sb.AppendLine($"<p class=\"mb-0 bg-warning-subtle\"><b class=\"text-danger\">UploadDataRecursive</b>[{nestLevel}]: <u>pathToSrcFolder</u>={pathToSrcFolder}, <u>projectRubricPath</u>={projectRubricPath}</p>");
        DirectoryInfo dir = new DirectoryInfo(pathToSrcFolder);
        string desc = null;
        string fn = Path.Combine(pathToSrcFolder, "readme.txt");
        if (System.IO.File.Exists(fn)) {
            desc = System.IO.File.ReadAllText(fn);
            sb.AppendLine($"  <b>DESCRIPTION for rubric</b>: <small>{desc}</small>");
        }

        // Create Project / Update Description => get RubricId


        // Enumerate files
        foreach (var file in dir.GetFiles())
        {
            if (string.Compare(file.Name, "readme.txt", true) == 0)
            {
                continue;
            }
            sb.AppendLine("   <u>File</u>: " + file.Name);
        }

        // Enumerate directories
        string[] subdirectories = Directory.GetDirectories(pathToSrcFolder);
        foreach (var subdirectory in dir.GetDirectories())
        {
            sb.AppendLine("   <u>Directory</u>: " + subdirectory.Name);
            var ret = await UploadDataRecursive(Path.Combine(pathToSrcFolder, subdirectory.Name),
                projectRubricPath + "}" + subdirectory.Name,
                nestLevel + 1); // Recursive call to traverse subdirectory
            sb.Append(ret);
        }
        sb.AppendLine("</div>");

        return sb.ToString();
    
    }

    private static Collection<ChemicalFormulaComponent> FormulaFromString(string chemicalFormula)
    {
        Collection<ChemicalFormulaComponent> formula = new Collection<ChemicalFormulaComponent>();
        string elementRegex = "([A-Z][a-z]*)([0-9]*)";
        string validateRegex = "^(" + elementRegex + ")+$";

        if (!Regex.IsMatch(chemicalFormula, validateRegex))
            throw new FormatException("Input string was in an incorrect format.");

        foreach (Match match in Regex.Matches(chemicalFormula, elementRegex))
        {
            string name = match.Groups[1].Value;

            int count =
                match.Groups[2].Value != "" ?
                int.Parse(match.Groups[2].Value) :
                1;

            formula.Add(new ChemicalFormulaComponent(name,  // ChemicalElement.ElementFromSymbol(name),
                count));
        }

        return formula;
    }
}
