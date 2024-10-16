using Microsoft.EntityFrameworkCore.Metadata.Internal;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using System.ComponentModel.DataAnnotations;
using System.Net;
using System.Reflection;
using System.Text;
using System.Text.Json;
using WebUtilsLib;
using static TypeValidationLibrary.TypeValidator_EDX_CSV;

namespace TypeValidationLibrary
{
    /// <summary>
    /// HttpValidatorProxy to wrap external http services and introduce them in the app as native ones
    /// </summary>
    public class HttpTypeValidatorProxy : TypeValidatorBase // : IFileValidator
    {
        private string validationSchema;
        
        private string GetRequestUrl(string validationSchema) => validationSchema + "/body";


        public HttpTypeValidatorProxy(string validationSchema) {
            if (!validationSchema.StartsWith("http://") && !validationSchema.StartsWith("https://"))
                throw new ArgumentException($"validationSchema should start with http(s):// [{validationSchema} found]");
            this.validationSchema = validationSchema;
        }


        protected override TypeValidatorResult ValidateSpecific() {
            TypeValidatorResult res = null!;
            string requestUrl = GetRequestUrl(validationSchema);
            if (File != null)
            {
                res = HttpUtils.GetDataThroughWebService<TypeValidatorResult>(requestUrl, File.FullName).Result;
            }
            else if (Stream != null)
            {
                res = HttpUtils.GetDataThroughWebService<TypeValidatorResult>(requestUrl, Stream).Result;
            }
            else {
                throw new ArgumentNullException("File and Stream are not defined");
            }
            return res;
        }
    }
}