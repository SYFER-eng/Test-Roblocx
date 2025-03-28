local Library = {}

local BUTTON_WIDTH = 140
local BUTTON_HEIGHT = 30
local PADDING = 10
local COLUMNS = 2

function Library:CreateWindow()
    local gui = Instance.new("ScreenGui")
    gui.Name = tostring(math.random(1000000, 9999999))
    gui.ResetOnSpawn = false
    
    pcall(function()
        if syn then syn.protect_gui(gui) end
        gui.Parent = game:GetService("CoreGui")
    end)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, (BUTTON_WIDTH + PADDING) * COLUMNS + PADDING, 0, 300)
    frame.Position = UDim2.new(0.85, 0, 0.4, 0)
    frame.BackgroundTransparency = 0.6
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Parent = gui

    local buttonCount = 0
    local buttons = {}
    local states = {}
    local callbacks = {}

    local function createButton(name, key)
        local column = buttonCount % COLUMNS
        local row = math.floor(buttonCount / COLUMNS)
        buttonCount = buttonCount + 1
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, BUTTON_WIDTH, 0, BUTTON_HEIGHT)
        button.Position = UDim2.new(0, PADDING + (BUTTON_WIDTH + PADDING) * column,
                                  0, PADDING + (BUTTON_HEIGHT + PADDING) * row)
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        button.BackgroundTransparency = 0.3
        button.Text = name .. " [" .. key .. "]"
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Parent = frame
        
        states[name] = false
        buttons[name] = button
        return button
    end

    function Library:AddToggle(name, key, callback)
        local button = createButton(name, key)
        callbacks[name] = callback
        
        button.MouseButton1Click:Connect(function()
            states[name] = not states[name]
            button.BackgroundColor3 = states[name] and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(50, 50, 50)
            callback(states[name])
        end)
        
        return {
            GetState = function()
                return states[name]
            end,
            SetState = function(state)
                states[name] = state
                button.BackgroundColor3 = state and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(50, 50, 50)
                callback(state)
            end
        }
    end

    local dragging, dragInput, dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("RunService").RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                     startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    return Library
end

return Library
