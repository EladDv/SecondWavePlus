// This is an Unreal Script
                           
Class UIScreenListener_SecondWave extends UIScreenListener;

var SecondWave_CommandersChoice_Actor	Main_CommandersChoice_Actor;
var SecondWave_HiddenPotential_Actor	Main_HiddenPotential_Actor;
var SecondWave_Epigenetics_Actor		Main_Epigenetics_Actor;
var SecondWave_NotCreatedEqually_Actor	Main_NotCreatedEqually_Actor;

event OnInit(UIScreen Screen)
{
	local Object Myself;

	Myself=self;
	if(Main_CommandersChoice_Actor==none)	Main_CommandersChoice_Actor=Screen.Spawn(class'SecondWave_CommandersChoice_Actor');
	if(Main_HiddenPotential_Actor==none)	Main_HiddenPotential_Actor=Screen.Spawn(class'SecondWave_HiddenPotential_Actor');
	if(Main_Epigenetics_Actor==none)		Main_Epigenetics_Actor=Screen.Spawn(class'SecondWave_Epigenetics_Actor');
	if(Main_NotCreatedEqually_Actor==none)	Main_NotCreatedEqually_Actor=Screen.Spawn(class'SecondWave_NotCreatedEqually_Actor');
	`XEVENTMGR.RegisterForEvent(self,'Heartbeat_Lub_1',Heartbeat_Lub_1);
	`XEVENTMGR.RegisterForEvent(self,'Heartbeat_Lub_2',Heartbeat_Lub_2);	
}
event OnReceiveFocus(UIScreen Screen)
{
	
}

function CheckForUnitComponents(XComGameState NewGameState,optional bool Submit=false)
{
	local XComGameState_Unit Unit;
	local XComGameState_SecondWavePlus_UnitComponent UnitComp;
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit',Unit)
	{
		if(Unit.IsSoldier())
		{
			UnitComp=XComGameState_SecondWavePlus_UnitComponent(Unit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'));
			if(UnitComp==none)
			{
				UnitComp=XComGameState_SecondWavePlus_UnitComponent(NewGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent'));
				Unit.AddComponentObject(UnitComp);
				UnitComp.SendEventsAfterInit(NewGameState);
				NewGameState.AddStateObject(UnitComp);
				NewGameState.AddStateObject(Unit);
				if(Submit)
					`XCOMHISTORY.AddGameStateToHistory(NewGameState);
			}
		}
	}	
}
function EventListenerReturn Heartbeat_Lub_1(Object EventData, Object EventSource, XComGameState NewGameState, Name InEventID)
{ 
	`XEVENTMGR.TriggerEvent('Heartbeat_Dub_1',Main_CommandersChoice_Actor,Main_HiddenPotential_Actor,NewGameState);
	return ELR_NoInterrupt;
}
function EventListenerReturn Heartbeat_Lub_2(Object EventData, Object EventSource, XComGameState NewGameState, Name InEventID)
{ 
	CheckForUnitComponents(NewGameState);	
	`XEVENTMGR.TriggerEvent('Heartbeat_Dub_2',Main_Epigenetics_Actor,Main_NotCreatedEqually_Actor,NewGameState);
	return ELR_NoInterrupt;
}


