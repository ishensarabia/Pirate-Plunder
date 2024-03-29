local setting = require(script.Parent.Parent.Parent:WaitForChild("Setting"))
local physics = require(script.PhysicsModule)

local cam = {}
	
	cam.current = workspace.CurrentCamera
	cam.angles = {}
	cam.angles.x = 0
	cam.angles.y = 0
	cam.angles.z = 0
	cam.recoil = {}
	cam.recoil.x = physics.spring.new{d=setting.RecoilDamper;s=setting.RecoilSpeed;}
	cam.recoil.y = physics.spring.new{d=setting.RecoilDamper;s=setting.RecoilSpeed;}
	cam.recoil.z = physics.spring.new{d=setting.RecoilDamper;s=setting.RecoilSpeed;}
	
	function cam:accelerate(x,y,z)
		cam.recoil.x.impulse(x)
		cam.recoil.y.impulse(y)
		cam.recoil.z.impulse(z)
	end
	
	function cam:accelerateXY(x,y)
		cam.recoil.x.impulse(x)
		cam.recoil.y.impulse(y)
	end
	
	local function updatecam()			
		cam.current.CoordinateFrame = cam.current.CoordinateFrame*CFrame.Angles(cam.recoil.x.p(),cam.recoil.y.p(),cam.recoil.z.p())
	end
	
	game:GetService("RunService"):BindToRenderStep("RecoilCam",2000,function()
	    updatecam()
    end)

return cam
