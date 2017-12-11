// This is an Unreal Script
                           
class X2Ability_RedFog_SecondWave extends X2Ability;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateRedFogAbility());

	return Templates;
}

static function X2AbilityTemplate CreateRedFogAbility() // Thanks (again) to LWS and Amineri!
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_UnitPostBeginPlay PostBeginPlayTrigger;
	local X2Effect_RedFog_SecondWave RedFogEffect;
	local X2AbilityTrigger_EventListener Trigger;
	//local X2AbilityTrigger					Trigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RedFog_SecondWavePlus');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_criticallywounded";  
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;

/*
	PostBeginPlayTrigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	PostBeginPlayTrigger.Priority = 1;        // Lower priority to guarantee other stat-effecting abilities run first
	Template.AbilityTriggers.AddItem(PostBeginPlayTrigger);
*/
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'OnUnitBeginPlay';
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	Template.AbilityTriggers.AddItem(Trigger);

/*
	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);
*/
	//Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_PlayerInput');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	//Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Neutral;
	RedFogEffect = new class'X2Effect_RedFog_SecondWave';
	RedFogEffect.BuildPersistentEffect(1, true, true,true,eGameRule_PlayerTurnBegin); 
	RedFogEffect.SetDisplayInfo	(ePerkBuff_Penalty, "Red Fog", "Red Fog", Template.IconImage,, "", Template.AbilitySourceName);
	RedFogEffect.bCanTickEveryAction = true;
	RedFogEffect.VisualizationFn = RedFogVisualization;
	RedFogEffect.EffectTickedVisualizationFn = RedFogVisualization;
	RedFogEffect.EffectRemovedVisualizationFn = RedFogVisualization;

	Template.AddTargetEffect(RedFogEffect);

	//Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

//static function RedFogVisualization (XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
static function RedFogVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
    local XComGameState_Unit UnitState;
	UnitState = XComGameState_Unit(ActionMetadata.StateObject_NewState);
	if(UnitState == none || UnitState.IsDead())
    {
        return;
    }
    class'X2StatusEffects'.static.UpdateUnitFlag(ActionMetadata, VisualizeGameState.GetContext());

}
