local profile = {
    internal_monitor = "eDP-1",
    internal_mode = "2880x1800@90",
    internal_scale = 1.33,
    internal_bitdepth = 10,
    
    external_fallback = {
        mode = "preferred",
        position = "auto",
        scale = "auto",
        -- 8 bits : moins de bande passante sur le dock USB-C (MST), où l'entraînement du lien
        -- échouait parfois au rebranchement en 10 bits.
        bitdepth = 8
    },

    -- Écrans externes connus. "preferred" choisit le mode préféré de l'EDID, qui est 50 Hz
    -- sur le Xiaomi : on force donc 60 Hz.
    external_monitors = {
        {
            output = "desc:Xiaomi Corporation Mi Monitor 0000000000000",
            mode = "3440x1440@60",
            position = "auto",
            scale = 1,
            bitdepth = 8,
        },
    },
}

return profile
