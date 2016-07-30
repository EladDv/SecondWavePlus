// This is an Unreal Script
                           
Class SecondWave_Epigenetics_Object extends Object config(SecondWavePlus_Settings);

var config bool bIs_Epigenetics_Activated;

var config array<NCE_StatModifiers> EpigeneticsStatModifiers;
var config int TotalPoints_Enemy;
var config int Tolerance_Enemy;

function array<int>GetBaseModifiers()
{
	local array<int> ToRet;
	ToRet.AddItem(8);	
	ToRet.AddItem(80);	
	ToRet.AddItem(10);	
	ToRet.AddItem(12);	
	ToRet.AddItem(50);	
	ToRet.AddItem(20);	
	ToRet.AddItem(1);	
	ToRet.AddItem(27);	
	ToRet.AddItem(120);
	ToRet.AddItem(33);
	return ToRet;	
}

function RandomEnemyStats(XComGameState_Unit Unit)
{
	local int TotalCost,j,currentStat;
	local array<int> RandomStats;
	if(bIs_NCE_Activated&&Unit.IsSoldier()&&Unit.GetTeam()==ETeam_XCom)
	{
		do
		{
			TotalCost=0;
			RandomStats.Length=0;
			for(j=0;j<EpigeneticsStatModifiers.Length;j++)
			{
				currentStat=GetRandomStat(Unit,EpigeneticsStatModifiers[j]);
				RandomStats.AddItem(currentStat);
				TotalCost+=(currentStat*EpigeneticsStatModifiers[j].Stat_Cost);
			}
		}Until(Abs(TotalCost-TotalPoints_Enemy)<=Tolerance_Enemy);
	}
	`log("New Enemy Cost"@TotalCost,,'Second Wave Plus-Epigenetics');

	for(j=0;j<RandomStats.Length;j++)
	{
		Unit.setBaseMaxStat(EpigeneticsStatModifiers[j].StatType,Unit.GetMaxStat(EpigeneticsStatModifiers[j].StatType)+RandomStats[j]);
		Unit.setCurrentStat(EpigeneticsStatModifiers[j].StatType,Unit.GetMaxStat(EpigeneticsStatModifiers[j].StatType)+RandomStats[j]);
		`log("New Enemy Stat"@EpigeneticsStatModifiers[j].StatType @Unit.GetMaxStat(EpigeneticsStatModifiers[j].StatType),,'Second Wave Plus-Epigenetics');
	}
	Unit.setBaseMaxStat(eStat_ArmorChance,100.00f);
	Unit.setCurrentStat(eStat_ArmorChance,100.00f);
}

function int GetRandomSign()
{
	local int i;
	i=Rand(2);
	//`log ("got a random"@i);
	if(i==0)
		i=-1;
	return i;
}
function float GetUnitStatModifier(XComGameState_Unit Unit,ECharStatType Stat)
{
	
	local array<int> BaseStats;
	BaseStats=GetBaseModifiers();
	if(Stat==eStat_HP)
		return (Unit.GetBaseStat(Stat)/BaseStats[0]);
	else if(Stat==eStat_Offense)
		return (Unit.GetBaseStat(Stat)/BaseStats[1]);
	else if(Stat==eStat_Defense)
		return (Unit.GetBaseStat(Stat)/BaseStats[2]);
	else if(Stat==eStat_Mobility)
		return (Unit.GetBaseStat(Stat)/BaseStats[3]);
	else if(Stat==eStat_Will)
		return (Unit.GetBaseStat(Stat)/BaseStats[4]);
	else if(Stat==eStat_Dodge)
		return (Unit.GetBaseStat(Stat)/BaseStats[5]);
	else if(Stat==eStat_ArmorMitigation)
		return (Unit.GetBaseStat(Stat)/BaseStats[6]);
	else if(Stat==eStat_SightRadius)
		return (Unit.GetBaseStat(Stat)/BaseStats[7]);
	else if(Stat==eStat_PsiOffense)
		return (Unit.GetBaseStat(Stat)/BaseStats[8]);
	else if(Stat==eStat_FlankingCritChance)
		return (Unit.GetBaseStat(Stat)/BaseStats[9]);
	else 
		return 1;
	
}

function int GetRandomStat(XComGameState_Unit Unit,NCE_StatModifiers StatMod)
{
	local int ReturnStat,TempHolder;
	do
	{
		ReturnStat=	`SYNC_RAND(StatMod.Stat_Range)*GetRandomSign();
	}Until(ReturnStat>=StatMod.Stat_Min);
	return Round(ReturnStat*GetUnitStatModifier(Unit,StatMod.StatType));
}