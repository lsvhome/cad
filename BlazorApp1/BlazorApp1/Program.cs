using BlazorApp1.Components;
using BlazorApp1.Services;

var builder = WebApplication.CreateBuilder(args);

// Configure OpenSCAD/LLM services
var appConfig = new AppConfig
{
    AiProvider = builder.Configuration["ScadModifier:AiProvider"] ?? "openai",
    OpenAiApiKey = builder.Configuration["ScadModifier:OpenAiApiKey"] ?? "",
    OpenAiModel = builder.Configuration["ScadModifier:OpenAiModel"] ?? "gpt-4o-mini",
    OllamaBaseUrl = builder.Configuration["ScadModifier:OllamaBaseUrl"] ?? "http://host.docker.internal:11434",
    OllamaModel = builder.Configuration["ScadModifier:OllamaModel"] ?? "llama3.2",
    InputDir = builder.Configuration["ScadModifier:InputDir"] ?? "/app/input",
    OutputDir = builder.Configuration["ScadModifier:OutputDir"] ?? "/app/output"
};
appConfig.Validate();

builder.Services.AddSingleton(appConfig);
builder.Services.AddHttpClient();
builder.Services.AddScoped<LlmClient>();
builder.Services.AddScoped<OpenScadModifier>();

// Add services to the container.
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
   app.UseExceptionHandler("/Error", createScopeForErrors: true);
   // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
   app.UseHsts();
}
app.UseStatusCodePagesWithReExecute("/not-found", createScopeForStatusCodePages: true);
app.UseHttpsRedirection();

app.UseAntiforgery();

app.MapStaticAssets();
app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.Run();
