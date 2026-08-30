-- Configuration des écrans

local ok, profile = pcall(require, "profiles.default")
if not ok or not profile then
    profile = {
        internal_monitor = "eDP-1",
        internal_mode = "2880x1800@90",
        internal_scale = 1.25,
        internal_bitdepth = 10,
        external_fallback = {
            mode = "preferred",
            position = "auto",
            scale = "auto",
            bitdepth = 10,
        },
    }
end

-- Configuration de l'écran du portable
hl.monitor({
    output = profile.internal_monitor,
    mode = profile.internal_mode,
    position = "auto",
    scale = profile.internal_scale,
    bitdepth = profile.internal_bitdepth,
})

-- Règle par défaut pour tout écran externe connecté
if profile.external_fallback then
    hl.monitor({
        output = "",
        mode = profile.external_fallback.mode,
        position = profile.external_fallback.position,
        scale = profile.external_fallback.scale,
        bitdepth = profile.external_fallback.bitdepth,
    })
end
