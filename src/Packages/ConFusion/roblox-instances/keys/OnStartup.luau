local SpecialKey = require "./SpecialKey"

return SpecialKey "OnStartup" {
	stage = "last",
	apply = function(_, parent: Instance, callback: (Instance) -> ())
		callback(parent)
	end,
}
