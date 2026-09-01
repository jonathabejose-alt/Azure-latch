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
local aizenAwkOnCD = false

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

local function TeleportShot(char, shootDelay)
    local root = char.HumanoidRootPart
    task.delay(shootDelay, function()
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Ball") then return end
        
        local function executeShot()
            if getgenv().SkillShoot then
                ShootSkill()
            else
                remote:FireServer(buffer.fromstring(buffers["base"]), {
                    {"kick", 100, false, root.CFrame.LookVector * 1e19}
                })
            end
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
        pcall(function()
            char:PivotTo(CFrame.new((function()
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = filterList
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                local rayResult = workspace:Raycast(root.Position, lookVector * 1000, rayParams)
                return rayResult and rayResult.Position - lookVector * 2 or root.Position
            end)()))
            root.CFrame = root.CFrame * CFrame.Angles(0, math.pi, 0) * CFrame.new(0, 0, -8.823999)
        end)
        task.wait(0.2)
        
        executeShot()
        
        task.wait(0.001)
        root.CFrame = originalCFrame
    end)
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

local function GoryuVolley()
    local char = plr.Character
    if not char or Stunned() or IsOnCD("skill1") then return end
    if not HasBall() then return end

    CancelMove()
    DoCD("skill1", 8)

    local humanoid = char.Humanoid

    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do track:Stop(0) end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://127065716648860"
    local track = humanoid:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action
    track:Play()

    pcall(function()
        require(rep.client.replication).aizen_goryu_volley_windup(char)
    end)

    Stun(1.5, true)

    TeleportShot(char, 0.3)

    task.delay(1.5, function()
        pcall(function()
            track:Stop()
        end)
    end)
end

local function GoryuOnBall()
    local char = plr.Character
    if not char or Stunned() or IsOnCD("skill2") then return end
    if not HasBall() then return end

    CancelMove()
    DoCD("skill2", 6)

    pcall(function()
        require(rep.client.replication).aizen_goryu_onball(char)
    end)

    Stun(1, true)

    TeleportShot(char, 0.4)

    task.delay(1, function()
        if char and char.state then
            char.state.stun.Value = false
        end
    end)
end

local function GoryuFeint()
    local char = plr.Character
    if not char or Stunned() or IsOnCD("skill3") then return end
    if not HasBall() then return end

    CancelMove()
    DoCD("skill3", 4)

    pcall(function()
        require(rep.client.replication).aizen_goryu_feint(char)
    end)

    Stun(1.5, true)

    TeleportShot(char, 1.1)

    task.delay(1.5, function()
        if char and char.state then
            char.state.stun.Value = false
        end
    end)
end

local function ShatterSecond()
    local char = plr.Character
    if not char or Stunned() or IsOnCD("skill4") then return end

    CancelMove()
    DoCD("skill4", 10)

    pcall(function()
        require(rep.client.replication).aizen_shatter_second(char)
    end)
end

local function AizenAwaken()
    local char = plr.Character
    if not char or Stunned() or aizenAwkOnCD then return end
    if not HasBall() then return end

    aizenAwkOnCD = true

    local humanoid = char.Humanoid
    local savedStyle = plr:GetAttribute("style")

    Stun(21, true)
    plr:SetAttribute("style", "aizen")

    TweenService:Create(humanoid, TweenInfo.new(0.5, Enum.EasingStyle.Cubic), {HipHeight = 25}):Play()

    task.delay(0.5, function()
        task.spawn(function()
            pcall(function()
                local song = Instance.new("Sound")
                song.SoundId = "rbxassetid://112192271447858"
                song.Volume = 12
                song.Parent = SoundService
                song:Play()
                Debris:AddItem(song, 120)
            end)
        end)

        task.spawn(function()
            pcall(function()
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://110777328331339"
                local track = humanoid:LoadAnimation(anim)
                track.Priority = Enum.AnimationPriority.Action
                track:Play()
                task.delay(21, function()
                    pcall(function() track:Stop() end)
                end)
            end)
        end)

        task.spawn(function()
            pcall(function()
                require(rep.client.replication).aizen_awaken(char)
            end)
        end)
    end)

    task.delay(21, function()
        if not char or not char.Parent then return end
        
        TweenService:Create(humanoid, TweenInfo.new(0.3, Enum.EasingStyle.Cubic), {HipHeight = 0}):Play()
        plr:SetAttribute("style", savedStyle)
        
        task.delay(30, function()
            aizenAwkOnCD = false
        end)
    end)
end

local function StopMoveset()
    stopped = true
    
    pcall(function()
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
    end)
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

    buttons.skill1.Base.MouseButton1Down:Connect(GoryuVolley)
    buttons.skill2.Base.MouseButton1Down:Connect(GoryuOnBall)
    buttons.skill3.Base.MouseButton1Down:Connect(GoryuFeint)
    buttons.skill4.Base.MouseButton1Down:Connect(ShatterSecond)

    buttons.skill1.Base.Reuse.Text = "Ball"
    buttons.skill2.Base.Reuse.Text = "Ball"
    buttons.skill3.Base.Reuse.Text = "Ball"
    buttons.skill4.Base.Reuse.Text = "Any"

    for i = 1, 4 do 
        buttons["skill"..i].Base.Reuse.Visible = true
        buttons["skill"..i].Visible = true
    end

    pcall(function()
        local mh = hotbar:FindFirstChild("MagicHealth")
        if mh and mh:FindFirstChild("Awakening") then
            mh.Awakening.TouchTap:Connect(AizenAwaken)
            mh.Awakening.MouseButton1Click:Connect(AizenAwaken)
        end
    end)
end

Setup(plr.Character)

plr.CharacterAdded:Connect(function(char)
    aizenAwkOnCD = false
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
                hotbar.Backpack.Hotbar.skill1.Base.ToolName.Text = "Goryu Volley"
                hotbar.Backpack.Hotbar.skill2.Base.ToolName.Text = "Goryu On-Ball"
                hotbar.Backpack.Hotbar.skill3.Base.ToolName.Text = "Goryu Feint"
                hotbar.Backpack.Hotbar.skill4.Base.ToolName.Text = "Shatter Second"

                hotbar.MagicHealth.Awakening.Text = "AWAKEN"
                hotbar.MagicHealth.TextLabel.Text = "Welcome to my Soul Society."
                hotbar.MagicHealth.Health.Frame.UIGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 100, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 200))
                }
            end
        end
        task.wait(0.1)
    end
end)

UserInputService.InputBegan:Connect(function(input, bg)
    if bg or stopped then return end

    if input.KeyCode == Enum.KeyCode.G then
        AizenAwaken()
    elseif input.KeyCode == Enum.KeyCode.One then
        GoryuVolley()
    elseif input.KeyCode == Enum.KeyCode.Two then
        GoryuOnBall()
    elseif input.KeyCode == Enum.KeyCode.Three then
        GoryuFeint()
    elseif input.KeyCode == Enum.KeyCode.Four then
        ShatterSecond()
    elseif input.KeyCode == Enum.KeyCode.F5 then
        StopMoveset()
    end
end)

print("Aizen Moveset loaded!")
