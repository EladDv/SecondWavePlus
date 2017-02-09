// This is an Unreal Script
                           
class SecondWave_HiddenPotential_GameState extends SecondWave_GameStateParent config(SecondWavePlus_Settings);

var config int HiddenPotentialRandomPercentage;
var config bool bIs_HiddenPotential_Activated;
var config array<string> ExcludedClasses;

function InitListeners()
{
	local Object Myself;

	Myself=self;
	`XEVENTMGR.RegisterForEvent(Myself,'HiddenPotential_Start',HiddenPotentialStart, , , ,true);
	`XEVENTMGR.RegisterForEvent(Myself,'HiddenPotential_ApplyUpdate',HiddenPotentialApplyUpdate, , , ,true);
}

function ObtainOptions()
{
	local SecondWave_OptionsDataStore SWDataStore;
	SWDataStore=class'SecondWave_OptionsDataStore'.static.GetInstance();	

	bIs_HiddenPotential_Activated=SWDataStore.GetValues("bIs_HiddenPotential_Activated").Bool_Value;
	HiddenPotentialRandomPercentage=SWDataStore.GetValues("HiddenPotentialRandomPercentage").Int_Value;

}

function EventListenerReturn HiddenPotentialStart(Object EventData, Object EventSource, XComGameState NewGameState, Name InEventID)
{
	if(bIs_HiddenPotential_Activated)
		AddHiddenPotentialToUnit(XComGameState_Unit(EventSource),NewGameState);
	return ELR_NoInterrupt;
}
function XComGameState_SecondWavePlus_UnitComponent AddHiddenPotentialToUnit(XComGameState_Unit Unit,Optional XComGameState NewGameState)
{
	local XComGameState_SecondWavePlus_UnitComponent SW_UnitComponent,OldUnitComp;
	local XComGameState BackupGameState;
	OldUnitComp=XComGameState_SecondWavePlus_UnitComponent(Unit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'));
	if(NewGameState!=none)
		SW_UnitComponent=XComGameState_SecondWavePlus_UnitComponent(NewGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent',OldUnitComp.ObjectID));
	else
	{
		BackupGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Unit Adding Hidden Potential");
		SW_UnitComponent=XComGameState_SecondWavePlus_UnitComponent(BackupGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent',OldUnitComp.ObjectID));
	}
	`log("Testing:"@!SW_UnitComponent.GetHasGot_HiddenPotential() @Unit.GetFullName(),,'Second Wave Plus-Hidden Potential');

	if(!SW_UnitComponent.GetHasGot_HiddenPotential())
	{
		SW_UnitComponent.SetHasGot_HiddenPotential(True);
		SW_UnitComponent.LastUpdatedLevel=0;
		if(NewGameState==none)
		{
			BackupGameState.AddStateObject(SW_UnitComponent);
			if(BackupGameState.GetNumGameStateObjects()>0)
				`XCOMHistory.AddGameStateToHistory(BackupGameState);
			else
				`XCOMHistory.CleanupPendingGameState(BackupGameState);
		}
		else
		{
			`log("Testing 2:" @Unit.GetFullName(),,'Second Wave Plus-Hidden Potential');
			if(SW_UnitComponent!=none)
				NewGameState.AddStateObject(SW_UnitComponent);

			`log("Testing 3:" @Unit.GetFullName(),,'Second Wave Plus-Hidden Potential');
		}
	}
	return SW_UnitComponent;
}
function array<HiddenPotentialLevelChanges> CreateHiddenPotentialRanks(XComGameState_Unit Unit)
{
	local array<HiddenPotentialLevelChanges> ToRetArray;
	local HiddenPotentialStatChanges TempStatChange;
	local HiddenPotentialLevelChanges TempLevelChange;
	local array<SoldierClassStatType> SoldierClassProgressions;
	local SoldierClassStatType SingleSoldierClassProgression;
	local SecondWave_RandomizerActor RandActor;
	local int i,TempLog;
	
	RandActor=`SCREENSTACK.GetCurrentScreen().Spawn(class'SecondWave_RandomizerActor',`SCREENSTACK.GetCurrentScreen());
	for(i=0;i<Unit.GetSoldierClassTemplate().GetMaxConfiguredRank();i++)
	{
		TempLevelChange.StatChanges.Length=0;
		TempLevelChange.Level=i;
		SoldierClassProgressions=Unit.GetSoldierClassTemplate().GetStatProgression(i);
		foreach SoldierClassProgressions(SingleSoldierClassProgression)
		{
			if(SingleSoldierClassProgression.StatType!=eStat_CombatSims)
			{
				TempStatChange.StatType=eStat_MAX;
				TempStatChange.Change=0;
				TempStatChange.StatType=SingleSoldierClassProgression.StatType;
				Templog=Round(SingleSoldierClassProgression.StatAmount*HiddenPotentialRandomPercentage/100);
				`log("Random Limit:"@Templog*-1 @"-"@Templog,,'Second Wave Plus-Hidden Potential');
				TempStatChange.Change=RandActor.GetRandomStat(Round(SingleSoldierClassProgression.StatAmount*HiddenPotentialRandomPercentage/100),,true);
				TempLevelChange.StatChanges.AddItem(TempStatChange);
			}
		}
		ToRetArray.AddItem(TempLevelChange);
	}

	RandActor.Destroy();

	`log("ToRetArray Length"@ToRetArray.Length @Unit.GetSoldierClassTemplate().DisplayName);
	return ToRetArray;
}

function EventListenerReturn HiddenPotentialApplyUpdate(Object EventData, Object EventSource, XComGameState NewGameState, Name InEventID)
{	
	if(bIs_HiddenPotential_Activated)
	{
			HiddenPotentialChangeStats(XComGameState_Unit(EventData),NewGameState);
	}
	return ELR_NoInterrupt;
}

function HiddenPotentialChangeStats(XComGameState_Unit mUnit,Optional XComGameState NewGameState)
{
	local XComGameState_SecondWavePlus_UnitComponent SW_UnitComponent,OldUnitComp;
	local XComGameState BackupGameState;
	local XComGameState_Unit Unit;
	local HiddenPotentialStatChanges StatChange;
	local HiddenPotentialLevelChanges LevelStatChanges;
	local array<HiddenPotentialLevelChanges> HiddenPotentialRanks;
	local int MaxStat,CurrentStat,i; 

	OldUnitComp=XComGameState_SecondWavePlus_UnitComponent(mUnit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'));
	if(NewGameState!=none)
	{
		SW_UnitComponent=XComGameState_SecondWavePlus_UnitComponent(NewGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent',OldUnitComp.ObjectID));
		Unit=XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit',mUnit.ObjectID));
	}
	else
	{
		BackupGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Unit Adding Hidden Potential");
		SW_UnitComponent=XComGameState_SecondWavePlus_UnitComponent(BackupGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent',OldUnitComp.ObjectID));
		Unit=XComGameState_Unit(BackupGameState.CreateStateObject(class'XComGameState_Unit',mUnit.ObjectID));
	}	
	if(!SW_UnitComponent.GetHasGot_HiddenPotential())
	{
		if(NewGameState!=none)
		{	
			SW_UnitComponent=AddHiddenPotentialToUnit(Unit,NewGameState);
			NewGameState.RemoveStateObject(SW_UnitComponent.ObjectID);
		}
		else
		{	
			SW_UnitComponent=AddHiddenPotentialToUnit(Unit,BackupGameState);
			BackupGameState.RemoveStateObject(SW_UnitComponent.ObjectID);
		}		
	}
	if(SW_UnitComponent.LastUpdatedLevel==Unit.GetRank())
		return;

	`log("Unit Name:"@Unit.GetFullName() @"Unit Rank:"@Unit.GetRank() @"Unit Class" @Unit.GetSoldierClassTemplate().DisplayName ,,'Second Wave Plus-Hidden Potential');
	if(Unit.GetRank()==0||!bIs_HiddenPotential_Activated)
		return;

	else if(Unit.GetRank()==1 || XComGameState_SecondWavePlus_UnitComponent(mUnit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent')).GetSavedLevelChanges().Length==0)
	{
		HiddenPotentialRanks=CreateHiddenPotentialRanks(Unit);
		SW_UnitComponent.SetHiddenPotentialLevelChanges(HiddenPotentialRanks);
	}

	for(i=XComGameState_SecondWavePlus_UnitComponent(mUnit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent')).LastUpdatedLevel;i<Unit.GetRank();i++)
	{
		`log("Hidden potential i is:"@i,,'Second Wave Plus-Hidden Potential');
		if(HiddenPotentialRanks.Length<=i)
			LevelStatChanges=XComGameState_SecondWavePlus_UnitComponent(mUnit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent')).GetSpecificLevelChanges(i);
		else
			LevelStatChanges=HiddenPotentialRanks[i];

		if(ExcludedClasses.Find(string(Unit.GetSoldierClassTemplateName()))==-1)
		{
			Foreach LevelStatChanges.StatChanges(StatChange)
			{
				`log("Changing Unit Stats: Max Stat" @StatChange.StatType@":" @Unit.GetMaxStat(StatChange.StatType) @"Change:"@StatChange.Change ,,'Second Wave Plus-Hidden Potential');
				`log("Changing Unit Stats: Current Stat" @StatChange.StatType@":" @Unit.GetCurrentStat(StatChange.StatType) @"Change:"@StatChange.Change ,,'Second Wave Plus-Hidden Potential');
				MaxStat=Unit.GetMaxStat(StatChange.StatType);
				CurrentStat=Unit.GetCurrentStat(StatChange.StatType);
				Unit.SetBaseMaxStat(StatChange.StatType,MaxStat+StatChange.Change);
				Unit.SetCurrentStat(StatChange.StatType,CurrentStat+StatChange.Change);
			}
		}
		SW_UnitComponent.LastUpdatedLevel=Unit.GetRank();
	}
	UIArmory_Promotion(`SCREENSTACK.GetFirstInstanceOf(class'UIArmory_Promotion')).Header.PopulateData(Unit);

	if(NewGameState!=none)
	{
		NewGameState.AddStateObject(SW_UnitComponent);
		NewGameState.AddStateObject(Unit);
	}
	else
	{
		BackupGameState.AddStateObject(SW_UnitComponent);
		BackupGameState.AddStateObject(Unit);
		if(BackupGameState.GetNumGameStateObjects()>0)
			`XCOMHistory.AddGameStateToHistory(BackupGameState);
		else
			`XCOMHistory.CleanupPendingGameState(BackupGameState);
	}
}

function XComGameState_SecondWavePlus_UnitComponent GetUnitComponent(XComGameState_Unit Unit,XComGameState NewGameState)
{
	local XComGameState_SecondWavePlus_UnitComponent SW_UnitComponent,OldUnitComp;
	OldUnitComp=XComGameState_SecondWavePlus_UnitComponent(Unit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'));
	if(NewGameState!=none)
		SW_UnitComponent=XComGameState_SecondWavePlus_UnitComponent(NewGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent',OldUnitComp.ObjectID));
	return SW_UnitComponent;
}