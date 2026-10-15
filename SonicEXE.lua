getgenv().HBM = 90

local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local plr = Players.LocalPlayer
local rep = game:GetService("ReplicatedStorage")
local other = rep.client.replication.otherReplication
local V2011 = require(other["2011xVFX"])
local VSONIC = require(other.sonicVFX)
local REPL = require(rep.client.replication)
local remote = rep:WaitForChild("ByteNetReliable")

local buffers = {}
loadstring(game:HttpGet("https://pastebin.com/raw/8XJh7dzh"))()
repeat task.wait() until game.Lighting:FindFirstChild("BUFFERSTRINGS")
for _, val in ipairs(game.Lighting:FindFirstChild("BUFFERSTRINGS"):GetChildren()) do
    buffers[val.Name] = val.Value
end
game.Lighting:FindFirstChild("BUFFERSTRINGS"):Destroy()

local SHOT_ANIM = "rbxassetid://99881509878056"
local SHOT_SOUND = "rbxassetid://126011406873336"

local stopped = false
local awkOnCD = false
local buttonConnections = {}
local awakenConnections = {}

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

local function GetBar()
	local gui = plr.PlayerGui:FindFirstChild("Hotbar")
	if not gui then return nil end
	local backpack = gui:FindFirstChild("Backpack")
	if not backpack then return nil end
	return backpack:FindFirstChild("Hotbar")
end

local function IsOnCD(name)
	local bar = GetBar()
	if not bar then return false end
	local btn = bar:FindFirstChild(name)
	if btn and btn:FindFirstChild("Cooldown") then return btn.Cooldown.Visible end
	return false
end

local function DoCD(name, duration)
	local bar = GetBar()
	if not bar then return end
	local btn = bar:FindFirstChild(name)
	if btn and btn:FindFirstChild("Cooldown") then
		btn.Cooldown.Visible = true
		btn.Cooldown.Size = UDim2.new(1, 0, -1, 0)
		TweenService:Create(btn.Cooldown, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
			Size = UDim2.new(1, 0, 0, 0),
		}):Play()
		task.delay(duration, function()
			if btn and btn.Cooldown then
				btn.Cooldown.Visible = false
			end
		end)
	end
end

local function SendKick(power, direction)
	remote:FireServer(buffer.fromstring(buffers["base"]))
end

local function SendGrab()
	remote:FireServer(buffer.fromstring(buffers["grabball"]))
end

local function StopTracks(humanoid)
	if not humanoid then return end
	for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
		track:Stop(0)
	end
end

local function PlayAnimation(humanoid, animationId, priority)
	local anim = Instance.new("Animation")
	anim.AnimationId = animationId
	local track = humanoid:LoadAnimation(anim)
	track.Priority = priority or Enum.AnimationPriority.Action
	track:Play()
	return track
end

local function PlaySound(root, soundId, volume, lifetime)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume
	sound.Parent = root
	sound:Play()
	Debris:AddItem(sound, lifetime)
	return sound
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
				char:SetAttribute("disableRotate", false)
			end
		end)
	end)
	Debris:AddItem(cfg, time)
end


local function BlockOriginalSkills()
	task.wait(0.1)
	local bar = GetBar()
	if not bar then return end
	for i = 1, 5 do
		local skill = bar:FindFirstChild("skill" .. i)
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

        task.wait(0.003)
        root.CFrame = originalCFrame
    end)
end

local function Shortcut()
	if stopped then return end
	local char = plr.Character
	if not char or Stunned() or IsOnCD("skill1") then return end

	CancelMove()
	DoCD("skill1", 1)

	local humanoid = char.Humanoid
	local root = char.HumanoidRootPart

	StopTracks(humanoid)
	local track = PlayAnimation(humanoid, "rbxassetid://116455589260954")

	pcall(function() REPL.DashSuper(char) end)
	PlaySound(root, "rbxassetid://111414558186727", 2, 3)

	Stun(0.3, false)

	task.delay(1.5, function()
		pcall(function() track:Stop() end)
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

local function Altisimus()
	if stopped then return end
	local char = plr.Character
	if not char or Stunned() or IsOnCD("skill4") then return end
	if not HasBall() then return end

	CancelMove()
	DoCD("skill4", 8)

	local humanoid = char.Humanoid
	local root = char.HumanoidRootPart

	StopTracks(humanoid)
	local track = PlayAnimation(humanoid, "rbxassetid://87372679250302")

	PlaySound(root, "rbxassetid://71942851306233", 1.5, 6)


	pcall(function() REPL.x2011_altisimus(char) end)
    

	TeleportShot(char, 1.2)
	Stun(2, false)

	task.delay(2, function()
		pcall(function() track:Stop() end)
	end)
end

local function Shot()
	if stopped then return end
	local char = plr.Character
	if not char or Stunned() or IsOnCD("skill5") then return end
	if not HasBall() then return end
    Stun(1.7, true)

	CancelMove()
	DoCD("skill5", 1)

	local humanoid = char.Humanoid
	local root = char.HumanoidRootPart
	if not humanoid or not root then return end

	Stun(0.7, true)
	PlaySound(root, SHOT_SOUND, 2, 4)
	pcall(function() VSONIC.sonic_whirlwind_shot(char, 6) end)
	TeleportShot(char, 1.2)

	local shotTrack = PlayAnimation(humanoid, SHOT_ANIM, Enum.AnimationPriority.Action4)
	task.delay(3, function()
		pcall(function() shotTrack:Stop() end)
	end)
end

local function ExeAwk()
	if stopped then return end
	local char = plr.Character
	if not char or Stunned() or awkOnCD then return end
	if not HasBall() then return end

	awkOnCD = true

	local humanoid = char.Humanoid

	Stun(21, true)
	plr:SetAttribute("style", "exe")

	TweenService:Create(humanoid, TweenInfo.new(0.3, Enum.EasingStyle.Cubic), {HipHeight = 25}):Play()

	task.spawn(function()
		pcall(function()
			local sound = Instance.new("Sound")
			sound.Name = "EXE_AwkSong"
			sound.SoundId = "rbxassetid://9281508259"
			sound.Volume = 10
			sound.Parent = SoundService
			sound.Looped = false
			sound:Play()
			task.delay(129, function()
				pcall(function() sound:Stop() end)
				pcall(function() sound:Destroy() end)
			end)
		end)
	end)

	task.spawn(function()
		pcall(function()
			local anim = Instance.new("Animation")
			anim.AnimationId = "rbxassetid://131202945094680"
			local track = humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(anim)
			track.Priority = Enum.AnimationPriority.Action4
			track:Play(0)
		end)
	end)


	task.spawn(function()
		pcall(function() REPL.exeAwk(char) end)
	end)

	task.delay(21, function()
		pcall(function()
			TweenService:Create(humanoid, TweenInfo.new(0.3, Enum.EasingStyle.Cubic), {HipHeight = 0}):Play()
		end)
		task.delay(30, function()
			awkOnCD = false
		end)
	end)
end

local function OffBallCombo()
	if stopped then return end
	local char = plr.Character
	if not char or Stunned() or awkOnCD then return end
	if HasBall() then return end

	awkOnCD = true

	local humanoid = char.Humanoid

	Stun(21, true)
	plr:SetAttribute("style", "exe")

	task.spawn(function()
		pcall(function()
			local sound = Instance.new("Sound")
			sound.Name = "2011x_OffBallSong"
			sound.SoundId = "rbxassetid://88429358187173"
			sound.Volume = 1
			sound.Parent = SoundService
			sound.Looped = false
			sound:Play()
			task.delay(129, function()
				pcall(function() sound:Stop() end)
				pcall(function() sound:Destroy() end)
			end)
		end)
	end)

	task.spawn(function()
		pcall(function()
			local anim = Instance.new("Animation")
			anim.AnimationId = "rbxassetid://91640149728350"
			local track = humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(anim)
			track.Priority = Enum.AnimationPriority.Action4
			track:Play(0)
		end)
	end)

	local animatedVictims = setmetatable({}, {__mode = "k"})
	local victimTracks = {}
	local connections = {}

	local function AnimateVictim(victimRig)
		if not victimRig then return end
		if animatedVictims[victimRig] then return end
		animatedVictims[victimRig] = true

		local animator
		local victimHum = victimRig:FindFirstChildOfClass("Humanoid")
		if victimHum then
			animator = victimHum:FindFirstChildOfClass("Animator")
			if not animator then
				animator = Instance.new("Animator")
				animator.Parent = victimHum
			end
		else
			local animCtrl = victimRig:FindFirstChildOfClass("AnimationController")
			if not animCtrl then return end
			animator = animCtrl:FindFirstChildOfClass("Animator")
			if not animator then
				animator = Instance.new("Animator")
				animator.Parent = animCtrl
			end
		end

		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://97339752363968"
		local track = animator:LoadAnimation(anim)
		track.Priority = Enum.AnimationPriority.Action4
		track:Play(0)
		victimTracks[track] = true
	end

	local function CheckForVictim(parent)
		if not parent or not parent.Parent then return end
		local victim = parent:FindFirstChild("Victim")
		if victim then
			AnimateVictim(victim)
		end
	end

	table.insert(connections, Workspace.ChildAdded:Connect(function(child)
		if child:IsA("Model") then
			task.spawn(function()
				task.wait(0.3)
				CheckForVictim(child)
			end)
		end
	end))

	local effects = workspace:FindFirstChild("Effects")
	if effects then
		table.insert(connections, effects.ChildAdded:Connect(function(child)
			if child:IsA("Model") then
				task.spawn(function()
					task.wait(0.3)
					CheckForVictim(child)
				end)
			end
		end))
	end

	task.spawn(function()
		for i = 1, 60 do
			task.wait(1)
			if stopped or plr.Character ~= char then break end
			for _, obj in ipairs(Workspace:GetDescendants()) do
				if obj:IsA("Model") and obj.Name == "Victim" then
					local hum = obj:FindFirstChildOfClass("Humanoid")
					if hum then
						AnimateVictim(obj)
					end
				end
			end
		end
	end)

	task.spawn(function()
		pcall(function() REPL.x2011_tartarus(char) end)
	end)

	task.spawn(function()
		pcall(function() REPL.evil_exeAwk(char) end)
	end)

	task.delay(21, function()
		for _, conn in ipairs(connections) do
			pcall(function() conn:Disconnect() end)
		end
		for track in pairs(victimTracks) do
			pcall(function() track:Stop() end)
			victimTracks[track] = nil
		end
		task.delay(30, function()
			awkOnCD = false
		end)
	end)
end

local function BindSkill(buttons, name, fn)
	local btn = buttons:FindFirstChild(name)
	local base = btn and btn:FindFirstChild("Base")
	if not base then return end
	local old = buttonConnections[name]
	if old then
		pcall(function() old:Disconnect() end)
	end
	buttonConnections[name] = base.MouseButton1Down:Connect(fn)
end

local function StopMoveset()
	stopped = true

	for name, conn in pairs(buttonConnections) do
		pcall(function() conn:Disconnect() end)
		buttonConnections[name] = nil
	end
	for _, conn in ipairs(awakenConnections) do
		pcall(function() conn:Disconnect() end)
	end
	awakenConnections = {}

	local bar = GetBar()
	if bar then
		for i = 1, 5 do
			local skill = bar:FindFirstChild("skill" .. i)
			if skill then
				skill.Visible = false
			end
		end
	end
end

local function Setup(char)
	if stopped then return end
	while not stopped and plr.Team == game.Teams.lobby do
		task.wait(0.5)
	end
	if stopped then return end
	task.wait(0.1)
	BlockOriginalSkills()

	plr:SetAttribute("style", "exe")

	local hotbar = plr.PlayerGui:WaitForChild("Hotbar", 30)
	if not hotbar or stopped then return end
	local backpack = hotbar:WaitForChild("Backpack", 30)
	if not backpack or stopped then return end
	local buttons = backpack:WaitForChild("Hotbar", 30)
	if not buttons or stopped then return end

	BindSkill(buttons, "skill1", Shortcut)
	BindSkill(buttons, "skill2", Exterminate)
	BindSkill(buttons, "skill3", EXEStrike)
	BindSkill(buttons, "skill4", Altisimus)
	BindSkill(buttons, "skill5", Shot)

	buttons.skill1.Base.Reuse.Text = "Ball"
	buttons.skill2.Base.Reuse.Text = "Off Ball"
	buttons.skill3.Base.Reuse.Text = "Ball"
	buttons.skill4.Base.Reuse.Text = "Ball"
	buttons.skill5.Base.Reuse.Text = "Ball"

	for i = 1, 5 do
		local skill = buttons:FindFirstChild("skill" .. i)
		local base = skill and skill:FindFirstChild("Base")
		if base then
			base.Reuse.Visible = true
		end
		if skill then
			skill.Visible = true
		end
	end

	pcall(function()
		local mh = hotbar:FindFirstChild("MagicHealth")
		local awaken = mh and mh:FindFirstChild("Awakening")
		if not awaken then return end
		local function onAwaken()
			if stopped then return end
			if HasBall() then
				ExeAwk()
			else
				OffBallCombo()
			end
		end
		table.insert(awakenConnections, awaken.TouchTap:Connect(onAwaken))
		table.insert(awakenConnections, awaken.MouseButton1Click:Connect(onAwaken))
	end)
end

Setup(plr.Character)

plr.CharacterAdded:Connect(function(char)
	awkOnCD = false
	task.wait(1)
	Setup(char)
end)

local brandedGui = nil

local function ApplyBranding()
	local hotbar = plr.PlayerGui:WaitForChild("Hotbar", 30)
	if not hotbar then return end
	local backpack = hotbar:WaitForChild("Backpack", 30)
	if not backpack then return end
	local bar = backpack:WaitForChild("Hotbar", 30)
	if not bar then return end

	local labels = {
		skill1 = "Shortcut",
		skill2 = "Exterminate",
		skill3 = "EXE Strike",
		skill4 = "Altisimus",
		skill5 = "whirlwind shot",
	}
	for slot, text in pairs(labels) do
		local btn = bar:FindFirstChild(slot)
		local toolName = btn and btn:FindFirstChild("Base") and btn.Base:FindFirstChild("ToolName")
		if toolName then toolName.Text = text end
	end

	local magic = hotbar:WaitForChild("MagicHealth", 30)
	if not magic then return end
	local awakening = magic:FindFirstChild("Awakening")
	if awakening then awakening.Text = "FLOW" end
	local textLabel = magic:FindFirstChild("TextLabel")
	if textLabel then textLabel.Text = "Many Souls To Play With." end

	if brandedGui ~= magic then
		local health = magic:FindFirstChild("Health")
		local frame = health and health:FindFirstChild("Frame")
		local gradient = frame and frame:FindFirstChildOfClass("UIGradient")
		if gradient then
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 0)),
})
		end
		brandedGui = magic
	end
end

task.spawn(function()
	while not stopped do
		pcall(ApplyBranding)
		if stopped then break end
		plr.CharacterAdded:Wait()
		task.wait(1)
	end
end)

UserInputService.InputBegan:Connect(function(input, bg)
	if bg or stopped then return end

	if input.KeyCode == Enum.KeyCode.G then
		if HasBall() then
			ExeAwk()
		else
			OffBallCombo()
		end
	elseif input.KeyCode == Enum.KeyCode.One then
		Shortcut()
	elseif input.KeyCode == Enum.KeyCode.Two then
		Exterminate()
	elseif input.KeyCode == Enum.KeyCode.Three then
		EXEStrike()
	elseif input.KeyCode == Enum.KeyCode.Four then
		Altisimus()
	elseif input.KeyCode == Enum.KeyCode.Five then
		Shot()
	elseif input.KeyCode == Enum.KeyCode.F5 then
		StopMoveset()
	end
end)

print("Sonic.exe Moveset loaded!")
