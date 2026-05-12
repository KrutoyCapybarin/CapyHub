loadstring(game:HttpGet("https://pastebin.com/raw/82iVnchL"))()

local win = UI:Window({ Title = '  CapyHub - "Bite By Night" Matcha Edition'})
local tab = win:Tab({ Title = "Main" })
local sec = tab:Section({ Title = "Rage (RISKY)", Collapsed = true })

-- ══════════════════════════════════════════
--  UTILS
-- ══════════════════════════════════════════

local function findPart(model)
    for _, v in pairs(model:GetChildren()) do
        if v:IsA("BasePart") then return v end
    end
end

local function getKiller()
    local killerFolder = workspace:FindFirstChild("PLAYERS") and workspace.PLAYERS:FindFirstChild("KILLER")
    if not killerFolder then return nil end
    for _, v in pairs(killerFolder:GetChildren()) do
        local hrp = v:FindFirstChild("HumanoidRootPart")
        if hrp then return v end
    end
end

-- ══════════════════════════════════════════
--  MAIN TAB — RAGE
-- ══════════════════════════════════════════

avoiding_traps = false

sec:Label({ Title = "Auto avoid traps makes the part above traps, not letting you get in trouble" })
sec:Label({ Title = 'ALERT: YOU CAN GET BAN IF SOMEONE FIND YOU USING "Auto Avoid Traps"' })
sec:Checkbox({ Title = "Auto avoid traps" }, function(avoidtraps_change)
    avoiding_traps = avoidtraps_change
    if avoidtraps_change then
        task.spawn(function()
            local player = game.Players.LocalPlayer
            while avoiding_traps do
                local ignore = workspace:FindFirstChild("IGNORE")
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if ignore and hrp then
                    for i = 1, 3 do
                        local trapModel = ignore:FindFirstChild("Trap" .. i)
                        if trapModel then
                            local trap = findPart(trapModel)
                            if trap then
                                local dist = (hrp.Position - trap.Position).Magnitude
                                if dist < 10 then
                                    local p = hrp.Position
                                    local forward = hrp.CFrame.LookVector
                                    hrp.CFrame = CFrame.new(p.X, trap.Position.Y + 8, p.Z) * CFrame.Angles(0, math.atan2(forward.X, forward.Z) + math.pi, 0)
                                    hrp.AssemblyLinearVelocity = Vector3.new(forward.X * 30, 5, forward.Z * 30)
                                end
                            end
                        end
                    end
                end
                task.wait()
            end
        end)
    end
end)

-- ══════════════════════════════════════════
--  ESP TAB
-- ══════════════════════════════════════════
--  ESP UTILS
-- ══════════════════════════════════════════

local RS = game:GetService("RunService")
local localPlayer = game.Players.LocalPlayer

local function newBox(color)
    local d = Drawing.new("Square")
    d.Visible = false; d.Filled = false
    d.Color = color;   d.Thickness = 1
    return d
end
local function newText(color, size)
    local d = Drawing.new("Text")
    d.Visible = false; d.Outline = true
    d.Color = color;   d.Size = size or 14; d.Center = true
    return d
end
local function calcBox(hrp, head)
    local tp, tv = WorldToScreen(hrp.Position)
    local hp, hv = WorldToScreen(head.Position)
    if not tv or not hv then return nil end
    local h = math.abs(hp.Y - tp.Y) * 2
    local w = h * 0.55
    return tp, hp, h, w
end
local function getDist(pos)
    local lc = localPlayer.Character
    local lhrp = lc and lc:FindFirstChild("HumanoidRootPart")
    if not lhrp then return 0 end
    local p = typeof(pos) == "Vector3" and pos or pos.Position
    return math.floor((lhrp.Position - p).Magnitude)
end

-- ══════════════════════════════════════════
--  ESP TAB
-- ══════════════════════════════════════════

local esptab = win:Tab({ Title = "ESP" })
local espsec = esptab:Section({ Title = "ESP", Collapsed = true })

-- ── Killer ESP ──────────────────────────────────────────────
local killer_on = false
local killer_d = nil

espsec:Checkbox({ Title = "Killer ESP" }, function(state)
    killer_on = state
    if state then
        killer_d = { box = newBox(Color3.fromRGB(255,50,50)), name = newText(Color3.fromRGB(255,50,50)), dist = newText(Color3.fromRGB(220,220,220), 13) }
        task.spawn(function()
            while killer_on do
                local killer = getKiller()
                local hrp    = killer and killer:FindFirstChild("HumanoidRootPart")
                if not hrp then
                    killer_d.box.Visible = false; killer_d.name.Visible = false; killer_d.dist.Visible = false
                else
                    local headPos = (killer:FindFirstChild("Head") or hrp).Position + Vector3.new(0, 1.5, 0)
                    local tp, hp, h, w = calcBox(hrp, { Position = headPos })
                    if not tp then
                        killer_d.box.Visible = false; killer_d.name.Visible = false; killer_d.dist.Visible = false
                    else
                        local skin = killer:FindFirstChild("Skin") and killer.Skin.Value or ""
                        local char = killer:FindFirstChild("Character") and killer.Character.Value or killer.Name
                        local label = skin ~= "" and (skin.." "..char) or char
                        killer_d.box.Position = Vector2.new(tp.X - w/2, hp.Y); killer_d.box.Size = Vector2.new(w, h); killer_d.box.Visible = true
                        killer_d.name.Text = label; killer_d.name.Position = Vector2.new(tp.X, hp.Y - 16); killer_d.name.Visible = true
                        killer_d.dist.Text = "["..getDist(hrp).."m]"; killer_d.dist.Position = Vector2.new(tp.X, hp.Y - 30); killer_d.dist.Visible = true
                    end
                end
                task.wait(0.05)
            end
        end)
    else
        killer_on = false
        if killer_d then killer_d.box:Remove(); killer_d.name:Remove(); killer_d.dist:Remove(); killer_d = nil end
    end
end)

-- ── Player ESP ───────────────────────────────────────────────
local player_on = false
local player_d = {}

espsec:Checkbox({ Title = "Player ESP" }, function(state)
    player_on = state
    if state then
        task.spawn(function()
            while player_on do
                local found = {}
                for _, obj in pairs(game.Players:GetChildren()) do
                    if obj.ClassName == "Folder" and obj.Name ~= localPlayer.Name then
                        local char = workspace:FindFirstChild(obj.Name)
                        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                        local head = char and char:FindFirstChild("Head")
                        if hrp and head then
                            local key = hrp.Address
                            found[key] = true
                            if not player_d[key] then
                                player_d[key] = { box = newBox(Color3.fromRGB(100,200,255)), name = newText(Color3.fromRGB(100,200,255)), dist = newText(Color3.fromRGB(220,220,220), 13), label = obj.Name }
                            end
                            local d = player_d[key]
                            local tp, hp, h, w = calcBox(hrp, head)
                            if not tp then
                                d.box.Visible = false; d.name.Visible = false; d.dist.Visible = false
                            else
                                d.box.Position = Vector2.new(tp.X - w/2, hp.Y); d.box.Size = Vector2.new(w, h); d.box.Visible = true
                                d.name.Text = d.label; d.name.Position = Vector2.new(tp.X, hp.Y - 16); d.name.Visible = true
                                d.dist.Text = "["..getDist(hrp).."m]"; d.dist.Position = Vector2.new(tp.X, hp.Y - 30); d.dist.Visible = true
                            end
                        end
                    end
                end
                for key, d in pairs(player_d) do
                    if not found[key] then
                        d.box:Remove(); d.name:Remove(); d.dist:Remove()
                        player_d[key] = nil
                    end
                end
                task.wait(0.05)
            end
        end)
    else
        player_on = false
        for _, d in pairs(player_d) do d.box:Remove(); d.name:Remove(); d.dist:Remove() end
        player_d = {}
    end
end)

-- ── Generator ESP ────────────────────────────────────────────
local gen_on = false
local gen_d = {}

local function scanGenerators()
    local gensFolder = workspace:FindFirstChild("MAPS")
        and workspace.MAPS:FindFirstChild("GAME MAP")
        and workspace.MAPS["GAME MAP"]:FindFirstChild("Tasks")
        and workspace.MAPS["GAME MAP"].Tasks:FindFirstChild("Generators")
    if not gensFolder then return end
    for _, gen in pairs(gensFolder:GetChildren()) do
        local hrp = gen:FindFirstChild("HumanoidRootPart")
        if hrp and not gen_d[hrp.Address] then
            gen_d[hrp.Address] = { dot = newText(Color3.fromRGB(255,200,0), 14), dist = newText(Color3.fromRGB(220,220,220), 13), hrp = hrp, gen = gen }
        end
    end
end

espsec:Checkbox({ Title = "Generator ESP" }, function(state)
    gen_on = state
    if state then
        task.spawn(function()
            local scanTimer = 0
            while gen_on do
                scanTimer += 0.05
                if scanTimer >= 2 then
                    scanTimer = 0
                    scanGenerators()
                end
                for _, d in pairs(gen_d) do
                    local prog = d.gen:GetAttribute("Progress") or 0
                    if prog >= 100 then d.dot.Visible = false; d.dist.Visible = false; continue end
                    local sp, vis = WorldToScreen(d.hrp.Position)
                    if not vis then d.dot.Visible = false; d.dist.Visible = false; continue end
                    local color = prog >= 75 and Color3.fromRGB(255,80,80) or prog >= 50 and Color3.fromRGB(255,180,0) or Color3.fromRGB(100,255,100)
                    d.dot.Text = "Generator ["..prog.."%]"; d.dot.Color = color; d.dot.Position = Vector2.new(sp.X, sp.Y - 16); d.dot.Visible = true
                    d.dist.Text = "["..getDist(d.hrp).."m]"; d.dist.Position = Vector2.new(sp.X, sp.Y); d.dist.Visible = true
                end
                task.wait(0.05)
            end
        end)
    else
        gen_on = false
        for _, d in pairs(gen_d) do d.dot:Remove(); d.dist:Remove() end
        gen_d = {}
    end
end)

-- ── Door ESP ─────────────────────────────────────────────────
local door_on = false
local door_d = {}

espsec:Checkbox({ Title = "Door ESP" }, function(state)
    door_on = state
    if state then
        task.spawn(function()
            local ignore = workspace:FindFirstChild("IGNORE")
            if not ignore then return end

            
            local doorIdx = 0
            for _, v in pairs(ignore:GetChildren()) do
                if v.Name == "Door Base" then
                    local ok, pos = pcall(function() return v.Position end)
                    if ok and typeof(pos) == "Vector3" then
                        doorIdx += 1
                        door_d[doorIdx] = { label = newText(Color3.fromRGB(50,255,50), 14), dist = newText(Color3.fromRGB(220,220,220), 13), part = v, idx = doorIdx }
                    end
                end
            end
            print("[DOOR] tracked:", doorIdx)

            while door_on do
                for _, d in pairs(door_d) do
                    local ok, pos = pcall(function() return d.part.Position end)
                    if not ok then d.label.Visible = false; d.dist.Visible = false; continue end
                    local sp, vis = WorldToScreen(pos)
                    if not vis then d.label.Visible = false; d.dist.Visible = false; continue end
                    local breaks = d.part:GetAttribute("Breaks")
                    local btext, color
                    if breaks == nil then
                        btext = "?"; color = Color3.fromRGB(180, 180, 180)
                    elseif breaks <= 0 then
                        btext = "0"; color = Color3.fromRGB(255, 60, 60)
                    elseif breaks == 1 then
                        btext = "1"; color = Color3.fromRGB(255, 180, 0)
                    else
                        btext = tostring(breaks); color = Color3.fromRGB(50, 255, 50)
                    end
                    d.label.Text = "Door ["..d.idx.."] "..btext.."hp"; d.label.Color = color; d.label.Position = Vector2.new(sp.X, sp.Y - 16); d.label.Visible = true
                    d.dist.Text = "["..getDist(pos).."m]"; d.dist.Position = Vector2.new(sp.X, sp.Y); d.dist.Visible = true
                end
                task.wait(0.05)
            end
        end)
    else
        door_on = false
        for _, d in pairs(door_d) do d.label:Remove(); d.dist:Remove() end
        door_d = {}
    end
end)


-- ── Trap ESP ─────────────────────────────────────────────────
local trap_on = false
local trap_d = {}

espsec:Checkbox({ Title = "Trap ESP" }, function(state)
    trap_on = state
    if state then
        task.spawn(function()
            local ignore = workspace:FindFirstChild("IGNORE")
            if ignore then
                for i = 1, 3 do
                    local trapModel = ignore:FindFirstChild("Trap" .. i)
                    local part = trapModel and findPart(trapModel)
                    if part then
                        trap_d[i] = { label = newText(Color3.fromRGB(255,80,255), 14), dist = newText(Color3.fromRGB(220,220,220), 13), part = part, name = "Trap"..i }
                    end
                end
            end
            while trap_on do
                for _, d in pairs(trap_d) do
                    local sp, vis = WorldToScreen(d.part.Position)
                    if not vis then d.label.Visible = false; d.dist.Visible = false; continue end
                    d.label.Text = d.name; d.label.Position = Vector2.new(sp.X, sp.Y - 16); d.label.Visible = true
                    d.dist.Text = "["..getDist(d.part.Position).."m]"; d.dist.Position = Vector2.new(sp.X, sp.Y); d.dist.Visible = true
                end
                task.wait(0.05)
            end
        end)
    else
        trap_on = false
        for _, d in pairs(trap_d) do d.label:Remove(); d.dist:Remove() end
        trap_d = {}
    end
end)
