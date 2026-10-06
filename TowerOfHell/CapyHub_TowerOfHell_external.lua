local datamodel = game
loadstring(datamodel:HttpGet("https://raw.githubusercontent.com/9mfg/rem-ui/main/rem.lua"))()

local UI = Rem

local Main = UI:AddTab({
    Title = "Tower of Hell",
    Icon = "script"
})


local datamodel = game
local Players = datamodel.Players
local user = Players.LocalPlayer
local vro = Players.LocalPlayer
local vros_body = vro.Character
local vros_soul = vros_body.Humanoid

local UserInputService = datamodel:GetService("UserInputService")
local RunService = datamodel:GetService("RunService")
local Players = datamodel:GetService("Players")

local rs = datamodel:GetService("ReplicatedStorage")

-- put your jump power
local JUMP_POWER = 50

--[[
d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93
d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93
d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93
d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93
d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93
d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93
d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93
d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93
d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93
d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93
d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93
]]




local bunnihop_toggle = Main:AddToggle({
    Title = "Bunny Hop",
    Description = "Makes you jump automatically.",
    Default = false,
    Callback = function(value)
        if value then
            -- ON CODE
            rs.GameValues.bunnyJumping.Value = true
            
        else
            -- OFF CODE
            rs.GameValues.bunnyJumping.Value = false
        end
    end
})


local ijConnection = nil

local infinite_jumps_toggle = Main:AddToggle({
    Title = "Infinite Jumps",
    Description = "Allows you to jump infinitely.",
    Default = false,
    Callback = function(value)
        if value then
            -- ON CODE
            if ijConnection then
                ijConnection:Disconnect()
                ijConnection = nil
            end

            ijConnection = RunService.Heartbeat:Connect(function()
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    local char = user.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp then
                        hrp.AssemblyLinearVelocity = Vector3.new(
                            hrp.AssemblyLinearVelocity.X,
                            JUMP_POWER,
                            hrp.AssemblyLinearVelocity.Z
                        )
                    end
                end
            end)
        else
            -- OFF CODE
            if ijConnection then
                ijConnection:Disconnect()
                ijConnection = nil
            end
        end
    end
})



local KillBrickBypass_toggle = Main:AddToggle({
    Title = "KillBrick Bypass",
    Description = "Similar to Invincibility mutator.",
    Default = false,

    Callback = function(value)
        if value then
            -- ON CODE
            rs.GameValues.killbricksDisabled.Value = true
        else
            -- OFF CODE
            rs.GameValues.killbricksDisabled.Value = false
        end
    end
})





Main:Select()
