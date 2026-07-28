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

print("KJ Preload creado")

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

    plr:SetAttribute("style", "KJ")
    char.state.stun.Value = true
    humanoid.HipHeight = 15
    humanoid.WalkSpeed = 0
    root.CFrame = CFrame.new(-573, 3, 950)
    root.Anchored = true

    pcall(function() humanoid:LoadAnimation(kj.Animation):Play() end)
    pcall(function() require(rep.client.replication).KJUnlimitedFlexworks(char) end)

    task.wait(29)

    local gui = Instance.new("ScreenGui", plr.PlayerGui)
    local flash = Instance.new("Frame", gui)
    flash.Size = UDim2.new(1, 0, 1, 0)
    flash.BackgroundColor3 = Color3.new(1, 1, 1)
    flash.BackgroundTransparency = 1
    TweenService:Create(flash, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
    task.delay(1.5, function() gui:Destroy() end)
    
    task.wait(1.2)
    root.Anchored = false
    
    task.wait(0.5)
    local goal = plr.Team.Name == "A" and workspace.map.Bgoal or workspace.map.Agoal
    if goal then
        root.CFrame = goal.CFrame
        task.wait(0.185)
        remote:FireServer(buffer.fromstring(buffers["base"]), {{"kick", 30, true, vector.create(0, 1, 0)}})
    end
    
    task.delay(0.35, function()
        humanoid.WalkSpeed = 40
        humanoid.HipHeight = 0
        char.state.stun.Value = false
    end)
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
    buttons.skill1.Base.ToolName.Text = "Unlimited Flexworks"
    buttons.skill2.Base.ToolName.Text = "Handball"
    buttons.skill3.Base.ToolName.Text = "20-20-20 Dropkick"
    buttons.skill1.Base.Reuse.Text = "Ball"
    buttons.skill2.Base.Reuse.Text = "Ball"
    buttons.skill3.Base.Reuse.Text = "Ball"
    for i = 1, 3 do buttons["skill"..i].Base.Reuse.Visible = true end
    buttons.skill4.Visible = false
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
