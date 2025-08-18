-- 🔥 SafeGenTeleport V2
_G.SafeGenTeleportV2 = true

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- ✅ Danh sách account thật được phép sử dụng script
local AllowedPlayers = {
    ["Hu1a0_Hu9"] = true,
    ["hdksakst"] = true
}

-- 🚫 Nếu LocalPlayer không có trong danh sách thì thoát luôn
if not AllowedPlayers[LP.Name] then
    warn("⛔ '"..LP.Name.."' không có quyền dùng SafeGenTeleportV2")
    return
end

-- Danh sách killers nguy hiểm (giữ nguyên như bản v1)
local DangerousKillersV2 = {
    Jason = true, ["1x1x1x1"] = true, c00lkidd = true,
    Noli = true, JohnDoe = true, Quest666 = true
}

-- Danh sách NPC/Model trong map để filter
local TargetModelsV2 = {
    Noob = true, Guest1337 = true, Elliot = true, Shedletsky = true,
    TwoTime = true, ["007n7"] = true, Chance = true,
    Builderman = true, Taph = true, Dusekkar = true
}

local function isDangerousKillerNearV2(position, radius)
    local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
    if not killersFolder then return false end
    for _, killer in ipairs(killersFolder:GetChildren()) do
        local hrp = killer:FindFirstChild("HumanoidRootPart")
        if hrp and DangerousKillersV2[killer.Name] then
            if (hrp.Position - position).Magnitude <= radius then
                return true
            end
        end
    end
    return false
end

local function teleportToFarthestGeneratorV2()
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
        print("✅ [V2] Teleported to farthest generator:", farthestGen.Name)
    end
end

-- 🔄 Loop chính V2
task.spawn(function()
    while _G.SafeGenTeleportV2 do
        local character = LP.Character
        -- ✅ Chỉ chạy cho account hợp lệ + khi nhân vật thuộc TargetModels
        if character and TargetModelsV2[character.Name] then
            if isDangerousKillerNearV2(character.HumanoidRootPart.Position, 50) then
                teleportToFarthestGeneratorV2()
            end
        end
        task.wait(0.0000001) -- 🚀 Tốc độ cực nhanh
    end
end)
