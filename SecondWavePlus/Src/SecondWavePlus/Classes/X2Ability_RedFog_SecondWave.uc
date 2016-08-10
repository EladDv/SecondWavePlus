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

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RedFog_SecondWavePlus');
	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;

	PostBeginPlayTrigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	PostBeginPlayTrigger.Priority -= 100;        // Lower priority to guarantee other stat-effecting abilities run first
	Template.AbilityTriggers.AddItem(PostBeginPlayTrigger);


	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	
	RedFogEffect = new class'X2Effect_RedFog_SecondWave';
	RedFogEffect.BuildPersistentEffect(1, true, true, true, eGameRule_PlayerTurnBegin); 
	RedFogEffect.bCanTickEveryAction = true;
	RedFogEffect.VisualizationFn = RedFogVisualization;
	RedFogEffect.EffectTickedVisualizationFn = RedFogVisualization;
	RedFogEffect.EffectRemovedVisualizationFn = RedFogVisualization;

	Template.AddTargetEffect(RedFogEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function RedFogVisualization (XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
    local XComGameState_Unit UnitState;

	if(!BuildTrack.StateObject_NewState.IsA('XComGameState_Unit'))
    {
        return;
    }
	UnitState = XComGameState_Unit(BuildTrack.StateObject_NewState);
	if(UnitState == none || UnitState.IsDead())
    {
        return;
    }
    class'X2StatusEffects'.static.UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());

}
