using Microsoft.AspNetCore.Http;
using Serilog;
using System.Diagnostics;

namespace BankingApp.API.Middleware;

public static class RequestLoggingMiddleware
{
    public static IApplicationBuilder UseRequestLogging(this IApplicationBuilder app)
    {
        return app.Use(async (context, next) =>
        {
            var stopwatch = Stopwatch.StartNew();
            var originalBodyStream = context.Response.Body;

            using var memoryStream = new MemoryStream();
            context.Response.Body = memoryStream;

            try
            {
                await next();
            }
            finally
            {
                stopwatch.Stop();
                memoryStream.Position = 0;
                await memoryStream.CopyToAsync(originalBodyStream);

                var logData = new
                {
                    Timestamp = DateTime.UtcNow,
                    Method = context.Request.Method,
                    Path = context.Request.Path,
                    QueryString = context.Request.QueryString.ToString(),
                    StatusCode = context.Response.StatusCode,
                    Duration = stopwatch.ElapsedMilliseconds,
                    UserAgent = context.Request.Headers["User-Agent"].ToString(),
                    RemoteIpAddress = context.Connection.RemoteIpAddress?.ToString(),
                    UserId = context.User?.Identity?.Name ?? "anonymous",
                    ContentLength = context.Response.ContentLength ?? 0
                };

                // Log based on status code
                if (context.Response.StatusCode >= 400)
                {
                    Log.Warning("HTTP {Method} {Path} returned {StatusCode} in {Duration}ms", 
                        logData.Method, logData.Path, logData.StatusCode, logData.Duration);
                }
                else
                {
                    Log.Information("HTTP {Method} {Path} returned {StatusCode} in {Duration}ms", 
                        logData.Method, logData.Path, logData.StatusCode, logData.Duration);
                }

                // Log sensitive operations
                if (IsSensitiveOperation(context.Request.Path, context.Request.Method))
                {
                    Log.Warning("Sensitive operation detected: {Method} {Path} by user {UserId}", 
                        logData.Method, logData.Path, logData.UserId);
                }
            }
        });
    }

    private static bool IsSensitiveOperation(PathString path, string method)
    {
        var sensitivePaths = new[]
        {
            "/api/auth/login",
            "/api/auth/logout",
            "/api/auth/register",
            "/api/accounts/transfer",
            "/api/accounts/withdraw",
            "/api/accounts/deposit",
            "/api/users/password",
            "/api/users/mfa"
        };

        var sensitiveMethods = new[] { "POST", "PUT", "DELETE" };

        return sensitivePaths.Any(p => path.StartsWithSegments(p)) && 
               sensitiveMethods.Contains(method.ToUpper());
    }
} 