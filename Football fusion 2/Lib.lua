local Library = {}

function Library:CreateWindow()
    local gui = Instance.new("ScreenGui")
    gui.Name = tostring(math.random(1000000, 9999999))
    gui.ResetOnSpawn = false
    
    if syn then
        syn.protect_gui(gui)
        gui.Parent = game.CoreGui
    else
        gui.Parent = game.CoreGui
    end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 150, 0, 200)
    frame.Position = UDim2.new(0.85, 0, 0.4, 0)
    frame.BackgroundTransparency = 0.6
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Parent = gui

    local buttons = {}
    local states = {}
    local callbacks = {}

    local function createButton(name, key)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.9, 0, 0, 30)
        button.Position = UDim2.new(0.05, 0, 0, #buttons * 35 + 10)
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

    -- Make UI draggable
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
