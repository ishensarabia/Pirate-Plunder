local mainGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("MainGUI")
local topStatus = mainGui:WaitForChild("TopStatus")
local announcementLabel = mainGui:WaitForChild("Announcement")
local piratesScoreUI = mainGui:WaitForChild("PiratesChest").Score
local sailorsScoreUI = mainGui:WaitForChild("SailorsChest").Score
-- This indicates the status of the battle
local status = game.ReplicatedStorage.Common.RoundSystem:WaitForChild("Status")
--Team scores
local piratesScore = game.ReplicatedStorage.Common.GameValues.PiratesScore
local sailorsScore = game.ReplicatedStorage.Common.GameValues.SailorsScore
local requiredScore = game.ReplicatedStorage.Common.GameValues.RequiredChestsToWin
-- Button to join the battle
local joinBattleButton = game.Players.LocalPlayer.PlayerGui.MainGUI.JoinButton

local player  = game.Players.LocalPlayer
topStatus.Visible = true
piratesScoreUI.Text = piratesScore.Value .. "/" .. requiredScore.Value
sailorsScoreUI.Text = sailorsScore.Value .. "/" .. requiredScore.Value



game.ReplicatedStorage.Common.RoundSystem.Remotes.ToggleMapVote.OnClientEvent:Connect(function(visibility)
	
	if not game.Players.LocalPlayer:FindFirstChild("InMenu") then
		mainGui.MapVoting.Visible = visibility
	end		
							
end)

piratesScore:GetPropertyChangedSignal("Value"):Connect(function()
	piratesScoreUI.Text = piratesScore.Value .. "/" .. requiredScore.Value
	announcementLabel.Text = "Pirates have scored!"
	mainGui.Score:Play()
	mainGui.Score.Ended:Wait()
	announcementLabel.Text = ""
end)

sailorsScore:GetPropertyChangedSignal("Value"):Connect(function()
	sailorsScoreUI.Text = sailorsScore.Value .. "/" .. requiredScore.Value
	announcementLabel.Text = "Sailors have scored!"
	mainGui.Score:Play()
	mainGui.Score.Ended:Wait()
	announcementLabel.Text = ""
end)


status:GetPropertyChangedSignal("Value"):Connect(function()
	topStatus.Text = status.Value;
end)



joinBattleButton.MouseButton1Click:connect(function()

	game.ReplicatedStorage.Common.RoundSystem.Remotes.JoinBattle:FireServer();

end)

while wait(0.1) do
	
	if player.Team == game:GetService("Teams").Pirates then
		for index, chest in pairs(workspace.PirateChests:GetChildren()) do
			if chest.MainPart.Attachment:FindFirstChild("ProximityPrompt") then
				chest.MainPart.Attachment.ProximityPrompt.Enabled = false
			end
		end	
	end

	if player.Team == game:GetService("Teams").Sailors then
		for index, chest in pairs(workspace.SailorChests:GetChildren()) do
			if chest.MainPart.Attachment:FindFirstChild("ProximityPrompt") then
				chest.MainPart.Attachment.ProximityPrompt.Enabled = false
			end
		end	
	end	
end