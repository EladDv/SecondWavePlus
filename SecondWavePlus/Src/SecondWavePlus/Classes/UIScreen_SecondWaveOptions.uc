// This is an Unreal Script
                           
class UIScreen_SecondWaveOptions extends UIScreen dependson(SecondWave_GameStateParent) Config(SecondWavePlus_Settings);

var int m_iCurrentSelection;

var UIBGBox BGB;

var UIList List;
var array<UIMechaListItem> ClickedItems;

var config array<NCE_StatModifiers> SavedNCEItems;
var config array<NCE_StatModifiers> SavedEpigeneticsItems;

var localized array<string> OptionNames;
var localized array<string> UIRangesNames;

var config array<UIRanges> StatChangesRanges;

var array<UIMechaListItem> CreatedUIMLI;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);
	CreateScreen();
}

simulated function CreateScreen()
{
	BGB=Spawn(class'UIBGBox',self).InitBG('BackgroundBGBox',,,1440,900,eUIState_Normal);
	BGB.OriginCenter();
	BGB.AnchorCenter();

	List = Spawn(class'UIList', self);
	List.InitList('ItemList', , , 750, 300);
	List.OnItemClicked = OnChildClicked;
	List.CreateItemContainer();
	List.OnSelectionChanged = SetSelected; 
	List.OnItemDoubleClicked = OnChildClicked;

	//List.OriginCenter();
	//List.AnchorCenter();	

	//SavedNCEItems=GetExistingNCESM();
	//SavedEpigeneticsItems=GetExistingNCESM(true);
	List.RealizeList();	
	`log("Setup Create Screen");
}

simulated public function SetupSettings()
{

	CreatedUIMLI.AddItem(UIMechaListItem(List.CreateItem(class'UIMechaListItem')));
	//CreatedUIMLI.AddItem(Spawn(Class'UIMechaListItem',Screen));
	CreatedUIMLI[CreatedUIMLI.Length-1].InitListItem();
	CreatedUIMLI[CreatedUIMLI.Length-1].SetPosition(300, 100);
	CreatedUIMLI[CreatedUIMLI.Length-1].UpdateDataCheckbox("Stat"@OptionNames[0],"",true,UpdateNCE);
	CreatedUIMLI[CreatedUIMLI.Length-1].Checkbox.SetReadOnly(false);
	CreatedUIMLI[CreatedUIMLI.Length-1].SetDisabled(false);
	CreatedUIMLI[CreatedUIMLI.Length-1].AnimateIn(0);
	if(CreatedUIMLI[CreatedUIMLI.Length-1].Checkbox.bChecked)
		UpdateNCE(CreatedUIMLI[CreatedUIMLI.Length-1].Checkbox);
	List.RealizeList();	
	List.RealizeItems(0);
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
	local SecondWave_UIListItem_NCEStatChangesUpdate StatChangesDescription;
	local NCE_StatModifiers SCSingle;
	local array<ECharStatType> CompatibleStats;
	local int Found;	

	UpdateCompatibleStatTypes(CompatibleStats);
	if(!CheckBox.bChecked)
	{
		List.ClearItems();
		SetupSettings();
		List.RealizeList();		
	}
	foreach SavedNCEItems(SCSingle)
	{
		Found=StatChangesRanges.Find('StatType',SCSingle.StatType);
		if(Found==-1)
			continue;
		
		StatChangesDescription=SecondWave_UIListItem_NCEStatChangesUpdate(List.CreateItem(class'SecondWave_UIListItem_NCEStatChangesUpdate'));
		StatChangesDescription.InitSCUpdateItem(SCSingle,StatChangesRanges[Found],CompatibleStats,UIRangesNames,OnRemovedClickedNCE,OnSavedClickedNCE);	
		`log("Setup Saved Settings");
	}
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

simulated public function OnChildClicked(UIList ContainerList, int ItemIndex){}

simulated function SetSelected(UIList ContainerList, int ItemIndex)
{
	m_iCurrentSelection = ItemIndex;
}

function OnRemovedClickedNCE(SecondWave_UIListItem_NCEStatChangesUpdate SCU)
{
	SavedNCEItems.RemoveItem(SCU.SCSingle);
}
function OnSavedClickedNCE(SecondWave_UIListItem_NCEStatChangesUpdate SCU)
{
	local int i;
	i=SavedNCEItems.find('StatType',SCU.SCSingle.StatType);
	if(i!=-1)
		SavedNCEItems[i]=SCU.TempSM;
}