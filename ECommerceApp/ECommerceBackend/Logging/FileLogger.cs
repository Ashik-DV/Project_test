using System.Text;
using ECommerceBackend.Models;

namespace ECommerceBackend.Logging;

public class FileLogger : IApplicationLogger
{
    private readonly string _logsDirectory;
    private readonly SemaphoreSlim _semaphore = new(1, 1);

    public FileLogger(IWebHostEnvironment environment)
    {
        _logsDirectory = Path.Combine(
            environment.ContentRootPath,
            "Logs");

        Directory.CreateDirectory(_logsDirectory);
    }

    public async Task LogAsync(ApplicationLog log)
    {
        // Create a separate file for each day

        
        var logFileName =
            $"application-{log.RequestStartTime:yyyy-MM-dd}.log";

        var logFilePath = Path.Combine(
            _logsDirectory,
            logFileName);

        var logText = new StringBuilder();

        logText.AppendLine(
            $"[{log.RequestStartTime:yyyy-MM-dd HH:mm:ss}]");

        logText.AppendLine($"Level: {log.Level}");
        logText.AppendLine($"CorrelationId: {log.CorrelationId}");

        logText.AppendLine(
            $"{log.HttpMethod} {log.RequestPath}{log.QueryString}");

        logText.AppendLine($"Status: {log.ResponseStatusCode}");
        logText.AppendLine($"Duration: {log.ExecutionDurationMs}ms");
        logText.AppendLine($"Client IP: {log.ClientIp}");
        logText.AppendLine($"Message: {log.Message}");

        logText.AppendLine(new string('-', 80));
       

        await _semaphore.WaitAsync();
     Console.WriteLine("FILE LOGGER CALLED");
    Console.WriteLine($"File path: {logFilePath}");

        try
        {
            await File.AppendAllTextAsync(
                logFilePath,
                logText.ToString());
                Console.WriteLine("FILE LOG SAVED");
        }
        finally
        {
            _semaphore.Release();
        }
    }
}