-- Settings
local KILL_RADIUS = 15
local TICK_RATE = 0.1

local Players = game:GetService("Players")

-- Core Function
local function executeKillAura(originPart)
	local currentPosition = originPart.Position
	
	-- Define detection parameters
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	
	-- Detect parts within the defined radius
	local targetParts = workspace:GetPartBoundsInRadius(currentPosition, KILL_RADIUS, params)
	local processedCharacters = {}

	for _, part in pairs(targetParts) do
		local character = part.Parent
		
		-- Ensure we only process each model once per tick
		if character and not processedCharacters[character] then
			processedCharacters[character] = true
			
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			
			if humanoid and humanoid.Health > 0 then
				-- Validate if the target is an NPC (not a Player)
				local isPlayer = Players:GetPlayerFromCharacter(character)
				
				if not isPlayer then
					-- Instant kill command
					humanoid.Health = 0
				end
			end
		end
	end
end

-- Listener for Player Spawning
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local rootPart = character:WaitForChild("HumanoidRootPart")
		
		-- Active loop while character exists
		while character and character.Parent do
			executeKillAura(rootPart)
			task.wait(TICK_RATE)
		end
	end)
end)