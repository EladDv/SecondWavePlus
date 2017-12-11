// This is an Unreal Script
                           
class SecondWave_RedFog_GameState extends SecondWave_GameStateParent config(SecondWavePlus_Settings);

var config bool b_IsRedFogActive;
var config bool b_IsRedFogActive_Aliens;
var config bool b_IsRedFogActive_Advent;
var config bool b_IsRedFogActive_XCom;
var config bool b_IsRedFogActive_Robotics;
var config bool b_UseGaussianEquasion;

var config array<RedFogFormulatType> FTypeRF;

function InitListeners()
{             
	local Object Myself;
	Myself=self;
	`XCOMHISTORY.RegisterOnNewGameStateDelegate(OnNewGameState_HealthWatcher);
	
	`XEVENTMGR.RegisterForEvent(Myself,'TacticalGameEnd',OnTacticalGameEnd,ELD_OnStateSubmitted);	
}

function ObtainOptions()
{
	local SecondWave_OptionsDataStore SWDataStore;
	SWDataStore=class'SecondWave_OptionsDataStore'.static.GetInstance();	

	b_IsRedFogActive=SWDataStore.GetValues("b_IsRedFogActive").Bool_Value;
	//b_IsRedFogActive = false;
	b_IsRedFogActive_Aliens=SWDataStore.GetValues("b_IsRedFogActive_Aliens").Bool_Value;
	b_IsRedFogActive_Advent=SWDataStore.GetValues("b_IsRedFogActive_Advent").Bool_Value;
	b_IsRedFogActive_XCom=SWDataStore.GetValues("b_IsRedFogActive_XCom").Bool_Value;
	b_IsRedFogActive_Robotics=SWDataStore.GetValues("b_IsRedFogActive_Robotics").Bool_Value;
	b_UseGaussianEquasion=SWDataStore.GetValues("b_UseGaussianEquasion").Bool_Value;
	FTypeRF=SWDataStore.SavedRedFogTypes;

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
					`log("RED FOG ACTIVE! FOUND COMPONENT",,'Second Wave Plus-Red Fog');
					UpdatedUnit = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', HPChangedUnit.ObjectID));
					NewGameState.AddStateObject(UpdatedUnit);
					RFEComponent.GetRedFogStatChanges(UpdatedUnit, NewGameState);
				}
			}
		}
	}
	if(NewGameState.GetNumGameStateObjects() > 0)
		 `XCOMHISTORY.AddGameStateToHistory(NewGameState);
	else
		`XCOMHISTORY.CleanupPendingGameState(NewGameState);
}

static function GetHPChangedObjectList(XComGameState NewGameState, out array<XComGameState_Unit> OutHPChangedObjects) //Thank you Amineri and LWS! 
{
	local XComGameStateHistory History;
	local int StateObjectIndex;
	local XComGameState_Unit UnitStateCurrent, UnitStatePrevious;

	History = `XCOMHISTORY;
	//`log("RED FOG ACTIVE! FOUND UNIT!  NewGameState.GetNumGameStateObjects:"@ NewGameState.GetNumGameStateObjects() );
    foreach NewGameState.IterateByClassType(class'XComGameState_Unit', UnitStateCurrent)
	{
		if( UnitStateCurrent != none )
		{
			UnitStatePrevious = XComGameState_Unit(History.GetGameStateForObjectID(UnitStateCurrent.ObjectID, , NewGameState.HistoryIndex - 1));
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
		`log("HAS RED FOG TEMPLATE");
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

		`log("Iterating through unit" @AbilitySourceUnitState.GetFullName());

		if(AbilitySourceUnitState.GetTeam() != eTeam_XCom && AbilitySourceUnitState.GetTeam() != eTeam_Alien)
			continue;

		if( (AbilitySourceUnitState.IsSoldier() && !b_IsRedFogActive_XCom) ||
			(AbilitySourceUnitState.IsAlien()&& !b_IsRedFogActive_Aliens) ||
			(AbilitySourceUnitState.IsAdvent() && !b_IsRedFogActive_Advent) ||
			(AbilitySourceUnitState.IsRobotic() && !b_IsRedFogActive_Robotics) || !b_IsRedFogActive)
			continue;



		AbilitySourceUnitState = XComGameState_Unit(GameState.CreateStateObject(class'XComGameState_Unit', AbilitySourceUnitState.ObjectID));
		GameState.AddStateObject(AbilitySourceUnitState);

		foreach AllAbilityTemplates(AbilityTemplate)
		{
			AbilityRef = AbilitySourceUnitState.FindAbility(AbilityTemplate.DataName);
			if( AbilityRef.ObjectID == 0 )
			{
				AbilityRef = `TACTICALRULES.InitAbilityForUnit(RedFogAbilityTemplate, AbilitySourceUnitState, GameState);
				`log("ADDED ABILITY TO UNIT");
			}
			AbilityState = XComGameState_Ability(GameState.CreateStateObject(class'XComGameState_Ability', AbilityRef.ObjectID));
			GameState.AddStateObject(AbilityState);
		}

		// trigger event listeners now to update red fog activation for already applied effects
		//EventMgr.TriggerEvent('RedFogActivated', AbilitySourceUnitState, AbilitySourceUnitState, GameState);
	}
}

function EventListenerReturn OnTacticalGameEnd(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	`XCOMHISTORY.UnRegisterOnNewGameStateDelegate(OnNewGameState_HealthWatcher);
	GCValidationChecks();
	return ELR_NoInterrupt;
}

static function GCValidationChecks() //Thanks Amineri and LWS
{
    local XComGameStateHistory History;
    local XComGameState NewGameState;
    local XComGameState_Unit UnitState;
    local XComGameState_Effect_RedFog_SecondWave SWPCState;
 
    `LOG("SWP: Starting RF EFFECT Garbage Collection and Validation.");
 
    History = `XCOMHISTORY;
    NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("SWP States cleanup");

    foreach History.IterateByClassType(class'XComGameState_Effect_RedFog_SecondWave',SWPCState,,true)
    {
		`LOG("SWP Component has no current owning unit, cleaning up state.",,'Dragonpunk Second Wave Plus');
		// Remove disconnected state
		NewGameState.RemoveStateObject(SWPCState.ObjectID);
    }
    if (NewGameState.GetNumGameStateObjects() > 0)
	{
		`TACTICALRULES.SubmitGameState(NewGameState);
        //`XCOMHISTORY.AddGameStateToHistory(NewGameState);
    }
	else
        History.CleanupPendingGameState(NewGameState);
}
 
