using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Xml.Linq;
using System;

namespace InfProject.Models;

public class Substrate
{
    public int SubstrateId { get; set; }
    public string SubstrateMaterial { get; set; } = null!;
    public int SortCode { get; set; }
}
