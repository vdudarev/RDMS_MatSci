using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;
using FluentValidation;
using InfProject.Utils;

namespace InfProject.Models;

/// <summary>
/// for validation:
/// https://learn.microsoft.com/en-us/aspnet/core/mvc/models/validation
/// </summary>
public class ObjectInfoLinked : ObjectInfo
{
    public int ObjectLinkObjectId { get; set; }
    public int MainObjectId { get; set; }
    public int SortCodeLink { get; set; }


    public DateTime? Link_created { get; set; }

    public int? Link_createdBy { get; set; }

    public DateTime? Link_updated { get; set; }

    public int? Link_updatedBy { get; set; }

    // Link type characterization - April 2024 - begin
    public int? LinkTypeObjectId { get; set; }
    public string? LinkTypeObjectName { get; set; }
    public string? LinkTypeObjectNameUrl { get; set; }
    // Link type characterization - April 2024 - end

    public override string ToString() => $"Link for {base.ToString()} [ObjectLinkObjectId={ObjectLinkObjectId}, MainObjectId={MainObjectId}, LinkTypeObjectId={LinkTypeObjectId}, LinkType={LinkTypeObjectName}]";
}
