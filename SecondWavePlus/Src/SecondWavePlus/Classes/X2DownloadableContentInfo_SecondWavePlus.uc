//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_SecondWavePlus.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_SecondWavePlus extends X2DownloadableContentInfo dependson(SecondWave_GameStateParent);



/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{
	local UIScreen_SecondWaveOptions UISWOScreen;

	UISWOScreen= `SCREENSTACK.GetCurrentScreen().Spawn(Class'UIScreen_SecondWaveOptions',none);
	`SCREENSTACK.Push(UISWOScreen);
	UISWOScreen.CreateScreen();
	UISWOScreen.LargeB.OnClickedDelegate=OnContinueButton;		
	UISWOScreen.LargeB.OnDoubleClickedDelegate=OnContinueButton;
}

simulated public function OnContinueButton(UIButton Button)
{
	local SecondWave_CommandersChoice_GameState		Main_CommandersChoice_GameState;
	local SecondWave_HiddenPotential_GameState		Main_HiddenPotential_GameState;
	local SecondWave_Epigenetics_GameState			Main_Epigenetics_GameState;
	local SecondWave_NotCreatedEqually_GameState	Main_NotCreatedEqually_GameState;
	local SecondWave_AbsolutlyCritical_GameState	Main_AbsolutlyCritical_GameState;
	local SecondWave_NewEconomy_GameState			Main_NewEconomy_GameState;
	local SecondWave_RedFog_GameState				Main_RedFog_GameState;
	local SecondWave_UIScreenSettings_GameState		Main_ScreenSettings_GameState;
	local XComGameState StartState;


	UIScreen_SecondWaveOptions(`SCREENSTACK.GetFirstInstanceOf(class'UIScreen_SecondWaveOptions')).ContinueButton(Button);

	StartState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Loading Data For New Campagin");
	Main_CommandersChoice_GameState=SecondWave_CommandersChoice_GameState(StartState.CreateStateObject(class'SecondWave_CommandersChoice_GameState'));
	Main_HiddenPotential_GameState=SecondWave_HiddenPotential_GameState(StartState.CreateStateObject(class'SecondWave_HiddenPotential_GameState'));
	Main_Epigenetics_GameState=SecondWave_Epigenetics_GameState(StartState.CreateStateObject(class'SecondWave_Epigenetics_GameState'));
	Main_NotCreatedEqually_GameState=SecondWave_NotCreatedEqually_GameState(StartState.CreateStateObject(class'SecondWave_NotCreatedEqually_GameState'));
	Main_AbsolutlyCritical_GameState=SecondWave_AbsolutlyCritical_GameState(StartState.CreateStateObject(class'SecondWave_AbsolutlyCritical_GameState'));
	Main_RedFog_GameState=SecondWave_RedFog_GameState(StartState.CreateStateObject(class'SecondWave_RedFog_GameState'));
	Main_NewEconomy_GameState=SecondWave_NewEconomy_GameState(StartState.CreateStateObject(class'SecondWave_NewEconomy_GameState'));
	Main_ScreenSettings_GameState=SecondWave_UIScreenSettings_GameState(StartState.CreateStateObject(class'SecondWave_UIScreenSettings_GameState'));

	StartState.AddStateObject(Main_CommandersChoice_GameState);
	StartState.AddStateObject(Main_HiddenPotential_GameState);
	StartState.AddStateObject(Main_Epigenetics_GameState);
	StartState.AddStateObject(Main_NotCreatedEqually_GameState);
	StartState.AddStateObject(Main_AbsolutlyCritical_GameState);
	StartState.AddStateObject(Main_NewEconomy_GameState);
	StartState.AddStateObject(Main_RedFog_GameState);
	StartState.AddStateObject(Main_ScreenSettings_GameState);

	Main_CommandersChoice_GameState.ObtainOptions();
	Main_HiddenPotential_GameState.ObtainOptions();
	Main_Epigenetics_GameState.ObtainOptions();
	Main_NotCreatedEqually_GameState.ObtainOptions();
	Main_AbsolutlyCritical_GameState.ObtainOptions();
	Main_RedFog_GameState.ObtainOptions();
	Main_NewEconomy_GameState.ObtainOptions();
	Main_ScreenSettings_GameState.ObtainOptions();

	`log("Grabbing New Options On Old Campaign",,'Second Wave Plus');
	CheckForUnitComponents(StartState,Main_HiddenPotential_GameState,Main_NotCreatedEqually_GameState,Main_AbsolutlyCritical_GameState);
	Main_HiddenPotential_GameState.InitListeners();
	Main_NotCreatedEqually_GameState.InitListeners();	
	Main_RedFog_GameState.InitListeners();	
	Main_NewEconomy_GameState.CreateNewEconomy(StartState);

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
	local SecondWave_CommandersChoice_GameState		Main_CommandersChoice_GameState;
	local SecondWave_HiddenPotential_GameState		Main_HiddenPotential_GameState;
	local SecondWave_Epigenetics_GameState			Main_Epigenetics_GameState;
	local SecondWave_NotCreatedEqually_GameState	Main_NotCreatedEqually_GameState;
	local SecondWave_AbsolutlyCritical_GameState	Main_AbsolutlyCritical_GameState;
	local SecondWave_NewEconomy_GameState			Main_NewEconomy_GameState;
	local SecondWave_RedFog_GameState				Main_RedFog_GameState;
	local SecondWave_UIScreenSettings_GameState		Main_ScreenSettings_GameState;

	Main_CommandersChoice_GameState=SecondWave_CommandersChoice_GameState(StartState.CreateStateObject(class'SecondWave_CommandersChoice_GameState'));
	Main_HiddenPotential_GameState=SecondWave_HiddenPotential_GameState(StartState.CreateStateObject(class'SecondWave_HiddenPotential_GameState'));
	Main_Epigenetics_GameState=SecondWave_Epigenetics_GameState(StartState.CreateStateObject(class'SecondWave_Epigenetics_GameState'));
	Main_NotCreatedEqually_GameState=SecondWave_NotCreatedEqually_GameState(StartState.CreateStateObject(class'SecondWave_NotCreatedEqually_GameState'));
	Main_AbsolutlyCritical_GameState=SecondWave_AbsolutlyCritical_GameState(StartState.CreateStateObject(class'SecondWave_AbsolutlyCritical_GameState'));
	Main_RedFog_GameState=SecondWave_RedFog_GameState(StartState.CreateStateObject(class'SecondWave_RedFog_GameState'));
	Main_NewEconomy_GameState=SecondWave_NewEconomy_GameState(StartState.CreateStateObject(class'SecondWave_NewEconomy_GameState'));
	Main_ScreenSettings_GameState=SecondWave_UIScreenSettings_GameState(StartState.CreateStateObject(class'SecondWave_UIScreenSettings_GameState'));

	StartState.AddStateObject(Main_CommandersChoice_GameState);
	StartState.AddStateObject(Main_HiddenPotential_GameState);
	StartState.AddStateObject(Main_Epigenetics_GameState);
	StartState.AddStateObject(Main_NotCreatedEqually_GameState);
	StartState.AddStateObject(Main_AbsolutlyCritical_GameState);
	StartState.AddStateObject(Main_NewEconomy_GameState);
	StartState.AddStateObject(Main_RedFog_GameState);
	StartState.AddStateObject(Main_ScreenSettings_GameState);
	
	Main_CommandersChoice_GameState.ObtainOptions();
	Main_HiddenPotential_GameState.ObtainOptions();
	Main_Epigenetics_GameState.ObtainOptions();
	Main_NotCreatedEqually_GameState.ObtainOptions();
	Main_AbsolutlyCritical_GameState.ObtainOptions();
	Main_RedFog_GameState.ObtainOptions();
	Main_NewEconomy_GameState.ObtainOptions();
	Main_ScreenSettings_GameState.ObtainOptions();

	`log("Starting New Campaign",,'Second Wave Plus');
	CheckForUnitComponents(StartState,Main_HiddenPotential_GameState,Main_NotCreatedEqually_GameState,Main_AbsolutlyCritical_GameState);
	Main_HiddenPotential_GameState.InitListeners();
	Main_NotCreatedEqually_GameState.InitListeners();
	Main_RedFog_GameState.InitListeners();	

}

static function CheckForUnitComponents(XComGameState NewGameState,SecondWave_HiddenPotential_GameState HidPA,SecondWave_NotCreatedEqually_GameState NCEA,SecondWave_AbsolutlyCritical_GameState ACA,optional bool Submit=false)
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