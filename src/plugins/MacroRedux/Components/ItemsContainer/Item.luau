local pluginContainer = script.Parent.Parent.Parent
local ItemClasses = pluginContainer.Classes

local Types = require(pluginContainer.Types)

local Logging = require(pluginContainer.Utility.Logging)
local MacroManager = require(pluginContainer.Utility.MacroManager)

local Fusion = require(pluginContainer.Packages.Fusion)
local t = require(pluginContainer.Packages.t)

local Children = Fusion.Children

local validate = t.optional(t.InstanceIsA "Frame")

local function getMacroItemClass(name: string)
	local customClass = MacroManager.CustomItemClasses[name]

	if customClass then
		return customClass
	end

	local classModule = ItemClasses:FindFirstChild(name)

	if not classModule then
		return
	end

	return require(classModule) :: any
end

local function Item(scope: Fusion.Scope, macroItem: Types.MacroItem)
	local targetType = macroItem.Type
	local constructor = getMacroItemClass(targetType)

	if not constructor then
		Logging.warn("classCannotFind", nil, targetType)
		return
	end

	if macroItem._rendered == true then
		Logging.warn("itemAlreadyRendered", nil, targetType)

		return
	end

	local inner = scope:innerScope()

	local itemContents: Frame?
	local success, err = pcall(function()
		itemContents = constructor(inner, macroItem)
	end)

	if not success then
		Logging.errorNonFatal("itemConstructorError", err, targetType)
	end

	local ok, msg = validate(itemContents)

	if not ok then
		Logging.errorNonFatal("itemInvalidContainer", nil, targetType, msg)

		inner:doCleanup()

		return
	end

	local visible = inner:Value(true)

	function macroItem:SetVisible(isVisible: boolean)
		visible:set(isVisible)
	end

	macroItem._rendered = true

	local size = scope:Value(Vector2.zero)

	if itemContents then
		size:bindToInstanceProperty(itemContents, "AbsoluteSize")
	end

	return inner:New "Frame" {
		Name = `{macroItem.Order}_{targetType}_MacroItem`,
		LayoutOrder = macroItem.Order,

		-- this doesn't work for some reason?
		-- doing it this way causes there to be extra padding which i suspect is because of the
		-- ui padding descendants, which is weird. i thought it would only account for them
		-- if they were direct children of the frame, but i guess not.
		-- maybe i should report this as a bug?
		-- ehhh, i'm too lazy...

		-- Size = UDim2.new(1, 0, 0, 0),
		-- AutomaticSize = Enum.AutomaticSize.Y,

		Size = inner:Computed(function(use: Fusion.Use)
			return UDim2.new(1, 0, 0, use(size).Y)
		end),

		BackgroundTransparency = 1,

		Visible = visible,

		[Children] = {
			ItemContents = itemContents,
		},
	}
end

return Item
