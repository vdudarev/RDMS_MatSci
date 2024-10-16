using InfProject.DBContext;

namespace InfProject.Models;

public static class SampleExtension {
    /// <summary>
    /// Extends Sample information to SampleFull
    /// </summary>
    /// <param name="sample">Sample object instance</param>
    /// <param name="dataContext">DataContext (access to database to retrieve the data)</param>
    /// <returns>SampleFull - extended Sample information including Substrate, Type and WaferID</returns>
    public static SampleFull ToSampleFull(this Sample sample, DataContext dataContext) {
        int substrateObjectId = dataContext.GetSubstrateIdForSample(sample.ObjectId).Result;
        SampleFull.SampleType type = ((SampleFull.SampleType?)dataContext.Property_GetPropertyIntByName(sample.ObjectId, "Type", null).Result?.Value) ?? SampleFull.SampleType.Unknown;
        long? waferId = dataContext.Property_GetPropertyIntByName(sample.ObjectId, "Wafer ID", null).Result?.Value;
        SampleFull ret = new SampleFull(sample, substrateObjectId, type, waferId);
        return ret;
    }
}