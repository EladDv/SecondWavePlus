// This is an Unreal Script
                           
class SecondWave_UIListItem_NCEStatChangesUpdate extends UISimpleScreen dependson(SecondWave_GameStateParent);

var UIBGBox BGB;

var UIMechaListItem StatNCEDestcription;
var UIMechaListItem StatTypeDropdown;
var UIMechaListItem StatRangeSlider;
var UIMechaListItem StatMinSlider;
var UIMechaListItem StatCostSlider;
var UIMechaListItem FinalButton;
var UIButton		CancelButton;
var UIButton		ApplyButton;

var UIList MyList;

var array<UIRanges> StatRanges;
var UIRanges UsedStatRanges;
var array<ECharStatType> CompatibleStatTypes;
var array<string> Descriptions;

var string SCString;
var bool IsOpen;

var NCE_StatModifiers SCSingle;
var NCE_StatModifiers TempSM;

delegate OnRemovedClickedDelegate(SecondWave_UIListItem_NCEStatChangesUpdate SCU);
delegate OnSavedClickedDelegate(SecondWave_UIListItem_NCEStatChangesUpdate SCU);
delegate OnCancelClickedDelegate(SecondWave_UIListItem_NCEStatChangesUpdate SCU);

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);
	CreateScreen();
	self.OriginCenter();
	self.AnchorCenter();
	StatNCEDestcription=UIMechaListItem(MyList.CreateItem(class'UIMechaListItem')).InitListItem();
}

simulated function InitSCUpdateItem(NCE_StatModifiers SSCSingle, array<UIRanges> InStatRanges, 
									array<ECharStatType> InCompatibleStatTypes,array<string> Descs,
									delegate<OnSavedClickedDelegate> OnSavedClicked,delegate<OnRemovedClickedDelegate> OnRemovedClicked,
									delegate<OnCancelClickedDelegate> OnCancClicked)
{
	`log("Called InitSCUpdateItem");
	StatRanges=InStatRanges;
	UsedStatRanges=StatRanges[StatRanges.Find('StatType',SSCSingle.StatType)];
	CompatibleStatTypes=InCompatibleStatTypes;

	SCSingle=SSCSingle;
	TempSM=SSCSingle;
	SCString="Stat:"$SCSingle.StatType @", Range:"$SCSingle.Stat_Range @", Min Stat:"$SCSingle.Stat_Min @", Cost:"$SCSingle.Stat_Cost;
	//CreateScreen();
	StatNCEDestcription.UpdateDataDescription(SCString);
	Descriptions=Descs;
	OnRemovedClickedDelegate=OnRemovedClicked;
	OnSavedClickedDelegate=OnSavedClicked;
	OnCancelClickedDelegate=OnCancClicked;
	OpenEditList(MyList);

}

simulated function CreateScreen()
{
	local TRect rBG,rList;
	
	rBG=self.MakeRect(80,0,1760,990);
	rList=self.MakeRect(170,53,1808-160,1017-90);
	BGB=self.AddBG(rBG,eUIState_Normal);
	MyList=AddList(rList," ",OnChildClicked);
	MyList.ItemPadding=0;
}


simulated function OnRemoved()
{
	RemoveEverything(MyList);
	Super.OnRemoved();	
}

function OpenEditList(UIList List, optional bool InitFromScratch=false)
{
	if(InitFromScratch)
	{
		StatNCEDestcription=UIMechaListItem(MyList.CreateItem(class'UIMechaListItem')).InitListItem();
		SCString="Stat:"$SCSingle.StatType @", Range:"$SCSingle.Stat_Range @", Min Stat:"$SCSingle.Stat_Min @", Cost:"$SCSingle.Stat_Cost;
		StatNCEDestcription.UpdateDataDescription(SCString);
	}

	StatTypeDropdown=UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem();
	StatTypeDropdown.UpdateDataSpinner(Descriptions[0],string(SCSingle.StatType),OnStatTypeSpinnerChanged);


	StatRangeSlider=UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem();
	StatRangeSlider.UpdateDataSlider(Descriptions[1],string(UsedStatRanges.Range),0.5,,OnStatRangeChanged);
	StatRangeSlider.Slider.SetStepSize(float(UsedStatRanges.RangeSteps)/100.00f);

	StatMinSlider=UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem();
	StatMinSlider.UpdateDataSlider(Descriptions[2],string(UsedStatRanges.Min),0.5,,OnStatMinChanged);
	StatMinSlider.Slider.SetStepSize(float(UsedStatRanges.MinSteps)/100.00f);

	StatCostSlider=UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem();
	StatCostSlider.UpdateDataSlider(Descriptions[3],string(UsedStatRanges.Cost),0.5,,OnStatCostChanged);
	StatCostSlider.Slider.SetStepSize(float(UsedStatRanges.CostSteps)/100.00f);

	FinalButton=UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem();
	FinalButton.UpdateDataButton("","Remove",OnItemRemoved);
	
	CancelButton=Spawn(Class'UIButton',FinalButton);
	CancelButton.InitButton(, "Cancel", OnItemCancel);
	CancelButton.SetHeight( 35 );
	CancelButton.SetX((CancelButton.Width)/2);

	ApplyButton=Spawn(Class'UIButton',FinalButton);
	ApplyButton.InitButton(, "Apply",OnItemApply);
	ApplyButton.SetHeight( 35 );
	ApplyButton.SetX((FinalButton.Width-ApplyButton.Width)/2);


	List.RealizeList();
	List.RealizeItems(0);
	List.RealizeMaskAndScrollbar();
}

function RemoveEverything(UIList List)
{
	List.ClearItems();

	StatNCEDestcription.Remove();
	StatTypeDropdown.Remove();
	StatRangeSlider.Remove();
	StatMinSlider.Remove();
	StatCostSlider.Remove();
	CancelButton.Remove();
	FinalButton.Remove();
	
	List.RealizeList();
	List.RealizeItems(0);
	List.RealizeMaskAndScrollbar();
}

function OnStatTypeSpinnerChanged(UIListItemSpinner SpinnerControl, int Direction)
{
	local int Found;

	Found=CompatibleStatTypes.Find(SCSingle.StatType);
	if(Found>0||Direction==1)
		Found+=Direction;
	else if(Found==0 && Direction==-1)
		Found=CompatibleStatTypes.Length-1;

	TempSM.StatType=CompatibleStatTypes[Found];
	SpinnerControl.SetValue(String(CompatibleStatTypes[Found]));
	SpinnerControl.selectedIndex=Found;
	UsedStatRanges=StatRanges[StatRanges.Find('StatType',TempSM.StatType)];	
	RemoveEverything(MyList);
	OpenEditList(MyList,true);
}
	
function OnStatRangeChanged(UISlider sliderControl)
{
	TempSM.Stat_Range=UsedStatRanges.Range+Round(2*UsedStatRanges.RangeSteps*(sliderControl.percent-50.0)/100);
	sliderControl.SetText(string(TempSM.Stat_Range));
}
	
function OnStatMinChanged(UISlider sliderControl)
{
	TempSM.Stat_Min=UsedStatRanges.Min+Round(2*UsedStatRanges.MinSteps*(sliderControl.percent-50.0)/100);
	sliderControl.SetText(string(TempSM.Stat_Min));
}
	
function OnStatCostChanged(UISlider sliderControl)
{
	TempSM.Stat_Cost=UsedStatRanges.Cost+Round(2*UsedStatRanges.CostSteps*(sliderControl.percent-50.0)/100);
	sliderControl.SetText(string(TempSM.Stat_Cost));
}

simulated public function OnChildClicked(UIList ContainerList, int ItemIndex)
{
	`log("Clicked on little list"@ItemIndex);
	return;
}
	
function OnItemApply(UIButton Button)
{
	OnSavedClickedDelegate(self);
}
	
function OnItemCancel(UIButton Button)
{
	TempSM=SCSingle;	
	OnCancelClickedDelegate(self);
}
function OnItemRemoved(UIButton Button)
{
	OnRemovedClickedDelegate(self);	
}