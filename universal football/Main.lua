local Library = loadstring(game:HttpGet('YOUR_RAW_LINK_TO_LIBRARY'))()
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

local function findBall()
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("BasePart") and v.Name:lower():find("ball") then
            return v
        end
    end
    return nil
end

local function updateBallSize(ball, scale)
    if not ball then return end
    
    local originalSize = Vector3.new(2, 2, 2)
    ball.Size = originalSize * scale
    
    if ball:FindFirstChild("TouchInterest") then
        ball.TouchInterest.Size = ball.Size * 1.2
    end
end

local enhancedView = Window:AddToggle("Enhanced View", "V", function(state)
    local camera = workspace.CurrentCamera
    camera.CFrame = camera.CFrame * CFrame.new(0, state and 2 or -2, 0)
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
    local ball = findBall()
    if ball then
        updateBallSize(ball, state and 5 or 1)
    end
end)

workspace.ChildAdded:Connect(function(child)
    if child:IsA("BasePart") and child.Name:lower():find("ball") and bigBall.GetState() then
        task.wait()
        updateBallSize(child, 5)
    end
end)

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
        local ball = findBall()
        if ball then
            local camera = workspace.CurrentCamera
            camera.CFrame = CFrame.new(camera.CFrame.Position, ball.Position)
        end
    end
    
    if autoCatch.GetState() then
        local ball = findBall()
        if ball then
            local distance = (ball.Position - rootPart.Position).Magnitude
            if distance < 10 then
                local catchEvent = ReplicatedStorage:FindFirstChild("CatchBall", true)
                if catchEvent then
                    catchEvent:FireServer()
                end
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
        local ball = findBall()
        if ball then
            updateBallSize(ball, 5)
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
