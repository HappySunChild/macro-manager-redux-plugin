local Classes = require "@plugin/Classes"
local types = require "@plugin/types"

local ConFusion = require "@packages/ConFusion"
local t = require "@packages/t"

local Logging = require "@utility/Logging"

local Children = ConFusion.Children

local validate = t.InstanceIsA "GuiBase2d"

local function Item(scope: ConFusion.Scope, macro_item: types.MacroItem)
	if table.isfrozen(macro_item) then
		return Logging.warn "itemFrozen"
	end

	local target_type = macro_item.Type
	local constructor = Classes.getClass(target_type)

	if not constructor then
		return Logging.warn("classCannotFind", nil, target_type)
	end

	-- added this to prevent weird duplicate rerenders
	-- usually this would happen if you accidently inserted the same item twice into
	-- an items array. but i mainly added this so that you couldn't
	-- as easily crash studio by putting a section inside of its own items array
	-- which would recursively create itself until the script or studio crashed.
	if macro_item._was_rendered == true then
		return Logging.warn("itemAlreadyRendered", nil, target_type)
	end

	local inner = scope:innerScope()

	local ok, contents = xpcall(function()
		return constructor(inner, macro_item)
	end, Logging.parse)
	if not ok then
		Logging.errorNonFatal("itemConstructorError", contents, target_type)

		inner:doCleanup()

		return
	end

	local ok, err = validate(contents)
	if not ok then
		Logging.errorNonFatal("itemInvalidContainer", nil, target_type, err)

		inner:doCleanup()

		return
	end

	local visible = inner:Value(true)

	function macro_item:SetVisible(isVisible: boolean)
		visible:set(isVisible)
	end

	macro_item._was_rendered = true

	local size = inner:PropertyOf(contents, "AbsoluteSize")

	return inner:New "Frame" {
		Name = `{macro_item.Order}_{target_type}_MacroItem`,
		LayoutOrder = macro_item.Order,

		Size = inner:Computed(function(use: ConFusion.Use)
			return UDim2.new(1, 0, 0, use(size).Y)
		end),

		BackgroundTransparency = 1,
		Visible = visible,

		[Children] = contents,
	}
end

return Item
