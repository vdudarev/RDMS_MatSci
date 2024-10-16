using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;
using FluentValidation;
using InfProject.Utils;

namespace InfProject.Models;

public class ObjectLinkRubric
{
    public int ObjectLinkRubricId { get; set; }
    public int RubricId { get; set; }
    public int ObjectId { get; set; }
    public int SortCode { get; set; }

    public DateTime? _created { get; set; }
    public int? _createdBy { get; set; }
    public DateTime? _updated { get; set; }
    public int? _updatedBy { get; set; }
    public override string ToString() => $"Object Link for rubric {RubricId}: linked object {ObjectId} [ObjectLinkRubricId={ObjectLinkRubricId}, SortCode={SortCode}]";
}
