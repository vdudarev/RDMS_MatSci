using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using WebUtilsLib;
using static TypeValidationLibrary.TypeValidator_EDX_CSV;
using static WebUtilsLib.DBUtils;

// TypeInfo.ValidationSchema = type:TypeValidationLibrary.TypeValidator_EDX_CSV
namespace TypeValidationLibrary
{
    /// <summary>
    /// base class
    /// </summary>
    public class TypeValidator_EDX_CSV : TypeValidatorBase, IFileValidator, ITableGetter, IDatabaseValuesGetter
    {
        // Sync with: wwwroot/js/site.js : ViewWafer / edxMA420_0based
        public readonly int[] EdxMA420_0based = new int[] { 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 272, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 292, 295, 296, 297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 317, 318, 319, 320, 321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 339, 340, 341, 342, 343, 344, 345, 346, 347, 348, 349, 350, 351, 352, 353, 361, 362, 363, 364, 365, 366, 367, 368, 369, 370, 371, 372, 373, 383, 384, 385, 386, 387, 388, 389, 390, 391, 392, 393, 406, 407, 408, 409, 410, 411, 412 };

        static readonly string[] allowedColumns = { "Spectrum", "In stats.", "X (mm)", "Y (mm)", "x", "y", "Index" };
        static readonly string[] dependencyColumns = { "Spectrum", "X (mm)", "Y (mm)", "x", "y", "Index" };
        static readonly string[] indexColumns = { "Index", "Spectrum" };
        static readonly string[] coordsColumns = { "X (mm)", "Y (mm)", "x", "y" };
        static readonly string[] xColumns = { "X (mm)", "x" };
        static readonly string[] yColumns = { "Y (mm)", "y" };

        static readonly string[] allowedExt = new string[] { ".csv", ".txt" };
        public enum Mode { 
            Unknown = 0,
            Raw = 1,
            CSV = 2,
            RawNonStandard = 3,
            RawNoFooter = 4
        }

        private Mode mode;
        private DataTable? dt;
        int verifiedVersion;

        public TypeValidator_EDX_CSV() : base()
        {
            // default configuration
            AllowedExtensions.AddRange(allowedExt);
        }



        /// <summary>
        /// HANGS:  === TOTAL: ok=583, fail=12; failExtension=668 === ContainsCoordinatesCount: 331. Completed in 273681,5985 ms
        /// without code        === TOTAL: ok=583, fail=12; failExtension=668 === ContainsCoordinatesCount: 796. Completed in 2082,1102 ms
        /// </summary>
        protected override void InitValidation()
        {
            mode = Mode.Unknown;
            dt = null;
            //Console.WriteLine(File.Name);
        }

        // No headers
        // 2018-04-27_3654_Ti-Nb-Mo-Ta-W_Si + SiO2_30288_180422-K2-1 TiNbMoTaW equi V7-5x EDX.txt
        // unknown column "counts"
        // 2018-04-28_3665_Ti-Nb-Mo-Ta-W_Si + SiO2_30378_180426-K2-1 TiNbMoTaW equi V13-5x EDX.txt
        // spaces instead of tab between [Spectrum    In stats.] + In stats : No / Yes
        // 2019-02-28_4181_Cr-Mn-Fe-Co-Ni_Si + SiO2_37624_190225-K2-2 CrMnFeCoNi TF from Cantor TF target EDX.txt
        // UNKNOWN format
        // 2019-02-28_4183_Cu-Zr-Nb-Hf-W, Cr-Mn-Fe-Co-Ni, Al-Si-Ti-V-Mo_Si_37604_190227-K7-1 3x 5-element TF target EDX.txt
        // last column: Hf(L)	
        // 2020-10-05_4976_Ti-Ni-Cu-Zr-Pd-Hf_Si + SiO2_48165_200928-K2-1 HER _TiNi_CuHfPdZr_000043709.txt
        // 2020-10-05_4977_Ti-Ni-Cu-Zr-Pd-Hf_Si + SiO2_48168_200930-K2-1 HER _TiNi_CuHfPdZr HER hit reference_000043712.txt

        // Strange format: Spectrum 1	Atomic %
        // 2022-11-23_8144_Pd-Fe-Cu-Ag_Sapphire_64606_0008144_Aztec EDS_000059645.txt

        /// <summary>
        /// Type-specific logic
        /// </summary>
        /// <returns></returns>
        protected override TypeValidatorResult ValidateSpecific() {
            mode = Mode.Unknown;
            dt = null;
            verifiedVersion = version;
            TypeValidatorResult result = new TypeValidatorResult();

            //if (string.Compare(File.Extension, ".txt", true)==0) { }  // sometimes it could be other extension
            string contents = string.Empty;
            if (File != null)
            {
                contents = System.IO.File.ReadAllText(File.FullName, Encoding);
            }
            else if (Stream != null) {
                using (var reader = new StreamReader(Stream, Encoding))
                {
                    contents = reader.ReadToEndAsync().Result;
                }
            }
            if (string.IsNullOrEmpty(contents)) {
                result.Code = 400;
                result.Message = "Empty content";
                return result;
            }

            //int idxProcessing = contents.IndexOf("Processing option : ", StringComparison.InvariantCultureIgnoreCase);
            int idxProcessing = contents.IndexOf("Processing option", StringComparison.InvariantCultureIgnoreCase); // 2016-11-02_1471_Ni-Co-Al_Si + SiO2_9523_141128-K1-2_annealed_standard.txt
            if (idxProcessing == -1) { // 2022-10-11_8118_Pd-Fe-Cu-Ag_Sapphire_63269_221005-K2-1 EDX center_000058330.txt
                idxProcessing = contents.IndexOf("All results in atomic%", StringComparison.InvariantCultureIgnoreCase); 
            } 
            int idxMean = contents.IndexOf("\nMean\t", StringComparison.InvariantCultureIgnoreCase);
            if (idxMean == -1) { // this could be f@cking Mac (Jill's case)
				idxMean = contents.IndexOf("\rMean\t", StringComparison.InvariantCultureIgnoreCase);
			}
            // int idxProcessingLast = contents.LastIndexOf("Processing option : ", StringComparison.InvariantCultureIgnoreCase);
            int idxProcessingLast = contents.LastIndexOf("Processing option", StringComparison.InvariantCultureIgnoreCase); // 2016-11-02_1471_Ni-Co-Al_Si + SiO2_9523_141128-K1-2_annealed_standard.txt
            if (idxProcessingLast == -1) {  // 2022-10-11_8118_Pd-Fe-Cu-Ag_Sapphire_63269_221005-K2-1 EDX center_000058330.txt
                idxProcessingLast = contents.LastIndexOf("All results in atomic%", StringComparison.InvariantCultureIgnoreCase); 
            } 
            int idxMeanLast = contents.LastIndexOf("\nMean\t", StringComparison.InvariantCultureIgnoreCase);
            if (idxMeanLast == -1) { // this could be f@cking Mac (Jill's case)
				idxMeanLast = contents.LastIndexOf("\rMean\t", StringComparison.InvariantCultureIgnoreCase);
			}

            if (idxProcessing >= 0 && idxMean > 0 && (idxProcessing != idxProcessingLast || idxMean != idxMeanLast))
            {      // raw file (multiple data portions: several "Processing option" or "Mean" detected))
                mode = Mode.RawNonStandard;
                // 2017-09-13_3267_Cr-Mn-Fe-Ni_Si + SiO2_23228_170913-K2-1 Cr-Mn-Fe-Ni Cr66 v3 EDX.txt - HERE IS Untypical situation - we havе filtered list at the top and the full version ar the bottom
                if (idxProcessing < idxMean)
                {
                    result.Warning = "raw file (multiple data portions: several \"Processing option\" or \"Mean\" detected - consider first fragment)";
                    idxProcessingLast = idxProcessing;
                    idxMeanLast = idxMean;
                }
                else {
                    if (contents.TrimStart(new char[] {'\r', '\n', '\t' }).StartsWith("Spectrum"))
                        idxProcessing = 0;
                    else
                        return new TypeValidatorResult(100, "raw file (multiple data portions: several \"Processing option\" or \"Mean\" detected : idxProcessing > idxMean)");
                }
            }

            string csv = contents;
            if (idxProcessing >= 0 && idxMean > 0 && idxProcessing == idxProcessingLast && idxMean == idxMeanLast)   {      // raw file (single data portion)
                mode = Mode.Raw;
                int idxStart = csv.IndexOf("\nSpectrum", idxProcessing + 1);
                if (idxStart == -1) {   // this could be f@cking Mac (Jill's case)
					idxStart = csv.IndexOf("\rSpectrum", idxProcessing + 1);
				}
				csv = csv.Substring(idxStart + 1, idxMean - idxStart - 1);
            }
            if (idxProcessing >= 0 && idxMean==-1 && idxProcessing == idxProcessingLast)   {      // raw file (without footer)   // 2016-08-18_1300_CoMnGe(1-x)Alx_Si + SiO2_6561_160216-K1-2.txt
                mode = Mode.RawNoFooter;
                int idxStart = csv.IndexOf("\nSpectrum", idxProcessing + 1);
                if (idxStart == -1) {   // this could be f@cking Mac (Jill's case)
					idxStart = csv.IndexOf("\rSpectrum", idxProcessing + 1);
				}
                csv = csv.Substring(idxStart + 1);
            }
            csv = _NormalizeRawCSV(csv);

            _ValidateCSV(csv, result);
            if (!result || dt == null) {
                return result;
            }

            if (mode == Mode.Unknown) {
                mode = Mode.CSV;
            }
            _ValidateTable(result);

            return result;
        }

        private static string _NormalizeRawCSV(string csv) {
            int prevLength;
			// !!! can not delete DOUBLE TABS otherwise almost-right-formed files are wrong: https://webcompact.wdm.ruhr-uni-bochum.de/sample/samplebyid/8457 - here we have "X (mm)" and "Y (mm)" column names, but no data (NULL, NULL)
			//do {    // "2017-04-21_1958_Cr-Mn-Fe-Co-Ni_other_19115_170313-K2-1 Cr-Mn-Fe-Co-Ni v13-APT EDX.txt" - three tabs
			//    prevLength = csv.Length;
			//    csv = csv.Replace("\t\t", "\t");    // 2016-12-12_1566_IrO2-SnO2_Si + SiO2_11410_161010-K5-1 IrO2-SnO2 nr3 EDX.txt - double tables in data!!!
			//} while (csv.Length != prevLength);
			csv = csv.Replace("\t\r\n", "\r\n");
			csv = csv.Replace("\t\r", "\r");
			csv = csv.Replace("\t\n", "\n");
			csv = csv.Replace("\r\n\r\n", "\r\n");
			csv = csv.Replace("\r\r", "\r");
			csv = csv.Replace("\n\n", "\n");
			while (csv.StartsWith("\r") || csv.StartsWith("\n"))
                csv = csv.Substring(1);
            while (csv.EndsWith("\r") || csv.EndsWith("\n"))
                csv = csv.Substring(0, csv.Length - 1);
            while (csv.EndsWith("\t"))
                csv = csv.Substring(0, csv.Length - 1);
            if (csv.StartsWith(",") || csv.StartsWith(";"))
                csv = "Index" + csv;
            return csv;
        }


        /// <summary>
        /// validate CSV
        /// </summary>
        /// <param name="csv"></param>
        /// <returns></returns>
        protected TypeValidatorResult _ValidateCSV(string csv, TypeValidatorResult result) {
            if (result == null) {
                result = new TypeValidatorResult();
            }
            dt = null;
            try
            {
                bool firstLineContainsHeader = true;
                string delimiter = CSVParser.GuessDelimiter(csv);
                dt = CSVParser.VB_Parse(csv, delimiter, firstLineContainsHeader, 
                    name => elements.Contains(name) || coordsColumns.Contains(name) ? typeof(float) : typeof(string));
            }
            catch (Exception ex)
            {
                result.Code = 500;
                result.Message = $"{ex.GetType()} {ex.Message}";
            }
            return result;
        }


        // ??????? WTF ???????
        // 2019-02-28_4183_Cu-Zr-Nb-Hf-W, Cr-Mn-Fe-Co-Ni, Al-Si-Ti-V-Mo_Si_37604_190227-K7-1 3x 5-element TF target EDX

        // 2022-10-11_8118_Pd-Fe-Cu-Ag_Sapphire_63269_221005-K2-1 EDX center_000058330.txt
        // 2022-11-23_8144_Pd-Fe-Cu-Ag_Sapphire_64606_0008144_Aztec EDS_000059645.txt

        protected TypeValidatorResult _ValidateTable(TypeValidatorResult result) {
            if (result == null)
            {
                result = new TypeValidatorResult();
            }
            List<string> columnsToRemove = new List<string>();
            try
            {
                if (dt==null)
                {
                    result.Code = 549;
                    result.Message = $"dt==null";
                    return result;
                }
                if (dt.Columns.Count < 2)
                {
                    result.Code = 550;
                    result.Message = $"dt.Columns.Count < 2 [dt.Columns.Count={dt.Columns.Count}]";
                    return result;
                }
                if (mode==Mode.Raw && dt.Columns[0].ColumnName != "Spectrum") {
                    result.Code = 551;
                    result.Message = $"In Raw file first column name should be 'Spectrum' [{dt.Columns[0].ColumnName}]";
                    return result;
                }
                int ElementsStartIndex = -1;
                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    if (elements.Contains(dt.Columns[i].ColumnName))
                    {
                        if (ElementsStartIndex == -1)
                            ElementsStartIndex = i;
                    }
                    else if (allowedColumns.Contains(dt.Columns[i].ColumnName))
                    {
                        if (ElementsStartIndex > -1)
                        {
                            throw new Exception($"column {i}: {dt.Columns[i].ColumnName}, but ElementsStartIndex={ElementsStartIndex}");
                        }
                    }
                    else {
                        if (ElementsStartIndex >= 0 && dt.Columns[i].ColumnName.StartsWith("Column")) {
                            if (!string.IsNullOrEmpty(result.Warning)) {
                                result.Warning += " ";
                            }
                            columnsToRemove.Add(dt.Columns[i].ColumnName);
                            result.Warning += $"column {i}: {dt.Columns[i].ColumnName} (unknown column name, REMOVED)";
                        }
                        else if (ElementsStartIndex >= 0 && dt.Columns[i].ColumnName.StartsWith("Total"))
                        {
                            // 2018-04-01_3594_Nb-Ta-Ti-V_Si + SiO2_29150_180316-K2-2 NbTaTiV library V3 quick EDX.txt
                            // 2018-04-30_3626_Ti-Nb-Mo-Ta-W_Si + SiO2_30476_180409-K2-1 TiNbMoTaW library V1 EDX.txt
                            if (!string.IsNullOrEmpty(result.Warning))
                            {
                                result.Warning += " ";
                            }
                            columnsToRemove.Add(dt.Columns[i].ColumnName);
                            result.Warning += $"column {i}: {dt.Columns[i].ColumnName} (TOTAL column name, REMOVED)";
                        }
                        else {
                            throw new Exception($"column {i}: {dt.Columns[i].ColumnName} (unknown column name)");
                        }
                    }
                }
                foreach (var column in columnsToRemove)
                {
                    dt.Columns.Remove(column);
                }
            }
            catch (Exception ex)
            {
                result.Code = 500;
                result.Message = $"{ex.GetType()} {ex.Message}";
            }
            return result;
        }


        /// <summary>
        /// DataTable for ITableGetter
        /// </summary>
        /// </summary>
        /// <returns></returns>
        private DataTable? DataTable => dt;

        /// <summary>
        /// Is there any coordinates ("X (mm)", "Y (mm)", "x", "y")
        /// GetCoordinates for ITableGetter
        /// </summary>
        /// <returns></returns>
        private CoordinatesResult GetCoordinates(DataTable dt)
        {
            if (dt == null)
                return new CoordinatesResult();
            List<string> coordinates = new List<string>();
            foreach (DataColumn column in dt.Columns)
            {
                if (coordsColumns.Contains(column.ColumnName))
                    coordinates.Add(column.ColumnName);
            }
            return new CoordinatesResult(coordinates.ToArray());
        }


        /// <summary>
        /// Is there any coordinates ("X (mm)", "Y (mm)", "x", "y")
        /// GetCoordinates for ITableGetter
        /// </summary>
        /// <returns></returns>
        private DependenciesResult GetDependencies(DataTable dt)
        {
            if (dt == null)
                return new DependenciesResult();
            List<string> xColumns = new List<string>();
            foreach (DataColumn column in dt.Columns)
            {
                if (dependencyColumns.Contains(column.ColumnName, StringComparer.OrdinalIgnoreCase))
                    xColumns.Add(column.ColumnName);
            }
            return new DependenciesResult(xColumns.ToArray());
        }

        public Table GetTable() {
            if (verifiedVersion != version)
            {
                Validate();
                verifiedVersion = version;
            }
            return new Table(dt, GetCoordinates(dt), GetDependencies(dt));
        }

        /// <summary>
        /// get all boundaries values for writing to DB
        /// GetDatabaseValues for IDatabaseValuesGetter
        /// </summary>
        /// <returns></returns>
        public DatabaseValues GetDatabaseValues()
        {
            DatabaseValues dbv = new DatabaseValues();
            if (dt == null || dt.Columns.Count < 2)
            {
                return dbv;
            }
            GetDatabaseValues_FillProperties(dbv.Properties);

            GetDatabaseValues_FillCompositions(dbv.Compositions);
            return dbv;
        }


        /// <summary>
        /// get all properties (all boundaries values for writing to DB)
        /// </summary>
        /// <param name="props">properties to fill</param>
        public void GetDatabaseValues_FillProperties(List<PropertyValue> props)
        {
            var system = (this as IContext).Context.ChemicalSystem;


            List<string> elements = new List<string>();
            for (int i = 0; i < dt.Columns.Count; i++)
            {
                if (TypeValidator_EDX_CSV.elements.Contains(dt.Columns[i].ColumnName))
                {
                    elements.Add(dt.Columns[i].ColumnName);
                }
            }
            for (int i = 0; i < elements.Count; i++)    // columns
            {
                double min = 100, max = 0;  // in percent
                double value;
                string element = elements[i];
                if (!system.Contains(element)) {
                    continue;   // skip element, that is absent in the list of a sample (exclude substrate)
                }
                for (int rowIndex = 0; rowIndex < dt.Rows.Count; rowIndex++)    // rows
                {
                    if (dt.Rows.Count == 420 && !EdxMA420_0based.Contains(rowIndex))  // skip outliers of measurement grid: 420 => 342
                        continue;
                    DataRow row = dt.Rows[rowIndex];
                    value = row[element] == DBNull.Value || string.IsNullOrEmpty(row[element]?.ToString()) ? 0.0 : Convert.ToDouble(row[element]);
                    if (min > value)
                        min = value;
                    if (max < value)
                        max = value;
                }
                // Minimal {element} content
                props.Add(new PropertyValue()
                {
                    PropertyType = PropertyType.Float,
                    PropertyName = element,
                    SortCode = (i + 1) * 10,
                    Row = 1,
                    Value = (min < 0 ? 0 : min),
                    Comment = $"Minimal {element} content"
                });
                // Maximal {element} content
                props.Add(new PropertyValue()
                {
                    PropertyType = PropertyType.Float,
                    PropertyName = element,
                    SortCode = (i + 1) * 10,
                    Row = 2,
                    Value = (max > 100 ? 100 : max),
                    Comment = $"Maximal {element} content"
                });
            }
        }

        private static string CleanStringOfNonDigits(string s)
        {
            if (string.IsNullOrEmpty(s)) return s;
            string cleaned = new string(s.Where(char.IsDigit).ToArray());
            return cleaned;
        }

        /// <summary>
        /// get all compositions
        /// </summary>
        public void GetDatabaseValues_FillCompositions(List<CompositionValue> comps)
        {
            var system = (this as IContext).Context.ChemicalSystem;

            List<string> elements = new List<string>();
            for (int i = 0; i < dt.Columns.Count; i++)
            {
                if (TypeValidator_EDX_CSV.elements.Contains(dt.Columns[i].ColumnName))
                {
                    elements.Add(dt.Columns[i].ColumnName);
                }
            }
            string element;
            object value;
            double dblValue;

            // name of the column with Measurement Area
            string indexColumnName = indexColumns.FirstOrDefault(s => dt.Columns.Contains(s));  // "Index" or "Spectrum"
            string xColumnName = xColumns.FirstOrDefault(s => dt.Columns.Contains(s));  // "X (mm)" or "x"
            string yColumnName = yColumns.FirstOrDefault(s => dt.Columns.Contains(s));  // "Y (mm)" or "y"

            DataRow row;
            bool isSubset = elements.Count < system.Length && elements.All(elem => system.Contains(elem));  // consider SUBSET
            int maIndexFirst = 1;   // ideal case (start index == 1)
            if (dt.Rows.Count > 0) {    // want to understand, what is start index: 0 or 1 ?
                maIndexFirst = GetMeasurementAreaIndex(indexColumnName, dt.Rows[0], 0);
            }
            int maManual = 0;
            for (int rowIndex=0; rowIndex < dt.Rows.Count; rowIndex++)    // rows
            {
                if (dt.Rows.Count == 420 && !EdxMA420_0based.Contains(rowIndex)) {  // skip outliers of measurement grid: 420 => 342
                    continue;
                }
                row = dt.Rows[rowIndex];
                // Measurement Area
                var composition = new CompositionValue() { DeletePreviousProperties = true };
                int ma = dt.Rows.Count == 420 || dt.Rows.Count == 342 ? ++maManual : GetMeasurementAreaIndex(indexColumnName, row, rowIndex) + (maIndexFirst<1 ? 1 : 0);
                composition.Properties.Add(new PropertyValue()
                {
                    PropertyType = PropertyType.Int,
                    PropertyName = "Measurement Area",
                    Value = ma
                });
                // x
                if (!string.IsNullOrEmpty(xColumnName))
                {
                    value = row[xColumnName];
                    dblValue = value == DBNull.Value || string.IsNullOrEmpty(value?.ToString()) ? 0.0 : Convert.ToDouble(value);
                    composition.Properties.Add(new PropertyValue()
                    {
                        PropertyType = PropertyType.Float,
                        PropertyName = "x",
                        Value = dblValue
                    });
                }
                // y
                if (!string.IsNullOrEmpty(yColumnName))
                {
                    value = row[yColumnName];
                    dblValue = value == DBNull.Value || string.IsNullOrEmpty(value?.ToString()) ? 0.0 : Convert.ToDouble(value);
                    composition.Properties.Add(new PropertyValue()
                    {
                        PropertyType = PropertyType.Float,
                        PropertyName = "y",
                        Value = dblValue
                    });
                }
                // add elements to composition
                double sum = 0; // should be == 100%
                if (isSubset) {
                    for (int i = 0; i < elements.Count; i++)
                    {
                        if (!system.Contains(elements[i]))
                        {
                            continue;   // skip element, that is absent in the list of a sample (exclude substrate)
                        }
                        value = row[elements[i]];
                        sum += value == DBNull.Value || string.IsNullOrEmpty(value?.ToString()) ? 0.0 : Convert.ToDouble(value);
                    }
                }
                for (int i = 0; i < elements.Count; i++)
                {
                    element = elements[i];
                    if (isSubset && !system.Contains(element))
                    {
                        continue;   // skip element, that is absent in the list of a sample (exclude substrate)
                    }
                    value = row[element];
                    dblValue = value == DBNull.Value || string.IsNullOrEmpty(value?.ToString()) ? 0.0 : Convert.ToDouble(value);
                    if (isSubset && sum>0) {
                        dblValue *= 100 / sum;
                    }
                    composition.CompositionElements.Add(new CompositionElement()
                    {
                        CompoundIndex = i * 10,
                        ElementName = element,
                        ValueAbsolute = null,
                        ValuePercent = dblValue
                    });
                }
                comps.Add(composition);
            }

        }

        /// <summary>
        /// GetMeasurementAreaIndex
        /// </summary>
        /// <param name="indexColumnName">name of the column containing index</param>
        /// <param name="row"></param>
        /// <param name="rowIndex"></param>
        /// <returns>index should be 0 or more (-1 - skip row == no Measurement Area)</returns>
        private static int GetMeasurementAreaIndex(string indexColumnName, DataRow row, int rowIndex)
        {
            if (string.IsNullOrEmpty(indexColumnName))
                return rowIndex + 1;
            string value = row[indexColumnName].ToString().ToLower();
            if (value == "max." || value == "min.")
                return -1;  // skip row
            int leftBrace = value.IndexOf('{');
            int rightBrace = value.IndexOf('}');
            if (leftBrace >= 0 && leftBrace < rightBrace) {
                value = value.Substring(leftBrace + 1, rightBrace - leftBrace - 1);
            } else {
                value = CleanStringOfNonDigits(value);
            }
            if (!int.TryParse(value, out int val)) {
                throw new FormatException($"GetMeasurementAreaIndex: unable to determine the Measurement Area index [value=\"{row[indexColumnName]}\", valueToParse=\"{value}\", indexColumnName={indexColumnName}, rowIndex={rowIndex}]");
            }
            return val;
        }
    }
}