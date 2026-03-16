namespace BlazorApp1.Services;

public class AppConfig
{
    public string AiProvider { get; set; } = "openai";
    public string OpenAiApiKey { get; set; } = "";
    public string OpenAiModel { get; set; } = "gpt-4o-mini";
    public string OllamaBaseUrl { get; set; } = "http://host.docker.internal:11434";
    public string OllamaModel { get; set; } = "llama3.2";
    public string InputDir { get; set; } = "/app/input";
    public string OutputDir { get; set; } = "/app/output";

    public void Validate()
    {
        if (string.Equals(AiProvider, "openai", StringComparison.OrdinalIgnoreCase)
            && string.IsNullOrWhiteSpace(OpenAiApiKey))
        {
            throw new InvalidOperationException("OpenAiApiKey is required when using the OpenAI provider.");
        }

        if (!string.Equals(AiProvider, "openai", StringComparison.OrdinalIgnoreCase)
            && !string.Equals(AiProvider, "ollama", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException($"Invalid AiProvider: {AiProvider}. Must be 'openai' or 'ollama'.");
        }
    }
}
