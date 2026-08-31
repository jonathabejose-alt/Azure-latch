if getgenv().Zolar and getgenv().Zolar.Unload then
    getgenv().Zolar:Unload()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local BNR = ReplicatedStorage:WaitForChild("ByteNetReliable")

local buffers = {}
loadstring(game:HttpGet("https://pastebin.com/raw/8XJh7dzh"))()
repeat task.wait() until game.Lighting:FindFirstChild("BUFFERSTRINGS")
for _, val in ipairs(game.Lighting:FindFirstChild("BUFFERSTRINGS"):GetChildren()) do
    buffers[val.Name] = val.Value
end
game.Lighting:FindFirstChild("BUFFERSTRINGS"):Destroy()

local vector = {
    create = function(x, y, z)
        return Vector3.new(x, y, z)
    end
}

local Zolar = loadstring(game:HttpGet("https://raw.githubusercontent.com/jonathabejose-alt/Azure-latch/refs/heads/main/ZolarUi.lua"))()

local Window = Zolar:Window({
    Name = "ZOLAR",
    Icon = "128056142918696",
    Accent = Color3.fromRGB(179, 165, 255)
})

local Combat = Window:Tab({
    Name = "Combat",
    Icon = "swords"
})

local Main = Combat:SubTab({
    Name = "Main",
    Icon = "zap"
})

local TrapSection = Main:Section({
    Name = "Trap Distance Buffs",
    Side = 1
})

local Distances = {
    trapDistBuff = 0,
    trapSpeedBuff = 100,
    trapVertical = 0
}

local trapSystemEnabled = false

local DashConfigs = {
    TrapAnim1 = { animIds = { ["rbxassetid://73387016994281"] = true }, sliderVar = "trapDistBuff", speedVar = "trapSpeedBuff", isTrap = true, duration = 0.8, wait = 0.05 },
    TrapAnim2 = { animIds = { ["rbxassetid://101043441232233"] = true }, sliderVar = "trapDistBuff", speedVar = "trapSpeedBuff", isTrap = true, duration = 0.8, wait = 0.05 },
    TrapAnim3 = { animIds = { ["rbxassetid://96593185131882"] = true }, sliderVar = "trapDistBuff", speedVar = "trapSpeedBuff", isTrap = true, duration = 0.8, wait = 0.05 },
    TrapAnim4 = { animIds = { ["rbxassetid://116422938520670"] = true }, sliderVar = "trapDistBuff", speedVar = "trapSpeedBuff", isTrap = true, duration = 0.8, wait = 0.05 },
    TrapAnim5 = { animIds = { ["rbxassetid://90734196141468"] = true }, sliderVar = "trapDistBuff", speedVar = "trapSpeedBuff", isTrap = true, duration = 0.8, wait = 0.05 },
    TrapAnim6 = { animIds = { ["rbxassetid://85349589701503"] = true }, sliderVar = "trapDistBuff", speedVar = "trapSpeedBuff", isTrap = true, duration = 0.8, wait = 0.05 },
    TrapAnim7 = { animIds = { ["rbxassetid://120351399679118"] = true }, sliderVar = "trapDistBuff", speedVar = "trapSpeedBuff", isTrap = true, duration = 0.8, wait = 0.05 },
}

local ActiveDashes = {}
local cachedHRP = nil
local dRenderConn = nil

local function updateDashes(dt)
    for i = #ActiveDashes, 1, -1 do
        local dash = ActiveDashes[i]
        local hrp = dash.hrp
        if not hrp or not hrp.Parent then 
            table.remove(ActiveDashes, i)
        else
            if dash.track and not dash.track.IsPlaying then 
                table.remove(ActiveDashes, i)
            else
                local step = math.min(dash.speed * dt, dash.remaining)
                local look = hrp.CFrame.LookVector
                local dir = Vector3.new(look.X, 0, look.Z)
                if dir.Magnitude < 0.01 then 
                    dir = Vector3.new(0, 0, 1) 
                else 
                    dir = dir.Unit 
                end
                
                local newY = hrp.Position.Y
                if dash.cfg.isTrap then
                    local vertScale = (Distances.trapVertical or 0) / 100
                    newY = newY + (vertScale * step)
                end
                
                local newPos = hrp.Position + dir * step
                hrp.CFrame = CFrame.new(newPos.X, newY, newPos.Z) * CFrame.new(Vector3.zero, dir)
                dash.remaining = dash.remaining - step
                if dash.remaining <= 0 then 
                    table.remove(ActiveDashes, i) 
                end
            end
        end
    end
    if #ActiveDashes == 0 and dRenderConn then 
        dRenderConn:Disconnect()
        dRenderConn = nil 
    end
end

local function startUpdateIfNeeded()
    if not dRenderConn and #ActiveDashes > 0 then
        dRenderConn = RunService.RenderStepped:Connect(updateDashes)
    end
end

local function startDash(hrp, cfg, track)
    local dist = Distances[cfg.sliderVar]
    if dist <= 0 then return end
    task.delay(cfg.wait or 0, function()
        if not hrp or not hrp.Parent then return end
        local dash = { hrp = hrp, remaining = dist, cfg = cfg, track = track }
        if cfg.speedVar then
            dash.speed = Distances[cfg.speedVar]
        else
            dash.speed = dist / cfg.duration
        end
        table.insert(ActiveDashes, dash)
        startUpdateIfNeeded()
    end)
end

local function onAnimPlayed(track)
    if not track.Animation then return end
    local id = track.Animation.AnimationId
    for _, cfg in pairs(DashConfigs) do
        local match = cfg.animIds and cfg.animIds[id]
        if match and cachedHRP and cachedHRP.Parent then
            startDash(cachedHRP, cfg, track)
        end
    end
end

local function setupTrapChar(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    local animator = hum:WaitForChild("Animator", 5)
    if not animator then return end
    cachedHRP = char:WaitForChild("HumanoidRootPart", 5)
    if not cachedHRP then return end
    animator.AnimationPlayed:Connect(onAnimPlayed)
end

if player.Character then setupTrapChar(player.Character) end
player.CharacterAdded:Connect(setupTrapChar)

TrapSection:Toggle({
    Name = "Enable Trap Buffs",
    Default = false,
    Callback = function(v)
        trapSystemEnabled = v
    end
})

TrapSection:Slider({
    Name = "Extra Trap Distance",
    Min = 0,
    Max = 500,
    Default = 0,
    Suffix = "studs",
    Callback = function(v) Distances.trapDistBuff = v end,
})

TrapSection:Slider({
    Name = "Extra Trap Speed",
    Min = 0,
    Max = 1000,
    Default = 100,
    Suffix = "spd",
    Callback = function(v) Distances.trapSpeedBuff = v end,
})

TrapSection:Slider({
    Name = "Trap Vertical (Height)",
    Min = -100,
    Max = 100,
    Default = 0,
    Suffix = "%",
    Callback = function(v) Distances.trapVertical = v end,
})

local BallFeatures = Main:Section({
    Name = "Ball Features",
    Side = 1
})

local bmRadius = 1
local bmState = { active = false }

BallFeatures:Toggle({
    Name = "Ball Magnet (Auto Grab)",
    Default = false,
    Callback = function(v)
        bmState.active = v
    end,
})

BallFeatures:Slider({
    Name = "Magnet Radius",
    Min = 1,
    Max = 25,
    Default = 1,
    Suffix = "studs",
    Callback = function(v) bmRadius = v end,
})

task.spawn(function()
    while task.wait() do
        if not bmState.active or bmRadius < 2 then 
        else
            local ball = workspace.Terrain:FindFirstChild("Ball")
            if ball then
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - ball.Position).Magnitude <= bmRadius then
                    pcall(function() 
                        BNR:FireServer(buffer.fromstring(buffers["grabball"])) 
                    end)
                end
            end
        end
    end
end)

local autoGoalState = { enabled = false, conn = nil }

BallFeatures:Toggle({
    Name = "Auto Goal",
    Default = false,
    Callback = function(v)
        autoGoalState.enabled = v
        if v then
            local map = workspace:WaitForChild("map")
            local agoal = map:WaitForChild("Agoal")
            local bgoal = map:WaitForChild("Bgoal")

            local function ingame()
                local s = player.Character and player.Character:FindFirstChild("state")
                return s and s:FindFirstChild("ingame") and s.ingame.Value
            end

            local function disableCollisions()
                local gk = map:FindFirstChild("gkbarriar")
                if gk then
                    if gk:FindFirstChild("A") then gk.A.CanCollide = false end
                    if gk:FindFirstChild("B") then gk.B.CanCollide = false end
                end
                if agoal then agoal.CanCollide = false end
                if bgoal then bgoal.CanCollide = false end
            end

            local function stealBall()
                local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local ball = workspace.Terrain:FindFirstChild("Ball")
                if root and ball then
                    root.CFrame = CFrame.new(ball.Position.X, 0, ball.Position.Z)
                end
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character then
                        local ob = p.Character:FindFirstChild("Ball")
                        local or2 = p.Character:FindFirstChild("HumanoidRootPart")
                        if ob and or2 and root then
                            root.CFrame = ob.CFrame
                            BNR:FireServer(buffer.fromstring(buffers["base"]), { { "tackle" } })
                        end
                    end
                end
            end

            local function hasBall()
                return player.Character and player.Character:FindFirstChild("Ball") ~= nil
            end

            autoGoalState.conn = RunService.RenderStepped:Connect(function()
                if not autoGoalState.enabled then return end
                pcall(function()
                    if not ingame() then return end
                    disableCollisions()
                    stealBall()
                    if hasBall() then
                        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        local goal = player.Team.Name == "A" and bgoal or agoal
                        if root and goal then
                            root.CFrame = goal.CFrame
                            task.wait(0.185)
                            BNR:FireServer(buffer.fromstring(buffers["base"]), { { "kick", 20, false, vector.create(0, 1, 0) } })
                        end
                    end
                end)
            end)
        else
            if autoGoalState.conn then
                autoGoalState.conn:Disconnect()
                autoGoalState.conn = nil
            end
        end
    end
})

local AutoCounterSection = Main:Section({
    Name = "Auto Dribble/Counter",
    Side = 1
})

local autoSkillState = {
    toggleDribble = false,
    toggleCounter1 = false,
    toggleCounter2 = false,
    toggleCounter3 = false,
    toggleCounter4 = false,
    toggleCounter5 = false,
    toggleTSpecial = false,
    mCD = 65,
    fireRate = 0.05,
    useClosestTeammate = false
}

local tackle_anim = {
    "rbxassetid://109744655458082",
    "rbxassetid://113088324958896"
}

local function hasball()
    return player.Character and player.Character:FindFirstChild("Ball") ~= nil
end

local function getClosestTeammate()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closest, closestDistSq = nil, math.huge
    local pPos = root.Position
    local pTeam = player.Team
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Team == pTeam and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local distSq = (pPos - hrp.Position).Magnitude ^ 2
                if distSq < closestDistSq then
                    closestDistSq = distSq
                    closest = plr
                end
            end
        end
    end
    return closest
end

local function fireSkill(skillName, targetPlayer)
    if not hasball() then return end
    local args
    if autoSkillState.useClosestTeammate and targetPlayer then
        local targetChar = targetPlayer.Character
        args = { buffer.fromstring(buffers["base"]), {{ skillName, targetChar }} }
    else
        args = { buffer.fromstring(buffers["base"]), {{ skillName }} }
    end
    BNR:FireServer(unpack(args))
end

local function setupPlayer(plr)
    if plr == player then return end
    
    local function onCharAdded(char)
        local humanoid = char:WaitForChild("Humanoid", 6)
        if not humanoid then return end
        local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:WaitForChild("Animator", 4)
        if not animator then return end
        
        animator.AnimationPlayed:Connect(function(animTrack)
            local isTackle = false
            for _, id in ipairs(tackle_anim) do
                if animTrack.Animation.AnimationId == id then
                    isTackle = true
                    break
                end
            end
            if not isTackle then return end
            if plr.Team == player.Team then return end
            
            local lastFire = 0
            local loopConn
            loopConn = RunService.Heartbeat:Connect(function()
                if not animTrack.IsPlaying or not hasball() then
                    if loopConn then loopConn:Disconnect() end
                    return
                end
                
                local now = tick()
                if now - lastFire < autoSkillState.fireRate then return end
                lastFire = now
                
                local myChar = player.Character
                local root = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local targetHRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                
                if root and targetHRP and (root.Position - targetHRP.Position).Magnitude > autoSkillState.mCD then
                    return
                end
                
                local closestTeammate = autoSkillState.useClosestTeammate and getClosestTeammate() or nil
                
                if autoSkillState.toggleCounter1 then fireSkill("skill1", closestTeammate) end
                if autoSkillState.toggleCounter2 then fireSkill("skill2", closestTeammate) end
                if autoSkillState.toggleCounter3 then fireSkill("skill3", closestTeammate) end
                if autoSkillState.toggleCounter4 then fireSkill("skill4", closestTeammate) end
                if autoSkillState.toggleCounter5 then fireSkill("skill5", closestTeammate) end
                if autoSkillState.toggleTSpecial then fireSkill("Tspecialer", closestTeammate) end
                if autoSkillState.toggleDribble then fireSkill("dribble", closestTeammate) end
            end)
        end)
    end
    
    if plr.Character then onCharAdded(plr.Character) end
    plr.CharacterAdded:Connect(onCharAdded)
end

for _, plr in ipairs(Players:GetPlayers()) do
    setupPlayer(plr)
end
Players.PlayerAdded:Connect(setupPlayer)

AutoCounterSection:Toggle({
    Name = "Auto Dribble",
    Default = false,
    Callback = function(v) autoSkillState.toggleDribble = v end
})

AutoCounterSection:Toggle({
    Name = "Auto Counter (Move 1)",
    Default = false,
    Callback = function(v) autoSkillState.toggleCounter1 = v end
})

AutoCounterSection:Toggle({
    Name = "Auto Counter (Move 2)",
    Default = false,
    Callback = function(v) autoSkillState.toggleCounter2 = v end
})

AutoCounterSection:Toggle({
    Name = "Auto Counter (Move 3)",
    Default = false,
    Callback = function(v) autoSkillState.toggleCounter3 = v end
})

AutoCounterSection:Toggle({
    Name = "Auto Counter (Move 4)",
    Default = false,
    Callback = function(v) autoSkillState.toggleCounter4 = v end
})

AutoCounterSection:Toggle({
    Name = "Auto Counter (Move 5)",
    Default = false,
    Callback = function(v) autoSkillState.toggleCounter5 = v end
})

AutoCounterSection:Toggle({
    Name = "T Special (Only if you have it)",
    Default = false,
    Callback = function(v) autoSkillState.toggleTSpecial = v end
})

AutoCounterSection:Toggle({
    Name = "Use Closest Teammate",
    Default = false,
    Callback = function(v) autoSkillState.useClosestTeammate = v end
})

AutoCounterSection:Slider({
    Name = "Counter Radius",
    Min = 25,
    Max = 75,
    Default = 65,
    Suffix = "studs",
    Callback = function(v) autoSkillState.mCD = v end
})

local AirDribbleSection = Main:Section({
    Name = "Air Dribble",
    Side = 1
})

local airDribbleState = {
    enabled = false,
    isHolding = false,
    lastKick = 0
}

local bindKey = Enum.KeyCode.LeftAlt
local cooldown = 0.255
local holdingConnection = nil

local function performAirDribble()
    local now = tick()
    if now - airDribbleState.lastKick < cooldown then return end

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not (hum and root) then return end

    airDribbleState.lastKick = now

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://76587445975710"
    local track = hum:LoadAnimation(anim)
    track:Play()

    local dir = root.CFrame.LookVector
    local kickVec = Vector3.new(dir.X * 0.75, 0.65, dir.Z * 0.75)

    BNR:FireServer(buffer.fromstring(buffers["base"]), {{"kick", 28, false, kickVec}})
end

AirDribbleSection:Toggle({
    Name = "Air Dribble",
    Default = false,
    Callback = function(v) airDribbleState.enabled = v end
})

AirDribbleSection:Textbox({
    Name = "Air Dribble Bind",
    Placeholder = "Example: E, Q, LeftAlt",
    Callback = function(text)
        if typeof(text) ~= "string" then
            bindKey = Enum.KeyCode.LeftAlt
            return
        end
        local formatted = text:gsub("%s+", "")
        local success, key = pcall(function()
            return Enum.KeyCode[formatted]
        end)
        if success and key then
            bindKey = key
        else
            bindKey = Enum.KeyCode.LeftAlt
        end
    end
})

UserInputService.InputBegan:Connect(function(input, gp)
    if gp or input.KeyCode ~= bindKey then return end
    if not airDribbleState.enabled then return end
    airDribbleState.isHolding = true
    performAirDribble()
    
    if holdingConnection then holdingConnection:Disconnect() end
    holdingConnection = RunService.Heartbeat:Connect(function()
        if airDribbleState.isHolding and airDribbleState.enabled then
            performAirDribble()
        else
            holdingConnection:Disconnect()
            holdingConnection = nil
        end
    end)
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == bindKey then
        airDribbleState.isHolding = false
        if holdingConnection then
            holdingConnection:Disconnect()
            holdingConnection = nil
        end
    end
end)

local InfinitePassSection = Main:Section({
    Name = "Infinite Range Passing",
    Side = 1
})

local passingState = {
    InfiniteRangePassing = false,
    busy = false
}

local keyToSkill = {
    [Enum.KeyCode.One] = "skill1",
    [Enum.KeyCode.Two] = "skill2",
    [Enum.KeyCode.Three] = "skill3",
    [Enum.KeyCode.Four] = "skill4",
}

local function getClosestPlayerToCursor()
    local mousePos = UserInputService:GetMouseLocation()
    local closestChar, closestDist = nil, math.huge
    local Camera = workspace.CurrentCamera
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Team == player.Team then
            local char = p.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            if hum and hrp and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestChar = char
                    end
                end
            end
        end
    end
    
    return closestChar
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not passingState.InfiniteRangePassing then return end
    if passingState.busy then return end
    if player.Team == game.Teams.lobby then return end
    
    local skillName = keyToSkill[input.KeyCode]
    if not skillName then return end
    
    local targetChar = getClosestPlayerToCursor()
    if not targetChar then return end
    
    passingState.busy = true
    
    BNR:FireServer(buffer.fromstring(buffers["base"]), {{skillName, targetChar}})
    
    task.delay(0.1, function()
        passingState.busy = false
    end)
end)

InfinitePassSection:Toggle({
    Name = "Infinite Range Passing",
    Default = false,
    Callback = function(v) passingState.InfiniteRangePassing = v end
})

local LineUps = Combat:SubTab({
    Name = "Line Ups",
    Icon = "target"
})

local LineUpsSection = LineUps:Section({
    Name = "Auto Line Ups",
    Side = 1
})

local padCount = 0
local targetCount = 0
local activeLineups = {}
local holdingRMB = false
local camLockConnection = nil
local activeTarget = nil
local lineupLockActive = false
local currentLineupMode = "Freeze"

local camera = workspace.CurrentCamera
local character = player.Character
local hrp = character and character:FindFirstChild("HumanoidRootPart")
local humanoid = character and character:FindFirstChildOfClass("Humanoid")

local function updateCharacterRefs(char)
    character = char
    hrp = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
end

if player.Character then 
    updateCharacterRefs(player.Character) 
end
player.CharacterAdded:Connect(updateCharacterRefs)

local function pad(pos, color)
    padCount += 1
    local p = Instance.new("Part")
    p.Name = "pad" .. padCount
    p.Size = Vector3.new(4, 4, 4)
    p.Position = pos
    p.Transparency = 0.65
    p.Anchored = true
    p.CanCollide = false
    p.Color = color
    p.Material = Enum.Material.SmoothPlastic
    p.Parent = workspace
    table.insert(activeLineups, p)
end

local function target(pos, color)
    targetCount += 1
    local t = Instance.new("Part")
    t.Name = "target" .. targetCount
    t.Shape = Enum.PartType.Ball
    t.Size = Vector3.new(7, 7, 7)
    t.Position = pos
    t.Anchored = true
    t.CanCollide = false
    t.Color = color
    t.Material = Enum.Material.Neon
    t.Parent = workspace
    table.insert(activeLineups, t)
end

local function clearLineups()
    for _, obj in ipairs(activeLineups) do
        if obj and obj.Parent then obj:Destroy() end
    end
    activeLineups = {}
    padCount = 0
    targetCount = 0
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holdingRMB = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holdingRMB = false
        activeTarget = nil
        lineupLockActive = false
        
        if camLockConnection then
            camLockConnection:Disconnect()
            camLockConnection = nil
        end
        
        if humanoid then humanoid.WalkSpeed = 30 end
        if hrp then hrp.Anchored = false end
    end
end)

local function getPadUnderPlayer()
    if not hrp then return nil end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(hrp.Position, Vector3.new(0, -6, 0), params)
    if result and result.Instance then
        return result.Instance.Name:match("^pad(%d+)$")
    end
    return nil
end

local function startCamLock(targetPart)
    activeTarget = targetPart
    if camLockConnection then camLockConnection:Disconnect() end
    camLockConnection = RunService.RenderStepped:Connect(function()
        if not activeTarget then
            if camLockConnection then camLockConnection:Disconnect() end
            camLockConnection = nil
            return
        end
        camera.CFrame = CFrame.new(camera.CFrame.Position, activeTarget.Position)
    end)
end

local function stopCamLock()
    activeTarget = nil
    if camLockConnection then
        camLockConnection:Disconnect()
        camLockConnection = nil
    end
end

local function resetLineupPhysics()
    if lineupLockActive then
        lineupLockActive = false
        if currentLineupMode == "Freeze" then
            if hrp then hrp.Anchored = false end
        elseif currentLineupMode == "Slowness" then
            if humanoid then humanoid.WalkSpeed = 30 end
        end
    end
end

local function applyLineupMode()
    lineupLockActive = true
    if currentLineupMode == "Freeze" then
        if hrp then hrp.Anchored = true end
    elseif currentLineupMode == "Slowness" then
        if humanoid then humanoid.WalkSpeed = 5 end
    end
end

RunService.RenderStepped:Connect(function()
    if not holdingRMB or not hrp or not humanoid then
        resetLineupPhysics()
        return
    end
    
    local padIndex = getPadUnderPlayer()
    if not padIndex then
        resetLineupPhysics()
        stopCamLock()
        return
    end
    
    local targetPart = workspace:FindFirstChild("target" .. padIndex)
    if not targetPart then
        resetLineupPhysics()
        return
    end
    
    if activeTarget ~= targetPart then
        startCamLock(targetPart)
    end
    
    applyLineupMode()
end)

local function createLineUps(goalRelative, colors)
    clearLineups()
    
    local map = workspace:WaitForChild("map")
    local agoal = map:FindFirstChild("Agoal")
    local bgoal = map:FindFirstChild("Bgoal")
    
    if not agoal or not bgoal then return end
    
    local agoalPos = agoal.Position
    local bgoalPos = bgoal.Position
    
    for i, entry in ipairs(goalRelative) do
        local basePos = (i <= #goalRelative/2) and agoalPos or bgoalPos
        local col = colors[(i - 1) % #colors + 1]
        
        pad(basePos + entry.pad, col)
        target(basePos + entry.target, col)
    end
end

LineUpsSection:Toggle({
    Name = "Sae Line Ups",
    Default = false,
    Callback = function(v)
        if v then
            local colors = {
                Color3.fromRGB(255, 0, 0),
                Color3.fromRGB(0, 255, 0),
                Color3.fromRGB(255, 255, 0),
                Color3.fromRGB(0, 0, 255),
                Color3.fromRGB(255, 0, 255),
                Color3.fromRGB(255, 182, 193),
            }
            
            local goalRelative = {
                {pad = Vector3.new(-58, -9, -127), target = Vector3.new(71, 35, -13)},
                {pad = Vector3.new(-38, -9, -171), target = Vector3.new(70, 18, -13)},
                {pad = Vector3.new(-16, -9, -176), target = Vector3.new(45, 45, -14)},
                {pad = Vector3.new(15, -9, -174), target = Vector3.new(25, 25, -14)},
                {pad = Vector3.new(48, -9, -161), target = Vector3.new(20, 32, -14)},
                {pad = Vector3.new(71, -9, -134), target = Vector3.new(22, 5, -12)},
                {pad = Vector3.new(86, -9, -113), target = Vector3.new(31, 19, -14)},
                {pad = Vector3.new(99, -9, -137), target = Vector3.new(29, 34, -14)},
                {pad = Vector3.new(-47, -9, -145), target = Vector3.new(53, 28, -14)},
                {pad = Vector3.new(132, -9, -111), target = Vector3.new(30, 8, -13)},
                {pad = Vector3.new(58, -9, 127), target = Vector3.new(-71, 35, 13)},
                {pad = Vector3.new(38, -9, 171), target = Vector3.new(-70, 18, 13)},
                {pad = Vector3.new(16, -9, 176), target = Vector3.new(-45, 45, 14)},
                {pad = Vector3.new(-15, -9, 174), target = Vector3.new(-25, 25, 14)},
                {pad = Vector3.new(-48, -9, 161), target = Vector3.new(-20, 32, 14)},
                {pad = Vector3.new(-71, -9, 134), target = Vector3.new(-22, 5, 12)},
                {pad = Vector3.new(-86, -9, 113), target = Vector3.new(-31, 19, 14)},
                {pad = Vector3.new(-99, -9, 137), target = Vector3.new(-29, 34, 14)},
                {pad = Vector3.new(47, -9, 145), target = Vector3.new(-53, 28, 14)},
                {pad = Vector3.new(-132, -9, 111), target = Vector3.new(-30, 8, 13)},
            }
            
            createLineUps(goalRelative, colors)
        else
            clearLineups()
        end
    end
})

LineUpsSection:Toggle({
    Name = "Yukimiya Line Ups",
    Default = false,
    Callback = function(v)
        if v then
            local colors = {
                Color3.fromRGB(255, 0, 0),
                Color3.fromRGB(255, 255, 0),
                Color3.fromRGB(0, 0, 255),
                Color3.fromRGB(0, 255, 0),
            }
            
            local goalRelative = {
                {pad = Vector3.new(3, -9, -216), target = Vector3.new(68, 144, -16)},
                {pad = Vector3.new(62, -9, -193), target = Vector3.new(50, 91, -16)},
                {pad = Vector3.new(-39, -9, -128), target = Vector3.new(6, 0, -12)},
                {pad = Vector3.new(-32, -9, -134), target = Vector3.new(15, 8, -15)},
                {pad = Vector3.new(-142, -9, -97), target = Vector3.new(81, 65, -16)},
                {pad = Vector3.new(-69, -9, -212), target = Vector3.new(158, 223, -16)},
                {pad = Vector3.new(32, -9, -130), target = Vector3.new(-10, 24, -14)},
                {pad = Vector3.new(-115, -9, -160), target = Vector3.new(33, 72, -14)},
                {pad = Vector3.new(-92, -9, -188), target = Vector3.new(99, 133, -13)},
                {pad = Vector3.new(-40, -9, -208), target = Vector3.new(50, 116, -14)},
                {pad = Vector3.new(57, -9, -122), target = Vector3.new(-8, 23, -15)},
                {pad = Vector3.new(-3, -9, 216), target = Vector3.new(-68, 144, 16)},
                {pad = Vector3.new(-62, -9, 193), target = Vector3.new(-50, 91, 16)},
                {pad = Vector3.new(39, -9, 128), target = Vector3.new(-6, 0, 12)},
                {pad = Vector3.new(32, -9, 134), target = Vector3.new(-15, 8, 15)},
                {pad = Vector3.new(142, -9, 97), target = Vector3.new(-81, 65, 16)},
                {pad = Vector3.new(69, -9, 212), target = Vector3.new(-158, 223, 16)},
                {pad = Vector3.new(-32, -9, 130), target = Vector3.new(10, 24, 14)},
                {pad = Vector3.new(115, -9, 160), target = Vector3.new(-33, 72, 14)},
                {pad = Vector3.new(92, -9, 188), target = Vector3.new(-99, 133, 13)},
                {pad = Vector3.new(40, -9, 208), target = Vector3.new(-50, 116, 14)},
                {pad = Vector3.new(-57, -9, 122), target = Vector3.new(8, 23, 15)},
            }
            
            createLineUps(goalRelative, colors)
        else
            clearLineups()
        end
    end
})

local MovesetSection = Combat:SubTab({
    Name = "Movesets",
    Icon = "swords"
})

local Movesets = MovesetSection:Section({
    Name = "Tze Movesets",
    Side = 1
})

Movesets:Button({
    Name = "Sonic.EXE",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/3XaQHzCX", true))()
    end,
})

Movesets:Button({
    Name = "KJ Moveset (Req. shidou)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/jonathabejose-alt/Azure-latch/refs/heads/main/KJ%20Style.lua", true))()
    end,
})

Movesets:Button({
    Name = "Messi",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/jonathabejose-alt/Azure-latch/refs/heads/main/MessiStyle.lua", true))()
    end,
})

Movesets:Button({
    Name = "Ronaldo",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/jonathabejose-alt/Azure-latch/refs/heads/main/RonaldoStyle.lua", true))()
    end,
})

Movesets:Button({
    Name = "Loki",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/jonathabejose-alt/Azure-latch/refs/heads/main/loki.lua"))()
    end,
})

local Settings = Window:Tab({
    Name = "Settings",
    Icon = "settings"
})

local Config = Settings:SubTab({
    Name = "Config",
    Icon = "save"
})

Config:ThemeConfig({ })

Window:Watermark({
    Name = "ZOLAR"
})
