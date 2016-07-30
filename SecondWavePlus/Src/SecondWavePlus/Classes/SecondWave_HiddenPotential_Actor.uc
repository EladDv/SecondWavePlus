// This is an Unreal Script
                           
class SecondWave_HiddenPotential_Actor extends SecondWave_ActorParent config(SecondWavePlus_Settings);

var config int HiddenPotentialRandomPercentage;
var config bool bIs_HiddenPotential_Activated;

function InitListeners()
{
	local Object Myself;

	Myself=self;
	`XEVENTMGR.RegisterForEvent(Myself,'HiddenPotential_Start',HiddenPotentialStart);
	`XEVENTMGR.RegisterForEvent(Myself,'HiddenPotential_ApplyUpdate',HiddenPotentialApplyUpdate);
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
	local SecondWave_HiddenPotentialStatHolder_Actor NewHolder;
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

		if(SW_UnitComponent.GetHiddenPotentialHolder()==none)
		{
			NewHolder=Spawn(class'SecondWave_HiddenPotentialStatHolder_Actor');
			SW_UnitComponent.SetHiddenPotentialHolder(NewHolder);
			//SW_UnitComponent.SetHiddenPotentialLevelChanges(CreateHiddenPotentialRanks(Unit));
			SW_UnitComponent.SetHasGot_HiddenPotential(True);
		}	
		else
		{
			//SW_UnitComponent.SetHiddenPotentialLevelChanges(CreateHiddenPotentialRanks(Unit));
			SW_UnitComponent.SetHasGot_HiddenPotential(True);
		}
		if(NewGameState==none)
		{
			BackupGameState.AddStateObject(SW_UnitComponent);
			if(BackupGameState.GetNumGameStateObjects()>0)
				`XCOMHistory.AddGameStateToHistory(BackupGameState);
			else
				`XCOMHistory.CleanupPendingGameState(BackupGameState);
		}
		else
			NewGameState.AddStateObject(SW_UnitComponent);
	
	}
}
function array<HiddenPotentialLevelChanges> CreateHiddenPotentialRanks(XComGameState_Unit Unit)
{
	local array<HiddenPotentialLevelChanges> ToRetArray;
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
			TempStatChange.Change=GetRandomSign()*`SYNC_RAND(Round(SingleSoldierClassProgression.StatAmount*HiddenPotentialRandomPercentage));
			ToRetArray[i].StatChanges.AddItem(TempStatChange);
		}
	}
	return ToRetArray;
}

function int GetRandomSign()
{
	local int i;
	i=`SYNC_RAND(1);
	if(i==0)
		i=-1;
	return i;	
}
function EventListenerReturn HiddenPotentialApplyUpdate(Object EventData, Object EventSource, XComGameState NewGameState, Name InEventID)
{	
	if(bIs_HiddenPotential_Activated)
		HiddenPotentialChangeStats(XComGameState_Unit(EventSource),NewGameState);
	return ELR_NoInterrupt;
}

function HiddenPotentialChangeStats(XComGameState_Unit Unit,Optional XComGameState NewGameState)
{
	local XComGameState_SecondWavePlus_UnitComponent SW_UnitComponent,OldUnitComp;
	local XComGameState BackupGameState;
	local HiddenPotentialStatChanges StatChange;
	local HiddenPotentialLevelChanges LevelStatChanges;
	OldUnitComp=XComGameState_SecondWavePlus_UnitComponent(Unit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'));
	if(NewGameState!=none)
		SW_UnitComponent=XComGameState_SecondWavePlus_UnitComponent(NewGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent',OldUnitComp.ObjectID));
	else
	{
		BackupGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Unit Adding Hidden Potential");
		SW_UnitComponent=XComGameState_SecondWavePlus_UnitComponent(BackupGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent',OldUnitComp.ObjectID));
	}	
	if(!SW_UnitComponent.GetHasGot_HiddenPotential()||SW_UnitComponent.GetHiddenPotentialHolder()==none)
	{
		AddHiddenPotentialToUnit(Unit,NewGameState);
		if(newGameState!=none)
			SW_UnitComponent=GetUnitComponent(Unit,NewGameState);
		else
			SW_UnitComponent=GetUnitComponent(Unit,BackupGameState);
	}
	if(Unit.GetRank()==1)
	{
		SW_UnitComponent.SetHiddenPotentialLevelChanges(CreateHiddenPotentialRanks(Unit));
	}
	LevelStatChanges=SW_UnitComponent.GetSpecificLevelChanges(Unit.GetRank());
	Foreach LevelStatChanges.StatChanges(StatChange)
	{
		Unit.SetBaseMaxStat(StatChange.StatType,Unit.GetMaxStat(StatChange.StatType)+StatChange.Change);
		Unit.SetCurrentStat(StatChange.StatType,Unit.GetCurrentStat(StatChange.StatType)+StatChange.Change);
	}
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