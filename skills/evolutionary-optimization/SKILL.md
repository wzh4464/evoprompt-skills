---
name: evolutionary-optimization
description: Guide for using evolutionary algorithms to optimize prompts in EvoPrompt - covers genetic algorithms, differential evolution, coevolution, and the evolution engine
---

# Evolutionary Prompt Optimization

## Core Abstractions (`src/evoprompt/algorithms/base.py`)

```python
# Individual = a single prompt with fitness score
Individual(prompt="Analyze this code...", fitness=0.85)

# Population = collection of individuals
Population(individuals=[ind1, ind2, ...])
population.best()   # highest fitness
population.worst()  # lowest fitness
population.sort_by_fitness()

# EvolutionAlgorithm = abstract base
# Required methods: initialize_population, select_parents, crossover, mutate
```

## Available Algorithms

### Genetic Algorithm (`src/evoprompt/algorithms/genetic.py`)

```python
from evoprompt.algorithms.genetic import GeneticAlgorithm

ga = GeneticAlgorithm({
    "population_size": 20,
    "max_generations": 10,
    "mutation_rate": 0.1,
    "selection_method": "tournament",  # or "roulette"
    "tournament_size": 3,
    "crossover_rate": 0.8,
    "elitism": 2,  # preserve top N across generations
})
```

Selection methods:
- **Tournament**: Pick `tournament_size` random individuals, select best
- **Roulette**: Fitness-proportionate selection

### Differential Evolution (`src/evoprompt/algorithms/differential.py`)

```python
from evoprompt.algorithms.differential import DifferentialEvolution

de = DifferentialEvolution({
    "population_size": 20,
    "max_generations": 10,
    "mutation_factor": 0.8,   # F parameter
    "crossover_rate": 0.9,    # CR parameter
    "strategy": "best/1/bin",  # or "rand/1/bin"
})
```

Strategies:
- **best/1/bin**: Uses best individual as base vector (exploitation-focused)
- **rand/1/bin**: Uses random individual as base (exploration-focused)

### Coevolution (`src/evoprompt/algorithms/coevolution.py`)

Multi-population coevolutionary approach where separate populations evolve cooperatively.

## Running Evolution

### Via EvolutionEngine (`src/evoprompt/core/evolution.py`)

```python
from evoprompt.core.evolution import EvolutionEngine
from evoprompt.algorithms.genetic import GeneticAlgorithm
from evoprompt.llm.client import create_default_client

engine = EvolutionEngine(
    algorithm=ga,
    evaluator=my_evaluator,
    llm_client=create_default_client(),
)
result = engine.evolve()
# result contains best prompt, fitness history, generation stats
```

### Via Demo Scripts

```bash
# Quick 1% data demo
uv run python demo_primevul_1percent.py

# Full experiment
uv run python run_primevul_1percent.py
```

## How LLM-Driven Mutation Works

Unlike traditional EA where mutation is random, EvoPrompt uses the LLM itself:

1. **Crossover**: LLM combines two parent prompts into a child prompt
2. **Mutation**: LLM rewrites/paraphrases a prompt to create a variant
3. **Evaluation**: Each prompt is scored by running it against labeled code samples

The LLM's `paraphrase()` method generates semantic-preserving variations:
```python
client.paraphrase("Analyze this code for vulnerabilities")
# -> "Examine the following code snippet to identify security flaws"
```

## Tracking Evolution (`src/evoprompt/core/prompt_tracker.py`)

```python
from evoprompt.core.prompt_tracker import PromptTracker

tracker = PromptTracker(output_dir="outputs/my_experiment")
tracker.record_snapshot(generation=0, population=pop)
tracker.save()  # writes JSONL + TXT summaries
```

## Cost Tracking (`src/evoprompt/utils/cost_tracker.py`)

```python
from evoprompt.utils.cost_tracker import CostTracker

tracker = CostTracker()
tracker.record_llm_call(tokens=150, duration=0.5)
tracker.record_retrieval_call(duration=0.1)
tracker.summary()  # total tokens, total cost, avg latency
```
