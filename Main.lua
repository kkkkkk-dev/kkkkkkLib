--// Connections
local GetService = game.GetService
local Players = GetService("Players")
local TweenService = GetService("TweenService")
local UserInputService = GetService("UserInputService")
local RunService = GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

if not game:IsLoaded() then game.Loaded:Wait() end

local Setup = {
    Keybind = Enum.KeyCode.LeftControl,
    Transparency = 0.2,
    ThemeMode = "Dark",
    Size = UDim2.new(0, 620, 0, 460),
    MaxExpandPadding = UDim2.new(0, 80, 0, 120),   -- <-- tambahan: padding saat expand
}

local Theme = {
    Primary = Color3.fromRGB(30, 30, 30),
    Secondary = Color3.fromRGB(35, 35, 35),
    Component = Color3.fromRGB(40, 40, 40),
    Interactables = Color3.fromRGB(45, 45, 45),
    Tab = Color3.fromRGB(200, 200, 200),
    Title = Color3.fromRGB(240,240,240),
    Description = Color3.fromRGB(200,200,200),
    Shadow = Color3.fromRGB(0, 0, 0),
    Outline = Color3.fromRGB(40, 40, 40),
    Icon = Color3.fromRGB(220, 220, 220),
}

local Animations = {}

function Animations:Open(Window, Transparency, UseCurrentSize)
    local Original = UseCurrentSize and Window.Size or Setup.Size
    local Multiplied = UDim2.new(Original.X.Scale*1.08, Original.X.Offset*1.08, Original.Y.Scale*1.08, Original.Y.Offset*1.08)
    local Shadow = Window:FindFirstChildOfClass("UIStroke") or Window:FindFirstChild("Shadow", true)

    if Shadow then Shadow.Transparency = 1 end
    Window.Size = Multiplied
    Window.GroupTransparency = 1
    Window.Visible = true

    if Shadow then TweenService:Create(Shadow, TweenInfo.new(0.25), {Transparency = 0.4}):Play() end
    TweenService:Create(Window, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        Size = Original,
        GroupTransparency = Transparency or 0,
    }):Play()
end

function Animations:Close(Window)
    local Original = Window.Size
    local Multiplied = UDim2.new(Original.X.Scale*1.08, Original.X.Offset*1.08, Original.Y.Scale*1.08, Original.Y.Offset*1.08)
    local Shadow = Window:FindFirstChildOfClass("UIStroke") or Window:FindFirstChild("Shadow", true)

    TweenService:Create(Window, TweenInfo.new(0.25), {Size = Multiplied, GroupTransparency = 1}):Play()
    if Shadow then TweenService:Create(Shadow, TweenInfo.new(0.25), {Transparency = 1}):Play() end

    task.delay(0.26, function()
        Window.Visible = false
        Window.Size = Original
    end)
end

-- Setup Screen
local Screen
local BlurModule

if identifyexecutor then
    Screen = game:GetService("InsertService"):LoadLocalAsset("rbxassetid://18490507748")
    BlurModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/lates-lib/main/Assets/Blur.lua"))()
else
    Screen = script.Parent
    -- BlurModule = require(script.Blur) -- uncomment jika pakai require
end

xpcall(function()
    Screen.Parent = game:GetService("CoreGui")
end, function()
    Screen.Parent = PlayerGui
end)

Screen.Main.Visible = false

local Library = {}
local Blurs = {}

function Library:CreateWindow(Settings)
    local Window = Screen.Main:Clone()
    Window.Name = Settings.Title or "Window"
    Window.Parent = Screen
    Window.Visible = false   -- mulai dari tidak kelihatan

    local Sidebar = Window:FindFirstChild("Sidebar", true)
    local ContentHolder = Window:FindFirstChild("Main", true) or Window:FindFirstChildWhichIsA("ScrollingFrame", true)

    local isMaximized = false
    local isMinimized = true
    local blurEnabled = Settings.Blurring or false
    local blurObj

    if blurEnabled then
        blurObj = BlurModule.new(Window, 6)
        Blurs[Window.Name] = blurObj
    end

    -- Buat tombol kontrol manual (pojok kanan atas)
    local TitleBar = Window:FindFirstChild("TitleBar") or Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1,0,0,36)
    TitleBar.BackgroundColor3 = Theme.Secondary
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Window
    TitleBar.ZIndex = 10

    local uiList = Instance.new("UIListLayout")
    uiList.FillDirection = Enum.FillDirection.Horizontal
    uiList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    uiList.Padding = UDim.new(0,6)
    uiList.Parent = TitleBar

    local function createControlButton(name, color, text)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(0,32,0,28)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 18
        btn.BorderSizePixel = 0
        btn.Parent = TitleBar
        return btn
    end

    local minimizeBtn = createControlButton("Minimize", Color3.fromRGB(255, 180, 0), "−")
    local maximizeBtn = createControlButton("Maximize", Color3.fromRGB(60, 180, 80), "□")
    local closeBtn    = createControlButton("Close",    Color3.fromRGB(220, 50, 50), "×")

    -- Mini bar saat minimize
    local miniBar = nil
    local function createMiniBar()
        if miniBar then return end
        miniBar = Instance.new("Frame")
        miniBar.Name = "MiniBar"
        miniBar.Size = UDim2.new(0,240,0,38)
        miniBar.Position = UDim2.new(0.5, -120, 0.96, -48)
        miniBar.BackgroundColor3 = Theme.Secondary
        miniBar.Parent = Screen
        miniBar.Visible = false

        local lbl = Instance.new("TextLabel", miniBar)
        lbl.Size = UDim2.new(0.7,0,1,0)
        lbl.Position = UDim2.new(0,12,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = Settings.Title or "UI"
        lbl.TextColor3 = Theme.Title
        lbl.Font = Enum.Font.GothamSemibold
        lbl.TextSize = 15
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local restoreBtn = Instance.new("TextButton", miniBar)
        restoreBtn.Size = UDim2.new(0,32,0,32)
        restoreBtn.Position = UDim2.new(1,-44,0.5,-16)
        restoreBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        restoreBtn.Text = "↑"
        restoreBtn.TextColor3 = Color3.new(1,1,1)
        restoreBtn.Font = Enum.Font.GothamBold

        restoreBtn.MouseButton1Click:Connect(function()
            isMinimized = false
            miniBar.Visible = false
            Window.Visible = true
            Animations:Open(Window, Setup.Transparency)
            if blurObj then blurObj.root.Parent = workspace.CurrentCamera end
        end)

        -- Bisa ditambah drag miniBar jika mau
    end

    -- Handler tombol
    minimizeBtn.MouseButton1Click:Connect(function()
        if not isMinimized then
            isMinimized = true
            createMiniBar()
            miniBar.Visible = true
            Animations:Close(Window)
            task.delay(0.3, function()
                Window.Visible = false
                if blurObj then blurObj.root.Parent = nil end
            end)
        end
    end)

    maximizeBtn.MouseButton1Click:Connect(function()
        if isMaximized then
            -- Restore
            isMaximized = false
            TweenService:Create(Window, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                Size = Setup.Size,
                Position = Window:GetAttribute("PrevPosition") or UDim2.new(0.5,0,0.5,0),
                AnchorPoint = Vector2.new(0.5,0.5)
            }):Play()
            maximizeBtn.Text = "□"
        else
            -- Expand pintar (memanjang sesuai konten)
            isMaximized = true
            Window:SetAttribute("PrevPosition", Window.Position)
            Window:SetAttribute("PrevSize", Window.Size)

            -- Hitung tinggi total konten
            local content = ContentHolder
            local totalHeight = 60  -- titlebar + padding
            for _, child in content:GetDescendants() do
                if child:IsA("GuiObject") and child.Visible then
                    totalHeight += child.AbsoluteSize.Y + 8  -- margin kecil
                end
            end

            local targetSize = UDim2.new(
                0, math.clamp(Window.AbsoluteSize.X + 140, 620, 1100),
                0, math.clamp(totalHeight + Setup.MaxExpandPadding.Y.Offset, 500, 860)
            )

            TweenService:Create(Window, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
                Size = targetSize,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5)
            }):Play()

            maximizeBtn.Text = "❐"   -- simbol restore
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        Animations:Close(Window)
        task.delay(0.3, function()
            if blurObj then blurObj:Destroy() end
            Window:Destroy()
        end)
    end)

    -- Drag window (judul bar)
    Drag(TitleBar)

    -- Mulai dalam keadaan minimize
    createMiniBar()
    miniBar.Visible = true

    -- Return table options (sama seperti sebelumnya, tambahkan jika perlu)
    local Options = {}
    -- ... (fungsi AddTab, AddButton, AddToggle, dll tetap sama seperti kode asli kamu)

    return Options
end

return Library
