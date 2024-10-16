using Microsoft.AspNetCore.Mvc.Formatters;
using System;
using static WebUtilsLib.DBUtils.DatabaseValues;

namespace WebUtilsLib;

public static partial class DBUtils
{
    public class CompositionsForSampleUpdate
    {
        public Predicate Predicate { get; set; }
        public bool DeletePreviousProperties { get; set; } = false;
        public List<PropertyValue> Properties { get; init; } = new List<PropertyValue>();
    }
}
