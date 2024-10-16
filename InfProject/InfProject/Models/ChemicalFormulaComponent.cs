namespace InfProject.Models
{
    /// <summary>
    /// essentially name-value pair (chemical element, quantity)
    /// </summary>
    public class ChemicalFormulaComponent
    {
        public ChemicalFormulaComponent(string element, int quantity)
        {
            Element = element;
            Quantity = quantity;
        }

        public string Element { get; set; }
        public int Quantity { get; set; }
    }
}
