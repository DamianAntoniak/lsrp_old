dcmd_zamelduj(playerid, params[])
{
 #pragma unused params

 if(PlayerInfo[playerid][pLocalType] != CONTENT_TYPE_BUSINESS || PlayerInfo[playerid][pLocal] == 0)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê w ¿adnym hotelu.");
  return 1;
 }

 new businessindex = GetBusinessById(PlayerInfo[playerid][pLocal]);

 if(BizzInfo[businessindex][bType] != BUSINESS_TYPE_HOTEL)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê w ¿adnym hotelu.");
  return 1;
 }
 
 switch(BizzInfo[businessindex][bId])
 {
  case BUSINESS_MOTEL_JEFFERSON_ID, BUSINESS_MOTEL_IDLEWOOD_ID:
  {
   if(!PlayerToPoint(2.0, playerid, 2216.5930, -1147.6163, 1025.7969))
   {
    SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê przy recepcji.");
    return 1;
   }
  }
  
  case BUSINESS_HOTEL_RODEO_ID:
  {
   if(!PlayerToPoint(2.0, playerid, 2269.7852,1628.7980,1084.2451))
   {
    SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê przy recepcji.");
    return 1;
   }
  }
  
  default:
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê w ¿adnym hotelu.");
   return 1;
  }
 }

 PlayerInfo[playerid][pHotelId] = PlayerInfo[playerid][pLocal];
 
 new string[128];
 
 format(string, sizeof(string), "Zameldowa³eœ siê w %s. Numer Twojego pokoju to %d (u¿yj /pokoj wejdz [NrPokoju], by wejœæ do pokoju).", BizzInfo[businessindex][bName], PlayerInfo[playerid][pId]);
 SendClientMessage(playerid, COLOR_LORANGE, string);

 return 1;
}

dcmd_wymelduj(playerid, params[])
{
 #pragma unused params

 if(PlayerInfo[playerid][pLocalType] != CONTENT_TYPE_BUSINESS || PlayerInfo[playerid][pLocal] == 0)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê w ¿adnym hotelu.");
  return 1;
 }

 new businessindex = GetBusinessById(PlayerInfo[playerid][pLocal]);

 if(BizzInfo[businessindex][bType] != BUSINESS_TYPE_HOTEL)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê w ¿adnym hotelu.");
  return 1;
 }

 switch(BizzInfo[businessindex][bId])
 {
  case BUSINESS_MOTEL_JEFFERSON_ID, BUSINESS_MOTEL_IDLEWOOD_ID:
  {
   if(!PlayerToPoint(2.0, playerid, 2216.5930, -1147.6163, 1025.7969))
   {
    SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê przy recepcji.");
    return 1;
   }
  }

  case BUSINESS_HOTEL_RODEO_ID:
  {
   if(!PlayerToPoint(2.0, playerid, 2269.7852,1628.7980,1084.2451))
   {
    SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê przy recepcji.");
    return 1;
   }
  }

  default:
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê w ¿adnym hotelu.");
   return 1;
  }
 }

 PlayerInfo[playerid][pHotelId] = 0;
 
 SendClientMessage(playerid, COLOR_GREY, "Wymeldowa³eœ siê z tego hotelu.");

 return 1;
}

dcmd_pokoj(playerid, params[])
{
 if(PlayerInfo[playerid][pLocalType] != CONTENT_TYPE_BUSINESS || PlayerInfo[playerid][pLocal] == 0)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê w ¿adnym hotelu.");
  return 1;
 }

 new businessindex = GetBusinessById(PlayerInfo[playerid][pLocal]);

 if(BizzInfo[businessindex][bType] != BUSINESS_TYPE_HOTEL)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê w ¿adnym hotelu.");
 }

 new idx, command[24], tmp[64], string[128];
 
 tmp = strtok(params, idx);

 if(!strlen(tmp))
 {
  format(string, sizeof(string), "** %s **", BizzInfo[businessindex][bName]);
 	SendClientMessage(playerid, COLOR_LORANGE, string);
	 SendClientMessage(playerid, COLOR_AWHITE,  "/pokoj zamknij");
	 SendClientMessage(playerid, COLOR_AWHITE,  "/pokoj wejdz [NumerPokoju]");

 	return 1;
 }

 strmid(command, tmp, 0, sizeof(tmp), sizeof(command));

 if(!strcmp(command, "zamknij", true))
	{
	 if(PlayerInfo[playerid][pHotelId] == 0)
	 {
	  SendClientMessage(playerid, COLOR_GRAD2,  "Nie posiadasz w³asnego pokoju hotelowego.");
	  return 1;
	 }
	 
	 switch(BizzInfo[businessindex][bId])
  {
   case BUSINESS_MOTEL_JEFFERSON_ID, BUSINESS_MOTEL_IDLEWOOD_ID:
   {
    if(!PlayerToPoint(6.0, playerid, 2227.7571,-1150.4762,1029.7969) && !PlayerToPoint(6.0, playerid, 2233.6584,-1113.2397,1050.8828))
    {
     SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê przy drzwiach do pokoju hotelowego.");
     return 1;
    }
   }
   
   case BUSINESS_HOTEL_RODEO_ID:
   {
    if(!PlayerToPoint(6.0, playerid, 2267.3501,1647.5829,1084.2344) && !PlayerToPoint(6.0, playerid, 2237.5435,-1080.6592,1049.0234))
    {
     SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê przy drzwiach do pokoju hotelowego.");
     return 1;
    }
   }
   
   default:
   {
    SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê w ¿adnym hotelu.");
    return 1;
   }
  }
	
	 if(PlayerInfo[playerid][pHotelLocked] == 1)
	 {
	  SendClientMessage(playerid, COLOR_GRAD2, "Pokój zosta³ otworzony.");
	  PlayerInfo[playerid][pHotelLocked] = 0;
	 }
	 else
	 {
	  SendClientMessage(playerid, COLOR_GRAD2, "Pokój zosta³ zamkniêty.");
	  PlayerInfo[playerid][pHotelLocked] = 1;
	 }
	 
	 return 1;
	}
	else if(!strcmp(command, "wejdz", true))
	{
	 switch(BizzInfo[businessindex][bId])
  {
   case BUSINESS_MOTEL_JEFFERSON_ID, BUSINESS_MOTEL_IDLEWOOD_ID:
   {
    if(!PlayerToPoint(6.0, playerid, 2227.7571,-1150.4762,1029.7969))
    {
     SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê przy drzwiach do pokoju hotelowego.");
     return 1;
    }
   }
   
   case BUSINESS_HOTEL_RODEO_ID:
   {
    if(!PlayerToPoint(6.0, playerid, 2267.3501,1647.5829,1084.2344))
    {
     SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê przy drzwiach do pokoju hotelowego.");
     return 1;
    }
   }

   default:
   {
    SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê w ¿adnym hotelu.");
    return 1;
   }
  }
	
	 tmp = strtok(params, idx);
	 
	 if(!strlen(tmp))
  {
   SendClientMessage(playerid, COLOR_GRAD2,  "U¯YJ: /pokoj wejdz [NumerPokoju]");
   return 1;
  }
  
  new roomno = strval(tmp);
  new ownerindex = GetHotelRoomOwner(PlayerInfo[playerid][pLocal], roomno);
  
  if(ownerindex == INVALID_PLAYER_ID || (ownerindex != INVALID_PLAYER_ID && PlayerInfo[ownerindex][pHotelLocked] == 1))
  {
   SendClientMessage(playerid, COLOR_GRAD2,  "Ten pokój jest zamkniêty.");
   return 1;
  }
  
  switch(BizzInfo[businessindex][bId])
  {
   case BUSINESS_MOTEL_JEFFERSON_ID, BUSINESS_MOTEL_IDLEWOOD_ID:
   {
    SetPlayerPosEx(playerid, 2233.6584,-1113.2397,1050.8828);
    SetPlayerFacingAngle(playerid, 2.7833);
    SetPlayerInterior(playerid, 5);
   }
   
   case BUSINESS_HOTEL_RODEO_ID:
   {
    SetPlayerPosEx(playerid, 2237.5435,-1080.6592,1049.0234);
    SetPlayerFacingAngle(playerid, 2.5548);
    SetPlayerInterior(playerid, 2);
   }

   default:
   {
    SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê w ¿adnym hotelu.");
    return 1;
   }
  }

  SetPlayerVirtualWorld(playerid, ownerindex+1);
  SetCameraBehindPlayer(playerid);
  
  return 1;
	}

 return 1;
}

stock GetHotelRoomOwner(businessid, roomno)
{
 for(new i = 0; i < MAX_PLAYERS; i++)
 {
  if(IsPlayerConnected(i) && PlayerInfo[i][pHotelId] == businessid && PlayerInfo[i][pId] == roomno)
  {
   return i;
  }
 }
 
 return INVALID_PLAYER_ID;
}
