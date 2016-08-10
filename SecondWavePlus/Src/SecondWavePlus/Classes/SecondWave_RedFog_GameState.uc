// This is an Unreal Script
                           
class SecondWave_RedFog_GameState extends SecondWave_GameStateParent config(SecondWavePlus_Settings);

var config bool b_IsRedFogActive;
var config bool b_IsRedFogActive_Aliens;
var config bool b_IsRedFogActive_XCom;
var config bool b_IsRedFogActive_Robotics;
var config bool b_UseGaussianEquasion;

var config array<RedFogFormulatType> FTypeRF;

function InitListeners()
{
	`XCOMHISTORY.RegisterOnNewGameStateDelegate(OnNewGameState_HealthWatcher);
}

static function OnNewGameState_HealthWatcher(XComGameState GameState) //Thank you Amineri and LWS! 
{
	local XComGameState NewGameState;
	local int StateObjectIndex;
	local XComGameState_Effect RedFogEffect;
	local XComGameState_Effect_RedFog_SecondWave RFEComponent;
	local XComGameState_Unit HPChangedUnit, UpdatedUnit;
	local array<XComGameState_Unit> HPChangedObjects;  // is generically just a pair of XComGameState_BaseObjects, pre and post the change

	//`log("RED FOG ACTIVE! Starting Stuff");
	if(`TACTICALRULES == none || !`TACTICALRULES.TacticalGameIsInPlay()) return; // only do this checking when in tactical battle

	HPChangedObjects.Length = 0;
	GetHPChangedObjectList(GameState, HPChangedObjects);
	if(HPChangedObjects.Length>0) `log("RED FOG ACTIVE! FOUND UNIT! HPChangedObjects.Length:"@HPChangedObjects.Length,,'Second Wave Plus-Red Fog');
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Update RedFog OnNewGameState_HealthWatcher");
	for( StateObjectIndex = 0; StateObjectIndex < HPChangedObjects.Length; ++StateObjectIndex )
	{	
		HPChangedUnit = HPChangedObjects[StateObjectIndex];
		if(HPChangedUnit.IsUnitAffectedByEffectName(class'X2Effect_RedFog_SecondWave'.default.EffectName))
		{
			`log("RED FOG ACTIVE! FOUND UNIT AFFECTED"@HPChangedUnit.GetFullName(),,'Second Wave Plus-Red Fog');
			RedFogEffect = HPChangedUnit.GetUnitAffectedByEffectState(class'X2Effect_RedFog_SecondWave'.default.EffectName);
			if(RedFogEffect != none)
			{
				`log("RED FOG ACTIVE! FOUND GAME STATE",,'Second Wave Plus-Red Fog');
				RFEComponent = XComGameState_Effect_RedFog_SecondWave(RedFogEffect.FindComponentObject(class'XComGameState_Effect_RedFog_SecondWave'));
				if(RFEComponent != none)
				{
					UpdatedUnit = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', HPChangedUnit.ObjectID));
					NewGameState.AddStateObject(RFEComponent.GetOwner());
					NewGameState.AddStateObject(UpdatedUnit);
					RFEComponent.GetRedFogStatChanges(UpdatedUnit, NewGameState,true);
					`log("RED FOG ACTIVE! APPLIED STATS",,'Second Wave Plus-Red Fog');
				}
			}
		}
	}
	if(NewGameState.GetNumGameStateObjects() > 0)
		`TACTICALRULES.SubmitGameState(NewGameState);
	else
		`XCOMHISTORY.CleanupPendingGameState(NewGameState);
}

static function GetHPChangedObjectList(XComGameState NewGameState, out array<XComGameState_Unit> OutHPChangedObjects) //Thank you Amineri and LWS! 
{
	local XComGameStateHistory History;
	local int StateObjectIndex;
	local XComGameState_BaseObject StateObjectCurrent;
	local XComGameState_BaseObject StateObjectPrevious;
	local XComGameState_Unit UnitStateCurrent, UnitStatePrevious;

	History = `XCOMHISTORY;
	//`log("RED FOG ACTIVE! FOUND UNIT!  NewGameState.GetNumGameStateObjects:"@ NewGameState.GetNumGameStateObjects() );
    for( StateObjectIndex = 0; StateObjectIndex < NewGameState.GetNumGameStateObjects(); ++StateObjectIndex )
	{
		StateObjectCurrent = NewGameState.GetGameStateForObjectIndex(StateObjectIndex);		
		UnitStateCurrent = XComGameState_Unit(StateObjectCurrent);
		if( UnitStateCurrent != none )
		{
			StateObjectPrevious = History.GetGameStateForObjectID(StateObjectCurrent.ObjectID, , NewGameState.HistoryIndex - 1);
			UnitStatePrevious = XComGameState_Unit(StateObjectPrevious);
			//`log(UnitStatePrevious.GetFullName() @"Unit HP:"@UnitStatePrevious.GetCurrentStat(eStat_HP));
			if(UnitStatePrevious != none && UnitStateCurrent.GetCurrentStat(eStat_HP) != UnitStatePrevious.GetCurrentStat(eStat_HP))
			{
				OutHPChangedObjects.AddItem(UnitStateCurrent);
			}
		}
	}
}

function AddRedFogAbilityToAllUnits(XComGameState GameState)
{
	local X2AbilityTemplate RedFogAbilityTemplate, AbilityTemplate;
	local array<X2AbilityTemplate> AllAbilityTemplates;
	local XComGameStateHistory History;
	local XComGameState_Unit AbilitySourceUnitState;
	local StateObjectReference AbilityRef;
	local XComGameState_Ability AbilityState;
	local Name AdditionalAbilityName;
	local X2EventManager EventMgr;

	History = `XCOMHISTORY;
	EventMgr = `XEVENTMGR;
	RedFogAbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('RedFog_SecondWavePlus');

	if( RedFogAbilityTemplate != none )
	{
		AllAbilityTemplates.AddItem(RedFogAbilityTemplate);
		foreach RedFogAbilityTemplate.AdditionalAbilities(AdditionalAbilityName)
		{
			AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(AdditionalAbilityName);
			if( AbilityTemplate != none )
			{
				AllAbilityTemplates.AddItem(AbilityTemplate);
			}
		}
	}

	foreach History.IterateByClassType(class'XComGameState_Unit', AbilitySourceUnitState)
	{
		if(AbilitySourceUnitState.GetTeam() != eTeam_XCom && AbilitySourceUnitState.GetTeam() != eTeam_Alien)
			continue;

		AbilitySourceUnitState = XComGameState_Unit(GameState.CreateStateObject(class'XComGameState_Unit', AbilitySourceUnitState.ObjectID));
		GameState.AddStateObject(AbilitySourceUnitState);

		foreach AllAbilityTemplates(AbilityTemplate)
		{
			AbilityRef = AbilitySourceUnitState.FindAbility(AbilityTemplate.DataName);
			if( AbilityRef.ObjectID == 0 )
			{
				AbilityRef = `TACTICALRULES.InitAbilityForUnit(RedFogAbilityTemplate, AbilitySourceUnitState, GameState);
			}

			AbilityState = XComGameState_Ability(GameState.CreateStateObject(class'XComGameState_Ability', AbilityRef.ObjectID));
			GameState.AddStateObject(AbilityState);
		}

		// trigger event listeners now to update red fog activation for already applied effects
		EventMgr.TriggerEvent('RedFogActivated', AbilitySourceUnitState, AbilitySourceUnitState, GameState);
	}
}