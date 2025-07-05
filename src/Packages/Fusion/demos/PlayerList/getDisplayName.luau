local VERIFIED_BADGE = utf8.char(0xE000)
local PREMIUM_BADGE = utf8.char(0xE001)

local function getDisplayName(player: Player)
	local formattedName = player.DisplayName

	if player.HasVerifiedBadge then
		formattedName = formattedName .. VERIFIED_BADGE
	end

	if player.MembershipType == Enum.MembershipType.Premium then
		formattedName = PREMIUM_BADGE .. " " .. formattedName
	end

	return formattedName
end

return getDisplayName
