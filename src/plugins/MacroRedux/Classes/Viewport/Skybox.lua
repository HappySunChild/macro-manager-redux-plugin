local skybox = {}
skybox.__index = skybox

function skybox.new(parent: Instance?)
	local model = Instance.new('Model')
	model.Name = 'Skybox'
	model.Parent = parent
	
	for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
		local normal = Vector3.FromNormalId(face)
		
		local skyboxPart = Instance.new('Part')
		skyboxPart.Name = `Skybox{face.Name}Face`
		skyboxPart.CFrame = CFrame.new(normal * 1024, Vector3.zero)
		skyboxPart.Size = Vector3.new(2048, 2048, 1)
		skyboxPart.Locked = true
		skyboxPart.Parent = model
	end
	
	local newSkybox = setmetatable({}, skybox)
	newSkybox.Model = model
	
	local texture = Instance.new('Texture')
	texture.StudsPerTileU = 128
	texture.StudsPerTileV = 128
	texture.Texture = 'rbxassetid://6372755229'
	texture.Transparency = 0.8
	
	newSkybox:SetTexture(texture)
	newSkybox:SetColor(Color3.new(0.5, 0.5, 0.5))
	
	return newSkybox
end

function skybox:SetTexture(texture: Texture)
	local model = self.Model :: Model
	
	if not model then
		return
	end
	
	for _, part: BasePart in ipairs(model:GetChildren()) do
		part:ClearAllChildren()
		
		if texture then
			local newTexture = texture:Clone()
			newTexture.Parent = part
		end
	end
end

function skybox:SetColor(color: Color3)
	local model = self.Model :: Model
	
	if not model then
		return
	end
	
	for _, part: BasePart in ipairs(model:GetChildren()) do
		part.Color = color
	end
end

return skybox