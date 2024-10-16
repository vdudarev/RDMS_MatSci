using System.Data;
using WebUtilsLib;

namespace TypeValidationLibrary
{
    /// <summary>
    /// Tabular data with coordinates names
    /// </summary>
    public class Table {
        public Table(DataTable? dataTable, CoordinatesResult? coordinates, DependenciesResult? dependencies) {
            DataTable = dataTable;
            Coordinates = coordinates;
            Dependencies = dependencies;
        }

        /// <summary>
        /// Get DataTable from the data
        /// </summary>
        public DataTable? DataTable { get; init; }

        /// <summary>
        /// Is there any coordinates ("X (mm)", "Y (mm)", "x", "y" columns)
        /// </summary>
        /// <returns>CoordinatesResult (Coordinates columns)</returns>
        public CoordinatesResult? Coordinates { get; init; }

        /// <summary>
        /// Is there any dependency columns ("Temperature", "Pressure", etc. columns)
        /// </summary>
        /// <returns>DependenciesResult (Dependencies columns)</returns>
        public DependenciesResult? Dependencies { get; init; }

        /// <summary>
        /// Get CSV from DataTable
        /// </summary>
        /// <returns>CSV string</returns>
        public string GetCSV(string delimiter = "\t")
            => DataTable2CSV.GetCSVfromDataTable(delimiter, DataTable!, includeHeaders: true, changeEndL2Space: true);
    }
}