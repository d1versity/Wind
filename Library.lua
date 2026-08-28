-- Wind by d1versity [A.K.A. Vhyse] | v1.4
-- Prolly the coolest UI I have ever made

local Library = {
    Theme = {
        OuterBorder = Color3.fromRGB(5, 5, 5),
        MainBg = Color3.fromRGB(12, 12, 15),
        SidebarBg = Color3.fromRGB(10, 10, 12),
        SectionBg = Color3.fromRGB(16, 17, 20),
        Border = Color3.fromRGB(35, 35, 40),
        Accent = Color3.fromRGB(65, 120, 225),
        Text = Color3.fromRGB(230, 230, 235),
        SubText = Color3.fromRGB(140, 140, 150),
        ElementBg = Color3.fromRGB(22, 23, 28),
        Hover = Color3.fromRGB(30, 31, 38)
    },
    Icons = {
        Wind        = "rbxassetid://10747382750",
        Person      = "rbxassetid://10747373176",
        Warning     = "rbxassetid://10709753149",
        Info        = "rbxassetid://10723415903",
        Settings    = "rbxassetid://10734950309",
        Target      = "rbxassetid://10734977012",
        Crosshair   = "rbxassetid://10709818534",
        Gun         = "rbxassetid://10709818534",
        Repeat      = "rbxassetid://10734933966",
        Eye         = "rbxassetid://10723346959",
        Home        = "rbxassetid://10723407389",
        Search      = "rbxassetid://10734943674",
        Shield      = "rbxassetid://10734951847",
        Code        = "rbxassetid://10709810463",
        Crystal     = "rbxassetid://7734053426",
        Save        = "rbxassetid://10734950309" 
    },
    Registry = {},
    Connections = {},
    AllowDrag = true,
    ColorClipboard = Color3.fromRGB(255, 255, 255)
}

local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local function Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do inst[k] = v end
    return inst
end

local function MakeSmoothDraggable(dragHandle, frameToMove)
    local dragging = false
    local dragInput, dragStart, startPos
    local targetPos = frameToMove.Position

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and Library.AllowDrag then
            dragging = true
            dragStart = input.Position
            startPos = frameToMove.Position
            targetPos = startPos
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging and Library.AllowDrag then
            local delta = input.Position - dragStart
            targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    local lerpConn = RS.RenderStepped:Connect(function(dt)
        if frameToMove.Parent and Library.AllowDrag then
            local currentPos = frameToMove.Position
            if currentPos ~= targetPos then
                frameToMove.Position = currentPos:Lerp(targetPos, math.clamp(dt * 15, 0, 1))
            end
        end
    end)
    table.insert(Library.Connections, lerpConn)
end

local function FadeUI(element, isVisible, duration)
    local proxy = element:FindFirstChild("FadeProxy")
    if not proxy then
        proxy = Create("NumberValue", {Name = "FadeProxy", Value = isVisible and 0 or 1, Parent = element})
        proxy.Changed:Connect(function(val)
            local function apply(obj)
                if obj:GetAttribute("OrigStored") then
                    local obg = obj:GetAttribute("OBg")
                    if obg then obj.BackgroundTransparency = obg + (1 - obg) * val end
                    local otx = obj:GetAttribute("OTx")
                    if otx then obj.TextTransparency = otx + (1 - otx) * val end
                    local ost = obj:GetAttribute("OSt")
                    if ost then obj.Transparency = ost + (1 - ost) * val end
                    local oim = obj:GetAttribute("OIm")
                    if oim then obj.ImageTransparency = oim + (1 - oim) * val end
                    local osc = obj:GetAttribute("OSc")
                    if osc then obj.ScrollBarImageTransparency = osc + (1 - osc) * val end
                end
            end
            apply(element)
            for _, child in ipairs(element:GetDescendants()) do apply(child) end
        end)
    end
    
    local function tag(obj)
        if not obj:GetAttribute("OrigStored") then
            obj:SetAttribute("OrigStored", true)
            if obj:IsA("GuiObject") then obj:SetAttribute("OBg", obj.BackgroundTransparency) end
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then obj:SetAttribute("OTx", obj.TextTransparency) end
            if obj:IsA("UIStroke") then obj:SetAttribute("OSt", obj.Transparency) end
            if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then obj:SetAttribute("OIm", obj.ImageTransparency) end
            if obj:IsA("ScrollingFrame") then obj:SetAttribute("OSc", obj.ScrollBarImageTransparency) end
        end
    end
    tag(element)
    for _, child in ipairs(element:GetDescendants()) do tag(child) end
    
    local target = isVisible and 0 or 1
    if duration == 0 then
        proxy.Value = target
    else
        TS:Create(proxy, TweenInfo.new(duration, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Value = target}):Play()
    end
end

function Library:CreateWindow(titleText)
    local sg = Create("ScreenGui", {
        Name = "Wind_UI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        Parent = (gethui and gethui()) or game:GetService("CoreGui")
    })

    -- [ WATERMARK SYSTEM ]
    local WMOuter = Create("Frame", { 
        Size = UDim2.new(0, 0, 0, 42), 
        Position = UDim2.new(0, 50, 0, 50), 
        BackgroundColor3 = Library.Theme.OuterBorder, 
        BackgroundTransparency = 0.4, 
        BorderSizePixel = 0, 
        AutomaticSize = Enum.AutomaticSize.X, 
        Visible = false, 
        Parent = sg 
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = WMOuter })
    Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), Parent = WMOuter })
    MakeSmoothDraggable(WMOuter, WMOuter)
    
    local WMInner = Create("Frame", { 
        Size = UDim2.new(0, 0, 1, 0), 
        BackgroundColor3 = Library.Theme.MainBg, 
        AutomaticSize = Enum.AutomaticSize.X, 
        Parent = WMOuter 
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = WMInner })
    Create("UIStroke", { Color = Library.Theme.Border, Thickness = 1, Parent = WMInner })
    Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = WMInner })
    
    local WMLayout = Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = WMInner })

    local function AddWMLine(order)
        local line = Create("Frame", { Size = UDim2.new(0, 2, 0, 16), BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0, LayoutOrder = order, Parent = WMInner })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = line })
    end

    local WMIcon = Create("ImageLabel", { Size = UDim2.new(0, 24, 0, 24), BackgroundTransparency = 1, Image = Library.Icons.Wind, ImageColor3 = Library.Theme.Accent, LayoutOrder = 0, Parent = WMInner })
    AddWMLine(1)

    local WMAvatar = Create("ImageLabel", { Size = UDim2.new(0, 24, 0, 24), BackgroundColor3 = Library.Theme.ElementBg, Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150", LayoutOrder = 2, Parent = WMInner })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = WMAvatar })
    AddWMLine(3)

    local WMName = Create("TextLabel", { AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, Text = LocalPlayer.DisplayName, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 13, LayoutOrder = 4, Parent = WMInner })
    AddWMLine(5)
    
    local WMTime = Create("TextLabel", { AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, Text = "00:00:00", TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, LayoutOrder = 6, Parent = WMInner })
    AddWMLine(7)
    
    local WMFPS = Create("TextLabel", { AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, RichText = true, Text = "0 <font color='#"..Library.Theme.Accent:ToHex().."'>FPS</font>", TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, LayoutOrder = 8, Parent = WMInner })
    AddWMLine(9)

    local gameName = "Roblox"
    if game.PlaceId > 0 then
        task.spawn(function()
            pcall(function()
                gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
                if #gameName > 30 then gameName = gameName:sub(1, 30) .. "..." end
            end)
        end)
    end
    local WMGame = Create("TextLabel", { AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, Text = gameName, TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, LayoutOrder = 10, Parent = WMInner })

    local lastTick, frames = tick(), 0
    RS.RenderStepped:Connect(function()
        frames = frames + 1
        if tick() - lastTick >= 1 then
            WMFPS.Text = frames .. " <font color='#"..Library.Theme.Accent:ToHex().."'>FPS</font>"
            frames = 0
            lastTick = tick()
        end
        WMTime.Text = os.date("%H:%M:%S")
        WMGame.Text = gameName
    end)

    -- Force Cache Initial Fade States
    WMOuter.Visible = true
    FadeUI(WMOuter, false, 0)
    WMOuter.Visible = false

    -- [ MAIN WINDOW ]
    local OuterFrame = Create("Frame", { Size = UDim2.new(0, 760, 0, 510), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.5, -255), BackgroundColor3 = Library.Theme.OuterBorder, BackgroundTransparency = 0.4, BorderSizePixel = 0, ClipsDescendants = true, Parent = sg })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = OuterFrame })
    MakeSmoothDraggable(OuterFrame, OuterFrame)

    local MainFrame = Create("Frame", { Size = UDim2.new(1, -10, 1, -10), Position = UDim2.new(0, 5, 0, 5), BackgroundColor3 = Library.Theme.MainBg, BorderSizePixel = 0, Parent = OuterFrame })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = MainFrame })
    Create("UIStroke", { Color = Library.Theme.Border, Thickness = 1, Parent = MainFrame })

    local Sidebar = Create("Frame", { Size = UDim2.new(0, 190, 1, 0), BackgroundColor3 = Library.Theme.SidebarBg, BorderSizePixel = 0, Parent = MainFrame })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Sidebar })
    Create("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BackgroundColor3 = Library.Theme.Border, BorderSizePixel = 0, Parent = Sidebar })

    local LogoArea = Create("Frame", { Size = UDim2.new(1, 0, 0, 70), BackgroundTransparency = 1, Parent = Sidebar })
    Create("ImageLabel", { Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0, 16, 0.5, -12), BackgroundTransparency = 1, Image = Library.Icons.Wind, ImageColor3 = Library.Theme.Accent, Parent = LogoArea })
    Create("TextLabel", { Size = UDim2.new(1, -50, 0, 20), Position = UDim2.new(0, 48, 0.5, -10), BackgroundTransparency = 1, Text = titleText, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = LogoArea })

    local TabContainer = Create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -140), Position = UDim2.new(0, 0, 0, 70), BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = Sidebar })
    Create("UIListLayout", { Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Parent = TabContainer })

    local ProfileArea = Create("Frame", { Size = UDim2.new(1, 0, 0, 70), Position = UDim2.new(0, 0, 1, -70), BackgroundTransparency = 1, Parent = Sidebar })
    local Avatar = Create("ImageLabel", { Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(0, 15, 0.5, -16), BackgroundColor3 = Library.Theme.ElementBg, Image = "rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150", Parent = ProfileArea })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Avatar })
    Create("TextLabel", { Size = UDim2.new(1, -60, 0, 20), Position = UDim2.new(0, 55, 0.5, -10), BackgroundTransparency = 1, Text = LocalPlayer.DisplayName, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = ProfileArea })

    local ContentContainer = Create("Frame", { Size = UDim2.new(1, -190, 1, 0), Position = UDim2.new(0, 190, 0, 0), BackgroundTransparency = 1, Parent = MainFrame })

    local TopBar = Create("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Parent = ContentContainer })
    local SearchBtn = Create("ImageButton", { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -30, 0.5, -9), BackgroundTransparency = 1, Image = Library.Icons.Search, ImageColor3 = Library.Theme.SubText, Parent = TopBar })
    
    local SearchBox = Create("TextBox", { Size = UDim2.new(0, 0, 0, 28), Position = UDim2.new(1, -60, 0.5, -14), AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = Library.Theme.ElementBg, TextColor3 = Library.Theme.Text, PlaceholderText = "Search...", Text = "", Font = Enum.Font.Gotham, TextSize = 12, ClipsDescendants = true, Visible = false, Parent = TopBar })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = SearchBox })
    Create("UIStroke", { Color = Library.Theme.Border, Parent = SearchBox })
    Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = SearchBox })

    local searchOpen = false
    SearchBtn.MouseButton1Click:Connect(function()
        searchOpen = not searchOpen
        if searchOpen then
            SearchBox.Visible = true
            TS:Create(SearchBox, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = UDim2.new(0, 200, 0, 28)}):Play()
            TS:Create(SearchBtn, TweenInfo.new(0.3), {ImageColor3 = Library.Theme.Accent}):Play()
        else
            SearchBox.Text = ""
            TS:Create(SearchBox, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 28)}):Play()
            TS:Create(SearchBtn, TweenInfo.new(0.3), {ImageColor3 = Library.Theme.SubText}):Play()
            task.delay(0.3, function() if not searchOpen then SearchBox.Visible = false end end)
        end
    end)

    local isVisible = true
    local isAnimating = true
    local baseSize = UDim2.new(0, 760, 0, 510)
    
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Insert and not isAnimating then
            isAnimating = true
            isVisible = not isVisible
            if isVisible then
                OuterFrame.Visible = true
                TS:Create(OuterFrame, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = baseSize}):Play()
                task.delay(0.5, function() isAnimating = false end)
            else
                TS:Create(OuterFrame, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Size = UDim2.new(0, 760, 0, 0)}):Play()
                task.delay(0.45, function() OuterFrame.Visible = false; isAnimating = false end)
            end
        end
    end)

    local NotifContainer = Create("Frame", { Size = UDim2.new(0, 310, 1, -20), Position = UDim2.new(1, -330, 0, 10), BackgroundTransparency = 1, Parent = sg })
    Create("UIListLayout", { Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right, Parent = NotifContainer })

    local WindowObj = { CurrentTab = nil, Tabs = {}, TabCount = 0, IsLoadingConfig = false }
    
    function WindowObj:Notify(title, text, duration)
        if WindowObj.IsLoadingConfig then return end
        
        duration = duration or 5
        local textBounds = TextService:GetTextSize(text, 12, Enum.Font.Gotham, Vector2.new(225, 9999))
        local descHeight = textBounds.Y
        local innerHeight = math.max(60, 32 + descHeight + 15) 
        local targetHeight = innerHeight + 10
        
        local OuterNFrame = Create("Frame", { Size = UDim2.new(0, 290, 0, 0), BackgroundColor3 = Library.Theme.OuterBorder, BackgroundTransparency = 0.4, ClipsDescendants = true, Parent = NotifContainer })
        Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = OuterNFrame })

        local NFrame = Create("Frame", { Size = UDim2.new(1, -10, 1, -10), Position = UDim2.new(0, 5, 0, 5), BackgroundColor3 = Library.Theme.SectionBg, ClipsDescendants = true, Parent = OuterNFrame })
        Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = NFrame })
        Create("UIStroke", { Color = Library.Theme.Border, Parent = NFrame })
        
        local Icon = Create("ImageLabel", { Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0, 15, 0, 12), BackgroundTransparency = 1, Image = Library.Icons.Info, ImageColor3 = Library.Theme.Accent, Parent = NFrame })
        Create("TextLabel", { Size = UDim2.new(1, -55, 0, 20), Position = UDim2.new(0, 48, 0, 10), BackgroundTransparency = 1, Text = title, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = NFrame })
        Create("TextLabel", { Size = UDim2.new(1, -55, 0, descHeight), Position = UDim2.new(0, 48, 0, 32), BackgroundTransparency = 1, Text = text, TextColor3 = Library.Theme.SubText, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, Parent = NFrame })
        
        local ProgBar = Create("Frame", { Size = UDim2.new(1, -12, 0, 2), Position = UDim2.new(0, 6, 1, -4), AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0, Parent = NFrame })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ProgBar })

        TS:Create(OuterNFrame, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = UDim2.new(0, 290, 0, targetHeight)}):Play()
        TS:Create(ProgBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)}):Play()
        
        task.delay(duration, function()
            TS:Create(OuterNFrame, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Size = UDim2.new(0, 290, 0, 0)}):Play()
            task.delay(0.4, function() OuterNFrame:Destroy() end)
        end)
    end

    local CPBg = Create("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Visible = false, ZIndex = 50, Parent = MainFrame })
    local CPWindow = Create("Frame", { Size = UDim2.new(0, 240, 0, 350), Position = UDim2.new(0.5, -120, 0.5, -175), BackgroundColor3 = Library.Theme.MainBg, ZIndex = 51, Parent = CPBg })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = CPWindow })
    Create("UIStroke", { Color = Library.Theme.Border, Parent = CPWindow })
    
    Create("TextLabel", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "Color Picker", TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 13, ZIndex = 52, Parent = CPWindow })

    local SVMap = Create("TextButton", { Size = UDim2.new(1, -20, 0, 150), Position = UDim2.new(0, 10, 0, 35), BackgroundColor3 = Color3.fromRGB(255, 0, 0), AutoButtonColor = false, Text = "", ZIndex = 52, Parent = CPWindow })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = SVMap })
    local SVWhite = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), ZIndex = 53, Parent = SVMap })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = SVWhite })
    Create("UIGradient", { Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}), Parent = SVWhite })
    local SVBlack = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0), ZIndex = 54, Parent = SVMap })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = SVBlack })
    Create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}), Parent = SVBlack })
    local SVThumb = Create("Frame", { Size = UDim2.new(0, 10, 0, 10), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), ZIndex = 55, Parent = SVMap })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SVThumb })
    Create("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Parent = SVThumb })

    local HueSlider = Create("TextButton", { Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 10, 0, 195), BackgroundColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false, Text = "", ZIndex = 52, Parent = CPWindow })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = HueSlider })
    Create("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)) }), Parent = HueSlider })
    local HueThumb = Create("Frame", { Size = UDim2.new(0, 6, 1, 4), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), ZIndex = 53, Parent = HueSlider })
    Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = HueThumb })
    Create("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Parent = HueThumb })

    local RGBContainer = Create("Frame", { Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 220), BackgroundTransparency = 1, ZIndex = 52, Parent = CPWindow })
    Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5), Parent = RGBContainer })
    
    local function CreateRGBBox(name)
        local f = Create("Frame", { Size = UDim2.new(0, 70, 1, 0), BackgroundTransparency = 1, ZIndex = 52, Parent = RGBContainer })
        Create("TextLabel", { Size = UDim2.new(0, 15, 1, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Library.Theme.SubText, Font = Enum.Font.GothamBold, TextSize = 12, ZIndex = 52, Parent = f })
        local box = Create("TextBox", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 20, 0, 0), BackgroundColor3 = Library.Theme.ElementBg, TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12, ZIndex = 52, Parent = f })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = box })
        Create("UIStroke", { Color = Library.Theme.Border, Parent = box })
        return box
    end
    local RBox, GBox, BBox = CreateRGBBox("R"), CreateRGBBox("G"), CreateRGBBox("B")

    local CopyPasteContainer = Create("Frame", { Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 265), BackgroundTransparency = 1, ZIndex = 52, Parent = CPWindow })
    local CopyBtn = Create("TextButton", { Size = UDim2.new(0.5, -5, 1, 0), BackgroundColor3 = Library.Theme.ElementBg, Text = "Copy", TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false, ZIndex = 52, Parent = CopyPasteContainer })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = CopyBtn })
    Create("UIStroke", { Color = Library.Theme.Border, Parent = CopyBtn })
    local PasteBtn = Create("TextButton", { Size = UDim2.new(0.5, -5, 1, 0), Position = UDim2.new(0.5, 5, 0, 0), BackgroundColor3 = Library.Theme.ElementBg, Text = "Paste", TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false, ZIndex = 52, Parent = CopyPasteContainer })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = PasteBtn })
    Create("UIStroke", { Color = Library.Theme.Border, Parent = PasteBtn })

    local CloseCPBtn = Create("TextButton", { Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 305), BackgroundColor3 = Library.Theme.ElementBg, Text = "Apply & Close", TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false, ZIndex = 52, Parent = CPWindow })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = CloseCPBtn })
    Create("UIStroke", { Color = Library.Theme.Border, Parent = CloseCPBtn })

    local CPState = { H = 0, S = 1, V = 1, Callback = nil }

    local function UpdateCPVisuals()
        local c = Color3.fromHSV(CPState.H, CPState.S, CPState.V)
        SVMap.BackgroundColor3 = Color3.fromHSV(CPState.H, 1, 1)
        SVThumb.Position = UDim2.new(CPState.S, 0, 1 - CPState.V, 0)
        HueThumb.Position = UDim2.new(CPState.H, 0, 0.5, 0)
        RBox.Text = tostring(math.floor(c.R * 255))
        GBox.Text = tostring(math.floor(c.G * 255))
        BBox.Text = tostring(math.floor(c.B * 255))
        if CPState.Callback then CPState.Callback(c) end
    end

    CopyBtn.MouseButton1Click:Connect(function()
        Library.ColorClipboard = Color3.fromHSV(CPState.H, CPState.S, CPState.V)
    end)
    
    PasteBtn.MouseButton1Click:Connect(function()
        CPState.H, CPState.S, CPState.V = Library.ColorClipboard:ToHSV()
        UpdateCPVisuals()
    end)

    local draggingSV, draggingHue = false, false
    SVMap.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = true end end)
    HueSlider.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = false; draggingHue = false end end)
    
    UIS.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            if draggingSV then
                CPState.S = math.clamp((i.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1)
                CPState.V = 1 - math.clamp((i.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1)
                UpdateCPVisuals()
            elseif draggingHue then
                CPState.H = math.clamp((i.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
                UpdateCPVisuals()
            end
        end
    end)

    local function UpdateFromRGB()
        local r, g, b = tonumber(RBox.Text) or 255, tonumber(GBox.Text) or 255, tonumber(BBox.Text) or 255
        CPState.H, CPState.S, CPState.V = Color3.fromRGB(r, g, b):ToHSV()
        UpdateCPVisuals()
    end
    RBox.FocusLost:Connect(UpdateFromRGB)
    GBox.FocusLost:Connect(UpdateFromRGB)
    BBox.FocusLost:Connect(UpdateFromRGB)

    CloseCPBtn.MouseButton1Click:Connect(function()
        Library.AllowDrag = true
        TS:Create(CPBg, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        FadeUI(CPWindow, false, 0.2)
        task.delay(0.2, function() CPBg.Visible = false end)
    end)

    function WindowObj:OpenColorPicker(currentColor, callback)
        Library.AllowDrag = false
        CPState.H, CPState.S, CPState.V = currentColor:ToHSV()
        CPState.Callback = callback
        UpdateCPVisuals()
        
        CPBg.Visible = true
        FadeUI(CPWindow, false, 0)
        TS:Create(CPBg, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
        FadeUI(CPWindow, true, 0.2)
    end

    local isSwitchingTab = false

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        if not WindowObj.CurrentTab then return end
        
        for _, tab in ipairs(WindowObj.Tabs) do
            if tab.Name == WindowObj.CurrentTab then
                for secFrame, secData in pairs(tab.Sections) do
                    local hasVisibleElement = false
                    for _, el in ipairs(secData.Elements) do
                        local match = el.Name:lower():find(query) or query == ""
                        if match and not el.IsVisible then
                            el.IsVisible = true
                            el.Frame.Visible = true
                            TS:Create(el.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, el.OrigH)}):Play()
                            FadeUI(el.Frame, true, 0.3)
                            hasVisibleElement = true
                        elseif not match and el.IsVisible then
                            el.IsVisible = false
                            TS:Create(el.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                            FadeUI(el.Frame, false, 0.3)
                            task.delay(0.3, function() if not el.IsVisible then el.Frame.Visible = false end end)
                        elseif match then
                            hasVisibleElement = true
                        end
                    end
                    if hasVisibleElement and not secData.IsVisible then
                        secData.IsVisible = true
                        secFrame.Visible = true
                        TS:Create(secData.Title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
                        TS:Create(secData.Stroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
                    elseif not hasVisibleElement and secData.IsVisible then
                        secData.IsVisible = false
                        TS:Create(secData.Title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                        TS:Create(secData.Stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
                        task.delay(0.3, function() if not secData.IsVisible then secFrame.Visible = false end end)
                    end
                end
            end
        end
    end)

    function WindowObj:CreateTab(tabName, iconName)
        local realIcon = Library.Icons[iconName] or iconName or Library.Icons.Settings
        WindowObj.TabCount = WindowObj.TabCount + 1

        local TabBtn = Create("TextButton", { Size = UDim2.new(1, -20, 0, 36), BackgroundColor3 = Library.Theme.SidebarBg, Text = "", AutoButtonColor = false, LayoutOrder = WindowObj.TabCount, Parent = TabContainer })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TabBtn })
        local AccentLine = Create("Frame", { Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0, Parent = TabBtn })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = AccentLine })

        local TIcon = Create("ImageLabel", { Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 15, 0.5, -8), BackgroundTransparency = 1, Image = realIcon, ImageColor3 = Library.Theme.SubText, Parent = TabBtn })
        local TabText = Create("TextLabel", { Size = UDim2.new(1, -45, 1, 0), Position = UDim2.new(0, 40, 0, 0), BackgroundTransparency = 1, Text = tabName, TextColor3 = Library.Theme.SubText, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = TabBtn })

        local TabBase = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, Parent = ContentContainer })
        local TabContent = Create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -40), Position = UDim2.new(0, 0, 0, 40), BackgroundTransparency = 1, ScrollBarThickness = 0, Parent = TabBase })
        local LeftCol = Create("Frame", { Size = UDim2.new(0.5, -15, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Parent = TabContent })
        local RightCol = Create("Frame", { Size = UDim2.new(0.5, -15, 1, 0), Position = UDim2.new(0.5, 5, 0, 0), BackgroundTransparency = 1, Parent = TabContent })
        
        Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 10), Parent = LeftCol })
        Create("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 10), Parent = RightCol })
        Create("UIListLayout", { Padding = UDim.new(0, 10), Parent = LeftCol })
        Create("UIListLayout", { Padding = UDim.new(0, 10), Parent = RightCol })

        local TabObj = {Name = tabName, Btn = TabBtn, Text = TabText, Icon = TIcon, Accent = AccentLine, Base = TabBase, Sections = {}}
        table.insert(WindowObj.Tabs, TabObj)

        TabBtn.MouseButton1Click:Connect(function()
            if isSwitchingTab or WindowObj.CurrentTab == tabName then return end
            isSwitchingTab = true

            local prevTabObj
            for _, t in pairs(WindowObj.Tabs) do
                if t.Name == WindowObj.CurrentTab then prevTabObj = t end
                TS:Create(t.Btn, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.SidebarBg}):Play()
                TS:Create(t.Text, TweenInfo.new(0.2), {TextColor3 = Library.Theme.SubText}):Play()
                TS:Create(t.Icon, TweenInfo.new(0.2), {ImageColor3 = Library.Theme.SubText}):Play()
                TS:Create(t.Accent, TweenInfo.new(0.2), {Size = UDim2.new(0, 3, 0, 0)}):Play()
            end
            
            if prevTabObj then
                FadeUI(prevTabObj.Base, false, 0.15)
                task.wait(0.15)
                prevTabObj.Base.Visible = false
            end
            
            TS:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.ElementBg}):Play()
            TS:Create(TabText, TweenInfo.new(0.2), {TextColor3 = Library.Theme.Text}):Play()
            TS:Create(TIcon, TweenInfo.new(0.2), {ImageColor3 = Library.Theme.Accent}):Play()
            TS:Create(AccentLine, TweenInfo.new(0.2), {Size = UDim2.new(0, 3, 0, 18)}):Play()
            
            TabBase.Visible = true
            FadeUI(TabBase, false, 0)
            FadeUI(TabBase, true, 0.2)
            
            WindowObj.CurrentTab = tabName
            task.wait(0.2)
            isSwitchingTab = false
        end)

        -- Prevent the auto-generated config tab from stealing default focus
        if not WindowObj.CurrentTab and tabName ~= "Configuration" then
            TabBase.Visible = true
            TabBtn.BackgroundColor3 = Library.Theme.ElementBg
            TabText.TextColor3 = Library.Theme.Text
            TIcon.ImageColor3 = Library.Theme.Accent
            AccentLine.Size = UDim2.new(0, 3, 0, 18)
            WindowObj.CurrentTab = tabName
        end

        function TabObj:CreateSection(sectionName, side)
            side = side or "Left"
            local parentCol = side == "Left" and LeftCol or RightCol

            local SectionFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Library.Theme.SectionBg, Parent = parentCol })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = SectionFrame })
            local SStroke = Create("UIStroke", { Color = Library.Theme.Border, Parent = SectionFrame })

            local STitle = Create("TextLabel", { Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = string.upper(sectionName), TextColor3 = Library.Theme.SubText, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = SectionFrame })

            local ElementContainer = Create("Frame", { Size = UDim2.new(1, 0, 1, -30), Position = UDim2.new(0, 0, 0, 30), BackgroundTransparency = 1, Parent = SectionFrame })
            local ELayout = Create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = ElementContainer })

            ELayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, 0, 0, ELayout.AbsoluteContentSize.Y + 35)
                TabContent.CanvasSize = UDim2.new(0, 0, 0, math.max(LeftCol.UIListLayout.AbsoluteContentSize.Y, RightCol.UIListLayout.AbsoluteContentSize.Y) + 15)
            end)

            TabObj.Sections[SectionFrame] = {Title = STitle, Stroke = SStroke, IsVisible = true, Elements = {}}
            local SectionObj = {}
            local elementCount = 0 
            
            local function RegEl(name, frame, origH)
                elementCount = elementCount + 1
                frame.LayoutOrder = elementCount 
                frame.ClipsDescendants = true
                table.insert(TabObj.Sections[SectionFrame].Elements, {Name = name, Frame = frame, OrigH = origH, IsVisible = true})
            end
            
            function SectionObj:CreateButton(name, callback)
                local BFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, Parent = ElementContainer })
                local Btn = Create("TextButton", { Size = UDim2.new(1, -20, 0, 28), Position = UDim2.new(0, 10, 0, 4), BackgroundColor3 = Library.Theme.ElementBg, Text = name, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false, Parent = BFrame })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Btn })
                Create("UIStroke", { Color = Library.Theme.Border, Parent = Btn })

                Btn.MouseButton1Click:Connect(function()
                    TS:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.Hover}):Play()
                    task.wait(0.1)
                    TS:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.ElementBg}):Play()
                    callback()
                end)
                RegEl(name, BFrame, 36)
                return { Set = function(_, newText) Btn.Text = newText end }
            end

            function SectionObj:CreateDualButtons(name1, callback1, name2, callback2)
                local DBFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, Parent = ElementContainer })
                
                local Btn1 = Create("TextButton", { Size = UDim2.new(0.5, -15, 0, 28), Position = UDim2.new(0, 10, 0, 4), BackgroundColor3 = Library.Theme.ElementBg, Text = name1, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false, Parent = DBFrame })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Btn1 })
                Create("UIStroke", { Color = Library.Theme.Border, Parent = Btn1 })

                local Btn2 = Create("TextButton", { Size = UDim2.new(0.5, -15, 0, 28), Position = UDim2.new(0.5, 5, 0, 4), BackgroundColor3 = Library.Theme.ElementBg, Text = name2, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false, Parent = DBFrame })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Btn2 })
                Create("UIStroke", { Color = Library.Theme.Border, Parent = Btn2 })

                Btn1.MouseButton1Click:Connect(function()
                    TS:Create(Btn1, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.Hover}):Play()
                    task.wait(0.1)
                    TS:Create(Btn1, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.ElementBg}):Play()
                    callback1()
                end)
                
                Btn2.MouseButton1Click:Connect(function()
                    TS:Create(Btn2, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.Hover}):Play()
                    task.wait(0.1)
                    TS:Create(Btn2, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.ElementBg}):Play()
                    callback2()
                end)

                RegEl(name1 .. " " .. name2, DBFrame, 36)
            end

            function SectionObj:CreateInput(name, placeholder, callback)
                local IFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, Parent = ElementContainer })
                Create("TextLabel", { Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = IFrame })
                
                local TextBox = Create("TextBox", { Size = UDim2.new(1, -20, 0, 24), Position = UDim2.new(0, 10, 0, 20), BackgroundColor3 = Library.Theme.ElementBg, TextColor3 = Library.Theme.Text, PlaceholderText = placeholder, Text = "", Font = Enum.Font.Gotham, TextSize = 12, Parent = IFrame })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = TextBox })
                Create("UIStroke", { Color = Library.Theme.Border, Parent = TextBox })
        
                local function setInput(val)
                    TextBox.Text = val
                    callback(val)
                end
        
                TextBox.FocusLost:Connect(function() callback(TextBox.Text) end)
                RegEl(name, IFrame, 45)
                return { Set = function(_, val) setInput(val) end }
            end

            function SectionObj:CreateToggle(name, default, callback)
                local id = tabName .. "_" .. name
                local state = default
                Library.Registry[id] = {Value = state, Type = "Toggle"}

                local TFrame = Create("TextButton", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Text = "", Parent = ElementContainer })
                Create("TextLabel", { Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = TFrame })

                local Track = Create("Frame", { Size = UDim2.new(0, 32, 0, 16), Position = UDim2.new(1, -42, 0.5, -8), BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.ElementBg, Parent = TFrame })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Track })
                Create("UIStroke", { Color = Library.Theme.Border, Parent = Track })
                local Thumb = Create("Frame", { Size = UDim2.new(0, 12, 0, 12), Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = Track })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Thumb })

                local function setState(val)
                    state = val
                    Library.Registry[id].Value = state
                    TS:Create(Track, TweenInfo.new(0.2), {BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.ElementBg}):Play()
                    TS:Create(Thumb, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}):Play()
                    callback(state)
                end
                Library.Registry[id].Set = setState

                TFrame.MouseButton1Click:Connect(function() setState(not state) end)
                RegEl(name, TFrame, 32)
                return { Set = setState }
            end

            function SectionObj:CreateDropdown(name, list, default, callback)
                local id = tabName .. "_" .. name
                Library.Registry[id] = {Value = default, Type = "Dropdown"}
                
                local DFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1, ClipsDescendants = true, Parent = ElementContainer })
                Create("TextLabel", { Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 2), BackgroundTransparency = 1, Text = name, TextColor3 = Library.Theme.SubText, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = DFrame })
                
                local DropBtn = Create("TextButton", { Size = UDim2.new(1, -20, 0, 24), Position = UDim2.new(0, 10, 0, 20), BackgroundColor3 = Library.Theme.ElementBg, Text = "", AutoButtonColor = false, Parent = DFrame })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = DropBtn })
                Create("UIStroke", { Color = Library.Theme.Border, Parent = DropBtn })

                local SelectedText = Create("TextLabel", { Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = default, TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = DropBtn })
                local Chevron = Create("TextLabel", { Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -20, 0, 0), BackgroundTransparency = 1, Text = "v", TextColor3 = Library.Theme.SubText, Font = Enum.Font.Gotham, TextSize = 12, Parent = DropBtn })

                local Scroll = Create("ScrollingFrame", { Size = UDim2.new(1, -20, 0, 0), Position = UDim2.new(0, 10, 0, 48), BackgroundColor3 = Library.Theme.ElementBg, ScrollBarThickness = 0, Parent = DFrame })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Scroll })
                Create("UIStroke", { Color = Library.Theme.Border, Parent = Scroll })
                local SLayout = Create("UIListLayout", { Parent = Scroll })

                local open = false
                local function toggle()
                    open = not open
                    Chevron.Rotation = open and 180 or 0
                    local targetHeight = open and math.clamp(#list * 24, 0, 120) or 0
                    TS:Create(Scroll, TweenInfo.new(0.2), {Size = UDim2.new(1, -20, 0, targetHeight)}):Play()
                    
                    local newFrameHeight = 48 + targetHeight + (open and 5 or 0)
                    TS:Create(DFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, newFrameHeight)}):Play()
                    
                    for _, el in ipairs(TabObj.Sections[SectionFrame].Elements) do
                        if el.Name == name then el.OrigH = newFrameHeight end
                    end
                end

                DropBtn.MouseButton1Click:Connect(toggle)

                local function populate(arr)
                    for _, c in pairs(Scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                    Scroll.CanvasSize = UDim2.new(0, 0, 0, #arr * 24)
                    for _, opt in ipairs(arr) do
                        local btn = Create("TextButton", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = "  " .. opt, TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = Scroll })
                        btn.MouseButton1Click:Connect(function()
                            SelectedText.Text = opt
                            Library.Registry[id].Value = opt
                            toggle()
                            callback(opt)
                        end)
                    end
                end
                populate(list)

                local function setDrop(val)
                    SelectedText.Text = val
                    Library.Registry[id].Value = val
                    callback(val) 
                end
                Library.Registry[id].Set = setDrop

                RegEl(name, DFrame, 48)

                return {
                    Set = setDrop,
                    Refresh = function(_, newList, newDef) 
                        list = newList
                        populate(newList)
                        if newDef then setDrop(newDef) end 
                    end
                }
            end

            function SectionObj:CreateColorPicker(name, default, callback)
                local id = tabName .. "_" .. name
                local val = default
                Library.Registry[id] = {Value = val, Type = "ColorPicker"}

                local CFrame = Create("TextButton", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Text = "", Parent = ElementContainer })
                Create("TextLabel", { Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = CFrame })

                local ColorBox = Create("Frame", { Size = UDim2.new(0, 32, 0, 16), Position = UDim2.new(1, -42, 0.5, -8), BackgroundColor3 = val, Parent = CFrame })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ColorBox })
                Create("UIStroke", { Color = Library.Theme.Border, Parent = ColorBox })

                local function setColor(newColor)
                    val = newColor
                    Library.Registry[id].Value = newColor
                    ColorBox.BackgroundColor3 = newColor
                    callback(newColor)
                end
                Library.Registry[id].Set = setColor

                CFrame.MouseButton1Click:Connect(function()
                    WindowObj:OpenColorPicker(val, setColor)
                end)
                RegEl(name, CFrame, 32)
                return { Set = setColor }
            end

            function SectionObj:CreateSlider(name, min, max, default, callback)
                local id = tabName .. "_" .. name
                local val = default
                Library.Registry[id] = {Value = val, Type = "Slider"}

                local SFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, Parent = ElementContainer })
                Create("TextLabel", { Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = name, TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = SFrame })
                local ValLbl = Create("TextLabel", { Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0, 5), BackgroundTransparency = 1, Text = tostring(val), TextColor3 = Library.Theme.SubText, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, Parent = SFrame })

                local TrackBtn = Create("TextButton", { Size = UDim2.new(1, -20, 0, 4), Position = UDim2.new(0, 10, 0, 30), BackgroundColor3 = Library.Theme.ElementBg, Text = "", AutoButtonColor = false, Parent = SFrame })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = TrackBtn })
                local Fill = Create("Frame", { Size = UDim2.new((val - min)/(max - min), 0, 1, 0), BackgroundColor3 = Library.Theme.Accent, Parent = TrackBtn })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Fill })
                local Thumb = Create("Frame", { Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(1, -5, 0.5, -5), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = Fill })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Thumb })

                local dragging = false
                
                local function setSlider(newVal)
                    val = math.clamp(newVal, min, max)
                    TS:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new((val - min)/(max - min), 0, 1, 0)}):Play()
                    ValLbl.Text = tostring(val)
                    Library.Registry[id].Value = val
                    callback(val)
                end
                Library.Registry[id].Set = setSlider

                local function updateSlider(input)
                    local percent = math.clamp((input.Position.X - TrackBtn.AbsolutePosition.X) / TrackBtn.AbsoluteSize.X, 0, 1)
                    setSlider(math.floor(min + (max - min) * percent))
                end

                TrackBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true updateSlider(input) end end)
                UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                UIS.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end end)

                RegEl(name, SFrame, 45)
                return { Set = setSlider }
            end

            function SectionObj:CreateKeybind(name, default, callback)
                local id = tabName .. "_" .. name
                local defaultName = "None"
                local currentKey = nil
                
                if typeof(default) == "EnumItem" then
                    currentKey = default
                    if default.EnumType == Enum.KeyCode then
                        defaultName = default.Name
                    elseif default.EnumType == Enum.UserInputType then
                        defaultName = string.gsub(default.Name, "MouseButton", "MB")
                    end
                end
                
                Library.Registry[id] = {Value = defaultName, Type = "Keybind"}

                local KFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Parent = ElementContainer })
                Create("TextLabel", { Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = KFrame })
                
                local BindBtn = Create("TextButton", { Size = UDim2.new(0, 60, 0, 20), Position = UDim2.new(1, -70, 0.5, -10), BackgroundColor3 = Library.Theme.ElementBg, Text = defaultName, TextColor3 = Library.Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false, Parent = KFrame })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = BindBtn })
                Create("UIStroke", { Color = Library.Theme.Border, Parent = BindBtn })

                local listening = false

                local function setKey(newKeyStr)
                    BindBtn.Text = newKeyStr
                    Library.Registry[id].Value = newKeyStr
                    
                    local parsedKey = nil
                    if newKeyStr:match("MB") then
                        local num = newKeyStr:match("%d")
                        parsedKey = Enum.UserInputType["MouseButton" .. num]
                    elseif newKeyStr ~= "None" then
                        pcall(function() parsedKey = Enum.KeyCode[newKeyStr] end)
                    end
                    currentKey = parsedKey
                    callback(currentKey)
                end
                Library.Registry[id].Set = setKey

                BindBtn.MouseButton1Click:Connect(function()
                    if listening then return end
                    listening = true
                    TS:Create(BindBtn, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
                    task.wait(0.15)
                    BindBtn.Text = "..."
                    TS:Create(BindBtn, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
                end)

                UIS.InputBegan:Connect(function(input, gp)
                    if listening then
                        local key = input.KeyCode
                        local type = input.UserInputType
                        local isMouse = (type == Enum.UserInputType.MouseButton1 or type == Enum.UserInputType.MouseButton2 or type == Enum.UserInputType.MouseButton3)
                        local isKeyboard = (type == Enum.UserInputType.Keyboard)
                        
                        if isKeyboard and key == Enum.KeyCode.Unknown then return end
                        
                        if isMouse or isKeyboard then
                            local newKeyStr = "None"
                            if key == Enum.KeyCode.Escape then
                                currentKey = nil
                            elseif isKeyboard then
                                newKeyStr = key.Name
                            elseif isMouse then
                                newKeyStr = string.gsub(type.Name, "MouseButton", "MB")
                            end
                            
                            listening = false
                            TS:Create(BindBtn, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
                            task.wait(0.15)
                            setKey(newKeyStr)
                            TS:Create(BindBtn, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
                        end
                        return 
                    end
                    
                    if not gp and currentKey ~= nil and not listening then
                        if input.KeyCode == currentKey or input.UserInputType == currentKey then
                            callback(currentKey)
                        end
                    end
                end)

                RegEl(name, KFrame, 32)
                return { Set = setKey }
            end

            return SectionObj
        end
        return TabObj
    end

    -- ========================================== --
    --          CONFIG SYSTEM INTEGRATION         --
    -- ========================================== --
    local safeTitle = string.gsub(titleText, "[^%w%s_]", ""):gsub(" ", "")
    local folderPath = "WindUI/" .. safeTitle
    
    if makefolder then
        if not isfolder("WindUI") then makefolder("WindUI") end
        if not isfolder(folderPath) then makefolder(folderPath) end
    end

    local ConfigTab = WindowObj:CreateTab("Configuration", "Save")
    ConfigTab.Btn.LayoutOrder = 99999

    local VisualsSec = ConfigTab:CreateSection("UI Options", "Left")
    local isWMVisible = false
    VisualsSec:CreateToggle("Show Watermark", false, function(v)
        isWMVisible = v
        if v then
            WMOuter.Visible = true
            FadeUI(WMOuter, true, 0.3)
        else
            FadeUI(WMOuter, false, 0.3)
            task.delay(0.3, function() if not isWMVisible then WMOuter.Visible = false end end)
        end
    end)

    local ConfigSec = ConfigTab:CreateSection("Config Manager", "Right")
    local currentName = "Default"
    
    local ConfigInput
    ConfigInput = ConfigSec:CreateInput("Config Name", "Enter name...", function(val)
        currentName = val
    end)

    local function GetConfigs()
        local list = {}
        if listfiles then
            for _, file in ipairs(listfiles(folderPath)) do
                local fileName = file:match("([^/\\]+)%.json$")
                if fileName then table.insert(list, fileName) end
            end
        end
        return list
    end

    local selectedConfig = ""
    local ConfigDrop
    ConfigDrop = ConfigSec:CreateDropdown("Select Config", GetConfigs(), "", function(val)
        selectedConfig = val
        if ConfigInput and val ~= "" then ConfigInput:Set(val) end
    end)

    ConfigSec:CreateDualButtons("Save Config", function()
        if writefile then
            local data = {}
            for id, entry in pairs(Library.Registry) do
                local val = entry.Value
                if entry.Type == "ColorPicker" and typeof(val) == "Color3" then
                    data[id] = {Type = "Color3", R = val.R, G = val.G, B = val.B}
                else
                    data[id] = {Type = entry.Type, Value = val}
                end
            end
            writefile(folderPath .. "/" .. currentName .. ".json", HttpService:JSONEncode(data))
            ConfigDrop:Refresh(GetConfigs(), currentName)
            WindowObj:Notify("Configuration", "Saved config: " .. currentName .. ".json", 3)
        end
    end, "Refresh List", function()
        ConfigDrop:Refresh(GetConfigs(), selectedConfig)
    end)

    ConfigSec:CreateDualButtons("Load Config", function()
        if readfile and isfile(folderPath .. "/" .. selectedConfig .. ".json") then
            local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(folderPath .. "/" .. selectedConfig .. ".json")) end)
            if success and type(decoded) == "table" then
                WindowObj.IsLoadingConfig = true
                for id, entry in pairs(decoded) do
                    if Library.Registry[id] and Library.Registry[id].Set then
                        if entry.Type == "Color3" then
                            Library.Registry[id].Set(Color3.new(entry.R, entry.G, entry.B))
                        else
                            Library.Registry[id].Set(entry.Value)
                        end
                    end
                end
                task.spawn(function()
                    task.wait(0.1)
                    WindowObj.IsLoadingConfig = false
                    WindowObj:Notify("Configuration", "Loaded config: " .. selectedConfig, 3)
                end)
            end
        end
    end, "Delete Config", function()
        if delfile and isfile(folderPath .. "/" .. selectedConfig .. ".json") then
            delfile(folderPath .. "/" .. selectedConfig .. ".json")
            ConfigDrop:Refresh(GetConfigs(), "")
            WindowObj:Notify("Configuration", "Deleted config: " .. selectedConfig, 3)
        end
    end)

    OuterFrame.Size = UDim2.new(0, 760, 0, 0)
    task.delay(0.2, function()
        TS:Create(OuterFrame, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = baseSize}):Play()
        task.delay(0.6, function() isAnimating = false end)
    end)
    
    return WindowObj
end

return Library
