local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/SYFER-eng/Test-Roblocx/refs/heads/main/Football%20fusion%202/Lib.lua'))()
local Window = Library:CreateWindow()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function getCharacter()
    return Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoid()
    local character = getCharacter()
    return character:FindFirstChild("Humanoid")
end

local function getRootPart()
    local character = getCharacter()
    return character:FindFirstChild("HumanoidRootPart")
end

local enhancedView = Window:AddToggle("Enhanced View", "V", function(state)
    local camera = workspace.CurrentCamera
    if state then
        camera.CFrame = camera.CFrame * CFrame.new(0, 2, 0)
    else
        camera.CFrame = camera.CFrame * CFrame.new(0, -2, 0)
    end
end)

local quickMove = Window:AddToggle("Quick Move", "M", function(state)
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = state and 22 or 16
    end
end)

local smartTrack = Window:AddToggle("Smart Track", "T", function(state)
    -- Handled in RunService
end)

local autoCatch = Window:AddToggle("Auto Catch", "C", function(state)
    -- Handled in RunService
end)

local speedBoost = Window:AddToggle("Speed Boost", "B", function(state)
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = state and 24 or 16
    end
end)

local jumpBoost = Window:AddToggle("Jump Boost", "J", function(state)
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.JumpPower = state and 55 or 50
    end
end)

local bigBall = Window:AddToggle("Bigger Ball", "X", function(state)
    local ball = workspace:FindFirstChild("Football")
    if ball then
        local scale = state and 10 or 1
        local visualScale = Instance.new("Vector3Value")
        visualScale.Value = Vector3.new(scale, scale, scale)
        
        local mesh = ball:FindFirstChildOfClass("SpecialMesh") or Instance.new("SpecialMesh", ball)
        mesh.Scale = visualScale.Value
        
        ball.Size = ball.Size * (state and 1.2 or 0.833)
    end
end)

local function findRemoteEvent(name)
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and remote.Name:lower():find(name:lower()) then
            return remote
        end
    end
    return nil
end

local catchRemote = findRemoteEvent("catch")
local tackleRemote = findRemoteEvent("tackle")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local keyBindings = {
        [Enum.KeyCode.V] = enhancedView,
        [Enum.KeyCode.M] = quickMove,
        [Enum.KeyCode.T] = smartTrack,
        [Enum.KeyCode.C] = autoCatch,
        [Enum.KeyCode.B] = speedBoost,
        [Enum.KeyCode.J] = jumpBoost,
        [Enum.KeyCode.X] = bigBall
    }
    
    if keyBindings[input.KeyCode] then
        keyBindings[input.KeyCode].SetState(not keyBindings[input.KeyCode].GetState())
    end
end)

RunService.RenderStepped:Connect(function(deltaTime)
    local character = getCharacter()
    local humanoid = getHumanoid()
    local rootPart = getRootPart()
    
    if not character or not humanoid or not rootPart then return end
    
    if smartTrack.GetState() then
        local ball = workspace:FindFirstChild("Football")
        if ball then
            local camera = workspace.CurrentCamera
            local cameraPosition = camera.CFrame.Position
            local ballPosition = ball.Position
            camera.CFrame = CFrame.new(cameraPosition, ballPosition)
        end
    end
    
    if autoCatch.GetState() then
        local ball = workspace:FindFirstChild("Football")
        if ball and catchRemote then
            local distance = (ball.Position - rootPart.Position).Magnitude
            if distance < 10 then
                catchRemote:FireServer()
            end
        end
    end
    
    if quickMove.GetState() and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        humanoid.WalkSpeed = humanoid.WalkSpeed * 1.02
    end
    
    if speedBoost.GetState() then
        humanoid.WalkSpeed = 24
    end
    
    if jumpBoost.GetState() then
        humanoid.JumpPower = 55
    end
    
    if bigBall.GetState() then
        local ball = workspace:FindFirstChild("Football")
        if ball then
            local mesh = ball:FindFirstChildOfClass("SpecialMesh")
            if mesh and mesh.Scale.X < 10 then
                mesh.Scale = Vector3.new(10, 10, 10)
            end
        end
    end
end)

Players.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    task.wait(1)
    if speedBoost.GetState() then
        local humanoid = newCharacter:WaitForChild("Humanoid")
        humanoid.WalkSpeed = 24
    end
    if jumpBoost.GetState() then
        local humanoid = newCharacter:WaitForChild("Humanoid")
        humanoid.JumpPower = 55
    end
end)
