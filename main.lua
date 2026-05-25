--[[
 ENI MOBILE HUB v6.2
 MODERN UI + PERFECT 3D MOBILE FLY (UP/DOWN FIXED)
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
	Noclip = false,
	ClickTP = false,
	FlySpeed = 90
}

local Connections = {}

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
--       MODERN UI SETUP
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
Main.Size = UDim2.new(0, 320, 0, 360)
Main.Position = UDim2.new(0.5, -160, 0.5, -180)
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
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -24, 0, 35)
TabBar.Position = UDim2.new(0, 12, 0, 45)
TabBar.BackgroundTransparency = 1
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
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 95)
	page.BorderSizePixel = 0
	
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.Parent = Content

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = page
	
	local pad = Instance.new("UIPadding", page)
	pad.PaddingRight = UDim.new(0, 6)

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

local function CreateTab(name)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0.33, -4, 1, 0)
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
local TeleportPage = CreatePage("Teleport")
local UtilityPage = CreatePage("Utility")

CreateTab("Movement")
CreateTab("Teleport")
CreateTab("Utility")

SwitchPage("Movement")

--// MODERN BUTTON COMPONENT
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
		callback()
	end)
	return b
end

--=============================
--        LOGIC & CHEATS
--=============================

--// FLY 
local FlyVel
local FlyAtt

local function StopFly()
	State.Fly = false
	State.Noclip = false

	local c,h = GetChar()
	if h then h.PlatformStand = false end

	if FlyVel then FlyVel:Destroy() FlyVel = nil end
	if FlyAtt then FlyAtt:Destroy() FlyAtt = nil end
	Notify("ENI", "Fly & Noclip Disabled")
end

local function StartFly()
	if State.Fly then return end
	local c,h,hrp = GetChar()
	if not hrp then return end

	State.Fly = true
	State.Noclip = true
	h.PlatformStand = true

	FlyAtt = Instance.new("Attachment", hrp)
	FlyVel = Instance.new("LinearVelocity")
	FlyVel.Attachment0 = FlyAtt
	FlyVel.MaxForce = math.huge
	FlyVel.VectorVelocity = Vector3.zero
	FlyVel.RelativeTo = Enum.ActuatorRelativeTo.World
	FlyVel.Parent = hrp

	hrp.AssemblyLinearVelocity = Vector3.zero
	Notify("ENI", "Fly & Noclip Enabled")
end

Connect(LP.CharacterAdded, function()
	if State.Fly then StopFly() end
	if State.Noclip then State.Noclip = false end
end)

--// 3D MOBILE FLY LOOP (PERFECTED)
Connect(RunService.RenderStepped,function()
	if not State.Fly or not FlyVel then return end
	local c,h,hrp = GetChar()
	if not hrp then return end

	local move = h.MoveDirection
	local velocity = Vector3.zero

	if move.Magnitude > 0 then
		local cam = Workspace.CurrentCamera
		if cam then
			local camCF = cam.CFrame
			
			-- Получаем только угол поворота влево-вправо (Yaw)
			local _, yaw, _ = camCF:ToOrientation()
			
			-- Создаем "плоский" CFrame без наклона вверх/вниз
			local flatCF = CFrame.Angles(0, yaw, 0)
			
			-- Преобразуем движение джойстика в локальные оси (вперед/назад, влево/вправо)
			local localInput = flatCF:VectorToObjectSpace(move)
			
			-- Накладываем эти оси на реальный 3D-угол камеры
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
end)

--// NOCLIP
Connect(RunService.Stepped,function()
	if not State.Noclip then return end
	local c = GetChar()
	if not c then return end
	for _,v in pairs(c:GetDescendants()) do
		if v:IsA("BasePart") then v.CanCollide = false end
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

--// BUTTONS BINDING
Button(MovementPage, "Toggle Fly", function()
	if State.Fly then StopFly() else StartFly() end
end)

Button(MovementPage, "Toggle Noclip", function()
	State.Noclip = not State.Noclip
	Notify("ENI", "Noclip: " .. tostring(State.Noclip))
end)

Button(MovementPage, "Fly Speed +10", function()
	State.FlySpeed += 10
	Notify("ENI", "Speed: " .. State.FlySpeed)
end)

Button(MovementPage, "Fly Speed -10", function()
	State.FlySpeed -= 10
	Notify("ENI", "Speed: " .. State.FlySpeed)
end)

Button(TeleportPage, "Toggle ClickTP", function()
	State.ClickTP = not State.ClickTP
	Notify("ENI", "ClickTP: " .. tostring(State.ClickTP) .. " (Double Tap)")
end)

Button(UtilityPage, "Hide GUI", function()
	Main.Visible = false
end)

Button(UtilityPage, "Destroy Script", function()
	for _,v in pairs(Connections) do pcall(function() v:Disconnect() end) end
	if State.Fly then StopFly() end
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

Notify("ENI HUB", "Loaded v6.2")
Main.Visible = true
