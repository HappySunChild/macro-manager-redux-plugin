local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local castToGraph = require(package.Graph.castToGraph)
local evaluate = require(package.Graph.evaluate)

local xkindof = require(package.Utility.xkindof)

local function collectObservers(target: Types.GraphObject, outputTable)
	if target._observers ~= nil then
		for _, observer in target._observers do
			table.insert(outputTable, observer)
		end
	end

	return outputTable
end

local function change(target: Types.GraphObject)
	if not castToGraph(target) then
		return External.logError("invalidChangeType", nil, typeof(target))
	end

	if not evaluate(target, true) then
		return
	end

	local searchInNow = { target }
	local searchInNext = {}
	local userList = {}

	repeat
		local done = true

		for _, searchTarget in searchInNow do
			for user in searchTarget._users do
				if user.validity == "busy" then
					return External.logError "infiniteLoop"
				end

				if user.validity == "valid" then
					user.validity = "invalid"

					done = false

					table.insert(searchInNext, user)
					table.insert(userList, user)
				end
			end
		end

		searchInNow, searchInNext = searchInNext, searchInNow

		table.clear(searchInNext)
	until done

	local eagerList = {}

	collectObservers(target, eagerList)

	for _, user: Types.GraphObject in userList do
		collectObservers(user, eagerList)

		if user.timeliness == "eager" then
			table.insert(eagerList, user)
		end
	end

	table.sort(eagerList, function(a, b)
		return a.createdAt < b.createdAt
	end)

	for _, eagerUser: Types.GraphObject in eagerList do
		if xkindof(eagerUser) == "observer" then
			eagerUser.callback()

			continue
		end

		evaluate(eagerUser, false)
	end

	return true
end

return change
