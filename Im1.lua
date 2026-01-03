-- LocalScript (put into StarterPlayerScripts)
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

-- Ẩn thanh máu mặc định
pcall(function()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
end)

-- Cấu hình: chỉnh giá trị extra để hiển thị số âm lớn hơn / nhỏ hơn
-- Ví dụ extra = 50 sẽ khiến hiển thị = Health - (MaxHealth + 50)
local EXTRA_NEGATIVE = 50

-- Tạo GUI hiển thị
local function makeGui(parent)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NegativeHealthGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = parent

    local bg = Instance.new("Frame")
    bg.Name = "BG"
    bg.Size = UDim2.new(0, 200, 0, 40)
    bg.Position = UDim2.new(0, 20, 0, 20)
    bg.BackgroundTransparency = 0.35
    bg.Parent = screenGui

    local label = Instance.new("TextLabel")
    label.Name = "HPLabel"
    label.Size = UDim2.new(1, -10, 1, -10)
    label.Position = UDim2.new(0, 5, 0, 5)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 20
    label.TextStrokeTransparency = 0.6
    label.Text = "HP: --"
    label.Parent = bg

    return screenGui, label
end

local function onCharacter(character)
    local playerGui = player:WaitForChild("PlayerGui")
    -- Remove old gui nếu có
    if playerGui:FindFirstChild("NegativeHealthGui") then
        playerGui.NegativeHealthGui:Destroy()
    end

    local screenGui, label = makeGui(playerGui)

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        humanoid = character:WaitForChild("Humanoid")
    end

    local function updateHealthDisplay(h)
        -- h = humanoid.Health
        -- Muốn hiển thị số âm: trừ đi MaxHealth + EXTRA_NEGATIVE
        local maxH = humanoid.MaxHealth or 100
        local shown = math.floor(h - (maxH + EXTRA_NEGATIVE))

        -- Ví dụ, nếu shown = -120 thì label sẽ hiển thị "HP: -120"
        label.Text = "HP: " .. tostring(shown)
    end

    -- Cập nhật lần đầu
    updateHealthDisplay(humanoid.Health)

    -- Kết nối sự kiện khi máu thay đổi
    local conn
    conn = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        -- dùng pcall để an toàn nếu humanoid bị nil giữa chừng
        pcall(function()
            updateHealthDisplay(humanoid.Health)
        end)
    end)

    -- Khi nhân vật bị thay đổi/respawn, ngắt kết nối cũ
    character.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if conn then conn:Disconnect() end
        end
    end)
end

-- Lắng nghe khi character spawn
if player.Character then
    onCharacter(player.Character)
end
player.CharacterAdded:Connect(onCharacter)
