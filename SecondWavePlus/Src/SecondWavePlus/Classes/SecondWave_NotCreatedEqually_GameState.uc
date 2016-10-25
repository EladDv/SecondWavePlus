// This is an Unreal Script
                           
class SecondWave_NotCreatedEqually_GameState extends SecondWave_GameStateParent config(SecondWavePlus_Settings);

var config bool bIs_NCE_Activated;
var config bool bIs_NCERobotic_Activated;
var config bool bIs_ExpensiveTalent_Activated;

var config float	ExpensiveTalentMultiplier;
var config int		TotalPoints_XCom;
var config int		Tolerance_XCom;
var config array<NCE_StatModifiers> NCEStatModifiers;

function InitListeners()
{
	local Object Myself;

	Myself=self;
	`XEVENTMGR.RegisterForEvent(Myself,'NCE_Start',NCEStart);
	`XEVENTMGR.RegisterForEvent(Myself,'NewCrewNotification',ExpensiveTalentResourceUpdate,ELD_OnStateSubmitted);
}



function EventListenerReturn NCEStart(Object EventData, Object EventSource, XComGameState NewGameState, Name InEventID)
{
	RandomStats(XComGameState_Unit(EventSource),NewGameState);
	return ELR_NoInterrupt;
}
function RandomStats(XComGameState_Unit Unit,Optional XComGameState NewGameState)
{
	local int TotalCost,j,currentStat;
	local XComGameState_SecondWavePlus_UnitComponent SW_UnitComponent,OldUnitComp;
	local XComGameState BackupGameState;
	local array<int> RandomStats;
	local SecondWave_RandomizerActor RandActor;
	
	if(Unit.IsRobotic()||!bIs_NCERobotic_Activated)
		return;
	RandActor=`SCREENSTACK.GetCurrentScreen().Spawn(class'SecondWave_RandomizerActor',`SCREENSTACK.GetCurrentScreen());	
	OldUnitComp=XComGameState_SecondWavePlus_UnitComponent(Unit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'));
	if(NewGameState!=none)
		SW_UnitComponent=XComGameState_SecondWavePlus_UnitComponent(NewGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent',OldUnitComp.ObjectID));
	else
	{
		BackupGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Unit NCE");
		SW_UnitComponent=XComGameState_SecondWavePlus_UnitComponent(BackupGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent',OldUnitComp.ObjectID));
	}
	`log("Testing:"@bIs_NCE_Activated @Unit.IsSoldier() @SW_UnitComponent!=none @!SW_UnitComponent.GetHasGot_NotCreatedEqually() @Unit.GetFullName(),,'Second Wave Plus-NCE');
	if(bIs_NCE_Activated&&Unit.IsSoldier() && SW_UnitComponent!=none && !SW_UnitComponent.GetHasGot_NotCreatedEqually())
	{
		do
		{
			TotalCost=0;
			RandomStats.Length=0;
			for(j=0;j<NCEStatModifiers.Length;j++)
			{
				currentStat=RandActor.GetRandomStat(NCEStatModifiers[j].Stat_Range,NCEStatModifiers[j].Stat_Min);
				RandomStats.AddItem(currentStat);
				TotalCost+=(currentStat*NCEStatModifiers[j].Stat_Cost);
			}
		}Until(Abs(TotalCost-TotalPoints_XCom)<=Tolerance_XCom);
	
		`log("New XCom Cost"@TotalCost,,'Second Wave Plus-NCE');
		for(j=0;j<RandomStats.Length;j++)
		{
			Unit.SetBaseMaxStat(NCEStatModifiers[j].StatType,Unit.GetMaxStat(NCEStatModifiers[j].StatType)+RandomStats[j]);
			Unit.SetCurrentStat(NCEStatModifiers[j].StatType,Unit.GetMaxStat(NCEStatModifiers[j].StatType));
			`log("New XCom Stat:"@NCEStatModifiers[j].StatType @"Max:"@Unit.GetMaxStat(NCEStatModifiers[j].StatType) @"Cost:"@(RandomStats[j]*NCEStatModifiers[j].Stat_Cost) ,,'Second Wave Plus-NCE');

		}
		Unit.setBaseMaxStat(eStat_ArmorChance,100.00f);
		Unit.setCurrentStat(eStat_ArmorChance,100.00f);
		SW_UnitComponent.SetHasGot_NotCreatedEqually(True);

		if(bIs_ExpensiveTalent_Activated)
		{
			SW_UnitComponent.ExtraCostExpensiveTalent= Round(ExpensiveTalentMultiplier*TotalCost);
			`log("Expensive Talent Cost:"@Round(ExpensiveTalentMultiplier*TotalCost),,'Second Wave Plus-Expensive Talent');
		}
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

function EventListenerReturn ExpensiveTalentResourceUpdate(Object EventData, Object EventSource, XComGameState NewGameState, Name InEventID)
{
	local XComGameState GameState;
	GameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Unit Doing Hidden Potential");
	ExpensiveTalentResource(XComGameState_Unit(EventData),NewGameState);
	`XCOMGAME.GameRuleset.SubmitGameState(GameState);

	return ELR_NoInterrupt;
}

function ExpensiveTalentResource(XComGameState_Unit Unit,Optional XComGameState NewGameState)
{
	local XComGameState_SecondWavePlus_UnitComponent SW_UnitComponent,OldUnitComp;
	local XComGameState_HeadquartersXCom XComHQ;

	if(!Unit.IsSoldier()||!`SCREENSTACK.HasInstanceOf(class'UIRecruitSoldiers'))
		return;

	OldUnitComp=XComGameState_SecondWavePlus_UnitComponent(Unit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'));
	SW_UnitComponent=XComGameState_SecondWavePlus_UnitComponent(NewGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent',OldUnitComp.ObjectID));
	if(SW_UnitComponent.GetHasGot_NotCreatedEqually() && bIs_ExpensiveTalent_Activated && SW_UnitComponent.ExtraCostExpensiveTalent!=0)
	{
		XComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
		NewGameState.AddStateObject(XComHQ);
		XComHQ.AddResource(NewGameState, 'Supplies', -SW_UnitComponent.ExtraCostExpensiveTalent);
		`HQPRES.m_kAvengerHUD.UpdateResources();
	}
}
function int GetExpensiveTalentCost(XComGameState_Unit Unit)
{
	local XComGameState_SecondWavePlus_UnitComponent SW_UnitComponent,OldUnitComp;
	local XComGameState GameState;
	GameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Unit Doing Hidden Potential");

	OldUnitComp=XComGameState_SecondWavePlus_UnitComponent(Unit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'));
	SW_UnitComponent=XComGameState_SecondWavePlus_UnitComponent(GameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent',OldUnitComp.ObjectID));
	//`log("OldUnitComp:"@OldUnitComp.ExtraCostExpensiveTalent @",SW_UnitComponent:"@SW_UnitComponent.ExtraCostExpensiveTalent,,'Second Wave Plus-Expensive Talent');
	if(GameState.GetNumGameStateObjects()>0)
		`XCOMHistory.AddGameStateToHistory(GameState);
	else
		`XCOMHistory.CleanupPendingGameState(GameState);

	return SW_UnitComponent.ExtraCostExpensiveTalent;
}