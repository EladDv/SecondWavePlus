// This is an Unreal Script
                           
class SecondWave_CommandersChoice_GameState extends SecondWave_GameStateParent config(SecondWavePlus_Settings);

var config bool bIs_CommandersChoice_Activated;
var config bool bIs_CommandersChoiceForVets_Activated;
var config array<string> ExcludedClasses;

function ObtainOptions()
{
	local SecondWave_OptionsDataStore SWDataStore;
	SWDataStore=class'SecondWave_OptionsDataStore'.static.GetInstance();	

	bIs_CommandersChoice_Activated=SWDataStore.GetValues("bIs_CommandersChoice_Activated").Bool_Value;
}

function ChangeClass (XComGameState_Unit mUnit,name ClassName)
{
    local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_Unit Unit;
	local int i,OriginalRank,OGwillCurrent,OGwillMax,OGwillShaken;
	local XComGameState_SecondWavePlus_UnitComponent SW_UnitComponent,OldUnitComp;

	if(string(ClassName) ~= string(mUnit.GetSoldierClassTemplate().DataName) || !bIs_CommandersChoice_Activated ||(!bIs_CommandersChoiceForVets_Activated && mUnit.GetRank()>1))
		return;
	
	NewGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Unit Class");
	Unit= XComGameState_Unit(NewGameState.CreateStateObject(mUnit.class,mUnit.ObjectID));
	OGwillCurrent=Unit.GetCurrentStat(eStat_Will);
	OGwillMax=Unit.GetBaseStat(eStat_Will);
	if(Unit.bIsShaken)
		OGwillShaken=Unit.SavedWillValue;
	
	if(!ReverseHiddenPotential(Unit,NewGameState))
	{
		OriginalRank=UnrankUnit(Unit,NewGameState);
		if(NewGameState.GetNumGameStateObjects()>0)
			`XCOMHISTORY.AddGameStateToHistory(NewGameState);
		else
			`XCOMHISTORY.CleanupPendingGameState(NewGameState);

		NewGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Unit Class");
		Unit= XComGameState_Unit(NewGameState.CreateStateObject(mUnit.class,mUnit.ObjectID));
	
		for(i=0;i<OriginalRank;i++)
		{
			Unit.RankUpSoldier( NewGameState, ClassName , false);

			`XEVENTMGR.TriggerEvent('HiddenPotential_ApplyUpdate',Unit,Unit,NewGameState);	
		}
	}
	else
	{
		OriginalRank=UnrankUnit(Unit,NewGameState);
		if(NewGameState.GetNumGameStateObjects()>0)
			`XCOMHISTORY.AddGameStateToHistory(NewGameState);
		else
			`XCOMHISTORY.CleanupPendingGameState(NewGameState);
		for(i=0;i<OriginalRank;i++)
		{
			NewGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Unit Class");
			Unit= XComGameState_Unit(NewGameState.CreateStateObject(mUnit.class,mUnit.ObjectID));

			Unit.RankUpSoldier( NewGameState, ClassName , false);

			`XEVENTMGR.TriggerEvent('HiddenPotential_ApplyUpdate',Unit,Unit,NewGameState);	
		}
	}
	Unit.SetBaseMaxStat(eStat_Will,OGwillMax);
	Unit.SetCurrentStat(eStat_Will,OGwillCurrent);
	if(Unit.bIsShaken)
		Unit.SavedWillValue=OGwillShaken;

	UIArmory_Promotion(`SCREENSTACK.GetFirstInstanceOf(class'UIArmory_Promotion')).Header.PopulateData(Unit);

	OldUnitComp=XComGameState_SecondWavePlus_UnitComponent(Unit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'));
	if(NewGameState!=none)
		SW_UnitComponent=XComGameState_SecondWavePlus_UnitComponent(NewGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent',OldUnitComp.ObjectID));
	NewGameState.AddStateObject(Unit);
	NewGameState.AddStateObject(SW_UnitComponent);
	
	History=`XCOMHISTORY;
	if(NewGameState.GetNumGameStateObjects()>0)
	{
		History.AddGameStateToHistory(NewGameState);
	}
	else
		History.CleanupPendingGameState(NewGameState);

	UIArmory_Promotion(`SCREENSTACK.GetFirstInstanceOf(class'UIArmory_Promotion')).PopulateData();

}

function bool ReverseHiddenPotential(XComGameState_Unit Unit,XComGameState NewGameState )
{
	local int i,MaxStat,CurrentStat;
	local HiddenPotentialStatChanges StatChange;
	local HiddenPotentialLevelChanges SingleLevelChange;
	local XComGameState_SecondWavePlus_UnitComponent SW_UnitComponent,OldUnitComp;

	OldUnitComp=XComGameState_SecondWavePlus_UnitComponent(Unit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'));
	if(NewGameState!=none)
		SW_UnitComponent=XComGameState_SecondWavePlus_UnitComponent(NewGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent',OldUnitComp.ObjectID));
	
	if(SW_UnitComponent==none || !SW_UnitComponent.GetHasGot_HiddenPotential())
	{
		`XEVENTMGR.TriggerEvent('HiddenPotential_Start',Unit,Unit,NewGameState);			
		return false;
	}
	for(i=0;i<Unit.GetRank();i++)
	{
		SingleLevelChange=SW_UnitComponent.GetSpecificLevelChanges(i);
		foreach SingleLevelChange.StatChanges(StatChange)
		{
			MaxStat=Unit.GetMaxStat(StatChange.StatType);
			CurrentStat=Unit.GetCurrentStat(StatChange.StatType);
			Unit.SetBaseMaxStat(StatChange.StatType,MaxStat-StatChange.Change);
			Unit.SetCurrentStat(StatChange.StatType,CurrentStat-StatChange.Change);
		}
	}	
	SW_UnitComponent.SetHasGot_HiddenPotential(false);
	return true;
}

function int UnrankUnit(XComGameState_Unit Unit,XComGameState NewGameState)
{
	//local array<SoldierClassRank> SoldierClassRanks;
	local array<int> MaxSoldierStats;
	local array<int> CurrentSoldierStats;
	local array<SoldierClassStatType> SoldierClassProgressions;
	local SoldierClassStatType SingleSoldierClassProgression;
	local int i,SaveRank,MaxStat,CurrentStat;
	local XComGameState_SecondWavePlus_UnitComponent SW_UnitComponent,OldUnitComp;

	SaveRank=Unit.GetRank();
	for(i=0;i<Unit.GetRank();i++)
	{
		SoldierClassProgressions=Unit.GetSoldierClassTemplate().GetStatProgression(i);
		foreach SoldierClassProgressions(SingleSoldierClassProgression)
		{
			MaxStat=Unit.GetMaxStat(SingleSoldierClassProgression.StatType);
			CurrentStat=Unit.GetCurrentStat(SingleSoldierClassProgression.StatType);
			Unit.SetBaseMaxStat(SingleSoldierClassProgression.StatType,MaxStat-SingleSoldierClassProgression.StatAmount);
			Unit.SetCurrentStat(SingleSoldierClassProgression.StatType,CurrentStat-SingleSoldierClassProgression.StatAmount);
		}
	}
	for(i = 0; i < eStat_MAX; i++)
	{
		MaxSoldierStats.AddItem(Unit.GetMaxStat(ECharStatType(i)));
		CurrentSoldierStats.AddItem(Unit.GetCurrentStat(ECharStatType(i)));
	}
	Unit.ResetSoldierAbilities();
	Unit.ResetRankToRookie();
	for(i = 0; i < eStat_MAX; i++)
	{
		Unit.SetBaseMaxStat(ECharStatType(i),MaxSoldierStats[i]);
		Unit.SetCurrentStat(ECharStatType(i),CurrentSoldierStats[i]);
		`log("Unit Base Stats"@ECharStatType(i) @"Max Stat:" @MaxSoldierStats[i] @"Current Stat:"@CurrentSoldierStats[i],,'Second Wave Plus-Commanders Choice');
	}
	NewGameState.AddStateObject(Unit);
	OldUnitComp=XComGameState_SecondWavePlus_UnitComponent(Unit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'));
	if(NewGameState!=none)
		SW_UnitComponent=XComGameState_SecondWavePlus_UnitComponent(NewGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent',OldUnitComp.ObjectID));
	NewGameState.AddStateObject(SW_UnitComponent);
	
	return SaveRank;
}