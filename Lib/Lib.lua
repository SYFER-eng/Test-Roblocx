-- Silent Aim Library Core
local SilentAimLib = {
    Version = "1.0.0",
    Config = {
        Enabled = false,
        TargetPart = "Head",
        FOV = 100,
        ShowFOV = true,
        FOVColor = Color3.fromRGB(255, 255, 255),
        FOVThickness = 2,
        TeamCheck = false,
        VisibilityCheck = false,
        HitChance = 100
    }
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- FOV Circle Setup
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = SilentAimLib.Config.FOVThickness
FOVCircle.Color = SilentAimLib.Config.FOVColor
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false

-- Utility Functions
local function IsVisible(part)
    if not SilentAimLib.Config.VisibilityCheck then return true end
    
    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 2048)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, part.Parent})
    return not hit
end

local function IsTeammate(player)
    if not SilentAimLib.Config.TeamCheck then return false end
    return player.Team == LocalPlayer.Team
end

local function CalculateChance(percentage)
    return percentage >= math.random(1, 100)
end

-- Core Functions
function SilentAimLib:GetClosestPlayer()
    local MaxDist = math.huge
    local Target = nil
    
    if not CalculateChance(self.Config.HitChance) then return nil end
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild(self.Config.TargetPart) then
            if not IsTeammate(Player) then
                local TargetPart = Player.Character[self.Config.TargetPart]
                if IsVisible(TargetPart) then
                    local ScreenPoint = Camera:WorldToScreenPoint(TargetPart.Position)
                    local VectorDistance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                    
                    if VectorDistance < MaxDist and VectorDistance <= self.Config.FOV then
                        MaxDist = VectorDistance
                        Target = Player
                    end
                end
            end
        end
    end
    
    return Target
end

function SilentAimLib:UpdateFOV()
    FOVCircle.Visible = self.Config.Enabled and self.Config.ShowFOV
    FOVCircle.Radius = self.Config.FOV
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    FOVCircle.Color = self.Config.FOVColor
    FOVCircle.Thickness = self.Config.FOVThickness
end

-- Hook Game Functions
local oldNameCall = nil
oldNameCall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local args = {...}
    local method = getnamecallmethod()
    
    if method == "FindPartOnRayWithIgnoreList" and SilentAimLib.Config.Enabled then
        local target = SilentAimLib:GetClosestPlayer()
        if target and target.Character then
            args[2] = Ray.new(Camera.CFrame.Position, 
                (target.Character[SilentAimLib.Config.TargetPart].Position - Camera.CFrame.Position).Unit * 1000)
        end
    end
    
    return oldNameCall(unpack(args))
end))

-- Update Loop
RunService.RenderStepped:Connect(function()
    SilentAimLib:UpdateFOV()
end)

-- API Functions
function SilentAimLib:Toggle(state)
    self.Config.Enabled = state
end

function SilentAimLib:SetFOV(value)
    self.Config.FOV = value
end

function SilentAimLib:SetTargetPart(part)
    self.Config.TargetPart = part
end

function SilentAimLib:SetTeamCheck(state)
    self.Config.TeamCheck = state
end

function SilentAimLib:SetVisibilityCheck(state)
    self.Config.VisibilityCheck = state
end

function SilentAimLib:SetHitChance(percentage)
    self.Config.HitChance = percentage
end

function SilentAimLib:SetFOVVisibility(state)
    self.Config.ShowFOV = state
end

function SilentAimLib:SetFOVColor(color)
    self.Config.FOVColor = color
end

function SilentAimLib:SetFOVThickness(value)
    self.Config.FOVThickness = value
end

return SilentAimLib
