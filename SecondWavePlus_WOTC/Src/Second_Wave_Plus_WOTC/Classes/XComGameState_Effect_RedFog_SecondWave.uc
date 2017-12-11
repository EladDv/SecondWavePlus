// This is an Unreal Script
                           
class XComGameState_Effect_RedFog_SecondWave extends SecondWave_GameStateParent config(SecondWavePlus_Settings);

var bool b_IsRedFogActive;
var bool b_IsRedFogActive_Aliens;
var bool b_IsRedFogActive_Advent;
var bool b_IsRedFogActive_XCom;
var bool b_IsRedFogActive_Robotics;
var bool b_UseGaussianEquasion;

var array<RedFogFormulatType> FTypeRF;
var StateObjectReference MyUnitRef;

struct PreChangeStats
{
	var ECharStatType StatType;	
	var float MaxStat;
	var float CurrentStat;	
	var float BaseStat;	
};
var array<PreChangeStats> PCSRF;

function XComGameState_Effect_RedFog_SecondWave InitRFComponent()
{
	local SecondWave_RedFog_GameState	Main_RedFog_GameState;

	Main_RedFog_GameState=SecondWave_RedFog_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_RedFog_GameState'));
	b_IsRedFogActive=Main_RedFog_GameState.b_IsRedFogActive;
	b_IsRedFogActive_Aliens=Main_RedFog_GameState.b_IsRedFogActive_Aliens;
	b_IsRedFogActive_Advent=Main_RedFog_GameState.b_IsRedFogActive_Advent;
	b_IsRedFogActive_XCom=Main_RedFog_GameState.b_IsRedFogActive_XCom;
	b_IsRedFogActive_Robotics=Main_RedFog_GameState.b_IsRedFogActive_Robotics;
	b_UseGaussianEquasion=Main_RedFog_GameState.b_UseGaussianEquasion;
	FTypeRF=Main_RedFog_GameState.FTypeRF;
	return self;
}

function XComGameState_Effect GetOwner(optional XComGameState GameState)
{
	if(GameState!=none)
	{
		if(XComGameState_Effect(GameState.GetGameStateForObjectID(self.OwningObjectId))!=none)
			return XComGameState_Effect(GameState.GetGameStateForObjectID(self.OwningObjectId));
	}
	return XComGameState_Effect(`XCOMHISTORY.GetGameStateForObjectID(self.OwningObjectId));
}

function RegisterForRFEvents(optional XComGameState_Unit TargetUnit)
{
	local RedFogFormulatType FTypeLocal;
	local Object SelfObj;
	
	SelfObj=self;
	if(SelfObj==none)
		return;
	`XEVENTMGR.RegisterForEvent(SelfObj,'RedFogActivated',UpdateRedFog,ELD_OnStateSubmitted,,TargetUnit,true);
	`XEVENTMGR.RegisterForEvent(SelfObj,'RedFogCleanup',RedFogCleanup,ELD_OnStateSubmitted,,TargetUnit,true);
	`XEVENTMGR.RegisterForEvent(SelfObj,'UnitRemovedFromPlay',RedFogCleanup,ELD_OnStateSubmitted,,TargetUnit,true);
}
function EventListenerReturn RedFogCleanup(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameStateHistory History;
    local XComGameState NewGameState;
	local XComGameState_Effect_RedFog_SecondWave SWRFEffectObject;
    local XComGameState_Effect EffectState;
	local PreChangeStats LocalPCS;
	local Object SelfObj;
	local XComGameState_Unit MyUnit;
	SelfObj=self;
	History=`XCOMHISTORY;
	`XEVENTMGR.UnRegisterFromAllEvents(SelfObj);
	`log("CLEANING UP RED FOG");
    NewGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("cleanup");	
    SWRFEffectObject=XComGameState_Effect_RedFog_SecondWave(NewGameState.CreateStateObject(self.Class, self.ObjectID));
	if(SWRFEffectObject.OwningObjectId > 0)
    {
			EffectState = XComGameState_Effect(History.GetGameStateForObjectID(SWRFEffectObject.OwningObjectID));
        if(EffectState == none)
			NewGameState.RemoveStateObject(SWRFEffectObject.ObjectID);
		else if (EffectState.bRemoved)
			NewGameState.RemoveStateObject(SWRFEffectObject.ObjectID);
	}
	else
		NewGameState.RemoveStateObject(SWRFEffectObject.ObjectID);
	
	MyUnit=XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit',MyUnitRef.ObjectID));
	foreach PCSRF(LocalPCS)
	{
		if(LocalPCS.CurrentStat==MyUnit.GetMaxStat(LocalPCS.StatType))
			MyUnit.SetCurrentStat(LocalPCS.StatType,LocalPCS.CurrentStat);
		else
			MyUnit.SetCurrentStat(LocalPCS.StatType,MyUnit.GetMaxStat(LocalPCS.StatType));
	
	}
	NewGameState.AddStateObject(MyUnit);
	if (NewGameState.GetNumGameStateObjects() > 0)
        History.AddGameStateToHistory(NewGameState);
    else
        History.CleanupPendingGameState(NewGameState);

	
	return ELR_NoInterrupt;
}
function EventListenerReturn UpdateRedFog(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_Unit Unit, UpdatedUnitState;
	local XComGameState_Effect_RedFog_SecondWave UpdatedRFState;
	local XComGameState NewGameState;
	
	Unit = XComGameState_Unit(EventSource);
	if(Unit==none)
		GetTargetUnit();
	if(Unit==none)
		return ELR_NoInterrupt;
	if(!b_IsRedFogActive)
		return ELR_NoInterrupt;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Update RedFog");
	UpdatedRFState = XComGameState_Effect_RedFog_SecondWave(NewGameState.CreateStateObject(self.Class, self.ObjectID));
	NewGameState.AddStateObject(UpdatedRFState);
	UpdatedUnitState = XComGameState_Unit(NewGameState.CreateStateObject(Unit.Class, Unit.ObjectID));
	NewGameState.AddStateObject(UpdatedUnitState);
	if(UpdatedUnitState.IsAlien()&& !b_IsRedFogActive_Aliens)
	{
		UpdatedRFState.GetRedFogStatChanges(UpdatedUnitState, NewGameState);
		SubmitGameState(NewGameState);
		return ELR_NoInterrupt;
	}
	if(UpdatedUnitState.IsSoldier() && !b_IsRedFogActive_XCom)
	{
		UpdatedRFState.GetRedFogStatChanges(UpdatedUnitState, NewGameState);
		SubmitGameState(NewGameState);
		return ELR_NoInterrupt;
	}
	if(UpdatedUnitState.IsRobotic() && !b_IsRedFogActive_Robotics)
	{
		UpdatedRFState.GetRedFogStatChanges(UpdatedUnitState, NewGameState);
		SubmitGameState(NewGameState);
		return ELR_NoInterrupt;
	}
	if(UpdatedUnitState.IsAdvent() && !b_IsRedFogActive_Advent)
	{
		UpdatedRFState.GetRedFogStatChanges(UpdatedUnitState, NewGameState);
		SubmitGameState(NewGameState);
		return ELR_NoInterrupt;
	}
	UpdatedRFState.GetRedFogStatChanges(UpdatedUnitState, NewGameState);
	SubmitGameState(NewGameState);
	return ELR_NoInterrupt;
}

function bool IsRFActive(XComGameState_Unit UpdatedUnitState)
{
	if(!b_IsRedFogActive)
	{
		return false;
	}
	if(UpdatedUnitState.IsAlien()&& !b_IsRedFogActive_Aliens)
	{
		return false;
	}
	if(UpdatedUnitState.IsSoldier() && !b_IsRedFogActive_XCom)
	{
		return false;
	}
	if(UpdatedUnitState.IsRobotic() && !b_IsRedFogActive_Robotics)
	{
		return false;
	}
	if(UpdatedUnitState.IsAdvent() && !b_IsRedFogActive_Advent)
	{
		return false;
	}
	return true;
}

function XComGameState_Unit GetTargetUnit(optional XComGameState NewGameState)
{
	local XComGameState_Unit  TargetUnit;
	local XComGameState_Effect OwningEffect;

	OwningEffect = GetOwner(NewGameState);

	if (NewGameState != none)
		TargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(OwningEffect.ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	if (TargetUnit == none)
		TargetUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(OwningEffect.ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	if (TargetUnit == none)
		return none;

	return TargetUnit;
}

function GetRedFogStatChanges(XComGameState_Unit Unit, XComGameState GameState)
{
	local XComGameState_Effect	OwningEffect;
	local array<StatChange>		StatChanges;
	local StatChange			NewChange;
	local RedFogFormulatType	FTypeLocal;

	OwningEffect=GetOwner(GameState);
	OwningEffect = XComGameState_Effect(GameState.CreateStateObject(OwningEffect.Class, OwningEffect.ObjectID));
	GameState.AddStateObject(OwningEffect);
	Unit.UnApplyEffectFromStats(OwningEffect, GameState);
	if(!IsRFActive(Unit))
		return;
	StatChanges.Length=0;
	foreach FTypeRF(FTypeLocal)
	{
		NewChange.StatType=FTypeLocal.StatType;
		NewChange.StatAmount = -1 * Unit.GetBaseStat(FTypeLocal.StatType) * GetStatMultiplier(FTypeLocal,Unit.GetCurrentStat(eStat_HP),Unit.GetMaxStat(eStat_HP));
		NewChange.ModOp=MODOP_Addition;
		//`log("Unit: "@Unit.GetFullName() @FTypeLocal.StatType $": " $Unit.GetMaxStat(FTypeLocal.StatType)*(	NewChange.StatAmount = 1.0f - GetStatMultiplier(FTypeLocal,Unit.GetCurrentStat(eStat_HP),Unit.GetMaxStat(eStat_HP))));
		StatChanges.AddItem(NewChange);
	}
	OwningEffect.StatChanges = StatChanges;
	Unit.ApplyEffectToStats(OwningEffect, GameState);

}

function float GetStatMultiplier(RedFogFormulatType FTypeLocal, float CurrentHP , float MaxHP)
{
	local float FinalAnswer;

	if( CurrentHP <= 0 ) return 1.0f;
	switch (FTypeLocal.RedFogCalcType)
	{
		case 0:
			FinalAnswer = Get_A_Modifier(CurrentHP,MaxHP,FTypeLocal.Range);
			Break;

		case 1:
			FinalAnswer = Get_B_Modifier(CurrentHP,MaxHP,FTypeLocal.Range);
			Break;

		case 2:
			FinalAnswer = Get_C_Modifier(CurrentHP,MaxHP,FTypeLocal.Range);
			Break;
		default:
			FinalAnswer = 0.0f;
			Break;	
	}
	if(CurrentHP<=0 || CurrentHP == MaxHP)
		FinalAnswer = 1.0f;

	return 1.0f-FinalAnswer;	
}
		  
function float Get_A_Modifier(float CurrentHP , float MaxHP,optional float AimRange)
{
	local float Result;
	local float X,temp;

	if(!b_UseGaussianEquasion)
	{
		X=ABS((CurrentHP/MaxHP));
		`log("RedFog X Calc: "@X,,'Second Wave Plus-Red Fog');
		Result=0.7f*X;
		`log("RedFog Res1 Calc: "@Result,,'Second Wave Plus-Red Fog');
		Result=Result+0.3f;
		 Result=FMax(Result,0.000001f);
		 `log("RedFog A Calc: "@Result,,'Second Wave Plus-Red Fog');
		`log("HP: " @MaxHP @" " @CurrentHP,,'Second Wave Plus-Red Fog');
	}

	else
	{
		X=ABS((CurrentHP/MaxHP));
		`log("RedFog Gaus X Calc: "@X,,'Second Wave Plus-Red Fog');
		temp=(AimRange+0.3475);
		`log("RedFog Gaus Temp Calc: "@temp,,'Second Wave Plus-Red Fog');
		Result=	(X-1)*(X-1);
		Result=Result*-1.0f;
		`log("RedFog Gaus res1 Calc: "@Result,,'Second Wave Plus-Red Fog');
		Result=Result/(2.0f*(temp*temp));
		`log("RedFog Gaus res2 Calc: "@Result,,'Second Wave Plus-Red Fog');
		Result=EXP(Result);
		`log("RedFog A Res Gaussian Calc: "@Result,,'Second Wave Plus-Red Fog');
	}

	Result=FMax(Result,0.000001f);
	return 	Result;
}
function float Get_B_Modifier(float CurrentHP , float MaxHP,optional float MobilityRange)
{
	local float Result;
	local float X,temp;

    if(!b_UseGaussianEquasion)
	{
		X=ABS((CurrentHP/MaxHP));
		`log("RedFog Mob X Calc: "@X,,'Second Wave Plus-Red Fog');
		Result=0.3f*X;
		`log("RedFog Mob Res1 Calc: "@Result,,'Second Wave Plus-Red Fog');
		Result=0.7f+Result;															
		`log("RedFog B Res Calc: "@Result,,'Second Wave Plus-Red Fog');
		`log("HP: " @MaxHP @" " @CurrentHP,,'Second Wave Plus-Red Fog');
	}
	else
	{
		X=ABS((CurrentHP/MaxHP));
		`log("RedFog Gaus X Calc: "@X,,'Second Wave Plus-Red Fog');
		temp=(2.185-(0.9-MobilityRange)*5);
		`log("RedFog Gaus Temp Calc: "@temp,,'Second Wave Plus-Red Fog');
		Result=	(X-1)*(X-1);
		Result=Result*-1.0f;
		`log("RedFog Gaus res1 Calc: "@Result,,'Second Wave Plus-Red Fog');
		Result=Result/(2.0f*(temp*temp));
		`log("RedFog Gaus res2 Calc: "@Result,,'Second Wave Plus-Red Fog');
		Result=EXP(Result);
		`log("RedFog B Res Gaussian Calc: "@Result,,'Second Wave Plus-Red Fog');
	}

	Result=FMax(Result,0.000001f);
	return 	Result;
}
function float Get_C_Modifier(float CurrentHP , float MaxHP,optional float WillRange)
{
	local float Result;
	local float X,temp;

	if(!b_UseGaussianEquasion)
	{
		X=ABS((CurrentHP/MaxHP));
		`log("RedFog Will X Calc: "@X,,'Second Wave Plus-Red Fog');
		Result=0.5f*X;
		`log("RedFog Will Res1 Calc: "@Result,,'Second Wave Plus-Red Fog');
		Result=0.5f+Result;
		 Result=FMax(Result,0.000001f);
		`log("RedFog C Res Calc: "@Result,,'Second Wave Plus-Red Fog');
		`log("HP: " @MaxHP @" " @CurrentHP,,'Second Wave Plus-Red Fog');
	}
	else
	{
		X=ABS((CurrentHP/MaxHP));
		`log("RedFog Gaus X Calc: "@X,,'Second Wave Plus-Red Fog');
		temp=WillRange/(0.588+(0.11*(0.5-WillRange)));
		`log("RedFog Gaus Temp Calc: "@temp,,'Second Wave Plus-Red Fog');
		Result=	(X-1)*(X-1);
		Result=Result*-1.0f;
		`log("RedFog Gaus res1 Calc: "@Result,,'Second Wave Plus-Red Fog');
		Result=Result/(2.0f*(temp*temp));
		`log("RedFog Gaus res2 Calc: "@Result,,'Second Wave Plus-Red Fog');
		Result=EXP(Result);
		`log("RedFog C Res Gaussian Calc: "@Result,,'Second Wave Plus-Red Fog');
	}

	Result=FMax(Result,0.000001f);
	return 	Result;
}

function SubmitGameState(out XComGameState NewGameState)
{
	local X2TacticalGameRuleset TacticalRules;
	local XComGameStateHistory History;

	if (NewGameState.GetNumGameStateObjects() > 0)
	{
		History = `XCOMHISTORY;
		History.AddGameStateToHistory(NewGameState);
	}
	else
	{
		History = `XCOMHISTORY;
		History.CleanupPendingGameState(NewGameState);
	}
}