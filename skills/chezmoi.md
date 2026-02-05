# Chezmoi Knowledge Base

This skill file captures patterns, gotchas, and architecture decisions for this dotfiles setup.

## Architecture: Multi-Source Setup

This setup uses **two chezmoi sources** - personal (public) and work (internal):

```
~/.dotfiles/personal/ → ~/.local/share/chezmoi/     (public GitHub)
~/.dotfiles/work/     → wherever work repo cloned   (internal GitHub)
```

### Key Design Decisions

1. **Personal works standalone** - No dependency on work repo
2. **Work is additive** - Supplements, never replaces personal files
3. **Conditional entry points** - Personal files include/source work files:
   - `.gitconfig`: `[include] path = ~/.gitconfig_work`
   - `.zshrc`: sources `~/.config/zsh/*.zsh` (picks up `work.zsh`)
4. **Separate chezmoi configs** - Each repo has its own `.chezmoi.toml.tmpl`
5. **Shared AGE key** - Both repos use `~/.config/chezmoi/key.txt`

### Chezmoi Wrapper Function

Work repo provides a `chezmoi` shell function that applies both sources:

```zsh
chezmoi() {
    command chezmoi "$@"
    local cmd="$1"
    if [[ -d ~/.dotfiles/work && "$cmd" =~ ^(apply|diff|status|update)$ ]]; then
        command chezmoi --source ~/.dotfiles/work --config ~/.dotfiles/work/.chezmoi.toml "$@"
    fi
}
```

**Why a wrapper instead of native multi-source?**
- Chezmoi officially doesn't support multiple sources (by design)
- Alternatives considered: git submodules, chezmoi externals, include directives
- Wrapper is simplest and most maintainable
- See: https://www.chezmoi.io/user-guide/frequently-asked-questions/design/#can-chezmoi-support-multiple-sources-or-multiple-source-states

### Work-Only Operations

```bash
chezmoi-work add <file>
chezmoi-work edit <file>
chezmoi-work diff
```

## File Naming Conventions

| Prefix/Suffix | Meaning | Notes |
|---------------|---------|-------|
| `dot_` | Target starts with `.` | `dot_zshrc` → `.zshrc` |
| `private_` | chmod 600 | For sensitive but not encrypted files |
| `executable_` | chmod +x | |
| `symlink_` | Creates symlink | Contents = target path |
| `encrypted_` | AGE encrypted | Needs key to decrypt |
| `.tmpl` | Go template | Processed with template data |
| `_darwin` / `_linux` | OS filter | Only applies on that OS |

### Script Prefixes (in `.chezmoiscripts/`)

| Prefix | When it runs | Tracked by |
|--------|--------------|------------|
| `run_before_` | Before file apply | - |
| `run_after_` | After every apply | - |
| `run_once_` | Once per machine | Filename hash |
| `run_onchange_` | When content changes | Content hash |

**Combining prefixes:** `run_once_before_`, `run_once_after_`, `run_onchange_after_`

### Critical Gotchas

1. **`encrypted_` prefix on directories doesn't work**
   - Wrong: `encrypted_dot_config/zsh/work.zsh.tmpl.age`
   - Right: `dot_config/zsh/encrypted_work.zsh.tmpl.age`

2. **Scripts in wrong location get copied as files**
   - Scripts MUST be in `.chezmoiscripts/` directory
   - Root-level `run_*.sh` files get copied to `~/run_*.sh`

3. **`encrypted_` prefix doesn't apply to scripts**
   - Wrong: `.chezmoiscripts/encrypted_run_once_foo.sh.tmpl.age`
   - Right: `.chezmoiscripts/run_once_foo.sh.tmpl.age` (`.age` suffix is enough)

4. **Template data is per-source**
   - Each chezmoi source has its own `.chezmoi.toml`
   - Work repo sets `isWork = true` in its own config
   - Personal repo detects `isWork` via hostname/metatron

## Encryption

### AGE Encryption Setup

```
~/.config/chezmoi/key.txt           # Private key (NEVER commit)
<source>/encrypted_*.age            # Encrypted files (safe to commit)
```

### When to Encrypt

- **Encrypt:** API tokens, credentials, private keys
- **Don't encrypt (use work repo instead):** Internal DNS names, tool configs, non-secret work references

### Commands

```bash
# Add encrypted file
chezmoi add --encrypt ~/.npmrc

# Edit encrypted file
chezmoi edit ~/.npmrc

# Decrypt to stdout
chezmoi decrypt <source-path>

# View encrypted file contents
chezmoi cat ~/.npmrc
```

## Common Operations

### Debugging

```bash
# See what chezmoi would do
chezmoi diff

# Check template rendering
chezmoi execute-template < dot_file.tmpl

# See target path for source file
chezmoi target-path dot_zshrc.tmpl

# See source path for target file
chezmoi source-path ~/.zshrc

# List all managed files
chezmoi managed

# Check for issues
chezmoi doctor
chezmoi verify
```

### Handling `chezmoi diff` Clutter

**Problem:** `run_` scripts showing in diff
**Solution:** Use `run_once_` prefix if script should only run once

**Problem:** External repo (kickstart.nvim) has local changes
**Solution:** Add cleanup to build step, e.g., `make install && git checkout .`

### Re-running `run_once_` Scripts

```bash
# Clear state for a specific script
chezmoi state delete-bucket --bucket=scriptState

# Or delete specific script state
chezmoi state dump | jq  # Find the key
chezmoi state delete --key=<key>
```

## Template Variables

```go
{{ .chezmoi.os }}           // "darwin" or "linux"
{{ .chezmoi.arch }}         // "arm64" or "amd64"
{{ .chezmoi.hostname }}     // machine hostname
{{ .chezmoi.sourceDir }}    // path to chezmoi source
{{ .isWork }}               // custom: is this a work machine?
{{ .email }}                // custom: user email
{{ .name }}                 // custom: user name
```

### Conditional Patterns

```go
{{- if eq .chezmoi.os "darwin" }}
# macOS only
{{- end }}

{{- if .isWork }}
# Work machine only
{{- end }}

{{- if and .isWork (eq .chezmoi.os "linux") }}
# Work Linux only
{{- end }}
```

## External Dependencies

`.chezmoiexternal.toml` manages git repos:

```toml
[".kickstart.nvim"]
    type = "git-repo"
    url = "https://github.com/user/kickstart.nvim.git"
    refreshPeriod = "168h"  # Weekly
```

**Note:** External repos are read-only from chezmoi's perspective. Local changes may cause issues.

## Symlinks via Chezmoi

Create `symlink_<name>.tmpl` with target path as contents:

```
# dot_dotfiles/symlink_personal.tmpl
{{ .chezmoi.sourceDir }}
```

Creates: `~/.dotfiles/personal` → `~/.local/share/chezmoi`

## References

### Official Documentation
- User Guide: https://www.chezmoi.io/user-guide/
- Reference: https://www.chezmoi.io/reference/
- FAQ: https://www.chezmoi.io/user-guide/frequently-asked-questions/

### Key FAQ Entries
- Multiple sources: https://www.chezmoi.io/user-guide/frequently-asked-questions/design/#can-chezmoi-support-multiple-sources-or-multiple-source-states
- Encryption: https://www.chezmoi.io/user-guide/encryption/
- Templates: https://www.chezmoi.io/user-guide/templating/

### GitHub
- Issues: https://github.com/twpayne/chezmoi/issues
- Discussions: https://github.com/twpayne/chezmoi/discussions

### Useful Searches
- Multi-source setups: `site:github.com/twpayne/chezmoi "multiple sources"`
- Work/personal split: `site:github.com/twpayne/chezmoi work personal`
- Encryption issues: `site:github.com/twpayne/chezmoi encrypted_ .age`

## This Repository's Structure

```
~/.local/share/chezmoi/           # Personal (public)
├── .chezmoi.toml.tmpl            # Config with isWork detection
├── .chezmoidata/packages.toml    # Brew/apt packages
├── .chezmoiexternal.toml         # External repos (kickstart.nvim)
├── .chezmoiscripts/              # Setup scripts
├── dot_config/zsh/               # Zsh config (sources work.zsh if present)
├── dot_dotfiles/                 # Creates ~/.dotfiles/ symlinks
│   └── symlink_personal.tmpl
└── dot_gitconfig.tmpl            # Includes ~/.gitconfig_work if isWork

~/.dotfiles/work/                 # Work (internal)
├── .chezmoi.toml.tmpl            # Config with isWork=true
├── dot_config/zsh/work.zsh.tmpl  # Work aliases + chezmoi wrapper
├── dot_dotfiles/
│   └── symlink_work.tmpl
├── private_dot_gitconfig_work.tmpl
├── bin/                          # Work scripts
├── .chezmoiscripts/              # Work tool installers
├── bootstrap.sh                  # Provisioning entry point
└── bootstrap-interactive.sh      # First-login setup
```
