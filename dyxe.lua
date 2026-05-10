-- [[ TUAN ANDIKA HUB - V3.0 (ANTI-BLANK EDITION) ]] --

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local flying = false
local carrying = false
local targetPlayer = nil
local carryConnection = nil
local bg, bv

-- ========================================== --
--   GUI CREATION (HARDCODED POSITIONS)       --
-- ========================================== --
local AndikaHubGui = Instance.new("ScreenGui")
AndikaHubGui.Name = "AndikaHub_V3"
AndikaHubGui.ResetOnSpawn = false

-- Bypass proteksi
local success, result = pcall(function() return gethui() end)
if success and result then
    AndikaHubGui.Parent = result
else
    AndikaHubGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Frame (Kotak Utama)
local MainFrame = Instance.new("Frame", AndikaHubGui)
MainFrame.Size = UDim2.new(0, 250, 0, 250)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(200, 0, 0) -- Garis pinggir merah
MainFrame.Active = true
MainFrame.Draggable = true

-- Top Bar (Header)
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TopBar.BorderSizePixel = 0

-- Logo / Teks
local TitleLabel = Instance.new("TextLabel", TopBar)
TitleLabel.Size = UDim2.new(0, 150, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ANDIKA HUB 👑"
TitleLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
TitleLabel.Font = Enum.Font.Code
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 10

-- Tombol Exit
local ExitButton = Instance.new("TextButton", TopBar)
ExitButton.Size = UDim2.new(0, 30, 0, 30)
ExitButton.Position = UDim2.new(1, -30, 0, 0)
ExitButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ExitButton.BorderSizePixel = 0
ExitButton.Text = "X"
ExitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ExitButton.Font = Enum.Font.Code
ExitButton.TextSize = 18
ExitButton.ZIndex = 10

-- Tombol Fly (Posisi Paksa)
local FlyButton = Instance.new("TextButton", MainFrame)
FlyButton.Size = UDim2.new(0.9, 0, 0, 45)
FlyButton.Position = UDim2.new(0.05, 0, 0, 50) -- Jarak dari atas
FlyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FlyButton.BorderSizePixel = 1
FlyButton.BorderColor3 = Color3.fromRGB(100, 0, 0)
FlyButton.Text = "🕊️ Toggle Fly (F)"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.Font = Enum.Font.Code
FlyButton.TextSize = 16
FlyButton.ZIndex = 10

-- Tombol Carry (Posisi Paksa)
local CarryButton = Instance.new("TextButton", MainFrame)
CarryButton.Size = UDim2.new(0.9, 0, 0, 45)
CarryButton.Position = UDim2.new(0.05, 0, 0, 105) -- Jarak dari atas
CarryButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
CarryButton.BorderSizePixel = 1
CarryButton.BorderColor3 = Color3.fromRGB(100, 0, 0)
CarryButton.Text = "😈 Toggle Carry (C)"
CarryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CarryButton.Font = Enum.Font.Code
CarryButton.TextSize = 16
CarryButton.ZIndex = 10

-- Label Status
local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(0.9, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.05, 0, 1, -30)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Ready for chaos."
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 14
StatusLabel.ZIndex = 10

-- ========================================== --
--             LOGIC FUNCTIONS                --
-- ========================================== --
local function updateStatus(pesan)
    StatusLabel.Text = pesan
end

local function toggleCarry()
    if carrying then
        carrying = false
        targetPlayer = nil
        if carryConnection then carryConnection:Disconnect() end
        updateStatus("Korban dilepaskan.")
        CarryButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    else
        if Mouse.Target and Mouse.Target.Parent:FindFirstChild("Humanoid") then
            local character = Mouse.Target.Parent
            targetPlayer = Players:GetPlayerFromCharacter(character)
        end

        if targetPlayer and targetPlayer ~= LocalPlayer then
            carrying = true
            updateStatus("Menculik: " .. targetPlayer.Name)
            CarryButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

            carryConnection = RunService.RenderStepped:Connect(function()
                if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    targetPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                    targetPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 50, 0)
                else
                    carrying = false
                    carryConnection:Disconnect()
                    CarryButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                end
            end)
        else
            updateStatus("Arahkan kursor ke target!")
        end
    end
end

local function toggleFly()
    flying = not flying
    local char = LocalPlayer.Character
    if flying and char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        bg = Instance.new("BodyGyro", hrp)
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.cframe = hrp.CFrame
        bv = Instance.new("BodyVelocity", hrp)
        bv.velocity = Vector3.new(0,0,0)
        bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        char.Humanoid.PlatformStand = true
        updateStatus("Terbang AKTIF!")
        FlyButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        
        spawn(function()
            while flying do
                RunService.RenderStepped:Wait()
                if char and char:FindFirstChild("Humanoid") then
                    bg.cframe = workspace.CurrentCamera.CoordinateFrame
                    local moveDir = Vector3.new(0,0,0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + workspace.CurrentCamera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - workspace.CurrentCamera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + workspace.CurrentCamera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - workspace.CurrentCamera.CFrame.RightVector end
                    bv.velocity = moveDir * 50
                end
            end
        end)
    else
        if bg then bg:Destroy() end
        if bv then bv:Destroy() end
        if char and char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end
        updateStatus("Terbang NONAKTIF.")
        FlyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end

FlyButton.MouseButton1Click:Connect(toggleFly)
CarryButton.MouseButton1Click:Connect(toggleCarry)

ExitButton.MouseButton1Click:Connect(function()
    if flying then toggleFly() end
    if carrying then toggleCarry() end
    AndikaHubGui:Destroy()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then toggleFly()
    elseif input.KeyCode == Enum.KeyCode.C then toggleCarry() end
end)
