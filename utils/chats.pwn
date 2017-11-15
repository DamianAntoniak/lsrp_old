stock ProxDetector(Float:radius, playerid, string[], col1, col2, col3, col4, col5)
{
	if(!IsPlayerConnected(playerid)) return 0;

	new Float:posx, Float:posy, Float:posz;
	GetPlayerPos(playerid, posx, posy, posz);
	
	new Float:tposx, Float:tposy, Float:tposz;
	
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(!IsPlayerLoggedIn(i)) continue;
			if(BigEar[i])
			{
				if(OnAdminDuty[i] == 1 && hasMaskOn[playerid] == 1)
				{
					new string2[128], playername[MAX_PLAYER_NAME];
					GetPlayerNameEx(playerid, playername, sizeof(playername));
					format(string2, sizeof(string2), "[%s] %s", playername, string);
					SendClientMessage(i, col5, string2);
				}
				else
				{
					SendClientMessage(i, col5, string);
				}
				continue;
			}
			
			if(GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(i)) continue;
			
			GetPlayerPos(i, tposx, tposy, tposz);
			
			new color = -1;
			
			if(Type8(posx, posy, posz, tposx, tposy, tposz, radius/16))
			{
				color = col1;
			}
			else if(Type8(posx, posy, posz, tposx, tposy, tposz, radius/8))
			{
				color = col2;
			}
			else if(Type8(posx, posy, posz, tposx, tposy, tposz, radius/4))
			{
				color = col3;
			}
			else if(Type8(posx, posy, posz, tposx, tposy, tposz, radius/2))
			{
				color = col4;
			}
			else if(Type8(posx, posy, posz, tposx, tposy, tposz, radius))
			{
				color = col5;
			}
			
			if(color != -1)
			{
				if(OnAdminDuty[i] == 1 && hasMaskOn[playerid] == 1)
				{
					new string2[128], playername[MAX_PLAYER_NAME];
					GetPlayerNameEx(playerid, playername, sizeof(playername));
					format(string2, sizeof(string2), "[%s] %s", playername, string);
					SendClientMessage(i, color, string2);
				}
				else
				{
					SendClientMessage(i, color, string);
				}
        
        //if(bubble) SetPlayerChatBubble(i, string, col1, radius, 5000);
			}
		}
	}
	
	return 1;
}
