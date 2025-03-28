local SilentAim = {}
SilentAim.__index = SilentAim

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

function SilentAim.new()
    local self = setmetatable({}, SilentAim)
    
    self.Enabled = false
    self.TargetPart = "Head"
    self.FOV = 100
    self.FOVCircle = Drawing.new("Circle")
    self.FOVCircle.Thickness = 2
    self.FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    self.FOVCircle.Filled = false
    self.FOVCircle.Transparency = 1
    
    return self
end

function SilentAim:GetClosestPlayer()
    local MaxDist = math.huge
    local Target = nil
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(self.TargetPart) then
            local ScreenPoint = workspace.CurrentCamera:WorldToScreenPoint(v.Character[self.TargetPart].Position)
            local VectorDistance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
            
            if VectorDistance < MaxDist and VectorDistance <= self.FOV then
                MaxDist = VectorDistance
                Target = v
            end
        end
    end
    
    return Target
end

function SilentAim:UpdateFOV()
    self.FOVCircle.Visible = self.Enabled
    self.FOVCircle.Radius = self.FOV
    self.FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
end

return SilentAim
