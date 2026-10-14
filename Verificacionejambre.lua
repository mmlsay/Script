local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

-- =========================================================
-- CONFIGURACIÓN
-- =========================================================
local KEY_LINK = "https://work.ink/3539/key-system"
local VALIDATE_URL = "https://work.ink/_api/v2/token/isValid/"
local SAVE_FILE = "AutoMobFarm_Key.txt"
local SINGLE_USE = false          -- true = la key se borra en Work.ink tras validarla
local AUTO_OPEN_ON_START = true   -- abre la página al ejecutar si no hay key guardada
local COOLDOWN = 2                -- segundos entre intentos
local MAX_FAILS = 5               -- fallos antes de bloquear
local LOCKOUT = 15                -- segundos de bloqueo

-- =========================================================
-- SCRIPT PRINCIPAL
-- =========================================================
local function startMainScript()
    print("Ejecutando Auto Mob Farm...")
    -------------------------------------------------------------
    -- PEGA AQUÍ EL CÓDIGO DE TU SCRIPT PRINCIPAL (AUTO FARM) --
    -------------------------------------------------------------
end

-- =========================================================
-- UTILIDADES
-- =========================================================
local function openLink(url)
    for _, fn in ipairs({openurl, open_url, syn and syn.open_url}) do
        if type(fn) == "function" and pcall(fn, url) then return true end
    end
    local ok = pcall(function() GuiService:OpenBrowserWindow(url) end)
    return ok
end

local function httpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and type(res) == "string" and res ~= "" then return res end

    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if req then
        local ok2, r = pcall(req, {Url = url, Method = "GET"})
        if ok2 and r and r.Body and r.Body ~= "" then return r.Body end
    end
    return nil
end

-- Devuelve: true, key_limpia  |  false, motivo ("empty" | "format" | "network" | "invalid")
local function isValidKey(key)
    key = tostring(key or ""):gsub("%s+", "")
    if key == "" then return false, "empty" end
    if #key < 8 or #key > 100 or not key:match("^[%w%-_]+$") then
        return false, "format"
    end

    local url = VALIDATE_URL .. HttpService:UrlEncode(key)
    if SINGLE_USE then url = url .. "?deleteToken=1" end

    local body = httpGet(url)
    if not body then return false, "network" end

    local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
    if not ok or type(data) ~= "table" then return false, "network" end

    if data.valid == true or data.isValid == true then
        return true, key
    end
    return false, "invalid"
end

-- Guardado de key (si el ejecutor soporta archivos)
local function saveKey(key)
    if writefile then pcall(writefile, SAVE_FILE, key) end
end
local function loadSavedKey()
    if isfile and readfile then
        local ok, content = pcall(function()
            if isfile(SAVE_FILE) then return readfile(SAVE_FILE) end
        end)
        if ok and content and content ~= "" then return content end
    end
end
local function clearSavedKey()
    if isfile and delfile then
        pcall(function() if isfile(SAVE_FILE) then delfile(SAVE_FILE) end end)
    end
end

-- =========================================================
-- INTERFAZ
-- =========================================================
local function getGuiParent()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    return CoreGui
end

local parent = getGuiParent()
local old = parent:FindFirstChild("WorkInkKeySystem")
if old then old:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WorkInkKeySystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parent

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 220)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Sistema de Key - Auto Mob Farm"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(0.85, 0, 0, 40)
TextBox.Position = UDim2.new(0.075, 0, 0.25, 0)
TextBox.PlaceholderText = "Pega tu Key aquí..."
TextBox.Text = ""
TextBox.ClearTextOnFocus = false
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 140)
TextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
TextBox.Font = Enum.Font.SourceSans
TextBox.TextSize = 14
TextBox.Parent = MainFrame
Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 6)

local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(0.4, 0, 0, 35)
VerifyBtn.Position = UDim2.new(0.075, 0, 0.52, 0)
VerifyBtn.Text = "Verificar Key"
VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.Font = Enum.Font.SourceSansBold
VerifyBtn.TextSize = 14
VerifyBtn.Parent = MainFrame
Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 6)

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0.4, 0, 0, 35)
GetKeyBtn.Position = UDim2.new(0.525, 0, 0.52, 0)
GetKeyBtn.Text = "Obtener Key"
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyBtn.Font = Enum.Font.SourceSans
GetKeyBtn.TextSize = 14
GetKeyBtn.Parent = MainFrame
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 6)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.85, 0, 0, 30)
StatusLabel.Position = UDim2.new(0.075, 0, 0.78, 0)
StatusLabel.Text = "Pulsa «Obtener Key» para conseguir tu key"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.TextSize = 12
StatusLabel.TextWrapped = true
StatusLabel.Font = Enum.Font.SourceSansItalic
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = MainFrame

local COLORS = {
    info = Color3.fromRGB(180, 180, 180),
    wait = Color3.fromRGB(255, 220, 0),
    ok = Color3.fromRGB(0, 255, 120),
    err = Color3.fromRGB(255, 70, 70),
}
local function setStatus(text, kind)
    StatusLabel.Text = text
    StatusLabel.TextColor3 = COLORS[kind or "info"]
end

-- Arrastre compatible con móvil y PC
do
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- =========================================================
-- LÓGICA DE VERIFICACIÓN
-- =========================================================
local busy = false
local lastAttempt = 0
local fails = 0
local lockedUntil = 0

local MESSAGES = {
    empty = "Escribe tu key primero.",
    format = "Formato de key inválido.",
    network = "No se pudo conectar. Revisa tu internet.",
    invalid = "Key inválida o expirada.",
}

local function tryVerify(rawKey, auto)
    if busy then return end

    local now = os.clock()
    if now < lockedUntil then
        setStatus(("Demasiados intentos. Espera %ds."):format(math.ceil(lockedUntil - now)), "err")
        return
    end
    if not auto and now - lastAttempt < COOLDOWN then
        setStatus("Espera un momento antes de reintentar.", "err")
        return
    end

    busy = true
    lastAttempt = now
    VerifyBtn.Text = "..."
    setStatus(auto and "Comprobando key guardada..." or "Verificando...", "wait")

    local valid, info = isValidKey(rawKey)

    if valid then
        saveKey(info)
        setStatus("¡Key válida! Cargando...", "ok")
        task.wait(0.8)
        ScreenGui:Destroy()
        task.spawn(startMainScript)
        return -- busy queda en true: ya no hay GUI
    end

    if auto then
        clearSavedKey()
        setStatus("Tu key guardada expiró. Consigue una nueva.", "err")
    else
        setStatus(MESSAGES[info] or MESSAGES.invalid, "err")
        if info == "invalid" or info == "format" then
            fails += 1
            if fails >= MAX_FAILS then
                lockedUntil = os.clock() + LOCKOUT
                fails = 0
                setStatus(("Bloqueado %ds por demasiados intentos."):format(LOCKOUT), "err")
            end
        end
    end

    VerifyBtn.Text = "Verificar Key"
    busy = false
end

VerifyBtn.MouseButton1Click:Connect(function()
    tryVerify(TextBox.Text, false)
end)

TextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then tryVerify(TextBox.Text, false) end
end)

GetKeyBtn.MouseButton1Click:Connect(function()
    local copied = false
    if setclipboard then
        copied = pcall(setclipboard, KEY_LINK)
    end

    if openLink(KEY_LINK) then
        setStatus("Abriendo la página de la key...", "ok")
    elseif copied then
        setStatus("Enlace copiado. Pégalo en tu navegador.", "ok")
    else
        TextBox.Text = KEY_LINK
        setStatus("Copia el enlace de la caja de texto.", "info")
    end
end)

-- =========================================================
-- INICIO
-- =========================================================
local saved = loadSavedKey()
if saved then
    task.spawn(function() tryVerify(saved, true) end)
elseif AUTO_OPEN_ON_START then
    task.defer(function()
        if setclipboard then pcall(setclipboard, KEY_LINK) end
        if openLink(KEY_LINK) then
            setStatus("Abriendo la página de la key...", "ok")
        else
            setStatus("Enlace copiado. Pégalo en tu navegador.", "info")
        end
    end)
end
