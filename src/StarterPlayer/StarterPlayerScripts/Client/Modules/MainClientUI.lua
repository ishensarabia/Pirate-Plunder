local playerGui = game.Players.LocalPlayer.PlayerGui;
local player = game.Players.LocalPlayer
local GuiModule = {};



function GuiModule.PlayButton()

    local tween = require(playerGui:WaitForChild("StartMenu").Animator).PlayButton
    tween:Play()
    tween.DonePlaying.Event:Connect(function()

            playerGui.StartMenu.MainFrame.Visible = false
            player.inMenu.Value = false
        
    end)

    
end

function GuiModule.JoinButton()

    local tween = require(playerGui:WaitForChild("MainGUI").Animator).JoinButton
	tween:Play()
    tween.DonePlaying.Event:wait()

end

function GuiModule.TeamSelected(Team)
	
	game.ReplicatedStorage.Common.RoundSystem.Remotes.SelectTeam:FireServer(Team)
	playerGui.TeamSelection.Enabled = false

	
end


return GuiModule;