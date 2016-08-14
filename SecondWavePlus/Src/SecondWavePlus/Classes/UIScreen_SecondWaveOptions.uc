// This is an Unreal Script
                           
class UIScreen_SecondWaveOptions extends UISimpleScreen dependson(SecondWave_GameStateParent) Config(SecondWavePlus_Settings);

var int m_iCurrentSelection;

var UIBGBox BGB;
var UIX2PanelHeader Header;
var UIList List;

var array<UIMechaListItem> ClickedItems;

var config array<NCE_StatModifiers> SavedNCEItems;
var config array<NCE_StatModifiers> SavedEpigeneticsItems;

var localized array<string> OptionNames;
var localized array<string> UIRangesNames;
var localized string		SWPOptionsHeader;

var config array<UIRanges> StatChangesRanges;

var array<UIMechaListItem> CreatedUIMLI;
var UIListItemString MyStringItem;

var array<SecondWave_UIListItem_NCEStatChangesUpdate> NCEItems;
var array<SecondWave_UIListItem_NCEStatChangesUpdate> EpigeneticsItems;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);
	CreateScreen();
}

simulated function CreateScreen()
{
	local TRect rBG,rList,rHeader;
	
	rBG=self.MakeRect(0,0,1920,1080);
	rList=self.MakeRect(90,53,1808,1017);
	rHeader=self.MakeRect(2,2,1916,50);
	BGB=self.AddBG(rBG,eUIState_Normal);
	Header=AddHeader(rHeader,SWPOptionsHeader,MakeLinearColor(0, 1, 1, 0.85));
	Header.OriginTopCenter();
	Header.AnchorTopCenter();
	List=AddList(rList," ",OnChildClicked);
	List.ItemPadding=0;
	SetupSettings();
}

simulated public function SetupSettings()
{
	List.ClearItems();
	CreatedUIMLI.Length=0;
	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem());
	//CreatedUIMLI[CreatedUIMLI.Length]=Spawn(Class'UIMechaListItem', List.itemContainer).InitListItem();
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataCheckbox(OptionNames[0],"",true,UpdateNCE);
	CreatedUIMLI[CreatedUIMLI.Length-1].Checkbox.SetReadOnly(false);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(false);
	CreatedUIMLI[CreatedUIMLI.Length-1].AnimateIn(0);
	if(CreatedUIMLI[CreatedUIMLI.Length-1].Checkbox.bChecked)
		UpdateNCE(CreatedUIMLI[CreatedUIMLI.Length-1].Checkbox);
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

simulated function UpdateNCE(UICheckbox CheckBox)
{
	local NCE_StatModifiers SCSingle;
	local array<ECharStatType> CompatibleStats;
	local int Found;	
	local array<UIPanel> SCUArray;

	UpdateCompatibleStatTypes(CompatibleStats);
	if(!CheckBox.bChecked)
	{
		self.GetChildrenOfType(Class'SecondWave_UIListItem_NCEStatChangesUpdate',SCUArray);
		for(found=0;found<SCUArray.Length;found++)
		{
			CheckBox.RemoveChild(SCUArray[found]);
			SCUArray[found].Removed();
		}
		SCUArray.Length=0;
		//List.ClearItems();
		//SetupSettings();
		//List.RealizeList();		
	}
	`log("SavedNCEItems Length"@SavedNCEItems.Length);	
	foreach SavedNCEItems(SCSingle)
	{
		Found=StatChangesRanges.Find('StatType',SCSingle.StatType);
		if(Found==-1)
			continue;
		
		NCEItems.AddItem(Spawn(class'SecondWave_UIListItem_NCEStatChangesUpdate',self));
		NCEItems[NCEItems.Length-1].InitSCUpdateItem(List,SCSingle,StatChangesRanges[Found],CompatibleStats,UIRangesNames,OnRemovedClickedNCE,OnSavedClickedNCE,OnOpenListItems);	
		`log("Setup Saved Settings");
	}
	//CheckBox.SetChecked(saveSettings);
}

simulated function OnOpenListItems(SecondWave_UIListItem_NCEStatChangesUpdate SCU)
{
	SCU.OpenEditList(List);
}
function OnRemovedClickedNCE(SecondWave_UIListItem_NCEStatChangesUpdate SCU)
{
	SavedNCEItems.RemoveItem(SCU.SCSingle);
	SetupSettings();
}
function OnSavedClickedNCE(SecondWave_UIListItem_NCEStatChangesUpdate SCU)
{
	local int i;
	i=SavedNCEItems.find('StatType',SCU.SCSingle.StatType);
	if(i!=-1)
		SavedNCEItems[i]=SCU.TempSM;

	SCU.SCSingle=SCU.TempSM;
}
simulated function UpdateNCE_Robotics(UICheckbox CheckBox)
{
	
}
simulated function UpdateExpensiveTalent(UICheckbox CheckBox)
{
	
}
simulated function UpdateHiddenPotential(UICheckbox CheckBox)
{
	
}
simulated function UpdateAbsolutlyCritical(UIListItemSpinner SpinnerControl, int Direction)
{
	
}
simulated function UpdateEpigenetics(UICheckbox CheckBox)
{
	
}
simulated function UpdateEpigeneticsRobotics(UICheckbox CheckBox)
{
	
}
simulated function UpdateRedFog(UIListItemSpinner SpinnerControl, int Direction)
{
	
}
simulated function UpdateNewEconomy(UICheckbox CheckBox)
{
	
}

simulated public function OnChildClicked(UIList ContainerList, int ItemIndex)
{
	if(UIMechaListItem(List.GetItem(itemIndex))!=none)
		UpdateNCE(UIMechaListItem(List.GetItem(itemIndex)).Checkbox);
}

simulated function SetSelected(UIList ContainerList, int ItemIndex)
{
	m_iCurrentSelection = ItemIndex;
}

