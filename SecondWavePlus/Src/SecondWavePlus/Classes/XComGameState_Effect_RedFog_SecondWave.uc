// This is an Unreal Script
                           
class XComGameState_Effect_RedFog_SecondWave extends SecondWave_GameStateParent config(SecondWavePlus_Settings);

var config bool b_IsRedFogActive;
var config bool b_IsRedFogActive_Aliens;
var config bool b_IsRedFogActive_XCom;
var config bool b_IsRedFogActive_Robotics;
var config bool b_UseGaussianEquasion;

var config array<RedFogFormulatType> FTypeRF;
var array<RedFogFormulatType> FTypeRF_Persistent;
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
	foreach FTypeRF(FTypeLocal)
	{
		if(FTypeLocal.StatType==eStat_Offense||FTypeLocal.StatType==eStat_PsiOffense)
			return;

		PCSRF.Add(1);
		PCSRF[PCSRF.length-1].StatType=FTypeLocal.StatType;
		PCSRF[PCSRF.length-1].BaseStat=TargetUnit.GetBaseStat(FTypeLocal.StatType);
		PCSRF[PCSRF.length-1].MaxStat=TargetUnit.GetMaxStat(FTypeLocal.StatType);
		PCSRF[PCSRF.length-1].CurrentStat=TargetUnit.GetCurrentStat(FTypeLocal.StatType);
	}
	MyUnitRef=TargetUnit.GetReference();
}
function EventListenerReturn RedFogCleanup(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
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
        `GAMERULES.SubmitGameState(NewGameState);
    else
        History.CleanupPendingGameState(NewGameState);

	
	return ELR_NoInterrupt;
}
function EventListenerReturn UpdateRedFog(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
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
	if(UpdatedUnitState.GetTeam()==eTeam_Alien && !b_IsRedFogActive_Aliens)
	{
		UpdatedRFState.GetRedFogStatChanges(UpdatedUnitState, NewGameState);
		return ELR_NoInterrupt;
	}
	if(UpdatedUnitState.GetTeam()==eTeam_XCOM && !b_IsRedFogActive_XCom)
	{
		UpdatedRFState.GetRedFogStatChanges(UpdatedUnitState, NewGameState);
		return ELR_NoInterrupt;
	}
	if(UpdatedUnitState.IsRobotic() && !b_IsRedFogActive_Robotics)
	{
		UpdatedRFState.GetRedFogStatChanges(UpdatedUnitState, NewGameState);
		return ELR_NoInterrupt;
	}
	UpdatedRFState.GetRedFogStatChanges(UpdatedUnitState, NewGameState,true);
	SubmitGameState(NewGameState);
	return ELR_NoInterrupt;
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

function GetRedFogStatChanges(XComGameState_Unit Unit, XComGameState GameState,Optional bool Active=false)
{
	local XComGameState_Effect	OwningEffect;
	local array<StatChange>		StatChanges;
	local StatChange			NewChange;
	local RedFogFormulatType	FTypeLocal;

	OwningEffect=GetOwner(GameState);
	OwningEffect = XComGameState_Effect(GameState.CreateStateObject(OwningEffect.Class, OwningEffect.ObjectID));
	GameState.AddStateObject(OwningEffect);
	Unit.UnApplyEffectFromStats(OwningEffect, GameState);
	if(!Active)
		return;

	StatChanges.Length=0;
	foreach FTypeRF(FTypeLocal)
	{
		NewChange.StatType=FTypeLocal.StatType;
		NewChange.StatAmount=GetStatMultiplier(FTypeLocal,Unit.GetCurrentStat(eStat_HP),Unit.GetBaseStat(eStat_HP));
		NewChange.ModOp=MODOP_Multiplication;
		`log("Unit: "@Unit.GetFullName() @FTypeLocal.StatType $": " $Unit.GetMaxStat(FTypeLocal.StatType)*(1+GetStatMultiplier(FTypeLocal,Unit.GetCurrentStat(eStat_HP),Unit.GetBaseStat(eStat_HP))));

		if(FTypeLocal.StatType==eStat_Offense || FTypeLocal.StatType==eStat_PsiOffense)StatChanges.AddItem(NewChange);
		else
			Unit.SetCurrentStat(FTypeLocal.StatType,Unit.GetMaxStat(FTypeLocal.StatType)*(1+GetStatMultiplier(FTypeLocal,Unit.GetCurrentStat(eStat_HP),Unit.GetBaseStat(eStat_HP))));
	}
	OwningEffect.StatChanges = StatChanges;
	Unit.ApplyEffectToStats(OwningEffect, GameState);

}

function float GetStatMultiplier(RedFogFormulatType FTypeLocal, float CurrentHP , float MaxHP)
{
	local float FinalAnswer;

	if(CurrentHP>=MaxHP)
		return 1.0f;
	if(CurrentHP<=0)
		return 0.000001f;

	switch (FTypeLocal.RedFogCalcType)
	{
		case 0:
			FinalAnswer= Get_A_Modifier(CurrentHP,MaxHP,FTypeLocal.Range);
			Break;

		case 1:
			FinalAnswer= Get_B_Modifier(CurrentHP,MaxHP,FTypeLocal.Range);
			Break;

		case 2:
			FinalAnswer= Get_C_Modifier(CurrentHP,MaxHP,FTypeLocal.Range);
			Break;
		default:
			FinalAnswer=1.0f;
			Break;	
	}
	return (1-FinalAnswer)*-1;	
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
		TacticalRules = `TACTICALRULES;
		TacticalRules.SubmitGameState(NewGameState);
	}
	else
	{
		History = `XCOMHISTORY;
		History.CleanupPendingGameState(NewGameState);
	}
}