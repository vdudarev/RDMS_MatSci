using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

/// https://markb.uk/asp-net-core-read-raw-request-body-as-string.html
namespace WebUtilsLib
{
    public class EnableRequestBodyBufferingMiddleware
    {
        private readonly RequestDelegate _next;

        public EnableRequestBodyBufferingMiddleware(RequestDelegate next) =>
            _next = next;

        public async Task InvokeAsync(HttpContext context)
        {
            context.Request.EnableBuffering();

            await _next(context);
        }
    }
}
