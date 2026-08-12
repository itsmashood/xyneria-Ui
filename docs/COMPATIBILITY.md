# Compatibility

The package keeps the main Xyneria-facing wrapper signatures used by the previous project version.

Preserved library calls:

- `XyneriaUI:GetCore()`
- `XyneriaUI:GetStyle()`
- `XyneriaUI:SetTheme(name)`
- `XyneriaUI:Notify(title, content, icon, duration)`
- `XyneriaUI:CreateWindow(options)`

Preserved app calls include tabs, sections, dialogs, notifications, visibility methods, title/author/scale setters, effects, pulse and config save/load.

Common controls are implemented directly by this package. Some advanced or highly specialized behavior from older builds may need adaptation because this codebase intentionally uses a smaller native core.
