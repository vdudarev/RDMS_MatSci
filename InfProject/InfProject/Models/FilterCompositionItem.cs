using FluentValidation;
using InfProject.DBContext;
using InfProject.Utils;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Data;

namespace InfProject.Models;

/// <summary>
/// == dbo.FilterCompositionItem
/// </summary>
public class FilterCompositionItem
{
    public string ElementName { get; set; } = null!;
    public double? ValueAbsoluteMin { get; set; }
    public double? ValueAbsoluteMax { get; set; }
    public double? ValuePercentMin { get; set; }
    public double? ValuePercentMax { get; set; }

    public override string ToString()
    {
        if (ValueAbsoluteMin != null || ValueAbsoluteMax != null) { 
            if (ValueAbsoluteMin != null && ValueAbsoluteMax != null)
                return $"{ElementName}{ValueAbsoluteMin}-{ValueAbsoluteMax}";
            return $"{ElementName}{ValueAbsoluteMin}{ValueAbsoluteMax}";
        }
        if (ValuePercentMin != null || ValuePercentMax != null) {
            if (ValuePercentMin != null && ValuePercentMax != null)
                return $"{ElementName}{ValuePercentMin}-{ValuePercentMax}%";
            return $"{ElementName}{ValuePercentMin}{ValuePercentMax}%";
        }
        return $"{ElementName}";
    }
    /*
    public static DataTable ToDataTable(IEnumerable<FilterCompositionItem> data)
    {
        DataTable table = new DataTable();
        table.Columns.Add("ElementName", typeof(string));
        table.Columns.Add("ValueAbsoluteMin", typeof(double));
        table.Columns.Add("ValueAbsoluteMax", typeof(double));
        table.Columns.Add("ValuePercentMin", typeof(double));
        table.Columns.Add("ValuePercentMax", typeof(double));
        foreach (FilterCompositionItem item in data)
        {
            table.Rows.Add(item.ElementName, 
                item.ValueAbsoluteMin.HasValue ? item.ValueAbsoluteMin : DBNull.Value, 
                item.ValueAbsoluteMax.HasValue ? item.ValueAbsoluteMax : DBNull.Value, 
                item.ValuePercentMin.HasValue ? item.ValuePercentMin : DBNull.Value, 
                item.ValuePercentMax.HasValue ? item.ValuePercentMax : DBNull.Value);
        }
        return table;
    }
    */
}
