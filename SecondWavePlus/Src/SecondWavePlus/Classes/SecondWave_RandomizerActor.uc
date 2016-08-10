// This is an Unreal Script

Class SecondWave_RandomizerActor extends Actor;

var int Sign;
var int StatInt,StatMin,StatRange;
var float Multiplier;
var float MultiplierPercentage;

function int GetRandomSign()
{
	//SetTimer(0.02,false,nameof(RandomSign));
	RandomSign();
	return Sign;
}

function float GetRandomMultiplier(float Perc)
{
	MultiplierPercentage=Perc;
	//SetTimer(0.02,false,nameof(RandomMultiplier));
	RandomMultiplier();
	return Multiplier;
}

function int GetRandomStat(int IStatRange,Optional int IStatMin=0,Optional bool Symmetric=false)
{
	StatMin=IStatMin;
	StatRange=IStatRange;
	if(!Symmetric)
		RandomStat();	//SetTimer(0.02,false,nameof(RandomStat));
	else
		RandomStatSymmetric();	//SetTimer(0.02,false,nameof(RandomStatSymmetric));
	return StatInt;
}


function RandomSign()
{
	local int i;
	local float Fi;
	Fi=RandRange(-1.0,1);
	if(Fi==0.0)
		Sign=1;

	i=Round(Fi/Abs(Fi));
	Sign=i;
	`log("Random Sign:"@Sign,,'Second Wave Plus-Randomizer');
}

function RandomStat()
{
	local int ReturnInt;
	do
	{
		ReturnInt= Round(RandRange(-float(StatRange),float(StatRange)));		
	}Until(ReturnInt>=StatMin);
	StatInt=ReturnInt;
	`log("Random Stat Not Symmetric:"@StatInt,,'Second Wave Plus-Randomizer');
}

function RandomMultiplier()
{
	local float RandomF;
	RandomF=RandRange(0.0,MultiplierPercentage/100.0);
	RandomSign();
	Multiplier=RandomF*float(Sign);
	`log("Random Multiplier:"@Multiplier,,'Second Wave Plus-Randomizer');

}

function RandomStatSymmetric()
{
	local int ReturnInt;
	ReturnInt=Round(RandRange(-float(StatRange),float(StatRange)));
	StatInt=ReturnInt;
	`log("Random Stat Symmetric:"@StatInt,,'Second Wave Plus-Randomizer');
}
