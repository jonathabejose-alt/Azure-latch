local plr = game.Players.LocalPlayer
local rep = game:GetService("ReplicatedStorage")
local remote = rep:WaitForChild("ByteNetReliable")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local buffers = {}
loadstring(game:HttpGet("https://pastebin.com/raw/8XJh7dzh"))()
repeat task.wait() until game.Lighting:FindFirstChild("BUFFERSTRINGS")
for _, val in ipairs(game.Lighting:FindFirstChild("BUFFERSTRINGS"):GetChildren()) do
    buffers[val.Name] = val.Value
end
game.Lighting:FindFirstChild("BUFFERSTRINGS"):Destroy()

local stopped = false
local exeAwkOnCD = false

local trajectory = {}
local metavisionEnabled = false
local metavisionLoop = nil

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

local function hideAllMetavision()
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
    local char = plr.Character
    if not char then return {} end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return {} end
    local nearby = {}
    local pos = hrp.Position
    local playersList = Players:GetPlayers()
    for i = 1, #playersList do
        local p = playersList[i]
        if p ~= plr then
            local c = p.Character
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
        hideAllMetavision()
        return
    end
    
    if #trajectory < 2 then
        hideAllMetavision()
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

local function setupBarrierDisable(part)
    if not part then return end
    part.CanCollide = false
    part.AncestryChanged:Connect(function()
        if part and part.Parent then
            part.CanCollide = false
        end
    end)
end

local function watchGkBarriar(gkb)
    for _, name in ipairs({"Abarriar", "Bbarriar"}) do
        local p = gkb:FindFirstChild(name)
        if p then setupBarrierDisable(p) end
        gkb.ChildAdded:Connect(function(child)
            if child.Name == name then setupBarrierDisable(child) end
        end)
    end
end

local function watchMap()
    local map = workspace:FindFirstChild("map")
    if map then
        local gkb = map:FindFirstChild("gkbarriar")
        if gkb then watchGkBarriar(gkb) end
        map.ChildAdded:Connect(function(child)
            if child.Name == "gkbarriar" then watchGkBarriar(child) end
        end)
        for _, name in ipairs({"Agoal", "Bgoal"}) do
            local g = map:FindFirstChild(name)
            if g then g.CanCollide = false end
            map.ChildAdded:Connect(function(child)
                if child.Name == name then child.CanCollide = false end
            end)
        end
    end
end

task.spawn(watchMap)
workspace.ChildAdded:Connect(function(child)
    if child.Name == "map" then watchMap() end
end)

local function HasBall()
    return plr.Character and plr.Character:FindFirstChild("Ball")
end

local function Stunned()
    local char = plr.Character
    if not char then return true end
    local state = char:FindFirstChild("state")
    if not state then return true end
    local stun = state:FindFirstChild("stun")
    if not stun then return true end
    return stun.Value
end

local function CancelMove()
    local char = plr.Character
    if char then
        local state = char:FindFirstChild("state")
        if state then
            local stun = state:FindFirstChild("stun")
            if stun then
                stun.Value = true
                task.wait(0.04)
                stun.Value = false
            end
        end
    end
end

local function IsOnCD(name)
    local hotbar = plr.PlayerGui:FindFirstChild("Hotbar")
    if not hotbar then return false end
    local btn = hotbar.Backpack.Hotbar:FindFirstChild(name)
    if btn and btn:FindFirstChild("Cooldown") then return btn.Cooldown.Visible end
    return false
end

local function DoCD(name, duration)
    local hotbar = plr.PlayerGui:FindFirstChild("Hotbar")
    if not hotbar then return end
    local btn = hotbar.Backpack.Hotbar:FindFirstChild(name)
    if btn and btn:FindFirstChild("Cooldown") then
        btn.Cooldown.Visible = true
        btn.Cooldown.Size = UDim2.new(1, 0, -1, 0)
        TweenService:Create(btn.Cooldown, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.delay(duration, function() 
            if btn and btn.Cooldown then
                btn.Cooldown.Visible = false 
            end
        end)
    end
end

local function Stun(time, disableRotate)
    local char = plr.Character
    if not char then return end
    if char.state then
        char.state.stun.Value = true
    end
    if disableRotate then char:SetAttribute("disableRotate", true) end
    local cfg = Instance.new("Configuration")
    cfg:SetAttribute("speed", 0)
    cfg:SetAttribute("jump", 0)
    local movements = char:FindFirstChild("movements")
    if movements then
        cfg.Parent = movements
    end
    task.delay(time, function()
        pcall(function()
            if char and char.state then
                char.state.stun.Value = false
            end
            if disableRotate then 
                pcall(function() char:SetAttribute("disableRotate", false) end)
            end
        end)
    end)
    Debris:AddItem(cfg, time)
end

local function BlockOriginalSkills()
    task.wait(0.1)
    local hotbar = plr.PlayerGui:FindFirstChild("Hotbar")
    if hotbar then
        local buttons = hotbar.Backpack.Hotbar
        for i = 1, 5 do
            local skill = buttons:FindFirstChild("skill" .. i)
            if skill and skill:FindFirstChild("Base") then
                local base = skill.Base
                base.Active = false
                base.AutoButtonColor = false
                pcall(function()
                    base.MouseButton1Click:DisconnectAll()
                    base.MouseButton1Down:DisconnectAll()
                end)
            end
        end
    end
end

local function TeleportShot(char, shootDelay)
    local root = char.HumanoidRootPart
    task.delay(shootDelay, function()
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Ball") then return end
        
        local function executeShot()
            remote:FireServer(buffer.fromstring(buffers["base"]), {
                {"kick", 100, false, root.CFrame.LookVector * 1e19}
            })
        end

        if getgenv().LegitMode then
            executeShot()
            return
        end

        local originalCFrame = root.CFrame
        local lookVector = root.CFrame.LookVector
        local team = char.state.team.Value
        local oppositeTeam = team == "A" and "B" or "A"
        local goal = workspace.map and workspace.map:FindFirstChild(oppositeTeam .. "goal")
        local filterList = {char, workspace.Effects}
        if goal then table.insert(filterList, goal) end
        local gkBarrier = workspace.map and workspace.map:FindFirstChild("gkbarriar")
        if gkBarrier then
            local barrierPart = gkBarrier:FindFirstChild(oppositeTeam == "A" and "Abarriar" or "Bbarriar")
            if barrierPart then table.insert(filterList, barrierPart) end
        end
        local gkCheck = workspace.map and workspace.map:FindFirstChild(oppositeTeam .. "GoalkeeperCheck")
        if gkCheck then table.insert(filterList, gkCheck) end
        char:PivotTo(CFrame.new((function()
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = filterList
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            local rayResult = workspace:Raycast(root.Position, lookVector * 1000, rayParams)
            return rayResult and rayResult.Position - lookVector * 2 or root.Position
        end)()))
        root.CFrame = root.CFrame * CFrame.Angles(0, math.pi, 0) * CFrame.new(0, 0, -8.823999)
        task.wait(0.2)
        
        executeShot()
        
        task.wait(0.001)
        root.CFrame = originalCFrame
    end)
end

local function Shortcut()
    local char = plr.Character
    if not char or Stunned() or IsOnCD("skill1") then return end

    CancelMove()
    DoCD("skill1", 1)

    local humanoid = char.Humanoid
    local root = char.HumanoidRootPart

    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do track:Stop(0) end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://116455589260954"
    local track = humanoid:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action
    track:Play()

    pcall(function()
        require(rep.client.replication).DashSuper(char)
    end)

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://111414558186727"
    sound.Volume = 2
    sound.Parent = root
    sound:Play()
    Debris:AddItem(sound, 3)

    Stun(0.3, false)

    task.delay(1.5, function()
        pcall(function()
            track:Stop()
        end)
    end)
end

local function Exterminate()
    local char = plr.Character
    if not char or Stunned() or IsOnCD("skill2") then return end
    if HasBall() then return end

    local ball = workspace.Terrain:FindFirstChild("Ball")
    if not ball then return end

    local root = char.HumanoidRootPart
    local dist = (root.Position - ball.Position).Magnitude
    if dist > 1050 then return end

    CancelMove()
    DoCD("skill2", 0.8)

    local humanoid = char.Humanoid
    local originalCF = root.CFrame
    local grabbedByHBM = false

    if getgenv().HBM and type(getgenv().HBM) == "number" then
        local hbmSize = getgenv().HBM
        if dist <= hbmSize then
            remote:FireServer(buffer.fromstring(buffers["grabball"]))
            task.wait(0.15)
            if HasBall() then
                grabbedByHBM = true
            end
        end
    end

    if not grabbedByHBM then
        local grabbed = false
        local timeout = 0
        local maxTimeout = 300 

        while not grabbed and timeout < maxTimeout do
            local currentBall = workspace.Terrain:FindFirstChild("Ball")
            if not currentBall then
                root.CFrame = originalCF
                return
            end

            local targetPos = currentBall.Position + Vector3.new(0, 2, 0)
            root.CFrame = CFrame.new(targetPos, targetPos + Vector3.new(0, 0, -1))
            root.AssemblyLinearVelocity = Vector3.zero

            task.wait(0.1)

            remote:FireServer(buffer.fromstring(buffers["grabball"]))
            task.wait(0.05)

            if HasBall() then
                grabbed = true
                break
            end

            timeout = timeout + 1
        end

        if not grabbed then
            root.CFrame = originalCF
            return
        end
    end

    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do track:Stop(0) end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://71606482166598"
    local track = humanoid:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action
    track:Play()

    if not grabbedByHBM then
        root.Anchored = true
    end

    pcall(function()
        require(rep.client.replication).TP(char)
    end)

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://130820040577966"
    sound.Volume = 2
    sound.Parent = root
    sound:Play()
    Debris:AddItem(sound, 5)

    Stun(0.7, true)

    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0.3
    highlight.Parent = char
    Debris:AddItem(highlight, 1.5)

    TweenService:Create(highlight, TweenInfo.new(1.5), {FillTransparency = 1}):Play()
    TweenService:Create(highlight, TweenInfo.new(1.5), {OutlineTransparency = 1}):Play()

    task.delay(0.9, function()
        root.Anchored = false
        pcall(function()
            track:Stop()
            if char and char.state then
                char.state.stun.Value = false
            end
        end)
    end)
end

local function EXEStrike()
    local char = plr.Character
    if not char or Stunned() or IsOnCD("skill3") then return end
    if not HasBall() then return end

    CancelMove()
    DoCD("skill3", 8)

    local humanoid = char.Humanoid
    local root = char.HumanoidRootPart

    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do track:Stop(0) end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://111105572890621"
    local track = humanoid:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action
    track:Play()

    TweenService:Create(humanoid, TweenInfo.new(0.3, Enum.EasingStyle.Cubic), {HipHeight = 25}):Play()

    local sound1 = Instance.new("Sound")
    sound1.SoundId = "rbxassetid://71531490355205"
    sound1.Volume = 2
    sound1.Parent = root
    sound1:Play()
    Debris:AddItem(sound1, 4)

    task.spawn(function()
        task.wait(3.9)
        local sound2 = Instance.new("Sound")
        sound2.SoundId = "rbxassetid://125906215069324"
        sound2.Volume = 3
        sound2.Parent = root
        sound2:Play()
        Debris:AddItem(sound2, 5)
    end)

    pcall(function()
        require(rep.client.replication).DASTStrike(char)
    end)
   
    task.delay(3.8, function()
        root.Anchored = false
        root.Velocity = Vector3.new(0, -200, 0)
        humanoid.HipHeight = 0
    end)

    TeleportShot(char, 3.9)
    
    Stun(5.2, false)

    task.delay(5.2, function()
        pcall(function()
            track:Stop()
        end)
    end)
end

local function OpenMetavision()
    if stopped then return end
    
    if not metavisionEnabled then
        metavisionEnabled = true
        DoCD("skill4", 15)
        
        if not metavisionLoop then
            metavisionLoop = RunService.Heartbeat:Connect(updateMetavision)
        end
    else
        metavisionEnabled = false
        if metavisionLoop then
            metavisionLoop:Disconnect()
            metavisionLoop = nil
        end
        hideAllMetavision()
    end
end

local function ExeAwk()
    local char = plr.Character
    if not char or Stunned() or exeAwkOnCD then return end
    if not HasBall() then return end

    exeAwkOnCD = true

    local humanoid = char.Humanoid
    local root = char.HumanoidRootPart
    local savedStyle = plr:GetAttribute("style")

    Stun(21, true)
    plr:SetAttribute("style", "exe")

    TweenService:Create(humanoid, TweenInfo.new(0.3, Enum.EasingStyle.Cubic), {HipHeight = 25}):Play()

    task.spawn(function()
        pcall(function()
            local song = rep.Resources.exe.awkSong
            song.Volume = 12
            require(rep.util.soundUtil):play(song, SoundService)
            task.delay(129, function()
                song:Stop()
            end)
        end)
    end)

    task.spawn(function()
        pcall(function()
            require(rep.util.animationUtil):loadAnimation(char, rep.Resources.exe.awk):Play()
        end)
    end)

    task.spawn(function()
        pcall(function()
            require(rep.client.replication).exeAwk(char)
        end)
    end)

    task.delay(21, function()
        if not char or not char.Parent then return end
        
        TweenService:Create(humanoid, TweenInfo.new(0.3, Enum.EasingStyle.Cubic), {HipHeight = 0}):Play()
        plr:SetAttribute("style", savedStyle)
        
        task.delay(30, function()
            exeAwkOnCD = false
        end)
    end)
end

local function StopMoveset()
    stopped = true
    metavisionEnabled = false
    
    if metavisionLoop then
        metavisionLoop:Disconnect()
        metavisionLoop = nil
    end
    
    hideAllMetavision()
    
    pcall(function()
        visionFolder:Destroy()
    end)
    
    local hotbar = plr.PlayerGui:FindFirstChild("Hotbar")
    if hotbar then
        local buttons = hotbar.Backpack.Hotbar
        for i = 1, 5 do
            local skill = buttons:FindFirstChild("skill" .. i)
            if skill then
                skill.Visible = false
            end
        end
    end
end

local function Setup(char)
    if stopped then return end
    repeat task.wait() until plr.Team ~= game.Teams.lobby
    task.wait(0.1)
    BlockOriginalSkills()
    
    local hotbar = plr.PlayerGui:WaitForChild("Hotbar")
    local buttons = hotbar.Backpack.Hotbar

    if buttons.skill5 then buttons.skill5.Visible = false end
    if buttons.skill5 and buttons.skill5.Base then buttons.skill5.Base.Active = false end

    buttons.skill1.Base.MouseButton1Down:Connect(Shortcut)
    buttons.skill2.Base.MouseButton1Down:Connect(Exterminate)
    buttons.skill3.Base.MouseButton1Down:Connect(EXEStrike)
    buttons.skill4.Base.MouseButton1Down:Connect(OpenMetavision)

    buttons.skill1.Base.Reuse.Text = "Ball"
    buttons.skill2.Base.Reuse.Text = "Off Ball"
    buttons.skill3.Base.Reuse.Text = "Ball"
    buttons.skill4.Base.Reuse.Text = "God Mode"

    for i = 1, 4 do 
        buttons["skill"..i].Base.Reuse.Visible = true
        buttons["skill"..i].Visible = true
    end

    pcall(function()
        local mh = hotbar:FindFirstChild("MagicHealth")
        if mh and mh:FindFirstChild("Awakening") then
            mh.Awakening.TouchTap:Connect(ExeAwk)
            mh.Awakening.MouseButton1Click:Connect(ExeAwk)
        end
    end)
end

Setup(plr.Character)

plr.CharacterAdded:Connect(function(char)
    exeAwkOnCD = false
    task.wait(1)
    Setup(char)
end)

task.spawn(function()
    while true do
        if stopped then break end
        local gui = plr:WaitForChild("PlayerGui", 2)
        if gui then
            local hotbar = gui:FindFirstChild("Hotbar")
            if hotbar then
                hotbar.Backpack.Hotbar.skill1.Base.ToolName.Text = "Shortcut"
                hotbar.Backpack.Hotbar.skill2.Base.ToolName.Text = "Exterminate"
                hotbar.Backpack.Hotbar.skill3.Base.ToolName.Text = "EXE Strike"
                hotbar.Backpack.Hotbar.skill4.Base.ToolName.Text = "Open Metavision"

                hotbar.MagicHealth.Awakening.Text = "FLOW"
                hotbar.MagicHealth.TextLabel.Text = "Many Souls To Play With."
                hotbar.MagicHealth.Health.Frame.UIGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 0))
                }
            end
        end
        task.wait(0.1)
    end
end)

UserInputService.InputBegan:Connect(function(input, bg)
    if bg or stopped then return end

    if input.KeyCode == Enum.KeyCode.G then
        ExeAwk()
    elseif input.KeyCode == Enum.KeyCode.One then
        Shortcut()
    elseif input.KeyCode == Enum.KeyCode.Two then
        Exterminate()
    elseif input.KeyCode == Enum.KeyCode.Three then
        EXEStrike()
    elseif input.KeyCode == Enum.KeyCode.Four then
        OpenMetavision()
    elseif input.KeyCode == Enum.KeyCode.F5 then
        StopMoveset()
    end
end)

print("Sonic.exe Moveset loaded!")
