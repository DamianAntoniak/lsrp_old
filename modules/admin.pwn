stock WarpPlayerToPlayer(playerid, toplayerid)
{
 new Float:x, Float:y, Float:z;

 GetPlayerPos(toplayerid, x, y, z);
 GetXYInFrontOfPlayer(toplayerid, x, y, 1.5);

 WarpPlayerToPos(playerid, x, y, z, GetPlayerInterior(toplayerid), GetPlayerVirtualWorld(toplayerid));

 PlayerInfo[playerid][pLocal]     = PlayerInfo[toplayerid][pLocal];
 PlayerInfo[playerid][pLocalType] = PlayerInfo[toplayerid][pLocalType];
}

stock WarpPlayerToVehicle(playerid, vehicleid)
{
 new Float:x, Float:y, Float:z;

 GetVehiclePos(vehicleid, x, y, z);
 //GetXYInFrontOfVehicle(vehicleid, x, y, 5.0);

 WarpPlayerToPos(playerid, x, y, z+1.5, 0, GetVehicleVirtualWorld(vehicleid));
}

stock WarpPlayerToPos(playerid, Float:x, Float:y, Float:z, interiorid = -1, virtualworld = -1)
{
 new vehicleindex = GetPlayerVehicleID(playerid);

 if(vehicleindex)
 {
  if(interiorid != -1) SetPlayerInterior(playerid, interiorid);
  if(interiorid != -1) LinkVehicleToInterior(vehicleindex, interiorid);
  if(virtualworld != -1) SetPlayerVirtualWorldEx(playerid, virtualworld);
  SetVehiclePos(vehicleindex, x, y, z);
 }
 else
 {
  if(interiorid != -1) SetPlayerInterior(playerid, interiorid);
  if(virtualworld != -1) SetPlayerVirtualWorldEx(playerid, virtualworld);
  SetPlayerPosEx(playerid, x, y, z);
 }
}

dcmd_a(playerid, params[])
{	
 if(PlayerInfo[playerid][pAdmin] < 1)
 {
	 SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
	 return 1;
	}
	
	if(!strlen(params))
 {
	 SendClientMessage(playerid, COLOR_GRAD2, "Wpisz: (/a)dmin [admin chat]");
 	return 1;
 }
	
	new playername[MAX_PLAYER_NAME], string[128];
	
	GetPlayerNameEx(playerid, playername, sizeof(playername));
	
	format(string, sizeof(string), "*%d Admin %s: %s", PlayerInfo[playerid][pAdmin], playername, params);
 SendAdminMessage(COLOR_YELLOW2, string);

 printf("Admin %s: %s", playername, params);

 return 1;
}

dcmd_kick(playerid, params[], silent=0)
{
 if(PlayerInfo[playerid][pAdmin] < 1)
 {
	 SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
	 return 1;
	}

 new reason[128], str[315], string[128], giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME], giveplayerid;

 if(sscanf(params, "us", giveplayerid, reason))
	{
	 if(silent == 1)
	 {
		 SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /skick [IdGracza/Cz��Nazwy] [Pow�d]");
	 }
	 else
	 {
	  SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /kick [IdGracza/Cz��Nazwy] [Pow�d]");
	 }
		return 1;
	}
	
 if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }

 if(giveplayerid == playerid)
	{
		SendClientMessage(playerid, COLOR_GRAD2, "Nie mo�esz wyrzuci� samego siebie.");
		return 1;
	}
	
	Log_Kick(playerid, giveplayerid, reason);

    GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));

	if(silent == 1)
	{
 	//format(string, sizeof(string), "Admin: %s zosta� wyrzucony przez %s, Pow�d: %s", giveplayer, sendername, reason);
	//SendClientMessage(giveplayerid, COLOR_LIGHTRED, string);
	 format(string, sizeof(string), "Zosta�e� wyrzucony z servera przez: {9e1e1e}%s.\n{a9c4e4}Pow�d: {9e1e1e}%s\n\n{9e1e1e}UWAGA:\n{a9c4e4}Je�li kara by�a nies�uszna mo�esz si� odwo�a� na forum w odpowienim dziale.\nPami�taj r�wnie� o screenie, kt�ry jest niezb�dny do apelacji.", sendername, reason);
	 ShowPlayerDialog(giveplayerid, DIALOG_KICK_FOR_PLAYER, DIALOG_STYLE_MSGBOX, "Kick", string,"Zamknij", "");
	 
	 strcat(string, " (skick)");
 	ABroadCast(COLOR_LIGHTRED,string,1);
	}
	else
	{
	 //format(string, sizeof(string), "Admin: %s zosta� wyrzucony przez %s, Pow�d: %s", giveplayer, sendername, reason);
	 EscapePL(string);
	 format(string, sizeof(string), "~>~ Kick ~<~ ~r~%s ~w~zostal wyrzucony przez ~r~%s, ~w~Powod: ~r~%s%s", giveplayer, sendername, reason);
	 //SendClientMessageToAll(COLOR_LIGHTRED, string);
	 TextDrawSetString(Kara, string);
	 TextDrawShowForAll(Kara);
	 KillTimer(KaraTD);
	 KaraTD = SetTimer("textkara", 10000, 0);
	 format(str, sizeof(str), "Zosta�e� wyrzucony z servera przez: {9e1e1e}%s.\n{a9c4e4}Pow�d: {9e1e1e}%s\n\n{9e1e1e}UWAGA:\n{a9c4e4}Je�li kara by�a nies�uszna mo�esz si� odwo�a� na forum w odpowienim dziale.\nPami�taj r�wnie� o screenie, kt�ry jest niezb�dny do apelacji.", sendername, reason);
	 ShowPlayerDialog(giveplayerid, DIALOG_KICK_FOR_PLAYER, DIALOG_STYLE_MSGBOX, "Kick", str,"Zamknij", "");
	 TextDrawHideForPlayer(giveplayerid, Kara);
 }

	Kick(giveplayerid);
	
	return 1;
}

dcmd_skick(playerid, params[])
{
 return dcmd_kick(playerid, params, 1);
}

dcmd_warn(playerid, params[], kick=0)
{
	if(PlayerInfo[playerid][pAdmin] < 2)
	{
		SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
		return 1;
	}

	new reason[128], str[315], string[128], giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME], giveplayerid;

	if(sscanf(params, "us", giveplayerid, reason))
	{
		if(kick == 0)
		{	
			SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /warn [IdGracza/Cz��Nazwy] [Pow�d]");
		}
		else
		{
			SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /kwarn [IdGracza/Cz��Nazwy] [Pow�d]");
		}
		return 1;
	}
	
	if(giveplayerid == INVALID_PLAYER_ID)
	{
		SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
		return 1;
	}

	if(giveplayerid == playerid)
	{
		SendClientMessage(playerid, COLOR_GRAD2, "Nie mo�esz ostrzec samego siebie.");
		return 1;
	}
	
	PlayerInfo[giveplayerid][pWarns]++;

	GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));

	new year, month,day;
	getdate(year, month, day);
	
	if(PlayerInfo[giveplayerid][pWarns] == 3)
	{
		format(string, sizeof(string), "Admin: %s zosta� zbanowany (po 3 ostrze�eniach) przez %s, Pow�d: %s (%d-%d-%d)", giveplayer, sendername, reason, month, day, year);
		KickLog(string);
		EscapePL(string);
		format(string, sizeof(string), "~>~ Ban ~<~ ~r~%s ~w~zosta� zbanowany (po 3 ostrze�eniach) przez ~r~%s, ~w~Powod: ~r~%s%s", giveplayer, sendername, reason);
		format(str, sizeof(str), "Zosta�e� zbanowany (po 3 ostrze�eniach) przez: {9e1e1e}%s, {a9c4e4}Pow�d: {9e1e1e}%s\n\n{9e1e1e}UWAGA:\n{a9c4e4}Je�li kara by�a nies�uszna mo�esz si� odwo�a� na forum w odpowienim dziale.\nPami�taj r�wnie� o screenie, kt�ry jest niezb�dny do apelacji.", sendername, reason);
	    ShowPlayerDialog(giveplayerid, DIALOG_WARN_FOR_PLAYER, DIALOG_STYLE_MSGBOX, "Warn", str,"Zamknij", "");
	    TextDrawHideForPlayer(giveplayerid, Kara);

		Log_Warn(playerid, giveplayerid, reason);
		strcat(reason, " (Limit ostrze�e�)");

		PlayerInfo[giveplayerid][pLevel]  = 1;
		PlayerInfo[giveplayerid][pMember] = 0;
		PlayerInfo[giveplayerid][pLeader] = 0;

		MySQLBanPlayer(giveplayerid, reason, playerid);
	}
	else
	{
		if(kick == 0)
		{
			format(string, sizeof(string), "Admin: %s zosta� ostrze�ony przez %s, Pow�d: %s (%d-%d-%d)", giveplayer, sendername, reason, month, day, year);
			KickLog(string);
			EscapePL(string);
			format(string, sizeof(string), "~>~ Warn ~<~ ~r~%s ~w~zostal ostrzezony przez ~r~%s, ~w~Powod: ~r~%s%s", giveplayer, sendername, reason);
			format(str, sizeof(str), "Zosta�e� ostrze�ony przez: {9e1e1e}%s, {a9c4e4}Pow�d: {9e1e1e}%s\n\n{9e1e1e}UWAGA:\n{a9c4e4}Je�li kara by�a nies�uszna mo�esz si� odwo�a� na forum w odpowienim dziale.\nPami�taj r�wnie� o screenie, kt�ry jest niezb�dny do apelacji.", sendername, reason);
	        ShowPlayerDialog(giveplayerid, DIALOG_WARN_FOR_PLAYER, DIALOG_STYLE_MSGBOX, "Warn", str,"Zamknij", "");
	        TextDrawSetString(Kara, string);
	        TextDrawShowForAll(Kara);
	        TextDrawHideForPlayer(giveplayerid, Kara);
	        KillTimer(KaraTD);
	        KaraTD = SetTimer("textkara", 10000, 0);

		}
		else
		{
			format(string, sizeof(string), "Admin: %s zosta� ostrze�ony i wyrzucony przez %s, Pow�d: %s (%d-%d-%d)", giveplayer, sendername, reason, month, day, year);
			KickLog(string);
			EscapePL(string);
			format(string, sizeof(string), "~>~ Warn ~<~ ~r~%s ~w~zostal ostrzezony i wyrzucony przez ~r~%s, ~w~Powod: ~r~%s%s", giveplayer, sendername, reason);
			format(str, sizeof(str), "Zosta�e� ostrze�ony i  wyrzucony z servera przez: {9e1e1e}%s.\n{a9c4e4}Pow�d: {9e1e1e}%s\n\n{9e1e1e}UWAGA:\n{a9c4e4}Je�li kara by�a nies�uszna mo�esz si� odwo�a� na forum w odpowienim dziale.\nPami�taj r�wnie� o screenie, kt�ry jest niezb�dny do apelacji.", sendername, reason);
	        ShowPlayerDialog(giveplayerid, DIALOG_WARN_FOR_PLAYER, DIALOG_STYLE_MSGBOX, "Warn & Kick", str,"Zamknij", "");
	        TextDrawSetString(Kara, string);
	        TextDrawShowForAll(Kara);
	        TextDrawHideForPlayer(giveplayerid, Kara);
	        KillTimer(KaraTD);
	        KaraTD = SetTimer("textkara", 10000, 0);
		}
		
		Log_Warn(playerid, giveplayerid, reason);

		if(kick == 1) Kick(giveplayerid);
 }

	return 1;
}

dcmd_unwarn(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 2)
 {
	 SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
	 return 1;
	}

 new reason[128], str[315], string[128], giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME], giveplayerid;

 if(sscanf(params, "us", giveplayerid, reason))
	{
	 SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /unwarn [IdGracza/Cz��Nazwy] [Pow�d]");
		return 1;
	}
	
 if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }

 if(giveplayerid == playerid)
	{
		SendClientMessage(playerid, COLOR_GRAD2, "Nie mo�esz �ci�ga� w�asnych ostrze�e�.");
		return 1;
	}
	
	if(PlayerInfo[giveplayerid][pWarns] <= 0)
	{
	 SendClientMessage(playerid, COLOR_GRAD2, "Ta osoba nie ma �adnych ostrze�e�.");
		return 1;
	}
	
	PlayerInfo[giveplayerid][pWarns]--;

  GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));

  new year, month,day;
	getdate(year, month, day);
	
	format(string, sizeof(string), "Admin: %s �ci�gn�� ostrze�enie %s, Pow�d: %s (%d-%d-%d)", sendername, giveplayer, reason, month, day, year);
	KickLog(string);
	EscapePL(string);
	//format(string, sizeof(string), "Admin: %s �ci�gn�� ostrze�enie %s, Pow�d: %s", sendername, giveplayer, reason);
	format(string, sizeof(string), "~>~ UnWarn ~<~ ~r~%s ~w~sciagnal ostrzezenie ~r~%s, ~w~Powod: ~r~%s%s", sendername, giveplayer, reason);
	format(str, sizeof(str), "Administrator {9e1e1e}%s �ci�gn�� Ci ostrze�enie, {a9c4e4}Pow�d: {9e1e1e}%s\n\n{9e1e1e}UWAGA:\n{a9c4e4}Twoja kara zosta�a zniesiona, lecz pami�taj na przysz�o��, by nie pope�nia� tych samych b��d�w.", sendername, reason);
    ShowPlayerDialog(giveplayerid, DIALOG_UNWARN_FOR_PLAYER, DIALOG_STYLE_MSGBOX, "UnWarn", str,"Zamknij", "");
    TextDrawSetString(Kara, string);
	TextDrawShowForAll(Kara);
	TextDrawHideForPlayer(giveplayerid, Kara);
	KillTimer(KaraTD);
	KaraTD = SetTimer("textkara", 10000, 0);
	//SendClientMessageToAll(COLOR_LIGHTRED, string);
	Log_UnWarn(playerid, giveplayerid, reason);
	

	return 1;
}

dcmd_kwarn(playerid, params[])
{
 return dcmd_warn(playerid, params, 1);
}

dcmd_o(playerid, params[])
{
 if (PlayerInfo[playerid][pAdmin] < 2)
	{
	 SendClientMessage(playerid, COLOR_GRAD2, "Nie jeste� uprawniony do u�ycia tej komendy.");
		return 1;
	}
 	
 if(!strlen(params))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: (/o)oc [wiadomo��]");
		return 1;
	}

 new string[128], playername[MAX_PLAYER_NAME];

	GetPlayerNameEx(playerid, playername, sizeof(playername));
	params[0] = chrtoupper(params[0]);

	if(strlen(params) > SPLIT_TEXT_LIMIT)
	{
	 new stext[128];
	 	
  strmid(stext, params, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
	 format(string, sizeof(string), "(( %s: %s... ))", playername, stext);
 	OOCOff(COLOR_OOC,string);

  strmid(stext, params, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
  format(string, sizeof(string), "(( %s: ...%s ))", playername, stext);
 	OOCOff(COLOR_OOC,string);
 }
 else
 {
  format(string, sizeof(string), "(( %s: %s ))", playername, params);
  OOCOff(COLOR_OOC,string);
 }

 printf("(( %s: %s ))", playername, params);
	
	return 1;
}

dcmd_ado(playerid, params[])
{
 if (PlayerInfo[playerid][pAdmin] < 2)
	{
	 SendClientMessage(playerid, COLOR_GRAD2, "Nie jeste� uprawniony do u�ycia tej komendy.");
		return 1;
	}

 if(!strlen(params))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /ado [wiadomo��]");
		return 1;
	}

 new string[128], playername[MAX_PLAYER_NAME];

	GetPlayerNameEx(playerid, playername, sizeof(playername));
	params[0] = chrtoupper(params[0]);

	if(strlen(params) > SPLIT_TEXT_LIMIT)
	{
	 new stext[128];

  strmid(stext, params, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
	 format(string, sizeof(string), "** %s... **", stext);
 	OOCOff(COLOR_DO_BLUE,string);

  strmid(stext, params, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
  format(string, sizeof(string), "** ...%s **", stext);
 	OOCOff(COLOR_DO_BLUE, string);
 }
 else
 {
  format(string, sizeof(string), "** %s **", params);
  OOCOff(COLOR_DO_BLUE, string);
 }

 printf("(%s)** %s **", playername, params);

	return 1;
}
dcmd_goto(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 1)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
  return 1;
 }

 new giveplayerid;

 if(sscanf(params, "u", giveplayerid))
	{
	 new param[8];
	 
	 if(Spectate[playerid] != INVALID_PLAYER_ID)
	 {
	  KillTimer(safeTimer[playerid]);
		 IsPlayerSafe[playerid] = 1;
   safeTimer[playerid] = SetTimerEx("SetPlayerUnsafe", 2500, 0, "d", playerid); // wylaczenie fixa na szpital
	 	
	 	MedicBill[playerid] = 0;
 		setSpawnOnSpawn[playerid] = 0;
 		
	  TogglePlayerSpectating(playerid, 0);
	  
	  format(param, sizeof(param), "%d", Spectate[playerid]);
	  dcmd_goto(playerid, param);
	  
	  Spectate[playerid] = INVALID_PLAYER_ID;
	  
	  return 1;
	 }
	
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /goto [IdGracza/Cz��Nazwy]");
		return 1;
	}
	
 if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }

 if(playerid == giveplayerid)
	{
  SendClientMessage(playerid, COLOR_GREY, "Nie mo�esz teleportowa� si� do samego siebie.");
  return 1;
 }

 if(GetPlayerState(giveplayerid) == PLAYER_STATE_SPECTATING || GetPlayerState(giveplayerid) == PLAYER_STATE_NONE)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie mo�esz si� teleportowa� do tej osoby (ogl�da ona kogo� lub jej posta� nie istnieje w grze).");
  return 1;
 }

 WarpPlayerToPlayer(playerid, giveplayerid);

 new string[128], giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME];
	
	GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
	
	format(string, sizeof(string), "Teleportowa�e� si� do (ID: %d) %s.", giveplayerid, giveplayer);
	SendClientMessage(playerid, COLOR_GRAD1, string);
	
	printf("Admin: %s teleportowa� si� do %s.", sendername, giveplayer);
	
	return 1;
}

dcmd_gethere(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 1)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
  return 1;
 }

 new giveplayerid;

 if(sscanf(params, "u", giveplayerid))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /gethere [IdGracza/Cz��Nazwy]");
		return 1;
	}
	
 if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }

 if(playerid == giveplayerid)
	{
  SendClientMessage(playerid, COLOR_GREY, "Nie mo�esz teleportowa� si� do samego siebie.");
  return 1;
 }

 if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING || GetPlayerState(playerid) == PLAYER_STATE_NONE)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie mo�esz teleportowa� do siebie tej osoby (ogl�dasz kogo� lub Twoja posta� nie istnieje w grze).");
  return 1;
 }

 WarpPlayerToPlayer(giveplayerid, playerid);

 new string[128], giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME];
	
	GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
	
	format(string, sizeof(string), "Teleportowa�e� do siebie (ID: %d) %s.", giveplayerid, giveplayer);
	SendClientMessage(playerid, COLOR_GRAD1, string);
	
	printf("Admin: %s teleportowa� do siebie %s.", sendername, giveplayer);
	
	return 1;
}

dcmd_teleport(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 1)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
  return 1;
 }

 new giveplayerid, toplayerid;

 if(sscanf(params, "uu", giveplayerid, toplayerid))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /teleport [IdGracza/Cz��Nazwy] [IdGracza/Cz��Nazwy]");
		return 1;
	}
	
 if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }

 if(toplayerid == giveplayerid)
	{
  SendClientMessage(playerid, COLOR_GREY, "Nie mo�esz teleportowa� si� tej samej osoby do siebie.");
  return 1;
 }

 if(GetPlayerState(toplayerid) == PLAYER_STATE_SPECTATING || GetPlayerState(toplayerid) == PLAYER_STATE_NONE)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie mo�esz si� teleportowa� osoby do tej osoby (ogl�da ona kogo� lub jej posta� nie istnieje w grze).");
  return 1;
 }

 WarpPlayerToPlayer(giveplayerid, toplayerid);

 new string[128], giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME], toplayername[MAX_PLAYER_NAME];
	
	GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	GetPlayerNameEx(toplayerid, toplayername, sizeof(toplayername));
	GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
	
	format(string, sizeof(string), "Teleportowa�e� (ID: %d) %s do (ID: %d) %s.", giveplayerid, giveplayer, toplayerid, toplayername);
	SendClientMessage(playerid, COLOR_GRAD1, string);
	
	format(string, sizeof(string), "Administrator %s teleportowa� Ci� do %s.", sendername, toplayername);
	SendClientMessage(giveplayerid, COLOR_GRAD1, string);
	
	format(string, sizeof(string), "Administrator %s teleportowa� %s do Ciebie.", sendername, giveplayer);
	SendClientMessage(toplayerid, COLOR_GRAD1, string);
	
	printf("Admin: %s teleportowa� %s do %s.", sendername, giveplayer, toplayerid);
	
	return 1;
}

dcmd_recon(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 1)
 {
	 SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
	 return 1;
	}
			
 new giveplayerid;

 if(strcmp("off", params, true, strlen(params)) == 0)
	{
	 if(Spectate[playerid] != INVALID_PLAYER_ID)
	 {
	  KillTimer(safeTimer[playerid]);
		 IsPlayerSafe[playerid] = 1;
   safeTimer[playerid] = SetTimerEx("SetPlayerUnsafe", 2500, 0, "d", playerid); // wylaczenie fixa na szpital
	 	
	 	MedicBill[playerid] = 0;
 		setSpawnOnSpawn[playerid] = 0;
 		
	  TogglePlayerSpectating(playerid, 0);
	
	  PlayerInfo[playerid][pLocal] = Unspec[playerid][sLocal];
	  PlayerInfo[playerid][pLocalType] = Unspec[playerid][sLocalType];
	
	  SetPlayerInterior(playerid, Unspec[playerid][sPint]);
	  SetPlayerVirtualWorld(playerid, Unspec[playerid][sVW]);
	  SetPlayerPosEx(playerid, Unspec[playerid][sPx], Unspec[playerid][sPy], Unspec[playerid][sPz]);
	
	  Spectate[playerid] = INVALID_PLAYER_ID;
	 }
	
	 return 1;
	}
	
 if(sscanf(params, "u", giveplayerid)) { SendClientMessage(playerid, COLOR_GRAD2,  "U�YJ: /recon [IdGracza/Cz��Nazwy]"); return 1; }

 if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }

	if(Spectate[playerid] == INVALID_PLAYER_ID)
	{
		GetPlayerPos(playerid, Unspec[playerid][sPx], Unspec[playerid][sPy], Unspec[playerid][sPz]);
		Unspec[playerid][sPint]  = GetPlayerInterior(playerid);
		Unspec[playerid][sVW]    = GetPlayerVirtualWorld(playerid);
		Unspec[playerid][sLocal] = PlayerInfo[playerid][pLocal];
		Unspec[playerid][sLocalType] = PlayerInfo[playerid][pLocalType];
	}
	
	Spectate[playerid] = giveplayerid;
	
	PlayerSpectatePlayerOrVehicle(playerid, giveplayerid);
	
	return 1;
}

dcmd_setplayerint(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 1)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
  return 1;
 }

 new giveplayerid, interiorid;

 if(sscanf(params, "ud", giveplayerid, interiorid))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /setplayerint [IdGracza/Cz��Nazwy] [InteriorId]");
		return 1;
	}
	
 if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }

 SetPlayerInterior(giveplayerid, interiorid);
 
 new string[128], giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME];
 
 GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
	
	format(string, sizeof(string), "Zmieni�e� interior (ID: %d) %s na %d.", giveplayerid, giveplayer, interiorid);
	SendClientMessage(playerid, COLOR_GRAD1, string);
	
	printf("Admin: %s zmieni� interior %s na %d.", sendername, giveplayer, interiorid);
	
	return 1;
}

dcmd_setplayervw(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 1)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
  return 1;
 }

 new giveplayerid, virtualworldid;

 if(sscanf(params, "ud", giveplayerid, virtualworldid))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /setplayervw [IdGracza/Cz��Nazwy] [VWId]");
		return 1;
	}
	
 if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }

 SetPlayerVirtualWorldEx(giveplayerid, virtualworldid);

 new string[128], giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME];

 GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
	
	format(string, sizeof(string), "Zmieni�e� wirtualny �wiat (ID: %d) %s na %d.", giveplayerid, giveplayer, virtualworldid);
	SendClientMessage(playerid, COLOR_GRAD1, string);
	
	printf("Admin: %s zmieni� wirtualny �wiat %s na %d.", sendername, giveplayer, virtualworldid);
	
	return 1;
}

dcmd_setint(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 1)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
  return 1;
 }

 new interiorid;

 if(sscanf(params, "d", interiorid))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /setint [InteriorId]");
		return 1;
	}
	
	SetPlayerInterior(playerid, interiorid);
	
	new string[128];
	
	format(string, sizeof(string), "Zmieni�e� interior na %d.", interiorid);
	SendClientMessage(playerid, COLOR_GRAD1, string);
	
	return 1;
}

dcmd_setvw(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 1 && !HasPermission(playerid, CREATING_INTERIORS))
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
  return 1;
 }

 new virtualworldid;

 if(sscanf(params, "d", virtualworldid))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /setvw [VWId]");
		return 1;
	}
	
	SetPlayerVirtualWorldEx(playerid, virtualworldid);
	
	new string[128];
	
	format(string, sizeof(string), "Zmieni�e� wirtualny �wiat na %d.", virtualworldid);
	SendClientMessage(playerid, COLOR_GRAD1, string);
	
	return 1;
}

dcmd_getvw(playerid, params[])
{
 #pragma unused params

 new string[64];

 format(string, sizeof(string), "Wirtualny �wiat: %d.", GetPlayerVirtualWorld(playerid));
 SendClientMessage(playerid, COLOR_GRAD1, string);
 
 return 1;
}

dcmd_check(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 1)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
  return 1;
 }

 new giveplayerid;

 if(sscanf(params, "u", giveplayerid))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /check [IdGracza/Cz��Nazwy]");
		return 1;
	}
	
	if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }

 ShowStats(playerid,giveplayerid,1);

 return 1;
}

dcmd_freeze(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 1)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
  return 1;
 }

 new giveplayerid;

 if(sscanf(params, "u", giveplayerid))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /freeze [IdGracza/Cz��Nazwy]");
		return 1;
	}
	
	if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }
 
 new string[128], giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME];

 GetPlayerNameEx(playerid, sendername, sizeof(sendername));
 GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
	
 TogglePlayerControllable(giveplayerid, 0);
	
	format(string, sizeof(string), "Admin: %s zosta� zamro�ony przez %s.", giveplayer ,sendername);
	ABroadCast(COLOR_LIGHTRED,string,1);
						
	printf("Admin: %s zamrozil %s",sendername,  giveplayer);
	
 return 1;
}

dcmd_unfreeze(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 1)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
  return 1;
 }

 new giveplayerid;

 if(sscanf(params, "u", giveplayerid))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /unfreeze [IdGracza/Cz��Nazwy]");
		return 1;
	}
	
	if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }

 new string[128], giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME];

 GetPlayerNameEx(playerid, sendername, sizeof(sendername));
 GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
	
 TogglePlayerControllable(giveplayerid, 1);
	
	format(string, sizeof(string), "Admin: %s zosta� odmro�ony przez %s.", giveplayer ,sendername);
	ABroadCast(COLOR_LIGHTRED,string,1);
						
	printf("Admin: %s odmrozil %s",sendername,  giveplayer);
	
 return 1;
}

dcmd_adminduty(playerid, params[])
{
 #pragma unused params

	if(PlayerInfo[playerid][pAdmin] > 0 && PlayerInfo[playerid][pAdmin] != 3)
	{
	 if(OnAdminDuty[playerid] == 0)
	 {
	 	SendClientMessage(playerid, COLOR_GRAD1, "Rozpocz��e� s�u�b� admina, b�dziesz teraz widzia� reporty.");
	  	OnAdminDuty[playerid] = 1;
		}
		else
		{
	 		SendClientMessage(playerid, COLOR_GRAD1, "Zako�czy�e� s�u�b� admina, od teraz nie b�dziesz widzia� �adnych report�w.");
		 	OnAdminDuty[playerid] = 0;
		}

		UpdateEverybodiesHud();

		for(new i = 0; i < MAX_PLAYERS; i++)
  		{
   			if(IsPlayerConnected(i))
   			{
    			if(hasMaskOn[i] > 0 && OnAdminDuty[playerid] == 0)
    			{
     				ShowPlayerNameTagForPlayer(playerid, i, 0);
    			}
    			else
    			{
     				if(PlayerInfo[playerid][pHiddenNametags] == 1 && OnAdminDuty[playerid] == 0)
     				{
      					ShowPlayerNameTagForPlayer(playerid, i, 0);
     				}
     				else
     				{
      					ShowPlayerNameTagForPlayer(playerid, i, 1);
     				}
    			}
			}
		}
	}
	return 1;
}

dcmd_respawnaut(playerid, params[])
{
 #pragma unused params

 if(PlayerInfo[playerid][pAdmin] < 2)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
  return 1;
 }
 
 for(new i = 1; i < MAX_VEHICLES+1; i++)
	{
		if(!IsVehicleInUse(i))
  {
   SetVehicleToRespawn(i);

   /*if(Vehicles[i][vId] != -1)
   {
    //SetTimerEx("Items_OnVehicleSpawn", 2500, 0, "d", i);
		SetVehicleNotModded(i);
   }*/
  }
	}
	
 SendClientMessageToAll(COLOR_GRAD1, "Nieu�ywane pojazdy wr�ci�y na miejsca spawnu.");
 
 return 1;
}

dcmd_respawnautszybki(playerid, params[])
{
 #pragma unused params

 if(PlayerInfo[playerid][pAdmin] < 2)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
  return 1;
 }

 for(new i = 1; i < MAX_VEHICLES+1; i++)
	{
		if(!IsVehicleInUse(i))
  {
   new Float:vposx, Float:vposy, Float:vposz, Float:vposa;
   GetVehiclePos(i, vposx, vposy, vposz);
   GetVehicleZAngle(i, vposa);
   SetVehiclePos(i, vposx, vposy, vposz);
   SetVehicleZAngle(i, vposa);
  }
	}

 SendClientMessage(playerid, COLOR_GRAD1, "Nieu�ywane pojazdy wr�ci�y na ostatnie pozycje.");

 return 1;
}

dcmd_respawnstrefa(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 2)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
  return 1;
 }
 
 new Float:radius;

 if(sscanf(params, "f", radius))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /respawnstrefa [Promie�]");
		return 1;
	}
	
	new Float:x, Float:y, Float:z;

 for(new i = 1; i<MAX_VEHICLES + 1; i++)
	{
	 GetVehiclePos(i, x, y, z);

  if(!IsVehicleInUse(i) && PlayerToPoint(radius, playerid, x, y, z))
  {
   SetVehicleToRespawn(i);

   /*if(Vehicles[i][vId] != -1)
   {
    //SetTimerEx("Items_OnVehicleSpawn", 2500, 0, "d", i);
		SetVehicleNotModded(i);
   }*/
		}
	}
 	
	SendClientMessage(playerid, COLOR_GRAD1, "Wszystkie pojazdy w okre�lonej strefie zosta�y respawnowane.");

 return 1;
}

dcmd_gotocar(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 2)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
  return 1;
 }

 new vehicleindex;

 if(sscanf(params, "d", vehicleindex))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /gotocar [IdPojazdu]");
		return 1;
	}
	
	new Float:x, Float:y, Float:z, string[128];
	GetVehiclePos(vehicleindex, x, y, z);
	GetXYInFrontOfVehicle(vehicleindex, x, y, 5.0);
	WarpPlayerToPos(playerid, x, y, z);
	
	format(string, sizeof(string), "Teleportowa�e� si� do pojazdu (SA-MP ID: %d) %s.", vehicleindex, GetVehicleName(vehicleindex));
	SendClientMessage(playerid, COLOR_GRAD1, string);
	
	return 1;
}

dcmd_fixveh(playerid, params[])
{
  #pragma unused params

  if(PlayerInfo[playerid][pAdmin] < 3)
  {
    SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
    return 1;
  }
 
  if(!IsPlayerInAnyVehicle(playerid))
	{
	  SendClientMessage(playerid, COLOR_GREY, "Nie znajdujesz si� w �adnym poje�dzie.");
    return 1;
	}
	
	new vehicleindex = GetPlayerVehicleID(playerid);
	
	RepairVehicle(vehicleindex);
	SetVehicleHealthEx(vehicleindex, 1000.0);
  SendClientMessage(playerid, COLOR_GREY, "Samoch�d zosta� naprawiony.");
 
 return 1;
}

dcmd_weather(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 4)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
  return 1;
 }

 new weatherid;

 if(sscanf(params, "d", weatherid))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /weather [IdPogody]");
		return 1;
	}
	
	if(weatherid < 0 || weatherid > 45)
 {
  if(weatherid != 150 && weatherid != 500 && weatherid != 1337)
  {
   SendClientMessage(playerid, COLOR_GREY, "Niepoprawne ID pogody.");
   return 1;
  }
  else
  {
   if(PlayerInfo[playerid][pAdmin] < 1337)
   {
    SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do ustawienia tej pogody.");
    return 1;
   }
  }
 }
	
	SetWeather(weatherid);
	actWeather = weatherid;
			
 Config_WriteInt("weather", actWeather);
			
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	 if(IsPlayerConnected(i))
	 {
		 if(GetPlayerVirtualWorld(i) == FAKE_INTERIOR_VW_ID)
   {
    SetPlayerWeather(i, 33);
   }
   if(GetPlayerInterior(i) > 0)
   {
    SetPlayerWeather(i, 1);
   }
	 }
	}
	
	new string[64];
	
	format(string, sizeof(string), "Ustawi�e� pogod� na %d.", weatherid);
	SendClientMessage(playerid, COLOR_GRAD1, string);
	
	return 1;
}

dcmd_sethp(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 2)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
  return 1;
 }

 new giveplayerid, Float:health;

 if(sscanf(params, "uf", giveplayerid, health))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /sethp [IdGracza/Cz��Nazwy] [�ycie]");
		return 1;
	}
	
	if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }
 
 if(PlayerInfo[playerid][pAdmin] < 1337 && playerid == giveplayerid)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie mo�esz ustawi� �ycia samemu sobie.");
  return 1;
 }
 
 SetPlayerHealthEx(giveplayerid, health);

 new giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME];

 GetPlayerNameEx(playerid, sendername, sizeof(sendername));
 GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
 
 printf("Admin: %s ustawi� �ycie %s na %.2f.", sendername, giveplayer, health);
	
	return 1;
}

dcmd_setarmor(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 2)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
  return 1;
 }

 new giveplayerid, Float:armor;

 if(sscanf(params, "uf", giveplayerid, armor))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /setarmor [IdGracza/Cz��Nazwy] [Zbroja]");
		return 1;
	}
	
	if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }

 if(PlayerInfo[playerid][pAdmin] < 1337 && playerid == giveplayerid)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie mo�esz ustawi� �ycia samemu sobie.");
  return 1;
 }

 SetPlayerArmour(giveplayerid, armor);

 new giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME];

 GetPlayerNameEx(playerid, sendername, sizeof(sendername));
 GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));

 printf("Admin: %s ustawi� zbroj� %s na %.2f.", sendername, giveplayer, armor);
	
	return 1;
}

dcmd_mute(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 2)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
  return 1;
 }

 new giveplayerid;

 if(sscanf(params, "u", giveplayerid))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /mute [IdGracza/Cz��Nazwy]");
		return 1;
	}
	
	if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }
 
 new string[128], giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME];
 
	GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));

	if(PlayerInfo[giveplayerid][pMuted] == 0)
	{
	 PlayerInfo[giveplayerid][pMuted] = 1;
	 
	 format(string, sizeof(string), "Admin: %s zosta� wyciszony przez %s.",giveplayer ,sendername);
		ABroadCast(COLOR_LIGHTRED, string, 1);
		
		printf("Admin: %s wyciszyl %s.", sendername, giveplayer);
	}
	else
	{
	 PlayerInfo[giveplayerid][pMuted] = 0;
	 
		format(string, sizeof(string), "Admin: %s zosta� odciszony przez %s.",giveplayer ,sendername);
		ABroadCast(COLOR_LIGHTRED, string, 1);
		
		printf("Admin: %s odciszyl %s.", sendername, giveplayer);
	}
	
	return 1;
}

dcmd_gotols(playerid, params[])
{
 #pragma unused params
 
 if(PlayerInfo[playerid][pAdmin] < 1)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
  return 1;
 }
		    else if(PlayerToPoint(12.0, playerid, 193.5294,179.0991,1003.0234)){}
 //WarpPlayerToPos(playerid, 1529.6, -1691.2, 13.3, 0, 0);
 WarpPlayerToPos(playerid, 1318.5482, 792.1910, 10.8387, 0, 0);
 
 PlayerInfo[playerid][pLocal] = 0;
	PlayerInfo[playerid][pLocalType] = 0;
	
	SendClientMessage(playerid, COLOR_GRAD1, "Zosta�e� teleportowany.");
	
	return 1;
}

dcmd_gotolv(playerid, params[])
{
 #pragma unused params
 
 if(PlayerInfo[playerid][pAdmin] < 1)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
  return 1;
 }

 WarpPlayerToPos(playerid, 1699.2, 1435.1, 10.7, 0, 0);

 PlayerInfo[playerid][pLocal] = 0;
	PlayerInfo[playerid][pLocalType] = 0;
	
	SendClientMessage(playerid, COLOR_GRAD1, "Zosta�e� teleportowany.");
	
	return 1;
}

dcmd_gotosf(playerid, params[])
{
 #pragma unused params
 
 if(PlayerInfo[playerid][pAdmin] < 1)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
  return 1;
 }

 WarpPlayerToPos(playerid, -1417.0, -295.8, 14.1, 0, 0);

 PlayerInfo[playerid][pLocal] = 0;
	PlayerInfo[playerid][pLocalType] = 0;
	
	SendClientMessage(playerid, COLOR_GRAD1, "Zosta�e� teleportowany.");
	
	return 1;
}

dcmd_endround(playerid, params[])
{
 #pragma unused params
 
 if(PlayerInfo[playerid][pAdmin] < 1337)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
  return 1;
 }
 
 GameModeInitExitFunc();
 
 return 1;
}

dcmd_jail(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 2)
 {
	 SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
	 return 1;
	}

 new reason[128], time, giveplayerid, string[128], giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME];

 if(sscanf(params, "uis", giveplayerid, time, reason))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /jail [IdGracza/Cz��Nazwy] [Czas w minutach] [Pow�d]");
		return 1;
	}
	
 if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }

 if(giveplayerid == playerid)
	{
		SendClientMessage(playerid, COLOR_GREY, "Nie mo�esz uwi�zi� samego siebie.");
		return 1;
	}
	
	if(time < 0)
	{
	 SendClientMessage(playerid, COLOR_GREY, "Czas wi�zienia nie mo�� by� mniejszy od 0.");
		return 1;
	}
	
	Log_AdminJail(playerid, giveplayerid, time, reason);
	
	PlayerInfo[giveplayerid][pJailed]   = 4;
	PlayerInfo[giveplayerid][pJailTime] = time * 60;
	SetPlayerInterior(giveplayerid, 0);
	SetPlayerPosEx(giveplayerid, 154.2834, -1952.1342, 47.8750);
	SetPlayerFacingAngle(giveplayerid, 342.0233);
	SetPlayerVirtualWorldEx(giveplayerid, giveplayerid+1);

 GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
	
	format(string, sizeof(string), "Uwi�zi�e� %s w Admin Jailu na %d minut.", giveplayer, time);
	SendClientMessage(playerid, COLOR_LIGHTRED, string);
    //format(string, sizeof(string), "Zosta�e� uwi�ziony w Admin Jailu przez %s na %d minut.", sendername, time);
	format(string, sizeof(string), "Zosta�e� uwi�ziony w Admin Jailu na: {9e1e1e}%d{a9c4e4} minut, przez: {9e1e1e}%s.\n{a9c4e4}Pow�d: {9e1e1e}%s\n\n{9e1e1e}UWAGA:\n{a9c4e4}Je�li kara by�a nies�uszna mo�esz si� odwo�a� na forum w odpowiednim dziale.\nPami�taj r�wnie� o Screenie, kt�ry jest niezb�dny do apelacji.", time, sendername, reason);
	ShowPlayerDialog(giveplayerid, DIALOG_AJ_FOR_PLAYER, DIALOG_STYLE_MSGBOX, "Admin Jail", string,"Zamknij", "");
		
	/*SendClientMessage(giveplayerid, COLOR_LIGHTRED, string);
	format(string, sizeof(string), "Pow�d: %s.", reason);
	SendClientMessage(giveplayerid, COLOR_LIGHTRED, string);*/
	
	new year, month,day;
	getdate(year, month, day);
	format(string, sizeof(string), "Admin: %s zosta� uwi�ziony w Admin Jailu przez %s, Pow�d: %s (%d-%d-%d)", giveplayer, sendername, reason, month, day, year);
	AdminJailLog(string);
	EscapePL(string);
	format(string, sizeof(string), " ~>~ Admin Jail ~<~ ~r~%s ~w~zostal uwieziony w Admin Jailu przez ~r~%s, ~w~Powod: ~r~%s%s", giveplayer, sendername, reason);
	TextDrawSetString(Kara, string);
	TextDrawShowForAll(Kara);
	KillTimer(KaraTD);
	KaraTD = SetTimer("textkara", 15000, 0);
	TextDrawHideForPlayer(giveplayerid, Kara);
	//SendClientMessageToAll(COLOR_LIGHTRED, string);
	
	return 1;
}

dcmd_tod(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 4)
 {
	 SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
	 return 1;
 }

 new hour, string[128], playername[MAX_PLAYER_NAME];

 if(sscanf(params, "i", hour))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /tod [Godzina (0-23)]");
		return 1;
	}

 if(hour < 0 || hour > 23)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /tod [Godzina (0-23)]");
		return 1;
 }

 SetWorldTimeEx(hour);
 
 format(string, sizeof(string), "Czas ustawiony na godzin� %d.", hour);
 BroadCast(COLOR_GRAD1, string);
 
 GetPlayerNameEx(playerid, playername, sizeof(playername));
 printf("Admin: %s ustawi� czas na godzin� %d.", playername, hour);
 
 return 1;
}


dcmd_logout(playerid, params[])
{
 #pragma unused params
 
 if(PlayerInfo[playerid][pAdmin] < 2)
 {
	 SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
	 return 1;
	}
	
	MySQLSetPlayerNotLogged(playerid);
	OnPlayerSave(playerid);
 Items_OnObjectUnspawn(CONTENT_TYPE_USER, PlayerInfo[playerid][pId]);
 gPlayerLogged[playerid] = 0;
 
 SendClientMessage(playerid, COLOR_GRAD1, "Wylogowa�e� si�.");
 
 return 1;
}

dcmd_logoutpl(playerid, params[])
{
 #pragma unused params

 if(PlayerInfo[playerid][pAdmin] < 2)
 {
	 SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
	 return 1;
	}
	
	new giveplayerid, string[128], sendername[MAX_PLAYER_NAME], giveplayer[MAX_PLAYER_NAME];

 if(sscanf(params, "u", giveplayerid))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /logoutpl [IdGraczy/Cz��Nazwy]");
		return 1;
	}
	
	if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }
	
	GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
	
	MySQLSetPlayerNotLogged(giveplayerid);
	OnPlayerSave(giveplayerid);
 Items_OnObjectUnspawn(CONTENT_TYPE_USER, PlayerInfo[giveplayerid][pId]);
 gPlayerLogged[giveplayerid] = 0;

 format(string, sizeof(string), "Wylogowa�e� %s.", giveplayer);
 SendClientMessage(playerid, COLOR_GRAD1, string);
 
 format(string, sizeof(string), "Zosta�e� wylogowany przez %s.", sendername);
 SendClientMessage(giveplayerid, COLOR_GRAD1, string);
 
 printf("Admin: %s wylogowa� %s.", sendername, giveplayer);

 return 1;
}

dcmd_mark(playerid, params[])
{
 #pragma unused params

 if(PlayerInfo[playerid][pAdmin] < 1)
 {
	 SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
	 return 1;
	}
	
	GetPlayerPos(playerid, TeleportDest[playerid][0], TeleportDest[playerid][1], TeleportDest[playerid][2]);
	TeleportDest[playerid][3] = GetPlayerInterior(playerid);
	TeleportDest[playerid][4] = GetPlayerVirtualWorld(playerid);
	
	TeleportDest[playerid][5] = PlayerInfo[playerid][pLocal];
 TeleportDest[playerid][6] = PlayerInfo[playerid][pLocalType];
 
 SendClientMessage(playerid, COLOR_GRAD1, "Miejsce teleportacji zosta�o zapisane.");
	
	return 1;
}

dcmd_gotomark(playerid, params[])
{
 #pragma unused params

 if(PlayerInfo[playerid][pAdmin] < 1)
 {
	 SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
	 return 1;
	}

 WarpPlayerToPos(playerid, TeleportDest[playerid][0], TeleportDest[playerid][1], TeleportDest[playerid][2], floatround(TeleportDest[playerid][3]), floatround(TeleportDest[playerid][4]));
 
 PlayerInfo[playerid][pLocal]     = floatround(TeleportDest[playerid][5]);
 PlayerInfo[playerid][pLocalType] = floatround(TeleportDest[playerid][6]);

 SendClientMessage(playerid, COLOR_GRAD1, "Teleportowa�e� si� do zapisanej pozycji.");

 return 1;
}

dcmd_clearplayer(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 2)
 {
	 SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
	 return 1;
	}
	
 new giveplayerid, string[128], giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME];

 if(sscanf(params, "u", giveplayerid))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /clearplayer [IdGracza/Cz��Nazwy]");
		return 1;
	}
	
 if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }
 
 GetPlayerNameEx(playerid, sendername, sizeof(sendername));
 GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
 
  PlayerInfo[giveplayerid][pLeader] = 0;				
	PlayerInfo[giveplayerid][pMember] = 0;
	PlayerInfo[giveplayerid][pChar]   = 0;
	PlayerInfo[giveplayerid][pModel]  = 188;
	PlayerInfo[giveplayerid][pUFMember] = MAX_UNOFFICIAL_FACTIONS+1;
	SetPlayerSkin(giveplayerid, PlayerInfo[giveplayerid][pModel]);
	MedicBill[giveplayerid]           = 0;
	SetPlayerWeapons(giveplayerid);
	RespawnPlayer(giveplayerid);
	ClearCrime(giveplayerid);
				
	format(string, sizeof(string), "Zosta�e� wyczyszczony przez %s", sendername);
	SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
	format(string, sizeof(string), "Wyczy�ci�e� %s.", giveplayer);
	SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
				
	printf("Admin: %s wyczy�ci� gracza %s.", sendername, giveplayer);
	
	return 1;
}

dcmd_ah(playerid, params[])
{
 #pragma unused params
 
 if(PlayerInfo[playerid][pAdmin] < 1)
 {
	 SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
	 return 1;
	}
	
 SendClientMessage(playerid, COLOR_LORANGE,"** Komendy administratora **");
 
 SendClientMessage(playerid, COLOR_AWHITE, "/a(dmin) /adminduty /(s)kick /jail /(s)ban /(k)warn /goto /gethere /freeze /unfreeze /recon /check /pojazdmodel");
 SendClientMessage(playerid, COLOR_AWHITE, "/setint /setplayerint /setvw /setplayervw /getvw /setskin /sethp /setarmor /respawn(aut|strefa) /sprawdzpojazdy");
 SendClientMessage(playerid, COLOR_AWHITE, "/teleport /setjob /removebw /clearplayer /logout /logoutpl /mute /mark /gotomark /goto(ls|lv|sf) /zezwoleniepojazd /awyrzuc");
 SendClientMessage(playerid, COLOR_AWHITE, "/afrisk /owned");

 // /apojazd /adrzwi /obiekty - co z nimi?

 if(PlayerInfo[playerid][pAdmin] >= 1337)
 {
  SendClientMessage(playerid, COLOR_AWHITE, "/weather /fixveh /tod /setstat /uszy /makeleader /edit");
 }
 
 return 1;
}

dcmd_makeadmin(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1337)
	{
	 SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
	 return 1;
	}
	
	new string[128], giveplayerid, level, giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME];
	
	if(sscanf(params, "ud", giveplayerid, level))
	{
	 SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /makeadmin [IdGracza/Cz��Nazwy] [Poziom (1,1337)]");
		return 1;
	}
	
	if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }
	
	GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));

 PlayerInfo[giveplayerid][pAdmin] = level;
	
	format(string, sizeof(string), "Otrzyma�e� %d poziom administratora od %s.", level, sendername);
	SendClientMessage(giveplayerid, COLOR_LORANGE, string);
	
 format(string, sizeof(string), "Da�e� %s %d poziom administratora.", giveplayer, level);
 SendClientMessage(playerid, COLOR_LORANGE, string);
						
	printf("Admin: %s mianowa� %s administratorem %d poziomu.", sendername, giveplayer, level);
						
	UpdateEverybodiesHud();
	
	return 1;
}



dcmd_awyrzuc(playerid,params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1)
	{
	 SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
	 return 1;
	}
	
	new order[12], giveplayerid;
	
	if(sscanf(params, "su", order, giveplayerid))
	{
	  SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /awyrzuc [frakcja/firma/organizacja] [IdGracza/Cz��Nazwy]");
		return 1;
	}
	
	if(giveplayerid == INVALID_PLAYER_ID)
	{
    SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
    return 1;
	}
	
	new giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME],string[MAX_STRING];
	
	if (!strcmp(order,"frakcja",true,7))
	{
	  GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
	  GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	  printf("Admin: %s has uninvited %s.", sendername, giveplayer);
	  format(string, sizeof(string), "* Zosta�e� wyrzucony z frakcji przez administratora %s.", sendername);
	  SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
	  SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, "* Znowu jeste� cywilem.");
	  PlayerInfo[giveplayerid][pMember] = 0;
	  PlayerInfo[giveplayerid][pRank] = 0;
	  new rand = random(sizeof(CIV));
	  SetSpawnInfo(giveplayerid, TEAM_NONE, CIV[rand],0.0,0.0,0.0,0,0,0,0,0,0,0);
	  PlayerInfo[giveplayerid][pModel] = CIV[rand];
	  format(string, sizeof(string), "   Wyrzuci�e� %s z frakcji.", giveplayer);
	  SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
		return 1;
	}
	else if (!strcmp(order,"firma",true,5))
	{
	  PlayerInfo[giveplayerid][pBusiness] = INVALID_BUSINESS_ID;

    GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
    GetPlayerNameEx(playerid, sendername, sizeof(sendername));

    printf("Business: %s has uninvited %s from business.", sendername, giveplayer);

    format(string, sizeof(string), "%s zwolni� Ci� z firmy.", sendername);
    SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);

    format(string, sizeof(string), "Zwolni�e� %s z firmy.", giveplayer);
    SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
		return 1;
	}
	else if (!strcmp(order,"organizacja",true,11))
	{
	  PlayerInfo[giveplayerid][pUFMember] = MAX_UNOFFICIAL_FACTIONS+1;
				
	  GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
	  GetPlayerNameEx(playerid, sendername, sizeof(sendername));
				 			
	  printf("Admin: %s wyrzucil %s.", sendername, giveplayer);
				
	  format(string, sizeof(string), "* Zosta�e� wyrzucony z organizacji przez lidera %s.", sendername);
	  SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
				 			
	  format(string, sizeof(string), "   Wyrzuci�e� %s z organizacji.", giveplayer);
	  SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
	  return 1;
	}
	else
	{
	  SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /wyrzuc [frakcja/firma/organizacja] [IdGracza/Cz��Nazwy]");
		return 1;
	}
}

dcmd_setskin(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 1)
 {
	 SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
	 return 1;
	}
	
	new string[128], giveplayerid, skinid, giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME];
	
	if(sscanf(params, "ud", giveplayerid, skinid))
	{
	 SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /setskin [IdGracza/Cz��Nazwy] [IdSkina]");
		return 1;
	}
	
	if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }
 
 if(!IsSkinValid(skinid))
 {
  SendClientMessage(playerid, COLOR_GREY, "Niepoprawny skin.");
  return 1;
 }
 
 SetPlayerSkin(giveplayerid, skinid);
 PlayerInfo[giveplayerid][pModel] = skinid;
 
 GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
 
 format(string, sizeof(string), "Administrator %s ustawi� Tw�j skin na %d.", sendername, skinid);
	SendClientMessage(giveplayerid, COLOR_LORANGE, string);
	
 format(string, sizeof(string), "Ustawi�e� %s skin %d.", giveplayer, skinid);
 SendClientMessage(playerid, COLOR_LORANGE, string);
						
	printf("Admin: %s ustawi� %s skin %d.", sendername, giveplayer, skinid);
	
	return 1;
}

dcmd_setjob(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 2)
 {
	 SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
	 return 1;
	}
	
	new string[128], giveplayerid, jobid, giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME];
	
	if(sscanf(params, "ud", giveplayerid, jobid))
	{
	 SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /setjob [IdGracza/Cz��Nazwy] [IdPracy]");
		return 1;
	}
	
	if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }
 
 if(!IsActiveJob(jobid))
 {
  SendClientMessage(playerid, COLOR_GREY, "Ta praca jest niepoprawna lub nieaktywna.");
  return 1;
 }
 
 PlayerInfo[giveplayerid][pJob] = jobid;
 
 GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));

 format(string, sizeof(string), "Administrator %s ustawi� Twoj� prac� na %s.", sendername, Jobs[jobid][jName]);
	SendClientMessage(giveplayerid, COLOR_LORANGE, string);
	
 format(string, sizeof(string), "Ustawi�e� prac� %s na (ID: %d) %s.", giveplayer, jobid, Jobs[jobid][jName]);
 SendClientMessage(playerid, COLOR_LORANGE, string);
						
	printf("Admin: %s ustawi� %s prac� na %d.", sendername, giveplayer, jobid);
 
 return 1;
}

dcmd_ban(playerid, params[], silent=0)
{
 if(PlayerInfo[playerid][pAdmin] < 2)
 {
	 SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
	 return 1;
	}

 new reason[128], str[315], string[128], giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME], giveplayerid;

 if(sscanf(params, "us", giveplayerid, reason))
	{
	 if(silent == 1)
	 {
	  SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /sban [IdGracza/Cz��Nazwy] [Pow�d]");
  }
  else
  {
   SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /ban [IdGracza/Cz��Nazwy] [Pow�d]");
  }
		return 1;
	}
	
 if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }

 if(giveplayerid == playerid)
	{
		SendClientMessage(playerid, COLOR_GRAD2, "Nie mo�esz zbanowa� samego siebie.");
		return 1;
	}

 GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));

 if(silent == 1)
 {
	 /*format(string, sizeof(string), "Admin: %s zosta� zbanowany przez %s, Pow�d: %s", giveplayer, sendername, reason);
	 SendClientMessage(giveplayerid, COLOR_LIGHTRED, string);*/
	  format(string, sizeof(string), "Zosta�e� zbanowany przez: {9e1e1e}%s, {a9c4e4}Pow�d: {9e1e1e}%s\n\n{9e1e1e}UWAGA:\n{a9c4e4}Je�li kara by�a nies�uszna mo�esz si� odwo�a� na forum w odpowidenim dziale.\nPami�taj r�wnie� o screenie, kt�ry jest niezb�dny do apelacji.", sendername, reason);
	 ShowPlayerDialog(giveplayerid, DIALOG_BAN_FOR_PLAYER, DIALOG_STYLE_MSGBOX, "Ban", string,"Zamknij", "");
	 
	 strcat(string, " (sban)");	
	 ABroadCast(COLOR_LIGHTRED,string,1);
 }
 else
 {

  //format(string, sizeof(string), "Admin: %s zosta� zbanowany przez %s, Pow�d: %s.", giveplayer, sendername, reason);
  //SendClientMessageToAll(COLOR_LIGHTRED, string);
  EscapePL(string);
   format(string, sizeof(string), "~>~ Ban ~<~ ~r~%s ~w~zostal zbanowany przez ~r~%s, ~w~Powod: ~r~%s%s", giveplayer, sendername, reason);
   	 TextDrawSetString(Kara, string);
	 TextDrawShowForAll(Kara);
	 KillTimer(KaraTD);
	 KaraTD = SetTimer("textkara", 10000, 0);
	 format(str, sizeof(str), "Zosta�e� zbanowany przez: {9e1e1e}%s, {a9c4e4}Pow�d: {9e1e1e}%s\n\n{9e1e1e}UWAGA:\n{a9c4e4}Je�li kara by�a nies�uszna mo�esz si� odwo�a� na forum w odpowiednim dziale.\nPami�taj r�wnie� o screenie, kt�ry jest niezb�dny do apelacji.", sendername, reason);
	 ShowPlayerDialog(giveplayerid, DIALOG_BAN_FOR_PLAYER, DIALOG_STYLE_MSGBOX, "Ban", str,"Zamknij", "");
	 TextDrawHideForPlayer(giveplayerid, Kara);
 }
	
	PlayerInfo[giveplayerid][pLevel]  = 1;
	PlayerInfo[giveplayerid][pMember] = 0;
	PlayerInfo[giveplayerid][pLeader] = 0;

	MySQLBanPlayer(giveplayerid, reason, playerid);

	return 1;
}

dcmd_sban(playerid, params[])
{
 return dcmd_ban(playerid, params, 1);
}

dcmd_block(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 1)
 {
	 SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
	 return 1;
	}
	
	new reason[128], str[315], string[128], giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME], giveplayerid;
	
	if(sscanf(params, "us", giveplayerid, reason))
	{
	 SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /block [IdGracza/Cz��Nazwy] [Pow�d]");
		return 1;
	}
	
	if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }
 
 if(giveplayerid == playerid)
	{
  SendClientMessage(playerid, COLOR_GREY, "Nie mo�esz zablokowa� samego siebie.");
  return 1;
 }
 
 GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
 
 new year, month,day;
	getdate(year, month, day);
	
 format(string, sizeof(string), "Admin: Konto %s zosta�o zablokowane przez %s, Pow�d: %s (%d-%d-%d)", giveplayer, sendername, reason, month, day, year);
	BanLog(string);
	
 //format(string, sizeof(string), "Admin: Konto %s zosta�o zablokowane przez %s, Pow�d: %s.", giveplayer, sendername, reason);
 format(string, sizeof(string), "~>~ Block ~<~ ~w~Konto ~r~%s ~w~zostal zablokowana przez ~r~%s, ~w~Powod: ~r~%s%s", giveplayer, sendername, reason);
 //SendClientMessageToAll(COLOR_LIGHTRED, string);
	TextDrawSetString(Kara, str);
	TextDrawShowForAll(Kara);
	KillTimer(KaraTD);
	KaraTD = SetTimer("textkara", 15000, 0);
	format(str, sizeof(str), "Twoje konto zosta�o zablokowane przez: {9e1e1e}%s, {a9c4e4}Pow�d: {9e1e1e}%s\n\n{9e1e1e}UWAGA:\n{a9c4e4}Je�li kara by�a nies�uszna mo�esz si� odwo�a� na forum w odpowienim dziale.\nPami�taj r�wnie� o screenie, kt�ry jest niezb�dny do apelacji.", sendername, reason);
	 ShowPlayerDialog(giveplayerid, DIALOG_BLOCK_FOR_PLAYER, DIALOG_STYLE_MSGBOX, "Kick", str,"Zamknij", "");
	 TextDrawHideForPlayer(giveplayerid, Kara);
	PlayerInfo[giveplayerid][pLevel]  = 1;
	PlayerInfo[giveplayerid][pMember] = 0;
	PlayerInfo[giveplayerid][pLeader] = 0;
	
	Log_Block(playerid, giveplayerid, reason);
	
	Kick(giveplayerid);
 
 return 1;
}

dcmd_admins(playerid, params[])
{
 #pragma unused params
 
 new sendername[MAX_PLAYER_NAME], string[128];
 new names[][] = {"Admin", "Supporter"};
 
 new adminscount = 0;

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(PlayerInfo[i][pAdmin] > 0 && PlayerInfo[i][pAdmin] < 4)
			{
				adminscount++;
			}
			if((PlayerInfo[i][pAdmin] > 4 && OnAdminDuty[i] == 1) || (PlayerInfo[playerid][pAdmin] > 0 && PlayerInfo[i][pAdmin] <= 4))
			{
				adminscount++;
			}
		}
	}
	
	if(adminscount > 0)
	{
		SendClientMessage(playerid, COLOR_AWHITE, "Administratorzy Online:");
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(IsPlayerConnected(i))
			{
				if((PlayerInfo[i][pAdmin] < 4 && PlayerInfo[i][pAdmin] > 0) || (PlayerInfo[i][pAdmin] > 4 && PlayerInfo[i][pAdmin] > 0) || (PlayerInfo[i][pAdmin] > 4 && PlayerInfo[i][pAdmin] != 1338 && OnAdminDuty[i] == 1))
				{
					if(OnAdminDuty[i] == 1)
					{
						GetPlayerNameEx(i, sendername, sizeof(sendername));
						format(string, sizeof(string), "%s: (ID: %d) %s (S�u�ba admina: Tak)", names[PlayerInfo[i][pAdmin] == 1 ? 1 : 0], i, sendername);
						SendClientMessage(playerid, COLOR_LORANGE, string);
					}
					else
					{
						GetPlayerNameEx(i, sendername, sizeof(sendername));
						format(string, sizeof(string), "%s: %s (S�u�ba admina: Nie)", names[PlayerInfo[i][pAdmin] == 0 ? 1 : 0], i, sendername);
						SendClientMessage(playerid, COLOR_GRAD2, string);
					}
				}
			}
		}
	}
	else
	{
	 	GameTextForPlayer(playerid, "~w~Brak administratorow ~r~on-line", 3000, 5);
	}
	
	return 1;
}

dcmd_slap(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 1)
 {
	 SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
	 return 1;
	}
	
	new string[128], giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME], giveplayerid;
	
	if(sscanf(params, "u", giveplayerid))
	{
	 SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /slap [IdGracza/Cz��Nazwy]");
		return 1;
	}
	
	if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedost�pna.");
  return 1;
 }

	new Float:vx, Float:vy, Float:vz;

	GetPlayerPos(giveplayerid, vx, vy, vz);
	SetPlayerPosEx(giveplayerid, vx, vy, vz+2.5);
	
	GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));

 format(string, sizeof(string), "Admin: %s podrzuci� gracza %s.", sendername, giveplayer);
	ABroadCast(COLOR_LIGHTRED, string, 1);
	
	printf("Admin: %s podrzuci� gracza %s",sendername,  giveplayer);
	
	return 1;
}

dcmd_playername(playerid,params[])
{
 if(PlayerInfo[playerid][pAdmin] < 1337)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
		return 1;
 }

 new giveplayerid, playername[MAX_PLAYER_NAME];

 if(sscanf(params, "us", giveplayerid, playername))
 {
  SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /playername [IdGracza/Cz��Nazwy] [NowaNazwa]");
		return 1;
 }

 if(giveplayerid == INVALID_PLAYER_ID)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Ta osoba jest niedost�pna.");
  return 1;
 }

 SetPlayerName(giveplayerid, playername);

 return 1;
}

dcmd_dajprawko(playerid,params[])
{
 if(PlayerInfo[playerid][pAdmin] < 2)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
		return 1;
 }

 new giveplayerid, sendername[MAX_PLAYER_NAME], giveplayer[MAX_PLAYER_NAME];

 if(sscanf(params, "u", giveplayerid))
 {
  SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /dajprawko [IdGracza/Cz��Nazwy]]");
		return 1;
 }

 if(giveplayerid == INVALID_PLAYER_ID)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Ta osoba jest niedost�pna.");
  return 1;
 }
 
 if(!PlayerInfo[giveplayerid][pCarLic])
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Ta osoba nie ma starego prawa jazdy.");
  return 1;
 }
 
	new nitem[pItem];
				
	nitem[iItemId] = ITEM_LICENSE_CAR;
	nitem[iCount] = 0;
	nitem[iOwner] = PlayerInfo[giveplayerid][pId];
	nitem[iOwnerType] = CONTENT_TYPE_USER;
	nitem[iPosX] = 0.0;
	nitem[iPosY] = 0.0;
	nitem[iPosZ] = 0.0;
	nitem[iPosVW] = 0;
	nitem[iFlags] = 0;
	nitem[iAttr1] = PlayerInfo[giveplayerid][pId];
	GetPlayerNameEx(giveplayerid, nitem[iAttr5], sizeof(nitem[iAttr5]));

	new id = CreateItem(nitem);

	if(id == HAS_REACHED_LIMIT)
	{
		SendClientMessage(playerid, COLOR_GREY, "Ta osoba nie mo�e posiada� wi�cej przedmiot�w.");
		return 1;
	}
	
	PlayerInfo[giveplayerid][pCarLic] = 0;
	
	GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));

	new string[128];

  format(string, sizeof(string), "Administrator %s da� Tobie prawo jazdy.", sendername);
	SendClientMessage(giveplayerid, COLOR_LORANGE, string);
	
  format(string, sizeof(string), "Da�e� %s prawo jazdy.", giveplayer);
  SendClientMessage(playerid, COLOR_LORANGE, string);
						
	printf("Admin: %s da� prawo jazdy %s.", sendername, giveplayer);
	
	return 1;
}

dcmd_reservedslots(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1337)
	{
		SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
		return 1;
	}
	
	new slots, string[128];
	
	if(sscanf(params, "d", slots))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /reservedslots [Ilo��Slot�w]");
		format(string, sizeof(string), "Ilo�� zarezerwowanych slot�w: %d.", ReservedSlots);
		return 1;
  }
	
	if(slots < 0 || slots > 5)
	{
		SendClientMessage(playerid, COLOR_GRAD2, "Niepoprawna ilo�� slot�w.");
		return 1;
	}
	
	format(string, sizeof(string), "Ilo�� zarezerwowanych slot�w zosta�a zmieniona na %d.", slots);
	SendClientMessage(playerid, COLOR_LORANGE, string);
	
	Config_WriteInt("reserved_slots", slots);
	ReservedSlots = slots;
	
	new sendername[MAX_PLAYER_NAME];
	GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	
	printf("[slots] %s ustawi� ilo�� zarezerwowanych slot�w na %d.", sendername, slots);
	
	return 1;
}

dcmd_pojazdmodel(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1)
	{
		SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
		return 1;
	}
	
	new model;
	
	if(sscanf(params, "d", model))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U�YJ: /pojazdmodel [IdModelu]");
		return 1;
  }
	
	if(!IsValidVehicleModel(model))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "Niepoprawny model.");
		return 1;
	}
	
	new string[128], c = 0;
	
	format(string, sizeof(string), "Gracze prowadz�cy (ID: %d) %s:", model, GetVehicleNameByModel(model));
	SendClientMessage(playerid, COLOR_LORANGE, string);
	
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i) && GetPlayerState(i) == PLAYER_STATE_DRIVER)
		{
			new pvehid = GetPlayerVehicleID(playerid);
			new pmodel = GetVehicleModel(pvehid);
			
			if(pmodel != model) continue;
			
			new playername[MAX_PLAYER_NAME];
			
			GetPlayerNameEx(i, playername, sizeof(playername));
			
			format(string, sizeof(string), "(ID: %d) %s, Godzin przegranych: %d, Pr�dko��: %d km/h.", i, playername, PlayerInfo[i][pConnectTime], PlayerSpeed[i]);
			SendClientMessage(playerid, COLOR_AWHITE, string);
			
			c++;
		}
	}
	
	if(!c) SendClientMessage(playerid, COLOR_GREY, "Brak graczy prowadz�cych taki pojazd.");
	
	return 1;
}

dcmd_debug(playerid, params[])
{
	#pragma unused params

	if(PlayerInfo[playerid][pAdmin] < 1337)
	{
		SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
		return 1;
	}
	
	if(MySQLDebug == 1)
	{
	  MySQLDebug = 0;
		SendClientMessage(playerid, COLOR_GREY, "Debug wy��czony!");
	}
	else
	{
		MySQLDebug = 1;
		SendClientMessage(playerid, COLOR_GREY, "Debug w��czony!");
	}
	
	mysql_debug(MySQLDebug);
	
	return 1;
}

// new string[128], giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME];

dcmd_afrisk(playerid,params[])
{

	if(PlayerInfo[playerid][pAdmin] < 2)
	{
		SendClientMessage(playerid, COLOR_GREY, "Nie jeste� uprawniony do u�ycia tej komendy!");
		return 1;
	}

 new tmp[24], idx;

 tmp = strtok(params, idx);
	
 if(!strlen(tmp))
	{
		SendClientMessage(playerid, COLOR_WHITE, "U�YJ: /afrisk [IdGracza/Cz��Nazwy]");
		return 1;
	}
		
		new giveplayerid = ReturnUser(tmp);
 
		if(giveplayerid == playerid) 
		{ 
		SendClientMessage(playerid, COLOR_GREY, "Nie mo�esz przeszuka� siebie samego."); 
		return 1; 
		}

		new giveplayer[MAX_PLAYER_NAME];
		GetPlayerNameMask(giveplayerid, giveplayer, sizeof(giveplayer));
	
		new string[128];
	
		//format(string, sizeof(string), "przeszuka� %s.", giveplayer);
		//ServerMe(playerid,string);
	
		format(string, sizeof(string), "Przedmioty %s (Pieni�dzy przy sobie: $%d):", giveplayer, GetPlayerMoneyEx(giveplayerid));
		SendClientMessage(playerid, COLOR_LORANGE, string);
		ShowObjectItemsForPlayer(CONTENT_TYPE_USER, PlayerInfo[giveplayerid][pId], playerid, params, idx, "afrisk [IdGracza/Cz��Nazwy]");
		return 1;
}
