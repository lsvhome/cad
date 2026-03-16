using System.Net.Http.Json;
using System.Text.Json.Serialization;

namespace BlazorApp1.Services;

public class LlmClient
{
    private readonly AppConfig _config;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ILogger<LlmClient> _logger;

    public LlmClient(AppConfig config, IHttpClientFactory httpClientFactory, ILogger<LlmClient> logger)
    {
        _config = config;
        _httpClientFactory = httpClientFactory;
        _logger = logger;
    }

    public async Task<string> GetCompletionAsync(string systemPrompt, string userPrompt)
    {
        return _config.AiProvider.ToLowerInvariant() switch
        {
            "openai" => await GetOpenAiCompletionAsync(systemPrompt, userPrompt),
            "ollama" => await GetOllamaCompletionAsync(systemPrompt, userPrompt),
            _ => throw new InvalidOperationException($"Unknown AI provider: {_config.AiProvider}")
        };
    }

    private async Task<string> GetOpenAiCompletionAsync(string systemPrompt, string userPrompt)
    {
        var client = _httpClientFactory.CreateClient("OpenAI");
        client.DefaultRequestHeaders.Authorization =
            new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", _config.OpenAiApiKey);

        var request = new OpenAiRequest
        {
            Model = _config.OpenAiModel,
            Messages =
            [
                new ChatMessage { Role = "system", Content = systemPrompt },
                new ChatMessage { Role = "user", Content = userPrompt }
            ],
            Temperature = 0.7,
            MaxTokens = 2000
        };

        var response = await client.PostAsJsonAsync("https://api.openai.com/v1/chat/completions", request);
        response.EnsureSuccessStatusCode();

        var result = await response.Content.ReadFromJsonAsync<OpenAiResponse>();
        return result?.Choices?.FirstOrDefault()?.Message?.Content
               ?? throw new InvalidOperationException("Empty response from OpenAI.");
    }

    private async Task<string> GetOllamaCompletionAsync(string systemPrompt, string userPrompt)
    {
        var client = _httpClientFactory.CreateClient("Ollama");

        var request = new OllamaRequest
        {
            Model = _config.OllamaModel,
            Messages =
            [
                new ChatMessage { Role = "system", Content = systemPrompt },
                new ChatMessage { Role = "user", Content = userPrompt }
            ],
            Stream = false,
            Options = new OllamaOptions { Temperature = 0.7, NumPredict = 2000 }
        };

        var response = await client.PostAsJsonAsync($"{_config.OllamaBaseUrl}/api/chat", request);
        response.EnsureSuccessStatusCode();

        var result = await response.Content.ReadFromJsonAsync<OllamaResponse>();
        return result?.Message?.Content
               ?? throw new InvalidOperationException("Empty response from Ollama.");
    }

    #region DTOs

    private sealed class ChatMessage
    {
        [JsonPropertyName("role")] public string Role { get; set; } = "";
        [JsonPropertyName("content")] public string Content { get; set; } = "";
    }

    private sealed class OpenAiRequest
    {
        [JsonPropertyName("model")] public string Model { get; set; } = "";
        [JsonPropertyName("messages")] public List<ChatMessage> Messages { get; set; } = [];
        [JsonPropertyName("temperature")] public double Temperature { get; set; }
        [JsonPropertyName("max_tokens")] public int MaxTokens { get; set; }
    }

    private sealed class OpenAiResponse
    {
        [JsonPropertyName("choices")] public List<OpenAiChoice>? Choices { get; set; }
    }

    private sealed class OpenAiChoice
    {
        [JsonPropertyName("message")] public ChatMessage? Message { get; set; }
    }

    private sealed class OllamaRequest
    {
        [JsonPropertyName("model")] public string Model { get; set; } = "";
        [JsonPropertyName("messages")] public List<ChatMessage> Messages { get; set; } = [];
        [JsonPropertyName("stream")] public bool Stream { get; set; }
        [JsonPropertyName("options")] public OllamaOptions Options { get; set; } = new();
    }

    private sealed class OllamaOptions
    {
        [JsonPropertyName("temperature")] public double Temperature { get; set; }
        [JsonPropertyName("num_predict")] public int NumPredict { get; set; }
    }

    private sealed class OllamaResponse
    {
        [JsonPropertyName("message")] public ChatMessage? Message { get; set; }
    }

    #endregion
}
