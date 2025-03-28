local Library = loadstring(game:HttpGet('YOUR_RAW_LINK_TO_LIBRARY'))()
local Window = Library:CreateWindow()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local enhancedView = Window:AddToggle("Enhanced View", "V", function(state)
    workspace.CurrentCamera.FieldOfView = state and 85 or 70
end)

local quickMove = Window:AddToggle("Quick Move", "M", function(state)
    -- Toggle state handled in RunService
end)

local smartTrack = Window:AddToggle("Smart Track", "T", function(state)
    -- Toggle state handled in RunService
end)

local autoCatch = Window:AddToggle("Auto Catch", "C", function(state)
    -- Toggle state handled in RunService
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.V then
        enhancedView.SetState(not enhancedView.GetState())
    elseif input.KeyCode == Enum.KeyCode.M then
        quickMove.SetState(not quickMove.GetState())
    elseif input.KeyCode == Enum.KeyCode.T then
        smartTrack.SetState(not smartTrack.GetState())
    elseif input.KeyCode == Enum.KeyCode.C then
        autoCatch.SetState(not autoCatch.GetState())
    end
end)

RunService.RenderStepped:Connect(function()
    if quickMove.GetState() and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = humanoid.WalkSpeed * 1.05
        end
    end
    
    if smartTrack.GetState() then
        local ball = workspace:FindFirstChild("Football")
        if ball then
            local camera = workspace.CurrentCamera
            camera.CFrame = CFrame.new(camera.CFrame.Position, ball.Position)
        end
    end
end)
