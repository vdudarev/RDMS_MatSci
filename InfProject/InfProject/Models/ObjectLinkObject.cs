using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;
using FluentValidation;
using InfProject.Utils;

namespace InfProject.Models;

public class ObjectLinkObject
{
    public int ObjectLinkObjectId { get; set; }
    public int ObjectId { get; set; }
    public int LinkedObjectId { get; set; }
    public int SortCode { get; set; }

    public override string ToString() => $"Link for object {ObjectId}: linked object {LinkedObjectId} [ObjectLinkObjectId={ObjectLinkObjectId}, SortCode={SortCode}]";
}
