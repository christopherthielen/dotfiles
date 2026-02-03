# Dotfiles (chezmoi)

Personal dotfiles managed with [chezmoi](https://chezmoi.io/).

## Quick Start

### New Machine Bootstrap

```bash
# Install chezmoi and apply dotfiles in one command
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME

# Or if chezmoi is already installed
chezmoi init --apply $GITHUB_USERNAME
```

### Manual Setup

```bash
# Install chezmoi
brew install chezmoi  # macOS
# or
sh -c "$(curl -fsLS get.chezmoi.io)"  # Linux

# Initialize and apply
chezmoi init --apply $GITHUB_USERNAME
```

## Common Commands

```bash
# See what changes would be made
chezmoi diff

# Apply changes
chezmoi apply

# Edit a file (opens in $EDITOR, applies on save)
chezmoi edit ~/.zshrc

# Add a new file to be managed
chezmoi add ~/.some-config

# Update from remote and apply
chezmoi update

# Re-run scripts (e.g., after modifying package list)
chezmoi apply --force
```

## Structure

- `.chezmoi.toml.tmpl` - Config template with machine-type prompts
- `.chezmoiexternal.toml` - External dependencies (oh-my-zsh, plugins)
- `dot_*` - Files that become `~/.*`
- `run_once_*` - Scripts that run once per machine
- `run_onchange_*` - Scripts that run when their content changes
- `*.tmpl` - Template files with OS/machine conditionals

## Machine Types

On first init, you'll be prompted:
- **Is this a work machine?** - Enables Netflix-specific configs
- **Email** - Sets git user email

These values are stored in `~/.config/chezmoi/chezmoi.toml`.

## Testing Changes

```bash
# Preview what would happen (safe, no changes made)
chezmoi diff

# Apply to a test directory instead of $HOME
chezmoi apply --destination /tmp/chezmoi-test

# Dry run (shows commands without executing)
chezmoi apply --dry-run --verbose
```
