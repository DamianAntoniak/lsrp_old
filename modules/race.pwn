#define MAX_RACE_CHECKPOINTS 100
#define INVALID_RACE_TRACK_ID -1

enum raceCheckpointEnum {
 rcId,
 Float:rcPosX,
 Float:rcPosY,
 Float:rcPosZ,
 Float:rcRadius,
 rcPoints
}

enum raceTrackEnum {
 rtId,
 Float:rtStartPosX,
 Float:rtStartPosY,
 Float:rtStartPosZ,
 Float:rtStartPosA,
 rtColumns,
 rtMaxMembers,
 Float:rtDistanceSide,
 Float:rtDistanceBack
}

enum raceEnum {
 Float:raPrizes[MAX_PLAYERS]
}

new Float:raceCheckpoints[MAX_RACE_CHECKPOINTS][raceCheckpointEnum];
new RaceOn = 0;
new PlayerRace[MAX_PLAYERS];
new PlayerRaceProgress[MAX_PLAYERS];
new PlayerRaceCheckpoint[MAX_PLAYERS];
new RaceMembers = 0;
new RaceMembersFinished = 0;
new RaceBetIndex = INVALID_BET_INDEX;
new RaceTrackId = INVALID_RACE_TRACK_ID;
new RaceStarted = 0;
new RaceTrack[raceTrackEnum];
new Race[raceEnum];
new RaceStart = 0;
new RaceTrackEditorOn = 0;

#define GetPlayerRacePlace(%1) (RaceStarted ? floatround(raceCheckpoints[PlayerRaceProgress[%1]][rcPoints]) : BetMembers[%1][ebmPlace])
#define UpdateRacersHud() for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && PlayerRace[i]) UpdatePlayerHud(i)

stock array_sum(array[], size=sizeof array)
{
 new sum = 0;

 for(new i = 0; i < size; i++)
 {
  sum += array[i];
 }

 return sum;
}

stock Float:array_fsum(Float:array[], size=sizeof array)
{
 new Float:sum = 0.0;

 for(new i = 0; i < size; i++)
 {
  sum += array[i];
 }

 return sum;
}

forward ShowPlayerRaceCheckpoint(playerid);
public ShowPlayerRaceCheckpoint(playerid)
{
 new nextcheckpoint = PlayerRaceCheckpoint[playerid] >= GetRaceCheckpointsCount()-1 ? 0 : PlayerRaceCheckpoint[playerid]+1;

 SetPlayerRaceCheckpoint(playerid, (PlayerRaceCheckpoint[playerid] == GetRaceCheckpointsCount()-1) ? 1 : 0 ,
   raceCheckpoints[PlayerRaceCheckpoint[playerid]][rcPosX], raceCheckpoints[PlayerRaceCheckpoint[playerid]][rcPosY], raceCheckpoints[PlayerRaceCheckpoint[playerid]][rcPosZ],
   raceCheckpoints[nextcheckpoint][rcPosX], raceCheckpoints[nextcheckpoint][rcPosY], raceCheckpoints[nextcheckpoint][rcPosZ],
   10.0);

 return 1;
}

stock GetRaceCheckpointsCount()
{
 new count = 0;
 
 for(new i = 0; i < MAX_RACE_CHECKPOINTS; i++)
 {
  if(raceCheckpoints[i][rcId] != INVALID_RACE_TRACK_ID)
  {
   count++;
  }
 }
 
 return count;
}
 
forward CreateRace(betindex);
public CreateRace(betindex)
{
 RaceOn = 1;
 RaceMembers = 0;
 RaceMembersFinished = 0;
 RaceBetIndex = betindex;
 RaceStarted = 0;
 RaceStart = 0;

 for(new i = 0; i < MAX_PLAYERS; i++)
 {
  PlayerRace[i] = 0;
  PlayerRaceCheckpoint[i] = 0;
  PlayerRaceProgress[i] = 0;
 }
 
 for(new i = 0; i < sizeof(raceCheckpoints); i++)
 {
  raceCheckpoints[i][rcPoints] = 0;
 }

 return 1;
}

forward LoadTrack(trackname[]);
public LoadTrack(trackname[])
{
 for(new i = 0; i < sizeof(raceCheckpoints); i++)
 {
  raceCheckpoints[i][rcId] = INVALID_RACE_TRACK_ID;
 }

 new query[128];
 new data[10][12];
 
 format(query, sizeof(query), "SELECT * FROM `races_track` WHERE `name` = '%s'", trackname);
 mysql_query(query);
 mysql_store_result();
 
 if(!mysql_num_rows())
 {
  mysql_free_result();
  return 0;
 }
 
 mysql_fetch_row_format(query);
 split(query, data, '|');
 
 new trackid = strval(data[0]);
 
 RaceTrack[rtId] = trackid;
 RaceTrack[rtStartPosX]  = floatstr(data[2]);
 RaceTrack[rtStartPosY]  = floatstr(data[3]);
 RaceTrack[rtStartPosZ]  = floatstr(data[4]);
 RaceTrack[rtStartPosA]  = floatstr(data[5]);
 RaceTrack[rtColumns]    = strval(data[6]);
 RaceTrack[rtMaxMembers] = strval(data[7]);
 RaceTrack[rtDistanceSide]   = floatstr(data[8]);
 RaceTrack[rtDistanceBack]   = floatstr(data[9]);
 
 mysql_free_result();
 
 format(query, sizeof(query), "SELECT * FROM `races_trackcheckpoint` WHERE `track_id` = %d ORDER BY `place` ASC", trackid);
 mysql_query(query);
 mysql_store_result();
 
 if(mysql_num_rows() > 0)
 {
  new i = 0;
  
  while(mysql_fetch_row_format(query) == 1)
  {
   split(query, data, '|');
   
   raceCheckpoints[i][rcId]     = strval(data[0]);
   raceCheckpoints[i][rcPosX]   = floatstr(data[3]);
   raceCheckpoints[i][rcPosY]   = floatstr(data[4]);
   raceCheckpoints[i][rcPosZ]   = floatstr(data[5]);
   raceCheckpoints[i][rcRadius] = floatstr(data[6]);
   raceCheckpoints[i][rcPoints] = 0;

   i++;
  }
 }
 
 mysql_free_result();
 
 RaceTrackId = trackid;
 
 return 1;
}

forward StartRace();
public StartRace()
{
 RaceStarted = 1;
 RaceStart = GetTickCount();

 for(new i = 0; i < MAX_PLAYERS; i++)
 {
  if(IsPlayerConnected(i) && PlayerRace[i])
  {
   gPlayerCheckpointStatus[i] = CHECKPOINT_RACE;

   ShowPlayerRaceCheckpoint(i);
   
   TogglePlayerControllable(i, 1);
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

stock TimeConvert(Time)
{
	new Float:fTime = floatdiv(Time, 60000);
 new Minutes, Seconds, MSeconds;

 Minutes = floatround(fTime, floatround_tozero);
 Seconds = floatround(floatmul(fTime - Minutes, 60), floatround_tozero);
 MSeconds = floatround(floatmul(floatmul(fTime - Minutes, 60) - Seconds, 1000), floatround_tozero);
 
 new string[32], string2[8];
 
 format(string, sizeof(string), "%d", Minutes);

 if (Seconds < 10) format(string2, sizeof(string2), ":0%d", Seconds);
	else format(string2, sizeof(string2), ":%d", Seconds);
	
	strcat(string, string2);
	
 if (MSeconds < 100) format(string2, sizeof(string2), ".0%d", MSeconds);
	else format(string2, sizeof(string2), ".%d", MSeconds);

 strcat(string, string2);

	return string;
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
	
	 if(PlayerRaceCheckpoint[playerid] == GetRaceCheckpointsCount()-1) // meta
	 {
	  DisablePlayerRaceCheckpoint(playerid);

   raceCheckpoints[PlayerRaceCheckpoint[playerid]][rcPoints]++;
   BetMembers[playerid][ebmPlace] = GetPlayerRacePlace(playerid);

   PlayerRace[playerid] = 0;

   RaceMembersFinished++;
   
   new Time = GetTickCount() - RaceStart;
		 
		 new sendername[MAX_PLAYER_NAME];
		 GetPlayerNameEx(playerid, sendername, sizeof(sendername));

   new string[128];
		 format(string, sizeof(string), "%d. %s ukoñczy³ wyœcig z wynikiem %s.", BetMembers[playerid][ebmPlace], sendername, TimeConvert(Time));
   SendRaceMessage(COLOR_AWHITE, string);
	 	
   PlayerFinishBet(playerid, RaceBetIndex);

   if(RaceMembersFinished >= GetRaceMembersCount())
   {
    FinishBet(RaceBetIndex);
    RaceOn = 0;
    RaceStarted = 0;
   }
	 }
	 else
	 {
	  //new string[128];
	  //format(string, sizeof(string), "raceCheckpoints[%d][3]: %f+1.0", PlayerRaceCheckpoint[playerid], raceCheckpoints[PlayerRaceCheckpoint[playerid]][rcPoints]);
	  //SendClientMessage(playerid, COLOR_GREY, string);
   raceCheckpoints[PlayerRaceCheckpoint[playerid]][rcPoints]++;

   PlayerPlaySound(playerid, 1137, 0.0, 0.0, 0.0);

   PlayerRaceProgress[playerid] = PlayerRaceCheckpoint[playerid];
	
	  PlayerRaceCheckpoint[playerid] = PlayerRaceCheckpoint[playerid] >= GetRaceCheckpointsCount()-1 ? 0 : PlayerRaceCheckpoint[playerid]+1;
	  ShowPlayerRaceCheckpoint(playerid);
	
	  UpdatePlayerHud(playerid);
  }
 }

 return 1;
}

dcmd_wyscig(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 1)
	{
		SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ uprawniony do u¿ycia tej komendy!");
		return 1;
	}

 if(RaceTrackEditorOn)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Zarz¹dzanie wyœcigiem jest niedostêpne, kiedy tryb edycji tras jest aktywny.");
 	return 1;
 }
 
 new command[16], tmp[32], idx, string[128];

 tmp = strtok(params, idx);

 if(!strlen(tmp))
 {
 	SendClientMessage(playerid, COLOR_LORANGE, "** Wyœcig **");
	 SendClientMessage(playerid, COLOR_AWHITE,  "stworz, nagroda, zapros, zaladujtrase, lista");
 	return 1;
 }

 strmid(command, tmp, 0, sizeof(tmp), sizeof(command));

 if(!strcmp(command, "nagroda", true))
	{
	 if(RaceOn == 1)
	 {
	  SendClientMessage(playerid, COLOR_GRAD2, "Nie mo¿esz zmieniæ nagród dla aktualnie trwaj¹cego wyœcigu.");
	 	return 1;
	 }
	 
	 tmp = strtok(params, idx);

  if(!strlen(tmp))
	 {
	 	SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /wyscig nagroda [Miejsce] [WielkoœæNagrody]");
	 	return 1;
	 }

  new place = strval(tmp);
  
  tmp = strtok(params, idx);

  if(!strlen(tmp))
	 {
	 	SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /wyscig nagroda [Miejsce] [WielkoœæNagrody]");
	 	SendClientMessage(playerid, COLOR_GRAD2, "Wielkoœæ nagrody jest stawk¹ procentow¹. Dla stawki 20-procentowej wpisz \"0.2\".");
	 	return 1;
	 }

  new Float:price = floatstr(tmp);
  
  if(place < 1 || place > sizeof(Race[raPrizes]))
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Niepoprawny numer miejsca.");
	 	return 1;
  }
  
  if(price < 0.0 || price > 100.0)
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Niepoprawna wielkoœæ nagrody.");
	 	return 1;
  }
  
  new temp[raceEnum];
  
	 for(new i = 0; i < sizeof(Race[raPrizes]); i++)	temp[raPrizes][i] = Race[raPrizes][i];

  temp[raPrizes][place-1] = price;
  
  new Float:newsum = array_fsum(temp[raPrizes], sizeof(temp[raPrizes]));

  if(newsum > 1.0)
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Suma wielkoœci nagród nie mo¿e przekracaæ 100 procent.");
	 	return 1;
  }
  
  Race[raPrizes][place-1] = price;
  
  format(string, sizeof(string), "Nagroda dla %d. miejsca ustawiona na %.2f.", place, price);
  SendClientMessage(playerid, COLOR_LORANGE, string);
  format(string, sizeof(string), "Suma wielkoœci nagród wynosi: %.2f.", newsum);
  SendClientMessage(playerid, COLOR_GRAD2, string);
  
  return 1;
	}
 else if(!strcmp(command, "stworz", true))
	{
	 if(RaceTrackId == INVALID_RACE_TRACK_ID)
	 {
	  SendClientMessage(playerid, COLOR_GRAD2, "¯adna trasa wyœcigu nie zosta³a za³adowana. U¿yj /wyscig zaladujtrase [NazwaTrasy], by za³adowaæ trasê.");
	 	return 1;
	 }
	
	 if(RaceOn == 1)
	 {
	  SendClientMessage(playerid, COLOR_GRAD2, "Wyœcig aktualnie trwa.");
	  ShowBetInfo(RaceBetIndex, playerid);
	 	return 1;
	 }
	
	 tmp = strtok(params, idx);

  if(!strlen(tmp))
	 {
	 	SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /wyscig stworz [Stawka]");
	 	return 1;
	 }

  new stake = strval(tmp);
  
  if(stake > 0)
  {
   if(array_fsum(Race[raPrizes], sizeof(Race[raPrizes])) < 0.9)
   {
    SendClientMessage(playerid, COLOR_GRAD2, "Wielkoœci nagród s¹ niepoprawnie skonfigurowane. Suma procentowa nagród musi wynosiæ przynajmniej 90 procent z ca³ej stawki.");
	   return 1;
   }
  }
  
  new Bet[ebBet];
  Bet[ebId] = BET_ID_RACE;
  Bet[ebStake] = stake;
  Bet[ebMaxMembers] = 500;

  new betindex = CreateBet(playerid, Bet, "Wyscig");

  Bets[betindex][ebPrizes] = Race[raPrizes];

  CreateRace(betindex);

  format(string, sizeof(string), "Wyœcig zosta³ pomyœlnie utworzony (ID Trasy: %d, ID zak³adu: %d)", RaceTrackId, betindex);
  SendClientMessage(playerid, COLOR_GRAD2, string);

  return 1;
	}
	else if(!strcmp(command, "zaladujtrase", true))
	{
	 if(RaceOn == 1)
	 {
	  SendClientMessage(playerid, COLOR_GRAD2, "Nie mo¿esz zmieniæ trasy podczas wyœcigu.");
	 	return 1;
	 }
	 
	 tmp = strtok(params, idx);

  if(!strlen(tmp))
  {
  	SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /wyscig zaladujtrase [NazwaTrasy]");
  	return 1;
  }

  if(!LoadTrack(tmp))
  {
   format(string, sizeof(string), "Trasa \"%s\" nie mog³a zostaæ za³adowana.", tmp);
   SendClientMessage(playerid, COLOR_GREY, string);
   
   return 1;
  }
  
  format(string, sizeof(string), "Trasa \"%s\" zosta³a za³adowana pomyœlnie.", tmp);
  SendClientMessage(playerid, COLOR_LORANGE, string);
  
  return 1;
	}
	else if(!strcmp(command, "lista", true))
	{
  new betindex = GetMadeByPlayerBet(playerid);

  if(betindex == INVALID_BET_INDEX)
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Nie stworzy³eœ ¿adnego wyœcigu.");
   return 1;
  }
  
  if(betindex != RaceBetIndex)
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Nie stworzy³eœ ¿adnego wyœcigu.");
   return 1;
  }
  
  SendClientMessage(playerid, COLOR_LORANGE, "Cz³onkowie wyœcigu:");
  
  new pActPage = 1;
  new pLimit   = 8;
  new count    = GetRaceMembersCount();
  
  if(count == 0)
 	{
 	 SendClientMessage(playerid, COLOR_WHITE, "Brak cz³onków wyœcigu.");
 	}
  
  tmp = strtok(params, idx);

  if(strlen(tmp))
  {
  	pActPage = strval(tmp);

   if(pActPage < 1)
   {
    SendClientMessage(playerid, COLOR_GRAD2, "Niepoprawny numer strony.");
	   return 1;
   }

	  if((pActPage-1) * pLimit >= count)
	  {
	   SendClientMessage(playerid, COLOR_GRAD2, "Strona o podanym numerze nie istnieje.");
	   return 1;
	  }
	 }

	 new c1 = 0;	
  
  for(new i = 0; i < MAX_PLAYERS; i++)
  {
   if(IsPlayerConnected(i) && RaceBetIndex == BetMembers[i][ebmBetIndex])
		 {
		  if(c1 < ((pActPage-1) * pLimit))
    {
     c1++;
     continue;
    }

    if(c1 >= (((pActPage-1) * pLimit)+pLimit))
    {
     break;
    }
    
    new playername[MAX_PLAYER_NAME];
    GetPlayerNameEx(i, playername, sizeof(playername));
    format(string, sizeof(string), "(ID: %d) %s.", i, playername);
    SendClientMessage(playerid, COLOR_AWHITE, string);
    
    c1++;
		 }
  }
  
  if(pActPage * pLimit >= count)
  {
   format(string, sizeof(string), "U¯YJ: /%s [NrStrony]", command);
  }
  else
  {
   format(string, sizeof(string), "U¯YJ: /%s [NrStrony] (Nr nastêpnej strony: %d)", command, (pActPage+1));
  }

  SendClientMessage(playerid, COLOR_GRAD4, string);
  
  return 1;
 }
	else if(!strcmp(command, "zapros", true))
	{
  new betindex = GetMadeByPlayerBet(playerid);

  if(betindex == INVALID_BET_INDEX)
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Nie stworzy³eœ ¿adnego wyœcigu.");
   return 1;
  }

  if(GetBetMembersCount(betindex) >= Bets[betindex][ebMaxMembers])
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Nie mo¿esz zaprosiæ wiêkszej iloœci osób do wyœcigu.");
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
	 if(GetBetMembersCount(RaceBetIndex) < 2)
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Wyœcig musi mieæ przynajmniej dwóch cz³onków, aby móg³ byæ rozpoczêty.");
   //return 1;
  }
  
	 UpdateRacersHud();
	
	 for(new i = 0; i < MAX_PLAYERS; i++)
		{
		 if(RaceBetIndex == BetMembers[i][ebmBetIndex])
		 {
		  if(GetPlayerState(i) != PLAYER_STATE_DRIVER)
		  {
		   SendClientMessage(playerid, COLOR_GRAD2, "Nie wszyscy kierowcy znajduj¹ siê w swoich pojazdach.");
	   	return 1;
		  }
		 }
	 }
	
	 for(new i = 0; i < MAX_PLAYERS; i++)
		{
		 if(RaceBetIndex == BetMembers[i][ebmBetIndex])
		 {
    new
     Float:posx = RaceTrack[rtStartPosX],
     Float:posy = RaceTrack[rtStartPosY],
     Float:posz = RaceTrack[rtStartPosZ],
     Float:posa = RaceTrack[rtStartPosA]
    ;

		  new place = GetPlayerRacePlace(i);
    new row   = floatround((place-1)/RaceTrack[rtColumns], floatround_floor);

		  switch((place-1)%RaceTrack[rtColumns])
		  {
		   case 0:
		   {
		    new Float:distance = RaceTrack[rtDistanceBack];

	     posx -= ((distance*row) * floatsin(-posa, degrees));
		    posy -= ((distance*row) * floatcos(-posa, degrees));

		    SetVehiclePos(GetPlayerVehicleID(i), posx, posy, posz);
		    SetVehicleZAngle(GetPlayerVehicleID(i), posa);
		   }
		
		   default:
		   {
		    new Float:distance = RaceTrack[rtDistanceSide];
	
	     posx -= ((distance*((place-1) % RaceTrack[rtColumns])) * floatsin(-posa-90, degrees));
		    posy -= ((distance*((place-1) % RaceTrack[rtColumns])) * floatcos(-posa-90, degrees));

      distance = RaceTrack[rtDistanceBack];

		    posx -= ((distance*row) * floatsin(-posa, degrees));
		    posy -= ((distance*row) * floatcos(-posa, degrees));

		    SetVehiclePos(GetPlayerVehicleID(i), posx, posy, posz);
		    SetVehicleZAngle(GetPlayerVehicleID(i), posa);
		   }
		  }
		
		  TogglePlayerControllable(i, 0);
		 }
		}
		
	 RaceCountDown(10);

  return 1;
	}
	else if(!strcmp(command, "zakoncz", true))
	{
	 if(RaceOn == 0)
	 {
	  SendClientMessage(playerid, COLOR_GRAD2, "Nie ma ¿adnego wyœcigu.");
	 	return 1;
	 }
	
  FinishBet(RaceBetIndex);
  RaceBetIndex = INVALID_BET_INDEX;
  RaceOn = 0;
  RaceStarted = 0;

  return 1;
	}
	else if(!strcmp(command, "test", true))
	{
	 print("----");
	 for(new i = 0; i < sizeof(Race[raPrizes]); i++)
	 {
	  printf("Nagroda: %d - %f.", i, Race[raPrizes][i]);
	 }

	 return 1;
	}
	else if(!strcmp(command, "pojazd", true))
	{
	 tmp = strtok(params, idx);

  if(!strlen(tmp))
	 {
	 	SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /wyscig pojazd [IdPojazdu]");
	 	return 1;
	 }

  new vehicleid = strval(tmp);
  
  if(!IsVehicleOwner(PlayerInfo[playerid][pId], vehicleid))
  {
   SendClientMessage(playerid, COLOR_GRAD1, "Nie jesteœ w³aœcicielem tego pojazdu.");
	  return 1;
  }
  
  switch(CanVehicleBeSpawned(vehicleid))
  {
   case 2: { SendClientMessage(playerid, COLOR_GRAD1, "Ten pojazd nie zosta³ jeszcze dostarczony."); return 1; }
   case 3: { SendClientMessage(playerid, COLOR_GRAD1, "Ten pojazd jest zniszczony, nie mo¿esz go u¿yæ w wyœcigu."); return 1; }
   case 4: { SendClientMessage(playerid, COLOR_GRAD1, "Ten pojazd znajduje siê aktualnie w warsztacie."); return 1; }
  }
  
  new vehid = SpawnUserVehicle(playerid, vehicleid); // pobieramy ID pojazdu in-game

  format(string, sizeof(string), "%s (ID: %d) zespawnowa³ siê na miejscu parkingowym.", GetVehicleName(vehid), vehicleid);
  SendClientMessage(playerid, COLOR_WHITE, string);
  
	 /*new model = GetVehicleModel(GetPlayerVehicleID(playerid));
	
	 GetVehiclePos(GetPlayerVehicleID(playerid), posx, posy, posz);
	 GetVehicleZAngle(GetPlayerVehicleID(playerid), posa);
	
	 new Float:distance = 8.0;
	
	 posx -= (distance * floatsin(-posa, degrees));
		posy -= (distance * floatcos(-posa, degrees));

		CreateVehicle(model, posx, posy, posz, posa, 0, 0, 10);
		
		GetVehiclePos(GetPlayerVehicleID(playerid), posx, posy, posz);
	 GetVehicleZAngle(GetPlayerVehicleID(playerid), posa);

	 posx -= ((distance) * floatsin(-posa+90, degrees));
		posy -= ((distance) * floatcos(-posa+90, degrees));

		CreateVehicle(model, posx, posy, posz, posa, 6, 6, 10);
		
		GetVehiclePos(GetPlayerVehicleID(playerid), posx, posy, posz);
	 GetVehicleZAngle(GetPlayerVehicleID(playerid), posa);

	 posx -= ((distance) * floatsin(-posa-90, degrees));
		posy -= ((distance) * floatcos(-posa-90, degrees));

		CreateVehicle(model, posx, posy, posz, posa, 6, 6, 10);*/

	}
	
	return 1;
}

forward RaceCountDown(start);
public  RaceCountDown(start)
{
 new string[100];

 if(start > 0)
 {
  format(string, sizeof(string), "~w~%d", start);

  for(new i = 0; i < MAX_PLAYERS; i++)
  {
   if(RaceBetIndex == BetMembers[i][ebmBetIndex])
		 {
		  GameTextForPlayer(i, string, 1000, 5);
		  
		  PlayerPlaySound(i, 1137, 0.0, 0.0, 0.0);
		 }
  }

  SetTimerEx("RaceCountDown", 1000, 0, "d", start-1);
 }
 else
 {
  for(new i = 0; i < MAX_PLAYERS; i++)
  {
   if(RaceBetIndex == BetMembers[i][ebmBetIndex])
		 {
		  GameTextForPlayer(i, "~y~START!!!", 500, 5);
		  
		  PlayerPlaySound(i, 1138, 0.0, 0.0, 0.0);
		 }
  }

  StartRace();
 }

 return 1;
}

forward SendRaceMessage(color, string[]);
public SendRaceMessage(color, string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
		 if(RaceBetIndex == BetMembers[i][ebmBetIndex])
		 {
				SendClientMessage(i, color, string);
			}
		}
	}
}
