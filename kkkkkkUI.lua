-- ===== Services =====
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")
local Lighting          = game:GetService("Lighting")
local ContextActionService = game:GetService("ContextActionService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ===== Helper UI Creator =====
local function makeUI(parent, class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    obj.Parent = parent
    return obj
end

-- ===== UI State & Globals =====
local UIState = { Toggles = {}, Sliders = {}, Texts = {} }

local uiBlur = makeUI(Lighting, "BlurEffect", {Size = 20, Enabled = false})

-- ScreenGui
local screenGui = makeUI(LocalPlayer:WaitForChild("PlayerGui"), "ScreenGui", {
    Name = "ModernAdminUI",
    ResetOnSpawn = false
})

-- Main Frame (minimized by default)
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

-- Shadow & Stroke
makeUI(mainFrame, "ImageLabel", {
    BackgroundTransparency = 1,
    Image = "rbxassetid://5028857084",
    ImageTransparency = 0.75,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(24,24,276,276),
    Size = UDim2.new(1,0,1,0),
    ZIndex = -1
})
makeUI(mainFrame, "UIStroke", {
    Color = Color3.fromRGB(70,70,70),
    Thickness = 1.2,
    Transparency = 0.2
})

-- Header
local header = makeUI(mainFrame, "Frame", {
    Size = UDim2.new(1,0,0,28),
    BackgroundColor3 = Color3.fromRGB(20,20,20),
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    Active = true
})
makeUI(header, "UICorner", {CornerRadius = UDim.new(0,12)})
makeUI(header, "UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0,6)
})
makeUI(header, "TextLabel", {
    Text = "Modern Admin",
    Font = Enum.Font.GothamSemibold,
    TextColor3 = Color3.fromRGB(255,255,255),
    TextSize = 12,
    BackgroundTransparency = 1,
    Size = UDim2.new(1,-46,1,0),
    TextXAlignment = Enum.TextXAlignment.Left
})

-- Minimize Button
local minimizeButton = makeUI(header, "TextButton", {
    Text = "+",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(255,255,255),
    BackgroundTransparency = 0.3,
    BackgroundColor3 = Color3.fromRGB(50,50,50),
    Size = UDim2.new(0,24,0,24)
})
makeUI(minimizeButton, "UICorner", {CornerRadius = UDim.new(1,0)})

-- Options Container
local optionsFrame = makeUI(mainFrame, "ScrollingFrame", {
    Position = UDim2.new(0,0,0,28),
    Size = UDim2.new(1,0,1,-28),
    BackgroundTransparency = 1,
    ScrollBarThickness = 6,
    CanvasSize = UDim2.new(0,0,0,0),
    VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
    Active = true
})
local layout = makeUI(optionsFrame, "UIListLayout", {
    Padding = UDim.new(0,5),
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Top
})
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    optionsFrame.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 10)
end)
optionsFrame.Visible = false

-- ===== Tween Info =====
local isMinimized = true
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local minimizedSize = UDim2.new(0,260,0,40)
local maximizedSize = UDim2.new(0,260,0,420)  -- sesuaikan jika tambah lebih banyak fitur

-- ===== Dragging =====
local dragging, dragStart, startPos
local function disableControls() return Enum.ContextActionResult.Sink end

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        ContextActionService:BindAction("DisableControls", disableControls, false, unpack(Enum.UserInputType:GetEnumItems()))
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                ContextActionService:UnbindAction("DisableControls")
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ===== Toggle Creator =====
local function createToggle(name, displayText, default, callback)
    local frame = makeUI(optionsFrame, "Frame", {
        Size = UDim2.new(0.95,0,0,34),
        BackgroundColor3 = Color3.fromRGB(40,40,40),
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0
    })
    makeUI(frame, "UICorner", {CornerRadius = UDim.new(0,8)})

    makeUI(frame, "TextLabel", {
        Text = displayText,
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(220,220,220),
        TextSize = 13,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.58,0,1,0),
        Position = UDim2.new(0.03,0,0,0),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local toggleBtn = makeUI(frame, "TextButton", {
        Text = default and "ON" or "OFF",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(255,255,255),
        BackgroundColor3 = default and Color3.fromRGB(60,180,60) or Color3.fromRGB(180,60,60),
        Size = UDim2.new(0.35,0,0.7,0),
        Position = UDim2.new(0.62,0,0.15,0)
    })
    makeUI(toggleBtn, "UICorner", {CornerRadius = UDim.new(0,6)})

    local state = default or false
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.Text = state and "ON" or "OFF"
        TweenService:Create(toggleBtn, TweenInfo.new(0.25), {
            BackgroundColor3 = state and Color3.fromRGB(60,180,60) or Color3.fromRGB(180,60,60)
        }):Play()
        UIState.Toggles[name] = state
        if callback then callback(state) end
    end)

    if default then callback(true) end
    UIState.Toggles[name] = state
end

-- ===== TextBox Creator (untuk Spy) =====
local function createTextInput(name, placeholder, callback)
    local frame = makeUI(optionsFrame, "Frame", {
        Size = UDim2.new(0.95,0,0,36),
        BackgroundColor3 = Color3.fromRGB(35,35,35),
        BorderSizePixel = 0
    })
    makeUI(frame, "UICorner", {CornerRadius = UDim.new(0,8)})

    makeUI(frame, "TextLabel", {
        Text = name,
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(200,200,200),
        TextSize = 13,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.4,0,1,0),
        Position = UDim2.new(0.03,0,0,0),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local box = makeUI(frame, "TextBox", {
        Size = UDim2.new(0.55,0,0.7,0),
        Position = UDim2.new(0.42,0,0.15,0),
        BackgroundColor3 = Color3.fromRGB(45,45,45),
        TextColor3 = Color3.fromRGB(220,220,220),
        PlaceholderText = placeholder,
        PlaceholderColor3 = Color3.fromRGB(140,140,140),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        ClearTextOnFocus = false,
        Text = ""
    })
    makeUI(box, "UICorner", {CornerRadius = UDim.new(0,6)})

    box.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            callback(box.Text)
        end
    end)

    box.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            box:CaptureFocus()
        end
    end)
end

-- ===== WalkSpeed Slider (contoh sederhana) =====
local function createWalkSpeedSlider()
    local frame = makeUI(optionsFrame, "Frame", {
        Size = UDim2.new(0.95,0,0,40),
        BackgroundColor3 = Color3.fromRGB(40,40,40),
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0
    })
    makeUI(frame, "UICorner", {CornerRadius = UDim.new(0,8)})

    makeUI(frame, "TextLabel", {
        Text = "Walk Speed",
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(220,220,220),
        TextSize = 13,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.4,0,0.5,0),
        Position = UDim2.new(0.03,0,0.1,0)
    })

    local sliderBg = makeUI(frame, "Frame", {
        Size = UDim2.new(0.55,0,0.25,0),
        Position = UDim2.new(0.42,0,0.4,0),
        BackgroundColor3 = Color3.fromRGB(60,60,60)
    })
    makeUI(sliderBg, "UICorner", {CornerRadius = UDim.new(0,4)})

    local handle = makeUI(sliderBg, "Frame", {
        Size = UDim2.new(0,14,1.4,0),
        Position = UDim2.new(0,0, -0.2,0),
        BackgroundColor3 = Color3.fromRGB(100,200,100),
        AnchorPoint = Vector2.new(0.5,0.5)
    })
    makeUI(handle, "UICorner", {CornerRadius = UDim.new(1,0)})

    local valueLabel = makeUI(frame, "TextLabel", {
        Text = "16",
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.fromRGB(200,200,200),
        TextSize = 13,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.15,0,0.5,0),
        Position = UDim2.new(0.82,0,0.1,0)
    })

    local currentSpeed = 16
    local min, max = 16, 100

    local function updateSpeed(rel)
        rel = math.clamp(rel, 0, 1)
        currentSpeed = math.floor(min + (max - min) * rel + 0.5)
        valueLabel.Text = tostring(currentSpeed)

        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = currentSpeed end
        end
    end

    local dragging = false
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    handle.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    sliderBg.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local rel = math.clamp((inp.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            handle.Position = UDim2.new(rel, 0, 0.5, 0)
            updateSpeed(rel)
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((inp.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            handle.Position = UDim2.new(rel, 0, 0.5, 0)
            updateSpeed(rel)
        end
    end)
end

-- ===== Fitur Logic (dari kode kamu) =====
local connections = {}
local nameTags = {}
local originalProps = {}
local originalGraphics = {}
local checkpointLabels = {}
local checkpointGui = nil

local function noclip(state)
    if state then
        if connections.noclip then return end
        connections.noclip = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in char:GetChildren() do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if connections.noclip then connections.noclip:Disconnect() connections.noclip = nil end
        local char = LocalPlayer.Character
        if char then
            for _, part in char:GetChildren() do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end

local function infiniteJump(state)
    if state then
        if connections.jump then return end
        connections.jump = UserInputService.JumpRequest:Connect(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState("Jumping") end
        end)
    else
        if connections.jump then connections.jump:Disconnect() connections.jump = nil end
    end
end

local function godMode(state)
    -- versi sederhana (bisa diperluas seperti kode asli kamu)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if state then
        hum.Health = math.huge
        hum.MaxHealth = math.huge
    else
        hum.Health = hum.MaxHealth
    end
end

local function antiKick(state)
    -- versi ringan (bisa diperluas)
    if state then
        if connections.antikick then return end
        connections.antikick = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char and char.Parent \~= Workspace then
                char.Parent = Workspace
            end
        end)
    else
        if connections.antikick then connections.antikick:Disconnect() connections.antikick = nil end
    end
end

local function nameEsp(state)
    if state then
        for _, plr in Players:GetPlayers() do
            if plr \~= LocalPlayer and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp and not nameTags[plr.UserId] then
                    local bg = Instance.new("BillboardGui", hrp)
                    bg.Size = UDim2.new(0,120,0,40)
                    bg.AlwaysOnTop = true
                    bg.StudsOffset = Vector3.new(0,3.5,0)

                    local lbl = Instance.new("TextLabel", bg)
                    lbl.Size = UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = plr.Name
                    lbl.TextColor3 = Color3.new(1,1,1)
                    lbl.TextScaled = true
                    lbl.Font = Enum.Font.SourceSansBold

                    nameTags[plr.UserId] = bg
                end
            end
        end
    else
        for _, tag in nameTags do tag:Destroy() end
        nameTags = {}
    end
end

local function invisible(state)
    local char = LocalPlayer.Character
    if not char then return end

    if state then
        originalProps = {}
        for _, part in char:GetChildren() do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                originalProps[part] = part.Transparency
                part.Transparency = 1
            end
        end
    else
        for part, trans in originalProps do
            if part and part.Parent then part.Transparency = trans end
        end
        originalProps = {}
    end
end

local spyConnection
local function spy(targetName)
    if spyConnection then
        spyConnection:Disconnect()
        spyConnection = nil
        Camera.CameraType = Enum.CameraType.Custom
    end

    if targetName == "" then return end

    local target = Players:FindFirstChild(targetName)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end

    local hrp = target.Character.HumanoidRootPart
    Camera.CameraType = Enum.CameraType.Scriptable

    spyConnection = RunService.RenderStepped:Connect(function()
        if hrp and hrp.Parent then
            Camera.CFrame = hrp.CFrame * CFrame.new(0, 5, 15)
        else
            spy("")
        end
    end)
end

local function antiLag(state)
    if state then
        originalGraphics = {
            GlobalShadows = Lighting.GlobalShadows,
            Technology = Lighting.Technology,
            FogEnd = Lighting.FogEnd,
            Brightness = Lighting.Brightness
        }
        Lighting.GlobalShadows = false
        Lighting.Technology = Enum.Technology.Compatibility
        Lighting.FogEnd = 100000
        Lighting.Brightness = 1
        -- bisa ditambah matikan particle dll
    else
        if originalGraphics.GlobalShadows \~= nil then
            Lighting.GlobalShadows = originalGraphics.GlobalShadows
            Lighting.Technology = originalGraphics.Technology
            Lighting.FogEnd = originalGraphics.FogEnd
            Lighting.Brightness = originalGraphics.Brightness
        end
    end
end

-- ===== Buat semua toggle & input =====
createToggle("Noclip",        "Noclip",           false, noclip)
createToggle("InfJump",       "Infinite Jump",    false, infiniteJump)
createToggle("GodMode",       "God Mode",         false, godMode)
createToggle("AntiKick",      "Anti Kick",        false, antiKick)
createToggle("NameESP",       "Name ESP",         false, nameEsp)
createToggle("Invisible",     "Invisible",         false, invisible)
createToggle("AntiLag",       "Anti Lag",          false, antiLag)

createTextInput("Spy Player", "Enter player name → press Enter", spy)

createWalkSpeedSlider()

-- ===== Minimize / Maximize =====
local function toggleMinimize()
    isMinimized = not isMinimized
    minimizeButton.Text = isMinimized and "+" or "-"
    uiBlur.Enabled = not isMinimized
    optionsFrame.Visible = not isMinimized

    TweenService:Create(mainFrame, tweenInfo, {Size = isMinimized and minimizedSize or maximizedSize}):Play()
end
minimizeButton.MouseButton1Click:Connect(toggleMinimize)

-- ===== Re-apply saat respawn =====
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5) -- tunggu humanoid
    if UIState.Toggles.Noclip     then noclip(true)     end
    if UIState.Toggles.InfJump    then infiniteJump(true) end
    if UIState.Toggles.GodMode    then godMode(true)    end
    if UIState.Toggles.AntiKick   then antiKick(true)   end
    if UIState.Toggles.Invisible  then invisible(true)  end
    -- NameESP & AntiLag biasanya global, tidak perlu di-reapply
end)
