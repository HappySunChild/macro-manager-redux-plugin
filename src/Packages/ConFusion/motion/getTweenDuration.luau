local function getTweenDuration(tweenInfo: TweenInfo)
	if tweenInfo.RepeatCount == -1 then
		return math.huge
	end

	local duration = tweenInfo.DelayTime + tweenInfo.Time

	if tweenInfo.Reverses then
		duration += tweenInfo.Time
	end

	duration *= tweenInfo.RepeatCount + 1

	return duration
end

return getTweenDuration
