using System.Runtime.InteropServices;
using System.Runtime.Serialization;
using System.Xml.Linq;

namespace TypeValidationLibrary
{
    /// <summary>
    /// coordinates in dataset result
    /// </summary>
    public class CoordinatesResult
    {
        public static readonly string[] DefaultCoordsColumns = { "X (mm)", "Y (mm)", "x", "y" };

        /// <summary>
        /// Coordinate names
        /// </summary>
        public string[] CoordinateNames { get; set; } = new string[0];

        /// <summary>
        /// Is there any coordinates ("X (mm)", "Y (mm)", "x", "y" columns)
        /// </summary>
        public bool HasCoordinates => CoordinateNames.Length > 0;

        public CoordinatesResult() { }
        public CoordinatesResult(string[]? coordinateNames = null) : base()
        {
            if (coordinateNames != null) {
                CoordinateNames = coordinateNames;
            }
        }

        public override string ToString() 
            => HasCoordinates ? 
                $"coordinates: {string.Join(",", CoordinateNames)}" : string.Empty;

        public static implicit operator bool(CoordinatesResult obj) 
            => obj.HasCoordinates;


        /// <summary>
        /// Helper method to get CoordinatesResult from a table columns
        /// </summary>
        /// <param name="tableColumns">array of column names</param>
        /// <param name="coordsColumns">array with names, regarded as coordinates (if null, then fallback to DefaultCoordsColumns = { "X (mm)", "Y (mm)", "x", "y" })</param>
        /// <returns>CoordinatesResult</returns>
        public static CoordinatesResult GetCoordinatesResult(string[] tableColumns, string[] coordsColumns = null)
        {
            if (coordsColumns == null)
                coordsColumns = DefaultCoordsColumns;
            List<string> list = new List<string>();
            foreach (string column in tableColumns)
            {
                if (coordsColumns.Contains(column))
                    list.Add(column);
            }
            return new CoordinatesResult(list.ToArray());
        }
    }
}