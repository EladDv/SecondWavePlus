// This is an Unreal Script
                           
class SecondWave_ActorParent extends Actor;

struct NCE_StatModifiers
{
	var ECharStatType StatType;
	var  int Stat_Range;
	var  int Stat_Min;
	var  int Stat_Cost;
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