-- [[ TUAN ANDIKA HUB - V6.0 (SUPERNOVA FLING) ]] --
-- Mengoyak arsitektur FE dengan Hitbox Overlap murni.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local flying = false
local flinging = false
local targetPlayer = nil
local flingConnection = nil
local bg, bv

-- ========================================== --
--   GUI CREATION (HARDCODED)                 --
-- ========================================== --
local AndikaHubGui = Instance.new("ScreenGui")
AndikaHubGui.Name = "AndikaHub_V6"
AndikaHubGui.ResetOnSpawn = false

local success, result = pcall(function() return gethui() end)
if success and result then
    AndikaHubGui.Parent = result
else
    AndikaHubGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame", AndikaHubGui)
MainFrame.Size = UDim2.new(0, 250, 0, 250)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(150, 0, 255) -- Warna ungu korupsi
MainFrame.Active = true
MainFrame.Draggable = true

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TopBar.BorderSizePixel = 0

local TitleLabel = Instance.new("TextLabel", TopBar)
TitleLabel.Size = UDim2.new(0, 150, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ANDIKA HUB 👑"
TitleLabel.TextColor3 = Color3.fromRGB(200, 100, 255)
TitleLabel.Font = Enum.Font.Code
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local ExitButton = Instance.new("TextButton", TopBar)
ExitButton.Size = UDim2.new(0, 30, 0, 30)
ExitButton.Position = UDim2.new(1, -30, 0, 0)
ExitButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ExitButton.BorderSizePixel = 0
ExitButton.Text = "X"
ExitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ExitButton.Font = Enum.Font.Code
ExitButton.TextSize = 18

local FlyButton = Instance.new("TextButton", MainFrame)
FlyButton.Size = UDim2.new(0.9, 0, 0, 45)
FlyButton.Position = UDim2.new(0.05, 0, 0, 50)
FlyButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FlyButton.BorderSizePixel = 1
FlyButton.BorderColor3 = Color3.fromRGB(100, 0, 150)
FlyButton.Text = "🕊️ Fly (F)"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.Font = Enum.Font.Code
FlyButton.TextSize = 16

local SuperFlingButton = Instance.new("TextButton", MainFrame)
SuperFlingButton.Size = UDim2.new(0.9, 0, 0, 45)
SuperFlingButton.Position = UDim2.new(0.05, 0, 0, 105)
SuperFlingButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SuperFlingButton.BorderSizePixel = 1
SuperFlingButton.BorderColor3 = Color3.fromRGB(100, 0, 150)
SuperFlingButton.Text = "💥 Supernova Fling (C)"
SuperFlingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SuperFlingButton.Font = Enum.Font.Code
SuperFlingButton.TextSize = 16

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(0.9, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.05, 0, 1, -30)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Awaiting Target..."
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 14

-- ========================================== --
--             LOGIC FUNCTIONS                --
-- ========================================== --
local function updateStatus(pesan)
    StatusLabel.Text = pesan
end

local function getClosestPlayer(radius)
    local closestPlayer = nil
    local shortestDistance = radius
    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    if not myPos then return nil end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos = p.Character.HumanoidRootPart.Position
            local distance = (myPos - pos).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = p
            end
        end
    end
    return closestPlayer
end

-- INI ADALAH FUNGSI FLING MODERN YANG BRUTAL
local function toggleSuperFling()
    if flinging then
        flinging = false
        targetPlayer = nil
        if flingConnection then flingConnection:Disconnect() end
        
        -- Kembalikan physics ke normal
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
            LocalPlayer.Character.HumanoidRootPart.RotVelocity = Vector3.new(0,0,0)
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
        updateStatus("Supernova Nonaktif.")
        SuperFlingButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    else
        targetPlayer = getClosestPlayer(30) -- Jarak pencarian diperbesar
        if targetPlayer then
            flinging = true
            updateStatus("Menghancurkan: " .. targetPlayer.Name)
            SuperFlingButton.BackgroundColor3 = Color3.fromRGB(100, 0, 150)

            -- Matikan tabrakan lokal agar tidak terpental sendiri
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end

            -- Loop brutal memaksa koordinat menyatu
            flingConnection = RunService.Heartbeat:Connect(function()
                if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local myHRP = LocalPlayer.Character.HumanoidRootPart
                    local targetHRP = targetPlayer.Character.HumanoidRootPart
                    
                    -- Paksa teleport berulang kali ke dalam tubuh musuh
                    myHRP.CFrame = targetHRP.CFrame
                    -- Berikan velocity rotasi maksimal
