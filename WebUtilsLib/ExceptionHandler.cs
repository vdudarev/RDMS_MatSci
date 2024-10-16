using Microsoft.AspNetCore.Http;
using System.Text;

namespace WebUtilsLib
{
    public static class ExceptionHandler
    {
        private static IHttpContextAccessor httpContextAccessor;
        public static void SetHttpContextAccessor(IHttpContextAccessor accessor)
        {
            httpContextAccessor = accessor;
        }

        public static string ToStringForLog(this Exception? ex)
        {
            
            StringBuilder sb = new StringBuilder();
            HttpRequest req = httpContextAccessor?.HttpContext?.Request;
            if (req != null) {
                sb.Append($"{req.Method} {req.Host}{req.Path}{(string.IsNullOrEmpty(req.QueryString.Value) ? string.Empty : $"?{req.QueryString.Value}")} ");
            }
            do
            {
                sb.AppendLine($"{ex?.GetType()}: {ex?.Message} [{ex?.StackTrace}]");
                ex = ex?.InnerException;
            } while (ex != null);
            return sb.ToString();
        }

    }
}
