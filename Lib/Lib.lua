-- Custom UI Library
local UILib = {}

function UILib:CreateWindow()
    local ScreenGui = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local Container = Instance.new("Frame")
    
    ScreenGui.Parent = game:GetService("CoreGui")
    
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.2, 0, 0.2, 0)
    Main.Size = UDim2.new(0, 300, 0, 400)
    Main.Active = true
    Main.Draggable = true
    
    Title.Name = "Title"
    Title.Parent = Main
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.SourceSansBold
    Title.Text = "Silent Aim"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    
    Container.Name = "Container"
    Container.Parent = Main
    Container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Container.BorderSizePixel = 0
    Container.Position = UDim2.new(0, 0, 0, 35)
    Container.Size = UDim2.new(1, 0, 1, -35)
    
    return Container
end

function UILib:CreateToggle(parent, text, callback)
    local Toggle = Instance.new("TextButton")
    local Status = Instance.new("Frame")
    local enabled = false
    
    Toggle.Name = "Toggle"
    Toggle.Parent = parent
    Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Toggle.BorderSizePixel = 0
    Toggle.Size = UDim2.new(0.9, 0, 0, 30)
    Toggle.Position = UDim2.new(0.05, 0, 0, #parent:GetChildren() * 35)
    Toggle.Font = Enum.Font.SourceSans
    Toggle.Text = "  " .. text
    Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.TextSize = 14
    Toggle.TextXAlignment = Enum.TextXAlignment.Left
    
    Status.Name = "Status"
    Status.Parent = Toggle
    Status.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    Status.BorderSizePixel = 0
    Status.Position = UDim2.new(1, -40, 0.5, -8)
    Status.Size = UDim2.new(0, 30, 0, 16)
    
    Toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        Status.BackgroundColor3 = enabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        callback(enabled)
    end)
end

function UILib:CreateSlider(parent, text, min, max, callback)
    local SliderFrame = Instance.new("Frame")
    local SliderText = Instance.new("TextLabel")
    local SliderButton = Instance.new("TextButton")
    local SliderInner = Instance.new("Frame")
    local ValueText = Instance.new("TextLabel")
    
    SliderFrame.Name = "SliderFrame"
    SliderFrame.Parent = parent
    SliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Size = UDim2.new(0.9, 0, 0, 45)
    SliderFrame.Position = UDim2.new(0.05, 0, 0, #parent:GetChildren() * 35)
    
    SliderText.Name = "SliderText"
    SliderText.Parent = SliderFrame
    SliderText.BackgroundTransparency = 1
    SliderText.Position = UDim2.new(0, 5, 0, 0)
    SliderText.Size = UDim2.new(1, -10, 0, 20)
    SliderText.Font = Enum.Font.SourceSans
    SliderText.Text = text
    SliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderText.TextSize = 14
    SliderText.TextXAlignment = Enum.TextXAlignment.Left
    
    SliderButton.Name = "SliderButton"
    SliderButton.Parent = SliderFrame
    SliderButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SliderButton.BorderSizePixel = 0
    SliderButton.Position = UDim2.new(0, 5, 0, 25)
    SliderButton.Size = UDim2.new(1, -10, 0, 15)
    SliderButton.Text = ""
    SliderButton.AutoButtonColor = false
    
    SliderInner.Name = "SliderInner"
    SliderInner.Parent = SliderButton
    SliderInner.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    SliderInner.BorderSizePixel = 0
    SliderInner.Size = UDim2.new(0.5, 0, 1, 0)
    
    ValueText.Name = "ValueText"
    ValueText.Parent = SliderButton
    ValueText.BackgroundTransparency = 1
    ValueText.Size = UDim2.new(1, 0, 1, 0)
    ValueText.Font = Enum.Font.SourceSans
    ValueText.Text = tostring(min)
    ValueText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValueText.TextSize = 14
    
    local function updateSlider(input)
        local pos = UDim2.new(math.clamp((input.Position.X - SliderButton.AbsolutePosition.X) / SliderButton.AbsoluteSize.X, 0, 1), 0, 1, 0)
        SliderInner.Size = pos
        local value = math.floor(min + (max - min) * pos.X.Scale)
        ValueText.Text = tostring(value)
        callback(value)
    end
    
    SliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local connection
            connection = game:GetService("RunService").RenderStepped:Connect(function()
                updateSlider(input)
            end)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                end
            end)
        end
    end)
end

-- Silent Aim Implementation
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local SilentAim = {
    Enabled = false,
    FOV = 100,
    TargetPart = "Head"
}

-- Create FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1

-- Get Closest Player Function
function SilentAim:GetClosestPlayer()
    local MaxDist = math.huge
    local Target = nil
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(self.TargetPart) then
            if v.Character:FindFirstChildOfClass("Humanoid") and v.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                local ScreenPoint = Camera:WorldToScreenPoint(v.Character[self.TargetPart].Position)
                local VectorDistance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude
                
                if VectorDistance < MaxDist and VectorDistance <= self.FOV then
                    MaxDist = VectorDistance
                    Target = v
                end
            end
        end
    end
    
    return Target
end

-- Create UI
local Container = UILib:CreateWindow()

-- Create Toggle
UILib:CreateToggle(Container, "Enable Silent Aim", function(state)
    SilentAim.Enabled = state
    FOVCircle.Visible = state
end)

-- Create FOV Slider
UILib:CreateSlider(Container, "FOV Size", 0, 500, function(value)
    SilentAim.FOV = value
end)

-- Update FOV Circle
game:GetService("RunService").RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    FOVCircle.Radius = SilentAim.FOV
end)

-- Namecall Hook
local oldNameCall = nil
oldNameCall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local args = {...}
    local method = getnamecallmethod()
    
    if method == "FindPartOnRayWithIgnoreList" and SilentAim.Enabled then
        local target = SilentAim:GetClosestPlayer()
        if target and target.Character then
            args[2] = Ray.new(Camera.CFrame.Position, 
                (target.Character[SilentAim.TargetPart].Position - Camera.CFrame.Position).Unit * 1000)
        end
    end
    
    return oldNameCall(unpack(args))
end))
