--[[ 
vibecoded by gemini in web cuz im broke asf
not a single line of this code was checked soooo
]]

if _G.DataModelExplorer then
	pcall(function()
		_G.DataModelExplorer:Destroy()
	end)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Useful services shown first in exact order
local USEFUL_SERVICES = {
	"Workspace",
	"Players",
	"CoreGui",
	"Lighting",
	"ReplicatedStorage",
	"ReplicatedFirst",
	"StarterGui",
	"StarterPack",
	"StarterPlayer"
}

local USEFUL_SET = {}
for _, name in ipairs(USEFUL_SERVICES) do
	USEFUL_SET[name] = true
end

-- Separate folder at the bottom for remaining services
local OTHER_SERVICES_FOLDER = {
	Name = "OtherServices",
	ClassName = "Folder",
	IsOtherServices = true
}

local function isLeftMouseDown()
	if type(ismouse1pressed) == "function" then
		local ok, pressed = pcall(ismouse1pressed)
		if ok then
			return pressed == true
		end
	end
	return false
end

local CANDIDATE_PROPERTIES = {
	"Name", "ClassName", "Value", "Text", "Visible", "Enabled",
	"Transparency", "BackgroundTransparency", "Position", "Size",
	"CFrame", "Anchored", "CanCollide", "Color", "BrickColor",
	"Material", "Health", "MaxHealth", "WalkSpeed", "JumpPower",
	"Parent"
}

local function isOtherServicesFolder(inst)
	return type(inst) == "table" and inst.IsOtherServices == true
end

local function isRootDataModel(inst)
	if inst == game then
		return true
	end
	if type(inst) == "userdata" or type(inst) == "table" then
		local ok, cname = pcall(function()
			return tostring(inst.ClassName)
		end)
		if ok and (cname == "DataModel" or cname == "Ugc") then
			return true
		end
		local ok2, nm = pcall(function()
			return tostring(inst.Name)
		end)
		if ok2 and (nm == "DataModel" or nm == "Ugc") then
			return true
		end
	end
	return false
end

local function sanitizeText(str)
	if type(str) ~= "string" then
		str = tostring(str)
	end
	-- Strip non-printable/corrupted high bytes if external returns garbage in ClassName
	local cleaned = string.gsub(str, "[^\32-\126]", "")
	if cleaned == "" or #cleaned ~= #str then
		return ""
	end
	return cleaned
end

local function getSafeName(inst)
	if isOtherServicesFolder(inst) then
		return "OtherServices"
	end
	if isRootDataModel(inst) then
		return "DataModel"
	end
	local nm = "?"
	pcall(function()
		nm = tostring(inst.Name)
	end)
	local clean = sanitizeText(nm)
	return clean ~= "" and clean or nm
end

local function getSafeClass(inst)
	if isOtherServicesFolder(inst) then
		return "Folder"
	end
	if isRootDataModel(inst) then
		return "DataModel"
	end
	local cname = ""
	pcall(function()
		cname = tostring(inst.ClassName)
	end)
	local clean = sanitizeText(cname)
	if clean ~= "" then
		return clean
	end
	return getSafeName(inst)
end

local Explorer = {
	CurrentRoot = game,
	SelectedInstance = game,
	Visible = true,
	TreeScroll = 0,
	InspectorScroll = 0,
	WinX = 120,
	WinY = 90,
	WinW = 780,
	WinH = 460,
	HeaderH = 28,
	TreeW = 320,
	RowH = 20,
	Dragging = false,
	DragOffsetX = 0,
	DragOffsetY = 0,
	PrevMouseDown = false,
	Drawings = {},
	RowHitboxes = {},
	BackHitbox = nil,
	Running = true
}

local function createDrawing(drawType, props)
	local obj = Drawing.new(drawType)
	for k, v in pairs(props) do
		obj[k] = v
	end
	table.insert(Explorer.Drawings, obj)
	return obj
end

local function isPointInBox(px, py, x, y, w, h)
	return px >= x and px <= (x + w) and py >= y and py <= (y + h)
end

local function formatValue(val)
	local t = typeof(val)
	if t == "Instance" then
		return string.format("%s [%s]", getSafeName(val), getSafeClass(val))
	elseif t == "Vector3" or t == "Vector2" then
		return string.format("%.2f, %.2f%s", val.X, val.Y, t == "Vector3" and string.format(", %.2f", val.Z) or "")
	elseif t == "Color3" then
		return string.format("%d, %d, %d", math.round(val.R * 255), math.round(val.G * 255), math.round(val.B * 255))
	elseif t == "boolean" or t == "number" then
		return tostring(val)
	elseif t == "string" then
		local clean = sanitizeText(val)
		if clean == "" then
			clean = tostring(val)
		end
		if #clean > 40 then
			return string.format("\"%s...\"", string.sub(clean, 1, 40))
		end
		return string.format("\"%s\"", clean)
	else
		return string.format("<%s>", tostring(t))
	end
end

local function getSafeProperties(inst)
	if isOtherServicesFolder(inst) then
		return {
			{ key = "Name", val = "\"OtherServices\"" },
			{ key = "ClassName", val = "Folder" },
			{ key = "Parent", val = "DataModel" }
		}
	end

	local result = {}
	for _, propName in ipairs(CANDIDATE_PROPERTIES) do
		local ok, val = pcall(function()
			return inst[propName]
		end)
		if ok then
			local formatted = (propName == "ClassName") and getSafeClass(inst) or formatValue(val)
			table.insert(result, {
				key = propName,
				val = formatted
			})
		end
	end
	return result
end

local function getAttributesList(inst)
	if isOtherServicesFolder(inst) or isRootDataModel(inst) then
		return {}
	end

	local result = {}
	local ok, attrs = pcall(function()
		return inst:GetAttributes()
	end)
	if ok and type(attrs) == "table" then
		for k, v in pairs(attrs) do
			table.insert(result, {
				key = tostring(k),
				val = formatValue(v)
			})
		end
		table.sort(result, function(a, b)
			return a.key < b.key
		end)
	end
	return result
end

local function getUsefulServicesList()
	local list = {}
	for _, serviceName in ipairs(USEFUL_SERVICES) do
		local ok, svc = pcall(function()
			return game:GetService(serviceName)
		end)
		if ok and svc then
			table.insert(list, svc)
		end
	end
	return list
end

local function getOtherServicesList(dmRoot)
	local list = {}
	local sourceRoot = dmRoot or game
	local ok, children = pcall(function()
		return sourceRoot:GetChildren()
	end)
	if ok and type(children) == "table" then
		for _, child in ipairs(children) do
			local cname = getSafeClass(child)
			local nm = getSafeName(child)
			if not USEFUL_SET[cname] and not USEFUL_SET[nm] then
				table.insert(list, child)
			end
		end
	end
	return list
end

local function getSafeChildren(inst)
	if isOtherServicesFolder(inst) then
		return getOtherServicesList(game)
	end

	if isRootDataModel(inst) then
		local useful = getUsefulServicesList()
		local other = getOtherServicesList(inst)
		local result = {}
		for _, svc in ipairs(useful) do
			table.insert(result, svc)
		end
		if #other > 0 then
			table.insert(result, OTHER_SERVICES_FOLDER)
		end
		return result
	end

	local ok, children = pcall(function()
		return inst:GetChildren()
	end)
	if not ok or type(children) ~= "table" then
		return {}
	end
	return children
end

local function getDataModelPath(inst)
	if isOtherServicesFolder(inst) then
		return "DataModel.OtherServices"
	end
	if isRootDataModel(inst) then
		return "DataModel"
	end
	local full = getSafeName(inst)
	pcall(function()
		local rawFull = tostring(inst:GetFullName())
		local cleanFull = sanitizeText(rawFull)
		if cleanFull ~= "" then
			full = cleanFull
		end
	end)
	return "DataModel." .. full
end

-- UI Elements
local bgMain = createDrawing("Square", {
	Color = Color3.fromRGB(24, 24, 28),
	Filled = true,
	Thickness = 1,
	Visible = true,
	ZIndex = 1
})

local borderMain = createDrawing("Square", {
	Color = Color3.fromRGB(65, 65, 78),
	Filled = false,
	Thickness = 1,
	Visible = true,
	ZIndex = 2
})

local headerBar = createDrawing("Square", {
	Color = Color3.fromRGB(34, 34, 40),
	Filled = true,
	Visible = true,
	ZIndex = 2
})

local titleText = createDrawing("Text", {
	Text = "Capy'S Explorer",
	Color = Color3.fromRGB(235, 235, 245),
	Size = 14,
	Outline = true,
	Visible = true,
	ZIndex = 3
})

local dividerVert = createDrawing("Line", {
	Color = Color3.fromRGB(60, 60, 72),
	Thickness = 1,
	Visible = true,
	ZIndex = 2
})

local MAX_TREE_ROWS = math.floor((Explorer.WinH - Explorer.HeaderH - 28) / Explorer.RowH)
local MAX_INSP_ROWS = math.floor((Explorer.WinH - Explorer.HeaderH - 28) / Explorer.RowH)

local backBg = createDrawing("Square", {
	Color = Color3.fromRGB(45, 45, 55),
	Filled = true,
	Visible = true,
	ZIndex = 3
})

local backLabel = createDrawing("Text", {
	Text = ".. (Up)",
	Color = Color3.fromRGB(160, 200, 255),
	Size = 13,
	Outline = true,
	Visible = true,
	ZIndex = 4
})

local function makeBtn(labelStr)
	local bg = createDrawing("Square", {
		Color = Color3.fromRGB(48, 48, 60),
		Filled = true,
		Visible = true,
		ZIndex = 4
	})
	local txt = createDrawing("Text", {
		Text = labelStr,
		Color = Color3.fromRGB(235, 235, 245),
		Size = 13,
		Outline = true,
		Visible = true,
		ZIndex = 5
	})
	return { bg = bg, txt = txt, x = 0, y = 0, w = 22, h = 18 }
end

local btnTreeUp = makeBtn("^")
local btnTreeDown = makeBtn("v")
local btnInspUp = makeBtn("^")
local btnInspDown = makeBtn("v")

local treeRowBgs = {}
local treeRowTexts = {}
for i = 1, MAX_TREE_ROWS do
	treeRowBgs[i] = createDrawing("Square", {
		Color = Color3.fromRGB(30, 30, 36),
		Filled = true,
		Visible = false,
		ZIndex = 3
	})
	treeRowTexts[i] = createDrawing("Text", {
		Text = "",
		Color = Color3.fromRGB(220, 220, 230),
		Size = 13,
		Outline = true,
		Visible = false,
		ZIndex = 4
	})
end

local inspLines = {}
for i = 1, MAX_INSP_ROWS do
	inspLines[i] = createDrawing("Text", {
		Text = "",
		Color = Color3.fromRGB(215, 215, 225),
		Size = 13,
		Outline = true,
		Visible = false,
		ZIndex = 3
	})
end

local function positionBtn(btn, x, y, w, h)
	btn.x, btn.y, btn.w, btn.h = x, y, w, h
	btn.bg.Position = Vector2.new(x, y)
	btn.bg.Size = Vector2.new(w, h)
	btn.txt.Position = Vector2.new(x + math.floor(w / 2) - 4, y + 1)
end

local function updateLayoutPositions()
	local wx, wy = Explorer.WinX, Explorer.WinY
	local ww, wh = Explorer.WinW, Explorer.WinH
	local hh, tw, rh = Explorer.HeaderH, Explorer.TreeW, Explorer.RowH

	bgMain.Position = Vector2.new(wx, wy)
	bgMain.Size = Vector2.new(ww, wh)

	borderMain.Position = Vector2.new(wx, wy)
	borderMain.Size = Vector2.new(ww, wh)

	headerBar.Position = Vector2.new(wx, wy)
	headerBar.Size = Vector2.new(ww, hh)

	titleText.Position = Vector2.new(wx + 10, wy + 7)

	dividerVert.From = Vector2.new(wx + tw, wy + hh)
	dividerVert.To = Vector2.new(wx + tw, wy + wh)

	local topRowY = wy + hh + 4
	local topRowH = rh - 2
	backBg.Position = Vector2.new(wx + 4, topRowY)
	backBg.Size = Vector2.new(tw - 60, topRowH)
	backLabel.Position = Vector2.new(wx + 10, topRowY + 2)

	positionBtn(btnTreeUp, wx + tw - 52, topRowY, 22, topRowH)
	positionBtn(btnTreeDown, wx + tw - 26, topRowY, 22, topRowH)

	positionBtn(btnInspUp, wx + ww - 54, topRowY, 22, topRowH)
	positionBtn(btnInspDown, wx + ww - 28, topRowY, 22, topRowH)

	for i = 1, MAX_TREE_ROWS do
		local y = wy + hh + 26 + (i - 1) * rh
		treeRowBgs[i].Position = Vector2.new(wx + 4, y)
		treeRowBgs[i].Size = Vector2.new(tw - 8, rh - 2)
		treeRowTexts[i].Position = Vector2.new(wx + 10, y + 2)
	end

	local inspX = wx + tw + 10
	for i = 1, MAX_INSP_ROWS do
		local y = wy + hh + 26 + (i - 1) * rh
		inspLines[i].Position = Vector2.new(inspX, y)
	end
end

local function setAllVisible(state)
	for _, d in ipairs(Explorer.Drawings) do
		pcall(function()
			d.Visible = state
		end)
	end
end

local function resolveParent(root)
	if isOtherServicesFolder(root) then
		return game
	end
	if isRootDataModel(root) then
		return nil
	end
	local ok, p = pcall(function()
		return root.Parent
	end)
	if ok and p then
		if isRootDataModel(p) then
			return game
		end
		return p
	end
	return game
end

local function refreshUI()
	if not Explorer.Visible then
		setAllVisible(false)
		return
	end

	updateLayoutPositions()

	bgMain.Visible = true
	borderMain.Visible = true
	headerBar.Visible = true
	titleText.Visible = true
	dividerVert.Visible = true
	backBg.Visible = true
	backLabel.Visible = true
	btnTreeUp.bg.Visible = true
	btnTreeUp.txt.Visible = true
	btnTreeDown.bg.Visible = true
	btnTreeDown.txt.Visible = true
	btnInspUp.bg.Visible = true
	btnInspUp.txt.Visible = true
	btnInspDown.bg.Visible = true
	btnInspDown.txt.Visible = true

	local wx, wy, hh, tw, rh = Explorer.WinX, Explorer.WinY, Explorer.HeaderH, Explorer.TreeW, Explorer.RowH

	local rootPath = getDataModelPath(Explorer.CurrentRoot)
	if #rootPath > 55 then
		rootPath = "..." .. string.sub(rootPath, -52)
	end
	titleText.Text = "Capy'S Explorer | Path: " .. tostring(rootPath)
	local parentInst = resolveParent(Explorer.CurrentRoot)
	Explorer.BackHitbox = {
		x = wx + 4,
		y = wy + hh + 4,
		w = tw - 60,
		h = rh - 2,
		target = parentInst
	}

	if parentInst then
		local pName = isRootDataModel(parentInst) and "DataModel" or getSafeName(parentInst)
		backLabel.Text = ".. (Up: " .. pName .. ")"
		backLabel.Color = Color3.fromRGB(160, 200, 255)
	else
		backLabel.Text = ".. (DataModel Root)"
		backLabel.Color = Color3.fromRGB(115, 115, 125)
	end

	local children = getSafeChildren(Explorer.CurrentRoot)
	local maxTreeScroll = math.max(0, #children - MAX_TREE_ROWS)
	Explorer.TreeScroll = math.clamp(Explorer.TreeScroll, 0, maxTreeScroll)
	Explorer.RowHitboxes = {}

	for i = 1, MAX_TREE_ROWS do
		local idx = i + Explorer.TreeScroll
		local child = children[idx]
		local bg = treeRowBgs[i]
		local txt = treeRowTexts[i]

		if child then
			local isSelected = (child == Explorer.SelectedInstance)
			local hasKids = #getSafeChildren(child) > 0
			local cName = getSafeName(child)
			local cClass = getSafeClass(child)

			bg.Visible = true
			bg.Color = isSelected and Color3.fromRGB(60, 85, 130) or Color3.fromRGB(30, 30, 36)

			txt.Visible = true
			txt.Text = string.format("%s %s [%s]", hasKids and "+" or "-", cName, cClass)
			txt.Color = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(220, 220, 230)

			table.insert(Explorer.RowHitboxes, {
				x = bg.Position.X,
				y = bg.Position.Y,
				w = bg.Size.X,
				h = bg.Size.Y,
				instance = child
			})
		else
			bg.Visible = false
			txt.Visible = false
		end
	end

	local lines = {}
	local target = Explorer.SelectedInstance
	if target then
		local tClass = getSafeClass(target)
		local tFull = getDataModelPath(target)

		table.insert(lines, { text = "--- INFO ---", color = Color3.fromRGB(130, 210, 255) })
		table.insert(lines, { text = "ClassName: " .. tClass, color = Color3.fromRGB(240, 240, 245) })
		table.insert(lines, { text = "FullName: " .. tFull, color = Color3.fromRGB(190, 190, 205) })

		table.insert(lines, { text = "--- PROPERTIES ---", color = Color3.fromRGB(130, 210, 255) })
		local props = getSafeProperties(target)
		for _, p in ipairs(props) do
			table.insert(lines, {
				text = string.format("%s: %s", p.key, p.val),
				color = Color3.fromRGB(225, 225, 235)
			})
		end

		table.insert(lines, { text = "--- ATTRIBUTES ---", color = Color3.fromRGB(130, 210, 255) })
		local attrs = getAttributesList(target)
		if #attrs == 0 then
			table.insert(lines, { text = "(no attributes)", color = Color3.fromRGB(140, 140, 155) })
		else
			for _, a in ipairs(attrs) do
				table.insert(lines, {
					text = string.format("%s = %s", a.key, a.val),
					color = Color3.fromRGB(185, 240, 185)
				})
			end
		end
	end

	local maxInspScroll = math.max(0, #lines - MAX_INSP_ROWS)
	Explorer.InspectorScroll = math.clamp(Explorer.InspectorScroll, 0, maxInspScroll)

	for i = 1, MAX_INSP_ROWS do
		local entry = lines[i + Explorer.InspectorScroll]
		local lineObj = inspLines[i]
		if entry then
			lineObj.Visible = true
			lineObj.Text = entry.text
			lineObj.Color = entry.color
		else
			lineObj.Visible = false
		end
	end
end

local function handleClick(mx, my)
	if isPointInBox(mx, my, btnTreeUp.x, btnTreeUp.y, btnTreeUp.w, btnTreeUp.h) then
		Explorer.TreeScroll = Explorer.TreeScroll - 4
		refreshUI()
		return
	end
	if isPointInBox(mx, my, btnTreeDown.x, btnTreeDown.y, btnTreeDown.w, btnTreeDown.h) then
		Explorer.TreeScroll = Explorer.TreeScroll + 4
		refreshUI()
		return
	end
	if isPointInBox(mx, my, btnInspUp.x, btnInspUp.y, btnInspUp.w, btnInspUp.h) then
		Explorer.InspectorScroll = Explorer.InspectorScroll - 4
		refreshUI()
		return
	end
	if isPointInBox(mx, my, btnInspDown.x, btnInspDown.y, btnInspDown.w, btnInspDown.h) then
		Explorer.InspectorScroll = Explorer.InspectorScroll + 4
		refreshUI()
		return
	end

	local back = Explorer.BackHitbox
	if back and back.target and isPointInBox(mx, my, back.x, back.y, back.w, back.h) then
		Explorer.CurrentRoot = back.target
		Explorer.SelectedInstance = back.target
		Explorer.TreeScroll = 0
		Explorer.InspectorScroll = 0
		refreshUI()
		return
	end

	for _, box in ipairs(Explorer.RowHitboxes) do
		if isPointInBox(mx, my, box.x, box.y, box.w, box.h) then
			Explorer.SelectedInstance = box.instance
			Explorer.InspectorScroll = 0
			if #getSafeChildren(box.instance) > 0 then
				Explorer.CurrentRoot = box.instance
				Explorer.TreeScroll = 0
			end
			refreshUI()
			return
		end
	end
end

pcall(function()
	Mouse.KeyDown:Connect(function(key)
		if key == "0" then
			Explorer.Visible = not Explorer.Visible
			refreshUI()
		end
	end)
end)

task.spawn(function()
	while Explorer.Running do
		local mx, my = 0, 0
		local mOk = pcall(function()
			mx = Mouse.X
			my = Mouse.Y
		end)

		if mOk and Explorer.Visible then
			local down = isLeftMouseDown()
			local justPressed = down and (not Explorer.PrevMouseDown)
			local justReleased = (not down) and Explorer.PrevMouseDown

			if justPressed then
				if isPointInBox(mx, my, Explorer.WinX, Explorer.WinY, Explorer.WinW, Explorer.HeaderH) then
					Explorer.Dragging = true
					Explorer.DragOffsetX = mx - Explorer.WinX
					Explorer.DragOffsetY = my - Explorer.WinY
				else
					handleClick(mx, my)
				end
			end

			if Explorer.Dragging then
				if down then
					Explorer.WinX = mx - Explorer.DragOffsetX
					Explorer.WinY = my - Explorer.DragOffsetY
					refreshUI()
				elseif justReleased then
					Explorer.Dragging = false
				end
			end

			Explorer.PrevMouseDown = down
		end

		if RunService and RunService.RenderStepped then
			RunService.RenderStepped:Wait()
		else
			task.wait(0.016)
		end
	end
end)

function Explorer:Destroy()
	self.Running = false
	for _, d in ipairs(self.Drawings) do
		pcall(function()
			d:Remove()
		end)
	end
	table.clear(self.Drawings)
	_G.DataModelExplorer = nil
end

_G.DataModelExplorer = Explorer
refreshUI()
