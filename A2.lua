local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local event = ReplicatedStorage:FindFirstChild("KillAuraToggleEvent") or Instance.new("RemoteEvent", ReplicatedStorage)
event.Name = "KillAuraToggleEvent"

local enabledPlayers = {}
local defaultRadius = 50

event.OnServerEvent:Connect(function(player, enabled, radius)
	if not player then return end
	enabledPlayers[player.UserId] = {enabled = enabled == true, radius = tonumber(radius) or defaultRadius}
end)

Players.PlayerRemoving:Connect(function(player)
	enabledPlayers[player.UserId] = nil
end)

RunService.Heartbeat:Connect(function()
	for userId, data in pairs(enabledPlayers) do
		if data.enabled then
			local player = Players:GetPlayerByUserId(userId)
			if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				local pos = player.Character.HumanoidRootPart.Position
				local rad = data.radius
				for _, obj in pairs(workspace:GetDescendants()) do
					if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
						local hum = obj:FindFirstChild("Humanoid")
						local hrp = obj:FindFirstChild("HumanoidRootPart")
						if hum and hrp and hum.Health > 0 and (hrp.Position - pos).Magnitude <= rad then
							local owner = Players:GetPlayerFromCharacter(obj)
							if not owner then
								pcall(function()
									hum:TakeDamage(hum.Health + 99999)
									hum:ChangeState(Enum.HumanoidStateType.Dead)
									obj:BreakJoints()
								end)
							end
						end
					end
				end
			end
		end
	end
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local event = ReplicatedStorage:WaitForChild("KillAuraToggleEvent")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KillAuraGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,220,0,120)
frame.Position = UDim2.new(0,10,0,10)
frame.Parent = screenGui
frame.BackgroundTransparency = 0.3

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0,200,0,40)
toggle.Position = UDim2.new(0,10,0,10)
toggle.Text = "Off"
toggle.Parent = frame

local radiusBox = Instance.new("TextBox")
radiusBox.Size = UDim2.new(0,100,0,30)
radiusBox.Position = UDim2.new(0,10,0,60)
radiusBox.Text = "50"
radiusBox.ClearTextOnFocus = false
radiusBox.Parent = frame

local radiusLabel = Instance.new("TextLabel")
radiusLabel.Size = UDim2.new(0,100,0,30)
radiusLabel.Position = UDim2.new(0,110,0,60)
radiusLabel.Text = "Radius"
radiusLabel.Parent = frame

local enabled = false
local radius = 50

toggle.MouseButton1Click:Connect(function()
	enabled = not enabled
	toggle.Text = enabled and "On" or "Off"
	event:FireServer(enabled, radius)
end)

radiusBox.FocusLost:Connect(function(enterPressed)
	local n = tonumber(radiusBox.Text)
	if n and n > 0 then
		radius = n
		radiusLabel.Text = "Radius: "..tostring(radius)
		if enabled then
			event:FireServer(true, radius)
		end
	else
		radiusBox.Text = tostring(radius)
	end
end)
