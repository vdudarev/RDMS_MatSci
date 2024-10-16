using Newtonsoft.Json;
using System.Text.Json.Serialization;

namespace WebUtilsLib
{
    public static partial class DBUtils
    {
        public class PropertyValue
        {
            public int PropertyId { get; init; }
            [JsonPropertyName("Type")]
            [JsonProperty(PropertyName = "Type")]
            public PropertyType PropertyType { get; init; }
            [JsonPropertyName("Name")]
            [JsonProperty(PropertyName = "Name")]
            public string PropertyName { get; init; } = null!;
            public object Value { get; set; } = null!;
            public double? ValueEpsilon { get; init; }
            public int SortCode { get; init; }
            public int? Row { get; init; }
            public string? Comment { get; init; }
            public int? SourceObjectId { get; set; }

            /// <summary>
            /// Normalizes Value according to PropertyType
            ///     No mapping exists from object type System.Text.Json.JsonElement to a known managed provider native type.
            /// </summary>
            public void NormalizeValue() {
                if (PropertyType == PropertyType.Int) {
                    Value = Convert.ToInt64(Value?.ToString());
                } else if (PropertyType == PropertyType.Float) {
                    Value = Convert.ToDouble(Value?.ToString());
                } else { 
                    Value = Value?.ToString(); 
                }
            }

            public override string ToString() => $"(name={PropertyName}, value={Value}, type={PropertyType})";
        }

    }
}
