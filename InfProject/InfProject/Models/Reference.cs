using FluentValidation;
using InfProject.DBContext;
using InfProject.Utils;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using System.ComponentModel.DataAnnotations;

namespace InfProject.Models;

public class Reference : ObjectInfo
{
    [Order]
    [HiddenInput]
    [Display(Name = "Reference ID", GroupName="HIDDEN")]
    public int ReferenceId {
        get => ObjectId;
        set => ObjectId = value;
    }

    [Order]
    [StringLength(512)]
    [Display(Name = "Authors list (comma-separated)")]
    public string Authors { get; set; } = null!;

    [Order]
    [Required]
    [StringLength(1024)]
    [Display(Name = "Title")]
    public string Title { get; set; } = null!;

    [Order]
    [StringLength(256)]
    [Display(Name = "Journal")]
    public string Journal { get; set; } = null!;

    [Order]
    [Display(Name = "Year")]
    public int Year { get; set; }

    [Order]
    [StringLength(32)]
    [Display(Name = "Volume")]
    public string Volume { get; set; } = null!;

    [Order]
    [StringLength(32)]
    [Display(Name = "Number (issue)")]
    public string Number { get; set; } = null!;

    [Order]
    [StringLength(32)]
    [Display(Name = "Start Page")]
    public string StartPage { get; set; } = null!;

    [Order]
    [StringLength(32)]
    [Display(Name = "End Page")]
    public string EndPage { get; set; } = null!;

    [Order]
    [StringLength(256)]
    [Display(Name = "DOI")]
    public string DOI { get; set; } = null!;

    [Order]
    [StringLength(256)]
    [Display(Name = "URL")]
    public string URL { get; set; } = null!;

    [Order]
    [StringLength(4096)]
    [Display(Name = "BibTeX ")]
    public string BibTeX { get; set; } = null!;
}

public class ReferenceValidator : AbstractValidator<Reference>
{
    public ReferenceValidator()
    {
        RuleFor(obj => obj.Title).NotEmpty().WithMessage("Title must be specified");
        RuleFor(obj => obj.Year).GreaterThanOrEqualTo(1900).WithMessage("Year must be greather than 1900");
    }

}