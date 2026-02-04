# Chezmoi Dotfiles Documentation

## Directory Structure

```
~/.local/share/chezmoi/           # Source state (this becomes your git repo)
├── .chezmoi.toml.tmpl            # Config template (prompts for isWork, email, etc.)
├── .chezmoidata/packages.toml    # Package lists for brew/apt
├── .chezmoiexternal.toml         # External git repos (kickstart.nvim)
├── .chezmoiignore                # Files to skip based on OS/conditions
├── dot_zshrc.tmpl                # ~/.zshrc (dot_ prefix = dotfile)
├── dot_gitconfig.tmpl            # ~/.gitconfig
├── dot_config/                   # ~/.config/
│   ├── starship.toml.tmpl        # Starship prompt config
│   ├── zsh/
│   │   ├── aliases.zsh.tmpl
│   │   ├── git.zsh               # Git helper functions
│   │   └── tools.zsh.tmpl        # Tool integrations (fnm, fzf, mcfly, etc.)
│   └── symlink_nvim.tmpl         # Symlink to ~/.kickstart.nvim
├── bin/
│   └── executable_killport       # executable_ prefix = chmod +x
├── encrypted_*.age               # Encrypted files (work configs, secrets)
├── run_onchange_install-packages.sh.tmpl  # Runs when file content changes
└── run_once_after_post-install.sh.tmpl    # Runs after other scripts
```

## Naming Conventions

| Prefix | Meaning |
|--------|---------|
| `dot_` | Becomes `.` (dot_zshrc → .zshrc) |
| `executable_` | chmod +x |
| `private_` | chmod 600 |
| `symlink_` | Creates a symlink |
| `encrypted_` | Decrypted on apply (needs age key) |
| `run_once_` | Script runs once per machine |
| `run_onchange_` | Script runs when its content changes |
| `run_once_after_` | Runs after other run_once scripts |
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

**3. Separate files with OS suffix:** (not used in this setup, but available)

```
dot_zshrc.tmpl           # All platforms
dot_zshrc_darwin.tmpl    # macOS only
```

## Bootstrapping a New Machine

```bash
# One-liner to bootstrap (downloads chezmoi + applies your dotfiles)
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply yourgithub/dotfiles

# Or step by step:
brew install chezmoi
chezmoi init yourgithub/dotfiles   # Clones to ~/.local/share/chezmoi
chezmoi diff                        # Preview changes
chezmoi apply                       # Apply changes
```

On first `init`, the `.chezmoi.toml.tmpl` prompts for:
- Is this a work machine?
- Email address
- Full name

These values are saved to `~/.config/chezmoi/chezmoi.toml` and used for templating.

## Package Management

Packages are defined in `.chezmoidata/packages.toml` and installed via `run_onchange_` scripts.

```bash
# run_onchange_install-packages.sh.tmpl
# Chezmoi runs this when the CONTENT of this file changes

FORMULAE=(
    autojump
    bat
    # ... adding a package here triggers re-run
)

for formula in "${FORMULAE[@]}"; do
    brew install "$formula" 2>/dev/null || true
done
```

**Key behaviors:**
- `run_once_` - Runs once ever (tracked by filename hash)
- `run_onchange_` - Runs when file content changes (add a package → re-runs)
- Scripts are idempotent (check if already installed before installing)

**To update packages:** Edit the package list in the source, then `chezmoi apply`.

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

4. **On a new machine**, you need to:

   ```bash
   # Copy your age key (securely - not via git!)
   mkdir -p ~/.config/chezmoi
   # Paste your key into ~/.config/chezmoi/key.txt
   
   # Then chezmoi can decrypt
   chezmoi apply
   ```

**Your age key** (in `~/.config/chezmoi/key.txt`):
- Generated once, reused on all your machines
- Transfer it securely (1Password, airdrop, etc.)
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
