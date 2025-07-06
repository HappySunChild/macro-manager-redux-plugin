--!strict
local Selection = game:GetService "Selection"
local ServerStorage = game:GetService "ServerStorage"

local CONTAINER_NAME = "MACRO_PLUGIN"
local REQUIRED_SUBFOLDERS = {
	"Macros",
	"MacroItemClasses",
}

local currentContainer = nil :: Instance?
local temporaryContainer = nil :: Instance?

local function _validateContainer(container: Instance?): boolean
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

local function setupContainer(): Instance
	local container = ServerStorage:FindFirstChild(CONTAINER_NAME)

	-- create a new container if one doesn't already exist
	if container == nil then
		container = Instance.new "Folder"
		container.Name = CONTAINER_NAME
		container.Parent = ServerStorage

		Selection:Set { container }
	end

	-- NOTE: we can't give access to the built in macro item class types, because they are reliant on ConFusion.
	-- Now I guess this could be resolved by either not using ConFusion, or making ConFusion accessible to the user.

	-- I don't really like the idea of forcing people to learn a UI framework so that they can slightly improve
	-- their own user experience, so that rules out making ConFusion accessible.
	-- (Not to mention that the user may already have ConFusion in their project, causing weird reduplication)

	-- I'm also not really keen on removing ConFusion since it's pretty helpful and it'd be weird to have the
	-- item classes specifically not be built with ConFusion, considering everything else is.

	-- So that leaves me with making it so the user can either completely overwrite the classes with their own
	-- logic and ui, or just leave them how there are.

	-- This allows a lot more freedom in the way that the user constructs their own macro item classes.
	-- I mean sure, it might be a little bit annoying having to basically recreate the entire item class if you want to slightly modify it,
	-- but that's just the way it's going to have to be since I can't really think of any other ways.

	for _, name in REQUIRED_SUBFOLDERS do
		if (container :: Instance):FindFirstChild(name) == nil then
			local subFolder = Instance.new "Folder"
			subFolder.Name = name
			subFolder.Parent = container
		end
	end

	currentContainer = container

	return container :: Instance
end

local function getCurrentContainer(): Instance
	if not _validateContainer(currentContainer) then
		return setupContainer()
	end

	return currentContainer :: Instance
end

local function createTemporaryContainer(): Instance
	if temporaryContainer then
		temporaryContainer:Destroy()
	end

	local active = getCurrentContainer()

	local temporary = active:Clone()
	temporary.Archivable = false
	temporary.Name ..= ".tmp"
	temporary.Parent = ServerStorage

	temporaryContainer = temporary

	return temporary
end

return table.freeze {
	ContainerName = CONTAINER_NAME,

	getCurrentContainer = getCurrentContainer,

	setupContainer = setupContainer,
	createTemporaryContainer = createTemporaryContainer,
}
