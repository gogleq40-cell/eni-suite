--[[
 ENI MOBILE HUB v7.2
 DIRECT SLIDERS + CFRAME SPEEDHACK
]]

--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer

--// SECURE PARENTING
local ParentTarget = (gethui and gethui()) or CoreGui or LP:WaitForChild("PlayerGui")

--// REMOVE OLD
pcall(function()
	local old = ParentTarget:FindFirstChild("ENI_MOBILE")
	if old then old:Destroy() end
end)

--// STATE
local State = {
	Fly = false,
	FlySpeed = 90,
	Noclip = false,
	ClickTP = false,
	WalkSpeed = 16,
	JumpPower = 50,
	InfJump = false,
	GodMode = false,
	ESP = false,
	Chams = false,
	Speedhack = 0 -- Новая функция!
}

local Connections = {}
local TargetPlayer = nil

local function Connect(signal, func)
	local c = signal:Connect(func)
	table.insert(Connections, c)
	return c
end

local function Notify(title, text)
	pcall(function()
		StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 3})
	end)
end

local function GetChar()
	local c = LP.Character
	if not c then return end
	local h = c:FindFirstChildOfClass("Humanoid")
	local hrp = c:FindFirstChild("HumanoidRootPart")
	if not h or not hrp then return end
	return c, h, hrp
end

--=============================
--       PREMIUM UI SETUP
--=============================

local GUI = Instance.new("ScreenGui")
GUI.Name = "ENI_MOBILE"
GUI.ResetOnSpawn = false
GUI.Parent = ParentTarget

--// FLOAT BUTTON
local Float = Instance.new("TextButton")
Float.Size = UDim2.new(0, 50, 0, 50)
Float.Position = UDim2.new(0, 15, 0.5, -25)
Float.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Float.Text = "E"
Float.TextColor3 = Color3.fromRGB(99, 102, 241)
Float.Font = Enum.Font.GothamBold
Float.TextSize = 22
Float.Parent = GUI

Instance.new("UICorner", Float).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(99, 102, 241)
FloatStroke.Thickness = 2
FloatStroke.Parent = Float

--// MAIN MENU
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 340, 0, 380)
Main.Position = UDim2.new(0.5, -170, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = GUI

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 55)
MainStroke.Thickness = 1
MainStroke.Parent = Main

--// TITLE
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = " ENI MOBILE HUB"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local TitlePad = Instance.new("UIPadding", Title)
TitlePad.PaddingLeft = UDim.new(0, 15)

--// TAB BAR
local TabBar = Instance.new("ScrollingFrame")
TabBar.Size = UDim2.new(1, -24, 0, 35)
TabBar.Position = UDim2.new(0, 12, 0, 45)
TabBar.BackgroundTransparency = 1
TabBar.ScrollBarThickness = 0
TabBar.CanvasSize = UDim2.new(1.3, 0, 0, 0)
TabBar.Parent = Main

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 6)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabBar

--// CONTENT AREA
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -24, 1, -95)
Content.Position = UDim2.new(0, 12, 0, 90)
Content.BackgroundTransparency = 1
Content.Parent = Main

--// PAGES SYSTEM 
local Pages = {}
local TabButtons = {}

local function CreatePage(name)
	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.ScrollBarThickness = 2
	page.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 95)
	page.BorderSizePixel = 0
	
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.Parent = Content

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = page
	
	local pad = Instance.new("UIPadding", page)
	pad.PaddingRight = UDim.new(0, 8)

	Pages[name] = page
	return page
end

local function SwitchPage(name)
	for _,v in pairs(Pages) do v.Visible = false end
	for tName, btn in pairs(TabButtons) do
		if tName == name then
			btn.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
			btn.TextColor3 = Color3.new(1, 1, 1)
		else
			btn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
			btn.TextColor3 = Color3.fromRGB(180, 180, 180)
		end
	end
	Pages[name].Visible = true
end

local function CreateTab(name, width)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, width, 1, 0)
	b.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
	b.Text = name
	b.TextColor3 = Color3.fromRGB(180, 180, 180)
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 12
	b.Parent = TabBar

	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

	b.MouseButton1Click:Connect(function()
		SwitchPage(name)
	end)
	TabButtons[name] = b
end

local MovementPage = CreatePage("Movement")
local PlayerPage = CreatePage("Player")
local VisualsPage = CreatePage("Visuals")
local TeleportPage = CreatePage("Teleport")
local UtilityPage = CreatePage("Utility")

CreateTab("Movement", 80)
CreateTab("Player", 60)
CreateTab("Visuals", 65)
CreateTab("Teleport", 75)
CreateTab("Utility", 60)

SwitchPage("Movement")

--// PREMIUM COMPONENTS
local function Button(parent, text, callback)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 42)
	b.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
	b.Text = text
	b.TextColor3 = Color3.fromRGB(220, 220, 220)
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 14
	b.Parent = parent

	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(45, 45, 55)
	stroke.Parent = b

	b.MouseButton1Click:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(99, 102, 241)}):Play()
		task.wait(0.1)
		TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 32)}):Play()
		callback(b)
	end)
	return b
end

local function Toggle(parent, text, defaultState, callback)
	local state = defaultState or false
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 42)
	b.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
	b.Text = ""
	b.Parent = parent

	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(45, 45, 55)
	stroke.Parent = b

	local label = Instance.new("TextLabel", b)
	label.Size = UDim2.new(1, -50, 1, 0)
	label.Position = UDim2.new(0, 15, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left

	local indicator = Instance.new("Frame", b)
	indicator.Size = UDim2.new(0, 20, 0, 20)
	indicator.Position = UDim2.new(1, -32, 0.5, -10)
	indicator.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 6)
	
	local function updateVis()
		if state then
			TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(99, 102, 241)}):Play()
			TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(99, 102, 241)}):Play()
		else
			TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}):Play()
			TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(45, 45, 55)}):Play()
		end
	end
	updateVis()

	b.MouseButton1Click:Connect(function()
		state = not state
		updateVis()
		callback(state)
	end)
	
	return b
end

local function Slider(parent, text, min, max, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 55)
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
	frame.Parent = parent

	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(45, 45, 55)
	stroke.Parent = frame

	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(1, -20, 0, 25)
	label.Position = UDim2.new(0, 15, 0, 4)
	label.BackgroundTransparency = 1
	label.Text = text .. ": " .. default
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left

	local bg = Instance.new("Frame", frame)
	bg.Size = UDim2.new(1, -30, 0, 6)
	bg.Position = UDim2.new(0, 15, 0, 35)
	bg.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame", bg)
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local btn = Instance.new("TextButton", bg)
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.Position = UDim2.new(0,0,-2,0)
	btn.Size = UDim2.new(1,0,5,0)
	btn.BackgroundTransparency = 1
	btn.Text = ""

	local dragging = false
	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)
	btn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	Connect(UIS.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local relativeX = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
			fill.Size = UDim2.new(relativeX, 0, 1, 0)
			local val = math.floor(min + ((max - min) * relativeX))
			label.Text = text .. ": " .. val
			callback(val)
		end
	end)
end

--=============================
--        LOGIC & CHEATS
--=============================

--// FLY 
local FlyVel
local FlyAtt

local function StopFly()
	State.Fly = false
	local c,h = GetChar()
	if h then h.PlatformStand = false end
	if FlyVel then FlyVel:Destroy() FlyVel = nil end
	if FlyAtt then FlyAtt:Destroy() FlyAtt = nil end
end

local function StartFly()
	if State.Fly then return end
	local c,h,hrp = GetChar()
	if not hrp then return end

	State.Fly = true
	h.PlatformStand = true

	FlyAtt = Instance.new("Attachment", hrp)
	FlyVel = Instance.new("LinearVelocity")
	FlyVel.Attachment0 = FlyAtt
	FlyVel.MaxForce = math.huge
	FlyVel.VectorVelocity = Vector3.zero
	FlyVel.RelativeTo = Enum.ActuatorRelativeTo.World
	FlyVel.Parent = hrp
	hrp.AssemblyLinearVelocity = Vector3.zero
end

Connect(LP.CharacterAdded, function()
	if State.Fly then StopFly() end
	State.Noclip = false
	State.GodMode = false
end)

--// RENDER STEPPED (Fly, Movement Mods, ESP)
Connect(RunService.RenderStepped,function()
	local c,h,hrp = GetChar()
	
	-- FLY LOGIC
	if State.Fly and FlyVel and hrp and h then
		local move = h.MoveDirection
		local velocity = Vector3.zero

		if move.Magnitude > 0 then
			local cam = Workspace.CurrentCamera
			if cam then
				local camCF = cam.CFrame
				local _, yaw, _ = camCF:ToOrientation()
				local flatCF = CFrame.Angles(0, yaw, 0)
				local localInput = flatCF:VectorToObjectSpace(move)
				local move3D = camCF:VectorToWorldSpace(localInput)
				if move3D.Magnitude > 0 then
					velocity = move3D.Unit * State.FlySpeed
				end
			else
				velocity = move * State.FlySpeed
			end
		end
		FlyVel.VectorVelocity = velocity
		hrp.AssemblyAngularVelocity = Vector3.zero
	end
	
	-- SPEED & JUMP MODS (Абсолютный контроль, всегда ставим значение со слайдера)
	if h then
		h.WalkSpeed = State.WalkSpeed
		h.UseJumpPower = true
		h.JumpPower = State.JumpPower
	end
	
	-- CFRAME SPEEDHACK
	if State.Speedhack > 0 and h and hrp and h.MoveDirection.Magnitude > 0 and not State.Fly then
		-- Сдвигает персонажа на дополнительные стады микротелепортами (bypasses WalkSpeed)
		hrp.CFrame = hrp.CFrame + (h.MoveDirection * (State.Speedhack / 5))
	end
	
	-- ESP & CHAMS LOGIC
	if State.ESP or State.Chams then
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local targetHrp = p.Character.HumanoidRootPart
				
				-- Chams
				if State.Chams then
					local hl = p.Character:FindFirstChild("ENI_Chams")
					if not hl then
						hl = Instance.new("Highlight")
						hl.Name = "ENI_Chams"
						hl.FillColor = Color3.fromRGB(99, 102, 241)
						hl.OutlineColor = Color3.fromRGB(255, 255, 255)
						hl.Parent = p.Character
					end
					hl.Enabled = true
				else
					local hl = p.Character:FindFirstChild("ENI_Chams")
					if hl then hl.Enabled = false end
				end

				-- ESP Names
				if State.ESP then
					local bg = targetHrp:FindFirstChild("ENI_ESP")
					if not bg then
						bg = Instance.new("BillboardGui")
						bg.Name = "ENI_ESP"
						bg.Size = UDim2.new(0, 200, 0, 50)
						bg.StudsOffset = Vector3.new(0, 3, 0)
						bg.AlwaysOnTop = true
						
						local txt = Instance.new("TextLabel")
						txt.Size = UDim2.new(1, 0, 1, 0)
						txt.BackgroundTransparency = 1
						txt.Text = p.Name
						txt.TextColor3 = Color3.fromRGB(255, 255, 255)
						txt.TextStrokeTransparency = 0.5
						txt.Font = Enum.Font.GothamBold
						txt.TextSize = 14
						txt.Parent = bg
						bg.Parent = targetHrp
					end
					bg.Enabled = true
				else
					local bg = targetHrp:FindFirstChild("ENI_ESP")
					if bg then bg.Enabled = false end
				end
			end
		end
	end
end)

--// CLEAN ESP
local function CleanESP()
	for _, p in pairs(Players:GetPlayers()) do
		if p.Character then
			local bg = p.Character:FindFirstChild("HumanoidRootPart") and p.Character.HumanoidRootPart:FindFirstChild("ENI_ESP")
			if bg then bg:Destroy() end
			local hl = p.Character:FindFirstChild("ENI_Chams")
			if hl then hl:Destroy() end
		end
	end
end

--// STEPPED (Noclip & GodMode)
Connect(RunService.Stepped,function()
	local c, h = GetChar()
	if not c then return end
	
	-- GodMode Logic (Infinite Health)
	if State.GodMode and h then
		h.MaxHealth = math.huge
		h.Health = math.huge
	end

	-- Noclip Logic
	if State.Noclip then
		for _,v in pairs(c:GetDescendants()) do
			if v:IsA("BasePart") then v.CanCollide = false end
		end
	end
end)

--// INF JUMP
Connect(UIS.JumpRequest, function()
	if State.InfJump then
		local c, h = GetChar()
		if h then
			h:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

--// CLICK TP
local lastTapTime = 0
Connect(UIS.InputBegan,function(input,gp)
	if gp or not State.ClickTP then return end
	if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

	local currentTime = tick()
	if currentTime - lastTapTime < 0.3 then
		local cam = Workspace.CurrentCamera
		if not cam then return end

		local pos = input.Position 
		local ray = cam:ViewportPointToRay(pos.X,pos.Y)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude

		local c = GetChar()
		if c then params.FilterDescendantsInstances = {c} end

		local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
		if result then
			local _,_,hrp = GetChar()
			if hrp then hrp.CFrame = CFrame.new(result.Position + Vector3.new(0,5,0)) end
		end
		lastTapTime = 0 
	else
		lastTapTime = currentTime
	end
end)

--=============================
--       PAGES BINDING
--=============================

--// MOVEMENT 
Toggle(MovementPage, "Enable Fly", false, function(val)
	if val then StartFly() else StopFly() end
end)

Slider(MovementPage, "Fly Speed", 10, 300, 90, function(val)
	State.FlySpeed = val
end)

Toggle(MovementPage, "Enable Noclip", false, function(val)
	State.Noclip = val
end)

--// PLAYER (Прямое управление)
Toggle(PlayerPage, "God Mode (Invincible)", false, function(val)
	State.GodMode = val
end)

Toggle(PlayerPage, "Infinite Jump", false, function(val)
	State.InfJump = val
end)

-- Ползунки без тумблеров. Стандартное значение: WalkSpeed=16, Jump=50
Slider(PlayerPage, "WalkSpeed", 16, 200, 16, function(val)
	State.WalkSpeed = val
end)

Slider(PlayerPage, "JumpPower", 50, 300, 50, function(val)
	State.JumpPower = val
end)

Slider(PlayerPage, "CFrame Speedhack", 0, 10, 0, function(val)
	State.Speedhack = val
end)

--// VISUALS
Toggle(VisualsPage, "Player Names (ESP)", false, function(val)
	State.ESP = val
	if not val and not State.Chams then CleanESP() end
end)

Toggle(VisualsPage, "Player Chams", false, function(val)
	State.Chams = val
	if not val and not State.ESP then CleanESP() end
end)

--// TELEPORT
Toggle(TeleportPage, "Double-Tap ClickTP", false, function(val)
	State.ClickTP = val
end)

Button(TeleportPage, "Target: None", function(btn)
	local valid = {}
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LP then table.insert(valid, p) end
	end
	if #valid == 0 then Notify("ENI", "No other players found") return end
	
	local currentIndex = TargetPlayer and table.find(valid, TargetPlayer) or 0
	local nextIndex = (currentIndex % #valid) + 1
	TargetPlayer = valid[nextIndex]
	
	btn.Text = "Target: " .. TargetPlayer.Name
end)

Button(TeleportPage, "Teleport To Target", function()
	if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local _,_,hrp = GetChar()
		if hrp then
			hrp.CFrame = TargetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
			Notify("ENI", "Teleported to " .. TargetPlayer.Name)
		end
	else
		Notify("ENI", "Target is dead or invalid")
	end
end)

--// UTILITY
Button(UtilityPage, "Hide GUI", function()
	Main.Visible = false
end)

Button(UtilityPage, "Destroy Script", function()
	for _,v in pairs(Connections) do pcall(function() v:Disconnect() end) end
	if State.Fly then StopFly() end
	CleanESP()
	GUI:Destroy()
end)

--=============================
--        DRAGGING LOGIC
--=============================

Float.MouseButton1Click:Connect(function()
	Main.Visible = not Main.Visible
end)

local function MakeDraggable(UIElement, DragArea)
	local dragging, dragStart, startPos
	DragArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = UIElement.Position
		end
	end)
	DragArea.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	Connect(UIS.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
			local delta = input.Position - dragStart
			UIElement.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

MakeDraggable(Float, Float)
MakeDraggable(Main, Title)

Notify("ENI HUB", "Loaded v7.2 - Спидхак")
Main.Visible = true
