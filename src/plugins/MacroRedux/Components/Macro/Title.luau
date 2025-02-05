local ScriptEditorService = game:GetService('ScriptEditorService')
local Selection = game:GetService('Selection')

local pluginFolder = script.Parent.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)
local Theme = require(Components.Theme)

local Padding = require(Components.Padding)

local Title = Roact.Component:extend('MacroTitle')

function Title:init(props)
	self.InitialText = props.Text
	self.DisplayText, self.UpdateDisplayText = Roact.createBinding(self.InitialText)
	
	self.LastClick = 0
end

function Title:render()
	return Theme.with(function(theme)
		local props = self.props
		local macro = props.Macro
		
		return Roact.createElement('Frame', {
			Size = UDim2.new(0, 0, 0, 16),
			AutomaticSize = Enum.AutomaticSize.X,
			
			BackgroundTransparency = 1,
			BackgroundColor3 = theme.HoverBackground,
			BorderSizePixel = 0,
			
			[Roact.Event.InputBegan] = function(_, input: InputObject)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					if (tick() - self.LastClick) <= 0.5 then
						ScriptEditorService:OpenScriptDocumentAsync(props.Script)
					else
						Selection:Set({props.Script})
					end
					
					self.LastClick = tick()
				end
			end,
			[Roact.Event.MouseEnter] = function(element: Frame)
				element.BackgroundTransparency = 0
				
				if macro.GetDetail then
					local success, detail = xpcall(macro.GetDetail, warn, macro)
					
					if not success then
						return
					end
					
					self.UpdateDisplayText(`{self.InitialText} ({detail})`)
				end
			end,
			[Roact.Event.MouseLeave] = function(element: Frame)
				element.BackgroundTransparency = 1
				
				self.UpdateDisplayText(self.InitialText)
			end,
		}, {
			Padding = Roact.createElement(Padding, {Left = 2, Right = 2, All = 0}),
			Layout = Roact.createElement('UIListLayout', {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 2)
			}),
			
			Icon = Roact.createElement('ImageLabel', {
				Size = UDim2.fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				
				BackgroundTransparency = 1,
				Image = props.Icon or 'rbxassetid://95866080',
				
				LayoutOrder = 1,
			}),
			Label = Roact.createElement('TextLabel', {
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				
				Text = self.DisplayText,
				TextSize = 16,
				TextColor3 = theme.TitleText,
				FontFace = theme.Font,
				TextTruncate = Enum.TextTruncate.AtEnd,
				
				BackgroundTransparency = 1,
				
				LayoutOrder = 2,
			})
		})
	end)
end

return Title