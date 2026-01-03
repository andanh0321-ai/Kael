local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local event = ReplicatedStorage:FindFirstChild("GodModeToggle")
if not event then
    event = Instance.new("RemoteEvent")
    event.Name = "GodModeToggle"
    event.Parent = ReplicatedStorage
end
local state = {}
event.OnServerEvent:Connect(function(player, enable)
    local st = state[player]
    if not st then
        st = {enabled = false, originalMax = 100}
        state[player] = st
    end
    st.enabled = enable
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if enable then
                st.originalMax = humanoid.MaxHealth or 100
                humanoid.MaxHealth = 1e9
                humanoid.Health = humanoid.MaxHealth
            else
                humanoid.MaxHealth = st.originalMax or 100
                if humanoid.Health > humanoid.MaxHealth then
                    humanoid.Health = humanoid.MaxHealth
                end
            end
        end
    end
end)
Players.PlayerAdded:Connect(function(player)
    state[player] = {enabled = false, originalMax = 100}
    player.CharacterAdded:Connect(function(char)
        local humanoid = char:WaitForChild("Humanoid")
        local st = state[player]
        if st.enabled then
            st.originalMax = humanoid.MaxHealth or 100
            humanoid.MaxHealth = 1e9
            humanoid.Health = humanoid.MaxHealth
        else
            humanoid.MaxHealth = st.originalMax or 100
        end
        humanoid.HealthChanged:Connect(function(h)
            if st.enabled and h < 1 then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    end)
    local playerGui = player:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GodModeGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    local frame = Instance.new("Frame")
    frame.Name = "Frame"
    frame.Size = UDim2.new(0,200,0,80)
    frame.Position = UDim2.new(0,10,0,10)
    frame.BackgroundTransparency = 0.3
    frame.Parent = screenGui
    local toggle = Instance.new("TextButton")
    toggle.Name = "Toggle"
    toggle.Size = UDim2.new(1, -20, 0, 40)
    toggle.Position = UDim2.new(0,10,0,10)
    toggle.Text = "God Mode: OFF"
    toggle.Parent = frame
    local close = Instance.new("TextButton")
    close.Name = "Close"
    close.Size = UDim2.new(1, -20, 0, 24)
    close.Position = UDim2.new(0,10,0,52)
    close.Text = "Close"
    close.Parent = frame
    local localScript = Instance.new("LocalScript")
    localScript.Name = "GodModeLocal"
    localScript.Source = [[local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local event = ReplicatedStorage:WaitForChild("GodModeToggle")
local enabled = false
local screenGui = script.Parent.Parent
local toggle = screenGui.Frame:WaitForChild("Toggle")
local close = screenGui.Frame:WaitForChild("Close")
toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    event:FireServer(enabled)
    if enabled then
        toggle.Text = "God Mode: ON"
    else
        toggle.Text = "God Mode: OFF"
    end
end)
close.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)
]]
    localScript.Parent = frame
end)
Players.PlayerRemoving:Connect(function(player)
    state[player] = nil
end)
