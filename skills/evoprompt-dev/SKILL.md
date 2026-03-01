---
name: evoprompt-dev
description: EvoPrompt project development guide - architecture, conventions, and common commands for the evolutionary prompt optimization framework targeting vulnerability detection
---

# EvoPrompt Development Guide

## Project Overview

EvoPrompt is an evolutionary prompt optimization framework for vulnerability detection. It uses evolutionary algorithms (GA, DE, Coevolution) to automatically optimize prompts for security code analysis.

## Key Conventions

- **All Python commands must use `uv run`**: e.g. `uv run python script.py`
- **No excessive try/except**: Let exceptions propagate during development for easier debugging. Only add error handling where graceful degradation or user-facing messages are needed.
- **src layout**: All package code lives under `src/evoprompt/`
- **API config via .env**: Environment variables `API_BASE_URL`, `API_KEY`, `BACKUP_API_BASE_URL`, `MODEL_NAME`

## Project Structure

```
src/evoprompt/
├── core/              # EvolutionEngine, PromptTracker, Evaluator protocol
├── algorithms/        # GA, DE, Coevolution (base: Individual, Population, EvolutionAlgorithm)
├── llm/               # LLM clients: SVENLLMClient, OpenAICompatibleClient, LocalLLMClient
├── data/              # Dataset classes: PrimevulDataset, SVENDataset, BenchmarkDataset
├── evaluators/        # CWECategoryEvaluator, DetectionStatistics
├── detectors/         # ThreeLayerDetector, RAGThreeLayerDetector, HierarchicalDetector
├── agents/            # RouterAgent, DetectorAgent
├── multiagent/        # MultiAgentCoordinator, CoordinationStrategy
├── rag/               # KnowledgeBase, CodeSimilarityRetriever
├── prompts/           # HierarchicalPrompt, ThreeLayerPromptSet, CWE mappings
├── analysis/          # BanditAnalyzer, AnalysisResult
├── training/          # ContrastivePromptTrainer
├── workflows/         # End-to-end detection workflows
├── utils/             # CostTracker, helpers
├── metrics/           # Metric implementations
├── optimization/      # Optimization utilities
└── cli.py             # CLI entry point
```

## Common Commands

```bash
# Run experiments
uv run python demo_primevul_1percent.py
uv run python run_primevul_1percent.py

# Tests
uv run pytest tests/

# Lint & type check
uv run ruff check src/
uv run mypy src/

# Format
uv run black src/evoprompt tests
uv run isort src/evoprompt tests
```

## Output Location

Experiment results go to `outputs/<experiment>/<timestamp>/`:
- `experiment_summary.json` - Summary
- `prompt_evolution.jsonl` - Full evolution record
- `best_prompts.txt` - Best prompt history
- `llm_call_history.json` - LLM call log

## Architecture Patterns

- **Factory functions**: `create_llm_client()`, `create_dataset()` for object creation
- **Abstract base classes**: `LLMClient`, `Dataset`, `EvolutionAlgorithm` define interfaces
- **Protocol-based evaluator**: `Evaluator` uses Python Protocol for duck typing
- **SVEN compatibility**: `sven_llm_init()` / `sven_llm_query()` wrapper functions maintain API parity with the SVEN submodule
