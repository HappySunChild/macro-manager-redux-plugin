local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)

local Group = require(Components.Group)
local ReferenceGroup = Roact.Component:extend('ReferenceGroup')

function ReferenceGroup:init(props)
	if not props.Render then
		warn('Missing Render callback for ReferenceGroup.')
		
		props.Render = function()
			return Roact.createElement('TextLabel', {
				Size = UDim2.fromOffset(50, 50),
				Text = 'Missing Render Callback!'
			})
		end
	end
	
	if not props.Refs then
		warn('Missing Refs property for ReferenceGroup.')
		
		props.Refs = {}
	end
end

function ReferenceGroup:render()
	local props = self.props
	
	local children = {}
	
	for index: string, data in ipairs(props.Refs) do
		local name, ref = data.Name, data.Ref
		
		children[name] = props.Render(ref, name, index)
	end
	
	return Roact.createElement(Group, props, children)
end

return ReferenceGroup