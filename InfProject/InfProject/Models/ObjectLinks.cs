using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Diagnostics.CodeAnalysis;
using Dapper;
using FluentValidation;
using InfProject.Utils;
using Newtonsoft.Json;

namespace InfProject.Models;

public class ObjectLinks
{
    public class Link {
        public int LinkTypeObjectId { get; set; }   // object that characterizes "type of a link"
        public int LinkedObjectId { get; set; }
        public int SortCode { get; set; }
        public static DataTable GetTableParameter(int objectId, Link[] list)
        {
            var table = new DataTable();
            table.Columns.Add("ObjectLinkObjectId", typeof(int));
            table.Columns.Add("ObjectId", typeof(int));
            table.Columns.Add("LinkedObjectId", typeof(int));
            table.Columns.Add("SortCode", typeof(int));
            table.Columns.Add("LinkTypeObjectId", typeof(int));
            foreach (var item in list)
            {
                table.Rows.Add(0, objectId, item.LinkedObjectId, item.SortCode, item.LinkTypeObjectId);
            }
            return table;
        }
    }

    public int ObjectId { get; set; }
    public Link[] Links { get; set; }


    public static DataTable GetTableParameter(IEnumerable<(int ObjectId, int LinkedObjectId, int SortCode, int LinkTypeObjectId)> links)
    {
        var table = new DataTable();
        table.Columns.Add("ObjectLinkObjectId", typeof(int));
        table.Columns.Add("ObjectId", typeof(int));
        table.Columns.Add("LinkedObjectId", typeof(int));
        table.Columns.Add("SortCode", typeof(int));
        table.Columns.Add("LinkTypeObjectId", typeof(int));
        foreach (var item in links)
        {
            table.Rows.Add(0, item.ObjectId, item.LinkedObjectId, item.SortCode, item.LinkTypeObjectId);
        }
        return table;
    }


    public override string ToString() => JsonConvert.SerializeObject(this);
}
