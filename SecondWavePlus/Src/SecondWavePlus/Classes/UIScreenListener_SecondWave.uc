// This is an Unreal Script
                           
Class UIScreenListener_SecondWave extends UIScreenListener;



event OnInit(UIScreen Screen)
{
	local SecondWave_NotCreatedEqually_GameState NCEA;
	local SecondWave_HiddenPotential_GameState HidPA;
	local SecondWave_NewEconomy_GameState NECON;
	local Object Myself;
	local XComGameState NewGameState;
	local SecondWave_RedFog_GameState RFA;
	Myself=self;

	//`XEVENTMGR.RegisterForEvent(Myself,'Heartbeat_Lub_1',Heartbeat_Lub_1);
	//`XEVENTMGR.RegisterForEvent(Myself,'Heartbeat_Lub_2',Heartbeat_Lub_2);	
	//Main_HiddenPotential_GameState.InitListeners();
	//Main_NotCreatedEqually_GameState.InitListeners();
	`XEVENTMGR.RegisterForEvent(Myself,'OnTacticalBeginPlay',OnTacticalBeginPlay,ELD_OnStateSubmitted);	
	`XEVENTMGR.RegisterForEvent(Myself,'OnUnitBeginPlay',OnUnitBeginPlay,ELD_OnStateSubmitted);	
	if(Screen.IsA('UIArmory_Promotion'))
	{
			NewGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Unit Doing Hidden Potential");
			`XEVENTMGR.TriggerEvent('HiddenPotential_ApplyUpdate',XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UIArmory_Promotion(Screen).UnitReference.ObjectID)),,NewGameState);
			SubmitGameState(NewGameState);
	}
	if(Screen.IsA('UIFacilityGrid'))
	{
		NCEA=SecondWave_NotCreatedEqually_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_NotCreatedEqually_GameState'));
		HidPA=SecondWave_HiddenPotential_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_HiddenPotential_GameState'));
		NECON=SecondWave_NewEconomy_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_NewEconomy_GameState'));
		AddNotCreatedEqually();
		HidPA.InitListeners();
		NCEA.InitListeners();	
		NewGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("New Economy Update");
		NECON.CreateNewEconomy(NewGameState);
		SubmitGameState(NewGameState);
	}
	else if(Screen.IsA('UIRecruitSoldiers'))
	{
		UIRecruitSoldiers(Screen).List.OnSelectionChanged=OnRecruitChangedOverride;
	}
	if(`TACTICALRULES == none || !`TACTICALRULES.TacticalGameIsInPlay())	
	{
		RFA=SecondWave_RedFog_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_RedFog_GameState'));
		RFA.InitListeners();
	}

}
event OnReceiveFocus(UIScreen Screen)
{
	local XComGameState NewGameState;
	local SecondWave_RedFog_GameState RFA;
	local SecondWave_NewEconomy_GameState NECON;
	if(`TACTICALRULES == none || !`TACTICALRULES.TacticalGameIsInPlay())	
	{
		RFA=SecondWave_RedFog_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_RedFog_GameState'));
		RFA.InitListeners();
	}
	if(Screen.IsA('UIArmory_Promotion'))
	{
			NewGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Unit Doing Hidden Potential");
			`XEVENTMGR.TriggerEvent('HiddenPotential_ApplyUpdate',XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UIArmory_Promotion(Screen).UnitReference.ObjectID)),,NewGameState);
			SubmitGameState(NewGameState);	
	}
	else if(Screen.IsA('UIFacilityGrid'))
	{
		NECON=SecondWave_NewEconomy_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_NewEconomy_GameState'));
		AddNotCreatedEqually();
		NewGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("New Economy Update");
		NECON.CreateNewEconomy(NewGameState);
		SubmitGameState(NewGameState);
	}
	else if(Screen.IsA('UIRecruitSoldiers'))
	{
		UIRecruitSoldiers(Screen).List.OnSelectionChanged=OnRecruitChangedOverride;
	}
}
function AddNotCreatedEqually()
{
	local SecondWave_NotCreatedEqually_GameState NCEA;
	local SecondWave_HiddenPotential_GameState HidPA;
	local SecondWave_AbsolutlyCritical_GameState ACA;
	local XComGameStateHistory history;
	local XComGameState_Unit Unit;
	local XComGameState_SecondWavePlus_UnitComponent UnitComp;
	local XComGameState NewGameState;


	history=`XCOMHISTORY;
	NCEA=SecondWave_NotCreatedEqually_GameState(history.GetSingleGameStateObjectForClass(class'SecondWave_NotCreatedEqually_GameState'));
	HidPA=SecondWave_HiddenPotential_GameState(history.GetSingleGameStateObjectForClass(class'SecondWave_HiddenPotential_GameState'));
	ACA=SecondWave_AbsolutlyCritical_GameState(history.GetSingleGameStateObjectForClass(class'SecondWave_AbsolutlyCritical_GameState'));
	
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit',Unit)
	{
		if(Unit.IsSoldier())
		{
			UnitComp=XComGameState_SecondWavePlus_UnitComponent(Unit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'));
			if(UnitComp==none)
			{
				NewGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Units"@RAND(1000000000));
				UnitComp=XComGameState_SecondWavePlus_UnitComponent(NewGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent'));
				Unit.AddComponentObject(UnitComp);
				NewGameState.AddStateObject(UnitComp);
				NewGameState.AddStateObject(Unit);
				SubmitGameState(NewGameState);
			}
			else
			{
				`log("Unit"@Unit.GetFullName() @"Has A Unit Comp",,'Second Wave Plus');
				if(NCEA.bIs_NCE_Activated)
				{
					NewGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Units"@RAND(1000000000));
					NCEA.RandomStats(Unit,NewGameState);
					SubmitGameState(NewGameState);
				}
				if(HidPA.bIs_HiddenPotential_Activated)
				{
					NewGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Units"@RAND(1000000000));
					HidPA.AddHiddenPotentialToUnit(Unit,NewGameState);
					SubmitGameState(NewGameState);
				}
				if(ACA.bIs_AbsolutlyCritical_Activated)
				{
					NewGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Units"@RAND(1000000000));
					ACA.AddAbsolutlyCriticalToUnit(Unit,NewGameState);
					SubmitGameState(NewGameState);
				}
			}
		}
	}
	`log("Add Not Created Equally Passed!FINAL",,'Second Wave Plus');

	
}
function EventListenerReturn OnUnitBeginPlay(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local SecondWave_Epigenetics_GameState Epig;
	local SecondWave_AbsolutlyCritical_GameState ACA;
	local XComGameState_Unit Unit;
	local XComGameState NewGameState;
	NewGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Units");
	Unit=XComGameState_Unit(EventData);
	Epig=SecondWave_Epigenetics_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_Epigenetics_GameState'));
	ACA=SecondWave_AbsolutlyCritical_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_AbsolutlyCritical_GameState'));
	if((Unit.IsAdvent()||Unit.IsAlien())&&!Unit.IsSoldier())
	{
		if(Epig.RandomEnemyStats(Unit))
			NewGameState.AddStateObject(Unit);
		
		if(ACA.bIs_AbsolutlyCritical_Activated)
			ACA.AddAbsolutlyCriticalToUnit(Unit,NewGameState);
	}
	SubmitGameState(NewGameState);
	return ELR_NoInterrupt;
}
function EventListenerReturn OnTacticalBeginPlay(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local SecondWave_NotCreatedEqually_GameState NCEA;
	local SecondWave_HiddenPotential_GameState HidPA;
	local SecondWave_Epigenetics_GameState Epig;
	local SecondWave_AbsolutlyCritical_GameState ACA;
	local SecondWave_RedFog_GameState RFA;
	local XComGameStateHistory history;
	local XComGameState_Unit Unit;
	local XComGameState_SecondWavePlus_UnitComponent UnitComp;
	local XComGameState NewGameState;
	NewGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Units");

	history=`XCOMHISTORY;
	NCEA=SecondWave_NotCreatedEqually_GameState(history.GetSingleGameStateObjectForClass(class'SecondWave_NotCreatedEqually_GameState'));
	HidPA=SecondWave_HiddenPotential_GameState(history.GetSingleGameStateObjectForClass(class'SecondWave_HiddenPotential_GameState'));
	Epig=SecondWave_Epigenetics_GameState(history.GetSingleGameStateObjectForClass(class'SecondWave_Epigenetics_GameState'));
	ACA=SecondWave_AbsolutlyCritical_GameState(history.GetSingleGameStateObjectForClass(class'SecondWave_AbsolutlyCritical_GameState'));
	RFA=SecondWave_RedFog_GameState(history.GetSingleGameStateObjectForClass(class'SecondWave_RedFog_GameState'));
	RFA.InitListeners();

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit',Unit)
	{
		`log("On Tactical Begin Play:"@Unit.IsSoldier(),,'Second Wave Plus');

		if(Unit.IsSoldier())
		{
			UnitComp=XComGameState_SecondWavePlus_UnitComponent(Unit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'));
			if(UnitComp==none)
			{
				UnitComp=XComGameState_SecondWavePlus_UnitComponent(NewGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent'));
				Unit.AddComponentObject(UnitComp);
				NewGameState.AddStateObject(UnitComp);
				NewGameState.AddStateObject(Unit);
				
			}
			else
			{
				`log("Unit"@Unit.GetFullName() @"Has A Unit Comp",,'Second Wave Plus');
				if(NCEA.bIs_NCE_Activated)NCEA.RandomStats(Unit,NewGameState);
				if(ACA.bIs_AbsolutlyCritical_Activated)ACA.AddAbsolutlyCriticalToUnit(Unit,NewGameState);
				if(HidPA.bIs_HiddenPotential_Activated)HidPA.AddHiddenPotentialToUnit(Unit,NewGameState);
			}
		}
		else if((Unit.IsAdvent()||Unit.IsAlien())&&!Unit.IsSoldier())
		{			
			if(Epig.RandomEnemyStats(Unit))
				NewGameState.AddStateObject(Unit);
		}
	}
	RFA.AddRedFogAbilityToAllUnits(NewGameState);
	SubmitGameState(NewGameState);

	return ELR_NoInterrupt;
}
function SubmitGameState(XComGameState NewGameState)
{
	if(NewGameState.GetNumGameStateObjects()>0)
		`XCOMHistory.AddGameStateToHistory(NewGameState);
	else
		`XCOMHistory.CleanupPendingGameState(NewGameState);	
}

simulated function OnRecruitChangedOverride(UIList kList, int itemIndex )
{
	local XGParamTag LocTag;
	local UIRecruitSoldiers RSScreen;
	local StateObjectReference UnitRef;
	local XComGameState_Unit Recruit;
	local XComGameState_HeadquartersResistance ResistanceHQ;
	local X2ImageCaptureManager CapMan;		
	local Texture2D StaffPicture;
	local string ImageString;
	
	if(itemIndex == INDEX_NONE) return;

	RSScreen=UIRecruitSoldiers(`SCREENSTACK.GetFirstInstanceOf(class'UIRecruitSoldiers'));
	if(RSScreen==none) return;

	Recruit = RSScreen.m_arrRecruits[itemIndex];
	UnitRef = Recruit.GetReference();
	ResistanceHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();

	LocTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	if(XComGameState_SecondWavePlus_UnitComponent(Recruit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'))!=none)
		LocTag.IntValue0 = ResistanceHQ.GetRecruitSupplyCost()+XComGameState_SecondWavePlus_UnitComponent(Recruit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent')).ExtraCostExpensiveTalent;
	else
		LocTag.IntValue0 = ResistanceHQ.GetRecruitSupplyCost();

	RSScreen.AS_SetCost(RSScreen.m_strCost, `XEXPAND.ExpandString(RSScreen.m_strSupplies));
	RSScreen.AS_SetDescription(Recruit.GetBackground());
	RSScreen.AS_SetTime(RSScreen.m_strTime, RSScreen.m_strInstant);
	RSScreen.AS_SetPicture(); // hide picture until character portrait is loaded
	
	CapMan = X2ImageCaptureManager(`XENGINE.GetImageCaptureManager());	
	ImageString = "UnitPicture"$UnitRef.ObjectID;
	StaffPicture = CapMan.GetStoredImage(UnitRef, name(ImageString));
	if(StaffPicture == none)
	{
		RSScreen.DeferredSoldierPictureListIndex = itemIndex;
		RSScreen.ClearTimer(nameof(DeferredUpdateSoldierPicture_Listener));
		RSScreen.SetTimer(0.1f, false, nameof(DeferredUpdateSoldierPicture_Listener));
	}	
	else
	{
		RSScreen.AS_SetPicture("img:///"$PathName(StaffPicture));
	}
}

function DeferredUpdateSoldierPicture_Listener()
{	
	local StateObjectReference UnitRef;
	local XComGameState_Unit Recruit;
	local XComPhotographer_Strategy Photo;	
	local UIRecruitSoldiers RSScreen;

	RSScreen=UIRecruitSoldiers(`SCREENSTACK.GetFirstInstanceOf(class'UIRecruitSoldiers'));
	if(RSScreen==none) return;

	Recruit = RSScreen.m_arrRecruits[RSScreen.DeferredSoldierPictureListIndex];
	UnitRef = Recruit.GetReference();
		
	Photo = `GAME.StrategyPhotographer;	
	if (!Photo.HasPendingHeadshot(UnitRef, RSScreen.OnSoldierHeadCaptureFinished))
	{
		Photo.AddHeadshotRequest(UnitRef, 'UIPawnLocation_ArmoryPhoto', 'SoldierPicture_Head_Armory', 512, 512, RSScreen.OnSoldierHeadCaptureFinished,, false, true);
	}	
}