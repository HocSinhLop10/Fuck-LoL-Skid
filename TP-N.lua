-- 🔥 SafeGenTeleport (Auto Detect V1/V2 Updated)
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
    Noli = true, JohnDoe = true, Quest666 = true
}

-- Danh sách Clone (cũng coi là nguy hiểm)
local DangerousClones = {
    PizzaDeliveryRig = true,
    Mafia1 = true,
    Mafia2 = true
}

-- Danh sách NPC/Model Survivors
local TargetModels = {
    Noob = true, Guest1337 = true, Elliot = true, Shedletsky = true,
    TwoTime = true, ["007n7"] = true, Chance = true,
    Builderman = true, Taph = true, Dusekkar = true
}

-- ✅ Hàm check có killer hoặc clone gần không
local function isDangerNear(position, radius, includeClones)
    local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
    if killersFolder then
        for _, killer in ipairs(killersFolder:GetChildren()) do
            local hrp = killer:FindFirstChild("HumanoidRootPart")
            if hrp and DangerousKillers[killer.Name] then
                if (hrp.Position - position).Magnitude <= radius then
                    return true
                end
            end
            if includeClones and hrp and DangerousClones[killer.Name] then
                if (hrp.Position - position).Magnitude <= radius then
                    return true
                end
            end
        end
    end
    return false
end

-- ✅ Teleport đến generator xa & an toàn nhất
local function teleportToSafeGenerator(includeClones)
    local character = LP.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local myPos = character.HumanoidRootPart.Position
    local bestGen, bestDistance = nil, 0

    local mapFolder = workspace:FindFirstChild("Map")
        and workspace.Map:FindFirstChild("Ingame")
        and workspace.Map.Ingame:FindFirstChild("Map")
    if not mapFolder then return end

    for _, gen in ipairs(mapFolder:GetChildren()) do
        if gen.Name == "Generator" and gen:FindFirstChild("Progress") then
            local genPos = gen:GetPivot().Position
            local dist = (myPos - genPos).Magnitude
            -- chỉ chọn generator an toàn
            if dist > bestDistance and not isDangerNear(genPos, 50, includeClones) then
                bestDistance = dist
                bestGen = gen
            end
        end
    end

    if bestGen then
        local goalPos = (bestGen:GetPivot() * CFrame.new(0, 0, -3)).Position
        character:PivotTo(CFrame.new(goalPos + Vector3.new(0, 2, 0)))
        print("✅ Teleported to safe generator:", bestGen.Name)
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
        if character and character:FindFirstChild("HumanoidRootPart") then
            local charName = character.Name

            -- Nếu là Killer
            if DangerousKillers[charName] or DangerousClones[charName] then
                -- KHÔNG teleport nếu có killer hoặc clone gần
                if not isDangerNear(character.HumanoidRootPart.Position, 50, true) then
                    teleportToSafeGenerator(false) -- killers chỉ né killers, không cần né clone
                end

            -- Nếu là Survivor
            elseif TargetModels[charName] then
                if isDangerNear(character.HumanoidRootPart.Position, 50, true) then
                    teleportToSafeGenerator(true) -- survivors né cả killers + clone
                end
            end
        end
        task.wait(delayTime)
    end
end)
