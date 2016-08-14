// This is an Unreal Script
                           
class SecondWave_UIListItem_NCEStatChangesUpdate extends Actor dependson(SecondWave_GameStateParent);


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
var bool IsOpen;

var NCE_StatModifiers SCSingle;
var NCE_StatModifiers TempSM;

delegate OnRemovedClickedDelegate(SecondWave_UIListItem_NCEStatChangesUpdate SCU);
delegate OnSavedClickedDelegate(SecondWave_UIListItem_NCEStatChangesUpdate SCU);
delegate OnListClicked(SecondWave_UIListItem_NCEStatChangesUpdate SCU);

simulated function InitSCUpdateItem(UIList List,NCE_StatModifiers SSCSingle, UIRanges InStatRanges, 
									array<ECharStatType> InCompatibleStatTypes,array<string> Descs,
									delegate<OnSavedClickedDelegate> OnSavedClicked,delegate<OnRemovedClickedDelegate> OnRemovedClicked,
									delegate<OnListClicked> OnButtonClicked)
{
	local ECharStatType IndST;

	StatRanges=InStatRanges;
	CompatibleStatTypes=InCompatibleStatTypes;
	foreach InCompatibleStatTypes(IndST)
	{
		StatTypesNames.AddItem(string(IndST));
	}
	SCSingle=SSCSingle;
	TempSM=SSCSingle;
	SCString="Stat:"$SCSingle.StatType @"Range:"$SCSingle.Stat_Range @"Min Stat:"$SCSingle.Stat_Min @"Cost:"$SCSingle.Stat_Cost;

	StatNCEDestcription=UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem();
	StatNCEDestcription.UpdateDataButton(SCString,"Edit",OpenEditListClickedCallback,OpenEditListCallback);
	Descriptions=Descs;
	OnRemovedClickedDelegate=OnRemovedClicked;
	OnSavedClickedDelegate=OnSavedClicked;
	OnListClicked=OnButtonClicked;
}
function OpenEditListCallback()
{
	OnListClicked(self);
}
function OpenEditListClickedCallback(UIButton Button)
{
	OnListClicked(self);
}


function OpenEditList(UIList List)
{
	if(!IsOpen)
	{
		StatNCEDestcription.Button.SetText("Discard");
		StatTypeDropdown=Spawn(class'UIMechaListItem',List.ItemContainer).InitListItem();
		List.ItemContainer.ChildPanels.InsertItem(List.GetItemIndex(StatNCEDestcription)+1,StatTypeDropdown);
		StatTypeDropdown.UpdateDataDropdown(Descriptions[0],StatTypesNames,0,OnStatTypeDropdownChanged);
		StatTypeDropdown.Dropdown.Items=StatTypesNames;

		StatRangeSlider=Spawn(class'UIMechaListItem',List.ItemContainer).InitListItem();
		List.ItemContainer.ChildPanels.InsertItem(List.GetItemIndex(StatNCEDestcription)+2,StatRangeSlider);
		StatRangeSlider.UpdateDataSlider(Descriptions[1],string(StatRanges.Range),0,,OnStatRangeChanged);
		StatRangeSlider.Slider.stepSize=StatRanges.RangeSteps/100.00;

		StatMinSlider=Spawn(class'UIMechaListItem',List.ItemContainer).InitListItem();
		List.ItemContainer.ChildPanels.InsertItem(List.GetItemIndex(StatNCEDestcription)+3,StatMinSlider);
		StatMinSlider.UpdateDataSlider(Descriptions[2],string(StatRanges.Min),0,,OnStatMinChanged);
		StatMinSlider.Slider.stepSize=StatRanges.MinSteps/100.00;

		StatCostSlider=Spawn(class'UIMechaListItem',List.ItemContainer).InitListItem();
		List.ItemContainer.ChildPanels.InsertItem(List.GetItemIndex(StatNCEDestcription)+4,StatCostSlider);
		StatCostSlider.UpdateDataSlider(Descriptions[3],string(StatRanges.Cost),0,,OnStatCostChanged);
		StatCostSlider.Slider.stepSize=StatRanges.CostSteps/100.00;
	
		FinalButton=Spawn(class'UIMechaListItem',List.ItemContainer).InitListItem();
		List.ItemContainer.ChildPanels.InsertItem(List.GetItemIndex(StatNCEDestcription)+5,FinalButton);
		FinalButton.UpdateDataButton("","Apply",OnItemApply);
		FinalButton.Button.AnchorTopRight();
		CancelButton=Spawn(Class'UIButton',FinalButton).InitButton('CancelButton',"Cancel",OnItemCancel);
		CancelButton.AnchorTopCenter();
		RemoveButton=Spawn(Class'UIButton',FinalButton).InitButton('RemoveButton',"Remove",OnItemRemoved);
		RemoveButton.AnchorTopLeft();
		//ListContainer.ShrinkToFit();	
	}
	else
	{
		RemoveEverything(List);
		StatNCEDestcription=UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem();
		SCString="Stat:"$SCSingle.StatType @"Range:"$SCSingle.Stat_Range @"Min Stat:"$SCSingle.Stat_Min @"Cost:"$SCSingle.Stat_Cost;
		StatNCEDestcription.UpdateDataButton(SCString,"Edit",OpenEditListClickedCallback,OpenEditListCallback);
	}
}

function RemoveEverything(UIList List)
{
	List.ItemContainer.RemoveChild(StatNCEDestcription);
	List.ItemContainer.RemoveChild(StatTypeDropdown);
	List.ItemContainer.RemoveChild(StatRangeSlider);
	List.ItemContainer.RemoveChild(StatMinSlider);
	List.ItemContainer.RemoveChild(StatCostSlider);
	List.ItemContainer.RemoveChild(FinalButton);

	StatNCEDestcription.Removed();
	StatTypeDropdown.Removed();
	StatRangeSlider.Removed();
	StatMinSlider.Removed();
	StatCostSlider.Removed();
	CancelButton.Removed();
	FinalButton.Removed();

	StatTypeDropdown.Hide();
	StatNCEDestcription.Hide();
	StatTypeDropdown.Hide();
	StatRangeSlider.Hide();
	StatMinSlider.Hide();
	StatCostSlider.Hide();
	CancelButton.Hide();
	FinalButton.Hide();
	StatTypeDropdown.Hide();
	
	List.RealizeList();
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
}
function OnItemRemoved(UIButton Button)
{
	OnRemovedClickedDelegate(self);	
}