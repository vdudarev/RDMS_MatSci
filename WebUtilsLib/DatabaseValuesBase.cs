namespace WebUtilsLib
{
    public static partial class DBUtils
    {
        public class DatabaseValuesBase
        {
            #region Properties
            public bool DeletePreviousProperties { get; set; } = true;
            public List<PropertyValue> Properties { get; init; } = new List<PropertyValue>();
            #endregion // Properties
        }
    }
}
