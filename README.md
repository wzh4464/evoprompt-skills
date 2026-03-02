# evoprompt-skills

AI coding assistant skills for the [EvoPrompt](https://github.com/wzh4464/evoprompt) evolutionary prompt optimization framework targeting vulnerability detection.

## Skills

| Skill | Description |
|-------|-------------|
| **evoprompt-dev** | Project development guide — architecture, conventions, and common commands |
| **vulnerability-detection** | Hierarchical detection, CWE categorization, RAG-enhanced analysis, multi-agent coordination |
| **evolutionary-optimization** | Genetic algorithms, differential evolution, coevolution, and the evolution engine |
| **llm-client-setup** | SVEN-compatible clients, OpenAI-compatible endpoints, ModelScope integration, API failover |
| **dataset-management** | Primevul, SVEN, Benchmark datasets, balanced sampling, contrastive learning data preparation |

## Installation

### Option 1: Clone + install script

```bash
git clone https://github.com/wzh4464/evoprompt-skills.git
cd evoprompt-skills
bash install.sh
```

By default, skills are installed to `~/.config/opencode/skills/`. Pass a custom path:

```bash
bash install.sh ~/.claude/skills
```

### Option 2: Manual copy

```bash
git clone https://github.com/wzh4464/evoprompt-skills.git
cp -r evoprompt-skills/skills/* ~/.config/opencode/skills/
```

### Option 3: Symlink

```bash
git clone https://github.com/wzh4464/evoprompt-skills.git
for dir in evoprompt-skills/skills/*/; do
  ln -sfn "$(pwd)/$dir" ~/.config/opencode/skills/"$(basename "$dir")"
done
```

## Prerequisites

- [EvoPrompt](https://github.com/wzh4464/evoprompt) repository cloned locally
- Python 3.9+
- [uv](https://github.com/astral-sh/uv) package manager

## Compatibility

These skills use the SKILL.md format and work with:

- [OpenCode](https://github.com/opencode-ai/opencode)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (copy to `~/.claude/skills/`)

## License

MIT
