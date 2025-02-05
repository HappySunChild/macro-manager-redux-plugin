local pluginFolder = script.Parent.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)
local PluginShared = require(Libraries.Shared)

local Theme = require(Components.Theme)
local Padding = require(Components.Padding)

local Item = Roact.Component:extend('MacroItem')

function Item:init(macroItem)
	if not macroItem.__Component then
		warn(`ItemClass '{macroItem.Type}' does not have Roact component specified!`)
		
		return
	end
	
	self.FrameRef = Roact.createRef()
	
	self.Size, self.UpdateSize = Roact.createBinding(UDim2.fromScale(1, 0))
	self.Sizing, self.UpdateSizing = Roact.createBinding(Enum.AutomaticSize.Y)
	
	self.Item = macroItem
	self:setState({
		Visible = macroItem.Visible
	})
	
	local component = self
	
	function macroItem:SetVisible(visible)
		macroItem.Visible = visible
		
		component:setState({
			Visible = visible
		})
	end
	
	function macroItem:ScrollTo(duration: number?, alignment: Enum.VerticalAlignment)
		PluginShared:Publish('ScrollApp', component.FrameRef:getValue(), duration, alignment)
	end
end

function Item:render()
	return Theme.with(function(theme)
		local macroItem = self.Item
		
		return Roact.createElement('Frame', {
			Size = self.Size,
			AutomaticSize = self.Sizing,
			
			BorderSizePixel = 0,
			BackgroundColor3 = theme.ItemBackground,
			LayoutOrder = macroItem.Order,
			
			Visible = self.state.Visible ~= false,
			
			[Roact.Ref] = self.FrameRef
		}, {
			Padding = Roact.createElement(Padding, {
				All = 2
			}),
			
			ItemContent = Roact.createElement(macroItem.__Component, macroItem)
		})
	end)
end

-- weird crazy fix up ahead for the dropdown getting scaled incorrectly
-- literally want to peel off my skin because of this fix whyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
-- also doing this because i don't think there's a way to send data up the element tree with roact

function Item:didMount()
	local item = self.Item
	
	-- bubblegum and duct tape fix! lets pray that roblox doesn't decide to break this
	-- this wouldn't be an issue if roblox just let us have autoscale ignore certain gui objects but noooo
	-- we have to settle for this for now.
	if item.__Component.AutoScale == false then
		local frame = self.FrameRef:getValue() :: Frame
		
		local size = UDim2.new(1, 0, 0, frame.AbsoluteSize.Y) -- get the current size of the frame after autoscale first runs
		
		self.UpdateSize(size) -- set to initial size
		self.UpdateSizing(nil)  -- disable autoscale
	end
end

return Item