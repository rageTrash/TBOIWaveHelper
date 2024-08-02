# Wave Helper Content


## WaveType

Info : This can be access in `WaveHelper.WaveType`
<br>

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
<br>
<br>

## Functions
Info : This can be access in `WaveHelper`.
<br>

### GetVersion ()
#### int GetVersion ()
Returns the version of `WaveHelper`.
<br>Can be access too by `WaveHelper.Version`.
<br>

### AddCallback ()
#### void AddCallback ([WaveCallbacks](README.md#wavecallbacks), function Function, int ExtraParam, CallbackPriority)
<br>

### RemoveCallback ()
#### void RemoveCallback ([WaveCallbacks](README.md#wavecallbacks), function Function)
<br>

### RunCallback ()
#### void RunCallback ([WaveCallbacks](README.md#wavecallbacks), int ExtraParam, arg1, arg2)
<br>

### GetWave ()
#### int GetWave ()
Returns the concurrent wave in the room or in greed mode
<br>

### IsValidWaveRoom ()
#### boolean IsValidWaveRoom ()
Checks if the concurrent room can have waves.
<br>Returns `false` if is greed mode.
<br>

### IsGreedMainRoom ()
#### boolean IsGreedMainRoom ()
Checks if is the main room of greed mode.
<br>Returns `false` if is not greed mode or the ultra greed floor.
<br>
<br>

## WaveCallbacks

Info : This can be access in `WaveHelper.WaveCallbacks`.
<br>Warning : `WaveType.WAVE_GIDEON` doesn't run if the `WaveType` is `nil`.
<br>

### WC_WAVE_START

|ID|Name|Function Args|Optional Args|
|:--|:--|:--|:--|
|1 |WC_WAVE_START | (int CurrentWaveNum, <br>[WaveType](README.md#wavetype)) | [WaveType](README.md#wavetype) |
<br>

### WC_WAVE_CHANGE

|ID|Name|Function Args|Optional Args|
|:--|:--|:--|:--|
|2 |WC_WAVE_CHANGE | (int CurrentWaveNum, <br>[WaveType](README.md#wavetype)) | [WaveType](README.md#wavetype) |
<br>

### WC_WAVE_CLEAR

|ID|Name|Function Args|Optional Args|
|:--|:--|:--|:--|
|3 |WC_WAVE_CLEAR | (int CurrentWaveNum, <br>[WaveType](README.md#wavetype)) | [WaveType](README.md#wavetype) |

Info : This callback may rarely run in greed mode.
<br>

### WC_WAVE_FINISH

|ID|Name|Function Args|Optional Args|
|:--|:--|:--|:--|
|4 |WC_WAVE_FINISH | (int CurrentWaveNum, <br>[WaveType](README.md#wavetype)) | [WaveType](README.md#wavetype) |



