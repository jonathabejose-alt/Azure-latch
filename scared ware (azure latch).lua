if getgenv().ScaredWare and getgenv().ScaredWare.Unload then
    getgenv().ScaredWare:Unload()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
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
    create = function(x, y, z) return Vector3.new(x, y, z) end
}

local role = ReplicatedStorage:WaitForChild("BytenetStorage"):WaitForChild("Networking").Value:match('"bytenet_selectRole"%s*:%s*(%d+)')
role = role and tonumber(role)
local pick = string.char(role)

local VindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Skinny-yz/vindUI-Test/main/full.luau"))()

getgenv().CONFIG = {
    Theme = "Midnight",
    Intro = {
        Enabled = true,
        Title = "Scared Ware UI",
        Eyebrow = "AZURE LATCH",
        Subtitle = "Loading your workspace...",
        Logo = "Lucide:ghost",
        UseBlur = true,
        Transparency = 0.22,
        Shimmer = true,
        Duration = 2.5,
        Skippable = true,
        ReducedMotion = false,
    },
    MobileScaleReference = 450,
    UserInfo = { Enabled = true, Avatar = "player", NameMode = "display" },
}

VindUI:SetTheme(getgenv().CONFIG.Theme)
VindUI:PreloadIcons({ "Lucide", "Material", "Phosphor", "SF" })
VindUI:SetScaleRange(0.75, 1.35)
VindUI:SetMobileScaleReference(getgenv().CONFIG.MobileScaleReference)

pcall(function() VindUI:ShowIntro(getgenv().CONFIG.Intro):Wait() end)

local ENV = (getgenv and getgenv()) or _G
if ENV.__AZURE_LATCH_CLEANUP then pcall(ENV.__AZURE_LATCH_CLEANUP) end

local Config = {
    Movement = { WalkSpeedEnabled = false, WalkSpeedValue = 16, JumpEnabled = false, JumpValue = 50 },
    PlayerList = { Enabled = false, MaxDistance = 500 },
    BallESP = { Enabled = false, Color = Color3.fromRGB(255,255,0), ShowDistance = true, MaxDistance = 2000 },
    Notifications = { GoalScored = true, BallStolen = true, Tackled = true },
}

local ConfigStore = {
    Id = "AzureLatch", Selected = "default", AutoSave = true, AutoLoad = true,
    Applying = false, LastFingerprint = nil, StatusLabel = nil,
    ProfileDropdown = nil, ProfileInput = nil, PendingProfile = nil,
    Root = "ScaredWare/Configs",
}

local FS = {
    Write = type(writefile) == "function" and writefile or nil,
    Read = type(readfile) == "function" and readfile or nil,
    IsFile = type(isfile) == "function" and isfile or nil,
    MakeFolder = type(makefolder) == "function" and makefolder or nil,
    ListFiles = type(listfiles) == "function" and listfiles or nil,
    DeleteFile = type(delfile) == "function" and delfile or nil,
}

ConfigStore.Available = FS.Write ~= nil and FS.Read ~= nil and FS.IsFile ~= nil and FS.MakeFolder ~= nil
ConfigStore.Folder = ConfigStore.Root .. "/" .. ConfigStore.Id
ConfigStore.MetaPath = ConfigStore.Folder .. "/_meta.json"

local function sanitizeConfigName(value, fallback)
    local text = tostring(value or "")
    text = text:gsub("[^%w%-%._ ]", "_")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    text = text:gsub("%s+", "_"):gsub("_+", "_")
    if text == "" then text = tostring(fallback or "default") end
    return text:sub(1, 80)
end

local function ensureConfigFolders()
    if not FS.MakeFolder then return false end
    local current = ""
    for part in ConfigStore.Folder:gmatch("[^/\\]+") do
        current = current == "" and part or (current .. "/" .. part)
        pcall(FS.MakeFolder, current)
    end
    return true
end

local function configPath(name)
    return ConfigStore.Folder .. "/" .. sanitizeConfigName(name, "default") .. ".json"
end

local function encodeJSON(value)
    local ok, result = pcall(function() return HttpService:JSONEncode(value) end)
    return ok and result or nil
end

local function decodeJSON(text)
    local ok, result = pcall(function() return HttpService:JSONDecode(text) end)
    return ok and result or nil
end

local function setConfigStatus(text)
    if ConfigStore.StatusLabel and ConfigStore.StatusLabel.Set then
        ConfigStore.StatusLabel:Set(tostring(text or ""))
    end
end

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
            ["rbxassetid://131681055843039"] = "Front", ["rbxassetid://114963791456755"] = "Left",
            ["rbxassetid://115966658644919"] = "Right", ["rbxassetid://122404546980503"] = "Back",
            ["rbxassetid://70754845580062"] = "RightBack", ["rbxassetid://128061536134952"] = "LeftBack",
            ["rbxassetid://71501932579824"] = "FrontRight", ["rbxassetid://96632954418440"] = "FrontLeft",
            ["rbxassetid://70397727954557"] = "Front", ["rbxassetid://131196726012273"] = "Front",
        }, sliderVar = "razorDist", duration = 0.35, cooldown = 0.15, wait = 0.1, isDirectional = true,
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
    Devour = { animId = "rbxassetid://117921992582675", sliderVar = "devourMaxDist", speed = 150, cooldown = 0.15, isUnlimited = true, wait = 0.2 },
}

local Distances = {}
for _, cfg in pairs(DashConfigs) do Distances[cfg.sliderVar] = 0 end

local function configSnapshot()
    return {
        Version = 2,
        Distances = Distances,
        Movement = { WalkSpeedEnabled = Config.Movement.WalkSpeedEnabled, WalkSpeedValue = Config.Movement.WalkSpeedValue, JumpEnabled = Config.Movement.JumpEnabled, JumpValue = Config.Movement.JumpValue },
        PlayerList = { Enabled = Config.PlayerList.Enabled, MaxDistance = Config.PlayerList.MaxDistance },
        BallESP = { Enabled = Config.BallESP.Enabled, MaxDistance = Config.BallESP.MaxDistance, ShowDistance = Config.BallESP.ShowDistance },
        Theme = VindUI._ThemeName,
    }
end

local function configFingerprint() return encodeJSON(configSnapshot()) or "" end

local function applyConfigTable(data)
    if type(data) ~= "table" then return false end
    ConfigStore.Applying = true
    if type(data.Distances) == "table" then
        for k, v in pairs(data.Distances) do
            if Distances[k] ~= nil and type(v) == "number" then Distances[k] = v end
        end
    end
    local mv = type(data.Movement) == "table" and data.Movement or {}
    if mv.WalkSpeedEnabled ~= nil then Config.Movement.WalkSpeedEnabled = mv.WalkSpeedEnabled end
    if mv.WalkSpeedValue ~= nil then Config.Movement.WalkSpeedValue = mv.WalkSpeedValue end
    if mv.JumpEnabled ~= nil then Config.Movement.JumpEnabled = mv.JumpEnabled end
    if mv.JumpValue ~= nil then Config.Movement.JumpValue = mv.JumpValue end
    local pl = type(data.PlayerList) == "table" and data.PlayerList or {}
    if pl.Enabled ~= nil then Config.PlayerList.Enabled = pl.Enabled end
    if pl.MaxDistance ~= nil then Config.PlayerList.MaxDistance = pl.MaxDistance end
    local be = type(data.BallESP) == "table" and data.BallESP or {}
    if be.Enabled ~= nil then Config.BallESP.Enabled = be.Enabled end
    if be.MaxDistance ~= nil then Config.BallESP.MaxDistance = be.MaxDistance end
    if be.ShowDistance ~= nil then Config.BallESP.ShowDistance = be.ShowDistance end
    if type(data.Theme) == "string" and data.Theme ~= "" then pcall(function() VindUI:SetTheme(data.Theme) end) end
    ConfigStore.Applying = false
    return true
end

local function saveMeta()
    if not ConfigStore.Available then return false end
    local text = encodeJSON({Version = 1, Selected = ConfigStore.Selected, AutoSave = ConfigStore.AutoSave, AutoLoad = ConfigStore.AutoLoad})
    if not text then return false end
    return pcall(FS.Write, ConfigStore.MetaPath, text)
end

local function loadMeta()
    if not ConfigStore.Available or not FS.IsFile(ConfigStore.MetaPath) then return end
    local ok, text = pcall(FS.Read, ConfigStore.MetaPath)
    if not ok then return end
    local data = decodeJSON(text)
    if type(data) ~= "table" then return end
    if data.Selected ~= nil then ConfigStore.Selected = sanitizeConfigName(data.Selected, "default") end
    if data.AutoSave ~= nil then ConfigStore.AutoSave = data.AutoSave == true end
    if data.AutoLoad ~= nil then ConfigStore.AutoLoad = data.AutoLoad == true end
end

local function saveConfig(name, notify)
    if not ConfigStore.Available then setConfigStatus("Unavailable") return false end
    local clean = sanitizeConfigName(name or ConfigStore.Selected, "default")
    ConfigStore.Selected = clean
    ensureConfigFolders()
    local text = encodeJSON(configSnapshot())
    if not text then setConfigStatus("Save failed") return false end
    local ok, err = pcall(FS.Write, configPath(clean), text)
    if not ok then setConfigStatus("Save failed: " .. tostring(err)) return false end
    saveMeta()
    ConfigStore.LastFingerprint = configFingerprint()
    setConfigStatus("Saved " .. clean)
    if notify then VindUI:Notify({Title = "Configs", Text = "Saved " .. clean, Type = "success", Duration = 2}) end
    return true
end

local function loadConfig(name, notify)
    if not ConfigStore.Available then setConfigStatus("Unavailable") return false end
    local clean = sanitizeConfigName(name or ConfigStore.Selected, "default")
    local path = configPath(clean)
    if not FS.IsFile(path) then setConfigStatus("Not found " .. clean) return false end
    local ok, text = pcall(FS.Read, path)
    if not ok then setConfigStatus("Load failed") return false end
    local data = decodeJSON(text)
    if type(data) ~= "table" then setConfigStatus("Load failed: invalid") return false end
    if not applyConfigTable(data) then setConfigStatus("Load failed: values") return false end
    ConfigStore.Selected = clean
    saveMeta()
    ConfigStore.LastFingerprint = configFingerprint()
    setConfigStatus("Loaded " .. clean)
    if notify then VindUI:Notify({Title = "Configs", Text = "Loaded " .. clean, Type = "success", Duration = 2}) end
    return true
end

local function listConfigProfiles()
    local result, seen = {}, {}
    local function add(name)
        local clean = sanitizeConfigName(name, "default")
        if not seen[clean] then seen[clean] = true table.insert(result, clean) end
    end
    add("default"); add(ConfigStore.Selected)
    if ConfigStore.Available and FS.ListFiles then
        local ok, files = pcall(FS.ListFiles, ConfigStore.Folder)
        if ok and type(files) == "table" then
            for _, file in ipairs(files) do
                local normalized = tostring(file):gsub("\\", "/")
                local name = normalized:match("([^/]+)%.json$")
                if name and name ~= "_meta" then add(name) end
            end
        end
    end
    table.sort(result)
    return result
end

local function deleteConfig(name)
    if not ConfigStore.Available or not FS.DeleteFile then setConfigStatus("Delete unavailable") return false end
    local clean = sanitizeConfigName(name or ConfigStore.Selected, "default")
    local path = configPath(clean)
    if not FS.IsFile(path) then setConfigStatus("Not found " .. clean) return false end
    local ok = pcall(FS.DeleteFile, path)
    if not ok then setConfigStatus("Delete failed") return false end
    if ConfigStore.Selected == clean then ConfigStore.Selected = "default" end
    saveMeta()
    setConfigStatus("Deleted " .. clean)
    return true
end

if ConfigStore.Available then
    ensureConfigFolders()
    loadMeta()
    if ConfigStore.AutoLoad and FS.IsFile(configPath(ConfigStore.Selected)) then
        local ok, text = pcall(FS.Read, configPath(ConfigStore.Selected))
        if ok then
            local data = decodeJSON(text)
            if type(data) == "table" then applyConfigTable(data) end
        end
    end
end

local ActiveDashes = {}
local cachedHRP = nil
local renderConn = nil
local ZERO = Vector3.new()
local DEFAULT_DIR = Vector3.new(0,0,1)

local DirectionOffsets = {
    Front = Vector3.new(0,0,1), Back = Vector3.new(0,0,-1), Left = Vector3.new(-1,0,0), Right = Vector3.new(1,0,0),
    FrontLeft = Vector3.new(-1,0,1).Unit, FrontRight = Vector3.new(1,0,1).Unit,
    LeftBack = Vector3.new(-1,0,-1).Unit, RightBack = Vector3.new(1,0,-1).Unit,
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
    if #ActiveDashes == 0 and renderConn then renderConn:Disconnect() renderConn = nil end
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
        if cfg.animId and id == cfg.animId then match = true
        elseif cfg.animIds then
            if cfg.isDirectional then
                directionName = cfg.animIds[id]
                if directionName then match = true end
            elseif cfg.animIds[id] then match = true end
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

local function setupCharacterDash(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    local animator = hum:WaitForChild("Animator", 5)
    if not animator then return end
    cachedHRP = char:WaitForChild("HumanoidRootPart", 5)
    if not cachedHRP then return end
    animator.AnimationPlayed:Connect(onAnimationPlayed)
end

if player.Character then setupCharacterDash(player.Character) end
player.CharacterAdded:Connect(setupCharacterDash)

getgenv().destroyed = false
getgenv().connections = {}

local function addConnection(connection)
    table.insert(getgenv().connections, connection)
    return connection
end

local guiParent = player:FindFirstChildOfClass("PlayerGui")
if not guiParent then guiParent = player:WaitForChild("PlayerGui", 10) end
if not guiParent and gethui then
    local ok, result = pcall(gethui)
    if ok and result then guiParent = result end
end
if not guiParent then guiParent = CoreGui end

local Window = VindUI:CreateWindow({
    Title = "Scared Ware UI",
    Subtitle = "Azure Latch | v0.3",
    Icon = "Lucide:ghost",
    Size = UDim2.fromOffset(660, 500),
    MinSize = Vector2.new(500, 360),
    Draggable = true,
    Resizable = true,
    UseBlur = true,
    DefaultTab = "Home",
    TabWidth = 130,
    TabScrollbar = true,
    UserInfo = getgenv().CONFIG.UserInfo,
})

VindUI:Notify({ Title = "Scared Ware UI", Text = "Azure Latch v0.3 loaded", Type = "success", Duration = 4 })

getgenv().CombatGroup = Window:AddTabGroup({Name = "COMBAT"})
getgenv().SkillsGroup = Window:AddTabGroup({Name = "SKILLS"})
getgenv().BallGroup = Window:AddTabGroup({Name = "BALL"})
getgenv().WorldGroup = Window:AddTabGroup({Name = "WORLD"})
getgenv().SystemGroup = Window:AddTabGroup({Name = "SYSTEM"})

getgenv().MovementTab   = getgenv().CombatGroup:AddTab({ Name = "Movement", Icon = "Lucide:move-3d" })
getgenv().AutoPlayTab   = getgenv().CombatGroup:AddTab({ Name = "Auto Play", Icon = "Lucide:bot" })
getgenv().LineUpsTab    = getgenv().CombatGroup:AddTab({ Name = "Line Ups", Icon = "Lucide:target" })
getgenv().GoalkeeperTab = getgenv().CombatGroup:AddTab({ Name = "Goalkeeper", Icon = "Lucide:shield" })

getgenv().MovesetsTab   = getgenv().SkillsGroup:AddTab({ Name = "Movesets", Icon = "Lucide:wand-sparkles" })
getgenv().PassingTab    = getgenv().SkillsGroup:AddTab({ Name = "Passing", Icon = "Lucide:radio-tower" })

getgenv().BallControlTab = getgenv().BallGroup:AddTab({ Name = "Ball Control", Icon = "Lucide:circle-dot" })
getgenv().PlayersTab     = getgenv().BallGroup:AddTab({ Name = "Players", Icon = "Lucide:users" })

getgenv().TeleportsTab  = getgenv().WorldGroup:AddTab({ Name = "Teleports", Icon = "Lucide:map-pin" })
getgenv().WorldTab      = getgenv().WorldGroup:AddTab({ Name = "World", Icon = "Lucide:globe" })
getgenv().DubsTab       = getgenv().WorldGroup:AddTab({ Name = "Dubs", Icon = "Lucide:volume-2" })
getgenv().ExploitsTab   = getgenv().WorldGroup:AddTab({ Name = "Exploits", Icon = "Lucide:shield-alert" })

getgenv().HomeTab     = getgenv().SystemGroup:AddTab({ Name = "Home", Icon = "Lucide:layout-dashboard" })
getgenv().ServerTab   = getgenv().SystemGroup:AddTab({ Name = "Server", Icon = "Lucide:server" })
getgenv().MiscTab     = getgenv().SystemGroup:AddTab({ Name = "Misc", Icon = "Lucide:more-horizontal" })
getgenv().SettingsTab = getgenv().SystemGroup:AddTab({ Name = "Settings", Icon = "Lucide:settings" })
getgenv().ConfigTab   = getgenv().SystemGroup:AddTab({ Name = "Configs", Icon = "Lucide:save" })

local swSuppressNotifs = false
local function swNotify(title, text, dur)
    if swSuppressNotifs then return end
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = dur or 2 })
    end)
end
getgenv().swNotify = swNotify
getgenv().swSuppressNotifs = function(v) swSuppressNotifs = v end
getgenv().MovementTab:AddSection("Universal Movement Buffs", "Lucide:move-3d")
getgenv().MovementTab:AddLabel("Set sliders to 0 to disable")

getgenv().MovementTab:AddSlider({ Text = "Tackle Distance", Min = 0, Max = 75, Default = Distances.tackleDist, Increment = 1, Flag = "SW_tackleDist", Callback = function(v) Distances.tackleDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Rush Distance", Min = 0, Max = 75, Default = Distances.rushDist, Increment = 1, Flag = "SW_rushDist", Callback = function(v) Distances.rushDist = v end })
getgenv().MovementTab:AddSlider({ Text = "GK Front Dive", Min = 0, Max = 75, Default = Distances.gkDist, Increment = 1, Flag = "SW_gkDist", Callback = function(v) Distances.gkDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Naruhaya Footwork", Min = 0, Max = 200, Default = Distances.naruhayaDist, Increment = 1, Flag = "SW_naruhayaDist", Callback = function(v) Distances.naruhayaDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Raumdeuter", Min = 0, Max = 200, Default = Distances.raumDist, Increment = 1, Flag = "SW_raumDist", Callback = function(v) Distances.raumDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Draconic Rush", Min = 0, Max = 200, Default = Distances.dracDist, Increment = 1, Flag = "SW_dracDist", Callback = function(v) Distances.dracDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Step Overs", Min = 0, Max = 200, Default = Distances.stepDist, Increment = 1, Flag = "SW_stepDist", Callback = function(v) Distances.stepDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Kaiser Off Ball", Min = 0, Max = 200, Default = Distances.kaiserDist, Increment = 1, Flag = "SW_kaiserDist", Callback = function(v) Distances.kaiserDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Occlusion Break", Min = 0, Max = 200, Default = Distances.occlusionDist, Increment = 1, Flag = "SW_occlusionDist", Callback = function(v) Distances.occlusionDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Diving Header", Min = 0, Max = 125, Default = Distances.divingDist, Increment = 1, Flag = "SW_divingDist", Callback = function(v) Distances.divingDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Reflex Tackle", Min = 0, Max = 125, Default = Distances.reflexDist, Increment = 1, Flag = "SW_reflexDist", Callback = function(v) Distances.reflexDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Razor Break", Min = 0, Max = 35, Default = Distances.razorDist, Increment = 1, Flag = "SW_razorDist", Callback = function(v) Distances.razorDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Drag Scissors", Min = 0, Max = 100, Default = Distances.dragDist, Increment = 1, Flag = "SW_dragDist", Callback = function(v) Distances.dragDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Hero Instinct", Min = 0, Max = 300, Default = Distances.instinctDist, Increment = 1, Flag = "SW_instinctDist", Callback = function(v) Distances.instinctDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Zombie Dribble", Min = 0, Max = 250, Default = Distances.zombDist, Increment = 1, Flag = "SW_zombDist", Callback = function(v) Distances.zombDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Beautiful Destruction", Min = 0, Max = 33, Default = Distances.beautifulDist, Increment = 1, Flag = "SW_beautifulDist", Callback = function(v) Distances.beautifulDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Creative (Side)", Min = 0, Max = 25, Default = Distances.creativeDist, Increment = 1, Flag = "SW_creativeDist", Callback = function(v) Distances.creativeDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Nutmeg Reflex", Min = 0, Max = 50, Default = Distances.reflexNutmegDist, Increment = 1, Flag = "SW_reflexNutmegDist", Callback = function(v) Distances.reflexNutmegDist = v end })
getgenv().MovementTab:AddSlider({ Text = "King's Path", Min = 0, Max = 750, Default = Distances.kingsDist, Increment = 1, Flag = "SW_kingsDist", Callback = function(v) Distances.kingsDist = v end })
getgenv().MovementTab:AddSlider({ Text = "DEVOUR", Min = 0, Max = 500, Default = Distances.devourMaxDist, Increment = 1, Flag = "SW_devourMaxDist", Callback = function(v) Distances.devourMaxDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Control (Ground)", Min = 0, Max = 30, Default = Distances.controlVarDist, Increment = 1, Flag = "SW_controlVarDist", Callback = function(v) Distances.controlVarDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Mach Cut-In", Min = 0, Max = 200, Default = Distances.machDist, Increment = 1, Flag = "SW_machDist", Callback = function(v) Distances.machDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Golden Zone (Req Ball)", Min = 0, Max = 400, Default = Distances.goldenDist, Increment = 1, Flag = "SW_goldenDist", Callback = function(v) Distances.goldenDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Twin Steps", Min = 0, Max = 75, Default = Distances.twinStepsDist, Increment = 1, Flag = "SW_twinStepsDist", Callback = function(v) Distances.twinStepsDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Glacial Cut", Min = 0, Max = 175, Default = Distances.glacialDist, Increment = 1, Flag = "SW_glacialDist", Callback = function(v) Distances.glacialDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Close Quarter Dribble", Min = 0, Max = 250, Default = Distances.quarterDist, Increment = 1, Flag = "SW_quarterDist", Callback = function(v) Distances.quarterDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Go-Go!", Min = 0, Max = 100, Default = Distances.gogoDist, Increment = 1, Flag = "SW_gogoDist", Callback = function(v) Distances.gogoDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Guard Dog", Min = 0, Max = 100, Default = Distances.guardDist, Increment = 1, Flag = "SW_guardDist", Callback = function(v) Distances.guardDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Speedy Turn", Min = 0, Max = 250, Default = Distances.speedyDist, Increment = 1, Flag = "SW_speedyDist", Callback = function(v) Distances.speedyDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Fetch", Min = 0, Max = 100, Default = Distances.fetchDist, Increment = 1, Flag = "SW_fetchDist", Callback = function(v) Distances.fetchDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Silent Steal", Min = 0, Max = 125, Default = Distances.silentDist, Increment = 1, Flag = "SW_silentDist", Callback = function(v) Distances.silentDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Corvine", Min = 0, Max = 100, Default = Distances.corvineDist, Increment = 1, Flag = "SW_corvineDist", Callback = function(v) Distances.corvineDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Kusarigama", Min = 0, Max = 75, Default = Distances.kusarDist, Increment = 1, Flag = "SW_kusarDist", Callback = function(v) Distances.kusarDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Shadow Step", Min = 0, Max = 50, Default = Distances.shadowDist, Increment = 1, Flag = "SW_shadowDist", Callback = function(v) Distances.shadowDist = v end })

getgenv().MovementTab:AddDivider()
getgenv().MovementTab:AddSection("Trap Buffs", "Lucide:move-vertical")

local trapEnabled = false
local trapDist = 0
local trapSpeed = 100
local trapVertical = 0

local trapAnims = {
    "rbxassetid://73387016994281", "rbxassetid://101043441232233",
    "rbxassetid://96593185131882", "rbxassetid://116422938520670",
    "rbxassetid://90734196141468", "rbxassetid://85349589701503",
    "rbxassetid://120351399679118",
}

getgenv().MovementTab:AddToggle({
    Text = "Enable Trap Buffs",
    Description = "Gate for trap buffs",
    Icon = "Lucide:power",
    Flag = "SW_trapEnabled",
    Default = false,
    Callback = function(v)
        trapEnabled = v
        if not v then
            ActiveDashes = {}
            if renderConn then renderConn:Disconnect() renderConn = nil end
        end
    end,
})

getgenv().MovementTab:AddSlider({ Text = "Extra Trap Distance", Min = 0, Max = 500, Default = 0, Increment = 1, Flag = "SW_trapDist", Callback = function(v) trapDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Extra Trap Speed", Min = 0, Max = 1000, Default = 100, Increment = 1, Flag = "SW_trapSpeed", Callback = function(v) trapSpeed = v end })
getgenv().MovementTab:AddSlider({ Text = "Trap Vertical", Min = -100, Max = 100, Default = 0, Increment = 1, Flag = "SW_trapVertical", Callback = function(v) trapVertical = v end })

addConnection(RunService.RenderStepped:Connect(function(dt)
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
end))

getgenv().MovementTab:AddDivider()
getgenv().MovementTab:AddSection("Trap Helper", "Lucide:target")

local trapHelperState = { enabled = false, active = false, track = nil, ball = nil, conn = nil, alignOri = nil }
local trapHelperMaxDist = 50
local trapHelperSpeed = 50

local function findBall()
    local t = workspace.Terrain
    if t then
        local b = t:FindFirstChild("Ball")
        if b and b:IsA("BasePart") then return b end
    end
end

local function cleanupTrapHelper()
    if trapHelperState.conn then trapHelperState.conn:Disconnect() trapHelperState.conn = nil end
    trapHelperState.active = false
    trapHelperState.track = nil
    trapHelperState.ball = nil
    if trapHelperState.alignOri then trapHelperState.alignOri:Destroy() trapHelperState.alignOri = nil end
end

local function startLerpToBall(hrp, ball, track)
    if (ball.Position - hrp.Position).Magnitude > trapHelperMaxDist then return end
    trapHelperState.ball = ball
    trapHelperState.track = track
    trapHelperState.active = true
    if trapHelperState.alignOri then trapHelperState.alignOri:Destroy() end
    local ao = Instance.new("AlignOrientation")
    ao.Name = "SW_TrapFaceAlign"
    ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
    ao.Attachment0 = hrp:FindFirstChild("RootAttachment") or Instance.new("Attachment", hrp)
    ao.RigidityEnabled = false
    ao.MaxTorque = 20000
    ao.Responsiveness = 1000
    ao.Parent = hrp
    trapHelperState.alignOri = ao
    if trapHelperState.conn then trapHelperState.conn:Disconnect() end
    trapHelperState.conn = RunService.RenderStepped:Connect(function(dt)
        if not trapHelperState.track or not trapHelperState.track.IsPlaying then cleanupTrapHelper() return end
        if not trapHelperState.ball or not trapHelperState.ball.Parent then cleanupTrapHelper() return end
        local cur = hrp.Position
        local tgt = trapHelperState.ball.Position - Vector3.new(0, 3, 0)
        local dir = tgt - cur
        local dist = dir.Magnitude
        if dist > trapHelperMaxDist or dist < 0.5 then cleanupTrapHelper() return end
        local move = dir.Unit * (trapHelperSpeed * dt)
        hrp.CFrame = CFrame.new(cur + move) * hrp.CFrame.Rotation
        local ballFlat = Vector3.new(trapHelperState.ball.Position.X, hrp.Position.Y, trapHelperState.ball.Position.Z)
        if trapHelperState.alignOri then trapHelperState.alignOri.CFrame = CFrame.lookAt(hrp.Position, ballFlat) end
    end)
    track.Stopped:Connect(cleanupTrapHelper)
end

local function hookTrapHelper(char)
    local animator = char:WaitForChild("Humanoid"):WaitForChild("Animator")
    local hrp2 = char:WaitForChild("HumanoidRootPart")
    animator.AnimationPlayed:Connect(function(track)
        if not trapHelperState.enabled then return end
        if not track.Animation then return end
        local id = track.Animation.AnimationId
        for _, animId in ipairs(trapAnims) do
            if id == animId then
                task.delay(0.05, function()
                    if track.IsPlaying then
                        local ball = findBall()
                        if ball then startLerpToBall(hrp2, ball, track) end
                    end
                end)
                break
            end
        end
    end)
end

if player.Character then hookTrapHelper(player.Character) end
player.CharacterAdded:Connect(hookTrapHelper)

getgenv().MovementTab:AddToggle({
    Text = "Trap Helper",
    Description = "Moves you toward ball during trap anims.",
    Icon = "Lucide:target",
    Flag = "SW_trapHelper",
    Default = false,
    Callback = function(v)
        trapHelperState.enabled = v
        swNotify("Trap Helper", v and "Enabled." or "Disabled.", 2)
    end,
})

getgenv().MovementTab:AddSlider({ Text = "Trap Helper Max Distance", Min = 50, Max = 200, Default = 50, Increment = 1, Flag = "SW_trapHelperMaxDist", Callback = function(v) trapHelperMaxDist = v end })
getgenv().MovementTab:AddSlider({ Text = "Trap Helper Speed", Min = 50, Max = 1000, Default = 50, Increment = 1, Flag = "SW_trapHelperSpeed", Callback = function(v) trapHelperSpeed = v end })

getgenv().MovementTab:AddDivider()
getgenv().MovementTab:AddSection("Movement Modifiers", "Lucide:gauge")

local jumpOriginal = nil
local jumpLastHumanoid = nil

local function captureJumpOriginal(hum)
    if not hum or jumpLastHumanoid == hum then return end
    jumpLastHumanoid = hum
    jumpOriginal = { JumpPower = hum.JumpPower, JumpHeight = hum.JumpHeight, UseJumpPower = hum.UseJumpPower }
end

local function restoreJumpOriginal(hum)
    if not hum or not jumpOriginal then return end
    hum.UseJumpPower = jumpOriginal.UseJumpPower
    if jumpOriginal.UseJumpPower then
        hum.JumpPower = jumpOriginal.JumpPower
    else
        hum.JumpHeight = jumpOriginal.JumpHeight
    end
end

addConnection(RunService.RenderStepped:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then jumpLastHumanoid = nil return end
    captureJumpOriginal(hum)
    if Config.Movement.JumpEnabled then
        hum.UseJumpPower = true
        hum.JumpPower = Config.Movement.JumpValue
    else
        restoreJumpOriginal(hum)
    end
    if Config.Movement.WalkSpeedEnabled then
        hum.WalkSpeed = Config.Movement.WalkSpeedValue
    end
end))

getgenv().MovementTab:AddToggle({
    Text = "Enable Speed Override",
    Icon = "Lucide:gauge",
    Flag = "SW_walkEnabled",
    Default = false,
    Callback = function(v)
        Config.Movement.WalkSpeedEnabled = v
        if not v then
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end,
})

getgenv().MovementTab:AddSlider({ Text = "Walk Speed", Min = 16, Max = 200, Default = 16, Increment = 1, Flag = "SW_walkSpeed", Suffix = " studs/s", Callback = function(v) Config.Movement.WalkSpeedValue = v end })

getgenv().MovementTab:AddToggle({
    Text = "Enable Jump Override",
    Icon = "Lucide:arrow-up-circle",
    Flag = "SW_jumpEnabled",
    Default = false,
    Callback = function(v) Config.Movement.JumpEnabled = v end,
})

getgenv().MovementTab:AddSlider({ Text = "Jump Power", Min = 50, Max = 300, Default = 50, Increment = 5, Flag = "SW_jumpValue", Callback = function(v) Config.Movement.JumpValue = v end })
getgenv().AutoPlayTab:AddSection("Auto Goal", "Lucide:goal")

local autoGoalState = { enabled = false, conn = nil }

getgenv().AutoPlayTab:AddToggle({
    Text = "Auto Goal",
    Description = "Auto-scoring: disables collisions + teleports + kicks",
    Icon = "Lucide:goal",
    Flag = "SW_autoGoal",
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

            local function stealBallLoop()
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
                    stealBallLoop()
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
            if autoGoalState.conn then autoGoalState.conn:Disconnect() autoGoalState.conn = nil end
        end
    end,
})

getgenv().AutoPlayTab:AddDivider()
getgenv().AutoPlayTab:AddSection("Auto Dribble / Counter", "Lucide:sparkles")

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
    useClosestTeammate = false,
}

local tackle_anim = {
    "rbxassetid://109744655458082", "rbxassetid://113088324958896",
    "rbxassetid://96801747244950", "rbxassetid://130345228612384",
    "rbxassetid://82417661349987",
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
            local hrp2 = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp2 then
                local distSq = (pPos - hrp2.Position).Magnitude ^ 2
                if distSq < closestDistSq then closestDistSq = distSq closest = plr end
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

local function setupPlayerCounter(plr)
    if plr == player then return end
    local function onCharAdded(char)
        local humanoid = char:WaitForChild("Humanoid", 6)
        if not humanoid then return end
        local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:WaitForChild("Animator", 4)
        if not animator then return end
        animator.AnimationPlayed:Connect(function(animTrack)
            local isTackle = false
            for _, id in ipairs(tackle_anim) do
                if animTrack.Animation.AnimationId == id then isTackle = true break end
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
                if root and targetHRP and (root.Position - targetHRP.Position).Magnitude > autoSkillState.mCD then return end
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

for _, plr in ipairs(Players:GetPlayers()) do setupPlayerCounter(plr) end
Players.PlayerAdded:Connect(setupPlayerCounter)

getgenv().AutoPlayTab:AddToggle({ Text = "Auto Dribble", Icon = "Lucide:wind", Flag = "SW_autoDribble", Default = false, Callback = function(v) autoSkillState.toggleDribble = v end })
getgenv().AutoPlayTab:AddToggle({ Text = "Auto Counter (Move 1)", Icon = "Lucide:sword", Flag = "SW_autoCounter1", Default = false, Callback = function(v) autoSkillState.toggleCounter1 = v end })
getgenv().AutoPlayTab:AddToggle({ Text = "Auto Counter (Move 2)", Icon = "Lucide:sword", Flag = "SW_autoCounter2", Default = false, Callback = function(v) autoSkillState.toggleCounter2 = v end })
getgenv().AutoPlayTab:AddToggle({ Text = "Auto Counter (Move 3)", Icon = "Lucide:sword", Flag = "SW_autoCounter3", Default = false, Callback = function(v) autoSkillState.toggleCounter3 = v end })
getgenv().AutoPlayTab:AddToggle({ Text = "Auto Counter (Move 4)", Icon = "Lucide:sword", Flag = "SW_autoCounter4", Default = false, Callback = function(v) autoSkillState.toggleCounter4 = v end })
getgenv().AutoPlayTab:AddToggle({ Text = "Auto Counter (Move 5)", Icon = "Lucide:sword", Flag = "SW_autoCounter5", Default = false, Callback = function(v) autoSkillState.toggleCounter5 = v end })
getgenv().AutoPlayTab:AddToggle({ Text = "T Special", Icon = "Lucide:star", Flag = "SW_autoTSpecial", Default = false, Callback = function(v) autoSkillState.toggleTSpecial = v end })
getgenv().AutoPlayTab:AddToggle({ Text = "Use Closest Teammate", Icon = "Lucide:users", Flag = "SW_useClosest", Default = false, Callback = function(v) autoSkillState.useClosestTeammate = v end })
getgenv().AutoPlayTab:AddSlider({ Text = "Counter Radius", Min = 25, Max = 75, Default = 65, Increment = 1, Flag = "SW_counterRadius", Suffix = " studs", Callback = function(v) autoSkillState.mCD = v end })

getgenv().AutoPlayTab:AddDivider()
getgenv().AutoPlayTab:AddSection("Air Dribble", "Lucide:wind")

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

getgenv().AutoPlayTab:AddToggle({ Text = "Air Dribble", Icon = "Lucide:wind", Flag = "SW_airDribble", Default = false, Callback = function(v) airDribState.enabled = v end })
getgenv().AutoPlayTab:AddKeybind({ Text = "Air Dribble Bind", Flag = "SW_airDribbleBind", Default = Enum.KeyCode.LeftAlt, Callback = function(key, kind) if key then airDribState.bind = key end end })

local holdingConn = nil
addConnection(UserInputService.InputBegan:Connect(function(input, gp)
    if gp or input.KeyCode ~= airDribState.bind then return end
    if not airDribState.enabled then return end
    airDribState.isHolding = true
    doAirDribble()
    if holdingConn then holdingConn:Disconnect() end
    holdingConn = RunService.Heartbeat:Connect(function()
        if airDribState.isHolding and airDribState.enabled then doAirDribble()
        else holdingConn:Disconnect() holdingConn = nil end
    end)
end))

addConnection(UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == airDribState.bind then airDribState.isHolding = false end
end))

getgenv().AutoPlayTab:AddDivider()
getgenv().AutoPlayTab:AddSection("Auto Activate", "Lucide:zap")

local autoActState = { enabled = false, dist = 10, moveNum = 1, db = true, minHeight = 0 }

getgenv().AutoPlayTab:AddToggle({ Text = "Auto Activate Skill", Icon = "Lucide:zap", Flag = "SW_autoActivate", Default = false, Callback = function(v) autoActState.enabled = v end })
getgenv().AutoPlayTab:AddSlider({ Text = "Distance", Min = 3, Max = 70, Default = 10, Increment = 0.5, Flag = "SW_autoActivateDist", Suffix = " studs", Callback = function(v) autoActState.dist = v end })
getgenv().AutoPlayTab:AddSlider({ Text = "Min Ball Height", Min = 0, Max = 50, Default = 0, Increment = 0.5, Flag = "SW_autoActivateHeight", Callback = function(v) autoActState.minHeight = v end })
getgenv().AutoPlayTab:AddTextbox({ Text = "Skill Number (1-5)", Flag = "SW_autoActivateSkill", Default = "1", Callback = function(t)
    local n = tonumber(t)
    if n and n >= 1 and n <= 5 then autoActState.moveNum = n end
end })

addConnection(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then autoActState.db = false end
end))

addConnection(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then autoActState.db = true end
end))

addConnection(RunService.RenderStepped:Connect(function()
    if not autoActState.enabled or autoActState.db then return end
    local char = player.Character
    local hrp2 = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp2 then return end
    local ball = workspace.Terrain:FindFirstChild("Ball")
    if not ball then return end
    if (hrp2.Position - ball.Position).Magnitude <= autoActState.dist then
        if autoActState.minHeight > 0 then
            local rel = ball.Position.Y - (hrp2.Position.Y - 2)
            if rel < autoActState.minHeight then return end
        end
        BNR:FireServer(buffer.fromstring(buffers["base"]), {{"skill" .. autoActState.moveNum}})
    end
end))

getgenv().AutoPlayTab:AddDivider()
getgenv().AutoPlayTab:AddSection("Kick Power", "Lucide:zap")

local kickHardState = { enabled = false }

getgenv().AutoPlayTab:AddToggle({
    Text = "Kick Like Kaiser",
    Description = "Forces every kick to max power.",
    Icon = "Lucide:zap",
    Flag = "SW_kickHard",
    Default = false,
    Callback = function(v)
        kickHardState.enabled = v
        swNotify("Kick Power", v and "Enabled." or "Disabled.", 2)
    end,
})

task.spawn(function()
    if type(getrawmetatable) ~= "function" then return end
    if getgenv().__SW_kickHook then return end
    getgenv().__SW_kickHook = true

    local BNR2 = ReplicatedStorage:WaitForChild("ByteNetReliable")
    local rawMeta = getrawmetatable(game)
    local oldIndex = rawMeta.__index
    local oldNamecall = rawMeta.__namecall
    setreadonly(rawMeta, false)

    local function patch(a)
        if not kickHardState.enabled then return end
        local pack = a[1]
        if type(pack) ~= "table" then return end
        for _, sub in pairs(pack) do
            if type(sub) == "table" and sub[1] == "kick" then
                sub[2] = 100
            end
        end
    end

    rawMeta.__index = newcclosure(function(self, key)
        if self == BNR2 and (key == "FireServer" or key == "fireServer") then
            return newcclosure(function(remote, ...)
                local a = { ... }
                patch(a)
                return oldIndex(remote, key)(remote, unpack(a))
            end)
        end
        return oldIndex(self, key)
    end)

    rawMeta.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if self == BNR2 and (method == "FireServer" or method == "fireServer") then
            local a = { ... }
            patch(a)
            return oldNamecall(self, unpack(a))
        end
        return oldNamecall(self, ...)
    end)

    setreadonly(rawMeta, true)
end)

getgenv().LineUpsTab:AddSection("Line Up Settings", "Lucide:crosshair")

local padCount = 0
local targetCount = 0
local activeLineups = {}
local autoActivateSkillPad = false
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
local lpChar = player.Character
local lpHrp = lpChar and lpChar:FindFirstChild("HumanoidRootPart")
local lpHumanoid = lpChar and lpChar:FindFirstChildOfClass("Humanoid")

local function updateLUCharRefs(char)
    lpChar = char
    lpHrp = char:WaitForChild("HumanoidRootPart")
    lpHumanoid = char:WaitForChild("Humanoid")
end

if player.Character then updateLUCharRefs(player.Character) end
player.CharacterAdded:Connect(updateLUCharRefs)

local function pad(pos, col)
    padCount += 1
    local p = Instance.new("Part")
    p.Name = "sw_pad" .. padCount
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

local function target(pos, col)
    targetCount += 1
    local t = Instance.new("Part")
    t.Name = "sw_target" .. targetCount
    t.Shape = Enum.PartType.Ball
    t.Size = Vector3.new(7, 7, 7)
    t.Position = pos
    t.Transparency = showTargets and targetTransparency or 1
    t.Anchored = true
    t.CanCollide = false
    t.Color = targetColor
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
    autoSkillFired = {}
    aimedPad = nil
    if camLockConnection then camLockConnection:Disconnect() camLockConnection = nil end
end
getgenv().swClearLineups = clearLineups

local function getPadUnderPlayer()
    if not lpHrp then return nil end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {lpChar}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(lpHrp.Position, Vector3.new(0, -6, 0), params)
    if result and result.Instance then
        return result.Instance.Name:match("^sw_pad(%d+)$")
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

addConnection(RunService.RenderStepped:Connect(function()
    if not lpHrp or not lpHumanoid then return end
    local padIndex = getPadUnderPlayer()
    if not padIndex then
        if aimedPad then aimedPad = nil stopCamLock() end
        return
    end
    local targetPart = workspace:FindFirstChild("sw_target" .. padIndex)
    if not targetPart then return end
    if autoAim then
        lpHrp.CFrame = CFrame.lookAt(lpHrp.Position, Vector3.new(targetPart.Position.X, lpHrp.Position.Y, targetPart.Position.Z))
        if aimedPad ~= padIndex then
            aimedPad = padIndex
            startCamLock(targetPart)
        end
    end
    if autoActivateSkillPad and not autoSkillFired[padIndex] then
        autoSkillFired[padIndex] = true
        BNR:FireServer(buffer.fromstring(buffers["base"]), {{"skill" .. skillNumber}})
        task.delay(1, function() autoSkillFired[padIndex] = nil end)
    end
end))

getgenv().LineUpsTab:AddToggle({ Text = "Show Targets", Flag = "SW_showTargets", Default = true, Callback = function(v)
    showTargets = v
    for _, obj in ipairs(activeLineups) do
        if obj and obj.Parent and obj.Name:match("^sw_target") then
            obj.Transparency = v and targetTransparency or 1
        end
    end
end })

getgenv().LineUpsTab:AddToggle({ Text = "Auto Aim On Pad", Icon = "Lucide:crosshair", Flag = "SW_lineupAutoAim", Default = false, Callback = function(v)
    autoAim = v
    if not v then aimedPad = nil stopCamLock() end
end })

getgenv().LineUpsTab:AddToggle({ Text = "Auto Activate Skill On Pad", Icon = "Lucide:zap", Flag = "SW_lineupAutoSkill", Default = false, Callback = function(v) autoActivateSkillPad = v end })

getgenv().LineUpsTab:AddTextbox({ Text = "Skill Number (1-5)", Flag = "SW_lineupSkillNum", Default = "1", Callback = function(text)
    local num = tonumber(text)
    if num and num >= 1 and num <= 5 then skillNumber = num end
end })

getgenv().LineUpsTab:AddColorPicker({ Text = "Pad Color", Flag = "SW_lineupPadColor", Default = Color3.fromRGB(255,0,0), Callback = function(c) padColor = c end })
getgenv().LineUpsTab:AddColorPicker({ Text = "Target Color", Flag = "SW_lineupTargetColor", Default = Color3.fromRGB(0,255,0), Callback = function(c) targetColor = c end })

getgenv().LineUpsTab:AddSlider({ Text = "Pad Transparency", Min = 0, Max = 1, Default = 0.65, Increment = 0.05, Flag = "SW_lineupPadTrans", Callback = function(v)
    padTransparency = v
    for _, obj in ipairs(activeLineups) do
        if obj and obj.Parent and obj.Name:match("^sw_pad") then obj.Transparency = v end
    end
end })

getgenv().LineUpsTab:AddSlider({ Text = "Target Transparency", Min = 0, Max = 1, Default = 0, Increment = 0.05, Flag = "SW_lineupTargetTrans", Callback = function(v)
    targetTransparency = v
    for _, obj in ipairs(activeLineups) do
        if obj and obj.Parent and obj.Name:match("^sw_target") then
            obj.Transparency = showTargets and v or 1
        end
    end
end })

getgenv().LineUpsTab:AddDivider()
getgenv().LineUpsTab:AddSection("Preset Line Ups", "Lucide:map-pin")

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

local KAISER_LINEUP = {
    {pad = Vector3.new(-76, -9, 140), target = Vector3.new(108, 19, 14)},
    {pad = Vector3.new(-35, -9, 178), target = Vector3.new(80, -5, 14)},
    {pad = Vector3.new(17, -9, 170), target = Vector3.new(26, 18, 14)},
    {pad = Vector3.new(81, -9, 178), target = Vector3.new(35, 34, 14)},
    {pad = Vector3.new(54, -9, 165), target = Vector3.new(34, 2, 14)},
    {pad = Vector3.new(-55, -9, 171), target = Vector3.new(87, -1, 14)},
    {pad = Vector3.new(-13, -9, 161), target = Vector3.new(76, 15, 14)},
    {pad = Vector3.new(-42, -9, 122), target = Vector3.new(73, 5, 14)},
    {pad = Vector3.new(61, -9, 114), target = Vector3.new(35, 16, 14)},
    {pad = Vector3.new(130, -9, 110), target = Vector3.new(50, 25, 14)},
    {pad = Vector3.new(110, -9, 151), target = Vector3.new(34, 25, 14)},
    {pad = Vector3.new(39, -9, 194), target = Vector3.new(32, 28, 14)},
    {pad = Vector3.new(76, -9, -140), target = Vector3.new(-108, 19, -14)},
    {pad = Vector3.new(35, -9, -178), target = Vector3.new(-80, -5, -14)},
    {pad = Vector3.new(-17, -9, -170), target = Vector3.new(-26, 18, -14)},
    {pad = Vector3.new(-81, -9, -178), target = Vector3.new(-35, 34, -14)},
    {pad = Vector3.new(-54, -9, -165), target = Vector3.new(-34, 2, -14)},
    {pad = Vector3.new(55, -9, -171), target = Vector3.new(-87, -1, -14)},
    {pad = Vector3.new(13, -9, -161), target = Vector3.new(-76, 15, -14)},
    {pad = Vector3.new(42, -9, -122), target = Vector3.new(-73, 5, -14)},
    {pad = Vector3.new(-61, -9, -114), target = Vector3.new(-35, 16, -14)},
    {pad = Vector3.new(-130, -9, -110), target = Vector3.new(-50, 25, -14)},
    {pad = Vector3.new(-110, -9, -151), target = Vector3.new(-34, 25, -14)},
    {pad = Vector3.new(-39, -9, -194), target = Vector3.new(-32, 28, -14)},
}

local KARASU_LINEUP = {
    {pad = Vector3.new(66, -9, 135), target = Vector3.new(-44, 39, 14)},
    {pad = Vector3.new(24, -9, 159), target = Vector3.new(-70, 19, 13)},
    {pad = Vector3.new(43, -9, 147), target = Vector3.new(-72, 34, 13)},
    {pad = Vector3.new(-12, -9, 160), target = Vector3.new(-23, 25, 14)},
    {pad = Vector3.new(-46, -9, 184), target = Vector3.new(5, 110, 14)},
    {pad = Vector3.new(-76, -9, 160), target = Vector3.new(-6, 74, 14)},
    {pad = Vector3.new(-28, -9, 178), target = Vector3.new(-11, 65, 14)},
    {pad = Vector3.new(-96, -9, 134), target = Vector3.new(-25, 45, 14)},
    {pad = Vector3.new(-47, -9, 142), target = Vector3.new(-19, 18, 14)},
    {pad = Vector3.new(47, -9, 124), target = Vector3.new(-67, 20, 13)},
    {pad = Vector3.new(-66, -9, -135), target = Vector3.new(44, 39, -14)},
    {pad = Vector3.new(-24, -9, -159), target = Vector3.new(70, 19, -13)},
    {pad = Vector3.new(-43, -9, -147), target = Vector3.new(72, 34, -13)},
    {pad = Vector3.new(12, -9, -160), target = Vector3.new(23, 25, -14)},
    {pad = Vector3.new(46, -9, -184), target = Vector3.new(-5, 110, -14)},
    {pad = Vector3.new(76, -9, -160), target = Vector3.new(6, 74, -14)},
    {pad = Vector3.new(28, -9, -178), target = Vector3.new(11, 65, -14)},
    {pad = Vector3.new(96, -9, -134), target = Vector3.new(25, 45, -14)},
    {pad = Vector3.new(47, -9, -142), target = Vector3.new(19, 18, -14)},
    {pad = Vector3.new(-47, -9, -124), target = Vector3.new(67, 20, -13)},
}

local RIN_LINEUP = {
    {pad = Vector3.new(62, -9, 121), target = Vector3.new(-29, -9, 38)},
    {pad = Vector3.new(35, -9, 150), target = Vector3.new(-26, -9, 50)},
    {pad = Vector3.new(0, -9, 161), target = Vector3.new(-33, 39, 14)},
    {pad = Vector3.new(-28, -9, 154), target = Vector3.new(-16, 28, 14)},
    {pad = Vector3.new(-56, -9, 135), target = Vector3.new(-28, 10, 14)},
    {pad = Vector3.new(21, -9, 161), target = Vector3.new(-40, -6, 13)},
    {pad = Vector3.new(-107, -9, 113), target = Vector3.new(-89, -9, 90)},
    {pad = Vector3.new(-133, -9, 102), target = Vector3.new(-27, 0, 15)},
    {pad = Vector3.new(-78, -9, 128), target = Vector3.new(-27, 9, 17)},
    {pad = Vector3.new(50, -9, 135), target = Vector3.new(-44, -3, 13)},
    {pad = Vector3.new(-62, -9, -121), target = Vector3.new(29, -9, -38)},
    {pad = Vector3.new(-35, -9, -150), target = Vector3.new(26, -9, -50)},
    {pad = Vector3.new(0, -9, -161), target = Vector3.new(33, 39, -14)},
    {pad = Vector3.new(28, -9, -154), target = Vector3.new(16, 28, -14)},
    {pad = Vector3.new(56, -9, -135), target = Vector3.new(28, 10, -14)},
    {pad = Vector3.new(-21, -9, -161), target = Vector3.new(40, -6, -13)},
    {pad = Vector3.new(107, -9, -113), target = Vector3.new(89, -9, -90)},
    {pad = Vector3.new(133, -9, -102), target = Vector3.new(27, 0, -15)},
    {pad = Vector3.new(78, -9, -128), target = Vector3.new(27, 9, -17)},
    {pad = Vector3.new(-50, -9, -135), target = Vector3.new(44, -3, -13)},
}

local RIN_FLOW_LINEUP = {
    {pad = Vector3.new(-134, -9, 266), target = Vector3.new(-73, -9, 74)},
    {pad = Vector3.new(51, -9, 237), target = Vector3.new(-87, 34, 13)},
    {pad = Vector3.new(-189, -9, 192), target = Vector3.new(-65, 24, 13)},
    {pad = Vector3.new(111, -9, 187), target = Vector3.new(-116, 16, 13)},
    {pad = Vector3.new(134, -9, -266), target = Vector3.new(73, -9, -74)},
    {pad = Vector3.new(-51, -9, -237), target = Vector3.new(87, 34, -13)},
    {pad = Vector3.new(189, -9, -192), target = Vector3.new(65, 24, -13)},
    {pad = Vector3.new(-111, -9, -187), target = Vector3.new(116, 16, -13)},
}

local RAINBOW = {
    Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(255,255,0),
    Color3.fromRGB(0,0,255), Color3.fromRGB(255,0,255), Color3.fromRGB(255,182,193),
}

local function createLineUps(goalRelative, colors, swapSides)
    clearLineups()
    local map = workspace:WaitForChild("map")
    local agoal = map:FindFirstChild("Agoal")
    local bgoal = map:FindFirstChild("Bgoal")
    if not agoal or not bgoal then return end
    for i, entry in ipairs(goalRelative) do
        local useA = (i <= #goalRelative/2)
        if swapSides then useA = not useA end
        local basePos = useA and agoal.Position or bgoal.Position
        local col = colors[(i - 1) % #colors + 1]
        pad(basePos + entry.pad, col)
        target(basePos + entry.target, col)
    end
end

getgenv().LineUpsTab:AddToggle({ Text = "Sae Line Ups", Icon = "Lucide:target", Flag = "SW_lineupSae", Default = false, Callback = function(v)
    if v then createLineUps(SAE_LINEUP, RAINBOW, false) else clearLineups() end
end })

getgenv().LineUpsTab:AddToggle({ Text = "Yukimiya Line Ups", Icon = "Lucide:target", Flag = "SW_lineupYuki", Default = false, Callback = function(v)
    if v then createLineUps(YUKI_LINEUP, RAINBOW, false) else clearLineups() end
end })

getgenv().LineUpsTab:AddToggle({ Text = "Kaiser Line Ups", Icon = "Lucide:target", Flag = "SW_lineupKaiser", Default = false, Callback = function(v)
    if v then createLineUps(KAISER_LINEUP, RAINBOW, true) else clearLineups() end
end })

getgenv().LineUpsTab:AddToggle({ Text = "Karasu Line Ups", Icon = "Lucide:target", Flag = "SW_lineupKarasu", Default = false, Callback = function(v)
    if v then createLineUps(KARASU_LINEUP, RAINBOW, true) else clearLineups() end
end })

getgenv().LineUpsTab:AddToggle({ Text = "Rin Line Ups", Icon = "Lucide:target", Flag = "SW_lineupRin", Default = false, Callback = function(v)
    if v then createLineUps(RIN_LINEUP, RAINBOW, true) else clearLineups() end
end })

getgenv().LineUpsTab:AddToggle({ Text = "Rin Flow Line Ups", Icon = "Lucide:target", Flag = "SW_lineupRinFlow", Default = false, Callback = function(v)
    if v then createLineUps(RIN_FLOW_LINEUP, RAINBOW, true) else clearLineups() end
end })

getgenv().LineUpsTab:AddDivider()
getgenv().LineUpsTab:AddSection("Line Up Creator", "Lucide:pencil-ruler")

getgenv().LineUpsTab:AddButton({
    Text = "Copy Lineup Code",
    Description = "Logs a lineup at current position & camera target.",
    Icon = "Lucide:clipboard-copy",
    Callback = function()
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp2 = char.HumanoidRootPart
        local cam = workspace.CurrentCamera
        local viewport = cam.ViewportSize
        local ray = cam:ViewportPointToRay(viewport.X/2, viewport.Y/2)
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = { char }
        params.FilterType = Enum.RaycastFilterType.Exclude
        local result = workspace:Raycast(ray.Origin, ray.Direction * 5000, params)
        if not result then return end
        local map = workspace:FindFirstChild("map")
        if not map then return end
        local aGoal = map:FindFirstChild("Agoal")
        local bGoal = map:FindFirstChild("Bgoal")
        if not aGoal or not bGoal then return end
        local distA = (hrp2.Position - aGoal.Position).Magnitude
        local distB = (hrp2.Position - bGoal.Position).Magnitude
        local useA = distA <= distB
        local goalPos = useA and aGoal.Position or bGoal.Position
        local targetOffset = result.Position - goalPos
        local playerOffset = hrp2.Position - goalPos
        local function r(n) return math.round(n) end
        local code = string.format("t(%d,%d,%d)p(%d,%d,%d)%s",
            r(targetOffset.X), r(targetOffset.Y), r(targetOffset.Z),
            r(playerOffset.X), r(playerOffset.Y), r(playerOffset.Z),
            useA and "a" or "b")
        setclipboard(code)
        swNotify("Lineup Copied", code, 5)
    end,
})

local LINEUP_COLORS = {
    Color3.fromRGB(255,0,0), Color3.fromRGB(255,128,0), Color3.fromRGB(255,255,0),
    Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255), Color3.fromRGB(128,0,255),
    Color3.fromRGB(255,0,255), Color3.fromRGB(128,255,0), Color3.fromRGB(120,72,0),
    Color3.fromRGB(255,255,255), Color3.fromRGB(0,0,0),
}

getgenv().LineUpsTab:AddTextbox({
    Text = "Enter Lineup Code(s)",
    Icon = "Lucide:code",
    Flag = "SW_lineupCodeInput",
    Placeholder = "t(..)p(..)a,t(..)p(..)b",
    Default = "",
    Callback = function(text)
        local char = player.Character
        local hrp2 = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp2 then return end
        local map = workspace:FindFirstChild("map")
        if not map then return end
        local agoal = map:FindFirstChild("Agoal")
        local bgoal = map:FindFirstChild("Bgoal")
        if not agoal or not bgoal then return end
        clearLineups()
        local colorIndex = 1
        for tx, ty, tz, px, py, pz, goalLetter in text:gmatch("t%((%-?[%d%.]+),(%-?[%d%.]+),(%-?[%d%.]+)%)p%((%-?[%d%.]+),(%-?[%d%.]+),(%-?[%d%.]+)%)([ab])") do
            local playerOffset = Vector3.new(tonumber(px), tonumber(py) - 3, tonumber(pz))
            local targetOffset = Vector3.new(tonumber(tx), tonumber(ty), tonumber(tz))
            local goalPos = goalLetter == "a" and agoal.Position or bgoal.Position
            local col = LINEUP_COLORS[((colorIndex - 1) % #LINEUP_COLORS) + 1]
            pad(goalPos + playerOffset, col)
            target(goalPos + targetOffset, col)
            colorIndex += 1
        end
        swNotify("Lineups Loaded", tostring(colorIndex - 1) .. " lineup(s) created.", 5)
    end,
})

getgenv().BallControlTab:AddSection("Ball Magnet", "Lucide:magnet")

local bmRadius = 5
local bmState = { active = false }

getgenv().BallControlTab:AddToggle({
    Text = "Enable Ball Magnet",
    Description = "Auto grabs ball when close.",
    Icon = "Lucide:magnet",
    Flag = "SW_ballMagnet",
    Default = false,
    Callback = function(v) bmState.active = v end,
})

getgenv().BallControlTab:AddSlider({
    Text = "Magnet Radius",
    Flag = "SW_ballMagnetRadius",
    Min = 1, Max = 25, Default = 5, Increment = 1,
    Suffix = " studs",
    Callback = function(v) bmRadius = v end,
})

addConnection(RunService.Heartbeat:Connect(function()
    if not bmState.active or bmRadius < 2 then return end
    local ball = workspace.Terrain:FindFirstChild("Ball")
    if not ball then return end
    local char = player.Character
    local hrp2 = char and char:FindFirstChild("HumanoidRootPart")
    if hrp2 and (hrp2.Position - ball.Position).Magnitude <= bmRadius then
        pcall(function() BNR:FireServer(buffer.fromstring(buffers["grabball"])) end)
    end
end))

getgenv().BallControlTab:AddDivider()
getgenv().BallControlTab:AddSection("Steal Ball", "Lucide:hand")

local stealActive = false

local function stealBall(aikuMode, bringBack)
    local hrp2 = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp2 then return end
    if stealActive then stealActive = false return end
    stealActive = true
    local skillName = aikuMode and "skill2" or "tackle"
    local origCF = bringBack and hrp2.CFrame or nil
    local waitTime = aikuMode and 0.7 or 0.05
    task.spawn(function()
        while stealActive and hrp2 and hrp2.Parent and not player.Character:FindFirstChild("Ball") do
            local ball = workspace.Terrain:FindFirstChild("Ball")
            if ball then hrp2.CFrame = CFrame.new(ball.Position) end
            for _, p in ipairs(Players:GetPlayers()) do
                if not stealActive then break end
                if p ~= player then
                    local b = p.Character and p.Character:FindFirstChild("Ball")
                    if b then
                        hrp2.CFrame = b.CFrame
                        BNR:FireServer(buffer.fromstring(buffers["base"]), {{skillName}})
                    end
                end
            end
            task.wait(waitTime)
        end
        if bringBack and stealActive and hrp2 and hrp2.Parent and player.Character:FindFirstChild("Ball") and origCF then
            hrp2.CFrame = origCF
        end
        stealActive = false
    end)
end

getgenv().BallControlTab:AddButton({ Text = "Steal Ball", Icon = "Lucide:hand", Callback = function() stealBall(false, false) end })
getgenv().BallControlTab:AddButton({ Text = "Steal Ball (Aiku)", Icon = "Lucide:zap", Callback = function() stealBall(true, false) end })
getgenv().BallControlTab:AddButton({ Text = "Bring Ball", Icon = "Lucide:undo-2", Callback = function() stealBall(false, true) end })
getgenv().BallControlTab:AddButton({ Text = "Bring Ball (Aiku)", Icon = "Lucide:undo-2", Callback = function() stealBall(true, true) end })

getgenv().BallControlTab:AddDivider()
getgenv().BallControlTab:AddSection("Get Flow", "Lucide:activity")

local flowPartData = {
    LocalPlayer = player,
    ByteNetReliable = BNR,
    flowPart = nil,
    flowActive = false,
    flowConnection = nil,
    originalCFrame = nil,
}

flowPartData.flowPart = Instance.new("Part")
flowPartData.flowPart.Name = "SW_flowPad"
flowPartData.flowPart.Size = Vector3.new(150, 1, 150)
flowPartData.flowPart.Anchored = true
flowPartData.flowPart.CanCollide = true
flowPartData.flowPart.Transparency = 1
flowPartData.flowPart.Position = Vector3.new(-782, 2500, 1262)
flowPartData.flowPart.Parent = workspace

getgenv().BallControlTab:AddButton({
    Text = "Get Flow (Req. Ball)",
    Description = "Click to attempt flow. Click again to cancel.",
    Icon = "Lucide:activity",
    Callback = function()
        local char = player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        if flowPartData.flowActive then
            flowPartData.flowActive = false
            if flowPartData.flowConnection then
                task.cancel(flowPartData.flowConnection)
                flowPartData.flowConnection = nil
            end
            if flowPartData.originalCFrame then root.CFrame = flowPartData.originalCFrame end
            return
        end

        flowPartData.flowActive = true
        flowPartData.originalCFrame = root.CFrame

        root.CFrame = flowPartData.flowPart.CFrame + Vector3.new(0, 5, 0)
        task.wait(0.67)

        flowPartData.flowConnection = task.spawn(function()
            local playerFolder = workspace:WaitForChild("characters"):WaitForChild(player.Name)
            local flow = playerFolder:WaitForChild("state"):WaitForChild("flow")

            local gks = {A = workspace.gks:FindFirstChild("A"), B = workspace.gks:FindFirstChild("B")}
            local preferredGK = nil
            local playerTeam = player.Team
            if playerTeam then
                local teamName = playerTeam.Name:lower()
                if teamName:find("a") or teamName == "red" then preferredGK = gks.A or gks.B
                elseif teamName:find("b") or teamName == "blue" then preferredGK = gks.B or gks.A
                end
            end

            if not preferredGK then
                swNotify("Get Flow", "No AI GK found.", 5)
                if flowPartData.originalCFrame and root and root.Parent then
                    root.CFrame = flowPartData.originalCFrame
                end
                flowPartData.flowActive = false
                return
            end

            while flowPartData.flowActive and flow.Value < 100 do
                for i = 1, 25 do
                    if not flowPartData.flowActive or flow.Value >= 100 then break end
                    BNR:FireServer(buffer.fromstring(buffers["base"]), { { "kick", 1, false, vector.create(0, 1, 0) } })
                    task.wait(0.15)
                end
                if not flowPartData.flowActive or flow.Value >= 100 then break end
                task.wait(0.5)

                if preferredGK then
                    local targetCF = preferredGK.PrimaryPart and preferredGK.PrimaryPart.CFrame or preferredGK:GetPivot()
                    root.CFrame = targetCF + Vector3.new(0, 5, 0)
                end
                task.wait(0.25)

                for i = 1, 2 do
                    if not flowPartData.flowActive or flow.Value >= 100 then break end
                    BNR:FireServer(buffer.fromstring(buffers["base"]), { { "kick", 1, false, vector.create(0, 1, 0) } })
                    task.wait(0.12)
                end
                if not flowPartData.flowActive or flow.Value >= 100 then break end
                task.wait(1)

                local ball = workspace.Terrain:FindFirstChild("Ball") or workspace.Terrain:WaitForChild("Ball", 10)
                if ball then
                    while flowPartData.flowActive and ball.Parent == workspace.Terrain and flow.Value < 100 do
                        root.CFrame = ball.CFrame + Vector3.new(0, 5, 0)
                        task.wait(0.05)
                    end
                end
                if not flowPartData.flowActive or flow.Value >= 100 then break end
                task.wait(0.2)
                root.CFrame = flowPartData.flowPart.CFrame + Vector3.new(0, 5, 0)
                task.wait(0.5)
            end

            task.wait(0.5)
            if flow.Value >= 100 then
                local ball = workspace.Terrain:FindFirstChild("Ball")
                if ball and ball.Parent == workspace.Terrain then
                    while ball.Parent == workspace.Terrain and flowPartData.flowActive do
                        root.CFrame = ball.CFrame + Vector3.new(0, 5, 0)
                        task.wait(0.05)
                    end
                end
            end

            task.wait(0.3)
            if flowPartData.flowActive and root and root.Parent and flowPartData.originalCFrame then
                root.CFrame = flowPartData.originalCFrame
            end
            flowPartData.flowActive = false
            flowPartData.flowConnection = nil
        end)
    end,
})

getgenv().BallControlTab:AddDivider()
getgenv().BallControlTab:AddSection("Always Ball", "Lucide:infinity")

local alwaysBallState = { enabled = false, conn = nil }

getgenv().BallControlTab:AddToggle({
    Text = "Always Ball",
    Description = "Zero gravity + root pinned to ball.",
    Icon = "Lucide:infinity",
    Flag = "SW_alwaysBall",
    Default = false,
    Callback = function(v)
        alwaysBallState.enabled = v
        if v then
            workspace.Gravity = 0
            alwaysBallState.conn = task.spawn(function()
                while alwaysBallState.enabled do
                    local char = player.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local ball = workspace.Terrain:FindFirstChild("Ball")
                    if root and ball then root.CFrame = CFrame.new(ball.Position) end
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
                    task.wait(0.1)
                end
            end)
        else
            workspace.Gravity = 196.2
            if alwaysBallState.conn then task.cancel(alwaysBallState.conn) alwaysBallState.conn = nil end
        end
    end,
})

getgenv().BallControlTab:AddDivider()
getgenv().BallControlTab:AddSection("Break Ball", "Lucide:circle-slash")

getgenv().BallControlTab:AddButton({ Text = "Break Ball (Player Method)", Icon = "Lucide:circle-slash", Callback = function()
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

getgenv().BallControlTab:AddButton({ Text = "Break Ball (Ball Method)", Icon = "Lucide:circle-slash", Callback = function()
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

getgenv().BallControlTab:AddButton({ Text = "Permanent Break Ball", Icon = "Lucide:skull", Callback = function()
    workspace.FallenPartsDestroyHeight = -50000
    player.Character:SetPrimaryPartCFrame(CFrame.new(1, -49999, 1))
end })

getgenv().BallControlTab:AddButton({ Text = "Fix Duplicate Ball", Icon = "Lucide:eraser", Callback = function()
    for _, obj in ipairs(workspace.Terrain:GetDescendants()) do
        if obj:IsA("MeshPart") and obj.Name == "Ball" then obj:Destroy() end
    end
end })

getgenv().BallControlTab:AddDivider()
getgenv().BallControlTab:AddSection("Ball ESP", "Lucide:eye")

local ballESPState = { enabled = false, maxDist = 2000, showDistance = true }
local ballESPTag = nil

getgenv().BallControlTab:AddToggle({
    Text = "Enable Ball ESP",
    Icon = "Lucide:eye",
    Flag = "SW_ballESP",
    Default = false,
    Callback = function(v)
        ballESPState.enabled = v
        if not v and ballESPTag then ballESPTag:Destroy() ballESPTag = nil end
    end,
})

getgenv().BallControlTab:AddSlider({
    Text = "ESP Max Distance",
    Flag = "SW_ballESPDist",
    Min = 100, Max = 5000, Default = 2000, Increment = 100,
    Suffix = " studs",
    Callback = function(v) ballESPState.maxDist = v end,
})

getgenv().BallControlTab:AddToggle({
    Text = "Show Distance",
    Flag = "SW_ballESPShowDist",
    Default = true,
    Callback = function(v) ballESPState.showDistance = v end,
})

addConnection(RunService.RenderStepped:Connect(function()
    if not ballESPState.enabled then return end
    local ball = workspace.Terrain:FindFirstChild("Ball")
    if not ball then
        if ballESPTag then ballESPTag:Destroy() ballESPTag = nil end
        return
    end
    if not ballESPTag or not ballESPTag.Parent then
        ballESPTag = Instance.new("Highlight")
        ballESPTag.Name = "SW_BallESP"
        ballESPTag.FillColor = Config.BallESP.Color
        ballESPTag.FillTransparency = 0.5
        ballESPTag.OutlineColor = Config.BallESP.Color
        ballESPTag.OutlineTransparency = 0
        ballESPTag.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        ballESPTag.Parent = ball
    end
    ballESPTag.Adornee = ball
end))

getgenv().PlayersTab:AddSection("Player List", "Lucide:users")

local playerListState = { enabled = false, maxDist = 500, refreshRate = 0.5 }
local playerListGUI = nil

local function getDistanceToPlayer(plr)
    local char = player.Character
    local hrp2 = char and char:FindFirstChild("HumanoidRootPart")
    local tChar = plr.Character
    local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
    if not hrp2 or not tHrp then return nil end
    return (hrp2.Position - tHrp.Position).Magnitude
end

local function buildPlayerListGUI()
    if playerListGUI and playerListGUI.Parent then playerListGUI:Destroy() end
    playerListGUI = Instance.new("ScreenGui")
    playerListGUI.Name = "_" .. tostring(math.random(100000000, 999999999))
    playerListGUI.ResetOnSpawn = false
    playerListGUI.IgnoreGuiInset = true
    playerListGUI.DisplayOrder = 999990
    playerListGUI.Parent = guiParent

    local frame = Instance.new("Frame")
    frame.Name = "PlayerList"
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.Position = UDim2.new(1, -20, 0, 100)
    frame.Size = UDim2.fromOffset(220, 300)
    frame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Parent = playerListGUI
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 70)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "PLAYERS"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 13
    title.Position = UDim2.fromOffset(12, 8)
    title.Size = UDim2.new(1, -24, 0, 18)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Scroll"
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.Position = UDim2.fromOffset(8, 30)
    scroll.Size = UDim2.new(1, -16, 1, -38)
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll
end

local function refreshPlayerList()
    if not playerListState.enabled then
        if playerListGUI then playerListGUI.Enabled = false end
        return
    end
    if not playerListGUI or not playerListGUI.Parent then buildPlayerListGUI() end
    playerListGUI.Enabled = true

    local scroll = playerListGUI.PlayerList:FindFirstChild("Scroll")
    if not scroll then return end

    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local myTeam = player.Team
    for _, plr in ipairs(Players:GetPlayers()) do
        local dist = getDistanceToPlayer(plr)
        if dist and dist <= playerListState.maxDist then
            local isSameTeam = plr.Team == myTeam
            local row = Instance.new("Frame")
            row.BackgroundColor3 = isSameTeam and Color3.fromRGB(30, 80, 140) or Color3.fromRGB(140, 30, 40)
            row.BackgroundTransparency = 0.7
            row.BorderSizePixel = 0
            row.Size = UDim2.new(1, 0, 0, 26)
            row.Parent = scroll
            local rowCorner = Instance.new("UICorner")
            rowCorner.CornerRadius = UDim.new(0, 5)
            rowCorner.Parent = row

            local nameLabel = Instance.new("TextLabel")
            nameLabel.BackgroundTransparency = 1
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.Text = plr.DisplayName or plr.Name
            nameLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
            nameLabel.TextSize = 12
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            nameLabel.Position = UDim2.fromOffset(8, 0)
            nameLabel.Size = UDim2.new(1, -70, 1, 0)
            nameLabel.Parent = row

            local distLabel = Instance.new("TextLabel")
            distLabel.BackgroundTransparency = 1
            distLabel.Font = Enum.Font.Gotham
            distLabel.Text = string.format("%d", math.floor(dist))
            distLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
            distLabel.TextSize = 11
            distLabel.TextXAlignment = Enum.TextXAlignment.Right
            distLabel.Position = UDim2.new(1, -60, 0, 0)
            distLabel.Size = UDim2.fromOffset(52, 26)
            distLabel.Parent = row
        end
    end
end

getgenv().PlayersTab:AddToggle({
    Text = "Enable Player List",
    Icon = "Lucide:users",
    Flag = "SW_playerList",
    Default = false,
    Callback = function(v)
        playerListState.enabled = v
        if v then refreshPlayerList()
        elseif playerListGUI then playerListGUI.Enabled = false end
    end,
})

getgenv().PlayersTab:AddSlider({
    Text = "Max Distance",
    Flag = "SW_playerListDist",
    Min = 100, Max = 2000, Default = 500, Increment = 50,
    Suffix = " studs",
    Callback = function(v) playerListState.maxDist = v end,
})

task.spawn(function()
    while not getgenv().destroyed do
        task.wait(playerListState.refreshRate)
        if playerListState.enabled then pcall(refreshPlayerList) end
    end
end)

getgenv().PlayersTab:AddDivider()
getgenv().PlayersTab:AddSection("Team Highlighting", "Lucide:users")

local teamHighlightActive = false
local teamHighlightFolder = nil

getgenv().PlayersTab:AddToggle({
    Text = "Team Highlighting",
    Icon = "Lucide:users",
    Flag = "SW_teamHighlight",
    Default = false,
    Callback = function(v)
        teamHighlightActive = v
        if v then
            if teamHighlightFolder then teamHighlightFolder:Destroy() end
            teamHighlightFolder = Instance.new("Folder")
            teamHighlightFolder.Name = "SW_Highlights"
            teamHighlightFolder.Parent = CoreGui
        else
            if teamHighlightFolder then teamHighlightFolder:Destroy() teamHighlightFolder = nil end
        end
    end,
})

addConnection(RunService.Heartbeat:Connect(function()
    if not teamHighlightActive or not teamHighlightFolder then return end
    for _, hl in ipairs(teamHighlightFolder:GetChildren()) do hl:Destroy() end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local color = (p.Team == player.Team) and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(255, 50, 50)
            local hl = Instance.new("Highlight")
            hl.FillColor = color
            hl.FillTransparency = 0.65
            hl.OutlineColor = color
            hl.Adornee = p.Character
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = teamHighlightFolder
        end
    end
end))

getgenv().PlayersTab:AddDivider()
getgenv().PlayersTab:AddSection("IFrame Indicator", "Lucide:circle-dot")

local iframeState = { enabled = false, dots = {} }

getgenv().PlayersTab:AddToggle({
    Text = "IFrame Indicator",
    Icon = "Lucide:circle-dot",
    Flag = "SW_iframeIndicator",
    Default = false,
    Callback = function(v)
        iframeState.enabled = v
        local chars = workspace:FindFirstChild("characters")
        if not chars then return end
        if v then
            task.spawn(function()
                while iframeState.enabled do
                    for _, char in ipairs(chars:GetChildren()) do
                        if not iframeState.dots[char] then
                            local hrp2 = char:FindFirstChild("HumanoidRootPart")
                            if hrp2 then
                                local bill = Instance.new("BillboardGui")
                                bill.Name = "SW_IframeDot"
                                bill.Size = UDim2.new(0, 12, 0, 12)
                                bill.StudsOffset = Vector3.new(0, 3, 0)
                                bill.AlwaysOnTop = true
                                bill.Adornee = hrp2
                                bill.Parent = hrp2
                                local dot = Instance.new("Frame")
                                dot.Size = UDim2.new(0, 6, 0, 6)
                                dot.Position = UDim2.new(0.5, -3, 0.5, -3)
                                dot.BackgroundColor3 = Color3.fromRGB(128, 128, 128)
                                dot.BorderSizePixel = 0
                                dot.Parent = bill
                                iframeState.dots[char] = dot
                            end
                        end
                    end
                    for char, dot in pairs(iframeState.dots) do
                        if char and dot and dot.Parent then
                            local st = char:FindFirstChild("state")
                            local ifr = st and st:FindFirstChild("iframe")
                            if ifr and ifr:IsA("BoolValue") then
                                dot.BackgroundColor3 = ifr.Value and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                            end
                        end
                    end
                    task.wait(0.2)
                end
            end)
        else
            for char, dot in pairs(iframeState.dots) do
                if dot and dot.Parent then dot.Parent:Destroy() end
            end
            iframeState.dots = {}
        end
    end,
})

getgenv().TeleportsTab:AddSection("Field Teleports", "Lucide:map-pin")

getgenv().TeleportsTab:AddButton({ Text = "Middle Field", Icon = "Lucide:map-pin", Callback = function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-540, 3, 1274)
    end
end })

getgenv().TeleportsTab:AddButton({ Text = "Commentator Area", Icon = "Lucide:mic", Callback = function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-6, 2, 3237)
    end
end })

getgenv().TeleportsTab:AddButton({ Text = "Goal Box A", Icon = "Lucide:goal", Callback = function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-537, 3, 1575)
    end
end })

getgenv().TeleportsTab:AddButton({ Text = "Goal Box B", Icon = "Lucide:goal", Callback = function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-534, 3, 974)
    end
end })

getgenv().TeleportsTab:AddButton({ Text = "Safety Spot (Invisible)", Icon = "Lucide:eye-off", Callback = function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-540, 3, 1274)
    end
end })

getgenv().TeleportsTab:AddButton({ Text = "GK Spot A", Icon = "Lucide:shield", Callback = function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-510, 3, 1706)
    end
end })

getgenv().TeleportsTab:AddButton({ Text = "GK Spot B", Icon = "Lucide:shield", Callback = function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-559, 3, 843)
    end
end })

getgenv().TeleportsTab:AddDivider()
getgenv().TeleportsTab:AddSection("Custom Coordinates", "Lucide:crosshair")

local customX, customY, customZ = 0, 3, 0

getgenv().TeleportsTab:AddSlider({ Text = "X", Min = -3000, Max = 3000, Default = 0, Increment = 1, Flag = "SW_tpX", Callback = function(v) customX = v end })
getgenv().TeleportsTab:AddSlider({ Text = "Y", Min = -100, Max = 500, Default = 3, Increment = 1, Flag = "SW_tpY", Callback = function(v) customY = v end })
getgenv().TeleportsTab:AddSlider({ Text = "Z", Min = -3000, Max = 3000, Default = 0, Increment = 1, Flag = "SW_tpZ", Callback = function(v) customZ = v end })

getgenv().TeleportsTab:AddButton({ Text = "Teleport To Coords", Icon = "Lucide:navigation", Callback = function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(customX, customY, customZ)
    end
end })

getgenv().TeleportsTab:AddButton({ Text = "Save Current Position", Icon = "Lucide:save", Callback = function()
    local char = player.Character
    local hrp2 = char and char:FindFirstChild("HumanoidRootPart")
    if hrp2 then
        customX = math.floor(hrp2.Position.X)
        customY = math.floor(hrp2.Position.Y)
        customZ = math.floor(hrp2.Position.Z)
        swNotify("Teleport", string.format("Saved %d, %d, %d", customX, customY, customZ), 2)
    end
end })

getgenv().WorldTab:AddSection("Lighting", "Lucide:sun")

local worldState = { fullbright = false, timeOfDay = 14, timeFrozen = false }
local worldOriginal = nil

local function captureWorldOriginal()
    if worldOriginal then return end
    worldOriginal = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        GlobalShadows = Lighting.GlobalShadows,
    }
end

local function restoreWorldOriginal()
    if not worldOriginal then return end
    for key, value in pairs(worldOriginal) do
        pcall(function() Lighting[key] = value end)
    end
end

getgenv().WorldTab:AddToggle({
    Text = "Fullbright",
    Description = "Removes darkness and fog.",
    Icon = "Lucide:sun",
    Flag = "SW_fullbright",
    Default = false,
    Callback = function(v)
        worldState.fullbright = v
        captureWorldOriginal()
        if v then
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
            Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
            Lighting.Brightness = 2
            Lighting.FogEnd = 1e6
            Lighting.GlobalShadows = false
        else
            restoreWorldOriginal()
        end
    end,
})

getgenv().WorldTab:AddSlider({
    Text = "Time of Day",
    Flag = "SW_timeOfDay",
    Min = 0, Max = 24, Default = 14, Increment = 0.5,
    Suffix = " h",
    Callback = function(v)
        worldState.timeOfDay = v
        if worldState.timeFrozen then
            captureWorldOriginal()
            Lighting.ClockTime = v
        end
    end,
})

getgenv().WorldTab:AddToggle({
    Text = "Freeze Time",
    Icon = "Lucide:clock",
    Flag = "SW_timeFrozen",
    Default = false,
    Callback = function(v)
        worldState.timeFrozen = v
        captureWorldOriginal()
        if v then Lighting.ClockTime = worldState.timeOfDay end
    end,
})

addConnection(RunService.Heartbeat:Connect(function()
    if worldState.timeFrozen then
        pcall(function() Lighting.ClockTime = worldState.timeOfDay end)
    end
end))

getgenv().WorldTab:AddDivider()
getgenv().WorldTab:AddSection("Atmosphere", "Lucide:cloud")

getgenv().WorldTab:AddToggle({
    Text = "No Fog",
    Icon = "Lucide:cloud",
    Flag = "SW_noFog",
    Default = false,
    Callback = function(v)
        captureWorldOriginal()
        if v then
            Lighting.FogEnd = 1e6
            Lighting.FogStart = 0
        else
            Lighting.FogEnd = worldOriginal and worldOriginal.FogEnd or 1000
            Lighting.FogStart = worldOriginal and worldOriginal.FogStart or 0
        end
    end,
})

getgenv().WorldTab:AddColorPicker({
    Text = "Ambient Color",
    Flag = "SW_ambientColor",
    Default = Color3.fromRGB(128, 128, 128),
    Callback = function(c)
        captureWorldOriginal()
        Lighting.Ambient = c
        Lighting.OutdoorAmbient = c
    end,
})

getgenv().WorldTab:AddButton({
    Text = "Reset World",
    Icon = "Lucide:rotate-ccw",
    Callback = function()
        restoreWorldOriginal()
        worldState.fullbright = false
        worldState.timeFrozen = false
        swNotify("World", "Lighting restored.", 2)
    end,
})

getgenv().WorldTab:AddDivider()
getgenv().WorldTab:AddSection("Physics", "Lucide:atom")

getgenv().WorldTab:AddSlider({
    Text = "Gravity",
    Flag = "SW_gravity",
    Min = 0, Max = 400, Default = 196.2, Increment = 5,
    Callback = function(v) workspace.Gravity = v end,
})

getgenv().WorldTab:AddButton({
    Text = "Reset Gravity",
    Icon = "Lucide:rotate-ccw",
    Callback = function() workspace.Gravity = 196.2 end,
})

getgenv().WorldTab:AddDivider()
getgenv().WorldTab:AddSection("Blatant", "Lucide:shield-alert")

local blatantState = { enabled = false, conn = nil }

getgenv().WorldTab:AddToggle({
    Text = "Blatant Mode",
    Description = "Removes goal box collisions.",
    Icon = "Lucide:shield-alert",
    Flag = "SW_blatant",
    Default = false,
    Callback = function(v)
        blatantState.enabled = v
        local map = workspace:FindFirstChild("map")
        if not map then return end
        if v then
            blatantState.conn = RunService.Heartbeat:Connect(function()
                local gk = map:FindFirstChild("gkbarriar")
                if gk then
                    local a = gk:FindFirstChild("Abarriar")
                    local b = gk:FindFirstChild("Bbarriar")
                    if a then a.CanCollide = false end
                    if b then b.CanCollide = false end
                end
                local ag = map:FindFirstChild("Agoal")
                local bg = map:FindFirstChild("Bgoal")
                if ag then ag.CanCollide = false end
                if bg then bg.CanCollide = false end
            end)
        else
            if blatantState.conn then blatantState.conn:Disconnect() blatantState.conn = nil end
            local gk = map:FindFirstChild("gkbarriar")
            if gk then
                if gk:FindFirstChild("Abarriar") then gk.Abarriar.CanCollide = true end
                if gk:FindFirstChild("Bbarriar") then gk.Bbarriar.CanCollide = true end
            end
        end
    end,
})

getgenv().DubsTab:AddSection("Voice Lines", "Lucide:volume-2")

local dubSetting = player:WaitForChild("setting", 10)
local dubCharacters = {}
local dubGlobalFlags = {}
local GLOBAL_FLAGS = { dubVoicelines = true, modifiedVoices = true }

local function prettifyName(flag)
    local s = flag:gsub("^dub_", ""):gsub("^dub", "")
    s = s:gsub("_", " ")
    s = s:gsub("(%a)([%w']*)", function(a, b) return a:upper() .. b:lower() end)
    if s == "" then s = flag end
    return s
end

if dubSetting then
    for _, child in ipairs(dubSetting:GetChildren()) do
        local n = child.Name
        if GLOBAL_FLAGS[n] then
            table.insert(dubGlobalFlags, { Name = n, Flag = n, Obj = child })
        elseif n:lower():find("dub") then
            table.insert(dubCharacters, { Name = prettifyName(n), Flag = n, Obj = child })
        end
    end
    table.sort(dubCharacters, function(a, b) return a.Name < b.Name end)
    table.sort(dubGlobalFlags, function(a, b) return a.Name < b.Name end)
end

local function setAllDubs(value)
    for _, c in ipairs(dubCharacters) do c.Obj.Value = value end
    for _, f in ipairs(dubGlobalFlags) do f.Obj.Value = value end
end

getgenv().DubsTab:AddToggle({
    Text = "Enable All Dubs",
    Icon = "Lucide:volume-2",
    Flag = "SW_allDubs",
    Default = false,
    Callback = function(v)
        setAllDubs(v)
        swNotify("Dubs", v and ("Enabled (" .. #dubCharacters .. ")") or "Disabled", 2)
    end,
})

getgenv().DubsTab:AddDivider()
getgenv().DubsTab:AddSection("Per Character (" .. #dubCharacters .. ")", "Lucide:user")

for _, c in ipairs(dubCharacters) do
    getgenv().DubsTab:AddToggle({
        Text = c.Name,
        Icon = "Lucide:user",
        Flag = "SW_" .. c.Flag,
        Default = c.Obj.Value,
        Callback = function(v) c.Obj.Value = v end,
    })
end

if #dubGlobalFlags > 0 then
    getgenv().DubsTab:AddDivider()
    getgenv().DubsTab:AddSection("Global Flags", "Lucide:flag")
    for _, f in ipairs(dubGlobalFlags) do
        getgenv().DubsTab:AddToggle({
            Text = f.Name,
            Description = "Master voice flag",
            Icon = "Lucide:volume-2",
            Flag = "SW_" .. f.Flag,
            Default = f.Obj.Value,
            Callback = function(v) f.Obj.Value = v end,
        })
    end
end

task.spawn(function()
    local known = {}
    for _, c in ipairs(dubCharacters) do known[c.Flag] = true end
    for _, f in ipairs(dubGlobalFlags) do known[f.Flag] = true end
    while not getgenv().destroyed do
        task.wait(5)
        local s = player:FindFirstChild("setting")
        if s then
            for _, child in ipairs(s:GetChildren()) do
                local n = child.Name
                if not known[n] and (n:lower():find("dub") or n:lower():find("voice")) then
                    known[n] = true
                    warn("[SW] new dub detected: " .. n)
                end
            end
        end
    end
end)

getgenv().MovesetsTab:AddSection("Moveset Presets", "Lucide:wand-sparkles")

local function loadMoveset(url, preset)
    return function()
        if preset then
            for k, v in pairs(preset) do getgenv()[k] = v end
        end
        loadstring(game:HttpGet(url, true))()
    end
end

getgenv().MovesetsTab:AddButton({ Text = "Messi", Icon = "Lucide:star", Callback = loadMoveset("https://raw.githubusercontent.com/jonathabejose-alt/Azure-latch/refs/heads/main/MessiStyle.lua", { DisableWatermark = false, LegitMode = false, ShootSkill = true }) })
getgenv().MovesetsTab:AddButton({ Text = "Ronaldo", Icon = "Lucide:star", Callback = loadMoveset("https://raw.githubusercontent.com/jonathabejose-alt/Azure-latch/refs/heads/main/RonaldoStyle.lua") })
getgenv().MovesetsTab:AddButton({ Text = "SonicEXE", Icon = "Lucide:zap", Callback = loadMoveset("https://raw.githubusercontent.com/jonathabejose-alt/Azure-latch/refs/heads/main/SonicEXE.lua", { HBM = 30 }) })
getgenv().MovesetsTab:AddButton({ Text = "KJ (Req. Shidou)", Icon = "Lucide:sword", Callback = loadMoveset("https://raw.githubusercontent.com/jonathabejose-alt/Azure-latch/refs/heads/main/KJ%20Style.lua", { HBM = 30 }) })
getgenv().MovesetsTab:AddButton({ Text = "Loki", Icon = "Lucide:wand", Callback = loadMoveset("https://raw.githubusercontent.com/jonathabejose-alt/Azure-latch/refs/heads/main/loki.lua") })
getgenv().MovesetsTab:AddButton({ Text = "Aizen", Icon = "Lucide:eye", Callback = loadMoveset("https://raw.githubusercontent.com/jonathabejose-alt/Azure-latch/refs/heads/main/aizenStyle.lua") })

getgenv().MovesetsTab:AddDivider()
getgenv().MovesetsTab:AddSection("Custom Script", "Lucide:code")

getgenv().MovesetsTab:AddTextbox({
    Text = "Script URL",
    Icon = "Lucide:link",
    Flag = "SW_movesetUrl",
    Placeholder = "https://raw.githubusercontent.com/...",
    Default = "",
    Callback = function(url) getgenv().SW_lastMovesetUrl = url end,
})

getgenv().MovesetsTab:AddButton({
    Text = "Load Custom",
    Icon = "Lucide:download",
    Callback = function()
        local url = getgenv().SW_lastMovesetUrl
        if not url or url == "" then
            swNotify("Moveset", "Paste a URL first.", 3)
            return
        end
        local ok, err = pcall(function() loadstring(game:HttpGet(url, true))() end)
        swNotify(ok and "Moveset Loaded" or "Load Failed", ok and "Custom script executed." or tostring(err), 3)
    end,
})

getgenv().PassingTab:AddSection("Infinite Range Passing", "Lucide:radio-tower")

local passingState = { enabled = false, busy = false }
local keyToSkill = {
    [Enum.KeyCode.One] = "skill1",
    [Enum.KeyCode.Two] = "skill2",
    [Enum.KeyCode.Three] = "skill3",
    [Enum.KeyCode.Four] = "skill4",
}

local function getClosestPlayerToCursor()
    local mousePos = UserInputService:GetMouseLocation()
    local closestChar, closestDist = nil, math.huge
    local cam = workspace.CurrentCamera
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Team == player.Team then
            local char = p.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local hrp2 = char and char:FindFirstChild("HumanoidRootPart")
            if hum and hrp2 and hum.Health > 0 then
                local screenPos, onScreen = cam:WorldToViewportPoint(hrp2.Position)
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

addConnection(UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not passingState.enabled or passingState.busy then return end
    if player.Team == game.Teams.lobby then return end
    local skillName = keyToSkill[input.KeyCode]
    if not skillName then return end
    local targetChar = getClosestPlayerToCursor()
    if not targetChar then return end
    passingState.busy = true
    BNR:FireServer(buffer.fromstring(buffers["base"]), {{skillName, targetChar}})
    task.delay(0.1, function() passingState.busy = false end)
end))

getgenv().PassingTab:AddToggle({
    Text = "Infinite Range Passing",
    Description = "Pass to teammate closest to cursor (1-4).",
    Icon = "Lucide:radio-tower",
    Flag = "SW_infinitePass",
    Default = false,
    Callback = function(v) passingState.enabled = v end,
})

getgenv().PassingTab:AddDivider()
getgenv().PassingTab:AddSection("Auto Pass", "Lucide:send")

local autoPassState = { enabled = false, key = Enum.KeyCode.E, cooldown = 0.3, lastPass = 0 }

getgenv().PassingTab:AddToggle({
    Text = "Auto Pass To Nearest",
    Description = "Hold key to auto-pass.",
    Icon = "Lucide:send",
    Flag = "SW_autoPass",
    Default = false,
    Callback = function(v) autoPassState.enabled = v end,
})

getgenv().PassingTab:AddKeybind({
    Text = "Auto Pass Key",
    Flag = "SW_autoPassKey",
    Default = Enum.KeyCode.E,
    Callback = function(key) if key then autoPassState.key = key end end,
})

getgenv().PassingTab:AddSlider({
    Text = "Pass Cooldown",
    Flag = "SW_autoPassCD",
    Min = 0.1, Max = 2.0, Default = 0.3, Increment = 0.05,
    Suffix = " s",
    Callback = function(v) autoPassState.cooldown = v end,
})

addConnection(RunService.Heartbeat:Connect(function()
    if not autoPassState.enabled then return end
    if not UserInputService:IsKeyDown(autoPassState.key) then return end
    local now = tick()
    if now - autoPassState.lastPass < autoPassState.cooldown then return end
    local char = player.Character
    if not char or not char:FindFirstChild("Ball") then return end
    autoPassState.lastPass = now
    local closest = getClosestPlayerToCursor()
    if closest then BNR:FireServer(buffer.fromstring(buffers["base"]), {{"skill1", closest}}) end
end))

getgenv().AutoPlayTab:AddDivider()
getgenv().AutoPlayTab:AddSection("Silent Core", "Lucide:eye-off")

local qteState = { enabled = false }

local function qteConvert(text)
    local m = { ["1"]="One", ["2"]="Two", ["3"]="Three", ["4"]="Four", ["5"]="Five", ["6"]="Six", ["7"]="Seven", ["8"]="Eight", ["9"]="Nine", ["0"]="Zero" }
    return m[text] or text
end

local function qteIsGreen(c)
    return c.G > c.R and c.G > c.B
end

addConnection(RunService.RenderStepped:Connect(function()
    if not qteState.enabled then return end
    if not player:FindFirstChild("PlayerGui") then return end
    local qteGui = player.PlayerGui:FindFirstChild("Qte")
    if qteGui and qteGui:FindFirstChild("QTE") then
        for _, d in ipairs(qteGui.QTE:GetDescendants()) do
            if d:IsA("Frame") or d:IsA("TextLabel") then
                if qteIsGreen(d.BackgroundColor3) then
                    local tl = qteGui.QTE:FindFirstChild("TextLabel")
                    if tl then
                        local keyCode = Enum.KeyCode[qteConvert(tl.Text)]
                        if keyCode then
                            VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
                            VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
                        end
                    end
                    break
                end
            end
        end
    end
end))

getgenv().AutoPlayTab:AddToggle({
    Text = "Auto QuickTimeEvent",
    Description = "Automatically presses QTE keys.",
    Icon = "Lucide:zap",
    Flag = "SW_autoQTE",
    Default = false,
    Callback = function(v) qteState.enabled = v end,
})

local nostunState = { enabled = false }
local function applyNoStun()
    if not nostunState.enabled then return end
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = 40 end
end

addConnection(RunService.RenderStepped:Connect(applyNoStun))

getgenv().AutoPlayTab:AddToggle({
    Text = "No Stun",
    Description = "Overrides stunned state WalkSpeed.",
    Icon = "Lucide:zap-off",
    Flag = "SW_noStun",
    Default = false,
    Callback = function(v)
        nostunState.enabled = v
        if v then applyNoStun() end
    end,
})

local autoStealState = { enabled = false, conns = {} }
local AUTO_STEAL_ANIM = "rbxassetid://76587445975710"

getgenv().AutoPlayTab:AddToggle({
    Text = "Auto Steal Ball",
    Description = "Tackles when opponent plays normal kick anim.",
    Icon = "Lucide:hand",
    Flag = "SW_autoSteal",
    Default = false,
    Callback = function(v)
        autoStealState.enabled = v
        for _, c in ipairs(autoStealState.conns) do pcall(function() c:Disconnect() end) end
        autoStealState.conns = {}
        if not v then return end

        local function hookChar(plr, char)
            local hum = char:WaitForChild("Humanoid", 6)
            if not hum then return end
            local animator = hum:WaitForChild("Animator", 4)
            if not animator then return end
            local c = animator.AnimationPlayed:Connect(function(track)
                if not autoStealState.enabled then return end
                if not track.Animation or track.Animation.AnimationId ~= AUTO_STEAL_ANIM then return end
                local targetHRP = char:FindFirstChild("HumanoidRootPart")
                local myChar = player.Character
                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if not targetHRP or not myHRP then return end
                if (myHRP.Position - targetHRP.Position).Magnitude > 20 then return end
                local start = tick()
                local conn
                conn = RunService.RenderStepped:Connect(function()
                    if not autoStealState.enabled or tick() - start > 0.5 then
                        conn:Disconnect()
                        return
                    end
                    local pos = myHRP.Position
                    local tpos = targetHRP.Position
                    myHRP.CFrame = CFrame.lookAt(pos, Vector3.new(tpos.X, pos.Y, tpos.Z))
                    BNR:FireServer(buffer.fromstring(buffers["base"]), {{"tackle"}})
                end)
            end)
            table.insert(autoStealState.conns, c)
        end

        local function hookPlr(plr)
            if plr == player then return end
            if plr.Character then hookChar(plr, plr.Character) end
            table.insert(autoStealState.conns, plr.CharacterAdded:Connect(function(char) hookChar(plr, char) end))
        end

        for _, p in ipairs(Players:GetPlayers()) do hookPlr(p) end
        table.insert(autoStealState.conns, Players.PlayerAdded:Connect(hookPlr))
    end,
})

getgenv().GoalkeeperTab:AddSection("Auto GK", "Lucide:shield")

local autoGKState = {
    celeron = { running = false, conns = {} },
    daffy = { running = false, conns = {} },
}

local function stopCeleronGK()
    local s = autoGKState.celeron
    s.running = false
    for _, c in ipairs(s.conns) do pcall(function() c:Disconnect() end) end
    s.conns = {}
    if s.look then pcall(function() s.look:Destroy() end) s.look = nil end
    if s.gui then pcall(function() s.gui:Destroy() end) s.gui = nil end
end

local function startCeleronGK()
    local s = autoGKState.celeron
    if s.running then return end
    s.running = true

    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local hrp2 = char:WaitForChild("HumanoidRootPart")

    local gui = Instance.new("ScreenGui")
    gui.Name = "SW_AutoGK"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")
    s.gui = gui
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(1, -26, 1, -26)
    dot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    dot.BorderSizePixel = 0
    dot.Parent = gui
    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(1, 0)
    dc.Parent = dot

    local ballHolder = ReplicatedStorage.workspace.ballHolder
    local map = workspace:WaitForChild("map")
    local terrain = workspace.Terrain
    local GRAVITY = Vector3.new(0, -workspace.Gravity, 0)
    local velSmooth = Vector3.zero
    local lastVel = Vector3.zero
    local tackleArgs = { buffer.fromstring(buffers["base"]), { { "tackle" } } }
    local grabBuf = buffer.fromstring(buffers["grabball"])
    local magnetBurst = false
    local tackleRadius = 35
    local lastHolder = ballHolder.Value
    local paused = false

    local look = Instance.new("AlignOrientation")
    look.Name = "SW_AutoGKLook"
    look.Mode = Enum.OrientationAlignmentMode.OneAttachment
    look.Attachment0 = hrp2:WaitForChild("RootAttachment")
    look.Responsiveness = 1200
    look.MaxTorque = math.huge
    look.Enabled = false
    look.Parent = hrp2
    s.look = look

    local function getBall()
        local b = terrain:FindFirstChild("Ball")
        if not b then b = workspace:FindFirstChild("Ball", true) end
        return b
    end

    table.insert(s.conns, ballHolder.Changed:Connect(function(cur)
        if lastHolder == char and cur == nil then
            paused = true
            task.delay(2.6, function() paused = false end)
        end
        lastHolder = cur
    end))

    table.insert(s.conns, UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.V then
            s.running = not s.running
            dot.BackgroundColor3 = s.running and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            if not s.running then look.Enabled = false end
        end
    end))

    local function predictImpact(pos, vel, accel, goal)
        if not goal then return nil end
        local cf = goal.CFrame
        local n = cf.LookVector
        local rel = pos - cf.Position
        local a = 0.5 * accel:Dot(n)
        local b = vel:Dot(n)
        local c = rel:Dot(n)
        if math.abs(a) < 1e-6 then
            if math.abs(b) < 1e-6 then return nil end
            local t = -c / b
            return t > 0 and t or nil
        end
        local disc = b*b - 4*a*c
        if disc < 0 then return nil end
        local sd = math.sqrt(disc)
        local t1 = (-b - sd) / (2*a)
        local t2 = (-b + sd) / (2*a)
        return (t1 > 0 and t1) or (t2 > 0 and t2)
    end

    table.insert(s.conns, RunService.RenderStepped:Connect(function(dt)
        if not s.running or paused then look.Enabled = false return end
        if player.Team == game.Teams.lobby then look.Enabled = false return end

        local currentHolder = ballHolder.Value
        local ball = getBall()

        if currentHolder and currentHolder ~= char and currentHolder:FindFirstChild("HumanoidRootPart") then
            local hr = currentHolder.HumanoidRootPart
            look.Enabled = true
            look.CFrame = CFrame.lookAt(hrp2.Position, Vector3.new(hr.Position.X, hrp2.Position.Y, hr.Position.Z))
            local dist = (hrp2.Position - hr.Position).Magnitude
            if dist <= tackleRadius then BNR:FireServer(unpack(tackleArgs)) end
        elseif ball then
            local rawVel = ball.AssemblyLinearVelocity
            velSmooth = velSmooth:Lerp(rawVel, math.clamp(dt*15, 0, 1))
            local accel = (velSmooth - lastVel) / math.max(dt, 1/240)
            lastVel = velSmooth
            local goal
            if player.Team == game.Teams.B then goal = map.Bgoal
            elseif player.Team == game.Teams.A then goal = map.Agoal end
            local tImpact = predictImpact(ball.Position, velSmooth, accel, goal)
            local predicted
            if tImpact then predicted = ball.Position + velSmooth*tImpact + 0.5*accel*tImpact*tImpact
            else predicted = ball.Position + velSmooth*0.25 + 0.5*GRAVITY*0.0625 end
            look.Enabled = true
            look.CFrame = CFrame.lookAt(hrp2.Position, Vector3.new(predicted.X, hrp2.Position.Y, predicted.Z))
            local dist = (hrp2.Position - ball.Position).Magnitude
            if dist > tackleRadius and dist <= 37 and ball.Position.Y > hrp2.Position.Y + 4 then hum.Jump = true end
            if dist <= tackleRadius then
                BNR:FireServer(unpack(tackleArgs))
                if not magnetBurst then
                    magnetBurst = true
                    task.spawn(function()
                        local start = os.clock()
                        while os.clock() - start < 0.897 and s.running do
                            BNR:FireServer(grabBuf)
                            task.wait(0.125)
                        end
                        magnetBurst = false
                    end)
                end
            end
        else
            look.Enabled = false
        end
    end))

    table.insert(s.conns, hum.Died:Connect(stopCeleronGK))
    table.insert(s.conns, player.CharacterAdded:Connect(stopCeleronGK))
end

local function stopDaffyGK()
    local s = autoGKState.daffy
    s.running = false
    for _, c in ipairs(s.conns) do pcall(function() c:Disconnect() end) end
    s.conns = {}
    if s.align then pcall(function() s.align:Destroy() end) s.align = nil end
    if s.gui then pcall(function() s.gui:Destroy() end) s.gui = nil end
    if s.cam and s.originalCamType then
        pcall(function() s.cam.CameraType = s.originalCamType s.cam.CFrame = s.originalCamCFrame end)
    end
end

local function startDaffyGK()
    local s = autoGKState.daffy
    if s.running then return end
    s.running = true
    s.kind = nil

    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local hrp2 = char:WaitForChild("HumanoidRootPart")
    s.cam = workspace.CurrentCamera
    s.originalCamType = s.cam.CameraType
    s.originalCamCFrame = s.cam.CFrame

    local gui = Instance.new("ScreenGui")
    gui.Name = "SW_DaffyGK"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")
    s.gui = gui

    local function mkBtn(txt, xOff)
        local b = Instance.new("TextButton")
        b.Text = txt
        b.Size = UDim2.new(0, 140, 0, 50)
        b.Position = UDim2.new(0.5, xOff, 0.5, -25)
        b.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        b.TextColor3 = Color3.fromRGB(220, 220, 220)
        b.TextScaled = true
        b.Font = Enum.Font.GothamBold
        b.Parent = gui
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = b
        return b
    end
    local camBtn = mkBtn("Camera Mode", -160)
    local bodyBtn = mkBtn("Body Mode", 20)

    camBtn.MouseButton1Up:Connect(function() s.kind = "cam" camBtn:Destroy() bodyBtn:Destroy() end)
    bodyBtn.MouseButton1Up:Connect(function() s.kind = "body" camBtn:Destroy() bodyBtn:Destroy() end)

    task.spawn(function()
        repeat task.wait() until s.kind ~= nil or not s.running
        if not s.running then return end
        if s.kind == "body" then
            hum.AutoRotate = false
            local align = Instance.new("AlignOrientation")
            align.Mode = Enum.OrientationAlignmentMode.OneAttachment
            align.Attachment0 = hrp2:WaitForChild("RootAttachment")
            align.Responsiveness = 300
            align.MaxTorque = math.huge
            align.Enabled = false
            align.Parent = hrp2
            s.align = align
        end
        local ballHolder = ReplicatedStorage.workspace.ballHolder
        local terrain = workspace.Terrain
        local lastHolder = ballHolder.Value
        local paused = false
        table.insert(s.conns, ballHolder.Changed:Connect(function(cur)
            if lastHolder == char and cur == nil then
                paused = true
                task.delay(0.7, function() paused = false end)
            end
            lastHolder = cur
        end))
        table.insert(s.conns, UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.F4 then stopDaffyGK() end
        end))
        local tackleArgs = { buffer.fromstring(buffers["base"]), { { "tackle" } } }
        table.insert(s.conns, RunService.RenderStepped:Connect(function()
            if not s.running then return end
            if player.Team == game.Teams.lobby or paused then
                if s.align then s.align.Enabled = false end
                return
            end
            local ball = terrain:FindFirstChild("Ball")
            if not ball then
                if s.align then s.align.Enabled = false end
                return
            end
            if s.kind == "cam" then
                s.cam.CameraType = Enum.CameraType.Scriptable
                s.cam.CFrame = CFrame.lookAt(s.cam.CFrame.Position, ball.Position)
            elseif s.kind == "body" and s.align then
                s.align.Enabled = true
                local dir = ball.Position - hrp2.Position
                dir = Vector3.new(dir.X, 0, dir.Z)
                if dir.Magnitude > 0.01 then s.align.CFrame = CFrame.lookAt(Vector3.zero, dir) end
            end
            local dist = (hrp2.Position - ball.Position).Magnitude
            if dist <= 60 then
                hum.Jump = ball.Position.Y >= hrp2.Position.Y + 6
                BNR:FireServer(unpack(tackleArgs))
            end
        end))
        table.insert(s.conns, hum.Died:Connect(stopDaffyGK))
        table.insert(s.conns, player.CharacterAdded:Connect(stopDaffyGK))
    end)
end

getgenv().GoalkeeperTab:AddToggle({
    Text = "Auto GK (v2)",
    Description = "V to toggle. Prediction-based.",
    Icon = "Lucide:shield",
    Flag = "SW_autoGKCeleron",
    Default = false,
    Callback = function(v)
        if v then startCeleronGK() swNotify("Auto GK", "v2 mode enabled.", 2)
        else stopCeleronGK() swNotify("Auto GK", "v2 mode disabled.", 2) end
    end,
})

getgenv().GoalkeeperTab:AddToggle({
    Text = "Auto GK (v1)",
    Description = "Camera or Body mode. F4 to disable.",
    Icon = "Lucide:shield",
    Flag = "SW_autoGKDaffy",
    Default = false,
    Callback = function(v)
        if v then startDaffyGK() swNotify("Auto GK", "v1 mode enabled. Pick mode.", 2)
        else stopDaffyGK() swNotify("Auto GK", "v1 mode disabled.", 2) end
    end,
})

getgenv().GoalkeeperTab:AddDivider()
getgenv().GoalkeeperTab:AddSection("Auto Position", "Lucide:map-pin")

local autoPositionState = { CF = false, GK = false, CFConn = nil, GKConn = nil }

local function firePacketsIfNear()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if (root.Position - Vector3.new(-371, 13, -1599)).Magnitude <= 15 or
       (root.Position - Vector3.new(-196, 13, -1599)).Magnitude <= 15 then
        BNR:FireServer(buffer.fromstring(pick .. "\001\001\000A"))
        BNR:FireServer(buffer.fromstring(pick .. "\001\001\000B"))
    end
end

local function fireGKPackets()
    BNR:FireServer(buffer.fromstring(pick .. "\005\001\000B"))
    BNR:FireServer(buffer.fromstring(pick .. "\005\001\000A"))
end

getgenv().GoalkeeperTab:AddToggle({
    Text = "Auto Pick CF",
    Icon = "Lucide:target",
    Flag = "SW_autoPickCF",
    Default = false,
    Callback = function(v)
        autoPositionState.CF = v
        if v then
            autoPositionState.CFConn = player.CharacterAdded:Connect(function()
                task.wait(0.3)
                firePacketsIfNear()
            end)
            task.spawn(function()
                repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                firePacketsIfNear()
            end)
        else
            if autoPositionState.CFConn then autoPositionState.CFConn:Disconnect() autoPositionState.CFConn = nil end
        end
    end,
})

getgenv().GoalkeeperTab:AddToggle({
    Text = "Auto Pick GK",
    Icon = "Lucide:shield",
    Flag = "SW_autoPickGK",
    Default = false,
    Callback = function(v)
        autoPositionState.GK = v
        if v then
            autoPositionState.GKConn = player.CharacterAdded:Connect(function()
                task.wait(0.3)
                fireGKPackets()
            end)
            task.spawn(function()
                repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                fireGKPackets()
            end)
        else
            if autoPositionState.GKConn then autoPositionState.GKConn:Disconnect() autoPositionState.GKConn = nil end
        end
    end,
})

getgenv().ExploitsTab:AddSection("Semi-Private Server", "Lucide:lock")

getgenv().ExploitsTab:AddButton({
    Text = "Semi-Private Server (11v11)",
    Icon = "Lucide:lock",
    Callback = function() TeleportService:Teleport(85946466968831, player) end,
})

getgenv().ExploitsTab:AddButton({
    Text = "Semi-Private Server Info",
    Icon = "Lucide:info",
    Callback = function() swNotify("Semi-Private Server", "If a player joins, block them then run again.", 10) end,
})

getgenv().ExploitsTab:AddDivider()
getgenv().ExploitsTab:AddSection("Instant Disconnect", "Lucide:log-out")

local disconnectState = { limit = nil, enabled = false }

getgenv().ExploitsTab:AddTextbox({
    Text = "Player Limit",
    Icon = "Lucide:hash",
    Flag = "SW_dcLimit",
    Placeholder = "e.g. 2",
    Default = "",
    Callback = function(v) disconnectState.limit = tonumber(v) end,
})

getgenv().ExploitsTab:AddToggle({
    Text = "Enable Instant Disconnect",
    Icon = "Lucide:log-out",
    Flag = "SW_dcEnabled",
    Default = false,
    Callback = function(v) disconnectState.enabled = v swNotify("Instant Disconnect", v and "Enabled." or "Disabled.", 2) end,
})

addConnection(RunService.RenderStepped:Connect(function()
    if disconnectState.enabled and disconnectState.limit and #Players:GetPlayers() > disconnectState.limit then
        player:Kick("Instant Disconnect triggered.")
    end
end))

getgenv().ExploitsTab:AddDivider()
getgenv().ExploitsTab:AddSection("Goalkeeper Anywhere", "Lucide:goal")

getgenv().ExploitsTab:AddButton({
    Text = "Goalkeeper Anywhere",
    Description = "Allows GK side dashes anywhere. Rejoin to disable.",
    Icon = "Lucide:goal",
    Callback = function()
        if type(hookfunction) ~= "function" then
            swNotify("Goalkeeper Anywhere", "Executor lacks hookfunction.", 3)
            return
        end
        local ok = pcall(function()
            local env = require(ReplicatedStorage.util.actionUtil)
            if not getgenv().__SW_gkHook then
                getgenv().__SW_gkHook = true
                hookfunction(env.checkGK, function(...) return true end)
            end
        end)
        swNotify("Goalkeeper Anywhere", ok and "Enabled." or "Failed.", 3)
    end,
})

getgenv().ExploitsTab:AddDivider()
getgenv().ExploitsTab:AddSection("Shachoko GK", "Lucide:shield-check")

getgenv().ExploitsTab:AddButton({
    Text = "Shachoko GK Catch",
    Description = "External GK catch script. Req. GK position.",
    Icon = "Lucide:shield-check",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/Hr1HnK38"))()
    end,
})

getgenv().ExploitsTab:AddDivider()
getgenv().ExploitsTab:AddSection("Goal Farm", "Lucide:footprints")

local goalFarmState = { enabled = false, CFConn = nil, RenderConn = nil, StopAt = nil }
local farmmode = "Solo Farm"
local lastFiredTeam = "B"
local teamSwitching = false
local lastResetTime = 0

local GoalAGoal = workspace:WaitForChild("map"):WaitForChild("Agoal")
local GoalBGoal = workspace:WaitForChild("map"):WaitForChild("Bgoal")

local function checkScoreCondition()
    local hotbar = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("Hotbar")
    local homeLabel = hotbar and hotbar:FindFirstChild("Home")
    local awayLabel = hotbar and hotbar:FindFirstChild("Away")
    if homeLabel and awayLabel then
        local h = tonumber(string.match(homeLabel.Text, ":%s*(%d+)")) or 0
        local a = tonumber(string.match(awayLabel.Text, "(%d+)%s*:")) or 0
        if math.abs(h - a) >= 4 and not (h >= 10 and a >= 10) then
            if os.clock() - lastResetTime >= 60 then return true end
        end
    end
    return false
end

local function farmIsInGame()
    local char = player.Character
    local st = char and char:FindFirstChild("state")
    local ig = st and st:FindFirstChild("ingame")
    return ig and ig.Value or false
end

local function farmDisableCollisions()
    local map = workspace:FindFirstChild("map")
    if not map then return end
    local gk = map:FindFirstChild("gkbarriar")
    if gk then
        if gk:FindFirstChild("A") then gk.A.CanCollide = false end
        if gk:FindFirstChild("B") then gk.B.CanCollide = false end
    end
    local ag = map:FindFirstChild("Agoal")
    local bg = map:FindFirstChild("Bgoal")
    if ag then ag.CanCollide = false end
    if bg then bg.CanCollide = false end
end

local function farmStealBall()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local ball = workspace.Terrain:FindFirstChild("Ball")
    if root and ball then
        task.wait(0.5)
        root.CFrame = CFrame.new(ball.Position.X, 0, ball.Position.Z)
    end
    for _, opp in pairs(Players:GetPlayers()) do
        if opp ~= player then
            local oChar = opp.Character
            local oBall = oChar and oChar:FindFirstChild("Ball")
            if oBall and root then
                task.wait(0.5)
                root.CFrame = oBall.CFrame
                BNR:FireServer(buffer.fromstring(buffers["base"]), {{"tackle"}})
            end
        end
    end
end

local function farmHasBall()
    return player.Character and player.Character:FindFirstChild("Ball") ~= nil
end

local function farmStop()
    goalFarmState.enabled = false
    if goalFarmState.CFConn then goalFarmState.CFConn:Disconnect() goalFarmState.CFConn = nil end
    if goalFarmState.RenderConn then goalFarmState.RenderConn:Disconnect() goalFarmState.RenderConn = nil end
    swNotify("Goal Farm", "Stopped.", 2)
end

getgenv().ExploitsTab:AddDropdown({
    Text = "Goal Farm Method",
    Flag = "SW_goalFarmMethod",
    Options = {"Solo Farm", "Alt Farm"},
    Default = "Solo Farm",
    Callback = function(v)
        farmmode = type(v) == "table" and v[1] or v
        swNotify("Goal Farm", "Method: " .. farmmode, 3)
    end,
})

getgenv().ExploitsTab:AddButton({
    Text = "Goal Farm Info",
    Icon = "Lucide:info",
    Callback = function()
        swNotify("Goal Farm", "Solo: both teams 0 or 15+ goals. Alt: enable on both accounts on separate teams.", 10)
    end,
})

getgenv().ExploitsTab:AddToggle({
    Text = "Goal Farm",
    Icon = "Lucide:footprints",
    Flag = "SW_goalFarm",
    Default = false,
    Callback = function(v)
        goalFarmState.enabled = v
        if v then
            goalFarmState.CFConn = player.CharacterAdded:Connect(function()
                task.wait(1)
                if goalFarmState.enabled then firePacketsIfNear() end
            end)
            task.spawn(function()
                repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if goalFarmState.enabled then firePacketsIfNear() end
            end)
            goalFarmState.RenderConn = RunService.RenderStepped:Connect(function()
                if not goalFarmState.enabled then return end
                pcall(function()
                    if farmmode == "Solo Farm" and (teamSwitching or checkScoreCondition()) then
                        if not teamSwitching then
                            teamSwitching = true
                            lastResetTime = os.clock()
                            task.spawn(function()
                                local char = player.Character
                                if char then char:BreakJoints() end
                                task.wait(8)
                                lastFiredTeam = (lastFiredTeam == "A") and "B" or "A"
                                BNR:FireServer(buffer.fromstring(pick .. "\001\001\000" .. lastFiredTeam))
                                teamSwitching = false
                            end)
                        end
                        return
                    end
                    if not farmIsInGame() then return end
                    farmDisableCollisions()
                    farmStealBall()
                    if farmHasBall() then
                        local char = player.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        local targetGoal = player.Team.Name == "A" and GoalBGoal or GoalAGoal
                        if root and targetGoal then
                            task.wait(0.5)
                            root.CFrame = targetGoal.CFrame
                            task.wait(0.185)
                            BNR:FireServer(buffer.fromstring(buffers["base"]), {{"kick", 50, false, vector.create(0, 1, 0)}})
                            firePacketsIfNear()
                        end
                    end
                end)
            end)
            task.spawn(function()
                local goals = player:WaitForChild("leaderstats"):WaitForChild("goals")
                while goalFarmState.enabled do
                    task.wait(1)
                    if goalFarmState.StopAt and goals.Value >= goalFarmState.StopAt then
                        farmStop()
                        return
                    end
                end
            end)
        else
            farmStop()
        end
    end,
})

getgenv().ExploitsTab:AddTextbox({
    Text = "Goal Target",
    Icon = "Lucide:hash",
    Flag = "SW_goalTarget",
    Placeholder = "0 = infinite",
    Default = "",
    Callback = function(v)
        local n = tonumber(v)
        goalFarmState.StopAt = n or math.huge
    end,
})

getgenv().MiscTab:AddSection("Notifications", "Lucide:bell-off")

getgenv().MiscTab:AddToggle({
    Text = "Suppress Notifications",
    Description = "Silences global popups.",
    Icon = "Lucide:bell-off",
    Flag = "SW_suppressNotifs",
    Default = false,
    Callback = function(v) getgenv().swSuppressNotifs(v) end,
})

getgenv().MiscTab:AddDivider()
getgenv().MiscTab:AddSection("Cutscene", "Lucide:film-off")

getgenv().MiscTab:AddToggle({
    Text = "No Cutscene",
    Description = "Stops crowd loop during cutscenes.",
    Icon = "Lucide:film-off",
    Flag = "SW_noCutscene",
    Default = false,
    Callback = function(v)
        local SoundService = game:GetService("SoundService")
        local temp = SoundService:FindFirstChild("sw_temp") or Instance.new("Folder", SoundService)
        temp.Name = "sw_temp"
        local crowd = SoundService:FindFirstChild("football-crowd-3-69245") or temp:FindFirstChild("football-crowd-3-69245")
        if v then
            if crowd and crowd:IsDescendantOf(SoundService) then
                local clone = crowd:Clone()
                clone.Parent = temp
                crowd:Stop()
                crowd:Destroy()
            end
        else
            local stored = temp:FindFirstChild("football-crowd-3-69245")
            if stored then
                stored.Parent = SoundService
                stored:Play()
            end
        end
    end,
})

getgenv().MiscTab:AddDivider()
getgenv().MiscTab:AddSection("Invisibility", "Lucide:eye-off")

local invisState = { active = false, character = nil, humanoid = nil, track = nil }

local function stopInvisibility()
    invisState.active = false
    if invisState.track then invisState.track:Stop() invisState.track:Destroy() invisState.track = nil end
    if invisState.humanoid then invisState.humanoid.CameraOffset = Vector3.new(0,0,0) end
end

local function startInvisibility()
    if not invisState.humanoid then return end
    invisState.active = true
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://113098409724280"
    local track = invisState.humanoid:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    track.Looped = false
    track:Play(0)
    track:AdjustSpeed(0)
    invisState.track = track
end

player.CharacterAdded:Connect(function(char)
    invisState.character = char
    invisState.humanoid = char:WaitForChild("Humanoid")
    if invisState.active then startInvisibility() end
end)

if player.Character then
    invisState.character = player.Character
    invisState.humanoid = player.Character:FindFirstChildOfClass("Humanoid")
end

getgenv().MiscTab:AddToggle({
    Text = "Invisibility V1 (Animation)",
    Icon = "Lucide:eye-off",
    Flag = "SW_invisV1",
    Default = false,
    Callback = function(v)
        if v then startInvisibility() else stopInvisibility() end
    end,
})

getgenv().MiscTab:AddButton({
    Text = "Invisibility V2 (Clone)",
    Description = "Clone method. Press Z to disable.",
    Icon = "Lucide:eye-off",
    Callback = function()
        local enabled = true
        local chars = workspace:WaitForChild("characters", 10)
        if not chars then return end
        local character = chars:WaitForChild(player.Name, 15)
        if not character then return end
        if not character:FindFirstChild("Humanoid") or not character:FindFirstChild("HumanoidRootPart") then return end
        character.Archivable = true
        local charRoot = character:WaitForChild("HumanoidRootPart")
        charRoot.Transparency = 1
        local clone = character:Clone()
        if not clone then return end
        clone.Name = player.Name .. "_Ghost"
        clone.Parent = workspace
        for _, obj in ipairs(clone:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Transparency = obj.Name == "HumanoidRootPart" and 1 or 0.4
                obj.CanCollide = true
            elseif obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("ShirtGraphic") then
                obj.Transparency = 0
            end
        end
        local cloneRoot = clone:WaitForChild("HumanoidRootPart", 5)
        local cloneHum = clone:WaitForChild("Humanoid", 5)
        if not cloneRoot or not cloneHum then clone:Destroy() return end
        cloneRoot.CFrame = character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
        cloneHum.WalkSpeed = 75
        cloneHum.JumpPower = 50
        player.Character = clone
        workspace.CurrentCamera.CameraSubject = cloneHum

        local runAnim = Instance.new("Animation")
        runAnim.AnimationId = "rbxassetid://90801998022970"
        local runTrack = cloneHum:LoadAnimation(runAnim)
        runTrack.Looped = true
        runTrack.Priority = Enum.AnimationPriority.Movement

        local jumpAnim = Instance.new("Animation")
        jumpAnim.AnimationId = "rbxassetid://80330677678466"
        local jumpTrack = cloneHum:LoadAnimation(jumpAnim)
        jumpTrack.Looped = false

        local isRunning = false
        local tpConn = RunService.Heartbeat:Connect(function()
            if not enabled then return end
            if not cloneRoot or not cloneRoot.Parent or not charRoot or not charRoot.Parent then return end
            local cp = cloneRoot.Position
            charRoot.CFrame = CFrame.new(cp - Vector3.new(0, 15, 0), cp)
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.Transparency = 1 part.CanCollide = false end
            end
        end)

        local speedConn = RunService.RenderStepped:Connect(function()
            if not enabled then return end
            if cloneHum and cloneHum.Parent then
                cloneHum.WalkSpeed = 75
                cloneHum.JumpPower = 50
            end
        end)

        UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.Z and enabled then
                enabled = false
                tpConn:Disconnect()
                speedConn:Disconnect()
                player.Character = character
                workspace.CurrentCamera.CameraSubject = character:FindFirstChild("Humanoid")
                if clone then clone:Destroy() end
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then part.Transparency = part.Name == "HumanoidRootPart" and 1 or 0 part.CanCollide = true end
                end
                runTrack:Stop(0.2)
                jumpTrack:Stop(0.2)
            end
        end)
    end,
})

getgenv().ServerTab:AddSection("Server Controls", "Lucide:server")

getgenv().ServerTab:AddButton({ Text = "Rejoin Server", Icon = "Lucide:refresh-cw", Callback = function() TeleportService:Teleport(game.PlaceId, player) end })

getgenv().ServerTab:AddButton({
    Text = "Server Hop",
    Icon = "Lucide:shuffle",
    Callback = function()
        local ok, servers = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
        end)
        if ok and servers and servers.data then
            for _, s in ipairs(servers.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, player)
                    return
                end
            end
        end
        swNotify("Server Hop", "No server found", 2)
    end,
})

getgenv().ServerTab:AddDivider()
getgenv().ServerTab:AddSection("Join By JobId", "Lucide:key")

local jobIdBuffer = ""

getgenv().ServerTab:AddTextbox({
    Text = "JobId",
    Icon = "Lucide:key",
    Flag = "SW_jobId",
    Placeholder = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    Default = "",
    Callback = function(text) jobIdBuffer = text end,
})

getgenv().ServerTab:AddButton({
    Text = "Join JobId",
    Icon = "Lucide:log-in",
    Callback = function()
        if jobIdBuffer == "" then swNotify("Server", "Paste a JobId first.", 2) return end
        local ok, err = pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, jobIdBuffer, player) end)
        swNotify(ok and "Joining" or "Failed", ok and "Teleporting..." or tostring(err), 3)
    end,
})

getgenv().ServerTab:AddDivider()
getgenv().ServerTab:AddSection("Session Info", "Lucide:info")

local SessionInfo = getgenv().ServerTab:AddInfoGrid({
    Title = "Session", Columns = 2,
    Items = {
        { Label = "JobId", Value = "..." },
        { Label = "PlaceId", Value = tostring(game.PlaceId) },
        { Label = "Players", Value = "..." },
        { Label = "Ping", Value = "-- ms" },
        { Label = "Uptime", Value = "0s" },
        { Label = "Region", Value = "Unknown" },
    },
})

SessionInfo:SetValue("JobId", game.JobId:sub(1, 12) .. "...")

task.spawn(function()
    local start = tick()
    while not getgenv().destroyed do
        task.wait(1)
        local ok, ping = pcall(function() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() end)
        SessionInfo:SetValue("Ping", ok and (math.floor(ping) .. " ms") or "-- ms")
        SessionInfo:SetValue("Players", tostring(#Players:GetPlayers()))
        local up = math.floor(tick() - start)
        local h = math.floor(up / 3600)
        local m = math.floor((up % 3600) / 60)
        local s = up % 60
        if h > 0 then SessionInfo:SetValue("Uptime", string.format("%dh %dm", h, m))
        elseif m > 0 then SessionInfo:SetValue("Uptime", string.format("%dm %ds", m, s))
        else SessionInfo:SetValue("Uptime", string.format("%ds", s)) end
    end
end)

getgenv().HomeTab:AddSubTab({ Name = "Info", Icon = "Lucide:layout-grid" }):AddSystemInfoGrid({ Description = "Live session info" })

local ChangelogSub = getgenv().HomeTab:AddSubTab({ Name = "Changelog", Icon = "Lucide:file-text" })
ChangelogSub:AddChangelogEntry({
    Version = "Scared Ware UI v0.3",
    Date = "Update",
    Changes = {
        { Type = "Added", Text = "Goalkeeper tab with Auto GK (v1 + v2)" },
        { Type = "Added", Text = "Exploits tab: Semi-Private, Instant Disconnect, GK Anywhere, Shachoko, Goal Farm" },
        { Type = "Added", Text = "Misc tab: Notification Suppression, No Cutscene, Invisibility V1/V2" },
        { Type = "Added", Text = "Kick Like Kaiser (hook)" },
        { Type = "Added", Text = "Auto QTE, Auto Steal Ball, No Stun" },
        { Type = "Added", Text = "Get Flow, Bring Ball, Always Ball, Fix Duplicate Ball" },
        { Type = "Added", Text = "Trap Helper, IFrame Indicator, Blatant Mode" },
        { Type = "Added", Text = "Line Ups: Kaiser, Karasu, Rin, Rin Flow + Line Up Creator" },
        { Type = "Added", Text = "Auto Pick CF, Auto Pick GK" },
        { Type = "Changed", Text = "Renamed parts to sw_pad/sw_target to avoid collisions" },
        { Type = "Changed", Text = "All notifications route through swNotify (respects suppression)" },
    },
})

getgenv().SettingsTab:AddSection("Reset Functions", "Lucide:rotate-ccw")

getgenv().SettingsTab:AddButton({
    Text = "Reset All Toggles",
    Icon = "Lucide:rotate-ccw",
    Callback = function()
        ActiveDashes = {}
        if renderConn then renderConn:Disconnect() renderConn = nil end
        if getgenv().swClearLineups then getgenv().swClearLineups() end
        restoreWorldOriginal()
        workspace.Gravity = 196.2
        swNotify("Reset", "All features have been turned off.", 3)
    end,
})

getgenv().SettingsTab:AddButton({
    Text = "Unload Scared Ware UI",
    Icon = "Lucide:power",
    Callback = function() if ENV.__AZURE_LATCH_CLEANUP then ENV.__AZURE_LATCH_CLEANUP() end end,
})

getgenv().SettingsTab:AddDivider()
getgenv().SettingsTab:AddSection("Menu", "Lucide:keyboard")

getgenv().SettingsTab:AddKeybind({
    Text = "Toggle Menu",
    Description = "Open/close panel.",
    Icon = "Lucide:keyboard",
    Flag = "SW_menuKey",
    Default = Enum.KeyCode.RightAlt,
    Callback = function(key, kind) if kind == "press" then Window:Toggle() end end,
})

getgenv().SettingsTab:AddDivider()
getgenv().SettingsTab:AddSection("Theme", "Lucide:palette")

local AvailableThemes = {"Dark", "Light", "Midnight", "Forest"}
local CurrentThemeLabel = getgenv().SettingsTab:AddLabel("Current: " .. tostring(getgenv().CONFIG.Theme))

getgenv().SettingsTab:AddDropdown({
    Text = "Select Theme",
    Flag = "SW_theme",
    Options = AvailableThemes,
    Default = getgenv().CONFIG.Theme,
    Callback = function(option)
        local value = type(option) == "table" and option[1] or option
        local ok = pcall(function() VindUI:SetTheme(value) end)
        if ok then
            getgenv().CONFIG.Theme = value
            if CurrentThemeLabel and CurrentThemeLabel.Set then CurrentThemeLabel:Set("Current: " .. value) end
        end
    end,
})

getgenv().ConfigTab:AddSection("Profile Management", "Lucide:user")

ConfigStore.StatusLabel = getgenv().ConfigTab:AddLabel(ConfigStore.Available and ("Ready | " .. ConfigStore.Selected) or "Unavailable | filesystem APIs missing")

if ConfigStore.Available then
    ConfigStore.ProfileDropdown = getgenv().ConfigTab:AddDropdown({
        Text = "Config Profile",
        Flag = "SW_configProfile",
        Options = listConfigProfiles(),
        Default = ConfigStore.Selected,
        Callback = function(option)
            local value = type(option) == "table" and option[1] or option
            if value ~= nil then
                ConfigStore.Selected = sanitizeConfigName(value, "default")
                ConfigStore.PendingProfile = ConfigStore.Selected
                if ConfigStore.ProfileInput and ConfigStore.ProfileInput.Set then ConfigStore.ProfileInput:Set(ConfigStore.Selected) end
                saveMeta()
                setConfigStatus("Selected " .. ConfigStore.Selected)
            end
        end,
    })

    ConfigStore.ProfileInput = getgenv().ConfigTab:AddTextbox({
        Text = "Profile Name",
        Icon = "Lucide:edit",
        Flag = "SW_configProfileName",
        Default = ConfigStore.Selected,
        Placeholder = "default",
        Callback = function(value) ConfigStore.PendingProfile = sanitizeConfigName(value, ConfigStore.Selected) end,
    })

    getgenv().ConfigTab:AddButton({
        Text = "Save / Create Profile",
        Icon = "Lucide:save",
        Callback = function()
            local profile = ConfigStore.PendingProfile or ConfigStore.Selected
            ConfigStore.Selected = sanitizeConfigName(profile, "default")
            if saveConfig(ConfigStore.Selected, true) then
                ConfigStore.ProfileDropdown:Refresh(listConfigProfiles())
                ConfigStore.ProfileDropdown:Set(ConfigStore.Selected)
            end
        end,
    })

    getgenv().ConfigTab:AddButton({
        Text = "Load Selected Profile",
        Icon = "Lucide:upload",
        Callback = function()
            if loadConfig(ConfigStore.Selected, true) then
                VindUI:Notify({ Title = "Configs", Text = "Loaded successfully", Type = "success", Duration = 2 })
            end
        end,
    })

    getgenv().ConfigTab:AddButton({
        Text = "Refresh Profiles",
        Icon = "Lucide:refresh-cw",
        Callback = function()
            ConfigStore.ProfileDropdown:Refresh(listConfigProfiles())
            ConfigStore.ProfileDropdown:Set(ConfigStore.Selected)
            setConfigStatus("Profiles refreshed")
        end,
    })

    getgenv().ConfigTab:AddButton({
        Text = "Delete Selected Profile",
        Icon = "Lucide:trash-2",
        Callback = function()
            local deleted = ConfigStore.Selected
            if deleteConfig(deleted) then
                ConfigStore.ProfileDropdown:Refresh(listConfigProfiles())
                ConfigStore.ProfileDropdown:Set(ConfigStore.Selected)
                if ConfigStore.ProfileInput then ConfigStore.ProfileInput:Set(ConfigStore.Selected) end
                VindUI:Notify({ Title = "Configs", Text = "Deleted " .. deleted, Type = "warning", Duration = 2 })
            end
        end,
    })

    getgenv().ConfigTab:AddDivider()
    getgenv().ConfigTab:AddSection("Automation", "Lucide:settings-2")

    getgenv().ConfigTab:AddToggle({
        Text = "Auto Save",
        Description = "Saves on setting change.",
        Icon = "Lucide:save",
        Flag = "SW_autoSave",
        Default = ConfigStore.AutoSave,
        Callback = function(value)
            ConfigStore.AutoSave = value == true
            saveMeta()
            if ConfigStore.AutoSave then saveConfig(ConfigStore.Selected, false) end
            setConfigStatus(ConfigStore.AutoSave and ("Auto Save ON | " .. ConfigStore.Selected) or "Auto Save OFF")
        end,
    })

    getgenv().ConfigTab:AddToggle({
        Text = "Auto Load",
        Description = "Loads last profile on start.",
        Icon = "Lucide:download",
        Flag = "SW_autoLoad",
        Default = ConfigStore.AutoLoad,
        Callback = function(value)
            ConfigStore.AutoLoad = value == true
            saveMeta()
            setConfigStatus(ConfigStore.AutoLoad and ("Auto Load ON | " .. ConfigStore.Selected) or "Auto Load OFF")
        end,
    })

    getgenv().ConfigTab:AddDivider()

    getgenv().ConfigTab:AddParagraph({
        Title = "How it works",
        Icon = "Lucide:info",
        Text = "Profiles save as JSON in your executor workspace folder. Auto Save writes on toggle changes; Auto Load restores on rejoin.",
    })
else
    getgenv().ConfigTab:AddParagraph({
        Title = "Persistent Configs Unavailable",
        Icon = "Lucide:alert-triangle",
        Text = "Executor needs writefile, readfile, isfile, makefolder.",
    })
end

task.spawn(function()
    task.wait(1)
    if not ConfigStore.Available then return end
    ConfigStore.LastFingerprint = configFingerprint()
    if ConfigStore.AutoSave and not FS.IsFile(configPath(ConfigStore.Selected)) then
        saveConfig(ConfigStore.Selected, false)
    end
    while not getgenv().destroyed do
        if ConfigStore.AutoSave and not ConfigStore.Applying then
            local current = configFingerprint()
            if current ~= "" and current ~= ConfigStore.LastFingerprint then
                saveConfig(ConfigStore.Selected, false)
            end
        end
        task.wait(0.5)
    end
end)

getgenv().cleanup = function()
    if getgenv().destroyed then return end
    getgenv().destroyed = true

    ActiveDashes = {}
    if renderConn then renderConn:Disconnect() renderConn = nil end
    if getgenv().swClearLineups then getgenv().swClearLineups() end
    restoreWorldOriginal()
    workspace.Gravity = 196.2

    if playerListGUI and playerListGUI.Parent then playerListGUI:Destroy() end
    if teamHighlightFolder and teamHighlightFolder.Parent then teamHighlightFolder:Destroy() end
    if flowPartData.flowPart then flowPartData.flowPart:Destroy() end

    for _, connection in ipairs(getgenv().connections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(getgenv().connections)

    pcall(function() Window:Destroy() end)
    pcall(function() VindUI:Unload() end)

    if ENV.__AZURE_LATCH_CLEANUP == getgenv().cleanup then ENV.__AZURE_LATCH_CLEANUP = nil end
end

ENV.__AZURE_LATCH_CLEANUP = getgenv().cleanup

Window:SelectTab("Home")
Window:Open()
