// You do not need to create a textdraw for each player. Simply modify the textdraw, 
// hide the textdraw for the targetted player and show it back. Others players will 
// not notice that the textdraw has changed.

new Text:SanNews;
//new NewsTimer;
new NewsVisible = 0;

#pragma unused NewsVisible

#define HUD_FLAG_UPDATE_ALL  0
#define HUD_FLAG_UPDATE_FUEL 1

stock ShowNews(text[], bgcolor=0x000000AA)
{
 TextDrawBoxColor(SanNews, bgcolor);
 TextDrawSetString(SanNews, text);
 TextDrawShowForAll(SanNews);
 
 //KillTimer(NewsTimer);
 //NewsTimer = SetTimer("HideSanNews", 15000, 0);
 
 NewsVisible = 1;
}

stock ToggleHudVisible(playerid, visible)
{
 if(visible)
 {
  TextDrawShowForPlayer(playerid, PlayerInfo[playerid][pHud]);
  UpdatePlayerHud(playerid);
 }
 else TextDrawHideForPlayer(playerid, PlayerInfo[playerid][pHud]);
}

stock UpdateEverybodiesHud()
{
 for(new i = 0; i < MAX_PLAYERS; i++)
 {
  if(IsPlayerConnected(i))
  {
   UpdatePlayerHud(i);
  }
 }
}

stock EscapePL(name[])
{
    for(new i = 0; name[i] != 0; i++)
    {
	    if(name[i] == 'œ') name[i] = 's';
	    else if(name[i] == 'ê') name[i] = 'e';
	    else if(name[i] == 'ó') name[i] = 'o';
	    else if(name[i] == '¹') name[i] = 'a';
	    else if(name[i] == '³') name[i] = 'l';
	    else if(name[i] == '¿') name[i] = 'z';
	    else if(name[i] == 'Ÿ') name[i] = 'z';
	    else if(name[i] == 'æ') name[i] = 'c';
	    else if(name[i] == 'ñ') name[i] = 'n';
    }
}

stock UpdatePlayerHud(playerid)
{
 new string[256], string2[64];
 
 if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
 {
 	new vehicle = GetPlayerVehicleID(playerid);
 	
 	if(!IsAirVehicle(vehicle) && !IsABoat(vehicle) && !IsABike(vehicle))
 	{
 	 if(Gas[vehicle] > 0)
   {
    if(Gas[vehicle] > 10)
    {
     format(string2, sizeof(string2), "Paliwo: %.0f", Vehicles[vehicle][vFuel]);
    }
    else
    {
     format(string2, sizeof(string2), "Paliwo: ~r~%.0f~w~", Vehicles[vehicle][vFuel]);
    }

    strcat(string, string2);
   }
   else
   {
    strcat(string, "Paliwo: ~r~Brak~w~");
   }
  }
 }
 
 if(PlayerRace[playerid] && RaceStarted)
 {
  format(string2, sizeof(string2), "~n~Miejsce: %d/%d", GetPlayerRacePlace(playerid), GetBetMembersCount(RaceBetIndex));
  strcat(string, string2);
 }
 
 //strcat(string, "~n~Radio: ~r~Wylaczone~w~~n~~n~Admins: ~g~5~w~/6");
 
 if(PlayerInfo[playerid][pAdmin] > 0)
 {
  new adminsonline, adminsonduty;
  
  for(new i = 0; i < MAX_PLAYERS; i++)
  {
   if(IsPlayerConnected(i))
   {
    if(PlayerInfo[i][pAdmin] > 0)
    {
     adminsonline++;
     
     if(OnAdminDuty[i] == 1)
     {
      adminsonduty++;
     }
    }
   }
  }
  
  new colors[2][4] = {"~r~", "~g~"};
  
  format(string2, sizeof(string2), "~n~~n~Admins: %s%d~w~/%d", colors[adminsonduty > 0 ? 1 : 0], adminsonduty, adminsonline);
  strcat(string, string2);
 }
 
 if(strlen(string) > 0)
 {
  TextDrawSetString(PlayerInfo[playerid][pHud], string);
 }
 else
 {
  TextDrawSetString(PlayerInfo[playerid][pHud], " ");
 }
}

forward InitTextdraws();
public InitTextdraws()
{
    SanNews = TextDrawCreate(1.000000, 439.000000, SAN_NEWS);
	TextDrawBackgroundColor(SanNews, 255);
	TextDrawFont(SanNews, 1);
	TextDrawLetterSize(SanNews, 0.280000, 0.799999);
	TextDrawColor(SanNews, 1097458175);
	TextDrawSetOutline(SanNews, 0);
	TextDrawSetProportional(SanNews, 1);
	TextDrawSetShadow(SanNews, 0);
	TextDrawUseBox(SanNews, 1);
	TextDrawBoxColor(SanNews, 0x000000AA);
	TextDrawTextSize(SanNews, 710.000000, 0.000000);
 
 for(new i = 0; i < MAX_PLAYERS; i++)
 {
  PlayerInfo[i][pHud] = TextDrawCreate(506.000000, 396.000000, "foo");//"Paliwo: 20~n~Radio: ~r~Wylaczone~w~~n~~n~Admins: ~g~5~w~/6");
  TextDrawAlignment(PlayerInfo[i][pHud], 1);
  TextDrawBackgroundColor(PlayerInfo[i][pHud], 0x000000ff);
  TextDrawFont(PlayerInfo[i][pHud], 1);
  TextDrawLetterSize(PlayerInfo[i][pHud], 0.400000, 1.100000);
  TextDrawColor(PlayerInfo[i][pHud], 0xffffffff);
  TextDrawSetProportional(PlayerInfo[i][pHud], 1);
  TextDrawSetShadow(PlayerInfo[i][pHud], 1);
 }
}

forward HideSanNews();
public HideSanNews()
{
 TextDrawHideForAll(SanNews);
 NewsVisible = 0;
}
