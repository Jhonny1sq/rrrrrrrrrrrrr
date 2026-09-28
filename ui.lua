local lib = {}

local coregui = game:GetService("CoreGui")
local uis     = game:GetService("UserInputService")
local tween   = game:GetService("TweenService")
local rs      = game:GetService("RunService")

local player  = game.Players.LocalPlayer

-- ==================== HELPERS ====================

local function Tween(gui, props, t, style, dir)
    local tw = tween:Create(gui, TweenInfo.new(
        t     or 0.18,
        style or Enum.EasingStyle.Quart,
        dir   or Enum.EasingDirection.Out
    ), props)
    tw:Play()
    return tw
end

local function randStr(n)
    n = n or math.random(8, 18)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local rng = Random.new()
    local out = table.create(n)
    for i = 1, n do
        local idx = rng:NextInteger(1, #chars)
        out[i] = chars:sub(idx, idx)
    end
    return table.concat(out)
end

local function corner(r, p)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = UDim.new(0, r)
    return c
end

local function stroke(col, thick, trans, p)
    local s = Instance.new("UIStroke", p)
    s.Color          = col
    s.Thickness      = thick or 1
    s.Transparency   = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function pad(px, p)
    local u = Instance.new("UIPadding", p)
    u.PaddingLeft   = UDim.new(0, px)
    u.PaddingRight  = UDim.new(0, px)
    u.PaddingTop    = UDim.new(0, px)
    u.PaddingBottom = UDim.new(0, px)
    return u
end

-- ==================== PALETTE — rivals dark / crimson ====================

local C = {
    Bg         = Color3.fromRGB(9,   9,  11),
    BgAlt      = Color3.fromRGB(6,   6,   8),
    Card       = Color3.fromRGB(14,  14,  18),
    CardHover  = Color3.fromRGB(21,  21,  27),
    Field      = Color3.fromRGB(11,  11,  14),
    Divider    = Color3.fromRGB(26,  26,  33),
    Border     = Color3.fromRGB(30,  30,  38),
    Text       = Color3.fromRGB(234, 234, 238),
    SubText    = Color3.fromRGB(122, 124, 136),
    Muted      = Color3.fromRGB(68,  70,  82),
    Accent     = Color3.fromRGB(212,  38,  46),
    AccentSoft = Color3.fromRGB(228, 100, 107),
    Success    = Color3.fromRGB(62,  175, 102),
    Font       = Enum.Font.GothamMedium,
    FontBold   = Enum.Font.GothamBold,
}

-- ==================== WINDOW ====================

lib.CreateWindow = function(GName, ToggleKey)
    local gui = Instance.new("ScreenGui", coregui)
    gui.Name           = randStr()
    gui.ResetOnSpawn   = false
    gui.IgnoreGuiInset = true

    -- root
    local window = Instance.new("Frame", gui)
    window.Name                   = randStr()
    window.BackgroundColor3       = C.Bg
    window.BackgroundTransparency = 1
    window.AnchorPoint            = Vector2.new(0.5, 0.5)
    window.Position               = UDim2.fromScale(0.5, 0.5)
    window.Size                   = UDim2.new(0, 220, 0, 260)
    window.BorderSizePixel        = 0
    window.ClipsDescendants       = true
    corner(6, window)
    stroke(C.Border, 1, 0.5, window)

    -- barely-there gradient — lighter at top, darker at bottom
    local wg = Instance.new("UIGradient", window)
    wg.Rotation = 90
    wg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 19)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8,  8,  10)),
    })

    -- 1px accent line across the very top
    local topLine = Instance.new("Frame", window)
    topLine.BackgroundColor3 = C.Accent
    topLine.BackgroundTransparency = 0.55
    topLine.BorderSizePixel = 0
    topLine.Size = UDim2.new(1, 0, 0, 1)
    topLine.ZIndex = 6

    -- ---- SIDEBAR ----
    local sidebar = Instance.new("Frame", window)
    sidebar.BackgroundColor3 = C.BgAlt
    sidebar.BorderSizePixel  = 0
    sidebar.Size             = UDim2.new(0, 168, 1, 0)
    sidebar.ZIndex           = 4
    corner(6, sidebar)

    local divLine = Instance.new("Frame", window)
    divLine.BackgroundColor3 = C.Divider
    divLine.BorderSizePixel  = 0
    divLine.Position         = UDim2.new(0, 168, 0, 0)
    divLine.Size             = UDim2.new(0, 1, 1, 0)
    divLine.ZIndex           = 4

    -- ---- HEADER ----
    local header = Instance.new("Frame", sidebar)
    header.BackgroundTransparency = 1
    header.Size   = UDim2.new(1, 0, 0, 96)
    header.ZIndex = 5

    -- logo bg: flat dark card with left accent bar
    local logoBg = Instance.new("Frame", header)
    logoBg.BackgroundColor3 = C.Card
    logoBg.BorderSizePixel  = 0
    logoBg.Position         = UDim2.new(0, 14, 0, 18)
    logoBg.Size             = UDim2.new(0, 42, 0, 42)
    logoBg.ZIndex           = 5
    corner(5, logoBg)
    stroke(C.Border, 1, 0.4, logoBg)

    local logoBar = Instance.new("Frame", logoBg)
    logoBar.BackgroundColor3 = C.Accent
    logoBar.BorderSizePixel  = 0
    logoBar.Position         = UDim2.new(0, 0, 0, 8)
    logoBar.Size             = UDim2.new(0, 2, 0, 26)
    logoBar.ZIndex           = 6
    corner(1, logoBar)

    local logoImg = Instance.new("ImageLabel", header)
    logoImg.Name                  = randStr()
    logoImg.BackgroundTransparency = 1
    logoImg.Position              = UDim2.new(0, 17, 0, 21)
    logoImg.Size                  = UDim2.new(0, 36, 0, 36)
    logoImg.Image                 = "rbxassetid://124542942531502"
    logoImg.ZIndex                = 6

    local brandLbl = Instance.new("TextLabel", header)
    brandLbl.BackgroundTransparency = 1
    brandLbl.Position        = UDim2.new(0, 64, 0, 24)
    brandLbl.Size            = UDim2.new(1, -78, 0, 16)
    brandLbl.Font            = C.FontBold
    brandLbl.TextSize        = 13
    brandLbl.TextColor3      = C.Text
    brandLbl.TextXAlignment  = Enum.TextXAlignment.Left
    brandLbl.TextTruncate    = Enum.TextTruncate.AtEnd
    brandLbl.Text            = "bloody.gg"
    brandLbl.ZIndex          = 5

    local gameLbl = Instance.new("TextLabel", header)
    gameLbl.BackgroundTransparency = 1
    gameLbl.Position       = UDim2.new(0, 64, 0, 43)
    gameLbl.Size           = UDim2.new(1, -78, 0, 12)
    gameLbl.Font           = C.Font
    gameLbl.TextSize       = 10
    gameLbl.TextColor3     = C.AccentSoft
    gameLbl.TextXAlignment = Enum.TextXAlignment.Left
    gameLbl.Text           = tostring(GName or "menu")
    gameLbl.ZIndex         = 5

    local headerLine = Instance.new("Frame", sidebar)
    headerLine.BackgroundColor3 = C.Divider
    headerLine.BorderSizePixel  = 0
    headerLine.Position         = UDim2.new(0, 0, 0, 96)
    headerLine.Size             = UDim2.new(1, 0, 0, 1)
    headerLine.ZIndex           = 5

    -- ---- TAB LIST ----
    -- 8px inset left and right, sits between header line and user card
    local tabsf = Instance.new("ScrollingFrame", sidebar)
    tabsf.BackgroundTransparency = 1
    tabsf.BorderSizePixel        = 0
    tabsf.Position               = UDim2.new(0, 8, 0, 104)
    tabsf.Size                   = UDim2.new(1, -16, 1, -158)
    tabsf.ScrollBarThickness     = 0
    tabsf.CanvasSize             = UDim2.new(0, 0, 0, 0)
    tabsf.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    tabsf.ZIndex                 = 5

    local tabsLayout = Instance.new("UIListLayout", tabsf)
    tabsLayout.Padding    = UDim.new(0, 2)
    tabsLayout.SortOrder  = Enum.SortOrder.LayoutOrder

    -- ---- USER CARD ----
    local userCard = Instance.new("Frame", sidebar)
    userCard.BackgroundColor3 = C.Card
    userCard.BorderSizePixel  = 0
    userCard.AnchorPoint      = Vector2.new(0, 1)
    userCard.Position         = UDim2.new(0, 0, 1, 0)
    userCard.Size             = UDim2.new(1, 0, 0, 52)
    userCard.ZIndex           = 5

    local ucTop = Instance.new("Frame", userCard)
    ucTop.BackgroundColor3 = C.Divider
    ucTop.BorderSizePixel  = 0
    ucTop.Size             = UDim2.new(1, 0, 0, 1)
    ucTop.ZIndex           = 6

    local ava = Instance.new("ImageLabel", userCard)
    ava.BackgroundColor3 = C.Field
    ava.BorderSizePixel  = 0
    ava.Position         = UDim2.new(0, 12, 0.5, -12)
    ava.Size             = UDim2.new(0, 24, 0, 24)
    ava.Image            = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=48&h=48"
    ava.ZIndex           = 6
    corner(12, ava)

    local uname = Instance.new("TextLabel", userCard)
    uname.BackgroundTransparency = 1
    uname.Position       = UDim2.new(0, 44, 0, 10)
    uname.Size           = UDim2.new(1, -52, 0, 14)
    uname.Font           = C.FontBold
    uname.TextSize       = 11
    uname.TextColor3     = C.Text
    uname.TextXAlignment = Enum.TextXAlignment.Left
    uname.TextTruncate   = Enum.TextTruncate.AtEnd
    uname.Text           = player.DisplayName
    uname.ZIndex         = 6

    local sDot = Instance.new("Frame", userCard)
    sDot.BackgroundColor3 = C.Success
    sDot.BorderSizePixel  = 0
    sDot.Position         = UDim2.new(0, 44, 0, 28)
    sDot.Size             = UDim2.new(0, 6, 0, 6)
    sDot.ZIndex           = 6
    corner(3, sDot)

    local sLbl = Instance.new("TextLabel", userCard)
    sLbl.BackgroundTransparency = 1
    sLbl.Position       = UDim2.new(0, 54, 0, 24)
    sLbl.Size           = UDim2.new(1, -62, 0, 12)
    sLbl.Font           = C.Font
    sLbl.TextSize       = 10
    sLbl.TextColor3     = C.Muted
    sLbl.TextXAlignment = Enum.TextXAlignment.Left
    sLbl.Text           = "active"
    sLbl.ZIndex         = 6

    -- ---- CONTENT ----
    local content = Instance.new("Frame", window)
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 184, 0, 14)
    content.Size     = UDim2.new(1, -196, 1, -28)
    content.ZIndex   = 4

    -- ---- DRAG BAR (header region) ----
    local dragBar = Instance.new("TextButton", window)
    dragBar.BackgroundTransparency = 1
    dragBar.BorderSizePixel        = 0
    dragBar.Position               = UDim2.new(0, 0, 0, 0)
    dragBar.Size                   = UDim2.new(0, 168, 0, 48)
    dragBar.Text                   = ""
    dragBar.AutoButtonColor        = false
    dragBar.ZIndex                 = 10

    -- ---- NOTIFICATIONS ----
    local notifs = Instance.new("Frame", gui)
    notifs.BackgroundTransparency = 1
    notifs.AnchorPoint            = Vector2.new(1, 1)
    notifs.Position               = UDim2.new(1, -16, 1, -16)
    notifs.Size                   = UDim2.new(0, 280, 1, -32)
    local notifsLayout = Instance.new("UIListLayout", notifs)
    notifsLayout.Padding             = UDim.new(0, 6)
    notifsLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    notifsLayout.VerticalAlignment   = Enum.VerticalAlignment.Bottom
    notifsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right

    -- ---- ENTRANCE ----
    tween:Create(window, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size                   = UDim2.new(0, 720, 0, 460),
        BackgroundTransparency = 0,
    }):Play()

    local tabs      = {}
    local wlib      = {}
    local firstTab  = true

    -- ---- DRAG ----
    local dragging, dragStart, startPos = false, nil, nil
    local targetPos = window.Position

    local function beginDrag(input)
        dragging  = true
        dragStart = input.Position
        startPos  = window.Position
        targetPos = window.Position
    end

    dragBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
            beginDrag(i)
        end
    end)
    uis.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            targetPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    uis.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local dragConn = rs.RenderStepped:Connect(function(dt)
        if not window.Parent then return end
        local cur = window.Position
        local lf  = math.clamp(dt * 16, 0, 1)
        window.Position = UDim2.new(
            cur.X.Scale  + (targetPos.X.Scale  - cur.X.Scale)  * lf,
            cur.X.Offset + (targetPos.X.Offset - cur.X.Offset) * lf,
            cur.Y.Scale  + (targetPos.Y.Scale  - cur.Y.Scale)  * lf,
            cur.Y.Offset + (targetPos.Y.Offset - cur.Y.Offset) * lf
        )
    end)

    -- ---- PULSE (active tab indicator on sidebar) ----
    local pulse = Instance.new("Frame", sidebar)
    pulse.BackgroundColor3       = C.Accent
    pulse.BackgroundTransparency = 1
    pulse.BorderSizePixel        = 0
    pulse.Position               = UDim2.new(0, 0, 0, 104)
    pulse.Size                   = UDim2.new(0, 2, 0, 16)
    pulse.ZIndex                 = 7
    corner(1, pulse)

    local pulsePhase = 0
    local pulseConn = rs.Heartbeat:Connect(function(dt)
        if not window.Parent then return end
        if pulse.BackgroundTransparency < 1 then
            pulsePhase = pulsePhase + dt * 2.2
            pulse.BackgroundTransparency = 0.25 + math.sin(pulsePhase) * 0.2
        end
    end)

    -- ---- TOGGLE KEYBIND ----
    wlib.ToggleKeybind = ToggleKey or Enum.KeyCode.Delete
    local menuOpen = true

    local function collectFadeTargets()
        local list = {}
        local function scan(obj)
            for _, d in ipairs(obj:GetChildren()) do
                if d:IsA("GuiObject") then
                    if not d:GetAttribute("_oBg") then
                        d:SetAttribute("_oBg", d.BackgroundTransparency)
                    end
                    local entry = { obj = d, origBg = d:GetAttribute("_oBg"), origText = nil }
                    if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                        if not d:GetAttribute("_oTx") then
                            d:SetAttribute("_oTx", d.TextTransparency)
                        end
                        entry.origText = d:GetAttribute("_oTx")
                    end
                    table.insert(list, entry)
                    scan(d)
                end
            end
        end
        scan(window)
        return list
    end

    local fadeTargets = collectFadeTargets()

    uis.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == wlib.ToggleKeybind then
            menuOpen = not menuOpen
            if menuOpen then
                window.Visible = true
                for _, e in ipairs(fadeTargets) do
                    if e.obj.Parent then
                        Tween(e.obj, { BackgroundTransparency = e.origBg }, 0.15)
                        if e.origText then Tween(e.obj, { TextTransparency = e.origText }, 0.15) end
                    end
                end
            else
                for _, e in ipairs(fadeTargets) do
                    if e.obj.Parent then
                        Tween(e.obj, { BackgroundTransparency = 1 }, 0.12)
                        if e.origText then Tween(e.obj, { TextTransparency = 1 }, 0.12) end
                    end
                end
                task.delay(0.14, function()
                    if not menuOpen then window.Visible = false end
                end)
            end
        end
    end)

    -- ==================== NOTIFICATION ====================

    wlib.Notification = function(title, text, duration)
        duration = duration or 4

        local card = Instance.new("Frame", notifs)
        card.BackgroundColor3       = C.Card
        card.BackgroundTransparency = 1
        card.BorderSizePixel        = 0
        card.Size                   = UDim2.new(1, 0, 0, 62)
        card.ZIndex                 = 20
        corner(6, card)
        local cs = stroke(C.Border, 1, 1, card)

        local strip = Instance.new("Frame", card)
        strip.BackgroundColor3       = C.Accent
        strip.BackgroundTransparency = 1
        strip.BorderSizePixel        = 0
        strip.Position               = UDim2.new(0, 0, 0, 8)
        strip.Size                   = UDim2.new(0, 2, 1, -16)
        strip.ZIndex                 = 21
        corner(1, strip)

        local tl = Instance.new("TextLabel", card)
        tl.BackgroundTransparency = 1
        tl.Position               = UDim2.new(0, 14, 0, 10)
        tl.Size                   = UDim2.new(1, -22, 0, 16)
        tl.Font                   = C.FontBold
        tl.TextSize               = 12
        tl.TextColor3             = C.Text
        tl.TextXAlignment         = Enum.TextXAlignment.Left
        tl.Text                   = tostring(title or "")
        tl.TextTransparency       = 1

        local bl = Instance.new("TextLabel", card)
        bl.BackgroundTransparency = 1
        bl.Position               = UDim2.new(0, 14, 0, 28)
        bl.Size                   = UDim2.new(1, -22, 0, 26)
        bl.Font                   = C.Font
        bl.TextSize               = 11
        bl.TextColor3             = C.SubText
        bl.TextXAlignment         = Enum.TextXAlignment.Left
        bl.TextYAlignment         = Enum.TextYAlignment.Top
        bl.TextWrapped            = true
        bl.Text                   = tostring(text or "")
        bl.TextTransparency       = 1

        Tween(card,  { BackgroundTransparency = 0 }, 0.2)
        Tween(cs,    { Transparency = 0.5 }, 0.2)
        Tween(strip, { BackgroundTransparency = 0 }, 0.2)
        Tween(tl,    { TextTransparency = 0 }, 0.2)
        Tween(bl,    { TextTransparency = 0 }, 0.2)

        task.delay(duration, function()
            if not card.Parent then return end
            Tween(card,  { BackgroundTransparency = 1 }, 0.2)
            Tween(cs,    { Transparency = 1 }, 0.2)
            Tween(strip, { BackgroundTransparency = 1 }, 0.2)
            Tween(tl,    { TextTransparency = 1 }, 0.2)
            Tween(bl,    { TextTransparency = 1 }, 0.2)
            task.wait(0.25)
            card:Destroy()
        end)
    end

    -- ==================== TAB ====================

    wlib.CreateTab = function(tabName)
        local tab = { Name = tabName }

        -- page
        local page = Instance.new("ScrollingFrame", content)
        page.BackgroundTransparency = 1
        page.BorderSizePixel        = 0
        page.Size                   = UDim2.new(1, 0, 1, 0)
        page.ScrollBarThickness     = 2
        page.ScrollBarImageColor3   = C.Accent
        page.CanvasSize             = UDim2.new(0, 0, 0, 0)
        page.Visible                = false
        page.ZIndex                 = 5
        local pl = Instance.new("UIListLayout", page)
        pl.Padding   = UDim.new(0, 6)
        pl.SortOrder = Enum.SortOrder.LayoutOrder
        pl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, pl.AbsoluteContentSize.Y + 10)
        end)

        -- tab button — no background, just text + left bar
        local btn = Instance.new("TextButton", tabsf)
        btn.BackgroundTransparency = 1
        btn.BorderSizePixel        = 0
        btn.Size                   = UDim2.new(1, 0, 0, 30)
        btn.LayoutOrder            = #tabs + 1
        btn.Text                   = ""
        btn.AutoButtonColor        = false
        btn.ZIndex                 = 6
        corner(4, btn)

        -- active bar: sits at left edge of the button
        local bar = Instance.new("Frame", btn)
        bar.BackgroundColor3       = C.Accent
        bar.BackgroundTransparency = 1
        bar.BorderSizePixel        = 0
        bar.AnchorPoint            = Vector2.new(0, 0.5)
        bar.Position               = UDim2.new(0, 0, 0.5, 0)
        bar.Size                   = UDim2.new(0, 2, 0, 14)
        bar.ZIndex                 = 7
        corner(1, bar)

        local btnLbl = Instance.new("TextLabel", btn)
        btnLbl.BackgroundTransparency = 1
        btnLbl.Position               = UDim2.new(0, 10, 0, 0)
        btnLbl.Size                   = UDim2.new(1, -12, 1, 0)
        btnLbl.Font                   = C.Font
        btnLbl.TextSize               = 12
        btnLbl.TextColor3             = C.Muted
        btnLbl.TextXAlignment         = Enum.TextXAlignment.Left
        btnLbl.ZIndex                 = 7
        btnLbl.Text                   = tabName

        tab.Page   = page
        tab.Button = btn
        tab.Bar    = bar
        tab.Label  = btnLbl

        local function selectTab()
            for _, t in pairs(tabs) do
                t.Page.Visible = false
                Tween(t.Bar,   { BackgroundTransparency = 1 }, 0.15)
                Tween(t.Label, { TextColor3 = C.Muted }, 0.15)
                t.Label.Font = C.Font
            end
            page.Visible = true
            Tween(bar,    { BackgroundTransparency = 0 }, 0.15)
            Tween(btnLbl, { TextColor3 = C.Text }, 0.15)
            btnLbl.Font = C.FontBold

            pulse.Position = UDim2.new(
                0, 0,
                0, 104 + (btn.AbsolutePosition.Y - tabsf.AbsolutePosition.Y) + 8
            )
            pulse.Size = UDim2.new(0, 2, 0, 14)
            pulse.BackgroundTransparency = 0.25
        end
        tab.Select = selectTab

        btn.MouseButton1Click:Connect(selectTab)

        -- ---- SECTION ----
        tab.CreateSection = function(name)
            local h = Instance.new("Frame", page)
            h.BackgroundTransparency = 1
            h.Size = UDim2.new(1, 0, 0, 20)

            local l = Instance.new("TextLabel", h)
            l.BackgroundTransparency = 1
            l.Position       = UDim2.new(0, 2, 0, 0)
            l.Size           = UDim2.new(1, -4, 1, 0)
            l.Font           = C.FontBold
            l.TextSize       = 10
            l.TextColor3     = C.Muted
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Text           = string.upper(name)
            return { Label = l, Holder = h }
        end

        -- ---- ROW BASE ----
        local function rowBase(h)
            local r = Instance.new("Frame", page)
            r.BackgroundColor3       = C.Card
            r.BackgroundTransparency = 0
            r.BorderSizePixel        = 0
            r.Size                   = UDim2.new(1, 0, 0, h or 40)
            r.ZIndex                 = 5
            corner(6, r)
            local s = stroke(C.Border, 1, 0.55, r)
            return r, s
        end

        -- ---- BUTTON (no hover) ----
        tab.CreateButton = function(cfg)
            cfg = cfg or {}
            local r, s = rowBase(38)

            local l = Instance.new("TextLabel", r)
            l.BackgroundTransparency = 1
            l.Position       = UDim2.new(0, 14, 0, 0)
            l.Size           = UDim2.new(1, -40, 1, 0)
            l.Font           = C.Font
            l.TextSize       = 12
            l.TextColor3     = C.Text
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Text           = cfg.Text or "Button"
            l.ZIndex         = 6

            -- minimal right-side chevron
            local chev = Instance.new("TextLabel", r)
            chev.BackgroundTransparency = 1
            chev.AnchorPoint            = Vector2.new(1, 0.5)
            chev.Position               = UDim2.new(1, -14, 0.5, 0)
            chev.Size                   = UDim2.new(0, 10, 0, 10)
            chev.Font                   = C.FontBold
            chev.TextSize               = 10
            chev.TextColor3             = C.Muted
            chev.Text                   = "›"
            chev.ZIndex                 = 6

            local b = Instance.new("TextButton", r)
            b.BackgroundTransparency = 1
            b.Size                   = UDim2.new(1, 0, 1, 0)
            b.Text                   = ""
            b.AutoButtonColor        = false
            b.ZIndex                 = 7

            b.MouseButton1Click:Connect(function()
                if cfg.Callback then task.spawn(cfg.Callback) end
            end)

            return { Row = r }
        end

        -- ---- TOGGLE (no hover) ----
        tab.CreateToggle = function(cfg)
            cfg = cfg or {}
            local state = cfg.Default == true
            local r, s  = rowBase(40)

            local l = Instance.new("TextLabel", r)
            l.BackgroundTransparency = 1
            l.Position       = UDim2.new(0, 14, 0, 0)
            l.Size           = UDim2.new(1, -80, 1, 0)
            l.Font           = C.Font
            l.TextSize       = 12
            l.TextColor3     = C.Text
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Text           = cfg.Text or "Toggle"
            l.ZIndex         = 6

            local track = Instance.new("Frame", r)
            track.BackgroundColor3 = state and C.Accent or C.Field
            track.BorderSizePixel  = 0
            track.AnchorPoint      = Vector2.new(1, 0.5)
            track.Position         = UDim2.new(1, -14, 0.5, 0)
            track.Size             = UDim2.new(0, 36, 0, 18)
            track.ZIndex           = 6
            corner(9, track)
            stroke(C.Border, 1, 0.5, track)

            local knob = Instance.new("Frame", track)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BorderSizePixel  = 0
            knob.AnchorPoint      = Vector2.new(0, 0.5)
            knob.Position         = state and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
            knob.Size             = UDim2.new(0, 14, 0, 14)
            knob.ZIndex           = 7
            corner(7, knob)

            local hit = Instance.new("TextButton", r)
            hit.BackgroundTransparency = 1
            hit.Size                   = UDim2.new(1, 0, 1, 0)
            hit.Text                   = ""
            hit.ZIndex                 = 8

            local function render()
                Tween(track, { BackgroundColor3 = state and C.Accent or C.Field }, 0.18)
                Tween(knob,  {
                    Position = state and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
                }, 0.18, Enum.EasingStyle.Back)
            end

            hit.MouseButton1Click:Connect(function()
                state = not state
                render()
                if cfg.Callback then task.spawn(cfg.Callback, state) end
            end)

            return {
                Row = r,
                Set = function(v)
                    state = v == true
                    render()
                    if cfg.Callback then task.spawn(cfg.Callback, state) end
                end,
                Get = function() return state end,
            }
        end

        -- ---- SLIDER (no hover) ----
        tab.CreateSlider = function(cfg)
            cfg = cfg or {}
            local minV  = cfg.Min     or 0
            local maxV  = cfg.Max     or 100
            local value = math.clamp(cfg.Default or minV, minV, maxV)
            local r, s  = rowBase(52)

            local l = Instance.new("TextLabel", r)
            l.BackgroundTransparency = 1
            l.Position       = UDim2.new(0, 14, 0, 8)
            l.Size           = UDim2.new(1, -100, 0, 16)
            l.Font           = C.Font
            l.TextSize       = 12
            l.TextColor3     = C.Text
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Text           = cfg.Text or "Slider"
            l.ZIndex         = 6

            local valLbl = Instance.new("TextLabel", r)
            valLbl.BackgroundTransparency = 1
            valLbl.AnchorPoint            = Vector2.new(1, 0)
            valLbl.Position               = UDim2.new(1, -14, 0, 8)
            valLbl.Size                   = UDim2.new(0, 80, 0, 16)
            valLbl.Font                   = C.FontBold
            valLbl.TextSize               = 12
            valLbl.TextColor3             = C.AccentSoft
            valLbl.TextXAlignment         = Enum.TextXAlignment.Right
            valLbl.Text                   = tostring(value)
            valLbl.ZIndex                 = 6

            local trackBg = Instance.new("Frame", r)
            trackBg.BackgroundColor3 = C.Field
            trackBg.BorderSizePixel  = 0
            trackBg.Position         = UDim2.new(0, 14, 1, -18)
            trackBg.Size             = UDim2.new(1, -28, 0, 6)
            trackBg.ZIndex           = 6
            corner(3, trackBg)

            local rel = (value - minV) / (maxV - minV)

            local fill = Instance.new("Frame", trackBg)
            fill.BackgroundColor3 = C.Accent
            fill.BorderSizePixel  = 0
            fill.Size             = UDim2.new(rel, 0, 1, 0)
            fill.ZIndex           = 7
            corner(3, fill)

            local knob = Instance.new("Frame", trackBg)
            knob.BackgroundColor3 = Color3.fromRGB(236, 236, 240)
            knob.BorderSizePixel  = 0
            knob.AnchorPoint      = Vector2.new(0.5, 0.5)
            knob.Position         = UDim2.new(rel, 0, 0.5, 0)
            knob.Size             = UDim2.new(0, 12, 0, 12)
            knob.ZIndex           = 8
            corner(6, knob)
            stroke(C.Accent, 1.5, 0, knob)

            local hit = Instance.new("TextButton", r)
            hit.BackgroundTransparency = 1
            hit.Position               = UDim2.new(0, 0, 1, -26)
            hit.Size                   = UDim2.new(1, 0, 0, 26)
            hit.Text                   = ""
            hit.ZIndex                 = 8

            local draggingSlider = false

            local function setFromX(x)
                local pct = math.clamp(
                    (x - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1
                )
                value = minV + (maxV - minV) * pct
                if cfg.Round then value = math.floor(value + 0.5) end
                fill.Size         = UDim2.new(pct, 0, 1, 0)
                knob.Position     = UDim2.new(pct, 0, 0.5, 0)
                valLbl.Text       = tostring(value)
                if cfg.Callback then task.spawn(cfg.Callback, value) end
            end

            hit.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                    or i.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = true
                    setFromX(i.Position.X)
                end
            end)
            uis.InputChanged:Connect(function(i)
                if draggingSlider and (i.UserInputType == Enum.UserInputType.MouseMovement
                    or i.UserInputType == Enum.UserInputType.Touch) then
                    setFromX(i.Position.X)
                end
            end)
            uis.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                    or i.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = false
                end
            end)

            return {
                Row = r,
                Set = function(v)
                    v = math.clamp(v, minV, maxV)
                    value = v
                    local pct = (v - minV) / (maxV - minV)
                    fill.Size     = UDim2.new(pct, 0, 1, 0)
                    knob.Position = UDim2.new(pct, 0, 0.5, 0)
                    valLbl.Text   = tostring(value)
                    if cfg.Callback then task.spawn(cfg.Callback, value) end
                end,
                Get = function() return value end,
            }
        end

        -- ---- TEXTBOX (no row hover — only input border focuses) ----
        tab.CreateTextBox = function(cfg)
            cfg = cfg or {}
            local r, s = rowBase(40)

            local l = Instance.new("TextLabel", r)
            l.BackgroundTransparency = 1
            l.Position       = UDim2.new(0, 14, 0, 0)
            l.Size           = UDim2.new(1, -174, 1, 0)
            l.Font           = C.Font
            l.TextSize       = 12
            l.TextColor3     = C.Text
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Text           = cfg.Text or "Input"
            l.ZIndex         = 6

            local boxBg = Instance.new("Frame", r)
            boxBg.BackgroundColor3 = C.Field
            boxBg.BorderSizePixel  = 0
            boxBg.AnchorPoint      = Vector2.new(1, 0.5)
            boxBg.Position         = UDim2.new(1, -14, 0.5, 0)
            boxBg.Size             = UDim2.new(0, 150, 0, 26)
            boxBg.ZIndex           = 6
            corner(5, boxBg)
            local bs = stroke(C.Border, 1, 0.55, boxBg)

            local input = Instance.new("TextBox", boxBg)
            input.BackgroundTransparency = 1
            input.Position               = UDim2.new(0, 10, 0, 0)
            input.Size                   = UDim2.new(1, -20, 1, 0)
            input.Font                   = C.Font
            input.TextSize               = 11
            input.TextColor3             = C.Text
            input.PlaceholderColor3      = C.Muted
            input.PlaceholderText        = cfg.Placeholder or "..."
            input.Text                   = cfg.Default or ""
            input.TextXAlignment         = Enum.TextXAlignment.Left
            input.ClearTextOnFocus       = false
            input.ZIndex                 = 7

            input.Focused:Connect(function()
                Tween(bs, { Color = C.Accent, Transparency = 0.2 }, 0.15)
            end)
            input.FocusLost:Connect(function(enter)
                Tween(bs, { Color = C.Border, Transparency = 0.55 }, 0.15)
                if cfg.Callback then task.spawn(cfg.Callback, input.Text, enter) end
            end)

            return {
                Row = r,
                Set = function(v) input.Text = v end,
                Get = function() return input.Text end,
            }
        end

        -- ---- LABEL ----
        tab.CreateLabel = function(cfg)
            cfg = cfg or {}
            local r = Instance.new("Frame", page)
            r.BackgroundTransparency = 1
            r.Size   = UDim2.new(1, 0, 0, cfg.Height or 20)
            r.ZIndex = 5
            local l = Instance.new("TextLabel", r)
            l.BackgroundTransparency = 1
            l.Position       = UDim2.new(0, 4, 0, 0)
            l.Size           = UDim2.new(1, -8, 1, 0)
            l.Font           = C.Font
            l.TextSize       = 11
            l.TextColor3     = cfg.Color or C.SubText
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.TextWrapped    = true
            l.Text           = cfg.Text or ""
            l.ZIndex         = 6
            return { Row = r }
        end

        -- ---- DROPDOWN (no header hover; option items keep hover for usability) ----
        tab.CreateDropdown = function(cfg)
            cfg = cfg or {}
            local options  = cfg.Options or {}
            local selected = cfg.Default or options[1]
            local expanded = false

            local container = Instance.new("Frame", page)
            container.BackgroundColor3       = C.Card
            container.BackgroundTransparency = 0
            container.BorderSizePixel        = 0
            container.Size                   = UDim2.new(1, 0, 0, 40)
            container.AutomaticSize          = Enum.AutomaticSize.Y
            container.ClipsDescendants       = true
            container.ZIndex                 = 5
            corner(6, container)
            local cs = stroke(C.Border, 1, 0.55, container)

            local cl = Instance.new("UIListLayout", container)
            cl.SortOrder = Enum.SortOrder.LayoutOrder

            local hdr = Instance.new("TextButton", container)
            hdr.BackgroundTransparency = 1
            hdr.Size                   = UDim2.new(1, 0, 0, 40)
            hdr.Text                   = ""
            hdr.AutoButtonColor        = false
            hdr.LayoutOrder            = 0
            hdr.ZIndex                 = 6

            local hl = Instance.new("TextLabel", hdr)
            hl.BackgroundTransparency = 1
            hl.Position       = UDim2.new(0, 14, 0, 0)
            hl.Size           = UDim2.new(1, -130, 1, 0)
            hl.Font           = C.Font
            hl.TextSize       = 12
            hl.TextColor3     = C.Text
            hl.TextXAlignment = Enum.TextXAlignment.Left
            hl.Text           = cfg.Text or "Dropdown"
            hl.ZIndex         = 7

            local vl = Instance.new("TextLabel", hdr)
            vl.BackgroundTransparency = 1
            vl.AnchorPoint            = Vector2.new(1, 0)
            vl.Position               = UDim2.new(1, -30, 0, 0)
            vl.Size                   = UDim2.new(0, 90, 1, 0)
            vl.Font                   = C.FontBold
            vl.TextSize               = 11
            vl.TextColor3             = C.AccentSoft
            vl.TextXAlignment         = Enum.TextXAlignment.Right
            vl.Text                   = tostring(selected or "")
            vl.ZIndex                 = 7

            local chev = Instance.new("TextLabel", hdr)
            chev.BackgroundTransparency = 1
            chev.AnchorPoint            = Vector2.new(1, 0.5)
            chev.Position               = UDim2.new(1, -12, 0.5, 0)
            chev.Size                   = UDim2.new(0, 12, 0, 12)
            chev.Font                   = C.FontBold
            chev.TextSize               = 9
            chev.TextColor3             = C.Muted
            chev.Text                   = "▼"
            chev.ZIndex                 = 7

            local listFrame = Instance.new("Frame", container)
            listFrame.BackgroundTransparency = 1
            listFrame.Size                   = UDim2.new(1, 0, 0, 0)
            listFrame.Visible                = false
            listFrame.LayoutOrder            = 1
            listFrame.ZIndex                 = 6
            local ll = Instance.new("UIListLayout", listFrame)
            ll.Padding   = UDim.new(0, 2)
            ll.SortOrder = Enum.SortOrder.LayoutOrder
            pad(6, listFrame)

            for i, opt in ipairs(options) do
                local ob = Instance.new("TextButton", listFrame)
                ob.BackgroundColor3       = C.Field
                ob.BackgroundTransparency = 0
                ob.BorderSizePixel        = 0
                ob.Size                   = UDim2.new(1, 0, 0, 28)
                ob.Text                   = ""
                ob.AutoButtonColor        = false
                ob.LayoutOrder            = i
                ob.ZIndex                 = 7
                corner(4, ob)

                local ol = Instance.new("TextLabel", ob)
                ol.BackgroundTransparency = 1
                ol.Position       = UDim2.new(0, 10, 0, 0)
                ol.Size           = UDim2.new(1, -16, 1, 0)
                ol.Font           = C.Font
                ol.TextSize       = 11
                ol.TextColor3     = C.SubText
                ol.TextXAlignment = Enum.TextXAlignment.Left
                ol.Text           = tostring(opt)
                ol.ZIndex         = 8

                -- hover stays on option items only (needed for usability)
                ob.MouseEnter:Connect(function()
                    Tween(ob, { BackgroundColor3 = C.CardHover }, 0.12)
                    Tween(ol, { TextColor3 = C.Text }, 0.12)
                end)
                ob.MouseLeave:Connect(function()
                    Tween(ob, { BackgroundColor3 = C.Field }, 0.12)
                    Tween(ol, { TextColor3 = C.SubText }, 0.12)
                end)
                ob.MouseButton1Click:Connect(function()
                    selected = opt
                    vl.Text = tostring(opt)
                    expanded = false
                    listFrame.Visible = false
                    listFrame.Size    = UDim2.new(1, 0, 0, 0)
                    Tween(chev, { Rotation = 0 }, 0.18)
                    if cfg.Callback then task.spawn(cfg.Callback, opt) end
                end)
            end

            hdr.MouseButton1Click:Connect(function()
                expanded = not expanded
                if expanded then
                    listFrame.Size    = UDim2.new(1, 0, 0, #options * 30 + 12)
                    listFrame.Visible = true
                    Tween(chev, { Rotation = 180 }, 0.18)
                else
                    listFrame.Size    = UDim2.new(1, 0, 0, 0)
                    listFrame.Visible = false
                    Tween(chev, { Rotation = 0 }, 0.18)
                end
            end)

            return {
                Row = container,
                Set = function(v)
                    if table.find(options, v) then
                        selected = v
                        vl.Text = tostring(v)
                        if cfg.Callback then task.spawn(cfg.Callback, v) end
                    end
                end,
                Get = function() return selected end,
            }
        end

        table.insert(tabs, tab)
        if firstTab then
            firstTab = false
            selectTab()
        end

        return tab
    end

    wlib.Window        = window
    wlib.ScreenGui     = gui
    wlib.TabsFrame     = tabsf
    wlib.Content       = content
    wlib.GameNameLabel = gameLbl

    wlib.Destroy = function()
        dragConn:Disconnect()
        pulseConn:Disconnect()
        gui:Destroy()
    end

    return wlib
end

-- ==================== DEMO ====================

local w    = lib.CreateWindow("blox fruits", Enum.KeyCode.Delete)

local main = w.CreateTab("Main")
main.CreateSection("Combat")
main.CreateButton({ Text = "Kill Aura",   Callback = function() print("kill aura") end })
main.CreateToggle({ Text = "ESP",         Default = false, Callback = function(s) print("esp:", s) end })
main.CreateSlider({
    Text = "WalkSpeed", Min = 16, Max = 300, Default = 16, Round = true,
    Callback = function(v)
        local hum = game.Players.LocalPlayer.Character
            and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end,
})
main.CreateDropdown({
    Text    = "Target Mode",
    Options = { "Nearest", "Lowest HP", "Random" },
    Default = "Nearest",
})

local cfg = w.CreateTab("Config")
cfg.CreateButton({ Text = "Save Config", Callback = function() print("saved") end })

w.Notification("Loaded", "bloody.gg active.", 4)

return lib
