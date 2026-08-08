#!/usr/bin/env python3
from pathlib import Path
import hashlib
import re

ROOT = Path(__file__).resolve().parents[1]
UPSTREAM = ROOT / "vendor" / "WindUI" / "dist" / "main.lua"
WRAPPER = ROOT / "src" / "XyneriaWrapper.lua"
OUT = ROOT / "dist" / "XyneriaUI.lua"

def patch_embedded_icons(core: str) -> str:
    # WindUI's exploit path downloads six icon packs from Footagesus/Icons.
    # The same icon packs are already embedded in the supplied dist bundle.
    # Use the embedded modules so XyneriaUI has no Footagesus raw-GitHub
    # dependency for the UI core or its standard icon packs.
    names = [
        ("lucide", "b"),
        ("solar", "c"),
        ("craft", "d"),
        ("geist", "e"),
        ("sfsymbols", "f"),
        ("gravity", "g"),
    ]

    for name, module_id in names:
        pattern = re.compile(
            rf'{name}=IsExploit\(\)and Loadstring\(\s*'
            rf'Get"https://raw\.githubusercontent\.com/Footagesus/Icons/refs/heads/main/'
            rf'{name}/dist/Icons\.lua"\s*'
            rf'\)\(\)or a\.load\'{module_id}\',',
            re.MULTILINE,
        )
        replacement = f"{name}=a.load'{module_id}',"
        core, count = pattern.subn(replacement, core)
        if count != 1:
            raise RuntimeError(
                f"Expected one icon patch for {name}; got {count}. "
                "Upstream dist layout may have changed."
            )

    return core

def indent(text: str, prefix: str = "    ") -> str:
    return "\n".join(prefix + line if line else "" for line in text.splitlines())

def main():
    original = UPSTREAM.read_text(encoding="utf-8")
    wrapper = WRAPPER.read_text(encoding="utf-8")
    core = patch_embedded_icons(original)

    header = '''--[[
 XyneriaUI standalone distribution
 Generated from a locally vendored WindUI v1.6.66 snapshot.

 IMPORTANT:
 - WindUI copyright (c) 2026 Footages, MIT License.
 - See LICENSES/WindUI-MIT.txt and THIRD_PARTY_NOTICES.md in the repository.
 - No WindUI CORE_URL is used at runtime.
 - Original upstream files are preserved under vendor/WindUI/.
]]

'''

    bundle = (
        header
        + "local function __xyneria_load_vendored_windui()\n"
        + indent(core)
        + "\nend\n\n"
        + "local WindUI = __xyneria_load_vendored_windui()\n"
        + "if not WindUI then\n"
        + "    error('[XyneriaUI] Vendored WindUI core failed to initialize.')\n"
        + "end\n\n"
        + wrapper
        + "\n"
    )

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(bundle, encoding="utf-8")

    if "raw.githubusercontent.com/Footagesus/WindUI" in bundle:
        raise RuntimeError("Footagesus WindUI CORE_URL unexpectedly remains.")
    if "raw.githubusercontent.com/Footagesus/Icons" in bundle:
        raise RuntimeError("Footagesus icon raw URLs unexpectedly remain.")

    print(f"Built: {OUT}")
    print(f"Size: {OUT.stat().st_size:,} bytes")
    print("SHA256:", hashlib.sha256(bundle.encode("utf-8")).hexdigest())

if __name__ == "__main__":
    main()
