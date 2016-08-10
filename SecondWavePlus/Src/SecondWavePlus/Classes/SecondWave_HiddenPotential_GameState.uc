// This is an Unreal Script
                           
class SecondWave_HiddenPotential_GameState extends SecondWave_GameStateParent config(SecondWavePlus_Settings);

var config int HiddenPotentialRandomPercentage;
var config bool bIs_HiddenPotential_Activated;
//var int LastUpdatedAtRank;
function InitListeners()
{
	local Object Myself;

	Myself=self;
	`XEVENTMGR.RegisterForEvent(Myself,'HiddenPotential_Start',HiddenPotentialStart, , , ,true);
	`XEVENTMGR.RegisterForEvent(Myself,'HiddenPotential_ApplyUpdate',HiddenPotentialApplyUpdate, , , ,true);
}
function EventListenerReturn HiddenPotentialStart(Object EventData, Object EventSource, XComGameState NewGameState, Name InEventID)
{
	if(bIs_HiddenPotential_Activated)
		AddHiddenPotentialToUnit(XComGameState_Unit(EventSource),NewGameState);
	return ELR_NoInterrupt;
}
function AddHiddenPotentialToUnit(XComGameState_Unit Unit,Optional XComGameState NewGameState)
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
	`log("ToRetArray Length"@ToRetArray.Length @Unit.GetSoldierClassTemplate().DisplayName);
	return ToRetArray;
}

function EventListenerReturn HiddenPotentialApplyUpdate(Object EventData, Object EventSource, XComGameState NewGameState, Name InEventID)
{	
	if(bIs_HiddenPotential_Activated)
		HiddenPotentialChangeStats(XComGameState_Unit(EventData),NewGameState);
	return ELR_NoInterrupt;
}

function HiddenPotentialChangeStats(XComGameState_Unit Unit,Optional XComGameState NewGameState)
{
	local XComGameState_SecondWavePlus_UnitComponent SW_UnitComponent,OldUnitComp;
	local XComGameState BackupGameState;
	local HiddenPotentialStatChanges StatChange;
	local HiddenPotentialLevelChanges LevelStatChanges;
	local array<HiddenPotentialLevelChanges> HiddenPotentialRanks;
	local int MaxStat,CurrentStat; 
	OldUnitComp=XComGameState_SecondWavePlus_UnitComponent(Unit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'));
	if(NewGameState!=none)
		SW_UnitComponent=XComGameState_SecondWavePlus_UnitComponent(NewGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent',OldUnitComp.ObjectID));
	else
	{
		BackupGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Unit Adding Hidden Potential");
		SW_UnitComponent=XComGameState_SecondWavePlus_UnitComponent(BackupGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent',OldUnitComp.ObjectID));
	}	
	if(!SW_UnitComponent.GetHasGot_HiddenPotential())
	{
		AddHiddenPotentialToUnit(Unit,NewGameState);
		if(newGameState!=none)
			SW_UnitComponent=GetUnitComponent(Unit,NewGameState);
		else
			SW_UnitComponent=GetUnitComponent(Unit,BackupGameState);
	}
	if(SW_UnitComponent.LastUpdatedLevel==Unit.GetRank())
		return;

	`log("Unit Rank:"@Unit.GetRank() @"Unit Class" @Unit.GetSoldierClassTemplate().DisplayName ,,'Second Wave Plus-Hidden Potential');
	if(Unit.GetRank()==0||!bIs_HiddenPotential_Activated)
		return;

	else if(Unit.GetRank()==1)
	{
		HiddenPotentialRanks=CreateHiddenPotentialRanks(Unit);
		SW_UnitComponent.SetHiddenPotentialLevelChanges(HiddenPotentialRanks);
	}
	if(HiddenPotentialRanks.Length==0)
		LevelStatChanges=SW_UnitComponent.GetSpecificLevelChanges(Unit.GetRank()-1);
	else
		LevelStatChanges=HiddenPotentialRanks[Unit.GetRank()-1];
	
	Foreach LevelStatChanges.StatChanges(StatChange)
	{
		`log("Changing Unit Stats: Max Stat" @StatChange.StatType@":" @Unit.GetMaxStat(StatChange.StatType) @"Change:"@StatChange.Change ,,'Second Wave Plus-Hidden Potential');
		`log("Changing Unit Stats: Current Stat" @StatChange.StatType@":" @Unit.GetCurrentStat(StatChange.StatType) @"Change:"@StatChange.Change ,,'Second Wave Plus-Hidden Potential');
		MaxStat=Unit.GetMaxStat(StatChange.StatType);
		CurrentStat=Unit.GetCurrentStat(StatChange.StatType);
		Unit.SetBaseMaxStat(StatChange.StatType,MaxStat+StatChange.Change);
		Unit.SetCurrentStat(StatChange.StatType,CurrentStat+StatChange.Change);
	}
	SW_UnitComponent.LastUpdatedLevel=Unit.GetRank();
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