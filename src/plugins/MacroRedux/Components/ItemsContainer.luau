local pluginContainer = script.Parent.Parent
local ItemClasses = pluginContainer.Classes

local MacroManager = require(pluginContainer.Utility.MacroManager)
local Theme = require(pluginContainer.Utility.Theme)
local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local Children = Fusion.Children

local RoundBorder = require(pluginContainer.Components.RoundBorder)

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
	local constructor = getMacroItemClass(macroItem.Type)

	if not constructor then
		warn(`Could not find MacroItem class for '{macroItem.Type}'`)

		return
	end

	local inner = scope:innerScope()

	local frame
	local success, err = pcall(function()
		frame = constructor(inner, macroItem)
	end)

	if not success then
		warn(`Error while adding MacroItem '{macroItem.Type}';\n\t{err}`)
	end

	local visible = inner:Value(true)
	local absoluteSize = inner:Value(Vector2.zero)

	function macroItem:SetVisible(isVisible: boolean)
		visible:set(isVisible)
	end

	if frame then
		absoluteSize:bindToInstanceProperty(frame, "AbsoluteSize")
	end

	return inner:New "Frame" {
		Size = inner:Computed(function(use)
			return UDim2.new(1, 0, 0, use(absoluteSize).Y)
		end),

		Name = `{macroItem.Type}_MacroItem`,
		BackgroundTransparency = 1,

		Visible = visible,

		[Children] = frame,
	}
end

local function ItemsContainer(
	scope: Fusion.Scope,
	props: {
		Items: { Types.MacroItem },
		Visible: Fusion.UsedAs<boolean>?,
	}
)
	if props.Items == nil or #props.Items == 0 then
		return
	end

	local inner = scope:innerScope { Item = Item, RoundBorder = RoundBorder }
	local items = {}

	for ind, macroItem in props.Items do
		local frame = inner:Item(macroItem)

		if not frame then
			continue
		end

		macroItem.Order = macroItem.Order or ind

		table.insert(items, frame)
	end

	return scope:New "Frame" {
		Position = UDim2.fromOffset(0, 18),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,

		BackgroundColor3 = Theme.Colors.ItemBackground,
		ClipsDescendants = true,
		Visible = props.Visible,

		[Children] = {
			Layout = inner:New "UIListLayout" {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
			Padding = inner:New "UIPadding" {
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
				PaddingLeft = UDim.new(0, 1),
				PaddingRight = UDim.new(0, 1),
			},

			RoundBorder = inner:RoundBorder { Thickness = 0 },

			Items = items,
		},
	}
end

return ItemsContainer
