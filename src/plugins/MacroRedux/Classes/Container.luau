local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)

local Theme = require(Components.Theme)
local Label = require(Components.NameLabel)


local ContainerComponent = Roact.Component:extend('ContainerMacroComponent')

function ContainerComponent:init(macroItem)
	self.Item = macroItem
	self.ContainerRef = Roact.createRef()
	
	self:setState({
		Name = macroItem.Name
	})
	
	macroItem.Instances = macroItem.Instances or {}
	
	local component = self
	
	function macroItem:GetContainer()
		return component.ContainerRef:getValue()
	end
	
	macroItem.CurrentTheme = Theme.getCurrentTheme()
	macroItem:ThemeChanged(macroItem.CurrentTheme)
end

function ContainerComponent:didMount()
	local macroItem = self.Item
	
	for _, instance in ipairs(macroItem.Instances) do
		instance.Parent = macroItem:GetContainer()
	end
	
	self.ThemeConnection = Theme.Changed:Connect(function()
		local theme = Theme.getCurrentTheme()
		
		macroItem.CurrentTheme = theme
		macroItem:ThemeChanged(theme)
	end)
end

function ContainerComponent:willUnmount()
	local macroItem = self.Item
	
	for _, instance in ipairs(macroItem.Instances) do
		instance.Parent = nil
	end
	
	self.ThemeConnection:Disconnect()
end

function ContainerComponent:render()
	local state = self.state
	
	return Roact.createElement('Frame', {
		Size = UDim2.fromScale(1, 0),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y
	}, {
		Label = Roact.createElement(Label, {Text = state.Name, Size = UDim2.fromOffset(0, 16)}),
		Container = Roact.createElement('Frame', {
			Position = UDim2.fromOffset(0, 18),
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			
			BackgroundTransparency = 1,
			
			[Roact.Ref] = self.ContainerRef
		})
	})
end

local containerClass = {}
containerClass.Name = 'Container'
containerClass.CurrentTheme = nil

containerClass.__Component = ContainerComponent
containerClass.__FunctionDetails = {
	Insert = '(object: Instance) -> nil!',
	GetContainer = '() -> Frame!',
	ThemeChanged = '(theme: {[string]: Color3, Font: Font}) -> nil'
}

------------------------------------------------------------
------------------------------------------------------------

function containerClass:ThemeChanged(theme)
	return theme
end

function containerClass:GetContainer()
	return nil
end

function containerClass:Clear()
	self:GetContainer():ClearAllChildren()
	self.Instances = {}
end

function containerClass:Insert(object: Instance)
	object.Parent = self:GetContainer()
	
	if not self.Instances then
		self.Instances = {}
	end
	
	table.insert(self.Instances, object)
end

return containerClass