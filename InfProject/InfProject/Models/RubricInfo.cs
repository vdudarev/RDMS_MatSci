using WebUtilsLib;

namespace InfProject.Models;

public class RubricInfo
{
    public int RubricId { get; set; }
    public int TenantId { get; set; }
    public DateTime? _created { get; set; }
    public int? _createdBy { get; set; }
    public DateTime? _updated { get; set; }
    public int? _updatedBy { get; set; }
    public int TypeId { get; set; }
    public int ParentId { get; set; }
    public int Level { get; set; }
    public int LeafFlag { get; set; }
    public int Flags { get; set; }
    public int SortCode { get; set; }
    public bool IsPublished { get; set; }
    public AccessControl AccessControl { get; set; }

    public string RubricName { get; set; } = string.Empty;
    public string RubricNameUrl { get; set; } = string.Empty;
    public string RubricPath { get; set; } = string.Empty;

    public override string ToString() => $"{RubricName} [RubricId={RubricId}]";
}
