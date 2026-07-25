local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local query = require(ReplicatedStorage.query)
local trajectory = {}
local metavisionEnabled = false
local stopped = false
local updateLoop = nil
local inputConn = nil

local visionFolder = Instance.new("Folder")
visionFolder.Name = "MetavisionParts"
visionFolder.Parent = Workspace

local beamPool = {}
local circlePool = {}
local circleData = {}
local maxBeams = 60
local maxCircles = 30
local fadeDuration = 8

for i = 1, maxBeams do
    local beam = Instance.new("Beam")
    beam.Width0 = 0.25
    beam.Width1 = 0.25
    beam.FaceCamera = true
    beam.Transparency = NumberSequence.new(1)
    beam.Color = ColorSequence.new(Color3.fromRGB(0, 150, 255))
    beam.Parent = visionFolder
    beamPool[i] = {
        beam = beam,
        attachment0 = Instance.new("Attachment"),
        attachment1 = Instance.new("Attachment"),
        spawnTime = 0,
        active = false
    }
    beamPool[i].attachment0.Parent = visionFolder
    beamPool[i].attachment1.Parent = visionFolder
    beam.Attachment0 = beamPool[i].attachment0
    beam.Attachment1 = beamPool[i].attachment1
end

for i = 1, maxCircles do
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Material = Enum.Material.Neon
    part.Shape = Enum.PartType.Ball
    part.Transparency = 1
    part.Parent = visionFolder
    circlePool[i] = part
    circleData[i] = {
        spawnTime = 0,
        active = false
    }
end

local function hideAll()
    for i = 1, maxBeams do
        beamPool[i].beam.Transparency = NumberSequence.new(1)
        beamPool[i].active = false
        beamPool[i].spawnTime = 0
    end
    for i = 1, maxCircles do
        circlePool[i].Transparency = 1
        circleData[i].active = false
        circleData[i].spawnTime = 0
    end
end

local function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Metavision",
            Text = text,
            Duration = 2
        })
    end)
end

local function getBallLandingPosition()
    if #trajectory == 0 then return nil end
    local currentTime = workspace:GetServerTimeNow()
    local lowestPoint = nil
    local lowestY = math.huge
    for _, point in ipairs(trajectory) do
        if point.Age and point.Position and point.Age > currentTime and point.Position.Y < lowestY then
            lowestY = point.Position.Y
            lowestPoint = point
        end
    end
    return lowestPoint
end

local function getBallHighestPosition()
    if #trajectory == 0 then return nil end
    local currentTime = workspace:GetServerTimeNow()
    local highestPoint = nil
    local highestY = -math.huge
    for _, point in ipairs(trajectory) do
        if point.Age and point.Position and point.Age > currentTime and point.Position.Y > highestY then
            highestY = point.Position.Y
            highestPoint = point
        end
    end
    return highestPoint
end

local function getNearbyPlayers(radius)
    local char = player.Character
    if not char then return {} end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return {} end
    local nearby = {}
    local pos = hrp.Position
    local playersList = Players:GetPlayers()
    for i = 1, #playersList do
        local plr = playersList[i]
        if plr ~= player then
            local c = plr.Character
            if c then
                local r = c:FindFirstChild("HumanoidRootPart")
                if r then
                    local dist = (r.Position - pos).Magnitude
                    if dist <= radius then
                        nearby[#nearby + 1] = {
                            position = r.Position,
                            hasBall = c:FindFirstChild("Ball") ~= nil,
                            distance = dist
                        }
                    end
                end
            end
        end
    end
    return nearby
end

local function updateMetavision()
    if stopped or not metavisionEnabled then
        hideAll()
        return
    end
    
    if #trajectory < 2 then
        hideAll()
        return
    end
    
    local currentTick = tick()
    local beamIdx = 0
    local circleIdx = 0
    
    for i = 1, maxBeams do
        local data = beamPool[i]
        if data.active then
            local elapsed = currentTick - data.spawnTime
            if elapsed >= fadeDuration then
                data.beam.Transparency = NumberSequence.new(1)
                data.active = false
                data.spawnTime = 0
            end
        end
    end
    
    for i = 1, maxCircles do
        local data = circleData[i]
        if data.active then
            local elapsed = currentTick - data.spawnTime
            if elapsed >= fadeDuration then
                circlePool[i].Transparency = 1
                data.active = false
                data.spawnTime = 0
            end
        end
    end
    
    local step = math.max(1, math.floor(#trajectory / maxBeams))
    local lastPoint = nil
    
    for i = 1, #trajectory, step do
        local point = trajectory[i]
        if point and point.Position then
            if lastPoint then
                beamIdx = beamIdx + 1
                if beamIdx <= maxBeams then
                    local beamData = beamPool[beamIdx]
                    
                    if not beamData.active then
                        beamData.spawnTime = currentTick
                        beamData.active = true
                    end
                    
                    beamData.attachment0.WorldPosition = lastPoint.Position
                    beamData.attachment1.WorldPosition = point.Position
                    beamData.beam.Transparency = NumberSequence.new(0.3)
                    beamData.beam.Color = ColorSequence.new(Color3.fromRGB(0, 180, 255))
                end
            end
            lastPoint = point
        end
    end
    
    local landing = getBallLandingPosition()
    if landing and landing.Position then
        circleIdx = circleIdx + 1
        if circleIdx <= maxCircles then
            local data = circleData[circleIdx]
            if not data.active then
                data.spawnTime = currentTick
                data.active = true
            end
            local p = circlePool[circleIdx]
            p.Shape = Enum.PartType.Ball
            p.Size = Vector3.new(1.5, 1.5, 1.5)
            p.Position = landing.Position
            p.Color = Color3.fromRGB(0, 255, 100)
            p.Transparency = 0.3
        end
    end
    
    local highest = getBallHighestPosition()
    if highest and highest.Position then
        circleIdx = circleIdx + 1
        if circleIdx <= maxCircles then
            local data = circleData[circleIdx]
            if not data.active then
                data.spawnTime = currentTick
                data.active = true
            end
            local p = circlePool[circleIdx]
            p.Shape = Enum.PartType.Ball
            p.Size = Vector3.new(1, 1, 1)
            p.Position = highest.Position
            p.Color = Color3.fromRGB(255, 0, 200)
            p.Transparency = 0.3
        end
    end
    
    local nearby = getNearbyPlayers(50)
    for j = 1, #nearby do
        local info = nearby[j]
        circleIdx = circleIdx + 1
        if circleIdx <= maxCircles then
            local data = circleData[circleIdx]
            if not data.active then
                data.spawnTime = currentTick
                data.active = true
            end
            local p = circlePool[circleIdx]
            p.Shape = Enum.PartType.Block
            p.Position = info.position
            if info.hasBall then
                p.Color = Color3.fromRGB(255, 0, 0)
                p.Size = Vector3.new(3, 4, 3)
            else
                p.Color = Color3.fromRGB(0, 255, 200)
                p.Size = Vector3.new(2, 3, 2)
            end
            p.Transparency = 0.5
        end
    end
end

local function toggleMetavision()
    if stopped then return end
    metavisionEnabled = not metavisionEnabled
    if metavisionEnabled then
        if not updateLoop then
            updateLoop = RunService.Heartbeat:Connect(updateMetavision)
        end
        notify("Metavision ON")
    else
        if updateLoop then
            updateLoop:Disconnect()
            updateLoop = nil
        end
        hideAll()
        notify("Metavision OFF")
    end
end

local function destroyAll()
    if stopped then return end
    stopped = true
    metavisionEnabled = false
    
    if updateLoop then
        updateLoop:Disconnect()
        updateLoop = nil
    end
    
    if inputConn then
        pcall(function() inputConn:Disconnect() end)
        inputConn = nil
    end
    
    pcall(function()
        visionFolder:Destroy()
    end)
    
    notify("Metavision DESTROYED")
    trajectory = nil
    player = nil
    query = nil
    beamPool = nil
    circlePool = nil
    circleData = nil
    
    print("Metavision completely destroyed")
end

query.requestTrajectory:Fire()

query.receiveTrajectory.OnClientEvent:Connect(function(data)
    if stopped then return end
    if data and type(data) == "table" and #data > 0 then
        trajectory = data
    end
end)

inputConn = UserInputService.InputBegan:Connect(function(input, gp)
    if gp or stopped then return end
    if input.KeyCode == Enum.KeyCode.F5 then
        toggleMetavision()
    elseif input.KeyCode == Enum.KeyCode.F4 then
        destroyAll()
    end
end)

notify("Metavision loaded!")
notify("F5 = Toggle | F4 = Destroy")
