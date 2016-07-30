// This is an Unreal Script
                           
class XComGameState_SecondWavePlus_UnitComponent extends XComGameState_BaseObject;

var protected bool b_HasGot_NotCreatedEqually;
var protected bool b_HasGot_CommandersChoiceVet;
var protected bool b_HasGot_HiddenPotential;

var private SecondWave_HiddenPotentialStatHolder_Actor HiddenPHolder;

public function SendEventsAfterInit(Optional XComGameState NewGameState)
{
	local Object Myself;

	Myself=self;

	`XEVENTMGR.TriggerEvent('NCE_Start',self,XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(self.OwningObjectId)),NewGameState);	
	`XEVENTMGR.TriggerEvent('HiddenPotential_Start',self,XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(self.OwningObjectId)),NewGameState);	
	`XEVENTMGR.RegisterForEvent(Myself,'UnitRankUp',OnRankUp);
}
function EventListenerReturn OnRankUp(Object EventData, Object EventSource, XComGameState NewGameState, Name InEventID)
{
	if(XComGameState_Unit(EventData).ObjectID==XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(self.OwningObjectId)).ObjectID)
		`XEVENTMGR.TriggerEvent('HiddenPotential_ApplyUpdate',self,XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(self.OwningObjectId)),NewGameState);	
	return ELR_NoInterrupt;
}
public function SetHiddenPotentialLevelChanges(array<HiddenPotentialLevelChanges> LevelChanges)
{	
	HiddenPHolder.SavedLevelChanges=LevelChanges;
}
public function array<HiddenPotentialLevelChanges> GetSavedLevelChanges()
{		
	return HiddenPHolder.SavedLevelChanges;	
}
public function SetHiddenPotentialHolder(SecondWave_HiddenPotentialStatHolder_Actor Holder)
{		
	HiddenPHolder=holder;
	HiddenPHolder.SetOwningObjectID(self.ObjectID);
}
public function SecondWave_HiddenPotentialStatHolder_Actor GetHiddenPotentialHolder()
{		
	return HiddenPHolder;	
}
public function HiddenPotentialLevelChanges GetSpecificLevelChanges(int i)
{		
	if(i!=-1 && i<HiddenPHolder.SavedLevelChanges.Length)
		return HiddenPHolder.SavedLevelChanges[i];	
}

public function SetHasGot_NotCreatedEqually (bool InBool)
{
	b_HasGot_NotCreatedEqually=InBool;	
}
public function SetHasGot_CommandersChoiceVet (bool InBool)
{
	b_HasGot_CommandersChoiceVet=InBool;	
}
public function SetHasGot_HiddenPotential (bool InBool)
{
	b_HasGot_HiddenPotential=InBool;
	if(!Inbool)
	{
		HiddenPHolder.Destroy();
		HiddenPHolder=none;
	}	
}
public function bool GetHasGot_NotCreatedEqually ()
{
	return b_HasGot_NotCreatedEqually;	
}
public function bool GetHasGot_CommandersChoiceVet ()
{
	return b_HasGot_CommandersChoiceVet;	
}
public function bool GetHasGot_HiddenPotential ()
{
	return b_HasGot_HiddenPotential;	
}
