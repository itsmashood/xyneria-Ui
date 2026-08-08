# Runtime dependency audit

The standalone Xyneria build removes the runtime dependency that originally loaded WindUI from the Footagesus GitHub `dist/main.lua`.

It also replaces WindUI's six standard icon-pack raw GitHub downloads with the copies already embedded in the supplied WindUI distribution.

The upstream source still contains optional third-party service adapter URLs such as Luarmor/Panda/Platoboost. Those adapters are not contacted by XyneriaUI unless you explicitly configure WindUI's own KeySystem/API service features. Xyneria uses its separate Cloudflare licensing system instead.
