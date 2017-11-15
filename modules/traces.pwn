#define AddPlayerTraceToObject(%1,%2,%3) AddObjectTraceToObject(CONTENT_TYPE_USER, PlayerInfo[%1][pId], %2, %3)

stock AddObjectTraceToObject(object_type, object_id, affected_type, affected_id)
{
	if(object_type == CONTENT_TYPE_USER)
	{
		new playerindex = GetPlayerById(object_id);
		if(playerindex != -1 && hasMaskOn[playerindex] == 1) return 1;
	}
	
	new query[200];
	
	format(query, sizeof(query), 
		"INSERT INTO `traces_trace` SET	`object_type_id` = %d, `object_id` = %d, `affected_type_id` = %d, `affected_id` = %d, `date` = NOW()",
		object_type, object_id, affected_type, affected_id);
	mysql_query(query);
	
	return 1;
}

stock ShowObjectTracesForPlayer(playerid, affected_type, affected_id)
{
	new query[256], string[128], n = 1;
	
	format(query, sizeof(query),
		"SELECT DISTINCT u.username FROM `traces_trace` t, `auth_user` u WHERE t.`object_id` = u.`id` AND t.`object_type_id` = %d AND t.`affected_type_id` = %d AND t.`affected_id` = %d ORDER BY t.`id` DESC LIMIT 10",
		CONTENT_TYPE_USER, affected_type, affected_id);
	mysql_query(query);
	mysql_store_result();
	if(mysql_num_rows() > 0)
	{
		while(mysql_fetch_row_format(query) == 1)
		{
			strreplace_fast('_', ' ', query)
			format(string, sizeof(string), "%d. %s.", n, query);
			SendClientMessage(playerid, COLOR_AWHITE, string);
		}
	}
	else
	{
	  SendClientMessage(playerid, COLOR_GREY, "Nie znaleziono ¿adnych œladów.");
	}
	
	return 1;
}

dcmd_slady(playerid, params[])
{
	if(GetPlayerOrganization(playerid) != 1 && GetPlayerOrganization(playerid) != 13 && PlayerInfo[playerid][pAdmin] < 1)
	{
		SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ uprawniony do u¿ycia tej komendy!");
		return 1;
	}

	new command[16], tmp[32], idx;
 
	tmp = strtok(params, idx);

	if(!strlen(tmp))
	{
		SendClientMessage(playerid, COLOR_LORANGE, "** Œlady **");
		SendClientMessage(playerid, COLOR_AWHITE,  "przedmiot, pojazd");
		return 1;
	}

	strmid(command, tmp, 0, sizeof(tmp), sizeof(command));
 
	if(!strcmp(command, "przedmiot", true))
  {
		tmp = strtok(params, idx);

		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /slady przedmiot [IdPrzedmiotu]");
			return 1;
		}

		new itemid = strval(tmp);
		
		if(!HasPlayerItem(playerid, itemid))
		{
			SendClientMessage(playerid, COLOR_GRAD2, "Nie posiadasz takiego przedmiotu.");
			return 1;
		}
		
		new itemindex = GetItemById(itemid);
		
		SendClientMessage(playerid, COLOR_LORANGE, "Znalezione œlady:");
		ShowObjectTracesForPlayer(playerid, CONTENT_TYPE_ITEM, Items[itemindex][iId]);
		
		return 1;
	}
	else if(!strcmp(command, "pojazd", true))
  {
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		{
			SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê w ¿adnym pojeŸdzie.");
			return 1;
		}
	
		new vehicleindex = GetPlayerVehicleID(playerid);
		
		if(Vehicles[vehicleindex][vId] == -1)
		{
			SendClientMessage(playerid, COLOR_GRAD2, "Ten pojazd nie zawiera ¿adnych œladów.");
			return 1;
		}

		SendClientMessage(playerid, COLOR_LORANGE, "Znalezione œlady:");
		ShowObjectTracesForPlayer(playerid, CONTENT_TYPE_VEHICLE, Vehicles[vehicleindex][vId]);
		
		return 1;
	}
 
 return 1;
}