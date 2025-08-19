-- 🔥 SafeGenTeleport (Auto Detect V1/V2)
_G.SafeGenTeleport = true

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- ✅ Danh sách account thật dùng V2
local AllowedPlayers = {
    ["Hu1a0_Hu9"] = true,
    ["hdksakst"] = true
}

-- Danh sách killers nguy hiểm
local DangerousKillers = {
    Jason = true, ["1x1x1x1"] = true, c00lkidd = true,
    Noli = true, JohnDoe = true, Quest666 = true, Mafia2 = true,
    Mafia1 = true, PizzaDeliveryRig = true
}

-- Danh sách NPC/Model trong map
local TargetModels = {
    Noob = true, Guest1337 = true, Elliot = true, Shedletsky = true,
    TwoTime = true, ["007n7"] = true, Chance = true,
    Builderman = true, Taph = true, Dusekkar = true
}

-- Hàm check killer
local function isDangerousKillerNear(position, radius)
    local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
    if not killersFolder then return false end
    for _, killer in ipairs(killersFolder:GetChildren()) do
        local hrp = killer:FindFirstChild("HumanoidRootPart")
        if hrp and DangerousKillers[killer.Name] then
            if (hrp.Position - position).Magnitude <= radius then
                return true
            end
        end
    end
    return false
end

-- Hàm teleport
local function teleportToFarthestGenerator()
    local character = LP.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local myPos = character.HumanoidRootPart.Position
    local farthestGen, maxDistance = nil, 0

    local mapFolder = workspace:FindFirstChild("Map")
        and workspace.Map:FindFirstChild("Ingame")
        and workspace.Map.Ingame:FindFirstChild("Map")
    if not mapFolder then return end

    for _, gen in ipairs(mapFolder:GetChildren()) do
        if gen.Name == "Generator" and gen:FindFirstChild("Progress") then
            local genPos = gen:GetPivot().Position
            local dist = (myPos - genPos).Magnitude
            if dist > maxDistance then
                maxDistance = dist
                farthestGen = gen
            end
        end
    end

    if farthestGen then
        local goalPos = (farthestGen:GetPivot() * CFrame.new(0, 0, -3)).Position
        character:PivotTo(CFrame.new(goalPos + Vector3.new(0, 2, 0)))
        print("✅ Teleported to farthest generator:", farthestGen.Name)
    end
end

-- 🔄 Loop chính (auto detect V1/V2)
task.spawn(function()
    local delayTime = 0.1 -- mặc định V1
    if AllowedPlayers[LP.Name] then
        print("🚀 V2 Mode enabled for:", LP.Name)
        delayTime = 0.0000001
    else
        print("🐢 V1 Mode enabled for:", LP.Name)
    end

    while _G.SafeGenTeleport do
        local character = LP.Character
        if character and TargetModels[character.Name] then
            if isDangerousKillerNear(character.HumanoidRootPart.Position, 50) then
                teleportToFarthestGenerator()
            end
        end
        task.wait(delayTime)
    end
end)
