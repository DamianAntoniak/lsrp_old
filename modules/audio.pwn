#define RETURN_IF_NOT_CONNECTED(%1) if(PlayerInfo[%1][pAudioState] != AUDIO_STATE_CONNECTED) return 0

stock Audio_Init()
{
  Audio_SetPack("ls-rp", true);
  Audio_SetPack("Iphone_Sounds", true);
}


public Audio_OnClientDisconnect(playerid)
{
  PlayerInfo[playerid][pAudioState] = AUDIO_STATE_DISCONNECTED;
}

public Audio_OnTransferFile(playerid, file[], current, total, result)
{
	new string[128];
	format(string, sizeof(string), "Wczytywanie klienta dzwieku ~b~%d~w~/%d", current, total);
	TextDrawSetString(AudioPlugin[playerid], string);
	TextDrawShowForPlayer(playerid, AudioPlugin[playerid]);
	if(current == total)
	{
	    TextDrawSetString(AudioPlugin[playerid], "Klient dzwieku zostal pomyslnie wczytany.");
		SetTimerEx("hideaudio", 5000, 0, "d", playerid);
	}
	return 1;
}

public Audio_OnClientConnect(playerid)
{
  PlayerInfo[playerid][pAudioState] = AUDIO_STATE_DOWNLOADING;
  TextDrawShowForPlayer(playerid, AudioPlugin[playerid]);
  Audio_TransferPack(playerid);
  TextDrawSetString(AudioPlugin[playerid], "Rozpoczynam wczytywanie klienta dzwieku...");
  return 1;
}

forward hideaudio(playerid);
public hideaudio(playerid)
{
	TextDrawHideForPlayer(playerid, AudioPlugin[playerid]);
	return 1;
}

stock Audio_PlaySound(playerid, audioid, bool:pause=false, bool:loop=false, bool:downmix=false)
{
  RETURN_IF_NOT_CONNECTED(playerid);
  return Audio_Play(playerid, audioid, pause, loop, downmix);
}

stock Audio_PlaySound3D(playerid, audioid, Float:x, Float:y, Float:z, Float:distance)
{
  RETURN_IF_NOT_CONNECTED(playerid);
  new handleid = Audio_Play(playerid, audioid, false, false, true);
  Audio_Set3DPosition(playerid, handleid, x, y, z, distance);
  Audio_Resume(playerid, handleid);
  return 1;
}

stock Audio_PlayInPlaceShort(audioid, Float:x, Float:y, Float:z, Float:distance, virtualworld)
{
  for(new i = 0; i < MAX_PLAYERS; i++)
  {
    if(!IsPlayerConnected(i)) continue;
    if(GetPlayerVirtualWorld(i) != virtualworld) continue;
    new handleid = Audio_Play(i, audioid, true, false, true);
    Audio_Set3DPosition(i, handleid, x, y, z, distance);
    //Audio_Resume(i, handleid);
    SetTimerEx("Resume_Audio", 100, false, "ii", i, handleid);
  }
}

forward Resume_Audio(playerid, handleid);
public Resume_Audio(playerid, handleid)
{
    Audio_Resume(playerid, handleid);
    return 1;
}
