local ScriptEditorService = game:GetService('ScriptEditorService')

local pluginFolder = script.Parent.Parent

local ItemClasses = pluginFolder.Classes
local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local PluginShared = require(Libraries.Shared)
local PluginSettings = require(Libraries.Settings)
local Roact = require(Libraries.Roact)
local Theme = require(Components.Theme)

-- Components
local Padding = require(Components.Padding)
local TopbarButton = require(Components.TopbarButton)
local MacroTitle = require(script.Title)
local MacroItem = require(script.Item)
local MacroItemsContainer = require(script.ItemsContainer)
local AlertIcon = require(script.Alert)

local MacroComponent = Roact.Component:extend('MacroComponent')

-----------------------------------------------------
-----------------------------------------------------

function MacroComponent:init(info)
	local module = info.Module
	local reference = info.Reference
	
	local displayName = info.DisplayName
	local macroName = info.Name
	
	local macroData = nil
	
	local requireSuccess, requireErr = pcall(function()
		macroData = require(module)
	end)
	
	if not requireSuccess then
		warn(`Error while requiring Macro '{displayName}'; {requireErr}`)
		
		self.RequireError = {Error = requireErr, Name = macroName, Script = info.Reference}
		
		return
	end
	
	if requireSuccess and typeof(macroData) ~= "table" then
		warn(`Unable to add Macro '{displayName}'; returned value is not a table`)
		
		return
	end
	
	if not macroData.Items then
		warn(`Macro '{displayName}' is missing "Items" table!`)
		
		return
	end
	
	-- create setting table for macro if it doesn't exist
	if not PluginSettings:Get(macroName) then
		PluginSettings:Set(macroName, {})
	end
	
	self.Name = macroName
	self.DisplayName = displayName
	self.Order = tonumber(macroData.Order)
	
	self.ReferenceScript = reference
	self.MacroData = macroData
	
	self.FrameRef = Roact.createRef()
	
	self:setState({
		Alerts = 0,
		Visible = macroData.Visible,
		Minimized = PluginSettings:Get(macroName .. '/Minimized') or macroData.Minimized
	})
	
	
	local component = self
	
	function macroData:SetVisible(visible: boolean)
		component:setState({
			Visible = visible
		})
	end
	
	function macroData:SetMinimized(enabled: boolean)
		if component.state.Minimized == enabled then
			return
		end
		
		component:setState({
			Minimized = enabled,
			Alerts = 0
		})
	end
	
	function macroData:ScrollTo(duration: number?, alignment: Enum.VerticalAlignment?)
		PluginShared:Publish('ScrollApp', component.FrameRef:getValue(), duration, alignment)
	end
	
	function macroData:SendAlert(scrollTo: boolean?)
		if not component.state.Minimized then
			if scrollTo then
				self:ScrollTo()
			end
			
			return
		end
		
		component:setState(function(prevState)
			return {Alerts = prevState.Alerts + 1}
		end)
	end
	
	-- Macro Lifecycle; Setup -> Items setup -> Init | Unmounting -> Cleanup
	
	if macroData.Setup then
		local success, err = pcall(macroData.Setup, macroData, PluginShared.Plugin, PluginSettings:Get(self.Name))
		
		if not success then
			warn(`Error running Setup for macro '{displayName}; {err}`)
			
			macroData:SendAlert()
		end
	end
	
	--------------------------------
	
	local itemComponents = {}
	
	for ind, itemData in pairs(macroData.Items) do
		if itemData == '---' then
			itemData = {
				Type = 'Divider'
			}
		end
		
		local itemType = PluginShared.ITEM_REMAP[itemData.Type] or itemData.Type
		local classModule = ItemClasses:FindFirstChild(itemType)
		
		if not classModule then
			warn(module, `ItemClass '{itemData.Type}' does not exist!`)
			
			continue
		end
		
		local itemClass = require(classModule)
		itemData.Order = itemData.Order or tonumber(ind)
		itemData.CurrentMacro = macroData
		itemData.Name = itemData.Name or itemData.Text
		
		setmetatable(itemData, {__index = itemClass})
		
		itemComponents[`{ind}_Item_{itemData.Type}`] = Roact.createElement(MacroItem, itemData)
	end
	
	self.ItemComponents = itemComponents
	
	--------------------------------
	
	if macroData.Init then
		-- i don't know why items aren't immediate but this works fine i guess
		-- always weird quirks with roact
		
		task.defer(function()
			local success, err = pcall(macroData.Init, macroData, PluginShared.Plugin, PluginSettings:Get(self.Name))
			
			if not success then
				warn(`Error running Init for Macro '{displayName}'; {err}`)
				
				macroData:SendAlert()
			end
		end)
	end
end

function MacroComponent:render()
	local macroData = self.MacroData
	
	return Theme.with(function(theme)
		if not macroData then
			local errInfo = self.RequireError
			
			if errInfo then
				return Roact.createElement('TextLabel', {
					LayoutOrder = -99,
					Size = UDim2.new(1, 0, 0, 22),
					AutomaticSize = Enum.AutomaticSize.Y,
					
					BackgroundColor3 = theme.NoticeBackground,
					BorderSizePixel = 0,
					
					Text = `There was an error loading macro '{errInfo.Name}'\n{errInfo.Error}`,
					TextSize = 16,
					TextColor3 = theme.ErrorText,
					FontFace = theme.Font,
					
					[Roact.Event.MouseEnter] = function(element)
						element.BackgroundColor3 = theme.HoverBackground
					end,
					[Roact.Event.MouseLeave] = function(element)
						element.BackgroundColor3 = theme.NoticeBackground
					end,
					[Roact.Event.InputBegan] = function(_, input: InputObject)
						if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
							return
						end
						
						ScriptEditorService:OpenScriptDocumentAsync(errInfo.Script)
					end
				})
			end
			
			return
		end
		
		local state = self.state
		
		local itemContainer = Roact.createElement(MacroItemsContainer, {
			Items = self.ItemComponents,
			Visible = state.Minimized ~= true
		})
		
		local alertIcon = nil
		
		if state.Alerts > 0 and state.Minimized then
			alertIcon = Roact.createElement(AlertIcon, {
				Count = state.Alerts
			})
		end
		
		return Roact.createElement('Frame', {
			LayoutOrder = self.Order,
			
			Size = UDim2.new(1, 0, 0, 18),
			AutomaticSize = Enum.AutomaticSize.Y,
			BorderSizePixel = 0,
			
			Visible = state.Visible,
			
			BackgroundColor3 = theme.MacroBackground,
			
			[Roact.Ref] = self.FrameRef
		}, {
			Padding = Roact.createElement(Padding, {All = 2}),
			Alert = alertIcon,
			Minimize = Roact.createElement(TopbarButton, {
				Size = UDim2.fromOffset(16, 16),
				Position = UDim2.fromScale(1, 0),
				AnchorPoint = Vector2.new(1, 0),
				
				Text = state.Minimized and '+' or '-',
				TextSize = 16,
				
				Callback = function()
					local newState = not state.Minimized
					
					self:setState({
						Minimized = newState,
						Alerts = 0
					})
					
					PluginSettings:Set(self.Name .. '/Minimized', newState)
					
					if not newState then
						macroData:ScrollTo()
					end
				end
			}),
			
			Title = Roact.createElement(MacroTitle, {
				Macro = macroData,
				Icon = macroData.Icon,
				Text = self.DisplayName,
				Script = self.ReferenceScript
			}),
			
			Items = itemContainer
		})
	end)
end

function MacroComponent:willUnmount()
	local macroData = self.MacroData
	
	if not macroData then
		return
	end
	
	if macroData.Cleanup then
		local success, err = pcall(macroData.Cleanup, macroData, PluginShared.Plugin, PluginSettings:Get(self.Name))
		
		if not success then
			warn(`Error running Cleanup for Macro '{self.DisplayName}'; {err}`)
		end
	end
end

return MacroComponent