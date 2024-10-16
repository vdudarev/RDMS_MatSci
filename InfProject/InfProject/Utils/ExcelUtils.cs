using InfProject.Models;
using OfficeOpenXml;
using System.Data;
using System.Text;

namespace InfProject.Utils
{
    public class ExcelUtils
    {

        /// <summary>
        /// Get Excel stream from DataTable
        /// </summary>
        /// <param name="dt"></param>
        /// <param name="sheetName"></param>
        /// <param name="action">action to perform after table is populated</param>
        /// <returns></returns>
        public static async Task<MemoryStream> GetMemoryStream(DataTable dt, string sheetName, Action<ExcelWorksheet> action = null)
        {
            var ms = new MemoryStream();
            using var package = new ExcelPackage(ms);
            var ws = package.Workbook.Worksheets.Add(sheetName);
            var range = ws.Cells["A1"].LoadFromDataTable(dt, true); // make BOLD for headers
            range.AutoFitColumns(); // auto fit columns width
            ws.Row(1).Style.Font.Bold = true;
            action?.Invoke(ws);
            await package.SaveAsync();
            ms.Position = 0;    // important, otherwise size is 0
            return ms;
        }

    }
}
