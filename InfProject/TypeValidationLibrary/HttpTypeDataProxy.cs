using System.Data;
using System.Dynamic;
using System.Text;
using System.Xml.Linq;
using WebUtilsLib;
using static WebUtilsLib.DBUtils;

namespace TypeValidationLibrary
{
    /// <summary>
    /// HttpDataProxy to wrap external http services and introduce them in the app as native ones
    /// </summary>
    public class HttpTypeDataProxy : ITableGetter, IDatabaseValuesGetter
    {
        private string dataSchema;
        private string GetDataRequestUrl(string dataSchema) => dataSchema + "/databasevaluesbody";
        private string GetTableRequestUrl(string dataSchema) => dataSchema + "/tablebody";

        public HttpTypeDataProxy(string dataSchema)
        {
            if (!dataSchema.StartsWith("http://") && !dataSchema.StartsWith("https://"))
                throw new ArgumentException($"dataSchema should start with http(s):// [{dataSchema} found]");
            this.dataSchema = dataSchema;
        }

        public Encoding Encoding { get; set; } = Encoding.UTF8;
        public FileInfo? File { get; set; }
        public Stream? Stream { get; set; }

        public DatabaseValues GetDatabaseValues()
        {
            DatabaseValues values = null!;
            string requestUrl = GetDataRequestUrl(dataSchema);     // https://validation.matinf.pro/edx/data/databasevaluesbody
            if (File != null)
            {
                values = HttpUtils.GetDataThroughWebService<DatabaseValues>(requestUrl, File.FullName).Result;
            }
            else if (Stream != null)
            {
                values = HttpUtils.GetDataThroughWebService<DatabaseValues>(requestUrl, Stream).Result;
            }
            else
            {
                throw new ArgumentNullException("File and Stream are not defined");
            }
            if (values?.Properties?.Count > 0) {    // after deserialization it's required to normalize values (object), otherwise ERROR: No mapping exists from object type System.Text.Json.JsonElement to a known managed provider native type.
                values.Properties.ForEach(x => x.NormalizeValue());
            }
            if (values?.Compositions?.Count > 0) {    // after deserialization it's required to normalize values (object), otherwise ERROR: No mapping exists from object type System.Text.Json.JsonElement to a known managed provider native type.
                values.Compositions.ForEach(c => c?.Properties?.ForEach(x => x.NormalizeValue()));
            }
            if (values?.CompositionsForSampleUpdate?.Count > 0) {
                values.CompositionsForSampleUpdate.ForEach(c => c?.Properties?.ForEach(x => x.NormalizeValue()));
                values.CompositionsForSampleUpdate.ForEach(c => c?.Predicate?.Properties?.ForEach(x => x.NormalizeValue()));
            }
            return values;
        }

        /// <summary>
        /// Get the table 
        /// </summary>
        /// <returns></returns>
        /// <exception cref="ArgumentNullException"></exception>
        public Table GetTable()
        {
            Table res = null!;
            dynamic table;
            string requestUrl = GetTableRequestUrl(dataSchema);
            if (File != null)
            {
                // res = HttpUtils.GetDataThroughWebService<Table>(requestUrl, File.FullName).Result;
                table = HttpUtils.GetDataThroughWebService<ExpandoObject>(requestUrl, File.FullName).Result;
            }
            else if (Stream != null)
            {
                // res = HttpUtils.GetDataThroughWebService<Table>(requestUrl, Stream).Result;
                table = HttpUtils.GetDataThroughWebService<ExpandoObject>(requestUrl, Stream).Result;
            }
            else
            {
                throw new ArgumentNullException("File and Stream are not defined");
            }
            res = GetTableFromDynamic(table);
            return res;
        }

        private Table GetTableFromDynamic(dynamic dyn) {
            DataTable table = new DataTable("CSV");
            //dynamic o1 = ((System.Text.Json.JsonElement)dyn).ValueKind;   // dyn["DataTable"];
            dynamic Lines = dyn.DataTable;

            int length = Lines.GetArrayLength();
            List<string> columnNames = new List<string>();
            if (length>0)
            {
                foreach (dynamic item in Lines[0].EnumerateObject())
                {
                    columnNames.Add(item.Name);
                    table.Columns.Add(item.Name);
                }
            }

            for (int idx=0; idx <length; idx++)
            {
                dynamic line = Lines[idx];
                dynamic col = line.EnumerateObject();
                DataRow dataRow = table.NewRow();
                foreach (dynamic item in col)
                {
                    //item.Name
                    //item.Value
                    //item.Value.ValueKind    // https://learn.microsoft.com/en-us/dotnet/api/system.text.json.jsonvaluekind?view=net-8.0
                    dataRow[item.Name] = item.Value;
                }
                table.Rows.Add(dataRow);
            }
            var columns = columnNames.ToArray();
            CoordinatesResult coordinates = CoordinatesResult.GetCoordinatesResult(columns);
            DependenciesResult dependencies = DependenciesResult.GetDependenciesResult(columns);
            Table res = new Table(table, coordinates, dependencies);
            return res;
        }

    }
}