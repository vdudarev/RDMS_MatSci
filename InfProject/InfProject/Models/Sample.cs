using FluentValidation;
using InfProject.DBContext;
using InfProject.Utils;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using System.ComponentModel.DataAnnotations;

namespace InfProject.Models;

public class Sample : ObjectInfo
{
    [Order]
    [HiddenInput]
    [Display(Name = "Sample ID", GroupName="HIDDEN")]
    public int SampleId {
        get => ObjectId;
        set => ObjectId = value;
    }

    [Order]
    [HiddenInput]
    [Display(Name = "Elements Count", GroupName = "HIDDEN")]
    public int ElemNumber { get; set; }

    [Order]
    [Required]
    [StringLength(256)]
    [Display(Name = "Chemical System")]
    public string Elements { get; set; } = null!;
}

public class SampleValidator : AbstractValidator<Sample>
{
    public SampleValidator()
    {
        // RuleFor(obj => obj.Elements).NotEmpty().WithMessage("Chemical system name must be specified");
        RuleFor(obj => obj.Elements).Custom((x, context) =>
        {
            var validator = new ChemicalElementsValidator();
            string err = validator.Validate(x);
            if (!string.IsNullOrEmpty(err))
            {
                context.AddFailure(err);
            }
        });
    }

}