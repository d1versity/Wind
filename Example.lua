-- Replace the string below with the raw URL to your uploaded UI Library.
-- Note: Wind UI automatically prevents double execution if the script is already running.
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/d1versity/Wind/refs/heads/main/Library.lua"))()
local LocalPlayer = game:GetService("Players").LocalPlayer

-- Create Window
local Window = Library:CreateWindow("Wind UI")

-- Create Tabs using any Lucide icon name (e.g., "crosshair", "eye", "sliders-horizontal", "flame", "swords")
local AimbotTab = Window:CreateTab("Aimbot", "crosshair")
local VisualsTab = Window:CreateTab("Visuals", "eye")
local MiscTab = Window:CreateTab("Misc", "sliders-horizontal")

-- Populate Aimbot Tab
local MainSec = AimbotTab:CreateSection("Main", "Left")
local FovSlider = MainSec:CreateSlider("Field of View", 10, 180, 63, function(v)
    print("FOV:", v)
end)

MainSec:CreateToggle("Enabled", true, function(v)
    print("Aimbot Enabled:", v)
end)

-- Demonstration of the Dynamic Dropdown Updaters
local HitboxDrop = MainSec:CreateDropdown("Hitbox", {"Head", "Torso", "Legs"}, "Head", function(selected) 
    print("Selected:", selected) 
end)

MainSec:CreateColorPicker("FOV Color", Color3.fromRGB(65, 120, 225), function(color)
    print("FOV Color:", color)
end)

local TargetSec = AimbotTab:CreateSection("Selection", "Left")
TargetSec:CreateSlider("Hit Chance", 1, 100, 50, function(v)
    print("Hit Chance:", v)
end)

local OtherSec = AimbotTab:CreateSection("Other", "Right")
OtherSec:CreateDualButtons("Refresh Hitboxes", function() 
    HitboxDrop:Refresh({"Neck", "Arms", "Feet"}, "Neck") -- Instantly updates dropdown
    Window:Notify("Dropdown Refreshed", "Hitbox options have been updated to new values.", 3)
end, "Reset FOV", function() 
    FovSlider:Set(60) -- Instantly updates slider
end)

-- Keybind passes (key, isPressed): 'false' when assigned, 'true' when pressed in-game
OtherSec:CreateKeybind("Trigger Key", Enum.KeyCode.F, function(key, isPressed) 
    if isPressed then
        print("Action Fired with key:", key.Name)
    end
end)

OtherSec:CreateButton("Test Notification", function()
    Window:Notify("System Message", "This is an animated notification complete with a draining progress bar. It dynamically resizes itself to fit incredibly long sentences without any text getting cut off!", 8)
end)

-- Populate Visuals Tab
local VisMain = VisualsTab:CreateSection("ESP Options", "Left")
VisMain:CreateToggle("Show Boxes", true, function(v) end)
VisMain:CreateColorPicker("Box Color", Color3.fromRGB(65, 120, 225), function(color) end)

-- Populate Misc Tab
local MiscMain = MiscTab:CreateSection("Utilities", "Left")
MiscMain:CreateInput("Custom Tag", "Type something...", function(text)
    print("Input submitted:", text)
end)

-- ========================================== --
--         MODULAR MINI WINDOW DEMO           --
-- ========================================== --
local StatusWin = Window:CreateMiniWindow({
    Title = "Player Status",
    Width = 250,
    Position = UDim2.new(0, 50, 0, 120),
    Visible = false
})

local TopRow = StatusWin:AddRow(8)
local PlayerAvatar = TopRow:AddImage("rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150", 28, true)
local PlayerName = TopRow:AddText(LocalPlayer.DisplayName, { Bold = true })
TopRow:AddDivider(true)
local PlayerState = TopRow:AddText("Active", { SubText = true })

StatusWin:AddDivider(false)
local HealthBar = StatusWin:AddProgressBar(0.85)
StatusWin:AddButton("Randomize Progress", function()
    local newVal = math.random(10, 100) / 100
    HealthBar:Set(newVal)
    PlayerState:Set(math.floor(newVal * 100) .. "%")
end)

local MiscHudSec = MiscTab:CreateSection("Mini Windows", "Right")
MiscHudSec:CreateToggle("Show Player Status HUD", false, function(state)
    StatusWin:SetVisible(state)
end)

-- Startup Notification (automatically queued until the cinematic intro finishes)
Window:Notify("Success", "Welcome to Wind UI v2.7. Library loaded successfully.", 7)
