using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Xml.Linq;
using System;

namespace InfProject.Models;

public class TreeItem
{
    public string ObjectId { get; set; } = null!;
    public int Level { get; set; }
    public string Class { get; set; } = null!;
    public string? ParentId { get; set; }
    public string KlId { get; set; } = null!;
    public string Description { get; set; } = null!;
    public string? Classif { get; set; }
    public string? Unit { get; set; }
    public string? Sort { get; set; }
    public string? ValueType { get; set; }
    public string Path { get; set; } = null!;
    public string Path2SortString { get; set; } = null!;

    public bool Checked { get; set; }
    public virtual List<TreeItem> Children { get; set; } = new List<TreeItem>();



    public TreeItem() { }

    /// <summary>
    /// Copy constructor.
    /// </summary>
    /// <param name="prev"></param>
    public TreeItem(TreeItem prev)
    {
        ObjectId = prev.ObjectId;
        Level = prev.Level;
        Class = prev.Class;
        ParentId = prev.ParentId;
        KlId = prev.KlId;
        Description = prev.Description;
        Classif = prev.Classif;
        Unit = prev.Unit;
        Sort = prev.Sort;
        ValueType = prev.ValueType;
        Path = prev.Path;
        Path2SortString = prev.Path2SortString;
        Checked = prev.Checked;
        Children = new List<TreeItem>(prev.Children);
    }

}
