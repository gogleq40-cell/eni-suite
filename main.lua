--[[
    ENI Suite v3
    Refactored Single-File Framework
    Optimized / Leak-Free / DeltaTime / Safe Cleanup
]]

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--// EXECUTOR ADAPTER
local Executor = {}

function Executor:GetUIParent()
    if gethui then
        return gethui()
    end

    return CoreGui
end

--// CONNECTION MANAGER
local ConnectionManager = {}
ConnectionManager.__index = ConnectionManager

function ConnectionManager.new()
    return setmetatable({
        Connections = {}
    }, ConnectionManager)
end

function ConnectionManager:Add(conn)
    table.insert(self.Connections, conn)
    return conn
end

function ConnectionManager:Cleanup()
    for _, conn in ipairs(self.Connections) do
        if typeof(conn) == "RBXScriptConnection" then
            pcall(function()
                conn:Disconnect()
            end)
        end
    end

    table.clear(self.Connections)
end

local Connections = ConnectionManager.new()

--// STATE
local State = {
    Fly = false,
    Noclip = false,
    ClickTP = false,
    FlySpeed = 80,
    GUIVisible = true,
}

--// UTILITIES
local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

local function GetCharacter()
    local char = LocalPlayer.Character

    if not char then
        return nil
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if not hum or not hrp then
        return nil
    end

    if hum.Health <= 0 then
        return nil
    end

    return char, hum, hrp
end

local function SafeTeleport(position)
    local char, hum, hrp = GetCharacter()

    if not hrp then
        return false
    end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {char}

    local result = Workspace:Raycast(
        position + Vector3.new(0, 50, 0),
        Vector3.new(0, -100, 0),
        rayParams
    )

    if not result then
        return false
    end

    local safePos = result.Position + Vector3.new(0, 4, 0)

    char:PivotTo(CFrame.new(safePos))

    return true
end

--// MOBILE SUPPORT
local Mobile = {
    Enabled = UIS.TouchEnabled
}

--// FLY SYSTEM
local Fly = {
    Velocity = Vector3.zero,
    Connection = nil,
    LV = nil,
    Attachment = nil,
}

function Fly:Start()
    if State.Fly then
        return
    end

    local char, hum, hrp = GetCharacter()

    if not hrp then
        return
    end

    State.Fly = true

    hum:ChangeState(Enum.HumanoidStateType.Physics)

    self.Attachment = Instance.new("Attachment")
    self.Attachment.Parent = hrp

    self.LV = Instance.new("LinearVelocity")
    self.LV.Attachment0 = self.Attachment
    self.LV.MaxForce = math.huge
    self.LV.VectorVelocity = Vector3.zero
    self.LV.Parent = hrp

    self.Connection = Connections:Add(
        RunService.RenderStepped:Connect(function(dt)
            if not State.Fly then
                return
            end

            local _, hum2, hrp2 = GetCharacter()

            if not hrp2 then
                return
            end

            local camera = Workspace.CurrentCamera

            if not camera then
                return
            end

            local moveDir = Vector3.zero

            if UIS.TouchEnabled then
                moveDir = hum2.MoveDirection
            else
                if UIS:IsKeyDown(Enum.KeyCode.W) then
                    moveDir += camera.CFrame.LookVector
                end

                if UIS:IsKeyDown(Enum.KeyCode.S) then
                    moveDir -= camera.CFrame.LookVector
                end

                if UIS:IsKeyDown(Enum.KeyCode.A) then
                    moveDir -= camera.CFrame.RightVector
                end

                if UIS:IsKeyDown(Enum.KeyCode.D) then
                    moveDir += camera.CFrame.RightVector
                end

                if UIS:IsKeyDown(Enum.KeyCode.Space) then
                    moveDir += Vector3.yAxis
                end

                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveDir -= Vector3.yAxis
                end
            end

            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit
            end

            self.Velocity = moveDir * State.FlySpeed

            self.LV.VectorVelocity = self.Velocity
        end)
    )

    Notify("ENI", "Fly Enabled", 2)
end

function Fly:Stop()
    State.Fly = false

    local _, hum = GetCharacter()

    if hum then
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    if self.Connection then
        self.Connection:Disconnect()
    end

    if self.LV then
        self.LV:Destroy()
    end

    if self.Attachment then
        self.Attachment:Destroy()
    end

    Notify("ENI", "Fly Disabled", 2)
end

--// NOCLIP SYSTEM
local Noclip = {
    Parts = {},
    Connection = nil,
}

function Noclip:CacheParts(char)
    table.clear(self.Parts)

    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(self.Parts, obj)
        end
    end
end

function Noclip:Start()
    if State.Noclip then
        return
    end

    local char = GetCharacter()

    if not char then
        return
    end

    State.Noclip = true

    self:CacheParts(char)

    self.Connection = Connections:Add(
        RunService.Stepped:Connect(function()
            if not State.Noclip then
                return
            end

            for _, part in ipairs(self.Parts) do
                if part and part.Parent then
                    part.CanCollide = false
                end
            end
        end)
    )

    Notify("ENI", "Noclip Enabled", 2)
end

function Noclip:Stop()
    State.Noclip = false

    for _, part in ipairs(self.Parts) do
        if part and part.Parent then
            part.CanCollide = true
        end
    end

    if self.Connection then
        self.Connection:Disconnect()
    end

    Notify("ENI", "Noclip Disabled", 2)
end

--// MOBILE FLOATING BUTTON
local MobileToggle

--// GUI
local function CreateButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 36)
    button.BackgroundColor3 = Color3.fromRGB(30,30,40)
    button.Text = text
    button.TextColor3 = Color3.new(1,1,1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.Parent = button

    button.MouseButton1Click:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(80,60,180)
        }):Play()

        task.wait(0.1)

        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(30,30,40)
        }):Play()

        callback()
    end)

    return button
end

local function CreateGUI()
    local old = Executor:GetUIParent():FindFirstChild("ENI_V3")

    if old then
        old:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "ENI_V3"
    gui.ResetOnSpawn = false
    gui.Parent = Executor:GetUIParent()

    local main = Instance.new("Frame")
    main.Size = UIS.TouchEnabled and UDim2.new(0, 300, 0, 380) or UDim2.new(0, 360, 0, 420)
    main.Position = UDim2.new(0.5, -180, 0.5, -210)
    main.BackgroundColor3 = Color3.fromRGB(18,18,24)
    main.Parent = gui

    local corner = Instance.new("UICorner")
    corner.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,40)
    title.BackgroundTransparency = 1
    title.Text = "⚡ ENI Suite v3"
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.new(1,1,1)
    title.TextSize = UIS.TouchEnabled and 20 or 16
    title.Parent = main

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,-20,1,-60)
    container.Position = UDim2.new(0,10,0,50)
    container.BackgroundTransparency = 1
    container.Parent = main

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,8)
    layout.Parent = container

    -- Fly
    CreateButton(container, "Toggle Fly", function()
        if State.Fly then
            Fly:Stop()
        else
            Fly:Start()
        end
    end)

    -- Noclip
    CreateButton(container, "Toggle Noclip", function()
        if State.Noclip then
            Noclip:Stop()
        else
            Noclip:Start()
        end
    end)

    -- Click TP
    CreateButton(container, "Toggle ClickTP", function()
        State.ClickTP = not State.ClickTP

        Notify("ENI", "ClickTP: " .. tostring(State.ClickTP), 2)
    end)

    -- Speed+
    CreateButton(container, "Increase Fly Speed", function()
        State.FlySpeed = math.clamp(State.FlySpeed + 10, 20, 150)

        Notify("ENI", "Fly Speed: " .. State.FlySpeed, 2)
    end)

    -- Speed-
    CreateButton(container, "Decrease Fly Speed", function()
        State.FlySpeed = math.clamp(State.FlySpeed - 10, 20, 150)

        Notify("ENI", "Fly Speed: " .. State.FlySpeed, 2)
    end)

    -- Mobile TP
    if UIS.TouchEnabled then
        CreateButton(container, "Tap Screen TP", function()
            State.ClickTP = not State.ClickTP

            Notify("ENI", "Tap Teleport: " .. tostring(State.ClickTP), 2)
        end)
    end

    -- Destroy
    CreateButton(container, "Destroy GUI", function()
        Connections:Cleanup()

        if State.Fly then
            Fly:Stop()
        end

        if State.Noclip then
            Noclip:Stop()
        end

        gui:Destroy()
    end)

    -- Dragging
    local dragging = false
    local dragStart
    local startPos

    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)

    title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    Connections:Add(
        UIS.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart

                main.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
    )

    if UIS.TouchEnabled then
        MobileToggle = Instance.new("TextButton")
        MobileToggle.Size = UDim2.new(0, 60, 0, 60)
        MobileToggle.Position = UDim2.new(0, 20, 0.5, -30)
        MobileToggle.BackgroundColor3 = Color3.fromRGB(80,60,180)
        MobileToggle.Text = "ENI"
        MobileToggle.TextColor3 = Color3.new(1,1,1)
        MobileToggle.Font = Enum.Font.GothamBold
        MobileToggle.TextSize = 18
        MobileToggle.Parent = gui

        local mobileCorner = Instance.new("UICorner")
        mobileCorner.CornerRadius = UDim.new(1,0)
        mobileCorner.Parent = MobileToggle

        MobileToggle.MouseButton1Click:Connect(function()
            main.Visible = not main.Visible
        end)

        local drag = false
        local dragInput
        local dragStart
        local startPos

        MobileToggle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                drag = true
                dragStart = input.Position
                startPos = MobileToggle.Position
            end
        end)

        MobileToggle.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                drag = false
            end
        end)

        Connections:Add(UIS.InputChanged:Connect(function(input)
            if drag and input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart

                MobileToggle.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end))
    end

    return gui
end

--// CLICK TP
Connections:Add(
    UIS.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end

        if not State.ClickTP then
            return
        end

        if UIS.TouchEnabled then
            if input.UserInputType ~= Enum.UserInputType.Touch then
                return
            end
        else
            if input.UserInputType ~= Enum.UserInputType.MouseButton2 then
                return
            end
        end

        local camera = Workspace.CurrentCamera

        if not camera then
            return
        end

        local mousePos = UIS:GetMouseLocation()

        local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude

        local char = GetCharacter()

        if char then
            params.FilterDescendantsInstances = {char}
        end

        local result = Workspace:Raycast(
            ray.Origin,
            ray.Direction * 1000,
            params
        )

        if result then
            SafeTeleport(result.Position)
        end
    end)
)

--// HOTKEY
Connections:Add(
    UIS.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end

        if input.KeyCode == Enum.KeyCode.RightShift then
            State.GUIVisible = not State.GUIVisible

            local gui = Executor:GetUIParent():FindFirstChild("ENI_V3")

            if gui then
                gui.Enabled = State.GUIVisible
            end
        end
    end)
)

--// RESPAWN RECOVERY
Connections:Add(
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)

        if State.Noclip then
            Noclip:Stop()
            task.wait(0.2)
            Noclip:Start()
        end

        if State.Fly then
            Fly:Stop()
            task.wait(0.2)
            Fly:Start()
        end
    end)
)

--// INIT
CreateGUI()

Notify(
    "ENI Suite v3",
    "Loaded Successfully",
    4
)

if UIS.TouchEnabled then
    Notify(
        "Mobile Mode",
        "Use ENI floating button and tap teleport",
        6
    )
else
    Notify(
        "Controls",
        "RightShift = Toggle GUI | RMB = ClickTP",
        6
    )
end
