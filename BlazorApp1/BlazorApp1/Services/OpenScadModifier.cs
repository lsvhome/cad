using System.Diagnostics;

namespace BlazorApp1.Services;

public class OpenScadModifier
{
    private readonly AppConfig _config;
    private readonly LlmClient _llmClient;
    private readonly ILogger<OpenScadModifier> _logger;

    public OpenScadModifier(AppConfig config, LlmClient llmClient, ILogger<OpenScadModifier> logger)
    {
        _config = config;
        _llmClient = llmClient;
        _logger = logger;

        Directory.CreateDirectory(_config.InputDir);
        Directory.CreateDirectory(_config.OutputDir);
    }

    public (string? Content, string? BaseName) ReadOrCreateScad(string? filename)
    {
        if (!string.IsNullOrWhiteSpace(filename))
        {
            var scadPath = Path.Combine(_config.InputDir, filename);
            if (File.Exists(scadPath) && Path.GetExtension(scadPath).Equals(".scad", StringComparison.OrdinalIgnoreCase))
            {
                _logger.LogInformation("Reading existing file: {Path}", scadPath);
                return (File.ReadAllText(scadPath), Path.GetFileNameWithoutExtension(scadPath));
            }

            _logger.LogWarning("File not found: {Path}", scadPath);
            return (null, null);
        }

        _logger.LogInformation("No file provided, creating new SCAD file");
        return (CreateDefaultScad(), "generated");
    }

    public (string? Content, string? BaseName) ReadUploadedScad(Stream fileStream, string fileName)
    {
        var destPath = Path.Combine(_config.InputDir, fileName);
        using (var fs = new FileStream(destPath, FileMode.Create))
        {
            fileStream.CopyTo(fs);
        }

        _logger.LogInformation("Uploaded file saved: {Path}", destPath);
        return (File.ReadAllText(destPath), Path.GetFileNameWithoutExtension(destPath));
    }

    public static string CreateDefaultScad()
    {
        return """
               // Default OpenSCAD file
               // A simple cube
               cube([10, 10, 10], center=true);
               """;
    }

    public async Task<string> ApplyModificationsAsync(string scadContent, string modificationPrompt)
    {
        const string systemPrompt = """
            You are an expert OpenSCAD developer.
            When given OpenSCAD code and a modification request, respond with ONLY the modified OpenSCAD code.
            Do not include explanations, markdown formatting, or code blocks - just the raw .scad code.
            Ensure the code is valid OpenSCAD syntax.
            """;

        var userPrompt = $"""
            Current OpenSCAD code:
            ```
            {scadContent}
            ```

            Modification request: {modificationPrompt}

            Provide the complete modified OpenSCAD code:
            """;

        _logger.LogInformation("Sending request to LLM...");
        var modified = await _llmClient.GetCompletionAsync(systemPrompt, userPrompt);

        // Clean up response (remove markdown if present)
        modified = modified.Trim();
        if (modified.StartsWith("```"))
        {
            var lines = modified.Split('\n');
            if (lines.Length > 2)
                modified = string.Join('\n', lines[1..^1]);

            modified = modified.Replace("```openscad", "").Replace("```", "").Trim();
        }

        return modified;
    }

    public string SaveScad(string content, string filename)
    {
        var outputPath = Path.Combine(_config.OutputDir, $"{filename}.scad");
        _logger.LogInformation("Saving modified file to: {Path}", outputPath);
        File.WriteAllText(outputPath, content);
        return outputPath;
    }

    public async Task<string?> RenderStlAsync(string scadPath, string outputName)
    {
        var stlPath = Path.Combine(_config.OutputDir, $"{outputName}.stl");
        _logger.LogInformation("Rendering STL: {Path}", stlPath);

        try
        {
            using var process = new Process();
            process.StartInfo = new ProcessStartInfo
            {
                FileName = "xvfb-run",
                ArgumentList = { "-a", "openscad", "-o", stlPath, scadPath },
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };

            process.Start();

            using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(60));
            await process.WaitForExitAsync(cts.Token);

            if (process.ExitCode == 0)
            {
                _logger.LogInformation("STL rendered successfully: {Path}", stlPath);
                return stlPath;
            }

            var stderr = await process.StandardError.ReadToEndAsync();
            _logger.LogError("OpenSCAD error: {Error}", stderr);
            return null;
        }
        catch (OperationCanceledException)
        {
            _logger.LogError("Rendering timed out");
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error rendering STL");
            return null;
        }
    }

    public async Task<ProcessResult> ProcessAsync(string? inputFile, string? modification,
        Stream? uploadStream = null, string? uploadFileName = null)
    {
        var result = new ProcessResult();

        // Step 1: Read, upload, or create SCAD file
        string? scadContent;
        string? baseName;

        if (uploadStream is not null && !string.IsNullOrEmpty(uploadFileName))
        {
            (scadContent, baseName) = ReadUploadedScad(uploadStream, uploadFileName);
        }
        else
        {
            (scadContent, baseName) = ReadOrCreateScad(inputFile);
        }

        if (scadContent is null)
        {
            result.ErrorMessage = "Could not read input file.";
            return result;
        }

        result.OriginalScad = scadContent;

        // Step 2: Apply modifications if requested
        if (!string.IsNullOrWhiteSpace(modification))
        {
            _logger.LogInformation("Applying modification: {Mod}", modification);
            scadContent = await ApplyModificationsAsync(scadContent, modification);
        }

        result.ModifiedScad = scadContent;

        // Step 3: Save modified SCAD
        var outputName = !string.IsNullOrWhiteSpace(modification) ? $"{baseName}_modified" : baseName!;
        var scadPath = SaveScad(scadContent, outputName);
        result.ScadFilePath = scadPath;

        // Step 4: Render STL
        var stlPath = await RenderStlAsync(scadPath, outputName);
        result.StlFilePath = stlPath;
        result.Success = stlPath is not null;

        return result;
    }
}

public class ProcessResult
{
    public bool Success { get; set; }
    public string? ErrorMessage { get; set; }
    public string? OriginalScad { get; set; }
    public string? ModifiedScad { get; set; }
    public string? ScadFilePath { get; set; }
    public string? StlFilePath { get; set; }
}
