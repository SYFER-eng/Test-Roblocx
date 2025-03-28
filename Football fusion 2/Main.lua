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
    return character and character:FindFirstChild("Humanoid")
end

local function getRootPart()
    local character = getCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

-- Safe view adjustment
local viewToggle = Window:AddToggle("Better View", "V", function(state)
    local camera = workspace.CurrentCamera
    if state then
        camera.CFrame = camera.CFrame * CFrame.new(0, 0.5, 0)
    else
        camera.CFrame = camera.CFrame * CFrame.new(0, -0.5, 0)
    end
end)

-- Movement enhancement
local moveBoost = Window:AddToggle("Move Boost", "M", function(state)
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = state and 18 or 16
    end
end)

-- Ball tracking
local ballTrack = Window:AddToggle("Track Ball", "T", function(state)
    -- Handled in RunService
end)

-- Catch assist
local catchAssist = Window:AddToggle("Catch Help", "C", function(state)
    -- Handled in RunService
end)

-- Jump enhancement
local jumpBoost = Window:AddToggle("Jump Help", "J", function(state)
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.JumpPower = state and 52 or 50
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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local keyBindings = {
        [Enum.KeyCode.V] = viewToggle,
        [Enum.KeyCode.M] = moveBoost,
        [Enum.KeyCode.T] = ballTrack,
        [Enum.KeyCode.C] = catchAssist,
        [Enum.KeyCode.J] = jumpBoost
    }
    
    if keyBindings[input.KeyCode] then
        keyBindings[input.KeyCode].SetState(not keyBindings[input.KeyCode].GetState())
    end
end)

local lastCatchAttempt = 0
RunService.RenderStepped:Connect(function(deltaTime)
    local character = getCharacter()
    local humanoid = getHumanoid()
    local rootPart = getRootPart()
    
    if not character or not humanoid or not rootPart then return end
    
    if ballTrack.GetState() then
        local ball = workspace:FindFirstChild("Football")
        if ball then
            local camera = workspace.CurrentCamera
            local cameraPosition = camera.CFrame.Position
            local ballPosition = ball.Position
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(cameraPosition, ballPosition), 0.1)
        end
    end
    
    if catchAssist.GetState() then
        local ball = workspace:FindFirstChild("Football")
        if ball and catchRemote and tick() - lastCatchAttempt > 0.1 then
            local distance = (ball.Position - rootPart.Position).Magnitude
            if distance < 8 then
                lastCatchAttempt = tick()
                catchRemote:FireServer()
            end
        end
    end
    
    if moveBoost.GetState() and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        humanoid.WalkSpeed = math.min(humanoid.WalkSpeed * 1.01, 19)
    end
end)

Players.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    task.wait(1)
    if moveBoost.GetState() then
        local humanoid = newCharacter:WaitForChild("Humanoid")
        humanoid.WalkSpeed = 18
    end
    if jumpBoost.GetState() then
        local humanoid = newCharacter:WaitForChild("Humanoid")
        humanoid.JumpPower = 52
    end
end)
