using Azure.Core.GeoJson;
using FluentValidation;
using FluentValidation.AspNetCore;
using FluentValidation.Results;
using InfProject.DBContext;
using InfProject.Models;
using InfProject.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.CodeAnalysis;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
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

[Route("rubric")]
public class RubricController : Controller
{
    private readonly IValidator<ObjectInfo> validator;
    private readonly ILogger<RubricController> logger;
    private readonly IConfiguration config;
    private readonly DataContext dataContext;
    private readonly IWebHostEnvironment webHostEnvironment;

    public RubricController(IValidator<ObjectInfo> validator, ILogger<RubricController> logger, IConfiguration config, DataContext dataContext, IWebHostEnvironment webHostEnvironment)
    {
        this.validator = validator;
        this.logger = logger;
        this.config = config;
        this.dataContext = dataContext;
        this.webHostEnvironment = webHostEnvironment;
    }

    /// <summary>
    /// redirect to rubric by it's RubricId
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    [HttpGet("id/{id}")]
    public async Task<IActionResult> Id([FromRoute] int id)
    {
        RubricInfo rubric = await dataContext.GetRubricById(id);
        if (rubric == null || string.IsNullOrEmpty(rubric.RubricNameUrl))
        {
            TempData["Err"] = $"Can not find rubric by id: {id}";
            return Redirect("/");
        }
        return Redirect($"/rubric/{rubric?.RubricNameUrl}");
    }


    [HttpGet("{url}")]
    public async Task<IActionResult> Index([FromRoute] string url) {

        RubricInfo rubric = await dataContext.GetRubricByUrl(url);
        if (rubric==null || rubric.RubricId == 0) 
        {
            return NotFound($"Can not find rubric by url: {url}");
        }
        if (HttpContext.IsReadDenied(rubric.AccessControl, (int)rubric._createdBy)) 
        {
            return this.RedirectToLoginOrAccessDenied(HttpContext);
        }
        return View("Rubric", rubric);
    }

}