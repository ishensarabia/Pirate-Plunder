local spring = {}

--do -- springs, ok, totally not from treyreynolds
	--local runtime = game ("GetService", "RunService")
	local t = 0
	
	spring = {mt = {}}
	spring.mt.__index = spring
	
	function spring.new( initial )
		local t0 = tick()
		local p0 = initial or 0
		local v0 = initial and 0 * initial or 0
		local t	= initial or 0
		local d	= 1
		local s = 1
		
		local function positionvelocity(tick)
			local x			=tick-t0
			local c0		=p0-t
			if s==0 then
				return		p0,0
			elseif d<1 then
				local c		=(1-d*d)^0.5
				local c1	=(v0/s+d*c0)/c
				local co	=math.cos(c*s*x)
				local si	=math.sin(c*s*x)
				local e		=2.718281828459045^(d*s*x)
				return		t+(c0*co+c1*si)/e,
							s*((c*c1-d*c0)*co-(c*c0+d*c1)*si)/e
			else
				local c1	=v0/s+c0
				local e		=2.718281828459045^(s*x)
				return		t+(c0+c1*s*x)/e,
							s*(c1-c0-c1*s*x)/e
			end
		end
		return setmetatable({},{
			__index=function(_, index)
				if index == "value" or index == "position" or index == "p" then
					local p,v = positionvelocity(tick())
					return p
				elseif index == "velocity" or index == "v" then
					local p,v = positionvelocity(tick())
					return v
				elseif index == "acceleration" or index == "a" then
					local x	= tick()-t0
					local c0 = p0-t
					if s == 0 then
						return 0
					elseif d < 1 then
						local c	=(1-d*d)^0.5
						local c1 = (v0/s+d*c0)/c
						return s*s*((d*d*c0-2*c*d*c1-c*c*c0)*math.cos(c*s*x)
								+(d*d*c1+2*c*d*c0-c*c*c1)*math.sin(c*s*x))
								/2.718281828459045^(d*s*x)
					else
						local c1 = v0/s+c0
						return s*s*(c0-2*c1+c1*s*x)
								/2.718281828459045^(s*x)
					end
				elseif index == "target" or index == "t" then
					return t
				elseif index == "damper" or index == "d" then
					return d
				elseif index == "speed" or index == "s" then
					return s
				end
			end;
			__newindex=function(_, index, value)
				local time = tick()
				if index == "value" or index == "position" or index == "p" then
					local p,v = positionvelocity(time)
					p0, v0 = value, v
				elseif index == "velocity" or index == "v" then
					local p,v = positionvelocity(time)
					p0, v0 = p, value
				elseif index == "acceleration" or index == "a" then
					local p, v = positionvelocity(time)
					p0, v0 = p, v + value
				elseif index == "target" or index == "t" then
					p0, v0 = positionvelocity(time)
					t = value
				elseif index == "damper" or index == "d" then
					p0, v0 = positionvelocity(time)
					d = value < 0 and 0 or value < 1 and value or 1
				elseif index == "speed" or index == "s" then
					p0, v0 = positionvelocity(time)
					s = value < 0 and 0 or value
				end
				t0 = time
			end;
		})
	end
--end 			
-- ok fine, treyreynolds made it

return spring
