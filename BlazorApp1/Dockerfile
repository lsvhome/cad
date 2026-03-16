# --- Build stage ---
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY BlazorApp1/BlazorApp1.csproj BlazorApp1/
RUN dotnet restore BlazorApp1/BlazorApp1.csproj --source https://api.nuget.org/v3/index.json

COPY . .
RUN dotnet publish BlazorApp1/BlazorApp1.csproj -c Release -o /app/publish --no-restore

# --- Runtime stage ---
FROM mcr.microsoft.com/dotnet/aspnet:10.0

# Optional corporate root CA (remove if not needed)
COPY Zscaler_Root_CA.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

# Install OpenSCAD and xvfb for headless STL rendering
RUN apt-get update && apt-get install -y --no-install-recommends \
    openscad \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app/publish .

# Create directories for input/output
RUN mkdir -p /app/input /app/output

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "BlazorApp1.dll"]
