// This is an Unreal Script
                           
class SecondWave_UIListItem_NCEStatChangesUpdate extends UIPanel dependson(SecondWave_GameStateParent);

var UIMechaListItem StatNCEDestcription;
var UIMechaListItem StatTypeDropdown;
var UIMechaListItem StatRangeSlider;
var UIMechaListItem StatMinSlider;
var UIMechaListItem StatCostSlider;
var UIMechaListItem FinalButton;
var UIButton		CancelButton;
var UIButton		RemoveButton;

var UIRanges StatRanges;
var array<ECharStatType> CompatibleStatTypes;
var array<string> StatTypesNames;
var array<string> Descriptions;

var string SCString;

var UIList List;

var bool IsOpen;

var NCE_StatModifiers SCSingle;
var NCE_StatModifiers TempSM;

delegate OnRemovedClickedDelegate(SecondWave_UIListItem_NCEStatChangesUpdate SCU);
delegate OnSavedClickedDelegate(SecondWave_UIListItem_NCEStatChangesUpdate SCU);

simulated function SecondWave_UIListItem_NCEStatChangesUpdate InitSCUpdateItem( NCE_StatModifiers SSCSingle, UIRanges InStatRanges, array<ECharStatType> InCompatibleStatTypes,array<string> Descs,delegate<OnSavedClickedDelegate> OnSavedClicked,delegate<OnRemovedClickedDelegate> OnRemovedClicked)
{
	local ECharStatType IndST;
	StatRanges=InStatRanges;
	CompatibleStatTypes=InCompatibleStatTypes;
	foreach InCompatibleStatTypes(IndST)
	{
		StatTypesNames.AddItem(string(IndST));
	}
	
	List=Spawn(Class'UIList',self).InitList('NCEItems',150,0,600);
	List.CreateItemContainer();

	SCSingle=SSCSingle;
	TempSM=SSCSingle;
	SCString="Stat:"$SCSingle.StatType @"Range:"$SCSingle.Stat_Range @"Min Stat:"$SCSingle.Stat_Min @"Cost:"$SCSingle.Stat_Cost;

	StatNCEDestcription=(Spawn(Class'UIMechaListItem',self)).InitListItem();
	StatNCEDestcription.UpdateDataButton(SCString,"Edit",OpenEditList,OpenEditListClicked);
	Descriptions=Descs;
	OnRemovedClickedDelegate=OnRemovedClicked;
	OnSavedClickedDelegate=OnSavedClicked;
	return self;
}

function OpenEditListClicked()
{
 	OpenEditList(StatNCEDestcription.Button);
}
function OpenEditList(UIButton Button)
{
	if(!IsOpen)
	{
		StatNCEDestcription.Button.SetText("Discard");
		StatTypeDropdown=UIMechaListItem(List.CreateItem(class'UIMechaListItem'));
		StatTypeDropdown.InitListItem();
		StatTypeDropdown.UpdateDataDropdown(Descriptions[0],StatTypesNames,0,OnStatTypeDropdownChanged);
		StatTypeDropdown.Dropdown.Items=StatTypesNames;

		StatRangeSlider=UIMechaListItem(List.CreateItem(class'UIMechaListItem'));
		StatRangeSlider.InitListItem();
		StatRangeSlider.UpdateDataSlider(Descriptions[1],string(StatRanges.Range),0,,OnStatRangeChanged);
		StatRangeSlider.Slider.stepSize=StatRanges.RangeSteps/100.00;

		StatMinSlider=UIMechaListItem(List.CreateItem(class'UIMechaListItem'));
		StatMinSlider.InitListItem();
		StatMinSlider.UpdateDataSlider(Descriptions[2],string(StatRanges.Min),0,,OnStatMinChanged);
		StatMinSlider.Slider.stepSize=StatRanges.MinSteps/100.00;

		StatCostSlider=UIMechaListItem(List.CreateItem(class'UIMechaListItem'));
		StatCostSlider.InitListItem();
		StatCostSlider.UpdateDataSlider(Descriptions[3],string(StatRanges.Cost),0,,OnStatCostChanged);
		StatCostSlider.Slider.stepSize=StatRanges.CostSteps/100.00;
	
		FinalButton=UIMechaListItem(List.CreateItem(class'UIMechaListItem'));
		FinalButton.InitListItem();
		FinalButton.UpdateDataButton("","Apply",OnApply);
		FinalButton.Button.AnchorTopRight();
		CancelButton=Spawn(Class'UIButton',FinalButton).InitButton('CancelButton',"Cancel",OnCancel);
		CancelButton.AnchorTopCenter();
		RemoveButton=Spawn(Class'UIButton',FinalButton).InitButton('RemoveButton',"Remove",OnRemoved);
		RemoveButton.AnchorTopLeft();
		//ListContainer.ShrinkToFit();	
	}
	else
	{
		List.ClearItems();
		StatNCEDestcription=UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem();
		SCString="Stat:"$SCSingle.StatType @"Range:"$SCSingle.Stat_Range @"Min Stat:"$SCSingle.Stat_Min @"Cost:"$SCSingle.Stat_Cost;
		StatNCEDestcription.UpdateDataButton(SCString,"Edit",OpenEditList,OpenEditListClicked);
	}
}

function OnStatTypeDropdownChanged(UIDropdown DropdownControl)
{
	TempSM.StatType=CompatibleStatTypes[DropdownControl.SelectedItem];
}
	
function OnStatRangeChanged(UISlider sliderControl)
{
	if((TempSM.Stat_Range-(TempSM.Stat_Range))==0)
		TempSM.Stat_Range=StatRanges.Range+Round(StatRanges.RangeSteps*(sliderControl.percent-50.0));
	else
		TempSM.Stat_Range=StatRanges.Range+(StatRanges.RangeSteps*(sliderControl.percent-50.0));
}
	
function OnStatMinChanged(UISlider sliderControl)
{
	if((TempSM.Stat_Range-(TempSM.Stat_Range))==0)
		TempSM.Stat_Min=StatRanges.Min+Round(StatRanges.MinSteps*(sliderControl.percent-50.0));
	else
		TempSM.Stat_Min=StatRanges.Min+(StatRanges.MinSteps*(sliderControl.percent-50.0));	
}
	
function OnStatCostChanged(UISlider sliderControl)
{
	if((TempSM.Stat_Range-(TempSM.Stat_Range))==0)
		TempSM.Stat_Cost=StatRanges.Cost+Round(StatRanges.CostSteps*(sliderControl.percent-50.0));
	else
		TempSM.Stat_Cost=StatRanges.Cost+(StatRanges.CostSteps*(sliderControl.percent-50.0));		
}
	
function OnApply(UIButton Button)
{
	OnSavedClickedDelegate(self);
}
	
function OnCancel(UIButton Button)
{
	TempSM=SCSingle;	
}
function OnRemoved(UIButton Button)
{
	OnRemovedClickedDelegate(self);	
}