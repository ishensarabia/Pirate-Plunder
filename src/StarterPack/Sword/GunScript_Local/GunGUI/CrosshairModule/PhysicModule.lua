local physics = {}

do
	local sort			=table.sort
	local atan2			=math.atan2
	local inf			=math.huge
	local cos			=math.cos
	local sin			=math.sin
	local setmetatable	=setmetatable
	local tick			=tick
	local dot			=Vector3.new().Dot

	physics.spring		={}

	do
		local cos=math.cos
		local sin=math.sin
		local e=2.718281828459045
		local setmt=setmetatable
		local error=error
		local tostring=tostring
		local tick=tick
	
		local function posvel(d,s,p0,v0,p1,v1,x)
			if s==0 then
				return p0
			elseif d<1-1e-8 then
				local h=(1-d*d)^0.5
				local c1=(p0-p1+2*d/s*v1)
				local c2=d/h*(p0-p1)+v0/(h*s)+(2*d*d-1)/(h*s)*v1
				local co=cos(h*s*x)
				local si=sin(h*s*x)
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
	
		function physics.spring.new(initial)
			local d=1
			local s=1
			local p0=initial or 0
			local v0=0*p0
			local p1=p0
			local v1=v0
			local t0=tick()
	
			local self={}
			local meta={}
	
			function self.getpv()
				return posvel(d,s,p0,v0,p1,v1,tick()-t0)
			end
	
			function self.setpv(p,v)
				local time=tick()
				local tp,tv=targposvel(p1,v1,time-t0)
				p0,v0=p,v
				p1,v1=tp,tv
				t0=time
			end
	
			function self.settargetpv(tp,tv)
				local time=tick()
				local p,v=posvel(d,s,p0,v0,p1,v1,time-t0)
				p0,v0=p,v
				p1,v1=tp,tv
				t0=time
			end
			
			function self:accelerate(a)
				local time=tick()
				local p,v=posvel(d,s,p0,v0,p1,v1,time-t0)
				local tp,tv=targposvel(p1,v1,time-t0)
				p0,v0=p,v+a
				p1,v1=tp,tv
				t0=time
			end
	
			function meta.__index(self,index)
				local time=tick()
				if index=="p" or index=="position" then
					local p,v=posvel(d,s,p0,v0,p1,v1,time-t0)
					return p
				elseif index=="v" or index=="velocity" then
					local p,v=posvel(d,s,p0,v0,p1,v1,time-t0)
					return v
				elseif index=="tp" or index=="t" or index=="targetposition" then
					local tp,tv=targposvel(p1,v1,time-t0)
					return tp
				elseif index=="tv" or index=="targetvelocity" then
					local tp,tv=targposvel(p1,v1,time-t0)
					return tv
				elseif index=="d" or index=="damper" then
					return d
				elseif index=="s" or index=="speed" then
					return s
				else
					error("no value "..tostring(index).." exists")
				end
			end
	
			function meta.__newindex(self,index,value)
				local time=tick()
				if index=="p" or index=="position" then
					local p,v=posvel(d,s,p0,v0,p1,v1,time-t0)
					local tp,tv=targposvel(p1,v1,time-t0)
					p0,v0=value,v
					p1,v1=tp,tv
				elseif index=="v" or index=="velocity" then
					local p,v=posvel(d,s,p0,v0,p1,v1,time-t0)
					local tp,tv=targposvel(p1,v1,time-t0)
					p0,v0=p,value
					p1,v1=tp,tv
				elseif index=="tp" or index=="t" or index=="targetposition" then
					local p,v=posvel(d,s,p0,v0,p1,v1,time-t0)
					local tp,tv=targposvel(p1,v1,time-t0)
					p0,v0=p,v
					p1,v1=value,tv
				elseif index=="tv" or index=="targetvelocity" then
					local p,v=posvel(d,s,p0,v0,p1,v1,time-t0)
					local tp,tv=targposvel(p1,v1,time-t0)
					p0,v0=p,v
					p1,v1=tp,value
				elseif index=="d" or index=="damper" then
					local p,v=posvel(d,s,p0,v0,p1,v1,time-t0)
					local tp,tv=targposvel(p1,v1,time-t0)
					p0,v0=p,v
					p1,v1=tp,tv
					d=value
				elseif index=="s" or index=="speed" then
					local p,v=posvel(d,s,p0,v0,p1,v1,time-t0)
					local tp,tv=targposvel(p1,v1,time-t0)
					p0,v0=p,v
					p1,v1=tp,tv
					s=value
				elseif index=="a" or index=="acceleration" then
					local time=tick()
					local p,v=posvel(d,s,p0,v0,p1,v1,time-t0)
					local tp,tv=targposvel(p1,v1,time-t0)
					p0,v0=p,v+value
					p1,v1=tp,tv
					t0=time
				else
					error("no value "..tostring(index).." exists")
				end
				t0=time
			end
	
			return setmt(self,meta)
		end
	end

	local function rootreals4(a,b,c,d,e)
		local x0,x1,x2,x3
		local m10=3*a
		local m0=-b/(4*a)
		local m4=c*c-3*b*d+12*a*e
		local m6=(b*b/(4*a)-2/3*c)/a
		local m9=((b*(4*c-b*b/a))/a-(8*d))/a
		local m5=c*(2*c*c-9*b*d-72*a*e)+27*a*d*d+27*b*b*e
		local m11=m5*m5-4*m4*m4*m4
		local m7
		if m11<0 then--Optimize
			local th=atan2((-m11)^0.5,m5)/3
			local m=((m5*m5-m11)/4)^(1/6)
			m7=(m4/m+m)/m10*cos(th)
		else--MAY NEED CASE FOR WHEN 2*c*c*c-9*b*c*d+27*a*d*d+27*b*b*e-72*a*c*e+((2*c*c*c-9*b*c*d+27*a*d*d+27*b*b*e-72*a*c*e)^2-4*(c*c-3*b*d+12*a*e)^3)^(1/2)=0
			local m8=(m5+m11^0.5)/2
			m8=m8<0 and -(-m8)^(1/3) or m8^(1/3)
			m7=(m4/m8+m8)/m10
		end
		local m2=2*m6-m7
		--print("m2",m2,0)
		local m12=m6+m7
		if m12<0 then
			local m3i=m9/(4*(-m12)^0.5)
			local m13=(m3i*m3i+m2*m2)^(1/4)*cos(atan2(m3i,m2)/2)/2
			--In order
			x0=m0-m13
			x1=m0-m13
			x2=m0+m13
			x3=m0+m13
		else
			local m1=m12^0.5
			--print("m1",m1,0)
			local m3=m9/(4*m1)
			--print("m3",m3,0)
			local m14=m2-m3
			local m15=m2+m3
			if m14<0 then
				x0=m0-m1/2
				x1=m0-m1/2
			else
				local m16=m14^0.5
				x0=m0-(m1+m16)/2
				x1=m0-(m1-m16)/2
			end
			if m15<0 then
				x2=m0+m1/2
				x3=m0+m1/2
			else
				local m17=m15^0.5
				x2=m0+(m1-m17)/2
				x3=m0+(m1+m17)/2
			end
			--bubble sort lel
			if x1<x0 then x0,x1=x1,x0 end
			if x2<x1 then x1,x2=x2,x1 end
			if x3<x2 then x2,x3=x3,x2 end
			if x1<x0 then x0,x1=x1,x0 end
			if x2<x1 then x1,x2=x2,x1 end
			if x1<x0 then x0,x1=x1,x0 end
		end
		return x0,x1,x2,x3
	end
	
	local function rootreals3(a,b,c,d)
		local x0,x1,x2
		local d0=b*b-3*a*c
		local d1=2*b*b*b+27*a*a*d-9*a*b*c
		local d=d1*d1-4*d0*d0*d0
		local m0=-1/(3*a)
		if d<0 then
			local cr,ci=d1/2,(-d)^0.5/2
			local th=atan2(ci,cr)/3
			local m=(cr*cr+ci*ci)^(1/6)
			local cr,ci=m*cos(th),m*sin(th)
			local m1=(1+d0/(m*m))/2
			local m2=(cr*d0+(cr-2*b)*m*m)/(6*a*m*m)
			local m3=ci*(d0+m*m)/(2*3^0.5*a*m*m)
			x0=-(b+cr*(1+d0/(m*m)))/(3*a)
			x1=m2-m3
			x2=m2+m3
		else
			local c3=(d1+d^0.5)/2
			c=c3<0 and -(-c3)^(1/3) or c3^(1/3)
			x0=m0*(b+c+d0/c)
			x1=m0*(b-(c*c+d0)/(2*c))
			x2=x1
		end
		if x1<x0 then x0,x1=x1,x0 end
		if x2<x1 then x1,x2=x2,x1 end
		if x1<x0 then x0,x1=x1,x0 end
		return x0,x1,x2
	end
	
	local function rootreals2(a,b,c)
		local p=-b/(2*a)
		local q2=p*p-c/a
		if 0<q2 then
			local q=q2^0.5
			return p-q,p+q
		else
			return p,p
		end
	end
	
	local solvemoar
	
	local function solve(a,b,c,d,e)
		if a*a<1e-32 then
			return solve(b,c,d,e)
		elseif e then
			if e*e<1e-32 then
				return solvemoar(a,b,c,d)
			elseif b*b<1e-12 and d*d<1e-12 then
				local roots={}
				local found={}
				local r0,r1=solve(a,c,e)
				if r0 then
					if r0>0 then
						local x=r0^0.5
						roots[#roots+1]=-x
						roots[#roots+1]=x
					elseif r0*r0<1e-32 then
						roots[#roots+1]=0
					end
				end
				if r1 then
					if r1>0 then
						local x=r1^0.5
						roots[#roots+1]=-x
						roots[#roots+1]=x
					elseif r1*r1<1e-32 then
						roots[#roots+1]=0
					end
				end
				sort(roots)
				return unpack(roots)
			else
				local roots={}
				local found={}
				local x0,x1,x2,x3=rootreals4(a,b,c,d,e)
				local d0,d1,d2=rootreals3(4*a,3*b,2*c,d)
				local m0,m1,m2,m3,m4=-inf,d0,d1,d2,inf
				local l0,l1,l2,l3,l4=a*inf,(((a*d0+b)*d0+c)*d0+d)*d0+e,(((a*d1+b)*d1+c)*d1+d)*d1+e,(((a*d2+b)*d2+c)*d2+d)*d2+e,a*inf
				if (l0<=0)==(0<=l1) then
					roots[#roots+1]=x0
					found[x0]=true
				end
				if (l1<=0)==(0<=l2) and not found[x1] then
					roots[#roots+1]=x1
					found[x1]=true
				end
				if (l2<=0)==(0<=l3) and not found[x2] then
					roots[#roots+1]=x2
					found[x2]=true
				end
				if (l3<=0)==(0<=l4) and not found[x3] then
					roots[#roots+1]=x3
				end
				return unpack(roots)
			end
		elseif d then
			if d*d<1e-32 then
				return solvemoar(a,b,c)
			elseif b*b<1e-12 and c*c<1e-12 then
				local p=d/a
				return p<0 and (-p)^(1/3) or -p^(1/3)
			else
				local roots={}
				local found={}
				local x0,x1,x2=rootreals3(a,b,c,d)
				local d0,d1=rootreals2(3*a,2*b,c)
				local l0,l1,l2,l3=-a*inf,((a*d0+b)*d0+c)*d0+d,((a*d1+b)*d1+c)*d1+d,a*inf
				if (l0<=0)==(0<=l1) then
					roots[#roots+1]=x0
					found[x0]=true
				end
				if (l1<=0)==(0<=l2) and not found[x1] then
					roots[#roots+1]=x1
					found[x1]=true
				end
				if (l2<=0)==(0<=l3) and not found[x2] then
					roots[#roots+1]=x2
				end
				return unpack(roots)
			end
		elseif c then
			local p=-b/(2*a)
			local q2=p*p-c/a
			if 0<q2 then
				local q=q2^0.5
				return p-q,p+q
			elseif q2==0 then
				return p
			end
		elseif b then
			if a*a>1e-32 then
				return -b/a
			end
		end
	end
	
	function solvemoar(a,b,c,d,e)
		local roots={solve(a,b,c,d,e)}
		local good=true
		for i=1,#roots do
			if roots[i]==0 then
				good=false
				break
			end
		end
		if good then
			roots[#roots+1]=0
			sort(roots)
		end
		return unpack(roots)
	end
	
	function physics.trajectory(pp,pv,pa,tp,tv,ta,s)
		local rp=tp-pp
		local rv=tv-pv
		local ra=ta-pa
		local t0,t1,t2,t3=solve(
			dot(ra,ra)/4,
			dot(ra,rv),
			dot(ra,rp)+dot(rv,rv)-s*s,
			2*dot(rp,rv),
			dot(rp,rp)
		)
		if t0 and t0>0 then
			return ra*t0/2+tv+rp/t0,t0
		elseif t1 and t1>0 then
			return ra*t1/2+tv+rp/t1,t1
		elseif t2 and t2>0 then
			return ra*t2/2+tv+rp/t2,t2
		elseif t3 and t3>0 then
			return ra*t3/2+tv+rp/t3,t3
		end
	end
end

return physics