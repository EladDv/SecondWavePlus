// This is an Unreal Script
                           
class SecondWave_NotCreatedEqually_Actor extends SecondWave_ActorParent config(SecondWavePlus_Settings);

var config bool bIs_NCE_Activated;

var config int TotalPoints_XCom;
var config int Tolerance_XCom;
var config array<NCE_StatModifiers> NCEStatModifiers;

function InitListeners()
{
	local Object Myself;

	Myself=self;
	`XEVENTMGR.RegisterForEvent(Myself,'NCE_Start',NCEStart);
}
function EventListenerReturn NCEStart(Object EventData, Object EventSource, XComGameState NewGameState, Name InEventID)
{
	RandomStats(XComGameState_Unit(EventSource),NewGameState);
	return ELR_NoInterrupt;
}
function int GetRandomStat(int StatRange,int StatMin)
{
	local int Sign,ReturnInt;
	Sign=`SYNC_RAND(1);
	if(Sign==0)
	 Sign=-1;
	do
	{
		ReturnInt= `SYNC_RAND(StatRange) * Sign;		
	}Until(ReturnInt>=StatMin);
	return ReturnInt;
}
function RandomStats(XComGameState_Unit Unit,Optional XComGameState NewGameState)
{
	local int TotalCost,j,currentStat;
	local XComGameState_SecondWavePlus_UnitComponent SW_UnitComponent,OldUnitComp;
	local XComGameState BackupGameState;
	local array<int> RandomStats;
		
	OldUnitComp=XComGameState_SecondWavePlus_UnitComponent(Unit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'));
	if(NewGameState!=none)
		SW_UnitComponent=XComGameState_SecondWavePlus_UnitComponent(NewGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent',OldUnitComp.ObjectID));
	else
	{
		BackupGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Unit NCE");
		SW_UnitComponent=XComGameState_SecondWavePlus_UnitComponent(BackupGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent',OldUnitComp.ObjectID));
	}
	if(bIs_NCE_Activated&&Unit.IsSoldier()&&Unit.GetTeam()==ETeam_XCom && SW_UnitComponent!=none && !SW_UnitComponent.GetHasGot_NotCreatedEqually())
	{
		do
		{
			TotalCost=0;
			RandomStats.Length=0;
			for(j=0;j<NCEStatModifiers.Length;j++)
			{
				currentStat=GetRandomStat(NCEStatModifiers[j].Stat_Range,NCEStatModifiers[j].Stat_Min);
				RandomStats.AddItem(currentStat);
				TotalCost+=(currentStat*NCEStatModifiers[j].Stat_Cost);
			}
		}Until(Abs(TotalCost-TotalPoints_XCom)<=Tolerance_XCom);
	
		`log("New XCom Cost"@TotalCost,,'Second Wave Plus-NCE');
		for(j=0;j<RandomStats.Length;j++)
		{
			Unit.setBaseMaxStat(NCEStatModifiers[j].StatType,Unit.GetMaxStat(NCEStatModifiers[j].StatType)+RandomStats[j]);
			Unit.setCurrentStat(NCEStatModifiers[j].StatType,Unit.GetMaxStat(NCEStatModifiers[j].StatType)+RandomStats[j]);
			`log("New XCom Stat"@NCEStatModifiers[j].StatType @Unit.GetMaxStat(NCEStatModifiers[j].StatType),,'Second Wave Plus-NCE');

		}
		Unit.setBaseMaxStat(eStat_ArmorChance,100.00f);
		Unit.setCurrentStat(eStat_ArmorChance,100.00f);
		SW_UnitComponent.SetHasGot_NotCreatedEqually(True);
		if(NewGameState!=none)
		{
			NewGameState.AddStateObject(SW_UnitComponent);
			NewGameState.AddStateObject(Unit);
			return;
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
}