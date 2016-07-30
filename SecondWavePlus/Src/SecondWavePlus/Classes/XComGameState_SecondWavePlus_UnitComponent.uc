// This is an Unreal Script
                           
class XComGameState_SecondWavePlus_UnitComponent extends XComGameState_BaseObject;

var protected bool b_HasGot_NotCreatedEqually;
var protected bool b_HasGot_CommandersChoiceVet;
var protected bool b_HasGot_HiddenPotential;

Struct HiddenPotentialStatChanges
{
	var ECharStatType StatType;
	var int Change;	
};
Struct HiddenPotentialLevelChanges
{
	var int Level;	
	var array<HiddenPotentialStatChanges> StatChanges;
};

var private array<HiddenPotentialLevelChanges> SavedLevelChanges;

public function SetHiddenPotentialLevelChanges(array<HiddenPotentialLevelChanges> LevelChanges)
{
	SavedLevelChanges=LevelChanges;
}
public function array<HiddenPotentialLevelChanges> GetSavedLevelChanges()
{		
	return SavedLevelChanges;	
}
public function HiddenPotentialLevelChanges GetSpecificLevelChanges(int i)
{		
	if(i!=-1 && i<SavedLevelChanges.Length)
		return SavedLevelChanges[i];	
}

public function SetHasGot_NotCreatedEqually (bool InBool)
{
	b_HasGot_NotCreatedEqually=InBool;	
}
public function SetHasGot_CommandersChoiceVet (bool InBool)
{
	b_HasGot_CommandersChoiceVet=InBool;	
}
public function SetHasGot_HiddenPotential (bool InBool)
{
	b_HasGot_HiddenPotential=InBool;	
}
public function GetHasGot_NotCreatedEqually ()
{
	return b_HasGot_NotCreatedEqually;	
}
public function GetHasGot_CommandersChoiceVet ()
{
	return b_HasGot_CommandersChoiceVet;	
}
public function GetHasGot_HiddenPotential ()
{
	return b_HasGot_HiddenPotential;	
}
