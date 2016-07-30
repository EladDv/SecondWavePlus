// This is an Unreal Script
                           
class XComGameState_SecondWavePlus_UnitComponent extends XComGameState_BaseObject;

var protected bool b_HasGot_NotCreatedEqually;
var protected bool b_HasGot_CommandersChoiceVet;
var protected bool b_HasGot_HiddenPotential;

var private SecondWave_HiddenPotentialStatHolder_Object HiddenPHolder;

public function SetHiddenPotentialLevelChanges(array<HiddenPotentialLevelChanges> LevelChanges)
{
	HiddenPHolder.SavedLevelChanges=LevelChanges;
}
public function array<HiddenPotentialLevelChanges> GetSavedLevelChanges()
{		
	return HiddenPHolder.SavedLevelChanges;	
}
public function SetHiddenPotentialHolder(SecondWave_HiddenPotentialStatHolder_Object Holder)
{		
	HiddenPHolder=holder;
	HiddenPHolder.SetOwningObjectID(self.ObjectID);
}
public function SecondWave_HiddenPotentialStatHolder_Object GetHiddenPotentialHolder()
{		
	return HiddenPHolder;	
}
public function HiddenPotentialLevelChanges GetSpecificLevelChanges(int i)
{		
	if(i!=-1 && i<HiddenPHolder.SavedLevelChanges.Length)
		return HiddenPHolder.SavedLevelChanges[i];	
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
	if(!Inbool)
	{
		HiddenPHolder.Destroy();
		
	}	
}
public function bool GetHasGot_NotCreatedEqually ()
{
	return b_HasGot_NotCreatedEqually;	
}
public function bool GetHasGot_CommandersChoiceVet ()
{
	return b_HasGot_CommandersChoiceVet;	
}
public function bool GetHasGot_HiddenPotential ()
{
	return b_HasGot_HiddenPotential;	
}
