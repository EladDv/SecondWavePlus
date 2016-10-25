// This is an Unreal Script
                           
class SecondWave_GameStateParent extends XComGameState_BaseObject;

struct NCE_StatModifiers
{
	var ECharStatType StatType;
	var  int Stat_Range;
	var  int Stat_Min;
	var  int Stat_Cost;
};

struct Epigenetics_BaseStats
{
	var ECharStatType StatType;
	var int Stat;	
};

struct RedFogFormulatType
{
	var ECharStatType StatType;
	var int RedFogCalcType; //0=Aim-like Calc, 1=Mobility-Like Calc, 2=Will-like Calc
	var float Range;
};

struct HiddenPotentialStatChanges
{
	var ECharStatType StatType;
	var int Change;	
};
struct HiddenPotentialLevelChanges
{
	var int Level;	
	var array<HiddenPotentialStatChanges> StatChanges;
};

struct UIRanges
{
	var ECharStatType StatType;	
	var float Range;	
	var float Min;	
	var float Cost;	
	var int	RangeSteps;
	var int	MinSteps;
	var int	CostSteps;
};

function int GetRandomSign()
{
	local int i;
	i=Rand(10);
	//`log ("got a random"@i);
	if(i%2==0)
		i=-1;
	else 
		i=1;
	return i;
}