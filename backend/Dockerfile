# High-Security Banking Application Backend Dockerfile
# Phase 1: Foundation & Core Infrastructure

# Multi-stage build for security and optimization
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS base
# Use Alpine Linux for smaller attack surface
USER app
WORKDIR /app
EXPOSE 8080 8443

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
# Install security updates and required packages
RUN apk update && apk upgrade && \
    apk add --no-cache \
    ca-certificates \
    curl \
    && rm -rf /var/cache/apk/*

WORKDIR /src

# Copy project files
COPY ["BankingApp.API/BankingApp.API.csproj", "BankingApp.API/"]
COPY ["BankingApp.Core/BankingApp.Core.csproj", "BankingApp.Core/"]
COPY ["BankingApp.Infrastructure/BankingApp.Infrastructure.csproj", "BankingApp.Infrastructure/"]
COPY ["BankingApp.Application/BankingApp.Application.csproj", "BankingApp.Application/"]

# Restore dependencies
RUN dotnet restore "BankingApp.API/BankingApp.API.csproj"

# Copy source code
COPY . .

# Build the application
WORKDIR "/src/BankingApp.API"
RUN dotnet build "BankingApp.API.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "BankingApp.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM base AS final
# Create non-root user for security
RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

# Install security tools and monitoring
RUN apk add --no-cache \
    curl \
    dumb-init \
    && rm -rf /var/cache/apk/*

# Copy published application
COPY --from=publish /app/publish .

# Set proper permissions
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Use dumb-init as PID 1 for proper signal handling
ENTRYPOINT ["dumb-init", "--"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Default command
CMD ["dotnet", "BankingApp.API.dll"] 