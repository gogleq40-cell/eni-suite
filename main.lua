--[[
    ENI MOBILE HUB v5
    FULL MOBILE REWORK
    Tabs + Modern GUI + Better Fly
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

--// REMOVE OLD
pcall(function()
    local old = CoreGui:FindFirstChild("ENI_MOBILE_V5")
    if old then
        old:Destroy()
    end
end)

--// STATE
local State = {
    Fly = false,
    Noclip = false,
    ClickTP = false,
    FlySpeed = 90
}

--// CONNECTIONS
local Connections = {}

local function Connect(signal, func)
    local c = signal:Connect(func)
    table.insert(Connections, c)
    return c
end

--// NOTIFY
local function Notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 4
        })
    end)
end

--// CHARACTER
local function GetChar()
    local c = LP.Character
    if not c then return end

    local h = c:FindFirstChildOfClass("Humanoid")
    local hrp = c:FindFirstChild("HumanoidRootPart")

    if not h or not hrp then
        return
    end

    return c, h, hrp
end

--// GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = "ENI_MOBILE_V5"
GUI.ResetOnSpawn = false
GUI.Parent = CoreGui

--// FLOATING BUTTON
local Float = Instance.new("TextButton")
Float.Size = UDim2.new(0,70,0,70)
Float.Position = UDim2.new(0,20,0.5,-35)
Float.BackgroundColor3 = Color3.fromRGB(110,80,255)
Float.Text = "ENI"
Float.TextColor3 = Color3.new(1,1,1)
Float.Font = Enum.Font.GothamBold
Float.TextSize = 22
Float.Parent = GUI

Instance.new("UICorner", Float).CornerRadius = UDim.new(1,0)

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(180,160,255)
FloatStroke.Thickness = 2
FloatStroke.Parent = Float

--// MAIN
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,460,0,300)
Main.Position = UDim2.new(0.5,-230,0.5,-150)
Main.BackgroundColor3 = Color3.fromRGB(20,20,28)
Main.Parent = GUI

Instance.new("UICorner", Main).CornerRadius = UDim.new(0,16)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(90,70,220)
MainStroke.Thickness = 2
MainStroke.Parent = Main

--// TITLE
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,45)
Title.BackgroundTransparency = 1
Title.Text = "⚡ ENI MOBILE HUB"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = Main

--// TAB BAR
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1,-20,0,40)
TabBar.Position = UDim2.new(0,10,0,50)
TabBar.BackgroundTransparency = 1
TabBar.Parent = Main

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0,8)
TabLayout.Parent = TabBar

--// CONTENT
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,-20,1,-100)
Content.Position = UDim2.new(0,10,0,95)
Content.BackgroundTransparency = 1
Content.Parent = Main

--// PAGES
local Pages = {}

local function CreatePage(name)
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,8)
    layout.Parent = page

    Pages[name] = page
    return page
end

local function SwitchPage(name)
    for _,v in pairs(Pages) do
        v.Visible = false
    end

    Pages[name].Visible = true
end

local function CreateTab(name)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,130,1,0)
    b.BackgroundColor3 = Color3.fromRGB(35,35,50)
    b.Text = name
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Parent = TabBar

    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)

    b.MouseButton1Click:Connect(function()
        SwitchPage(name)
    end)
end

local MovementPage = CreatePage("Movement")
local TeleportPage = CreatePage("Teleport")
local UtilityPage = CreatePage("Utility")

CreateTab("Movement")
CreateTab("Teleport")
CreateTab("Utility")

SwitchPage("Movement")

--// BUTTON
local function Button(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,40)
    b.BackgroundColor3 = Color3.fromRGB(32,32,44)
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 15
    b.Parent = parent

    Instance.new("UICorner", b).CornerRadius = UDim.new(0,12)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80,60,180)
    stroke.Parent = b

    b.MouseButton1Click:Connect(function()
        TweenService:Create(b,TweenInfo.new(.15),{
            BackgroundColor3 = Color3.fromRGB(70,50,180)
        }):Play()

        task.wait(.1)

        TweenService:Create(b,TweenInfo.new(.2),{
            BackgroundColor3 = Color3.fromRGB(32,32,44)
        }):Play()

        callback()
    end)

    return b
end

--// FLY
local FlyVel

local function StartFly()
    if State.Fly then return end

    local c,h,hrp = GetChar()
    if not hrp then return end

    State.Fly = true

    h.PlatformStand = true
    h.AutoRotate = false

    FlyVel = Instance.new("BodyVelocity")
    FlyVel.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
    FlyVel.Velocity = Vector3.zero
    FlyVel.Parent = hrp

    Notify("ENI","Fly Enabled")
end

local function StopFly()
    State.Fly = false

    local c,h = GetChar()

    if h then
        h.PlatformStand = false
        h.AutoRotate = true
    end

    if FlyVel then
        FlyVel:Destroy()
        FlyVel = nil
    end

    Notify("ENI","Fly Disabled")
end

Connect(RunService.RenderStepped,function()
    if not State.Fly then
        return
    end

    local c,h,hrp = GetChar()

    if not hrp then
        return
    end

    local cam = Workspace.CurrentCamera

    if not cam then
        return
    end

    local move = h.MoveDirection

    -- ВПЕРЕД/НАЗАД ПО КАМЕРЕ
    local velocity = Vector3.new(
        move.X,
        0,
        move.Z
    ) * State.FlySpeed

    -- ВВЕРХ/ВНИЗ КАМЕРОЙ
    local lookY = cam.CFrame.LookVector.Y

    velocity += Vector3.new(
        0,
        lookY * State.FlySpeed,
        0
    )

    FlyVel.Velocity = velocity

    -- АНТИ КРУТКА
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.RotVelocity = Vector3.zero
end)

--// NOCLIP
Connect(RunService.Stepped,function()
    if not State.Noclip then return end

    local c = GetChar()
    if not c then return end

    for _,v in pairs(c:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end)

--// CLICK TP
Connect(UIS.InputBegan,function(input,gp)
    if gp then return end
    if not State.ClickTP then return end

    if input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local cam = Workspace.CurrentCamera
    if not cam then return end

    local pos = UIS:GetMouseLocation()

    local ray = cam:ViewportPointToRay(pos.X,pos.Y)

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude

    local c = GetChar()

    if c then
        params.FilterDescendantsInstances = {c}
    end

    local result = Workspace:Raycast(
        ray.Origin,
        ray.Direction * 1000,
        params
    )

    if result then
        local _,_,hrp = GetChar()

        if hrp then
            hrp.CFrame = CFrame.new(result.Position + Vector3.new(0,5,0))
        end
    end
end)

--// MOVEMENT PAGE
Button(MovementPage,"Toggle Fly",function()
    if State.Fly then
        StopFly()
    else
        StartFly()
    end
end)

Button(MovementPage,"Toggle Noclip",function()
    State.Noclip = not State.Noclip
    Notify("ENI","Noclip: "..tostring(State.Noclip))
end)

Button(MovementPage,"Fly Speed +",function()
    State.FlySpeed += 10
    Notify("ENI","Speed: "..State.FlySpeed)
end)

Button(MovementPage,"Fly Speed -",function()
    State.FlySpeed -= 10
    Notify("ENI","Speed: "..State.FlySpeed)
end)

--// TP PAGE
Button(TeleportPage,"Toggle ClickTP",function()
    State.ClickTP = not State.ClickTP
    Notify("ENI","ClickTP: "..tostring(State.ClickTP))
end)

--// UTILITY PAGE
Button(UtilityPage,"Hide GUI",function()
    Main.Visible = false
end)

Button(UtilityPage,"Destroy Script",function()
    for _,v in pairs(Connections) do
        pcall(function()
            v:Disconnect()
        end)
    end

    GUI:Destroy()
end)

--// FLOAT TOGGLE
Float.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

--// FLOAT DRAG
do
    local dragging = false
    local dragStart
    local startPos

    Float.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Float.Position
        end
    end)

    Float.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    Connect(UIS.InputChanged,function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart

            Float.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--// MAIN DRAG
do
    local dragging = false
    local dragStart
    local startPos

    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    Title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    Connect(UIS.InputChanged,function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart

            Main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

Notify("ENI MOBILE HUB","Loaded Successfully")
