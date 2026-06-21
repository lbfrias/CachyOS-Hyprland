hl.layout.register("vertical_chat", {
    recalculate = function(ctx)
        local n = #ctx.targets
        if n == 0 then return end

        local discord_target = nil
        local messenger_target = nil
        local telegram_target = nil
        local other_targets = {}

        -- 1. Sort windows by valid properties
        for _, target in ipairs(ctx.targets) do
            if target.window then
                local class = string.lower(target.window.class or "")
                local init_title = string.lower(target.window.initial_title or "")

                if string.find(class, "discord") then
                    discord_target = target
                elseif string.find(init_title, "messenger") or string.find(class, "ffpwa") then
                    messenger_target = target
                elseif string.find(class, "telegram") then
                    telegram_target = target
                else
                    table.insert(other_targets, target)
                end
            end
        end

        -- 2. Enforce strict left-to-right sorting for the bottom row
        local bottom_targets = {}
        if messenger_target then table.insert(bottom_targets, messenger_target) end
        if telegram_target then table.insert(bottom_targets, telegram_target) end
        for _, target in ipairs(other_targets) do
            table.insert(bottom_targets, target)
        end

        -- Fallback: Promote a bottom app if Discord isn't open
        if not discord_target and #bottom_targets > 0 then
            discord_target = table.remove(bottom_targets, 1)
        end

        local area = ctx.area

        -- 3. Calculate and apply positions
        if discord_target and #bottom_targets == 0 then
            discord_target:place(area)
        elseif discord_target then
            -- Top section (65% height)
            local top_h = math.floor(area.h * 0.65)
            local bottom_h = area.h - top_h
            local bottom_y = area.y + top_h

            discord_target:place({
                x = area.x,
                y = area.y,
                w = area.w,
                h = top_h
            })

            -- Bottom row column layout
            local num_bottom = #bottom_targets
            local current_x = area.x

            for i, target in ipairs(bottom_targets) do
                local target_w

                if messenger_target and num_bottom > 1 then
                    if target == messenger_target then
                        target_w = math.floor(area.w * 0.60) -- Messenger gets 60% width
                    else
                        local remaining_w = area.w - math.floor(area.w * 0.60)
                        target_w = math.floor(remaining_w / (num_bottom - 1))
                    end
                else
                    target_w = math.floor(area.w / num_bottom)
                end

                -- Absolute pixel clamping for the last window to prevent gap bugs
                if i == num_bottom then
                    target_w = area.x + area.w - current_x
                end

                target:place({
                    x = current_x,
                    y = bottom_y,
                    w = target_w,
                    h = bottom_h
                })

                current_x = current_x + target_w
            end
        end
    end,
})
