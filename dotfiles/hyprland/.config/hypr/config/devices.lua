local trackpad = {
    names = {"apple-inc.-magic-trackpad", "apple-inc.-magic-trackpad-1"},
    sensitivity = 0.3,
    accel_profile = "0.2 0.1 0.2 0.4 1.5"
}

for _, name in ipairs(trackpad.names) do
    hl.device({
        name = name,
        sensitivity = trackpad.sensitivity,
        accel_profile = trackpad.accel_profile
    })
end
