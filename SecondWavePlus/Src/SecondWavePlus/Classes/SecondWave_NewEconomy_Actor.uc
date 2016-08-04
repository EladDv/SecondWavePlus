// This is an Unreal Script
                           
class SecondWave_NewEconomy_Actor extends SecondWave_ActorParent config(SecondWavePlus_Settings);

var config bool b_IsNewEconomyActive;
var config float NewEconomyRandomFraction;

function CreateNewEconomy(Optional XComGameState NewGameState)
{
	local XComGameState_WorldRegion CurrentRegion;
	local int AddedRegionIncome;
	
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_WorldRegion',CurrentRegion)
	{
		AddedRegionIncome=Round(CurrentRegion.BaseSupplyDrop*GetRandomMultiplier());
		CurrentRegion.ModifyBaseSupplyDrop(AddedRegionIncome);
		NewGameState.AddStateObject(CurrentRegion);
	}
}

function float GetRandomMultiplier()
{
	local float ToRet;
	local int TempMultiplier;
	do
	{
		ToRet= FRAND()*Ceil(NewEconomyRandomPrecentage);
	}Until(ToRet<=NewEconomyRandomPrecentage);
	return ToRet*GetRandomSign();
}