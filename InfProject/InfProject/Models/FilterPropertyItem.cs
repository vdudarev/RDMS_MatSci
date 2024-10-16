using FluentValidation;
using InfProject.DBContext;
using InfProject.Utils;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using System.ComponentModel.DataAnnotations;
using System.Data;

namespace InfProject.Models;

/// <summary>
/// == dbo.FilterPropertyItem
/// </summary>
public class FilterPropertyItem
{
    public string PropertyName { get; set; } = null!;
    public string PropertyType { get; set; } = null!;
    public double? ValueMin { get; set; }
    public double? ValueMax { get; set; }
    public string? ValueString { get; set; }
}
