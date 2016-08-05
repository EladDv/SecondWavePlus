// This is an Unreal Script
                           
class XComGameState_SecondWavePlus_UnitComponent extends SecondWave_GameStateParent;

var protected bool b_HasGot_NotCreatedEqually;
var protected bool b_HasGot_CommandersChoiceVet;
var protected bool b_HasGot_HiddenPotential;
var protected bool b_HasGot_AbsolutlyCritical;

var int ExtraCostExpensiveTalent;

var int LastUpdatedLevel;

var private array<HiddenPotentialLevelChanges> SavedLevelChanges;

public function SendEventsAfterInit(Optional XComGameState NewGameState)
{
	//local Object Myself;

	//Myself=self;

	`XEVENTMGR.TriggerEvent('NCE_Start',self,XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(self.OwningObjectId)),NewGameState);	
	`XEVENTMGR.TriggerEvent('HiddenPotential_Start',self,XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(self.OwningObjectId)),NewGameState);	
	`XEVENTMGR.TriggerEvent('AbsolutlyCritical_Start',self,XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(self.OwningObjectId)),NewGameState);	
	//`XEVENTMGR.RegisterForEvent(Myself,'UnitRankUp',OnRankUp,ELD_OnStateSubmitted, , ,true);
}
/*function EventListenerReturn OnRankUp(Object EventData, Object EventSource, XComGameState NewGameState, Name InEventID)
{
	`log("RankedUp!");
	if(XComGameState_Unit(EventData).ObjectID==XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(self.OwningObjectId)).ObjectID)
		`XEVENTMGR.TriggerEvent('HiddenPotential_ApplyUpdate',XComGameState_Unit(EventData),XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(self.OwningObjectId)),NewGameState);	
	return ELR_NoInterrupt;
}*/
public function SetHiddenPotentialLevelChanges(array<HiddenPotentialLevelChanges> LevelChanges)
{	
	SavedLevelChanges=LevelChanges;
}
public function array<HiddenPotentialLevelChanges> GetSavedLevelChanges()
{		
	return SavedLevelChanges;	
}
public function HiddenPotentialLevelChanges GetSpecificLevelChanges(int i)
{		
	if(i>=0 && i<SavedLevelChanges.Length)
		return SavedLevelChanges[i];	
	return SavedLevelChanges[0];
}

public function SetHasGot_AbsolutlyCritical (bool InBool)
{
	b_HasGot_AbsolutlyCritical=InBool;	
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
		SavedLevelChanges.Length=0;
	}	
}
public function bool GetHasGot_AbsolutlyCritical ()
{
	return b_HasGot_AbsolutlyCritical;
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
