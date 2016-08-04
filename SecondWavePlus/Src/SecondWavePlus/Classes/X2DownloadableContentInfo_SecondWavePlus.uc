//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_SecondWavePlus.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_SecondWavePlus extends X2DownloadableContentInfo;



/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{
	local SecondWave_CommandersChoice_Actor		Main_CommandersChoice_Actor;
	local SecondWave_HiddenPotential_Actor		Main_HiddenPotential_Actor;
	local SecondWave_Epigenetics_Actor			Main_Epigenetics_Actor;
	local SecondWave_NotCreatedEqually_Actor	Main_NotCreatedEqually_Actor;
	local SecondWave_AbsolutlyCritical_Actor	Main_AbsolutlyCritical_Actor;
	local SecondWave_NewEconomy_Actor			Main_NewEconomy_Actor;
	local SecondWave_RedFog_Actor				Main_RedFog_Actor;
	local XComGameState StartState;

	StartState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Loading Data For New Campagin");
	Main_CommandersChoice_Actor=SecondWave_CommandersChoice_Actor(StartState.CreateStateObject(class'SecondWave_CommandersChoice_Actor'));
	Main_HiddenPotential_Actor=SecondWave_HiddenPotential_Actor(StartState.CreateStateObject(class'SecondWave_HiddenPotential_Actor'));
	Main_Epigenetics_Actor=SecondWave_Epigenetics_Actor(StartState.CreateStateObject(class'SecondWave_Epigenetics_Actor'));
	Main_NotCreatedEqually_Actor=SecondWave_NotCreatedEqually_Actor(StartState.CreateStateObject(class'SecondWave_NotCreatedEqually_Actor'));
	Main_AbsolutlyCritical_Actor=SecondWave_AbsolutlyCritical_Actor(StartState.CreateStateObject(class'SecondWave_AbsolutlyCritical_Actor'));
	Main_RedFog_Actor=SecondWave_RedFog_Actor(StartState.CreateStateObject(class'SecondWave_RedFog_Actor'));
	Main_NewEconomy_Actor=SecondWave_NewEconomy_Actor(StartState.CreateStateObject(class'SecondWave_NewEconomy_Actor'));

	StartState.AddStateObject(Main_CommandersChoice_Actor);
	StartState.AddStateObject(Main_HiddenPotential_Actor);
	StartState.AddStateObject(Main_Epigenetics_Actor);
	StartState.AddStateObject(Main_NotCreatedEqually_Actor);
	StartState.AddStateObject(Main_AbsolutlyCritical_Actor);
	StartState.AddStateObject(Main_NewEconomy_Actor);
	StartState.AddStateObject(Main_RedFog_Actor);
	`log("Starting New Campaign",,'Second Wave Plus');
	CheckForUnitComponents(StartState,Main_HiddenPotential_Actor,Main_NotCreatedEqually_Actor,Main_AbsolutlyCritical_Actor);
	Main_HiddenPotential_Actor.InitListeners();
	Main_NotCreatedEqually_Actor.InitListeners();	
	Main_RedFog_Actor.InitListeners();	
	Main_NewEconomy_Actor.CreateNewEconomy(StartState);
	if(StartState.GetNumGameStateObjects()>0)
		`XCOMHistory.AddGameStateToHistory(StartState);
	else
		`XCOMHistory.CleanupPendingGameState(StartState);	
}


/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{
	local SecondWave_CommandersChoice_Actor		Main_CommandersChoice_Actor;
	local SecondWave_HiddenPotential_Actor		Main_HiddenPotential_Actor;
	local SecondWave_Epigenetics_Actor			Main_Epigenetics_Actor;
	local SecondWave_NotCreatedEqually_Actor	Main_NotCreatedEqually_Actor;
	local SecondWave_AbsolutlyCritical_Actor	Main_AbsolutlyCritical_Actor;
	local SecondWave_NewEconomy_Actor			Main_NewEconomy_Actor;
	local SecondWave_RedFog_Actor				Main_RedFog_Actor;

	Main_CommandersChoice_Actor=SecondWave_CommandersChoice_Actor(StartState.CreateStateObject(class'SecondWave_CommandersChoice_Actor'));
	Main_HiddenPotential_Actor=SecondWave_HiddenPotential_Actor(StartState.CreateStateObject(class'SecondWave_HiddenPotential_Actor'));
	Main_Epigenetics_Actor=SecondWave_Epigenetics_Actor(StartState.CreateStateObject(class'SecondWave_Epigenetics_Actor'));
	Main_NotCreatedEqually_Actor=SecondWave_NotCreatedEqually_Actor(StartState.CreateStateObject(class'SecondWave_NotCreatedEqually_Actor'));
	Main_AbsolutlyCritical_Actor=SecondWave_AbsolutlyCritical_Actor(StartState.CreateStateObject(class'SecondWave_AbsolutlyCritical_Actor'));
	Main_RedFog_Actor=SecondWave_RedFog_Actor(StartState.CreateStateObject(class'SecondWave_RedFog_Actor'));
	Main_NewEconomy_Actor=SecondWave_NewEconomy_Actor(StartState.CreateStateObject(class'SecondWave_NewEconomy_Actor'));

	StartState.AddStateObject(Main_CommandersChoice_Actor);
	StartState.AddStateObject(Main_HiddenPotential_Actor);
	StartState.AddStateObject(Main_Epigenetics_Actor);
	StartState.AddStateObject(Main_NotCreatedEqually_Actor);
	StartState.AddStateObject(Main_AbsolutlyCritical_Actor);
	StartState.AddStateObject(Main_NewEconomy_Actor);
	StartState.AddStateObject(Main_RedFog_Actor);
	`log("Starting New Campaign",,'Second Wave Plus');
	CheckForUnitComponents(StartState,Main_HiddenPotential_Actor,Main_NotCreatedEqually_Actor,Main_AbsolutlyCritical_Actor);
	Main_HiddenPotential_Actor.InitListeners();
	Main_NotCreatedEqually_Actor.InitListeners();
	Main_RedFog_Actor.InitListeners();	
	Main_NewEconomy_Actor.CreateNewEconomy(StartState);

}

static function CheckForUnitComponents(XComGameState NewGameState,SecondWave_HiddenPotential_Actor HidPA,SecondWave_NotCreatedEqually_Actor NCEA,SecondWave_AbsolutlyCritical_Actor ACA,optional bool Submit=false)
{
	local XComGameState_Unit Unit;
	local XComGameState_SecondWavePlus_UnitComponent UnitComp;
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit',Unit)
	{
		`log("Starting New Campaign:"@Unit.IsSoldier(),,'Second Wave Plus');

		if(Unit.IsSoldier())
		{
			UnitComp=XComGameState_SecondWavePlus_UnitComponent(Unit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'));
			if(UnitComp==none)
			{
				UnitComp=XComGameState_SecondWavePlus_UnitComponent(NewGameState.CreateStateObject(class'XComGameState_SecondWavePlus_UnitComponent'));
				Unit.AddComponentObject(UnitComp);
				NewGameState.AddStateObject(UnitComp);
				NewGameState.AddStateObject(Unit);
				
			}
			else
			{
				if(NCEA.bIs_NCE_Activated)NCEA.RandomStats(Unit,NewGameState);
				if(ACA.bIs_AbsolutlyCritical_Activated)ACA.AddAbsolutlyCriticalToUnit(Unit,NewGameState);
				if(HidPA.bIs_HiddenPotential_Activated)HidPA.AddHiddenPotentialToUnit(Unit,NewGameState);
			}
		}
	}
	`log("Starting New Campaign",,'Second Wave Plus');
	if(Submit)
			`XCOMHISTORY.AddGameStateToHistory(NewGameState);	
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Unit',Unit)
	{
		if(Unit.IsSoldier())
		{
			UnitComp=XComGameState_SecondWavePlus_UnitComponent(Unit.FindComponentObject(class'XComGameState_SecondWavePlus_UnitComponent'));
			if(UnitComp!=none && UnitComp.OwningObjectId>0) UnitComp.SendEventsAfterInit(NewGameState);
		}
	}
}