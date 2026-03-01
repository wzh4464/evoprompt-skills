---
name: dataset-management
description: Load, sample, and manage vulnerability detection datasets in EvoPrompt - covers Primevul, SVEN, Benchmark formats, balanced sampling, and contrastive learning data preparation
---

# Dataset Management

## Dataset Classes (`src/evoprompt/data/dataset.py`)

### Quick Start

```python
from evoprompt.data.dataset import create_dataset

# Factory function (auto-detects format)
dataset = create_dataset("primevul", "data/primevul/dev.jsonl", split="dev")
dataset = create_dataset("sven", "data/sven/dev.txt", split="dev")
dataset = create_dataset("benchmark", "data/benchmark/annotated.json", split="dev")

samples = dataset.get_samples(n=100)  # first 100 samples, or None for all
```

### Sample Object

```python
sample.input_text   # source code string
sample.target       # "0" (benign) or "1" (vulnerable)
sample.metadata     # dict with: idx, project, commit_id, cwe, cve, lang, file_name, ...
```

## Supported Formats

### Primevul (JSONL)

```jsonl
{"func": "void foo() {...}", "target": 1, "project": "linux", "cwe": ["CWE-119"], "file_name": "net/core/skbuff.c"}
```

- Auto-detects `_fixed` variants (e.g. `dev_fixed.jsonl` preferred over `dev.jsonl`)
- Language detection: filename extension first, code heuristics as fallback
- Companion metadata: if `dev.txt` exists with a matching `dev_sample.jsonl`, metadata is merged

### Primevul (Tab-separated)

```
<code>\t<0|1>
```

### SVEN (Tab-separated)

Same tab format, 9 CWE types.

### Benchmark (JSON)

```json
[{"code": "...", "gt": [{"category": "Memory", "cwe_id": 119, "line": 42}], "lang": "c"}]
```

Ground truth includes per-line vulnerability annotations.

## Data Preparation

```python
from evoprompt.data.dataset import prepare_primevul_data

# Convert JSONL -> tab-separated for EvoPrompt format
dev_path, test_path = prepare_primevul_data(
    primevul_dir="data/primevul/",
    output_dir="data/primevul_prepared/"
)
```

## Balanced Sampling (`src/evoprompt/data/sampler.py`)

For handling imbalanced datasets (vulnerability data is typically skewed):

```python
from evoprompt.data.sampler import BalancedSampler

sampler = BalancedSampler(dataset)
balanced = sampler.sample(n=200)  # equal positive/negative samples
```

### Contrastive Sampling

For contrastive learning (SCALE-style triplets):

```python
from evoprompt.data.sampler import ContrastiveSampler

sampler = ContrastiveSampler(dataset)
triplets = sampler.sample_triplets(n=50)
# Each triplet: (target_code, other_vuln_code, benign_code)
```

### Hierarchical Sampling

CWE-category-aware sampling:

```python
from evoprompt.data.sampler import HierarchicalSampler

sampler = HierarchicalSampler(dataset)
stratified = sampler.sample(n=200)  # balanced across CWE categories
```

## Language Detection

Built into `PrimevulDataset`:

1. **Filename-based**: `.c` -> C, `.cpp` -> C++, `.java` -> Java, `.py` -> Python, etc.
2. **Code heuristic fallback**: Scans first 1000 chars for language-specific indicators (`#include`, `public class`, `def `, etc.)

```python
lang = PrimevulDataset._detect_language_from_filename("net/core/skbuff.c")  # -> "c"
lang = PrimevulDataset._detect_language_from_code(code_string)               # -> "cpp"
```
