--[[
    ENI MOBILE HUB v6.0
    Optimized + Fixed + Modernized

    Improvements:
    - Respawn-safe
    - Modern fly system
    - Optimized noclip
    - Better mobile support
    - Memory leak fixes
    - Anti double execution
    - UI scaling improvements
    - Safe cleanup
    - Reduced lag
]]

--// ANTI DOUBLE EXECUTION
if getgenv().ENI_MOBILE_LOADED then
    return
end

getgenv().ENI_MOBILE_LOADED = true

--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

--// PLAYER
local LP = Players.LocalPlayer

--// REMOVE OLD GUI
pcall(function()
    local old = CoreGui:FindFirstChild("ENI_MOBILE_V6")
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

local function DisconnectAll()
    for _,v in ipairs(Connections) do
        pcall(function()
            v:Disconnect()
        end)
    end

    table.clear(Connections)
end

--// NOTIFY
local function Notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 3
        })
    end)
end

--// CHARACTER SYSTEM
local Character
local Humanoid
local RootPart

local function UpdateCharacter()
    Character = LP.Character or LP.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
end

UpdateCharacter()

Connect(LP.CharacterAdded, function()
    task.wait(1)

    UpdateCharacter()

    State.Fly = false
    State.Noclip = false
end)

--// GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = "ENI_MOBILE_V6"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent = CoreGui

--// FLOAT BUTTON
local Float = Instance.new("TextButton")
Float.Size = UDim2.fromOffset(70,70)
Float.Position = UDim2.new(0,20,0.5,-35)
Float.BackgroundColor3 = Color3.fromRGB(110,80,255)
Float.Text = "ENI"
Float.TextColor3 = Color3.new(1,1,1)
Float.Font = Enum.Font.GothamBold
Float.TextSize = 22
Float.AutoButtonColor = false
Float.Parent = GUI

Instance.new("UICorner", Float).CornerRadius = UDim.new(1,0)

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(180,160,255)
FloatStroke.Thickness = 2
FloatStroke.Parent = Float

--// MAIN WINDOW
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0.9,0,0.6,0)
Main.Position = UDim2.new(0.05,0,0.2,0)
Main.BackgroundColor3 = Color3.fromRGB(20,20,28)
Main.Visible = true
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
Title.Text = "⚡ ENI MOBILE HUB v6"
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

    if Pages[name] then
        Pages[name].Visible = true
    end
end

local function CreateTab(name)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,120,1,0)
    b.BackgroundColor3 = Color3.fromRGB(35,35,50)
    b.Text = name
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.AutoButtonColor = false
    b.Parent = TabBar

    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)

    b.MouseButton1Click:Connect(function()
        SwitchPage(name)
    end)

    return b
end

local MovementPage = CreatePage("Movement")
local TeleportPage = CreatePage("Teleport")
local UtilityPage = CreatePage("Utility")

CreateTab("Movement")
CreateTab("Teleport")
CreateTab("Utility")

SwitchPage("Movement")

--// BUTTON CREATOR
local function Button(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,42)
    b.BackgroundColor3 = Color3.fromRGB(32,32,44)
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 15
    b.AutoButtonColor = false
    b.Parent = parent

    Instance.new("UICorner", b).CornerRadius = UDim.new(0,12)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80,60,180)
    stroke.Parent = b

    b.MouseButton1Click:Connect(function()

        TweenService:Create(
            b,
            TweenInfo.new(0.12),
            {
                BackgroundColor3 = Color3.fromRGB(70,50,180)
            }
        ):Play()

        task.wait(0.1)

        TweenService:Create(
            b,
            TweenInfo.new(0.2),
            {
                BackgroundColor3 = Color3.fromRGB(32,32,44)
            }
        ):Play()

        pcall(callback)
    end)

    return b
end

--// FLY SYSTEM
local FlyConnection

local function StartFly()

    if State.Fly then
        return
    end

    if not RootPart or not Humanoid then
        return
    end

    State.Fly = true

    Humanoid.PlatformStand = false

    FlyConnection = RunService.RenderStepped:Connect(function()

        if not State.Fly then
            return
        end

        if not RootPart or not Humanoid then
            return
        end

        local cam = Workspace.CurrentCamera

        if not cam then
            return
        end

        local move = Humanoid.MoveDirection

        if move.Magnitude > 0 then

            RootPart.AssemblyLinearVelocity =
                cam.CFrame.LookVector * State.FlySpeed

        else

            RootPart.AssemblyLinearVelocity = Vector3.zero
        end

        RootPart.AssemblyAngularVelocity = Vector3.zero
    end)

    Notify("ENI","Fly Enabled")
end

local function StopFly()

    State.Fly = false

    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end

    if RootPart then
        RootPart.AssemblyLinearVelocity = Vector3.zero
    end

    Notify("ENI","Fly Disabled")
end

--// NOCLIP
local NoclipParts = {}

local function CacheParts()

    table.clear(NoclipParts)

    if not Character then
        return
    end

    for _,v in ipairs(Character:GetChildren()) do
        if v:IsA("BasePart") then
            table.insert(NoclipParts, v)
        end
    end
end

CacheParts()

Connect(LP.CharacterAdded, function()
    task.wait(1)
    CacheParts()
end)

Connect(RunService.Stepped, function()

    if not State.Noclip then
        return
    end

    for _,part in ipairs(NoclipParts) do
        if part and part.Parent then
            part.CanCollide = false
        end
    end
end)

--// CLICK TP
Connect(UIS.TouchTap, function(pos, gp)

    if gp then
        return
    end

    if not State.ClickTP then
        return
    end

    local cam = Workspace.CurrentCamera

    if not cam then
        return
    end

    local touchPos = pos[1]

    local ray = cam:ViewportPointToRay(
        touchPos.X,
        touchPos.Y
    )

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude

    if Character then
        params.FilterDescendantsInstances = {Character}
    end

    local result = Workspace:Raycast(
        ray.Origin,
        ray.Direction * 1000,
        params
    )

    if result and RootPart then
        RootPart.CFrame =
            CFrame.new(result.Position + Vector3.new(0,5,0))
    end
end)

--// MOVEMENT BUTTONS
Button(MovementPage,"Toggle Fly",function()

    if State.Fly then
        StopFly()
    else
        StartFly()
    end
end)

Button(MovementPage,"Toggle Noclip",function()

    State.Noclip = not State.Noclip

    Notify(
        "ENI",
        "Noclip: "..tostring(State.Noclip)
    )
end)

Button(MovementPage,"Increase Fly Speed",function()

    State.FlySpeed += 10

    Notify(
        "ENI",
        "Fly Speed: "..State.FlySpeed
    )
end)

Button(MovementPage,"Decrease Fly Speed",function()

    State.FlySpeed = math.max(10, State.FlySpeed - 10)

    Notify(
        "ENI",
        "Fly Speed: "..State.FlySpeed
    )
end)

--// TELEPORT
Button(TeleportPage,"Toggle ClickTP",function()

    State.ClickTP = not State.ClickTP

    Notify(
        "ENI",
        "ClickTP: "..tostring(State.ClickTP)
    )
end)

--// UTILITY
Button(UtilityPage,"Hide GUI",function()

    Main.Visible = false
end)

Button(UtilityPage,"Show GUI",function()

    Main.Visible = true
end)

Button(UtilityPage,"Destroy Script",function()

    StopFly()

    DisconnectAll()

    GUI:Destroy()

    getgenv().ENI_MOBILE_LOADED = false
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

    Connect(UIS.InputChanged, function(input)

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

    Connect(UIS.InputChanged, function(input)

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

--// START
Notify(
    "ENI MOBILE HUB",
    "Loaded Successfully"
)
