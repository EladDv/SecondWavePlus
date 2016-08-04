// This is an Unreal Script
                           
Class X2Effect_RedFog_SecondWave extends X2Effect_ModifyStats;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit TargetUnit;
	local XComGameState_Effect_RedFog_SecondWave SWRedFog;

	TargetUnit=XComGameState_Unit(kNewTargetState);
	if(TargetUnit==none)
		return;
	SWRedFog=XComGameState_Effect_RedFog_SecondWave(NewEffectState.FindComponentObject(class'XComGameState_Effect_RedFog_SecondWave'));

	if(SWRedFog==none)
	{
		SWRedFog=XComGameState_Effect_RedFog_SecondWave(NewGameState.CreateStateObject(class'XComGameState_Effect_RedFog_SecondWave'));
		SWRedFog.InitRFComponent();
		`log("Creating New SW Red Fog Object!");
		NewEffectState.AddComponentObject(SWRedFog);
		NewGameState.AddStateObject(SWRedFog);
	}
	SWRedFog.RegisterForRFEvents(TargetUnit);
	super.OnEffectAdded(ApplyEffectParameters,kNewTargetState,NewGameState,NewEffectState);
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{	
	`XEVENTMGR.TriggerEvent('RedFogCleanup',GetRedFogComponent(RemovedEffectState),GetRedFogComponent(RemovedEffectState),NewGameState);

	super.OnEffectRemoved(ApplyEffectParameters, NewGameState, bCleansed, RemovedEffectState);
}

static function XComGameState_Effect_RedFog_SecondWave GetRedFogComponent(XComGameState_Effect Effect)
{
	if (Effect != none) 
		return XComGameState_Effect_RedFog_SecondWave(Effect.FindComponentObject(class'XComGameState_Effect_RedFog_SecondWave'));
	return none;
}

defaultproperties
{
    DuplicateResponse=eDupe_Ignore
	EffectName="RedFog_SecondWavePlus";
	bRemoveWhenSourceDies=true;
}
