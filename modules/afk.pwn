// Filterscript settings
#define AFK_TIME 15 // minutes
#define IsPlayerAFK(%1) (AFKCheck[%1] >= 5)

new
	AFKCheck[MAX_PLAYERS],
	AFKTimer;
	
forward CheckIfAFKing();
public CheckIfAFKing()
{
	static
  Float:OldPosX[MAX_PLAYERS],
  Float:OldPosY[MAX_PLAYERS],
  Float:OldPosZ[MAX_PLAYERS];
	
	for (new playerid = 0; playerid < MAX_PLAYERS; playerid++)
	{
		if (!IsPlayerConnected(playerid)) continue;
		if (IsPlayerNPC(playerid)) continue;
		if (PlayerInfo[playerid][pAdmin] > 0) continue;
		if (PlayerInfo[playerid][pWounded] > 0) continue;
	
		new
			Float:NewPosX,
			Float:NewPosY,
			Float:NewPosZ;

		GetPlayerPos(playerid, NewPosX, NewPosY, NewPosZ);
		
		if(NewPosX == OldPosX[playerid] && NewPosY == OldPosY[playerid] && NewPosZ == OldPosZ[playerid])
		{
			if(AFKCheck[playerid] < AFK_TIME)
			{
				AFKCheck[playerid]++;
				
				if(AFKCheck[playerid] == 5) // wykryto AFK
				{
					SendClientMessage(playerid, COLOR_GREY, "Jesteœ nieaktywny ju¿ od 5 minut.");
					SetPlayerColor(playerid,0xbdb0d0ff);
					ToggleBlipVisibilty(playerid, true);
				}
				else if(AFKCheck[playerid] == AFK_TIME - 1) // za minutê kick
				{
					SendClientMessage(playerid, COLOR_GREY, "Za minutê zostaniesz wyrzucony z serwera.");
				}
				else if(AFKCheck[playerid] == AFK_TIME)
				{
					SendClientMessage(playerid, COLOR_GREY, "Zostajesz wyrzucony z serwera z powodu d³ugiej nieaktywnoœci.");
					KickPlayer[playerid] = 1;
				}
			}
		}
		else
		{
			if(AFKCheck[playerid] > 0)
			{
				OnPlayerBackOfAFK(playerid);
			}
		
			AFKCheck[playerid] = 0;
		}
		
		OldPosX[playerid] = NewPosX;
		OldPosY[playerid] = NewPosY;
		OldPosZ[playerid] = NewPosZ;
	}
	
	return 1;
}

stock OnPlayerBackOfAFK(playerid)
{
	SetPlayerToTeamColor(playerid);
}
