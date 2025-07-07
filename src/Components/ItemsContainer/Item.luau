local Classes = require "@plugin/Classes"
local Types = require "@plugin/Types"

local Logging = require "@utility/Logging"
local MacroManager = require "@utility/MacroManager"

local ConFusion = require "@packages/ConFusion"
local t = require "@packages/t"

local Children = ConFusion.Children

local validate = t.optional(t.InstanceIsA "GuiBase2d")

local function getMacroItemClass(name: string)
	local customClass = MacroManager.CustomItemClasses[name]

	if customClass then
		return customClass
	end

	-- fixes the linting issue, but is still very much a hack
	Classes.load()

	return Classes[name]
end

local _RENDERED = {}

local function Item(scope: ConFusion.Scope, macroItem: Types.MacroItem)
	local targetType = macroItem.Type
	local constructor = getMacroItemClass(targetType)

	if not constructor then
		Logging.warn("classCannotFind", nil, targetType)

		return
	end

	if macroItem[_RENDERED] == true then
		Logging.warn("itemAlreadyRendered", nil, targetType)

		return
	end

	local inner = scope:innerScope()
	local itemContents: Frame?

	xpcall(function()
		itemContents = constructor(inner, macroItem)
	end, function(err)
		Logging.errorNonFatal(
			"itemConstructorError",
			Logging.parse(err),
			targetType
		)
	end)

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

	macroItem[_RENDERED] = true

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

		Size = inner:Computed(function(use: ConFusion.Use)
			return UDim2.new(1, 0, 0, use(size).Y)
		end),

		BackgroundTransparency = 1,

		Visible = visible,

		[Children] = {
			contents = itemContents,
		},
	}
end

return Item
