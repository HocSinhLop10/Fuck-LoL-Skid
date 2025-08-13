_G.SafeGenTeleport = true

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local DangerousKillers = {
    Jason = true, ["1x1x1x1"] = true, c00lkidd = true,
    Noli = true, JohnDoe = true, Quest666 = true
}

local TargetModels = {
    Noob = true, Guest1337 = true, Elliot = true, Shedletsky = true,
    TwoTime = true, ["007n7"] = true, Chance = true,
    Builderman = true, Taph = true, Dusekkar = true
}

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

local function teleportToFarthestGenerator()
    local character = LP.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local myPos = character.HumanoidRootPart.Position
    local farthestGen, maxDistance = nil, 0

    local mapFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Ingame") and workspace.Map.Ingame:FindFirstChild("Map")
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

-- Loop chính
task.spawn(function()
    while _G.SafeGenTeleport do
        local character = LP.Character
        if character and TargetModels[character.Name] then
            if isDangerousKillerNear(character.HumanoidRootPart.Position, 50) then
                teleportToFarthestGenerator()
            end
        end
        task.wait(0.1)
    end
end)
