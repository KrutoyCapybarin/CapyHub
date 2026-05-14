loadstring(game:HttpGet("PASTE_URL_HERE"))()

local Window = UI:Window({
	Title = "My Script",
	Size = Vector2.new(600, 400),
})

local MainTab = Window:Tab({ Title = "Main" })
local MainSection = MainTab:Section({ Title = "General" })

MainSection:Label({ Title = "Click X in the title bar to close" })

MainSection:Button({ Title = "Do Something" }, function()
	print("button pressed")
end)

MainSection:Checkbox({ Title = "Toggle" }, function(bool)
	print("toggle:", bool)
end)

MainSection:Slider({ Title = "Speed", Min = 0, Max = 100, Step = 1, Default = 50, Suffix = "" }, function(n)
	print("speed:", n)
end)

-- можно вызвать Unload() из кода тоже
MainSection:Button({ Title = "Close from code" }, function()
	Window:Unload()
end)

-- Toggle по кнопке (прячет/показывает окно, не закрывает)
MainSection:Keybind({ Title = "Toggle UI", Key = Enum.KeyCode.RightShift }, function()
	Window:Toggle()
end)
