local NotificationManager = {}

-- Local Variables
local ScoreFrame = script.Parent.ScreenGui.ScoreFrame
local VictoryFrame = script.Parent.ScreenGui.VictoryMessage
local Events = game.ReplicatedStorage.Events
local DisplayVictory = Events.DisplayVictory
local DisplayScore = Events.DisplayScore
local ResetMouseIcon = Events.ResetMouseIcon
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

local MouseIcon = Mouse.Icon

-- Local Functions
local function OnScoreChange(team, score)
	ScoreFrame[tostring(team.TeamColor)].Text = score
end

local function OnDisplayVictory(winningTeam)
	if winningTeam then
		VictoryFrame.Visible = true
		if winningTeam == 'Tie' then
			VictoryFrame.Tie.Visible = true
		else
			VictoryFrame.Win.Visible = true
			local WinningFrame = VictoryFrame.Win.TeamDisplay
			WinningFrame.Size = UDim2.new(0, string.len(winningTeam.TeamColor.Name) * 19, 0, 50)
			WinningFrame.Position = UDim2.new(0, -WinningFrame.Size.X.Offset, 0, 0)
			WinningFrame.TextColor3 = winningTeam.TeamColor.Color
			WinningFrame.Text = winningTeam.TeamColor.Name
			WinningFrame.Visible = true
		end
	else
		VictoryFrame.Visible = false
		VictoryFrame.Win.Visible = false
		VictoryFrame.Win.TeamDisplay.Visible = false
		VictoryFrame.Tie.Visible = false
	end
end

local function OnResetMouseIcon()
	Mouse.Icon = MouseIcon
end

-- Event Bindings
DisplayVictory.OnClientEvent:connect(OnDisplayVictory)
DisplayScore.OnClientEvent:connect(OnScoreChange)
ResetMouseIcon.OnClientEvent:connect(OnResetMouseIcon)

return NotificationManager