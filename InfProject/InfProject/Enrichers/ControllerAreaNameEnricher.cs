using Azure.Core;
using Serilog.Core;
using Serilog.Events;

namespace InfProject;

public class ControllerAreaNameEnricher : ILogEventEnricher
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public ControllerAreaNameEnricher(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public void Enrich(LogEvent logEvent, ILogEventPropertyFactory propertyFactory)
    {
        var httpContext = _httpContextAccessor.HttpContext;
        var routeData = httpContext?.GetRouteData();
        var controllerName = routeData?.Values["controller"]?.ToString() ?? string.Empty;
        var areaName = routeData?.Values["area"]?.ToString() ?? string.Empty;

        HttpRequest req = httpContext?.Request;
        var url = req != null ? $"{req.Scheme}://{req.Host}{req.Path}{req.QueryString}" : null;
        var clientIpAddress = httpContext?.Connection.RemoteIpAddress.ToString();
        var user = httpContext?.User.Identity?.Name;

        var controllerNameProperty = propertyFactory.CreateProperty("ControllerName", controllerName);
        var areaNameProperty = propertyFactory.CreateProperty("AreaName", areaName);
        var urlProperty = propertyFactory.CreateProperty("Url", url);
        var clientIpAddressProperty = propertyFactory.CreateProperty("Ip", clientIpAddress);
        var userProperty = propertyFactory.CreateProperty("User", user);

        logEvent.AddOrUpdateProperty(controllerNameProperty);
        logEvent.AddOrUpdateProperty(areaNameProperty);
        logEvent.AddOrUpdateProperty(urlProperty);
        logEvent.AddOrUpdateProperty(clientIpAddressProperty);
        logEvent.AddOrUpdateProperty(userProperty);
    }
}


