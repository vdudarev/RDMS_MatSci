namespace WebUtilsLib
{
    public static partial class DBUtils
    {
        public class CompositionElement
        {
            public int CompoundIndex { get; set; }
            public string ElementName { get; set; } = null!;
            public double? ValueAbsolute { get; set; }
            public double ValuePercent { get; set; }
        }

    }
}
