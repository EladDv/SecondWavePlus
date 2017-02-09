// This is an Unreal Script
                           
Class SecondWave_Epigenetics_GameState extends SecondWave_GameStateParent config(SecondWavePlus_Settings);

var config bool bIs_Epigenetics_Activated;
var config bool bIs_EpigeneticsRobotics_Activated;

var config array<NCE_StatModifiers> EpigeneticsStatModifiers;
var config array<Epigenetics_BaseStats> EpigeneticsBaseStats;
var config array<string> ExcludeUnitFromFillingHP; 
var config array<string> ExcludeUnitFromEpigenetics; 
var config int TotalPoints_Enemy;
var config int Tolerance_Enemy;

function ObtainOptions()
{
	local SecondWave_OptionsDataStore SWDataStore;
	SWDataStore=class'SecondWave_OptionsDataStore'.static.GetInstance();	

	bIs_Epigenetics_Activated=SWDataStore.GetValues("bIs_Epigenetics_Activated").Bool_Value;
	bIs_EpigeneticsRobotics_Activated=SWDataStore.GetValues("bIs_EpigeneticsRobotics_Activated").Bool_Value;
	TotalPoints_Enemy=SWDataStore.GetValues("TotalPoints_Enemy").Int_Value;
	Tolerance_Enemy=SWDataStore.GetValues("Tolerance_Enemy").Int_Value;
	EpigeneticsStatModifiers=SWDataStore.SavedEpigeneticsItems;

}

function int GetBaseModifiers(ECharStatType StatT)
{
	local int ReturnStat;
		
	ReturnStat= EpigeneticsBaseStats[EpigeneticsBaseStats.Find('StatType',StatT)].Stat;
/*	ToRet.AddItem(8);	
	ToRet.AddItem(80);	
	ToRet.AddItem(10);	
	ToRet.AddItem(12);	
	ToRet.AddItem(50);	
	ToRet.AddItem(20);	
	ToRet.AddItem(1);	
	ToRet.AddItem(27);	
	ToRet.AddItem(120);
	ToRet.AddItem(33);*/
	return ReturnStat;	
}

function bool RandomEnemyStats(XComGameState_Unit Unit)
{
	local int TotalCost,j,currentStat,CodexHPSave;
	local array<int> RandomStats;

	if(Unit.GetMaxStat(eStat_BackpackSize)==10 ||Unit.GetBaseStat(eStat_BackpackSize)==10 ||Unit.GetCurrentStat(eStat_BackpackSize)==10)
		return false;
	if(Unit.IsRobotic()||!bIs_EpigeneticsRobotics_Activated)
		return false;

	if(ExcludeUnitFromEpigenetics.Find(string(Unit.GetMyTemplateName()))!=-1)
		return false;
		       
	if(bIs_Epigenetics_Activated&&Unit.GetTeam()==ETeam_Alien) // Fix Alien Rulers, or just disable
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
		
		`log("New Enemy: " @Unit.GetMyTemplateName(),,'Second Wave Plus-Epigenetics');
		`log("New Enemy Cost"@TotalCost ,,'Second Wave Plus-Epigenetics');

		for(j=0;j<RandomStats.Length;j++)
		{
			CodexHPSave=-1;
			if((EpigeneticsStatModifiers[j].StatType==eStat_HP) &&(Unit.GetMyTemplate().CharacterGroupName =='Cyberus'||ExcludeUnitFromFillingHP.Find(string(Unit.GetMyTemplateName()))!=-1))
				CodexHPSave=Unit.GetCurrentStat(eStat_HP);

			Unit.setBaseMaxStat(EpigeneticsStatModifiers[j].StatType,Unit.GetMaxStat(EpigeneticsStatModifiers[j].StatType)+RandomStats[j]);
			
			if(CodexHPSave==-1)
				Unit.setCurrentStat(EpigeneticsStatModifiers[j].StatType,Unit.GetMaxStat(EpigeneticsStatModifiers[j].StatType));
			
			`log("New Enemy Stat"@EpigeneticsStatModifiers[j].StatType @"Max:"@Unit.GetMaxStat(EpigeneticsStatModifiers[j].StatType) @"Cost:"@(RandomStats[j]*EpigeneticsStatModifiers[j].Stat_Cost),,'Second Wave Plus-Epigenetics');
		}
		Unit.SetBaseMaxStat(eStat_BackpackSize,10);
		Unit.SetCurrentStat(eStat_BackpackSize,10);
		Unit.SetBaseMaxStat(eStat_ArmorChance,100.00f);
		Unit.SetCurrentStat(eStat_ArmorChance,100.00f);
		return true;
	}
	return false;
}


function float GetUnitStatModifier(XComGameState_Unit Unit,ECharStatType Stat)
{
	if(Unit.GetBaseStat(Stat)==0 && Stat==eStat_ArmorMitigation)
		return 1;
	return (Unit.GetBaseStat(Stat)/GetBaseModifiers(Stat));	
}

function int GetRandomStat(XComGameState_Unit Unit,NCE_StatModifiers StatMod)
{
	local int ReturnStat;
	local SecondWave_RandomizerActor RandActor;
	
	RandActor=`SCREENSTACK.GetCurrentScreen().Spawn(class'SecondWave_RandomizerActor',none);
	do
	{
		ReturnStat= RandActor.GetRandomStat(StatMod.Stat_Range,StatMod.Stat_Min);//	RAND(StatMod.Stat_Range+1)*GetRandomSign();
	}Until(ReturnStat>=StatMod.Stat_Min && 
	(Unit.GetMaxStat(StatMod.StatType)+Round(ReturnStat*GetUnitStatModifier(Unit,StatMod.StatType)))>=0 && 
	(StatMod.StatType!=eStat_Mobility||(Unit.GetMaxStat(StatMod.StatType)+Round(ReturnStat*GetUnitStatModifier(Unit,StatMod.StatType)))>=7));

	RandActor.Destroy();

	return Round(ReturnStat*GetUnitStatModifier(Unit,StatMod.StatType));
}