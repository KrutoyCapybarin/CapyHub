--[[
You can skid it freely.
]]

loadstring(game:HttpGet("https://pastebin.com/raw/82iVnchL"))() -- UI LIB

local win = UI:Window({ Title = '  CapyHub - "Bite By Night" Matcha Edition' })
local tab = win:Tab({ Title = "Main" })
local sec = tab:Section({ Title = "Rage (RISKY)", Collapsed = true })

-- ═══════════════════════════════════════════════════════════════════════════════════════════════
--  UTILITIES
-- ═══════════════════════════════════════════════════════════════════════════════════════════════

local localPlayer = game.Players.LocalPlayer

local function findPart(model)
    for _, v in pairs(model:GetChildren()) do
        if v:IsA("BasePart") then return v end
      end
  end

local function getKiller()
    local killerFolder = workspace:FindFirstChild("PLAYERS") and workspace.PLAYERS:FindFirstChild("KILLER")
    if not killerFolder then return nil end
    for _, v in pairs(killerFolder:GetChildren()) do
        if v:FindFirstChild("HumanoidRootPart") then return v end
      end
  end

local function getDistance(pos)
    local char = localPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return 0 end
    local targetPos = type(pos) == "Vector3" and pos or pos.Position
    return math.floor((hrp.Position - targetPos).Magnitude)
  end

-- ═══════════════════════════════════════════════════════════════════════════════════════════════
--  AUTO AVOID TRAPS
-- ═══════════════════════════════════════════════════════════════════════════════════════════════

local avoiding_traps = false

sec:Label({ Title = "Auto avoid traps makes the part above traps, not letting you get in trouble" })
sec:Label({ Title = 'ALERT: YOU CAN GET BAN IF SOMEONE FIND YOU USING "Auto Avoid Traps"' })
sec:Checkbox({ Title = "Auto avoid traps" }, function(state)
    avoiding_traps = state
    if state then
        task.spawn(function()
            while avoiding_traps do
                local ignore = workspace:FindFirstChild("IGNORE")
                local char = localPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if ignore and hrp then
                    for i = 1, 3 do
                        local trapModel = ignore:FindFirstChild("Trap" .. i)
                        if trapModel then
                            local trapPart = findPart(trapModel)
                            if trapPart and (hrp.Position - trapPart.Position).Magnitude < 10 then
                                local forward = hrp.CFrame.LookVector
                                hrp.CFrame = CFrame.new(hrp.Position.X, trapPart.Position.Y + 8, hrp.Position.Z)
                                           * CFrame.Angles(0, math.atan2(forward.X, forward.Z) + math.pi, 0)
                                hrp.AssemblyLinearVelocity = Vector3.new(forward.X * 30, 5, forward.Z * 30)
                              end
                          end
                      end
                  end
                task.wait()
              end
          end)
      else
        -- ничего не делаем
      end
  end)
-- Add this to your Rage section (after the trap checkbox)
-- Works exactly like trap avoid but uses minion's Y + 14 studs for height

local avoiding_minion = false
sec:Checkbox({ Title = "Auto avoid Minion (higher jump)" }, function(state)
    avoiding_minion = state
    if state then
        task.spawn(function()
            local player = game.Players.LocalPlayer
            while avoiding_minion do
                local ignore = workspace:FindFirstChild("IGNORE")
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if ignore and hrp then
                    -- Find all minions inside IGNORE folder
                    local minions = {}
                    for _, obj in pairs(ignore:GetChildren()) do
                        if obj.Name == "Minion" then
                            local minionHrp = obj:FindFirstChild("HumanoidRootPart")
                            if minionHrp then
                                table.insert(minions, minionHrp)
                            end
                        end
                    end
                    for _, minionHrp in ipairs(minions) do
                        local dist = (hrp.Position - minionHrp.Position).Magnitude
                        if dist < 17 then
                            local forward = hrp.CFrame.LookVector
                            
                            hrp.CFrame = CFrame.new(hrp.Position.X, minionHrp.Position.Y + 10, hrp.Position.Z)
                            hrp.AssemblyLinearVelocity = Vector3.new(forward.X * 30, 5, forward.Z * 30)
                        end
                    end
                end
                task.wait()
            end
        end)
    end
end)
-- ═══════════════════════════════════════════════════════════════════════════════════════════════
--  ESP CORE HELPERS
-- ═══════════════════════════════════════════════════════════════════════════════════════════════

local function newBox(color)
    local d = Drawing.new("Square")
    d.Visible = false; d.Filled = false; d.Color = color; d.Thickness = 1
    return d
  end

local function newText(color, size)
    local d = Drawing.new("Text")
    d.Visible = false; d.Outline = true; d.Color = color; d.Size = size or 14; d.Center = true
    return d
  end

local function getBoxScreen(hrp, head)
    local tp, tv = WorldToScreen(hrp.Position)
    local hp, hv = WorldToScreen(head.Position)
    if not tv or not hv then return nil end
    local height = math.abs(hp.Y - tp.Y) * 2
    local width = height * 0.55
    return tp, hp, height, width
  end

-- ═══════════════════════════════════════════════════════════════════════════════════════════════
--  ESP TAB
-- ═══════════════════════════════════════════════════════════════════════════════════════════════

local espTab = win:Tab({ Title = "ESP" })
local espSection = espTab:Section({ Title = "ESP", Collapsed = true })

-- Helper for periodic refresh (every 1.5 seconds)
local function withPeriodicRefresh(interval, drawCallback, cleanupCallback, refreshCallback)
    local lastRefresh = os.clock()
    task.spawn(function()
        while true do
            local now = os.clock()
            if now - lastRefresh >= interval then
                lastRefresh = now
                if cleanupCallback then cleanupCallback() end
                if refreshCallback then refreshCallback() end
              end
            drawCallback()
            task.wait(0.05)
          end
      end)
  end

-- ═══════════════════════════════════════════════════════════════════════════════════════════════
--  1. KILLER ESP
-- ═══════════════════════════════════════════════════════════════════════════════════════════════

local killerActive = false
local killerData = nil

local function refreshKiller()
    if not killerActive then return end
    if killerData then
        killerData.box:Remove()
        killerData.name:Remove()
        killerData.dist:Remove()
      end
    killerData = {
        box = newBox(Color3.fromRGB(255, 50, 50)),
        name = newText(Color3.fromRGB(255, 50, 50)),
        dist = newText(Color3.fromRGB(220, 220, 220), 13)
      }
  end

local function drawKiller()
    if not killerActive then return end
    local killer = getKiller()
    local hrp = killer and killer:FindFirstChild("HumanoidRootPart")
    if not hrp then
        killerData.box.Visible = false
        killerData.name.Visible = false
        killerData.dist.Visible = false
        return
      end
    local headPos = (killer:FindFirstChild("Head") or hrp).Position + Vector3.new(0, 1.5, 0)
    local tp, hp, h, w = getBoxScreen(hrp, { Position = headPos })
    if not tp then
        killerData.box.Visible = false
        killerData.name.Visible = false
        killerData.dist.Visible = false
        return
      end
    local skin = killer:FindFirstChild("Skin") and killer.Skin.Value or ""
    local charName = killer:FindFirstChild("Character") and killer.Character.Value or killer.Name
    local label = (skin ~= "" and skin .. " " or "") .. charName
    killerData.box.Position = Vector2.new(tp.X - w/2, hp.Y)
    killerData.box.Size = Vector2.new(w, h)
    killerData.box.Visible = true
    killerData.name.Text = label
    killerData.name.Position = Vector2.new(tp.X, hp.Y - 16)
    killerData.name.Visible = true
    killerData.dist.Text = "[" .. getDistance(hrp) .. "m]"
    killerData.dist.Position = Vector2.new(tp.X, hp.Y - 30)
    killerData.dist.Visible = true
  end

espSection:Checkbox({ Title = "Killer ESP" }, function(state)
    killerActive = state
    if state then
        refreshKiller()
        withPeriodicRefresh(1.5, drawKiller,
            function()
                if killerData then
                    killerData.box:Remove()
                    killerData.name:Remove()
                    killerData.dist:Remove()
                    killerData = nil
                  end
              end,
            refreshKiller)
      else
        killerActive = false
        if killerData then
            killerData.box:Remove()
            killerData.name:Remove()
            killerData.dist:Remove()
            killerData = nil
          end
      end
  end)

-- ═══════════════════════════════════════════════════════════════════════════════════════════════
--  2. PLAYER ESP
-- ═══════════════════════════════════════════════════════════════════════════════════════════════

local playerActive = false
local playersData = {}

local function cleanupPlayers()
    for _, data in pairs(playersData) do
        data.box:Remove()
        data.name:Remove()
        data.dist:Remove()
      end
    playersData = {}
  end

local function refreshPlayers()
    if not playerActive then return end
    cleanupPlayers()
    local playersFolder = workspace:FindFirstChild("PLAYERS")
    if not playersFolder then return end
    for _, folder in pairs(playersFolder:GetChildren()) do
        if folder.Name ~= "KILLER" and folder.Name ~= localPlayer.Name then
            local hrp = folder:FindFirstChild("HumanoidRootPart")
            local head = folder:FindFirstChild("Head")
            if hrp and head then
                local key = tostring(hrp)
                playersData[key] = {
                    box = newBox(Color3.fromRGB(100, 200, 255)),
                    name = newText(Color3.fromRGB(100, 200, 255)),
                    dist = newText(Color3.fromRGB(220, 220, 220), 13),
                    label = folder.Name,
                    hrp = hrp,
                    head = head
                  }
              end
          end
      end
  end

local function drawPlayers()
    if not playerActive then return end
    for key, data in pairs(playersData) do
        if not data.hrp or not data.hrp.Parent then
            data.box:Remove()
            data.name:Remove()
            data.dist:Remove()
            playersData[key] = nil
          else
            local tp, hp, h, w = getBoxScreen(data.hrp, data.head)
            if not tp then
                data.box.Visible = false
                data.name.Visible = false
                data.dist.Visible = false
              else
                data.box.Position = Vector2.new(tp.X - w/2, hp.Y)
                data.box.Size = Vector2.new(w, h)
                data.box.Visible = true
                data.name.Text = data.label
                data.name.Position = Vector2.new(tp.X, hp.Y - 16)
                data.name.Visible = true
                data.dist.Text = "[" .. getDistance(data.hrp) .. "m]"
                data.dist.Position = Vector2.new(tp.X, hp.Y - 30)
                data.dist.Visible = true
              end
          end
      end
  end

espSection:Checkbox({ Title = "Player ESP" }, function(state)
    playerActive = state
    if state then
        refreshPlayers()
        withPeriodicRefresh(1.5, drawPlayers, cleanupPlayers, refreshPlayers)
      else
        playerActive = false
        cleanupPlayers()
      end
  end)

-- ═══════════════════════════════════════════════════════════════════════════════════════════════
--  3. GENERATOR ESP
-- ═══════════════════════════════════════════════════════════════════════════════════════════════

local generatorActive = false
local generatorsData = {}

local function cleanupGenerators()
    for _, data in pairs(generatorsData) do
        data.dot:Remove()
        data.dist:Remove()
      end
    generatorsData = {}
  end

local function refreshGenerators()
    if not generatorActive then return end
    cleanupGenerators()
    local gensFolder = workspace:FindFirstChild("MAPS")
        and workspace.MAPS:FindFirstChild("GAME MAP")
        and workspace.MAPS["GAME MAP"]:FindFirstChild("Tasks")
        and workspace.MAPS["GAME MAP"].Tasks:FindFirstChild("Generators")
    if not gensFolder then return end
    for _, gen in pairs(gensFolder:GetChildren()) do
        local hrp = gen:FindFirstChild("HumanoidRootPart")
        if hrp then
            local key = tostring(hrp)
            generatorsData[key] = {
                dot = newText(Color3.fromRGB(255, 200, 0), 14),
                dist = newText(Color3.fromRGB(220, 220, 220), 13),
                hrp = hrp,
                generator = gen
              }
          end
      end
  end

local function drawGenerators()
    if not generatorActive then return end
    for key, data in pairs(generatorsData) do
        if not data.hrp or not data.hrp.Parent then
            data.dot:Remove()
            data.dist:Remove()
            generatorsData[key] = nil
          else
            local progress = data.generator:GetAttribute("Progress") or 0
            if progress >= 100 then
                data.dot.Visible = false
                data.dist.Visible = false
              else
                local sp, vis = WorldToScreen(data.hrp.Position)
                if not vis then
                    data.dot.Visible = false
                    data.dist.Visible = false
                  else
                    local color = progress >= 75 and Color3.fromRGB(255, 80, 80)
                                 or progress >= 50 and Color3.fromRGB(255, 180, 0)
                                 or Color3.fromRGB(100, 255, 100)
                    data.dot.Text = "Generator [" .. progress .. "%]"
                    data.dot.Color = color
                    data.dot.Position = Vector2.new(sp.X, sp.Y - 16)
                    data.dot.Visible = true
                    data.dist.Text = "[" .. getDistance(data.hrp) .. "m]"
                    data.dist.Position = Vector2.new(sp.X, sp.Y)
                    data.dist.Visible = true
                  end
              end
          end
      end
  end

espSection:Checkbox({ Title = "Generator ESP" }, function(state)
    generatorActive = state
    if state then
        refreshGenerators()
        withPeriodicRefresh(1.5, drawGenerators, cleanupGenerators, refreshGenerators)
      else
        generatorActive = false
        cleanupGenerators()
      end
  end)

-- ═══════════════════════════════════════════════════════════════════════════════════════════════
--  4. DOOR ESP
-- ═══════════════════════════════════════════════════════════════════════════════════════════════

local doorActive = false
local doorsData = {}

local function cleanupDoors()
    for _, data in pairs(doorsData) do
        data.label:Remove()
        data.dist:Remove()
      end
    doorsData = {}
  end

local function refreshDoors()
    if not doorActive then return end
    cleanupDoors()
    local ignore = workspace:FindFirstChild("IGNORE")
    if not ignore then return end
    local idx = 0
    for _, part in pairs(ignore:GetChildren()) do
        if part.Name == "Door Base" then
            local success, pos = pcall(function() return part.Position end)
            if success and typeof(pos) == "Vector3" then
                idx = idx + 1
                doorsData[idx] = {
                    label = newText(Color3.fromRGB(50, 255, 50), 14),
                    dist = newText(Color3.fromRGB(220, 220, 220), 13),
                    part = part,
                    index = idx
                  }
              end
          end
      end
  end

local function drawDoors()
    if not doorActive then return end
    for _, data in pairs(doorsData) do
        if not data.part or not data.part.Parent then
            data.label:Remove()
            data.dist:Remove()
            doorsData[data.index] = nil
          else
            local success, pos = pcall(function() return data.part.Position end)
            if not success then
                data.label.Visible = false
                data.dist.Visible = false
              else
                local sp, vis = WorldToScreen(pos)
                if not vis then
                    data.label.Visible = false
                    data.dist.Visible = false
                  else
                    local breaks = data.part:GetAttribute("Breaks")
                    local breakText, color
                    if breaks == nil then
                        breakText = "?"; color = Color3.fromRGB(180, 180, 180)
                      elseif breaks <= 0 then
                        breakText = "0"; color = Color3.fromRGB(255, 60, 60)
                      elseif breaks == 1 then
                        breakText = "1"; color = Color3.fromRGB(255, 180, 0)
                      else
                        breakText = tostring(breaks); color = Color3.fromRGB(50, 255, 50)
                      end
                    data.label.Text = "Door [" .. data.index .. "] " .. breakText .. "hp"
                    data.label.Color = color
                    data.label.Position = Vector2.new(sp.X, sp.Y - 16)
                    data.label.Visible = true
                    data.dist.Text = "[" .. getDistance(pos) .. "m]"
                    data.dist.Position = Vector2.new(sp.X, sp.Y)
                    data.dist.Visible = true
                  end
              end
          end
      end
  end

espSection:Checkbox({ Title = "Door ESP" }, function(state)
    doorActive = state
    if state then
        refreshDoors()
        withPeriodicRefresh(1.5, drawDoors, cleanupDoors, refreshDoors)
      else
        doorActive = false
        cleanupDoors()
      end
  end)

-- ═══════════════════════════════════════════════════════════════════════════════════════════════
--  5. TRAP ESP
-- ═══════════════════════════════════════════════════════════════════════════════════════════════

local trapActive = false
local trapsData = {}

local function cleanupTraps()
    for _, data in pairs(trapsData) do
        data.label:Remove()
        data.dist:Remove()
      end
    trapsData = {}
  end

local function refreshTraps()
    if not trapActive then return end
    cleanupTraps()
    local ignore = workspace:FindFirstChild("IGNORE")
    if not ignore then return end
    for i = 1, 3 do
        local trapModel = ignore:FindFirstChild("Trap" .. i)
        if trapModel then
            local part = findPart(trapModel)
            if part then
                trapsData[i] = {
                    label = newText(Color3.fromRGB(255, 80, 255), 14),
                    dist = newText(Color3.fromRGB(220, 220, 220), 13),
                    part = part,
                    name = "Trap" .. i
                  }
              end
          end
      end
  end

local function drawTraps()
    if not trapActive then return end
    for _, data in pairs(trapsData) do
        if not data.part or not data.part.Parent then
            data.label:Remove()
            data.dist:Remove()
            trapsData[data.name] = nil
          else
            local sp, vis = WorldToScreen(data.part.Position)
            if not vis then
                data.label.Visible = false
                data.dist.Visible = false
              else
                data.label.Text = data.name
                data.label.Position = Vector2.new(sp.X, sp.Y - 16)
                data.label.Visible = true
                data.dist.Text = "[" .. getDistance(data.part) .. "m]"
                data.dist.Position = Vector2.new(sp.X, sp.Y)
                data.dist.Visible = true
              end
          end
      end
  end

espSection:Checkbox({ Title = "Trap ESP" }, function(state)
    trapActive = state
    if state then
        refreshTraps()
        withPeriodicRefresh(1.5, drawTraps, cleanupTraps, refreshTraps)
      else
        trapActive = false
        cleanupTraps()
      end
  end)


--[[
Капибарский От себя - Для себя

win = UI:Window({ Title = "title" })          -- окно
\___win:Toggle()                              -- спрятать/показать
\___win:Unload()                              -- закрыть (или X в тайтлбаре)
\___win:Tab({ Title = "title" })              -- таб слева
    \___tab:Section({ Title = "title", Collapsed = bool }) -- секция в табе
        \___sec:Label({ Title = "текст" })                         -- просто текст
        \___sec:Button({ Title = "текст" }, function() end)        -- кнопка
        \___sec:Checkbox({ Title = "текст" }, function(bool) end)  -- вкл/выкл
        \___sec:Slider({ Title = "текст", Min = 0, Max = 100, Step = 1, Default = 50, Suffix = "px" }, function(n) end)
        \___sec:MultiDropdown({ Title = "текст", Options = {"A","B","C"}, Default = {"A"} }, function(selected) end) -- selected это таблица
        \___sec:Keybind({ Title = "текст", Key = Enum.KeyCode.F }, function() end, function(newKey) end)
                                                                   -- 1й колбэк = нажата, 2й = сменена
]]

--sssss iuai
