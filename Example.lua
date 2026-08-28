-- Replace the string below with the raw URL to your uploaded UI Library.
-- Alternatively, if in Studio: local Library = require(script.Parent.WindUI)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/d1versity/Wind/refs/heads/main/Library.lua"))()

-- Create Window
local Window = Library:CreateWindow("Wind UI")

-- Create Tabs using built-in Icons
local AimbotTab = Window:CreateTab("Aimbot", "Target")
local VisualsTab = Window:CreateTab("Visuals", "Eye")
local MiscTab = Window:CreateTab("Misc", "Repeat")

-- Populate Aimbot Tab
local MainSec = AimbotTab:CreateSection("Main", "Left")
local FovSlider = MainSec:CreateSlider("Field of View", 10, 180, 63, function(v) end)
MainSec:CreateToggle("Enabled", true, function(v) end)

-- Demonstration of the Dynamic Dropdown Updaters
local HitboxDrop = MainSec:CreateDropdown("Hitbox", {"Head", "Torso", "Legs"}, "Head", function(selected) 
    print("Selected:", selected) 
end)

MainSec:CreateColorPicker("FOV Color", Color3.fromRGB(65, 120, 225), function(color) end)

local TargetSec = AimbotTab:CreateSection("Selection", "Left")
TargetSec:CreateSlider("Hit Chance", 1, 100, 50, function(v) end)

local OtherSec = AimbotTab:CreateSection("Other", "Right")
OtherSec:CreateDualButtons("Refresh Hitboxes", function() 
    HitboxDrop:Refresh({"Neck", "Arms", "Feet"}, "Neck") -- Instantly updates dropdown
    Window:Notify("Dropdown Refreshed", "Hitbox options have been updated to new values.", 3)
end, "Reset FOV", function() 
    FovSlider:Set(60) -- Instantly updates slider
end)

-- Keybind strictly captures only 1 key instantly on press and fires natively!
OtherSec:CreateKeybind("Trigger Key", Enum.KeyCode.F, function() 
    print("Action Fired!") 
end)

OtherSec:CreateButton("Test Notification", function()
    Window:Notify("System Message", "This is an animated notification complete with a draining progress bar. It dynamically resizes itself to fit incredibly long sentences without any text getting cut off!", 8)
end)

local VisMain = VisualsTab:CreateSection("ESP Options", "Left")
VisMain:CreateToggle("Show Boxes", true, function() end)
VisMain:CreateColorPicker("Box Color", Color3.fromRGB(65, 120, 225), function(color) end)

-- On Startup Notification 
task.delay(1.5, function()
    Window:Notify("Success", "Welcome to Wind UI. Library loaded successfully.", 7)
end)
