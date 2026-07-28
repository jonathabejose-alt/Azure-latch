local plr = game.Players.LocalPlayer
local cam = game.Workspace.CurrentCamera
local rep = game:GetService("ReplicatedStorage")
local remote = rep:WaitForChild("ByteNetReliable")
local kjFolder = rep.Resources.KJ
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local KJVFX = require(rep.client.replication.otherReplication.KJVFX)
local mainreplication = require(rep.client.replication.mainreplication)
local soundUtil = require(rep.util.soundUtil)

local stopped = false
local buffers = {}

if getgenv().HBM == nil then getgenv().HBM = false end
if type(getgenv().HBM) == "number" then
    getgenv().HBM = math.clamp(getgenv().HBM, 5, 80)
end

loadstring(game:HttpGet("https://pastebin.com/raw/8XJh7dzh"))()
repeat task.wait() until game.Lighting:FindFirstChild("BUFFERSTRINGS")
for _, val in ipairs(game.Lighting:FindFirstChild("BUFFERSTRINGS"):GetChildren()) do
    buffers[val.Name] = val.Value
end
game.Lighting:FindFirstChild("BUFFERSTRINGS"):Destroy()

local kjPreload = nil

for _, v in pairs(workspace:GetChildren()) do
    if v.Name == "KJ_Preload" then v:Destroy() end
end

local kj = kjFolder["Unlimited Flexworks"]
kj.Archivable = true
kjPreload = kj:Clone()
kjPreload.Name = "KJ_Preload"
kjPreload.Parent = workspace

for _, v in pairs(kjPreload:GetDescendants()) do
    if v:IsA("BasePart") then
        v.CFrame = CFrame.new(0, -500, 0)
        v.Anchored = true
    end
end


local function HasBall()
    return plr.Character and plr.Character:FindFirstChild("Ball")
end

local function Stunned()
    return plr.Character and plr.Character.state.stun.Value
end

local function CancelMove()
    local char = plr.Character
    if char and not char.state.stun.Value then
        char.state.stun.Value = true
        task.wait(0.04)
        char.state.stun.Value = false
    end
end

local function IsOnCD(name)
    local hotbar = plr.PlayerGui:FindFirstChild("Hotbar")
    if not hotbar then return false end
    local btn = hotbar.Backpack.Hotbar:FindFirstChild(name)
    if btn and btn:FindFirstChild("Cooldown") then
        return btn.Cooldown.Visible
    end
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
        task.delay(duration, function() btn.Cooldown.Visible = false end)
    end
end

local lastGoal = 0
local goalCooldown = 30

local function UnlimitedFlexworks()
    local char = plr.Character
    if not char or not HasBall() or IsOnCD("skill1") then return end
    if tick() - lastGoal < goalCooldown then return end

    CancelMove()
    lastGoal = tick()
    DoCD("skill1", goalCooldown)

    local humanoid = char.Humanoid
    local root = char.HumanoidRootPart
    local kj = kjFolder["Unlimited Flexworks"]

    local music = Instance.new("Sound")
    music.SoundId = "rbxassetid://114816321415107"
    music.Volume = 3.5
    music.MaxDistance = 10000
    music.MinDistance = 10
    music.Parent = root
    music:Play()
    Debris:AddItem(music, 30)

    plr:SetAttribute("style", "KJ")
    char.state.stun.Value = true
    humanoid.WalkSpeed = 0
    
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(0, 350000, 0)
    bv.Velocity = Vector3.new(0, 50, 0)
    bv.Parent = root

    pcall(function() humanoid:LoadAnimation(kj.Animation):Play() end)
    pcall(function() require(rep.client.replication).KJUnlimitedFlexworks(char) end)

    task.wait(29)
    bv:Destroy()
    
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(350000, 350000, 350000)
    bg.CFrame = root.CFrame
    bg.Parent = root

    local bvDown = Instance.new("BodyVelocity")
    bvDown.MaxForce = Vector3.new(0, 350000, 0)
    bvDown.Velocity = Vector3.new(0, -50, 0)
    bvDown.Parent = root
    
    task.wait(1)
    bvDown:Destroy()
    bg:Destroy()

    local goal = plr.Team.Name == "A" and workspace.map.Bgoal or workspace.map.Agoal
    if goal then
        root.CFrame = goal.CFrame * CFrame.new(0, 0, -3)
        task.wait(0.2)
        remote:FireServer(buffer.fromstring(buffers["base"]), {{"kick", 35, false, Vector3.new(0, 1, 0)}})
    end

    humanoid.WalkSpeed = 40
    char.state.stun.Value = false
end

local function Handball()
    local char = plr.Character
    if not char or Stunned() or not HasBall() or IsOnCD("skill2") then return end
    CancelMove()
    DoCD("skill2", 4)
    local humanoid = char.Humanoid
    local root = char.HumanoidRootPart
    pcall(function() soundUtil:play(kjFolder.Pass.sfx, root) end)
    local track = humanoid:LoadAnimation(kjFolder.Pass.Animation)
    track.Priority = Enum.AnimationPriority.Action4
    track:Play()
    task.delay(1, function() pcall(function() KJVFX.KJHandball(char) end) end)
    task.delay(0.3, function() remote:FireServer(buffer.fromstring(buffers["base"]), {{"skill2"}}) end)
end

local function Dropkick()
    local char = plr.Character
    if not char or Stunned() or not HasBall() or IsOnCD("skill3") then return end
    CancelMove()
    DoCD("skill3", 10)
    local humanoid = char.Humanoid
    local root = char.HumanoidRootPart
    char.state.stun.Value = true
    pcall(function() soundUtil:play(kjFolder["20-20-20 Dropkick"].DropkickUse, root) end)
    local track = humanoid:LoadAnimation(kjFolder["20-20-20 Dropkick"].Use)
    track.Priority = Enum.AnimationPriority.Action4
    track:Play()
    task.spawn(function() pcall(function() KJVFX.KJDropkick(char, char) end) end)
    task.delay(6.97, function() char.state.stun.Value = false end)
end

local function StoicBomb()
    local char = plr.Character
    if not char or Stunned() or IsOnCD("skill4") then return end
    if HasBall() then return end

    local ball = workspace.Terrain:FindFirstChild("Ball")
    if not ball then return end

    local root = char.HumanoidRootPart
    local dist = (root.Position - ball.Position).Magnitude
    if dist > 1050 then return end

    CancelMove()
    DoCD("skill4", 0.8)

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

    DoCD("skill4", 15)

    plr:SetAttribute("style", "KJ")
    char.state.stun.Value = true
    humanoid.WalkSpeed = 0
    root.Anchored = true

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://123647065656341"
    local track = humanoid:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    track:Play()

    pcall(function()
        require(rep.client.replication).KJStoicBomb(char)
    end)

    task.wait(3)

    pcall(function() track:Stop() end)
    root.Anchored = false
    humanoid.WalkSpeed = 40
    char.state.stun.Value = false
end

local kjAwkOnCD = false
local function KJFlow()
    local char = plr.Character
    if not char or Stunned() or kjAwkOnCD then return end
    if HasBall() then return end
    kjAwkOnCD = true
    char.state.stun.Value = true
    local humanoid = char.Humanoid
    local track = humanoid:LoadAnimation(kjFolder["Off Ball Flow"].User)
    track.Priority = Enum.AnimationPriority.Action4
    track:Play()
    task.spawn(function() pcall(function() KJVFX.KJOffBallAwk(char) end) end)
    task.delay(7.98, function()
        char.state.stun.Value = false
        task.delay(30, function() kjAwkOnCD = false end)
    end)
end

local function Setup(char)
    if stopped then return end
    repeat task.wait() until plr.Team ~= game.Teams.lobby
    task.wait(0.1)
    local hotbar = plr.PlayerGui:WaitForChild("Hotbar")
    local buttons = hotbar.Backpack.Hotbar
    buttons.skill1.Base.MouseButton1Down:Connect(UnlimitedFlexworks)
    buttons.skill2.Base.MouseButton1Down:Connect(Handball)
    buttons.skill3.Base.MouseButton1Down:Connect(Dropkick)
    buttons.skill4.Base.MouseButton1Down:Connect(StoicBomb)
    buttons.skill1.Base.ToolName.Text = "Unlimited Flexworks"
    buttons.skill2.Base.ToolName.Text = "Handball"
    buttons.skill3.Base.ToolName.Text = "20-20-20 Dropkick"
    buttons.skill4.Base.ToolName.Text = "Stoic Bomb"
    buttons.skill1.Base.Reuse.Text = "Ball"
    buttons.skill2.Base.Reuse.Text = "Ball"
    buttons.skill3.Base.Reuse.Text = "Ball"
    buttons.skill4.Base.Reuse.Text = "Off Ball"
    for i = 1, 4 do buttons["skill"..i].Base.Reuse.Visible = true end
    buttons.skill4.Visible = true
    buttons.skill5.Visible = false
    hotbar.MagicHealth.Awakening.Text = "20 Series"
    hotbar.MagicHealth.Health.Frame.UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(168, 0, 0))
    }
    char:GetAttributeChangedSignal("FlowActive"):Connect(function()
        if char:GetAttribute("FlowActive") == true and not stopped then
            char:SetAttribute("FlowActive", false)
        end
    end)
end

Setup(plr.Character)
plr.CharacterAdded:Connect(function(char)
    kjAwkOnCD = false
    lastGoal = 0
    task.wait(1)
    Setup(char)
end)

UserInputService.InputBegan:Connect(function(input, bg)
    if bg or stopped then return end
    if input.KeyCode == Enum.KeyCode.One then UnlimitedFlexworks()
    elseif input.KeyCode == Enum.KeyCode.Two then Handball()
    elseif input.KeyCode == Enum.KeyCode.Three then Dropkick()
    elseif input.KeyCode == Enum.KeyCode.Four then StoicBomb()
    elseif input.KeyCode == Enum.KeyCode.G then KJFlow()
    elseif input.KeyCode == Enum.KeyCode.F4 then stopped = true; print("stopped") end
end)

game.StarterGui:SetCore("SendNotification", {
    Title = "Moveset",
    Text = "KJ Moveset loaded!",
    Duration = 5,
    Button1 = "Ok",
})

print("KJ Moveset loaded!")
