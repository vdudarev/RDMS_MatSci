using FluentValidation;
using InfProject.DBContext;
using InfProject.Utils;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using System.ComponentModel.DataAnnotations;

namespace InfProject.Models;

/// <summary>
/// Handover object with Sample Information joined (to transfer samples between people and track them)
/// </summary>
public class HandoverSample : Handover
{
    /// <summary>
    /// Sample.ElemNumber
    /// </summary>
    public int SampleElemNumber { get; set; }

    /// <summary>
    /// Sample.Elements
    /// </summary>
    public string SampleElements { get; set; }

    /// <summary>
    /// Sample.ObjectInfo.ObjectName
    /// </summary>
    public string SampleObjectName { get; set; }

    /// <summary>
    /// Sample.ObjectInfo.ObjectNameUrl
    /// </summary>
    public string SampleObjectNameUrl { get; set; }
}
