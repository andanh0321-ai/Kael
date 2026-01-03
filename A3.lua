local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local RADIUS = 200
local ENABLED = false
local SCAN_RATE = 0.25
local last = 0

local function getPos(model)
	if not model then return end
	local hrp = model:FindFirstChild("HumanoidRootPart")
	if hrp then return hrp.Position end
	if model.PrimaryPart then return model.PrimaryPart.Position end
	for _,v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") then return v.Position end
	end
end

local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0,160,0,50)
btn.Position = UDim2.new(0,20,0,20)
btn.Text = "Kill Aura: OFF"
btn.Parent = gui

btn.MouseButton1Click:Connect(function()
	ENABLED = not ENABLED
	btn.Text = ENABLED and "Kill Aura: ON" or "Kill Aura: OFF"
end)

RunService.Heartbeat:Connect(function()
	if not ENABLED then return end
	if os.clock() - last < SCAN_RATE then return end
	last = os.clock()

	local char = player.Character
	if not char then return end
	local origin = getPos(char)
	if not origin then return end

	for _,hum in pairs(workspace:GetDescendants()) do
		if hum:IsA("Humanoid") and hum.Health > 0 then
			local model = hum.Parent
			if model and model:IsA("Model") and not Players:GetPlayerFromCharacter(model) then
				local pos = getPos(model)
				if pos and (pos - origin).Magnitude <= RADIUS then
					hum.Health = 0
					pcall(function() hum:ChangeState(Enum.HumanoidStateType.Dead) end)
					pcall(function() model:BreakJoints() end)
					pcall(function() hum.PlatformStand = true end)
					for _,d in pairs(model:GetDescendants()) do
						if d:IsA("Script") or d:IsA("ModuleScript") then
							pcall(function() d.Disabled = true end)
						end
					end
				end
			end
		end
	end
end)
