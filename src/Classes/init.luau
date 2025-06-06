-- return table.freeze {
-- 	Color3 = require "@self/Color3",
-- 	Boolean = require "@self/Boolean",
-- 	Button = require "@self/Button",
-- 	ButtonGroup = require "@self/ButtonGroup",
-- 	Container = require "@self/Container",
-- 	Divider = require "@self/Divider",
-- 	Dropdown = require "@self/Dropdown",
-- 	Label = require "@self/Label",
-- 	Number = require "@self/Number",
-- 	NumberRange = require "@self/NumberRange",
-- 	Section = require "@self/Section",
-- 	Slider = require "@self/Slider",
-- 	String = require "@self/String",
-- 	Title = require "@self/Title",
-- 	Vector2 = require "@self/Vector2",
-- 	Vector3 = require "@self/Vector3",
-- }

local ItemClasses = {}

local loaded = false

function ItemClasses.load()
	if loaded then
		return
	end

	loaded = true

	for _, class in script:GetChildren() do
		local index = class.Name

		ItemClasses[index] = require(class) :: any
	end
end

return ItemClasses :: { [string]: (...any) -> ...any }
