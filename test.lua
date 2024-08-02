include("waveHelper")

local WaveType = WaveHelper.WaveType
local WaveCallbacks = WaveHelper.WaveCallbacks

local TypeToName = {
	[WaveType.ALL_WAVES] = "All",
	[WaveType.WAVE_CHALLENGE] = "Challenge",
	[WaveType.WAVE_CHALLENGE_NORMAL] = "Normal Challenge",
	[WaveType.WAVE_CHALLENGE_BOSS] = "Boss Challenge",
	[WaveType.WAVE_BOSSRUSH] = "Boss Rush",
	[WaveType.WAVE_GREED] = "Greed",
	[WaveType.WAVE_GREED_NORMAL] = "Normal Greed",
	[WaveType.WAVE_GREED_BOSS] = "Boss Greed",
	[WaveType.WAVE_GREED_EXTRABOSS] = "Deal Boss Greed",
	[WaveType.WAVE_GIDEON] = "Gideon",
}

local function FlagsToName(wType)
	return " " .. (TypeToName[wType] or "Unknow")
end


local function TestStart(_, waveNum, wType)
	print((FlagsToName(wType) .." Wave Started ".. waveNum))
end
local function TestClear(_, waveNum, wType)
	print((FlagsToName(wType) .." Clear Wave ".. waveNum))
end
local function TestChange(_, waveNum, wType)
	print((FlagsToName(wType) .." Wave ".. waveNum))
end
local function TestFinish(_, waveNum, wType)
	print((FlagsToName(wType) .." Wave Finish ".. waveNum))
end


WaveHelper:AddCallback(WaveCallbacks.WC_WAVE_START, TestStart)
WaveHelper:AddCallback(WaveCallbacks.WC_WAVE_CLEAR, TestClear)
WaveHelper:AddCallback(WaveCallbacks.WC_WAVE_CHANGE, TestChange)
WaveHelper:AddCallback(WaveCallbacks.WC_WAVE_FINISH, TestFinish)


WaveHelper:AddCallback(WaveCallbacks.WC_WAVE_START, function()
	print("Gideon Start Check")
end, WaveType.WAVE_GIDEON)
WaveHelper:AddCallback(WaveCallbacks.WC_WAVE_CLEAR, function()
	print("Gideon Wave Clear")
end, WaveType.WAVE_GIDEON)
WaveHelper:AddCallback(WaveCallbacks.WC_WAVE_CHANGE, function(_, waveNum)
	print(("Gideon Wave Change "..waveNum))
end, WaveType.WAVE_GIDEON)
WaveHelper:AddCallback(WaveCallbacks.WC_WAVE_FINISH, function()
	print("Gideon Wave Finish")
end, WaveType.WAVE_GIDEON)