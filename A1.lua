local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local KILL_RANGE = 200

local function isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        local hrp = char:WaitForChild("HumanoidRootPart",5)
        local humanoid = char:WaitForChild("Humanoid",5)
        if not hrp or not humanoid then return end
        local conn
        conn = RunService.Heartbeat:Connect(function()
            if humanoid.Health <= 0 then conn:Disconnect() return end
            local origin = hrp.Position
            for _, model in ipairs(workspace:GetChildren()) do
                if model:IsA("Model") and model ~= char then
                    local h = model:FindFirstChildOfClass("Humanoid")
                    if h and h.Health > 0 and not isPlayerCharacter(model) then
                        local targetRoot = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
                        if targetRoot and (targetRoot.Position - origin).Magnitude <= KILL_RANGE then
                            pcall(function()
                                h.Health = 0
                                h:ChangeState(Enum.HumanoidStateType.Dead)
                                if targetRoot:IsA("BasePart") then targetRoot.Anchored = true end
                                for _, v in pairs(model:GetDescendants()) do
                                    if v:IsA("Animator") or v:IsA("AnimationController") then v:Destroy() end
                                end
                                pcall(function() model:BreakJoints() end)
                            end)
                        end
                    end
                end
            end
        end)
    end)
end)
