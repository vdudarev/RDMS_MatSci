using Microsoft.AspNetCore.Mvc.Formatters;
using System;
using static WebUtilsLib.DBUtils.DatabaseValues;

namespace WebUtilsLib;

public static partial class DBUtils
{
    public class Predicate
    {
        public List<PropertyValue> Properties { get; init; } = new List<PropertyValue>();

        public override string ToString() => string.Join(", ", Properties);
    }
}
