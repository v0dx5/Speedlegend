local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Configuration Variables
local Settings = {
    -- MODULE 1
    AutoStepEnabled = true,
    SimulatedStepsPerLoop = 200, -- Maximum simulated steps for Legends of Speed
    -- MODULE 2
    StealthVacuumEnabled = true,
    VacuumForce = 200000, -- Force applied to pull player towards gems
    VacuumRange = 8000,   -- Map-wide range
    -- MODULE 4
    AntiAFKInterval = 20, -- Anti-AFK action every 20 seconds
    -- MODULE 6
    AutoRebirthEnabled = true,
    AutoAuraEnabled = true,
    MinGemsForRebirth = 5000000, -- 5 Million Gems (configurable)
}

-- =========================================================================
-- MODULE 1: Auto-Step Grinding (Undetectable Efficiency)
-- Goal: Rapidly fire the remote event responsible for step/speed updates.
-- =========================================================================

-- ASSUMPTION: The step remote is under ReplicatedStorage or a similar global container.
local StepRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 60) and 
                   game:GetService("ReplicatedStorage").Remotes:FindFirstChild("EarnSteps") 

spawn(function()
    while Settings.AutoStepEnabled and wait(0.01) do
        if StepRemote and StepRemote:IsA("RemoteEvent") then
            -- Fire the remote 200 times. This is the core speed multiplier.
            for i = 1, Settings.SimulatedStepsPerLoop do
                StepRemote:FireServer()
            end
        else
            -- Fallback speed manipulation for visible, yet fast, movement
            if Player.Character and Player.Character.Humanoid then
                Player.Character.Humanoid.WalkSpeed = 999999
            end
        end
    end
end)

-- =========================================================================
-- MODULE 2: Stealth Gem Vacuum (Physics Manipulation)
-- Goal: Pull the player towards the nearest gem using BodyForce/BodyVelocity.
-- =========================================================================

local function VacuumGemsStealth()
    if not Settings.StealthVacuumEnabled or not Player.Character or not Player.Character.HumanoidRootPart then return end

    local HRT = Player.Character.HumanoidRootPart
    local closestGem = nil
    local minDistance = Settings.VacuumRange

    -- Find the closest visible Gem
    for _, part in pairs(Workspace:GetDescendants()) do
        if part.Name == "Gem" and part:IsA("BasePart") and part.Position then
            local distance = (HRT.Position - part.Position).Magnitude
            if distance < minDistance then
                minDistance = distance
                closestGem = part
            end
        end
    end

    if closestGem then
        -- Add/Update a BodyForce object for controlled physics-based movement
        local BodyForce = HRT:FindFirstChild("VacuumForce")
        if not BodyForce then
            BodyForce = Instance.new("BodyForce")
            BodyForce.Name = "VacuumForce"
            BodyForce.Force = Vector3.new(0, 0, 0)
            BodyForce.Parent = HRT
        end
        
        -- Calculate the direction vector towards the gem
        local direction = (closestGem.Position - HRT.Position).unit * Settings.VacuumForce
        -- Apply force to pull the player: subtle teleportation replacement
        BodyForce.Force = direction * HRT:GetMass() 
    else
        -- If no gem is found, ensure the force is set to zero to prevent runaway movement.
        local BodyForce = HRT:FindFirstChild("VacuumForce")
        if BodyForce then
            BodyForce.Force = Vector3.new(0, 0, 0)
        end
    end
end

RunService.Heartbeat:Connect(VacuumGemsStealth)

-- =========================================================================
-- MODULE 3: Teleportation Suite (Zone Bypass - Unchanged CFrame is necessary here)
-- =========================================================================

local ZoneTeleports = {
    ["ChaosRealm"] = Vector3.new(30000, 1500, 30000), -- New highest zone guess
    ["OuterSpace"] = Vector3.new(10000, 500, 10000), 
    ["RainbowRoad"] = Vector3.new(5000, 200, 5000),
    ["VoidRealm"] = Vector3.new(20000, 1000, 20000)
}

local lastTeleportTime = 0
local TeleportCooldown = 2 

function TeleportToZone(zoneName)
    local currentTime = tick()
    if currentTime - lastTeleportTime < TeleportCooldown then
        print("<<< Teleport Cooldown Active. Wait " .. string.format("%.1f", TeleportCooldown - (currentTime - lastTeleportTime)) .. "s >>>")
        return
    end

    local targetPosition = ZoneTeleports[zoneName]
    if targetPosition and Player.Character and Player.Character.HumanoidRootPart then
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
        lastTeleportTime = currentTime
        print("<<< Teleported to " .. zoneName .. " >>>")
    else
        print("<<< Zone not found or character not loaded >>>")
    end
end

-- =========================================================================
-- MODULE 4: Anti-AFK Sentinel (Eternal Presence - Randomized)
-- =========================================================================

local lastAFKTime = 0

local function AntiAFKLoop()
    if not Settings.AntiAFKInterval or not Player.Character then return end

    if tick() - lastAFKTime > Settings.AntiAFKInterval then 
        local camera = Workspace.CurrentCamera
        local randomRotation = math.random(-5, 5) -- Add randomness to the rotation
        camera.CFrame = camera.CFrame * CFrame.Angles(0, math.rad(randomRotation), 0)
        lastAFKTime = tick()
    end
end

RunService.Stepped:Connect(AntiAFKLoop)

-- =========================================================================
-- MODULE 5: Pet Dominance (Rapid Hatch Automation) - Path Updated for LoS assumption
-- =========================================================================

local PetDominanceSettings = {
    Enabled = true,
    EggButtonPath = "PlayerGui.MainUI.InventoryFrame.PetHatching.HatchButton" -- Adjusted common LoS path
}

local function HatchLoop()
    if not PetDominanceSettings.Enabled then return end
    
    local HatchButton = Player.PlayerGui:FindFirstChild("MainUI", true) and 
                        Player.PlayerGui.MainUI:FindFirstChild("InventoryFrame", true) and 
                        Player.PlayerGui.MainUI.InventoryFrame:FindFirstChild("PetHatching", true) and 
                        Player.PlayerGui.MainUI.InventoryFrame.PetHatching:FindFirstChild("HatchButton", true)

    if HatchButton and HatchButton:IsA("GuiButton") then
        HatchButton:Fire("MouseButton1Click") 
    end
end

-- Run the hatching loop aggressively 
RunService.Stepped:Connect(function()
    if PetDominanceSettings.Enabled and tick() % 0.05 < 0.01 then
        HatchLoop()
    end
end)

-- =========================================================================
-- MODULE 6: Aura and Rebirth Automation (LoS Progression Loop)
-- Goal: Achieve exponential growth by automating crucial mid-game actions.
-- =========================================================================

local AuraRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 60) and 
                   game:GetService("ReplicatedStorage").Remotes:FindFirstChild("PurchaseAura") 
local RebirthRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 60) and 
                      game:GetService("ReplicatedStorage").Remotes:FindFirstChild("Rebirth") 

local function ProgressionLoop()
    -- 1. Auto-Rebirth Check
    -- Assuming a common Gems stat location
    local GemsStat = Player.leaderstats and Player.leaderstats:FindFirstChild("Gems") 
    
    if Settings.AutoRebirthEnabled and GemsStat and GemsStat.Value >= Settings.MinGemsForRebirth then
        if RebirthRemote and RebirthRemote:IsA("RemoteEvent") then
            RebirthRemote:FireServer()
            print("<<< AUTO-REBIRTH EXECUTED >>>")
        end
    end

    -- 2. Auto-Aura Purchase (Assumes you have the correct Gems, tries to buy the latest one)
    if Settings.AutoAuraEnabled and AuraRemote and AuraRemote:IsA("RemoteEvent") then
        -- We fire without specific ID, hoping the server defaults to the highest purchasable/next available
        AuraRemote:FireServer() 
        -- For robust systems, you'd iterate through known Aura IDs and fire. This is faster.
    end
end

-- Run this check every few seconds to compound power
spawn(function()
    while Settings.AutoRebirthEnabled or Settings.AutoAuraEnabled do
        wait(5) 
        ProgressionLoop()
    end
end)


-- Initialization Display (Crucial for the operator)
print("---------------------------------------")
print("APEX SPEED GOD V3.0: UNTOUCHABLE PROTOCOL ACTIVE")
print("TARGET: Legends of Speed (Xeno/Modern Executor Optimized)")
print("MODULE 1 (Auto Step): " .. tostring(Settings.AutoStepEnabled))
print("MODULE 2 (Stealth Vacuum): " .. tostring(Settings.StealthVacuumEnabled) .. " (Physics-based)")
print("MODULE 5 (Pet Hatch): " .. tostring(PetDominanceSettings.Enabled) .. " (Path Assumed)")
print("MODULE 6 (Progression): " .. tostring(Settings.AutoRebirthEnabled) .. "/" .. tostring(Settings.AutoAuraEnabled))
print("CALL TeleportToZone('ChaosRealm') for instant zone bypass.")
print("---------------------------------------")
