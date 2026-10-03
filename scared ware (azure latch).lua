if getgenv().ScaredWare and getgenv().ScaredWare.Unload then
    getgenv().ScaredWare:Unload()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

local BNR = ReplicatedStorage:WaitForChild("ByteNetReliable")

local buffers = {}
loadstring(game:HttpGet("https://pastebin.com/raw/8XJh7dzh"))()
repeat task.wait() until Lighting:FindFirstChild("BUFFERSTRINGS")
for _, val in ipairs(Lighting:FindFirstChild("BUFFERSTRINGS"):GetChildren()) do
    buffers[val.Name] = val.Value
end
Lighting:FindFirstChild("BUFFERSTRINGS"):Destroy()

local vector = {
    create = function(x, y, z)
        return Vector3.new(x, y, z)
    end
}

local role = ReplicatedStorage:WaitForChild("BytenetStorage"):WaitForChild("Networking").Value:match('"bytenet_selectRole"%s*:%s*(%d+)')
role = role and tonumber(role)
local pick = string.char(role)

local VindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Skinny-yz/VVind-UI/refs/heads/main/src.lua"))()
VindUI:PreloadIcons({ "Lucide", "Material", "Phosphor", "SF" })
VindUI:SetScaleRange(0.75, 1.35)

local TOGGLE_KEY = Enum.KeyCode.RightAlt

local Window = VindUI:CreateWindow({
    Title = "Scared Ware UI",
    Subtitle = "Azure Latch - v0.1",
    Icon = "Lucide:ghost",
    Size = UDim2.fromOffset(660, 480),
    MinSize = Vector2.new(500, 360),
    Draggable = true,
    Resizable = true,
    UseBlur = true,
    DefaultTab = "Combat",
})

VindUI:Notify({
    Title = "Scared Ware UI",
    Text = "v0.1 Loaded",
    Type = "success",
    Duration = 4,
})

local CombatTab = Window:AddTab({ Name = "Combat", Icon = "Lucide:swords" })
local FeaturesTab = Window:AddTab({ Name = "Features", Icon = "Lucide:zap" })
local MiscTab = Window:AddTab({ Name = "Misc", Icon = "Lucide:puzzle" })
local HomeTab = Window:AddTab({ Name = "Home", Icon = "Lucide:layout-dashboard" })
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "Lucide:settings" })

local MainSub = CombatTab:AddSubTab({ Name = "Distance Buffs", Icon = "Lucide:move-3d" })
local LineUpsSub = CombatTab:AddSubTab({ Name = "Line Ups", Icon = "Lucide:target" })
local MovesetsSub = CombatTab:AddSubTab({ Name = "Movesets", Icon = "Lucide:wand-sparkles" })

MainSub:AddSection("Universal Movement Buffs", "Lucide:move-3d")

local DashConfigs = {
    Tackle = { animId = "rbxassetid://109744655458082", sliderVar = "tackleDist", duration = 0.4, cooldown = 0.15, wait = 0 },
    Rush = { animId = "rbxassetid://79394729551302", sliderVar = "rushDist", duration = 0.4, cooldown = 0.15, wait = 0.15 },
    GKDash = { animId = "rbxassetid://90537955276413", sliderVar = "gkDist", duration = 0.55, cooldown = 0.15, wait = 0.05 },
    Naruhaya = { animId = "rbxassetid://82240286756891", sliderVar = "naruhayaDist", duration = 0.45, cooldown = 0.15, wait = 0.33 },
    Raumdeuter = { animIds = {["rbxassetid://81582265162782"] = true}, sliderVar = "raumDist", duration = 0.55, cooldown = 0.15, wait = 0.1 },
    DraconicRush = { animId = "rbxassetid://95359966795185", sliderVar = "dracDist", duration = 0.625, cooldown = 0.15, wait = 0.175 },
    StepOvers = { animId = "rbxassetid://84063609284472", sliderVar = "stepDist", duration = 0.15, cooldown = 0.15, wait = 1.275 },
    KaiserOffBall = { animId = "rbxassetid://110660551661470", sliderVar = "kaiserDist", duration = 0.55, cooldown = 0.15, wait = 0.15 },
    OcclusionBreak = { animId = "rbxassetid://116181317759538", sliderVar = "occlusionDist", duration = 1.0, cooldown = 0.15, wait = 0.2 },
    DivingHeader = { animId = "rbxassetid://91506202951715", sliderVar = "divingDist", duration = 0.35, cooldown = 0.15, wait = 0.05 },
    ReflexTackle = { animId = "rbxassetid://113088324958896", sliderVar = "reflexDist", duration = 0.2, cooldown = 0.15, wait = 0 },
    RazorBreak = {
        animIds = {
            ["rbxassetid://131681055843039"] = "Front",
            ["rbxassetid://114963791456755"] = "Left",
            ["rbxassetid://115966658644919"] = "Right",
            ["rbxassetid://122404546980503"] = "Back",
            ["rbxassetid://70754845580062"] = "RightBack",
            ["rbxassetid://128061536134952"] = "LeftBack",
            ["rbxassetid://71501932579824"] = "FrontRight",
            ["rbxassetid://96632954418440"] = "FrontLeft",
            ["rbxassetid://70397727954557"] = "Front",
            ["rbxassetid://131196726012273"] = "Front"
        },
        sliderVar = "razorDist", duration = 0.35, cooldown = 0.15, wait = 0.1, isDirectional = true
    },
    CutIn = { animIds = {["rbxassetid://71217538180364"] = true, ["rbxassetid://87853371514282"] = true}, sliderVar = "dragDist", duration = 1.0, cooldown = 0.15, wait = 0.2 },
    HeroInstinct = { animId = "rbxassetid://82417661349987", sliderVar = "instinctDist", duration = 1.25, cooldown = 0.15, wait = 0.33 },
    CloseQuarterDribble = { animId = "rbxassetid://94171465685487", sliderVar = "quarterDist", duration = 2.25, cooldown = 0.15, wait = 0.18 },
    SpeedyTurn = { animId = "rbxassetid://109145068926350", sliderVar = "speedyDist", duration = 0.7, cooldown = 0.15, wait = 0.05 },
    Fetch = { animId = "rbxassetid://110734304480469", sliderVar = "fetchDist", duration = 0.525, cooldown = 0.15, wait = 0.125 },
    GoGo = { animId = "rbxassetid://111297568709238", sliderVar = "gogoDist", duration = 0.35, cooldown = 0.15, wait = 0.55 },
    GuardDog = { animId = "rbxassetid://111439544531399", sliderVar = "guardDist", duration = 0.35, cooldown = 0.15, wait = 0.1 },
    ZombieDribble = { animId = "rbxassetid://102294508090597", sliderVar = "zombDist", duration = 1.7, cooldown = 0.15, wait = 0.15 },
    Creative = { animId = "rbxassetid://77926234700416", sliderVar = "creativeDist", duration = 0.2, cooldown = 0.15, wait = 0.85 },
    GlacialCut = { animId = "rbxassetid://116769918041530", sliderVar = "glacialDist", duration = 0.5, cooldown = 0.15, wait = 0.425 },
    Beautiful = { animIds = {["rbxassetid://132788854309681"] = true, ["rbxassetid://138985718053619"] = true}, sliderVar = "beautifulDist", duration = 0.3, cooldown = 0.15, wait = 0 },
    ControlVar = { animId = "rbxassetid://77370115011368", sliderVar = "controlVarDist", duration = 0.3, cooldown = 0.15, wait = 0.1 },
    Corvine = { animId = "rbxassetid://79459013513539", sliderVar = "corvineDist", duration = 0.4, cooldown = 0.15, wait = 1.1 },
    Kusarigama = { animId = "rbxassetid://84772583028665", sliderVar = "kusarDist", duration = 0.55, cooldown = 0.15, wait = 0 },
    ShadowStep = { animIds = {["rbxassetid://133810381664491"] = true, ["rbxassetid://139230259021390"] = true}, sliderVar = "shadowDist", duration = 0.3, cooldown = 0.15, wait = 0 },
    SilentSteal = { animId = "rbxassetid://89782964116671", sliderVar = "silentDist", duration = 0.55, cooldown = 0.15, wait = 0.1 },
    NutmegReflex = { animId = "rbxassetid://73266865968554", sliderVar = "reflexNutmegDist", duration = 0.25, cooldown = 0.15, wait = 0.05 },
    TwinSteps = { animId = "rbxassetid://106299517516303", sliderVar = "twinStepsDist", duration = 0.15, cooldown = 0.15, wait = 1.75 },
    KingsPath = { animId = "rbxassetid://73560885704292", sliderVar = "kingsDist", duration = 1.175, cooldown = 0.15, wait = 0.4 },
    MachCutIn = { animIds = {["rbxassetid://133945265328817"] = true, ["rbxassetid://88448030655006"] = true}, sliderVar = "machDist", duration = 0.15, cooldown = 0.15, wait = 0.625 },
    GoldenZone = { animId = "rbxassetid://132426354821688", sliderVar = "goldenDist", duration = 2.0, cooldown = 0.15, requiresBall = true, wait = 0.15 },
    Devour = { animId = "rbxassetid://117921992582675", sliderVar = "devourMaxDist", speed = 150, cooldown = 0.15, isUnlimited = true, wait = 0.2 }
}

local Distances = {}
for _, cfg in pairs(DashConfigs) do
    Distances[cfg.sliderVar] = 0
end

local ActiveDashes = {}
local cachedHRP = nil
local renderConn = nil
local ZERO = Vector3.new()
local DEFAULT_DIR = Vector3.new(0,0,1)

local DirectionOffsets = {
    Front = Vector3.new(0, 0, 1),
    Back = Vector3.new(0, 0, -1),
    Left = Vector3.new(-1, 0, 0),
    Right = Vector3.new(1, 0, 0),
    FrontLeft = Vector3.new(-1, 0, 1).Unit,
    FrontRight = Vector3.new(1, 0, 1).Unit,
    LeftBack = Vector3.new(-1, 0, -1).Unit,
    RightBack = Vector3.new(1, 0, -1).Unit,
}

local function updateDashes(dt)
    for i = #ActiveDashes, 1, -1 do
        local dash = ActiveDashes[i]
        local hrp = dash.hrp
        if not hrp or not hrp.Parent then
            table.remove(ActiveDashes, i)
        else
            local step = dash.cfg.isUnlimited and (dash.speed * dt) or math.min(dash.speed * dt, dash.remaining)
            local moveDir

            if dash.isDirectional then
                local baseLook = hrp.CFrame.LookVector
                local right = baseLook:Cross(Vector3.new(0,1,0))
                local offset = dash.offset
                moveDir = (right * -offset.X + baseLook * offset.Z).Unit
            else
                local look = hrp.CFrame.LookVector
                moveDir = Vector3.new(look.X, 0, look.Z).Unit
                if moveDir.Magnitude < 0.01 then moveDir = DEFAULT_DIR end
            end

            local newPos = hrp.Position + moveDir * step
            hrp.CFrame = CFrame.new(newPos.X, hrp.Position.Y, newPos.Z) * CFrame.new(ZERO, moveDir)

            dash.remaining = dash.remaining - step
            if dash.remaining <= 0 then table.remove(ActiveDashes, i) end
        end
    end
    if #ActiveDashes == 0 and renderConn then
        renderConn:Disconnect()
        renderConn = nil
    end
end

local function startUpdateIfNeeded()
    if not renderConn and #ActiveDashes > 0 then
        renderConn = RunService.RenderStepped:Connect(updateDashes)
    end
end

local function startDash(hrp, cfg, track, directionName)
    local dist = Distances[cfg.sliderVar]
    if dist <= 0 then return end

    task.delay(cfg.wait or 0, function()
        if not hrp or not hrp.Parent then return end

        local dash = { hrp = hrp, remaining = dist, cfg = cfg, isDirectional = cfg.isDirectional == true }

        if dash.isDirectional and directionName then
            dash.offset = DirectionOffsets[directionName] or Vector3.new(0,0,1)
        end

        if cfg.isUnlimited then
            dash.remaining = math.huge
            dash.speed = cfg.speed
            if track then
                local stoppedConn
                stoppedConn = track.Stopped:Connect(function()
                    dash.remaining = 0
                    if stoppedConn then stoppedConn:Disconnect() end
                end)
            end
        else
            dash.speed = dist / cfg.duration
        end

        table.insert(ActiveDashes, dash)
        startUpdateIfNeeded()
    end)
end

local function onAnimationPlayed(track)
    if not track.Animation then return end
    local id = track.Animation.AnimationId

    for _, cfg in pairs(DashConfigs) do
        local match = false
        local directionName = nil

        if cfg.animId and id == cfg.animId then
            match = true
        elseif cfg.animIds then
            if cfg.isDirectional then
                directionName = cfg.animIds[id]
                if directionName then match = true end
            elseif cfg.animIds[id] then
                match = true
            end
        end

        if match and cachedHRP and cachedHRP.Parent then
            if cfg.requiresBall then
                local ball = cachedHRP.Parent:FindFirstChild("Ball")
                if not ball then continue end
            end
            startDash(cachedHRP, cfg, track, directionName)
        end
    end
end

local function setupCharacter(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    local animator = hum:WaitForChild("Animator", 5)
    if not animator then return end
    cachedHRP = char:WaitForChild("HumanoidRootPart", 5)
    if not cachedHRP then return end
    animator.AnimationPlayed:Connect(onAnimationPlayed)
end

if player.Character then setupCharacter(player.Character) end
player.CharacterAdded:Connect(setupCharacter)

MainSub:AddLabel("Set sliders to 0 to disable")
MainSub:AddSlider({ Text = "Tackle Distance", Min = 0, Max = 75, Default = 0, Increment = 1, Callback = function(v) Distances.tackleDist = v end })
MainSub:AddSlider({ Text = "Rush Distance", Min = 0, Max = 75, Default = 0, Increment = 1, Callback = function(v) Distances.rushDist = v end })
MainSub:AddSlider({ Text = "GK Front Dive", Min = 0, Max = 75, Default = 0, Increment = 1, Callback = function(v) Distances.gkDist = v end })
MainSub:AddSlider({ Text = "Naruhaya Footwork", Min = 0, Max = 200, Default = 0, Increment = 1, Callback = function(v) Distances.naruhayaDist = v end })
MainSub:AddSlider({ Text = "Raumdeuter", Min = 0, Max = 200, Default = 0, Increment = 1, Callback = function(v) Distances.raumDist = v end })
MainSub:AddSlider({ Text = "Draconic Rush", Min = 0, Max = 200, Default = 0, Increment = 1, Callback = function(v) Distances.dracDist = v end })
MainSub:AddSlider({ Text = "Step Overs", Min = 0, Max = 200, Default = 0, Increment = 1, Callback = function(v) Distances.stepDist = v end })
MainSub:AddSlider({ Text = "Kaiser Off Ball", Min = 0, Max = 200, Default = 0, Increment = 1, Callback = function(v) Distances.kaiserDist = v end })
MainSub:AddSlider({ Text = "Occlusion Break", Min = 0, Max = 200, Default = 0, Increment = 1, Callback = function(v) Distances.occlusionDist = v end })
MainSub:AddSlider({ Text = "Diving Header", Min = 0, Max = 125, Default = 0, Increment = 1, Callback = function(v) Distances.divingDist = v end })
MainSub:AddSlider({ Text = "Reflex Tackle", Min = 0, Max = 125, Default = 0, Increment = 1, Callback = function(v) Distances.reflexDist = v end })
MainSub:AddSlider({ Text = "Razor Break", Min = 0, Max = 35, Default = 0, Increment = 1, Callback = function(v) Distances.razorDist = v end })
MainSub:AddSlider({ Text = "Drag Scissors", Min = 0, Max = 100, Default = 0, Increment = 1, Callback = function(v) Distances.dragDist = v end })
MainSub:AddSlider({ Text = "Hero Instinct", Min = 0, Max = 300, Default = 0, Increment = 1, Callback = function(v) Distances.instinctDist = v end })
MainSub:AddSlider({ Text = "Zombie Dribble", Min = 0, Max = 250, Default = 0, Increment = 1, Callback = function(v) Distances.zombDist = v end })
MainSub:AddSlider({ Text = "Beautiful Destruction", Min = 0, Max = 33, Default = 0, Increment = 1, Callback = function(v) Distances.beautifulDist = v end })
MainSub:AddSlider({ Text = "Creative (Side)", Min = 0, Max = 25, Default = 0, Increment = 1, Callback = function(v) Distances.creativeDist = v end })
MainSub:AddSlider({ Text = "Nutmeg Reflex", Min = 0, Max = 50, Default = 0, Increment = 1, Callback = function(v) Distances.reflexNutmegDist = v end })
MainSub:AddSlider({ Text = "King's Path", Min = 0, Max = 750, Default = 0, Increment = 1, Callback = function(v) Distances.kingsDist = v end })
MainSub:AddSlider({ Text = "DEVOUR", Min = 0, Max = 500, Default = 0, Increment = 1, Callback = function(v) Distances.devourMaxDist = v end })
MainSub:AddSlider({ Text = "Control (Ground)", Min = 0, Max = 30, Default = 0, Increment = 1, Callback = function(v) Distances.controlVarDist = v end })
MainSub:AddSlider({ Text = "Mach Cut-In", Min = 0, Max = 200, Default = 0, Increment = 1, Callback = function(v) Distances.machDist = v end })
MainSub:AddSlider({ Text = "Golden Zone (Req Ball)", Min = 0, Max = 400, Default = 0, Increment = 1, Callback = function(v) Distances.goldenDist = v end })
MainSub:AddSlider({ Text = "Twin Steps", Min = 0, Max = 75, Default = 0, Increment = 1, Callback = function(v) Distances.twinStepsDist = v end })
MainSub:AddSlider({ Text = "Glacial Cut", Min = 0, Max = 175, Default = 0, Increment = 1, Callback = function(v) Distances.glacialDist = v end })
MainSub:AddSlider({ Text = "Close Quarter Dribble", Min = 0, Max = 250, Default = 0, Increment = 1, Callback = function(v) Distances.quarterDist = v end })
MainSub:AddSlider({ Text = "Go-Go!", Min = 0, Max = 100, Default = 0, Increment = 1, Callback = function(v) Distances.gogoDist = v end })
MainSub:AddSlider({ Text = "Guard Dog", Min = 0, Max = 100, Default = 0, Increment = 1, Callback = function(v) Distances.guardDist = v end })
MainSub:AddSlider({ Text = "Speedy Turn", Min = 0, Max = 250, Default = 0, Increment = 1, Callback = function(v) Distances.speedyDist = v end })
MainSub:AddSlider({ Text = "Fetch", Min = 0, Max = 100, Default = 0, Increment = 1, Callback = function(v) Distances.fetchDist = v end })
MainSub:AddSlider({ Text = "Silent Steal", Min = 0, Max = 125, Default = 0, Increment = 1, Callback = function(v) Distances.silentDist = v end })
MainSub:AddSlider({ Text = "Corvine", Min = 0, Max = 100, Default = 0, Increment = 1, Callback = function(v) Distances.corvineDist = v end })
MainSub:AddSlider({ Text = "Kusarigama", Min = 0, Max = 75, Default = 0, Increment = 1, Callback = function(v) Distances.kusarDist = v end })
MainSub:AddSlider({ Text = "Shadow Step", Min = 0, Max = 50, Default = 0, Increment = 1, Callback = function(v) Distances.shadowDist = v end })

MainSub:AddDivider()
MainSub:AddSection("Trap Buffs", "Lucide:move-vertical")

local trapEnabled = false
local trapDist = 0
local trapSpeed = 100
local trapVertical = 0

local trapAnims = {
    "rbxassetid://73387016994281",
    "rbxassetid://101043441232233",
    "rbxassetid://96593185131882",
    "rbxassetid://116422938520670",
    "rbxassetid://90734196141468",
    "rbxassetid://85349589701503",
    "rbxassetid://120351399679118",
}

MainSub:AddToggle({
    Text = "Enable Trap Buffs",
    Description = "Gate for trap buffs",
    Icon = "Lucide:power",
    Default = false,
    Callback = function(v)
        trapEnabled = v
        if not v then
            ActiveDashes = {}
            if renderConn then renderConn:Disconnect() renderConn = nil end
        end
    end
})

MainSub:AddSlider({ Text = "Extra Trap Distance", Min = 0, Max = 500, Default = 0, Increment = 1, Callback = function(v) trapDist = v end })
MainSub:AddSlider({ Text = "Extra Trap Speed", Min = 0, Max = 1000, Default = 100, Increment = 1, Callback = function(v) trapSpeed = v end })
MainSub:AddSlider({ Text = "Trap Vertical", Min = -100, Max = 100, Default = 0, Increment = 1, Callback = function(v) trapVertical = v end })

task.spawn(function()
    RunService.RenderStepped:Connect(function(dt)
        if not trapEnabled then return end
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
            for _, id in ipairs(trapAnims) do
                if track.Animation.AnimationId == id and track.IsPlaying then
                    local dir = hrp.CFrame.LookVector
                    local newDir = Vector3.new(dir.X, trapVertical / 100, dir.Z).Unit
                    local step = math.min(trapSpeed * dt, trapDist)
                    hrp.CFrame = hrp.CFrame + newDir * step
                    break
                end
            end
        end
    end)
end)

MainSub:AddDivider()
MainSub:AddSection("Auto Goal", "Lucide:goal")

local autoGoalState = { enabled = false, conn = nil }

MainSub:AddToggle({
    Text = "Auto Goal",
    Description = "Auto-scoring: disables collisions + teleports + kicks",
    Icon = "Lucide:goal",
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

MainSub:AddDivider()
MainSub:AddSection("Auto Dribble/Counter", "Lucide:sparkles")

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
    "rbxassetid://113088324958896",
    "rbxassetid://96801747244950",
    "rbxassetid://130345228612384",
    "rbxassetid://82417661349987"
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
        args = { buffer.fromstring(buffers["base"]), {{ skillName, targetPlayer.Character }} }
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

for _, plr in ipairs(Players:GetPlayers()) do setupPlayer(plr) end
Players.PlayerAdded:Connect(setupPlayer)

MainSub:AddToggle({ Text = "Auto Dribble", Default = false, Callback = function(v) autoSkillState.toggleDribble = v end })
MainSub:AddToggle({ Text = "Auto Counter (Move 1)", Default = false, Callback = function(v) autoSkillState.toggleCounter1 = v end })
MainSub:AddToggle({ Text = "Auto Counter (Move 2)", Default = false, Callback = function(v) autoSkillState.toggleCounter2 = v end })
MainSub:AddToggle({ Text = "Auto Counter (Move 3)", Default = false, Callback = function(v) autoSkillState.toggleCounter3 = v end })
MainSub:AddToggle({ Text = "Auto Counter (Move 4)", Default = false, Callback = function(v) autoSkillState.toggleCounter4 = v end })
MainSub:AddToggle({ Text = "Auto Counter (Move 5)", Default = false, Callback = function(v) autoSkillState.toggleCounter5 = v end })
MainSub:AddToggle({ Text = "T Special", Default = false, Callback = function(v) autoSkillState.toggleTSpecial = v end })
MainSub:AddToggle({ Text = "Use Closest Teammate", Default = false, Callback = function(v) autoSkillState.useClosestTeammate = v end })
MainSub:AddSlider({ Text = "Counter Radius", Min = 25, Max = 75, Default = 65, Increment = 1, Callback = function(v) autoSkillState.mCD = v end })

MainSub:AddDivider()
MainSub:AddSection("Air Dribble", "Lucide:wind")

local airDribState = { enabled = false, isHolding = false, lastKick = 0, bind = Enum.KeyCode.LeftAlt }

local function doAirDribble()
    local now = tick()
    if now - airDribState.lastKick < 0.255 then return end
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not (hum and root) then return end
    airDribState.lastKick = now
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://76587445975710"
    hum:LoadAnimation(anim):Play()
    local dir = root.CFrame.LookVector
    BNR:FireServer(buffer.fromstring(buffers["base"]), {{"kick", 28, false, Vector3.new(dir.X*0.75, 0.65, dir.Z*0.75)}})
end

MainSub:AddToggle({ Text = "Air Dribble", Default = false, Callback = function(v) airDribState.enabled = v end })
MainSub:AddTextbox({ Text = "Air Dribble Bind", Default = "LeftAlt", Callback = function(t)
    local ok, kc = pcall(function() return Enum.KeyCode[t:gsub("%s+","")] end)
    if ok and kc then airDribState.bind = kc else airDribState.bind = Enum.KeyCode.LeftAlt end
end })

local holdingConn = nil
UserInputService.InputBegan:Connect(function(input, gp)
    if gp or input.KeyCode ~= airDribState.bind then return end
    if not airDribState.enabled then return end
    airDribState.isHolding = true
    doAirDribble()
    if holdingConn then holdingConn:Disconnect() end
    holdingConn = RunService.Heartbeat:Connect(function()
        if airDribState.isHolding and airDribState.enabled then doAirDribble()
        else holdingConn:Disconnect() holdingConn = nil end
    end)
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == airDribState.bind then airDribState.isHolding = false end
end)

MainSub:AddDivider()
MainSub:AddSection("Infinite Range Passing", "Lucide:radio-tower")

local passingState = { InfiniteRangePassing = false, busy = false }

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
    if gp or not passingState.InfiniteRangePassing or passingState.busy then return end
    if player.Team == game.Teams.lobby then return end
    local skillName = keyToSkill[input.KeyCode]
    if not skillName then return end
    local targetChar = getClosestPlayerToCursor()
    if not targetChar then return end
    passingState.busy = true
    BNR:FireServer(buffer.fromstring(buffers["base"]), {{skillName, targetChar}})
    task.delay(0.1, function() passingState.busy = false end)
end)

MainSub:AddToggle({ Text = "Infinite Range Passing", Description = "Pass to teammate closest to cursor (keys 1-4)", Default = false, Callback = function(v) passingState.InfiniteRangePassing = v end })

LineUpsSub:AddSection("Line Up Settings", "Lucide:crosshair")

local padCount = 0
local targetCount = 0
local activeLineups = {}
local autoActivateSkill = false
local autoAim = false
local skillNumber = 1
local padColor = Color3.fromRGB(255, 0, 0)
local targetColor = Color3.fromRGB(0, 255, 0)
local padTransparency = 0.65
local targetTransparency = 0
local showTargets = true
local autoSkillFired = {}
local camLockConnection = nil
local activeTarget = nil
local aimedPad = nil

local camera = workspace.CurrentCamera
local character = player.Character
local hrp = character and character:FindFirstChild("HumanoidRootPart")
local humanoid = character and character:FindFirstChildOfClass("Humanoid")

local function updateCharacterRefs(char)
    character = char
    hrp = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
end

if player.Character then updateCharacterRefs(player.Character) end
player.CharacterAdded:Connect(updateCharacterRefs)

local function pad(pos, color)
    padCount += 1
    local p = Instance.new("Part")
    p.Name = "pad" .. padCount
    p.Size = Vector3.new(4, 4, 4)
    p.Position = pos
    p.Transparency = padTransparency
    p.Anchored = true
    p.CanCollide = false
    p.Color = padColor
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
    t.Transparency = targetTransparency
    t.Anchored = true
    t.CanCollide = false
    t.Color = targetColor
    t.Material = Enum.Material.Neon
    t.Parent = workspace
    t.Transparency = showTargets and targetTransparency or 1
    table.insert(activeLineups, t)
end

local function clearLineups()
    for _, obj in ipairs(activeLineups) do
        if obj and obj.Parent then obj:Destroy() end
    end
    activeLineups = {}
    padCount = 0
    targetCount = 0
    autoSkillFired = {}
    aimedPad = nil
    if camLockConnection then camLockConnection:Disconnect() camLockConnection = nil end
end

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
    if camLockConnection then camLockConnection:Disconnect() camLockConnection = nil end
end

RunService.RenderStepped:Connect(function()
    if not hrp or not humanoid then return end
    local padIndex = getPadUnderPlayer()
    if not padIndex then
        if aimedPad then aimedPad = nil stopCamLock() end
        return
    end
    local targetPart = workspace:FindFirstChild("target" .. padIndex)
    if not targetPart then return end

    if autoAim then
        hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(targetPart.Position.X, hrp.Position.Y, targetPart.Position.Z))
        if aimedPad ~= padIndex then
            aimedPad = padIndex
            startCamLock(targetPart)
        end
    end

    if autoActivateSkill and not autoSkillFired[padIndex] then
        autoSkillFired[padIndex] = true
        BNR:FireServer(buffer.fromstring(buffers["base"]), {{"skill" .. skillNumber}})
        task.delay(1, function() autoSkillFired[padIndex] = nil end)
    end
end)

LineUpsSub:AddToggle({ Text = "Show Targets", Default = true, Callback = function(v)
    showTargets = v
    for _, obj in ipairs(activeLineups) do
        if obj and obj.Parent and obj.Name:match("^target") then
            obj.Transparency = v and targetTransparency or 1
        end
    end
end })

LineUpsSub:AddToggle({ Text = "Auto Aim On Pad", Default = false, Callback = function(v)
    autoAim = v
    if not v then aimedPad = nil stopCamLock() end
end })

LineUpsSub:AddToggle({ Text = "Auto Activate Skill On Pad", Default = false, Callback = function(v) autoActivateSkill = v end })

LineUpsSub:AddTextbox({ Text = "Skill Number (1-5)", Default = "1", Callback = function(text)
    local num = tonumber(text)
    if num and num >= 1 and num <= 5 then skillNumber = num end
end })

LineUpsSub:AddColorPicker({ Text = "Pad Color", Default = Color3.fromRGB(255,0,0), Callback = function(c) padColor = c end })
LineUpsSub:AddColorPicker({ Text = "Target Color", Default = Color3.fromRGB(0,255,0), Callback = function(c) targetColor = c end })

LineUpsSub:AddSlider({ Text = "Pad Transparency", Min = 0, Max = 1, Default = 0.65, Increment = 0.05, Callback = function(v)
    padTransparency = v
    for _, obj in ipairs(activeLineups) do
        if obj and obj.Parent and obj.Name:match("^pad") then obj.Transparency = v end
    end
end })

LineUpsSub:AddSlider({ Text = "Target Transparency", Min = 0, Max = 1, Default = 0, Increment = 0.05, Callback = function(v)
    targetTransparency = v
    for _, obj in ipairs(activeLineups) do
        if obj and obj.Parent and obj.Name:match("^target") then
            obj.Transparency = showTargets and v or 1
        end
    end
end })

LineUpsSub:AddDivider()
LineUpsSub:AddSection("Preset Line Ups", "Lucide:map-pin")

local SAE_LINEUP = {
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

local YUKI_LINEUP = {
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

local RAINBOW = {
    Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(255,255,0),
    Color3.fromRGB(0,0,255), Color3.fromRGB(255,0,255), Color3.fromRGB(255,182,193)
}

local function createLineUps(goalRelative, colors)
    clearLineups()
    local map = workspace:WaitForChild("map")
    local agoal = map:FindFirstChild("Agoal")
    local bgoal = map:FindFirstChild("Bgoal")
    if not agoal or not bgoal then return end
    for i, entry in ipairs(goalRelative) do
        local basePos = (i <= #goalRelative/2) and agoal.Position or bgoal.Position
        local col = colors[(i - 1) % #colors + 1]
        pad(basePos + entry.pad, col)
        target(basePos + entry.target, col)
    end
end

LineUpsSub:AddToggle({ Text = "Sae Line Ups", Default = false, Callback = function(v)
    if v then createLineUps(SAE_LINEUP, RAINBOW) else clearLineups() end
end })

LineUpsSub:AddToggle({ Text = "Yukimiya Line Ups", Default = false, Callback = function(v)
    if v then createLineUps(YUKI_LINEUP, RAINBOW) else clearLineups() end
end })

MovesetsSub:AddSection("Movesets", "Lucide:wand-sparkles")

local function loadMoveset(url, preset)
    return function()
        if preset then
            for k, v in pairs(preset) do
                getgenv()[k] = v
            end
        end
        loadstring(game:HttpGet(url, true))()
    end
end

MovesetsSub:AddButton({ Text = "Messi", Callback = loadMoveset("https://raw.githubusercontent.com/jonathabejose-alt/Azure-latch/refs/heads/main/MessiStyle.lua", { DisableWatermark = false, LegitMode = false, ShootSkill = true }) })
MovesetsSub:AddButton({ Text = "Ronaldo", Callback = loadMoveset("https://raw.githubusercontent.com/jonathabejose-alt/Azure-latch/refs/heads/main/RonaldoStyle.lua") })
MovesetsSub:AddButton({ Text = "SonicEXE", Callback = loadMoveset("https://raw.githubusercontent.com/jonathabejose-alt/Azure-latch/refs/heads/main/SonicEXE.lua", { HBM = 30 }) })
MovesetsSub:AddButton({ Text = "KJ (Req. shidou)", Callback = loadMoveset("https://raw.githubusercontent.com/jonathabejose-alt/Azure-latch/refs/heads/main/KJ%20Style.lua", { HBM = 30 }) })
MovesetsSub:AddButton({ Text = "Loki", Callback = loadMoveset("https://raw.githubusercontent.com/jonathabejose-alt/Azure-latch/refs/heads/main/loki.lua") })
MovesetsSub:AddButton({ Text = "Aizen", Callback = loadMoveset("https://raw.githubusercontent.com/jonathabejose-alt/Azure-latch/refs/heads/main/aizenStyle.lua") })

FeaturesTab:AddSection("Ball Features", "Lucide:circle-dot")

local bmRadius = 1
local bmState = { active = false }

FeaturesTab:AddToggle({ Text = "Ball Magnet (Auto Grab)", Description = "Auto grabs ball when close", Default = false, Callback = function(v) bmState.active = v end })
FeaturesTab:AddSlider({ Text = "Magnet Radius", Min = 1, Max = 25, Default = 1, Increment = 1, Callback = function(v) bmRadius = v end })

task.spawn(function()
    while task.wait() do
        if not bmState.active or bmRadius < 2 then
        else
            local ball = workspace.Terrain:FindFirstChild("Ball")
            if ball then
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - ball.Position).Magnitude <= bmRadius then
                    pcall(function() BNR:FireServer(buffer.fromstring(buffers["grabball"])) end)
                end
            end
        end
    end
end)

FeaturesTab:AddDivider()
FeaturesTab:AddSection("Break Ball", "Lucide:circle-slash")

FeaturesTab:AddButton({ Text = "Break Ball (Player Method)", Callback = function()
    local baseplatePosition = Vector3.new(-190, 14864566, 492)
    for x = 0, 2 do
        for z = 0, 2 do
            local part = Instance.new("Part")
            part.Size = Vector3.new(10, 1, 10)
            part.Anchored = true
            part.Position = baseplatePosition + Vector3.new(x * 10, 0, z * 10)
            part.Parent = workspace
        end
    end
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(baseplatePosition + Vector3.new(0, 100000000000000, 0))
    end
end })

FeaturesTab:AddButton({ Text = "Break Ball (Ball Method)", Callback = function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local orig = root.Position
        root.CFrame = CFrame.new(Vector3.new(-390, 475, 354))
        task.wait(0.3)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        task.wait(0.3)
        root.CFrame = CFrame.new(orig)
    end
end })

FeaturesTab:AddButton({ Text = "Permanent Break Ball", Callback = function()
    workspace.FallenPartsDestroyHeight = -50000
    player.Character:SetPrimaryPartCFrame(CFrame.new(1, -49999, 1))
end })

FeaturesTab:AddDivider()
FeaturesTab:AddSection("Steal Ball", "Lucide:hand")

local stealActive = false

local function stealBall(aikuMode)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if stealActive then stealActive = false return end
    stealActive = true
    local skillName = aikuMode and "skill2" or "tackle"
    task.spawn(function()
        while stealActive and hrp and hrp.Parent and not player.Character:FindFirstChild("Ball") do
            local ball = workspace.Terrain:FindFirstChild("Ball")
            if ball then hrp.CFrame = CFrame.new(ball.Position) end
            for _, p in ipairs(Players:GetPlayers()) do
                if not stealActive then break end
                if p ~= player then
                    local b = p.Character and p.Character:FindFirstChild("Ball")
                    if b then
                        hrp.CFrame = b.CFrame
                        BNR:FireServer(buffer.fromstring(buffers["base"]), {{skillName}})
                    end
                end
            end
            task.wait(0.05)
        end
        stealActive = false
    end)
end

FeaturesTab:AddButton({ Text = "Steal Ball", Callback = function() stealBall(false) end })
FeaturesTab:AddButton({ Text = "Steal Ball (Aiku - Reflex Tackle)", Callback = function() stealBall(true) end })

FeaturesTab:AddDivider()
FeaturesTab:AddSection("No Cooldown Dash", "Lucide:zap")

local forwardAnim = "rbxassetid://79394729551302"
local sideRightAnim = "rbxassetid://114016332539655"
local sideLeftAnim = "rbxassetid://100207093237932"
local dashState = { forward = false, side = false, lastF = 0, lastS = 0 }

local function isAnimPlaying(animId)
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
        if track.Animation and track.Animation.AnimationId == animId then return true end
    end
    return false
end

local function forwardRush()
    if not dashState.forward then return end
    if tick() - dashState.lastF < 0.75 then return end
    if isAnimPlaying(forwardAnim) then return end
    dashState.lastF = tick()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
    local anim = Instance.new("Animation")
    anim.AnimationId = forwardAnim
    animator:LoadAnimation(anim):Play()
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(2e6, 2e4, 2e6)
    bv.P = 1500
    bv.Parent = root
    local id = "FwdRush_" .. tostring(os.clock())
    RunService:BindToRenderStep(id, Enum.RenderPriority.Character.Value + 10, function()
        if root and root.Parent then bv.Velocity = root.CFrame.LookVector * 100 end
    end)
    task.delay(0.5, function()
        RunService:UnbindFromRenderStep(id)
        if bv then bv:Destroy() end
    end)
end

local function sideDash(dir)
    if not dashState.side then return end
    if tick() - dashState.lastS < 0.3 then return end
    if isAnimPlaying(sideRightAnim) or isAnimPlaying(sideLeftAnim) then return end
    dashState.lastS = tick()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
    local anim = Instance.new("Animation")
    anim.AnimationId = dir == "right" and sideRightAnim or sideLeftAnim
    animator:LoadAnimation(anim):Play()
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(2e6, 2e4, 2e6)
    bv.P = 1500
    bv.Parent = root
    local id = "SideDash_" .. tostring(os.clock())
    RunService:BindToRenderStep(id, Enum.RenderPriority.Character.Value + 10, function()
        if root and root.Parent then
            local right = root.CFrame.RightVector
            bv.Velocity = right * (dir == "right" and 75 or -75)
        end
    end)
    task.delay(0.4, function()
        RunService:UnbindFromRenderStep(id)
        if bv then bv:Destroy() end
    end)
end

FeaturesTab:AddToggle({ Text = "No Rush Cooldown (F)", Default = false, Callback = function(v) dashState.forward = v end })
FeaturesTab:AddToggle({ Text = "No Side Dash Cooldown (Q+A/D)", Default = false, Callback = function(v) dashState.side = v end })

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then forwardRush()
    elseif input.KeyCode == Enum.KeyCode.Q then
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then sideDash("right")
        elseif UserInputService:IsKeyDown(Enum.KeyCode.A) then sideDash("left") end
    end
end)

FeaturesTab:AddDivider()
FeaturesTab:AddSection("Auto Position", "Lucide:map-pin")

FeaturesTab:AddToggle({ Text = "Auto Pick CF", Default = false, Callback = function(v)
    getgenv().SW_AutoCF = v
    if v then
        local char = player.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root and ((root.Position - Vector3.new(-371,13,-1599)).Magnitude <= 15 or (root.Position - Vector3.new(-196,13,-1599)).Magnitude <= 15) then
                BNR:FireServer(buffer.fromstring(pick .. "\001\001\000A"))
                BNR:FireServer(buffer.fromstring(pick .. "\001\001\000B"))
            end
        end
    end
end })

FeaturesTab:AddToggle({ Text = "Auto Pick GK", Default = false, Callback = function(v)
    if v then
        BNR:FireServer(buffer.fromstring(pick .. "\005\001\000B"))
        BNR:FireServer(buffer.fromstring(pick .. "\005\001\000A"))
    end
end })

FeaturesTab:AddDivider()
FeaturesTab:AddSection("Auto Activate", "Lucide:zap")

local autoActState = { enabled = false, dist = 10, moveNum = 1, hold = true, db = true, minHeight = 0 }

FeaturesTab:AddToggle({ Text = "Auto Activate Skill", Default = false, Callback = function(v) autoActState.enabled = v end })
FeaturesTab:AddTextbox({ Text = "Skill Number (1-5)", Default = "1", Callback = function(t)
    local n = tonumber(t)
    if n and n >= 1 and n <= 5 then autoActState.moveNum = n end
end })
FeaturesTab:AddSlider({ Text = "Distance", Min = 3, Max = 70, Default = 10, Increment = 0.5, Callback = function(v) autoActState.dist = v end })
FeaturesTab:AddSlider({ Text = "Min Ball Height", Min = 0, Max = 50, Default = 0, Increment = 0.5, Callback = function(v) autoActState.minHeight = v end })

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if autoActState.hold then autoActState.db = false
        else autoActState.db = not autoActState.db end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and autoActState.hold then
        autoActState.db = true
    end
end)

RunService.RenderStepped:Connect(function()
    if not autoActState.enabled or autoActState.db then return end
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local ball = workspace.Terrain:FindFirstChild("Ball")
    if not ball then return end
    if (hrp.Position - ball.Position).Magnitude <= autoActState.dist then
        if autoActState.minHeight > 0 then
            local rel = ball.Position.Y - (hrp.Position.Y - 2)
            if rel < autoActState.minHeight then return end
        end
        BNR:FireServer(buffer.fromstring(buffers["base"]), {{"skill" .. autoActState.moveNum}})
    end
end)

FeaturesTab:AddDivider()
FeaturesTab:AddSection("Invisibility", "Lucide:eye-off")

local invisState = { active = false, character = nil, humanoid = nil, animationTrack = nil }
local invisAnim = "rbxassetid://113098409724280"
local invisSafety = Vector3.new(-540, 3, 1274)

local function startInvisibility()
    if not invisState.humanoid then return end
    invisState.active = true
    local anim = Instance.new("Animation")
    anim.AnimationId = invisAnim
    local track = invisState.humanoid:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    track.Looped = false
    track:Play(0)
    track:AdjustSpeed(0)
    invisState.animationTrack = track
end

local function stopInvisibility()
    invisState.active = false
    if invisState.animationTrack then
        invisState.animationTrack:Stop()
        invisState.animationTrack:Destroy()
        invisState.animationTrack = nil
    end
    if invisState.humanoid then invisState.humanoid.CameraOffset = Vector3.new(0, 0, 0) end
end

RunService.RenderStepped:Connect(function()
    if not invisState.active or not invisState.humanoid or not invisState.character then return end
    invisState.humanoid.CameraOffset = Vector3.new(0, 0, 0)
    local rootPart = invisState.character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local result = workspace:Raycast(rootPart.Position, Vector3.new(0, -500, 0))
        if not result then rootPart.CFrame = CFrame.new(invisSafety) end
    end
end)

player.CharacterAdded:Connect(function(char)
    invisState.character = char
    invisState.humanoid = char:WaitForChild("Humanoid")
    if invisState.active then startInvisibility() end
end)

if player.Character then
    invisState.character = player.Character
    invisState.humanoid = player.Character:FindFirstChildOfClass("Humanoid")
end

FeaturesTab:AddToggle({ Text = "Invisibility V1 (Animation)", Default = false, Callback = function(v)
    if v then startInvisibility() else stopInvisibility() end
end })

FeaturesTab:AddDivider()
FeaturesTab:AddSection("Team Highlighting", "Lucide:users")

FeaturesTab:AddToggle({ Text = "Team Highlighting", Default = false, Callback = function(v)
    if v then
        local folder = Instance.new("Folder")
        folder.Name = "SW_Highlights"
        folder.Parent = game:GetService("CoreGui")
        local function apply()
            for _, hl in ipairs(folder:GetChildren()) do hl:Destroy() end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local color = (p.Team == player.Team) and Color3.fromRGB(0,150,255) or Color3.fromRGB(255,50,50)
                    local hl = Instance.new("Highlight")
                    hl.FillColor = color
                    hl.FillTransparency = 0.65
                    hl.OutlineColor = color
                    hl.Adornee = p.Character
                    hl.Parent = folder
                end
            end
        end
        apply()
        local c1 = Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function() task.wait(0.5) apply() end)
        end)
        local c2 = RunService.Heartbeat:Connect(function()
            if not folder.Parent then c1:Disconnect() c2:Disconnect() return end
            apply()
        end)
        getgenv().SW_HighlightFolder = folder
    else
        if getgenv().SW_HighlightFolder then
            getgenv().SW_HighlightFolder:Destroy()
            getgenv().SW_HighlightFolder = nil
        end
    end
end })

MiscTab:AddSection("Teleports", "Lucide:map-pin")
MiscTab:AddButton({ Text = "Middle Field", Callback = function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-540, 3, 1274)
    end
end })
MiscTab:AddButton({ Text = "Commentator Area", Callback = function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-6, 2, 3237)
    end
end })
MiscTab:AddButton({ Text = "Goal Box A", Callback = function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-537, 3, 1575)
    end
end })
MiscTab:AddButton({ Text = "Goal Box B", Callback = function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-534, 3, 974)
    end
end })

MiscTab:AddDivider()
MiscTab:AddSection("Utilities", "Lucide:wrench")

MiscTab:AddButton({ Text = "Infinite Yield", Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end })

MiscTab:AddButton({ Text = "Fix Duplicate Balls", Callback = function()
    for _, obj in ipairs(workspace.Terrain:GetDescendants()) do
        if obj:IsA("MeshPart") and obj.Name == "Ball" then obj:Destroy() end
    end
end })

MiscTab:AddDivider()
MiscTab:AddSection("Dubs", "Lucide:volume-2")

MiscTab:AddToggle({ Text = "Enable All Dubs/Voicelines", Default = false, Callback = function(v)
    local setting = player.setting
    local dubs = {
        setting.dub_yukimiya, setting.dubVoicelines, setting.britishaikuevil,
        setting.dub_barou, setting.dub_chigiri, setting.dub_donlorenzo,
        setting.dub_gagamaru, setting.dub_isagi, setting.dub_kaiser,
        setting.dub_karasu, setting.dub_kunigami, setting.dub_masterylorenzo,
        setting.dub_nagi, setting.dub_otoya, setting.dub_rin,
        setting.dub_sae, setting.dub_what,
    }
    for _, dub in ipairs(dubs) do
        if dub then dub.Value = v end
    end
    StarterGui:SetCore("SendNotification", {Title = "Dubs", Text = v and "Enabled" or "Disabled", Duration = 2})
end })

HomeTab:AddSubTab({ Name = "Details And Info", Icon = "Lucide:layout-grid" }):AddSystemInfoGrid({ Description = "Live session info" })

local ChangelogSub = HomeTab:AddSubTab({ Name = "Changelog", Icon = "Lucide:file-text" })

ChangelogSub:AddChangelogEntry({
    Version = "Scared Ware UI v0.1",
    Date    = "Release",
    Changes = {
        { Type = "Added",   Text = "Initial release" },
        { Type = "Added",   Text = "Combat tab with 30+ Distance Buff sliders" },
        { Type = "Added",   Text = "Trap Buffs (distance/speed/vertical)" },
        { Type = "Added",   Text = "Auto Goal" },
        { Type = "Added",   Text = "Auto Dribble / Auto Counter (moves 1-5 + T Special)" },
        { Type = "Added",   Text = "Air Dribble with custom bind" },
        { Type = "Added",   Text = "Infinite Range Passing" },
        { Type = "Added",   Text = "Line Ups (Sae + Yukimiya) with custom settings" },
        { Type = "Added",   Text = "9 Movesets" },
        { Type = "Added",   Text = "Features tab: Ball Magnet, Break Ball, Steal Ball" },
        { Type = "Added",   Text = "No Rush / Side Dash Cooldown" },
        { Type = "Added",   Text = "Auto Pick CF/GK" },
        { Type = "Added",   Text = "Auto Activate Skill" },
        { Type = "Added",   Text = "Invisibility V1" },
        { Type = "Added",   Text = "Team Highlighting" },
        { Type = "Added",   Text = "Misc tab: Teleports, Utilities, Dubs" },
        { Type = "Added",   Text = "Menu keybind: Right Alt" },
    },
})

local ConfigSub = SettingsTab:AddSubTab({ Name = "Config", Icon = "Lucide:save" })

ConfigSub:AddSection("Session", "Lucide:activity")

ConfigSub:AddParagraph({
    Title = "Scared Ware UI v0.1",
    Icon = "Lucide:ghost",
    Text = "Based on Zolar + Celeron for Azure Latch.",
})

ConfigSub:AddDivider()

ConfigSub:AddKeybind({
    Text = "Toggle Menu",
    Description = "Key used to open/close the panel",
    Icon = "Lucide:keyboard",
    Default = TOGGLE_KEY,
    Callback = function(key, kind)
        if kind == "press" then Window:Toggle() end
    end,
})

ConfigSub:AddDivider()

ConfigSub:AddButton({
    Text = "Reset All Toggles",
    Description = "Turns every auto feature off",
    Icon = "Lucide:rotate-ccw",
    Callback = function()
        ActiveDashes = {}
        if renderConn then renderConn:Disconnect() renderConn = nil end
        clearLineups()
        VindUI:Notify({ Title = "Reset", Text = "All features have been turned off.", Type = "warning", Duration = 3 })
    end,
})

Window:SelectTab("Home")
Window:Open()
