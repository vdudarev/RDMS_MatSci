using InfProject.DBContext;
using WebUtilsLib;

namespace InfProject.Models;

public class Filter
{
    public AccessControlFilter AccessFilter { get; set; }
    public FilterCompositionItem[] CompositionItems { get; set; } = null!;
    public FilterPropertyItem[] PropertyItems { get; set; } = null!;
    public int TypeId { get; set; }
    public string SearchPhrase { get; set; } = null!;
    public int CreatedByUser { get; set; }
    public DateTime? CreatedMin { get; set; }
    public DateTime? CreatedMax { get; set; }
    public int ObjectId { get; set; }
    public int ExternalId { get; set; }
    public string Json { get; set; } = null!;

    public Filter() {
        AccessFilter = new AccessControlFilter();
        CompositionItems = Array.Empty<FilterCompositionItem>();
        PropertyItems = Array.Empty<FilterPropertyItem>();
        TypeId = CreatedByUser = ObjectId = ExternalId = 0;
        SearchPhrase = Json = string.Empty;
        CreatedMin = CreatedMax = null;
    }

    public string System => string.Join("-", CompositionItems.OrderBy(x => x.ElementName));

    /// <summary>
    /// true - search contains chemical system; othewise false
    /// TODO: enhance TypeId analysis (make it true if type is derived from chemical system)
    /// </summary>
    public bool ContainsChemicalSystem => !string.IsNullOrEmpty(System) 
        || TypeId==DataContext.SampleTypeId || TypeId == DataContext.CompositionTypeId;

    public bool IsEmpty => AccessFilter.IsNone
        && CompositionItems.Length == 0 && PropertyItems.Length == 0
        && TypeId == 0 && string.IsNullOrEmpty(SearchPhrase) && CreatedByUser==0
        && CreatedMin == null && CreatedMax == null && ObjectId == 0 && ExternalId == 0 && string.IsNullOrEmpty(Json);
}
