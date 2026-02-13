-- ===== Helper =====
local function makeUI(parent, class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    obj.Parent = parent
    return obj
end

-- ===== Blur =====
local uiBlur = makeUI(Lighting, "BlurEffect", {
    Size = 20,
    Enabled = false
})

-- ===== ScreenGui =====
local screenGui = makeUI(LocalPlayer:WaitForChild("PlayerGui"), "ScreenGui", {
    Name = "ModernAdminUI",
    ResetOnSpawn = false
})

-- ===== Main Frame =====
local mainFrame = makeUI(screenGui, "Frame", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0.2, 0),
    Size = UDim2.new(0, 260, 0, 40),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    Active = true
})
makeUI(mainFrame, "UICorner", {CornerRadius = UDim.new(0, 12)})

-- ===== Shadow & Stroke =====
local shadow = makeUI(mainFrame, "ImageLabel", {
    BackgroundTransparency = 1,
    Image = "rbxassetid://5028857084",
    ImageTransparency = 0.75,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(24, 24, 276, 276),
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    ZIndex = -1
})
local stroke = makeUI(mainFrame, "UIStroke", {
    Color = Color3.fromRGB(70, 70, 70),
    Thickness = 1.2,
    Transparency = 0.2
})

-- ===== Header =====
local header = makeUI(mainFrame, "Frame", {
    Size = UDim2.new(1, 0, 0, 28),
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    Active = true
})
makeUI(header, "UICorner", {CornerRadius = UDim.new(0, 12)})
makeUI(header, "UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 6)
})
makeUI(header, "TextLabel", {
    Text = "Modern Admin",
    Font = Enum.Font.GothamSemibold,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 12,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -46, 1, 0),
    TextXAlignment = Enum.TextXAlignment.Left
})

-- ===== Minimize Button =====
local minimizeButton = makeUI(header, "TextButton", {
    Text = "+",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.3,
    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
    Size = UDim2.new(0, 24, 0, 24)
})
makeUI(minimizeButton, "UICorner", {CornerRadius = UDim.new(1, 0)})

-- ===== Scrollable Options =====
local optionsFrame = makeUI(mainFrame, "ScrollingFrame", {
    Position = UDim2.new(0, 0, 0, 28),
    Size = UDim2.new(1, 0, 1, -28),
    BackgroundTransparency = 1,
    ScrollBarThickness = 6,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
    Active = true
})
local layout = makeUI(optionsFrame, "UIListLayout", {
    Padding = UDim.new(0, 5),
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Top
})
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    optionsFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
end)
optionsFrame.Visible = false

-- ===== Auto Size Calculator =====
local function calculateMaximizedSize()
    local optionCount = #UIState.Toggles + #UIState.Sliders + #UIState.Dropdowns + #UIState.Texts
    local heightPerOption = 40
    local maxHeight = 400  -- Batas maksimal tinggi
    local calculatedHeight = math.min(optionCount * heightPerOption + 30, maxHeight)
    return UDim2.new(0, 260, 0, calculatedHeight)
end

-- ===== Global UI State =====
local UIState = {
    Toggles = {},
    Sliders = {},
    Dropdowns = {},
    Texts = {}
}

-- ===== Tween Setup =====
local isMinimized = true
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local minimizedSize = UDim2.new(0, 260, 0, 40)
local maximizedSize = calculateMaximizedSize()  -- Auto calculate
mainFrame.Size = minimizedSize

-- ===== Dragging =====
local dragging, dragStart, startPos
local function disableControls()
    return Enum.ContextActionResult.Sink
end
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        CAS:BindAction("DisableControls", disableControls, false, unpack(Enum.UserInputType:GetEnumItems()))
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                CAS:UnbindAction("DisableControls")
            end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ===== Minimize / Maximize =====
local function toggleMinimize()
    if isMinimized then
        isMinimized = false
        minimizeButton.Text = "-"
        uiBlur.Enabled = true
        optionsFrame.Visible = true
        TweenService:Create(mainFrame, tweenInfo, {Size = maximizedSize}):Play()
        TweenService:Create(shadow, tweenInfo, {Size = maximizedSize, ImageTransparency = 0.6}):Play()
        TweenService:Create(stroke, tweenInfo, {Transparency = 0, Thickness = 1.8}):Play()
    else
        isMinimized = true
        minimizeButton.Text = "+"
        uiBlur.Enabled = false
        optionsFrame.Visible = false
        TweenService:Create(mainFrame, tweenInfo, {Size = minimizedSize}):Play()
        TweenService:Create(shadow, tweenInfo, {Size = minimizedSize, ImageTransparency = 0.75}):Play()
        TweenService:Create(stroke, tweenInfo, {Transparency = 0.2, Thickness = 1.2}):Play()
    end
end
minimizeButton.MouseButton1Click:Connect(toggleMinimize)

-- ===== Noclip =====
function noclip(state)
    NoclipEnabled = state
    local character = LocalPlayer.Character
    if not character then return end
    if state and not NoclipConnection then
        NoclipConnection = RunService.Stepped:Connect(function()
            for _, part in ipairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    elseif not state and NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- ===== Infinite Jump =====
function infinityJump(state)
    InfiniteJumpEnabled = state
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
    if not humanoid then return end
    if state and not JumpConnection then
        JumpConnection = UserInputService.JumpRequest:Connect(function()
            humanoid:ChangeState("Jumping")
        end)
    elseif not state and JumpConnection then
        JumpConnection:Disconnect()
        JumpConnection = nil
    end
end

-- ===== God Mode =====
function godMode(state)
    GodModeEnabled = state
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass('Humanoid')
    if not humanoid then return end
    if state then
        if GodModeConnection then return end
        GodModeConnection = {
            RunService.Stepped:Connect(function()
                humanoid.Health = math.huge
            end),
            character.ChildRemoved:Connect(function(child)
                local newChild = child:Clone()
                newChild.Parent = character
                newChild.CFrame = child.CFrame
                child:Destroy()
            end)
        }
    elseif not state and GodModeConnection then
        for _, conn in ipairs(GodModeConnection) do
            conn:Disconnect()
        end
        GodModeConnection = nil
        humanoid.Health = humanoid.MaxHealth
    end
end

-- ===== Anti-Kick =====
function antiKick(state)
    AntiKickEnabled = state
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end
    if state and not AntiKickConnection then
        local previousPosition = hrp.CFrame
        AntiKickConnection = RunService.Stepped:Connect(function()
            local currentPosition = hrp.CFrame
            if (currentPosition.Position - previousPosition.Position).Magnitude > 500 then
                hrp.CFrame = previousPosition
            end
            previousPosition = currentPosition
            if character.Parent ~= Workspace then
                character.Parent = Workspace
            end
            if humanoid.Health < 1 then
                humanoid.Health = 1
            end
        end)
    elseif not state and AntiKickConnection then
        AntiKickConnection:Disconnect()
        AntiKickConnection = nil
    end
end

-- ===== Name ESP =====
local function createNameTag(player)
    if NameTags[player.UserId] or player == LocalPlayer then return end
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local nameTag = Instance.new("BillboardGui")
    nameTag.Size = UDim2.new(2, 0, 1, 0)
    nameTag.AlwaysOnTop = true
    nameTag.StudsOffset = Vector3.new(0, 4, 0)
    nameTag.Parent = hrp
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextScaled = false
    textLabel.TextSize = 18
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Text = player.Name
    textLabel.Parent = nameTag
    NameTags[player.UserId] = nameTag
end

function nameEsp(state)
    NameEspEnabled = state
    if state and not NameEspConnection then
        for _, player in ipairs(Players:GetPlayers()) do
            createNameTag(player)
        end
        NameEspConnection = Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                createNameTag(player)
            end)
        end)
    elseif not state and NameEspConnection then
        NameEspConnection:Disconnect()
        NameEspConnection = nil
        for _, nameTag in pairs(NameTags) do
            nameTag:Destroy()
        end
        NameTags = {}
    end
end

-- ===== Invisible =====
function invisible(state)
    InvisibleEnabled = state
    local character = LocalPlayer.Character
    if not character then return end
    task.spawn(function()
        if state then
            for _, part in ipairs(character:GetChildren()) do
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    originalProperties[part] = {Transparency = part.Transparency, CanCollide = part.CanCollide}
                    part.Transparency = 1
                    part.CanCollide = false
                end
            end
        else
            for _, part in ipairs(character:GetChildren()) do
                local original = originalProperties[part]
                if original then
                    part.Transparency = original.Transparency
                    part.CanCollide = original.CanCollide
                end
            end
            originalProperties = {}
        end
        local humanoid = character:FindFirstChildOfClass('Humanoid')
        if humanoid then
            humanoid.DisplayDistanceType = state and Enum.HumanoidDisplayDistanceType.None or Enum.HumanoidDisplayDistanceType.Model
        end
    end)
end

-- ===== Walk Speed =====
local function applyWalkSpeed(character, speed)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = speed
    end
end

-- ===== Spy =====
function spy(targetName)
    if SpyConnection then
        SpyConnection:Disconnect()
        SpyConnection = nil
        Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        SpyEnabled = false
    end
    if targetName and targetName ~= "" then
        local targetPlayer = Players:FindFirstChild(targetName)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            SpyEnabled = true
            if InvisibleEnabled then
                invisible(false)
            end
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
            SpyConnection = RunService.RenderStepped:Connect(function()
                local offset = CFrame.new(0, 5, 15)
                local cameraCframe = targetHRP.CFrame * offset
                Workspace.CurrentCamera.CFrame = cameraCframe
            end)
        end
    end
end

-- ===== Anti-Lag =====
function antiLag(state)
    AntiLagEnabled = state
    task.spawn(function()
        if state then
            originalGraphics = {
                GlobalShadows = Lighting.GlobalShadows,
                Technology = Lighting.Technology,
                FogEnd = Lighting.FogEnd,
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient,
                Brightness = Lighting.Brightness,
                BloomEnabled = Lighting.BloomEnabled,
            }
            Lighting.GlobalShadows = false
            Lighting.Technology = Enum.Technology.Compatibility
            Lighting.FogEnd = 100
            Lighting.Ambient = Color3.new(0, 0, 0)
            Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
            Lighting.Brightness = 0
            Lighting.BloomEnabled = false
            for _, part in ipairs(Workspace:GetDescendants()) do
                if part:IsA("ParticleEmitter") then
                    part.Enabled = false
                end
            end
        else
            if originalGraphics and next(originalGraphics) then
                Lighting.GlobalShadows = originalGraphics.GlobalShadows
                Lighting.Technology = originalGraphics.Technology
                Lighting.FogEnd = originalGraphics.FogEnd
                Lighting.Ambient = originalGraphics.Ambient
                Lighting.OutdoorAmbient = originalGraphics.OutdoorAmbient
                Lighting.Brightness = originalGraphics.Brightness
                Lighting.BloomEnabled = originalGraphics.BloomEnabled
            end
            for _, part in ipairs(Workspace:GetDescendants()) do
                if part:IsA("ParticleEmitter") then
                    part.Enabled = true
                end
            end
        end
    end)
end

-- ===== ESP Checkpoint =====
local function isCheckpoint(part)
    local name = part.Name:lower()
    local keywords = {"stage", "save", "spawn", "teleport", "goal", "lobby", "checkpoint", "win", "finish"}
    for _, keyword in ipairs(keywords) do
        if string.find(name, keyword) then
            return true
        end
    end
    if part.Material == Enum.Material.ForceField or part.Material == Enum.Material.Neon then
        return true
    end
    if part:FindFirstChild("Checkpoint") or part:FindFirstChildOfClass("Configuration") then
        return true
    end
    if part.Size.Y < 2 and part.Anchored and part.CanCollide then
        if part.Position.Y < 5 then
            return true
        end
    end
    return false
end

local function createCheckpointLabel(part)
    if CheckpointLabels[part] or not part:IsA("BasePart") or not isCheckpoint(part) then
        return
    end
    local label = Instance.new("TextLabel")
    label.Name = "CheckpointLabel_" .. part.Name
    label.Size = UDim2.new(0, 200, 0, 30)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0
    label.TextColor3 = Color3.new(0, 1, 0)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.Text = string.format("%s\n(%.0f, %.0f, %.0f)",
        part.Name, part.Position.X, part.Position.Y, part.Position.Z)
    label.Parent = CheckpointGui
    CheckpointLabels[part] = label
end

function espCheckpoint(state)
    CheckpointEspEnabled = state
    if state then
        if CheckpointEspConnection then
            CheckpointEspConnection:Disconnect()
            CheckpointEspConnection = nil
        end
        if CheckpointAddedConnection then
            CheckpointAddedConnection:Disconnect()
            CheckpointAddedConnection = nil
        end
        if CheckpointGui and CheckpointGui.Parent then
            CheckpointGui:Destroy()
        end
        CheckpointGui = Instance.new("ScreenGui")
        CheckpointGui.Name = "CheckpointESP"
        CheckpointGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        for _, part in pairs(Workspace:GetDescendants()) do
            createCheckpointLabel(part)
        end
        CheckpointAddedConnection = Workspace.DescendantAdded:Connect(function(part)
            if part:IsA("BasePart") then
                createCheckpointLabel(part)
            end
        end)
        CheckpointEspConnection = RunService.RenderStepped:Connect(function()
            for checkpoint, label in pairs(CheckpointLabels) do
                if checkpoint and checkpoint.Parent then
                    local vector, onScreen = Camera:WorldToScreenPoint(checkpoint.Position)
                    if onScreen then
                        label.Visible = true
                        label.Position = UDim2.new(0, vector.X, 0, vector.Y)
                    else
                        label.Visible = false
                    end
                else
                    label:Destroy()
                    CheckpointLabels[checkpoint] = nil
                end
            end
        end)
    else
        if CheckpointEspConnection then
            CheckpointEspConnection:Disconnect()
            CheckpointEspConnection = nil
        end
        if CheckpointAddedConnection then
            CheckpointAddedConnection:Disconnect()
            CheckpointAddedConnection = nil
        end
        for _, label in pairs(CheckpointLabels) do
            label:Destroy()
        end
        CheckpointLabels = {}
        if CheckpointGui and CheckpointGui.Parent then
            CheckpointGui:Destroy()
        end
        CheckpointGui = nil
    end
end

-- ===== Unlock All =====
function unlockAll(state)
    UnlockAllEnabled = state
    local character = LocalPlayer.Character
    if not character then return end
    if state and not UnlockAllConnection then
        UnlockAllConnection = RunService.Stepped:Connect(function()
            for _, item in ipairs(character:GetChildren()) do
                if item:IsA("Tool") or item:IsA("HopperBin") then
                    item.Grip = CFrame.new(0, 0, 0)
                    item.GripRight = Vector3.new(1, 0, 0)
                    item.GripUp = Vector3.new(0, 1, 0)
                    item.GripForward = Vector3.new(0, 0, 1)
                end
            end
        end)
    elseif not state and UnlockAllConnection then
        UnlockAllConnection:Disconnect()
        UnlockAllConnection = nil
    end
end

-- ===== Option Creators =====
local function createToggleOption(name, text)
    local frame = makeUI(optionsFrame, "Frame", {
        Size = UDim2.new(0.95, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0
    })
    makeUI(frame, "UICorner", {CornerRadius = UDim.new(0, 6)})
    makeUI(frame, "TextLabel", {
        Text = text,
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.55, 0, 1, 0),
        Position = UDim2.new(0.03, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local toggle = makeUI(frame, "TextButton", {
        Text = "OFF",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = Color3.fromRGB(150, 50, 50),
        Size = UDim2.new(0.35, 0, 0.75, 0),
        Position = UDim2.new(0.62, 0, 0.125, 0),
        Active = true
    })
    makeUI(toggle, "UICorner", {CornerRadius = UDim.new(0, 6)})
    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = state and "ON" or "OFF"
        TweenService:Create(toggle, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            BackgroundColor3 = state and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(150, 50, 50)
        }):Play()
        UIState.Toggles[name] = state
        maximizedSize = calculateMaximizedSize()
    end)
    UIState.Toggles[name] = state
end

local function createSlider(name, min, max, default, step)
    step = step or 1
    local frame = makeUI(optionsFrame, "Frame", {
        Size = UDim2.new(0.95, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0
    })
    makeUI(frame, "UICorner", {CornerRadius = UDim.new(0, 6)})
    makeUI(frame, "TextLabel", {
        Text = name,
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.35, 0, 1, 0),
        Position = UDim2.new(0.03, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local sliderFrame = makeUI(frame, "Frame", {
        Size = UDim2.new(0.55, 0, 0.35, 0),
        Position = UDim2.new(0.42, 0, 0.35, 0),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        Active = true
    })
    makeUI(sliderFrame, "UICorner", {CornerRadius = UDim.new(0, 4)})
    local handle = makeUI(sliderFrame, "Frame", {
        Size = UDim2.new(0, 12, 1, 0),
        BackgroundColor3 = Color3.fromRGB(50, 150, 50),
        Active = true
    })
    makeUI(handle, "UICorner", {CornerRadius = UDim.new(0, 6)})
    local valueLabel = makeUI(frame, "TextLabel", {
        Text = tostring(default),
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 12,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.15, 0, 1, 0),
        Position = UDim2.new(0.88, 0, 0, 0)
    })
    local rel = (default - min) / (max - min)
    handle.Position = UDim2.new(rel, 0, 0, 0)

    local function updateSlider(value)
        rel = (value - min) / (max - min)
        handle.Position = UDim2.new(rel, 0, 0, 0)
        valueLabel.Text = tostring(math.floor(value * 10) / 10)
    end

    local function valueToColor(value)
        local green = (value - min) / (max - min) * 255
        return Color3.fromRGB(0, green, 0)
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local function update(value)
                local clamped = math.clamp(value, min, max)
                updateSlider(clamped)
                UIState.Sliders[name] = clamped
            end
            local function onSlide(input)
                local pos = UDim2.new(0, input.Position.X - sliderFrame.AbsolutePosition.X, 0, 0)
                local value = pos.X / sliderFrame.AbsoluteSize.X * (max - min) + min
                update(value)
            end
            local connection
            connection = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    onSlide(input)
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if input.UserInputState == Enum.UserInputState.End then
                        connection:Disconnect()
                    end
                end
            end)
            onSlide(input)
        end
    end)

    UIState.Sliders[name] = default
    maximizedSize = calculateMaximizedSize()
end

-- ===== Character Listener =====
LocalPlayer.CharacterAdded:Connect(function(character)
    applyWalkSpeed(character, currentWalkSpeed)
    if NoclipEnabled then noclip(true) end
    if InfiniteJumpEnabled then infinityJump(true) end
    if GodModeEnabled then godMode(true) end
    if AntiKickEnabled then antiKick(true) end
    if NameEspEnabled then nameEsp(true) end
    if InvisibleEnabled then invisible(true) end
    if AntiLagEnabled then antiLag(true) end
    if CheckpointEspEnabled then espCheckpoint(true) end
    if UnlockAllEnabled then unlockAll(true) end
end)

-- ===== Character Removing Listener =====
LocalPlayer.CharacterRemoving:Connect(function(character)
    if NoclipEnabled then noclip(false) end
    if InfiniteJumpEnabled then infinityJump(false) end
    if GodModeEnabled then godMode(false) end
    if AntiKickEnabled then antiKick(false) end
    if InvisibleEnabled then invisible(false) end
end)

-- ===== UI Initialization =====
task.spawn(function()
    createToggleOption("Noclip", "Noclip")
    createToggleOption("Infinite Jump", "Infinite Jump")
    createToggleOption("God Mode", "God Mode")
    createToggleOption("Anti Kick", "Anti Kick")
    createToggleOption("Name ESP", "Name ESP")
    createToggleOption("Invisible", "Invisible")
    createToggleOption("Anti-Lag", "Anti-Lag")
    createToggleOption("Checkpoint ESP", "Checkpoint ESP")
    createToggleOption("Unlock All", "Unlock All")
    createSlider("WalkSpeed", 16, 100, 16, 1)
end)
