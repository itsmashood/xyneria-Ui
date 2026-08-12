# Architecture

The project uses a small native module graph:

1. `Theme` defines visual tokens.
2. `Util` provides instance creation, animation, safe callbacks and GUI-parent selection.
3. `Config` stores registered flag values when executor filesystem functions are available.
4. `Controls` implements elements directly with Roblox instances and input events.
5. `Window` implements the shell, tabs, dialogs, open/close behavior and keyboard toggling.
6. `XyneriaUI` exposes the script-facing API and notification host.

The build script packages those modules into one file using an internal module loader. Source files remain individually editable.
