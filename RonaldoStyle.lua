workspace.map.gkbarriar.Abarriar.CanCollide = false
workspace.map.gkbarriar.Bbarriar.CanCollide = false
workspace.map.Agoal.CanCollide = false
workspace.map.Bgoal.CanCollide = false

local ReplicatedStorage = game.ReplicatedStorage

local buffers = {}
loadstring(game:HttpGet("https://pastebin.com/raw/8XJh7dzh"))()
repeat task.wait() until game.Lighting:FindFirstChild("BUFFERSTRINGS")
for _, val in ipairs(game.Lighting:FindFirstChild("BUFFERSTRINGS"):GetChildren()) do
    buffers[val.Name] = val.Value
end
game.Lighting:FindFirstChild("BUFFERSTRINGS"):Destroy()

game:GetService("ReplicatedStorage").Resources.shidou.NEWthemes.SoundId = "rbxassetid://101265113960897"
game:GetService("ReplicatedStorage").Resources.shidou.AwkOvertime.BGM.SoundId = "rbxassetid://101265113960897"

local plr = game.Players.LocalPlayer
local rep = game:GetService("ReplicatedStorage")
local remote = rep:WaitForChild("ByteNetReliable")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

if getgenv().DribbleSpeed == nil then getgenv().DribbleSpeed = 1 end
getgenv().DribbleSpeed = math.clamp(getgenv().DribbleSpeed, 0.1, 3)

local initialized = false
local fahh = false
local disabled = false
local lastAccelerate = 0
local accelerateCooldown = 7.5
local lastGOAT = 0
local goatCooldown = 30

local skillNames = {
    [1] = "CR7 Dribble",
    [2] = "Bicycle Kick",
    [3] = "Flawless Pass",
    [4] = "Reaction Dash",
    [5] = "Greatest Of All Time"
}

local function ToggleAttachment(attachment, enabled, duration)
    if not attachment then return end
    for _, descendant in ipairs(attachment:GetDescendants()) do
        if descendant:IsA("ParticleEmitter") then descendant.Enabled = enabled end
    end
    if duration and duration > 0 then
        task.delay(duration, function() ToggleAttachment(attachment, false) end)
    end
end

local function EmitAttachment(attachment)
    if not attachment then return end
    for _, descendant in ipairs(attachment:GetDescendants()) do
        if descendant:IsA("ParticleEmitter") then
            local delayTime = descendant:GetAttribute("EmitDelay") or 0
            local count = descendant:GetAttribute("EmitCount") or 1
            if delayTime > 0 then task.delay(delayTime, function() descendant:Emit(count) end)
            else descendant:Emit(count) end
        end
    end
end

local function GroupWeld(model, rootPart)
    for _, part in ipairs(rootPart:GetDescendants()) do
        if part:IsA("BasePart") and model:FindFirstChild(part.Name) then
            local weld = Instance.new("Weld")
            weld.Name = "weld"
            weld.Part0 = model:FindFirstChild(part.Name)
            weld.Part1 = part
            weld.Parent = part
        end
    end
end

local function hasball()
    return plr.Character and plr.Character:FindFirstChild("Ball") ~= nil
end

local function BodyVelocity(part, speed, duration, startAtZero, easingInfo, delayTween, delayStart, useCustomTween)
    for _, v in pairs(part:GetChildren()) do
        if v:IsA("BodyVelocity") then v:Destroy() end
    end
    local directionProperty = delayTween or "LookVector"
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(350000, 0, 350000)
    bv.Parent = part
    task.delay(duration, bv.Destroy, bv)
    local valueHolder = Instance.new("NumberValue")
    valueHolder.Value = startAtZero and 0 or speed
    valueHolder.Parent = bv
    if not useCustomTween then
        local tweenInfo = easingInfo or TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        game.TweenService:Create(valueHolder, tweenInfo, {Value = startAtZero and 0 or speed}):Play()
    else
        task.delay(useCustomTween, function()
            local easingStyle = easingInfo or Enum.EasingStyle.Linear
            local tweenInfo = TweenInfo.new(duration, easingStyle, Enum.EasingDirection.Out)
            game.TweenService:Create(valueHolder, tweenInfo, {Value = startAtZero and 0 or speed}):Play()
        end)
    end
    if not delayStart then
        bv.Velocity = part.CFrame[directionProperty] * speed
        local connection = RunService.RenderStepped:Connect(function()
            if not bv or not bv.Parent then connection:Disconnect(); return end
            bv.Velocity = part.CFrame[directionProperty] * valueHolder.Value
        end)
    end
    return bv, valueHolder
end

local function sfx(sound, part)
    local s = sound:Clone()
    s.Parent = part
    s:Play()
    game.Debris:AddItem(s, s.TimeLength + 20)
end

local function StartCooldownUI(slotNumber, duration)
    local gui = plr:WaitForChild("PlayerGui", 5)
    if not gui then return end
    local hotbar = gui:FindFirstChild("Hotbar")
    if not hotbar then return end
    local backpack = hotbar:FindFirstChild("Backpack")
    if not backpack then return end
    local hb = backpack:FindFirstChild("Hotbar")
    if not hb then return end
    local skill = hb:FindFirstChild("skill" .. slotNumber)
    if not skill then return end
    local cdFrame = skill:FindFirstChild("Cooldown")
    if not cdFrame then return end
    cdFrame.Size = UDim2.new(1, 0, -1, 0)
    cdFrame.Visible = true
    local tween = TweenService:Create(cdFrame, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 0, 0)})
    tween:Play()
    tween.Completed:Connect(function() cdFrame.Visible = false end)
end

task.spawn(function()
    while true do
        if disabled then break end
        local gui = plr:WaitForChild("PlayerGui", 2)
        if gui then
            local hotbar = gui:FindFirstChild("Hotbar")
            if hotbar then
                local backpack = hotbar:FindFirstChild("Backpack")
                if backpack then
                    local hb = backpack:FindFirstChild("Hotbar")
                    if hb then
                        for i = 1, 5 do
                            local skill = hb:FindFirstChild("skill" .. i)
                            if skill and skill:FindFirstChild("Base") and skill.Base:FindFirstChild("ToolName") then
                                if skill.Base.ToolName.Text ~= skillNames[i] then skill.Base.ToolName.Text = skillNames[i] end
                            end
                            if skill and skill:FindFirstChild("Base") and skill.Base:FindFirstChild("Reuse") then
                                if i == 1 then skill.Base.Reuse.Text = "Ball"
                                elseif i == 2 then skill.Base.Reuse.Text = "Shot"
                                elseif i == 3 then skill.Base.Reuse.Text = "Pass"
                                elseif i == 4 then skill.Base.Reuse.Text = "Off The Ball"
                                elseif i == 5 then skill.Base.Reuse.Text = "Awaken" end
                                skill.Base.Reuse.Visible = true
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

UserInputService.InputBegan:Connect(function(input, bg)
    if bg then return end
    if disabled then return end
    
    if input.KeyCode == Enum.KeyCode.F4 then
        disabled = true
        return
    end
    
    local char = plr.Character
    if not char then return end
    
    local state = char:FindFirstChild("state")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if input.KeyCode == Enum.KeyCode.One then
        task.spawn(function()
            local stun = state and state:FindFirstChild("stun")
            if stun then stun.Value = true; task.wait(0.03); stun.Value = fahh and true or false end
        end)
        task.wait(0.03)
        if char.state.stun.Value or not hasball() or fahh then return end
        char.state.stun.Value = true
        local loopws = RunService.RenderStepped:Connect(function() char.Humanoid.WalkSpeed = 0 end)
        fahh = true
        task.delay(4.6, function()
            if disabled then return end
            loopws:Disconnect()
            char.Humanoid.WalkSpeed = 40
            char.state.stun.Value = false
            StartCooldownUI(1, 5)
            fahh = false
        end)
        local anim = char.Humanoid:LoadAnimation(rep.Resources.ronaldo.running)
        anim:Play()
        local dribbleClone = rep.Resources.RonaldoDribble:Clone()
        GroupWeld(char, dribbleClone)
        dribbleClone.Parent = workspace.Effects
        sfx(rep.Resources.ronaldo.RonaldoDribble, root)
        game.Debris:AddItem(dribbleClone, 5)
        local speedMultiplier = math.clamp(getgenv().DribbleSpeed or 1, 0.1, 3)
        task.spawn(function()
            task.delay(1.5, function() if not disabled then BodyVelocity(root, 40 * speedMultiplier, 1) end end)
            task.delay(1.8, function() if not disabled then BodyVelocity(root, 120 * speedMultiplier, 1.1) end end)
            task.delay(2.5, function() if not disabled then BodyVelocity(root, 90 * speedMultiplier, 0.75) end end)
            task.delay(2.9, function() if not disabled then BodyVelocity(root, 100 * speedMultiplier, 0.85) end end)
            task.delay(3.2, function() if not disabled then BodyVelocity(root, 175 * speedMultiplier, 1.7) end end)
            task.delay(3.9, function() if not disabled then BodyVelocity(root, 40 * speedMultiplier, 0.65) end end)
        end)
        task.spawn(function()
            local attach = dribbleClone.Rig.Head["1"]
            EmitAttachment(attach)
            ToggleAttachment(attach, true, 1)
        end)
        task.delay(2.5, function() if not disabled then EmitAttachment(dribbleClone.Rig.HumanoidRootPart["3"]) end end)
        task.delay(2.933, function() if not disabled then EmitAttachment(dribbleClone.Rig.HumanoidRootPart["4"]) end end)
        task.delay(3.2, function() if not disabled then EmitAttachment(dribbleClone.Rig.HumanoidRootPart["3.2"]) end end)
        task.delay(3.417, function() if not disabled then EmitAttachment(dribbleClone.Rig.HumanoidRootPart["3.5"]) end end)
        task.delay(3.933, function() if not disabled then EmitAttachment(dribbleClone.Rig.HumanoidRootPart["5"]) end end)

    elseif input.KeyCode == Enum.KeyCode.Two then
        if not hasball() then
            local stun = state and state:FindFirstChild("stun")
            if stun then stun.Value = true; task.wait(0.03); stun.Value = false end
            return
        end
        if char.state.stun.Value or plr.PlayerGui.Hotbar.Backpack.Hotbar.skill2.Cooldown.Visible then return end
        local bicycle1 = Instance.new("Animation")
        bicycle1.AnimationId = "rbxassetid://126734456236034"
        local bicycle = char.Humanoid:LoadAnimation(bicycle1)
        bicycle.Priority = Enum.AnimationPriority.Action2
        bicycle:Play()
        sfx(rep.Resources.ronaldo.KICK, char.HumanoidRootPart)
        task.delay(0.8, function()
            if disabled then return end
            local boom = rep.Resources.ronaldo.bicyclekick:Clone()
            boom.Parent = char.HumanoidRootPart
            boom.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
            for _, v in pairs(boom:GetDescendants()) do
                if v:IsA("ParticleEmitter") then v:Emit(v:GetAttribute("EmitCount")) end
            end
            game.Debris:AddItem(boom, 5)
        end)
        task.delay(0.9, function()
            if not char or not char:FindFirstChild("Ball") then return end
            local team = char.state.team.Value
            local oppositeTeam = team == "A" and "B" or "A"
            local goal = workspace.map and workspace.map:FindFirstChild(oppositeTeam .. "goal")
            local filterList = {char, workspace.Effects}
            if goal then table.insert(filterList, goal) end
            local originalCFrame = root.CFrame
            local lookVector = root.CFrame.LookVector
            char:PivotTo(CFrame.new((function()
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = filterList
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                local rayResult = workspace:Raycast(root.Position, lookVector * 1000, rayParams)
                return rayResult and rayResult.Position - lookVector * 2 or root.Position
            end)()))
            root.CFrame = root.CFrame * CFrame.Angles(0, math.pi, 0) * CFrame.new(0, 0, -8.823999)
            task.wait(0.2)
            remote:FireServer(buffer.fromstring(buffers["base"]), {{"kick", 100, false, root.CFrame.LookVector * 1e19}})
            task.wait(0.001)
            root.CFrame = originalCFrame
        end)
        StartCooldownUI(2, 8)

    elseif input.KeyCode == Enum.KeyCode.Three then
        local cooldownUI = plr.PlayerGui:FindFirstChild("Hotbar") and plr.PlayerGui.Hotbar:FindFirstChild("Backpack") and plr.PlayerGui.Hotbar.Backpack:FindFirstChild("Hotbar") and plr.PlayerGui.Hotbar.Backpack.Hotbar:FindFirstChild("skill3") and plr.PlayerGui.Hotbar.Backpack.Hotbar.skill3.Cooldown
        if cooldownUI and cooldownUI.Visible then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local stun = state and state:FindFirstChild("stun")
        if stun then stun.Value = true; task.wait(0.03); stun.Value = false end
        if not hasball() then return end
        local closestTeammate = nil
        local shortestDistance = 180
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p == plr or not p.Character or p.Team ~= plr.Team or p.Team == game.Teams.lobby then continue end
            local tr = p.Character:FindFirstChild("HumanoidRootPart")
            if not tr then continue end
            local d = (root.Position - tr.Position).Magnitude
            if d < shortestDistance then shortestDistance = d; closestTeammate = p end
        end
        if not closestTeammate then return end
        local targetRoot = closestTeammate.Character.HumanoidRootPart
        local distance = shortestDistance
        char.state.stun.Value = true
        char.Humanoid.WalkSpeed = 0
        local passAnim = Instance.new("Animation")
        passAnim.AnimationId = "rbxassetid://129737241094076"
        local track = char.Humanoid:LoadAnimation(passAnim)
        track.Priority = Enum.AnimationPriority.Action
        track:Play()
        sfx(rep.Resources.ronaldo.KICK, root)
        StartCooldownUI(3, 6)
        task.wait(0.35)
        if not char or not root.Parent then return end
        local direction = (targetRoot.Position - root.Position).Unit
        local kickDir = Vector3.new(direction.X, 0.18, direction.Z).Unit
        local power = math.clamp(distance / 1.4, 18, 95)
        remote:FireServer(buffer.fromstring(buffers["base"]), {{"kick", power, true, vector.create(kickDir.X, kickDir.Y, kickDir.Z)}})
        task.delay(0.7, function()
            if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = 40 end
            if char and char:FindFirstChild("state") then char.state.stun.Value = false end
        end)

    elseif input.KeyCode == Enum.KeyCode.Four then
        if hasball() then
            local stun = state and state:FindFirstChild("stun")
            if stun then stun.Value = true; task.wait(0.03); stun.Value = false end
            return
        end
        if tick() - lastAccelerate < accelerateCooldown then return end
        lastAccelerate = tick()
        local stun = state and state:FindFirstChild("stun")
        if stun then stun.Value = true; task.wait(0.03); stun.Value = false end
        StartCooldownUI(4, accelerateCooldown)
        local accelAnim = Instance.new("Animation")
        accelAnim.AnimationId = "rbxassetid://73266865968554"
        local track = char.Humanoid:LoadAnimation(accelAnim)
        track.Priority = Enum.AnimationPriority.Action
        track.TimePosition = 0
        track:Play()
        local accelSound = Instance.new("Sound")
        accelSound.SoundId = "rbxassetid://80157960628620"
        accelSound.Volume = 4
        accelSound.Parent = root
        accelSound:Play()
        game.Debris:AddItem(accelSound, 10)
        local effect1 = rep.Resources.nagi.newgroundcontroleffect["1"]:Clone()
        local effect2 = rep.Resources.nagi.newgroundcontroleffect["2"]:Clone()
        effect1.Parent = root; effect2.Parent = root
        effect1.CFrame = root.CFrame; effect2.CFrame = root.CFrame
        local allParticles = {}
        local colorToggle = true
        for _, obj in ipairs(effect1:GetDescendants()) do
            if obj:IsA("ParticleEmitter") then
                local cloned = obj:Clone()
                cloned.Color = ColorSequence.new(colorToggle and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0))
                cloned.Size = NumberSequence.new(obj.Size.Keypoints[1].Value * 1.5)
                cloned.Parent = root; cloned.Enabled = true
                table.insert(allParticles, cloned)
                colorToggle = not colorToggle
            end
        end
        for _, obj in ipairs(effect2:GetDescendants()) do
            if obj:IsA("ParticleEmitter") then
                local cloned = obj:Clone()
                cloned.Color = ColorSequence.new(colorToggle and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0))
                cloned.Size = NumberSequence.new(obj.Size.Keypoints[1].Value * 1.1)
                cloned.Parent = root; cloned.Enabled = true
                table.insert(allParticles, cloned)
                colorToggle = not colorToggle
            end
        end
        task.spawn(function()
            BodyVelocity(root, 120, 1, false, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
            task.delay(1, function() for _, p in allParticles do if p and p.Parent then p.Enabled = false end end end)
            task.delay(3, function() for _, p in allParticles do if p then p:Destroy() end end; if effect1 then effect1:Destroy() end; if effect2 then effect2:Destroy() end end)
        end)

    elseif input.KeyCode == Enum.KeyCode.Five then
        if not hasball() then return end
        if tick() - lastGOAT < goatCooldown then return end
        lastGOAT = tick()
        StartCooldownUI(5, goatCooldown)
        local humanoid = char.Humanoid
        local savedStyle = plr:GetAttribute("style")
        plr:SetAttribute("style", "ronaldo")
        char.state.stun.Value = true
        humanoid.WalkSpeed = 0
        root.Anchored = true
        root.CFrame = root.CFrame + Vector3.new(0, 30, 0)
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://117697415418770"
        local track = humanoid:LoadAnimation(anim)
        track.Priority = Enum.AnimationPriority.Action4
        track:Play()
        pcall(function() require(rep.client.replication).ronaldoIttooeasy(char) end)
        task.wait(18.2)
        root.CFrame = root.CFrame - Vector3.new(0, 30, 0)
        root.Anchored = false
        local goal = plr.Team.Name == "A" and workspace.map.Bgoal or workspace.map.Agoal
        local barriar = plr.Team.Name == "A" and workspace.map.gkbarriar.Bbarriar or workspace.map.gkbarriar.Abarriar
        if barriar then barriar.CanCollide = false end
        if goal then goal.CanCollide = false end
        if goal and hasball() then
            root.CFrame = goal.CFrame
            repeat task.wait() until (root.Position - goal.Position).Magnitude < 5
            task.wait(0.2)
            remote:FireServer(buffer.fromstring(buffers["base"]), {{"kick", 20, false, vector.create(0, 1, 0)}})
        end
        humanoid.WalkSpeed = 40
        char.state.stun.Value = false
        plr:SetAttribute("style", savedStyle)

    elseif input.KeyCode == Enum.KeyCode.G then
        if not hasball() then return end
        local savedStyle = plr:GetAttribute("style")
        plr:SetAttribute("style", "ronaldo")
        char.state.stun.Value = true
        task.spawn(function()
            pcall(function()
                require(rep.util.soundUtil):play(rep.Resources.ronaldo["0508"], SoundService)
                local sound = SoundService:WaitForChild("0508", 3)
                if sound then require(rep.client.replication).awkScreen(sound, Color3.fromRGB(255, 225, 150)) end
            end)
        end)
        task.spawn(function() pcall(function() require(rep.util.animationUtil):loadAnimation(char, rep.Resources.ronaldo.newawk):Play() end) end)
        task.spawn(function() pcall(function() require(rep.client.replication).ronaldoAwk(char) end) end)
        task.delay(5.333, function()
            plr:SetAttribute("style", savedStyle)
            char.state.stun.Value = false
        end)
    end
end)

local function load(char)
    if initialized then return end
    initialized = true
    repeat task.wait() until plr.Team ~= game.Teams.lobby
    task.wait(0.1)
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
end

load(plr.Character)
plr.CharacterAdded:Connect(function(char) task.wait(1); load(char) end)
print("Ronaldo Moveset loaded!")
