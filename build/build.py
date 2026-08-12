from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DIST = ROOT / "dist"
DIST.mkdir(exist_ok=True)

MODULES = ["Theme", "Util", "Config", "Controls", "Window", "XyneriaUI"]

require_pattern = re.compile(r'require\(script\.Parent\.([A-Za-z0-9_]+)\)')

parts = [
    "-- XyneriaUI standalone build\n",
    "local __modules = {}\nlocal __cache = {}\nlocal __require\n\n",
]

for name in MODULES:
    source = (SRC / f"{name}.lua").read_text(encoding="utf-8")
    source = require_pattern.sub(lambda m: f'__require("{m.group(1)}")', source)
    parts.append(f'__modules["{name}"] = function()\n{source}\nend\n\n')

parts.append('''__require = function(name)
    if __cache[name] ~= nil then
        return __cache[name]
    end
    local loader = __modules[name]
    assert(loader, "Unknown XyneriaUI module: " .. tostring(name))
    local value = loader()
    __cache[name] = value
    return value
end

return __require("XyneriaUI")
''')

output = "".join(parts)
(DIST / "XyneriaUI.lua").write_text(output, encoding="utf-8", newline="\n")
print(f"built {DIST / 'XyneriaUI.lua'} ({len(output.encode('utf-8'))} bytes)")
