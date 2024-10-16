namespace InfProject.DBContext;

public partial class DataContext
{
    /// <summary>
    /// TypeId for LinkType (must be -2 in database)
    /// </summary>
    public const int LinkTypeTypeId = -2;
    /// <summary>
    /// TypeId for Handover (must be -1 in database)
    /// </summary>
    public const int HandoverTypeId = -1;
    /// <summary>
    /// TypeId for Substrate (must be 5 in database)
    /// </summary>
    public const int SubstrateTypeId = 5;
    /// <summary>
    /// TypeId for Sample (must be 6 in database)
    /// </summary>
    public const int SampleTypeId = 6;
    /// <summary>
    /// TypeId for Composition (must be 8 in database)
    /// </summary>
    public const int CompositionTypeId = 8;
    /// <summary>
    /// TypeId for Synthesis (must be 18 in database)
    /// </summary>
    public const int SynthesisTypeId = 18;
    /// <summary>
    /// TypeId for Request For Synthesis (must be 83 in database)
    /// </summary>
    public const int RequestForSynthesisTypeId = 83;
    /// <summary>
    /// TypeId for "Ideas or experiment plans" (must be 89 in database)
    /// </summary>
    public const int IdeasAndPlansTypeId = 89;
}