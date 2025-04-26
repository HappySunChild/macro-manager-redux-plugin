local TweenService = game:GetService 'TweenService'

local function getTweenAlpha(info: TweenInfo, currentTime: number)
	local cycleCount = info.RepeatCount + 1
	local cycleDuration = info.DelayTime + info.Time

	if info.Reverses then
		cycleDuration += info.Time
	end

	if currentTime == math.huge then
		return 1
	end

	if currentTime >= cycleDuration * cycleCount and cycleCount > 0 then
		return 1
	end

	local cycleTime = currentTime % cycleDuration

	if cycleTime < info.DelayTime then
		return 0
	end

	local tweenProgress = (cycleTime - info.DelayTime) / info.Time

	if tweenProgress > 1 then
		tweenProgress = 2 - tweenProgress
	end

	local alpha = TweenService:GetValue(tweenProgress, info.EasingStyle, info.EasingDirection)

	return alpha
end

return getTweenAlpha
