namespace WebUtilsLib
{
    public static partial class DBUtils
    {
        public class CompositionValue : DatabaseValuesBase  // inheritance to add extended properties for composition (i.e. for -> Sample -> Object)
        {
            // due to inheritance get properties for object-composition

            /// <summary>
            /// Measurement Area number (1..342)
            /// </summary>
            // public int MeasurementArea;

            /// <summary>
            /// LIST of elements with index and order
            /// </summary>
            public List<CompositionElement> CompositionElements { get; init; } = new List<CompositionElement>();
        }

    }
}
