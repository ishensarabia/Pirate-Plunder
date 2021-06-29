local GuiModule = require(game.Players.LocalPlayer.PlayerScripts.Client.Modules.MainClientUI)
local playerGui = game.Players.LocalPlayer.PlayerGui;


playerGui:WaitForChild("MainGUI").JoinButton.MouseButton1Click:Connect(function()
	GuiModule.JoinButton()
	playerGui:WaitForChild("MainGUI").JoinButton.Visible = false
end)
playerGui:WaitForChild("TeamSelection").Frame.Pirates.MouseButton1Click:Connect(function()
	GuiModule.TeamSelected("Pirates")
end)
playerGui:WaitForChild("TeamSelection").Frame.Sailors.MouseButton1Click:Connect(function()
	GuiModule.TeamSelected("Sailors")
end)