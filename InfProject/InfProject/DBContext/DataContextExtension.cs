using Microsoft.AspNetCore.Mvc;
using System.Data.SqlClient;
using System.Data;
using Dapper;
using InfProject.Models;
using InfProject.Utils;
using WebUtilsLib;
using System.Security.Claims;
using InfProject.DTO;
using System;
using static System.Runtime.InteropServices.JavaScript.JSType;
using Newtonsoft.Json.Linq;
using System.ComponentModel.DataAnnotations;
using System.Reflection;
using System.Text;
using static InfProject.Models.Composition;
using Microsoft.AspNetCore.Http.HttpResults;
using System.Diagnostics.Metrics;
using Microsoft.CodeAnalysis;
using OfficeOpenXml.Packaging.Ionic.Zlib;
using OfficeOpenXml.Style;
using System.Collections.Generic;
using System.Security.AccessControl;
using TypeValidationLibrary;

namespace InfProject.DBContext;

public static class DataContextExtension
{


    // TODO: implement context stuffing
    /// <summary>
    /// Extract Context for the current object (currentContextObject) from database having dataContext
    /// </summary>
    /// <param name="dataContext">DataContext - active database link</param>
    /// <param name="currentContextObject">current object (that should know "parent" sample)</param>
    /// <returns></returns>
    public static async Task<Context> ExtractContext(this DataContext dataContext, ObjectInfo currentContextObject)
    {
        Context ctx = new Context();
        //Dictionary<string, string> dict = new Dictionary<string, string>();
        ctx.ChemicalSystem = new string[] { "As", "Ga" };

        return ctx;
    }

}
