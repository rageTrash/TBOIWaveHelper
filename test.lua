include("waveHelper")

local WaveFlags = WaveHelper.WaveFlags
local WaveCallbacks = WaveHelper.WaveCallbacks


local function FlagsToName(flags)
	if flags & WaveFlags.WAVE_BOSSRUSH > 0 then
		return "Boss Rush"
	elseif flags & WaveFlags.WAVE_GIDEON > 0 then
		return "Gideon"
	end
	local str = ""

	if flags & WaveFlags.WAVE_NORMAL > 0 then
		str = "Normal"
	elseif flags & WaveFlags.WAVE_BOSS > 0 then
		str = "Boss"
	end

	if flags & WaveFlags.WAVE_CHALLENGE > 0 then
		str = str .." Challenge"
	elseif flags & WaveFlags.WAVE_GREED > 0 then
		str = str .." Greed"
	end
	return str
end


local function TestStart(_, wFlags)
	print((FlagsToName(wFlags) .." Wave Started"))
end
local function TestChange(_, waveNum, wFlags)
	print((FlagsToName(wFlags) .." Wave ".. waveNum))
end
local function TestFinish(_, wFlags)
	print((FlagsToName(wFlags) .." Wave Finish"))
end


WaveHelper:AddCallback(WaveCallbacks.WC_WAVE_START, TestStart)
WaveHelper:AddCallback(WaveCallbacks.WC_WAVE_CHANGE, TestChange)
WaveHelper:AddCallback(WaveCallbacks.WC_WAVE_FINISH, TestFinish)

WaveHelper:AddCallback(WaveCallbacks.WC_WAVE_START, TestStart, WaveFlags.WAVE_GIDEON)
WaveHelper:AddCallback(WaveCallbacks.WC_WAVE_CHANGE, TestChange, WaveFlags.WAVE_GIDEON)
WaveHelper:AddCallback(WaveCallbacks.WC_WAVE_FINISH, TestFinish, WaveFlags.WAVE_GIDEON)