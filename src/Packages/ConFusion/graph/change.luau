local graph = require "./types"

local External = require "../External"

local castToGraph = require "./castToGraph"
local evaluate = require "./evaluate"

local function _isEager(target: graph.GraphObject)
	if target.timeliness == "eager" then
		return true
	end

	if target._observers ~= nil then
		return next(target._observers) ~= nil
	end

	return false
end

local function _fireObservers(target: graph.GraphObject)
	if target._observers == nil then
		return
	end

	for _, callback in target._observers do
		External.doTaskImmediate(callback)
	end
end

local function change(target: graph.GraphObject)
	if not castToGraph(target) then
		return External.logError("invalidChangeType", nil, typeof(target))
	end

	if not evaluate(target, true) then
		return
	end

	local searchInNow = { target }
	local searchInNext = {}

	local eagerList = {}

	repeat
		local done = true

		for _, searchTarget: graph.GraphObject in searchInNow do
			for user in searchTarget._users do
				if user.validity == "busy" then
					External.logError "infiniteLoop"
				end

				if user.validity == "valid" then
					user.validity = "invalid"

					done = false

					table.insert(searchInNext, user)

					if _isEager(user) then
						table.insert(eagerList, user)
					end
				end
			end
		end

		searchInNow, searchInNext = searchInNext, searchInNow

		table.clear(searchInNext)
	until done

	table.sort(eagerList, function(a, b)
		return a.createdAt < b.createdAt
	end)

	_fireObservers(target)

	for _, eagerUser: graph.GraphObject in eagerList do
		if evaluate(eagerUser) then
			_fireObservers(eagerUser)
		end
	end

	return true
end

return change
