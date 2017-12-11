// This is an Unreal Script
                           
class SecondWave_OptionsDataStore extends UIDataStore dependson(SecondWave_GameStateParent);

Struct SecondWaveOptions
{
	var string Option;
	var int		Int_Value;	
	var bool	Bool_Value;	
	var float	Float_Value;	
	var string	String_Value;	
};

var array<SecondWaveOptions> SavedOptions;

var array<RedFogFormulatType> SavedRedFogTypes;

var array<UIRanges> StatChangesRanges;
var array<UIRanges> RedFogChangeRanges;

var array<NCE_StatModifiers> SavedNCEItems;
var array<NCE_StatModifiers> SavedEpigeneticsItems;

public function SecondWaveOptions GetValues(string OptionName)
{	
	local int i;
	local SecondWaveOptions ToRet;
	i=SavedOptions.Find('Option',OptionName);
	if(i!=-1)
		return SavedOptions[i];

	return ToRet;
}

public function bool SetValues(string OptionName,int type=-1,optional int inInt ,optional bool inBool , optional float inFloat, optional string inString )
{	
	local int i;
	i=SavedOptions.Find('Option',OptionName);
	if(i!=-1 && type!=-1)
	{
		switch (type)
		{
			case 0:
				SavedOptions[i].Int_Value=inInt;
				break;		
			case 1:
				SavedOptions[i].Bool_Value=inBool;
				break;		
			case 2:
				SavedOptions[i].Float_Value=inFloat;
				break;		
			case 3:
				SavedOptions[i].String_Value=inString;
				break;		

		}
		return true;
	}
	return false;
}

public function AddOption(string OptionName,int type=-1,optional int inInt ,optional bool inBool , optional float inFloat, optional string inString )
{	
	local SecondWaveOptions NewOption;
	NewOption.Option=OptionName;

	if(type!=-1)
	{
		switch (type)
		{
			case 0:
				`log("SAVED:" @OptionName @", value is:"@inInt);
				NewOption.Int_Value=inInt;
				break;		
			case 1:
				`log("SAVED:" @OptionName @", value is:"@inBool);
				NewOption.Bool_Value=inBool;
				break;		
			case 2:
				`log("SAVED:" @OptionName @", value is:"@inFloat);
				NewOption.Float_Value=inFloat;
				break;		
			case 3:
				`log("SAVED:" @OptionName @", value is:"@inString);
				NewOption.String_Value=inString;	
				break;		
		}
	}
	if(SavedOptions.find('Option',OptionName) == -1)
		SavedOptions.AddItem(NewOption);
	else
		SavedOptions[SavedOptions.find('Option',OptionName)] = NewOption;
}

public static function SecondWave_OptionsDataStore GetInstance() 
{
    local SecondWave_OptionsDataStore instance;
    local DataStoreClient dataStoreManager;

    dataStoreManager = class'UIInteraction'.static.GetDataStoreClient();

    instance = SecondWave_OptionsDataStore( dataStoreManager.FindDataStore( class'SecondWave_OptionsDataStore'.default.Tag ) );
    
    if( instance == none ) 
	{
        instance = dataStoreManager.CreateDataStore( class'SecondWave_OptionsDataStore' );
        dataStoreManager.RegisterDataStore(instance);
    }
    return instance;
}

public function Check()
{
	`log("SavedOptions Length:"@SavedOptions.Length );
	`log("SavedNCEItems Length:"@SavedNCEItems.Length );
	`log("SavedEpigeneticsItems Length:"@SavedEpigeneticsItems.Length );
	`log("RedFogChangeRanges Length:"@RedFogChangeRanges.Length );
	`log("StatChangesRanges Length:"@StatChangesRanges.Length );
	`log("SavedRedFogTypes Length:"@SavedRedFogTypes.Length );
}

DefaultProperties
{
    Tag=Dragonpunk_SecondWavePlus
}
