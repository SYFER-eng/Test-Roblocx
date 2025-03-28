-- Silent Aim Library Core
local SilentAimLib = {
    Version = "1.1.0",
    Config = {
        Enabled = false,
        TargetPart = "Head",
        FOV = 100,
        ShowFOV = true,
        FOVColor = Color3.fromRGB(255, 255, 255),
        FOVThickness = 2,
        TeamCheck = false,
        VisibilityCheck = false,
        HitChance = 100,
        ShowTarget = true
    }
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Visual Elements
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = SilentAimLib.Config.FOVThickness
FOVCircle.Color = SilentAimLib.Config.FOVColor
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false

local TargetBox = Drawing.new("Square")
TargetBox.Thickness = 2
TargetBox.Color = Color3.fromRGB(255, 0, 0)
TargetBox.Filled = false
TargetBox.Transparency = 1
TargetBox.Visible = false

-- Raycasting Configuration
local RaycastParams = RaycastParams.new()
RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
RaycastParams.FilterDescendantsInstances = {LocalPlayer.Character}

-- Utility Functions
local function IsVisible(part)
    local ray = Camera:ViewportPointToRay(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local raycastResult = workspace:Raycast(ray.Origin, (part.Position - ray.Origin).Unit * 2048, RaycastParams)
    return raycastResult and raycastResult.Instance:IsDescendantOf(part.Parent)
end

local function UpdateTargetBox(target)
    if not target or not SilentAimLib.Config.ShowTarget then
        TargetBox.Visible = false
        return
    end

    local targetPart = target.Character[SilentAimLib.Config.TargetPart]
    local vector, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
    
    if onScreen then
        local size = (Camera:WorldToViewportPoint(targetPart.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(targetPart.Position + Vector3.new(0, 3, 0)).Y) / 2
        TargetBox.Size = Vector2.new(size * 1.5, size * 2)
        TargetBox.Position = Vector2.new(vector.X - TargetBox.Size.X / 2, vector.Y - TargetBox.Size.Y / 2)
        TargetBox.Visible = true
    else
        TargetBox.Visible = false
    end
end

-- Enhanced GetClosestPlayer with Raycasting
function SilentAimLib:GetClosestPlayer()
    local MaxDist = self.Config.FOV
    local Target = nil
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild(self.Config.TargetPart) then
            local TargetPart = Player.Character[self.Config.TargetPart]
            local vector, onScreen = Camera:WorldToViewportPoint(TargetPart.Position)
            local Distance = (Vector2.new(vector.X, vector.Y) - ScreenCenter).Magnitude
            
            if onScreen and Distance <= MaxDist and IsVisible(TargetPart) then
                MaxDist = Distance
                Target = Player
            end
        end
    end
    
    UpdateTargetBox(Target)
    return Target
end

-- Enhanced FOV Update
function SilentAimLib:UpdateFOV()
    FOVCircle.Visible = self.Config.Enabled and self.Config.ShowFOV
    FOVCircle.Radius = self.Config.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Color = self.Config.FOVColor
    FOVCircle.Thickness = self.Config.FOVThickness
end

-- Enhanced Namecall Hook with Raycasting
local oldNameCall = nil
oldNameCall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local args = {...}
    local method = getnamecallmethod()
    
    if (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") and SilentAimLib.Config.Enabled then
        local target = SilentAimLib:GetClosestPlayer()
        if target and target.Character then
            local targetPart = target.Character[SilentAimLib.Config.TargetPart]
            args[2] = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000)
        end
    end
    
    return oldNameCall(unpack(args))
end))

-- Update Loop
RunService.RenderStepped:Connect(function()
    SilentAimLib:UpdateFOV()
    SilentAimLib:GetClosestPlayer()
end)

-- Enhanced API Functions
function SilentAimLib:SetFOV(value)
    self.Config.FOV = value
    self:UpdateFOV()
end

function SilentAimLib:ToggleTargetBox(state)
    self.Config.ShowTarget = state
    if not state then
        TargetBox.Visible = false
    end
end

-- Return the enhanced library
return SilentAimLib
