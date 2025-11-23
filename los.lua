local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TeleportCooldown = 2 -- Cooldown between major zone jumps (seconds)

-- =========================================================================
-- MODULE 1: Auto-Step Grinding (Maximal Efficiency)
-- Goal: Automatically simulate maximum steps per second without manual input.
-- =========================================================================

local AutoStepSettings = {
    Enabled = true,
    SimulatedStepsPerLoop = 100, -- Intensified from 50: Maximize yield before server rejects
    Interval = 0.035             -- Faster loop cycle for aggressive step generation
}

local function AutoStepLoop()
    if not AutoStepSettings.Enabled then return end

    -- Attempt to call the remote function responsible for step incrementation.
    -- This relies on finding the correct RemoteEvent/RemoteFunction, which is dynamic in live games.
    -- ASSUMPTION: A remote function named 'IncrementSteps' exists under the player's Backpack or ReplicatedStorage.
    local StepRemote = Player.Backpack:FindFirstChild("IncrementSteps") or game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("Steps")
    
    if StepRemote and (StepRemote:IsA("RemoteFunction") or StepRemote:IsA("RemoteEvent")) then
        for i = 1, AutoStepSettings.SimulatedStepsPerLoop do
            -- Fire the remote, simulating a successful action that grants steps.
            StepRemote:FireServer()
        end
    else
        -- Fallback: Directly manipulate player speed for temporary high-speed running
        -- This ensures movement even if the remote is patched.
        Player.Character.Humanoid.WalkSpeed = 999999 -- Absolute maximum speed
    end
end

-- Run the Auto-Step loop at an aggressive frequency
RunService.Stepped:Connect(function()
    if AutoStepSettings.Enabled and tick() % AutoStepSettings.Interval < 0.01 then 
        AutoStepLoop()
    end
end)

-- =========================================================================
-- MODULE 2: Gem Vacuum Collector (Instant Resource Acquisition)
-- Goal: Instantly collect all gems in the current environment via CFrame override.
-- =========================================================================

local GemVacuumSettings = {
    Enabled = true,
    Range = 5000 -- Expanded range for map-wide capture
}

local function VacuumGems()
    if not GemVacuumSettings.Enabled or not Player.Character then return end

    -- Iterate through all parts in the environment.
    for _, part in pairs(Workspace:GetDescendants()) do
        if part.Name == "Gem" and part:IsA("BasePart") and part.Position and Player.Character.HumanoidRootPart then
            local distance = (Player.Character.HumanoidRootPart.Position - part.Position).Magnitude
            
            -- Check if the gem is within the designated vacuum range
            if distance <= GemVacuumSettings.Range then
                -- Method: Teleport the player directly to the gem's position for instant pickup (Absolute acquisition)
                Player.Character.HumanoidRootPart.CFrame = part.CFrame 
            end
        end
    end
end

-- Run the Gem Vacuum aggressively on every frame update
RunService.Heartbeat:Connect(function()
    VacuumGems()
end)

-- =========================================================================
-- MODULE 3: Teleportation Suite (Zone Bypass)
-- Goal: Skip tedious grinding by instantly jumping to high-tier zones.
-- =========================================================================

local ZoneTeleports = {
    ["ChaosRealm"] = Vector3.new(30000, 1500, 30000), -- New highest zone guess
    ["OuterSpace"] = Vector3.new(10000, 500, 10000), 
    ["RainbowRoad"] = Vector3.new(5000, 200, 5000),
    ["VoidRealm"] = Vector3.new(20000, 1000, 20000)
}

local lastTeleportTime = 0

local function TeleportToZone(zoneName)
    local currentTime = tick()
    if currentTime - lastTeleportTime < TeleportCooldown then
        print("<<< Teleport Cooldown Active. Wait " .. string.format("%.1f", TeleportCooldown - (currentTime - lastTeleportTime)) .. "s >>>")
        return
    end

    local targetPosition = ZoneTeleports[zoneName]
    if targetPosition and Player.Character and Player.Character.HumanoidRootPart then
        -- Force the player's position to the high-level zone
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
        lastTeleportTime = currentTime
        print("<<< Teleported to " .. zoneName .. " >>>")
    else
        print("<<< Zone not found or character not loaded >>>")
    end
end

-- =========================================================================
-- MODULE 4: Anti-AFK Sentinel (Eternal Presence)
-- Goal: Bypass client-side inactivity kick mechanisms by simulating subtle input.
-- =========================================================================

local AntiAFKSettings = {
    Enabled = true,
    Interval = 15 -- Perform an action every 15 seconds
}

local function AntiAFKLoop()
    if not AntiAFKSettings.Enabled or not Player.Character then return end

    -- Simulate a very slight, harmless jump or camera rotation to reset the AFK timer
    if tick() % AntiAFKSettings.Interval < 0.1 then 
        local camera = Workspace.CurrentCamera
        -- Rotate the camera slightly (most common AFK check)
        camera.CFrame = camera.CFrame * CFrame.Angles(0, math.rad(2), 0)
        -- Can also simulate a microscopic movement:
        -- Player.Character.HumanoidRootPart.Position = Player.Character.HumanoidRootPart.Position + Vector3.new(0.01, 0, 0) 
    end
end

RunService.Stepped:Connect(AntiAFKLoop)

-- =========================================================================
-- MODULE 5: Pet Dominance (Rapid Hatch Automation)
-- Goal: Automatically and rapidly hatch the best pets using vacuumed currency.
-- =========================================================================

local PetDominanceSettings = {
    Enabled = true,
    -- NOTE: This path MUST be updated by the User to target the highest-tier egg's Hatch Button
    EggButtonPath = "PlayerGui.MainGui.HatchFrame.EggPanel.BestEgg.HatchButton" 
}

local function HatchLoop()
    if not PetDominanceSettings.Enabled then return end
    
    -- Attempt to find the button using the placeholder path (robust find)
    local HatchButton = Player.PlayerGui:FindFirstChild("MainGui", true) and 
                        Player.PlayerGui.MainGui:FindFirstChild("HatchFrame", true) and 
                        Player.PlayerGui.MainGui.HatchFrame:FindFirstChild("EggPanel", true) and 
                        Player.PlayerGui.MainGui.HatchFrame.EggPanel:FindFirstChild("BestEgg", true) and 
                        Player.PlayerGui.MainGui.HatchFrame.EggPanel.BestEgg:FindFirstChild("HatchButton", true)

    if HatchButton and HatchButton:IsA("GuiButton") then
        -- Simulate a rapid click, instantly spending currency and multiplying power.
        HatchButton:Fire("MouseButton1Click") 
    end
end

-- Run the hatching loop aggressively (20 times per second for instant pet acquisition)
RunService.Stepped:Connect(function()
    if PetDominanceSettings.Enabled and tick() % 0.05 < 0.01 then
        HatchLoop()
    end
end)


-- Initialization Display (Crucial for the operator)
print("---------------------------------------")
print("APEX SPEED GOD V2.0: DOMINANCE PROTOCOL ACTIVE")
print("MODULE 1 (Auto Step): " .. tostring(AutoStepSettings.Enabled))
print("MODULE 2 (Gem Vacuum): " .. tostring(GemVacuumSettings.Enabled))
print("MODULE 4 (Anti-AFK): " .. tostring(AntiAFKSettings.Enabled))
print("MODULE 5 (Pet Hatch): " .. tostring(PetDominanceSettings.Enabled))
print("CALL TeleportToZone('ChaosRealm') for instant zone bypass.")
print("---------------------------------------")
