// This is an Unreal Script
                           
class SecondWave_NotCreatedEqually_Object extends Object config(SecondWavePlus_Settings);

var config bool bIs_NCE_Activated;
struct NCE_StatModifiers
{
	var ECharStatType StatType;
	var  int Stat_Range;
	var  int Stat_Min;
	var  int Stat_Cost;
};
var config int TotalPoints_XCom;
var config int Tolerance_XCom;
var config array<NCE_StatModifiers> NCEStatModifiers;

function int GetRandomStat(int StatRange,int StatMin)
{
	local int Sign,ReturnInt;
	Sign=`SYNC_RAND(1);
	if(Sign==0)
	 Sign=-1;
	do
	{
		ReturnInt= `SYNC_RAND(StatRange) * Sign;		
	}Until(ReturnInt>=StatMin);
	return ReturnInt;
}
function RandomStats(XComGameState_Unit Unit,Optional XComGameState NewGameState)
{
	local int TotalCost,j,currentStat;
	local XComGameState_SecondWavePlus_UnitComponent SW_UnitComponent;
	local array<int> RandomStats;

	SW_UnitComponent=XComGameState_SecondWavePlus_UnitComponent(Unit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'));
	if(bIs_NCE_Activated&&Unit.IsSoldier()&&Unit.GetTeam()==ETeam_XCom && SW_UnitComponent!=none && !SW_UnitComponent.GetHasGot_NotCreatedEqually())
	{
		do
		{
			TotalCost=0;
			RandomStats.Length=0;
			for(j=0;j<NCEStatModifiers.Length;j++)
			{
				currentStat=GetRandomStat(NCEStatModifiers[j].Stat_Range,NCEStatModifiers[j].Stat_Min);
				RandomStats.AddItem(currentStat);
				TotalCost+=(currentStat*NCEStatModifiers[j].Stat_Cost);
			}
		}Until(Abs(TotalCost-TotalPoints_XCom)<=Tolerance_XCom);
	
		`log("New XCom Cost"@TotalCost,,'Second Wave Plus-NCE');
		for(j=0;j<RandomStats.Length;j++)
		{
			Unit.setBaseMaxStat(NCEStatModifiers[j].StatType,Unit.GetMaxStat(NCEStatModifiers[j].StatType)+RandomStats[j]);
			Unit.setCurrentStat(NCEStatModifiers[j].StatType,Unit.GetMaxStat(NCEStatModifiers[j].StatType)+RandomStats[j]);
			`log("New XCom Stat"@NCEStatModifiers[j].StatType @Unit.GetMaxStat(NCEStatModifiers[j].StatType),,'Second Wave Plus-NCE');

		}
		Unit.setBaseMaxStat(eStat_ArmorChance,100.00f);
		Unit.setCurrentStat(eStat_ArmorChance,100.00f);
		SW_UnitComponent.SetHasGot_NotCreatedEqually(True);
		NewGameState.AddStateObject(SW_UnitComponent);
		NewGameState.AddStateObject(Unit);
	}
}