-- Pink Neon Fluent GUI Enhanced
local a, b = {
    {
        1,
        "ModuleScript",
        {"MainModule"},
        {
            {18, "ModuleScript", {"Creator"}},
            {28, "ModuleScript", {"Icons"}},
            {
                47,
                "ModuleScript",
                {"Themes"},
                {
                    {48, "ModuleScript", {"PinkNeon"}} -- Thêm theme mới
                }
            },
            -- ... rest of the structure remains similar
        }
    }
}

local function createEnhancedGUI()
    local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/Source.lua"))()
    
    -- Custom Pink Neon Theme
    local PinkNeonTheme = {
        Accent = Color3.fromRGB(255, 20, 147), -- Hot Pink
        AccentDark = Color3.fromRGB(199, 0, 57), -- Deep Pink
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(200, 200, 200),
        Element = Color3.fromRGB(30, 30, 40),
        ElementTransparency = 0.9,
        HoverChange = 0.05,
        ToggleToggled = Color3.fromRGB(255, 20, 147),
        ToggleSlider = Color3.fromRGB(100, 100, 120),
        SliderRail = Color3.fromRGB(50, 50, 60),
        DropdownFrame = Color3.fromRGB(40, 40, 50),
        DropdownHolder = Color3.fromRGB(35, 35, 45),
        DropdownBorder = Color3.fromRGB(255, 20, 147),
        Keybind = Color3.fromRGB(45, 45, 55),
        Dialog = Color3.fromRGB(35, 35, 45),
        DialogBorder = Color3.fromRGB(255, 20, 147),
        DialogHolder = Color3.fromRGB(40, 40, 50),
        DialogButton = Color3.fromRGB(50, 50, 60),
        DialogButtonBorder = Color3.fromRGB(255, 20, 147),
        TitleBarLine = Color3.fromRGB(255, 20, 147),
        Tab = Color3.fromRGB(40, 40, 50),
        InElementBorder = Color3.fromRGB(80, 80, 90),
        ElementBorder = Color3.fromRGB(255, 20, 147),
        AcrylicMain = Color3.fromRGB(20, 20, 30),
        AcrylicBorder = Color3.fromRGB(255, 20, 147),
        AcrylicGradient = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 20, 147)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(148, 0, 211))
        },
        AcrylicNoise = 0.8
    }

    -- Apply custom theme
    for theme, colors in pairs(PinkNeonTheme) do
        Fluent:SetThemeColor(theme, colors)
    end

    -- Enhanced Window Creation
    local Window = Fluent:CreateWindow({
        Title = "Pink Neon GUI",
        SubTitle = "Enhanced Version",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = true,
        Theme = "PinkNeon",
        MinimizeKey = Enum.KeyCode.RightControl
    })

    -- Add glowing effect to window
    local function addGlowEffect(frame)
        local glow = Instance.new("UIStroke")
        glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        glow.Color = Color3.fromRGB(255, 20, 147)
        glow.Thickness = 2
        glow.Transparency = 0.7
        glow.Parent = frame
        
        -- Pulsing animation
        local pulseSpeed = 1
        local connection
        connection = game:GetService("RunService").Heartbeat:Connect(function(dt)
            local alpha = 0.5 + math.sin(tick() * pulseSpeed) * 0.3
            glow.Transparency = 0.8 - alpha * 0.3
        end)
        
        frame.Destroying:Connect(function()
            connection:Disconnect()
        end)
    end

    -- Enhanced Tabs with Icons
    local MainTab = Window:AddTab({
        Title = "🏠 Main",
        Icon = "home"
    })

    local SettingsTab = Window:AddTab({
        Title = "⚙️ Settings",
        Icon = "settings"
    })

    -- Enhanced Sections with better styling
    local MainSection = MainTab:AddSection("🌟 Main Features")
    local VisualSection = MainTab:AddSection("🎨 Visual Effects")
    local ConfigSection = SettingsTab:AddSection("🔧 Configuration")

    -- Enhanced Toggle with better visuals
    local EnhancedToggle = MainSection:AddToggle("EnhancedMode", {
        Title = "✨ Enhanced Mode",
        Description = "Enable advanced features and effects",
        Default = false
    })

    -- Color Picker with neon colors
    local NeonColor = VisualSection:AddColorpicker("NeonColor", {
        Title = "🎨 Neon Color",
        Description = "Choose your neon accent color",
        Default = Color3.fromRGB(255, 20, 147),
        Transparency = 0
    })

    -- Enhanced Dropdown with search
    local FeatureDropdown = MainSection:AddDropdown("Features", {
        Title = "🚀 Features",
        Description = "Select features to enable",
        Values = {"Auto Farm", "ESP", "Aimbot", "Speed Hack", "Fly"},
        Multi = true,
        Default = {"Auto Farm"}
    })

    -- Enhanced Slider with value display
    local SpeedSlider = MainSection:AddSlider("SpeedMultiplier", {
        Title = "⚡ Speed Multiplier",
        Description = "Adjust movement speed",
        Default = 1,
        Min = 1,
        Max = 10,
        Rounding = 1
    })

    -- Enhanced Button with hover effects
    local ExecuteBtn = MainSection:AddButton("Execute", {
        Title = "🎯 Execute Script",
        Description = "Run the selected features"
    })

    ExecuteBtn:OnClick(function()
        Fluent:Notify({
            Title = "Execution Started",
            Content = "Running selected features...",
            SubContent = "Check console for details",
            Duration = 3
        })
    end)

    -- Keybind with better styling
    local ToggleKeybind = ConfigSection:AddKeybind("ToggleGUI", {
        Title = "🔑 Toggle GUI",
        Description = "Key to show/hide the interface",
        Default = "RightControl",
        Mode = "Toggle"
    })

    -- Enhanced Input with placeholder
    local PlayerName = ConfigSection:AddInput("PlayerName", {
        Title = "👤 Player Name",
        Description = "Enter target player name",
        Default = "",
        Placeholder = "Enter username...",
        Numeric = false
    })

    -- Add some visual separators
    local function addSeparator(section, text)
        section:AddParagraph({
            Title = text,
            Content = "―".rep(50)
        })
    end

    addSeparator(MainSection, "Visual Settings")
    
    -- Background toggle
    local BackgroundToggle = VisualSection:AddToggle("CustomBackground", {
        Title = "🌃 Custom Background",
        Description = "Enable animated background",
        Default = true
    })

    -- Particle effects toggle
    local ParticlesToggle = VisualSection:AddToggle("ParticleEffects", {
        Title = "✨ Particle Effects",
        Description = "Enable floating particles",
        Default = false
    })

    -- Apply glow to main window
    spawn(function()
        wait(1)
        if Window.Root then
            addGlowEffect(Window.Root)
        end
    end)

    -- Enhanced notifications
    local function showEnhancedNotification(title, content)
        Fluent:Notify({
            Title = title,
            Content = content,
            SubContent = "Pink Neon GUI",
            Duration = 5
        })
    end

    -- Demo notification
    spawn(function()
        wait(2)
        showEnhancedNotification("🎉 Welcome!", "Pink Neon GUI loaded successfully!")
    end)

    return {
        Window = Window,
        Fluent = Fluent,
        Tabs = {
            Main = MainTab,
            Settings = SettingsTab
        },
        Notify = showEnhancedNotification
    }
end

-- Initialize the enhanced GUI
local EnhancedGUI = createEnhancedGUI()

-- Make it globally accessible
getgenv().PinkNeonGUI = EnhancedGUI

return EnhancedGUI
