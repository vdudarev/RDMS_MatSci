using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Runtime.InteropServices;
using System.Xml;
using System.Xml.Linq;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;

namespace WebUtilsLib
{
    public static partial class DBUtils
    {
        /// <summary>
        /// Get Table Parameter
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="list"></param>
        /// <returns></returns>
        public static DataTable GetTableParameterFromSingleColumn<T>(T[] list) {
            var table = new DataTable();
            table.Columns.Add("Value", typeof(T));
            foreach (var item in list)
            {
                table.Rows.Add(item);
            }
            return table;
        }


        /// <summary>
        /// returns table (row==object) for IEnumerable<T>
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="data"></param>
        /// <returns>DataTable</returns>
        public static DataTable ToDataTable<T>(this IEnumerable<T> data)
        {
            PropertyDescriptorCollection props =
                TypeDescriptor.GetProperties(typeof(T));
            DataTable table = new DataTable();
            for (int i = 0; i < props.Count; i++)
            {
                PropertyDescriptor prop = props[i];
                table.Columns.Add(prop.Name, 
                    Nullable.GetUnderlyingType(prop.PropertyType) != null ? (Type)Nullable.GetUnderlyingType(prop.PropertyType) : prop.PropertyType);
            }
            object[] values = new object[props.Count];
            foreach (T item in data)
            {
                for (int i = 0; i < values.Length; i++)
                {
                    values[i] = props[i].GetValue(item) == null ? DBNull.Value : props[i].GetValue(item);
                }
                table.Rows.Add(values);
            }
            return table;
        }

        /// <summary>
        /// Returns mapped .Net type for Property type
        /// (for Properties Tables)
        /// </summary>
        /// <param name="propertyTypeName">string with property Type (as stated in the table name)</param>
        /// <returns>Type for .Net</returns>
        public static Type GetTypeByPropertyType(PropertyType type) => GetTypeByPropertyType(type.ToString());

        /// <summary>
        /// Returns mapped .Net type for Property type
        /// (for Properties Tables)
        /// </summary>
        /// <param name="propertyTypeName">string with property Type (as stated in the table name)</param>
        /// <returns>Type for .Net</returns>
        public static Type GetTypeByPropertyType(string propertyTypeName) {
            // mode != "Float" && mode != "Int" && mode != "String" && mode != "BigString"
            switch (propertyTypeName) {
                case "Float":
                    return typeof(double?);
                case "Int":
                    return typeof(long?);
                case "String":
                case "BigString":
                    return typeof(string);
            }
            return typeof(object);
        }

        public static object? GetValueByPropertyType(string propertyTypeName, string value) {
            if (string.IsNullOrEmpty(value))
                return null;
            Type t = GetTypeByPropertyType(propertyTypeName);
            switch (propertyTypeName) {
                case "Float":
                    double.TryParse(value, out double d);
                    return  d;
                case "Int":
                    long.TryParse(value, out long i);
                    return i;
                //case "String":
                //case "BigString":
                //    return value;
            }
            return value;
        }

        /// <summary>
        /// Returns mapped System.Data.DbType for Property type
        /// (for Properties Tables)
        /// </summary>
        /// <param name="propertyTypeName">string with property Type (as stated in the table name)</param>
        /// <returns>Type for .Net</returns>
        public static DbType GetDbTypeByPropertyType(PropertyType type) => GetDbTypeByPropertyType(type.ToString());

        /// <summary>
        /// Returns mapped System.Data.DbType for Property type
        /// (for Properties Tables)
        /// </summary>
        /// <param name="propertyTypeName">string with property Type (as stated in the table name)</param>
        /// <returns>Type for .Net</returns>
        public static DbType GetDbTypeByPropertyType(string propertyTypeName)
        {
            // mode != "Float" && mode != "Int" && mode != "String" && mode != "BigString"
            switch (propertyTypeName)
            {
                case "Float":
                    return DbType.Double;
                case "Int":
                    return DbType.Int64;
                case "String":
                case "BigString":
                    return DbType.String;
            }
            return DbType.Object;
        }

        /// <summary>
        /// Extracts table structure (in terms of columns and their types from properties list)
        /// Additionally: returns minimum row number (expected to be 1, if there are any rows)
        /// Additionally: returns maximum row number (expected to be 1 or higher, if there are any rows)
        /// </summary>
        /// <param name="listAll">List (union) of all properties values for object</param>
        /// <returns>Tuple with (DataTable, minRow, maxRow)</returns>
        public static (DataTable dt, int minRow, int maxRow) GetTableStructure(List<dynamic> listAll)
        {
            DataTable dt = new DataTable();
            int min=int.MaxValue, max=int.MinValue;
            string name, type;
            foreach (var item in listAll)
            {
                name = item.PropertyName;
                /*
                int i = name.IndexOf('_'), row;
                if (i>0 && name.StartsWith("row") && int.TryParse(name.Substring(3, i-3), out row)) {
                    colName = name.Substring(i + 1);
                    if (!string.IsNullOrEmpty(colName) && !dt.Columns.Contains(colName)) {
                        type = item.Type;
                        dt.Columns.Add(colName, GetTypeByPropertyType(type));
                    }
                    if (row < min)
                        min = row;
                    if (row > max)
                        max = row;
                }
                */
                if (item.Row>0)
                {
                    if (!string.IsNullOrEmpty(name) && !dt.Columns.Contains(name))
                    {
                        type = item.Type;
                        dt.Columns.Add(name, GetTypeByPropertyType(type));
                    }
                    if (item.Row < min)
                        min = item.Row;
                    if (item.Row > max)
                        max = item.Row;
                }

            }
            if (min == int.MaxValue)
                min = 0;
            if (max == int.MinValue)
                max = 0;
            return (dt, min, max);
        }



        /// <summary>
        /// Extracts table structure (in terms of columns and their types from properties list)
        /// Additionally: returns minimum row number (expected to be 1, if there are any rows)
        /// Additionally: returns maximum row number (expected to be 1 or higher, if there are any rows)
        /// </summary>
        /// <param name="listAll">List (union) of all properties values for object</param>
        /// <returns>Tuple with (DataTable, minRow, maxRow)</returns>
        public static DataTable GetNonTablePropertiesStructure()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Type", typeof(string)); // Float, Int, ...
            dt.Columns.Add("Name", typeof(string));
            dt.Columns.Add("Value", typeof(string)); // actual Value
            dt.Columns.Add("Epsilon", typeof(string)); // for Float only
            dt.Columns.Add("Comment", typeof(string)); // SEPARATOR or ...
            return dt;
        }



        /// <summary>
        /// Returns DataTable for properties list (discovers table structure, based on property names 'row<int>_ColumnName' and fills the table)
        /// </summary>
        /// <param name="listAll"></param>
        /// <param name="sourceObjectIdMode">0 - ignore; 1 - make HTML-links to Source Object</param>
        /// <returns></returns>
        public static DataTable FeedTablePropertiesFromList(List<dynamic> listAll, int sourceObjectIdMode = 0)
        {
            (DataTable dt, int min, int max) = GetTableStructure(listAll);
            if (min==0 && max==0)
                return dt;
            string name, value, sourceObjectIdStr;
            int i, row, sourceObjectId;
            for (i = min; i <= max; i++)    // add empty rows
            {
                dt.Rows.Add();
            }
            foreach (var item in listAll)
            {
                name = item.PropertyName;
                if (item.Row>0)
                {
                    value = item.Value;
                    if (dt.Columns.Contains(name))
                    {
                        if (sourceObjectIdMode > 0) {
                            sourceObjectIdStr = item.SourceObjectId?.ToString() ?? string.Empty;
                            if (int.TryParse(sourceObjectIdStr, out sourceObjectId) && sourceObjectId != 0) {
                                value = $"<a href=\"/object/id/{sourceObjectId}\">{value}</a>";
                            }
                        }
                        dt.Rows[item.Row - min][name] = value;
                    }
                }
            }
            return dt;
        }



        /// <summary>
        /// Returns DataTable for properties list (discovers table structure, based on property names 'row<int>_ColumnName' and fills the table)
        /// </summary>
        /// <param name="listAll"></param>
        /// <returns></returns>
        public static DataTable FeedNonTablePropertiesFromList(List<PropertyValue> listAll)
        {
            //DataTable dt = GetNonTablePropertiesStructure();
            //dt.Columns.Add("Type", typeof(string)); // Float, Int, ...
            //dt.Columns.Add("Name", typeof(string));
            //dt.Columns.Add("Value", typeof(string)); // actual Value
            //dt.Columns.Add("Epsilon", typeof(string)); // for Float only
            //dt.Columns.Add("Comment", typeof(string)); // SEPARATOR or ...
            DataTable dt = new DataTable();
            dt.Columns.Add("Type", typeof(string)); // Float, Int, ...
            dt.Columns.Add("Name", typeof(string));
            dt.Columns.Add("Value", typeof(string)); // actual Value
            dt.Columns.Add("Epsilon", typeof(string)); // for Float only
            dt.Columns.Add("Comment", typeof(string)); // SEPARATOR or ...
            dt.Columns.Add("SourceObjectId", typeof(string)); // SourceObjectId
            // dt.Rows.Add("Type", "Name", "Value", "Epsilon", "Comment");
            foreach (var item in listAll) {
                dt.Rows.Add(item.PropertyType, item.PropertyName, item.Value, item.ValueEpsilon, item.Comment, item.SourceObjectId);
            }
            return dt;
        }




        /// <summary>
        /// Returns DataTable for properties list Template
        /// </summary>
        /// <param name="listAll"></param>
        /// <returns></returns>
        public static DataTable FeedTableTemplate(List<dynamic> listAll)
        {
            DataTable dt = new DataTable();
            if (listAll.Count > 0) {
                string type, name;
                dt.Rows.Add();
                foreach (var item in listAll)
                {
                    type = item.PropertyType;
                    name = item.PropertyName;
                    if (!string.IsNullOrEmpty(name) && !dt.Columns.Contains(name))
                    {
                        dt.Columns.Add(name, typeof(string));
                        dt.Rows[0][name] = type;
                    }
                }
            }
            return dt;
        }


        public static string ConvertDataTableToJson(DataTable dataTable, Newtonsoft.Json.Formatting formatting = Newtonsoft.Json.Formatting.None)
        {
            string jsonString = string.Empty;

            if (dataTable != null && dataTable.Rows.Count > 0)
            {
                jsonString = JsonConvert.SerializeObject(dataTable);
            }

            return jsonString;
        }
    }
}
