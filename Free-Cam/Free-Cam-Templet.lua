local camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local noclip = Instance.new("Part")
noclip.Anchored = true
noclip.Size = Vector3.new(1, 1, 1)
noclip.Transparency = 1
noclip.CanCollide = false
noclip.Parent = workspace

local speed = 5
local active = false
local connections = {}
local rotX, rotY = 0, 0
local sensitivity = 0.5

local armOffsets = {
    LeftArm = CFrame.new(-1.5, -1, 1),
    RightArm = CFrame.new(1.5, -1, 1)
}

local function getArmParts()
    if not player.Character then return {} end
    return {
        Left = player.Character:FindFirstChild("Left Arm"),
        Right = player.Character:FindFirstChild("Right Arm")
    }
end

local function setArmProperties(isGlass)
    local arms = getArmParts()
    if arms.Left then 
        arms.Left.Material = isGlass and Enum.Material.Glass or Enum.Material.Plastic
        arms.Left.Transparency = isGlass and 0.5 or 0
        arms.Left.Reflectance = isGlass and 0.8 or 0
    end
    if arms.Right then 
        arms.Right.Material = isGlass and Enum.Material.Glass or Enum.Material.Plastic
        arms.Right.Transparency = isGlass and 0.5 or 0
        arms.Right.Reflectance = isGlass and 0.8 or 0
    end
end

local function getHeadCFrame()
    if player.Character and player.Character:FindFirstChild("Head") then
        return player.Character.Head.CFrame
    end
    return camera.CFrame
end

local function setCharacterAnchored(anchored)
    if player.Character then
        for _, part in pairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Anchored = anchored
            end
        end
    end
end

local function cleanup()
    setCharacterAnchored(false)
    setArmProperties(false)
    camera.CameraType = Enum.CameraType.Custom
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    
    for _, connection in pairs(connections) do
        connection:Disconnect()
    end
    
    noclip:Destroy()
end

table.insert(connections, UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Equals then
        active = true
        setCharacterAnchored(true)
        setArmProperties(true)
        camera.CameraType = Enum.CameraType.Scriptable
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        
        local headCF = getHeadCFrame()
        noclip.CFrame = headCF
        camera.CFrame = headCF
        
        local _, _, rotZ = headCF:ToOrientation()
        rotX = math.deg(rotZ)
        rotY = 0
        
    elseif input.KeyCode == Enum.KeyCode.Minus then
        active = false
        setCharacterAnchored(false)
        setArmProperties(false)
        camera.CameraType = Enum.CameraType.Custom
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    elseif input.KeyCode == Enum.KeyCode.End then
        cleanup()
        script:Destroy()
    end
end))

table.insert(connections, UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and active then
        rotX = rotX - input.Delta.X * sensitivity
        rotY = math.clamp(rotY - input.Delta.Y * sensitivity, -89, 89)
    end
end))

table.insert(connections, RunService.RenderStepped:Connect(function(deltaTime)
    if not active then return end
    
    local moveSpeed = speed * deltaTime * 60
    local angleX = math.rad(rotX)
    local angleY = math.rad(rotY)
    
    local cf = CFrame.new(noclip.Position) * 
              CFrame.fromEulerAnglesYXZ(angleY, angleX, 0)
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        cf = cf + (cf.LookVector * moveSpeed)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        cf = cf - (cf.LookVector * moveSpeed)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        cf = cf - (cf.RightVector * moveSpeed)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        cf = cf + (cf.RightVector * moveSpeed)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        cf = cf + (cf.UpVector * moveSpeed)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        cf = cf - (cf.UpVector * moveSpeed)
    end
    
    noclip.CFrame = cf
    camera.CFrame = cf
    
    local arms = getArmParts()
    if arms.Left then
        arms.Left.CFrame = cf * armOffsets.LeftArm
    end
    if arms.Right then
        arms.Right.CFrame = cf * armOffsets.RightArm
    end
end))
