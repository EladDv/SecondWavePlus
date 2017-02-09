// This is an Unreal Script
                           
class SecondWave_NewEconomy_GameState extends SecondWave_GameStateParent config(SecondWavePlus_Settings);

var config bool b_IsNewEconomyActive;
var config float NewEconomyMaxRandomPercentage;
var config int MinimalRegionIncome;

var bool RandomisedEcon;

function ObtainOptions()
{
	local SecondWave_OptionsDataStore SWDataStore;
	SWDataStore=class'SecondWave_OptionsDataStore'.static.GetInstance();	

	b_IsNewEconomyActive=SWDataStore.GetValues("b_IsNewEconomyActive").Bool_Value;
	MinimalRegionIncome=SWDataStore.GetValues("MinimalRegionIncome").Int_Value;
	NewEconomyMaxRandomPercentage=SWDataStore.GetValues("NewEconomyMaxRandomPercentage").Float_Value;

}

function CreateNewEconomy(Optional XComGameState NewGameState)
{
	local XComGameState_WorldRegion CurrentRegion;
	local int AddedRegionIncome;
	local int NewIncome;
	local SecondWave_RandomizerActor RandActor;
	if(!b_IsNewEconomyActive || NewEconomyMaxRandomPercentage==0||RandomisedEcon)
		return;

	RandActor=`SCREENSTACK.GetCurrentScreen().Spawn(class'SecondWave_RandomizerActor',`SCREENSTACK.GetCurrentScreen());
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_WorldRegion',CurrentRegion)
	{
		
		AddedRegionIncome=Round(CurrentRegion.BaseSupplyDrop*RandActor.GetRandomMultiplier(NewEconomyMaxRandomPercentage));
		`log("CurrentRegion:"@CurrentRegion.GetDisplayName() @",Old Income:"@CurrentRegion.BaseSupplyDrop @"New Income:"@AddedRegionIncome,,'Second Wave Plus-New Economy');
		NewIncome=CurrentRegion.BaseSupplyDrop+AddedRegionIncome;
		CurrentRegion.BaseSupplyDrop=max(MinimalRegionIncome,NewIncome);
		NewGameState.AddStateObject(CurrentRegion);
	}

	RandActor.Destroy();

	RandomisedEcon=true;
}

function float GetRandomMultiplier()
{
	local float ToRet,RandomF;
	RandomF=RandRange(0.0,NewEconomyMaxRandomPercentage/100.0);
	ToRet=RandomF*float(GetRandomSign());
	return ToRet;
}