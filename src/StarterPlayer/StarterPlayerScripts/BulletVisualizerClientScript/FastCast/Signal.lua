--[[
	Creates signals via a modulized version of RbxUtility (It was deprecated so this will be released for people who would like to keep using it.
	
	This creates RBXScriptSignals.
	
	API:
		table Signal:connect(Function f) --Will run f when the event fires.
		void Signal:wait() --Will wait until the event fires
		void Signal:disconnectAll() --Will disconnect ALL connections created on this signal
		void Signal:fire(Tuple args) --Cause the event to fire with your own arguments
		
		
		Connect, Wait, DisconnectAll, and Fire are also acceptable for calling (An uppercase letter rather than a lowercase one)
		
		
	Standard creation:
	
		local SignalModule = require(this module)
		local Signal = SignalModule:CreateNewSignal()
		
		function OnEvent()
			print("Event fired!")
		end
		
		Signal:Connect(OnEvent) --Unlike objects, this does not do "object.SomeEvent:Connect()" - Instead, the Signal variable is the event itself.
		
		Signal:Fire() --Fire it.
--]]

local Signal = {}

function Signal:CreateNewSignal()
	local This = {}

	local mBindableEvent = Instance.new('BindableEvent')
	local mAllCns = {} --All connection objects returned by mBindableEvent::connect
	
	--Note to scripters: the 'self' variable is built into lua. Any time a method in a table is called (table:somemethod()), a local variable in that function named "self" is created. This variable is an alias to whatever table the function is part of.

	function This:Connect(Func)
		assert(This == self, "Expected ':' not '.' calling member function Connect")
		assert(typeof(Func) == "function", "Argument #1 of Connect must be a function, got a "..typeof(Func))
		
		local Con = mBindableEvent.Event:Connect(Func)
		mAllCns[Con] = true
		local ScrSig = {}
		function ScrSig:Disconnect()
			assert(ScrSig == self, "Expected ':' not '.' calling member function Disconnect")
			
			Con:Disconnect()
			mAllCns[Con] = nil
		end
				
		return ScrSig
	end
	
	function This:DisconnectAll()
		assert(This == self, "Expected ':' not '.' calling member function DisconnectAll")
				
		for Connection, _ in pairs(mAllCns) do
			Connection:Disconnect()
			mAllCns[Connection] = nil
		end
	end
	
	function This:Wait()
		assert(This == self, "Expected ':' not '.' calling member function Wait")
		
		return mBindableEvent.Event:Wait()
	end
	
	function This:Fire(...)
		assert(This == self, "Expected ':' not '.' calling member function Fire")
		
		mBindableEvent:Fire(...)
	end
	return This
end

return Signal