# Wave Helper Content


## WaveType

Info : This can be access in `WaveHelper.WaveType`


|Value|Enumerator|Comment|
|:--|:--|:--|
|-1 |ALL_WAVES |  |
|0 |WAVE_CHALLENGE |  |
|1 |WAVE_CHALLENGE_NORMAL |  |
|2 |WAVE_CHALLENGE_BOSS |  |
|10 |WAVE_BOSSRUSH |  |
|20 |WAVE_GREED |  |
|21 |WAVE_GREED_NORMAL |  |
|22 |WAVE_GREED_BOSS |  |
|23 |WAVE_GREED_EXTRABOSS |  |
|23 |WAVE_GREED_DEALBOSS |  |
|30 |WAVE_GIDEON |  |


## Functions

Info : This can be access in `WaveHelper`


### GetVersion ()
#### int GetVersion ()
Returns the version of `WaveHelper`
Can be access too by `WaveHelper.Version`


### AddCallback ()
#### void AddCallback ([WaveCallbacks](README.md#wavecallbacks), function Function, int ExtraParam, CallbackPriority)


### RemoveCallback ()
#### void RemoveCallback ([WaveCallbacks](README.md#wavecallbacks), function Function)


### RunCallback ()
#### void RunCallback ([WaveCallbacks](README.md#wavecallbacks), int ExtraParam, arg1, arg2)


### GetWave ()
#### int GetWave ()
Returns the concurrent wave in the room or in greed mode


### IsValidWaveRoom ()
#### boolean IsValidWaveRoom ()
Checks if the concurrent room can have waves
Returns `false` if is greed mode


### IsGreedMainRoom ()
#### boolean IsGreedMainRoom ()
Checks if is the main room of greed mode
Returns `false` if is not greed mode or the ultra greed floor



## WaveCallbacks

Info : This can be access in `WaveHelper.WaveCallbacks`

Warning : `WaveType.WAVE_GIDEON` doesn't run if the `WaveType` is `nil` 


### WC_WAVE_START

|ID|Name|Function Args|Optional Args|
|:--|:--|:--|:--|
|1 |WC_WAVE_START | ([WaveType](README.md#wavetype)) | [WaveType](README.md#wavetype) |


### WC_WAVE_CHANGE

|ID|Name|Function Args|Optional Args|
|:--|:--|:--|:--|
|2 |WC_WAVE_CHANGE | (int CurrentWaveNum, <br>[WaveType](README.md#wavetype)) | [WaveType](README.md#wavetype) |


### WC_WAVE_CLEAR

|ID|Name|Function Args|Optional Args|
|:--|:--|:--|:--|
|3 |WC_WAVE_CLEAR | (int CurrentWaveNum, <br>[WaveType](README.md#wavetype)) | [WaveType](README.md#wavetype) |

Info : This callback may rarely run in greed mode.


### WC_WAVE_FINISH

|ID|Name|Function Args|Optional Args|
|:--|:--|:--|:--|
|4 |WC_WAVE_FINISH | ([WaveType](README.md#wavetype)) | [WaveType](README.md#wavetype) |



