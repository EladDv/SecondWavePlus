// This is an Unreal Script
                           
class SecondWave_UIScreenSettings_GameState extends SecondWave_GameStateParent  config(SecondWavePlus_Settings);

var config array<UIRanges> StatChangeRanges;
var config array<UIRanges> RedFogChangeRanges;

function ObtainOptions()
{
	local SecondWave_OptionsDataStore SWDataStore;
	SWDataStore=class'SecondWave_OptionsDataStore'.static.GetInstance();	
	
	StatChangeRanges=SWDataStore.StatChangesRanges;
	RedFogChangeRanges=SWDataStore.RedFogChangeRanges;
}