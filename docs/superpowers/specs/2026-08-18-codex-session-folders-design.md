# Codex Session Folder Picker and Input Mode Design

## Goal

Improve new Codex sessions launched from Emacs in two ways:

1. Keep the current project as the primary workspace and allow zero or more sibling projects under `~/dev` to be added when the session starts.
2. Disable Codex's internal Vim mode for Emacs-launched sessions so that Emacs Evil is the only modal editing layer.

## Startup behavior

The current project directory remains Codex's working root. Immediately before a new terminal-backed Codex session starts, Emacs presents a multi-selection completion prompt containing the immediate child directories of `~/dev`.

The current project is excluded from the choices because it is already the primary workspace. Choosing no additional directories is valid. Every selected directory is passed to Codex as a separate `--add-dir DIR` pair.

The prompt runs only when a new session is actually being created. Reopening an existing Codex buffer, resuming a session, and forking a session retain their existing behavior and do not show the folder picker.

## Candidate discovery

Candidate discovery is isolated in a helper that:

- expands `~/dev` to an absolute directory;
- lists only its immediate children;
- retains directories and directory symlinks;
- excludes the current Codex root by resolved path;
- sorts candidates by display name; and
- returns no candidates if `~/dev` does not exist or is unreadable.

The picker displays the child directory names and resolves selections back to absolute paths. Cancelling the prompt cancels session creation; submitting an empty selection starts with only the current project.

## Codex integration

The integration advises the package's new-session buffer creation boundary. This boundary is late enough that reopening an existing buffer has already been handled, but early enough to append launch-specific command-line arguments.

For a new vterm session, the selected paths are converted to repeated CLI arguments:

```text
--add-dir /absolute/path/one --add-dir /absolute/path/two
```

The selections are scoped to that one launch and do not mutate the global `codex-program-switches` value.

## Input mode

The user's global Codex configuration enables `tui.vim_mode_default`. That conflicts with Evil because entering Emacs Insert state consumes the `i` key before it reaches the Codex TUI, leaving Codex in its own Normal mode.

`codex-program-switches` will include this Emacs-specific override:

```text
-c tui.vim_mode_default=false
```

Codex sessions launched outside Emacs continue to use the global setting. Inside Emacs, Evil controls Normal and Insert state, and Codex receives text using its non-modal composer behavior.

## Error handling

- Missing or unreadable `~/dev`: start without additional directories and do not fail session creation.
- No eligible child directories: start without displaying an empty picker.
- A directory disappearing after selection: allow Codex to report the invalid `--add-dir` argument rather than hiding the launch error.
- User cancellation: abort the new session normally through Emacs's standard quit behavior.

## Testing

ERT tests will cover:

- discovery of immediate directories without recursive descendants;
- exclusion of the current root, including equivalent resolved paths;
- deterministic sorting and filtering of non-directories;
- conversion of multiple selections into repeated `--add-dir` arguments;
- an empty selection producing no extra arguments;
- new-session advice appending launch-local arguments;
- resume paths bypassing the picker; and
- the Emacs Codex configuration including `tui.vim_mode_default=false`.

Verification will byte-compile or load the module in batch Emacs, run the focused ERT suite, and confirm the resulting CLI argument list.
