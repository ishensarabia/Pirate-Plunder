local GUI = script.Parent
local CrossFrame = GUI.Crosshair.Main
local CrossParts = {game.WaitForChild(CrossFrame,"HR"),game.WaitForChild(CrossFrame,"HL"),game.WaitForChild(CrossFrame,"VD"),game.WaitForChild(CrossFrame,"VU"),}
local Physics = require(script.PhysicModule)

--Accelerate module(part of physics module)
local e=2.718281828459045
local d=1
local s=1
local p0=0
local v0=0*p0
local p1=p0
local v1=v0
local t0=tick()

local function posvel(d,s,p0,v0,p1,v1,x)
	if s==0 then
		return p0
	elseif d<1-1e-8 then
		local h=(1-d*d)^0.5
		local c1=(p0-p1+2*d/s*v1)
		local c2=d/h*(p0-p1)+v0/(h*s)+(2*d*d-1)/(h*s)*v1
		local co=math.cos(h*s*x)
		local si=math.sin(h*s*x)
		local ex=e^(d*s*x)
		return co/ex*c1+si/ex*c2+p1+(x-2*d/s)*v1,
			s*(co*h-d*si)/ex*c2-s*(co*d+h*si)/ex*c1+v1
	elseif d<1+1e-8 then
		local c1=p0-p1+2/s*v1
		local c2=p0-p1+(v0+v1)/s
		local ex=e^(s*x)
		return (c1+c2*s*x)/ex+p1+(x-2/s)*v1,
			v1-s/ex*(c1+(s*x-1)*c2)
	else
		local h=(d*d-1)^0.5
		local a=(v1-v0)/(2*s*h)
		local b=d/s*v1-(p1-p0)/2
		local c1=(1-d/h)*b+a
		local c2=(1+d/h)*b-a
		local co=e^(-(h+d)*s*x)
		local si=e^((h-d)*s*x)
		return c1*co+c2*si+p1+(x-2*d/s)*v1,
			si*(h-d)*s*c2-co*(d+h)*s*c1+v1
	end
end
	
local function targposvel(p1,v1,x)
	return p1+x*v1,v1
end

local self={}

function self:accelerate(a)
	local time=tick()
	local p,v=posvel(d,s,p0,v0,p1,v1,time-t0)
	local tp,tv=targposvel(p1,v1,time-t0)
	p0,v0=p,v+a
	p1,v1=tp,tv
	t0=time
	return setmetatable(self)
end

--Crosshair module
local crosshair = {}

crosshair.crossscale = Physics.spring.new(0)	
crosshair.crossscale.s = 10	
crosshair.crossscale.d = 0.8
crosshair.crossscale.t = 1
crosshair.crossspring = Physics.spring.new(0)
crosshair.crossspring.s = 12
crosshair.crossspring.d = 0.65

local function updatecross()
	local size = crosshair.crossspring.p*4*crosshair.crossscale.p --*(char.speed/14*(1-0.8)*2+0.8)*(char.sprint+1)/2
	for i = 1, 4 do
		CrossParts[i].BackgroundTransparency = 1-size/20
	end
	CrossParts[1].Position = UDim2.new(0,size,0,0)
	CrossParts[2].Position = UDim2.new(0,-size-7,0,0)
	CrossParts[3].Position = UDim2.new(0,0,0,size)
	CrossParts[4].Position = UDim2.new(0,0,0,-size-7)
end

function crosshair:setcrossscale(scale)
	crosshair.crossscale.t = scale
end	
	
function crosshair:setcrosssize(size)
	crosshair.crossspring.t = size
end

function crosshair:setcrosssettings(size,speed,damper)
	crosshair.crossspring.t = size
	crosshair.crossspring.s = speed
	crosshair.crossspring.d = damper
end

game:GetService("RunService").RenderStepped:connect(function()
	updatecross()
end)

return crosshair