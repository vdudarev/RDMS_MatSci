using FluentValidation;
using InfProject.Utils;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using Microsoft.CodeAnalysis.Options;
using Microsoft.CodeAnalysis.Scripting;
using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;
using System.IO;

namespace InfProject.Models;


public class WCSampleShort
{
    public int ExternalId { get; set; }
    public int ProjectId { get; set; }
    public int ParentProjectId { get; set; }
    /// <summary>
    /// 0 - public; 1 - protectedNDA
    /// </summary>
    public int WCAccessControl { get; set; }
    /// <summary>
    /// INF AccessControl
    /// </summary>
    public int AccessControl { get; set; }
    public DateTime Created { get; set; }
    public string ProjectName { get; set; } = null!;
    public string SampleMaterial { get; set; } = null!;
    public int SubstrateId { get; set; }
    public string SubstrateMaterial { get; set; } = null!;

    public int ElemNumber { get; set; }

    public string _Elements = null!;
    public string Elements
    {
        get => _Elements.Trim('-');
        set => _Elements = value;
    }
    public int DepositionCount { get; set; }
    public int CharacterizationCount { get; set; }

    public string? Chamber { get; set; }
    public string CreatedByPerson { get; set; } = null!;

    public int _CreatedBy { get; set; }

}