new RaceTrackEditor_StartPos = 0;

dcmd_trasa(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1)
	{
		SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ uprawniony do u¿ycia tej komendy!");
		return 1;
	}

 if(RaceOn == 1)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Edytowanie tras jest niemo¿liwe podczas wyœcigów.");
 	return 1;
 }
	
 new command[16], tmp[32], idx, string[128];

 tmp = strtok(params, idx);

 if(!strlen(tmp))
 {
 	SendClientMessage(playerid, COLOR_LORANGE, "** Edytor tras **");
	 SendClientMessage(playerid, COLOR_AWHITE,  "stworz, kolumny, pozycjastartowa");
 	return 1;
 }

 strmid(command, tmp, 0, sizeof(tmp), sizeof(command));

 if(!strcmp(command, "zaladuj", true))
	{
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
  
  SendClientMessage(playerid, COLOR_GREY, "Tryb edycji tras zosta³ aktywowany, aby go deaktywowaæ u¿yj /trasa zakoncz.");
  RaceTrackEditorOn = 1;

  return 1;
	}
	else if(!strcmp(command, "zakoncz", true))
	{
	 SendClientMessage(playerid, COLOR_GREY, "Tryb edycji tras zosta³ deaktywowany.");
	 RaceTrackEditorOn = 0;
	 
	 return 1;
	}
	else if(!strcmp(command, "kolumny", true))
	{
	 tmp = strtok(params, idx);

  if(!strlen(tmp))
  {
  	SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /wyscig zaladujtrase [NazwaTrasy]");
  	format(string, sizeof(string), "Aktualna iloœæ kolumn na starcie: %d.", RaceTrack[rtColumns]);

  	return 1;
  }
  
  new columns = strval(tmp);
  
  if(columns < 1 || columns > 50)
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Niepoprawna iloœc kolumn.");
  	return 1;
  }
  
  if(columns > 1)
  {
   SendClientMessage(playerid, COLOR_GRAD2, "W przypadku ustawienia iloœci kolumn wiêkszej ni¿ 1 trzeba pamiêtaæ o tym, ¿e ustawione musz¹");
   SendClientMessage(playerid, COLOR_GRAD2, "byæ odpowiednie dystanse dla pozycji startowej.");
   return 1;
  }
  
  RaceTrack[rtColumns] = columns;
  SaveTrack();
  
  return 1;
	}
	else if(!strcmp(command, "pozycjastartowa", true))
	{
	 if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
	 {
	  SendClientMessage(playerid, COLOR_GRAD2, "Musisz znajdowaæ siê w pojeŸdzie.");
	  return 1;
	 }
	 
	 new vehicleindex = GetPlayerVehicleID(playerid);

	 if(!RaceTrackEditor_StartPos)
	 {
	  SendClientMessage(playerid, COLOR_GRAD2, "Ustaw siê na pozycji startu i u¿yj ponownie tej komendy, by zapisaæ pozycjê startow¹.");
	  
	  RaceTrackEditor_StartPos = 1;
	 }
	 
	 switch(RaceTrackEditor_StartPos)
	 {
	  case 1:
	  {
	   GetVehiclePos(vehicleindex, RaceTrack[rtStartPosX], RaceTrack[rtStartPosY], RaceTrack[rtStartPosZ]);
	   GetVehicleZAngle(vehicleindex, RaceTrack[rtStartPosA]);
	   
	   SetPlayerCheckpoint(playerid, RaceTrack[rtStartPosX], RaceTrack[rtStartPosY], RaceTrack[rtStartPosZ], 3.0);
	   
	   SendClientMessage(playerid, COLOR_GRAD2, "Pozycja startowa zapisana. Ustaw siê teraz po prawej stronie od checkpointa i u¿yj ponownie tej komendy.");
	
	   RaceTrackEditor_StartPos = 2;
	  }
	  
	  case 2:
	  {
	   new Float:posx, Float:posy, Float:posz;
	   
	   GetVehiclePos(vehicleindex, posx, posy, posz);
	
	   RaceTrack[rtDistanceSide] = GetDistanceBetweenPoints(posx, posy, posz, RaceTrack[rtStartPosX], RaceTrack[rtStartPosY], RaceTrack[rtStartPosZ]);
	
	   SendClientMessage(playerid, COLOR_GRAD2, "Pierwszy dystans zapisany. Ustaw siê teraz za checkpointem i u¿yj ponownie tej komendy.");
	
	   RaceTrackEditor_StartPos = 3;
	  }
	  
	  case 3:
	  {
	   new Float:posx, Float:posy, Float:posz;
	
	   GetVehiclePos(vehicleindex, posx, posy, posz);
	
	   RaceTrack[rtDistanceBack] = GetDistanceBetweenPoints(posx, posy, posz, RaceTrack[rtStartPosX], RaceTrack[rtStartPosY], RaceTrack[rtStartPosZ]);
	
	   SendClientMessage(playerid, COLOR_GRAD2, "Drugi dystans zapisany. Pozycja startowa skonfigurowana i zapisana.");
	   DisablePlayerCheckpoint(playerid);
	   
	   SaveTrack();
	   
	   RaceTrackEditor_StartPos = 0;
	  }
	 }
	 
	 return 1;
	}
	
	return 1;
}

stock SaveTrack()
{
 new query[256];
 
 format(query, sizeof(query),
   "UPDATE `races_track` \
    SET	`startx` = %f,	`starty` = %f, `startz` = %f,	`starta` = %f,	`columns` = %d,	`max_members` = %d,	`distance_side` = %f, `distance_back` = %f\
    WHERE `id` = %d",
  RaceTrack[rtStartPosX],
  RaceTrack[rtStartPosY],
  RaceTrack[rtStartPosZ],
  RaceTrack[rtStartPosA],
  RaceTrack[rtColumns],
  RaceTrack[rtMaxMembers],
  RaceTrack[rtDistanceSide],
  RaceTrack[rtDistanceBack],
  RaceTrackId
 );
 
 mysql_query(query);
 
 return 1;
}
