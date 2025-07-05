local ReplicatedStorage = game:GetService "ReplicatedStorage"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local peek = Fusion.peek

local scope = Fusion:scoped()

local cooldownActive = scope:Value(false)
local eventualValue = scope:Eventual(function(use, become: (V) -> ())
	if not use(cooldownActive) then
		return become "Inactive"
	end

	for i = 10, 1, -1 do
		become(i)

		task.wait(1)
	end

	return become "Done"
end)

scope:Observer(eventualValue):onBind(function()
	print(peek(eventualValue), eventualValue:isPending())
end)

cooldownActive:set(true)
