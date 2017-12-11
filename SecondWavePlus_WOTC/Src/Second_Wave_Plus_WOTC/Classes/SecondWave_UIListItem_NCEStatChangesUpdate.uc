// This is an Unreal Script
                           
class SecondWave_UIListItem_NCEStatChangesUpdate extends UISimpleScreen dependson(SecondWave_GameStateParent);

var UIBGBox BGB;

var UIMechaListItem StatNCEDestcription;
var UIMechaListItem StatTypeDropdown;
var UIMechaListItem StatRangeSlider;
var UIMechaListItem StatMinSlider;
var UIMechaListItem StatCostSlider;
var UIMechaListItem RFTypeSpinner;
var UIMechaListItem FinalButton;
var UIButton		CancelButton;
var UIButton		ApplyButton;

var UIList MyList;

var array<UIRanges> StatRanges;
var UIRanges UsedStatRanges;
var array<ECharStatType> CompatibleStatTypes;
var array<ECharStatType> AvaliableStatTypes;
var array<String> AvaliableStatTypesStrings;
var array<string> Descriptions;

var string SCString;
var bool IsOpen;


var NCE_StatModifiers SCSingle;
var NCE_StatModifiers TempSM;

var bool DoingRF;

var RedFogFormulatType RFFSingle;
var RedFogFormulatType RFFTempSM;
	
var array<string> RFTypeNames;

	

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
									array<ECharStatType> InCompatibleStatTypes,array<ECharStatType> InAvaliableStatTypes,array<string> Descs,
									delegate<OnSavedClickedDelegate> OnSavedClicked,delegate<OnRemovedClickedDelegate> OnRemovedClicked,
									delegate<OnCancelClickedDelegate> OnCancClicked)
{
	local ECharStatType NewNCE;

	`log("Called InitSCUpdateItem");
	StatRanges=InStatRanges;
	DoingRF=false;
	UsedStatRanges=StatRanges[StatRanges.Find('StatType',SSCSingle.StatType)];
	CompatibleStatTypes=InCompatibleStatTypes;
	AvaliableStatTypes=InAvaliableStatTypes;
	foreach AvaliableStatTypes(NewNCE)
	{
		AvaliableStatTypesStrings.AddItem(string(NewNCE));
	}
	SCSingle=SSCSingle;
	TempSM=SSCSingle;
	SCString="Stat:"$SCSingle.StatType @", Range:"$SCSingle.Stat_Range @", Min Stat change:"$SCSingle.Stat_Min @", Cost:"$SCSingle.Stat_Cost;
	//CreateScreen();
	StatNCEDestcription.UpdateDataDescription(SCString);
	Descriptions=Descs;
	OnRemovedClickedDelegate=OnRemovedClicked;
	OnSavedClickedDelegate=OnSavedClicked;
	OnCancelClickedDelegate=OnCancClicked;
	OpenEditList(MyList);

}

simulated function InitRFUpdateItem(RedFogFormulatType RFFSSingle, array<UIRanges> InStatRanges, 
									array<ECharStatType> InCompatibleStatTypes,array<ECharStatType> InAvaliableStatTypes,array<string> Descs,
									delegate<OnSavedClickedDelegate> OnSavedClicked,delegate<OnRemovedClickedDelegate> OnRemovedClicked,
									delegate<OnCancelClickedDelegate> OnCancClicked)
{
	local ECharStatType NewNCE;


	`log("Called InitRFUpdateItem");
	DoingRF=true;
	StatRanges=InStatRanges;
	UsedStatRanges=StatRanges[StatRanges.Find('StatType',RFFSingle.StatType)];
	CompatibleStatTypes=InCompatibleStatTypes;
	AvaliableStatTypes=InAvaliableStatTypes;
	foreach AvaliableStatTypes(NewNCE)
	{
		AvaliableStatTypesStrings.AddItem(string(NewNCE));
	}
	RFFSingle=RFFSSingle;
	RFFTempSM=RFFSingle;
	RFTypeNames.AddItem("Aim-Like");
	RFTypeNames.AddItem("Mobility-Like");
	RFTypeNames.AddItem("Will-Like");
	SCString="Stat:"$RFFSingle.StatType @", Range:"$RFFSingle.Range @", Calculation Type:"@RFTypeNames[RFFSingle.RedFogCalcType];
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
		if(DoingRF)
			SCString="Stat:"$SCSingle.StatType @", Range:"$SCSingle.Stat_Range @", Min Stat:"$SCSingle.Stat_Min @", Cost:"$SCSingle.Stat_Cost;
		else
			SCString="Stat:"$RFFSingle.StatType @", Range:"$RFFSingle.Range @", Calculation Type:"@RFTypeNames[RFFSingle.RedFogCalcType];
		StatNCEDestcription.UpdateDataDescription(SCString);
	}

	FinalButton = Spawn( class'UIMechaListItem', List.itemContainer );
	FinalButton.bAnimateOnInit = false;
	FinalButton.InitListItem();
	FinalButton.SetY((DoingRF?4:5)*class'UIMechaListItem'.default.Height);
	//FinalButton=UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem();
	FinalButton.UpdateDataButton("","Remove",OnItemRemoved);
	
	CancelButton=Spawn(Class'UIButton',FinalButton);
	CancelButton.InitButton(, "Cancel", OnItemCancel);
	CancelButton.SetHeight( 35 );
	CancelButton.SetX((CancelButton.Width)/2);

	ApplyButton=Spawn(Class'UIButton',FinalButton);
	ApplyButton.InitButton(, "Apply",OnItemApply);
	ApplyButton.SetHeight( 35 );
	ApplyButton.SetX((FinalButton.Width-ApplyButton.Width)/2);

	if(!DoingRF)
	{
		StatCostSlider = Spawn( class'UIMechaListItem', List.itemContainer );
		StatCostSlider.bAnimateOnInit = false;
		StatCostSlider.InitListItem();
		StatCostSlider.SetY(4*class'UIMechaListItem'.default.Height);
		//StatCostSlider=UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem();
		StatCostSlider.UpdateDataSlider(Descriptions[3],string(TempSM.Stat_Cost),0.5,,OnStatCostChanged);
		StatCostSlider.Slider.SetStepSize(100.00f/float(UsedStatRanges.CostSteps));
		StatCostSlider.Slider.SetPercent(50.0);
	
		StatMinSlider = Spawn( class'UIMechaListItem', List.itemContainer );
		StatMinSlider.bAnimateOnInit = false;
		StatMinSlider.InitListItem();
		StatMinSlider.SetY(3*class'UIMechaListItem'.default.Height);
		//StatMinSlider=UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem();
		StatMinSlider.UpdateDataSlider(Descriptions[2],string(TempSM.Stat_Min),0.5,,OnStatMinChanged);
		StatMinSlider.Slider.SetStepSize(100.00f/float(UsedStatRanges.MinSteps));
		StatMinSlider.Slider.SetPercent(50.0);
	}
	else
	{
		RFTypeSpinner = Spawn( class'UIMechaListItem', List.itemContainer );
		RFTypeSpinner.bAnimateOnInit = false;
		RFTypeSpinner.InitListItem();
		RFTypeSpinner.SetY(3*class'UIMechaListItem'.default.Height);
		//RFTypeSpinner=UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem();
		//CreatedUIMLI[CreatedUIMLI.Length]=Spawn(Class'UIMechaListItem', List.itemContainer).InitListItem();
		RFTypeSpinner.UpdateDataSpinner(Descriptions[2],RFTypeNames[RFFSingle.RedFogCalcType],UpdateRedFogSpinner);	
		RFTypeSpinner.Spinner.selectedIndex=RFFSingle.RedFogCalcType;
	}

	StatRangeSlider = Spawn( class'UIMechaListItem', List.itemContainer );
	StatRangeSlider.bAnimateOnInit = false;
	StatRangeSlider.InitListItem();
	StatRangeSlider.SetY(2*class'UIMechaListItem'.default.Height);
	//StatRangeSlider=UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem();
	StatRangeSlider.UpdateDataSlider(Descriptions[1],DoingRF ? string(RFFSingle.Range) : string(SCSingle.Stat_Range),0.5,,OnStatRangeChanged);
	StatRangeSlider.Slider.SetStepSize(DoingRF ? 10.0 : 100.00f/float(UsedStatRanges.RangeSteps));

	if(SCSingle.Stat_Range<(UsedStatRanges.RangeSteps/2))
		StatRangeSlider.Slider.SetPercent(50.0+((SCSingle.Stat_Range-(UsedStatRanges.RangeSteps/2))*StatRangeSlider.Slider.stepSize));
	else
		StatMinSlider.Slider.SetPercent(50.0);

	StatTypeDropdown = Spawn( class'UIMechaListItem', List.itemContainer );
	StatTypeDropdown.bAnimateOnInit = false;
	StatTypeDropdown.InitListItem();
	StatTypeDropdown.SetY(class'UIMechaListItem'.default.Height);
	//StatTypeDropdown=UIMechaListItem(List.CreateItem(class'UIMechaListItem')).InitListItem();
	StatTypeDropdown.UpdateDataDropdown(Descriptions[0],AvaliableStatTypesStrings,0,OnStatTypeDropDownChanged);

//	List.RealizeList();
//	List.RealizeItems(0);
//	List.RealizeMaskAndScrollbar();
}

function RemoveEverything(UIList List)
{
	List.ClearItems();

	StatNCEDestcription.Remove();
	StatTypeDropdown.Remove();
	StatRangeSlider.Remove();
	StatMinSlider.Remove();
	RFTypeSpinner.Remove();
	StatCostSlider.Remove();
	CancelButton.Remove();
	FinalButton.Remove();
	
	List.RealizeList();
	List.RealizeItems(0);
	List.RealizeMaskAndScrollbar();
}

function OnStatTypeDropDownChanged(UIDropdown DropdownControl)
{
	if(!DoingRF)
		TempSM.StatType=AvaliableStatTypes[DropdownControl.SelectedItem];
	else
		RFFTempSM.StatType=AvaliableStatTypes[DropdownControl.SelectedItem];

	UsedStatRanges=StatRanges[StatRanges.Find('StatType', DoingRF? RFFTempSM.StatType:TempSM.StatType)];	
	RemoveEverything(MyList);
	OpenEditList(MyList,true);
}

function float NRound(float In)
{
	if(UsedStatRanges.Range<1.0 && UsedStatRanges.Range>0.0)
		return In;
	else
		return Round(In);
}
	
function OnStatRangeChanged(UISlider sliderControl)
{
	if(!DoingRF)
	{
		/*if((SCSingle.Stat_Range<=(float(UsedStatRanges.RangeSteps)/2.0) ))
		{
			`log("CHANGING AND IF");
			StatRangeSlider.Slider.SetPercent(50.0+((SCSingle.Stat_Range-(float(UsedStatRanges.RangeSteps)/2.0))*StatRangeSlider.Slider.stepSize));
			`log("Percentage:"@sliderControl.percent @"TempSM Stat Range:"@(UsedStatRanges.RangeSteps) @((sliderControl.percent-(50.0+((SCSingle.Stat_Range-(float(UsedStatRanges.RangeSteps)/2.0))*StatRangeSlider.Slider.stepSize))/100.00)));
			TempSM.Stat_Range=SCSingle.Stat_Range+NRound(UsedStatRanges.RangeSteps*(sliderControl.percent-(50.0+((SCSingle.Stat_Range-(float(UsedStatRanges.RangeSteps)/2.0))*StatRangeSlider.Slider.stepSize))/100.00));	
		}
		else*/
		//{
			//`log("CHANGING AND ELSE");
		`log("Percentage:"@sliderControl.percent @"TempSM Stat Range:"@(UsedStatRanges.RangeSteps) @((sliderControl.percent-50.0)/100.00));
		TempSM.Stat_Range=SCSingle.Stat_Range+NRound(UsedStatRanges.RangeSteps*(sliderControl.percent-50.0)/100.00);
			
		//}
		sliderControl.SetText(string(TempSM.Stat_Range));
	}
	else
	{
		RFFTempSM.Range=(StatRangeSlider.Slider.percent/100);	
		if(StatRangeSlider.Slider.percent==1)
			RFFTempSM.Range=0;
		sliderControl.SetText(string(RFFTempSM.Range));

	}
}
	
function OnStatMinChanged(UISlider sliderControl)
{
	`log("Percentage:"@sliderControl.percent @"TempSM Stat Min:"@(UsedStatRanges.MinSteps) @((sliderControl.percent-50.0)/100.00));
	TempSM.Stat_Min=SCSingle.Stat_Min+NRound(UsedStatRanges.MinSteps*(sliderControl.percent-50.0)/100.00);
	sliderControl.SetText(string(TempSM.Stat_Min));
}
	
function OnStatCostChanged(UISlider sliderControl)
{
	`log("Percentage:"@sliderControl.percent @"TempSM Stat Cost:"@(UsedStatRanges.CostSteps) @((sliderControl.percent-50.0)/100.00));
	TempSM.Stat_Cost=SCSingle.Stat_Cost+NRound(UsedStatRanges.CostSteps*(sliderControl.percent-50.0)/100.00);
	sliderControl.SetText(string(TempSM.Stat_Cost));
}

simulated function UpdateRedFogSpinner(UIListItemSpinner SpinnerControl, int Direction)
{
	local int currentIndex;
	currentIndex=RFTypeNames.Find(SpinnerControl.value);

	if(currentIndex== RFTypeNames.Length-1 && Direction==1 )
		currentIndex=0;
	else if(currentIndex==0 && Direction==-1)
		currentIndex=RFTypeNames.Length-1;
	else
		currentIndex+=Direction;

	SpinnerControl.SetValue(RFTypeNames[currentIndex]);
	SpinnerControl.selectedIndex=currentIndex;
	RFFTempSM.RedFogCalcType=currentIndex;
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