---
name: llm-client-setup
description: Configure and use LLM clients in EvoPrompt - covers SVEN-compatible clients, OpenAI-compatible endpoints, ModelScope integration, local models, and API failover
---

# LLM Client Configuration

## Quick Start

```python
from evoprompt.llm.client import create_default_client, sven_llm_init, sven_llm_query

# Option 1: Default client (reads from .env)
client = create_default_client()

# Option 2: SVEN-compatible interface
client = sven_llm_init()
result = sven_llm_query("Analyze this code", client, task=True)
```

## Environment Variables (.env)

```bash
API_BASE_URL=https://api-inference.modelscope.cn/v1/   # Primary API endpoint
API_KEY=your-api-key-here                                # API key
BACKUP_API_BASE_URL=https://newapi.aicohere.org/v1       # Fallback endpoint
MODEL_NAME=Qwen/Qwen3-Coder-480B-A35B-Instruct          # Model identifier

# Optional: separate model for meta-prompt evolution
META_MODEL_NAME=claude-sonnet-4-5-20250929-thinking
META_API_BASE_URL=https://...
META_API_KEY=sk-...
```

The `.env` file is auto-loaded from project root or `src/evoprompt/` parent directories.

## Client Types

### OpenAICompatibleClient (default)

Works with any OpenAI-compatible API: ModelScope, OpenRouter, vLLM, etc.

```python
from evoprompt.llm.client import OpenAICompatibleClient

client = OpenAICompatibleClient(
    api_base="https://api-inference.modelscope.cn/v1/",
    api_key="sk-...",
    model_name="Qwen/Qwen3-Coder-480B-A35B-Instruct",
    max_retries=3,
    retry_delay=1.0
)
```

### SVENLLMClient

Uses raw `requests` instead of the `openai` SDK. Supports automatic failover between primary and backup API.

```python
from evoprompt.llm.client import SVENLLMClient

client = SVENLLMClient(max_concurrency=16)
# Automatically reads API_BASE_URL, API_KEY, BACKUP_API_BASE_URL from env
```

### LocalLLMClient

For local HuggingFace models (lazy-loaded).

```python
from evoprompt.llm.client import LocalLLMClient

client = LocalLLMClient(model_name="codellama/CodeLlama-7b-hf", device="auto")
```

## Factory Function

```python
from evoprompt.llm.client import create_llm_client

# Auto-detect client type from model name
client = create_llm_client("Qwen/Qwen3-Coder-480B-A35B-Instruct")  # -> OpenAICompatibleClient
client = create_llm_client("kimi-k2-code")                          # -> SVENLLMClient
client = create_llm_client("codellama/CodeLlama-7b-hf")             # -> LocalLLMClient
client = create_llm_client()                                         # -> OpenAICompatibleClient (default)
```

## Batch Processing

```python
results = client.batch_generate(
    prompts=["prompt1", "prompt2", ...],
    batch_size=8,          # prompts per batch
    concurrent=True,       # enable thread-pool concurrency
    max_concurrency=16,    # max parallel requests (SVENLLMClient)
    use_async=True,        # use async client if available
    temperature=0.1,
    delay=0.1,             # rate limiting delay (sequential only)
)
```

## Key Features

- **Auto failover**: Primary API fails -> automatically tries backup API
- **Exponential backoff**: Retries with increasing delay on failure
- **Task truncation**: `task=True` returns only the first paragraph of response
- **Paraphrase**: `client.paraphrase("text")` generates semantic-preserving variations
- **Meta-prompt client**: `create_meta_prompt_client()` for prompt evolution with a separate (possibly stronger) model
