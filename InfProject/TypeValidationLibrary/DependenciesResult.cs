using System.Runtime.InteropServices;
using System.Runtime.Serialization;

namespace TypeValidationLibrary
{
    /// <summary>
    /// Dependencies in dataset result
    /// </summary>
    public class DependenciesResult
    {
        static readonly string[] DefaultDependencyColumns = { "MA", "Spectrum", "X (mm)", "Y (mm)", "x", "y", "Index", "T", "Temperature" };

        /// <summary>
        /// Dependency column names
        /// </summary>
        public string[] DependencyNames { get; set; } = new string[0];

        /// <summary>
        /// Is there any dependency columns ("Temperature", "Pressure", etc. columns)
        /// </summary>
        public bool HasDependencies => DependencyNames.Length > 0;

        public DependenciesResult() { }
        public DependenciesResult(string[]? dependencyNames = null) : base()
        {
            if (dependencyNames != null) {
                DependencyNames = dependencyNames;
            }
        }

        public override string ToString() 
            => HasDependencies ? 
                $"dependencies: {string.Join(",", DependencyNames)}" : string.Empty;

        public static implicit operator bool(DependenciesResult obj) 
            => obj.HasDependencies;

        /// <summary>
        /// Helper method to get DependenciesResult from a table columns
        /// </summary>
        /// <param name="tableColumns">array of column names</param>
        /// <param name="dependencyColumns">array with names, regarded as dependencies (if null, then fallback to DefaultDependencyColumns = { "MA", "Spectrum", "X (mm)", "Y (mm)", "x", "y", "Index", "T", "Temperature" })</param>
        /// <returns>CoordinatesResult</returns>
        public static DependenciesResult GetDependenciesResult(string[] tableColumns, string[] dependencyColumns = null)
        {
            if (dependencyColumns == null)
                dependencyColumns = DefaultDependencyColumns;
            List<string> list = new List<string>();
            foreach (string column in tableColumns)
            {
                if (dependencyColumns.Contains(column))
                    list.Add(column);
            }
            return new DependenciesResult(list.ToArray());
        }
    }
}