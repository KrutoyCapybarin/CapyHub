local resolvers = {
    vector3 = function(target)
        return target
    end,

    instance = function(target)
        if target:IsA("BasePart") then
            return target.Position
        end
    end,
}

local math_util = {
    distance = function(a, b)
        local diff = a - b
        return math.sqrt(diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z)
    end,

    lerp = function(a, b, alpha)
        return Vector3.new(
            a.X + (b.X - a.X) * alpha,
            a.Y + (b.Y - a.Y) * alpha,
            a.Z + (b.Z - a.Z) * alpha
        )
    end,

    easing = {
        linear = function(alpha)
            return alpha
        end,

        smoothstep = function(alpha)
            return alpha * alpha * (3 - 2 * alpha)
        end,

        ease_in_quad = function(alpha)
            return alpha * alpha
        end,

        ease_out_quad = function(alpha)
            return alpha * (2 - alpha)
        end,

        ease_in_out_quad = function(alpha)
            if alpha < 0.5 then
                return 2 * alpha * alpha
            else
                return -1 + (4 - 2 * alpha) * alpha
            end
        end,
    }
}

function tween_to(local_player, target, speed, easing_style) --not local cuz we using it outscript
    local result = {completed = false}

    if not (local_player and target and speed > 0) then 
        result.completed = true
        return result 
    end

    local char = local_player.Character
    if not char then
        result.completed = true
        return result
    end

    local hrp = char:WaitForChild("HumanoidRootPart")
    local resolve = resolvers[typeof(target):lower()]
    local target_position = resolve and resolve(target)
    if not target_position then
        result.completed = true
        return result
    end

    local start_position = hrp.Position
    local distance = math_util.distance(start_position, target_position)
    local duration = distance / speed
    if duration <= 0 then
        result.completed = true
        return result
    end

    local easing_func = math_util.easing[easing_style] or math_util.easing.linear

    task.spawn(function()
        local elapsed = 0
        local dt = 1 / 240
        while elapsed < duration do
            elapsed = elapsed + dt
            local alpha = math.clamp(elapsed / duration, 0, 1)
            local eased_alpha = easing_func(alpha)
            hrp.Position = math_util.lerp(start_position, target_position, eased_alpha)
            task.wait(dt)
        end
        hrp.Position = target_position
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        result.completed = true
    end)

    return result
end

