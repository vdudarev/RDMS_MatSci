using Serilog.Core;
using Serilog.Events;
using Serilog.Formatting;

namespace InfProject.Enrichers;

public class DynamicFileSink : ILogEventSink
{
    private readonly ITextFormatter _textFormatter;

    public DynamicFileSink(ITextFormatter textFormatter)
    {
        _textFormatter = textFormatter;
    }

    public void Emit(LogEvent logEvent)
    {
        var controllerName = logEvent.Properties.ContainsKey("ControllerName")
            ? logEvent.Properties["ControllerName"].ToString().Trim('"')
            : string.Empty;
        var areaName = logEvent.Properties.ContainsKey("AreaName")
            ? logEvent.Properties["AreaName"].ToString().Trim('"')
            : string.Empty;

        if (!string.IsNullOrEmpty(areaName)) {
            areaName = $"-{areaName}";
        }
        // var logFilePath = Path.Combine("Logs", $"{areaName}-{controllerName}.log");
        var logFilePath = Path.Combine("Logs", $"log{areaName}{DateTime.Now.ToString("yyyyMMdd")}.log");

        using (var streamWriter = new StreamWriter(logFilePath, true))
        {
            _textFormatter.Format(logEvent, streamWriter);
        }
    }
}