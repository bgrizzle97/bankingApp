using System.Net;
using System.Text.Json;
using Microsoft.AspNetCore.Http;
using Serilog;

namespace BankingApp.API.Middleware;

public static class GlobalExceptionHandlerMiddleware
{
    public static IApplicationBuilder UseGlobalExceptionHandler(this IApplicationBuilder app)
    {
        return app.Use(async (context, next) =>
        {
            try
            {
                await next();
            }
            catch (Exception ex)
            {
                await HandleExceptionAsync(context, ex);
            }
        });
    }

    private static async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        context.Response.ContentType = "application/json";
        
        var response = new
        {
            error = new
            {
                message = "An error occurred while processing your request.",
                type = "InternalServerError"
            }
        };

        switch (exception)
        {
            case UnauthorizedAccessException:
                context.Response.StatusCode = (int)HttpStatusCode.Unauthorized;
                response = new
                {
                    error = new
                    {
                        message = "Access denied.",
                        type = "Unauthorized"
                    }
                };
                break;

            case ArgumentException:
                context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
                response = new
                {
                    error = new
                    {
                        message = "Invalid request parameters.",
                        type = "BadRequest"
                    }
                };
                break;

            case InvalidOperationException:
                context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
                response = new
                {
                    error = new
                    {
                        message = "Invalid operation.",
                        type = "BadRequest"
                    }
                };
                break;

            default:
                context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
                
                // Log the full exception details
                Log.Error(exception, "Unhandled exception occurred");
                
                // In development, include more details
                if (context.RequestServices.GetService<IWebHostEnvironment>()?.EnvironmentName == "Development")
                {
                    response = new
                    {
                        error = new
                        {
                            message = exception.Message,
                            type = exception.GetType().Name,
                            stackTrace = exception.StackTrace
                        }
                    };
                }
                break;
        }

        var jsonResponse = JsonSerializer.Serialize(response, new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        });

        await context.Response.WriteAsync(jsonResponse);
    }
} 