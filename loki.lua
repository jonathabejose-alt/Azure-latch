local plr = game.Players.LocalPlayer
local cam = game.Workspace.CurrentCamera

local stopped = false
local buffers = {}

loadstring(game:HttpGet("https://pastebin.com/raw/8XJh7dzh"))()
repeat task.wait() until game.Lighting:FindFirstChild("BUFFERSTRINGS")
for _, val in ipairs(game.Lighting:FindFirstChild("BUFFERSTRINGS"):GetChildren()) do
    buffers[val.Name] = val.Value
end
game.Lighting:FindFirstChild("BUFFERSTRINGS"):Destroy()

local link = "https://files.catbox.moe/u1yzdo.mp3"
local filename = "lokiTheme.mp3"

local data = game:HttpGet(link, true)
writefile(filename, data)

local getasset = getcustomasset or getsynasset
if not getasset then
    error("executor missing getcustomasset/getsynasset")
end

game:GetService("ReplicatedStorage").Resources.isagi.theme.SoundId = getasset(filename)
game:GetService("ReplicatedStorage").Resources.isagi["isagi themeover"].SoundId = getasset(filename)
game:GetService("ReplicatedStorage").Resources.isagi["direct shot"].SoundId = "rbxassetid://118471535207840"

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local replication = require(ReplicatedStorage.client.replication)

local function CancelMove()
    local charg = plr.Character
    if charg and charg.state and charg.state.stun.Value == false then
        charg.state.stun.Value = true
        task.wait(0.04)
        charg.state.stun.Value = false
    end
end

local function HasBall()
    return plr.Character and plr.Character:FindFirstChild("Ball")
end

local function Stunned()
    return plr.Character and plr.Character.state and plr.Character.state.stun.Value
end

local function IsMoveOnCD(name)
    local hotbar = plr.PlayerGui and plr.PlayerGui:FindFirstChild("Hotbar")
    if hotbar and hotbar.Backpack and hotbar.Backpack.Hotbar:FindFirstChild(name) then
        local button = hotbar.Backpack.Hotbar:FindFirstChild(name)
        if button and button.Cooldown and button.Cooldown.Visible == true then
            return true
        end
    end
    return false
end

local function DoCDVisual(len, name)
    local hotbar = plr.PlayerGui and plr.PlayerGui:FindFirstChild("Hotbar")
    if hotbar and hotbar.Backpack and hotbar.Backpack.Hotbar:FindFirstChild(name) then
        local button = hotbar.Backpack.Hotbar:FindFirstChild(name)
        if button and button.Cooldown then
            button.Cooldown.Visible = true
            button.Cooldown.Size = UDim2.new(1, 0, -1, 0)
            TweenService:Create(button.Cooldown, TweenInfo.new(len, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 0, 0)}):Play()
            task.delay(len, function()
                if button and button.Cooldown then
                    button.Cooldown.Visible = false
                end
            end)
        end
    end
end

local remote = ReplicatedStorage:WaitForChild("ByteNetReliable")

local function TeleportShot(char, shootDelay)
    local root = char.HumanoidRootPart
    task.delay(shootDelay, function()
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Ball") then return end
        
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
        
        remote:FireServer(buffer.fromstring(buffers["base"]), {
            {"kick", 100, false, root.CFrame.LookVector * 1e19}
        })
        
        task.wait(0.001)
        root.CFrame = originalCFrame
    end)
end

local function Skill1(char)
    if IsMoveOnCD("skill1") then CancelMove() return end
    if not HasBall() then return CancelMove() end
    
    CancelMove()
    DoCDVisual(8, "skill1")
    
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://97586424269981"
    local humanoid = char:WaitForChild("Humanoid")
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    track:Play()
    
    replication.LokiKick(char)
    
    TeleportShot(char, 0.4)
end

local function Skill2(char)
    if IsMoveOnCD("skill2") then CancelMove() return end
    if HasBall() then return CancelMove() end
    if Stunned() then return end
    
    local ball = Workspace.Terrain:FindFirstChild("Ball")
    if not ball then return end
    
    CancelMove()
    DoCDVisual(10, "skill2")
    
    local root = char:WaitForChild("HumanoidRootPart")
    
    local grabbed = false
    local timeout = 0
    
    while not grabbed and timeout < 60 do
        local currentBall = Workspace.Terrain:FindFirstChild("Ball")
        if not currentBall then
            return
        end
        
        local targetPos = currentBall.Position + Vector3.new(0, 2, 0)
        root.CFrame = CFrame.new(targetPos, targetPos + Vector3.new(0, 0, -1))
        root.AssemblyLinearVelocity = Vector3.zero
        
        task.wait(0.05)
        remote:FireServer(buffer.fromstring(buffers["grabball"]))
        task.wait(0.05)
        
        if HasBall() then
            grabbed = true
            break
        end
        
        timeout = timeout + 1
    end
    
    if not grabbed then
        return
    end
    
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://82371642989185"
    local humanoid = char:WaitForChild("Humanoid")
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    track:Play()
    
    replication.lokicatch(char)
end

local Skill3Active = false

local function Skill3(char)
    if stopped or Skill3Active or IsMoveOnCD("skill3") or Stunned() then return end
    
    CancelMove()
    DoCDVisual(0.1, "skill3")
    Skill3Active = true
    
    replication.LokiDashSuper(char)
    
    Skill3Active = false
end

local function Skill4(char)
    if IsMoveOnCD("skill4") then CancelMove() return end
    if not HasBall() then return CancelMove() end
    if Stunned() then return end
    
    CancelMove()
    DoCDVisual(15, "skill4")
    
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://115839777221212"
    local humanoid = char:WaitForChild("Humanoid")
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    track:Play()
    
    replication.LokiKick(char)
    
    TeleportShot(char, 0.4)
end

local function Skill5(char)
    if IsMoveOnCD("skill5") then CancelMove() return end
    if HasBall() then return CancelMove() end
    if Stunned() then return end
    
    local ball = Workspace.Terrain:FindFirstChild("Ball")
    if not ball then return end
    
    CancelMove()
    DoCDVisual(12, "skill5")
    
    local root = char:WaitForChild("HumanoidRootPart")
    
    local grabbed = false
    local timeout = 0
    
    while not grabbed and timeout < 60 do
        local currentBall = Workspace.Terrain:FindFirstChild("Ball")
        if not currentBall then
            return
        end
        
        local targetPos = currentBall.Position + Vector3.new(0, 2, 0)
        root.CFrame = CFrame.new(targetPos, targetPos + Vector3.new(0, 0, -1))
        root.AssemblyLinearVelocity = Vector3.zero
        
        task.wait(0.05)
        remote:FireServer(buffer.fromstring(buffers["grabball"]))
        task.wait(0.05)
        
        if HasBall() then
            grabbed = true
            break
        end
        
        timeout = timeout + 1
    end
    
    if not grabbed then
        return
    end
    
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://82240286756891"
    local humanoid = char:WaitForChild("Humanoid")
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    track:Play()
    
    replication.lokicatch(char)
end

local lokiFlowOnCD = false

local function LokiFlow(char)
    if Stunned() or lokiFlowOnCD then return end
    if HasBall() then return end
    
    lokiFlowOnCD = true
    
    replication.LokiFlow(char)
    
    remote:FireServer(buffer.fromstring(buffers["base"]), { { "tackle" } })
    
    task.delay(30, function()
        lokiFlowOnCD = false
    end)
end

local function SetUp(char)
    if stopped then return end
    repeat task.wait() until plr.Team ~= game.Teams.lobby
    task.wait(0.1)
    
    local hotbar = plr.PlayerGui.Hotbar
    hotbar.Backpack.Hotbar.skill1.Base.MouseButton1Down:Connect(function()
        Skill1(plr.Character)
    end)
    hotbar.Backpack.Hotbar.skill2.Base.MouseButton1Down:Connect(function()
        Skill2(plr.Character)
    end)
    hotbar.Backpack.Hotbar.skill3.Base.MouseButton1Down:Connect(function()
        Skill3(plr.Character)
    end)
    hotbar.Backpack.Hotbar.skill4.Base.MouseButton1Down:Connect(function()
        Skill4(plr.Character)
    end)
    hotbar.Backpack.Hotbar.skill5.Base.MouseButton1Down:Connect(function()
        Skill5(plr.Character)
    end)
    
    hotbar.Backpack.Hotbar.skill1.Base.Reuse.Text = "Ball"
    hotbar.Backpack.Hotbar.skill2.Base.Reuse.Visible = true
    hotbar.Backpack.Hotbar.skill2.Base.Reuse.Text = "Trap"
    hotbar.Backpack.Hotbar.skill3.Base.Reuse.Text = "Movement"
    hotbar.Backpack.Hotbar.skill4.Base.Reuse.Text = "Ball"
    hotbar.Backpack.Hotbar.skill5.Base.Reuse.Text = "Trap"
    
    hotbar.Backpack.Hotbar.skill4.Visible = true
    hotbar.Backpack.Hotbar.skill5.Visible = true
    
    for i = 1, 5 do
        hotbar.Backpack.Hotbar["skill"..i].Base.Reuse.Visible = true
    end
    
    hotbar.Backpack.Hotbar.skill1.Base.ToolName.Text = "Holding Back"
    hotbar.Backpack.Hotbar.skill2.Base.ToolName.Text = "Too Slow"
    hotbar.Backpack.Hotbar.skill3.Base.ToolName.Text = "Lightspeed Dash"
    hotbar.Backpack.Hotbar.skill4.Base.ToolName.Text = "Lightspeed Kick"
    hotbar.Backpack.Hotbar.skill5.Base.ToolName.Text = "Is this Okay?"
    
    hotbar.MagicHealth.Awakening.Text = "God of Mischief"
    hotbar.MagicHealth.TextLabel.Visible = true
    hotbar.MagicHealth.TextLabel.Text = "Loki"
    hotbar.MagicHealth.Health.Frame.UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(123, 50, 168))
    }
    
    plr.Character:GetAttributeChangedSignal("FlowActive"):Connect(function()
        if plr.Character:GetAttribute("FlowActive") == true then
            if stopped then return end
            LokiFlow(char)
            plr.Character:SetAttribute("FlowActive", false)
        end
    end)
end

SetUp(plr.Character)

plr.CharacterAdded:Connect(function(char)
    if stopped then return end
    task.wait(1)
    SetUp(char)
end)

local soundReplacementActive = true
local shot = "rbxassetid://118471535207840"
local isag = {
    ["rbxassetid://114952862979282"] = true
}

local function replaceSound(sound)
    if not sound:IsA("Sound") then return end
    if not soundReplacementActive then return end
    if isag[sound.SoundId] then
        sound:Stop()
        sound.SoundId = shot
        sound:Play()
    end
end

for _, sound in ipairs(Workspace:GetDescendants()) do
    replaceSound(sound)
end

local connection
connection = Workspace.DescendantAdded:Connect(replaceSound)

UserInputService.InputBegan:Connect(function(input, bg)
    if bg or stopped then return end
    
    if input.KeyCode == Enum.KeyCode.One then
        Skill1(plr.Character)
    elseif input.KeyCode == Enum.KeyCode.Two then
        Skill2(plr.Character)
    elseif input.KeyCode == Enum.KeyCode.Three then
        Skill3(plr.Character)
    elseif input.KeyCode == Enum.KeyCode.Four then
        Skill4(plr.Character)
    elseif input.KeyCode == Enum.KeyCode.Five then
        Skill5(plr.Character)
    elseif input.KeyCode == Enum.KeyCode.G then
        LokiFlow(plr.Character)
    elseif input.KeyCode == Enum.KeyCode.F4 then
        stopped = true
        Skill3Active = false
        soundReplacementActive = false
        if connection then
            connection:Disconnect()
        end
        print("Loki Moveset stopped")
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Three then
        Skill3Active = false
    end
end)

game.StarterGui:SetCore("SendNotification", {
    Title = "Loki Moveset",
    Text = "Loki Moveset loaded!",
    Duration = 5,
    Button1 = "Ok",
})

print("Loki Moveset loaded!")
