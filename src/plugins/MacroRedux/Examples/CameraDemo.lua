local Selection = game:GetService("Selection")

local insertButton = {}
insertButton.Type = "Button"
insertButton.Text = "Insert Selected Model"

local saveButton = {}
saveButton.Type = "Button"
saveButton.Text = "Save"

local fovSlider = {
	Type = "Slider",
	Name = "FOV",
	Minimum = 1,
	Maximum = 30,
}

local viewport = {}
viewport.Type = "Viewport"
viewport.Name = "Preview"

local cameraDemo = {}
cameraDemo.Order = 2
cameraDemo.Icon = "rbxassetid://71492477999959"
cameraDemo.CurrentModel = nil
cameraDemo.Items = { insertButton, fovSlider, viewport, saveButton }

function cameraDemo:Activate()
	insertButton:SetText("Cancel")

	fovSlider:SetVisible(true)
	saveButton:SetVisible(true)
	viewport:SetVisible(true)
	viewport:ScrollTo()
end

function cameraDemo:Deactivate()
	insertButton:SetText("Insert Seleted Model")

	fovSlider:SetVisible(false)
	viewport:SetVisible(false)
	saveButton:SetVisible(false)
end

function cameraDemo:Init()
	local viewportFrame = viewport:GetViewportFrame() :: ViewportFrame
	viewportFrame.LightColor = Color3.new(1, 1, 1)
	viewportFrame.Ambient = Color3.new(0.8, 0.8, 0.8)
	viewportFrame.LightDirection = Vector3.new(-0.2, -1.5, 0.5)
	
	cameraDemo:Deactivate()

	function insertButton:Activated()
		if cameraDemo.CurrentModel then
			cameraDemo:Deactivate()

			viewport:Clear()

			cameraDemo.CurrentModel = nil

			return
		end

		local model = Selection:Get()[1]

		if not model or not model:IsA("Model") then
			warn("No model selected.")

			return
		end

		cameraDemo.CurrentModel = model

		local cameraInfo = model:FindFirstChild("CameraInfo")

		cameraDemo:Activate()

		viewport:Recenter()

		if cameraInfo then
			viewport.FieldOfView = cameraInfo:GetAttribute("FieldOfView")
			viewport:SetTransform(cameraInfo:GetAttribute("CFrame"), Vector3.zero)

			fovSlider:SetValue(cameraInfo:GetAttribute("FieldOfView"))
		end

		viewport:SetObject(model:Clone())
	end
	
	function saveButton:Activated()
		if not cameraDemo.CurrentModel then
			return
		end

		cameraDemo:Deactivate()

		local model = cameraDemo.CurrentModel

		if model:FindFirstChild("CameraInfo") then
			model:FindFirstChild("CameraInfo"):Destroy()
		end

		local cameraInfo = Instance.new("Configuration")
		cameraInfo.Name = "CameraInfo"
		cameraInfo.Parent = model

		cameraInfo:SetAttribute("CFrame", viewport:GetTransform())
		cameraInfo:SetAttribute("FieldOfView", viewport.FieldOfView)

		Selection:Set({ cameraInfo })
	end

	function fovSlider:Changed(newValue)
		viewport.FieldOfView = math.clamp(newValue, 0, 120)
		viewport:UpdateCamera()
	end
end

return cameraDemo
