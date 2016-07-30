// This is an Unreal Script
                           
class SecondWave_X2SoldierClassTemplate_Helper extends X2SoldierClassTemplate;

static function array<SoldierClassRank> GetSoldierRanks(X2SoldierClassTemplate Template)
{
	local int i;
	local array<SoldierClassRank> RetSoldierRanks;
	RetSoldierRanks=Template.SoldierRanks;
	for(i=0;i<RetSoldierRanks.Length;i++)
	{
		RetSoldierRanks[i].aAbilityTree.Length=0;
	}
	return RetSoldierRanks;	
}