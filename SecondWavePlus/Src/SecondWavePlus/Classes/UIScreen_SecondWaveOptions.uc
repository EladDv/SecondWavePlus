// This is an Unreal Script
                           
class UIScreen_SecondWaveOptions extends UISimpleScreen dependson(SecondWave_GameStateParent) Config(SecondWavePlus_Settings);

var int m_iCurrentSelection;

var UIBGBox BGB;
var UIX2PanelHeader Header;
var UIList List;

var array<UIMechaListItem> ClickedItems;

var config array<NCE_StatModifiers> SavedNCEItems;
var config array<NCE_StatModifiers> SavedEpigeneticsItems;

var int NCECheckboxPosition;
var int EpigeneticsCheckboxPosition;

var config int TotalPoints_Enemy;
var config int Tolerance_Enemy;
var config int TotalPoints_XCom;
var config int Tolerance_XCom;

var localized array<string> ApplyToTypes;
var localized array<string> OptionNames;
var localized array<string> UIRangesNames;
var localized string		SWPOptionsHeader;

var config array<UIRanges> StatChangesRanges;

var array<UIMechaListItem> CreatedUIMLI;
var UIListItemString MyStringItem;

var array<SecondWave_UIListItem_NCEStatChangesUpdate> NCEItems;
var array<SecondWave_UIListItem_NCEStatChangesUpdate> EpigeneticsItems;

var bool NCEWasCheckedBefore;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);
	CreateScreen();
}

simulated function CreateScreen()
{
	local TRect rBG,rList,rHeader;
	
	rBG=self.MakeRect(80,0,1760,990);
	rList=self.MakeRect(135,53,1808-160,1017-90);
	rHeader=self.MakeRect(90,60,1760,50);
	BGB=self.AddBG(rBG,eUIState_Normal);
	Header=AddHeader(rHeader,SWPOptionsHeader,MakeLinearColor(0, 1, 1, 0.85));
	Header.AnchorTopLeft();
	List=AddList(rList," ",OnChildClicked);
	List.ItemPadding=0;
	SetupSettings(false,true);
}

simulated public function SetupSettings(optional bool NCEChecked=false,optional bool RunOnce=false)
{
	List.ClearItems();
	CreatedUIMLI.Length=0;
	
	ShowNCE(false);
	ShowNCE_Robotics(false);
	ShowExpensiveTalent(false);
	ShowAbsolutlyCritical(false);
	ShowCommandersChoice(false);
	ShowEpigenetics(false);
	ShowEpigeneticsRobotics(false);
	ShowHiddenPotential(false);
	ShowRedFog(false);
	ShowNewEconomy(false);

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
	CompatibleStats.AddItem(eStat_ArmorPiercing);
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

function array<NCE_StatModifiers> GetExistingNCESM(optional bool ReturnEpigenetics=false)
{
	local SecondWave_NotCreatedEqually_GameState	NCEGS;	
	local SecondWave_Epigenetics_GameState			EPGGS;	
	local XComGameState								NewGS;
	local XComGameState_CampaignSettings			CampSettings;
	local SecondWave_CampaignSettings				SWCampSettigns;
	local array<NCE_StatModifiers>					EmptyArray;

	EmptyArray.length=0;

	CampSettings=XComGameState_CampaignSettings(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings'));
	SWCampSettigns=SecondWave_CampaignSettings(CampSettings.FindComponentObject(class'SecondWave_CampaignSettings'));
	if(SWCampSettigns!=none)
	{
		if(ReturnEpigenetics)
			return SWCampSettigns.EpigeneticsStatModifiers;
		else
			return SWCampSettigns.NCEStatModifiers;
	}
	
	NCEGS=SecondWave_NotCreatedEqually_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_NotCreatedEqually_GameState'));
	EPGGS=SecondWave_Epigenetics_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_Epigenetics_GameState'));
	if(NCEGS!=none && !ReturnEpigenetics)
		return NCEGS.NCEStatModifiers;
	else if(EPGGS!=none && ReturnEpigenetics)
		return EPGGS.EpigeneticsStatModifiers;

	
	if(!ReturnEpigenetics)
	{
		NewGS=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Loading Data NCE");
		EPGGS=SecondWave_Epigenetics_GameState(NewGS.CreateStateObject(class'SecondWave_Epigenetics_GameState'));
		`XCOMHistory.CleanupPendingGameState(NewGS);	
		return EPGGS.EpigeneticsStatModifiers;
	}
	else
	{
		NewGS=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Loading Data NCE");
		NCEGS=SecondWave_NotCreatedEqually_GameState(NewGS.CreateStateObject(class'SecondWave_NotCreatedEqually_GameState'));
		`XCOMHistory.CleanupPendingGameState(NewGS);	
		return NCEGS.NCEStatModifiers;
	}
	return EmptyArray;
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
	
}


simulated function UpdateNCE(UICheckbox CheckBox)
{
	local int i;
	for(i=1;i<=SavedNCEItems.Length/*+3*/;i++)
	{
		UIMechaListItem(List.GetItem(NCECheckboxPosition+i)).SetDisabled(!CheckBox.bChecked);
	}	
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
	OpenNewNCEStatScreen(SavedNCEItems[(NCECheckboxPosition-buttonIndex)-1],((NCECheckboxPosition-buttonIndex)-1));

}

simulated function OpenNewNCEStatScreen(NCE_StatModifiers SCSingle , int Found)
{
	local SecondWave_UIListItem_NCEStatChangesUpdate LocalNCEScreen;
	local array<ECharStatType> CompatibleStats;

	if(Found==-1)
		return;

	UpdateCompatibleStatTypes(CompatibleStats);
	LocalNCEScreen=Spawn(class'SecondWave_UIListItem_NCEStatChangesUpdate',self);
	`SCREENSTACK.Push(LocalNCEScreen);	
	LocalNCEScreen.InitSCUpdateItem(SCSingle,StatChangesRanges,CompatibleStats,UIRangesNames,OnSavedClickedNCE,OnRemovedClickedNCE,OnCancelClickedNCE);	
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
	
}

simulated function ShowExpensiveTalent(bool Activated)
{
	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem());
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataCheckbox(OptionNames[2],"",Activated,UpdateExpensiveTalent);	
}

simulated function UpdateExpensiveTalent(UICheckbox CheckBox)
{
	
}

simulated function ShowAbsolutlyCritical(bool Activated)
{
	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem());
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataDescription(class'UIUtilities_Text'.static.AlignCenter((class'UIUtilities_Text'.static.StyleText(OptionNames[3],eUITextStyle_Tooltip_Title))));
	CreatedUIMLI[CreatedUIMLI.Length-1].BG.SetAlpha(0);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(true);
	CreatedUIMLI[CreatedUIMLI.Length-1].MC.FunctionVoid("onReceiveFocus");
	CreatedUIMLI[CreatedUIMLI.Length-1].OnReceiveFocus();	
	CreatedUIMLI[CreatedUIMLI.Length-1].MC.FunctionVoid("onLoseFocus");
	CreatedUIMLI[CreatedUIMLI.Length-1].OnLoseFocus();	

	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem());
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataSpinner(OptionNames[3],ApplyToTypes[0],UpdateAbsolutlyCritical);		
	CreatedUIMLI[CreatedUIMLI.Length-1].Spinner.selectedIndex=0;
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
	
}
simulated function UpdateEpigenetics(UICheckbox CheckBox)
{
	local int i;
	for(i=1;i<=SavedEpigeneticsItems.Length/*+3*/;i++)
	{
		UIMechaListItem(List.GetItem(EpigeneticsCheckboxPosition+i)).SetDisabled(!CheckBox.bChecked);
	}		
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

simulated function OnEpigeneticsClicked(UIButton Button)
{
	local int buttonIndex;
	buttonIndex=List.GetItemIndex(UIMechaListItem(Button.ParentPanel));
	if(buttonIndex==-1)
	{
		`log("Error! got a non existent Epigenetics button");
		return;
	}
	OpenNewEpigeneticsStatScreen(SavedEpigeneticsItems[(EpigeneticsCheckboxPosition-buttonIndex)-1],((EpigeneticsCheckboxPosition-buttonIndex)-1));
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
	LocalNCEScreen.InitSCUpdateItem(SCSingle,StatChangesRanges,CompatibleStats,UIRangesNames,OnSavedClickedEpi,OnRemovedClickedEpi,OnCancelClickedEpi);	
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
	
}
simulated function UpdateHiddenPotential(UICheckbox CheckBox)
{
	
}

simulated function ShowRedFog(bool Activated)
{
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
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataCheckbox(OptionNames[8],"",Activated,UpdateHiddenPotential);
	CreatedUIMLI[CreatedUIMLI.Length-1].Checkbox.SetReadOnly(false);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(false);
	CreatedUIMLI[CreatedUIMLI.Length-1].AnimateIn(0);
}

simulated function UpdateRedFog(UIListItemSpinner SpinnerControl, int Direction)
{
	
}

simulated function ShowNewEconomy(bool Activated)
{
	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(Class'UIMechaListItem')).InitListItem());
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataDescription(class'UIUtilities_Text'.static.AlignCenter((class'UIUtilities_Text'.static.StyleText(OptionNames[9],eUITextStyle_Tooltip_Title))));
	CreatedUIMLI[CreatedUIMLI.Length-1].BG.SetAlpha(0);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(true);
	CreatedUIMLI[CreatedUIMLI.Length-1].MC.FunctionVoid("onReceiveFocus");
	CreatedUIMLI[CreatedUIMLI.Length-1].OnReceiveFocus();	
	CreatedUIMLI[CreatedUIMLI.Length-1].MC.FunctionVoid("onLoseFocus");
	CreatedUIMLI[CreatedUIMLI.Length-1].OnLoseFocus();	

	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem());
	//CreatedUIMLI[CreatedUIMLI.Length]=Spawn(Class'UIMechaListItem', List.itemContainer).InitListItem();
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataCheckbox(OptionNames[9],"",Activated,UpdateHiddenPotential);
	CreatedUIMLI[CreatedUIMLI.Length-1].Checkbox.SetReadOnly(false);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(false);
	CreatedUIMLI[CreatedUIMLI.Length-1].AnimateIn(0);
}

simulated function UpdateNewEconomy(UICheckbox CheckBox)
{
	
}

simulated function SetSelected(UIList ContainerList, int ItemIndex)
{
	m_iCurrentSelection = ItemIndex;
}
simulated public function OnChildClicked(UIList ContainerList, int ItemIndex)
{
	`log("Clicked on little list"@ItemIndex);
	return;
}
