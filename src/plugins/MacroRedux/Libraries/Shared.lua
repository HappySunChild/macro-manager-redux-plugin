local pluginShared = {}
pluginShared.DEFAULT_ITEM_HEIGHT = 20
pluginShared.ITEM_REMAP = {
	Title = 'Label',
	Text = 'Label',
	Seperator = 'Divider',
	Object = 'Instance',
	Custom = 'Container',
	Display = 'Container',
	Frame = 'Container',
	Float = 'Number',
	Checkbox = 'Boolean',
	Toggle = 'Boolean',
}

pluginShared.Plugin = nil :: Plugin?
pluginShared.CurrentUserId = nil :: number?

local subscriptions = {}

function pluginShared:Unsubscribe(name: string)
	subscriptions[name] = nil
end

function pluginShared:Subscribe(name: string, callback)
	subscriptions[name] = callback
end

function pluginShared:Publish(name: string, ...)
	local callback = subscriptions[name]
	
	if callback then
		task.spawn(xpcall, callback, warn, ...)
	end
end

return pluginShared