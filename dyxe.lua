-- [[ TUAN ANDIKA HUB - V5.0 (SERVER TORNADO EDITION) ]] --

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local flying = false
local flinging = false
local bg, bv, flingVelocity

-- ========================================== --
--   GUI CREATION (HARDCODED POSITIONS)       --
-- ========================================== --
local AndikaHubGui = Instance.new("ScreenGui")
AndikaHubGui.Name = "AndikaHub_V5"
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
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(200, 0, 0)
MainFrame.Active = true
MainFrame.Draggable = true

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TopBar.BorderSizePixel = 0

local TitleLabel = Instance.new("TextLabel", TopBar)
TitleLabel.Size = UDim2.new(0, 150, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ANDIKA HUB 👑"
TitleLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
TitleLabel.Font = Enum.Font.Code
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local ExitButton = Instance.new("TextButton", TopBar)
ExitButton.Size = UDim2.new(0, 30, 0, 30)
ExitButton.Position = UDim2.new(1, -30, 0, 0)
ExitButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ExitButton.BorderSizePixel = 0
ExitButton.Text = "X"
ExitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ExitButton.Font = Enum.Font.Code
ExitButton.TextSize = 18

local FlyButton = Instance.new("TextButton", MainFrame)
FlyButton.Size = UDim2.new(0.9, 0, 0, 45)
FlyButton.Position = UDim2.new(0.05, 0, 0, 50)
FlyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FlyButton.BorderSizePixel = 1
FlyButton.BorderColor3 = Color3.fromRGB(100, 0, 0)
FlyButton.Text = "🕊️ Toggle Fly (F)"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.Font = Enum.Font.Code
FlyButton.TextSize = 16

local FlingButton = Instance.new("TextButton", MainFrame)
FlingButton.Size = UDim2.new(0.9, 0, 0, 45)
FlingButton.Position = UDim2.new(0.05, 0, 0, 105)
FlingButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FlingButton.BorderSizePixel = 1
FlingButton.BorderColor3 = Color3.fromRGB(100, 0, 0)
FlingButton.Text = "🌪️ Tornado Strike (C)"
FlingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingButton.Font = Enum.Font.Code
FlingButton.TextSize = 16

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(0.9, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.05, 0, 1, -30)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Server Chaos Ready."
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 14

-- ========================================== --
--             LOGIC FUNCTIONS                --
-- ========================================== --
local function updateStatus(pesan)
    StatusLabel.Text = pesan
end

local function toggleFling()
    flinging = not flinging
    local char = LocalPlayer.Character
    if flinging and char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        
        -- Memutar tubuh Tuan dengan kecepatan sangat tidak wajar
        flingVelocity = Instance.new("BodyAngularVelocity")
        flingVelocity.Name = "AliceTornado"
        flingVelocity.AngularVelocity = Vector3.new(0, 99999, 0)
        flingVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
        flingVelocity.Parent = hrp
        
        updateStatus("Tornado AKTIF! Tabrak mereka!")
        FlingButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    else
        if char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("AliceTornado") then
            char.HumanoidRootPart.AliceTornado:Destroy()
        end
        updateStatus("Tornado NONAKTIF.")
        FlingButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
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
FlingButton.MouseButton1Click:Connect(toggleFling)

ExitButton.MouseButton1Click:Connect(function()
    if flying then toggleFly() end
    if flinging then toggleFling() end
    AndikaHubGui:Destroy()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then toggleFly()
    elseif input.KeyCode == Enum.KeyCode.C then toggleFling() end
end)
