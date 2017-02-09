// This is an Unreal Script

Class X2Effect_RedFogStats_SecondWave extends X2Effect_PersistentStatChange dependson(SecondWave_GameStateParent) config(SecondWavePlus_Settings);

var config bool b_IsRedFogActive;
var config bool b_IsRedFogActive_Aliens;
var config bool b_IsRedFogActive_Advent;
var config bool b_IsRedFogActive_XCom;
var config bool b_IsRedFogActive_Robotics;
var config bool b_UseGaussianEquasion;

var config array<RedFogFormulatType> FTypeRF;

simulated function AddRedFogStatChange(ECharStatType StatType,XComGameState_Unit Unit, optional EStatModOp InModOp=MODOP_Addition)
{
	local StatChange NewChange;
	local int Found;

	Found=FTypeRF.find('StatType',StatType);
	if(Found==INDEX_NONE)
		return;

	NewChange.StatType = StatType;
	NewChange.StatAmount =Unit.GetMaxStat(StatType)*GetStatMultiplier(FTypeRF[Found],Unit.GetCurrentStat(eStat_HP),Unit.GetMaxStat(eStat_HP));
	NewChange.ModOp = InModOp;

	m_aStatChanges.AddItem(NewChange);
}

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ShotInfo;
	local int Found;

	Found=m_aStatChanges.Find('StatType',eStat_Offense);
	if(Found != -1)
	{
		ShotInfo.ModType = eHit_Success;
		ShotInfo.Reason = "SWP Red Fog";
		ShotInfo.Value =m_aStatChanges[Found].StatAmount;
		ShotModifiers.AddItem(ShotInfo);
	}
}

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local RedFogFormulatType LocalRF;
	m_aStatChanges.Length=0;
	foreach FTypeRF(LocalRF)
	{	
		AddRedFogStatChange(LocalRF.StatType,XComGameState_Unit(kNewTargetState));
	}
	NewEffectState.StatChanges = m_aStatChanges;
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}


function float GetStatMultiplier(RedFogFormulatType FTypeLocal, float CurrentHP , float MaxHP)
{
	local float FinalAnswer;

	if(CurrentHP>=MaxHP)
		return 0.0f;
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

defaultproperties
{
    DuplicateResponse=eDupe_Ignore
	EffectName="RedFog_SecondWavePlus_StatsChange";
	bRemoveWhenSourceDies=true;
}