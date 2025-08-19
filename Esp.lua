local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- 📌 Danh sách model Clone
local allowedModelsClone = {
    ["1x1x1x1Zombie"] = true,
    ["PizzaDeliveryRig"] = true,
    ["Mafia1"] = true,
    ["Mafia2"] = true,
}

-- Internal containers
local drawingsClone = {}
local espConnectionClone
local addedConnClone, removedConnClone

-- Tạo ESP
local function createESP(model, drawings, color)
    if not model or drawings[model] then return end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local text = Drawing.new("Text")
    text.Size = 14
    text.Center = true
    text.Outline = true
    text.Visible = false
    text.Color = color

    drawings[model] = text
end

-- Xoá ESP
local function removeESP(model, drawings)
    if drawings[model] then
        pcall(function() drawings[model]:Remove() end)
        drawings[model] = nil
    end
end

-- Quét workspace và tạo ESP
local function scanWorkspaceForAllowed(allowedList, drawings, color)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and allowedList[obj.Name] and obj:FindFirstChild("HumanoidRootPart") then
            createESP(obj, drawings, color)
        end
    end
end

-- 🔥 Bắt đầu ESP Clone
function startESPClone()
    if espConnectionClone then return end
    scanWorkspaceForAllowed(allowedModelsClone, drawingsClone, Color3.fromRGB(0, 255, 0)) -- màu xanh lá

    espConnectionClone = RunService.RenderStepped:Connect(function()
        for model, text in pairs(drawingsClone) do
            if not model or not model.Parent or not model:FindFirstChild("HumanoidRootPart") then
                text.Visible = false
            else
                local hrp = model.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.5, 0))
                local dist = (hrp.Position - Camera.CFrame.Position).Magnitude
                text.Text = string.format("%s [%.0fm]", model.Name, dist)
                text.Position = Vector2.new(pos.X, pos.Y)
                text.Visible = onScreen
            end
        end
    end)

    addedConnClone = workspace.DescendantAdded:Connect(function(obj)
        local model = obj:IsA("Model") and obj or obj:FindFirstAncestorOfClass("Model")
        if model and allowedModelsClone[model.Name] and model:FindFirstChild("HumanoidRootPart") then
            createESP(model, drawingsClone, Color3.fromRGB(0, 255, 0))
        end
    end)

    removedConnClone = workspace.DescendantRemoving:Connect(function(obj)
        if obj:IsA("Model") and drawingsClone[obj] then
            removeESP(obj, drawingsClone)
        end
    end)
end

-- 🛑 Dừng ESP Clone
function stopESPClone()
    if espConnectionClone then espConnectionClone:Disconnect() end
    if addedConnClone then addedConnClone:Disconnect() end
    if removedConnClone then removedConnClone:Disconnect() end
    for _, text in pairs(drawingsClone) do
        pcall(function() text:Remove() end)
    end
    table.clear(drawingsClone)
    espConnectionClone, addedConnClone, removedConnClone = nil, nil, nil
end
