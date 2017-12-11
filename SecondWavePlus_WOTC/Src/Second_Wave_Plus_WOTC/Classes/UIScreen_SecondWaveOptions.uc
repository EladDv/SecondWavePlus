// This is an Unreal Script
                           
class UIScreen_SecondWaveOptions extends UISimpleScreen dependson(SecondWave_GameStateParent) config(SecondWavePlus_UISettings);

var int m_iCurrentSelection;

var UIBGBox BGB;
var UIX2PanelHeader Header;
var UIList List;
var UILargeButton LargeB;

var array<UIMechaListItem> ClickedItems;

var array<NCE_StatModifiers> SavedNCEItems;
var array<NCE_StatModifiers> SavedEpigeneticsItems;
var int TotalPoints_Enemy;
var int Tolerance_Enemy;
var int TotalPoints_XCom;
var int Tolerance_XCom;

var array<RedFogFormulatType> SavedRedFogTypes;


var array<UIRanges> StatChangesRanges;
var array<UIRanges> RedFogChangeRanges;

var int NCECheckboxPosition;
var int EpigeneticsCheckboxPosition;
var int RedFogCheckboxPosition;

var localized array<string> ApplyToTypes;
var localized array<string> OptionNames;
var localized array<string> UIRangesNames;
var localized array<string> UIRFRangesNames;
var localized string		SWPOptionsHeader;
var localized string		Percentage;
var localized string		Multiplier;

var array<UIMechaListItem> CreatedUIMLI;

var array<SecondWave_UIListItem_NCEStatChangesUpdate> NCEItems;
var array<SecondWave_UIListItem_NCEStatChangesUpdate> EpigeneticsItems;
var array<SecondWave_UIListItem_NCEStatChangesUpdate> RedFogItems;

var bool NCEWasCheckedBefore;

var SecondWave_CommandersChoice_GameState		Main_CommandersChoice_GameState;
var SecondWave_HiddenPotential_GameState		Main_HiddenPotential_GameState;
var SecondWave_Epigenetics_GameState			Main_Epigenetics_GameState;
var SecondWave_NotCreatedEqually_GameState		Main_NotCreatedEqually_GameState;
var SecondWave_AbsolutlyCritical_GameState		Main_AbsolutlyCritical_GameState;
var SecondWave_NewEconomy_GameState				Main_NewEconomy_GameState;
var SecondWave_RedFog_GameState					Main_RedFog_GameState;
var SecondWave_UIScreenSettings_GameState		Main_ScreenSettings_GameState;
var XComGameState StartState;

var bool Submitted;
simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{	
	super.InitScreen(InitController, InitMovie, InitName);
	
}

simulated function CreateScreen(optional bool CreateAnyways = false)
{
	local TRect rBG,rList,rHeader;

	if((`SCREENSTACK.HasInstanceOf(class'UIShellDifficulty') && !`SCREENSTACK.HasInstanceOf(class'UIPauseMenu')) || CreateAnyways)
	{
		StartState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Loading Data For New Campagin");
		Main_CommandersChoice_GameState=SecondWave_CommandersChoice_GameState(StartState.CreateStateObject(class'SecondWave_CommandersChoice_GameState'));
		Main_HiddenPotential_GameState=SecondWave_HiddenPotential_GameState(StartState.CreateStateObject(class'SecondWave_HiddenPotential_GameState'));
		Main_Epigenetics_GameState=SecondWave_Epigenetics_GameState(StartState.CreateStateObject(class'SecondWave_Epigenetics_GameState'));
		Main_NotCreatedEqually_GameState=SecondWave_NotCreatedEqually_GameState(StartState.CreateStateObject(class'SecondWave_NotCreatedEqually_GameState'));
		Main_AbsolutlyCritical_GameState=SecondWave_AbsolutlyCritical_GameState(StartState.CreateStateObject(class'SecondWave_AbsolutlyCritical_GameState'));
		Main_RedFog_GameState=SecondWave_RedFog_GameState(StartState.CreateStateObject(class'SecondWave_RedFog_GameState'));
		Main_NewEconomy_GameState=SecondWave_NewEconomy_GameState(StartState.CreateStateObject(class'SecondWave_NewEconomy_GameState'));
		Main_ScreenSettings_GameState=SecondWave_UIScreenSettings_GameState(StartState.CreateStateObject(class'SecondWave_UIScreenSettings_GameState'));
	}
	else
	{
		StartState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Loading Data For Change Campagin");
		Main_CommandersChoice_GameState=SecondWave_CommandersChoice_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_CommandersChoice_GameState'));
		Main_HiddenPotential_GameState=SecondWave_HiddenPotential_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_HiddenPotential_GameState'));
		Main_Epigenetics_GameState=SecondWave_Epigenetics_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_Epigenetics_GameState'));
		Main_NotCreatedEqually_GameState=SecondWave_NotCreatedEqually_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_NotCreatedEqually_GameState'));
		Main_AbsolutlyCritical_GameState=SecondWave_AbsolutlyCritical_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_AbsolutlyCritical_GameState'));
		Main_RedFog_GameState=SecondWave_RedFog_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_RedFog_GameState'));
		Main_NewEconomy_GameState=SecondWave_NewEconomy_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_NewEconomy_GameState'));
		Main_ScreenSettings_GameState=SecondWave_UIScreenSettings_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_UIScreenSettings_GameState'));
		
		/*
		Main_CommandersChoice_GameState=SecondWave_CommandersChoice_GameState(StartState.CreateStateObject(class'SecondWave_CommandersChoice_GameState',Main_CommandersChoice_GameState.ObjectID));
		Main_HiddenPotential_GameState=SecondWave_HiddenPotential_GameState(StartState.CreateStateObject(class'SecondWave_HiddenPotential_GameState',Main_HiddenPotential_GameState.ObjectID));
		Main_Epigenetics_GameState=SecondWave_Epigenetics_GameState(StartState.CreateStateObject(class'SecondWave_Epigenetics_GameState',Main_Epigenetics_GameState.ObjectID));
		Main_NotCreatedEqually_GameState=SecondWave_NotCreatedEqually_GameState(StartState.CreateStateObject(class'SecondWave_NotCreatedEqually_GameState',Main_NotCreatedEqually_GameState.ObjectID));
		Main_AbsolutlyCritical_GameState=SecondWave_AbsolutlyCritical_GameState(StartState.CreateStateObject(class'SecondWave_AbsolutlyCritical_GameState',Main_AbsolutlyCritical_GameState.ObjectID));
		Main_RedFog_GameState=SecondWave_RedFog_GameState(StartState.CreateStateObject(class'SecondWave_RedFog_GameState',Main_RedFog_GameState.ObjectID));
		Main_NewEconomy_GameState=SecondWave_NewEconomy_GameState(StartState.CreateStateObject(class'SecondWave_NewEconomy_GameState',Main_NewEconomy_GameState.ObjectID));
		Main_ScreenSettings_GameState=SecondWave_UIScreenSettings_GameState(StartState.CreateStateObject(class'SecondWave_UIScreenSettings_GameState',Main_ScreenSettings_GameState.ObjectID));
		*/
	}
	SavedNCEItems=Main_NotCreatedEqually_GameState.NCEStatModifiers;
	TotalPoints_XCom=Main_NotCreatedEqually_GameState.TotalPoints_XCom;
	Tolerance_XCom=Main_NotCreatedEqually_GameState.Tolerance_XCom;
	SavedEpigeneticsItems=Main_Epigenetics_GameState.EpigeneticsStatModifiers;
	TotalPoints_Enemy=Main_Epigenetics_GameState.TotalPoints_Enemy;
	Tolerance_Enemy=Main_Epigenetics_GameState.Tolerance_Enemy;
	StatChangesRanges=Main_ScreenSettings_GameState.StatChangeRanges;
	SavedRedFogTypes=Main_RedFog_GameState.FTypeRF;	
	RedFogChangeRanges=Main_ScreenSettings_GameState.RedFogChangeRanges;

	rBG=self.MakeRect(80,0,1760,990);
	rList=self.MakeRect(135,53,1808-160,1017-90);
	rHeader=self.MakeRect(90,60,1760,50);
	BGB=self.AddBG(rBG,eUIState_Normal);
	Header=AddHeader(rHeader,SWPOptionsHeader,MakeLinearColor(0, 1, 1, 0.85));
	Header.AnchorTopLeft();
	List=AddList(rList," ",OnChildClicked);
	List.ItemPadding=0;
	`log("Main_ScreenSettings_GameState.StatChangeRanges" @Main_ScreenSettings_GameState.StatChangeRanges.length);
	`log("StatChangesRanges" @StatChangesRanges.length);
	`log("Tolerance_XCom" @Tolerance_XCom);
	LargeB=Spawn(class'UILargeButton',self).InitLargeButton('HideThis',"Continue",,ContinueButton);
	LargeB.AnchorBottomRight();
	LargeB.AnimateIn(0);
	SetupSettings(true);

}

simulated public function ContinueButton(UIButton Button)
{
	SubmitToHistory();
	`XCOMHistory.CleanupPendingGameState(StartState);
	`SCREENSTACK.Pop(self);
}

simulated function OnRemoved()
{
	if(!Submitted)
	{	
		SubmitToHistory();
		`XCOMHistory.CleanupPendingGameState(StartState);
	}
	super.OnRemoved();
}

public function SubmitToHistory()
{
	local SecondWave_OptionsDataStore SWDataStore;
	
	SWDataStore=class'SecondWave_OptionsDataStore'.static.GetInstance();

	SWDataStore.SavedNCEItems = SavedNCEItems;
	SWDataStore.SavedEpigeneticsItems = SavedEpigeneticsItems;
	SWDataStore.StatChangesRanges = StatChangesRanges;
	SWDataStore.SavedRedFogTypes = SavedRedFogTypes;	
	SWDataStore.RedFogChangeRanges = RedFogChangeRanges;
	
	SWDataStore.SavedOptions.Length = 0;
	SWDataStore.AddOption("bIs_CommandersChoice_Activated",1,,Main_CommandersChoice_GameState.bIs_CommandersChoice_Activated);

	SWDataStore.AddOption("bIs_HiddenPotential_Activated",1,,Main_HiddenPotential_GameState.bIs_HiddenPotential_Activated);
	SWDataStore.AddOption("HiddenPotentialRandomPercentage",0,Main_HiddenPotential_GameState.HiddenPotentialRandomPercentage);

	SWDataStore.AddOption("bIs_Epigenetics_Activated",1,,Main_Epigenetics_GameState.bIs_Epigenetics_Activated);
	SWDataStore.AddOption("bIs_EpigeneticsRobotics_Activated",1,,Main_Epigenetics_GameState.bIs_EpigeneticsRobotics_Activated);
	SWDataStore.AddOption("TotalPoints_Enemy",0,Main_Epigenetics_GameState.TotalPoints_Enemy);
	SWDataStore.AddOption("Tolerance_Enemy",0,Main_Epigenetics_GameState.Tolerance_Enemy);

	SWDataStore.AddOption("bIs_NCE_Activated",1,,Main_NotCreatedEqually_GameState.bIs_NCE_Activated);
	SWDataStore.AddOption("bIs_NCERobotic_Activated",1,,Main_NotCreatedEqually_GameState.bIs_NCERobotic_Activated);
	SWDataStore.AddOption("bIs_ExpensiveTalent_Activated",1,,Main_NotCreatedEqually_GameState.bIs_ExpensiveTalent_Activated);
	SWDataStore.AddOption("ExpensiveTalentMultiplier",2,,,Main_NotCreatedEqually_GameState.ExpensiveTalentMultiplier);
	SWDataStore.AddOption("TotalPoints_XCom",0,Main_NotCreatedEqually_GameState.TotalPoints_XCom);
	SWDataStore.AddOption("Tolerance_XCom",0,Main_NotCreatedEqually_GameState.Tolerance_XCom);
		
	SWDataStore.AddOption("bIs_AbsolutlyCritical_Activated",1,,Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Activated);
	SWDataStore.AddOption("bIs_AbsolutlyCritical_XCOM_Activated",1,,Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_XCOM_Activated);
	SWDataStore.AddOption("bIs_AbsolutlyCritical_Advent_Activated",1,,Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Advent_Activated);
	SWDataStore.AddOption("bIs_AbsolutlyCritical_Aliens_Activated",1,,Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Aliens_Activated);

	SWDataStore.AddOption("b_IsRedFogActive",1,,Main_RedFog_GameState.b_IsRedFogActive);
	SWDataStore.AddOption("b_IsRedFogActive_Aliens",1,,Main_RedFog_GameState.b_IsRedFogActive_Aliens);
	SWDataStore.AddOption("b_IsRedFogActive_Advent",1,,Main_RedFog_GameState.b_IsRedFogActive_Advent);
	SWDataStore.AddOption("b_IsRedFogActive_XCom",1,,Main_RedFog_GameState.b_IsRedFogActive_XCom);
	SWDataStore.AddOption("b_IsRedFogActive_Robotics",1,,Main_RedFog_GameState.b_IsRedFogActive_Robotics);
	SWDataStore.AddOption("b_UseGaussianEquasion",1,,Main_RedFog_GameState.b_UseGaussianEquasion);

	SWDataStore.AddOption("b_IsNewEconomyActive",1,,Main_NewEconomy_GameState.b_IsNewEconomyActive);
	SWDataStore.AddOption("NewEconomyMaxRandomPercentage",0,Main_NewEconomy_GameState.NewEconomyMaxRandomPercentage);
	SWDataStore.AddOption("MinimalRegionIncome",0,Main_NewEconomy_GameState.MinimalRegionIncome);


	SWDataStore.Check();
	
	Submitted=true;
	/*StartState.AddStateObject(Main_CommandersChoice_GameState);
	StartState.AddStateObject(Main_HiddenPotential_GameState);
	StartState.AddStateObject(Main_Epigenetics_GameState);
	StartState.AddStateObject(Main_NotCreatedEqually_GameState);
	StartState.AddStateObject(Main_AbsolutlyCritical_GameState);
	StartState.AddStateObject(Main_NewEconomy_GameState);
	StartState.AddStateObject(Main_RedFog_GameState);
	StartState.AddStateObject(Main_ScreenSettings_GameState);

	`XCOMHistory.AddGameStateToHistory(StartState);*/

}

simulated public function SetupSettings(optional bool RunOnce=false)
{
	List.ClearItems();
	CreatedUIMLI.Length=0;
	
	ShowNCE(Main_NotCreatedEqually_GameState.bIs_NCE_Activated);
	ShowNCE_Robotics(Main_NotCreatedEqually_GameState.bIs_NCERobotic_Activated);
	ShowExpensiveTalent(Main_NotCreatedEqually_GameState.bIs_ExpensiveTalent_Activated);
	ShowAbsolutlyCritical(Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Activated);
	ShowCommandersChoice(Main_CommandersChoice_GameState.bIs_CommandersChoice_Activated);
	ShowEpigenetics(Main_Epigenetics_GameState.bIs_Epigenetics_Activated);
	ShowEpigeneticsRobotics(Main_Epigenetics_GameState.bIs_EpigeneticsRobotics_Activated);
	ShowHiddenPotential(Main_HiddenPotential_GameState.bIs_HiddenPotential_Activated);
	ShowRedFog(Main_RedFog_GameState.b_IsRedFogActive);
	ShowNewEconomy(Main_NewEconomy_GameState.b_IsNewEconomyActive);

	List.RealizeList();	
	List.RealizeItems(0);
	List.AnimateIn(0.1f);
	List.Show();	
	`log("Setup Settings");
}

function UpdateCompatibleStatTypes(out array<ECharStatType> CompatibleStats)
{
	CompatibleStats.AddItem(eStat_HP);
	CompatibleStats.AddItem(eStat_Offense);
	CompatibleStats.AddItem(eStat_Defense);
	CompatibleStats.AddItem(eStat_Mobility);
	CompatibleStats.AddItem(eStat_Will);
	CompatibleStats.AddItem(eStat_Hacking);
	CompatibleStats.AddItem(eStat_SightRadius);
	CompatibleStats.AddItem(eStat_Dodge);
	CompatibleStats.AddItem(eStat_ArmorMitigation);
	CompatibleStats.AddItem(eStat_PsiOffense);
	CompatibleStats.AddItem(eStat_HackDefense);
	CompatibleStats.AddItem(eStat_DetectionRadius);
	CompatibleStats.AddItem(eStat_CritChance);
	CompatibleStats.AddItem(eStat_Strength);
	CompatibleStats.AddItem(eStat_HearingRadius);
	CompatibleStats.AddItem(eStat_FlankingCritChance);
	CompatibleStats.AddItem(eStat_ShieldHP);
	CompatibleStats.AddItem(eStat_FlankingAimBonus);	
}

simulated function ShowNCE(bool Activated)
{
	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem());
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataDescription(class'UIUtilities_Text'.static.AlignCenter((class'UIUtilities_Text'.static.StyleText(OptionNames[0],eUITextStyle_Tooltip_Title))));
	CreatedUIMLI[CreatedUIMLI.Length-1].BG.SetAlpha(0);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(true);
	CreatedUIMLI[CreatedUIMLI.Length-1].MC.FunctionVoid("onReceiveFocus");
	CreatedUIMLI[CreatedUIMLI.Length-1].OnReceiveFocus();	
	CreatedUIMLI[CreatedUIMLI.Length-1].MC.FunctionVoid("onLoseFocus");
	CreatedUIMLI[CreatedUIMLI.Length-1].OnLoseFocus();	

	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem());
	//CreatedUIMLI[CreatedUIMLI.Length]=Spawn(Class'UIMechaListItem', List.itemContainer).InitListItem();
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataCheckbox(OptionNames[0],"",Activated,UpdateNCE);
	CreatedUIMLI[CreatedUIMLI.Length-1].Checkbox.SetReadOnly(false);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(false);
	CreatedUIMLI[CreatedUIMLI.Length-1].AnimateIn(0);
	NCECheckboxPosition=List.GetItemIndex(CreatedUIMLI[CreatedUIMLI.Length-1]);
	ShowNCEItems(Activated);	
	
	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem());
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataButton("Add New Item","Add",OnAddNewNCEClicked);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(!Activated);
	CreatedUIMLI[CreatedUIMLI.Length-1].AnimateIn(0);
}


simulated function UpdateNCE(UICheckbox CheckBox) // TODO: Remember to put all the checkbox results back into the game states!
{
	local int i;
	for(i=1;i<=SavedNCEItems.Length+1;i++)
	{
		UIMechaListItem(List.GetItem(NCECheckboxPosition+i)).SetDisabled(!CheckBox.bChecked);
	}	
	Main_NotCreatedEqually_GameState.bIs_NCE_Activated=CheckBox.bChecked;
}

simulated function ShowNCEItems(bool Activated)
{
	local NCE_StatModifiers SCSingle;
	local string SCString;
	local array<ECharStatType> CompatibleStats;
	local int Found;	
	local UIMechaListItem AddNewItem;
	UpdateCompatibleStatTypes(CompatibleStats);
	`log("SavedNCEItems Length"@SavedNCEItems.Length);	

	foreach SavedNCEItems(SCSingle)
	{
		Found=StatChangesRanges.Find('StatType',SCSingle.StatType);
		if(Found==-1)
			continue;
		
		SCString="Stat:"$SCSingle.StatType @", Range:"$SCSingle.Stat_Range @", Min Stat:"$SCSingle.Stat_Min @", Cost:"$SCSingle.Stat_Cost;
		AddNewItem=UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem();
		AddNewItem.UpdateDataButton(SCString,"Edit",OnNCEClicked);
		AddNewItem.Value.Text=string(Found);
		AddNewItem.SetDisabled(!Activated);
	}
	//AddNewItem=UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem();
	//AddNewItem.UpdateDataButton("Create New Not Create Equally Stat Randomizer","Add",CreateNewNCEItem);
	
	//CheckBox.SetChecked(saveSettings);
}

simulated function OnNCEClicked(UIButton Button)
{
	local int buttonIndex;
	buttonIndex=List.GetItemIndex(UIMechaListItem(Button.ParentPanel));
	if(buttonIndex==-1)
	{
		`log("Error! got a non existent NCE button");
		return;
	}
	OpenNewNCEStatScreen(SavedNCEItems[(buttonIndex-NCECheckboxPosition)-1],((buttonIndex-NCECheckboxPosition)-1));

}

function OnAddNewNCEClicked(UIButton Button)
{
	local array<ECharStatType> TempHolder;
	local ECharStatType NewNCE;
	local NCE_StatModifiers SCSingle;
	local int i;

	UpdateCompatibleStatTypes(TempHolder);
	for(i=0;i<TempHolder.Length;i++)
	{
		if(SavedNCEItems.Find('StatType',TempHolder[i])!=-1 || StatChangesRanges.Find('StatType',TempHolder[i])==-1)
			continue;

		else
		{
			NewNCE=TempHolder[i];
			break;
		}
	}
	i=StatChangesRanges.Find('StatType',NewNCE);
	SCSingle.StatType=NewNCE;
	SCSingle.Stat_Range=StatChangesRanges[i].Range;
	SCSingle.Stat_Min=StatChangesRanges[i].Min;
	SCSingle.Stat_Cost=StatChangesRanges[i].Cost;

	OpenNewNCEStatScreen(SCSingle,i);
	
}

simulated function array<ECharStatType> GetAvailableNCEStatTypes(optional ECharStatType InsertAtStart=eStat_Invalid)
{
	local array<ECharStatType> TempHolder,OutTypes;
	local int i;

	UpdateCompatibleStatTypes(TempHolder);
	if(InsertAtStart!=eStat_Invalid)
	{
		OutTypes.AddItem(InsertAtStart);
	}
	for(i=0;i<TempHolder.Length;i++)
	{
		if(SavedNCEItems.Find('StatType',TempHolder[i])!=-1 || StatChangesRanges.Find('StatType',TempHolder[i])==-1)
			continue;

		else
			OutTypes.AddItem(TempHolder[i]);
	}
	return OutTypes;	
}

simulated function OpenNewNCEStatScreen(NCE_StatModifiers SCSingle , int Found)
{
	local SecondWave_UIListItem_NCEStatChangesUpdate LocalNCEScreen;
	local array<ECharStatType> CompatibleStats;
	if(Found==-1 ||StatChangesRanges.Find('StatType',SCSingle.StatType)==-1 )
		return;

	UpdateCompatibleStatTypes(CompatibleStats);

	LocalNCEScreen=Spawn(class'SecondWave_UIListItem_NCEStatChangesUpdate',self);
	`SCREENSTACK.Push(LocalNCEScreen);	
	LocalNCEScreen.InitSCUpdateItem(SCSingle,StatChangesRanges,CompatibleStats,GetAvailableNCEStatTypes(SCSingle.StatType),UIRangesNames,OnSavedClickedNCE,OnRemovedClickedNCE,OnCancelClickedNCE);	
	`log("Setup Saved Settings");	
}

function OnRemovedClickedNCE(SecondWave_UIListItem_NCEStatChangesUpdate SCU)
{
	SavedNCEItems.RemoveItem(SCU.SCSingle);
	`SCREENSTACK.Pop(SCU);
	SCU.Remove();
	SetupSettings();
}
function OnSavedClickedNCE(SecondWave_UIListItem_NCEStatChangesUpdate SCU)
{
	local int i;
	i=SavedNCEItems.find('StatType',SCU.SCSingle.StatType);
	if(i!=-1)
		SavedNCEItems[i]=SCU.TempSM;

	SCU.SCSingle=SCU.TempSM;
	`SCREENSTACK.Pop(SCU);
	SCU.Remove();
	SetupSettings();
}

function OnCancelClickedNCE(SecondWave_UIListItem_NCEStatChangesUpdate SCU)
{
	`SCREENSTACK.Pop(SCU);
	SCU.Remove();
	SetupSettings();
}


simulated function ShowNCE_Robotics(bool Activated)
{
	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem());
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataCheckbox(OptionNames[1],"",Activated,UpdateNCE_Robotics);	
}

simulated function UpdateNCE_Robotics(UICheckbox CheckBox)
{
	Main_NotCreatedEqually_GameState.bIs_NCERobotic_Activated=CheckBox.bChecked;
}

simulated function ShowExpensiveTalent(bool Activated)
{
	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem());
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataCheckbox(OptionNames[2],"",Activated,UpdateExpensiveTalent);	
	
	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem());
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataSlider(Multiplier,string(1 + Main_NotCreatedEqually_GameState.ExpensiveTalentMultiplier),int(100*Main_NotCreatedEqually_GameState.ExpensiveTalentMultiplier/2),,OnExpensiveTalentChanged);	
	CreatedUIMLI[CreatedUIMLI.Length-1].Slider.SetStepSize(2.5f);
	CreatedUIMLI[CreatedUIMLI.Length-1].Slider.SetPercent(100*Main_NotCreatedEqually_GameState.ExpensiveTalentMultiplier/2);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(!Activated);
	CreatedUIMLI[CreatedUIMLI.Length-1].AnimateIn(0);
}


simulated function UpdateExpensiveTalent(UICheckbox CheckBox)
{
	Main_NotCreatedEqually_GameState.bIs_ExpensiveTalent_Activated=CheckBox.bChecked;
	CreatedUIMLI[CreatedUIMLI.Find(UIMechaListItem(CheckBox.ParentPanel))+1].SetDisabled(!CheckBox.bChecked);
}
	
function OnExpensiveTalentChanged(UISlider sliderControl)
{
	sliderControl.SetText(string(1+(sliderControl.percent/50.0)));
	Main_NotCreatedEqually_GameState.ExpensiveTalentMultiplier=(sliderControl.percent/50.0);
}


simulated function ShowAbsolutlyCritical(bool Activated)
{
	local int ACState;
	
	ACState=int(Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_XCOM_Activated)+2*int(Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Advent_Activated)+4*int(Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Aliens_Activated);

	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem());
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataDescription(class'UIUtilities_Text'.static.AlignCenter((class'UIUtilities_Text'.static.StyleText(OptionNames[3],eUITextStyle_Tooltip_Title))));
	CreatedUIMLI[CreatedUIMLI.Length-1].BG.SetAlpha(0);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(true);
	CreatedUIMLI[CreatedUIMLI.Length-1].MC.FunctionVoid("onReceiveFocus");
	CreatedUIMLI[CreatedUIMLI.Length-1].OnReceiveFocus();	
	CreatedUIMLI[CreatedUIMLI.Length-1].MC.FunctionVoid("onLoseFocus");
	CreatedUIMLI[CreatedUIMLI.Length-1].OnLoseFocus();	

	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem());
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataSpinner(OptionNames[3],ApplyToTypes[ACState],UpdateAbsolutlyCritical);		
	CreatedUIMLI[CreatedUIMLI.Length-1].Spinner.selectedIndex=ACState;
	CreatedUIMLI[CreatedUIMLI.Length-1].AnimateIn(0);
}



simulated function UpdateAbsolutlyCritical(UIListItemSpinner SpinnerControl, int Direction)
{
	local int currentIndex;
	currentIndex=ApplyToTypes.Find(SpinnerControl.value);

	if(currentIndex== ApplyToTypes.Length-1 && Direction==1 )
		currentIndex=0;
	else if(currentIndex==0 && Direction==-1)
		currentIndex=ApplyToTypes.Length-1;
	else
		currentIndex+=Direction;
	
	switch (currentIndex)
	{
		case 0:
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Activated=false;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_XCOM_Activated=false;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Advent_Activated=false;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Aliens_Activated=false;
			break;
		case 1:
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Activated=true;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_XCOM_Activated=true;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Advent_Activated=false;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Aliens_Activated=false;
			break;
		case 2:
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Activated=true;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_XCOM_Activated=false;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Advent_Activated=true;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Aliens_Activated=false;			
			break;
		case 3:
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Activated=true;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_XCOM_Activated=true;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Advent_Activated=true;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Aliens_Activated=false;			
			break;
		case 4:
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Activated=true;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_XCOM_Activated=false;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Advent_Activated=false;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Aliens_Activated=true;			
			break;
		case 5:
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Activated=true;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_XCOM_Activated=true;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Advent_Activated=false;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Aliens_Activated=true;			
			break;
		case 6:
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Activated=true;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_XCOM_Activated=false;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Advent_Activated=true;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Aliens_Activated=true;			
			break;
		case 7:
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Activated=true;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_XCOM_Activated=true;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Advent_Activated=true;
			Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Aliens_Activated=true;			
			break;
		
	}
	SpinnerControl.SetValue(ApplyToTypes[currentIndex]);
	SpinnerControl.selectedIndex=currentIndex;
	
}

simulated function ShowCommandersChoice(bool Activated,optional bool RunOnce=false)
{
	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem());
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataDescription(class'UIUtilities_Text'.static.AlignCenter((class'UIUtilities_Text'.static.StyleText(OptionNames[4],eUITextStyle_Tooltip_Title))));
	CreatedUIMLI[CreatedUIMLI.Length-1].BG.SetAlpha(0);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(true);
	CreatedUIMLI[CreatedUIMLI.Length-1].MC.FunctionVoid("onReceiveFocus");
	CreatedUIMLI[CreatedUIMLI.Length-1].OnReceiveFocus();	
	CreatedUIMLI[CreatedUIMLI.Length-1].MC.FunctionVoid("onLoseFocus");
	CreatedUIMLI[CreatedUIMLI.Length-1].OnLoseFocus();	

	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem());
	//CreatedUIMLI[CreatedUIMLI.Length]=Spawn(Class'UIMechaListItem', List.itemContainer).InitListItem();
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataCheckbox(OptionNames[4],"",Activated,UpdateCommandersChoice);
	CreatedUIMLI[CreatedUIMLI.Length-1].Checkbox.SetReadOnly(false);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(false);
	CreatedUIMLI[CreatedUIMLI.Length-1].AnimateIn(0);	
}

simulated function UpdateCommandersChoice(UICheckbox CheckBox)
{
	Main_CommandersChoice_GameState.bIs_CommandersChoice_Activated=CheckBox.bChecked;
}

simulated function ShowEpigenetics(bool Activated)
{
	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem());
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataDescription(class'UIUtilities_Text'.static.AlignCenter((class'UIUtilities_Text'.static.StyleText(OptionNames[5],eUITextStyle_Tooltip_Title))));
	CreatedUIMLI[CreatedUIMLI.Length-1].BG.SetAlpha(0);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(true);
	CreatedUIMLI[CreatedUIMLI.Length-1].MC.FunctionVoid("onReceiveFocus");
	CreatedUIMLI[CreatedUIMLI.Length-1].OnReceiveFocus();	
	CreatedUIMLI[CreatedUIMLI.Length-1].MC.FunctionVoid("onLoseFocus");
	CreatedUIMLI[CreatedUIMLI.Length-1].OnLoseFocus();	

	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem());
	//CreatedUIMLI[CreatedUIMLI.Length]=Spawn(Class'UIMechaListItem', List.itemContainer).InitListItem();
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataCheckbox(OptionNames[5],"",Activated,UpdateEpigenetics);
	CreatedUIMLI[CreatedUIMLI.Length-1].Checkbox.SetReadOnly(false);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(false);
	CreatedUIMLI[CreatedUIMLI.Length-1].AnimateIn(0);
	EpigeneticsCheckboxPosition=List.GetItemIndex(CreatedUIMLI[CreatedUIMLI.Length-1]);
	ShowEpigeneticsItems(Activated);	

	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem());
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataButton("Add New Item","Add",OnAddNewEpigeneticsClicked);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(!Activated);
	CreatedUIMLI[CreatedUIMLI.Length-1].AnimateIn(0);
	
}
simulated function UpdateEpigenetics(UICheckbox CheckBox)
{
	local int i;
	for(i=1;i<=SavedEpigeneticsItems.Length+1/*+3*/;i++)
	{
		UIMechaListItem(List.GetItem(EpigeneticsCheckboxPosition+i)).SetDisabled(!CheckBox.bChecked);
	}		
	Main_Epigenetics_GameState.bIs_Epigenetics_Activated=CheckBox.bChecked;
}
	
simulated function ShowEpigeneticsItems(bool Activated)
{
	local NCE_StatModifiers SCSingle;
	local string SCString;
	local array<ECharStatType> CompatibleStats;
	local int Found;	
	local UIMechaListItem AddNewItem;
	UpdateCompatibleStatTypes(CompatibleStats);
	`log("SavedEpigeneticsItems Length"@SavedEpigeneticsItems.Length);	

	foreach SavedEpigeneticsItems(SCSingle)
	{
		Found=StatChangesRanges.Find('StatType',SCSingle.StatType);
		if(Found==-1)
			continue;
		
		SCString="Stat:"$SCSingle.StatType @", Range:"$SCSingle.Stat_Range @", Min Stat:"$SCSingle.Stat_Min @", Cost:"$SCSingle.Stat_Cost;
		AddNewItem=UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem();
		AddNewItem.UpdateDataButton(SCString,"Edit",OnEpigeneticsClicked);
		AddNewItem.Value.Text=string(Found);
		AddNewItem.SetDisabled(!Activated);
	}
	//AddNewItem=UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem();
	//AddNewItem.UpdateDataButton("Create New Not Create Equally Stat Randomizer","Add",CreateNewNCEItem);
	
	//CheckBox.SetChecked(saveSettings);
}

function OnAddNewEpigeneticsClicked(UIButton Button)
{
	local array<ECharStatType> TempHolder;
	local ECharStatType NewNCE;
	local NCE_StatModifiers SCSingle;
	local int i;

	UpdateCompatibleStatTypes(TempHolder);
	for(i=0;i<TempHolder.Length;i++)
	{
		if(SavedEpigeneticsItems.Find('StatType',TempHolder[i])!=-1 || StatChangesRanges.Find('StatType',TempHolder[i])==-1)
			continue;

		else
		{
			NewNCE=TempHolder[i];
			break;
		}
	}
	i=StatChangesRanges.Find('StatType',NewNCE);
	SCSingle.StatType=NewNCE;
	SCSingle.Stat_Range=StatChangesRanges[i].Range;
	SCSingle.Stat_Min=StatChangesRanges[i].Min;
	SCSingle.Stat_Cost=StatChangesRanges[i].Cost;

	OpenNewEpigeneticsStatScreen(SCSingle,i);
	
}

simulated function OnEpigeneticsClicked(UIButton Button)
{
	local int buttonIndex;
	buttonIndex=List.GetItemIndex(UIMechaListItem(Button.ParentPanel));
	if(buttonIndex==-1)
	{
		`log("Error! got a non existent Epigenetics button");
		return;
	}
	OpenNewEpigeneticsStatScreen(SavedEpigeneticsItems[(buttonIndex-EpigeneticsCheckboxPosition)-1],((buttonIndex-EpigeneticsCheckboxPosition)-1));
}

simulated function OpenNewEpigeneticsStatScreen(NCE_StatModifiers SCSingle , int Found)
{
	local SecondWave_UIListItem_NCEStatChangesUpdate LocalNCEScreen;
	local array<ECharStatType> CompatibleStats;

	if(Found==-1)
		return;

	UpdateCompatibleStatTypes(CompatibleStats);
	LocalNCEScreen=Spawn(class'SecondWave_UIListItem_NCEStatChangesUpdate',self);
	`SCREENSTACK.Push(LocalNCEScreen);	
	LocalNCEScreen.InitSCUpdateItem(SCSingle,StatChangesRanges,CompatibleStats,GetAvailableEpiStatTypes(SCSingle.StatType),UIRangesNames,OnSavedClickedEpi,OnRemovedClickedEpi,OnCancelClickedEpi);	
	`log("Setup Saved Settings");	
}

function OnRemovedClickedEpi(SecondWave_UIListItem_NCEStatChangesUpdate SCU)
{
	SavedEpigeneticsItems.RemoveItem(SCU.SCSingle);
	`SCREENSTACK.Pop(SCU);
	SCU.Remove();
	SetupSettings();
}
function OnSavedClickedEpi(SecondWave_UIListItem_NCEStatChangesUpdate SCU)
{
	local int i;
	i=SavedEpigeneticsItems.find('StatType',SCU.SCSingle.StatType);
	if(i!=-1)
		SavedEpigeneticsItems[i]=SCU.TempSM;

	SCU.SCSingle=SCU.TempSM;
	`SCREENSTACK.Pop(SCU);
	SCU.Remove();
	SetupSettings();
}

function OnCancelClickedEpi(SecondWave_UIListItem_NCEStatChangesUpdate SCU)
{
	`SCREENSTACK.Pop(SCU);
	SCU.Remove();
	SetupSettings();
}

simulated function ShowEpigeneticsRobotics(bool Activated)
{
	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem());
	//CreatedUIMLI[CreatedUIMLI.Length]=Spawn(Class'UIMechaListItem', List.itemContainer).InitListItem();
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataCheckbox(OptionNames[6],"",Activated,UpdateEpigeneticsRobotics);
	CreatedUIMLI[CreatedUIMLI.Length-1].Checkbox.SetReadOnly(false);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(false);
	CreatedUIMLI[CreatedUIMLI.Length-1].AnimateIn(0);
}

simulated function UpdateEpigeneticsRobotics(UICheckbox CheckBox)
{
	Main_Epigenetics_GameState.bIs_EpigeneticsRobotics_Activated=CheckBox.bChecked;
}
simulated function array<ECharStatType> GetAvailableEpiStatTypes(optional ECharStatType InsertAtStart=eStat_Invalid)
{
	local array<ECharStatType> TempHolder,OutTypes;
	local int i;

	UpdateCompatibleStatTypes(TempHolder);
	if(InsertAtStart!=eStat_Invalid)
	{
		OutTypes.AddItem(InsertAtStart);
	}
	for(i=0;i<TempHolder.Length;i++)
	{
		if(SavedEpigeneticsItems.Find('StatType',TempHolder[i])!=-1 || RedFogChangeRanges.Find('StatType',TempHolder[i])==-1)
			continue;

		else
			OutTypes.AddItem(TempHolder[i]);
	}
	return OutTypes;	
}

simulated function ShowHiddenPotential(bool Activated)
{
	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem());
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataDescription(class'UIUtilities_Text'.static.AlignCenter((class'UIUtilities_Text'.static.StyleText(OptionNames[7],eUITextStyle_Tooltip_Title))));
	CreatedUIMLI[CreatedUIMLI.Length-1].BG.SetAlpha(0);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(true);
	CreatedUIMLI[CreatedUIMLI.Length-1].MC.FunctionVoid("onReceiveFocus");
	CreatedUIMLI[CreatedUIMLI.Length-1].OnReceiveFocus();	
	CreatedUIMLI[CreatedUIMLI.Length-1].MC.FunctionVoid("onLoseFocus");
	CreatedUIMLI[CreatedUIMLI.Length-1].OnLoseFocus();	

	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem());
	//CreatedUIMLI[CreatedUIMLI.Length]=Spawn(Class'UIMechaListItem', List.itemContainer).InitListItem();
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataCheckbox(OptionNames[7],"",Activated,UpdateHiddenPotential);
	CreatedUIMLI[CreatedUIMLI.Length-1].Checkbox.SetReadOnly(false);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(false);
	CreatedUIMLI[CreatedUIMLI.Length-1].AnimateIn(0);
		
	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem());
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataSlider(Percentage,string(Main_HiddenPotential_GameState.HiddenPotentialRandomPercentage),Main_HiddenPotential_GameState.HiddenPotentialRandomPercentage,,UpdatedHiddenPotentialPerc);	
	CreatedUIMLI[CreatedUIMLI.Length-1].Slider.SetStepSize(1.0);
	CreatedUIMLI[CreatedUIMLI.Length-1].Slider.SetPercent(Main_HiddenPotential_GameState.HiddenPotentialRandomPercentage);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(!Activated);
	CreatedUIMLI[CreatedUIMLI.Length-1].AnimateIn(0);
}
simulated function UpdateHiddenPotential(UICheckbox CheckBox)
{
	Main_HiddenPotential_GameState.bIs_HiddenPotential_Activated=CheckBox.bChecked;
	CreatedUIMLI[CreatedUIMLI.Find(UIMechaListItem(CheckBox.ParentPanel))+1].SetDisabled(!CheckBox.bChecked);
}
simulated function UpdatedHiddenPotentialPerc (UISlider sliderControl)
{
	sliderControl.SetText(string(int(sliderControl.percent)));
	Main_HiddenPotential_GameState.HiddenPotentialRandomPercentage=(int(sliderControl.percent));
}

simulated function ShowRedFog(bool Activated)
{
	local int RFState;
	
	RFState=int(Main_RedFog_GameState.b_IsRedFogActive_XCom)+2*int(Main_RedFog_GameState.b_IsRedFogActive_Advent)+4*int(Main_RedFog_GameState.b_IsRedFogActive_Aliens);

	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem());
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataDescription(class'UIUtilities_Text'.static.AlignCenter((class'UIUtilities_Text'.static.StyleText(OptionNames[8],eUITextStyle_Tooltip_Title))));
	CreatedUIMLI[CreatedUIMLI.Length-1].BG.SetAlpha(0);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(true);
	CreatedUIMLI[CreatedUIMLI.Length-1].MC.FunctionVoid("onReceiveFocus");
	CreatedUIMLI[CreatedUIMLI.Length-1].OnReceiveFocus();	
	CreatedUIMLI[CreatedUIMLI.Length-1].MC.FunctionVoid("onLoseFocus");
	CreatedUIMLI[CreatedUIMLI.Length-1].OnLoseFocus();	

	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem());
	//CreatedUIMLI[CreatedUIMLI.Length]=Spawn(Class'UIMechaListItem', List.itemContainer).InitListItem();
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataSpinner(OptionNames[8],ApplyToTypes[RFState],UpdateRedFogSpinner);		
	CreatedUIMLI[CreatedUIMLI.Length-1].Spinner.selectedIndex=RFState;
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(false,"Causes bugs and issues");
	CreatedUIMLI[CreatedUIMLI.Length-1].AnimateIn(0);

	ShowRedFogItems(Main_RedFog_GameState.b_IsRedFogActive);
	RedFogCheckboxPosition=List.GetItemIndex(CreatedUIMLI[CreatedUIMLI.Length-1]);

	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem());
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataButton("Add New Item","Add",OnAddNewRFClicked);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(!Activated);
	CreatedUIMLI[CreatedUIMLI.Length-1].AnimateIn(0);

	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem());
	//CreatedUIMLI[CreatedUIMLI.Length]=Spawn(Class'UIMechaListItem', List.itemContainer).InitListItem();
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataCheckbox(OptionNames[9],"",Main_RedFog_GameState.b_IsRedFogActive_Robotics,UpdateRoboticRF);
	CreatedUIMLI[CreatedUIMLI.Length-1].Checkbox.SetReadOnly(false);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(RFState==0);
	CreatedUIMLI[CreatedUIMLI.Length-1].AnimateIn(0);

	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem());
	//CreatedUIMLI[CreatedUIMLI.Length]=Spawn(Class'UIMechaListItem', List.itemContainer).InitListItem();
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataCheckbox(OptionNames[10],"",Main_RedFog_GameState.b_UseGaussianEquasion,UpdateGaussianRF);
	CreatedUIMLI[CreatedUIMLI.Length-1].Checkbox.SetReadOnly(false);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(RFState==0);
	CreatedUIMLI[CreatedUIMLI.Length-1].AnimateIn(0);
}

function ShowRedFogItems(bool Activated)
{
	local RedFogFormulatType RFFSingle;
	local string RFFString;
	local array<string> RFTypeNames;
	local array<ECharStatType> CompatibleStats;
	local int Found;	
	local UIMechaListItem AddNewItem;
	UpdateCompatibleStatTypes(CompatibleStats);
	`log("SavedNCEItems Length"@SavedNCEItems.Length);	
	
	RFTypeNames.AddItem("Aim-Like");
	RFTypeNames.AddItem("Mobility-Like");
	RFTypeNames.AddItem("Will-Like");

	foreach SavedRedFogTypes(RFFSingle)
	{
		Found=RedFogChangeRanges.Find('StatType',RFFSingle.StatType);
		if(Found==-1)
			continue;
		
		RFFString="Stat:"$RFFSingle.StatType @", Range:"$RFFSingle.Range @", Calculation Type:"@RFTypeNames[RFFSingle.RedFogCalcType];
		AddNewItem=UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem();
		AddNewItem.UpdateDataButton(RFFString,"Edit",OnRedFogClicked);
		AddNewItem.Value.Text=string(Found);
		AddNewItem.SetDisabled(!Activated);
	}
	//AddNewItem=UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem();
	//AddNewItem.UpdateDataButton("Create New Not Create Equally Stat Randomizer","Add",CreateNewNCEItem);
	
	//CheckBox.SetChecked(saveSettings);
}

simulated function OnRedFogClicked(UIButton Button)
{
	local int buttonIndex;
	buttonIndex=List.GetItemIndex(UIMechaListItem(Button.ParentPanel));
	if(buttonIndex==-1)
	{
		`log("Error! got a non existent RF button");
		return;
	}
	OpenNewRedFogStatScreen(SavedRedFogTypes[(buttonIndex-RedFogCheckboxPosition)-1],((buttonIndex-RedFogCheckboxPosition)-1));
	
}

simulated function array<ECharStatType> GetAvailableRFStatTypes(optional ECharStatType InsertAtStart=eStat_Invalid)
{
	local array<ECharStatType> TempHolder,OutTypes;
	local int i;

	UpdateCompatibleStatTypes(TempHolder);
	if(InsertAtStart!=eStat_Invalid)
	{
		OutTypes.AddItem(InsertAtStart);
	}
	for(i=0;i<TempHolder.Length;i++)
	{
		if(SavedRedFogTypes.Find('StatType',TempHolder[i])!=-1 || RedFogChangeRanges.Find('StatType',TempHolder[i])==-1)
			continue;

		else
			OutTypes.AddItem(TempHolder[i]);
	}
	return OutTypes;	
}

simulated function OpenNewRedFogStatScreen(RedFogFormulatType SCSingle , int Found)
{
	local SecondWave_UIListItem_NCEStatChangesUpdate LocalRedFogScreen;
	local array<ECharStatType> CompatibleStats;

	if(Found==-1)
		return;

	UpdateCompatibleStatTypes(CompatibleStats);
	LocalRedFogScreen=Spawn(class'SecondWave_UIListItem_NCEStatChangesUpdate',self);
	`SCREENSTACK.Push(LocalRedFogScreen);	
	LocalRedFogScreen.InitRFUpdateItem(SCSingle,RedFogChangeRanges,CompatibleStats,GetAvailableRFStatTypes(SCSingle.StatType),UIRFRangesNames,OnSavedClickedRF,OnRemovedClickedRF,OnCancelClickedRF);	
	`log("Setup Saved Settings");	
}
function OnRemovedClickedRF(SecondWave_UIListItem_NCEStatChangesUpdate SCU)
{
	SavedRedFogTypes.RemoveItem(SCU.RFFSingle);
	`SCREENSTACK.Pop(SCU);
	SCU.Remove();
	SetupSettings();
}
function OnSavedClickedRF(SecondWave_UIListItem_NCEStatChangesUpdate SCU)
{
	local int i;
	i=SavedRedFogTypes.find('StatType',SCU.RFFTempSM.StatType);
	if(i!=-1)
		SavedRedFogTypes[i]=SCU.RFFTempSM;

	SCU.RFFSingle=SCU.RFFTempSM;
	`SCREENSTACK.Pop(SCU);
	SCU.Remove();
	SetupSettings();
}

function OnCancelClickedRF(SecondWave_UIListItem_NCEStatChangesUpdate SCU)
{
	`SCREENSTACK.Pop(SCU);
	SCU.Remove();
	SetupSettings();
}
simulated function UpdateRedFogSpinner(UIListItemSpinner SpinnerControl, int Direction)
{
	
	local int i;
	local int currentIndex;
	currentIndex=ApplyToTypes.Find(SpinnerControl.value);

	if(currentIndex== ApplyToTypes.Length-1 && Direction==1 )
		currentIndex=0;
	else if(currentIndex==0 && Direction==-1)
		currentIndex=ApplyToTypes.Length-1;
	else
		currentIndex+=Direction;
	
	switch (currentIndex)
	{
		case 0:
			Main_RedFog_GameState.b_IsRedFogActive=false;
			Main_RedFog_GameState.b_IsRedFogActive_XCom=false;
			Main_RedFog_GameState.b_IsRedFogActive_Advent=false;
			Main_RedFog_GameState.b_IsRedFogActive_Aliens=false;
			break;
		case 1:
			Main_RedFog_GameState.b_IsRedFogActive=true;
			Main_RedFog_GameState.b_IsRedFogActive_XCom=true;
			Main_RedFog_GameState.b_IsRedFogActive_Advent=false;
			Main_RedFog_GameState.b_IsRedFogActive_Aliens=false;
			break;
		case 2:
			Main_RedFog_GameState.b_IsRedFogActive=true;
			Main_RedFog_GameState.b_IsRedFogActive_XCom=false;
			Main_RedFog_GameState.b_IsRedFogActive_Advent=true;
			Main_RedFog_GameState.b_IsRedFogActive_Aliens=false;			
			break;
		case 3:
			Main_RedFog_GameState.b_IsRedFogActive=true;
			Main_RedFog_GameState.b_IsRedFogActive_XCom=true;
			Main_RedFog_GameState.b_IsRedFogActive_Advent=true;
			Main_RedFog_GameState.b_IsRedFogActive_Aliens=false;			
			break;
		case 4:
			Main_RedFog_GameState.b_IsRedFogActive=true;
			Main_RedFog_GameState.b_IsRedFogActive_XCom=false;
			Main_RedFog_GameState.b_IsRedFogActive_Advent=false;
			Main_RedFog_GameState.b_IsRedFogActive_Aliens=true;			
			break;
		case 5:
			Main_RedFog_GameState.b_IsRedFogActive=true;
			Main_RedFog_GameState.b_IsRedFogActive_XCom=true;
			Main_RedFog_GameState.b_IsRedFogActive_Advent=false;
			Main_RedFog_GameState.b_IsRedFogActive_Aliens=true;			
			break;
		case 6:
			Main_RedFog_GameState.b_IsRedFogActive=true;
			Main_RedFog_GameState.b_IsRedFogActive_XCom=false;
			Main_RedFog_GameState.b_IsRedFogActive_Advent=true;
			Main_RedFog_GameState.b_IsRedFogActive_Aliens=true;			
			break;
		case 7:
			Main_RedFog_GameState.b_IsRedFogActive=true;
			Main_RedFog_GameState.b_IsRedFogActive_XCom=true;
			Main_RedFog_GameState.b_IsRedFogActive_Advent=true;
			Main_RedFog_GameState.b_IsRedFogActive_Aliens=true;			
			break;
		
	}
	for(i=1;i<=SavedRedFogTypes.Length+3/*+3*/;i++)
	{
		UIMechaListItem(List.GetItem(RedFogCheckboxPosition+i)).SetDisabled(!Main_RedFog_GameState.b_IsRedFogActive);
	}		
	SpinnerControl.SetValue(ApplyToTypes[currentIndex]);
	SpinnerControl.selectedIndex=currentIndex;
	
}

function OnAddNewRFClicked(UIButton Button)
{
	local array<ECharStatType> TempHolder;
	local ECharStatType NewNCE;
	local RedFogFormulatType FFSingle;
	local int i;

	UpdateCompatibleStatTypes(TempHolder);
	for(i=0;i<TempHolder.Length;i++)
	{
		if(SavedRedFogTypes.Find('StatType',TempHolder[i])!=-1 || RedFogChangeRanges.Find('StatType',TempHolder[i])==-1)
			continue;

		else
		{
			NewNCE=TempHolder[i];
			break;
		}
	}
	i=SavedRedFogTypes.Find('StatType',NewNCE);
	FFSingle.StatType=NewNCE;
	FFSingle.Range=SavedRedFogTypes[i].Range;
	FFSingle.RedFogCalcType=SavedRedFogTypes[i].RedFogCalcType;

	OpenNewRedFogStatScreen(FFSingle,i);
	
}

simulated function UpdateRoboticRF(UICheckbox CheckBox)
{
	Main_RedFog_GameState.b_IsRedFogActive_Robotics=CheckBox.bChecked;
}

simulated function UpdateGaussianRF(UICheckbox CheckBox)
{
	Main_RedFog_GameState.b_UseGaussianEquasion=CheckBox.bChecked;
}


simulated function ShowNewEconomy(bool Activated)
{
	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem());
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataDescription(class'UIUtilities_Text'.static.AlignCenter((class'UIUtilities_Text'.static.StyleText(OptionNames[11],eUITextStyle_Tooltip_Title))));
	CreatedUIMLI[CreatedUIMLI.Length-1].BG.SetAlpha(0);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(true);
	CreatedUIMLI[CreatedUIMLI.Length-1].MC.FunctionVoid("onReceiveFocus");
	CreatedUIMLI[CreatedUIMLI.Length-1].OnReceiveFocus();	
	CreatedUIMLI[CreatedUIMLI.Length-1].MC.FunctionVoid("onLoseFocus");
	CreatedUIMLI[CreatedUIMLI.Length-1].OnLoseFocus();	

	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem());
	//CreatedUIMLI[CreatedUIMLI.Length]=Spawn(Class'UIMechaListItem', List.itemContainer).InitListItem();
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataCheckbox(OptionNames[11],"",Activated,UpdateNewEconomy);
	CreatedUIMLI[CreatedUIMLI.Length-1].Checkbox.SetReadOnly(false);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(false);
	CreatedUIMLI[CreatedUIMLI.Length-1].AnimateIn(0);

	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem());
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataSlider(OptionNames[12],string(int(Main_NewEconomy_GameState.NewEconomyMaxRandomPercentage)),Main_NewEconomy_GameState.NewEconomyMaxRandomPercentage,,UpdateNewEconPerc);	
	CreatedUIMLI[CreatedUIMLI.Length-1].Slider.SetStepSize(1.0);
	CreatedUIMLI[CreatedUIMLI.Length-1].Slider.SetPercent(Main_NewEconomy_GameState.NewEconomyMaxRandomPercentage);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(!Activated);
	CreatedUIMLI[CreatedUIMLI.Length-1].AnimateIn(0);

	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem());
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataSlider(OptionNames[13],string(Main_NewEconomy_GameState.MinimalRegionIncome),Main_NewEconomy_GameState.MinimalRegionIncome,,UpdateNewEconMinIncome);	
	CreatedUIMLI[CreatedUIMLI.Length-1].Slider.SetStepSize(1.0);
	CreatedUIMLI[CreatedUIMLI.Length-1].Slider.SetPercent(float(Main_NewEconomy_GameState.MinimalRegionIncome));
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(!Activated);
	CreatedUIMLI[CreatedUIMLI.Length-1].AnimateIn(0);
}

simulated function UpdateNewEconomy(UICheckbox CheckBox)
{
	Main_NewEconomy_GameState.b_IsNewEconomyActive=CheckBox.bChecked;	
	CreatedUIMLI[CreatedUIMLI.Find(UIMechaListItem(CheckBox.ParentPanel))+1].SetDisabled(!CheckBox.bChecked);
	CreatedUIMLI[CreatedUIMLI.Find(UIMechaListItem(CheckBox.ParentPanel))+2].SetDisabled(!CheckBox.bChecked);
}


simulated function UpdateNewEconPerc(UISlider sliderControl)
{
	sliderControl.SetText(string(int(sliderControl.percent)));
	Main_NewEconomy_GameState.NewEconomyMaxRandomPercentage=(int(sliderControl.percent));
}
simulated function UpdateNewEconMinIncome(UISlider sliderControl)
{
	sliderControl.SetText(string(int(sliderControl.percent)));
	Main_NewEconomy_GameState.MinimalRegionIncome=(int(sliderControl.percent));
}
simulated public function OnChildClicked(UIList ContainerList, int ItemIndex)
{
	`log("Clicked on little list"@ItemIndex);
	return;
}
