# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal Emacs configuration using straight.el for package management and use-package for configuration. Designed for macOS with Evil mode (Vim emulation) as the primary editing paradigm.

## Architecture

**Module System**: Custom module loader defined in `early-init.el`. Modules live in `modules/` and are loaded via the `import` function which accepts either a single module name or a list.

```elisp
(import "core")           ; single module
(import '("git" "lsp"))   ; multiple modules
```

**Loading Order** (defined in `init.el`):
1. `core` - straight.el bootstrap, UI settings, performance tuning
2. `theme` - Font (ZedMono) and theme (Doom)
3. `evil` - Evil mode + evil-leader (SPC prefix) + plugins
4. `dired` - File browser with sidebar
5. `minibuffer` - Vertico + Consult + Marginalia + Orderless completion stack
6. `window` - popper, super-save, dimmer, separedit
7. `tab` - project + perspective
8. `term` - vterm configuration
9. `search` - deadgrep integration
10. `note` - org-mode, obsidian, olivetti
11. `programming` - LSP (eglot), git, language configs (markdown, yaml, python, just, kubernetes)
12. `ai` - gptel + claude-code

## Key Configuration Patterns

**Package Installation**: All packages use straight.el with use-package integration:
```elisp
(use-package package-name
  :config ...)
```

**Evil-leader keybindings** (SPC prefix, normal mode):
- `SPC SPC` - project-find-file
- `SPC gg` - magit
- `SPC pp` - project-switch-project
- `SPC pw` - save-buffer
- `SPC *` - deadgrep
- `SPC ,` - consult-project-buffer
- `SPC tt` - dired-sidebar-toggle-sidebar
- `SPC ff` - format buffer
- `SPC x` - M-x

**Keybinding Convention**: Non-evil bindings use `C-c` prefix with semantic sub-prefixes:
- `C-c c` - Claude Code / AI commands
- `C-c g` - Git commands (magit, etc.)
- Additional prefixes should follow the same pattern: letter reflects the domain

**LSP**: Uses built-in eglot (not lsp-mode). LSP keybindings in normal mode:
- `K` - eldoc
- `gd` - go to definition
- `gr` - find references
- `gi` - find implementation
- `g]`/`g[` - next/prev error

**Perspectives**: `M-t` to switch, `M-o` to open project in perspective, `M-]`/`M-[` next/prev.

## Testing Changes

Reload individual modules: `M-x load-file RET ~/.emacs.d/modules/MODULE.el`

Some modules are aggregators that import others (e.g., `ai.el` imports `gptel` and `claude-code`; `programming.el` imports `git`, `lsp`, and language modules). Reload the leaf module, not the aggregator, when iterating on a specific package.

Full restart: Quit and relaunch Emacs, or `emacs -Q` followed by `eval-buffer` on init.el.

## Code Style

**Modifying Behavior**: When changing how a package or feature behaves:
1. First check all available configurations, hooks, and customization options the package provides
2. Only write a custom function if configuration alone cannot achieve the goal
3. Keep custom functions minimal—no bloat

**Custom Functions**: Place custom helper functions at the bottom of module files, after the `use-package` declarations.

**Elisp Conventions**: Always use `if-let*`, `when-let*`, and `and-let*` instead of their non-starred variants (deprecated as of Emacs 31.1).

## Dependencies

- Emacs Plus 29+ with native-comp (via Homebrew)
- ripgrep (for deadgrep/consult-ripgrep)
- ZedMono Nerd Font (or change in theme.el)
- Language servers: typescript-language-server, pylsp
