local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)
local RefUtil = require(Libraries.RefUtility)
local PluginShared = require(Libraries.Shared)

local Label = require(Components.NameLabel)
local Entry = require(Components.Entry)
local ReferenceGroup = require(Components.ReferenceGroup)

local height = PluginShared.DEFAULT_ITEM_HEIGHT

local Vector3Component = Roact.Component:extend("Vector3MacroComponent")

function Vector3Component:getValue()
	local xBox, yBox, zBox = self.Refs:get("X", "Y", "Z")
	
	if not (xBox or yBox or zBox) then
		warn("Missing X, Y or Z entry box!")
		
		return
	end

	local xVal = tonumber(xBox.Text) or 0
	local yVal = tonumber(yBox.Text) or 0
	local zVal = tonumber(zBox.Text) or 0

	return Vector3.new(xVal, yVal, zVal)
end

function Vector3Component:init(macroItem)
	self.Item = macroItem
	self.Refs = RefUtil.combine("X", "Y", "Z")

	self:setState({
		Name = macroItem.Name,
		Value = macroItem.Value or Vector3.zero,
	})

	local component = self

	function macroItem:SetValue(newValue: Vector3)
		component:setState({
			Value = newValue,
		})
		
		local oldValue = self.Value
		
		self.Value = newValue
		self:Changed(newValue, oldValue)
	end
end

function Vector3Component:render()
	local state = self.state
	local macroItem = self.Item

	return Roact.createElement('Frame', {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1
	}, {
		Label = Roact.createElement(Label, {
			Text = state.Name,
			Size = UDim2.fromScale(0, 1),
		}),
		Group = Roact.createElement(ReferenceGroup, {
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.fromScale(0.6, 1),
			Position = UDim2.fromScale(1, 0),

			Refs = self.Refs:toInfo(),
			Render = function(ref, name, index)
				return Roact.createElement(Entry, {
					LayoutOrder = index,

					PlaceholderText = name,
					Text = string.format("%.2f", state.Value[name]),

					Size = UDim2.fromScale(0, 1),

					[Roact.Ref] = ref,

					Callback = function()
						macroItem:SetValue(self:getValue())
					end,
				})
			end,
		}),
	})
end

local vector3Class = {}
vector3Class.Name = "Vector3"
vector3Class.Value = Vector3.zero

vector3Class.__Component = Vector3Component
vector3Class.__FunctionDetails = {
	SetValue = "(newValue: Vector3) -> nil!",
	Set = "(newValue: Vector3) -> nil!",
	
	Changed = "(newValue: Vector3, oldValue: Vector3) -> nil",
}

------------------------------------------------------------
------------------------------------------------------------

function vector3Class:Changed(newValue: Vector3, oldValue: Vector3)
	return newValue, oldValue
end

function vector3Class:SetValue(value: Vector3)
	return value
end

--- Compatibility Methods ---

function vector3Class:Set(value: Vector3)
	self:SetValue(value)
end

return vector3Class
