using FluentValidation;
using InfProject.DBContext;
using InfProject.DTO;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.FlowAnalysis;
using Microsoft.Extensions.Options;
using System.Collections.Generic;
using System.Data;
using static InfProject.Models.Composition;

namespace InfProject.Utils
{
    public class ChemicalCompositionValidator
    {
        public string Validate(string system, List<CompositionItem> composition) {
            ChemicalElementsValidator validator = new ChemicalElementsValidator();
            string err = validator.Validate(system);
            if (!string.IsNullOrEmpty(err)) {
                return err;
            }

            if (composition == null || composition.Count==0) {
                return "List<CompositionItem> is null or empty";
            }
            string[] arrSystem = system.Split('-', StringSplitOptions.RemoveEmptyEntries);
            if (arrSystem.Length != composition.Count) {
                return "Chemical system and compound mismatch (arrSystem.Length != composition.Count)";
            }
            if (!composition.TrueForAll(x => x.ValuePercent >= 0 && x.ValuePercent <= 100))
            {
                return "Every Percentage should be in [0; 100]";
            }
            if (!composition.TrueForAll(x => x.ValueAbsolute >= 0))
            {
                return "Every Absolute should be >= 0";
            }
            double valueAbsolute = 0, valuePercent = 0;
            foreach (CompositionItem item in composition)
            {
                if (!arrSystem.Contains(item.ElementName)) {
                    return $"composition.Element({item.ElementName}) is not found in known elements list";
                }
                valueAbsolute += item.ValueAbsolute;
                valuePercent += item.ValuePercent;
            }
            if (valuePercent > 0 && valueAbsolute > 0) {
                return "Can not mix Percentage and Absolute values";
            }
            if (valueAbsolute > 0) {
                return string.Empty;
            }
            if (valuePercent >= 99.999 && valuePercent <= 100.001)
            {
                return string.Empty;
            }
            else {
                return "Sum of Percentage should be equal to 100%";
            }
        }
    }
}
