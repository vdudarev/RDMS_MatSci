using System.Data;

namespace InfProject.Models;

public class TableView
{
    /// <summary>
    /// DataTable to display
    /// </summary>
    public DataTable Table { get; set; }

    /// <summary>
    /// "Data caption"
    /// </summary>
    public string? Title { get; set; }

    /// <summary>
    /// Message to display in table contatins no rows.
    /// </summary>
    public string EmptyMessage { get; set; } = "No records";

    /// <summary>
    /// Delegate Func<int, int, object, string> to Render CELL value.
    /// first int - row index
    /// second int - column index
    /// object - cell value
    /// Return Value (string html, string attributes for cell node): HTML to output in the cell AND attributes for the cell node
    /// </summary>
    public Func<int, int, object, (string, string)>? RenderHtmlString { get; set; } = null;

    public TableView(DataTable table)
    {
        Table = table;
    }
}
