using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using Microsoft.VisualBasic.FileIO;
using System.Text.RegularExpressions;
using System.Globalization;

namespace WebUtilsLib
{
    /// <summary>
    /// класс для CSV-парсинга
    /// Использует string.Split, поэтому будут проблемы, если разделитель встретится в данных
    /// </summary>
    public class CSVParser
    {

#region Поля

        public string[] Lines = null;
        public string Separator = ",";
        public bool FirstLineContainsHeader = true;

#endregion // Поля

#region Конструкторы и инициализация

        public CSVParser() { }

        public CSVParser(bool FirstLineContainsHeader, string Separator)
            :this(FirstLineContainsHeader, Separator, null)
        { }

        public CSVParser(bool FirstLineContainsHeader, string Separator, string[] Lines)
        {
            this.FirstLineContainsHeader = FirstLineContainsHeader;
            this.Separator = Separator;
            this.Lines = Lines;
        }
#endregion //Конструкторы и инициализация

#region Реализация
        /// <summary>
        /// читает CSV-строки из строки с разделителями CrLf
        /// </summary>
        /// <param name="text">исходная строка</param>
        public void ReadLinesFromText(string text)
        {
            Lines = text.Split(new char[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
        }
        /// <summary>
        /// читает CSV-строки из файла с именем FileName
        /// </summary>
        /// <param name="FileName">имя файла на диске</param>
        public void ReadLinesFromFile(string FileName)
        {
            ReadLinesFromFile(FileName, Encoding.Default);
        }
        /// <summary>
        /// читает CSV-строки из файла с именем FileName в определенной кодировке
        /// </summary>
        /// <param name="FileName">имя файла на диске</param>
        /// <param name="encoding">кодировка</param>
        public void ReadLinesFromFile(string FileName, Encoding encoding)
        {
            Lines = File.ReadAllLines(FileName, encoding);
        }

        public void ReadLinesFromStream(Stream stream, Encoding encoding)
        {
            StreamReader sr = new StreamReader(stream, encoding);
            Lines = sr.ReadToEnd().Split(new char[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
        }


        /// <summary>
        /// возвращает отпарсенный DataTable
        /// </summary>
        /// <returns></returns>
        public DataTable Parse()
        {
            char[] separators = Separator.ToCharArray();
            bool IsHeaderProcessed=false;
            DataTable table = new DataTable("CSV");
            foreach (string line in Lines)
            {
                if (!IsHeaderProcessed)
                {
                    IsHeaderProcessed = true;
                    string[] names = line.Split(separators);
                    if (FirstLineContainsHeader)
                    {
                        foreach (string name in names)
                            table.Columns.Add(name);
                        continue;   // переходим к след. строке
                    }
                    else
                    {
                        foreach (string name in names)
                            table.Columns.Add();
                    }
                }
                // вставляем строку с данными в табличку
                string[] data = line.Split(separators);
                for (int i = table.Columns.Count; i < data.Length; i++) // добавим столбцы, если надо под данные
                    table.Columns.Add();
                DataRow dataRow = table.NewRow();
                for (int i = 0; i < data.Length; i++)
                    dataRow[i] = data[i];
                table.Rows.Add(dataRow);
            }
            return table;
        }
        #endregion // Реализация



        /// <summary>
        /// gets delimiter from CSV
        /// </summary>
        /// <param name="csv">CSV data</param>
        /// <returns>CSV delimiter</returns>
        public static string GuessDelimiter(string csv)
        {
            int[] arr = { csv.IndexOf("\r\n"), csv.IndexOf("\n"), csv.IndexOf("\r") };
            int index = arr.Where(x => x>0).OrderBy(x => x).First();
            string firstLine = StringUtils.Left(csv, index);
            string[] delimiters = { "\t", ";", "," };
            for (int i = 0; i < delimiters.Length; i++)
            {
                if (firstLine.IndexOf(delimiters[i])>=0)
                    return delimiters[i];
            }
            return ";"; // default
        }


        public static DataTable VB_Parse(string CSV, string delimiter, bool firstLineContainsHeader, Func<string, Type>? fieldTypeByName = null)
        {
            DataTable dt = new DataTable("CSV");
            StringReader sr = new StringReader(CSV);
            using (TextFieldParser parser = new TextFieldParser(sr) { 
                TextFieldType = FieldType.Delimited,  
                HasFieldsEnclosedInQuotes = true })
            {
                parser.SetDelimiters(delimiter);
                bool IsHeaderProcessed = false;

                string[] fields;
                int i;
                while (!parser.EndOfData)
                {
                    fields = parser.ReadFields();

                    if (!IsHeaderProcessed) {
                        if (firstLineContainsHeader)
                        {
                            foreach (string field in fields)
                            {
                                if (fieldTypeByName == null)
                                {
                                    dt.Columns.Add(field);
                                }
                                else {
                                    dt.Columns.Add(field, fieldTypeByName(field));
                                }
                            }
                            IsHeaderProcessed = true;
                            continue;   // go to next line
                        }
                        else {
                            foreach (string field in fields)
                            {
                                dt.Columns.Add();
                            }
                        }
                        IsHeaderProcessed = true;
                    }
                    // add row with data into table
                    for (i = dt.Columns.Count; i < fields.Length; i++) // add columns for data, if required
                        dt.Columns.Add();
                    DataRow dataRow = dt.NewRow();
                    for (i = 0; i < fields.Length; i++) {
                        if (dt.Columns[i].DataType == typeof(float)) 
                        {
                            dataRow[i] = float.TryParse(fields[i], CultureInfo.InvariantCulture, out float val) ? val : DBNull.Value;
                        }
                        else
                        {
                            dataRow[i] = fields[i];
                        }
                    }
                    dt.Rows.Add(dataRow);
                }
            }
            return dt;
        }
    }


    

    /// <summary>
    /// Convert DataTable to CSV
    /// Rfc4180
    /// </summary>
    public static class DataTable2CSV
    {
        public static void WriteDataTable(string separator, DataTable sourceTable, TextWriter writer, bool includeHeaders, bool changeEndL2Space = true)
        {
            if (includeHeaders)
            {
                List<string> headerValues = new List<string>();
                foreach (DataColumn column in sourceTable.Columns)
                {
                    headerValues.Add(QuoteValue(column.ColumnName));
                }

                writer.WriteLine(String.Join(separator, headerValues.ToArray()));
            }

            string[] items = null;
            string st;
            foreach (DataRow row in sourceTable.Rows)
            {
                if (changeEndL2Space)
                    items = row.ItemArray.Select(o => QuoteValue(ChangeEndL2Space(o.ToString()))).ToArray();
                else
                    items = row.ItemArray.Select(o => QuoteValue(o.ToString())).ToArray();
                st = String.Join(separator, items);
                writer.WriteLine(st);
            }

            writer.Flush();
        }


        public static string GetCSVfromDataTable(string separator, DataTable sourceTable, bool includeHeaders, bool changeEndL2Space = true)
        {
            if (sourceTable == null)
                return string.Empty;
			StringWriter sw = new StringWriter();
            WriteDataTable(separator, sourceTable, sw, includeHeaders, changeEndL2Space);
            return sw.ToString();
        }

        private static string QuoteValue(string value)
        {
            value=value.Replace("\r", "").Replace("\n", " ");
            return string.Concat("\"", value.Replace("\"", "\"\""), "\"");
        }
        private static string ChangeEndL2Space(string value)
        {
            value = value.Replace("\r", "").Replace("\n", " ");
            return value;
        }
    }

}
