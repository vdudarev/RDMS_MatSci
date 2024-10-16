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


public class SampleFull : Sample
{
    /// <summary>
    /// Please, make it consistent with View/Custom/EditSample
    /// </summary>
    public enum SampleType { Unknown=0, MaterialsLibrary=1, Stripe=2, NoGradient=3, StressChip=4, Piece=5 }

    /// <summary>
    /// ObjectId of a substrate for the sample (linked)
    /// </summary>
    [Order]
    [Required]
    [Display(Name = "Substrate Object")]
    public int SubstrateObjectId { get; set; }

    /// <summary>
    /// Type of the sample (according to SampleType enum)
    /// </summary>
    [Order]
    [Required]
    [Display(Name = "Sample Type")]
    public SampleType Type { get; set; } = SampleType.MaterialsLibrary;

    /// <summary>
    /// Wafer Identifier (unique identifier, placed on the wafer by a manufacturer)
    /// </summary>
    [Order]
    [Required]
    [Display(Name = "Wafer ID")]
    public long? WaferId { get; set; }

    public SampleFull() { } // For object crteation by reflection!

    public SampleFull(Sample sample, int substrateObjectId, SampleType type, long? waferId) {
        // ObjectInfo
        ObjectId = sample.ObjectId;
        TenantId = sample.TenantId;
        _created = sample._created;
        _createdBy = sample._createdBy;
        _updated = sample._updated;
        _updatedBy = sample._updatedBy;
        TypeId = sample.TypeId;
        RubricId = sample.RubricId;
        SortCode = sample.SortCode;
        AccessControl = sample.AccessControl;
        IsPublished = sample.IsPublished;
        ExternalId = sample.ExternalId;
        ObjectName = sample.ObjectName;
        ObjectNameUrl = sample.ObjectNameUrl;
        ObjectFilePath = sample.ObjectFilePath;
        ObjectFileHash = sample.ObjectFileHash;
        ObjectDescription = sample.ObjectDescription;
        
        // Sample
        ElemNumber = sample.ElemNumber;
        Elements = sample.Elements;

        // SubstrateObjectId
        SubstrateObjectId = substrateObjectId;
        Type = type;
        WaferId = waferId;
    }
}
public class SampleFullValidator : AbstractValidator<SampleFull>
{
    public SampleFullValidator()
    {
        RuleFor(obj => obj.SubstrateObjectId).GreaterThan(0).WithMessage("Logic: SubstrateObjectId must be specified");
        RuleFor(obj => obj.WaferId).NotNull().WithMessage("Logic: Wafer ID must be specified (in no label engraved, please specify \"0\" explicitly)");
    }
}