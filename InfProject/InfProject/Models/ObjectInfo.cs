using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;
using System.Security.AccessControl;
using FluentValidation;
using InfProject.Utils;
using WebUtilsLib;

namespace InfProject.Models;

/// <summary>
/// for validation:
/// https://learn.microsoft.com/en-us/aspnet/core/mvc/models/validation
/// </summary>
public class ObjectInfo
{
    [Order]
    [Display(Name = "Object ID")]
    public int ObjectId { get; set; }

    [Order]
    [Display(Name = "Tenant ID")]
    public int TenantId { get; set; }

    [Order]
    [Display(Name = "Created")]
    public DateTime? _created { get; set; }

    [Order]
    [Display(Name = "Created By")]
    public int? _createdBy { get; set; }

    [Order]
    [Display(Name = "Updated")]
    public DateTime? _updated { get; set; }

    [Order]
    [Display(Name = "Updated By")]
    public int? _updatedBy { get; set; }

    [Order]
    [Display(Name = "Type ID")]
    public int TypeId { get; set; }

    [Order]
    [Display(Name = "Rubric ID")]
    public int? RubricId { get; set; }

    [Order]
    [Display(Name = "Sort Code (asc)")]
    public int SortCode { get; set; }

    [Order]
    [Display(Name = "Access Control (accessibility)")]
    public AccessControl AccessControl { get; set; } = AccessControl.Public;

    [Order]
    [Display(Name = "Publish?")]
    public bool IsPublished { get; set; } = true;

    [Order]
    [Display(Name = "External Id (auxiliary)")]
    public int? ExternalId { get; set; }

    [Order]
    [Required]
    [Display(Name = "Name")]
    [StringLength(512, MinimumLength = 1, ErrorMessage = "Name length can't be more than 512 characters")]
    [AllowNull]
    public string ObjectName { get; set; } = string.Empty;

    [Order]
    [StringLength(256)]
    [Display(Name = "URL (unique)")]
    public string ObjectNameUrl { get; set; } = string.Empty;

    [Order]
    [StringLength(256, MinimumLength = -1, ErrorMessage = "File Path length can't be more than 256 characters")]
    [AllowNull]
    [Display(Name = "File Path")]
    public string ObjectFilePath { get; set; } = string.Empty;
    public string ObjectFile => Path.GetFileName(ObjectFilePath);

    [Order]
    [StringLength(128, MinimumLength = -1, ErrorMessage = "File Path length can't be more than 128 characters")]
    [AllowNull]
    [Display(Name = "File Hash")]
    public string? ObjectFileHash { get; set; }

    [Order]
    [StringLength(1024, MinimumLength = -1, ErrorMessage = "Description length can't be more than 1024 characters")]
    [AllowNull]
    [Display(Name = "Description")]
    public string ObjectDescription { get; set; } = string.Empty;

    public override string ToString() => $"{ObjectName} [ObjectId={ObjectId}, RubricId={RubricId}, TypeId={TypeId}]";

}


public static class Extension_ObjectInfo {
    /// <summary>
    /// Is this object a template for type
    /// </summary>
    public static bool IsTemplate(this ObjectInfo obj) => obj.ObjectName == "_Template";

    /// <summary>
    /// GetTemplateIconFor Object
    /// </summary>
    /// <param name="obj">ObjectInfo instance</param>
    /// <param name="Row">row in property</param>
    /// <returns></returns>
    public static string GetTemplateIcon(this ObjectInfo obj, int? Row)
    {
        if (!IsTemplate(obj))
            return string.Empty;
        if (Row == -1)
            return "<i class=\"bi bi-table\"></i> ";
        if (Row == null)
            return "<i class=\"bi bi-list-ol\"></i> ";
        return string.Empty;
    }
}


public class ObjectInfoValidator : AbstractValidator<ObjectInfo>
{
    public ObjectInfoValidator()
    {
        RuleFor(obj => obj.TenantId).GreaterThan(0).WithMessage("Infrastructure: TenantId must be specified");
        //RuleFor(obj => obj.TypeId).GreaterThan(0).WithMessage("Infrastructure: TypeId must be specified");
        RuleFor(obj => obj.TypeId).NotEqual(0).WithMessage("Infrastructure: TypeId must be specified");
        RuleFor(obj => obj.ObjectName).NotEmpty().WithMessage("Object name must be specified");
    }
}