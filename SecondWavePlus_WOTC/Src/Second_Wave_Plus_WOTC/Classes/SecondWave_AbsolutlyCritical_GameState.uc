// This is an Unreal Script
                           
class SecondWave_AbsolutlyCritical_GameState extends SecondWave_GameStateParent  config(SecondWavePlus_Settings);

var config bool bIs_AbsolutlyCritical_Activated;
var config bool bIs_AbsolutlyCritical_XCOM_Activated;
var config bool bIs_AbsolutlyCritical_Advent_Activated;
var config bool bIs_AbsolutlyCritical_Aliens_Activated;

function InitListeners()
{
	local Object Myself;

	Myself=self;
	`XEVENTMGR.RegisterForEvent(Myself,'AbsolutlyCritical_Start',AbsolutlyCriticalStart, , , ,true);
}

function ObtainOptions()
{
	local SecondWave_OptionsDataStore SWDataStore;
	SWDataStore=class'SecondWave_OptionsDataStore'.static.GetInstance();	
	bIs_AbsolutlyCritical_Activated=SWDataStore.GetValues("bIs_AbsolutlyCritical_Activated").Bool_Value;
	bIs_AbsolutlyCritical_XCOM_Activated=SWDataStore.GetValues("bIs_AbsolutlyCritical_XCOM_Activated").Bool_Value;
	bIs_AbsolutlyCritical_Advent_Activated=SWDataStore.GetValues("bIs_AbsolutlyCritical_Advent_Activated").Bool_Value;
	bIs_AbsolutlyCritical_Aliens_Activated=SWDataStore.GetValues("bIs_AbsolutlyCritical_Aliens_Activated").Bool_Value;
}


function EventListenerReturn AbsolutlyCriticalStart(Object EventData, Object EventSource, XComGameState NewGameState, Name InEventID, Object CallbackData)
{
	if(bIs_AbsolutlyCritical_Activated)
		AddAbsolutlyCriticalToUnit(XComGameState_Unit(EventSource),NewGameState);
	return ELR_NoInterrupt;
}

function AddAbsolutlyCriticalToUnit(XComGameState_Unit Unit,Optional XComGameState NewGameState)
{
	local XComGameState_SecondWavePlus_UnitComponent SW_UnitComponent,OldUnitComp;
	local XComGameState BackupGameState;
	if(!bIs_AbsolutlyCritical_Activated)
		return;

	if(Unit.IsSoldier()&&bIs_AbsolutlyCritical_XCOM_Activated)
	{
		OldUnitComp=XComGameState_SecondWavePlus_UnitComponent(Unit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'));
		if(NewGameState!=none)
			SW_UnitComponent=XComGameState_SecondWavePlus_UnitComponent(NewGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent',OldUnitComp.ObjectID));
		else
		{
			BackupGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Unit Adding Hidden Potential");
			SW_UnitComponent=XComGameState_SecondWavePlus_UnitComponent(BackupGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent',OldUnitComp.ObjectID));
		}
		`log("Testing:"@!SW_UnitComponent.GetHasGot_AbsolutlyCritical() @Unit.GetFullName(),,'Second Wave Plus-Absolutly Critical');

		if(!SW_UnitComponent.GetHasGot_AbsolutlyCritical()||Unit.GetMaxStat(eStat_FlankingCritChance)!=100||Unit.GetCurrentStat(eStat_FlankingCritChance)!=100)
		{
			Unit.SetBaseMaxStat(eStat_FlankingCritChance,100);
			Unit.SetCurrentStat(eStat_FlankingCritChance,100);
			SW_UnitComponent.SetHasGot_AbsolutlyCritical(True);
			if(NewGameState==none)
			{
				BackupGameState.AddStateObject(SW_UnitComponent);
				BackupGameState.AddStateObject(Unit);
				if(BackupGameState.GetNumGameStateObjects()>0)
					`XCOMHistory.AddGameStateToHistory(BackupGameState);
				else
					`XCOMHistory.CleanupPendingGameState(BackupGameState);
			}
			else
			{
				if(SW_UnitComponent!=none)
				{
					NewGameState.AddStateObject(SW_UnitComponent);
					NewGameState.AddStateObject(Unit);
				}	
			}
		}	
	}
	else if(bIs_AbsolutlyCritical_Activated&&(Unit.IsAdvent()||Unit.IsAlien()))
	{
		if(Unit.IsAdvent() && !bIs_AbsolutlyCritical_Advent_Activated)
			return;
		if(Unit.IsAlien() && !bIs_AbsolutlyCritical_Aliens_Activated)
			return;

		if(Unit.GetMaxStat(eStat_FlankingCritChance)!=100||Unit.GetCurrentStat(eStat_FlankingCritChance)!=100)
		{
			if(NewGameState==none)
			{
				BackupGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Unit Adding Hidden Potential");
				Unit.SetBaseMaxStat(eStat_FlankingCritChance,100);
				Unit.SetCurrentStat(eStat_FlankingCritChance,100);
				BackupGameState.AddStateObject(Unit);
				if(BackupGameState.GetNumGameStateObjects()>0)
					`XCOMHistory.AddGameStateToHistory(BackupGameState);
				else
					`XCOMHistory.CleanupPendingGameState(BackupGameState);
			}
			else
			{
				Unit.SetBaseMaxStat(eStat_FlankingCritChance,100);
				Unit.SetCurrentStat(eStat_FlankingCritChance,100);
				NewGameState.AddStateObject(Unit);
			}
				
		}
	}
}