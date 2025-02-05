local Skybox = require(script.Skybox)

local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)
local PluginShared = require(Libraries.Shared)

local Theme = require(Components.Theme)
local Label = require(Components.NameLabel)

local ViewportComponent = Roact.Component:extend('ViewportMacroComponent')

function ViewportComponent:init(macroItem)
	self.Item = macroItem
	self.ViewportRef = Roact.createRef()
	self.WorldRef = Roact.createRef()
	self.CameraRef = Roact.createRef()
	
	self._InputState = nil
	self._ClickStart = 0
	
	self:setState({
		Name = macroItem.Name
	})
	
	local component = self
	
	function macroItem:SetTransform(transform: CFrame, focus: Vector3?)
		local position = transform.Position
		local yAngle, xAngle = transform:ToOrientation()
		
		self.XAngle = math.deg(xAngle)
		self.YAngle = math.deg(yAngle)
		self.Position = focus or position
		
		if focus then
			self.Distance = (position - focus).Magnitude
		end
		
		self:UpdateCamera()
	end
	
	function macroItem:GetTransform()
		local rotation = CFrame.fromOrientation(math.rad(self.YAngle), math.rad(self.XAngle), 0)
		
		return CFrame.new(rotation.LookVector * -self.Distance, Vector3.zero) + self.Position
	end
	
	function macroItem:UpdateCamera()
		local camera: Camera = component.CameraRef:getValue()
		
		camera.FieldOfView = self.FieldOfView
		camera.CFrame = self:GetTransform()
	end
	
	function macroItem:Recenter()
		self.Position = Vector3.zero
		self:UpdateCamera()
	end
	
	------------------------------------------------------------
	------------------------------------------------------------
	
	function macroItem:GetViewportFrame()
		return component.ViewportRef:getValue()
	end
	
	function macroItem:GetWorldModel()
		return component.WorldRef:getValue()
	end
	
	function macroItem:GetCamera()
		return component.CameraRef:getValue()
	end
	
	
	function macroItem:Clear()
		local worldModel = self:GetWorldModel()
		
		if worldModel then
			worldModel:ClearAllChildren()
		end
		
		self.Instances = {}
	end
	
	function macroItem:SetObject(model: Model, clone: boolean?, location: CFrame?)
		self:Clear()
		self:Insert(model, clone, location)
	end
	
	function macroItem:Insert(model: Model, clone: boolean?, location: CFrame?)
		local newModel = model
	
		if clone or clone == nil then
			local success, cloned = pcall(model.Clone, model)
			
			if not success then
				warn('Unable to insert model!')
				
				return
			else
				newModel = cloned
			end
		end
		
		newModel:PivotTo(location or CFrame.new())
		newModel.Parent = self:GetWorldModel()
		
		if not macroItem.Instances then
			macroItem.Instances = {}
		end
		
		table.insert(macroItem.Instances, newModel)
	end
end

function ViewportComponent:render()
	local state = self.state
	local macroItem = self.Item
	
	local mainScrollingFrame = PluginShared.MainAppScrollingFrame :: ScrollingFrame?
	
	return Theme.with(function(theme)
		return Roact.createElement('Frame', {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			
			Size = UDim2.fromScale(1, 0),
		}, {
			Label = Roact.createElement(Label, {Text = state.Name, Size = UDim2.new(0, 0, 0, 16)}),
			Viewport = Roact.createElement('ViewportFrame', {
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				Size = UDim2.fromScale(1, 1),
				
				Position = UDim2.fromOffset(0, 18),
				
				BackgroundColor3 = Color3.new(0, 0, 0),
				
				BorderColor3 = theme.ViewportActiveBorder,
				BorderSizePixel = 0,
				
				CurrentCamera = self.CameraRef,
				
				[Roact.Ref] = self.ViewportRef,
				
				[Roact.Event.InputBegan] = function(frame: ViewportFrame, input: InputObject)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						self._ClickStart = tick()
					end
					
					if macroItem.Locked then
						return
					end
					
					if input.UserInputType == Enum.UserInputType.MouseButton2 then
						self._InputState = 'Dragging'
					elseif input.UserInputType == Enum.UserInputType.MouseButton3 or input.UserInputType == Enum.UserInputType.MouseButton1 then
						self._InputState = 'Panning'
					end
					
					if mainScrollingFrame then
						mainScrollingFrame.ScrollingEnabled = false
						frame.BorderSizePixel = 1
					end
				end,
				
				[Roact.Event.InputEnded] = function(frame: ViewportFrame, input: InputObject)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and (tick() - self._ClickStart) < 0.1 then -- slower...
						local position = Vector2.new(input.Position.X, input.Position.Y)
						local relativePosition = (position - frame.AbsolutePosition) / frame.AbsoluteSize
						
						macroItem:Clicked(relativePosition.X, relativePosition.Y)
					end
					
					if macroItem.Locked then
						return
					end
					
					if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 or input.UserInputType == Enum.UserInputType.MouseButton1 then
						self._InputState = nil
					end
					
					if input.UserInputType == Enum.UserInputType.MouseMovement and mainScrollingFrame then
						mainScrollingFrame.ScrollingEnabled = true
						frame.BorderSizePixel = 0
					end
				end,
				
				[Roact.Event.InputChanged] = function(_, input: InputObject)
					if macroItem.Locked then
						return
					end
					
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						local delta = input.Delta
						
						if self._InputState == 'Dragging' then
							delta *= macroItem.LookSensitivity
							
							macroItem.XAngle = (macroItem.XAngle - delta.X) % 360
							macroItem.YAngle = math.clamp(macroItem.YAngle - delta.Y, -80, 80)
						elseif self._InputState == 'Panning' then
							delta *= macroItem.PanSensitivity
							
							local transform = macroItem:GetTransform()
							
							macroItem.Position += ((transform.RightVector * -delta.X) + (transform.UpVector * delta.Y)) * 0.05
						end
					elseif input.UserInputType == Enum.UserInputType.MouseWheel then
						local scroll = input.Position.Z * macroItem.ZoomSensitivity
						
						macroItem.Distance = math.max(macroItem.Distance - scroll, 0.1)
					end
					
					macroItem:UpdateCamera()
				end,
			}, {
				WorldModel = Roact.createElement('WorldModel', {
					[Roact.Ref] = self.WorldRef
				}),
				
				Camera = Roact.createElement('Camera', {
					CFrame = CFrame.new(),
					
					[Roact.Ref] = self.CameraRef
				})
			})
		})
	end)
end

function ViewportComponent:willUnmount()
	local macroItem = self.Item
	
	if macroItem.Instances then -- preserve instances
		for _, object in ipairs(macroItem.Instances) do
			object.Parent = nil
		end
	end
end

function ViewportComponent:didMount()
	local macroItem = self.Item
	
	macroItem.Skybox = Skybox.new(self.ViewportRef:getValue())
	macroItem:UpdateCamera()
	
	if macroItem.Instances then
		for _, object in ipairs(table.clone(macroItem.Instances)) do -- "don't write where you're reading"
			pcall(function()
				object.Parent = macroItem:GetWorldModel()
			end)
		end
	end
end

local viewportClass = {
	Locked = false,
	
	FieldOfView = 90,
	Position = Vector3.zero,
	Distance = 10,
	XAngle = 0,
	YAngle = 0,
	
	PanSensitivity = 1,
	LookSensitivity = 1,
	ZoomSensitivity = 1
}

viewportClass.Name = 'Viewport'

viewportClass.__Component = ViewportComponent
viewportClass.__FunctionDetails = {
	GetViewportFrame = '() -> ViewportFrame!',
	GetWorldModel = '() -> WorldModel!',
	GetCamera = '() -> Camera!',
	
	SetObject = '(object: PVInstance, clone: boolean?, location: CFrame?) -> nil!',
	Insert = '(object: PVInstance, clone: boolean?, location: CFrame?) -> nil!',
	Clear = '() -> nil!',
	
	SetTransform = '(transform: CFrame) -> nil!',
	GetTransform = '() -> CFrame!',
	UpdateCamera = '() -> nil!',
	Recenter = '() -> nil!',
	
	GetViewportRay = '(x: number, y: number) -> Ray!',
	Raycast = '(origin: Vector3, direction: Vector3, params: RaycastParams?) -> RaycastResult?!',
	
	Clicked = '(x: number, y: number) -> nil'
}

------------------------------------------------------------
------------------------------------------------------------

function viewportClass:SetTransform(transform: CFrame)
	return transform
end

function viewportClass:GetTransform()
	return
end

function viewportClass:UpdateCamera()
	return
end

function viewportClass:Recenter()
	return
end

------------------------------------------------------------
------------------------------------------------------------

function viewportClass:GetCamera(): Camera?
	return
end

function viewportClass:GetViewportFrame(): ViewportFrame?
	return nil
end

function viewportClass:GetWorldModel(): WorldModel?
	return
end

function viewportClass:SetObject(model: Model, clone: boolean?, location: CFrame?)
	return model, clone, location
end

function viewportClass:Insert(model: Model, clone: boolean?, location: CFrame?)
	return model, clone, location
end

function viewportClass:Clear()
	return
end

------------------------------------------------------------
------------------------------------------------------------

function viewportClass:GetViewportRay(x, y)
	local camera = self:GetCamera()
	
	if not camera then
		return
	end
	
	return camera:ViewportPointToRay(x, y)
end

function viewportClass:Raycast(origin, direction, params)
	local worldModel = self:GetWorldModel()
	
	if not worldModel then
		return
	end
	
	return worldModel:Raycast(origin, direction, params)
end

function viewportClass:Clicked(x, y)
	return x, y
end

return viewportClass