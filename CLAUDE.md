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
5. `search` - deadgrep integration
6. `window` - perspective, popper, super-save
7. `term` - vterm configuration
8. `note` - org-mode, obsidian, olivetti
9. `finance` - ledger-mode
10. `programming` - completion, LSP (eglot), language configs

## Key Configuration Patterns

**Package Installation**: All packages use straight.el with use-package integration:
```elisp
(use-package package-name
  :config ...)
```

**Keybindings**: Evil-leader with SPC prefix for main commands:
- `SPC SPC` - project-find-file
- `SPC gg` - magit
- `SPC pp` - switch project
- `SPC *` - deadgrep
- `SPC ,` - buffer list
- `SPC ff` - format buffer
- `SPC x` - M-x

**LSP**: Uses built-in eglot (not lsp-mode). LSP keybindings in normal mode:
- `K` - eldoc
- `gd` - go to definition
- `gr` - find references
- `gi` - find implementation
- `g]`/`g[` - next/prev error

**Completion**: Vertico + Consult + Marginalia + Orderless stack.

**Perspectives**: `M-t` to switch, `M-o` to open project in perspective, `M-]`/`M-[` next/prev.

## Testing Changes

Reload individual modules: `M-x load-file RET ~/.emacs.d/modules/MODULE.el`

Full restart: Quit and relaunch Emacs, or `emacs -Q` followed by `eval-buffer` on init.el.

## Dependencies

- Emacs Plus 29+ with native-comp (via Homebrew)
- ripgrep (for deadgrep/consult-ripgrep)
- ZedMono Nerd Font (or change in theme.el)
- Language servers: typescript-language-server, pylsp
