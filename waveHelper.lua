local VERSION = 2


if WaveHelper and WaveHelper.Version ~= nil and WaveHelper.Version >= VERSION then return end

WaveHelper = WaveHelper or {}
WaveHelper.Version = VERSION
WaveHelper.SaveData = WaveHelper.SaveData or {}

if WaveHelper.Mod == nil then WaveHelper.Mod = RegisterMod("WaveHelper", 1) end
local Mod = WaveHelper.Mod

if WaveHelper.Game == nil then WaveHelper.Game = Game() end
local game = WaveHelper.Game



WaveHelper.WaveFlags = {
	WAVE_CHALLENGE = 1 << 0, -- Challenge room
	WAVE_NORMAL = 1 << 1,	-- Wave type
	WAVE_BOSS = 1 << 2,		-- Wave type
	WAVE_BOSSRUSH = 1 << 3,	-- Boss rush room
	WAVE_GREED = 1 << 4,	-- Greed mode
	WAVE_GIDEON = 1 << 5,	-- Gideon boss room
}
WaveHelper.WaveFlags.ALL_WAVE = (1 << 6) -1 - ( WaveHelper.WaveFlags.WAVE_NORMAL | WaveHelper.WaveFlags.WAVE_BOSS )

WaveHelper.WaveCallbacks = {
	WC_WAVE_START = 1,
	WC_WAVE_CHANGE = 2,
	WC_WAVE_FINISH = 3,
}


local WaveFlags = WaveHelper.WaveFlags
local WaveCallbacks = WaveHelper.WaveCallbacks

WaveHelper._callbacks = WaveHelper._callbacks or {
	[1] = {}, [2] = {}, [3] = {}, [4] = {},
}

local json = include("json")

local function IsOldVersion() return VERSION < WaveHelper.Version end


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

	--print(( "Callback : "..callback.." Function : ".. tostring(fun) .." Param : ".. tostring(param) .." Priority : ".. priority))
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
	--print( ("Callback ID : ".. callback .."\nWave Flags : ".. tostring(param)) )
	local callbacks = WaveHelper._callbacks[callback] or {}

	if param and (param & WaveFlags.WAVE_GIDEON) > 0 then
		for _, call in ipairs(callbacks) do	
			if call.param and (call.param & param) > 0 then
				call.fun({}, ...)
			end
			
		end	
		return
	end

	for _, call in ipairs(callbacks) do
		if not call.param or not param or (call.param & param) > 0 then
			call.fun({}, ...)
		end
		
	end
end



function WaveHelper:GetWave()
	return WaveHelper.SaveData.WaveCount or 0
end


function WaveHelper:IsValidWaveRoom()
	local rType = game:GetRoom():GetType()
	return (rType == RoomType.ROOM_CHALLENGE or
			rType == RoomType.ROOM_BOSSRUSH or
			(rType == RoomType.ROOM_BOSS and #Isaac.FindByType(EntityType.ENTITY_GIDEON) > 0))
end


local LastWave = 0
local EnemieCount = 0
local function Waves()
	local room = game:GetRoom()
	local rType = room:GetType()
	local IsGideon = false
	local wFlags = 0
	local conEnemies = 0

	if rType == RoomType.ROOM_CHALLENGE then
		wFlags = WaveFlags.WAVE_CHALLENGE
		wFlags = wFlags | (game:GetLevel():HasBossChallenge() and WaveFlags.WAVE_BOSS or WaveFlags.WAVE_NORMAL)
		conEnemies = Isaac.CountEnemies()

	elseif rType == RoomType.ROOM_BOSSRUSH then
		wFlags = WaveFlags.WAVE_BOSSRUSH
		conEnemies = Isaac.CountBosses()

	elseif rType == RoomType.ROOM_BOSS and #Isaac.FindByType(EntityType.ENTITY_GIDEON) > 0 then
		wFlags = WaveFlags.WAVE_GIDEON
		conEnemies = Isaac.CountEnemies() - #Isaac.FindByType(EntityType.ENTITY_GIDEON)
		IsGideon = true
	end


	local WaveNum = WaveHelper.SaveData.WaveCount or 0
	if not WaveHelper.SaveData.WaveStarted and (room:IsAmbushActive() or ( IsGideon and not room:IsClear() )) then
		WaveHelper:RunCallback(WaveCallbacks.WC_WAVE_START, wFlags, wFlags)
		WaveHelper.SaveData.WaveStarted = true
		WaveHelper.SaveData.WaveCount = WaveNum +1
	end

	--print(("EnemieCount : ".. EnemieCount .." | ConcurrentEnemies : ".. conEnemies))
	if EnemieCount == 0 and EnemieCount < conEnemies then
		WaveHelper:RunCallback(WaveCallbacks.WC_WAVE_CHANGE, wFlags, WaveNum, wFlags)
		LastWave = WaveNum
		WaveHelper.SaveData.WaveCount = WaveNum +1
	end

	if WaveHelper.SaveData.WaveStarted and (room:IsAmbushDone() or ( IsGideon and room:IsClear() )) then
		WaveHelper:RunCallback(WaveCallbacks.WC_WAVE_FINISH, wFlags, wFlags)
		WaveHelper.SaveData = {}
	end

	EnemieCount = conEnemies
end

local GreedLastWave = 0
local lastRoomClearState = true
local function WavesGreed()
	local conGreedWave = game:GetLevel().GreedModeWave
	local wFlags = WaveFlags.WAVE_GREED
	wFlags = wFlags | ( (conGreedWave >= game:GetGreedBossWaveNum()) and WaveFlags.WAVE_BOSS or WaveFlags.WAVE_NORMAL )
	local conRoomClear = game:GetRoom():IsClear()

	if lastRoomClearState and not conRoomClear then
		WaveHelper:RunCallback(WaveCallbacks.WC_WAVE_START, wFlags, wFlags)
	end

	if not conRoomClear and conGreedWave > GreedLastWave then
		WaveHelper:RunCallback(WaveCallbacks.WC_WAVE_CHANGE, wFlags, conGreedWave, wFlags)
		GreedLastWave = conGreedWave
	end

	if not lastRoomClearState and conRoomClear then
		WaveHelper:RunCallback(WaveCallbacks.WC_WAVE_FINISH, wFlags, wFlags)
	end

	lastRoomClearState = conRoomClear
end


function WaveUpdate()
	if game:IsGreedMode() then
		if game:GetLevel():GetCurrentRoomIndex() == 84 then WavesGreed() end
	elseif WaveHelper:IsValidWaveRoom() then
		Waves()
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

