local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local targetPlayer = nil
local ClickInterval = 0.10
local isLeftMouseDown = false
local isRightMouseDown = false
local autoClickConnection = nil
local isAiming = false

local function getClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePosition = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local headPosition, onScreen = camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                local screenPosition = Vector2.new(headPosition.X, headPosition.Y)
                local distance = (screenPosition - mousePosition).Magnitude
                
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    
    return closestPlayer
end

local function isLobbyVisible()
    return localPlayer.PlayerGui.MainGui.MainFrame.Lobby.Currency.Visible == true
end

local function autoClick()
    if autoClickConnection then
        autoClickConnection:Disconnect()
    end
    
    autoClickConnection = RunService.Heartbeat:Connect(function()
        if isLeftMouseDown or isRightMouseDown then
            if not isLobbyVisible() then
                mouse1click()
            end
        else
            autoClickConnection:Disconnect()
        end
    end)
end

-- Right mouse button controls aimbot
UserInputService.InputBegan:Connect(function(input, isProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not isProcessed then
        if not isLeftMouseDown then
            isLeftMouseDown = true
            autoClick()
        end
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 and not isProcessed then
        isAiming = true
        if not isRightMouseDown then
            isRightMouseDown = true
            autoClick()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, isProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not isProcessed then
        isLeftMouseDown = false
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 and not isProcessed then
        isAiming = false
        isRightMouseDown = false
    end
end)

RunService.RenderStepped:Connect(function()
    if not isLobbyVisible() and isAiming then
        targetPlayer = getClosestPlayerToMouse()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
            local head = targetPlayer.Character.Head
            camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
        end
    end
end)
