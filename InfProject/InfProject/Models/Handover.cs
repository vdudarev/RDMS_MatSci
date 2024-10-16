using FluentValidation;
using InfProject.DBContext;
using InfProject.Utils;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using System.ComponentModel.DataAnnotations;

namespace InfProject.Models;

/// <summary>
/// Handover object (to transfer samples between people and track them)
/// </summary>
public class Handover : ObjectInfo
{
    public enum HandoverType { 
        All=0, 
        Incoming=1,
        Outcoming=2
    };


    [Order]
    [HiddenInput]
    [Display(Name = "Handover ID", GroupName="HIDDEN")]
    public int HandoverId
    {
        get => ObjectId;
        set => ObjectId = value;
    }


    [Order]
    [Required]
    [Display(Name = "Sample Object ID")]
    public int SampleObjectId { get; set; }


    [Order]
    [Required]
    [Display(Name = "Destination User ID")]
    public int DestinationUserId { get; set; }


    [Order]
    [Display(Name = "Handover confirmation date")]
    public DateTime? DestinationConfirmed { get; set; }

    [Order]
    [StringLength(128)]
    [Display(Name = "Comments on confirmation")]
    public string? DestinationComments { get; set; } = null!;

    [Order]
    [StringLength(16384)]
    [Display(Name = "Json document")]
    public string Json { get; set; } = null!;

    [Order]
    [Display(Name = "Amount")]
    public double? Amount { get; set; }

    [Order]
    [StringLength(32)]
    [Display(Name = "Measurement Unit")]
    public string MeasurementUnit { get; set; } = null!;
}

public class HandoverValidator : AbstractValidator<Handover>
{
    public HandoverValidator()
    {
        RuleFor(obj => obj.DestinationUserId).GreaterThan(0).WithMessage("Destination user must be specified");
    }
}