using FluentValidation;
using InfProject.Utils;
using System.ComponentModel.DataAnnotations;
using Microsoft.IdentityModel.Tokens;
using System.Net;
using System;

namespace InfProject.Models;

public class TypeInfo : ICloneable
{
    [Order]
    public int TypeId { get; set; }

    [Order]
    [Display(Name = "Is Hierarchical")]
    public bool IsHierarchical { get; set; }

    [Order]
    [Display(Name = "Hierarchical classifier")]
    public int? TypeIdForRubric { get; set; }

    [Order]
    [Display(Name = "Type Name")]
    public string TypeName { get; set; } = null!;

    [Order]
    [Display(Name = "Table Name (Data Structure)")]
    public string TableName { get; set; } = null!;

    [Order]
    [Display(Name = "URL Prefix")]
    public string UrlPrefix { get; set; } = null!;

    [Order]
    [Display(Name = "Description")]
    public string? TypeComment { get; set; }

    /// <summary>
    /// <Type>:<TypeName> - create type (should support IFileValidator interface) and validate object by calling ValidateFile(...) or ValidateStream(...) method
    /// http(s)://urlForValidation - POST request to get TypeValidatorResult in JSON
    /// </summary>
    [Order]
    [Display(Name = "Validation Schema")]
    public string? ValidationSchema { get; set; }

    /// <summary>
    /// <Type>:<TypeName> - create type (should support IDatabaseValuesGetter interface) and return data object by calling GetDatabaseValues() method
    /// http(s)://urlForData - POST request to get DatabaseValues in JSON
    /// </summary>
    [Order]
    [Display(Name = "Data Schema")]
    public string? DataSchema { get; set; }

    /// <summary>
    /// File Required:
    /// False - File (successfully validated) is not required (optional) for object
    /// True - File (successfully validated) is required (mandatory) for object
    /// </summary>
    [Order]
    [Display(Name = "File Required")]
    public bool FileRequired { get; set; }


    /// <summary>
    /// Setting or type in JSON format
    /// </summary>
    [Order]
    [Display(Name = "Settings (JSON)")]
    public string SettingsJson { get; set; }

    /// <summary>
    /// OPTIONAL: for extended queries (e.g. GetTypesHierarchicalWithCount) returns how many corresponding objects are in the current tenant
    /// </summary>
    public int Count { get; set; }
    public override string ToString() => $"{TypeName} [TypeId={TypeId}]";

    public object Clone()
    {
        var t = (TypeInfo)MemberwiseClone();
        return t;
    }

    /// <summary>
    /// Get name of PartialView for particular type
    /// </summary>
    /// <param name="tableName">type's table name</param>
    /// <returns>Partial view name</returns>
    public static string GetObjectPartialView(string tableName) {
        string objectPartialView = $"_Object{tableName}";
        if (tableName == "Composition")
        {
            objectPartialView = $"_ObjectSample";
        }
        return objectPartialView ;
    }
}
public class TypeInfoValidator : AbstractValidator<TypeInfo>
{
    public TypeInfoValidator()
    {
        RuleFor(obj => obj.TypeName).MinimumLength(1).WithMessage("Infrastructure: Type Name must be specified");
        RuleFor(obj => obj.TypeComment).MinimumLength(1).WithMessage("Infrastructure: Type Description must be specified");
    }
}
