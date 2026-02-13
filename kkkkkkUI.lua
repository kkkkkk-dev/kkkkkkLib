-- ===== SAFE LOAD & WAIT =====
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    warn("[DEBUG] LocalPlayer not found yet - waiting...")
    LocalPlayer = Players.PlayerAdded:Wait()
end

LocalPlayer:WaitForChild("PlayerGui", 15)  -- tunggu max 15 detik

print("[DEBUG] Script started - attempting to create GUI")

local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local Lighting          = game:GetService("Lighting")
local ContextActionService = game:GetService("ContextActionService")

local Camera = Workspace.CurrentCamera

-- ===== Helper =====
local function makeUI(parent, class, props)
    local success, obj = pcall(function()
        local i = Instance.new(class)
        for k, v in pairs(props) do i[k] = v end
        i.Parent = parent
        return i
    end)
    if not success then
        warn("[DEBUG] Failed to create UI: " .. tostring(obj))
        return nil
    end
    return obj
end

-- ===== Unique GUI Name (anti conflict) =====
local uniqueName = "AdminPanel_" .. math.random(100000,999999) .. "_" .. tick()

-- ===== Blur =====
local uiBlur = makeUI(Lighting, "BlurEffect", {Size = 20, Enabled = false})

-- ===== ScreenGui (dibuat paling aman) =====
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local screenGui = makeUI(playerGui, "ScreenGui", {
    Name = uniqueName,
    ResetOnSpawn = false,
    IgnoreGuiInset = true,          -- penting: tidak ketutup topbar
    DisplayOrder = 999,             -- layer paling atas
    Enabled = true
})

if not screenGui then
    warn("[DEBUG] Failed to create ScreenGui!")
    return
end

print("[DEBUG] ScreenGui created: " .. uniqueName)

-- ===== Main Frame =====
local mainFrame = makeUI(screenGui, "Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),  -- tengah layar agar langsung kelihatan
    Size = UDim2.new(0, 280, 0, 50),
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    BackgroundTransparency = 0.25,
    BorderSizePixel = 0,
    Visible = true,
    Active = true,
    ClipsDescendants = true
})

if not mainFrame then
    warn("[DEBUG] Failed to create MainFrame!")
    return
end

makeUI(mainFrame, "UICorner", {CornerRadius = UDim.new(0, 14)})

-- Shadow
makeUI(mainFrame, "ImageLabel", {
    BackgroundTransparency = 1,
    Image = "rbxassetid://5028857084",
    ImageTransparency = 0.7,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(24,24,276,276),
    Size = UDim2.new(1,20,1,20),
    Position = UDim2.new(0,-10,0,-10),
    ZIndex = -2
})

-- Header
local header = makeUI(mainFrame, "Frame", {
    Size = UDim2.new(1,0,0,36),
    BackgroundColor3 = Color3.fromRGB(18,18,18),
    BorderSizePixel = 0
})
makeUI(header, "UICorner", {CornerRadius = UDim.new(0,14)})

makeUI(header, "TextLabel", {
    Text = "Modern Admin - Chapung",
    Font = Enum.Font.GothamSemibold,
    TextColor3 = Color3.fromRGB(240,240,240),
    TextSize = 14,
    BackgroundTransparency = 1,
    Size = UDim2.new(1,-50,1,0),
    Position = UDim2.new(0,10,0,0),
    TextXAlignment = Enum.TextXAlignment.Left
})

-- Minimize Button
local minBtn = makeUI(header, "TextButton", {
    Text = "-",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = Color3.fromRGB(255,255,255),
    BackgroundColor3 = Color3.fromRGB(200,50,50),
    Size = UDim2.new(0,32,0,32),
    Position = UDim2.new(1,-38,0.5, -16),
    AnchorPoint = Vector2.new(1,0.5)
})
makeUI(minBtn, "UICorner", {CornerRadius = UDim.new(1,0)})

print("[DEBUG] Basic UI elements created - should be visible now")

-- (Tambahkan bagian optionsFrame, toggles, functions noclip dll seperti versi sebelumnya di sini)
-- Untuk tes dulu, cukup sampai sini dulu agar GUI muncul.
-- Kalau sudah muncul kotak admin di tengah layar → baru tambah fitur satu-satu.

-- ===== Minimize Logic sederhana untuk tes =====
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    minBtn.Text = minimized and "+" or "-"
    TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
        Size = minimized and UDim2.new(0,280,0,50) or UDim2.new(0,280,0,420)
    }):Play()
    uiBlur.Enabled = not minimized
end)

print("[DEBUG] ModernAdminUI loaded - check your screen!")
