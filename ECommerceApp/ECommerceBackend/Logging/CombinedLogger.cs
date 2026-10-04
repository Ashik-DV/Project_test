using ECommerceBackend.Models;

namespace ECommerceBackend.Logging;

public class CombinedLogger : IApplicationLogger
{
    private readonly DatabaseLogger _databaseLogger;
    private readonly FileLogger _fileLogger;

    public CombinedLogger(
        DatabaseLogger databaseLogger,
        FileLogger fileLogger)
    {
        _databaseLogger = databaseLogger;
        _fileLogger = fileLogger;
    }

    public async Task LogAsync(ApplicationLog log)
    {
        await _databaseLogger.LogAsync(log);

        await _fileLogger.LogAsync(log);
    }
}