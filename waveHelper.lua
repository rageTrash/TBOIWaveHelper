local VERSION = 2.6


if WaveHelper and WaveHelper.Version ~= nil and WaveHelper.Version >= VERSION then return end

WaveHelper = WaveHelper or {}
WaveHelper.Version = VERSION
WaveHelper.SaveData = WaveHelper.SaveData or {}

if WaveHelper.Mod == nil then WaveHelper.Mod = RegisterMod("WaveHelper", 1) end
local Mod = WaveHelper.Mod

if WaveHelper.Game == nil then WaveHelper.Game = Game() end
local game = WaveHelper.Game


WaveHelper.WaveType = {
	ALL_WAVES = -1,
	WAVE_CHALLENGE = 0,
	WAVE_CHALLENGE_NORMAL = 1,
	WAVE_CHALLENGE_BOSS = 2,
	WAVE_BOSSRUSH = 10,
	WAVE_GREED = 20,
	WAVE_GREED_NORMAL = 21,
	WAVE_GREED_BOSS = 22,
	WAVE_GREED_EXTRABOSS = 23, WAVE_GREED_DEALBOSS = 23,-- extra boss fight in Greed mode
	WAVE_GIDEON = 30,
}


WaveHelper.WaveCallbacks = {
	WC_WAVE_START = 1,
	WC_WAVE_CHANGE = 2,
	WC_WAVE_CLEAR = 3,
	WC_WAVE_FINISH = 4,
}


local WaveType = WaveHelper.WaveType
local WaveCallbacks = WaveHelper.WaveCallbacks

WaveHelper._callbacks = WaveHelper._callbacks or {
	[1] = {}, [2] = {}, [3] = {}, [4] = {},
}

local json = include("json")

local function IsOldVersion() return VERSION < WaveHelper.Version end



local WaveGroupTypes = {
	[WaveType.WAVE_CHALLENGE] = {
		[WaveType.WAVE_CHALLENGE_NORMAL] = true,
		[WaveType.WAVE_CHALLENGE_BOSS] = true,
	},
	[WaveType.WAVE_CHALLENGE_NORMAL] = { [WaveType.WAVE_CHALLENGE] = true },
	[WaveType.WAVE_CHALLENGE_BOSS] = { [WaveType.WAVE_CHALLENGE] = true },
	[WaveType.WAVE_GREED] = {
		[WaveType.WAVE_GREED_NORMAL] = true,
		[WaveType.WAVE_GREED_BOSS] = true,
		[WaveType.WAVE_GREED_EXTRABOSS] = true,
	},
	[WaveType.WAVE_GREED_NORMAL] = { [WaveType.WAVE_GREED] = true},
	[WaveType.WAVE_GREED_BOSS] = {
		[WaveType.WAVE_GREED] = true,
		[WaveType.WAVE_GREED_EXTRABOSS] = true,
	},
	[WaveType.WAVE_GREED_EXTRABOSS] = { [WaveType.WAVE_GREED] = true },
}



local function CheckGroupType(callParam, param)
	if callParam == -1 or param == -1 or callParam == param then return true end
	if not WaveGroupTypes[callParam] then return false end
	return WaveGroupTypes[callParam][param] == true
end



local function LoadData(_, continued)
	if not continued then
		WaveHelper.SaveData = {}
		return
	end

	WaveHelper.SaveData = json.decode(Mod:LoadData()) or {}
end
local function SaveData()
	Mod:SaveData(json.encode(WaveHelper.SaveData))
end

Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, LoadData)
Mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, SaveData)
Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, SaveData)




function WaveHelper:GetVersion() return WaveHelper.Version end


function WaveHelper:AddCallback(callback, fun, param, priority)
	local priority = priority or 0
	local callbacks = WaveHelper._callbacks[callback] or {}

	local pos = #callbacks +1
	for i=#callbacks, 1, -1 do
		if callbacks[i].priority <= priority then
			break
		else
			pos = pos-1
		end
	end

	table.insert(WaveHelper._callbacks[callback], pos, {fun = fun, param= param, priority = priority})
end

function WaveHelper:RemoveCallback(callback, fun)
	for i =#WaveHelper._callbacks[callback], 1, -1 do
		if WaveHelper._callbacks[callback][i].fun == fun then
			table.remove(WaveHelper._callbacks[callback], i)
			return
		end
	end
end

function WaveHelper:RunCallback(callback, param, ...)
	local callbacks = WaveHelper._callbacks[callback] or {}

	if param and param == WaveType.WAVE_GIDEON then
		for _, call in ipairs(callbacks) do	
			if call.param and CheckGroupType(call.param, param) then
				call.fun({}, ...)
			end
			
		end	
		return
	end

	for _, call in ipairs(callbacks) do
		if not call.param or not param or (call.param ~= WaveType.WAVE_GIDEON and CheckGroupType(call.param, param)) then
			call.fun({}, ...)
		end
		
	end
end



function WaveHelper:GetWave()
	if game:IsGreedMode() then
		return game:GetLevel().GreedModeWave
	end
	return WaveHelper.SaveData.WaveCount or 0
end

function WaveHelper:IsValidWaveRoom()
	if game:IsGreedMode() then return false end
	local roomData = game:GetLevel():GetCurrentRoomDesc().Data
	local rType = roomData.Type
	return (rType == RoomType.ROOM_CHALLENGE or
			rType == RoomType.ROOM_BOSSRUSH or
			(rType == RoomType.ROOM_BOSS and roomData.Subtype == 83))
end

function WaveHelper:IsGreedMainRoom()
	if game:GetLevel():GetStage() == 7 then return false end
	return game:IsGreedMode() and game:GetLevel():GetCurrentRoomIndex() == 84
end



local function CheckNRunCallback(callID, check, waveType, arg1, arg2, doAfter)
	if not check or not check() then return end
	WaveHelper:RunCallback(callID, waveType, arg1, arg2)

	if doAfter then doAfter() end
end


local EnemieCount = 0
local function Waves()
	local room = game:GetRoom()
	local rType = room:GetType()
	local IsGideon = false
	local wType = 0
	local conEnemies = 0

	local start = function() return not WaveHelper.SaveData.WaveStarted and room:IsAmbushActive() end
	local finish = function() return WaveHelper.SaveData.WaveStarted and room:IsAmbushDone() end

	if rType == RoomType.ROOM_CHALLENGE then
		wType = WaveType.WAVE_CHALLENGE_NORMAL
		if game:GetLevel():HasBossChallenge() then wType = WaveType.WAVE_CHALLENGE_BOSS end

		conEnemies = Isaac.CountEnemies()

	elseif rType == RoomType.ROOM_BOSSRUSH then
		wType = WaveType.WAVE_BOSSRUSH
		conEnemies = Isaac.CountBosses()

	elseif rType == RoomType.ROOM_BOSS and game:GetLevel():GetCurrentRoomDesc().Data.Subtype == 83 then
		wType = WaveType.WAVE_GIDEON
		conEnemies = Isaac.CountEnemies() - #Isaac.FindByType(EntityType.ENTITY_GIDEON)

		start = function() return not WaveHelper.SaveData.WaveStarted and not room:IsClear() end
		finish = function() return WaveHelper.SaveData.WaveStarted and room:IsClear() end
	end


	local WaveNum = WaveHelper.SaveData.WaveCount or 0
	CheckNRunCallback(WaveCallbacks.WC_WAVE_START,
		start,
		wType,
		WaveNum, wType,
		function()
			WaveHelper.SaveData.WaveStarted = true
			WaveHelper.SaveData.WaveCount = WaveNum +1
		end)

	CheckNRunCallback(WaveCallbacks.WC_WAVE_CLEAR,
		function() return conEnemies == 0 and EnemieCount > conEnemies end,
		wType,
		WaveNum-1, wType)

	CheckNRunCallback(WaveCallbacks.WC_WAVE_CHANGE,
		function() return EnemieCount == 0 and EnemieCount < conEnemies end,
		wType,
		WaveNum, wType,
		function()
			WaveHelper.SaveData.WaveCount = WaveNum +1
		end)

	CheckNRunCallback(WaveCallbacks.WC_WAVE_FINISH,
		finish,
		wType,
		WaveNum-1, wType,
		function()
			WaveHelper.SaveData = {}
		end)

	EnemieCount = conEnemies
end

local GreedLastWave = 0
local lastRoomClearState = true
local function WavesGreed()
	local conGreedWave = game:GetLevel().GreedModeWave
	local wType = WaveType.WAVE_GREED_NORMAL

	if conGreedWave >= game:GetGreedBossWaveNum() then
		if conGreedWave == game:GetGreedBossWaveNum() +2 then
			wType = WaveType.WAVE_GREED_EXTRABOSS
		else
			wType = WaveType.WAVE_GREED_BOSS
		end
	end

	local conRoomClear = game:GetRoom():IsClear()

	CheckNRunCallback(WaveCallbacks.WC_WAVE_START,
		function() return lastRoomClearState and not conRoomClear end,
		wType,
		conGreedWave, wType)

	CheckNRunCallback(WaveCallbacks.WC_WAVE_CLEAR,
		function() return not lastRoomClearState and conRoomClear and conGreedWave == GreedLastWave end,
		wType,
		conGreedWave, wType)

	CheckNRunCallback(WaveCallbacks.WC_WAVE_CHANGE,
		function() return not conRoomClear and conGreedWave > GreedLastWave end,
		wType,
		conGreedWave, wType,
		function() GreedLastWave = conGreedWave end)

	CheckNRunCallback(WaveCallbacks.WC_WAVE_FINISH,
		function() return not lastRoomClearState and conRoomClear end,
		wType,
		conGreedWave, wType)

	lastRoomClearState = conRoomClear
end


local function WaveUpdate()
	if WaveHelper:IsGreedMainRoom() then WavesGreed()
	elseif WaveHelper:IsValidWaveRoom() then Waves()
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, WaveUpdate)

local function OnNewRoom()
	if game:IsGreedMode() then
		lastRoomClearState = true
		return
	end
	if not WaveHelper:IsValidWaveRoom() then return end
	LastWave = 0
	EnemieCount = 0
	WaveHelper.SaveData = {}
end
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, OnNewRoom)


local function ResetWaveGreed()
	GreedLastWave = 0
	lastRoomClearState = true
end
Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, ResetWaveGreed)


local function PostLoad()
	if not IsOldVersion() then
		print( ("WaveHelper Version ".. WaveHelper.Version.." has been set up") )
		Mod:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED, PostLoad)
		return
	end
	Mod:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED, LoadData)
	Mod:RemoveCallback(ModCallbacks.MC_PRE_GAME_EXIT, SaveData)
	Mod:RemoveCallback(ModCallbacks.MC_POST_NEW_LEVEL, SaveData)

	Mod:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED, PostLoad)

	Mod:RemoveCallback(ModCallbacks.MC_POST_UPDATE, WaveUpdate)
	Mod:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM, OnNewRoom)
	Mod:RemoveCallback(ModCallbacks.MC_POST_NEW_LEVEL, ResetWaveGreed)
end
Mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, 2^16, PostLoad)

