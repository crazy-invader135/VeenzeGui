-- Full UI Library with Core Animations Enabled
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local Library = {}

-- Ensure old instances are destroyed to keep the cleanup rule intact
if CoreGui:FindFirstChild("VeenzeUiLibrary") then
    CoreGui:FindFirstChild("VeenzeUiLibrary"):Destroy()
end

function Library:CreateWindow(scriptTitle)
    scriptTitle = scriptTitle or "Script Title"
    
    local VeenzeUiLibrary = Instance.new("ScreenGui")
    VeenzeUiLibrary.Name = "VeenzeUiLibrary"
    VeenzeUiLibrary.Parent = CoreGui
    VeenzeUiLibrary.ResetOnSpawn = false

    -- Main GUI Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 650, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = VeenzeUiLibrary

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(60, 60, 60)
    MainStroke.Thickness = 1
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent = MainFrame

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(MainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)

    -- Left Sidebar Panel
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 8)
    SidebarCorner.Parent = Sidebar

    local SidebarCover = Instance.new("Frame")
    SidebarCover.Size = UDim2.new(0, 10, 1, 0)
    SidebarCover.Position = UDim2.new(1, -10, 0, 0)
    SidebarCover.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SidebarCover.BorderSizePixel = 0
    SidebarCover.Parent = Sidebar

    -- Tab Container Scrolling Frame
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -16, 1, -120)
    TabContainer.Position = UDim2.new(0, 8, 0, 70)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 6)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabContainer

    -- Title Bar Top Right
    local TitleContainer = Instance.new("Frame")
    TitleContainer.Name = "TitleContainer"
    TitleContainer.Size = UDim2.new(1, -180, 0, 40)
    TitleContainer.Position = UDim2.new(0, 170, 0, 15)
    TitleContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TitleContainer.BorderSizePixel = 0
    TitleContainer.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 6)
    TitleCorner.Parent = TitleContainer

    local TitleStroke = Instance.new("UIStroke")
    TitleStroke.Color = Color3.fromRGB(70, 70, 70)
    TitleStroke.Thickness = 1
    TitleStroke.Parent = TitleContainer

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -20, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = scriptTitle
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 18
    TitleLabel.Font = Enum.Font.SourceSans
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleContainer

    -- Main Content Display Area
    local ContentPanel = Instance.new("Frame")
    ContentPanel.Name = "ContentPanel"
    ContentPanel.Size = UDim2.new(1, -180, 1, -80)
    ContentPanel.Position = UDim2.new(0, 170, 0, 65)
    ContentPanel.BackgroundTransparency = 1
    ContentPanel.Parent = MainFrame

    local PagesFolder = Instance.new("Folder")
    PagesFolder.Name = "Pages"
    PagesFolder.Parent = ContentPanel

    local Window = {
        CurrentTab = nil,
        Tabs = {},
        Binding = Enum.KeyCode.RightControl
    }

    -- Hide/Show UI via Keybind
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Window.Binding then
            VeenzeUiLibrary.Enabled = not VeenzeUiLibrary.Enabled
        end
    end)

    -- Smooth Page Transition Fade Effect
    local function SwitchPage(targetPage)
        for _, page in pairs(PagesFolder:GetChildren()) do
            if page.Visible and page ~= targetPage then
                local canvasGroup = page:FindFirstChildOfClass("CanvasGroup") or page
                TweenService:Create(canvasGroup, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 1}):Play()
                task.delay(0.15, function() page.Visible = false end)
            end
        end
        
        targetPage.Visible = true
        local targetGroup = targetPage:FindFirstChildOfClass("CanvasGroup") or targetPage
        targetGroup.GroupTransparency = 1
        TweenService:Create(targetGroup, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
    end

    -- Setup Hover Animation Helpers
    local function AddHoverAnimation(element, defaultColor, hoverColor)
        element.MouseEnter:Connect(function()
            TweenService:Create(element, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = hoverColor}):Play()
        end)
        element.MouseLeave:Connect(function()
            TweenService:Create(element, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = defaultColor}):Play()
        end)
    end

    -- Create Standard Page Layout Creator with Canvas Groups for clean fades
    local function CreatePageFrame(name)
        local PageFrame = Instance.new("ScrollingFrame")
        PageFrame.Name = name .. "Page"
        PageFrame.Size = UDim2.new(1, 0, 1, 0)
        PageFrame.BackgroundTransparency = 1
        PageFrame.BorderSizePixel = 0
        PageFrame.ScrollBarThickness = 3
        PageFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
        PageFrame.Visible = false
        PageFrame.Parent = PagesFolder

        local FadeGroup = Instance.new("CanvasGroup")
        FadeGroup.Size = UDim2.new(1, 0, 1, 0)
        FadeGroup.BackgroundTransparency = 1
        FadeGroup.Parent = PageFrame

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = FadeGroup

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            PageFrame.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
            FadeGroup.Size = UDim2.new(1, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)

        return PageFrame, FadeGroup
    end

    -- Sidebar Footer Control Setup (Credits & Settings)
    local FooterContainer = Instance.new("Frame")
    FooterContainer.Size = UDim2.new(1, -16, 0, 35)
    FooterContainer.Position = UDim2.new(0, 8, 1, -45)
    FooterContainer.BackgroundTransparency = 1
    FooterContainer.Parent = Sidebar

    local CreditsButton = Instance.new("TextButton")
    CreditsButton.Name = "CreditsButton"
    CreditsButton.Size = UDim2.new(0, 105, 1, 0)
    CreditsButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    CreditsButton.Text = "Credits"
    CreditsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CreditsButton.Font = Enum.Font.SourceSans
    CreditsButton.TextSize = 14
    CreditsButton.Parent = FooterContainer
    AddHoverAnimation(CreditsButton, Color3.fromRGB(45, 45, 45), Color3.fromRGB(55, 55, 55))

    local CreditsBtnCorner = Instance.new("UICorner")
    CreditsBtnCorner.CornerRadius = UDim.new(0, 6)
    CreditsBtnCorner.Parent = CreditsButton

    local CreditsBtnStroke = Instance.new("UIStroke")
    CreditsBtnStroke.Color = Color3.fromRGB(70, 70, 70)
    CreditsBtnStroke.Thickness = 1
    CreditsBtnStroke.Parent = CreditsButton

    local SettingsButton = Instance.new("ImageButton")
    SettingsButton.Name = "SettingsButton"
    SettingsButton.Size = UDim2.new(0, 32, 0, 32)
    SettingsButton.Position = UDim2.new(1, -32, 0, 1)
    SettingsButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    SettingsButton.Image = "rbxassetid://7072721666"
    SettingsButton.ImageColor3 = Color3.fromRGB(140, 165, 175)
    SettingsButton.Parent = FooterContainer
    AddHoverAnimation(SettingsButton, Color3.fromRGB(45, 45, 45), Color3.fromRGB(55, 55, 55))

    local SettingsBtnCorner = Instance.new("UICorner")
    SettingsBtnCorner.CornerRadius = UDim.new(0, 6)
    SettingsBtnCorner.Parent = SettingsButton

    local SettingsBtnStroke = Instance.new("UIStroke")
    SettingsBtnStroke.Color = Color3.fromRGB(70, 70, 70)
    SettingsBtnStroke.Thickness = 1
    SettingsBtnStroke.Parent = SettingsButton

    -- Setup Specialized Static Windows
    local CreditsPage, CreditsGroup = CreatePageFrame("Credits")
    local CreditsInner = Instance.new("Frame")
    CreditsInner.Size = UDim2.new(1, -5, 0, 320)
    CreditsInner.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    CreditsInner.Parent = CreditsGroup

    local CreditsInnerCorner = Instance.new("UICorner")
    CreditsInnerCorner.CornerRadius = UDim.new(0, 8)
    CreditsInnerCorner.Parent = CreditsInner

    local CreditsInnerStroke = Instance.new("UIStroke")
    CreditsInnerStroke.Color = Color3.fromRGB(70, 70, 70)
    CreditsInnerStroke.Thickness = 1
    CreditsInnerStroke.Parent = CreditsInner

    local CreditsLabel = Instance.new("TextLabel")
    CreditsLabel.Size = UDim2.new(1, -20, 1, -20)
    CreditsLabel.Position = UDim2.new(0, 10, 0, 10)
    CreditsLabel.BackgroundTransparency = 1
    CreditsLabel.Text = "Credits:\n\nUI lib made by: Veenze\n\nscript made by:\n\nextra credits here"
    CreditsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    CreditsLabel.TextSize = 16
    CreditsLabel.Font = Enum.Font.SourceSans
    CreditsLabel.TextXAlignment = Enum.TextXAlignment.Left
    CreditsLabel.TextYAlignment = Enum.TextYAlignment.Top
    CreditsLabel.Parent = CreditsInner

    local SettingsPage, SettingsGroup = CreatePageFrame("Settings")
    
    CreditsButton.MouseButton1Click:Connect(function()
        SwitchPage(CreditsPage)
    end)
    
    SettingsButton.MouseButton1Click:Connect(function()
        SwitchPage(SettingsPage)
    end)

    -- Window Methods
    function Window:CreateTab(tabName)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName .. "Tab"
        TabButton.Size = UDim2.new(1, 0, 0, 32)
        TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        TabButton.Text = tabName
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.Font = Enum.Font.SourceSans
        TabButton.TextSize = 14
        TabButton.Parent = TabContainer
        AddHoverAnimation(TabButton, Color3.fromRGB(45, 45, 45), Color3.fromRGB(60, 60, 60))

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 6)
        TabBtnCorner.Parent = TabButton

        local TabBtnStroke = Instance.new("UIStroke")
        TabBtnStroke.Color = Color3.fromRGB(70, 70, 70)
        TabBtnStroke.Thickness = 1
        TabBtnStroke.Parent = TabButton

        local Page, FadeGroup = CreatePageFrame(tabName)

        local PageHeader = Instance.new("Frame")
        PageHeader.Size = UDim2.new(1, -5, 0, 32)
        PageHeader.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        PageHeader.Parent = FadeGroup

        local PageHeaderCorner = Instance.new("UICorner")
        PageHeaderCorner.CornerRadius = UDim.new(0, 6)
        PageHeaderCorner.Parent = PageHeader

        local PageHeaderStroke = Instance.new("UIStroke")
        PageHeaderStroke.Color = Color3.fromRGB(70, 70, 70)
        PageHeaderStroke.Thickness = 1
        PageHeaderStroke.Parent = PageHeader

        local PageHeaderLabel = Instance.new("TextLabel")
        PageHeaderLabel.Size = UDim2.new(1, -20, 1, 0)
        PageHeaderLabel.Position = UDim2.new(0, 10, 0, 0)
        PageHeaderLabel.BackgroundTransparency = 1
        PageHeaderLabel.Text = tabName
        PageHeaderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        PageHeaderLabel.TextSize = 15
        PageHeaderLabel.Font = Enum.Font.SourceSans
        PageHeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
        PageHeaderLabel.Parent = PageHeader

        if Window.CurrentTab == nil then
            Window.CurrentTab = Page
            Page.Visible = true
            FadeGroup.GroupTransparency = 0
        end

        TabButton.MouseButton1Click:Connect(function()
            SwitchPage(Page)
        end)

        local TabMethods = {}

        -- Element: Toggle with Smooth Sliding Indicator Animation
        function TabMethods:CreateToggle(toggleName, default, callback)
            local enabled = default or false
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, -5, 0, 35)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            ToggleFrame.Parent = FadeGroup

            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = ToggleFrame

            local ToggleStroke = Instance.new("UIStroke")
            ToggleStroke.Color = Color3.fromRGB(70, 70, 70)
            ToggleStroke.Thickness = 1
            ToggleStroke.Parent = ToggleFrame

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = toggleName
            ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleLabel.TextSize = 14
            ToggleLabel.Font = Enum.Font.SourceSans
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleFrame

            local ToggleSwitch = Instance.new("TextButton")
            ToggleSwitch.Size = UDim2.new(0, 45, 0, 22)
            ToggleSwitch.Position = UDim2.new(1, -55, 0.5, -11)
            ToggleSwitch.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            ToggleSwitch.Text = ""
            ToggleSwitch.Parent = ToggleFrame

            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = ToggleSwitch

            local SwitchStroke = Instance.new("UIStroke")
            SwitchStroke.Color = Color3.fromRGB(60, 60, 60)
            SwitchStroke.Thickness = 1
            SwitchStroke.Parent = ToggleSwitch

            local Indicator = Instance.new("Frame")
            Indicator.Size = UDim2.new(0, 16, 0, 16)
            Indicator.Position = enabled and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
            Indicator.BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 50) or Color3.fromRGB(255, 50, 50)
            Indicator.Parent = ToggleSwitch

            local IndicatorCorner = Instance.new("UICorner")
            IndicatorCorner.CornerRadius = UDim.new(1, 0)
            IndicatorCorner.Parent = Indicator

            local function UpdateToggle()
                local targetPos = enabled and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
                local targetColor = enabled and Color3.fromRGB(0, 255, 50) or Color3.fromRGB(255, 50, 50)
                
                TweenService:Create(Indicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = targetPos, 
                    BackgroundColor3 = targetColor
                }):Play()
                callback(enabled)
            end

            ToggleSwitch.MouseButton1Click:Connect(function()
                enabled = not enabled
                UpdateToggle()
            end)

            local OverlayButton = Instance.new("TextButton")
            OverlayButton.Size = UDim2.new(1, -60, 1, 0)
            OverlayButton.BackgroundTransparency = 1
            OverlayButton.Text = ""
            OverlayButton.Parent = ToggleFrame
            OverlayButton.MouseButton1Click:Connect(function()
                enabled = not enabled
                UpdateToggle()
            end)
        end

        -- Element: Button
        function TabMethods:CreateButton(buttonName, callback)
            local ButtonFrame = Instance.new("TextButton")
            ButtonFrame.Size = UDim2.new(1, -5, 0, 32)
            ButtonFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            ButtonFrame.Text = buttonName
            ButtonFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
            ButtonFrame.Font = Enum.Font.SourceSans
            ButtonFrame.TextSize = 14
            ButtonFrame.Parent = FadeGroup
            AddHoverAnimation(ButtonFrame, Color3.fromRGB(45, 45, 45), Color3.fromRGB(55, 55, 55))

            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = ButtonFrame

            local ButtonStroke = Instance.new("UIStroke")
            ButtonStroke.Color = Color3.fromRGB(70, 70, 70)
            ButtonStroke.Thickness = 1
            ButtonStroke.Parent = ButtonFrame

            ButtonFrame.MouseButton1Click:Connect(function()
                -- Subtle click flash feedback animation
                TweenService:Create(ButtonFrame, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(65, 65, 65)}):Play()
                task.delay(0.05, function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
                end)
                callback()
            end)
        end

        -- Element: Slider
        function TabMethods:CreateSlider(sliderName, min, max, default, callback)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, -5, 0, 40)
            SliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            SliderFrame.Parent = FadeGroup

            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 6)
            SliderCorner.Parent = SliderFrame

            local SliderStroke = Instance.new("UIStroke")
            SliderStroke.Color = Color3.fromRGB(70, 70, 70)
            SliderStroke.Thickness = 1
            SliderStroke.Parent = SliderFrame

            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Size = UDim2.new(0, 100, 1, 0)
            SliderLabel.Position = UDim2.new(0, 10, 0, 0)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Text = sliderName
            SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            SliderLabel.TextSize = 14
            SliderLabel.Font = Enum.Font.SourceSans
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.Parent = SliderFrame

            local SliderValueLabel = Instance.new("TextLabel")
            SliderValueLabel.Size = UDim2.new(0, 60, 1, 0)
            SliderValueLabel.Position = UDim2.new(1, -70, 0, 0)
            SliderValueLabel.BackgroundTransparency = 1
            SliderValueLabel.Text = tostring(default)
            SliderValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            SliderValueLabel.TextSize = 14
            SliderValueLabel.Font = Enum.Font.SourceSans
            SliderValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            SliderValueLabel.Parent = SliderFrame

            local SliderTrack = Instance.new("Frame")
            SliderTrack.Size = UDim2.new(1, -200, 0, 6)
            SliderTrack.Position = UDim2.new(0, 120, 0.5, -3)
            SliderTrack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            SliderTrack.BorderSizePixel = 0
            SliderTrack.Parent = SliderFrame

            local TrackCorner = Instance.new("UICorner")
            TrackCorner.CornerRadius = UDim.new(1, 0)
            TrackCorner.Parent = SliderTrack

            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderTrack

            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = SliderFill

            local SliderKnob = Instance.new("TextButton")
            SliderKnob.Size = UDim2.new(0, 14, 0, 14)
            SliderKnob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
            SliderKnob.BackgroundColor3 = Color3.fromRGB(90, 80, 80)
            SliderKnob.Text = ""
            SliderKnob.Parent = SliderTrack

            local KnobCorner = Instance.new("UICorner")
            KnobCorner.CornerRadius = UDim.new(1, 0)
            KnobCorner.Parent = SliderKnob

            local KnobStroke = Instance.new("UIStroke")
            KnobStroke.Color = Color3.fromRGB(120, 120, 120)
            KnobStroke.Thickness = 1
            KnobStroke.Parent = SliderKnob

            local sliding = false
            local function Move(input)
                local relativeX = input.Position.X - SliderTrack.AbsolutePosition.X
                local percentage = math.clamp(relativeX / SliderTrack.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * percentage)
                
                SliderValueLabel.Text = tostring(value)
                
                -- Smooth out the track slider filling motion 
                TweenService:Create(SliderKnob, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(percentage, -7, 0.5, -7)}):Play()
                TweenService:Create(SliderFill, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
                
                callback(value)
            end

            SliderKnob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                    Move(input)
                end
            end)
        end

        -- Element: Dropdown with Interpolated Drop Opening Height Transitions
        function TabMethods:CreateDropdown(dropdownName, options, callback)
            local Expanded = false
            
            local DropdownContainer = Instance.new("Frame")
            DropdownContainer.Size = UDim2.new(1, -5, 0, 35)
            DropdownContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            DropdownContainer.ClipsDescendants = true
            DropdownContainer.Parent = FadeGroup

            local DropdownCorner = Instance.new("UICorner")
            DropdownCorner.CornerRadius = UDim.new(0, 6)
            DropdownCorner.Parent = DropdownContainer

            local DropdownStroke = Instance.new("UIStroke")
            DropdownStroke.Color = Color3.fromRGB(70, 70, 70)
            DropdownStroke.Thickness = 1
            DropdownStroke.Parent = DropdownContainer

            local DropdownHeader = Instance.new("TextButton")
            DropdownHeader.Size = UDim2.new(1, 0, 0, 35)
            DropdownHeader.BackgroundTransparency = 1
            DropdownHeader.Text = ""
            DropdownHeader.Parent = DropdownContainer

            local DropdownLabel = Instance.new("TextLabel")
            DropdownLabel.Size = UDim2.new(1, -20, 1, 0)
            DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
            DropdownLabel.BackgroundTransparency = 1
            DropdownLabel.Text = dropdownName
            DropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            DropdownLabel.TextSize = 14
            DropdownLabel.Font = Enum.Font.SourceSans
            DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            DropdownLabel.Parent = DropdownHeader

            local OptionListFrame = Instance.new("Frame")
            OptionListFrame.Size = UDim2.new(1, -12, 1, -40)
            OptionListFrame.Position = UDim2.new(0, 6, 0, 35)
            OptionListFrame.BackgroundTransparency = 1
            OptionListFrame.Parent = DropdownContainer

            local OptionLayout = Instance.new("UIListLayout")
            OptionLayout.Padding = UDim.new(0, 4)
            OptionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            OptionLayout.Parent = OptionListFrame

            local function RefreshContainerSize()
                local targetHeight = 35
                if Expanded then
                    targetHeight = 40 + OptionLayout.AbsoluteContentSize.Y
                end
                TweenService:Create(DropdownContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, -5, 0, targetHeight)
                }):Play()
            end

            for index, option in pairs(options) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Name = option .. "Btn"
                OptionButton.Size = UDim2.new(1, 0, 0, 28)
                OptionButton.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
                OptionButton.Text = "  " .. option
                OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                OptionButton.Font = Enum.Font.SourceSans
                OptionButton.TextSize = 14
                OptionButton.TextXAlignment = Enum.TextXAlignment.Left
                OptionButton.Parent = OptionListFrame
                AddHoverAnimation(OptionButton, Color3.fromRGB(38, 38, 38), Color3.fromRGB(48, 48, 48))

                local OptCorner = Instance.new("UICorner")
                OptCorner.CornerRadius = UDim.new(0, 4)
                OptCorner.Parent = OptionButton

                OptionButton.MouseButton1Click:Connect(function()
                    DropdownLabel.Text = dropdownName .. " - " .. option
                    Expanded = false
                    RefreshContainerSize()
                    callback(option)
                end)
            end

            DropdownHeader.MouseButton1Click:Connect(function()
                Expanded = not Expanded
                RefreshContainerSize()
            end)
        end

        return TabMethods
    end

    -- Element: Create Specialized "Supported Games" Tab View
    function Window:CreateSupportedGamesTab(gamesList)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = "SupportedGamesTab"
        TabButton.Size = UDim2.new(1, 0, 0, 32)
        TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        TabButton.Text = "Supported games"
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.Font = Enum.Font.SourceSans
        TabButton.TextSize = 14
        TabButton.Parent = TabContainer
        AddHoverAnimation(TabButton, Color3.fromRGB(45, 45, 45), Color3.fromRGB(60, 60, 60))

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 6)
        TabBtnCorner.Parent = TabButton

        local TabBtnStroke = Instance.new("UIStroke")
        TabBtnStroke.Color = Color3.fromRGB(70, 70, 70)
        TabBtnStroke.Thickness = 1
        TabBtnStroke.Parent = TabButton

        local Page, FadeGroup = CreatePageFrame("SupportedGames")

        local PageHeader = Instance.new("Frame")
        PageHeader.Size = UDim2.new(1, -5, 0, 32)
        PageHeader.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        PageHeader.Parent = FadeGroup

        local PageHeaderCorner = Instance.new("UICorner")
        PageHeaderCorner.CornerRadius = UDim.new(0, 6)
        PageHeaderCorner.Parent = PageHeader

        local PageHeaderStroke = Instance.new("UIStroke")
        PageHeaderStroke.Color = Color3.fromRGB(70, 70, 70)
        PageHeaderStroke.Thickness = 1
        PageHeaderStroke.Parent = PageHeader

        local PageHeaderLabel = Instance.new("TextLabel")
        PageHeaderLabel.Size = UDim2.new(1, -20, 1, 0)
        PageHeaderLabel.Position = UDim2.new(0, 10, 0, 0)
        PageHeaderLabel.BackgroundTransparency = 1
        PageHeaderLabel.Text = "Supported games:"
        PageHeaderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        PageHeaderLabel.TextSize = 15
        PageHeaderLabel.Font = Enum.Font.SourceSans
        PageHeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
        PageHeaderLabel.Parent = PageHeader

        TabButton.MouseButton1Click:Connect(function()
            SwitchPage(Page)
        end)

        for _, gameData in pairs(gamesList) do
            local GameRow = Instance.new("Frame")
            GameRow.Size = UDim2.new(1, -5, 0, 35)
            GameRow.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            GameRow.Parent = FadeGroup

            local RowCorner = Instance.new("UICorner")
            RowCorner.CornerRadius = UDim.new(0, 6)
            RowCorner.Parent = GameRow

            local RowStroke = Instance.new("UIStroke")
            RowStroke.Color = Color3.fromRGB(70, 70, 70)
            RowStroke.Thickness = 1
            RowStroke.Parent = GameRow

            local GameLabel = Instance.new("TextLabel")
            GameLabel.Size = UDim2.new(0, 180, 1, 0)
            GameLabel.Position = UDim2.new(0, 10, 0, 0)
            GameLabel.BackgroundTransparency = 1
            GameLabel.Text = gameData.name
            GameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            GameLabel.TextSize = 14
            GameLabel.Font = Enum.Font.SourceSans
            GameLabel.TextXAlignment = Enum.TextXAlignment.Left
            GameLabel.Parent = GameRow

            local StatusDot = Instance.new("Frame")
            StatusDot.Size = UDim2.new(0, 12, 0, 12)
            StatusDot.Position = UDim2.new(0, 195, 0.5, -6)
            
            if gameData.status == "green" then
                StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            elseif gameData.status == "yellow" then
                StatusDot.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
            else
                StatusDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            end
            
            StatusDot.Parent = GameRow

            local DotCorner = Instance.new("UICorner")
            DotCorner.CornerRadius = UDim.new(1, 0)
            DotCorner.Parent = StatusDot

            local JoinButton = Instance.new("TextButton")
            JoinButton.Size = UDim2.new(0, 80, 0, 24)
            JoinButton.Position = UDim2.new(1, -90, 0.5, -12)
            JoinButton.BackgroundColor3 = Color3.fromRGB(215, 55, 55)
            JoinButton.Text = "join game"
            JoinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            JoinButton.Font = Enum.Font.SourceSans
            JoinButton.TextSize = 14
            JoinButton.Parent = GameRow
            AddHoverAnimation(JoinButton, Color3.fromRGB(215, 55, 55), Color3.fromRGB(235, 75, 75))

            local JoinCorner = Instance.new("UICorner")
            JoinCorner.CornerRadius = UDim.new(0, 4)
            JoinCorner.Parent = JoinButton

            JoinButton.MouseButton1Click:Connect(function()
                if gameData.placeId then
                    TeleportService:Teleport(gameData.placeId, Players.LocalPlayer)
                end
            end)
        end
    end

    -- Build Out System Configuration Controls (Image 4 Settings)
    local function SetupSettingsTab()
        local Header = Instance.new("Frame")
        Header.Size = UDim2.new(1, -5, 0, 32)
        Header.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Header.Parent = SettingsGroup

        local HeaderCorner = Instance.new("UICorner")
        HeaderCorner.CornerRadius = UDim.new(0, 6)
        HeaderCorner.Parent = Header

        local HeaderStroke = Instance.new("UIStroke")
        HeaderStroke.Color = Color3.fromRGB(70, 70, 70)
        HeaderStroke.Thickness = 1
        HeaderStroke.Parent = Header

        local HeaderLabel = Instance.new("TextLabel")
        HeaderLabel.Size = UDim2.new(1, -20, 1, 0)
        HeaderLabel.Position = UDim2.new(0, 10, 0, 0)
        HeaderLabel.BackgroundTransparency = 1
        HeaderLabel.Text = "Settings"
        HeaderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        HeaderLabel.TextSize = 15
        HeaderLabel.Font = Enum.Font.SourceSans
        HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
        HeaderLabel.Parent = Header

        local LoadConfigBtn = Instance.new("TextButton")
        LoadConfigBtn.Size = UDim2.new(1, -5, 0, 32)
        LoadConfigBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        LoadConfigBtn.Text = "Load config"
        LoadConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        LoadConfigBtn.Font = Enum.Font.SourceSans
        LoadConfigBtn.TextSize = 14
        LoadConfigBtn.TextXAlignment = Enum.TextXAlignment.Left
        LoadConfigBtn.Parent = SettingsGroup
        AddHoverAnimation(LoadConfigBtn, Color3.fromRGB(45, 45, 45), Color3.fromRGB(55, 55, 55))

        local LCCorner = Instance.new("UICorner")
        LCCorner.CornerRadius = UDim.new(0, 6)
        LCCorner.Parent = LoadConfigBtn

        local LCStroke = Instance.new("UIStroke")
        LCStroke.Color = Color3.fromRGB(70, 70, 70)
        LCStroke.Thickness = 1
        LCStroke.Parent = LoadConfigBtn

        local ConfigDropdown = Instance.new("Frame")
        ConfigDropdown.Size = UDim2.new(1, -5, 0, 85)
        ConfigDropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        ConfigDropdown.Parent = SettingsGroup

        local CDCorner = Instance.new("UICorner")
        CDCorner.CornerRadius = UDim.new(0, 6)
        CDCorner.Parent = ConfigDropdown

        local CDStroke = Instance.new("UIStroke")
        CDStroke.Color = Color3.fromRGB(70, 70, 70)
        CDStroke.Thickness = 1
        CDStroke.Parent = ConfigDropdown

        local CDLabel = Instance.new("TextLabel")
        CDLabel.Size = UDim2.new(1, -20, 0, 25)
        CDLabel.Position = UDim2.new(0, 10, 0, 2)
        CDLabel.BackgroundTransparency = 1
        CDLabel.Text = "Config dropdown"
        CDLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        CDLabel.TextSize = 14
        CDLabel.Font = Enum.Font.SourceSans
        CDLabel.TextXAlignment = Enum.TextXAlignment.Left
        CDLabel.Parent = ConfigDropdown

        local Config1 = Instance.new("TextButton")
        Config1.Size = UDim2.new(0, 180, 0, 22)
        Config1.Position = UDim2.new(0, 10, 0, 28)
        Config1.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Config1.Text = "  config 1"
        Config1.TextColor3 = Color3.fromRGB(255, 255, 255)
        Config1.Font = Enum.Font.SourceSans
        Config1.TextSize = 13
        Config1.TextXAlignment = Enum.TextXAlignment.Left
        Config1.Parent = ConfigDropdown
        Instance.new("UICorner", Config1).CornerRadius = UDim.new(0, 4)
        AddHoverAnimation(Config1, Color3.fromRGB(35, 35, 35), Color3.fromRGB(45, 45, 45))

        local Config2 = Instance.new("TextButton")
        Config2.Size = UDim2.new(0, 180, 0, 22)
        Config2.Position = UDim2.new(0, 10, 0, 54)
        Config2.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Config2.Text = "  config 2"
        Config2.TextColor3 = Color3.fromRGB(255, 255, 255)
        Config2.Font = Enum.Font.SourceSans
        Config2.TextSize = 13
        Config2.TextXAlignment = Enum.TextXAlignment.Left
        Config2.Parent = ConfigDropdown
        Instance.new("UICorner", Config2).CornerRadius = UDim.new(0, 4)
        AddHoverAnimation(Config2, Color3.fromRGB(35, 35, 35), Color3.fromRGB(45, 45, 45))

        local ResetConfigBtn = Instance.new("TextButton")
        ResetConfigBtn.Size = UDim2.new(1, -5, 0, 32)
        ResetConfigBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        ResetConfigBtn.Text = "Reset config"
        ResetConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ResetConfigBtn.Font = Enum.Font.SourceSans
        ResetConfigBtn.TextSize = 14
        ResetConfigBtn.TextXAlignment = Enum.TextXAlignment.Left
        ResetConfigBtn.Parent = SettingsGroup
        AddHoverAnimation(ResetConfigBtn, Color3.fromRGB(45, 45, 45), Color3.fromRGB(55, 55, 55))

        local RCCorner = Instance.new("UICorner")
        RCCorner.CornerRadius = UDim.new(0, 6)
        RCCorner.Parent = ResetConfigBtn

        local RCStroke = Instance.new("UIStroke")
        RCStroke.Color = Color3.fromRGB(70, 70, 70)
        RCStroke.Thickness = 1
        RCStroke.Parent = ResetConfigBtn

        local SaveConfigBtn = Instance.new("TextButton")
        SaveConfigBtn.Size = UDim2.new(1, -5, 0, 32)
        SaveConfigBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        SaveConfigBtn.Text = "Save config"
        SaveConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        SaveConfigBtn.Font = Enum.Font.SourceSans
        SaveConfigBtn.TextSize = 14
        SaveConfigBtn.TextXAlignment = Enum.TextXAlignment.Left
        SaveConfigBtn.Parent = SettingsGroup
        AddHoverAnimation(SaveConfigBtn, Color3.fromRGB(45, 45, 45), Color3.fromRGB(55, 55, 55))

        local SCCorner = Instance.new("UICorner")
        SCCorner.CornerRadius = UDim.new(0, 6)
        SCCorner.Parent = SaveConfigBtn

        local SCStroke = Instance.new("UIStroke")
        SCStroke.Color = Color3.fromRGB(70, 70, 70)
        SCStroke.Thickness = 1
        SCStroke.Parent = SaveConfigBtn

        local BindFrame = Instance.new("Frame")
        BindFrame.Size = UDim2.new(1, -5, 0, 35)
        BindFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        BindFrame.Parent = SettingsGroup

        local BindCorner = Instance.new("UICorner")
        BindCorner.CornerRadius = UDim.new(0, 6)
        BindCorner.Parent = BindFrame

        local BindStroke = Instance.new("UIStroke")
        BindStroke.Color = Color3.fromRGB(70, 70, 70)
        BindStroke.Thickness = 1
        BindStroke.Parent = BindFrame

        local BindLabel = Instance.new("TextLabel")
        BindLabel.Size = UDim2.new(1, -120, 1, 0)
        BindLabel.Position = UDim2.new(0, 10, 0, 0)
        BindLabel.BackgroundTransparency = 1
        BindLabel.Text = "Hide ui keybind"
        BindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        BindLabel.TextSize = 14
        BindLabel.Font = Enum.Font.SourceSans
        BindLabel.TextXAlignment = Enum.TextXAlignment.Left
        BindLabel.Parent = BindFrame

        local BindButton = Instance.new("TextButton")
        BindButton.Size = UDim2.new(0, 90, 0, 22)
        BindButton.Position = UDim2.new(1, -100, 0.5, -11)
        BindButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        BindButton.Text = "[" .. Window.Binding.Name .. "]"
        BindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        BindButton.Font = Enum.Font.SourceSans
        BindButton.TextSize = 13
        BindButton.Parent = BindFrame

        local BBCorner = Instance.new("UICorner")
        BBCorner.CornerRadius = UDim.new(0, 4)
        BBCorner.Parent = BindButton

        local listening = false
        BindButton.MouseButton1Click:Connect(function()
            listening = true
            BindButton.Text = "[press key]"
        end)

        UserInputService.InputBegan:Connect(function(input)
            if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                Window.Binding = input.KeyCode
                BindButton.Text = "[" .. input.KeyCode.Name .. "]"
                listening = false
            end
        end)
    end
    
    SetupSettingsTab()

    function Window:SetCredits(customText)
        CreditsLabel.Text = customText
    end

    return Window
end

return Library
