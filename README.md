# Nvim Configuration

Configured with `lazy.nvim`.

## Plugins

Lua files in `lua/camspiers/plugins` are sourced automatically by `lazy.nvim`, and are expected to export a lazy spec table.

## Startup

Lua files in `lua/camspiers/startup` are sourced automatically. Make sure these files can be sourced in any order.

## Share

This directory is where manually sourced reusable lua should be placed.

## Ollama

There is a custom ollama model provided that should be built and given the name `code`.

Assuming you have ollama installed:

```bash
cd ollama-models
make
```
