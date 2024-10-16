using FluentValidation;
using InfProject.DBContext;
using InfProject.Utils;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using System.ComponentModel.DataAnnotations;
using System.Data;

namespace InfProject.Models;

public class Composition : Sample
{
    public class CompositionItem {
        public int CompositionId { get; set; }
        public int SampleId { get; set; }
        public int CompoundIndex { get; set; }
        public string ElementName { get; set; } = null!;
        public double ValueAbsolute { get; set; }
        public double ValuePercent { get; set; }
    }

    [Order]
    [Display(Name = "Composition Items", GroupName = "HIDDEN")]
    public List<CompositionItem> CompositionItems { get; set; } = new List<CompositionItem>();
    [Order]
    [Display(Name = "Xml", GroupName = "HIDDEN")]
    public string Xml { get; set; } = null!;

    public static DataTable GetTableParameter(List<CompositionItem> list)
    {
        var table = new DataTable();
        table.Columns.Add("CompositionId", typeof(int));
        table.Columns.Add("SampleId", typeof(int));
        table.Columns.Add("CompoundIndex", typeof(int));
        table.Columns.Add("ElementName", typeof(string));
        table.Columns.Add("ValueAbsolute", typeof(double));
        table.Columns.Add("ValuePercent", typeof(double));
        foreach (var item in list)
        {
            table.Rows.Add(item.CompositionId, item.SampleId, item.CompoundIndex, item.ElementName, item.ValueAbsolute, item.ValuePercent);
        }
        return table;
    }
}

public class CompositionValidator : AbstractValidator<Composition>
{
    public CompositionValidator()
    {
        RuleFor(obj => new { obj.Elements, obj.CompositionItems }).Custom((x, context) =>
        {
            var validator = new ChemicalCompositionValidator();
            string err = validator.Validate(x.Elements, x.CompositionItems);
            if (!string.IsNullOrEmpty(err))
            {
                context.AddFailure(err);
            }
        });
    }

}