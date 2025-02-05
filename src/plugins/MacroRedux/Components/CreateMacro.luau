local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)
local MacroManager = require(Libraries.MacroManager)

local Theme = require(Components.Theme)
local TopbarButton = require(Components.TopbarButton)
local Padding = require(Components.Padding)
local Entry = require(Components.Entry)
local Group = require(Components.Group)

local CreateMacro = Roact.Component:extend('CreateMacro')

function CreateMacro:init()
	self.FieldRef = Roact.createRef()
end

function CreateMacro:render()
	return Theme.with(function(theme)
		return Roact.createElement('Frame', {
			BackgroundColor3 = theme.MacroBackground,
			BorderSizePixel = 0,
			
			Size = UDim2.new(1, 0, 0, 24),
			LayoutOrder = -1e6 -- a big number
		}, {
			Roact.createElement(Group, {
				Size = UDim2.fromScale(1, 1)
			}, {
				Padding = Roact.createElement(Padding, {All = 2}),
				
				Button = Roact.createElement(TopbarButton, {
					Size = UDim2.new(0, 120, 1, 0),
					
					Text = 'Create Macro',
					TextSize = 16,
					TextColor3 = theme.TitleText,
					
					LayoutOrder = 2,
					Callback = function()
						local field = self.FieldRef:getValue()
						
						if not field then
							return
						end
						
						local text = field.Text
						
						if #text <= 1 then
							return
						end
						
						MacroManager:CreateMacro(text)
						
						field.Text = ''
					end
				}),
				
				Field = Roact.createElement(Entry, {
					Size = UDim2.fromScale(1, 1),
					BorderSizePixel = 0,
					
					Text = '',
					TextSize = 16,
					PlaceholderText = 'Macro Name',
					TextXAlignment = Enum.TextXAlignment.Left,
					
					[Roact.Ref] = self.FieldRef
				})
			})
		})
	end)
end

return CreateMacro