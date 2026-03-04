# OpenSCAD LLM Modifier

A Docker container that uses LLM (Large Language Models) to modify OpenSCAD files using natural language and render them to STL files.

## Features

- 🤖 **Dual AI Support**: Works with both cloud AI (OpenAI) and local AI (Ollama)
- 📝 **Natural Language Modifications**: Describe changes in plain English
- 🔧 **OpenSCAD Integration**: Automatically renders STL files
- 🐳 **Docker-based**: Easy deployment and reproducible environment

## Prerequisites

- Docker and Docker Compose installed
- For **OpenAI**: An OpenAI API key
- For **Ollama**: Ollama installed and running on your host machine

## Quick Start

### 1. Clone/Setup

Create the project directory and copy all files.

### 2. Configure Environment

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` and configure your AI provider:

**For OpenAI:**
```env
AI_PROVIDER=openai
OPENAI_API_KEY=sk-your-key-here
OPENAI_MODEL=gpt-4o-mini
```

**For Ollama:**
```env
AI_PROVIDER=ollama
OLLAMA_BASE_URL=http://host.docker.internal:11434
OLLAMA_MODEL=llama3.2
```

### 3. Prepare Directories

```bash
mkdir -p input output
```

### 4. Run the Container

**Option A: Create a new SCAD file with modifications**

```bash
export MODIFICATION="Create a cylinder with radius 10 and height 20"
docker-compose up
```

**Option B: Modify an existing SCAD file**

Place your `.scad` file in the `input/` directory, then:

```bash
export INPUT_FILE=mymodel.scad
export MODIFICATION="Make it twice as large and add rounded edges"
docker-compose up
```

**Option C: Just render existing file without modifications**

```bash
export INPUT_FILE=mymodel.scad
docker-compose up
```

### 5. Check Results

The modified SCAD file and rendered STL will be in the `output/` directory.

## Usage Examples

### Example 1: Create from scratch
```bash
export MODIFICATION="Create a parametric box with rounded corners, 50x30x20mm"
docker-compose up
```

### Example 2: Modify existing
```bash
# Place mypart.scad in input/ folder
export INPUT_FILE=mypart.scad
export MODIFICATION="Add mounting holes in each corner, 3mm diameter"
docker-compose up
```

### Example 3: Using Ollama locally
```bash
# Make sure Ollama is running: ollama serve
# Pull a model if needed: ollama pull llama3.2

export AI_PROVIDER=ollama
export MODIFICATION="Create a gear with 20 teeth"
docker-compose up
```

## Project Structure

```
.
├── Dockerfile              # Container definition
├── docker-compose.yml      # Docker Compose configuration
├── requirements.txt        # Python dependencies
├── main.py                # Main application logic
├── llm_client.py          # LLM client (OpenAI/Ollama)
├── config.py              # Configuration management
├── .env.example           # Example environment variables
├── .dockerignore          # Docker ignore file
├── input/                 # Place input .scad files here
└── output/                # Generated files appear here
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `AI_PROVIDER` | AI provider: `openai` or `ollama` | `openai` |
| `OPENAI_API_KEY` | Your OpenAI API key | - |
| `OPENAI_MODEL` | OpenAI model to use | `gpt-4o-mini` |
| `OLLAMA_BASE_URL` | Ollama API endpoint | `http://host.docker.internal:11434` |
| `OLLAMA_MODEL` | Ollama model to use | `llama3.2` |
| `INPUT_FILE` | Input .scad filename (in input/ dir) | None (creates new) |
| `MODIFICATION` | Natural language modification request | None |

## Building the Image

```bash
docker-compose build
```

## Running Without Docker Compose

```bash
# Build
docker build -t openscad-llm .

# Run
docker run -v $(pwd)/input:/app/input \
           -v $(pwd)/output:/app/output \
           -e AI_PROVIDER=openai \
           -e OPENAI_API_KEY=your-key \
           -e MODIFICATION="Create a sphere with radius 15" \
           openscad-llm
```

## Troubleshooting

### Ollama Connection Issues

If using Ollama and getting connection errors:

1. Ensure Ollama is running: `ollama serve`
2. Test Ollama locally: `curl http://localhost:11434/api/tags`
3. Check the `OLLAMA_BASE_URL` uses `host.docker.internal`

### OpenSCAD Rendering Fails

- Check the SCAD syntax in the output file
- Review Docker logs: `docker-compose logs`
- The LLM might have generated invalid OpenSCAD code

### Permission Issues

```bash
# Fix permissions on output directory
sudo chown -R $USER:$USER output/
```

## Advanced Usage

### Custom Python Script

You can modify `main.py` to add custom logic, or create your own script and update the Dockerfile CMD.

### Interactive Mode

For development, run an interactive session:

```bash
docker-compose run --rm openscad-modifier /bin/bash
```

## License

MIT License - Feel free to use and modify.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
