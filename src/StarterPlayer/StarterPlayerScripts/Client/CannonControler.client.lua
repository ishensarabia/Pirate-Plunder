local player = game.Players.LocalPlayer
local camera = workspace.Camera
local CannonClass = require(game.ReplicatedStorage.Common.OOP.Cannon)
--Services
local UserInputSerivce = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
--Events
local events =game.ReplicatedStorage.Common.CannonSystem.Remotes
--Usage variables

function UseCannon(cannonModel)
    player.Character.Humanoid.WalkSpeed = 0
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CameraSubject = cannonModel
    player:GetMouse().Icon = "rbxassetid://5610075630"

    camera.CFrame = cannonModel.PrimaryPart.CFrame * CFrame.Angles(0,89.5,0)
    camera.CFrame += Vector3.new(10,4,0)
    player.Character.Humanoid:GetPropertyChangedSignal("Jump"):Connect(function() 
        CannonClass:LeaveCannon()
    end)
    player:GetMouse().Button1Down:Connect(function()
             CannonClass:ShootCannon(player:GetMouse().Hit.Position)

            local cameraTween1 = TweenService:Create(camera, TweenInfo.new(0.1), {FieldOfView = 85})
            local cameraTween2 = TweenService:Create(camera, TweenInfo.new(0.1), {FieldOfView =70})

            cameraTween1:Play()
            cameraTween1.Completed:Wait()
            cameraTween2:Play()
            cameraTween2.Completed:Wait()


        
    end)    


   
    repeat
        wait()
        cannonModel:SetPrimaryPartCFrame(CFrame.new(cannonModel.PrimaryPart.Position, player:GetMouse().Hit.Position) * CFrame.Angles(0, math.pi/-2, 0))
    until player:GetAttribute("CannonID") == nil
    
    --Set the player back to normal
    player.Character.Humanoid.WalkSpeed = 16
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = player.Character
    player:GetMouse().Icon = ""

      
end

events.UseCannon.OnClientEvent:Connect(UseCannon) 