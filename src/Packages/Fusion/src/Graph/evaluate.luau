local External = require "../External"
local Types = require "../Types"

local castToGraph = require "./castToGraph"

local xtypeof = require "../Utility/xtypeof"

local function evaluate(target: Types.GraphObject, forceComputation: boolean?)
	if not castToGraph(target) then
		return External.logErrorNonFatal("invalidEvaluateType", nil, xtypeof(target))
	end

	if target.validity == "busy" then
		return External.logError "infiniteLoop"
	end

	local firstEvaluation = target._lastChange == nil or target._lastCompute == nil
	local isInvalid = target.validity == "invalid"

	if firstEvaluation or isInvalid or forceComputation then
		local needsComputation = firstEvaluation or forceComputation

		-- check if computation is actually needed
		if not needsComputation then
			for dependency in target._using do
				evaluate(dependency, false)

				if dependency._lastChange > target._lastCompute then
					needsComputation = true

					break
				end
			end
		end

		local targetMeaningfullyChanged = false

		if needsComputation then
			-- remove dependencies
			for dependency in target._using do
				dependency._users[target] = nil
				target._using[dependency] = nil
			end

			target.validity = "busy"

			targetMeaningfullyChanged = target:_evaluate() or firstEvaluation

			target._lastCompute = os.clock()
		end

		if targetMeaningfullyChanged then
			target._lastChange = os.clock()
		end

		target.validity = "valid"

		return targetMeaningfullyChanged
	end

	return false
end

return evaluate
