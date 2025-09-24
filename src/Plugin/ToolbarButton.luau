local ConFusion = require "@packages/ConFusion"

local OnEvent = ConFusion.OnEvent
local peek = ConFusion.peek

local function ToolbarButton(
	scope: ConFusion.Scope,
	props: {
		toolbar: PluginToolbar,

		id: string,
		name: string,
		description: string,
		icon: ConFusion.UsedAs<string>,

		noToggle: boolean?,

		clickableWhenViewportHidden: ConFusion.UsedAs<boolean>?,
		clickCallback: () -> ()?,
	}
): PluginToolbarButton
	local newButton = props.toolbar:CreateButton(
		props.id,
		props.description,
		peek(props.icon),
		props.name
	)

	return scope:Hydrate(newButton) {
		Icon = props.icon,
		ClickableWhenViewportHidden = props.clickableWhenViewportHidden,

		[OnEvent "Click"] = if props.noToggle
			then props.clickCallback
			else if props.clickCallback
				then function()
					newButton:SetActive(false)
					newButton:SetActive(true)

					props.clickCallback()
				end
				else nil,
	}
end

return ToolbarButton
