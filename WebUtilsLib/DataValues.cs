using Microsoft.AspNetCore.Mvc.Formatters;
using System;

namespace WebUtilsLib;

public static partial class DBUtils
{

    public class DatabaseValues: DatabaseValuesBase
    {
        // due to inheritance from DatabaseValuesBase we have properties here

        // for EDX data
        #region Composition
        public bool DeletePreviousCompositions { get; set; } = false;
        public List<CompositionValue> Compositions { get; init; } = new List<CompositionValue>();
        #endregion // Composition

        #region CompositionsForSampleUpdate
        public List<CompositionsForSampleUpdate> CompositionsForSampleUpdate { get; init; } = new List<CompositionsForSampleUpdate>();
        #endregion
    }
}
