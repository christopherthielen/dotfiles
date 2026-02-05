# Dotfiles Repository

Personal dotfiles managed with [chezmoi](https://chezmoi.io/).

## Skills

- [Chezmoi Knowledge Base](skills/chezmoi.md) - Architecture, patterns, gotchas, and references for this dotfiles setup

## Quick Reference

```bash
chezmoi diff      # Preview changes
chezmoi apply     # Apply changes
chezmoi update    # Pull + apply
chezmoi edit <file>   # Edit managed file
chezmoi add <file>    # Add new file
```

## Repository Structure

- `dot_*` - Dotfiles (applied to home directory)
- `.chezmoiscripts/` - Setup scripts
- `.chezmoidata/` - Template data (packages.toml)
- `skills/` - Knowledge base for AI assistants
