local Selection = game:GetService "Selection"
local ServerStorage = game:GetService "ServerStorage"

local REQUIRED_SUBFOLDERS = {
	"Macros",
	"MacroItemClasses",
}

local ContainerManager = {}
ContainerManager.ContainerName = "MACRO_PLUGIN"
ContainerManager.CurrentContainer = nil :: Instance?
ContainerManager.TemporaryContainer = nil :: Instance?

function ContainerManager:ValidateContainer(container: Instance?)
	if not container or not container:IsDescendantOf(game) then
		return false
	end

	for _, name in REQUIRED_SUBFOLDERS do
		if not container:FindFirstChild(name) then
			return false
		end
	end

	return true
end

function ContainerManager:SetupContainer()
	local container =
		ServerStorage:FindFirstChild(ContainerManager.ContainerName)

	if not container then
		container = Instance.new "Folder"
		container.Name = ContainerManager.ContainerName
		container.Parent = ServerStorage

		Selection:Set { container }
	end

	-- NOTE: we can't give access to the built in macro item class types, because they are reliant on Fusion.
	-- Now I guess this could be resolved by either not using Fusion, or making Fusion accessible to the user.

	-- I don't really like the idea of forcing people to learn a UI framework so that they can slightly improve
	-- their own user experience, so that rules out making Fusion accessible.
	-- (Not to mention that the user may already have Fusion in their project, causing weird reduplication)

	-- I'm also not really keen on removing Fusion since it's pretty helpful and it'd be weird to have the
	-- item classes specifically not be built with Fusion, considering everything else is.

	-- So that leaves me with making it so the user can either completely overwrite the classes with their own
	-- logic and ui, or just leave them how there are.

	-- This allows a lot more freedom in the way that the user constructs their own macro item classes.
	-- I mean sure, it might be a little bit annoying having to basically recreate the entire item class if you want to slightly modify it,
	-- but that's just the way it's going to have to be since I can't really think of any other ways.

	for _, name in REQUIRED_SUBFOLDERS do
		if not container:FindFirstChild(name) then
			local subFolder = Instance.new "Folder"
			subFolder.Name = name
			subFolder.Parent = container
		end
	end

	ContainerManager.CurrentContainer = container

	return container
end

function ContainerManager:CreateTemporaryContainer()
	if ContainerManager.TemporaryContainer then
		ContainerManager.TemporaryContainer:Destroy()
	end

	local current = ContainerManager.CurrentContainer

	if not ContainerManager:ValidateContainer(current) then
		ContainerManager:SetupContainer()
	end

	local temporary = current:Clone()
	temporary.Archivable = false
	temporary.Name ..= ".tmp"
	temporary.Parent = ServerStorage

	ContainerManager.TemporaryContainer = temporary

	return temporary
end

return ContainerManager
