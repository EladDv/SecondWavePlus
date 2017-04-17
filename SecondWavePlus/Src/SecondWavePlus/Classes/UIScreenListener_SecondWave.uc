// This is an Unreal Script
                           
Class UIScreenListener_SecondWave extends UIScreenListener;

var array<String> CC_ClassDisplayNames;
var array<Name> CC_ClassNames;
var localized string SecondWaveOptionsString;
var int SavedSecondWaveObjectPlace;
var UIMechaListItem CommandersChoiceSpinner;

simulated public function OnListChildClicked(UIList ContainerList, int ItemIndex)
{	
	local UIScreen_SecondWaveOptions UISWOScreen;

	if(UIListItemString(ContainerList.GetItem(ItemIndex)).Text~=SecondWaveOptionsString)
	{
		UISWOScreen = `SCREENSTACK.GetCurrentScreen().Spawn(Class'UIScreen_SecondWaveOptions',none);
		`SCREENSTACK.Push(UISWOScreen);
		UISWOScreen.CreateScreen();
		UISWOScreen.LargeB.OnClickedDelegate=OnContinueButton;		
		UISWOScreen.LargeB.OnDoubleClickedDelegate=OnContinueButton;
	}
	else
	{
		if(ItemIndex>SavedSecondWaveObjectPlace)
		{
			UIPauseMenu(`SCREENSTACK.GetFirstInstanceOf(class'UIPauseMenu')).OnChildClicked(ContainerList,ItemIndex-1);
			UIPauseMenu(`SCREENSTACK.GetFirstInstanceOf(class'UIPauseMenu')).SetSelected(ContainerList,ItemIndex);
		}
		else
			UIPauseMenu(`SCREENSTACK.GetFirstInstanceOf(class'UIPauseMenu')).OnChildClicked(ContainerList,ItemIndex);
		
	}
}

simulated public function OnContinueButton(UIButton Button)
{
	local SecondWave_CommandersChoice_GameState		Main_CommandersChoice_GameState;
	local SecondWave_HiddenPotential_GameState		Main_HiddenPotential_GameState;
	local SecondWave_Epigenetics_GameState			Main_Epigenetics_GameState;
	local SecondWave_NotCreatedEqually_GameState	Main_NotCreatedEqually_GameState;
	local SecondWave_AbsolutlyCritical_GameState	Main_AbsolutlyCritical_GameState;
	local SecondWave_NewEconomy_GameState			Main_NewEconomy_GameState;
	local SecondWave_RedFog_GameState				Main_RedFog_GameState;
	local SecondWave_UIScreenSettings_GameState		Main_ScreenSettings_GameState;
	local XComGameState StartState;


	UIScreen_SecondWaveOptions(`SCREENSTACK.GetFirstInstanceOf(class'UIScreen_SecondWaveOptions')).ContinueButton(Button);

	StartState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Loading Data For New settings");
	Main_CommandersChoice_GameState=SecondWave_CommandersChoice_GameState(StartState.CreateStateObject(class'SecondWave_CommandersChoice_GameState'));
	Main_HiddenPotential_GameState=SecondWave_HiddenPotential_GameState(StartState.CreateStateObject(class'SecondWave_HiddenPotential_GameState'));
	Main_Epigenetics_GameState=SecondWave_Epigenetics_GameState(StartState.CreateStateObject(class'SecondWave_Epigenetics_GameState'));
	Main_NotCreatedEqually_GameState=SecondWave_NotCreatedEqually_GameState(StartState.CreateStateObject(class'SecondWave_NotCreatedEqually_GameState'));
	Main_AbsolutlyCritical_GameState=SecondWave_AbsolutlyCritical_GameState(StartState.CreateStateObject(class'SecondWave_AbsolutlyCritical_GameState'));
	Main_RedFog_GameState=SecondWave_RedFog_GameState(StartState.CreateStateObject(class'SecondWave_RedFog_GameState'));
	Main_NewEconomy_GameState=SecondWave_NewEconomy_GameState(StartState.CreateStateObject(class'SecondWave_NewEconomy_GameState'));
	Main_ScreenSettings_GameState=SecondWave_UIScreenSettings_GameState(StartState.CreateStateObject(class'SecondWave_UIScreenSettings_GameState'));

	StartState.AddStateObject(Main_CommandersChoice_GameState);
	StartState.AddStateObject(Main_HiddenPotential_GameState);
	StartState.AddStateObject(Main_Epigenetics_GameState);
	StartState.AddStateObject(Main_NotCreatedEqually_GameState);
	StartState.AddStateObject(Main_AbsolutlyCritical_GameState);
	StartState.AddStateObject(Main_NewEconomy_GameState);
	StartState.AddStateObject(Main_RedFog_GameState);
	StartState.AddStateObject(Main_ScreenSettings_GameState);

	Main_CommandersChoice_GameState.ObtainOptions();
	Main_HiddenPotential_GameState.ObtainOptions();
	Main_Epigenetics_GameState.ObtainOptions();
	Main_NotCreatedEqually_GameState.ObtainOptions();
	Main_AbsolutlyCritical_GameState.ObtainOptions();
	Main_RedFog_GameState.ObtainOptions();
	Main_NewEconomy_GameState.ObtainOptions();
	Main_ScreenSettings_GameState.ObtainOptions();

	`log("Updating SWP...",,'Second Wave Plus');
	Main_HiddenPotential_GameState.InitListeners();
	Main_NotCreatedEqually_GameState.InitListeners();	
	Main_RedFog_GameState.InitListeners();	

	if(StartState.GetNumGameStateObjects()>0)
		`XCOMHistory.AddGameStateToHistory(StartState);
	else
		`XCOMHistory.CleanupPendingGameState(StartState);	
}


event OnInit(UIScreen Screen)
{
	local SecondWave_NotCreatedEqually_GameState NCEA;
	local SecondWave_HiddenPotential_GameState HidPA;
	local SecondWave_NewEconomy_GameState NECON;
	local Object Myself;
	local XComGameState NewGameState;
	local int i;
	local SecondWave_RedFog_GameState RFA;
	local UIScreen_SecondWaveOptions UISWOScreen;
	local UIListItemString SWOB;
	Myself=self;

	//`XEVENTMGR.RegisterForEvent(Myself,'Heartbeat_Lub_1',Heartbeat_Lub_1);
	//`XEVENTMGR.RegisterForEvent(Myself,'Heartbeat_Lub_2',Heartbeat_Lub_2);	
	//Main_HiddenPotential_GameState.InitListeners();
	//Main_NotCreatedEqually_GameState.InitListeners();
	`XEVENTMGR.RegisterForEvent(Myself,'OnTacticalBeginPlay',OnTacticalBeginPlay,ELD_OnStateSubmitted);	
	`XEVENTMGR.RegisterForEvent(Myself,'OnUnitBeginPlay',OnUnitBeginPlay,ELD_OnStateSubmitted);	
	if(Screen.IsA('UIShellDifficulty'))
	{
		UISWOScreen= Screen.Spawn(Class'UIScreen_SecondWaveOptions',none);
		`SCREENSTACK.Push(UISWOScreen);
		UISWOScreen.CreateScreen();
	}

	if(Screen.IsA('UIPauseMenu') && !`SCREENSTACK.HasInstanceOf(class'UIShell'))
	{
		if(`BATTLE == none)
		{
			SWOB=UIListItemString(UIPauseMenu(Screen).List.CreateItem()).InitListItem(SecondWaveOptionsString);
			UIPauseMenu(Screen).List.OnItemClicked=OnListChildClicked;
			UIPauseMenu(Screen).List.OnItemDoubleClicked=OnListChildClicked;
			
		}
	}

	if(Screen.IsA('UIArmory_Promotion'))
	{
		AddCommandersChoiceSpinner(UIArmory_Promotion(Screen));
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

	if(`TACTICALRULES != none || `TACTICALRULES.TacticalGameIsInPlay())	
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
//	local SecondWave_HiddenPotential_GameState HidPA;
	
	if(Screen.IsA('UIArmory_Promotion'))
	{
		`XEVENTMGR.TriggerEvent('HiddenPotential_ApplyUpdate',XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UIArmory_Promotion(Screen).UnitReference.ObjectID)),XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UIArmory_Promotion(Screen).UnitReference.ObjectID)));
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

	if(`TACTICALRULES != none || `TACTICALRULES.TacticalGameIsInPlay())	
	{
		RFA=SecondWave_RedFog_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_RedFog_GameState'));
		RFA.InitListeners();
	}
}

event OnRemoved(UIScreen Screen)
{

	if(Screen.IsA('UIArmory_Promotion'))
	{
		CC_ClassDisplayNames.Length=0;
		CC_ClassNames.Length=0;
		CommandersChoiceSpinner.Remove();
		CommandersChoiceSpinner=none;
	}
	if(Screen.IsA('UIArmory_MainMenu'))
	{
		class'XComGameState_SecondWavePlus_UnitComponent'.static.GCValidationChecks();
	}

}
function AddNotCreatedEqually()
{
	local SecondWave_NotCreatedEqually_GameState NCEA;
	local SecondWave_HiddenPotential_GameState HidPA;
	local SecondWave_AbsolutlyCritical_GameState ACA;
	local XComGameStateHistory history;
	local XComGameState_Unit mUnit,Unit;
	local XComGameState_SecondWavePlus_UnitComponent UnitComp;
	local XComGameState NewGameState;


	history=`XCOMHISTORY;
	NCEA=SecondWave_NotCreatedEqually_GameState(history.GetSingleGameStateObjectForClass(class'SecondWave_NotCreatedEqually_GameState'));
	HidPA=SecondWave_HiddenPotential_GameState(history.GetSingleGameStateObjectForClass(class'SecondWave_HiddenPotential_GameState'));
	ACA=SecondWave_AbsolutlyCritical_GameState(history.GetSingleGameStateObjectForClass(class'SecondWave_AbsolutlyCritical_GameState'));
	
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit',mUnit)
	{
		if(mUnit.IsSoldier())
		{
			NewGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Units"@RAND(1000000000));
			Unit=XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit',mUnit.ObjectID));
			UnitComp=XComGameState_SecondWavePlus_UnitComponent(Unit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'));
			if(UnitComp==none)
			{
				UnitComp=XComGameState_SecondWavePlus_UnitComponent(NewGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent'));
				Unit.AddComponentObject(UnitComp);
				NewGameState.AddStateObject(UnitComp);
				NewGameState.AddStateObject(Unit);
				SubmitGameState(NewGameState);
				NewGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Units"@RAND(1000000000));
				Unit=XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit',mUnit.ObjectID));
				UnitComp=XComGameState_SecondWavePlus_UnitComponent(Unit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'));
			}
			`log("Unit"@Unit.GetFullName() @"Has A Unit Comp",,'Second Wave Plus');
			if(NCEA.bIs_NCE_Activated)
			{
				NCEA.RandomStats(Unit,NewGameState);
			}
			if(HidPA.bIs_HiddenPotential_Activated)
			{
				HidPA.AddHiddenPotentialToUnit(Unit,NewGameState);
			}
			if(ACA.bIs_AbsolutlyCritical_Activated)
			{
				ACA.AddAbsolutlyCriticalToUnit(Unit,NewGameState);
			}
			SubmitGameState(NewGameState);
		}
	}
	`log("Add Not Created Equally Passed!FINAL",,'Second Wave Plus');

	
}
function EventListenerReturn OnUnitBeginPlay(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local SecondWave_Epigenetics_GameState Epig;
	local SecondWave_AbsolutlyCritical_GameState ACA;
	local SecondWave_RedFog_GameState RFA;

	local XComGameState_Unit Unit;
	local XComGameState NewGameState;
	NewGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Units");
	Unit=XComGameState_Unit(EventData);
	Epig=SecondWave_Epigenetics_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_Epigenetics_GameState'));
	ACA=SecondWave_AbsolutlyCritical_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_AbsolutlyCritical_GameState'));
	RFA=SecondWave_RedFog_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_RedFog_GameState'));

	if((Unit.IsAdvent()||Unit.IsAlien())&&!Unit.IsSoldier())
	{
		if(Epig.RandomEnemyStats(Unit))
			NewGameState.AddStateObject(Unit);
		
		ACA.AddAbsolutlyCriticalToUnit(Unit,NewGameState);
	}	
	RFA.AddRedFogAbilityToAllUnits(NewGameState);
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
	local XComGameState_Unit mUnit,Unit;
	local XComGameState_SecondWavePlus_UnitComponent UnitComp;
	local XComGameState NewGameState;

	history=`XCOMHISTORY;
	
	NewGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Updating Units");
	NCEA=SecondWave_NotCreatedEqually_GameState(history.GetSingleGameStateObjectForClass(class'SecondWave_NotCreatedEqually_GameState'));
	HidPA=SecondWave_HiddenPotential_GameState(history.GetSingleGameStateObjectForClass(class'SecondWave_HiddenPotential_GameState'));
	Epig=SecondWave_Epigenetics_GameState(history.GetSingleGameStateObjectForClass(class'SecondWave_Epigenetics_GameState'));
	ACA=SecondWave_AbsolutlyCritical_GameState(history.GetSingleGameStateObjectForClass(class'SecondWave_AbsolutlyCritical_GameState'));
	RFA=SecondWave_RedFog_GameState(history.GetSingleGameStateObjectForClass(class'SecondWave_RedFog_GameState'));
	RFA.InitListeners();

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit',mUnit)
	{
		Unit= XComGameState_Unit(NewGameState.CreateStateObject(mUnit.class,mUnit.ObjectID));
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
				`log(NCEA.bIs_NCE_Activated @","@NCEA.NCEStatModifiers.Length);
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
	local SecondWave_NotCreatedEqually_GameState NCEA;
	local UIRecruitSoldiers RSScreen;
	local StateObjectReference UnitRef;
	local XComGameState_Unit Recruit;
	local XComGameState_HeadquartersResistance ResistanceHQ;
	local X2ImageCaptureManager CapMan;		
	local Texture2D StaffPicture;
	local string ImageString;
	local string CostString;
	local string m_STR_Supplies;
	if(itemIndex == INDEX_NONE) return;

	RSScreen=UIRecruitSoldiers(`SCREENSTACK.GetFirstInstanceOf(class'UIRecruitSoldiers'));
	if(RSScreen==none) return;

	NCEA=SecondWave_NotCreatedEqually_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_NotCreatedEqually_GameState'));

	Recruit = RSScreen.m_arrRecruits[itemIndex];
	UnitRef = Recruit.GetReference();
	ResistanceHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();

	m_STR_Supplies=RSScreen.m_strSupplies;
	LocTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	Recruit= XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitRef.ObjectID));
	CostString = String(ResistanceHQ.GetRecruitSupplyCost()+NCEA.GetExpensiveTalentCost(Recruit));
	LocTag.IntValue0=ResistanceHQ.GetRecruitSupplyCost()+NCEA.GetExpensiveTalentCost(Recruit);
	//`log("LocTag.IntValue0:"@LocTag.IntValue0 @CostString @NCEA.GetExpensiveTalentCost(Recruit));
	RSScreen.AS_SetCost(RSScreen.m_strCost,CostString $Split(m_STR_Supplies,">",true));
	RSScreen.AS_SetDescription(Recruit.GetBackground());
	RSScreen.AS_SetTime(RSScreen.m_strTime, RSScreen.m_strInstant);
	RSScreen.AS_SetPicture(); // hide picture until character portrait is loaded
	
	CapMan = X2ImageCaptureManager(`XENGINE.GetImageCaptureManager());	
	ImageString = "UnitPicture"$UnitRef.ObjectID;
	StaffPicture = CapMan.GetStoredImage(UnitRef, name(ImageString));
	if(StaffPicture == none)
	{
		RSScreen.DeferredSoldierPictureListIndex = itemIndex;
		RSScreen.ClearTimer('DeferredUpdateSoldierPicture');
		RSScreen.SetTimer(0.1f, false, 'DeferredUpdateSoldierPicture');
	}	
	else
	{
		RSScreen.AS_SetPicture("img:///"$PathName(StaffPicture));
	}
}

function AddCommandersChoiceSpinner(UIArmory_Promotion PromotionScreen)
{
	local XComGameState_Unit PromotionScreenUnit;
	local string DisplayClassName;
	local int i;
	local array<X2SoldierClassTemplate> ClassTemplates;

	if(!SecondWave_CommandersChoice_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_CommandersChoice_GameState')).bIs_CommandersChoice_Activated)
		return;

	PromotionScreenUnit=XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(PromotionScreen.GetUnitRef().ObjectID));
	CC_ClassDisplayNames.Length=0;
	CC_ClassNames.Length=0;

	DisplayClassName=PromotionScreenUnit.GetSoldierClassTemplate().DisplayName  @"(" $string(PromotionScreenUnit.GetSoldierClassTemplate().DataName) $")";

	CC_ClassDisplayNames.AddItem(DisplayClassName);
	CC_ClassNames.AddItem(PromotionScreenUnit.GetSoldierClassTemplate().DataName);
	ClassTemplates=class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager().GetAllSoldierClassTemplates();
	for(i=0;i<ClassTemplates.Length;i++)
	{
		if(SecondWave_CommandersChoice_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_CommandersChoice_GameState')).ExcludedClasses.Find(string(ClassTemplates[i].DataName))!=-1)
			continue;

		if(ClassTemplates[i].DisplayName!="")
			DisplayClassName=ClassTemplates[i].DisplayName  @"(" $string(ClassTemplates[i].DataName) $")";
		else
			DisplayClassName=string(ClassTemplates[i].DataName) @"(" $string(ClassTemplates[i].DataName) $")";
			
		`log(DisplayClassName,,'Second Wave Plus - Commanders Choice');
		if(CC_ClassDisplayNames.Find(DisplayClassName)==-1)
		{
			CC_ClassDisplayNames.AddItem(DisplayClassName);
			CC_ClassNames.AddItem(ClassTemplates[i].DataName);	
		}	
	}

	CommandersChoiceSpinner= PromotionScreen.Spawn(class'UIMechaListItem', PromotionScreen);
	CommandersChoiceSpinner.InitListItem();
	CommandersChoiceSpinner.UpdateDataSpinner("",CC_ClassDisplayNames[0],OnChangedChoice_CC,ApplyCommandersChoice);
	CommandersChoiceSpinner.OriginBottomRight();		
	CommandersChoiceSpinner.AnchorBottomRight();
	CommandersChoiceSpinner.Spinner.selectedIndex=0;
	CommandersChoiceSpinner.Spinner.SetValue(CC_ClassDisplayNames[CommandersChoiceSpinner.Spinner.selectedIndex]);
	CommandersChoiceSpinner.Spinner.SetText("Commanders Choice");
//	CommandersChoiceSpinner.Button.SetX(CommandersChoiceSpinner.Button.X + CommandersChoiceSpinner.Button.Width * 1.5);
}

function OnChangedChoice_CC(UIListItemSpinner SpinnerControl, int Direction)
{
	if(CommandersChoiceSpinner.Spinner.selectedIndex > 0 && CommandersChoiceSpinner.Spinner.selectedIndex < CC_ClassNames.Length-1)
		CommandersChoiceSpinner.Spinner.selectedIndex += Direction;
	else if(CommandersChoiceSpinner.Spinner.selectedIndex == 0)
	{
		if(Direction == 1)
			CommandersChoiceSpinner.Spinner.selectedIndex++;
		else
			CommandersChoiceSpinner.Spinner.selectedIndex = CC_ClassNames.Length-1;
	}
	else if(CommandersChoiceSpinner.Spinner.selectedIndex == CC_ClassNames.Length-1)
	{
		if(Direction == 1)
			CommandersChoiceSpinner.Spinner.selectedIndex = 0;
		else
			--CommandersChoiceSpinner.Spinner.selectedIndex;
	}
	CommandersChoiceSpinner.Spinner.SetValue(CC_ClassDisplayNames[CommandersChoiceSpinner.Spinner.selectedIndex]);
}
function ApplyCommandersChoice()
{
	local SecondWave_CommandersChoice_GameState CCA;
	local XComGameState_Unit PromotionScreenUnit;
	local UIArmory_Promotion PromotionScreen;
	
	CCA=SecondWave_CommandersChoice_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_CommandersChoice_GameState'));
	PromotionScreen= UIArmory_Promotion(`SCREENSTACK.GetFirstInstanceOf(class'UIArmory_Promotion'));
	PromotionScreenUnit=XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(PromotionScreen.GetUnitRef().ObjectID)); 
	CCA.ChangeClass(PromotionScreenUnit,CC_ClassNames[CommandersChoiceSpinner.Spinner.selectedIndex]);
}