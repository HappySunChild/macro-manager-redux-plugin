local TweenService = game:GetService("TweenService")

local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)
local PluginShared = require(Libraries.Shared)

local Theme = require(Components.Theme)
local Padding = require(Components.Padding)
local Macro = require(Components.Macro)
local CreateMacro = require(Components.CreateMacro)

local App = Roact.Component:extend('App')

function App:init()
	self:setState({
		Macros = {}
	})
	
	self.ScrollRef = Roact.createRef()
end

function App:didMount()
	local scroll = self.ScrollRef:getValue()
	
	PluginShared.MainAppScrollingFrame = scroll
	
	PluginShared:Subscribe('UpdateMacroApp', function(macrosInfo)
		self:setState({
			Macros = macrosInfo
		})
	end)
	
	PluginShared:Subscribe('ScrollApp', function(frame: Frame, duration: number?, alignment: Enum.VerticalAlignment?)
		if not (frame and scroll) then
			return
		end
		
		alignment = alignment or Enum.VerticalAlignment.Top
		duration = duration or 0.4
		
		task.defer(function()
			local target = scroll.CanvasPosition.Y + frame.AbsolutePosition.Y
			
			if alignment == Enum.VerticalAlignment.Center then
				target -= scroll.AbsoluteWindowSize.Y / 2 - frame.AbsoluteSize.Y / 2
			elseif alignment == Enum.VerticalAlignment.Bottom then
				target -= scroll.AbsoluteWindowSize.Y - frame.AbsoluteSize.Y
			end
			
			target = math.clamp(target, 0, scroll.AbsoluteCanvasSize.Y - scroll.AbsoluteWindowSize.Y)
			
			TweenService:Create(scroll, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				CanvasPosition = Vector2.new(0, target)
			}):Play()
		end)
	end)
end

function App:willUnmount()
	PluginShared.MainAppScrollingFrame = nil
	PluginShared:Unsubscribe('UpdateMacroApp')
	PluginShared:Unsubscribe('ScrollApp')
end

function App:render()
	return Roact.createElement(Theme.Controller, {}, {
		Theme.with(function(theme)
			local state = self.state
			
			-- macro fragment
			local macros = {}
			
			for _, data in ipairs(state.Macros) do
				local module = data.Module
				
				macros[module.Name] = Roact.createElement(Macro, {
					Module = module,
					Reference = data.Reference,
					
					DisplayName = module.Name:gsub('(%l)([%u%d])', '%1 %2'),
					Name = module.Name
				})
			end
			
			if not next(macros) then
				macros.NoItems = Roact.createElement('TextLabel', {
					Size = UDim2.new(1, 0, 0, 26),
					
					BorderSizePixel = 0,
					BackgroundColor3 = theme.NoticeBackground,
					
					FontFace = theme.Font,
					RichText = true,
					Text = '<i>No macros detected</i>',
					TextSize = 18,
					TextColor3 = theme.DimmedText,
				})
			end
			
			local macroFragment = Roact.createFragment(macros)
			
			return Roact.createElement('ScrollingFrame', {
				Size = UDim2.fromScale(1, 1),
				CanvasSize = UDim2.fromScale(0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				
				BorderSizePixel = 0,
				
				ScrollBarImageColor3 = theme.Scrollbar,
				ScrollBarThickness = 0,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				
				BackgroundColor3 = theme.MainBackground,
				[Roact.Ref] = self.ScrollRef
			}, {
				Padding = Roact.createElement(Padding, {All = 2}),
				Layout = Roact.createElement('UIListLayout', {
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					
					Padding = UDim.new(0, 4)
				}),
				
				Macros = macroFragment,
				CreateMacro = Roact.createElement(CreateMacro)
			})
		end)
	})
end

return App