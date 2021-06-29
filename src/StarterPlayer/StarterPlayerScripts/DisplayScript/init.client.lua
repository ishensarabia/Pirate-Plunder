-- ROBLOX Services
local RunService = game:GetService("RunService")

-- Game Services
local NotificationManager = require(script.NotificationManager)
local TimerManager = require(script.TimerManager)

-- Local Variables
local Events = game.ReplicatedStorage.Events
local DisplayIntermission = Events.DisplayIntermission
local FetchConfiguration = Events.FetchConfiguration
local Camera = game.Workspace.CurrentCamera
local Player = game.Players.LocalPlayer
local ScreenGui = script.ScreenGui

local InIntermission = false
local IsTeams = nil

-- Initialization
game.StarterGui.ResetPlayerGuiOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- Local Functions
local function StartIntermission()
	-- Default to circle center of map
	local possiblePoints = {}
	table.insert(possiblePoints, Vector3.new(0,50,0))
	
	local focalPoint = possiblePoints[math.random(#possiblePoints)]
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.Focus = CFrame.new(focalPoint)
	
	local angle = 0
	game.Lighting.Blur.Enabled = true
	RunService:BindToRenderStep('IntermissionRotate', Enum.RenderPriority.Camera.Value, function()
		local cameraPosition = focalPoint + Vector3.new(50 * math.cos(angle), 20, 50 * math.sin(angle))
		Camera.CoordinateFrame = CFrame.new(cameraPosition, focalPoint)
		angle = angle + math.rad(.25)
		
		if BlurBlock then
		BlurBlock.CFrame = Camera.CoordinateFrame + 
			Camera.CoordinateFrame:vectorToWorldSpace(Vector3.new(0,0,-2))
		end
	end)
	
	ScreenGui.ScoreFrame["Bright blue"].Visible = false
	ScreenGui.ScoreFrame["Bright red"].Visible = false
end

local function StopIntermission()
	game.Lighting.Blur.Enabled = false
	RunService:UnbindFromRenderStep('IntermissionRotate')
	Camera.CameraType = Enum.CameraType.Custom
	if IsTeams then
		ScreenGui.ScoreFrame["Bright blue"].Visible = true
		ScreenGui.ScoreFrame["Bright red"].Visible = true
	end
end

local function OnDisplayIntermission(display)
	if display and not InIntermission then
		InIntermission = true
		StartIntermission()
	end	
	if not display and InIntermission then
		InIntermission = false
		StopIntermission()
	end
end

local function OnSetBlurBlock(block)
	BlurBlock = block
	BlurBlock.LocalTransparencyModifier = 0
end

local function OnFetchConfiguration(configFetched, configValue)
	if configFetched == "TEAMS" then
		IsTeams = configValue
		ScreenGui.ScoreFrame["Bright blue"].Visible = IsTeams
		ScreenGui.ScoreFrame["Bright red"].Visible = IsTeams
	end
end

-- Event Bindings
DisplayIntermission.OnClientEvent:connect(OnDisplayIntermission)
FetchConfiguration.OnClientEvent:connect(OnFetchConfiguration)

ScreenGui.ScoreFrame["Bright blue"].Visible = false
ScreenGui.ScoreFrame["Bright red"].Visible = false

-- See if the game is Team or FFA
IsTeams = FetchConfiguration:FireServer("TEAMS")