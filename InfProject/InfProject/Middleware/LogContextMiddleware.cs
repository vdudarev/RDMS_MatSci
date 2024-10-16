using Serilog.Context;
namespace InfProject;
/// <summary>
/// Middleware to set additional properties for LogContext
/// </summary>
public class LogContextMiddleware
{
    private readonly RequestDelegate _next;
    /// <summary>
    /// standard constructor for middleware
    /// </summary>
    /// <param name="next"></param>
    public LogContextMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    /// <summary>
    /// Invokes the middleware in every request
    /// </summary>
    /// <param name="context">HttpContext</param>
    /// <returns>Task</returns>
    public async Task Invoke(HttpContext context)
    {
        var routeData = context.GetRouteData();
        var controllerName = routeData?.Values["controller"]?.ToString() ?? string.Empty;
        var areaName = routeData?.Values["area"]?.ToString() ?? string.Empty;
        LogContext.PushProperty("ControllerName", controllerName);
        LogContext.PushProperty("AreaName", areaName);
        await _next(context);
    }
}
