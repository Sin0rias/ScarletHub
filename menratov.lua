-- ========================================
-- Services
-- ========================================
local Players = game:GetService('Players')
local CoreGui = game:GetService('CoreGui')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local Workspace = game:GetService('Workspace')
local Lighting = game:GetService('Lighting')
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService('TeleportService')
local PathfindingService = game:GetService('PathfindingService')
local TweenService = game:GetService('TweenService')

-- ========================================
-- State Management
-- ========================================
local isNotificationActive = false
local isESPPanelActive = false
local isPanelCollapsed = false
local currentCategory = 'ESP'
local savedCFrame = nil
local tweenSpeed = 35
local tpwalking = false
local speeds = 50 -- Увеличена скорость по умолчанию
local nowe = false

-- Visual states
local isLockTimeESPEnabled = false
local isFullbrightEnabled = false
local isPlayerEspActive = false
local playerEspInstances = {}
local lockEspInstances = {}

-- Movement states
local isSpeedEnabled = false
local isMultijumpEnabled = false
local isNoclipEnabled = false
local originalWalkspeed = 16
local customWalkspeed = 50
local multijumpForce = 50

-- Cheats states (from 2.txt)
local godmodeEnabled = true
local autoStealEnabled = false

-- Floor states (updated from new script)
local floorEnabled = false
local floorSize = Vector3.new(4, 0.5, 4)
local floorColor = Color3.fromRGB(50, 150, 200)
local floorParts = {}
local distance = 10
local godmodeHealthChangedConnection = nil

-- Teleport states (updated from new script)
local tweenActive = false
local character, hrp, humanoid = nil, nil, nil

-- ========================================
-- Private Server Functions (УСТАРЕВШИЙ МЕТОД)
-- ========================================
local md5 = {}
local hmac = {}
local base64 = {}

do
    do
        local T = {
            0xd76aa478,
            0xe8c7b756,
            0x242070db,
            0xc1bdceee,
            0xf57c0faf,
            0x4787c62a,
            0xa8304613,
            0xfd469501,
            0x698098d8,
            0x8b44f7af,
            0xffff5bb1,
            0x895cd7be,
            0x6b901122,
            0xfd987193,
            0xa679438e,
            0x49b40821,
            0xf61e2562,
            0xc040b340,
            0x265e5a51,
            0xe9b6c7aa,
            0xd62f105d,
            0x02441453,
            0xd8a1e681,
            0xe7d3fbc8,
            0x21e1cde6,
            0xc33707d6,
            0xf4d50d87,
            0x455a14ed,
            0xa9e3e905,
            0xfcefa3f8,
            0x676f02d9,
            0x8d2a4c8a,
            0xfffa3942,
            0x8771f681,
            0x6d9d6122,
            0xfde5380c,
            0xa4beea44,
            0x4bdecfa9,
            0xf6bb4b60,
            0xbebfbc70,
            0x289b7ec6,
            0xeaa127fa,
            0xd4ef3085,
            0x04881d05,
            0xd9d4d039,
            0xe6db99e5,
            0x1fa27cf8,
            0xc4ac5665,
            0xf4292244,
            0x432aff97,
            0xab9423a7,
            0xfc93a039,
            0x655b59c3,
            0x8f0ccc92,
            0xffeff47d,
            0x85845dd1,
            0x6fa87e4f,
            0xfe2ce6e0,
            0xa3014314,
            0x4e0811a1,
            0xf7537e82,
            0xbd3af235,
            0x2ad7d2bb,
            0xeb86d391,
        }

        local function add(a, b)
            local lsw = bit32.band(a, 0xFFFF) + bit32.band(b, 0xFFFF)
            local msw = bit32.rshift(a, 16) + bit32.rshift(b, 16) + bit32.rshift(lsw, 16)
            return bit32.bor(bit32.lshift(msw, 16), bit32.band(lsw, 0xFFFF))
        end

        local function rol(x, n)
            return bit32.bor(bit32.lshift(x, n), bit32.rshift(x, 32 - n))
        end

        local function F(x, y, z)
            return bit32.bor(bit32.band(x, y), bit32.band(bit32.bnot(x), z))
        end
        local function G(x, y, z)
            return bit32.bor(bit32.band(x, z), bit32.band(y, bit32.bnot(z)))
        end
        local function H(x, y, z)
            return bit32.bxor(x, bit32.bxor(y, z))
        end
        local function I(x, y, z)
            return bit32.bxor(y, bit32.bor(x, bit32.bnot(z)))
        end

        function md5.sum(message)
            local a, b, c, d = 0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476

            local message_len = #message
            local padded_message = message .. "\128"
            while #padded_message % 64 ~= 56 do
                padded_message = padded_message .. "\0"
            end

            local len_bytes = ""
            local len_bits = message_len * 8
            for i = 0, 7 do
                len_bytes = len_bytes .. string.char(bit32.band(bit32.rshift(len_bits, i * 8), 0xFF))
            end
            padded_message = padded_message .. len_bytes

            for i = 1, #padded_message, 64 do
                local chunk = padded_message:sub(i, i + 63)
                local X = {}
                for j = 0, 15 do
                    local b1, b2, b3, b4 = chunk:byte(j * 4 + 1, j * 4 + 4)
                    X[j] = bit32.bor(b1, bit32.lshift(b2, 8), bit32.lshift(b3, 16), bit32.lshift(b4, 24))
                end

                local aa, bb, cc, dd = a, b, c, d

                local s = { 7, 12, 17, 22, 5, 9, 14, 20, 4, 11, 16, 23, 6, 10, 15, 21 }

                for j = 0, 63 do
                    local f, k, shift_index
                    if j < 16 then
                        f = F(b, c, d)
                        k = j
                        shift_index = j % 4
                    elseif j < 32 then
                        f = G(b, c, d)
                        k = (1 + 5 * j) % 16
                        shift_index = 4 + (j % 4)
                    elseif j < 48 then
                        f = H(b, c, d)
                        k = (5 + 3 * j) % 16
                        shift_index = 8 + (j % 4)
                    else
                        f = I(b, c, d)
                        k = (7 * j) % 16
                        shift_index = 12 + (j % 4)
                    end

                    local temp = add(a, f)
                    temp = add(temp, X[k])
                    temp = add(temp, T[j + 1])
                    temp = rol(temp, s[shift_index + 1])

                    local new_b = add(b, temp)
                    a, b, c, d = d, new_b, b, c
                end

                a = add(a, aa)
                b = add(b, bb)
                c = add(c, cc)
                d = add(d, dd)
            end

            local function to_le_hex(n)
                local s = ""
                for i = 0, 3 do
                    s = s .. string.char(bit32.band(bit32.rshift(n, i * 8), 0xFF))
                end
                return s
            end

            return to_le_hex(a) .. to_le_hex(b) .. to_le_hex(c) .. to_le_hex(d)
        end
    end

    do
        function hmac.new(key, msg, hash_func)
            if #key > 64 then
                key = hash_func(key)
            end

            local o_key_pad = ""
            local i_key_pad = ""
            for i = 1, 64 do
                local byte = (i <= #key and string.byte(key, i)) or 0
                o_key_pad = o_key_pad .. string.char(bit32.bxor(byte, 0x5C))
                i_key_pad = i_key_pad .. string.char(bit32.bxor(byte, 0x36))
            end

            return hash_func(o_key_pad .. hash_func(i_key_pad .. msg))
        end
    end

    do
        local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

        function base64.encode(data)
            return (
                (data:gsub(".", function(x)
                    local r, b_val = "", x:byte()
                    for i = 8, 1, -1 do
                        r = r .. (b_val % 2 ^ i - b_val % 2 ^ (i - 1) > 0 and "1" or "0")
                    end
                    return r
                end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
                    if #x < 6 then
                        return ""
                    end
                    local c = 0
                    for i = 1, 6 do
                        c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
                    end
                    return b:sub(c + 1, c + 1)
                end) .. ({ "", "==", "=" })[#data % 3 + 1]
            )
        end
    end
end

local function GenerateReservedServerCode(placeId)
    local uuid = {}
    for i = 1, 16 do
        uuid[i] = math.random(0, 255)
    end

    uuid[7] = bit32.bor(bit32.band(uuid[7], 0x0F), 0x40) -- v4
    uuid[9] = bit32.bor(bit32.band(uuid[9], 0x3F), 0x80) -- RFC 4122

    local firstBytes = ""
    for i = 1, 16 do
        firstBytes = firstBytes .. string.char(uuid[i])
    end

    local gameCode =
        string.format("%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x", table.unpack(uuid))

    local placeIdBytes = ""
    local pIdRec = placeId
    for _ = 1, 8 do
        placeIdBytes = placeIdBytes .. string.char(pIdRec % 256)
        pIdRec = math.floor(pIdRec / 256)
    end

    local content = firstBytes .. placeIdBytes

    local SUPERDUPERSECRETROBLOXKEYTHATTHEYDIDNTCHANGEEVERSINCEFOREVER = "e4Yn8ckbCJtw2sv7qmbg" -- legacy leaked key from ages ago that still works due to roblox being roblox.
    local signature = hmac.new(SUPERDUPERSECRETROBLOXKEYTHATTHEYDIDNTCHANGEEVERSINCEFOREVER, content, md5.sum)

    local accessCodeBytes = signature .. content

    local accessCode = base64.encode(accessCodeBytes)
    accessCode = accessCode:gsub("+", "-"):gsub("/", "_")

    local pdding = 0
    accessCode, _ = accessCode:gsub("=", function()
        pdding = pdding + 1
        return ""
    end)

    accessCode = accessCode .. tostring(pdding)

    return accessCode, gameCode
end

-- ========================================
-- UI Creation & Logic
-- ========================================
local function showNotification(message)
    if not isNotificationActive then
        isNotificationActive = true
        local screenGui = CoreGui:FindFirstChild("NotificationGUI") or Instance.new("ScreenGui")
        screenGui.Name = "NotificationGUI"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

        local frame = Instance.new("Frame")
        -- ИЗМЕНЕНИЕ ДЛЯ ПЛАНШЕТА: Используем Scale (0.7) для ширины, чтобы уведомление хорошо выглядело на разных экранах.
        frame.Size = UDim2.new(0.7, 0, 0, 50)
        frame.AnchorPoint = Vector2.new(0.5, 1) -- Установка AnchorPoint для центрирования
        frame.Position = UDim2.new(0.5, 0, 1, -50) -- Центрирование по X, позиция у нижнего края
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        frame.BorderColor3 = Color3.fromRGB(20, 20, 20)
        frame.BorderSizePixel = 2
        frame.Parent = screenGui

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 1, -10)
        label.Position = UDim2.new(0, 5, 0, 5)
        label.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.Font = Enum.Font.SourceSansBold
        label.TextWrapped = true
        label.Text = message
        label.Parent = frame

        frame.Visible = false
        frame.Transparency = 1
        -- ИЗМЕНЕНИЕ ДЛЯ ПЛАНШЕТА: Корректировка TweenSizeAndPosition под новые scaled-значения.
        frame:TweenSizeAndPosition(
            UDim2.new(0.7, 0, 0, 50),
            UDim2.new(0.5, 0, 1, -60),
            "Out", "Quad", 0.5, true
        )
        task.wait(0.5)
        frame.Visible = true
        frame:TweenTransparency(Enum.Transparency.Background, 0, "Out", "Quad", 0.5, true)
        label:TweenTransparency(Enum.Transparency.Background, 1, "Out", "Quad", 0.5, true)

        task.wait(3)

        frame:TweenTransparency(Enum.Transparency.Background, 1, "In", "Quad", 0.5, true)
        label:TweenTransparency(Enum.Transparency.Background, 1, "In", "Quad", 0.5, true)
        task.wait(0.5)
        frame:Destroy()
        isNotificationActive = false
    end
end

-- ========================================
-- ESP Functions
-- ========================================
local function cleanUpPlayerEsp(player)
    if playerEspInstances[player.UserId] then
        for _, inst in ipairs(playerEspInstances[player.UserId]) do
            if inst and inst.Parent then
                inst:Destroy()
            end
        end
        playerEspInstances[player.UserId] = nil
    end
end

local function createPlayerEspElements(player)
    if player == LocalPlayer or playerEspInstances[player.UserId] then return end

    local character = player.Character or player.CharacterAdded:Wait()
    if not character then
        warn("ESP: Character not found for player: " .. player.Name)
        return
    end

    local humanoid = character:WaitForChild("Humanoid", 1)
    local rootPart = character:WaitForChild("HumanoidRootPart", 1)
    if not humanoid or not rootPart then
        warn("ESP: Humanoid or HumanoidRootPart not found for player: " .. player.Name)
        return
    end

    local playerObjects = {}

    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.new(1, 1, 1)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.Enabled = true
    highlight.Parent = character
    table.insert(playerObjects, highlight)

    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(4, 0, 2, 0)
    billboardGui.StudsOffset = Vector3.new(0, 4, 0)
    billboardGui.ClipsDescendants = true
    billboardGui.Parent = rootPart

    local containerFrame = Instance.new("Frame", billboardGui)
    containerFrame.Name = "Container"
    containerFrame.Size = UDim2.new(1, 0, 1, 0)
    containerFrame.BackgroundTransparency = 1

    local nameLabel = Instance.new("TextLabel", containerFrame)
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0.5, 0, 0.4, 0)
    nameLabel.Position = UDim2.new(0.25, 0, 0.25, 0)
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextScaled = true
    nameLabel.BackgroundTransparency = 1

    local healthBar = Instance.new("Frame", containerFrame)
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(0.5, 0, 0.2, 0)
    healthBar.Position = UDim2.new(0.25, 0, 0.65, 0)
    healthBar.BackgroundColor3 = Color3.new(1, 0, 0)
    healthBar.BorderSizePixel = 1
    healthBar.BorderColor3 = Color3.new(1, 1, 1)

    local healthFill = Instance.new("Frame", healthBar)
    healthFill.Name = "HealthFill"
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.new(0, 1, 0)
    healthFill.BorderSizePixel = 0

    table.insert(playerObjects, billboardGui)

    playerEspInstances[player.UserId] = playerObjects
end

local function updatePlayerEspElements(player)
    local espData = playerEspInstances[player.UserId]
    if not espData then return end

    local highlight = espData[1]
    local billboardGui = espData[2]

    local character = player.Character
    if not character or not character:FindFirstChild("Head") then return end

    local myHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
    if not myHead then return end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local raycastResult = Workspace:Raycast(myHead.Position, character.Head.Position - myHead.Position, raycastParams)
    local isVisible = not raycastResult or raycastResult.Instance:IsDescendantOf(player.Character)

    local color = isVisible and Color3.fromRGB(76, 209, 55) or Color3.fromRGB(232, 65, 24)

    local distance = (myHead.Position - character.Head.Position).Magnitude
    local scaleFactor = math.clamp(500 / distance, 0.5, 2.0)
    billboardGui.Size = UDim2.new(4 * scaleFactor, 0, 2 * scaleFactor, 0)

    if highlight then
        highlight.FillColor = color
        highlight.OutlineColor = color
    end

    if billboardGui and billboardGui.Parent then
        local container = billboardGui:FindFirstChild("Container")
        if not container then return end

        local nameLabel = container:FindFirstChild("NameLabel")
        local healthBar = container:FindFirstChild("HealthBar")
        local healthFill = healthBar and healthBar:FindFirstChild("HealthFill")
        local humanoid = character:FindFirstChildOfClass("Humanoid")

        if nameLabel then
            nameLabel.TextColor3 = color
        end
        if healthFill and humanoid then
            healthFill.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
            healthFill.BackgroundColor3 = color
        end
    end
end

local function updateLockESP()
    for _, inst in pairs(lockEspInstances) do
        if inst and inst.Parent then inst:Destroy() end
    end
    lockEspInstances = {}

    if not isLockTimeESPEnabled then return end

    for _, plot in pairs(Workspace.Plots:GetChildren()) do
        local purchases = plot:FindFirstChild("Purchases")
        if not purchases then warn("Lock ESP: Could not find 'Purchases' for plot " .. plot.Name); continue end

        local plotBlock = purchases:FindFirstChild("PlotBlock")
        if not plotBlock then warn("Lock ESP: Could not find 'PlotBlock' for plot " .. plot.Name); continue end

        local main = plotBlock:FindFirstChild("Main")
        if not main then warn("Lock ESP: Could not find 'Main' for plot " .. plot.Name); continue end

        local billboardGui = main:FindFirstChild("BillboardGui")
        if not billboardGui then warn("Lock ESP: Could not find 'BillboardGui' for plot " .. plot.Name); continue end

        local timeLabel = billboardGui:FindFirstChild("RemainingTime")
        if not timeLabel then warn("Lock ESP: Could not find 'RemainingTime' for plot " .. plot.Name); continue end

        local isUnlocked = timeLabel.Text == "0s"
        local displayText = isUnlocked and "UNLOCKED" or timeLabel.Text
        local plotName = plot.Name
        local color = plotName == (LocalPlayer.Name .. "'s Base") and Color3.fromRGB(76, 209, 55) or
                     (isUnlocked and Color3.fromRGB(232, 65, 24) or Color3.fromRGB(247, 215, 63))

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "LockESP_"..plot.Name
        billboard.Size = UDim2.new(0, 250, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 5, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = main

        local label = Instance.new("TextLabel")
        label.Name = "LockLabel"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.TextSize = 20
        label.Font = Enum.Font.GothamBold
        label.Parent = billboard

        billboard.Parent = plot
        lockEspInstances[plot] = billboard
        label.Text = displayText
        label.TextColor3 = color
    end
end


local function toggleFullbright(state)
    if state then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
    else
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end

-- ========================================
-- Movement Functions
-- ========================================

local function toggleSpeed(state)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if state then
            originalWalkspeed = humanoid.WalkSpeed
            humanoid.WalkSpeed = customWalkspeed
        else
            humanoid.WalkSpeed = originalWalkspeed
        end
    end
end

local function toggleMultijump(state)
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if humanoid and rootPart then
        if state then
            humanoid.PlatformStand = true
            humanoid.PlatformStand = false
            rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 1, 0)

            UserInputService.JumpRequest:Connect(function()
                if isMultijumpEnabled then
                    rootPart.Velocity = Vector3.new(0, multijumpForce, 0)
                end
            end)
        else
            humanoid.PlatformStand = false
        end
    end
end

local function toggleNoclip(state)
    local character = LocalPlayer.Character
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not state
            end
        end
    end
end

-- ========================================
-- Cheats & Teleport Functions (New logic)
-- ========================================

-- Функция для получения текущих ссылок на части персонажа
local function getCurrentReferences()
    character = LocalPlayer.Character
    if character then
        hrp = character:FindFirstChild('HumanoidRootPart')
        humanoid = character:FindFirstChild('Humanoid')
    else
        hrp, humanoid = nil, nil
    end
    return character, hrp, humanoid
end

-- Применение годмода
local function applyGodmode()
    getCurrentReferences()
    if humanoid then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        humanoid.BreakJointsOnDeath = false
        if godmodeHealthChangedConnection then
            godmodeHealthChangedConnection:Disconnect()
        end
        godmodeHealthChangedConnection = humanoid.HealthChanged:Connect(function()
            if godmodeEnabled and humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    end
end

-- Создание платформы на заданной высоте
local function createPlatformAtHeight(height)
    for i = #floorParts, 1, -1 do
        if floorParts[i] and floorParts[i].Parent then
            floorParts[i]:Destroy()
        end
        table.remove(floorParts, i)
    end
    getCurrentReferences()
    if not hrp then return end

    local pos = hrp.Position
    local stepsX = math.ceil(distance * 2 / floorSize.X)
    local stepsZ = math.ceil(distance * 2 / floorSize.Z)

    for x = -stepsX / 2, stepsX / 2 do
        for z = -stepsZ / 2, stepsZ / 2 do
            local p = Instance.new('Part')
            p.Size = floorSize
            p.Position = Vector3.new(pos.X + x * floorSize.X, height, pos.Z + z * floorSize.Z)
            p.Anchored = true
            p.CanCollide = true
            p.Color = floorColor
            p.Material = Enum.Material.ForceField
            p.Parent = Workspace
            table.insert(floorParts, p)
        end
    end
end

-- Удаление всех созданных полов
local function clearAllFloors()
    for i = #floorParts, 1, -1 do
        if floorParts[i] and floorParts[i].Parent then
            floorParts[i]:Destroy()
        end
        table.remove(floorParts, i)
    end
end

-- Перемещение с помощью pathfinding
local function pathfindingTween(targetPosition, speed)
    if tweenActive or not targetPosition then return end
    tweenActive = true
    getCurrentReferences()
    if not hrp or not humanoid then
        tweenActive = false
        return
    end

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentJumpHeight = 10,
        AgentMaxSlope = 45
    })
    path:ComputeAsync(hrp.Position, targetPosition)

    if path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        local index = 1
        local function moveNext()
            if not tweenActive or index > #waypoints then
                tweenActive = false
                return
            end
            local wp = waypoints[index]
            if wp.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end
            local targetPos = Vector3.new(wp.Position.X, hrp.Position.Y, wp.Position.Z)
            local dist = (hrp.Position - targetPos).Magnitude
            local t = dist / speed
            local tween = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {
                CFrame = CFrame.new(targetPos)
            })
            tween:Play()
            tween.Completed:Connect(function()
                index = index + 1
                moveNext()
            end)
        end
        moveNext()
    else
        warn('❌ Pathfinding falló')
        tweenActive = false
    end
end

local function onInteractionFinished()
    if savedCFrame then
        pathfindingTween(savedCFrame.Position, tweenSpeed)
    end
end

local function connectProximityPrompts()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA('ProximityPrompt') then
            obj.Triggered:Connect(function(plr)
                if plr == LocalPlayer and autoStealEnabled then
                    wait(0.1)
                    onInteractionFinished()
                end
            end)
        end
    end
end

-- New function for toggling floor logic
local function toggleFloorLogic(state)
    floorEnabled = state
    if not state then
        clearAllFloors()
    end
end

-- New function for auto steal toggle
local function toggleAutoStealLogic(state)
    autoStealEnabled = state
end

-- New function for saving position
local function saveCurrentPosition()
    getCurrentReferences()
    if hrp then
        savedCFrame = hrp.CFrame
        showNotification("Текущая позиция сохранена!")
    end
end

-- New function for teleporting
local function teleportToSavedPosition()
    if savedCframe and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = savedCframe
        showNotification("Телепортация к сохранённой позиции!")
    else
        showNotification("Позиция для телепортации не сохранена.")
    end
end

-- ========================================
-- Main Panel
-- ========================================
local function createESPPanel()
    if isESPPanelActive then return end
    isESPPanelActive = true

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MainPanelGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainPanel = Instance.new("Frame")
    -- ИЗМЕНЕНИЕ ДЛЯ ИСПРАВЛЕНИЯ РАСТЯНУТОГО ВИДА: Используем фиксированный размер (350px)
    mainPanel.Size = UDim2.new(0, 350, 0, 190) 
    mainPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainPanel.AnchorPoint = Vector2.new(0.5, 0.5)
    mainPanel.BackgroundColor3 = Color3.fromRGB(56, 23, 35) -- Красный оттенок
    mainPanel.BackgroundTransparency = 0.2
    mainPanel.BorderColor3 = Color3.fromRGB(255, 0, 0) -- Красная обводка
    mainPanel.BorderSizePixel = 2 -- Толщина обводки
    mainPanel.Parent = screenGui

    local UICorner_Panel = Instance.new("UICorner")
    UICorner_Panel.CornerRadius = UDim.new(0, 8)
    UICorner_Panel.Parent = mainPanel

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Красный заголовок
    header.Parent = mainPanel

    local headerLabel = Instance.new("TextLabel")
    headerLabel.Size = UDim2.new(1, -30, 1, 0)
    headerLabel.BackgroundTransparency = 1
    headerLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
    headerLabel.TextSize = 16
    headerLabel.Font = Enum.Font.SourceSansBold
    headerLabel.Text = "ScarletHub" -- Новое имя
    headerLabel.Parent = header

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 1, 0)
    closeButton.Position = UDim2.new(1, 0, 0, 0)
    closeButton.AnchorPoint = Vector2.new(1, 0)
    closeButton.Text = "X"
    closeButton.BackgroundColor3 = Color3.fromRGB(232, 65, 24)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 20
    closeButton.BorderSizePixel = 0
    closeButton.Parent = header

    local collapseButton = Instance.new("TextButton")
    collapseButton.Name = "CollapseButton"
    collapseButton.Size = UDim2.new(0, 30, 1, 0)
    collapseButton.Position = UDim2.new(1, -30, 0, 0)
    collapseButton.AnchorPoint = Vector2.new(1, 0)
    collapseButton.Text = "-"
    collapseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    collapseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    collapseButton.Font = Enum.Font.SourceSansBold
    collapseButton.TextSize = 20
    collapseButton.BorderSizePixel = 0
    collapseButton.Parent = header

    local UICorner_Header = Instance.new("UICorner")
    UICorner_Header.CornerRadius = UDim.new(0, 8)
    UICorner_Header.Parent = header

    -- Main content container
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -20, 1, -40)
    contentFrame.Position = UDim2.new(0.5, 0, 0, 40)
    contentFrame.AnchorPoint = Vector2.new(0.5, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainPanel

    local mainHorizontalLayout = Instance.new("UIListLayout")
    mainHorizontalLayout.FillDirection = Enum.FillDirection.Horizontal
    mainHorizontalLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    mainHorizontalLayout.Padding = UDim.new(0, 10)
    mainHorizontalLayout.Parent = contentFrame

    -- Left side for categories
    local categoriesFrame = Instance.new("Frame")
    categoriesFrame.Name = "Categories"
    categoriesFrame.Size = UDim2.new(0, 120, 1, 0)
    categoriesFrame.BackgroundTransparency = 1
    categoriesFrame.Parent = contentFrame

    local categoryLayout = Instance.new("UIListLayout")
    categoryLayout.FillDirection = Enum.FillDirection.Vertical
    categoryLayout.Padding = UDim.new(0, 5)
    categoryLayout.Parent = categoriesFrame

    local espCategoryButton = Instance.new("TextButton")
    espCategoryButton.Name = "ESPCategoryButton"
    espCategoryButton.Size = UDim2.new(1, 0, 0, 30)
    espCategoryButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Красная кнопка
    espCategoryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    espCategoryButton.Text = "ESP"
    espCategoryButton.TextSize = 16
    espCategoryButton.Font = Enum.Font.SourceSansBold
    espCategoryButton.Parent = categoriesFrame
    local UICorner_ESPCat = Instance.new("UICorner")
    UICorner_ESPCat.CornerRadius = UDim.new(0, 5)
    UICorner_ESPCat.Parent = espCategoryButton

    local movementCategoryButton = Instance.new("TextButton")
    movementCategoryButton.Name = "MovementCategoryButton"
    movementCategoryButton.Size = UDim2.new(1, 0, 0, 30)
    movementCategoryButton.BackgroundColor3 = Color3.fromRGB(25, 20, 36)
    movementCategoryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    movementCategoryButton.Text = "Movement"
    movementCategoryButton.TextSize = 16
    movementCategoryButton.Font = Enum.Font.SourceSansBold
    movementCategoryButton.Parent = categoriesFrame
    local UICorner_MoveCat = Instance.new("UICorner")
    UICorner_MoveCat.CornerRadius = UDim.new(0, 5)
    UICorner_MoveCat.Parent = movementCategoryButton

    local cheatsCategoryButton = Instance.new("TextButton")
    cheatsCategoryButton.Name = "CheatsCategoryButton"
    cheatsCategoryButton.Size = UDim2.new(1, 0, 0, 30)
    cheatsCategoryButton.BackgroundColor3 = Color3.fromRGB(25, 20, 36)
    cheatsCategoryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cheatsCategoryButton.Text = "Cheats"
    cheatsCategoryButton.TextSize = 16
    cheatsCategoryButton.Font = Enum.Font.SourceSansBold
    cheatsCategoryButton.Parent = categoriesFrame
    local UICorner_CheatsCat = Instance.new("UICorner")
    UICorner_CheatsCat.CornerRadius = UDim.new(0, 5)
    UICorner_CheatsCat.Parent = cheatsCategoryButton

    local teleportCategoryButton = Instance.new("TextButton")
    teleportCategoryButton.Name = "TeleportCategoryButton"
    teleportCategoryButton.Size = UDim2.new(1, 0, 0, 30)
    teleportCategoryButton.BackgroundColor3 = Color3.fromRGB(25, 20, 36)
    teleportCategoryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleportCategoryButton.Text = "Teleport"
    teleportCategoryButton.TextSize = 16
    teleportCategoryButton.Font = Enum.Font.SourceSansBold
    teleportCategoryButton.Parent = categoriesFrame
    local UICorner_TeleportCat = Instance.new("UICorner")
    UICorner_TeleportCat.CornerRadius = UDim.new(0, 5)
    UICorner_TeleportCat.Parent = teleportCategoryButton

    -- Right side for sub-buttons - NOW A SCROLLING FRAME
    local subButtonsFrame = Instance.new("ScrollingFrame")
    subButtonsFrame.Name = "SubButtons"
    subButtonsFrame.Size = UDim2.new(1, -130, 1, 0)
    subButtonsFrame.BackgroundTransparency = 1
    subButtonsFrame.CanvasSize = UDim2.new(0, 0, 2, 0) -- Adjust Y scale as needed
    subButtonsFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0) -- Красный скроллбар
    subButtonsFrame.Parent = contentFrame

    local subListLayout = Instance.new("UIListLayout")
    subListLayout.Padding = UDim.new(0, 5)
    subListLayout.FillDirection = Enum.FillDirection.Vertical
    subListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    subListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    subListLayout.Parent = subButtonsFrame

    -- ESP Sub-buttons
    local playerEspButton = Instance.new("TextButton")
    playerEspButton.Name = "PlayerESPButton"
    playerEspButton.Size = UDim2.new(1, -10, 0, 30)
    playerEspButton.BackgroundColor3 = Color3.fromRGB(25, 20, 36)
    playerEspButton.BackgroundTransparency = 0.5
    playerEspButton.BorderColor3 = Color3.fromRGB(255, 0, 0) -- Красная обводка кнопки
    playerEspButton.BorderSizePixel = 2
    playerEspButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerEspButton.Text = "Включить ESP Игроков"
    playerEspButton.TextSize = 14
    playerEspButton.Font = Enum.Font.SourceSansBold
    playerEspButton.Parent = subButtonsFrame
    local UICorner_PlayerESP = Instance.new("UICorner")
    UICorner_PlayerESP.CornerRadius = UDim.new(0, 5)
    UICorner_PlayerESP.Parent = playerEspButton

    local lockTimeEspButton = Instance.new("TextButton")
    lockTimeEspButton.Name = "LockTimeESPButton"
    lockTimeEspButton.Size = UDim2.new(1, -10, 0, 30)
    lockTimeEspButton.BackgroundColor3 = Color3.fromRGB(25, 20, 36)
    lockTimeEspButton.BackgroundTransparency = 0.5
    lockTimeEspButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
    lockTimeEspButton.BorderSizePixel = 2
    lockTimeEspButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    lockTimeEspButton.Text = "Включить ESP Блокировки"
    lockTimeEspButton.TextSize = 14
    lockTimeEspButton.Font = Enum.Font.SourceSansBold
    lockTimeEspButton.Parent = subButtonsFrame
    local UICorner_LockESP = Instance.new("UICorner")
    UICorner_LockESP.CornerRadius = UDim.new(0, 5)
    UICorner_LockESP.Parent = lockTimeEspButton

    local fullbrightButton = Instance.new("TextButton")
    fullbrightButton.Name = "FullbrightButton"
    fullbrightButton.Size = UDim2.new(1, -10, 0, 30)
    fullbrightButton.BackgroundColor3 = Color3.fromRGB(25, 20, 36)
    fullbrightButton.BackgroundTransparency = 0.5
    fullbrightButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
    fullbrightButton.BorderSizePixel = 2
    fullbrightButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    fullbrightButton.Text = "Включить Fullbright"
    fullbrightButton.TextSize = 14
    fullbrightButton.Font = Enum.Font.SourceSansBold
    fullbrightButton.Parent = subButtonsFrame
    local UICorner_Fullbright = Instance.new("UICorner")
    UICorner_Fullbright.CornerRadius = UDim.new(0, 5)
    UICorner_Fullbright.Parent = fullbrightButton

    -- Movement Sub-buttons
    local speedButton = Instance.new("TextButton")
    speedButton.Name = "SpeedButton"
    speedButton.Size = UDim2.new(1, -10, 0, 30)
    speedButton.BackgroundColor3 = Color3.fromRGB(25, 20, 36)
    speedButton.BackgroundTransparency = 0.5
    speedButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
    speedButton.BorderSizePixel = 2
    speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedButton.Text = "Включить Speed"
    speedButton.TextSize = 14
    speedButton.Font = Enum.Font.SourceSansBold
    speedButton.Parent = subButtonsFrame
    local UICorner_Speed = Instance.new("UICorner")
    UICorner_Speed.CornerRadius = UDim.new(0, 5)
    UICorner_Speed.Parent = speedButton

    local speedInput = Instance.new("TextBox")
    speedInput.Name = "SpeedInput"
    speedInput.PlaceholderText = "Введите скорость (например, 50)"
    speedInput.Text = tostring(customWalkspeed)
    speedInput.Size = UDim2.new(1, -10, 0, 30)
    speedInput.BackgroundTransparency = 0.5
    speedInput.BackgroundColor3 = Color3.fromRGB(25, 20, 36)
    speedInput.BorderColor3 = Color3.fromRGB(255, 0, 0)
    speedInput.BorderSizePixel = 2
    speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedInput.Font = Enum.Font.SourceSansBold
    speedInput.TextSize = 14
    speedInput.Parent = subButtonsFrame
    local UICorner_SpeedInput = Instance.new("UICorner")
    UICorner_SpeedInput.CornerRadius = UDim.new(0, 5)
    UICorner_SpeedInput.Parent = speedInput

    local multijumpButton = Instance.new("TextButton")
    multijumpButton.Name = "MultijumpButton"
    multijumpButton.Size = UDim2.new(1, -10, 0, 30)
    multijumpButton.BackgroundColor3 = Color3.fromRGB(25, 20, 36)
    multijumpButton.BackgroundTransparency = 0.5
    multijumpButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
    multijumpButton.BorderSizePixel = 2
    multijumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    multijumpButton.Text = "Включить Multijump"
    multijumpButton.TextSize = 14
    multijumpButton.Font = Enum.Font.SourceSansBold
    multijumpButton.Parent = subButtonsFrame
    local UICorner_Multijump = Instance.new("UICorner")
    UICorner_Multijump.CornerRadius = UDim.new(0, 5)
    UICorner_Multijump.Parent = multijumpButton

    local noclipButton = Instance.new("TextButton")
    noclipButton.Name = "NoclipButton"
    noclipButton.Size = UDim2.new(1, -10, 0, 30)
    noclipButton.BackgroundColor3 = Color3.fromRGB(25, 20, 36)
    noclipButton.BackgroundTransparency = 0.5
    noclipButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
    noclipButton.BorderSizePixel = 2
    noclipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    noclipButton.Text = "Включить Noclip"
    noclipButton.TextSize = 14
    noclipButton.Font = Enum.Font.SourceSansBold
    noclipButton.Parent = subButtonsFrame
    local UICorner_Noclip = Instance.new("UICorner")
    UICorner_Noclip.CornerRadius = UDim.new(0, 5)
    UICorner_Noclip.Parent = noclipButton

    -- Cheats Sub-buttons
    local godmodeButton = Instance.new("TextButton")
    godmodeButton.Name = "GodmodeButton"
    godmodeButton.Size = UDim2.new(1, -10, 0, 30)
    godmodeButton.BackgroundColor3 = godmodeEnabled and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(25, 20, 36)
    godmodeButton.BackgroundTransparency = 0.5
    godmodeButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
    godmodeButton.BorderSizePixel = 2
    godmodeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    godmodeButton.Text = godmodeEnabled and "Выключить God Mode" or "Включить God Mode"
    godmodeButton.TextSize = 14
    godmodeButton.Font = Enum.Font.SourceSansBold
    godmodeButton.Parent = subButtonsFrame
    local UICorner_Godmode = Instance.new("UICorner")
    UICorner_Godmode.CornerRadius = UDim.new(0, 5)
    UICorner_Godmode.Parent = godmodeButton

    local autoStealButton = Instance.new("TextButton")
    autoStealButton.Name = "AutoStealButton"
    autoStealButton.Size = UDim2.new(1, -10, 0, 30)
    autoStealButton.BackgroundColor3 = autoStealEnabled and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(25, 20, 36)
    autoStealButton.BackgroundTransparency = 0.5
    autoStealButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
    autoStealButton.BorderSizePixel = 2
    autoStealButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoStealButton.Text = autoStealEnabled and "Выключить Auto Steal" or "Включить Auto Steal"
    autoStealButton.TextSize = 14
    autoStealButton.Font = Enum.Font.SourceSansBold
    autoStealButton.Parent = subButtonsFrame
    local UICorner_AutoSteal = Instance.new("UICorner")
    UICorner_AutoSteal.CornerRadius = UDim.new(0, 5)
    UICorner_AutoSteal.Parent = autoStealButton

    -- Teleport Sub-buttons
    local savePosButton = Instance.new("TextButton")
    savePosButton.Name = "SavePosButton"
    savePosButton.Size = UDim2.new(1, -10, 0, 30)
    savePosButton.BackgroundColor3 = Color3.fromRGB(25, 20, 36)
    savePosButton.BackgroundTransparency = 0.5
    savePosButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
    savePosButton.BorderSizePixel = 2
    savePosButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    savePosButton.Text = "Сохранить позицию"
    savePosButton.TextSize = 14
    savePosButton.Font = Enum.Font.SourceSansBold
    savePosButton.Parent = subButtonsFrame
    local UICorner_SavePos = Instance.new("UICorner")
    UICorner_SavePos.CornerRadius = UDim.new(0, 5)
    UICorner_SavePos.Parent = savePosButton

    local teleportButton = Instance.new("TextButton")
    teleportButton.Name = "TeleportButton"
    teleportButton.Size = UDim2.new(1, -10, 0, 30)
    teleportButton.BackgroundColor3 = Color3.fromRGB(25, 20, 36)
    teleportButton.BackgroundTransparency = 0.5
    teleportButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
    teleportButton.BorderSizePixel = 2
    teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleportButton.Text = "Телепорт к позиции"
    teleportButton.TextSize = 14
    teleportButton.Font = Enum.Font.SourceSansBold
    teleportButton.Parent = subButtonsFrame
    local UICorner_Teleport = Instance.new("UICorner")
    UICorner_Teleport.CornerRadius = UDim.new(0, 5)
    UICorner_Teleport.Parent = teleportButton

    local createPrivateServerButton = Instance.new("TextButton")
    createPrivateServerButton.Name = "CreatePrivateServerButton"
    createPrivateServerButton.Size = UDim2.new(1, -10, 0, 30)
    createPrivateServerButton.BackgroundColor3 = Color3.fromRGB(25, 20, 36)
    createPrivateServerButton.BackgroundTransparency = 0.5
    createPrivateServerButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
    createPrivateServerButton.BorderSizePixel = 2
    createPrivateServerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    createPrivateServerButton.Text = "Создать приватный сервер"
    createPrivateServerButton.TextSize = 14
    createPrivateServerButton.Font = Enum.Font.SourceSansBold
    createPrivateServerButton.Parent = subButtonsFrame
    local UICorner_CreatePrivate = Instance.new("UICorner")
    UICorner_CreatePrivate.CornerRadius = UDim.new(0, 5)
    UICorner_CreatePrivate.Parent = createPrivateServerButton

    local joinCodeInput = Instance.new("TextBox")
    joinCodeInput.Name = "JoinCodeInput"
    joinCodeInput.PlaceholderText = "Введите код сервера"
    joinCodeInput.Text = ""
    joinCodeInput.Size = UDim2.new(1, -10, 0, 30)
    joinCodeInput.BackgroundTransparency = 0.5
    joinCodeInput.BackgroundColor3 = Color3.fromRGB(25, 20, 36)
    joinCodeInput.BorderColor3 = Color3.fromRGB(255, 0, 0)
    joinCodeInput.BorderSizePixel = 2
    joinCodeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    joinCodeInput.Font = Enum.Font.SourceSansBold
    joinCodeInput.TextSize = 14
    joinCodeInput.Parent = subButtonsFrame
    local UICorner_JoinCodeInput = Instance.new("UICorner")
    UICorner_JoinCodeInput.CornerRadius = UDim.new(0, 5)
    UICorner_JoinCodeInput.Parent = joinCodeInput

    local joinServerButton = Instance.new("TextButton")
    joinServerButton.Name = "JoinServerButton"
    joinServerButton.Size = UDim2.new(1, -10, 0, 30)
    joinServerButton.BackgroundColor3 = Color3.fromRGB(25, 20, 36)
    joinServerButton.BackgroundTransparency = 0.5
    joinServerButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
    joinServerButton.BorderSizePixel = 2
    joinServerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    joinServerButton.Text = "Присоединиться по коду"
    joinServerButton.TextSize = 14
    joinServerButton.Font = Enum.Font.SourceSansBold
    joinServerButton.Parent = subButtonsFrame
    local UICorner_JoinServerButton = Instance.new("UICorner")
    UICorner_JoinServerButton.CornerRadius = UDim.new(0, 5)
    UICorner_JoinServerButton.Parent = joinServerButton

    local function showCategory(category)
        local espButtons = {playerEspButton, lockTimeEspButton, fullbrightButton}
        local movementButtons = {speedButton, speedInput, multijumpButton, noclipButton}
        local cheatsButtons = {godmodeButton, autoStealButton}
        local teleportButtons = {savePosButton, teleportButton, createPrivateServerButton, joinCodeInput, joinServerButton}

        for _, btn in ipairs(espButtons) do btn.Visible = category == "ESP" end
        for _, btn in ipairs(movementButtons) do btn.Visible = category == "Movement" end
        for _, btn in ipairs(cheatsButtons) do btn.Visible = category == "Cheats" end
        for _, btn in ipairs(teleportButtons) do btn.Visible = category == "Teleport" end

        espCategoryButton.BackgroundColor3 = category == "ESP" and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(25, 20, 36)
        movementCategoryButton.BackgroundColor3 = category == "Movement" and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(25, 20, 36)
        cheatsCategoryButton.BackgroundColor3 = category == "Cheats" and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(25, 20, 36)
        teleportCategoryButton.BackgroundColor3 = category == "Teleport" and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(25, 20, 36)

        local totalHeight = 0
        local buttonHeight = 30
        local padding = 5

        if category == "ESP" then
            totalHeight = (buttonHeight * #espButtons) + (padding * (#espButtons - 1)) + 10
        elseif category == "Movement" then
            totalHeight = (buttonHeight * #movementButtons) + (padding * (#movementButtons - 1)) + 10
        elseif category == "Cheats" then
            totalHeight = (buttonHeight * #cheatsButtons) + (padding * (#cheatsButtons - 1)) + 10
        elseif category == "Teleport" then
            totalHeight = (buttonHeight * #teleportButtons) + (padding * (#teleportButtons - 1)) + 10
        end
        subButtonsFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
    end

    showCategory("ESP")

    -- Click handlers for main category buttons
    espCategoryButton.MouseButton1Click:Connect(function()
        currentCategory = "ESP"
        showCategory(currentCategory)
    end)

    movementCategoryButton.MouseButton1Click:Connect(function()
        currentCategory = "Movement"
        showCategory(currentCategory)
    end)

    cheatsCategoryButton.MouseButton1Click:Connect(function()
        currentCategory = "Cheats"
        showCategory(currentCategory)
    end)

    teleportCategoryButton.MouseButton1Click:Connect(function()
        currentCategory = "Teleport"
        showCategory(currentCategory)
    end)

    -- Collapse logic
    collapseButton.MouseButton1Click:Connect(function()
        isPanelCollapsed = not isPanelCollapsed
        if isPanelCollapsed then
            mainPanel:TweenSize(UDim2.new(0, 30, 0, 30), "Out", "Quad", 0.3)
            mainPanel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            contentFrame.Visible = false
            collapseButton.Text = "+"
            headerLabel.Visible = false
            closeButton.Visible = false
        else
            -- ИСПРАВЛЕНО: Устанавливаем фиксированную ширину 350px при разворачивании
            mainPanel:TweenSize(UDim2.new(0, 350, 0, 190), "Out", "Quad", 0.3)
            mainPanel.BackgroundColor3 = Color3.fromRGB(56, 23, 35)
            contentFrame.Visible = true
            collapseButton.Text = "-"
            headerLabel.Visible = true
            closeButton.Visible = true
        end
    end)

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        isESPPanelActive = false

        -- Reset all states
        isPlayerEspActive = false
        isLockTimeESPEnabled = false
        isFullbrightEnabled = false
        isSpeedEnabled = false
        isMultijumpEnabled = false
        isNoclipEnabled = false
        godmodeEnabled = false
        autoStealEnabled = false
        floorEnabled = false

        -- Clean up effects
        toggleFullbright(false)
        toggleSpeed(false)
        toggleMultijump(false)
        toggleNoclip(false)
        clearAllFloors()
        for _, player in ipairs(Players:GetPlayers()) do
            cleanUpPlayerEsp(player)
        end
        for _, inst in pairs(lockEspInstances) do
            if inst and inst.Parent then inst:Destroy() end
        end
        lockEspInstances = {}
    end)

    -- Dragging logic (работает и для Touch, и для MouseButton1, подходит для планшетов)
    local isDragging = false
    local dragStartPos

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStartPos = input.Position
            UserInputService:ChangeMouseIcon("rbxassetid://1326497258")
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartPos
            mainPanel.Position = UDim2.new(mainPanel.Position.X.Scale, mainPanel.Position.X.Offset + delta.X, mainPanel.Position.Y.Scale, mainPanel.Position.Y.Offset + delta.Y)
            dragStartPos = input.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
            UserInputService:ChangeMouseIcon("rbxassetid://620703814")
        end
    end)

    -- Button click handlers
    local function toggleButton(button, isEnabled, textEnabled, textDisabled, colorEnabled, colorDisabled)
        if isEnabled then
            button.BackgroundColor3 = colorEnabled
            button.Text = textEnabled
        else
            button.BackgroundColor3 = colorDisabled
            button.Text = textDisabled
        end
    end

    playerEspButton.MouseButton1Click:Connect(function()
        isPlayerEspActive = not isPlayerEspActive
        toggleButton(playerEspButton, isPlayerEspActive, "Выключить ESP Игроков", "Включить ESP Игроков", Color3.fromRGB(255, 0, 0), Color3.fromRGB(25, 20, 36))
        if isPlayerEspActive then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    createPlayerEspElements(player)
                end
            end
        else
            for _, player in ipairs(Players:GetPlayers()) do
                cleanUpPlayerEsp(player)
            end
        end
    end)

    lockTimeEspButton.MouseButton1Click:Connect(function()
        isLockTimeESPEnabled = not isLockTimeESPEnabled
        toggleButton(lockTimeEspButton, isLockTimeESPEnabled, "Выключить ESP Блокировки", "Включить ESP Блокировки", Color3.fromRGB(255, 0, 0), Color3.fromRGB(25, 20, 36))
        updateLockESP()
    end)

    fullbrightButton.MouseButton1Click:Connect(function()
        isFullbrightEnabled = not isFullbrightEnabled
        toggleButton(fullbrightButton, isFullbrightEnabled, "Выключить Fullbright", "Включить Fullbright", Color3.fromRGB(255, 0, 0), Color3.fromRGB(25, 20, 36))
        toggleFullbright(isFullbrightEnabled)
    end)


    speedInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local newSpeed = tonumber(speedInput.Text)
            if newSpeed and newSpeed > 0 then
                customWalkspeed = newSpeed
                if isSpeedEnabled then
                    toggleSpeed(true)
                end
                showNotification("Скорость обновлена: " .. newSpeed)
            else
                showNotification("Пожалуйста, введите корректное число.")
            end
        end
    end)

    speedButton.MouseButton1Click:Connect(function()
        local currentSpeed = tonumber(speedInput.Text)
        if currentSpeed and currentSpeed > 0 then
            isSpeedEnabled = not isSpeedEnabled
            toggleButton(speedButton, isSpeedEnabled, "Выключить Speed", "Включить Speed", Color3.fromRGB(255, 0, 0), Color3.fromRGB(25, 20, 36))
            toggleSpeed(isSpeedEnabled)
        else
            showNotification("Сначала введите корректное значение скорости!")
        end
    end)

    multijumpButton.MouseButton1Click:Connect(function()
        isMultijumpEnabled = not isMultijumpEnabled
        toggleButton(multijumpButton, isMultijumpEnabled, "Выключить Multijump", "Включить Multijump", Color3.fromRGB(255, 0, 0), Color3.fromRGB(25, 20, 36))
        toggleMultijump(isMultijumpEnabled)
    end)

    noclipButton.MouseButton1Click:Connect(function()
        isNoclipEnabled = not isNoclipEnabled
        toggleButton(noclipButton, isNoclipEnabled, "Выключить Noclip", "Включить Noclip", Color3.fromRGB(255, 0, 0), Color3.fromRGB(25, 20, 36))
        toggleNoclip(isNoclipEnabled)
    end)


    -- Cheats button handlers
    godmodeButton.MouseButton1Click:Connect(function()
        godmodeEnabled = not godmodeEnabled
        toggleButton(godmodeButton, godmodeEnabled, "Выключить God Mode", "Включить God Mode", Color3.fromRGB(255, 0, 0), Color3.fromRGB(25, 20, 36))
    end)

    autoStealButton.MouseButton1Click:Connect(function()
        autoStealEnabled = not autoStealEnabled
        toggleButton(autoStealButton, autoStealEnabled, "Выключить Auto Steal", "Включить Auto Steal", Color3.fromRGB(255, 0, 0), Color3.fromRGB(25, 20, 36))
    end)

    -- Teleport button handlers
    savePosButton.MouseButton1Click:Connect(saveCurrentPosition)
    teleportButton.MouseButton1Click:Connect(teleportToSavedPosition)

    createPrivateServerButton.MouseButton1Click:Connect(function()
        showNotification("Создание приватного сервера (устаревшим методом)...")
        local accessCode, _ = GenerateReservedServerCode(game.PlaceId)
        game.RobloxReplicatedStorage.ContactListIrisInviteTeleport:FireServer(game.PlaceId, "", accessCode)
        showNotification("Приватный сервер создан. Вы будете телепортированы.")
        pcall(function() setclipboard(accessCode) end)
        showNotification("Код сервера скопирован в буфер обмена: " .. accessCode)
    end)

    joinServerButton.MouseButton1Click:Connect(function()
        local code = joinCodeInput.Text
        if #code > 0 then
            showNotification("Присоединение к серверу по коду (устаревшим методом)...")
            game.RobloxReplicatedStorage.ContactListIrisInviteTeleport:FireServer(game.PlaceId, "", code)
        else
            showNotification("Пожалуйста, введите код сервера.")
        end
    end)
end

local function createFloatingFloorButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FloatingFloorGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local floorButton = Instance.new("TextButton")
    -- Фиксированный размер для маленькой кнопки приемлем
    floorButton.Name = "FloatingFloorButton"
    floorButton.Size = UDim2.new(0, 80, 0, 40)
    floorButton.Position = UDim2.new(1, -90, 0, 50)
    floorButton.AnchorPoint = Vector2.new(1, 0)
    floorButton.BackgroundColor3 = floorEnabled and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(25, 20, 36)
    floorButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
    floorButton.BorderSizePixel = 2
    floorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    floorButton.Text = floorEnabled and "Floor On" or "Floor Off"
    floorButton.TextSize = 14
    floorButton.Font = Enum.Font.SourceSansBold
    floorButton.Parent = screenGui

    local UICorner_Button = Instance.new("UICorner")
    UICorner_Button.CornerRadius = UDim.new(0, 8)
    UICorner_Button.Parent = floorButton

    local function toggleButton(button, isEnabled, textEnabled, textDisabled, colorEnabled, colorDisabled)
        if isEnabled then
            button.BackgroundColor3 = colorEnabled
            button.Text = textEnabled
        else
            button.BackgroundColor3 = colorDisabled
            button.Text = textDisabled
        end
    end

    floorButton.MouseButton1Click:Connect(function()
        floorEnabled = not floorEnabled
        toggleButton(floorButton, floorEnabled, "Floor On", "Floor Off", Color3.fromRGB(255, 0, 0), Color3.fromRGB(25, 20, 36))
        toggleFloorLogic(floorEnabled)
    end) -- ИСПРАВЛЕНА КРИТИЧЕСКАЯ ОШИБКА #1

    local isDragging = false
    local dragStartPos

    floorButton.InputBegan:Connect(function(input)
        -- Обработка как сенсорного (Touch), так и мышиного (MouseButton1) ввода
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStartPos = input.Position
            UserInputService:ChangeMouseIcon("rbxassetid://1326497258")
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartPos
            local currentPos = floorButton.Position.Offset
            -- При перемещении используем UDim2.new(0, X, 0, Y) для точного позиционирования
            floorButton.Position = UDim2.new(0, currentPos.X + delta.X, 0, currentPos.Y + delta.Y)
            dragStartPos = input.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
            UserInputService:ChangeMouseIcon("rbxassetid://620703814")
        end
    end)

    return screenGui
end


-- ========================================
-- Main Loop & Initialization
-- ========================================
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if isPlayerEspActive then
            createPlayerEspElements(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(cleanUpPlayerEsp)
LocalPlayer.CharacterAdded:Connect(applyGodmode)

task.spawn(function()
    while task.wait(0.5) do
        if isLockTimeESPEnabled then
            updateLockESP()
        end
        if isPlayerEspActive then
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LocalPlayer and pl.Character then
                    updatePlayerEspElements(pl)
                end
            end
        end

        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")

        if isNoclipEnabled and character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end

        if isSpeedEnabled and humanoid then
            humanoid.WalkSpeed = customWalkspeed
        end

        if godmodeEnabled and humanoid then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
            humanoid.BreakJointsOnDeath = false
        end
    end
end)


-- Main Loop from new script
RunService.Heartbeat:Connect(function(dt)
    -- Логика пола-лифта
    if floorEnabled then
        getCurrentReferences()
        if hrp then
            local floorHeight = hrp.Position.Y - 2.5 -- Регулируемое смещение для размещения под ногами
            createPlatformAtHeight(floorHeight)
        end
    end
end)

-- Проверка новых объектов
Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA('ProximityPrompt') then
        obj.Triggered:Connect(function(plr)
            if plr == LocalPlayer and autoStealEnabled then
                wait(0.1)
                onInteractionFinished()
            end
        end)
    end
end) -- ИСПРАВЛЕНА КРИТИЧЕСКАЯ ОШИБКА #2
connectProximityPrompts()


-- Анти-кик
pcall(function()
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = function(self, ...)
        if getnamecallmethod() == 'Kick' then
            return wait(math.huge)
        end
        return old(self, ...)
    end
    setreadonly(mt, true)
end)

createESPPanel()
createFloatingFloorButton()
