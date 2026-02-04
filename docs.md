# Chezmoi Dotfiles Documentation

## Directory Structure

```
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl              # Config template (prompts for isWork, email, etc.)
├── .chezmoidata/packages.toml      # Package lists for brew/apt
├── .chezmoiexternal.toml           # External git repos (kickstart.nvim)
├── .chezmoiignore                  # Files to skip based on OS/conditions
├── bootstrap.sh                    # Initial bootstrap script
├── dot_zshrc.tmpl                  # ~/.zshrc
├── dot_gitconfig.tmpl              # ~/.gitconfig
├── dot_gitignore_global            # ~/.gitignore_global
├── dot_nvimrc                      # ~/.nvimrc (sources .vimrc)
├── dot_vimrc                       # ~/.vimrc (basic vim settings)
├── dot_config/
│   ├── starship.toml.tmpl          # Starship prompt config
│   ├── symlink_nvim.tmpl           # Symlink ~/.config/nvim → ~/.kickstart.nvim
│   └── zsh/
│       ├── aliases.zsh.tmpl        # Shell aliases
│       ├── git.zsh                 # Git helper functions
│       └── tools.zsh.tmpl          # Tool integrations (fnm, fzf, mcfly, etc.)
├── bin/
│   └── executable_killport         # Kill process on port
├── encrypted_*.age                 # Encrypted work configs and secrets
├── run_before_bootstrap_darwin.sh  # Install Homebrew (macOS)
├── run_before_bootstrap_linux.sh   # Install apt prereqs + Linuxbrew
├── run_onchange_install-packages.sh.tmpl   # Install brew/apt packages
├── run_onchange_after_install-extras_linux.sh  # Linux-specific extras (tag)
├── run_once_defaults_darwin.sh     # macOS defaults (key repeat, etc.)
└── run_once_after_post-install.sh.tmpl     # git-lfs, nvim plugins
```

## Naming Conventions

| Prefix/Suffix | Meaning |
|---------------|---------|
| `dot_` | Becomes `.` (dot_zshrc → .zshrc) |
| `executable_` | chmod +x |
| `private_` | chmod 600 |
| `symlink_` | Creates a symlink |
| `encrypted_` | Decrypted on apply (needs age key) |
| `run_before_` | Script runs before files are copied |
| `run_once_` | Script runs once per machine |
| `run_onchange_` | Script runs when its content changes |
| `run_once_after_` | Runs after other run_once scripts |
| `_darwin` | Only applies on macOS |
| `_linux` | Only applies on Linux |
| `.tmpl` | Template - processed with Go text/template |

## Templating

Templates use Go's `text/template` syntax with access to:

```
{{ .chezmoi.os }}           # "darwin" or "linux"
{{ .chezmoi.arch }}         # "arm64" or "amd64"
{{ .chezmoi.hostname }}     # machine hostname
{{ .isWork }}               # Custom variable from config
{{ .email }}                # Custom variable from config
```

**Example from `dot_gitconfig.tmpl`:**

```
{{- if .isWork -}}
##### BEGIN METATRON AUTOCONFIG
[include]
    path = ~/.gitconfig-proxy
##### END METATRON AUTOCONFIG
{{ end }}

[user]
    name = {{ .name }}
    email = {{ .email }}

{{- if eq .chezmoi.os "darwin" }}
[credential]
    helper = osxkeychain
{{- end }}

{{- if .isWork }}
[include]
    path = ~/.gitconfig_work
{{- end }}
```

## OS Conditionals

Three ways to handle OS-specific config:

**1. In templates (inline):**

```
{{- if eq .chezmoi.os "darwin" }}
[credential]
    helper = osxkeychain
{{- end }}
```

**2. In `.chezmoiignore` (skip entire files):**

```
{{- if ne .chezmoi.os "darwin" }}
Library/**
{{- end }}

{{- if not .isWork }}
.config/zsh/work.zsh
{{- end }}
```

**3. Separate files with OS suffix:**

```
run_before_bootstrap_darwin.sh   # macOS only
run_before_bootstrap_linux.sh    # Linux only
run_once_defaults_darwin.sh      # macOS only
```

## Bootstrapping a New Machine

```bash
# One-liner (prompts for age key, installs Homebrew, applies dotfiles)
curl -fsSL https://raw.githubusercontent.com/christopherthielen/dotfiles/main/bootstrap.sh -o bootstrap.sh && bash bootstrap.sh
```

**What bootstrap.sh does:**
1. Prompts for your age encryption key (for secrets)
2. Downloads chezmoi standalone binary
3. Runs `chezmoi init --apply` which:
   - Installs Homebrew via `run_before_bootstrap_{os}.sh`
   - Prompts for work/personal, email, name
   - Applies all dotfiles and runs install scripts

**Manual workflow (if already bootstrapped):**
```bash
chezmoi update    # Pull latest + apply
chezmoi diff      # Preview changes
chezmoi apply     # Apply changes
```

## Package Management

Packages are defined in `.chezmoidata/packages.toml`:

```toml
[brew.common]
formulae = ["autojump", "bat", "fzf", "neovim", ...]

[darwin.brew]
formulae = ["mas", "coreutils", ...]
casks = ["ghostty", "docker", "raycast", ...]

[darwin.mas]
apps = [{ id = "1352778147", name = "Bitwarden" }, ...]

[linux.apt]
packages = ["build-essential", "zsh", ...]

[linux.brew]
formulae = ["fx", "go", ...]
```

The `run_onchange_install-packages.sh.tmpl` script reads from this data and installs packages. Adding a package to the toml file triggers a re-run on next `chezmoi apply`.

**Key behaviors:**
- `run_before_` - Runs before files are copied (used for Homebrew install)
- `run_once_` - Runs once ever (tracked by filename hash)
- `run_onchange_` - Runs when file content changes (add a package → re-runs)

**To update packages:** Edit `.chezmoidata/packages.toml`, then `chezmoi apply`.

**For ad-hoc updates:** Just run `brew upgrade` directly - chezmoi doesn't fight you.

## External Dependencies

The `.chezmoiexternal.toml` manages git repos and archives:

```toml
[".kickstart.nvim"]
    type = "git-repo"
    url = "https://github.com/christopherthielen/kickstart.nvim.git"
    refreshPeriod = "168h"   # Re-pull weekly
```

These are cloned/updated automatically on `chezmoi apply`.

## Zsh Plugin Management

Zsh plugins are managed by **zinit** (not oh-my-zsh). Zinit auto-installs on first shell launch.

**Key features:**
- Turbo mode: plugins load asynchronously for fast startup
- OMZ compatibility: loads OMZ libraries and plugins as snippets
- Auto-updates: `zinit update` updates all plugins

**Plugins loaded:**
- OMZ libraries: completion, directories, history, key-bindings
- OMZ plugins: git, docker, sudo, node, npm, yarn
- Third-party: zsh-vi-mode, zsh-autosuggestions, zsh-syntax-highlighting

**Tool integrations (in `tools.zsh.tmpl`):**
- fnm (Node version manager)
- fzf (fuzzy finder - Ctrl-T for files, Alt-C for cd)
- mcfly (history search - Ctrl-R)
- starship (prompt)
- autojump (directory jumping - `j <dir>`)
- tag-ag (jump-to-line aliases for ag)

## Secrets Management

This setup uses `age` encryption.

**File locations:**

```
~/.config/chezmoi/key.txt          # Your private key (NEVER commit this)
~/.local/share/chezmoi/encrypted_*.age  # Encrypted files (safe to commit)
```

**Encrypted files in this repo:**
- `encrypted_private_dot_npmrc.age` - npm auth tokens
- `encrypted_dot_gitconfig_work.tmpl.age` - Work git config
- `encrypted_dot_config/zsh/work.zsh.tmpl.age` - Work shell config
- `encrypted_run_once_install-work-tools.sh.tmpl.age` - Work tools installer
- `bin/encrypted_executable_*.age` - Work utility scripts

**How it works:**

1. **Encrypt a secret:**

   ```bash
   chezmoi add --encrypt ~/.npmrc
   # Creates encrypted_dot_npmrc.age in source
   ```

2. **The encrypted file** looks like random bytes - safe to publish:

   ```
   -----BEGIN AGE ENCRYPTED FILE-----
   YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSBCbGtqZ2...
   -----END AGE ENCRYPTED FILE-----
   ```

3. **On `chezmoi apply`**, it decrypts using your key and writes `~/.npmrc`

4. **On a new machine**, `bootstrap.sh` prompts for your age key automatically.

**Your age key** (in `~/.config/chezmoi/key.txt`):
- Generated once, reused on all your machines
- Store it securely (Bitwarden, 1Password, etc.)
- **Never commit it to git**

## Publishing to GitHub

**What to commit** (safe):

```
~/.local/share/chezmoi/           # Your entire source state
├── encrypted_*.age               # Encrypted secrets ✓
├── *.tmpl                        # Templates ✓
├── .chezmoi*.toml                # Config templates ✓
└── everything else               # ✓
```

**What NOT to commit:**

```
~/.config/chezmoi/key.txt         # Your age private key ✗
```

**To publish:**

```bash
cd ~/.local/share/chezmoi
git init
git add .
git commit -m "Initial chezmoi dotfiles"
git remote add origin git@github.com:yourusername/dotfiles.git
git push -u origin main
```

The encrypted files are safe because only someone with your `key.txt` can decrypt them.

## Daily Workflow

| Task | Command |
|------|---------|
| See what changed | `chezmoi diff` |
| Apply changes | `chezmoi apply` |
| Edit a managed file | `chezmoi edit ~/.zshrc` (edits source, then apply) |
| Add a new file | `chezmoi add ~/.newfile` |
| Add encrypted file | `chezmoi add --encrypt ~/.secret` |
| Update from git | `chezmoi update` (git pull + apply) |
| Re-run install scripts | `chezmoi apply --force` |
