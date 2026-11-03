--!strict
--[[
	============================================================================
	ANIME OBBY HUB — UNIFIED SINGLE-SCRIPT EDITION (ROBLOX LUAU)
	============================================================================
	Localizacao recomendada: StarterPlayer > StarterPlayerScripts (LocalScript)
	Inclui:
	- Configuracao Completa + Paleta Anime Futurista (Glassmorphism, Sem Emojis)
	- Rota Oficial de 10 Etapas extraida do video (Tempo WR: 9.012s | PB: 9.078s)
	- Gerador Local da Pista de Treino no Workspace
	- Sistema Auto Control (Iniciar, Pausar, Continuar, Parar, Reiniciar, Raycast)
	- Gravador de Percursos Customizados em Tempo Real
	- Sistema de Audio no SoundService e Imagem de Fundo Anime Configuravel
	- 5 Abas Completas: HOME, AUTO CONTROL, ROUTES, ANALYTICS, SETTINGS
	============================================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================================
-- 1. CONFIGURAÇÕES GERAIS, TEMA VISUAL E DADOS EXTRAÍDOS DO VÍDEO
-- ============================================================================
export type RouteStep = {
	StepIndex: number,
	Name: string,
	TargetTime: number,
	RelativeOffset: Vector3,
	PlatformSize: Vector3,
	ShouldJumpOnStart: boolean,
	ShouldJumpNearEnd: boolean,
	CameraYawOffset: number,
	IsCheckpoint: boolean,
	Note: string,
}

export type RouteData = {
	Id: string,
	Title: string,
	Description: string,
	BenchmarkTime: number,
	PreviousPB: number,
	Steps: {RouteStep},
}

local Config = {
	HubInfo = {
		Name = "ANIME OBBY HUB",
		Version = "3.0.0 UNIFIED EDITION",
		Subtitle = "AUTOMATION // TELEMETRY // ROUTE ENGINE",
		ReferenceRecordTime = 9.012,
		PreviousPersonalBest = 9.078,
	},

	DefaultSettings = {
		UIWindowTransparency = 0.12,
		BackgroundImageAssetId = "", -- Insira rbxassetid://ID_DA_IMAGEM na aba SETTINGS ou aqui
		BackgroundImageOpacity = 0.22,
		MusicAssetId = "", -- Insira rbxassetid://ID_DO_AUDIO na aba SETTINGS ou aqui
		MusicEnabled = true,
		MusicVolume = 0.45,
		AnimationsEnabled = true,
		UIScale = 1.0,
		ToggleKey = Enum.KeyCode.RightShift,
		DefaultWalkSpeed = 20,
		DefaultJumpPower = 52,
		WaypointPrecision = 2.6,
		AutoRecovery = true,
	},

	Theme = {
		BackgroundPrimary = Color3.fromRGB(11, 13, 22),
		BackgroundSecondary = Color3.fromRGB(17, 21, 36),
		PanelGlass = Color3.fromRGB(24, 30, 50),
		AccentPrimary = Color3.fromRGB(0, 215, 255),
		AccentSecondary = Color3.fromRGB(145, 70, 255),
		AccentSuccess = Color3.fromRGB(0, 230, 150),
		AccentWarning = Color3.fromRGB(255, 185, 40),
		AccentDanger = Color3.fromRGB(255, 65, 105),
		TextPrimary = Color3.fromRGB(242, 246, 255),
		TextSecondary = Color3.fromRGB(155, 168, 198),
		TextMuted = Color3.fromRGB(98, 110, 140),
		StrokeColor = Color3.fromRGB(60, 85, 135),
	},

	PreloadedRoutes = {
		{
			Id = "video_wr_9012",
			Title = "Rota Oficial do Video (No Plat 9.012s)",
			Description = "Sequencia de 10 etapas com saltos continuos, quinas e atalho diagonal observada no video.",
			BenchmarkTime = 9.012,
			PreviousPB = 9.078,
			Steps = {
				{
					StepIndex = 1,
					Name = "Largada + Salto com Giro (Cool x2)",
					TargetTime = 0.768,
					RelativeOffset = Vector3.new(12, 2, -18),
					PlatformSize = Vector3.new(5, 1.5, 5),
					ShouldJumpOnStart = true,
					ShouldJumpNearEnd = true,
					CameraYawOffset = -25,
					IsCheckpoint = true,
					Note = "Cruza a barra verde inicial e salta para o primeiro pilar a direita.",
				},
				{
					StepIndex = 2,
					Name = "Transicao Aerea Bloco Isolado",
					TargetTime = 1.769,
					RelativeOffset = Vector3.new(2, 4, -36),
					PlatformSize = Vector3.new(5, 1.5, 5),
					ShouldJumpOnStart = false,
					ShouldJumpNearEnd = true,
					CameraYawOffset = 15,
					IsCheckpoint = false,
					Note = "Salto imediato mantendo embalo sobre o segundo pilar quadrado a esquerda.",
				},
				{
					StepIndex = 3,
					Name = "Quina da Estrutura em L (Clean x5)",
					TargetTime = 2.769,
					RelativeOffset = Vector3.new(-10, 5, -52),
					PlatformSize = Vector3.new(10, 1.5, 8),
					ShouldJumpOnStart = false,
					ShouldJumpNearEnd = true,
					CameraYawOffset = -45,
					IsCheckpoint = true,
					Note = "Toca a quina direita da plataforma branca e redireciona para a viga estreita.",
				},
				{
					StepIndex = 4,
					Name = "Entrada na Viga Estreita (1 Stud)",
					TargetTime = 3.250,
					RelativeOffset = Vector3.new(-22, 6, -64),
					PlatformSize = Vector3.new(18, 1.2, 2.2),
					ShouldJumpOnStart = false,
					ShouldJumpNearEnd = false,
					CameraYawOffset = -90,
					IsCheckpoint = false,
					Note = "Aterrissa no inicio da passarela estreita horizontal.",
				},
				{
					StepIndex = 5,
					Name = "Corrida Lateral na Viga Estreita",
					TargetTime = 3.767,
					RelativeOffset = Vector3.new(-36, 6, -64),
					PlatformSize = Vector3.new(18, 1.2, 2.2),
					ShouldJumpOnStart = false,
					ShouldJumpNearEnd = true,
					CameraYawOffset = 0,
					IsCheckpoint = true,
					Note = "Percorre a passarela estreita para a esquerda sem desacelerar.",
				},
				{
					StepIndex = 6,
					Name = "Bloco Intermediario Norte",
					TargetTime = 4.762,
					RelativeOffset = Vector3.new(-36, 7, -82),
					PlatformSize = Vector3.new(5, 1.5, 5),
					ShouldJumpOnStart = false,
					ShouldJumpNearEnd = true,
					CameraYawOffset = 0,
					IsCheckpoint = false,
					Note = "Salto sobre o bloco quadrado intermediario rumo a passarela vertical.",
				},
				{
					StepIndex = 7,
					Name = "Viga Vertical e Pads Luminosos",
					TargetTime = 5.763,
					RelativeOffset = Vector3.new(-36, 9, -104),
					PlatformSize = Vector3.new(3.5, 1.5, 22),
					ShouldJumpOnStart = false,
					ShouldJumpNearEnd = true,
					CameraYawOffset = 35,
					IsCheckpoint = true,
					Note = "Avanca pela viga vertical ate os blocos iluminados no topo.",
				},
				{
					StepIndex = 8,
					Name = "Curva Aerea 90 Graus (Fantastic x6)",
					TargetTime = 6.763,
					RelativeOffset = Vector3.new(-52, 11, -118),
					PlatformSize = Vector3.new(12, 1.5, 6),
					ShouldJumpOnStart = false,
					ShouldJumpNearEnd = true,
					CameraYawOffset = 65,
					IsCheckpoint = false,
					Note = "Gira 90 graus para a esquerda saltando para a estrutura dobrada.",
				},
				{
					StepIndex = 9,
					Name = "Atalho Diagonal no Zigue-Zague (Awesome x7)",
					TargetTime = 7.764,
					RelativeOffset = Vector3.new(-68, 12, -132),
					PlatformSize = Vector3.new(10, 1.5, 10),
					ShouldJumpOnStart = false,
					ShouldJumpNearEnd = true,
					CameraYawOffset = 20,
					IsCheckpoint = true,
					Note = "Corta o caminho em zigue-zague saltando pelas quinas direitas.",
				},
				{
					StepIndex = 10,
					Name = "Micro-Pilares + Linha de Chegada (FULL COMBO)",
					TargetTime = 9.012,
					RelativeOffset = Vector3.new(-82, 13, -150),
					PlatformSize = Vector3.new(16, 2, 16),
					ShouldJumpOnStart = true,
					ShouldJumpNearEnd = false,
					CameraYawOffset = 0,
					IsCheckpoint = true,
					Note = "Transpõe os dois micro-blocos finais e cruza a barra verde em 9.012s.",
				},
			},
		},
	} :: {RouteData},
}

-- ============================================================================
-- 2. ESTADO DO SISTEMA, CONEXÕES E FUNÇÕES FISICAS LOCAIS
-- ============================================================================
local Settings = table.clone(Config.DefaultSettings)
local AvailableRoutes: {RouteData} = table.clone(Config.PreloadedRoutes)
local SelectedRouteIndex = 1

type AutoState = "IDLE" | "RUNNING" | "PAUSED" | "RECORDING"

local HubState = {
	IsOpen = true,
	ActiveTab = "HOME",
	ControlState = "IDLE" :: AutoState,
	CurrentStepIndex = 0,
	TotalSteps = #AvailableRoutes[1].Steps,
	SessionStartTime = os.clock(),
	RunStartTime = 0,
	PausedElapsedTime = 0,
	CurrentRunTime = 0,
	OriginCFrame = CFrame.identity,
	LastCheckpointCFrame = CFrame.identity,
	AttemptsCount = 0,
	CompletedCount = 0,
	BestRecordedTime = 0,
	RunHistory = {} :: {any},
	RecordedSteps = {} :: {RouteStep},
	RecordStartClock = 0,
}

local Connections: {RBXScriptConnection} = {}
local AutoLoopConnection: RBXScriptConnection? = nil

local function getCharacterComponents(): (Model?, Humanoid?, BasePart?)
	local character = LocalPlayer.Character
	if not character then
		return nil, nil, nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not humanoid or not rootPart or humanoid.Health <= 0 then
		return nil, nil, nil
	end
	return character, humanoid, rootPart
end

local function applyCharacterStats()
	local _, humanoid, _ = getCharacterComponents()
	if humanoid then
		humanoid.WalkSpeed = math.clamp(Settings.DefaultWalkSpeed, 8, 60)
		humanoid.UseJumpPower = true
		humanoid.JumpPower = math.clamp(Settings.DefaultJumpPower, 25, 100)
	end
end

local function teleportCharacterTo(targetCFrame: CFrame)
	local _, _, rootPart = getCharacterComponents()
	if rootPart then
		rootPart.AssemblyLinearVelocity = Vector3.zero
		rootPart.CFrame = targetCFrame
	end
end

local function checkEdgeOrObstacle(rootPart: BasePart, moveDirection: Vector3): (boolean, boolean)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {LocalPlayer.Character :: Instance}

	local forwardHit = workspace:Raycast(rootPart.Position, moveDirection.Unit * 3.5, rayParams)
	local hasObstacleAhead = forwardHit ~= nil

	local aheadOrigin = rootPart.Position + (moveDirection.Unit * 2.5)
	local groundAheadHit = workspace:Raycast(aheadOrigin, Vector3.new(0, -7, 0), rayParams)
	local isNearLedge = (groundAheadHit == nil)

	return hasObstacleAhead, isNearLedge
end

-- Constrói localmente no Workspace as 10 plataformas proporcionais ao vídeo
local function buildLocalPracticeCourse()
	local _, _, rootPart = getCharacterComponents()
	if not rootPart then
		return false
	end

	local existing = workspace:FindFirstChild("AnimeObbyHub_PracticeCourse")
	if existing then
		existing:Destroy()
	end

	local originCFrame = CFrame.new(rootPart.Position)
	HubState.OriginCFrame = originCFrame
	HubState.LastCheckpointCFrame = rootPart.CFrame

	local folder = Instance.new("Folder")
	folder.Name = "AnimeObbyHub_PracticeCourse"
	folder.Parent = workspace

	local startPad = Instance.new("Part")
	startPad.Name = "StartPlatform"
	startPad.Size = Vector3.new(16, 2, 16)
	startPad.Anchored = true
	startPad.Material = Enum.Material.SmoothPlastic
	startPad.Color = Color3.fromRGB(225, 232, 245)
	startPad.CFrame = originCFrame * CFrame.new(0, -3.2, 0)
	startPad.Parent = folder

	local startLine = Instance.new("Part")
	startLine.Name = "StartGreenBar"
	startLine.Size = Vector3.new(14, 0.4, 1.2)
	startLine.Anchored = true
	startLine.CanCollide = false
	startLine.Material = Enum.Material.Neon
	startLine.Color = Color3.fromRGB(40, 235, 95)
	startLine.CFrame = startPad.CFrame * CFrame.new(0, 1.1, -6)
	startLine.Parent = folder

	local route = AvailableRoutes[1]
	for _, step in ipairs(route.Steps) do
		local part = Instance.new("Part")
		part.Name = "Step_" .. tostring(step.StepIndex)
		part.Size = step.PlatformSize
		part.Anchored = true
		part.Material = Enum.Material.SmoothPlastic
		part.Color = step.IsCheckpoint and Color3.fromRGB(185, 220, 255) or Color3.fromRGB(235, 240, 250)
		part.CFrame = originCFrame * CFrame.new(step.RelativeOffset) * CFrame.new(0, -3.2, 0)
		part.Parent = folder

		if step.StepIndex == #route.Steps then
			local finishBar = Instance.new("Part")
			finishBar.Name = "FinishGreenBar"
			finishBar.Size = Vector3.new(14, 0.5, 1.2)
			finishBar.Anchored = true
			finishBar.CanCollide = false
			finishBar.Material = Enum.Material.Neon
			finishBar.Color = Color3.fromRGB(0, 255, 140)
			finishBar.CFrame = part.CFrame * CFrame.new(0, 1.2, 0)
			finishBar.Parent = folder
		end
	end

	return true
end

-- ============================================================================
-- 3. GERENCIADOR DE MÚSICA (SOUNDSERVICE)
-- ============================================================================
local HubMusic: Sound = SoundService:FindFirstChild("AnimeObbyHub_ThemeMusic") :: Sound
if not HubMusic then
	HubMusic = Instance.new("Sound")
	HubMusic.Name = "AnimeObbyHub_ThemeMusic"
	HubMusic.Looped = true
	HubMusic.Volume = Settings.MusicVolume
	HubMusic.Parent = SoundService
end

local function updateMusicPlayback()
	HubMusic.Volume = Settings.MusicVolume
	if Settings.MusicAssetId ~= "" and Settings.MusicEnabled and HubState.IsOpen then
		if HubMusic.SoundId ~= Settings.MusicAssetId then
			HubMusic.SoundId = Settings.MusicAssetId
		end
		if not HubMusic.IsPlaying then
			pcall(function()
				HubMusic:Play()
			end)
		end
	else
		if HubMusic.IsPlaying then
			HubMusic:Pause()
		end
	end
end

-- ============================================================================
-- 4. INTERFACE VISUAL PREMIUM (DARK GLASSMORPHISM + ANIME FUTURISTA)
-- ============================================================================
local OldGui = PlayerGui:FindFirstChild("AnimeObbyHub_ScreenGui")
if OldGui then
	OldGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AnimeObbyHub_ScreenGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local function playTween(instance: Instance, duration: number, goal: {[string]: any})
	if not Settings.AnimationsEnabled then
		for prop, val in pairs(goal) do
			(instance :: any)[prop] = val
		end
		return
	end
	local tween = TweenService:Create(
		instance,
		TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		goal
	)
	tween:Play()
end

-- Painel de Notificações Elegantes
local NotificationHolder = Instance.new("Frame")
NotificationHolder.Name = "NotificationHolder"
NotificationHolder.AnchorPoint = Vector2.new(1, 0)
NotificationHolder.Position = UDim2.new(1, -24, 0, 24)
NotificationHolder.Size = UDim2.new(0, 310, 0, 260)
NotificationHolder.BackgroundTransparency = 1
NotificationHolder.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
NotifLayout.Parent = NotificationHolder

local function sendNotification(titleText: string, bodyText: string, accentColor: Color3?)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 62)
	card.BackgroundColor3 = Config.Theme.BackgroundSecondary
	card.BackgroundTransparency = 0.08
	card.Parent = NotificationHolder

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = accentColor or Config.Theme.AccentPrimary
	stroke.Thickness = 1.2
	stroke.Transparency = 0.25
	stroke.Parent = card

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 3, 1, -14)
	bar.Position = UDim2.new(0, 8, 0, 7)
	bar.BackgroundColor3 = accentColor or Config.Theme.AccentPrimary
	bar.BorderSizePixel = 0
	bar.Parent = card

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -26, 0, 20)
	title.Position = UDim2.new(0, 18, 0, 8)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 13
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Config.Theme.TextPrimary
	title.Text = string.upper(titleText)
	title.Parent = card

	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(1, -26, 0, 28)
	desc.Position = UDim2.new(0, 18, 0, 28)
	desc.BackgroundTransparency = 1
	desc.Font = Enum.Font.Gotham
	desc.TextSize = 12
	desc.TextWrapped = true
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.TextColor3 = Config.Theme.TextSecondary
	desc.Text = bodyText
	desc.Parent = card

	task.delay(3.6, function()
		if card.Parent then
			playTween(card, 0.3, {BackgroundTransparency = 1})
			task.wait(0.32)
			if card.Parent then
				card:Destroy()
			end
		end
	end)
end

-- Botão Flutuante de Acesso Rápido (Suporte Total Mobile / iPad / Desktop)
local FloatingToggleBtn = Instance.new("TextButton")
FloatingToggleBtn.Name = "FloatingToggleBtn"
FloatingToggleBtn.AnchorPoint = Vector2.new(0, 0.5)
FloatingToggleBtn.Position = UDim2.new(0, 16, 0.5, 0)
FloatingToggleBtn.Size = UDim2.new(0, 118, 0, 38)
FloatingToggleBtn.BackgroundColor3 = Config.Theme.BackgroundSecondary
FloatingToggleBtn.BackgroundTransparency = 0.15
FloatingToggleBtn.Font = Enum.Font.GothamBold
FloatingToggleBtn.TextSize = 12
FloatingToggleBtn.TextColor3 = Config.Theme.AccentPrimary
FloatingToggleBtn.Text = "ANIME HUB"
FloatingToggleBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 8)
FloatCorner.Parent = FloatingToggleBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Config.Theme.AccentPrimary
FloatStroke.Thickness = 1.2
FloatStroke.Parent = FloatingToggleBtn

-- Janela Principal
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
MainWindow.Size = UDim2.new(0, 780, 0, 470)
MainWindow.BackgroundColor3 = Config.Theme.BackgroundPrimary
MainWindow.BackgroundTransparency = Settings.UIWindowTransparency
MainWindow.ClipsDescendants = true
MainWindow.Parent = ScreenGui

local WindowScale = Instance.new("UIScale")
WindowScale.Scale = Settings.UIScale
WindowScale.Parent = MainWindow

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainWindow

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Config.Theme.StrokeColor
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.2
MainStroke.Parent = MainWindow

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(185, 195, 235)),
})
MainGradient.Rotation = 35
MainGradient.Parent = MainWindow

-- Ilustração Anime de Fundo (Alinhada à Direita + Camada Escura de Legibilidade)
local BackgroundArt = Instance.new("ImageLabel")
BackgroundArt.Name = "BackgroundArt"
BackgroundArt.AnchorPoint = Vector2.new(1, 0.5)
BackgroundArt.Position = UDim2.new(1, 0, 0.5, 0)
BackgroundArt.Size = UDim2.new(0.55, 0, 1, 0)
BackgroundArt.BackgroundTransparency = 1
BackgroundArt.Image = Settings.BackgroundImageAssetId
BackgroundArt.ImageTransparency = 1 - Settings.BackgroundImageOpacity
BackgroundArt.ScaleType = Enum.ScaleType.Crop
BackgroundArt.ZIndex = 1
BackgroundArt.Parent = MainWindow

local DarkOverlay = Instance.new("Frame")
DarkOverlay.Name = "DarkReadabilityOverlay"
DarkOverlay.Size = UDim2.new(1, 0, 1, 0)
DarkOverlay.BackgroundColor3 = Config.Theme.BackgroundPrimary
DarkOverlay.BackgroundTransparency = 0.25
DarkOverlay.ZIndex = 2
DarkOverlay.Parent = MainWindow

local OverlayGradient = Instance.new("UIGradient")
OverlayGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.05),
	NumberSequenceKeypoint.new(0.65, 0.25),
	NumberSequenceKeypoint.new(1, 0.55),
})
OverlayGradient.Parent = DarkOverlay

-- Cabeçalho Arrastável
local HeaderBar = Instance.new("Frame")
HeaderBar.Name = "HeaderBar"
HeaderBar.Size = UDim2.new(1, 0, 0, 54)
HeaderBar.BackgroundColor3 = Config.Theme.BackgroundSecondary
HeaderBar.BackgroundTransparency = 0.2
HeaderBar.ZIndex = 3
HeaderBar.Parent = MainWindow

local HeaderStroke = Instance.new("UIStroke")
HeaderStroke.Color = Config.Theme.StrokeColor
HeaderStroke.Thickness = 1
HeaderStroke.Transparency = 0.55
HeaderStroke.Parent = HeaderBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 280, 0, 24)
TitleLabel.Position = UDim2.new(0, 22, 0, 8)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 17
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextColor3 = Config.Theme.TextPrimary
TitleLabel.Text = Config.HubInfo.Name
TitleLabel.ZIndex = 4
TitleLabel.Parent = HeaderBar

local SubtitleLabel = Instance.new("TextLabel")
SubtitleLabel.Size = UDim2.new(0, 320, 0, 16)
SubtitleLabel.Position = UDim2.new(0, 22, 0, 30)
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Font = Enum.Font.GothamMedium
SubtitleLabel.TextSize = 11
SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
SubtitleLabel.TextColor3 = Config.Theme.AccentPrimary
SubtitleLabel.Text = Config.HubInfo.Subtitle
SubtitleLabel.ZIndex = 4
SubtitleLabel.Parent = HeaderBar

local StatusBadge = Instance.new("TextLabel")
StatusBadge.Size = UDim2.new(0, 130, 0, 26)
StatusBadge.AnchorPoint = Vector2.new(1, 0.5)
StatusBadge.Position = UDim2.new(1, -64, 0.5, 0)
StatusBadge.BackgroundColor3 = Config.Theme.PanelGlass
StatusBadge.BackgroundTransparency = 0.15
StatusBadge.Font = Enum.Font.GothamBold
StatusBadge.TextSize = 11
StatusBadge.TextColor3 = Config.Theme.AccentPrimary
StatusBadge.Text = "STATE: IDLE"
StatusBadge.ZIndex = 4
StatusBadge.Parent = HeaderBar

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, 6)
BadgeCorner.Parent = StatusBadge

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 34, 0, 26)
CloseBtn.AnchorPoint = Vector2.new(1, 0.5)
CloseBtn.Position = UDim2.new(1, -18, 0.5, 0)
CloseBtn.BackgroundColor3 = Config.Theme.PanelGlass
CloseBtn.BackgroundTransparency = 0.2
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.TextColor3 = Config.Theme.TextSecondary
CloseBtn.Text = "X"
CloseBtn.ZIndex = 4
CloseBtn.Parent = HeaderBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Suporte para Arrastar Janela (Mouse e Toque)
do
	local dragging = false
	local dragStart = Vector2.zero
	local startPos = UDim2.new()

	table.insert(Connections, HeaderBar.InputBegan:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = Vector2.new(input.Position.X, input.Position.Y)
			startPos = MainWindow.Position
		end
	end))

	table.insert(Connections, UserInputService.InputChanged:Connect(function(input: InputObject)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
			MainWindow.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end))

	table.insert(Connections, UserInputService.InputEnded:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))
end

-- Barra Lateral e Páginas das Abas
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Position = UDim2.new(0, 14, 0, 66)
Sidebar.Size = UDim2.new(0, 170, 1, -80)
Sidebar.BackgroundColor3 = Config.Theme.BackgroundSecondary
Sidebar.BackgroundTransparency = 0.25
Sidebar.ZIndex = 3
Sidebar.Parent = MainWindow

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 10)
SidebarCorner.Parent = Sidebar

local SidebarStroke = Instance.new("UIStroke")
SidebarStroke.Color = Config.Theme.StrokeColor
SidebarStroke.Thickness = 1
SidebarStroke.Transparency = 0.5
SidebarStroke.Parent = Sidebar

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 8)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarList.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 12)
SidebarPadding.Parent = Sidebar

local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Position = UDim2.new(0, 198, 0, 66)
ContentContainer.Size = UDim2.new(1, -212, 1, -80)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ZIndex = 3
ContentContainer.Parent = MainWindow

local TabPages: {[string]: ScrollingFrame} = {}
local TabButtons: {[string]: TextButton} = {}
local TabNames = {"HOME", "AUTO CONTROL", "ROUTES", "ANALYTICS", "SETTINGS"}

local function switchTab(tabName: string)
	HubState.ActiveTab = tabName
	for name, page in pairs(TabPages) do
		page.Visible = (name == tabName)
	end
	for name, btn in pairs(TabButtons) do
		local isSelected = (name == tabName)
		playTween(btn, 0.2, {
			BackgroundColor3 = isSelected and Config.Theme.AccentPrimary or Config.Theme.PanelGlass,
			BackgroundTransparency = isSelected and 0.12 or 0.45,
			TextColor3 = isSelected and Config.Theme.BackgroundPrimary or Config.Theme.TextPrimary,
		})
	end
end

for _, tabName in ipairs(TabNames) do
	local btn = Instance.new("TextButton")
	btn.Name = tabName .. "_TabBtn"
	btn.Size = UDim2.new(1, -20, 0, 38)
	btn.BackgroundColor3 = Config.Theme.PanelGlass
	btn.BackgroundTransparency = 0.45
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.TextColor3 = Config.Theme.TextPrimary
	btn.Text = tabName
	btn.ZIndex = 4
	btn.Parent = Sidebar

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = btn

	local page = Instance.new("ScrollingFrame")
	page.Name = tabName .. "_Page"
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 4
	page.ScrollBarImageColor3 = Config.Theme.AccentPrimary
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.ZIndex = 4
	page.Parent = ContentContainer

	local pageLayout = Instance.new("UIListLayout")
	pageLayout.Padding = UDim.new(0, 10)
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Parent = page

	local pagePad = Instance.new("UIPadding")
	pagePad.PaddingRight = UDim.new(0, 8)
	pagePad.PaddingBottom = UDim.new(0, 12)
	pagePad.Parent = page

	TabButtons[tabName] = btn
	TabPages[tabName] = page

	btn.MouseButton1Click:Connect(function()
		switchTab(tabName)
	end)
end

local function createCard(parent: Instance, titleText: string, height: number, order: number): Frame
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, height)
	card.LayoutOrder = order
	card.BackgroundColor3 = Config.Theme.PanelGlass
	card.BackgroundTransparency = 0.25
	card.ZIndex = 4
	card.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 9)
	corner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = Config.Theme.StrokeColor
	stroke.Thickness = 1
	stroke.Transparency = 0.45
	stroke.Parent = card

	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, -24, 0, 22)
	header.Position = UDim2.new(0, 14, 0, 10)
	header.BackgroundTransparency = 1
	header.Font = Enum.Font.GothamBold
	header.TextSize = 13
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.TextColor3 = Config.Theme.AccentPrimary
	header.Text = string.upper(titleText)
	header.ZIndex = 5
	header.Parent = card

	return card
end

local function createActionButton(parent: Instance, label: string, pos: UDim2, size: UDim2, accent: Color3, callback: () -> ()): TextButton
	local btn = Instance.new("TextButton")
	btn.Position = pos
	btn.Size = size
	btn.BackgroundColor3 = accent
	btn.BackgroundTransparency = 0.15
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.TextColor3 = Config.Theme.BackgroundPrimary
	btn.Text = label
	btn.ZIndex = 5
	btn.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		playTween(btn, 0.12, {BackgroundTransparency = 0.4})
		task.delay(0.12, function()
			playTween(btn, 0.15, {BackgroundTransparency = 0.15})
		end)
		callback()
	end)

	return btn
end

-- ============================================================================
-- 5. MOTOR DE EXECUÇÃO DO AUTO CONTROL
-- ============================================================================
local RefreshRoutesUI: () -> () = function() end
local RefreshAnalyticsUI: () -> () = function() end

local function stopAutoControl(reason: string?)
	if AutoLoopConnection then
		AutoLoopConnection:Disconnect()
		AutoLoopConnection = nil
	end
	HubState.ControlState = "IDLE"
	StatusBadge.Text = "STATE: IDLE"
	StatusBadge.TextColor3 = Config.Theme.AccentPrimary

	local _, humanoid, _ = getCharacterComponents()
	if humanoid then
		humanoid:Move(Vector3.zero, false)
	end

	if reason then
		sendNotification("Auto Control", reason, Config.Theme.AccentWarning)
	end
end

local function startAutoControl()
	local _, humanoid, rootPart = getCharacterComponents()
	if not humanoid or not rootPart then
		sendNotification("Erro de Personagem", "Aguarde o carregamento do personagem e Humanoid.", Config.Theme.AccentDanger)
		return
	end

	if AutoLoopConnection then
		AutoLoopConnection:Disconnect()
		AutoLoopConnection = nil
	end

	local activeRoute = AvailableRoutes[SelectedRouteIndex]
	if not activeRoute or #activeRoute.Steps == 0 then
		sendNotification("Rota Invalida", "Selecione uma rota valida com etapas configuradas.", Config.Theme.AccentDanger)
		return
	end

	if HubState.OriginCFrame == CFrame.identity then
		HubState.OriginCFrame = CFrame.new(rootPart.Position)
	end
	HubState.LastCheckpointCFrame = rootPart.CFrame
	HubState.CurrentStepIndex = 1
	HubState.TotalSteps = #activeRoute.Steps
	HubState.RunStartTime = os.clock()
	HubState.CurrentRunTime = 0
	HubState.ControlState = "RUNNING"

	StatusBadge.Text = "STATE: RUNNING"
	StatusBadge.TextColor3 = Config.Theme.AccentSuccess

	applyCharacterStats()

	local stepJumpTriggered = false
	sendNotification("Auto Control Iniciado", "Executando: " .. activeRoute.Title, Config.Theme.AccentSuccess)

	AutoLoopConnection = RunService.Heartbeat:Connect(function()
		if HubState.ControlState ~= "RUNNING" then
			return
		end

		local _, hum, root = getCharacterComponents()
		if not hum or not root then
			stopAutoControl("Personagem reiniciado durante o percurso.")
			return
		end

		HubState.CurrentRunTime = os.clock() - HubState.RunStartTime
		local currentStep = activeRoute.Steps[HubState.CurrentStepIndex]
		if not currentStep then
			return
		end

		local targetWorldPos = (HubState.OriginCFrame * CFrame.new(currentStep.RelativeOffset)).Position

		-- Recuperação automática após queda (Auto Recovery)
		if Settings.AutoRecovery and (root.Position.Y < (targetWorldPos.Y - 18)) then
			teleportCharacterTo(HubState.LastCheckpointCFrame + Vector3.new(0, 3, 0))
			sendNotification("Recuperacao Ativa", "Retornando ao ultimo checkpoint seguro.", Config.Theme.AccentWarning)
			return
		end

		local flatDelta = Vector3.new(targetWorldPos.X - root.Position.X, 0, targetWorldPos.Z - root.Position.Z)
		local distance = flatDelta.Magnitude

		if currentStep.ShouldJumpOnStart and not stepJumpTriggered then
			hum.Jump = true
			stepJumpTriggered = true
		end

		if distance > 0.2 then
			local moveUnit = flatDelta.Unit
			local hasObstacle, isNearLedge = checkEdgeOrObstacle(root, moveUnit)
			if hasObstacle or (isNearLedge and currentStep.ShouldJumpNearEnd and distance < 14) then
				hum.Jump = true
			end
			hum:Move(moveUnit, false)
		end

		if distance <= Settings.WaypointPrecision then
			if currentStep.IsCheckpoint then
				HubState.LastCheckpointCFrame = CFrame.new(targetWorldPos + Vector3.new(0, 3, 0))
			end

			if HubState.CurrentStepIndex < #activeRoute.Steps then
				HubState.CurrentStepIndex += 1
				stepJumpTriggered = false
			else
				local finalTime = os.clock() - HubState.RunStartTime
				HubState.CurrentRunTime = finalTime
				HubState.AttemptsCount += 1
				HubState.CompletedCount += 1

				if HubState.BestRecordedTime == 0 or finalTime < HubState.BestRecordedTime then
					HubState.BestRecordedTime = finalTime
				end

				local entry = {
					RouteTitle = activeRoute.Title,
					RunTime = finalTime,
					Completed = true,
					StepsDone = #activeRoute.Steps,
					TotalSteps = #activeRoute.Steps,
					Timestamp = os.date("%H:%M:%S"),
				}
				table.insert(HubState.RunHistory, 1, entry)

				stopAutoControl(string.format("Percurso concluido em %.3fs!", finalTime))
				RefreshRoutesUI()
				RefreshAnalyticsUI()
			end
		end
	end)
end

local function pauseAutoControl()
	if HubState.ControlState == "RUNNING" then
		HubState.ControlState = "PAUSED"
		HubState.PausedElapsedTime = HubState.CurrentRunTime
		StatusBadge.Text = "STATE: PAUSED"
		StatusBadge.TextColor3 = Config.Theme.AccentWarning
		local _, hum, _ = getCharacterComponents()
		if hum then
			hum:Move(Vector3.zero, false)
		end
		sendNotification("Sistema Pausado", "Execucao suspensa na etapa " .. tostring(HubState.CurrentStepIndex), Config.Theme.AccentWarning)
	end
end

local function resumeAutoControl()
	if HubState.ControlState == "PAUSED" then
		HubState.RunStartTime = os.clock() - HubState.PausedElapsedTime
		HubState.ControlState = "RUNNING"
		StatusBadge.Text = "STATE: RUNNING"
		StatusBadge.TextColor3 = Config.Theme.AccentSuccess
		sendNotification("Execucao Retomada", "Continuando percurso da etapa " .. tostring(HubState.CurrentStepIndex), Config.Theme.AccentSuccess)
	end
end

local function restartAutoControl()
	stopAutoControl()
	if HubState.OriginCFrame ~= CFrame.identity then
		teleportCharacterTo(HubState.OriginCFrame + Vector3.new(0, 3, 0))
	end
	task.wait(0.15)
	startAutoControl()
end

-- ============================================================================
-- 6. CONSTRUÇÃO DAS 5 ABAS (HOME, AUTO CONTROL, ROUTES, ANALYTICS, SETTINGS)
-- ============================================================================

-- ABA 1: HOME
local HomePage = TabPages["HOME"]
local HomeHeroCard = createCard(HomePage, "Visao Geral do Sistema // " .. Config.HubInfo.Version, 118, 1)

local HeroDesc = Instance.new("TextLabel")
HeroDesc.Size = UDim2.new(1, -28, 0, 42)
HeroDesc.Position = UDim2.new(0, 14, 0, 36)
HeroDesc.BackgroundTransparency = 1
HeroDesc.Font = Enum.Font.Gotham
HeroDesc.TextSize = 12
HeroDesc.TextWrapped = true
HeroDesc.TextXAlignment = Enum.TextXAlignment.Left
HeroDesc.TextColor3 = Config.Theme.TextSecondary
HeroDesc.Text = "Sistema unificado de automacao e reproducao de percursos de Obby. Gere a pista de 10 etapas extraida do video (9.012s) ou grave suas proprias rotas."
HeroDesc.ZIndex = 5
HeroDesc.Parent = HomeHeroCard

createActionButton(
	HomeHeroCard,
	"GERAR PISTA DE TREINO DO VIDEO NO MAPA",
	UDim2.new(0, 14, 0, 80),
	UDim2.new(0, 290, 0, 28),
	Config.Theme.AccentPrimary,
	function()
		if buildLocalPracticeCourse() then
			sendNotification("Pista Gerada", "As 10 plataformas proporcionais ao video foram criadas a sua frente.", Config.Theme.AccentSuccess)
		end
	end
)

local HomeTelemetryCard = createCard(HomePage, "Telemetria em Tempo Real", 150, 2)

local HomeStateLabel = Instance.new("TextLabel")
HomeStateLabel.Size = UDim2.new(0.5, -20, 0, 22)
HomeStateLabel.Position = UDim2.new(0, 14, 0, 40)
HomeStateLabel.BackgroundTransparency = 1
HomeStateLabel.Font = Enum.Font.GothamMedium
HomeStateLabel.TextSize = 13
HomeStateLabel.TextXAlignment = Enum.TextXAlignment.Left
HomeStateLabel.TextColor3 = Config.Theme.TextPrimary
HomeStateLabel.Text = "Estado do Auto Control: IDLE"
HomeStateLabel.ZIndex = 5
HomeStateLabel.Parent = HomeTelemetryCard

local HomeStepLabel = Instance.new("TextLabel")
HomeStepLabel.Size = UDim2.new(0.5, -20, 0, 22)
HomeStepLabel.Position = UDim2.new(0, 14, 0, 66)
HomeStepLabel.BackgroundTransparency = 1
HomeStepLabel.Font = Enum.Font.GothamMedium
HomeStepLabel.TextSize = 13
HomeStepLabel.TextXAlignment = Enum.TextXAlignment.Left
HomeStepLabel.TextColor3 = Config.Theme.TextPrimary
HomeStepLabel.Text = "Progresso da Etapa: 0 / 10 (0%)"
HomeStepLabel.ZIndex = 5
HomeStepLabel.Parent = HomeTelemetryCard

local HomeRunTimerLabel = Instance.new("TextLabel")
HomeRunTimerLabel.Size = UDim2.new(0.5, -20, 0, 22)
HomeRunTimerLabel.Position = UDim2.new(0.5, 0, 0, 40)
HomeRunTimerLabel.BackgroundTransparency = 1
HomeRunTimerLabel.Font = Enum.Font.GothamBold
HomeRunTimerLabel.TextSize = 13
HomeRunTimerLabel.TextXAlignment = Enum.TextXAlignment.Left
HomeRunTimerLabel.TextColor3 = Config.Theme.AccentSuccess
HomeRunTimerLabel.Text = "Cronometro do Percurso: 0.000s"
HomeRunTimerLabel.ZIndex = 5
HomeRunTimerLabel.Parent = HomeTelemetryCard

local HomeSessionLabel = Instance.new("TextLabel")
HomeSessionLabel.Size = UDim2.new(0.5, -20, 0, 22)
HomeSessionLabel.Position = UDim2.new(0.5, 0, 0, 66)
HomeSessionLabel.BackgroundTransparency = 1
HomeSessionLabel.Font = Enum.Font.GothamMedium
HomeSessionLabel.TextSize = 13
HomeSessionLabel.TextXAlignment = Enum.TextXAlignment.Left
HomeSessionLabel.TextColor3 = Config.Theme.TextSecondary
HomeSessionLabel.Text = "Tempo da Sessao: 00:00"
HomeSessionLabel.ZIndex = 5
HomeSessionLabel.Parent = HomeTelemetryCard

local ProgressBarBg = Instance.new("Frame")
ProgressBarBg.Size = UDim2.new(1, -28, 0, 12)
ProgressBarBg.Position = UDim2.new(0, 14, 0, 112)
ProgressBarBg.BackgroundColor3 = Config.Theme.BackgroundPrimary
ProgressBarBg.ZIndex = 5
ProgressBarBg.Parent = HomeTelemetryCard

local ProgBgCorner = Instance.new("UICorner")
ProgBgCorner.CornerRadius = UDim.new(1, 0)
ProgBgCorner.Parent = ProgressBarBg

local ProgressBarFill = Instance.new("Frame")
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = Config.Theme.AccentPrimary
ProgressBarFill.ZIndex = 6
ProgressBarFill.Parent = ProgressBarBg

local ProgFillCorner = Instance.new("UICorner")
ProgFillCorner.CornerRadius = UDim.new(1, 0)
ProgFillCorner.Parent = ProgressBarFill

-- ABA 2: AUTO CONTROL
local AutoPage = TabPages["AUTO CONTROL"]
local ControlsCard = createCard(AutoPage, "Painel de Comando do Auto Control", 110, 1)

createActionButton(ControlsCard, "INICIAR", UDim2.new(0, 14, 0, 42), UDim2.new(0, 98, 0, 34), Config.Theme.AccentSuccess, startAutoControl)
createActionButton(ControlsCard, "PAUSAR", UDim2.new(0, 120, 0, 42), UDim2.new(0, 98, 0, 34), Config.Theme.AccentWarning, pauseAutoControl)
createActionButton(ControlsCard, "CONTINUAR", UDim2.new(0, 226, 0, 42), UDim2.new(0, 106, 0, 34), Config.Theme.AccentPrimary, resumeAutoControl)
createActionButton(ControlsCard, "PARAR", UDim2.new(0, 340, 0, 42), UDim2.new(0, 94, 0, 34), Config.Theme.AccentDanger, function()
	stopAutoControl("Execucao interrompida manualmente.")
end)
createActionButton(ControlsCard, "REINICIAR", UDim2.new(0, 442, 0, 42), UDim2.new(0, 102, 0, 34), Config.Theme.AccentSecondary, restartAutoControl)

local ParamsCard = createCard(AutoPage, "Ajuste de Velocidade, Precisao e Selecao de Percurso", 195, 2)

local SpeedValueLabel = Instance.new("TextLabel")
SpeedValueLabel.Size = UDim2.new(0, 240, 0, 24)
SpeedValueLabel.Position = UDim2.new(0, 14, 0, 40)
SpeedValueLabel.BackgroundTransparency = 1
SpeedValueLabel.Font = Enum.Font.GothamMedium
SpeedValueLabel.TextSize = 13
SpeedValueLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedValueLabel.TextColor3 = Config.Theme.TextPrimary
SpeedValueLabel.Text = "WalkSpeed Configurada: " .. tostring(Settings.DefaultWalkSpeed)
SpeedValueLabel.ZIndex = 5
SpeedValueLabel.Parent = ParamsCard

createActionButton(ParamsCard, "- VEL", UDim2.new(0, 260, 0, 38), UDim2.new(0, 68, 0, 26), Config.Theme.StrokeColor, function()
	Settings.DefaultWalkSpeed = math.max(12, Settings.DefaultWalkSpeed - 2)
	SpeedValueLabel.Text = "WalkSpeed Configurada: " .. tostring(Settings.DefaultWalkSpeed)
	applyCharacterStats()
end)

createActionButton(ParamsCard, "+ VEL", UDim2.new(0, 336, 0, 38), UDim2.new(0, 68, 0, 26), Config.Theme.AccentPrimary, function()
	Settings.DefaultWalkSpeed = math.min(50, Settings.DefaultWalkSpeed + 2)
	SpeedValueLabel.Text = "WalkSpeed Configurada: " .. tostring(Settings.DefaultWalkSpeed)
	applyCharacterStats()
end)

local PrecisionValueLabel = Instance.new("TextLabel")
PrecisionValueLabel.Size = UDim2.new(0, 240, 0, 24)
PrecisionValueLabel.Position = UDim2.new(0, 14, 0, 76)
PrecisionValueLabel.BackgroundTransparency = 1
PrecisionValueLabel.Font = Enum.Font.GothamMedium
PrecisionValueLabel.TextSize = 13
PrecisionValueLabel.TextXAlignment = Enum.TextXAlignment.Left
PrecisionValueLabel.TextColor3 = Config.Theme.TextPrimary
PrecisionValueLabel.Text = string.format("Tolerancia de Waypoint: %.1f studs", Settings.WaypointPrecision)
PrecisionValueLabel.ZIndex = 5
PrecisionValueLabel.Parent = ParamsCard

createActionButton(ParamsCard, "- PREC", UDim2.new(0, 260, 0, 74), UDim2.new(0, 68, 0, 26), Config.Theme.StrokeColor, function()
	Settings.WaypointPrecision = math.max(1.2, Settings.WaypointPrecision - 0.4)
	PrecisionValueLabel.Text = string.format("Tolerancia de Waypoint: %.1f studs", Settings.WaypointPrecision)
end)

createActionButton(ParamsCard, "+ PREC", UDim2.new(0, 336, 0, 74), UDim2.new(0, 68, 0, 26), Config.Theme.AccentPrimary, function()
	Settings.WaypointPrecision = math.min(6.0, Settings.WaypointPrecision + 0.4)
	PrecisionValueLabel.Text = string.format("Tolerancia de Waypoint: %.1f studs", Settings.WaypointPrecision)
end)

local SelectedRouteLabel = Instance.new("TextLabel")
SelectedRouteLabel.Size = UDim2.new(1, -28, 0, 22)
SelectedRouteLabel.Position = UDim2.new(0, 14, 0, 114)
SelectedRouteLabel.BackgroundTransparency = 1
SelectedRouteLabel.Font = Enum.Font.GothamBold
SelectedRouteLabel.TextSize = 12
SelectedRouteLabel.TextXAlignment = Enum.TextXAlignment.Left
SelectedRouteLabel.TextColor3 = Config.Theme.AccentPrimary
SelectedRouteLabel.Text = "Percurso Ativo: " .. AvailableRoutes[SelectedRouteIndex].Title
SelectedRouteLabel.ZIndex = 5
SelectedRouteLabel.Parent = ParamsCard

createActionButton(ParamsCard, "ALTERNAR ROTA SELECIONADA", UDim2.new(0, 14, 0, 144), UDim2.new(0, 220, 0, 30), Config.Theme.AccentSecondary, function()
	SelectedRouteIndex = (SelectedRouteIndex % #AvailableRoutes) + 1
	SelectedRouteLabel.Text = "Percurso Ativo: " .. AvailableRoutes[SelectedRouteIndex].Title
	HubState.TotalSteps = #AvailableRoutes[SelectedRouteIndex].Steps
	sendNotification("Rota Selecionada", AvailableRoutes[SelectedRouteIndex].Title, Config.Theme.AccentPrimary)
	RefreshRoutesUI()
end)

createActionButton(ParamsCard, "GRAVAR / SALVAR WAYPOINT ATUAL", UDim2.new(0, 246, 0, 144), UDim2.new(0, 260, 0, 30), Config.Theme.AccentSuccess, function()
	local _, _, root = getCharacterComponents()
	if not root then
		return
	end
	if HubState.ControlState ~= "RECORDING" then
		HubState.ControlState = "RECORDING"
		HubState.OriginCFrame = CFrame.new(root.Position)
		HubState.RecordedSteps = {}
		HubState.RecordStartClock = os.clock()
		sendNotification("Gravacao Iniciada", "Caminhe pelo mapa e clique novamente neste botao em cada plataforma.", Config.Theme.AccentSuccess)
	else
		local idx = #HubState.RecordedSteps + 1
		local relOffset = HubState.OriginCFrame:PointToObjectSpace(root.Position)
		table.insert(HubState.RecordedSteps, {
			StepIndex = idx,
			Name = "Waypoint Gravado #" .. tostring(idx),
			TargetTime = os.clock() - HubState.RecordStartClock,
			RelativeOffset = relOffset,
			PlatformSize = Vector3.new(6, 1.5, 6),
			ShouldJumpOnStart = false,
			ShouldJumpNearEnd = true,
			CameraYawOffset = 0,
			IsCheckpoint = (idx % 2 == 0),
			Note = "Ponto capturado manualmente no ambiente de teste.",
		})
		sendNotification("Waypoint #" .. tostring(idx) .. " Salvo", "Ponto adicionado a rota customizada.", Config.Theme.AccentPrimary)
	end
end)

-- ABA 3: ROUTES
local RoutesPage = TabPages["ROUTES"]
local RouteSummaryCard = createCard(RoutesPage, "Percursos Disponiveis e Checkpoints", 105, 1)

local RouteMetaLabel = Instance.new("TextLabel")
RouteMetaLabel.Size = UDim2.new(1, -28, 0, 38)
RouteMetaLabel.Position = UDim2.new(0, 14, 0, 34)
RouteMetaLabel.BackgroundTransparency = 1
RouteMetaLabel.Font = Enum.Font.Gotham
RouteMetaLabel.TextSize = 12
RouteMetaLabel.TextWrapped = true
RouteMetaLabel.TextXAlignment = Enum.TextXAlignment.Left
RouteMetaLabel.TextColor3 = Config.Theme.TextSecondary
RouteMetaLabel.ZIndex = 5
RouteMetaLabel.Parent = RouteSummaryCard

createActionButton(RouteSummaryCard, "FINALIZAR GRAVACAO COMO NOVA ROTA", UDim2.new(0, 14, 0, 72), UDim2.new(0, 260, 0, 24), Config.Theme.AccentPrimary, function()
	if #HubState.RecordedSteps == 0 then
		sendNotification("Aviso", "Grave ao menos 1 waypoint na aba Auto Control primeiro.", Config.Theme.AccentWarning)
		return
	end
	HubState.ControlState = "IDLE"
	local newRoute: RouteData = {
		Id = "custom_" .. tostring(#AvailableRoutes + 1),
		Title = "Rota Customizada #" .. tostring(#AvailableRoutes),
		Description = "Percurso gravado diretamente no seu mapa de teste.",
		BenchmarkTime = HubState.RecordedSteps[#HubState.RecordedSteps].TargetTime,
		PreviousPB = 0,
		Steps = table.clone(HubState.RecordedSteps),
	}
	table.insert(AvailableRoutes, newRoute)
	SelectedRouteIndex = #AvailableRoutes
	SelectedRouteLabel.Text = "Percurso Ativo: " .. newRoute.Title
	RefreshRoutesUI()
	sendNotification("Nova Rota Criada", newRoute.Title .. " pronta para execucao.", Config.Theme.AccentSuccess)
end)

local StepsListCard = createCard(RoutesPage, "Detalhamento das Etapas e Tempos do Video", 340, 2)
local StepsContainer = Instance.new("Frame")
StepsContainer.Size = UDim2.new(1, -24, 1, -44)
StepsContainer.Position = UDim2.new(0, 12, 0, 36)
StepsContainer.BackgroundTransparency = 1
StepsContainer.ZIndex = 5
StepsContainer.Parent = StepsListCard

local StepsLayout = Instance.new("UIListLayout")
StepsLayout.Padding = UDim.new(0, 4)
StepsLayout.Parent = StepsContainer

RefreshRoutesUI = function()
	for _, child in ipairs(StepsContainer:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local route = AvailableRoutes[SelectedRouteIndex]
	RouteMetaLabel.Text = string.format(
		"%s | Etapas: %d | Tempo de Referencia do Video: %.3fs (PB Anterior: %.3fs)",
		route.Title,
		#route.Steps,
		route.BenchmarkTime,
		route.PreviousPB
	)

	StepsListCard.Size = UDim2.new(1, 0, 0, 52 + (#route.Steps * 30))

	for _, step in ipairs(route.Steps) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 26)
		row.BackgroundColor3 = Config.Theme.BackgroundPrimary
		row.BackgroundTransparency = 0.35
		row.ZIndex = 5
		row.Parent = StepsContainer

		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 5)
		c.Parent = row

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -110, 1, 0)
		lbl.Position = UDim2.new(0, 10, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextSize = 11
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextColor3 = Config.Theme.TextPrimary
		lbl.Text = string.format(
			"[%02d] %s | Tempo Alvo: %.3fs | %s",
			step.StepIndex,
			step.Name,
			step.TargetTime,
			step.IsCheckpoint and "CHECKPOINT" or "TRANSICAO"
		)
		lbl.ZIndex = 6
		lbl.Parent = row

		createActionButton(row, "IR", UDim2.new(1, -54, 0, 3), UDim2.new(0, 46, 0, 20), Config.Theme.AccentPrimary, function()
			if HubState.OriginCFrame == CFrame.identity then
				local _, _, root = getCharacterComponents()
				if root then
					HubState.OriginCFrame = CFrame.new(root.Position)
				end
			end
			local targetCF = HubState.OriginCFrame * CFrame.new(step.RelativeOffset + Vector3.new(0, 3, 0))
			teleportCharacterTo(targetCF)
			sendNotification("Checkpoint", "Teleportado para Etapa " .. tostring(step.StepIndex), Config.Theme.AccentPrimary)
		end)
	end
end

-- ABA 4: ANALYTICS
local AnalyticsPage = TabPages["ANALYTICS"]
local MetricsCard = createCard(AnalyticsPage, "Comparativo de Desempenho vs Video Oficial (9.012s)", 115, 1)

local AnalyticsSummaryLabel = Instance.new("TextLabel")
AnalyticsSummaryLabel.Size = UDim2.new(1, -28, 0, 68)
AnalyticsSummaryLabel.Position = UDim2.new(0, 14, 0, 36)
AnalyticsSummaryLabel.BackgroundTransparency = 1
AnalyticsSummaryLabel.Font = Enum.Font.GothamMedium
AnalyticsSummaryLabel.TextSize = 13
AnalyticsSummaryLabel.TextWrapped = true
AnalyticsSummaryLabel.TextXAlignment = Enum.TextXAlignment.Left
AnalyticsSummaryLabel.TextColor3 = Config.Theme.TextPrimary
AnalyticsSummaryLabel.ZIndex = 5
AnalyticsSummaryLabel.Parent = MetricsCard

local HistoryCard = createCard(AnalyticsPage, "Historico de Testes da Sessao", 240, 2)
local HistoryContainer = Instance.new("Frame")
HistoryContainer.Size = UDim2.new(1, -24, 1, -44)
HistoryContainer.Position = UDim2.new(0, 12, 0, 36)
HistoryContainer.BackgroundTransparency = 1
HistoryContainer.ZIndex = 5
HistoryContainer.Parent = HistoryCard

local HistoryLayout = Instance.new("UIListLayout")
HistoryLayout.Padding = UDim.new(0, 4)
HistoryLayout.Parent = HistoryContainer

RefreshAnalyticsUI = function()
	local bestStr = HubState.BestRecordedTime > 0 and string.format("%.3fs", HubState.BestRecordedTime) or "Sem registro"
	local diffStr = "N/A"
	if HubState.BestRecordedTime > 0 then
		local delta = HubState.BestRecordedTime - Config.HubInfo.ReferenceRecordTime
		diffStr = (delta <= 0 and string.format("%.3fs", delta) or string.format("+%.3fs", delta))
	end

	AnalyticsSummaryLabel.Text = string.format(
		"Tentativas Totais: %d   |   Execucoes Concluidas: %d\nMelhor Tempo no Studio: %s   |   Referencia do Video (WR): 9.012s   |   Diferenca: %s",
		HubState.AttemptsCount,
		HubState.CompletedCount,
		bestStr,
		diffStr
	)

	for _, child in ipairs(HistoryContainer:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	if #HubState.RunHistory == 0 then
		local empty = Instance.new("TextLabel")
		empty.Size = UDim2.new(1, 0, 0, 24)
		empty.BackgroundTransparency = 1
		empty.Font = Enum.Font.Gotham
		empty.TextSize = 12
		empty.TextXAlignment = Enum.TextXAlignment.Left
		empty.TextColor3 = Config.Theme.TextMuted
		empty.Text = "Nenhuma tentativa finalizada nesta sessao."
		empty.ZIndex = 5
		empty.Parent = HistoryContainer
		return
	end

	for idx, item in ipairs(HubState.RunHistory) do
		if idx > 7 then
			break
		end
		local line = Instance.new("TextLabel")
		line.Size = UDim2.new(1, 0, 0, 22)
		line.BackgroundTransparency = 1
		line.Font = Enum.Font.Gotham
		line.TextSize = 12
		line.TextXAlignment = Enum.TextXAlignment.Left
		line.TextColor3 = Config.Theme.TextSecondary
		line.Text = string.format(
			"[%s] %s — Tempo: %.3fs — Etapas: %d/%d",
			tostring(item.Timestamp),
			tostring(item.RouteTitle),
			tonumber(item.RunTime) or 0,
			tonumber(item.StepsDone) or 0,
			tonumber(item.TotalSteps) or 10
		)
		line.ZIndex = 5
		line.Parent = HistoryContainer
	end
end

-- ABA 5: SETTINGS
local SettingsPage = TabPages["SETTINGS"]
local VisualSettingsCard = createCard(SettingsPage, "Aparencia, Transparencia, Escala e Imagem Anime", 190, 1)

createActionButton(VisualSettingsCard, "TRANSPARENCIA -", UDim2.new(0, 14, 0, 40), UDim2.new(0, 130, 0, 28), Config.Theme.StrokeColor, function()
	Settings.UIWindowTransparency = math.clamp(Settings.UIWindowTransparency - 0.05, 0, 0.5)
	MainWindow.BackgroundTransparency = Settings.UIWindowTransparency
end)

createActionButton(VisualSettingsCard, "TRANSPARENCIA +", UDim2.new(0, 152, 0, 40), UDim2.new(0, 130, 0, 28), Config.Theme.AccentPrimary, function()
	Settings.UIWindowTransparency = math.clamp(Settings.UIWindowTransparency + 0.05, 0, 0.5)
	MainWindow.BackgroundTransparency = Settings.UIWindowTransparency
end)

createActionButton(VisualSettingsCard, "OPACIDADE ARTE -", UDim2.new(0, 290, 0, 40), UDim2.new(0, 130, 0, 28), Config.Theme.StrokeColor, function()
	Settings.BackgroundImageOpacity = math.clamp(Settings.BackgroundImageOpacity - 0.05, 0, 0.85)
	BackgroundArt.ImageTransparency = 1 - Settings.BackgroundImageOpacity
end)

createActionButton(VisualSettingsCard, "OPACIDADE ARTE +", UDim2.new(0, 428, 0, 40), UDim2.new(0, 130, 0, 28), Config.Theme.AccentPrimary, function()
	Settings.BackgroundImageOpacity = math.clamp(Settings.BackgroundImageOpacity + 0.05, 0, 0.85)
	BackgroundArt.ImageTransparency = 1 - Settings.BackgroundImageOpacity
end)

createActionButton(VisualSettingsCard, "ESCALA UI: 90%", UDim2.new(0, 14, 0, 78), UDim2.new(0, 115, 0, 26), Config.Theme.StrokeColor, function()
	Settings.UIScale = 0.9
	WindowScale.Scale = 0.9
end)

createActionButton(VisualSettingsCard, "ESCALA UI: 100%", UDim2.new(0, 137, 0, 78), UDim2.new(0, 115, 0, 26), Config.Theme.AccentPrimary, function()
	Settings.UIScale = 1.0
	WindowScale.Scale = 1.0
end)

createActionButton(VisualSettingsCard, "ANIMACOES ON/OFF", UDim2.new(0, 260, 0, 78), UDim2.new(0, 150, 0, 26), Config.Theme.AccentSecondary, function()
	Settings.AnimationsEnabled = not Settings.AnimationsEnabled
	sendNotification("Animacoes", Settings.AnimationsEnabled and "Animacoes ativadas." or "Animacoes desativadas.", Config.Theme.AccentPrimary)
end)

local BgAssetInput = Instance.new("TextBox")
BgAssetInput.Size = UDim2.new(0, 340, 0, 30)
BgAssetInput.Position = UDim2.new(0, 14, 0, 118)
BgAssetInput.BackgroundColor3 = Config.Theme.BackgroundPrimary
BgAssetInput.Font = Enum.Font.Gotham
BgAssetInput.TextSize = 12
BgAssetInput.TextColor3 = Config.Theme.TextPrimary
BgAssetInput.PlaceholderText = "Insira rbxassetid://NUMERO da Arte Anime de Fundo"
BgAssetInput.Text = Settings.BackgroundImageAssetId
BgAssetInput.ClearTextOnFocus = false
BgAssetInput.ZIndex = 5
BgAssetInput.Parent = VisualSettingsCard

local BgCorner = Instance.new("UICorner")
BgCorner.CornerRadius = UDim.new(0, 6)
BgCorner.Parent = BgAssetInput

createActionButton(VisualSettingsCard, "APLICAR IMAGEM", UDim2.new(0, 364, 0, 118), UDim2.new(0, 145, 0, 30), Config.Theme.AccentSuccess, function()
	local raw = string.gsub(BgAssetInput.Text, "%s+", "")
	if raw ~= "" and not string.find(raw, "rbxassetid://") then
		raw = "rbxassetid://" .. raw
	end
	Settings.BackgroundImageAssetId = raw
	BackgroundArt.Image = raw
	sendNotification("Imagem Atualizada", "Asset de fundo aplicado.", Config.Theme.AccentSuccess)
end)

local AudioSettingsCard = createCard(SettingsPage, "Configuracao de Musica de Abertura e Tecla do Hub", 145, 2)

local MusicInput = Instance.new("TextBox")
MusicInput.Size = UDim2.new(0, 340, 0, 30)
MusicInput.Position = UDim2.new(0, 14, 0, 40)
MusicInput.BackgroundColor3 = Config.Theme.BackgroundPrimary
MusicInput.Font = Enum.Font.Gotham
MusicInput.TextSize = 12
MusicInput.TextColor3 = Config.Theme.TextPrimary
MusicInput.PlaceholderText = "Insira rbxassetid://NUMERO da Musica Instrumental"
MusicInput.Text = Settings.MusicAssetId
MusicInput.ClearTextOnFocus = false
MusicInput.ZIndex = 5
MusicInput.Parent = AudioSettingsCard

local MusicCorner = Instance.new("UICorner")
MusicCorner.CornerRadius = UDim.new(0, 6)
MusicCorner.Parent = MusicInput

createActionButton(AudioSettingsCard, "APLICAR AUDIO", UDim2.new(0, 364, 0, 40), UDim2.new(0, 145, 0, 30), Config.Theme.AccentSuccess, function()
	local raw = string.gsub(MusicInput.Text, "%s+", "")
	if raw ~= "" and not string.find(raw, "rbxassetid://") then
		raw = "rbxassetid://" .. raw
	end
	Settings.MusicAssetId = raw
	updateMusicPlayback()
	sendNotification("Audio Configurado", "Asset de musica atualizado no SoundService.", Config.Theme.AccentSuccess)
end)

createActionButton(AudioSettingsCard, "MUSICA ON/OFF", UDim2.new(0, 14, 0, 82), UDim2.new(0, 130, 0, 28), Config.Theme.AccentPrimary, function()
	Settings.MusicEnabled = not Settings.MusicEnabled
	updateMusicPlayback()
	sendNotification("Musica do Hub", Settings.MusicEnabled and "Reproducao ativada." or "Reproducao pausada.", Config.Theme.AccentPrimary)
end)

createActionButton(AudioSettingsCard, "VOLUME -", UDim2.new(0, 154, 0, 82), UDim2.new(0, 95, 0, 28), Config.Theme.StrokeColor, function()
	Settings.MusicVolume = math.clamp(Settings.MusicVolume - 0.1, 0, 1)
	updateMusicPlayback()
end)

createActionButton(AudioSettingsCard, "VOLUME +", UDim2.new(0, 258, 0, 82), UDim2.new(0, 95, 0, 28), Config.Theme.AccentPrimary, function()
	Settings.MusicVolume = math.clamp(Settings.MusicVolume + 0.1, 0, 1)
	updateMusicPlayback()
end)

-- ============================================================================
-- 7. CONTROLE DE VISIBILIDADE E ATUALIZAÇÃO EM TEMPO REAL
-- ============================================================================
local function toggleHubVisibility()
	HubState.IsOpen = not HubState.IsOpen
	MainWindow.Visible = HubState.IsOpen
	updateMusicPlayback()
end

CloseBtn.MouseButton1Click:Connect(toggleHubVisibility)
FloatingToggleBtn.MouseButton1Click:Connect(toggleHubVisibility)

table.insert(Connections, UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
	if not gameProcessed and input.KeyCode == Settings.ToggleKey then
		toggleHubVisibility()
	end
end))

table.insert(Connections, LocalPlayer.CharacterAdded:Connect(function()
	if HubState.ControlState == "RUNNING" then
		stopAutoControl("Personagem recarregado. Reinicie o percurso quando desejar.")
	end
end))

table.insert(Connections, RunService.RenderStepped:Connect(function()
	if not HubState.IsOpen then
		return
	end
	local sessionSeconds = math.floor(os.clock() - HubState.SessionStartTime)
	local mins = math.floor(sessionSeconds / 60)
	local secs = sessionSeconds % 60

	HomeStateLabel.Text = "Estado do Auto Control: " .. HubState.ControlState
	HomeSessionLabel.Text = string.format("Tempo da Sessao: %02d:%02d", mins, secs)
	HomeRunTimerLabel.Text = string.format("Cronometro do Percurso: %.3fs", HubState.CurrentRunTime)

	local total = math.max(1, HubState.TotalSteps)
	local ratio = math.clamp(HubState.CurrentStepIndex / total, 0, 1)
	HomeStepLabel.Text = string.format(
		"Progresso da Etapa: %d / %d (%d%%)",
		HubState.CurrentStepIndex,
		HubState.TotalSteps,
		math.floor(ratio * 100)
	)
	ProgressBarFill.Size = UDim2.new(ratio, 0, 1, 0)
end))

-- Inicialização
RefreshRoutesUI()
RefreshAnalyticsUI()
switchTab("HOME")
updateMusicPlayback()
sendNotification("Anime Obby Hub", "Script unico carregado com sucesso.", Config.Theme.AccentPrimary)
