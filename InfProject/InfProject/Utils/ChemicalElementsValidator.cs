using FluentValidation;
using InfProject.DBContext;
using InfProject.DTO;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.FlowAnalysis;
using Microsoft.Extensions.Options;
using System.Collections.Generic;
using System.Linq;

namespace InfProject.Utils
{
    public class ChemicalElementsValidator
    {
        /*
DECLARE @result nvarchar(max) = ''
SELECT @result = @result + '"' + ElementName + N'", ' FROM ElementInfo order by ElementName
SET @result = LEFT(@result, LEN(@result) - 1)       -- trim last ','
PRINT @result
        */
        public static readonly string[] elements = { "Ac", "Ag", "Al", "Am", "Ar", "As", "At", "Au", "B", "Ba", "Be", "Bh", "Bi", "Bk", "Br", "C", "Ca", "Cd", "Ce", "Cf", "Cl", "Cm", "Cn", "Co", "Cr", "Cs", "Cu", "Db", "Ds", "Dy", "Er", "Es", "Eu", "F", "Fe", "Fl", "Fm", "Fr", "Ga", "Gd", "Ge", "H", "He", "Hf", "Hg", "Ho", "Hs", "I", "In", "Ir", "K", "Kr", "La", "Li", "Lr", "Lu", "Lv", "Mc", "Md", "Mg", "Mn", "Mo", "Mt", "N", "Na", "Nb", "Nd", "Ne", "Nh", "Ni", "No", "Np", "O", "Og", "Os", "P", "Pa", "Pb", "Pd", "Pm", "Po", "Pr", "Pt", "Pu", "Ra", "Rb", "Re", "Rf", "Rg", "Rh", "Rn", "Ru", "S", "Sb", "Sc", "Se", "Sg", "Si", "Sm", "Sn", "Sr", "Ta", "Tb", "Tc", "Te", "Th", "Ti", "Tl", "Tm", "Ts", "U", "V", "W", "Xe", "Y", "Yb", "Zn", "Zr"};

        //public ChemicalElementsValidator()
        //{
        //    Init();
        //}

        //public void Init() {
        //    if (elements != null)
        //        return;
        //    //DataContext dataContext = HttpContext.RequestServices.GetService(typeof(DataContext));
        //    List<string> list = dataContext.GetChemicalElements().Result;
        //    if (elements != null)
        //        return;
        //    lock (lockObject) {
        //        elements = list;
        //    }
        //}

        public string Validate(string system) {
            if (string.IsNullOrEmpty(system))
                return "Chemical System can not be empty";
            if (system.Contains("--"))
                return "Chemical System can not contain empty positions";
            string[] arr = system.Split('-', StringSplitOptions.RemoveEmptyEntries);
            if (arr.Length==0)
                return "Chemical System can not contain 0 elements";
            foreach (var item in arr)
            {
                if (!elements.Contains(item, StringComparer.OrdinalIgnoreCase))
                    return $"unknown element: {item}";
            }
            return string.Empty;
        }

		public List<string> GetChemicalElementsOnly(IEnumerable<string> items)
		{
            var list = new List<string>();
            foreach (var item in items) { 
                if (elements.Contains(item))
					list.Add(item);
			}
			return list;
		}
	}
}
