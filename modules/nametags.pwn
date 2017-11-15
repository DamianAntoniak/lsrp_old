stock Nametags_Init()
{
  for(new i = 0; i < MAX_PLAYERS; i++)
	{
		PlayerInfo[i][pNametag] = Create3DTextLabel(" ", COLOR_YELLOW2, 0.0, 0.0, 0.0, 10.0, 0, 1);
	}
}

stock Description_Init()
{
  for(new i = 0; i < MAX_PLAYERS; i++)
	{
		PlayerInfo[i][pDescriptionText] = Create3DTextLabel(" ", COLOR_PURPLEF, 0.0, 0.0, 0.0, 10.0, 0, 1);
	}
}

#define PLAYER_STATE_WOUNDED 1
#define PLAYER_STATE_EATING 2
#define PLAYER_STATE_L 4


#define STATE_DECLARATION(%1,%2); if(PlayerInfo[playerid][pState2] & %1) { if(states != 0) strcat(tmp, ", "); strcat(tmp, %2); states++; }

stock Nametag_Update(playerid)
{
  new tmp[40];
  new states = 0;


  
  if(PlayerInfo[playerid][pState2] & PLAYER_STATE_WOUNDED)
  {
    if(states != 0) strcat(tmp, ", ");
    strcat(tmp, "nieprzytomny");
    states++;
  }
  
  if(PlayerInfo[playerid][pState2] & PLAYER_STATE_EATING)
  {
    if(states != 0) strcat(tmp, ", ");
    strcat(tmp, "je");
    states++;
  }
  
  if(PlayerInfo[playerid][pState2] & PLAYER_STATE_L)
  {
    if(states != 0) strcat(tmp, ", ");
    strcat(tmp, "s³ucha muzyki");
    states++;
  }
  

  new string[64];
  format(string, sizeof(string), "(%s)", tmp);
  
  if(states > 0)
  {
    Update3DTextLabelText(PlayerInfo[playerid][pNametag], COLOR_YELLOW2, string);
  }
  else
  {
    Update3DTextLabelText(PlayerInfo[playerid][pNametag], COLOR_YELLOW2, " ");
  }
  
	Attach3DTextLabelToPlayer(PlayerInfo[playerid][pNametag], playerid, 0, 0, 0.09);
}


stock Description_Update(playerid)
{
  // g³upie tricki z winy chujowego wordwrapa
  new tmp[128];
  
  strmid(tmp, PlayerInfo[playerid][pDescription], 0, strlen(PlayerInfo[playerid][pDescription]), 255);
  
  if(strlen(PlayerInfo[playerid][pDescription]) > 0) Update3DTextLabelText(PlayerInfo[playerid][pDescriptionText], COLOR_PURPLE, wordwrap(tmp));
  else Update3DTextLabelText(PlayerInfo[playerid][pDescriptionText], COLOR_PURPLEF, " ");
  
  Attach3DTextLabelToPlayer(PlayerInfo[playerid][pDescriptionText], playerid, 0, 0, -0.8);
}

stock NameTag_SetState(playerid, status)
{
  if(!(PlayerInfo[playerid][pState2] & status)) PlayerInfo[playerid][pState2] += status;
  Nametag_Update(playerid);
}

stock NameTag_RemoveState(playerid, status)
{
  if(PlayerInfo[playerid][pState2] & status) PlayerInfo[playerid][pState2] -= status;
  Nametag_Update(playerid);
}
