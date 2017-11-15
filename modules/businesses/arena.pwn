new Float:raceCheckpoints[][4] = {
 {-1420.2987,-134.8565,1044.7223,0.0},
 {-1499.3707,-149.4469,1048.8916,0.0},
 {-1530.6382,-221.2661,1050.5693,0.0},
 {-1486.1606,-271.9465,1050.0342,0.0},
 {-1406.1437,-260.5554,1051.0042,0.0},
 {-1372.3171,-134.5126,1051.1095,0.0},
 {-1271.1477,-172.3684,1050.5544,0.0},
 {-1274.1982,-245.0231,1050.5308,0.0},
 {-1386.6617,-267.3381,1044.0184,0.0},
 {-1397.6497,-198.5682,1043.1173,0.0},
 {-1420.2987,-134.8565,1044.7223,0.0},
 {-1499.3707,-149.4469,1048.8916,0.0},
 {-1530.6382,-221.2661,1050.5693,0.0},
 {-1486.1606,-271.9465,1050.0342,0.0},
 {-1406.1437,-260.5554,1051.0042,0.0},
 {-1372.3171,-134.5126,1051.1095,0.0},
 {-1271.1477,-172.3684,1050.5544,0.0},
 {-1274.1982,-245.0231,1050.5308,0.0},
 {-1386.6617,-267.3381,1044.0184,0.0},
 {-1397.6497,-198.5682,1043.1173,0.0},
 {-1420.2987,-134.8565,1044.7223,0.0},
 {-1499.3707,-149.4469,1048.8916,0.0},
 {-1530.6382,-221.2661,1050.5693,0.0},
 {-1486.1606,-271.9465,1050.0342,0.0},
 {-1406.1437,-260.5554,1051.0042,0.0},
 {-1372.3171,-134.5126,1051.1095,0.0},
 {-1271.1477,-172.3684,1050.5544,0.0},
 {-1274.1982,-245.0231,1050.5308,0.0},
 {-1386.6617,-267.3381,1044.0184,0.0},
 {-1397.6497,-198.5682,1043.1173,0.0}
};

new RaceOn = 0;
new PlayerRace[MAX_PLAYERS];
new PlayerRaceProgress[MAX_PLAYERS];
new PlayerRaceCheckpoint[MAX_PLAYERS];
new RaceMembers = 0;
new RaceMembersFinished = 0;
new RaceBetIndex = INVALID_BET_INDEX;

#define GetPlayerRacePlace(%1) floatround(raceCheckpoints[PlayerRaceProgress[%1]][3])

forward ShowPlayerRaceCheckpoint(playerid);
public ShowPlayerRaceCheckpoint(playerid)
{
 new nextcheckpoint = PlayerRaceCheckpoint[playerid] >= sizeof(raceCheckpoints)-1 ? 0 : PlayerRaceCheckpoint[playerid]+1;

 SetPlayerRaceCheckpoint(playerid, (PlayerRaceCheckpoint[playerid] == sizeof(raceCheckpoints)-1) ? 1 : 0 ,
   raceCheckpoints[PlayerRaceCheckpoint[playerid]][0], raceCheckpoints[PlayerRaceCheckpoint[playerid]][1], raceCheckpoints[PlayerRaceCheckpoint[playerid]][2],
   raceCheckpoints[nextcheckpoint][0], raceCheckpoints[nextcheckpoint][1], raceCheckpoints[nextcheckpoint][2],
   10.0);
   
 return 1;
}

forward CreateRace(betindex);
public CreateRace(betindex)
{
 RaceOn = 1;
 RaceMembers = 0;
 RaceMembersFinished = 0;
 RaceBetIndex = betindex;

 for(new i = 0; i < MAX_PLAYERS; i++)
 {
  PlayerRace[i] = 0;
  PlayerRaceCheckpoint[i] = 0;
  PlayerRaceProgress[i] = 0;
 }
 
 for(new i = 0; i < sizeof(raceCheckpoints); i++)
 {
  raceCheckpoints[i][3] = 0.0;
 }
 
 return 1;
}

forward StartRace();
public StartRace()
{
 for(new i = 0; i < MAX_PLAYERS; i++)
 {
  if(IsPlayerConnected(i) && PlayerRace[i])
  {
   gPlayerCheckpointStatus[i] = CHECKPOINT_RACE;

   ShowPlayerRaceCheckpoint(i);
  }
 }
 
 return 1;
}

forward AddPlayerToRace(playerid);
public AddPlayerToRace(playerid)
{
 PlayerRace[playerid] = 1;
 PlayerRaceCheckpoint[playerid] = 0;
 PlayerRaceProgress[playerid] = 0;

 RaceMembers++;
 
 return 1;
}

forward GetRaceMembersCount();
public GetRaceMembersCount()
{
 return GetBetMembersCount(RaceBetIndex);
}

forward OnPlayerEnterRaceCheckpoint(playerid);
public OnPlayerEnterRaceCheckpoint(playerid)
{
 if(gPlayerCheckpointStatus[playerid] == CHECKPOINT_RACE)
 {
  new State = GetPlayerState(playerid);

	 if(State != PLAYER_STATE_DRIVER)
	 {
	  return 1;
	 }
	 
	 if(PlayerRaceCheckpoint[playerid] == sizeof(raceCheckpoints)-1) // meta
	 {
	  DisablePlayerRaceCheckpoint(playerid);
   
   PlayerPlaySound(playerid, 1183, 0.0, 0.0, 0.0);
   
   BetMembers[playerid][ebmPlace] = GetPlayerRacePlace(playerid);
   
   PlayerRace[playerid] = 0;
   
   RaceMembersFinished++;
   
   if(RaceMembersFinished >= GetRaceMembersCount())
   {
    FinishBet(RaceBetIndex);
    RaceOn = 0;
   }
	 }
	 else
	 {
	  new string[128];
	  format(string, sizeof(string), "raceCheckpoints[%d][3]: %f+1.0", PlayerRaceCheckpoint[playerid], raceCheckpoints[PlayerRaceCheckpoint[playerid]][3]);
	  SendClientMessage(playerid, COLOR_GREY, string);
   raceCheckpoints[PlayerRaceCheckpoint[playerid]][3] += 1.0;

   PlayerPlaySound(playerid, 1137, 0.0, 0.0, 0.0);

   PlayerRaceProgress[playerid] = PlayerRaceCheckpoint[playerid];
	  
	  PlayerRaceCheckpoint[playerid] = PlayerRaceCheckpoint[playerid] >= sizeof(raceCheckpoints)-1 ? 0 : PlayerRaceCheckpoint[playerid]+1;
	  ShowPlayerRaceCheckpoint(playerid);
	  
	  UpdatePlayerHud(playerid);
  }
 }
 
 return 1;
}

dcmd_wyscig(playerid, params[])
{
 new command[16], tmp[32], idx;

 tmp = strtok(params, idx);

 if(!strlen(tmp))
 {
 	SendClientMessage(playerid, COLOR_LORANGE, "** Wyœcig **");
	 SendClientMessage(playerid, COLOR_AWHITE,  "stworz, zapros");
 	return 1;
 }

 strmid(command, tmp, 0, sizeof(tmp), sizeof(command));

 if(!strcmp(command, "stworz", true))
	{
	 if(RaceOn == 1)
	 {
	  SendClientMessage(playerid, COLOR_GRAD2, "Wyœcig aktualnie trwa.");
	 	return 1;
	 }
	 
	 tmp = strtok(params, idx);

  if(!strlen(tmp))
	 {
	 	SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /wyscig stworz [Stawka]");
	 	return 1;
	 }

  new stake = strval(tmp);

  new Bet[ebBet];
  Bet[ebId] = BET_ID_RACE;
  Bet[ebStake] = stake;
  Bet[ebMaxMembers] = 4;

  new betindex = CreateBet(playerid, Bet, "Wyscig");
  
  Bets[betindex][ebPrizes][0] = 0.5;
  Bets[betindex][ebPrizes][1] = 0.2;
  Bets[betindex][ebPrizes][2] = 0.1;
  
  if(CreateRace(betindex) == -1)
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Nie mo¿esz zaprosiæ wiêkszej iloœci osób do zak³adu.");
   // return \|/
  }

  return 1;
	}
	else if(!strcmp(command, "zapros", true))
	{
  new betindex = GetMadeByPlayerBet(playerid);
  
  if(betindex == INVALID_BET_INDEX)
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Nie masz ¿adnego zak³adu.");
   return 1;
  }
  
  if(GetBetMembersCount(betindex) >= Bets[betindex][ebMaxMembers])
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Nie mo¿esz zaprosiæ wiêkszej iloœci osób do zak³adu.");
   return 1;
  }
	
	 tmp = strtok(params, idx);

  if(!strlen(tmp))
	 {
	 	SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /wyscig zapros [IdGracza/CzêœæNazwy]");
	 	return 1;
	 }

  new giveplayerid = ReturnUser(tmp);

  InvitePlayerToBet(playerid, giveplayerid, betindex);
  
  return 1;
	}
	else if(!strcmp(command, "start", true))
	{
	 StartRace();
  
  return 1;
	}
	else if(!strcmp(command, "zakoncz", true))
	{
	 if(RaceOn == 0)
	 {
	  SendClientMessage(playerid, COLOR_GRAD2, "Wyœcig aktualnie trwa.");
	 	return 1;
	 }
	 
	 new betindex = GetMadeByPlayerBet(playerid);
	 
	 FinishBet(betindex);

  return 1;
	}
	
	return 1;
}
