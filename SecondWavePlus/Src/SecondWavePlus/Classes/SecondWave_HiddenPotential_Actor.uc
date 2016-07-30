// This is an Unreal Script
                           
class SecondWave_HiddenPotential_Object extends SecondWave_ObjectParent config(SecondWavePlus_Settings);

var config int HiddenPotentialRandomPercentage;
var config bool bIs_HiddenPotential_Activated;

function AddHiddenPotentialToUnit(XComGameState_Unit Unit)
{
	local XComGameState_SecondWavePlus_UnitComponent SW_UnitComponent;
	local XComGameState NewGameState;
	local SecondWave_HiddenPotentialStatHolder_Object NewHolder;
	SW_UnitComponent=XComGameState_SecondWavePlus_UnitComponent(Unit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'));
	if(SW_UnitComponent.GetHiddenPotentialHolder()==none)
	{
		NewHolder=new class'SecondWave_HiddenPotentialStatHolder_Object';
		SW_UnitComponent.SetHiddenPotentialHolder(NewHolder);
		SW_UnitComponent.SetHiddenPotentialLevelChanges(CreateHiddenPotentialRanks(Unit));
		SW_UnitComponent.SetHasGot_HiddenPotential(True);
	}	
	else
	{
		SW_UnitComponent.SetHiddenPotentialLevelChanges(CreateHiddenPotentialRanks(Unit));
		SW_UnitComponent.SetHasGot_HiddenPotential(True);
	}
	NewGameState.AddStateObject(SW_UnitComponent);
	
}
function array<HiddenPotentialLevelChanges> CreateHiddenPotentialRanks(XComGameState_Unit Unit)
{
	local array<HiddenPotentialLevelChanges> ToRetArray;
	local HiddenPotentialLevelChanges TempLevelChange;
	local HiddenPotentialStatChanges TempStatChange;
	local array<SoldierClassStatType> SoldierClassProgressions;
	local SoldierClassStatType SingleSoldierClassProgression;
	local int i;
	ToRetArray.Add(Unit.GetSoldierClassTemplate().GetMaxConfiguredRank());
	for(i=0;i<Unit.GetSoldierClassTemplate().GetMaxConfiguredRank();i++)
	{
		ToRetArray[i].Level=i;
		SoldierClassProgressions=Unit.GetSoldierClassTemplate().GetStatProgression(i);
		foreach SoldierClassProgressions(SingleSoldierClassProgression)
		{
			TempStatChange.StatType=eStat_MAX;
			TempStatChange.Change=0;
			TempStatChange.StatType=SingleSoldierClassProgression.StatType;
			TempStatChange.Change=GetRandomSign()*`SYNC_RAND(SingleSoldierClassProgression.StatAmount*HiddenPotentialRandomPercentage);
			ToRetArray[i].StatChanges.AddItem(TempStatChange);
		}
	}
	return ToRetArray;
}

function int GetRandomSign()
{
	int i;
	i=`SYNC_RAND(1);
	if(i==0)
		i=-1;
	return i;	
}