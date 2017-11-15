/*
~ LS-RP.net

GODFATHER RP SCRIPT by FEAR + LOS SANTOS ROLEPLAY MODIFICATIONS by BALON

@version SVN: $Id$Id$ $Author$ $l

Basic version of this script was published by FeaR, who done really huge
and good job. About 10.2007 me, Tomek and Ernest began to modify this script,
(me as programmer and Tomek and Ernest as my helpers) for LS-RP.net server.
After few months we were making a big, new polish server which
would replace Los Santos Role Play PL and Polish RP. It's using GF script,
which has really changed. A lot of new ideas have We implemented here and fixed a lot of bugs.

@copyright   2007-2010    All rights reserved (to the modification), do not copy, edit or resale.

Basic version created     by FeaR

Modified                  by Balon   <balonyo@gmail.com>
						  by Rabanbar <rabanbar@gmail.com>
                          by Wax	<damianapl17pl@gmail.com>

Polish translation        by Tomek   <tomaszyo@gmail.com>

Credits                   to Mike Venetto aka Rabanbar (he helped a lot with textes, ideas)
Credits                   to Astro.
Credits                   to Tratulla for his 2 .ini Functions.
Credits                   to the Fuel System creator on SA-MP forums.
*/

#include <a_samp>
#include <a_mysql>
#include <core>
#include <float>
#include <time>
#include <file>
#include <utils>
#include <streamer>
#include <audio>
#include <foreach>
#include <a_angle>
#include <sscanf2>



#include "defines.pwn"
// strval fix - do usuniecia przy 03
#pragma  tabsize 0
#pragma  dynamic 8192


//fix 0.3c
#define SetPlayerHoldingObject(%1,%2,%3,%4,%5,%6,%7,%8,%9) SetPlayerAttachedObject(%1,MAX_PLAYER_ATTACHED_OBJECTS-1,%2,%3,%4,%5,%6,%7,%8,%9)
#define StopPlayerHoldingObject(%1) RemovePlayerAttachedObject(%1,MAX_PLAYER_ATTACHED_OBJECTS-1)
#define IsPlayerHoldingObject(%1) IsPlayerAttachedObjectSlotUsed(%1,MAX_PLAYER_ATTACHED_OBJECTS-1)

#define HOLDING(%0) \
	((newkeys & (%0)) == (%0))

#include "variables.pwn"
#include "forwards.pwn"
#include "modules/logs.pwn"
#include "modules/vmod_protect.pwn"
#include "modules/config.pwn"
#include "modules/permissions.pwn"
#include "modules/nametags.pwn"
#include "modules/audio.pwn"
#include "modules/objects.pwn"
#include "modules/traces.pwn"
#include "modules/bets.pwn"
#include "modules/doors.pwn"
#include "modules/vehicles.pwn"
#include "modules/items.pwn"
#include "modules/organizations.pwn"
#include "modules/businesses.pwn"
#include "modules/jobs.pwn"
#include "modules/offers.pwn"
#include "modules/afk.pwn"
#include "modules/race.pwn"
#include "modules/race_track_editor.pwn"
#include "modules/textdraws.pwn"
#include "modules/help.pwn"
#include "modules/admin.pwn"
#include "modules/signals.pwn"
#include "modules/animations.pwn"
#include "modules/respray.pwn"
#include "modules/dialogs.pwn"
#include "modules/weapon_drop.pwn"
#include "modules/blocades.pwn"
#include "modules/border.pwn"
#include "modules/drugs.pwn"
#include "modules/gates.pwn"
#include "modules/siren.pwn"
#include "utils/chats.pwn"
#include "utils/misc.pwn"


/**
 * Funkcje po¿yczone, nie ma sensu wymyslaæ ko³a od nowa
 */
forward MySQLConnect(sqlhost[], sqluser[], sqlpass[], sqldb[]);
public MySQLConnect(sqlhost[], sqluser[], sqlpass[], sqldb[])
{
	print("MYSQL: Attempting to connect to server...");
	mysql_connect(sqlhost, sqluser, sqldb, sqlpass);
	//mysql_connect(const host[],const user[],const database[],const password[]);
	//mysql_select_db(sqldb);
	//mysql_debug(1);
	
	if(mysql_ping())
	{
		print("MYSQL: Database connection established.");
		return 1;
	}
	else
	{
		print("MYSQL: Connection error, retrying...");
		mysql_connect(sqlhost, sqluser, sqldb, sqlpass);
		//mysql_select_db(sqldb);
		if(mysql_ping())
		{
			print("MYSQL: Reconnection successful. We can continue as normal.");
			return 1;
		}
		else
		{
			print("MYSQL: Could not reconnect to server, terminating server...");
			SendRconCommand("exit");
			return 0;
		}
	}
}

forward MySQLCheckConnection();
public MySQLCheckConnection()
{
	if(mysql_ping())
	{
		return 1;
	}
	else
	{
		print("MYSQL: Connection seems dead, retrying...");
		MySQLDisconnect();
		MySQLConnect(MYSQL_HOST,MYSQL_USER,MYSQL_PASS,MYSQL_DB);
		if(mysql_ping())
		{
			print("MYSQL: Reconnection successful. We can continue as normal.");
			mysql_query("SET NAMES 'cp1250';");
			return 1;
		}
		else
		{
			print("MYSQL: Could not reconnect to server, terminating server...");
			SendRconCommand("exit");
			return 0;
		}
	}
}

/**
 * Koniec po¿yczania
 */
forward MySQLDisconnect();
public MySQLDisconnect()
{
	mysql_close();
	return 1;
}

forward MySQLBanPlayer(playerid, reason[], sender);
public MySQLBanPlayer(playerid, reason[], sender)
{
	new query[400];
	new ipaddress[15], escipaddress[15];
	new escreason[75];
	new playername[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME];
	new senderid;
	
	GetPlayerIp(playerid, ipaddress, sizeof(ipaddress));
	GetPlayerName(playerid, playername, sizeof(playername));
	
	mysql_real_escape_string(ipaddress, escipaddress);
	mysql_real_escape_string(reason, escreason);
	
	if(sender != 999)
	{
		GetPlayerName(sender, sendername, sizeof(sendername));
		senderid = PlayerInfo[sender][pId];
	
		format(query, sizeof(query), "INSERT INTO auth_ban SET user_id=%d, ip='%s', reason='%s', sender_id=%d, date=NOW()", PlayerInfo[playerid][pId], escipaddress, escreason, senderid);
		mysql_query(query);
	}
	else
	{
		strmid(sendername, "AntiCheat", 0, MAX_PLAYER_NAME);
		senderid = 0;
	
		format(query, sizeof(query), "INSERT INTO auth_ban SET user_id=%d, ip='%s', reason='%s', sender_id=NULL, date=NOW()", PlayerInfo[playerid][pId], escipaddress, escreason);
		mysql_query(query);
 }
	
	Kick(playerid);
	return 1;
}

forward MySQLSmsEx(pnumber, msg[], type[], sender[]);
public MySQLSmsEx(pnumber, msg[], type[], sender[])
{
	new query[256];
	new escmsg[75];
	
	mysql_real_escape_string(msg, escmsg);
	
	format(query, sizeof(query), "INSERT INTO greetings_greetings SET nick='%d', msg='%s', type='%s', sender='%s'", pnumber, msg, type, sender);
	//mysql_query(query);
	
	return 1;
}

forward MySQLIsPlayerBanned(playerid);
public MySQLIsPlayerBanned(playerid)
{
	new query[200];
	new ipaddress[15], escipaddress[15];
	new playername[MAX_PLAYER_NAME];
	
	GetPlayerIp(playerid, ipaddress, sizeof(ipaddress));
	GetPlayerName(playerid, playername, sizeof(playername));
	
	mysql_real_escape_string(ipaddress, escipaddress);
	
	format(query, sizeof(query), "SELECT (SELECT u.username FROM auth_user u WHERE u.id = b.user_id), b.reason, b.date FROM auth_ban b WHERE b.ip='%s' LIMIT 1", escipaddress);

	mysql_query(query);
 mysql_store_result();

 new row[170];

	if (mysql_num_rows() > 0)
	{
  //new field[125];
  //--new name[25], date[35], reason[100];
  new data[3][100];

	 mysql_fetch_row_format(row);
	
	 split(row, data, '|');
	
	 mysql_free_result();
	
	 format(query, sizeof(query), "SELECT e.id FROM auth_banexception e, auth_user u WHERE e.user_id=u.id AND u.username = '%s' LIMIT 1", playername);
 	mysql_query(query);
  mysql_store_result();

  if(mysql_num_rows() > 0){}
	 else
	 {
	  format(query, sizeof(query), "Twój adres IP zosta³ zbanowany (Postaæ: %s, Data: %s).", data[0], data[2]);
	  SendClientMessage(playerid, COLOR_RED, query);
	  format(query, sizeof(query), "Powód: %s", data[1]);
	  SendClientMessage(playerid, COLOR_RED, query);
	
   mysql_free_result();
	  return 0;
  }

  mysql_free_result();
  return 1;
 }
	
	mysql_free_result();
	return 1;
}

forward MySQLAccountExists(playerid);
public  MySQLAccountExists(playerid)
{
	new query[128];
	new playername[MAX_PLAYER_NAME], escplayername[MAX_PLAYER_NAME];
	

	GetPlayerName(playerid, playername, sizeof(playername));
	mysql_real_escape_string(playername, escplayername);
	
	format(query, sizeof(query), "SELECT id FROM `auth_user` WHERE BINARY username LIKE '%s' LIMIT 1", escplayername);
	mysql_query(query);
  mysql_store_result();

	if (mysql_num_rows() > 0)
	{
		new sqlid = mysql_fetch_int();
	  mysql_free_result();
    return sqlid;
	}
	else
	{
		mysql_free_result();
		return 0;
	}
}

stock IsAdminAccount(userid)
{
	new query[128];
	format(query, sizeof(query), "SELECT `user_id` FROM `auth_game_user_data` WHERE `admin` > 0 AND `user_id` = %d", userid);
	mysql_query(query);
	mysql_store_result();
	new exists = mysql_num_rows();
	mysql_free_result();
	return exists > 0 ? 1 : 0;
}

forward MySQLSetPlayerLogged(playerid);
public MySQLSetPlayerLogged(playerid)
{
	new query[128];
	
	format(query, sizeof(query), "UPDATE auth_userprofile SET online_game=1 WHERE user_id = %d", PlayerInfo[playerid][pId]);
	mysql_query(query);
	return 1;
}

forward MySQLSetPlayerNotLogged(playerid);
public MySQLSetPlayerNotLogged(playerid)
{
	new query[128];

	format(query, sizeof(query), "UPDATE auth_userprofile SET online_game=0 WHERE user_id = %d", PlayerInfo[playerid][pId]);
	mysql_query(query);
	return 1;
}

// przydziela mini frakcje jesli dany gracz jest liderem jakiejs
forward MySQLAssignMiniFaction(playerid);
public MySQLAssignMiniFaction(playerid)
{
	new query[256];
 new sendername[MAX_PLAYER_NAME];

 GetPlayerName(playerid, sendername, sizeof(sendername));

	format(query, sizeof(query), "SELECT id FROM organization_game_unofficial_factions WHERE leader_id = %d LIMIT 1", PlayerInfo[playerid][pId]);
	mysql_query(query);
	mysql_store_result();
	
	if (mysql_num_rows() > 0)
	{
  new data[10];

	 mysql_fetch_row_format(data);
	 printf("test: %s", data);
	 PlayerInfo[playerid][pUFLeader] = strval(data);
	}
	else
	{
	 PlayerInfo[playerid][pUFLeader] = MAX_UNOFFICIAL_FACTIONS+1;
	}
	
	mysql_free_result();
	return 1;
}

/**
 * Main
 */
main()
{
 print("--- Los Santos Role Play ---");
}

//------------------------------------------------------------------------------------------------------

public DollahScoreUpdate()
{
	new LevScore;
	for(new i=0; i<MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
		 #if LEVEL_MODE
   LevScore = PlayerInfo[i][pLevel];
   #else
   LevScore = 1;
   #endif
			SetPlayerScore(i, LevScore);
		}
	}
	return 1;
}

stock sright(source[], len)
{
	new retval[MAX_STRING], srclen;
	srclen = strlen(source);
	strmid(retval, source, srclen - len, srclen, MAX_STRING);
	return retval;
}

public Spectator()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(KickPlayer[i]==1) { Kick(i); }
		}
	}
}

//------------------------------------------------------------------------------------------------------

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{	
	if(PlayerInfo[playerid][pWounded] > 0)
	{
	   ApplyAnimationWounded(playerid);
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid,x,y,z);
		SetPlayerPosEx(playerid,x,y,z);
		return 1;
	}
	
	new Float:pArmour;
	GetPlayerArmour(playerid, pArmour);

	// fix na zbroje w wozie swat
	if(GetVehicleModel(vehicleid) == 427)
	{
		armourFix[playerid] = pArmour;
	}

	new slapplayer = 0;
	new newcar = vehicleid;

	if(!ispassenger)
	{
		if(IsABoat(newcar))
		{
		 if(PlayerInfo[playerid][pBoatLic] < 1)
			{
			 SendClientMessage(playerid, COLOR_GREY, "Nie wiesz jak ¿eglowaæ, wiêc opuszczasz ³ódŸ !");
			 slapplayer = 1;
			}
		}
		else if(IsAirVehicle(newcar))
		{
			if(PlayerInfo[playerid][pFlyLic] < 1)
			{
				if(TakingLesson[playerid] == 1) { }
				else
				{
					SendClientMessage(playerid, COLOR_GREY, "Nie wiesz jak lataæ, wiêc opuszczasz pojazd!");
					slapplayer = 1;
				}
			}
		}
	}
	
	 if(!ispassenger && !CanAccessVehicleByIndex(playerid, vehicleid) && Vehicles[vehicleid][vOwnerType] != CONTENT_TYPE_USER)
	 {
	  slapplayer = 1;
	
	  SendClientMessage(playerid, COLOR_GRAD1, "Nie posiadasz klucza do tego pojazdu.");
	 }
	
	 if(slapplayer == 1)
	 {
	  new Float:spX, Float:spY, Float:spZ;
	  GetPlayerPos(playerid, spX, spY, spZ);
	  SetPlayerPosEx(playerid, spX, spY, spZ);
	 }
	
	if((Vehicles[newcar][vId] != -1 && Vehicles[newcar][vLocked] == 1))// || gCarLock[newcar] == 1)
 {
	 SendClientMessage(playerid, COLOR_GREY, "Ten pojazd jest zamkniêty.");
	 
	 

  new Float:spX, Float:spY, Float:spZ;
	 GetPlayerPos(playerid, spX, spY, spZ);
	 SetPlayerPosEx(playerid, spX, spY, spZ);
	}
	
	return 1;
}

public IsAtClothShop(playerid)
{
    if(IsPlayerConnected(playerid))
	{
        if(PlayerToPoint(25.0,playerid,207.5627,-103.7291,1005.2578) || PlayerToPoint(25.0,playerid,203.9068,-41.0728,1001.8047))
		{//Binco & Suburban
		    return 1;
		}
		else if(PlayerToPoint(30.0,playerid,214.4470,-7.6471,1001.2109) || PlayerToPoint(50.0,playerid,161.3765,-83.8416,1001.8047))
		{//Zip & Victim
		    return 1;
		}
	}
	return 0;
}

public IsAtGasStation(playerid)
{
    if(IsPlayerConnected(playerid))
	{
		if(PlayerToPoint(6.0,playerid,1004.0070,-939.3102,42.1797) || PlayerToPoint(6.0,playerid,1944.3260,-1772.9254,13.3906))
		{//LS
		    return 1;
		}
		else if(PlayerToPoint(6.0,playerid,-90.5515,-1169.4578,2.4079) || PlayerToPoint(6.0,playerid,-1609.7958,-2718.2048,48.5391))
		{//LS
		    return 1;
		}
		else if(PlayerToPoint(6.0,playerid,124.611107, 1931.625000, 19.037874) || PlayerToPoint(6.0, playerid, -92.1366,-1169.7959,2.4391))
		{// wojsko
		  return 1;
		}
		//else if(PlayerToPoint(6.0,playerid,-2029.4968,156.4366,28.9498) || PlayerToPoint(8.0,playerid,-2408.7590,976.0934,45.4175))
		//{//SF
		//    return 1;
		//}
		else if(PlayerToPoint(5.0,playerid,-2243.9629,-2560.6477,31.8841) || PlayerToPoint(8.0,playerid,-1676.6323,414.0262,6.9484))
		{//Between LS and SF
		    return 1;
		}
		else if(PlayerToPoint(6.0,playerid,1267.4773, 1248.4735, 14.552) || PlayerToPoint(6.0,playerid,655.4480,-564.5933,16.3359)) // w LS-BG i Akademii
		{
		 return 1;
		}
		else if(PlayerToPoint(8.0,playerid,655.8789,-565.0969,16.3359))
		{//LV
		    return 1;
		}/*
		else if(PlayerToPoint(8.0,playerid,-1328.8250,2677.2173,49.7665) || PlayerToPoint(6.0,playerid,70.3882,1218.6783,18.5165))
		{//LV
		    return 1;
		}
		else if(PlayerToPoint(8.0,playerid,2113.7390,920.1079,10.5255) || PlayerToPoint(6.0,playerid,-1327.7218,2678.8723,50.0625))
		{//LV
		    return 1;
		}*/
	}
	return 0;
}

public IsAtFishPlace(playerid)
{
	if(IsPlayerConnected(playerid))
	{
	    if(PlayerToPoint(1.0,playerid,403.8266,-2088.7598,7.8359) || PlayerToPoint(1.0,playerid,398.7553,-2088.7490,7.8359))
		{//Fishplace at the bigwheel
		    return 1;
		}
		else if(PlayerToPoint(1.0,playerid,396.2197,-2088.6692,7.8359) || PlayerToPoint(1.0,playerid,391.1094,-2088.7976,7.8359))
		{//Fishplace at the bigwheel
		    return 1;
		}
		else if(PlayerToPoint(1.0,playerid,383.4157,-2088.7849,7.8359) || PlayerToPoint(1.0,playerid,374.9598,-2088.7979,7.8359))
		{//Fishplace at the bigwheel
		    return 1;
		}
		else if(PlayerToPoint(1.0,playerid,369.8107,-2088.7927,7.8359) || PlayerToPoint(1.0,playerid,367.3637,-2088.7925,7.8359))
		{//Fishplace at the bigwheel
		    return 1;
		}
		else if(PlayerToPoint(1.0,playerid,362.2244,-2088.7981,7.8359) || PlayerToPoint(1.0,playerid,354.5382,-2088.7979,7.8359))
		{//Fishplace at the bigwheel
		    return 1;
		}
	}
	return 0;
}

public IsAtCookPlace(playerid)
{
	if(IsPlayerConnected(playerid))
	{
	 if(PlayerToPoint(3.0,playerid,369.9786,-4.0798,1001.8589))
	 {//Cluckin Bell
	  return 1;
	 }
	 else if(PlayerToPoint(3.0,playerid,376.4466,-60.9574,1001.5078) || PlayerToPoint(3.0,playerid,378.1215,-57.4928,1001.5078))
		{//Burgershot
		 return 1;
		}
		else if(PlayerToPoint(3.0,playerid,374.1185,-113.6361,1001.4922) || PlayerToPoint(3.0,playerid,377.7971,-113.7668,1001.4922))
		{//Well Stacked Pizza
		 return 1;
		}
	}
	return 0;
}

forward IsAtBank(playerid);
public IsAtBank(playerid)
{
 if(IsPlayerConnected(playerid))
 {
  if(PlayerToPoint(10.0, playerid, 2311.9158,-6.4845,26.7422))
  {
   return 1;
  }
 }
 return 0;
}

public IsAtBar(playerid)
{
    if(IsPlayerConnected(playerid))
	{
		if(PlayerToPoint(4.0,playerid,495.7801,-76.0305,998.7578) || PlayerToPoint(4.0,playerid,499.9654,-20.2515,1000.6797))
		{//In grove street bar (with girlfriend), and in Havanna
		    return 1;
		}
		else if(PlayerToPoint(4.0,playerid,1215.9480,-13.3519,1000.9219) || PlayerToPoint(10.0,playerid,-2658.9749,1407.4136,906.2734))
		{//PIG Pen
		    return 1;
		}
		else if(PlayerToPoint(4.0,playerid,-785.3683,501.0689,1371.7422) || PlayerToPoint(9.0, playerid, 967.7076,-46.4535,1001.1172))// groove
		{
		 return 1;
	 }
	 else if(PlayerToPoint(4.0,playerid,1524.6733,-1845.0468,13.5702) || PlayerToPoint(4.0, playerid, 2500.0110,-1710.2867,1014.7422))
	 {
	  return 1;
  }
  else if(PlayerToPoint(7.5,playerid,1139.7184,-4.0225,1000.6719) || PlayerToPoint(7.5, playerid, -223.3029,1404.5865,27.7734)) // ufo bar Vagos
  {// kasyno yakuzy
   return 1;
  }
  else if(PlayerToPoint(7.5, playerid, 681.5106,-456.1122,-25.6099) || PlayerToPoint(15.0, playerid, 943.1820,6.2946,1000.9297)) // bar
  {
   return 1;
  }
	}
	return 0;
}


stock GetConnectedPlayersCount()
{
	new count = 0;
	
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i)) count++;
	}
	
	return count;
}

//------------------------------------------------------------------------------------------------------

public OnPlayerConnect(playerid)
{
    ResetPlayerWeapons(playerid);
    BorderTimer(playerid);
 //	ShowPlayerMarkers(0);
    //SetPlayerPosEx(playerid, 0.0,0.0,0.0);
    
    TextDrawShowForPlayer(playerid, Textdraw1);
	TextDrawShowForPlayer(playerid, Textdraw2);
	new plname[MAX_PLAYER_NAME];
	HidePM[playerid] = 0; PhoneOnline[playerid] = 0; 
	HideLSN[playerid] = 0; CellularPhone[playerid] = 0;
	GettingJob[playerid] = 0; MatsTaken[playerid] = 0;
    ApprovedLawyer[playerid] = 0; CallLawyer[playerid] = 0; WantLawyer[playerid] = 0;
	KickPlayer[playerid] = 0; CurrentMoney[playerid] = 0; UsedFind[playerid] = 0;
	CP[playerid] = 0; Robbed[playerid] = 0; SpawnChange[playerid] = 1;
	RobbedTime[playerid] = 0;
	RepairOffer[playerid] = 999; RepairPrice[playerid] = 0; RepairCar[playerid] = 0;
	TalkingLive[playerid] = 255; LiveOffer[playerid] = 999; TakingLesson[playerid] = 0;
	RefillOffer[playerid] = 999; RefillPrice[playerid] = 0;
	DrugOffer[playerid] = 999; PlayerCuffed[playerid] = 0; PlayerCuffedTime[playerid] = 0;
	DrugPrice[playerid] = 0;
	DrugGram[playerid] = 0;
	JailPrice[playerid] = 0; MedicTime[playerid] = 0; NeedMedicTime[playerid] = 0; MedicBill[playerid] = 0;
	WantedPoints[playerid] = 0;
	OnDuty[playerid] = 0; WantedLevel[playerid] = 0;
	BoxWaitTime[playerid] = 0; SchoolSpawn[playerid] = 0;
	SafeTime[playerid] = 60; TransportDuty[playerid] = 0; PlayerTied[playerid] = 0;
	TaxiCallTime[playerid] = 0; MedicCallTime[playerid] = 0; MechanicCallTime[playerid] = 0;
	FindTimePoints[playerid] = 0; FindTime[playerid] = 0; JobDuty[playerid] = 0; PizzaDuty[playerid] = 0;
	Mobile[playerid] = 255; BoxOffer[playerid] = 999; PlayerBoxing[playerid] = 0;
	Spectate[playerid] = INVALID_PLAYER_ID; PlayerDrunk[playerid] = 0; PlayerDrunkTime[playerid] = 0;
	Unspec[playerid][sLocal] = 255; FishCount[playerid] = 0;
    gLastCar[playerid] = 0; gLastCarPassenger[playerid] = 0;
	BigEar[playerid] = 0; gFam[playerid] = 0;
	gPlayerLogged[playerid] = 0; gPlayerLogTries[playerid] = 0; gPlayerAccount[playerid] = 0; gPlayerLogged2[playerid] = 0; setSpawnOnSpawn[playerid] = 0;
	gPlayerSpawned[playerid] = 0; BlocadePlayerIsSetting[playerid] = OBJECT_INVALID_ID;
	PlayerTazeTime[playerid] = 0; PlayerStoned[playerid] = 0;
	TicketOffer[playerid] = 999; TicketMoney[playerid] = 0;
	MatsHolding[playerid] = 0; DeadReason[playerid] = 0;
	TaxiAccepted[playerid] = 999; BusAccepted[playerid] = 999;
	NoFuel[playerid] = 0;
	HireCar[playerid] = 999; 
	TransportValue[playerid] = 0; TransportMoney[playerid] = 0; TransportTime[playerid] = 0; TransportCost[playerid] = 0; TransportDriver[playerid] = 999;
	GodMode[playerid] = 0; AFKCheck[playerid] = 0;
	WatchingTV[playerid] = 0; acceptDeath[playerid] = 0;
	Fishes[playerid][pLastFish] = 0; Fishes[playerid][pFishID] = 0;
    KillTimer(safeTimer[playerid]); IsPlayerSafe[playerid] = 1; // fix na szpital
    Injured[playerid] = 0;


 #if TIKI_EVENT
 PlayerInfo[playerid][pTiki] = 0;
 #endif
 PlayerInfo[playerid][pId] = -1;
 PlayerInfo[playerid][pOrderVehicle] = 0;
 PlayerInfo[playerid][pVehiclesInterval] = 0;
 PlayerInfo[playerid][pVehicleSpawnInterval] = 0;
 gAtmTimer[playerid] = 0;
 armourFix[playerid] = 0.0;
 skipAntyCheat[playerid] = 0;
 pizzaOrders[playerid] = 0;
 gLogged2[playerid] = 0;
 GivePlayerMoneyEx(playerid,PlayerInfo[playerid][pCash]);
	PlayerInfo[playerid][pRadioChannel] = INVALID_RADIO_CHANNEL;
	PlayerInfo[playerid][pVehicleBuyPermission] = 0;
	PlayerInfo[playerid][pTalkStyle] = 0;
	PlayerInfo[playerid][pLevel] = 0;
	PlayerInfo[playerid][pAdmin] = 0;
	PlayerInfo[playerid][pPremium] = 0;
	PlayerInfo[playerid][pConnectTime] = 0;
	PlayerInfo[playerid][pSex] = 0;
	PlayerInfo[playerid][pAge] = 0;
	PlayerInfo[playerid][pAccount] = 0;
	PlayerInfo[playerid][pCrimes] = 0;
	PlayerInfo[playerid][pDeaths] = 0;
	PlayerInfo[playerid][pArrested] = 0;
	PlayerInfo[playerid][pWantedDeaths] = 0;
	PlayerInfo[playerid][pFishes] = 0;
	PlayerInfo[playerid][pBiggestFish] = 0;
	PlayerInfo[playerid][pJob] = 0;
	PlayerInfo[playerid][pPayCheck] = 0;
	PlayerInfo[playerid][pHeadValue] = 0;
	PlayerInfo[playerid][pJailed] = 0;
	PlayerInfo[playerid][pJailTime] = 0;
	PlayerInfo[playerid][pMats] = 0;
	PlayerInfo[playerid][pDrugs] = 0;
	PlayerInfo[playerid][pLeader] = 0;
	PlayerInfo[playerid][pMember] = 0;
	PlayerInfo[playerid][pUFLeader] = MAX_UNOFFICIAL_FACTIONS+1;
	PlayerInfo[playerid][pUFMember] = MAX_UNOFFICIAL_FACTIONS+1;
	PlayerInfo[playerid][pRank] = 0;
	PlayerInfo[playerid][pChar] = 0;
	PlayerInfo[playerid][pContractTime] = 0;
	PlayerInfo[playerid][pDetSkill] = 0;
	PlayerInfo[playerid][pSexSkill] = 0;
	PlayerInfo[playerid][pBoxSkill] = 0;
	PlayerInfo[playerid][pLawSkill] = 0;
	PlayerInfo[playerid][pMechSkill] = 0;
	PlayerInfo[playerid][pJackSkill] = 0;
	PlayerInfo[playerid][pCarSkill] = 0;
	PlayerInfo[playerid][pNewsSkill] = 0;
	PlayerInfo[playerid][pDrugsSkill] = 0;
	PlayerInfo[playerid][pWeaponsSkill] = 0;
	PlayerInfo[playerid][pCookSkill] = 0;
	PlayerInfo[playerid][pFishSkill] = 0;
	PlayerInfo[playerid][pColtSkill] = 0;
	PlayerInfo[playerid][pPos_x] = 2246.6;
	PlayerInfo[playerid][pPos_y] = -1161.9;
	PlayerInfo[playerid][pPos_z] = 1029.7;
	PlayerInfo[playerid][pPos_a] = 0.0;
	PlayerInfo[playerid][pPos_VW] = 0;
	PlayerInfo[playerid][pInt] = 15;
	PlayerInfo[playerid][pLocal] = 0;
	PlayerInfo[playerid][pLocalType] = 0;
	PlayerInfo[playerid][pModel] = 188;
	PlayerInfo[playerid][pPhousekey] = 0;
	PlayerInfo[playerid][pBusiness] = INVALID_BUSINESS_ID;
	PlayerInfo[playerid][pCarLic] = 0;
	PlayerInfo[playerid][pFlyLic] = 0;
	PlayerInfo[playerid][pBigFlyLic] = 0;
	PlayerInfo[playerid][pBoatLic] = 0;
	PlayerInfo[playerid][pFishLic] = 0;
	PlayerInfo[playerid][pGunLic] = 0;
	PlayerInfo[playerid][pPayDay] = 0;
	PlayerInfo[playerid][pPayDayHad] = 0;
	PlayerInfo[playerid][pWins] = 0;
	PlayerInfo[playerid][pLoses] = 0;
	PlayerInfo[playerid][pWarns] = 0;
	PlayerInfo[playerid][pWasCrash] = 0;
	PlayerInfo[playerid][pNeedMedicTime] = 0;
	PlayerInfo[playerid][pHotelId] = -1;
	PlayerInfo[playerid][pThiefSkill] = 0;
	PlayerInfo[playerid][pThiefInterval] = 0;
 PlayerInfo[playerid][pMatsHolding] = 0;
 PlayerInfo[playerid][pPass] = 0;
 PlayerInfo[playerid][pPermit] = 0;
	PlayerInfo[playerid][pPayment] = 0;
	PlayerInfo[playerid][pActivated] = 0;
 PlayerInfo[playerid][pDuty] = 0;
 PlayerInfo[playerid][pMask] = 0;
 PlayerInfo[playerid][pPermissions] = 0;
 PlayerInfo[playerid][pStoppedVehicleInterval] = 0;
 PlayerInfo[playerid][pInjuriesTime] = 0;
 PlayerInfo[playerid][pLastPmRecipient] = -2;
 PlayerInfo[playerid][pInteriorAudio] = 0;
 PlayerInfo[playerid][pState] = 0;
 PlayerInfo[playerid][pState2] = 0;

 PlayerWeapons[playerid][pGun1]    = 0;
 PlayerWeapons[playerid][pAmmo1]   = 0;
 PlayerWeapons[playerid][pGun2]    = 0;
 PlayerWeapons[playerid][pAmmo2]   = 0;
 PlayerWeapons[playerid][pGun3]    = 0;
 PlayerWeapons[playerid][pAmmo3]   = 0;
 PlayerWeapons[playerid][pGun4]    = 0;
 PlayerWeapons[playerid][pAmmo4]   = 0;
 PlayerWeapons[playerid][pGun5]    = 0;
 PlayerWeapons[playerid][pAmmo5]   = 0;
 PlayerWeapons[playerid][pGun6]    = 0;
 PlayerWeapons[playerid][pAmmo6]   = 0;
 PlayerWeapons[playerid][pGun7]    = 0;
 PlayerWeapons[playerid][pAmmo7]   = 0;
 PlayerWeapons[playerid][pGun8]    = 0;
 PlayerWeapons[playerid][pAmmo8]   = 0;
 PlayerWeapons[playerid][pGun9]    = 0;
 PlayerWeapons[playerid][pAmmo9]   = 0;
 PlayerWeapons[playerid][pGun10]   = 0;
 PlayerWeapons[playerid][pAmmo10]  = 0;
 PlayerWeapons[playerid][pGun11]   = 0;
 PlayerWeapons[playerid][pAmmo11]  = 0;
 PlayerWeapons[playerid][pGun12]   = 0;
 PlayerWeapons[playerid][pAmmo12]  = 0;

 disableAntyCheat[playerid] = 0;
 RepairingVehicle[playerid] = 0;
 RepairingVehicleOwner[playerid] = 0;
 IsRepairing[playerid] = 0;
 IllegalOrderReady[playerid] = 0;
 onlogin[playerid] = 0;
 hasMaskOn[playerid] = 0;
 IsAllowedToPizzaBike[playerid] = 0;
 OnAdminDuty[playerid] = 0;
 NotPlayersMobile[playerid] = 0;
 HadACrash[playerid] = 0;
 deadPosition[playerid][dpDeath] = 0;
 deadPosition[playerid][dpDeathReason] = 0;

 gPlayerUsingLoopingAnim[playerid] = 0;
	gPlayerAnimLibsPreloaded[playerid] = 0;
	
	PlayerInfo[playerid][pAudioState] = AUDIO_STATE_DISCONNECTED;

	ClearCrime(playerid);
	ClearFishes(playerid);
	ClearMarriage(playerid);
	SetPlayerColor(playerid,COLOR_GRAD2);
	GetPlayerName(playerid, plname, sizeof(plname));
	// czyscimy konsole
	ClearConsole(playerid);
	
	#if CORPSES
	// wpuszczamy boty bezwzglêdnie
	if(IsPlayerNPC(playerid))
	{
		Corpse_HandleNPC(playerid, plname);
		
		return 1;
	}
	#endif
	
	// time
	if(charfind(plname,'_') < 1 || charfind(plname,'_') >= strlen(plname))
	{
	 SendClientMessage(playerid,COLOR_RED,"Twój nick powinien sk³adaæ siê z imienia i nazwiska oddzielonego znakiem podkreœlenia.");
	
	 KickPlayer[playerid] = 1;
	 return 0;
	}
	
 if(!MySQLIsPlayerBanned(playerid))
 {
  KickPlayer[playerid] = 1;
  return 0;
 }
	
	new usersqlid = MySQLAccountExists(playerid);
	
	if(usersqlid != 0)
	{
		new isadminaccount = IsAdminAccount(usersqlid);
		
		if(GetConnectedPlayersCount() > GetMaxPlayers() - ReservedSlots && !isadminaccount)
		{
			SendClientMessage(playerid, COLOR_WHITE, "Slot jest zarezerwowany dla administracji, przepraszamy.");
			
			KickPlayer[playerid] = 1;
			return 0;
		}
		
		new playerip[25];
		GetPlayerIp(playerid, playerip, sizeof(playerip));
		
		if(isadminaccount)
		{
			Log_Connection(playerip, usersqlid);
			
			SendClientMessage(playerid, COLOR_LIGHTRED, "Uwaga: Próbujesz zalogowaæ siê na konto administratora. Ka¿de po³¹czenie jest logowane.");
			SendClientMessage(playerid, COLOR_LIGHTRED, "Nieautoryzowane po³¹czenia z kontem administratora bêd¹ egzekwowane jak w³amanie na konto.");
		}
	
		gPlayerAccount[playerid] = 1;
		//SendClientMessage(playerid, COLOR_YELLOW, "Komunikat: Twój nick jest zarejestrowany, mo¿esz siê zalogowaæ");
		//SendClientMessage(playerid, COLOR_WHITE, "WSKAZÓWKA: Mo¿esz siê zalogowaæ za pomoc¹ komendy /zaloguj [has³o]");

		SetPlayerVirtualWorldEx(playerid, 202);
		
		return 1;
	}
	else
	{
		gPlayerAccount[playerid] = 0;
		ShowPlayerDialog(playerid, DIALOG_NO_ACCOUNT, DIALOG_STYLE_MSGBOX, "Brak konta", "Nie posiadasz konta. Aby do³¹czyæ do grona naszej spo³ecznoœci\nwejdŸ na {E0CA0D}www.ls-rp.net{a9c4e4} i stwórz postaæ!", "Zamknij", "");
		KickPlayer[playerid] = 1;
		return 1;
	}
}

public ClearMarriage(playerid)
{
	if(IsPlayerConnected(playerid))
	{
	 new string[MAX_PLAYER_NAME];
		format(string, sizeof(string), "Z nikim");
		strmid(PlayerInfo[playerid][pMarriedTo], string, 0, strlen(string), 255);
		PlayerInfo[playerid][pMarried] = 0;
	}
	return 1;
}

public ClearCrime(playerid)
{
	if(IsPlayerConnected(playerid))
	{
		new string[MAX_PLAYER_NAME];
		format(string, sizeof(string), "********");
		strmid(PlayerCrime[playerid][pBplayer], string, 0, strlen(string), 255);
		strmid(PlayerCrime[playerid][pVictim], string, 0, strlen(string), 255);
		strmid(PlayerCrime[playerid][pAccusing], string, 0, strlen(string), 255);
		strmid(PlayerCrime[playerid][pAccusedof], string, 0, strlen(string), 255);
	}
	return 1;
}

public FishCost(playerid, fish)
{
	if(IsPlayerConnected(playerid))
	{
		new cost = 0;
		switch (fish)
		{
		 case 1:
		 {
		  cost = 1;
		 }
		 case 2:
		 {
		  cost = 3;
	  }
		 case 3:
		 {
		  cost = 3;
		 }
		 case 5:
		 {
		  cost = 5;
		 }
		 case 6:
		 {
		  cost = 2;
		 }
		 case 8:
		 {
		  cost = 8;
		 }
		 case 9:
		 {
		  cost = 12;
   }
		 case 11:
		 {
		  cost = 9;
   }
		 case 12:
		 {
		  cost = 7;
	  }
		 case 14:
		 {
		  cost = 12;
		 }
		 case 15:
		 {
		  cost = 9;
	  }
		 case 16:
		 {
		  cost = 7;
		 }
		 case 17:
		 {
		  cost = 7;
	  }
		 case 18:
		 {
		  cost = 10;
		 }
		 case 19:
		 {
		  cost = 4;
		 }
		 case 21:
		 {
		  cost = 3;
		 }
		}
		return cost;
	}
	return 0;
}

public ClearFishes(playerid)
{
	if(IsPlayerConnected(playerid))
	{
	 Fishes[playerid][pFid1] = 0; Fishes[playerid][pFid2] = 0; Fishes[playerid][pFid3] = 0;
		Fishes[playerid][pFid4] = 0; Fishes[playerid][pFid5] = 0;
		Fishes[playerid][pWeight1] = 0; Fishes[playerid][pWeight2] = 0; Fishes[playerid][pWeight3] = 0;
		Fishes[playerid][pWeight4] = 0; Fishes[playerid][pWeight5] = 0;
		new string[MAX_PLAYER_NAME];
		format(string, sizeof(string), "Brak");
		strmid(Fishes[playerid][pFish1], string, 0, strlen(string), 255);
		strmid(Fishes[playerid][pFish2], string, 0, strlen(string), 255);
		strmid(Fishes[playerid][pFish3], string, 0, strlen(string), 255);
		strmid(Fishes[playerid][pFish4], string, 0, strlen(string), 255);
		strmid(Fishes[playerid][pFish5], string, 0, strlen(string), 255);
	}
	return 1;
}

public ClearFishID(playerid, fish)
{
	if(IsPlayerConnected(playerid))
	{
		new string[MAX_PLAYER_NAME];
		format(string, sizeof(string), "Brak");
		switch (fish)
		{
		    case 1:
		    {
		        strmid(Fishes[playerid][pFish1], string, 0, strlen(string), 255);
		        Fishes[playerid][pWeight1] = 0;
		        Fishes[playerid][pFid1] = 0;
		    }
		    case 2:
		    {
		        strmid(Fishes[playerid][pFish2], string, 0, strlen(string), 255);
		        Fishes[playerid][pWeight2] = 0;
		        Fishes[playerid][pFid2] = 0;
		    }
		    case 3:
		    {
		        strmid(Fishes[playerid][pFish3], string, 0, strlen(string), 255);
		        Fishes[playerid][pWeight3] = 0;
		        Fishes[playerid][pFid3] = 0;
		    }
		    case 4:
		    {
		        strmid(Fishes[playerid][pFish4], string, 0, strlen(string), 255);
		        Fishes[playerid][pWeight4] = 0;
		        Fishes[playerid][pFid4] = 0;
		    }
		    case 5:
		    {
		        strmid(Fishes[playerid][pFish5], string, 0, strlen(string), 255);
		        Fishes[playerid][pWeight5] = 0;
		        Fishes[playerid][pFid5] = 0;
		    }
		}
	}
	return 1;
}



//------------------------------------------------------------------------------------------------------
public OnPlayerDisconnect(playerid, reason)
{
 new playername[MAX_PLAYER_NAME];
 // Object_OnPlayerDisconnect(playerid, reason);
 KillTimer(TalkStyleSelectTimer[playerid]);
 KillTimer(safeTimer[playerid]);
 KillTimer(HadACrashTimer[playerid]);
 KillTimer(PizzaBikeTimer[playerid]);
 KillTimer(UnMuteTimer[playerid]);
 //-------------------[Telefon textdrawn]----------------------
 TextDrawShowForPlayer(playerid, p3);
 TextDrawShowForPlayer(playerid, p4); 
 TextDrawShowForPlayer(playerid, p5);
 //---------------------[Textura Iphona]-----------------------
 TextDrawHideForPlayer(playerid, txtSprite1); 
 //---------------------[Textura Iphona Aparat]----------------
 TextDrawHideForPlayer(playerid, txtSprite2);

 if (Painters[playerid][timer] != INVALID_TIMER)
 {
   KillTimer(Painters[playerid][timer]);
   Painters[playerid][timer] = INVALID_TIMER;
 }

 Bets_OnPlayerDisconnect(playerid, reason);
 Items_OnObjectUnspawn(CONTENT_TYPE_USER, PlayerInfo[playerid][pId]);
 new query[180];

 format(query, sizeof(query), "UPDATE `auth_userprofile` SET `connection_time` = `connection_time` + ROUND(TIME_TO_SEC(TIMEDIFF(NOW(), `last_login_game`))/60) WHERE user_id = %d", PlayerInfo[playerid][pId]);
 mysql_query(query);

 // ostatnio zalogowany (czas)
 format(query, sizeof(query), "UPDATE `auth_userprofile` SET `last_login_game` = NOW() WHERE user_id = %d", PlayerInfo[playerid][pId]);
 mysql_query(query);

 if(PlayerInfo[playerid][pAdmin] > 0)
 {
  UpdateEverybodiesHud();
 }

 #if TIKI_EVENT
 if(PlayerInfo[playerid][pTiki] == 1)
 {
  DestroyPlayerObject(playerid, PlayerInfo[playerid][pTikiObject]);
  PlayerInfo[playerid][pTiki] = 0;
 }
 #endif
 
 GetPlayerNameMask(playerid, playername, sizeof(playername));
 		new reason_ex[3][16] = {"Crash", "/q", "Kick/Ban"},
 		Text3D:t3D_ID;

	GetPlayerPos(playerid, PlayerInfo[playerid][pPos_x], PlayerInfo[playerid][pPos_y], PlayerInfo[playerid][pPos_z]);
	PlayerInfo[playerid][pInt] = GetPlayerInterior(playerid);
	PlayerInfo[playerid][pPos_VW] = GetPlayerVirtualWorld(playerid);

	format(query, sizeof(query), "%s (%d)\n(( %s ))",  playername, playerid, reason_ex[reason]);
	t3D_ID = Create3DTextLabel(query, COLOR_GREY, PlayerInfo[playerid][pPos_x], PlayerInfo[playerid][pPos_y], PlayerInfo[playerid][pPos_z]+0.5, 40.0, 0);
	SetTimerEx("TLeX", 60000, false, "i", _:t3D_ID);
    format(query, sizeof(query), "%s opuœci³ grê", playername);
    if(reason == 0) strcat(query, " (Crash)");
    strcat(query, ".");

 if (gPlayerLogged[playerid]) ProxDetector(10.0, playerid, query, COLOR_GREY, COLOR_GREY, COLOR_GREY, COLOR_GREY, COLOR_GREY);

 if(reason == 0)
 {
  SendMessageToVehiclesDrivers(playerid, COLOR_GREY, "W³aœciciel tego pojazdu opuœci³ grê w wyniku crasha. Pojazd bêdzie dostepny przez nastêpne 3 minuty");
	SendMessageToVehiclesDrivers(playerid, COLOR_GREY, "i zniknie jeœli jego w³aœciciel nie wróci w tym czasie do gry.");
  SetTimerEx("UnSpawnUserVehiclesIf", 180000, 0, "d", PlayerInfo[playerid][pId]);
 }
 else
 {
  SendMessageToVehiclesDrivers(playerid, COLOR_GREY, "W³aœciciel tego pojazdu opuœci³ grê.. Pojazd bêdzie dostepny przez nastêpn¹ minutê");
	SendMessageToVehiclesDrivers(playerid, COLOR_GREY, "i zniknie jeœli jego w³aœciciel nie wróci w tym czasie do gry.");
  SetTimerEx("UnSpawnUserVehiclesIf", 60000, 0, "d", PlayerInfo[playerid][pId]);

  if(PlayerInfo[playerid][pMuted] == 2)
  {
   PlayerInfo[playerid][pMuted] = 0;
  }
 }

 // update listy online
 MySQLSetPlayerNotLogged(playerid);

 if(PlayerInfo[playerid][pWounded] > 0)
 {
  PlayerInfo[playerid][pPos_x]  = deadPosition[playerid][dpX];
  PlayerInfo[playerid][pPos_y]  = deadPosition[playerid][dpY];
  PlayerInfo[playerid][pPos_z]  = deadPosition[playerid][dpZ];
  PlayerInfo[playerid][pPos_a]  = deadPosition[playerid][dpA];
  PlayerInfo[playerid][pInt]    = deadPosition[playerid][dpInt];
  PlayerInfo[playerid][pPos_VW] = deadPosition[playerid][dpVW];
 }

 PlayerInfo[playerid][pLocal] = 0;

 for(new i = 0; i < MAX_PLAYERS; i++)
 {
  if(IsPlayerConnected(i))
  {
   if(BlockedPM[i][playerid] == 1)
   {
    BlockedPM[i][playerid] = 0;
   }
  }
 }

 // fix na recona dla kickowanych ludzi
 for(new i = 0; i < MAX_PLAYERS; i++)
 {
  if(Spectate[i] == playerid)
  {
   dcmd_recon(i, "off");
   
   GetPlayerNameEx(playerid, playername, sizeof(playername));

   format(query, sizeof(query), "%s opuœci³ grê", playername);
   
   if(reason == 0) strcat(query, " (Crash)");
   strcat(query, ".");
   
   SendClientMessage(i, COLOR_GREY, query);
  }
 }

 if(RepairingVehicle[playerid] > 0)
 {
  TogglePlayerControllable(RepairingVehicleOwner[playerid], 1);

  GameTextForPlayer(RepairingVehicleOwner[playerid], "~w~Mechanik~n~~r~Opuscil gre", 5000, 1);

  RepairOffer[RepairingVehicleOwner[playerid]] = 999;
 	RepairPrice[RepairingVehicleOwner[playerid]] = 0;

  RepairPrice[RepairingVehicleOwner[playerid]] = 0;
  IsRepairing[RepairingVehicleOwner[playerid]] = 0;
  RepairingVehicleOwner[playerid] = 255;
  RepairingVehicle[playerid]      = 0;
  RepairCar[playerid]             = 999;
 }

 new caller = Mobile[playerid];
	if(IsPlayerConnected(caller))
	{
	 	if(caller != INVALID_PLAYER_ID)
 		{
			if(caller != 255)
			{
				if(caller < 255)
				{
					SendClientMessage(caller,  COLOR_GRAD2, "   Roz³¹czy³ siê.");
					CellTime[caller] = 0;
					CellTime[playerid] = 0;
		  			SendClientMessage(playerid,  COLOR_GRAD2, "   Roz³¹czy³eœ siê.");
 					Mobile[caller] = 255;
		 			SetPlayerSpecialActionEx(playerid,SPECIAL_ACTION_STOPUSECELLPHONE);
		 			SetPlayerSpecialActionEx(caller,SPECIAL_ACTION_STOPUSECELLPHONE);
		 		}
		 		Mobile[playerid] = 255;
		 		CellTime[playerid] = 0;
				RingTone[playerid] = 0;
			}
		 }
	}

 if(PlayerInfo[playerid][pMuted] == 2)
 {
  PlayerInfo[playerid][pMuted] = 0;
 }
 
 if (IsPlayerOnDesert(playerid) && GetPlayerOrganization(playerid)!=3) PlayerInfo[playerid][pWasCrash] = 1;//jak jesteœmy na pustyni spawnujemy siê tam gdzie byliœmy

 // by³ crash
 if(reason == 0 && PlayerInfo[playerid][pWounded] == 0) // jesli nie ma BW
 {
  if(HadACrash[playerid] == 0)
  {
	  if (!(IsPlayerInAnyVehicle(playerid) && IsAirVehicle(GetPlayerVehicleID(playerid)))) PlayerInfo[playerid][pWasCrash] = 1;
  }
	

  // zapisujemy duty - mimo podwójnego crasha
  if(OnDuty[playerid] == 1)
  {
   PlayerInfo[playerid][pDuty] = 1;
  }
 }
 // crash - najzwyklejszy
 else
 {
  PlayerInfo[playerid][pMask] = 0;
 }


 // jeœli crasha nie by³o - pojedynczego crasha
 if(PlayerInfo[playerid][pWasCrash] != 1)
 {
  // ....
 }

 if(mConvoy[playerid] > 0)
 {
  if(reason == 0)
  {
 	 SendRadioMessage(1, TEAM_GROVE_COLOR, "* Misja konwoju zosta³a przerwana, kierowca opuœci³ grê (crash).");
	 }
	 else
	 {
	  SendRadioMessage(1, TEAM_GROVE_COLOR, "* Misja konwoju zosta³a przerwana, kierowca opuœci³ grê.");
	 }
 	
  mConvoy[playerid] = 0;
  SetTimer("StopConvoyMission", 60000, 0);
 }

 #if 0
 if(RobbedMoney[playerid] > 0)
 {
  GivePlayerMoneyEx(playerid,-RobbedMoney[playerid]);
  RobbedMoney[playerid] = 0;
 }
 #endif

	OnPlayerSave(playerid);

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
  if(IsPlayerConnected(i))
  {
	  if(TaxiAccepted[i] < 999)
	  {
	   if(TaxiAccepted[i] == playerid)
	   {
	    TaxiAccepted[i] = 999;
		   GameTextForPlayer(i, "~w~Osoba zamawiajaca~n~~r~Opuscila gre", 5000, 1);
		   TaxiCallTime[i] = 0;
		   DisablePlayerCheckpoint(i);
		  }
	  }
	 }
	}
	if(TransportCost[playerid] > 0 && TransportDriver[playerid] < 999)
	{
	 if(IsPlayerConnected(TransportDriver[playerid]))
		{
		 new string[64];
		 TransportMoney[TransportDriver[playerid]] += TransportCost[playerid];
		 TransportTime[TransportDriver[playerid]] = 0;
		 TransportCost[TransportDriver[playerid]] = 0;
		 format(string, sizeof(string), "~w~Pasazer opuœci³ pojazd~n~~g~Zarobi³eœ $%d",TransportCost[playerid]);
		 GameTextForPlayer(TransportDriver[playerid], string, 5000, 1);
		}
	}

	if(HireCar[playerid] != 999)
	{
		gLastDriver[HireCar[playerid]] = 300;
		gCarLock[HireCar[playerid]] = 0;
		UnLockCar(HireCar[playerid]);
	}
	if (gLastCar[playerid] > 0)
	{
		gLastDriver[gLastCar[playerid]] = 300;
	}
	if(PlayerBoxing[playerid] > 0)
	{
	 if(Boxer1 == playerid)
	 {
	  if(IsPlayerConnected(Boxer2))
	  {
	   PlayerBoxing[Boxer2] = 0;
	   SetPlayerPosEx(Boxer2, 765.8433,3.2924,1000.7186);
	   SetPlayerInterior(Boxer2, 5);
	   GameTextForPlayer(Boxer2, "~r~Mecz wstrzymany", 5000, 1);
			}
	 }
	 else if(Boxer2 == playerid)
	 {
	  if(IsPlayerConnected(Boxer1))
	  {
	   PlayerBoxing[Boxer1] = 0;
	   SetPlayerPosEx(Boxer1, 765.8433,3.2924,1000.7186);
	   SetPlayerInterior(Boxer1, 5);
	   GameTextForPlayer(Boxer1, "~r~Mecz zosta³ przerwany", 5000, 1);
			}
	 }
	 InRing = 0;
  		RoundStarted = 0;
		Boxer1 = 255;
		Boxer2 = 255;
		TBoxer = 255;
	}
 if(TransportDuty[playerid] == 1)
	{
		TaxiDrivers -= 1;
	}
	if(PlayerInfo[playerid][pJob] == 11)
	{
	 if(JobDuty[playerid] == 1) { Medics -= 1; }
	}
	else if(PlayerInfo[playerid][pJob] == 7)
	{
	 if(JobDuty[playerid] == 1) { Mechanics -= 1; }
	}
}
public TLeX(t3D_ID) return Delete3DTextLabel(Text3D:t3D_ID);
/*
forward Nicki(playerid);
public Nicki(playerid)
{
   //if(hasMaskOn[playerid] == 2)//jak ma maskê to nie nadaje mu nicku
   if(hasMaskOn[playerid] == 0)
   {
        new str[30];
		format(str, sizeof(str), "%s (%d)", pName(playerid), playerid);
		Update3DTextLabelText(PlayerInfo[playerid][pNicknames3D], COLOR_OOC, str);
		
   }
   else //jak ma
   {
    	//Update3DTextLabelText(PlayerInfo[playerid][pNicknames3D], COLOR_OOC, " ");
   }
  return 1;
}*/
#if Anim_After_Shot
forward Shot(playerid);
public Shot(playerid)//poprawiny
{
  if(IsPlayerConnected(playerid))
  {
    Injured[playerid] = 0;
  }
return 0;
}
#endif
public SetPlayerSpawn(playerid, mode)
{
	if(IsPlayerConnected(playerid))
	{
		//new fraction = GetPlayerOrganization(playerid);
		new skin = PlayerInfo[playerid][pModel];
		if(deadPosition[playerid][dpDeath] > 0)
		{
			if(mode == SET_SPAWN_POSITION)
			{
				SetSpawnInfo(playerid, TEAM_NONE, skin, deadPosition[playerid][dpX], deadPosition[playerid][dpY], deadPosition[playerid][dpZ], deadPosition[playerid][dpA], 0, 0, 0, 0, 0, 0);
				return 1;
			}
		
			if(mode == SET_SPAWN_WHERE_SPAWN)
			{
				SetPlayerInterior(playerid,        deadPosition[playerid][dpInt]);
				SetPlayerVirtualWorldEx(playerid,  deadPosition[playerid][dpVW]);

				SetPlayerCameraPos(playerid,     deadPosition[playerid][dpX], deadPosition[playerid][dpY], deadPosition[playerid][dpZ]+4.0);
				SetPlayerCameraLookAt(playerid,  deadPosition[playerid][dpX], deadPosition[playerid][dpY], deadPosition[playerid][dpZ]);

				SetPlayerHealthEx(playerid,        1000.0);
				GodMode[playerid]                = 1;


				if(deadPosition[playerid][dpDeath] == 1)
				{
					SetTimerEx("ApplyAnimationWounded", 200,  0, "d", playerid);
					SetTimerEx("ApplyAnimationWounded", 600,  0, "d", playerid);
				}
				else
				{
					SetTimerEx("ApplyAnimationWounded", 3000, 0, "d", playerid);
					SetTimerEx("ApplyAnimationWounded", 5000, 0, "d", playerid);
				}
				
				ApplyAnimationWounded(playerid);
				
				NameTag_SetState(playerid, PLAYER_STATE_WOUNDED);

				SendClientMessage(playerid, COLOR_AWHITE, "W skutek odniesionych obra¿eñ straci³eœ przytomnoœæ.");
				SendClientMessage(playerid, COLOR_AWHITE, "Po wpisaniu /akceptujsmierc twoja postaæ zostanie uœmiercona bez mo¿liwoœci na dalsz¹ grê.");

				PlayerInfo[playerid][pInt]       = deadPosition[playerid][dpInt];

				if(deadPosition[playerid][dpDeath] == 1)
				{
					deadPosition[playerid][dpDeath]  = 2;
				}
				else
				{
					deadPosition[playerid][dpDeath]  = 0;
				}

				MedicBill[playerid]              = 0;

				gPlayerSpawned[playerid] = 1;
			}
			
			TogglePlayerControllable(playerid,0);
			return 1;
			
		}
		else TogglePlayerControllable(playerid,1);
		
		if(PlayerInfo[playerid][pWasCrash] == 1)
		{
			if(mode == SET_SPAWN_POSITION)
			{
				SetSpawnInfo(playerid, TEAM_NONE, skin, PlayerInfo[playerid][pPos_x], PlayerInfo[playerid][pPos_y], PlayerInfo[playerid][pPos_z]+0.25, 0.0, 0, 0, 0, 0, 0, 0);
			}

			if(mode == SET_SPAWN_WHERE_SPAWN)
			{
				PlayerInfo[playerid][pWasCrash] = 0;

				SetPlayerInterior(playerid, PlayerInfo[playerid][pInt]);

				SetPlayerVirtualWorldEx(playerid, PlayerInfo[playerid][pPos_VW]);
				
				if (!IsPlayerOnDesert(playerid)) GameTextForPlayer(playerid, "~r~Miales crasha~n~~w~Wracasz do ostatniej pozycji", 8000, 1);
				KillAni(playerid);

				gPlayerSpawned[playerid] = 1;

				KillTimer(HadACrashTimer[playerid]);
				HadACrash[playerid] = 1;
				HadACrashTimer[playerid] = SetTimerEx("SetHadACrashOff", 20000, 0, "d", playerid);
			}
			
			return 1;
		}

		if(PlayerInfo[playerid][pJailed] == 1)
		{
			if(mode == SET_SPAWN_POSITION)
			{
				SetSpawnInfo(playerid, TEAM_NONE, skin, 255.137, -41.5322, 1002.0234,0.0, 0, 0, 0, 0, 0, 0);
			}
		
			if(mode == SET_SPAWN_WHERE_SPAWN)
			{
				SetPlayerInterior(playerid, 3);
	
				SetPlayerVirtualWorldEx(playerid, 0);
				SendClientMessage(playerid, COLOR_LIGHTRED, "Nie skoñczy³eœ odsiadki, wracasz do wiêzienia.");
				KillAni(playerid);

				gPlayerSpawned[playerid] = 1;
				return 1;
			}
		}
		if(PlayerInfo[playerid][pJailed] == 2)
		{
			if(mode == SET_SPAWN_POSITION)
			{
				SetSpawnInfo(playerid, TEAM_NONE, skin, 268.5777,1857.9351,9.8133,0.0, 0, 0, 0, 0, 0, 0);
			}
		
			if(mode == SET_SPAWN_WHERE_SPAWN)
			{
				SetPlayerInterior(playerid, 0);

				SetPlayerWorldBounds(playerid, 337.5694,101.5826,1940.9759,1798.7453); //285.3481,96.9720,1940.9755,1799.0811
				SetPlayerVirtualWorldEx(playerid, 0);

				KillAni(playerid);
			
				gPlayerSpawned[playerid] = 1;
			}
			
			return 1;
		}
		if(PlayerInfo[playerid][pJailed] == 3)
		{
			if(mode == SET_SPAWN_POSITION)
			{
				SetSpawnInfo(playerid, TEAM_NONE, skin, 198.0123,175.1045,1003.0234,0.0, 0, 0, 0, 0, 0, 0);
			}
		
			if(mode == SET_SPAWN_WHERE_SPAWN)
			{
				SetPlayerInterior(playerid, 3);

				SetPlayerVirtualWorldEx(playerid, 0);
				SetCameraBehindPlayer(playerid);
				KillAni(playerid);

				gPlayerSpawned[playerid] = 1;
			}
			
			return 1;
		}
		
		if(PlayerInfo[playerid][pJailed] == 4)
		{
			if(mode == SET_SPAWN_POSITION)
			{
				SetSpawnInfo(playerid, TEAM_NONE, skin, 154.2834,-1952.1342,47.8750,342.0233, 0, 0, 0, 0, 0, 0);
			}

			if(mode == SET_SPAWN_WHERE_SPAWN)
			{
				SetPlayerInterior(playerid, 0);

				SetPlayerVirtualWorldEx(playerid, playerid+1);
				SetCameraBehindPlayer(playerid);
				KillAni(playerid);

				gPlayerSpawned[playerid] = 1;
			}
			
			return 1;
		}
		
		if(PlayerInfo[playerid][pJailed] == 5)
		{
			if(mode == SET_SPAWN_POSITION)
			{
				SetSpawnInfo(playerid, TEAM_NONE, skin, 
					gJailSpawns[PlayerInfo[playerid][pJailCell]][0], gJailSpawns[PlayerInfo[playerid][pJailCell]][1], gJailSpawns[PlayerInfo[playerid][pJailCell]][2], gJailSpawns[PlayerInfo[playerid][pJailCell]][3], 0, 0, 0, 0, 0, 0);
			}

			if(mode == SET_SPAWN_WHERE_SPAWN)
			{
				SetPlayerInterior(playerid, 0);

				SetPlayerVirtualWorldEx(playerid, 0);
				SetCameraBehindPlayer(playerid);
				KillAni(playerid);

				gPlayerSpawned[playerid] = 1;
			}
			
			return 1;
		}
		
		if(hadPlayerBw[playerid] && PlayerInfo[playerid][pJailed] == 0)
		{
		  if(mode == SET_SPAWN_POSITION)
			{
				SetSpawnInfo(playerid, TEAM_NONE, skin, 1146.7517,1351.0177,10.8704, 197.9449, 0, 0, 0, 0, 0, 0);
			}
			
			if(mode == SET_SPAWN_WHERE_SPAWN)
			{
				//SetPlayerPosEx(playerid,1146.7517,1351.0177,10.8704);
				//SetPlayerFacingAngle(playerid,197.9449);
				SetCameraBehindPlayer(playerid);
				SetPlayerVirtualWorldEx(playerid, FAKE_INTERIOR_VW_ID);
				SetPlayerInterior(playerid, 0);
				SetPlayerHealthEx(playerid, 50.0);
				
				hadPlayerBw[playerid] = 0;
				gPlayerSpawned[playerid] = 1;
			}
			
		  return 1;
		}		
		
		if(PlayerInfo[playerid][pLocalType]==CONTENT_TYPE_HOUSE)
		{
			//if(SpawnChange[playerid]) //If 1, then you get to your house, else spawn somewhere else
			{
				if(mode == SET_SPAWN_POSITION)
				{
					SetSpawnInfo(playerid, TEAM_NONE, skin, PlayerInfo[playerid][pPos_x], PlayerInfo[playerid][pPos_y],PlayerInfo[playerid][pPos_z]+0.2, 0.0, 0, 0, 0, 0, 0, 0);
				}

				if(mode == SET_SPAWN_WHERE_SPAWN)
				{
					SetPlayerToTeamColor(playerid);
					SetPlayerInterior(playerid,PlayerInfo[playerid][pInt]);

					SetPlayerVirtualWorldEx(playerid, PlayerInfo[playerid][pPos_VW]);

					//PlayerInfo[playerid][pLocal] = house;
					PlayerInfo[playerid][pLocalType] = CONTENT_TYPE_HOUSE;
					KillAni(playerid);

					gPlayerSpawned[playerid] = 1;
				}
				
				return 1;
			}
		}
	#if Audio_Info
	if(Audio_IsClientConnected(playerid))
    {
    }
    else
    {
     ShowPlayerDialog(playerid, DIALOG_AUDIO_PLUGIN, DIALOG_STYLE_MSGBOX, "Brak klient dzwieku", "System wykry³, ¿e nie posiadasz klienta dzwiêku lub zainstalowana\n wersja jest nieaktualna. Nie pozwól, by najlepsza zabawa Ciê ominê³a - Zainstaluj go ju¿ teraz!\n\n\n{9e1e1e}UWAGA:\n{a9c4e4} Aktualn¹ wersje klienta mo¿esz zawszê pobraæ z naszego Forum.\nPobranie i zainstalowanie klienta to tylko kilkanaœcie sekund, a zapewni\nniezapomniane chwile na serwerze.", "Zamknij", "");
    }
    #endif
		if(PlayerInfo[playerid][pHotelId] != 0)
		{
			if(SpawnChange[playerid]) //If 1, then you get to your house, else spawn somewhere else
			{
				switch(PlayerInfo[playerid][pHotelId])
				{
					case BUSINESS_MOTEL_JEFFERSON_ID, BUSINESS_MOTEL_IDLEWOOD_ID:
					{
						if(mode == SET_SPAWN_POSITION) SetSpawnInfo(playerid, TEAM_NONE, skin, 2233.6584,-1113.2397,1050.8828,2.7833, 0, 0, 0, 0, 0, 0);
						if(mode == SET_SPAWN_WHERE_SPAWN) SetPlayerInterior(playerid, 5);
					}

					case BUSINESS_HOTEL_RODEO_ID:
					{
						if(mode == SET_SPAWN_POSITION) SetSpawnInfo(playerid, TEAM_NONE, skin, 2237.5435,-1080.6592,1049.0234,2.5548, 0, 0, 0, 0, 0, 0);
						if(mode == SET_SPAWN_WHERE_SPAWN) SetPlayerInterior(playerid, 2);
					}
				}
		 
				if(mode == SET_SPAWN_WHERE_SPAWN)
				{
					PlayerInfo[playerid][pLocal] = PlayerInfo[playerid][pHotelId];
					PlayerInfo[playerid][pLocalType] = CONTENT_TYPE_BUSINESS;

					SetPlayerVirtualWorldEx(playerid, playerid+1);
					SetCameraBehindPlayer(playerid);

					gPlayerSpawned[playerid] = 1;
				}
				
				return 1;
			}
		}
		if(PlayerInfo[playerid][pUFLeader] < MAX_UNOFFICIAL_FACTIONS+1 || PlayerInfo[playerid][pUFMember] < MAX_UNOFFICIAL_FACTIONS+1)
		{
			new ufid = GetPlayerUnofficialOrganization(playerid);

			if(mode == SET_SPAWN_POSITION)
			{
				SetSpawnInfo(playerid, TEAM_NONE, skin, MiniFaction[ufid][mSpawnX],MiniFaction[ufid][mSpawnY],MiniFaction[ufid][mSpawnZ], MiniFaction[ufid][mSpawnA], 0, 0, 0, 0, 0, 0);
			}

			if(mode == SET_SPAWN_WHERE_SPAWN)
			{
				SetPlayerVirtualWorldEx(playerid,MiniFaction[ufid][mSpawnVW]);
				SetPlayerInterior(playerid,MiniFaction[ufid][mSpawnInterior]);

				//PlayerInfo[playerid][pInt] = MiniFaction[ufid][mSpawnVW];
				//KillAni(playerid);

				gPlayerSpawned[playerid] = 1;
			}
			
			return 1;
		}
		else
		{
			new org = GetPlayerOrganization(playerid);
		
			if(mode == SET_SPAWN_POSITION)
			{
			  /*if(org == 1 && PlayerInfo[playerid][pRank] == 1)
				{
					SetSpawnInfo(playerid, TEAM_NONE, skin, 229.5357, 168.4718, 1003.0234, 192.220, 0, 0, 0, 0, 0, 0);
					return 1;
				}*/
				
				SetSpawnInfo(playerid, TEAM_NONE, skin, Organizations[org][orgSpawnX], Organizations[org][orgSpawnY], Organizations[org][orgSpawnZ], Organizations[org][orgSpawnA], 0, 0, 0, 0, 0, 0);
			}

			if(mode == SET_SPAWN_WHERE_SPAWN)
			{
				if(org == 1 && PlayerInfo[playerid][pRank] == 1)
				{
					SetPlayerVirtualWorldEx(playerid, 3);
					SetPlayerInterior(playerid, 3);
					return 1;
				}
			
				// fix na interior szpitala i lsnews (pogoda)

				SetPlayerVirtualWorldEx(playerid, Organizations[org][orgSpawnVw]);

				SetPlayerInterior(playerid, Organizations[org][orgSpawnInterior]);
				
				if (PlayerInfo[playerid][pHealth] <= 0) SetPlayerHealthEx(playerid,75.0);

				gPlayerSpawned[playerid] = 1;
			}
			return 1;
		}
	}
	return 1;
}

//------------------------------------------------------------------------------------------------------

public OnPlayerDeath(playerid, killerid, reason)
{
	new string[128];

	ToggleHudVisible(playerid, 0);

	if(PizzaDuty[playerid] == 1)
	{
		DisablePlayerCheckpoint(playerid);
		PizzaDuty[playerid] = 0;
	}

	gPlayerSpawned[playerid] = 0;
	PlayerInfo[playerid][pLocal] = 0;
    
	if(DeadReason[playerid] == 0 && PlayerBoxing[playerid] == 0)
	{
		if(deadPosition[playerid][dpDeath] != 3)
		{
			if(reason == 0 || reason == 1 || reason == 2 || reason == 3 || reason == 4 || reason == 5 || reason == 6 || 
			reason == 7 || reason == 8 || reason == 9 || reason == 10 || reason == 11 || reason == 12 || reason == 13 || 
			reason == 14 || reason == 15 || reason == 16 || reason == 17 || reason == 18 ||  reason == 22 || reason == 23 
			|| reason == 24  || reason == 25  || reason == 26  || reason == 27 || reason == 28 || reason == 29 || reason == 30 
			|| reason == 31 || reason == 32 || reason == 33 || reason == 34 || reason == 35 || reason == 36 || reason == 37 || 
			reason == 38 || reason == 39 || reason == 40 || reason == 41 || reason == 42)
			{
				if(PlayerInfo[playerid][pWounded] == 0)
				{
					GetPlayerPos(playerid, deadPosition[playerid][dpX], deadPosition[playerid][dpY], deadPosition[playerid][dpZ]);
					GetPlayerFacingAngle(playerid, deadPosition[playerid][dpA]);

					deadPosition[playerid][dpInt]    = GetPlayerInterior(playerid);
					deadPosition[playerid][dpVW]     = GetPlayerVirtualWorld(playerid);
					deadPosition[playerid][dpWeapon] = reason;
					deadPosition[playerid][dpDeath]  = 1;
					deadPosition[playerid][dpDeathReason] = reason; // TODO: mamy tu to podwójnie

					SetPlayerSpawn(playerid, SET_SPAWN_POSITION);

					//SetPlayerInterior(playerid, deadPosition[playerid][dpInt]);

					// fix na antycheata
					//ResetPlayerWeaponsEx2(playerid);
					//ResetPlayerWeaponsEx(playerid);

					PlayerInfo[playerid][pWounded]   = 15 * 60;
				}
			}
		}
		else
		{
			deadPosition[playerid][dpDeath] = 0;
			if(hadPlayerBw[playerid]) SetPlayerSpawn(playerid, SET_SPAWN_POSITION);
		}
	}
	else
	{
	 DeadReason[playerid] = 0;
	}
	// usuwamy animacje
	if(gPlayerUsingLoopingAnim[playerid] == 1)
	{
		gPlayerUsingLoopingAnim[playerid] = 0;
	}
	
	if(mConvoy[playerid] > 0)
	{
		mConvoy[playerid] = 0;
		SetTimer("StopConvoyMission", 60000, 0);
		SendRadioMessage(1, TEAM_GROVE_COLOR, "* Misja konwoju zosta³a przerwana, kierowca uleg³ wypadkowi.");
		DisablePlayerCheckpoint(playerid);
	}

	// zabicie uciekajacego
	if(WantedLevel[playerid] >= 1)
	{
		new price = WantedLevel[playerid] * 20;
		new count;
		if(IsACop(killerid))
		{
			count = 1;
			format(string, sizeof(string), "~w~Uciekajacy podejrzany~n~~r~Bonus ~g~$%d", price / 2);
			GameTextForPlayer(killerid, string, 5000, 1);
			GivePlayerMoneyEx(killerid, price / 2);
			PlayerPlaySound(killerid, 1058, 0.0, 0.0, 0.0);
		}
		if(count == 1)
		{
			GivePlayerMoneyEx(playerid, - price);
			PlayerInfo[playerid][pWantedDeaths] += 1;
			if(PlayerInfo[killerid][pMember] == 13 || PlayerInfo[killerid][pLeader] == 13)
			{
				PlayerInfo[playerid][pJailed] = 3;
			}
			else
			{
				PlayerInfo[playerid][pJailed] = 1;
			}
			PlayerInfo[playerid][pJailTime] = (WantedLevel[playerid])*(600);
			format(string, sizeof(string), "* Zosta³eœ zatrzymany w wiêzieniu na %d sekund i straci³eœ $%d, poniewa¿ podczas ucieczki zosta³eœ postrzelony.", PlayerInfo[playerid][pJailTime], price);
			SendClientMessage(playerid, COLOR_LIGHTRED, string);
			WantedPoints[playerid] = 0;
			WantedLevel[playerid] = 0;
			SetPlayerWantedLevel(playerid, WantedLevel[playerid]);
		}
	}
	if(reason == 38)
	{
		new kstring[128];
		new kickname[MAX_PLAYER_NAME];
		if(IsPlayerConnected(killerid))
		{
			GetPlayerName(killerid, kickname, sizeof(kickname));
			format(string, 256, "AdmOstrze¿enie: %s [id-%d] zabi³ gracza z miniguna, zobacz czy to nie cheater (gun cheat)!!!",killerid,kickname);
			ABroadCast(COLOR_YELLOW2,string,1);
			printf("%s", kstring);
		}
	}
	if(reason == 34) //Sniperka
	{
		new kstring[128];
		new kickname[MAX_PLAYER_NAME];
		if(IsPlayerConnected(killerid))
		{
			if(PlayerInfo[killerid][pMember] == 8 || PlayerInfo[killerid][pLeader] == 8){}
			else
			{
				GetPlayerName(killerid, kickname, sizeof(kickname));
				format(string, 256, "AdmOstrze¿enie: %s [id-%d] zabi³ gracza za pomoc¹ snajperki (gun cheat)!!!",kickname,killerid);
				ABroadCast(COLOR_YELLOW2,string,1);
				printf("%s", kstring);
			}
		}
	}
	
	if(reason == 16) //Granaty
	{
		new kstring[128];
		new kickname[MAX_PLAYER_NAME];
		if(IsPlayerConnected(killerid))
		{
			GetPlayerName(killerid, kickname, sizeof(kickname));
			format(string, 256, "AdmOstrze¿enie: %s [id-%d] zabi³ gracza za pomoc¹ granatów (gun cheat)!!!",kickname,killerid);
			ABroadCast(COLOR_YELLOW2,string,1);
			printf("%s", kstring);
		}
	}
	if(reason == 37) //Miotacz
	{
		new kstring[128];
		new kickname[MAX_PLAYER_NAME];
		if(IsPlayerConnected(killerid))
		{
			GetPlayerName(killerid, kickname, sizeof(kickname));
			format(string, 256, "AdmOstrze¿enie: %s [id-%d] zabi³ gracza za pomoc¹ miotacza ognia/rozpalonego ognia (gun cheat)!!!",kickname,killerid);
			ABroadCast(COLOR_YELLOW2,string,1);
			printf("%s", kstring);
		}
	}
	if(reason == 39) //£adunki
	{
		new kstring[128];
		new kickname[MAX_PLAYER_NAME];
		if(IsPlayerConnected(killerid))
		{
			GetPlayerName(killerid, kickname, sizeof(kickname));
			format(string, 256, "AdmOstrze¿enie: %s [id-%d] zabi³ gracza za pomoc¹ ³adunków wybuchowych (gun cheat)!!!",kickname,killerid);
			ABroadCast(COLOR_YELLOW2,string,1);
			printf("%s", kstring);
		}
	}
	if(reason == 36) //Bazooka
	{
		new kstring[128];
		new kickname[MAX_PLAYER_NAME];
		if(IsPlayerConnected(killerid))
		{
			GetPlayerName(killerid, kickname, sizeof(kickname));
			format(string, 256, "AdmOstrze¿enie: %s [id-%d] zabi³ gracza za pomoc¹ bazooki (gun cheat)!!!",kickname,killerid);
			ABroadCast(COLOR_YELLOW2,string,1);
			printf("%s", kstring);
		}
	}
	if(reason == 35) //RPG
	{
		new kstring[128];
		new kickname[MAX_PLAYER_NAME];
		if(IsPlayerConnected(killerid))
		{
			GetPlayerName(killerid, kickname, sizeof(kickname));
			format(string, 256, "AdmOstrze¿enie: %s [id-%d] zabi³ gracza za pomoc¹ RPG (gun cheat)!!!",kickname,killerid);
			ABroadCast(COLOR_YELLOW2,string,1);
			printf("%s", kstring);
		}
	}
	//-----------------------------------------------------------------------
	#if Skills_Weapons_All
	
      #if Skills_Weapons_22
      if(reason == 22) //Colt(9mm)
	  {
		if(IsPlayerConnected(killerid))
		{
            PlayerInfo[killerid][pColtSkill] ++;
			if(PlayerInfo[killerid][pColtSkill] == 1)
			{
                if(IsUnofficialGangMember(killerid))
                {
                  SendClientMessage(playerid, COLOR_GREY, "* Obs³uga tego typu broni wysz³a ci na dobre, potrafisz chwyciæ j¹ pewniej, lepiej skupiasz swoje strza³y.");
                  return 1;
                }
                //new org = GetPlayerOrganization(playerid);
			    if(GetPlayerOrganization(playerid) == 1)
				{
					SendClientMessage(playerid, COLOR_YELLOW, "* Obs³uga tego typu broni wysz³a ci na dobre, potrafisz chwyciæ j¹ pewniej, lepiej skupiasz swoje strza³y.");
					return 1;
				}
                
			    SendClientMessage(killerid, COLOR_YELLOW, "* Nie obcowa³eœ du¿o z broni¹ paln¹. Kiepska kontrola oddechu i chwyt nie pomagaj¹ Ci w dok³adnym celowaniu!");
			}
			else if(PlayerInfo[killerid][pColtSkill] == 3)
			{
			    SendClientMessage(killerid, COLOR_YELLOW, "* Obs³uga Colt'a wysz³a ci na dobre, potrafisz chwyciæ j¹ pewniej, lepiej skupiasz siê na celu oraz znasz ju¿ budowe tego typu broni.");
		    }
			else if(PlayerInfo[killerid][pColtSkill] == 5)
			{
				SendClientMessage(killerid, COLOR_YELLOW, "* Twóje zdolnoœci strzeleckie z Desert Eagle wzros³y do 4!");
			}
			else if(PlayerInfo[killerid][pColtSkill] == 7)
			{
				SendClientMessage(killerid, COLOR_YELLOW, "* Sam nie wiesz, czy chwytanie dwóch gnatów aikimbo to dobry pomys³, ale w koñcu jesteœ prawdziwym gangsterem!");
			}
					

		}
	}
	#endif
	#endif
	//-----------------------------------------------------------------------
    PlayerInfo[killerid][pKills] ++;
    PlayerInfo[playerid][pDeaths] ++;
	if (gPlayerCheckpointStatus[playerid] > 4 && gPlayerCheckpointStatus[playerid] < 11)
	{
		DisablePlayerCheckpoint(playerid);
		gPlayerCheckpointStatus[playerid] = CHECKPOINT_NONE;
	}
	new caller = Mobile[playerid];
	if(caller != 255)
	{
		if(caller < 255)
		{
			SendClientMessage(caller,  COLOR_GRAD2, "   Pad³a ci bateria w komórce...");
			CellTime[caller] = 0;
			CellTime[playerid] = 0;
			Mobile[caller] = 255;
		}
		Mobile[playerid] = 255;
		CellTime[playerid] = 0;
	}
	ClearCrime(playerid);

	return 1;
}
public OnPlayerRequestSpawn(playerid)
{
	#if CORPSES
	if(IsNPCACorpse(playerid))
	{
		new corpseindex = GetCorpseByPlayerID(playerid);
		
		if(corpseindex != INVALID_CORPSE_ID)
		{
			SetSpawnInfo(playerid, 0, 188, Corpses[corpseindex][cPosX], Corpses[corpseindex][cPosY], Corpses[corpseindex][cPosZ], 0.0, 0, 0, 0, 0, 0, 0);
			SetPlayerVirtualWorld(playerid, Corpses[corpseindex][cPosVW]);
		}
	}
	#endif

	return 0;
}
public OnPlayerSpawn(playerid)
{
	SetCameraBehindPlayer(playerid);
	PlayerInfo[playerid][pHealth] = 100;
	if(setSpawnOnSpawn[playerid] == 1)
	{
		SetPlayerSpawn(playerid, SET_SPAWN_WHERE_SPAWN);
	
		
	}
	else
	{
		setSpawnOnSpawn[playerid] = 1;
	}
	SetPlayerToTeamColor(playerid);
	PlayerFixRadio(playerid);

	SetPlayerWeapons(playerid);
	
	TextDrawHideForPlayer(playerid, Textdraw1);
	TextDrawHideForPlayer(playerid, Textdraw2);
	
	TextDrawShowForPlayer(playerid, SanNews);
	
    EnableStuntBonusForPlayer(playerid, 0);
	if(!gPlayerAnimLibsPreloaded[playerid])
	{
		PreloadAnimLib(playerid,"GHANDS");
		PreloadAnimLib(playerid,"GANGS");
		PreloadAnimLib(playerid,"ped");
		PreloadAnimLib(playerid,"MISC");
		PreloadAnimLib(playerid,"CRACK");
		PreloadAnimLib(playerid,"INT_HOUSE");
		PreloadAnimLib(playerid,"MUSCULAR");
		PreloadAnimLib(playerid,"ON_LOOKERS");
		PreloadAnimLib(playerid,"Attractors");
		PreloadAnimLib(playerid,"POOL");
		PreloadAnimLib(playerid,"INT_OFFICE");
		PreloadAnimLib(playerid,"BSKTBALL");
		PreloadAnimLib(playerid,"RAPPING");
		//PreloadAnimLib(playerid,"AIRPORT");
		PreloadAnimLib(playerid,"BAR");
		//PreloadAnimLib(playerid,"BD_FIRE");
		PreloadAnimLib(playerid,"BEACH");
		PreloadAnimLib(playerid,"benchpress");
		PreloadAnimLib(playerid,"BASEBALL");
		//PreloadAnimLib(playerid,"BF_injection");
		//PreloadAnimLib(playerid,"BIKED");
		//PreloadAnimLib(playerid,"BIKEH");
		//PreloadAnimLib(playerid,"BIKELEAP");
		//PreloadAnimLib(playerid,"BIKES");
		//PreloadAnimLib(playerid,"BIKEV");
		//PreloadAnimLib(playerid,"BIKE_DBZ");
		PreloadAnimLib(playerid,"BLOWJOBZ");
		//PreloadAnimLib(playerid,"BMX");
		PreloadAnimLib(playerid,"BOMBER");
		PreloadAnimLib(playerid,"BOX");
		PreloadAnimLib(playerid,"BUDDY");
		PreloadAnimLib(playerid,"BUS");
		PreloadAnimLib(playerid,"CAMERA");
		PreloadAnimLib(playerid,"CAR");
		PreloadAnimLib(playerid,"CARRY");
		PreloadAnimLib(playerid,"CAR_CHAT");
		PreloadAnimLib(playerid,"CASINO");
		PreloadAnimLib(playerid,"CHAINSAW");
		PreloadAnimLib(playerid,"CHOPPA");
		PreloadAnimLib(playerid,"CLOTHES");
		PreloadAnimLib(playerid,"COACH");
		PreloadAnimLib(playerid,"COLT45");
		PreloadAnimLib(playerid,"COP_AMBIENT");
		PreloadAnimLib(playerid,"COP_DVBYZ");
		PreloadAnimLib(playerid,"CRIB");
		PreloadAnimLib(playerid,"DANCING");
		PreloadAnimLib(playerid,"DEALER");
		PreloadAnimLib(playerid,"DILDO");
		PreloadAnimLib(playerid,"DODGE");
		PreloadAnimLib(playerid,"DOZER");
		PreloadAnimLib(playerid,"DRIVEBYS");
		PreloadAnimLib(playerid,"FAT");
		PreloadAnimLib(playerid,"FIGHT_B");
		PreloadAnimLib(playerid,"FIGHT_C");
		PreloadAnimLib(playerid,"FIGHT_D");
		PreloadAnimLib(playerid,"FIGHT_E");
		PreloadAnimLib(playerid,"FINALE");
		PreloadAnimLib(playerid,"FINALE2");
		PreloadAnimLib(playerid,"FLAME");
		PreloadAnimLib(playerid,"Flowers");
		PreloadAnimLib(playerid,"FOOD");
		PreloadAnimLib(playerid,"Freeweights");
		PreloadAnimLib(playerid,"GHETTO_DB");
		PreloadAnimLib(playerid,"goggles");
		PreloadAnimLib(playerid,"GRAFFITI");
		PreloadAnimLib(playerid,"GRAVEYARD");
		PreloadAnimLib(playerid,"GRENADE");
		PreloadAnimLib(playerid,"GYMNASIUM");
		PreloadAnimLib(playerid,"HAIRCUTS");
		PreloadAnimLib(playerid,"HEIST9");
		PreloadAnimLib(playerid,"INT_OFFICE");
		PreloadAnimLib(playerid,"INT_SHOP");
		PreloadAnimLib(playerid,"JST_BUISNESS");
		PreloadAnimLib(playerid,"KART");
		PreloadAnimLib(playerid,"KISSING");
		PreloadAnimLib(playerid,"KNIFE");
		PreloadAnimLib(playerid,"LAPDAN1");
		PreloadAnimLib(playerid,"LAPDAN2");
		PreloadAnimLib(playerid,"LAPDAN3");
		PreloadAnimLib(playerid,"LOWRIDER");
		PreloadAnimLib(playerid,"MD_CHASE");
		PreloadAnimLib(playerid,"MD_END");
		PreloadAnimLib(playerid,"MEDIC");
		PreloadAnimLib(playerid,"MTB");
		PreloadAnimLib(playerid,"NEVADA");
		PreloadAnimLib(playerid,"OTB");
		PreloadAnimLib(playerid,"PARACHUTE");
		PreloadAnimLib(playerid,"PARK");
		PreloadAnimLib(playerid,"PAULNMAC");
		PreloadAnimLib(playerid,"PLAYER_DVBYS");
		PreloadAnimLib(playerid,"PLAYIDLES");
		PreloadAnimLib(playerid,"POLICE");
		PreloadAnimLib(playerid,"POOR");
		PreloadAnimLib(playerid,"PYTHON");
		PreloadAnimLib(playerid,"RIFLE");
		PreloadAnimLib(playerid,"RIOT");
		PreloadAnimLib(playerid,"ROB_BANK");
		PreloadAnimLib(playerid,"ROCKET");
		PreloadAnimLib(playerid,"RUSTLER");
		PreloadAnimLib(playerid,"RYDER");
		PreloadAnimLib(playerid,"SCRATCHING");
		PreloadAnimLib(playerid,"SHAMAL");
		PreloadAnimLib(playerid,"SHOP");
		PreloadAnimLib(playerid,"SHOTGUN");
		PreloadAnimLib(playerid,"SILENCED");
		PreloadAnimLib(playerid,"SKATE");
		PreloadAnimLib(playerid,"SMOKING");
		PreloadAnimLib(playerid,"SNIPER");
		PreloadAnimLib(playerid,"SPRAYCAN");
		PreloadAnimLib(playerid,"STRIP");
		PreloadAnimLib(playerid,"SUNBATHE");
		PreloadAnimLib(playerid,"SWAT");
		PreloadAnimLib(playerid,"SWEET");
		PreloadAnimLib(playerid,"SWIM");
		PreloadAnimLib(playerid,"SWORD");
		PreloadAnimLib(playerid,"TANK");
		PreloadAnimLib(playerid,"TATTOOS");
		PreloadAnimLib(playerid,"TEC");
		PreloadAnimLib(playerid,"TRAIN");
		PreloadAnimLib(playerid,"TRUCK");
		PreloadAnimLib(playerid,"UZI");
		PreloadAnimLib(playerid,"VAN");
		PreloadAnimLib(playerid,"VENDING");
		PreloadAnimLib(playerid,"VORTEX");
		PreloadAnimLib(playerid,"WAYFARER");
		PreloadAnimLib(playerid,"WEAPONS");
		PreloadAnimLib(playerid,"WUZI");
		
 		gPlayerAnimLibsPreloaded[playerid] = 1;
    }
	if(PlayerInfo[playerid][pMember] == 8 || PlayerInfo[playerid][pLeader] == 8)
	{
		PlayerInfo[playerid][pMask] = 1;
	}

	if(PlayerInfo[playerid][pMember] == 13 || PlayerInfo[playerid][pLeader] == 13)
	{
		PlayerInfo[playerid][pMask] = 1;
	}
	// maski & chusty
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(PlayerInfo[i][pHiddenNametags] == 1)
			{
				ShowPlayerNameTagForPlayer(i, playerid, 0);
			}

			if(hasMaskOn[i] > 0 && OnAdminDuty[playerid] == 0)
			{
				ShowPlayerNameTagForPlayer(playerid, i, 0);
			}
			else
			{
				ShowPlayerNameTagForPlayer(playerid, i, 1);
			}
		}
	}
	
    SetTimerEx("InfoAudio", 10000, 0, "i", playerid);
    
	ToggleHudVisible(playerid, 1);
	Nametag_Update(playerid);
	Description_Update(playerid);
	new itemindex = GetPlayerItemByType(playerid, ITEM_TYPE_HOLDABLE);
	
	if (itemindex != INVALID_ITEM_ID && Items[itemindex][iFlags] & ITEM_FLAG_USING)
	{
		Items[itemindex][iFlags] -= ITEM_FLAG_USING;
		UseItem(playerid, Items[itemindex][iId], "", 0);
	}
	return 1;

}

forward InfoAudio(playerid);
public InfoAudio(playerid)
{
        if(!Audio_IsClientConnected(playerid))
		ShowPlayerDialog(playerid, DIALOG_AUDIO_PLUGIN, DIALOG_STYLE_MSGBOX, "Brak klient dzwieku", "System wykry³, ¿e nie posiadasz klienta dzwiêku lub zainstalowana wersja jest nieaktualna.\nNie pozwól, by najlepsza zabawa Ciê ominê³a - zainstaluj go ju¿ teraz!\n\n\n{9e1e1e}UWAGA:\n{a9c4e4}Aktualn¹ wersje klienta mo¿esz zawsze pobraæ z naszego forum. Pobranie i zainstalowanie \nklienta to tylko kilkanaœcie sekund, a zapewni niezapomniane chwile na serwerze.", "Zamknij", "");
		return 1;
}
public OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid)
{
    /*if(weaponid == 22)
    {
        new Float:health;
        PlayerInfo[playerid][pHealth] = health;
        GetPlayerHealth(playerid, health);
        SetPlayerHealth(playerid, health-10);
    }
    new str[126];
    new Float:HP;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
      GetPlayerHealth(i, HP);
      if(HP > PlayerInfo[i][pHealth])
      {
         SetPlayerHealth(i, PlayerInfo[i][pHealth]);
      }
      else if(HP < PlayerInfo[i][pHealth])
      {
         if(hasMaskOn[playerid] == 0)
         {
            	format(str, sizeof(str), "%s (%d)", pName(playerid), playerid);
            	Update3DTextLabelText(PlayerInfo[playerid][pNicknames3D], COLOR_RED, str);
            	SetTimerEx("Nicki", 2000, 0, "u", i);
         }
         else
         {
            	//Update3DTextLabelText(PlayerInfo[playerid][pNicknames3D], COLOR_RED, " ");
            	//SetTimerEx("Nicki", 2000, 0, "u", i);
         }

		 PlayerInfo[i][pHealth] = HP;
	  }
    }*/
    #if Anim_After_Shot
    if(weaponid == 22)
	{
       ApplyAnimation(playerid, "CRACK", "crckidle1", 2, 1, 0, 0, 0, 0);
       SetTimerEx("Shot", 6000, 0, "d", playerid);
       Injured[playerid] = 1;
    }
    if(weaponid == 23)
	{
       ApplyAnimation(playerid, "CRACK", "crckidle1", 2, 1, 0, 0, 0, 0);
       SetTimerEx("Shot", 6000, 0, "d", playerid);
       Injured[playerid] = 1;
    }
    if(weaponid == 24)
	{
       ApplyAnimation(playerid, "CRACK", "crckidle1", 2, 1, 0, 0, 0, 0);
       SetTimerEx("Shot", 15000, 0, "d", playerid);
       Injured[playerid] = 1;
    }
    if(weaponid == 25)
	{
       ApplyAnimation(playerid, "CRACK", "crckidle1", 2, 1, 0, 0, 0, 0);
       SetTimerEx("Shot", 15000, 0, "d", playerid);
       Injured[playerid] = 1;
    }
    if(weaponid == 26)
	{
       ApplyAnimation(playerid, "CRACK", "crckidle1", 2, 1, 0, 0, 0, 0);
       SetTimerEx("Shot", 15000, 0, "d", playerid);
       Injured[playerid] = 1;
    }
    if(weaponid == 27)
	{
       ApplyAnimation(playerid, "CRACK", "crckidle1", 2, 1, 0, 0, 0, 0);
       SetTimerEx("Shot", 7000, 0, "d", playerid);
       Injured[playerid] = 1;
    }
    if(weaponid == 28)
	{
       ApplyAnimation(playerid, "CRACK", "crckidle1", 2, 1, 0, 0, 0, 0);
       SetTimerEx("Shot", 15000, 0, "d", playerid);
       Injured[playerid] = 1;
    }
    if(weaponid == 29)
	{
       ApplyAnimation(playerid, "CRACK", "crckidle1", 2, 1, 0, 0, 0, 0);
       SetTimerEx("Shot", 7000, 0, "d", playerid);
       Injured[playerid] = 1;
    }
    if(weaponid == 32)
	{
       ApplyAnimation(playerid, "CRACK", "crckidle1", 2, 1, 0, 0, 0, 0);
       SetTimerEx("Shot", 7000, 0, "d", playerid);
       Injured[playerid] = 1;
    }
    if(weaponid == 30)
	{
       ApplyAnimation(playerid, "CRACK", "crckidle1", 2, 1, 0, 0, 0, 0);
       SetTimerEx("Shot", 8000, 0, "d", playerid);
       Injured[playerid] = 1;
    }
    if(weaponid == 31)
	{
       ApplyAnimation(playerid, "CRACK", "crckidle1", 2, 1, 0, 0, 0, 0);
       SetTimerEx("Shot", 8000, 0, "d", playerid);
       Injured[playerid] = 1;
    }
    if(weaponid == 34)
	{
       ApplyAnimation(playerid, "CRACK", "crckidle1", 4.1, 1, 0, 0, 0, 0);
       SetPlayerHealth(playerid, 0);
       Injured[playerid] = 1;
    }
    #endif
    return 1;
}
forward textkara();
public textkara()
{
  TextDrawHideForAll(Kara);
  return 1;
}
public CKLog(string[])
{
	new entry[256];
	format(entry, sizeof(entry), "%s\n",string);
	new File:hFile;
	hFile = fopen("ck.log", io_append);
	fwrite(hFile, entry);
	fclose(hFile);
}

public PayLog(string[])
{
	new entry[256];
	format(entry, sizeof(entry), "%s\n",string);
	new File:hFile;
	hFile = fopen("pay.log", io_append);
	fwrite(hFile, entry);
	fclose(hFile);
}

public KickLog(string[])
{
	new entry[256];
	format(entry, sizeof(entry), "%s\n",string);
	new File:hFile;
	hFile = fopen("kick.log", io_append);
	fwrite(hFile, entry);
	fclose(hFile);
}

forward AdminJailLog(string[]);
public  AdminJailLog(string[])
{
	new entry[256];
	format(entry, sizeof(entry), "%s\n",string);
	new File:hFile;
	hFile = fopen("adminjail.log", io_append);
	fwrite(hFile, entry);
	fclose(hFile);
}


public BanLog(string[])
{
	new entry[256];
	format(entry, sizeof(entry), "%s\n",string);
	new File:hFile;
	hFile = fopen("ban.log", io_append);
	fwrite(hFile, entry);
	fclose(hFile);
}

public  WarnLog(string[])
{
	new entry[256];
	format(entry, sizeof(entry), "%s\n",string);
	new File:hFile;
	hFile = fopen("warn.log", io_append);
	fwrite(hFile, entry);
	fclose(hFile);
}

forward GLog(string[]);
public  GLog(string[])
{
	new entry[256];
	format(entry, sizeof(entry), "%s\n",string);
	new File:hFile;
	hFile = fopen("governor.log", io_append);
	fwrite(hFile, entry);
	fclose(hFile);
}


forward ArrestLog(string[]);
public  ArrestLog(string[])
{
	new entry[256];
	format(entry, sizeof(entry), "%s\n",string);
	new File:hFile;
	hFile = fopen("arrest.log", io_append);
	fwrite(hFile, entry);
	fclose(hFile);
}

public  KWarnLog(string[])
{
	new entry[256];
	format(entry, sizeof(entry), "%s\n",string);
	new File:hFile;
	hFile = fopen("kwarn.log", io_append);
	fwrite(hFile, entry);
	fclose(hFile);
}


public OnPlayerEnterCheckpoint(playerid)
{
	new string[128];
	new name[MAX_PLAYER_NAME];
	
	switch (gPlayerCheckpointStatus[playerid])
	{
		case CHECKPOINT_HOME:
		{
			PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);
			DisablePlayerCheckpoint(playerid);
			gPlayerCheckpointStatus[playerid] = CHECKPOINT_NONE;
			GameTextForPlayer(playerid, "~w~Jestes w~n~~y~Domu", 5000, 1);
			
			return 1;
		}
		case CHECKPOINT_VEHICLE:
		{
			return 1;
		}
		case CHECKPOINT_PIZZA:
		{
			if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return 1;

			if(PizzaDuty[playerid] == 1)
			{
				new tip = random(10);

				pizzaOrders[playerid] -= 1;

				if(tip > 0)
				{
					format(string, sizeof(string), "Otrzyma³eœ $%d napiwku za przywiezion¹ pizzê", tip);
					SendClientMessage(playerid, COLOR_AWHITE, string);
					GivePlayerMoneyEx(playerid, tip);
				}
				else
				{
					SendClientMessage(playerid, COLOR_AWHITE, "Klient odebra³ swoj¹ pizzê.");
				}

				if(pizzaOrders[playerid] > 0)
				{
					format(string, sizeof(string), "Pozosta³o zamówieñ: %d", pizzaOrders[playerid]);
					SendClientMessage(playerid, TEAM_GROVE_COLOR, string);

					GetRandomPizzaOrder(playerid);
				}
				else
				{
					SendClientMessage(playerid, TEAM_GROVE_COLOR, "Nie masz wiêcej zamówieñ, udaj siê do pizzeri po nastêpne.");
					DisablePlayerCheckpoint(playerid);
					gPlayerCheckpointStatus[playerid] = CHECKPOINT_NONE;
					IsAllowedToPizzaBike[playerid] = 1;
					KillTimer(PizzaBikeTimer[playerid]);
					PizzaBikeTimer[playerid] = SetTimerEx("DisallowPizzaBike", 60 * 5 * 1000, 0, "d", playerid);
				}
				return 1;
			}
		}
	}

	if(TaxiCallTime[playerid] > 0 && TaxiAccepted[playerid] < 999)
	{
		TaxiAccepted[playerid] = 999;
		GameTextForPlayer(playerid, "~w~Znalazles Pasazera", 5000, 1);
		TaxiCallTime[playerid] = 0;
		DisablePlayerCheckpoint(playerid);
	}
	else if(mConvoy[playerid] > 0)
	{
				 if(mConvoy[playerid] == 1) { mConvoy[playerid] = 2; loadMoneyToConvoy(playerid); DisablePlayerCheckpoint(playerid); SetPlayerCheckpoint(playerid, 1498.2234,-1739.8492,13.0967, 7.0); }
		else if(mConvoy[playerid] == 2) { mConvoy[playerid] = 3; loadMoneyToAtm(playerid); DisablePlayerCheckpoint(playerid); SetPlayerCheckpoint(playerid, 1494.0867,-1027.3678,23.3794, 7.0); }
		else if(mConvoy[playerid] == 3) { mConvoy[playerid] = 4; loadMoneyToAtm(playerid); DisablePlayerCheckpoint(playerid); SetPlayerCheckpoint(playerid, 2229.1560,-1142.9735,25.3601, 7.0); }
		else if(mConvoy[playerid] == 4) { mConvoy[playerid] = 5; loadMoneyToAtm(playerid); DisablePlayerCheckpoint(playerid); SetPlayerCheckpoint(playerid, 1012.2833,-932.6492,41.7587, 7.0); }
		else if(mConvoy[playerid] == 5) { mConvoy[playerid] = 6; loadMoneyToAtm(playerid); DisablePlayerCheckpoint(playerid); SetPlayerCheckpoint(playerid, 1751.0894,-1860.4945,13.1491, 7.0); }
		else if(mConvoy[playerid] == 6) { mConvoy[playerid] = 7; loadMoneyToAtm(playerid); DisablePlayerCheckpoint(playerid); SetPlayerCheckpoint(playerid, 1708.0170,-2312.7693,-3.1080, 7.0); }
		else if(mConvoy[playerid] == 7) { mConvoy[playerid] = 8; loadMoneyToAtm(playerid); DisablePlayerCheckpoint(playerid); SetPlayerCheckpoint(playerid, 819.5429,-1332.4968,13.0867, 7.0); }
		else if(mConvoy[playerid] == 8)
		{
			GetPlayerNameEx(playerid, name, sizeof(name));
			format(string, sizeof(string), "* %s zakoñczy³ rozwo¿enie pieniêdzy konwojem.", name);
			SendRadioMessage(1, TEAM_GROVE_COLOR, string);
			mConvoy[playerid] = 0; ConvoyMission = 0;
			DisablePlayerCheckpoint(playerid);
		}
	}
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnDynamicObjectMoved(objectid)
{
	if (objectid == ParachuteObject)
  {  
    DestroyDynamicObject(ParachuteObject);
    ParachuteObject = CreateDynamicObject(2919, SpotCoords[X], SpotCoords[Y], SpotCoords[Z]-6.55, 0.0, 0.0, SpotCoords[A], 0, 0, -1, PARACHUTE_STREAMER_DISTANCE);
    paratimer = SetTimer("ObjectFix",10000,true);
		return 1;
  }

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(PlayerSound[i][sObject] == objectid)
		{
			if(PlayerToPoint(50.0, i, PlayerSound[i][sX], PlayerSound[i][sY], PlayerSound[i][sZ]))
			{
				PlayerPlaySound(i, PlayerSound[i][sSound], PlayerSound[i][sX], PlayerSound[i][sY], PlayerSound[i][sZ]);
				DetachSoundFromPlayer(i);
			}
		}
	}
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	new string[128];

	if(pickupid == pickupTaxi)
	{
		GameTextForPlayer(playerid, "~y~Aby zamowic transport~n~~w~wpisz /wezwij taxi", 4000, 3);
		return 1;
	}
	else if(pickupid == pickupOrderVehicle)
	{
		GameTextForPlayer(playerid, "~y~Salon samochodowy~n~~w~Aby kupic pojazd wpisz ~g~/zamowpojazd", 4000, 3);
		return 1;
	}
	else if(pickupid == pickupPolicePark)
	{
		GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~r~Aby kupic bron wpisz~n~~w~/kupbron", 4000, 3);
		return 1;
	}
	else if(pickupid == pickupIllegalItems)
	{
		new price = 0;

		switch(IllegalOrderReady[playerid])
		{
			case 1:
			{
				price = 7000;

				if(GetPlayerMoneyEx(playerid) >= price)
				{
					new nitem[pItem];

					nitem[iItemId] = ITEM_MASK;
					nitem[iCount] = 5;
					nitem[iOwner] = PlayerInfo[playerid][pId];
					nitem[iOwnerType] = CONTENT_TYPE_USER;
					nitem[iPosX] = 0.0;
					nitem[iPosY] = 0.0;
					nitem[iPosZ] = 0.0;
					nitem[iPosVW] = 0;
					nitem[iFlags] = 0;

					new id = CreateItem(nitem);

					if(id == HAS_REACHED_LIMIT)
					{
						SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz posiadaæ wiêcej przedmiotów.");
						return 1;
					}

					IllegalOrderReady[playerid] = 0;

					GivePlayerMoneyEx(playerid,-price);
					format(string, sizeof(string), "~r~-$%d", price);
					GameTextForPlayer(playerid, string, 5000, 1);

					SendClientMessage(playerid, COLOR_WHITE, "PORADA: U¿yj przedmiotu by za³o¿yæ maskê.");
					return 1;
				}
				else
				{
					IllegalOrderReady[playerid] = 0;
					SendClientMessage(playerid, COLOR_GRAD1, "Nie staæ ciê na ten przedmiot.");
					return 1;
				}
			}
			default:
			{
				GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~r~Nie zamowiles zadnego przedmiotu", 4000, 3);
				return 1;
			}
		}
		return 1;
	}
	else if(pickupid == pickupPayment)
	{
		if(PlayerInfo[playerid][pPayment] > 0)
		{
			format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~w~Odebrales wyplate~n~w wysokosci~n~~p~$%d", PlayerInfo[playerid][pPayment]);
			GameTextForPlayer(playerid, string, 4000, 3);
			GivePlayerMoneyEx(playerid,PlayerInfo[playerid][pPayment]);
			PlayerInfo[playerid][pPayment] = 0;
		}
		else
		{
			GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~r~Nie ma zadnej wyplaty", 4000, 3);
		}
		return 1;
  }
	else if(pickupid == pickupNewsReporterReg)
	{
		if(PlayerInfo[playerid][pMember] == 9 || PlayerInfo[playerid][pLeader] == 9) { GameTextForPlayer(playerid, "~w~Wpisz ~r~/gazeta ~w~by napisac nowa gazete",5000,3); }
		return 1;
	}
	else if(pickupid == pickupGettingDrugs)
	{
		GameTextForPlayer(playerid, "~w~Wpisz /wez narkotyki, aby wziac ~r~Narkotyki", 5000, 3);
		return 1;
	}
	else if(pickupid == pickupHotDog1 || pickupid == pickupHotDog2 || pickupid == pickupHotDog3 || pickupid == pickupHotDog4 || pickupid == pickupHotDog5 || pickupid == pickupHotDog6)
	{
		GameTextForPlayer(playerid, "~g~Aby zjesc hot-doga~n~~y~wpisz /hotdog", 5000, 3);
		return 1;
	}
	else if(pickupid == pickupHotel || pickupid == pickupHotel2)
	{
		if(PlayerInfo[playerid][pHotelId] == 0)
		{
			GameTextForPlayer(playerid, "~w~Aby sie zameldowac~n~~g~Wpisz /zamelduj", 5000, 3);
		}
		else
		{
			GameTextForPlayer(playerid, "~w~Aby sie wymeldowac~n~~g~Wpisz /wymelduj", 5000, 3);
		}
		return 1;
	}
	else if(pickupid == pickupAcademy)
	{
		if(GetPlayerVirtualWorld(playerid) == 1)
		{
			if(academyTrening == 1)
			{
				if(PlayerInfo[playerid][pMember] == 17 || PlayerInfo[playerid][pLeader] == 17)
				{
					GameTextForPlayer(playerid, "~w~Odebrales bron potrzebna do treningu", 5000, 3);
					ResetPlayerWeaponsEx(playerid);
					GivePlayerWeaponEx2(playerid, 3,  1);
					GivePlayerWeaponEx2(playerid, 41, 500);
					GivePlayerWeaponEx2(playerid, 24, 150);
					SetPlayerArmour(playerid, 75.0);
				}
			}
			else
			{
				GameTextForPlayer(playerid, "~w~Aktualnie nie ma zadnego treningu", 5000, 3);
			}
		}
		return 1;
	}

	for(new i = 0; i < sizeof(Jobs); i++)
	{
		if(Jobs[i][jActive] == 1)
		{
			if(Jobs[i][jPickup] == pickupid)
			{
				if(PlayerInfo[playerid][pJob] > 0 || PlayerInfo[playerid][pMember] > 0) {}
				else
				{
					format(string, sizeof(string), "~g~Witamy,~n~~y~ mozesz tu zostac ~r~%s~y~ ~n~~w~Wpisz /aplikuj jezeli chcesz sie zatrudnic", Jobs[i][jName]);
					GameTextForPlayer(playerid, string, 5000, 3);
				}

				return 1;
			}
		}
	}

	for(new i = 0; i < sizeof(DoorInfo); i++)
	{
		if(DoorInfo[i][dPickup] == pickupid)
		{
			switch(DoorInfo[i][dLocalType])
			{
				case CONTENT_TYPE_BUSINESS:
				{
					new businessindex = GetBusinessById(DoorInfo[i][dLocal]);

					if(businessindex != -1)
					{
						format(string, sizeof(string), "~y~%s~n~~w~Wlasciciel : %s", BizzInfo[businessindex][bName], BizzInfo[businessindex][bOwnerName]);
						GameTextForPlayer(playerid, string, 2500, 3);

						return 1;
					}
				}
			}
		}
	}

	for(new h = 0; h < sizeof(HouseInfo); h++)
	{
		if(HouseInfo[h][hPickup] == pickupid)
		{
			if(HouseInfo[h][hOwned] == 1)
			{
				if(HouseInfo[h][hRentabil] == 0)
				{
					format(string, sizeof(string), "~w~Ten dom jest kupiony przez:~n~%s",HouseInfo[h][hOwnerName]);
				}
				else
				{
					format(string, sizeof(string), "~w~Ten dom jest kupiony przez:~n~%s~n~~g~Czynsz: $%d~n~~w~Wpisz ~y~/wynajmijpokoj~w~ aby wynajac",HouseInfo[h][hOwnerName],HouseInfo[h][hRent]);
				}
				GameTextForPlayer(playerid, string, 2500, 3);
				return 1;
			}
			else
			{
				format(string, sizeof(string), "~y~Ten dom jest na sprzedaz~n~~w~Opis: %s",HouseInfo[h][hDiscription]);
			}
			GameTextForPlayer(playerid, string, 2500, 3);
			return 1;
		}
	}
	if(pickupid == sackConvoyPickup)
	{
		if(pickupid == 0){}
		else
		{
			if(!IsACop(playerid))
			{
				// wanted
				WantedPoints[playerid] = 20;
				SetPlayerCriminal(playerid,255, "Kradzie¿ pieniêdzy z konwoju");
				SetPlayerWantedLevel(playerid, WantedLevel[playerid]);

				// log
				new playername[MAX_PLAYER_NAME];
				GetPlayerNameEx(playerid, playername, sizeof(playername));
				printf("*** %s ukradl pieniadze z konwoju !", playername);

				SendClientMessage(playerid, COLOR_WHITE, "** Uda³o ci siê ukraœæ pieni¹dze z konwoju.");
				SendClientMessage(playerid, COLOR_WHITE, "** Jeœli ciê z³api¹, oczekuj d³ugiej odsiadki !");
				SendClientMessage(playerid, COLOR_GRAD2, "INFO: Je¿eli atak na konwój by³ nie RP, mo¿esz otrzymaæ ostrze¿enie.");
				GivePlayerMoneyEx(playerid, 25000);
				DestroyPickup(pickupid);
				}
				else
				{
				SendClientMessage(playerid, COLOR_WHITE, "** Uda³o ci siê odzyskaæ pieni¹dze z konwoju.");

				new playername[MAX_PLAYER_NAME];

				GetPlayerNameEx(playerid, playername, sizeof(playername));
				format(string, sizeof(string), "* %s odzyska³ pieni¹dze z konwoju !", playername);
				SendRadioMessage(1, TEAM_GROVE_COLOR, string);

				DestroyPickup(pickupid);
			}
		}
	}

	return 1;
}

public SetAllPlayerCheckpoint(Float:allx, Float:ally, Float:allz, Float:radi, num)
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			SetPlayerCheckpoint(i,allx,ally,allz, radi);
			if (num != 255)
			{
				gPlayerCheckpointStatus[i] = num;
			}
		}
	}

}

public SetAllCopCheckpoint(Float:allx, Float:ally, Float:allz, Float:radi)
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(GetPlayerOrganization(i) == 1)
			{
				SetPlayerCheckpoint(i,allx,ally,allz, radi);
			}
		}
	}
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	new string[128];
	if(newstate != oldstate)
	{
		switch(newstate)
		{
			case PLAYER_STATE_DRIVER, PLAYER_STATE_PASSENGER:
			{
				for(new i = 0; i < MAX_PLAYERS; i++)
				{
					if(IsPlayerConnected(i) && Spectate[i] == playerid)
					{
						PlayerSpectateVehicle(i, GetPlayerVehicleID(playerid));
					}
				}
			}
			default:
			{
				for(new i = 0; i < MAX_PLAYERS; i++)
				{
					if(IsPlayerConnected(i) && Spectate[i] == playerid)
					{
						PlayerSpectatePlayer(i, playerid);
					}
				}
			}
		}
	}
	
	if(newstate != PLAYER_STATE_DRIVER)
	{
		UpdatePlayerHud(playerid);
	}
	
	if(newstate == PLAYER_STATE_ONFOOT)
	{
		new oldcar  = gLastCar[playerid];
		new oldcar2 = gLastCarPassenger[playerid];
	
		if(GetVehicleModel(oldcar) == 596 || GetVehicleModel(oldcar2) == 596 ||GetVehicleModel(oldcar) == 597 || GetVehicleModel(oldcar2) == 597 || GetVehicleModel(oldcar) == 599 || GetVehicleModel(oldcar2) == 599 || GetVehicleModel(oldcar) == 598 || GetVehicleModel(oldcar2) == 598)
		{
			disableAntyCheat[playerid] = 1;

			new weapon, ammo;

			GetPlayerWeaponData(playerid, 3, weapon, ammo);

			if(((weapon != 25 || weapon != 26 || weapon != 27) || ammo == 0))
			{
				PlayerWeapons[playerid][pGun3]  = 25;
				PlayerWeapons[playerid][pAmmo3] = 1000;
			}

			disableAntyCheat[playerid] = 0;
		}
	
		if(mConvoy[playerid] > 0)
		{
			mConvoy[playerid] = 0;
			DisablePlayerCheckpoint(playerid);
			SetTimer("StopConvoyMission", 60000, 0);
			SendRadioMessage(1, TEAM_GROVE_COLOR, "* Misja konwoju zosta³a przerwana, kierowca opuœci³ wóz");
		}
		
		if(TransportDuty[playerid] > 0)
		{
			if(TransportDuty[playerid] == 1)
			{
				TaxiDrivers -= 1;
			}
			
			DisablePlayerCheckpoint(playerid);
			TransportDuty[playerid] = 0;
			format(string, sizeof(string), "* Jesteœ po s³u¿bie. Zarobi³eœ $%d.", TransportMoney[playerid]);
			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
			TransportValue[playerid] = 0; TransportMoney[playerid] = 0;
		}
		
		if(TransportCost[playerid] > 0 && TransportDriver[playerid] < 999)
		{
			if(IsPlayerConnected(TransportDriver[playerid]))
			{
				TransportMoney[TransportDriver[playerid]] += TransportCost[playerid];
				TransportTime[TransportDriver[playerid]] = 0;
				TransportCost[TransportDriver[playerid]] = 0;
				format(string, sizeof(string), "~w~Koszt jazdy~n~~r~$%d",TransportCost[playerid]);
				GameTextForPlayer(playerid, string, 5000, 1);
				format(string, sizeof(string), "~w~Pasazer wyszedl z taxi~n~~g~Otrzymales $%d",TransportCost[playerid]);
				GameTextForPlayer(TransportDriver[playerid], string, 5000, 1);
			 
				if(TransportCost[playerid] > GetPlayerMoneyEx(playerid))
				{
					format(string, sizeof(string), "Pasa¿er nie móg³ zap³aciæ pe³nej kwoty, poniewa¿ nie ma wiêcej pieniêdzy (pozosta³o mu do zap³aty $%d).", TransportCost[playerid]-GetPlayerMoneyEx(playerid));
					SendClientMessage(TransportDriver[playerid], COLOR_GREY, string);
					GivePlayerMoneyEx(playerid, -GetPlayerMoneyEx(playerid));
				}
				else
				{
					GivePlayerMoneyEx(playerid, -TransportCost[playerid]);
				}
				
				//GivePlayerMoneyEx(TransportDriver[playerid], TransportCost[playerid]);
				TransportCost[playerid] = 0;
				TransportTime[playerid] = 0;
				TransportDriver[playerid] = 999;
			}
		}
	}
	if(newstate == PLAYER_STATE_PASSENGER) // TAXI & BUSSES
	{
		new name[MAX_PLAYER_NAME];
		GetPlayerNameEx(playerid, name, sizeof(name));
		new vehicleid = GetPlayerVehicleID(playerid);
	
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(IsPlayerConnected(i))
			{
				if(IsPlayerInVehicle(i, vehicleid) && GetPlayerState(i) == 2 && TransportDuty[i] > 0)
				{
					if(GetPlayerMoneyEx(playerid) < TransportValue[i])
					{
						format(string, sizeof(string), "* Potrzebujesz $%d aby wejœæ.", TransportValue[i]);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						RemovePlayerFromVehicle(playerid);
					}
					else
					{
						if(TransportDuty[i] == 1)
						{
							format(string, sizeof(string), "* Zap³aci³eœ $%d Taksówkarzowi.", TransportValue[i]);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
							format(string, sizeof(string), "* Pasa¿er %s wszed³ do twojej taksówki.", name);
							SendClientMessage(i, COLOR_LIGHTBLUE, string);
							TransportTime[i] = 1;
							TransportTime[playerid] = 1;
							TransportCost[playerid] = TransportValue[i];
							TransportCost[i] = TransportValue[i];
							TransportDriver[playerid] = i;
						}
						GivePlayerMoneyEx(playerid, - TransportValue[i]);
						TransportMoney[i] += TransportValue[i];
					}
				}
			}
		}
	
		if((Vehicles[vehicleid][vId] != -1 && Vehicles[vehicleid][vLocked] == 1))// || gCarLock[vehicleid] == 1)
		{
			SendClientMessage(playerid, COLOR_GREY, "Ten pojazd jest zamkniêty.");

			new Float:spX, Float:spY, Float:spZ;
			GetPlayerPos(playerid, spX, spY, spZ);
			SetPlayerPosEx(playerid, spX, spY, spZ);

			RemovePlayerFromVehicle(playerid);
		}
	
		gLastCarPassenger[playerid] = vehicleid;
	}
	if(newstate == PLAYER_STATE_WASTED)
	{
		SetPlayerSpawn(playerid, SET_SPAWN_POSITION);
	}
	if(newstate == PLAYER_STATE_DRIVER)
	{
		new newcar = GetPlayerVehicleID(playerid);

		GetVehiclePos(newcar, PlayerLastPos[playerid][0], PlayerLastPos[playerid][1], PlayerLastPos[playerid][2]);

		UpdatePlayerHud(playerid);
		
		#if DEBUG
		format(string, sizeof(string), "Id pojazdu: %d", newcar);
		SendClientMessage(playerid, COLOR_GREY, string);
		#endif
		
		format(string, sizeof(string), "~g~%s", GetVehicleName(newcar));
		GameTextForPlayer(playerid, string, 2500,1);
		
		// antycheat
		if((!CanAccessVehicleByIndex(playerid, newcar) && Vehicles[newcar][vOwnerType] != CONTENT_TYPE_USER) && Vehicles[newcar][vId] != -1 && PlayerInfo[playerid][pAdmin] < 1)
		{
			SetTimerEx("CheckIfDriveVehicle", 2000, 0, "dd", Vehicles[newcar][vId], PlayerInfo[playerid][pId]);
		}
		
		if(Vehicles[newcar][vId] != -1)
		{
			AddPlayerTraceToObject(playerid, CONTENT_TYPE_VEHICLE, Vehicles[newcar][vId]);
		}
  
		if(Vehicles[newcar][vType] == VEHICLE_TYPE_PIZZA)
		{
			if(PlayerInfo[playerid][pJob] == 17)
			{
				if(PlayerInfo[playerid][pPizzaTimer] > 0)
				{
					SendClientMessage(playerid, COLOR_GRAD1, "Odpocznij chwilê zanim wrócisz do pracy.");
					PizzaDuty[playerid] = 0;

					DisablePlayerCheckpoint(playerid);
					RemovePlayerFromVehicle(playerid);
					return 1;
				}
				if(IsAllowedToPizzaBike[playerid] == 1)
				{
				}
				else if(pizzaOrders[playerid] > 0)
				{
					SendClientMessage(playerid, COLOR_AWHITE, "Mo¿esz rozpocz¹æ rozwo¿enie pizzy, udaj siê do zaznaczonego domu.");
					format(string, sizeof(string), "Pozosta³o zamówieñ: %d", pizzaOrders[playerid]);
					SendClientMessage(playerid, TEAM_GROVE_COLOR, string);

					PizzaDuty[playerid] = 1;

					GetRandomPizzaOrder(playerid);
				}
				else
				{
					SendClientMessage(playerid, COLOR_GRAD1, "Nie posiadasz listy zamówieñ, aby j¹ odebraæ, udaj siê do pizzeri");
					DisablePlayerCheckpoint(playerid);
					RemovePlayerFromVehicle(playerid);
				}
			}
			else
			{
				SendClientMessage(playerid,COLOR_GREY,"Nie posiadasz kluczy do tego pojazdu.");
				RemovePlayerFromVehicle(playerid);
			}
		}
		
		if(GetVehicleModel(newcar) == 427)
		{
			SetPlayerArmour(playerid, armourFix[playerid]);
		}
		
		if(Gas[newcar] <= 0)
		{
			TogglePlayerControllable(playerid, 0);
			NoFuel[playerid] = 1;
		}
		
		if(Vehicles[newcar][vId] != -1)
		{
			format(string, sizeof(string), "W³aœciciel pojazdu: %s.", strreplace("_", " ", Vehicles[newcar][vOwnerName]));
			SendClientMessage(playerid, COLOR_PURPLE, string);
		}

		if((Vehicles[newcar][vId] != -1 && Vehicles[newcar][vLocked] == 1))// || gCarLock[newcar] == 1)
		{
			SendClientMessage(playerid, COLOR_GREY, "Ten pojazd jest zamkniêty.");

			new Float:spX, Float:spY, Float:spZ;
			GetPlayerPos(playerid, spX, spY, spZ);
			SetPlayerPosEx(playerid, spX, spY, spZ); 	
		}

		gLastCar[playerid] = newcar;
		gLastDriver[newcar] = playerid;
	}
	else if(newstate == PLAYER_STATE_SPECTATING)
	{
		if(PlayerInfo[playerid][pAdmin] < 1)
		{
			new giveplayer[MAX_PLAYER_NAME];
			GetPlayerNameEx(playerid, giveplayer, sizeof(giveplayer));
			format(string, sizeof(string), "Admin: %s zosta³ zbanowany, Powód: Podgl¹danie", giveplayer);
			SendClientMessageToAll(COLOR_LIGHTRED, string);
			PlayerInfo[playerid][pLevel] = 1;

			format(string, sizeof(string), "Podgladanie");
			MySQLBanPlayer(playerid, string, 999);
		}
	}
	else if(newstate == PLAYER_STATE_SPAWNED)
	{
		new Float: lwx, Float:lwy, Float:lwz;
		GetPlayerPos(playerid, lwx, lwy, lwz);
		if((lwz > 530.0 && PlayerInfo[playerid][pInt] == 0) || PlayerToPoint(1000.0, playerid, -1041.9,-1868.4,79.1)) //the highest land point in sa = 526.8
		{
			#if DEBUG
			SendClientMessage(playerid, COLOR_LIGHTRED, "DEBUG: Podwójny spawn onplayerstatechange:player_state_spawned");
			#endif
		}
		if(WantedPoints[playerid] > 0)
		{
			new dstring[128];
			new wanted = WantedPoints[playerid];
			new diecash = 0;
			while(WantedPoints[playerid] > 0)
			{
				diecash += 15;
				WantedPoints[playerid] --;
				SetPlayerWantedLevel(playerid, WantedLevel[playerid]);
			}
			format(dstring, sizeof(dstring), "Straciles $%d za œmieræ z %d punktami poszukiwañ.", diecash, wanted);
			SendClientMessage(playerid, COLOR_YELLOW, dstring);
			GivePlayerMoneyEx(playerid, - diecash);
			PlayerInfo[playerid][pWantedDeaths] += 1;
		}
		WantedPoints[playerid] = 0;
		SetPlayerWantedLevel(playerid, WantedLevel[playerid]);
		WantedLevel[playerid] = 0;

		MedicBill[playerid] = 1; // do sprawdzenia
	}
	
	if (IsPlayerOnBike(playerid))
	{
		if (HasPlayerMats(playerid))
		{
			SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz przewoziæ materia³ów na broñ na motorze!");

			new Float:spX, Float:spY, Float:spZ;
			GetPlayerPos(playerid, spX, spY, spZ);
			SetPlayerPosEx(playerid, spX, spY, spZ);

			RemovePlayerFromVehicle(playerid);
		}
	
	}
	
	return 1;
}

public RespawnAllCars()
{
	for(new i = 0; i < MAX_VEHICLES; i++)
	{
		if(IsAnyPlayerInVehicle(i)){}
		else
		{
			gLastDriver[i] = 999;
			UnLockCar(i);
			SetVehicleToRespawn(i);
			gCarLock[i] = 0;
		}
	}
}

IsPlayerOnBike(playerid)
{
  new const BikesModels[] = {509,481,510,462,448,581,522,461,521,523,463,586,468};
  new model = GetVehicleModel(GetPlayerVehicleID(playerid));
  
  for (new i = 0; i<sizeof(BikesModels) ; i++)
  {
    if (BikesModels[i]==model)
    {
      return 1;
    }
    else continue;
  }
  return 0;
}

public IsAnyPlayerInVehicle(vehicle)
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerInVehicle(i, vehicle)) { return 1; }
	}
	return 0;
}

public LockCar(carid)
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			SetVehicleParamsForPlayer(carid,i,0,1);
		}
	}
}

public UnLockCar(carid)
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i) && PlayerInfo[i][pWounded] == 0)
		{
			if(!IsAirVehicle(i))
			{
				SetVehicleParamsForPlayer(carid,i,0,0);
			}
		}
	}
}

public InitLockDoors(playerid)
{
	if(IsPlayerConnected(playerid))
	{
		for(new i = 0; i < MAX_VEHICLES; i++)
		{
			if (gCarLock[i] == 1)
			{
				SetVehicleParamsForPlayer(i,playerid,0,1);
			}
			else
			{
			 SetVehicleParamsForPlayer(i,playerid,0,0);
			}
		}
	}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerCameraPos(playerid,1460.0, -1324.0, 287.2);
	SetPlayerCameraLookAt(playerid,1374.5, -1291.1, 239.0);
	
	new plname[MAX_PLAYER_NAME];
	
	GetPlayerNameEx(playerid, plname, sizeof(plname));
		
	new string[128];
		
	format(string, sizeof(string), "Witaj %s! Zaloguj siê, by rozpocz¹æ grê.", plname);
  ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Logowanie", string, "Zaloguj siê", "WyjdŸ");
 
	return 1;
}

//---------------------------------------------------------

public SetPlayerCriminal(playerid,declare,reason[])
{//example: SetPlayerCriminal(playerid,255, "Stealing A Police Vehicle");
	if(IsPlayerConnected(playerid))
	{
		PlayerInfo[playerid][pCrimes] += 1;
		new points = WantedPoints[playerid];
		new turned[MAX_PLAYER_NAME];
		new turner[MAX_PLAYER_NAME];
		new turnmes[128];
		new wantedmes[128];
		new wlevel;
		strmid(PlayerCrime[playerid][pAccusedof], reason, 0, strlen(reason), 255);
		GetPlayerName(playerid, turned, sizeof(turned));
		if (declare == 255)
		{
			format(turner, sizeof(turner), "Nieznany");
			strmid(PlayerCrime[playerid][pVictim], turner, 0, strlen(turner), 255);
		}
		else
		{
			if(IsPlayerConnected(declare))
			{
				GetPlayerName(declare, turner, sizeof(turner));
				strmid(PlayerCrime[playerid][pVictim], turner, 0, strlen(turner), 255);
				strmid(PlayerCrime[declare][pBplayer], turned, 0, strlen(turned), 255);
				strmid(PlayerCrime[declare][pAccusing], reason, 0, strlen(reason), 255);
			}
		}
		format(turnmes, sizeof(turnmes), "Pope³ni³eœ przestêpstwo ( %s ). Zg³osi³ Cie: %s.",reason,turner);
		SendClientMessage(playerid, COLOR_LIGHTRED, turnmes);
		if(points > 0)
		{
			new yesnox;
			if(points == 3) { if(WantedLevel[playerid] != 1) { WantedLevel[playerid] = 1; wlevel = 1; yesnox = 1; } }
			else if(points >= 4 && points <= 5) { if(WantedLevel[playerid] != 2) { WantedLevel[playerid] = 2; wlevel = 2; yesnox = 1; } }
			else if(points >= 6 && points <= 7) { if(WantedLevel[playerid] != 3) { WantedLevel[playerid] = 3; wlevel = 3; yesnox = 1; } }
			else if(points >= 8 && points <= 9) { if(WantedLevel[playerid] != 4) { WantedLevel[playerid] = 4; wlevel = 4; yesnox = 1; } }
			else if(points >= 10 && points <= 11) { if(WantedLevel[playerid] != 5) { WantedLevel[playerid] = 5; wlevel = 5; yesnox = 1; } }
			else if(points >= 12 && points <= 13) { if(WantedLevel[playerid] != 6) { WantedLevel[playerid] = 6; wlevel = 6; yesnox = 1; } }
			else if(points >= 14) { if(WantedLevel[playerid] != 10) { WantedLevel[playerid] = 10; wlevel = 10; yesnox = 1; } }
			if(yesnox)
			{
				format(wantedmes, sizeof(wantedmes), "Aktualny poziom poszukiwania: %d", wlevel);
				SendClientMessage(playerid, COLOR_YELLOW, wantedmes);
				SetPlayerWantedLevel(playerid, wlevel);
				for(new i = 0; i < MAX_PLAYERS; i++)
				{
					if(IsPlayerConnected(i))
					{
						if(PlayerInfo[i][pMember] == 1||PlayerInfo[i][pLeader] == 1)
						{
							format(cbjstore, sizeof(turnmes), "Centrala: Do wszystkich jednostek! Doniós³: %s",turner);
							SendClientMessage(i, TEAM_BLUE_COLOR, cbjstore);
							format(cbjstore, sizeof(turnmes), "Centrala: Przestêpstwo: %s, Podejrzany: %s",reason,turned);
							SendClientMessage(i, TEAM_BLUE_COLOR, cbjstore);
						}
					}
				}
			}
		}
	}
}
//---------------------------------------------------------

public SetPlayerFree(playerid,declare,reason[])
{
	if(IsPlayerConnected(playerid))
	{
		ClearCrime(playerid);
		new turned[MAX_PLAYER_NAME];
		new turner[MAX_PLAYER_NAME];
		new crbjstore[128];
		
		if (declare == 255)
		{
			format(turner, sizeof(turner), "911");
		}
		else
		{
			if(IsPlayerConnected(declare))
			{
				GetPlayerNameEx(declare, turner, sizeof(turner));
			}
		}
		
		GetPlayerNameEx(playerid, turned, sizeof(turned));

		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(IsPlayerConnected(i))
			{
				if(PlayerInfo[i][pMember] == 1||PlayerInfo[i][pLeader] == 1)
				{
					format(crbjstore, sizeof(crbjstore), "Centrala: %s Wykona³y zadanie.",turner);
					SendClientMessage(i, COLOR_DBLUE, crbjstore);
					format(crbjstore, sizeof(crbjstore), "Centrala: %s zosta³ zatrzymany przez %s.",turned,reason);
					SendClientMessage(i, COLOR_DBLUE, crbjstore);
				}
			}
		}
	}
}

public OtherTimer()
{
	new string[128];
	//new Float:oldposx, Float:oldposy, Float:oldposz;
	new sendername[MAX_PLAYER_NAME], giveplayer[MAX_PLAYER_NAME];

	if(AutoChangeWeatherTimer > 0)
	{
		AutoChangeWeatherTimer -= 1;
		if(AutoChangeWeatherTimer < 1)
		{
			AutoChangeWeather();
		}
	}

	if(syncUpTimer > 0)
	{
		syncUpTimer -= 1;
		if(syncUpTimer < 1)
		{
			SyncTime();
			syncUpTimer = 30;
		}
	}

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(KickPlayer[i]==1) { Kick(i); }
   
			// anticheat
			if(GetPlayerSpecialAction(i) == SPECIAL_ACTION_USEJETPACK)
			{
				new year, month,day;
				getdate(year, month, day);
				GetPlayerNameEx(i, giveplayer, sizeof(giveplayer));
				format(string, sizeof(string), "Admin: %s zosta³ zbanowany, Powód: Jetpack (%d-%d-%d)", giveplayer, month,day,year);

				KickLog(string);
				format(string, sizeof(string), "Admin: %s zosta³ zbanowany, Powód: Jetpack", giveplayer);
				SendClientMessageToAll(COLOR_LIGHTRED, string);
				PlayerInfo[i][pLevel] = 1;
				PlayerInfo[i][pMember] = 0;
				PlayerInfo[i][pLeader] = 0;
				MySQLBanPlayer(i, "Jetpack", 999);
			}
		 
			if(PlayerInfo[i][pInjuriesTime] > 0)
			{
				PlayerInfo[i][pInjuriesTime] -= 1;
			}
		
			if(PlayerInfo[i][pWounded] > 0)
			{
				PlayerInfo[i][pWounded] -= 1;

				if(PlayerInfo[i][pWounded] < 1)
				{
					hadPlayerBw[i] = 1;
					deadPosition[i][dpDeath] = 3;
					GodMode[i] = 0;
					SetPlayerHealthEx(i, 0.0);
					NameTag_RemoveState(i, PLAYER_STATE_WOUNDED);
				}
				
				if (PlayerInfo[i][pWounded] > 0)
				{
				 	SetPlayerCameraPos(i,     deadPosition[i][dpX], deadPosition[i][dpY], deadPosition[i][dpZ]+4.0);
					SetPlayerCameraLookAt(i,  deadPosition[i][dpX], deadPosition[i][dpY], deadPosition[i][dpZ]);
				}
			}
		
			if(PlayerInfo[i][pVehiclesInterval] > 0)
			{
				PlayerInfo[i][pVehiclesInterval] -= 1;
			}
		
			if(PlayerInfo[i][pVehicleSpawnInterval] > 0)
			{
				PlayerInfo[i][pVehicleSpawnInterval] -= 1;
			}
		
			// naprawa auta
			// tajne kombinacje, sam sie pogubilem w tych zmiennych!
			if(RepairingVehicle[i] > 0)
			{
				RepairingVehicle[i] -= 1;

				if(RepairingVehicle[i] < 1)
				{
					TogglePlayerControllable(RepairingVehicleOwner[i], 1);

					GetPlayerNameEx(RepairingVehicleOwner[i], giveplayer, sizeof(giveplayer));
					GetPlayerNameEx(i, sendername, sizeof(sendername));
					RepairCar[i] = GetPlayerVehicleID(RepairingVehicleOwner[i]);
					
					RepairVehicle(RepairCar[i]);
					SetVehicleHealthEx(RepairCar[i], 1000.0);

					format(string, sizeof(string), "* Twój samochód zosta³ naprawiony za $%d przez Mechanika Samochodwego %s.",RepairPrice[RepairingVehicleOwner[i]],sendername);
					SendClientMessage(RepairingVehicleOwner[i], COLOR_LIGHTBLUE, string);
					format(string, sizeof(string), "* Naprawi³eœ samochód %s za $%d.",giveplayer,RepairPrice[RepairingVehicleOwner[i]]);
					SendClientMessage(i, COLOR_LIGHTBLUE, string);
					PlayerInfo[i][pMechSkill] ++;

					if(PlayerInfo[i][pMechSkill] == 50)
					{ SendClientMessage(i, COLOR_YELLOW, "* Twój poziom umiejêtnoœci Mechanika to 2, mo¿esz tankowaæ wiêcej paliwa."); }
					else if(PlayerInfo[i][pMechSkill] == 100)
					{ SendClientMessage(i, COLOR_YELLOW, "* Twój poziom umiejêtnoœci Mechanika to 3, mo¿esz tankowaæ wiêcej paliwa."); }
					else if(PlayerInfo[i][pMechSkill] == 200)
					{ SendClientMessage(i, COLOR_YELLOW, "* Twój poziom umiejêtnoœci Mechanika to 4, mo¿esz tankowaæ wiêcej paliwa."); }
					else if(PlayerInfo[i][pMechSkill] == 400)
					{ SendClientMessage(i, COLOR_YELLOW, "* Twój poziom umiejêtnoœci Mechanika to 5, mo¿esz tankowaæ wiêcej paliwa."); }

					PlayerInfo[i][pPayCheck] += RepairPrice[RepairingVehicleOwner[i]];
					GivePlayerMoneyEx(RepairingVehicleOwner[i], -RepairPrice[RepairingVehicleOwner[i]]);

					RepairOffer[RepairingVehicleOwner[i]] = 999;
					RepairPrice[RepairingVehicleOwner[i]] = 0;

					RepairPrice[RepairingVehicleOwner[i]] = 0;
					IsRepairing[RepairingVehicleOwner[i]] = 0;

					RepairingVehicleOwner[i] = 255;
					RepairingVehicle[i]      = 0;
					RepairCar[i]             = 999;
				}
				else
				{
					// niestety nasz jezyk nie jest taki prosty, wiec trzeba zrobic ladna odmiane.. ;)
					new toofaraway = 0;

					if(ProxDetectorS(8.0, i, RepairingVehicleOwner[i]))
					{
						toofaraway = 0;
					}
					else
					{
						toofaraway = 1;
					}

					if(toofaraway == 0)
					{
						if(RepairingVehicle[i] == 1)
						{
							format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~Twoj pojazd jest naprawiany~n~~w~(Pozostala %d sekunda)", RepairingVehicle[i]);
						}
						else if(RepairingVehicle[i] >= 2 && RepairingVehicle[i] <= 4)
						{
							format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~Twoj pojazd jest naprawiany~n~~w~(Pozostaly %d sekundy)", RepairingVehicle[i]);
						}
						else
						{
							format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~Twoj pojazd jest naprawiany~n~~w~(Pozostalo %d sekund)", RepairingVehicle[i]);
						}
						GameTextForPlayer(RepairingVehicleOwner[i], string, 1500, 3);
					}
					else
					{
						format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~Mechanik odszedl niekonczac rozpoczatej pracy");
						GameTextForPlayer(RepairingVehicleOwner[i], string, 4000, 3);
					}

					if(toofaraway == 0)
					{
						format(string, sizeof(string), "%d", RepairingVehicle[i]);
						GameTextForPlayer(i, string, 1500, 6);
					}
					else
					{
						format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~Przerwales naprawe auta");
						GameTextForPlayer(i, string, 4000, 3);
					}

					if(toofaraway == 1)
					{
						TogglePlayerControllable(RepairingVehicleOwner[i], 1);

						RepairOffer[RepairingVehicleOwner[i]] = 999;
						RepairPrice[RepairingVehicleOwner[i]] = 0;

						RepairPrice[RepairingVehicleOwner[i]] = 0;
						IsRepairing[RepairingVehicleOwner[i]] = 0;
						RepairingVehicleOwner[i] = 255;
						RepairingVehicle[i]      = 0;
						RepairCar[i]             = 999;
					}
				}
			}
			if(PlayerInfo[i][pPizzaTimer] > 0)
			{
				PlayerInfo[i][pPizzaTimer] -= 1;
			}
			if(PlayerInfo[i][pThiefInterval] > 0)
			{
				PlayerInfo[i][pThiefInterval] -= 1;
			}
			if(PlayerInfo[i][pNeedMedicTime] > 0)
			{
				PlayerInfo[i][pNeedMedicTime] -= 1;
				if(PlayerInfo[i][pNeedMedicTime] < 1)
				{
					MedicBill[i] = 1;
					PlayerInfo[i][pNeedMedicTime] = 0;
					SetPlayerPosEx(i,1146.3452,1350.4873,10.8954);
					SetPlayerFacingAngle(i,179.5821);
					SetPlayerInterior(i,0);
					SetPlayerVirtualWorldEx(i,FAKE_INTERIOR_VW_ID);
					SetCameraBehindPlayer(i);
					TogglePlayerControllable(i, 1);

					ClearAnimations(i);

					//new cut = deathcost; //PlayerInfo[playerid][pLevel]*deathcost;
					#if LEVEL_MODE
					new cut = PlayerInfo[i][pLevel]*deathcost;
					#else
					new cut = deathcost;
					#endif
					GivePlayerMoneyEx(i, -cut);
					format(string, sizeof(string), "Doktor: Koszt twojego leczenia wyniós³ $%d, Mi³ego dnia.", cut);
					SendClientMessage(i, TEAM_CYAN_COLOR, string);
					Tax += cut;

				}
			}
		}
	}
	return 1;
}

public OtherTimer2()
{
	new string[128];
	new Float:oldposx, Float:oldposy, Float:oldposz;

 for(new i = 0; i < MAX_PLAYERS; i++)
	{
  if(IsPlayerConnected(i))
  {
   if(GodMode[i] == 1) SetPlayerHealth(i, 1000.0);

   if(PlayerInfo[i][pFoodTimer] > 0)
   {
    new Float:playerhealth;
    
    // bezpieka na oszukiwanie z podwyzszonym HP
    GetPlayerHealth(i, playerhealth);
    
    if(playerhealth + PlayerInfo[i][pFoodHealthGrowth] > 100.0)
    {
     PlayerInfo[i][pFoodTimer] = 1;
    }
    else
    {
     SetPlayerHealthEx(i, playerhealth+PlayerInfo[i][pFoodHealthGrowth]);
    }
		
		if(PlayerInfo[i][pFoodTimer] == 1)
		{
		  NameTag_RemoveState(i, PLAYER_STATE_EATING);
		}
   
    PlayerInfo[i][pFoodTimer]--;
   }
 	 if(gAtmTimer[i] > 0)
   {
    gAtmTimer[i] -= 1;
	  }
   if(SafeTime[i] > 0)
		 {
		  SafeTime[i]--;
		 }
		 if(SafeTime[i] == 0)
		 {
		  SendClientMessage(i, COLOR_GRAD2, "Zostajesz roz³¹czony z serwerem z powodu braku aktywnoœci.");
		  SafeTime[i] = -1;
		  KickPlayer[i] = 1;
		 }
		 if(SafeTime[i] == 15)
	  {
			 if(gPlayerAccount[i] == 1 && gPlayerLogged[i] == 0)
				{
					SendClientMessage(i, COLOR_WHITE, "WSKAZÓWKA: Mo¿esz siê teraz zalogowaæ wpisz /zaloguj [has³o]");
				}
			}
	  if(PlayerInfo[i][pLocal] > 0 && PlayerInfo[i][pLocalType] > 0)
			{
				new local = PlayerInfo[i][pLocal];
				
				GetPlayerPos(i, oldposx, oldposy, oldposz);

				if(oldposz < 600.0)
				{				
				 switch(PlayerInfo[i][pLocalType])
				 {			
				  case CONTENT_TYPE_HOUSE:
				  {
				   SetPlayerPosEx(i, HouseInfo[local][hEntrancex], HouseInfo[local][hEntrancey],HouseInfo[local][hEntrancez]); // Warp the player
						 PlayerInfo[i][pLocal] = 0;
						 PlayerInfo[i][pLocalType] = 0;
						 SetPlayerInterior(i,0);
						 SetPlayerVirtualWorldEx(i,0);
						 PlayerInfo[i][pInt] = 0;
				  }
				
				  /*case CONTENT_TYPE_BUSINESS:
				  {
				   new door = GetBusinessDoor(local);
				
				   SetPlayerPosEx(i, DoorInfo[door][dEnterX], DoorInfo[door][dEnterY], DoorInfo[door][dEnterZ]);

						 PlayerInfo[i][pLocal] = 0;
						 PlayerInfo[i][pLocalType] = 0;
						 SetPlayerInterior(i,0);
						 SetPlayerVirtualWorldEx(i,0);
						 PlayerInfo[i][pInt] = 0;
				  }*/
				 }
				}
			}
		  if(CellTime[i] > 0)
			 {
			 if (CellTime[i] == cchargetime)
			 {
				 CellTime[i] = 1;
				 if(Mobile[Mobile[i]] == i)
				 {
				 	CallCost[i] = CallCost[i]+callcost;
				 }
				}
				CellTime[i] = CellTime[i] +1;
				if (Mobile[Mobile[i]] == 255 && CellTime[i] == 5)
				{
				 if(IsPlayerConnected(Mobile[i]))
				 {
						new called[MAX_PLAYER_NAME];
						GetPlayerNameMask(Mobile[i], called, sizeof(called));
						format(string, sizeof(string), "* Dzwoni telefon %s.", called);
						RingTone[Mobile[i]] = 10;
						ProxDetector(20.0, Mobile[i], string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					}
				}
			}
			if(TransportTime[i] > 0)
			{//Taxi driver and passenger only
			 if(TransportTime[i] >= 16)
				{
					TransportTime[i] = 1;
					if(TransportDriver[i] < 999)
					{
						if(IsPlayerConnected(TransportDriver[i]))
						{
	      TransportCost[i] += TransportValue[TransportDriver[i]];
						 TransportCost[TransportDriver[i]] = TransportCost[i];
						}
					}
				}
			 TransportTime[i] += 1;

    format(string, sizeof(string), "~r~%d ~w~: ~g~$%d",TransportTime[i],TransportCost[i]);

			 GameTextForPlayer(i, string, 15000, 6);
			}
		}
	}
	return 1;
}

public SetPlayerUnjail()
{
	new string[128];
	for(new i = 0; i < GetMaxPlayers(); i++)
	{
	 if(IsPlayerConnected(i))
	 {
			//new newcar = GetPlayerVehicleID(i);
			#if LEVEL_MODE
			new level = PlayerInfo[i][pLevel];
			if(level >= 0 && level <= 2) { PlayerInfo[i][pPayCheck] += 1; }
			else if(level >= 3 && level <= 4) { PlayerInfo[i][pPayCheck] += 2; }
			else if(level >= 5 && level <= 6) { PlayerInfo[i][pPayCheck] += 3; }
			else if(level >= 7 && level <= 8) { PlayerInfo[i][pPayCheck] += 4; }
			else if(level >= 9 && level <= 10) { PlayerInfo[i][pPayCheck] += 5; }
			else if(level >= 11 && level <= 12) { PlayerInfo[i][pPayCheck] += 6; }
			else if(level >= 13 && level <= 14) { PlayerInfo[i][pPayCheck] += 7; }
			else if(level >= 15 && level <= 16) { PlayerInfo[i][pPayCheck] += 8; }
			else if(level >= 17 && level <= 18) { PlayerInfo[i][pPayCheck] += 9; }
			else if(level >= 19 && level <= 20) { PlayerInfo[i][pPayCheck] += 10; }
			else if(level >= 21) { PlayerInfo[i][pPayCheck] += 11; }
			#endif
   if(PlayerInfo[i][pJailed] > 0)
   {
				if(PlayerInfo[i][pJailTime] > 0 && WantLawyer[i] == 0)
				{
					PlayerInfo[i][pJailTime]--;
				}
				if(PlayerInfo[i][pJailTime] <= 0 && WantLawyer[i] == 0)
				{
	    PlayerInfo[i][pJailTime] = 0;
					if(PlayerInfo[i][pJailed] == 1)
					{
						SetPlayerInterior(i, 6);
						SetPlayerPosEx(i,268.0903,77.6489,1001.0391);
					}
					else if(PlayerInfo[i][pJailed] == 2)
					{
					 SetPlayerWorldBounds(i,20000.0000,-20000.0000,20000.0000,-20000.0000); //Reset world to player
					 SetPlayerInterior(i, 0);
					 SetPlayerPosEx(i, 1798.5131,-1578.3892,14.0854);//90.2101,1920.4854,17.9422);
					}
					else if(PlayerInfo[i][pJailed] == 3)
					{
					 SetPlayerInterior(i, 0);
					 SetPlayerPosEx(i, 198.1884,178.4536,1003.0234);
					 SetPlayerFacingAngle(i,349.7198);
					}
					else if(PlayerInfo[i][pJailed] == 5)
					{
					 SetPlayerInterior(i, 0);
					 SetPlayerPosEx(i, 1330.1543,728.2797,11.3255);
					 SetPlayerFacingAngle(i,181.7900);
					}
					

					if(PlayerInfo[i][pJailed] != 4)
					{
					 SendClientMessage(i, COLOR_GRAD1,"   Odp³aci³eœ karê za swoje poczynania.");
					 format(string, sizeof(string), "~n~~g~Sprobuj byc lepszym czlowiekiem");
 					GameTextForPlayer(i, string, 5000, 1);
					}
					
					
					else
					{
					 SetPlayerInterior(i, 0);
					 SetPlayerPosEx(i, 154.3213,-1944.4292,4.0304);
					 SetPlayerFacingAngle(i,2.7859);
					 SetPlayerVirtualWorldEx(i,0);
					}
					
					PlayerInfo[i][pJailed] = 0;

					ClearCrime(i);
					SetPlayerToTeamColor(i);
				}
			}
	  if(UsedFind[i] >= 1)
	  {
	   UsedFind[i] += 1;
				if(UsedFind[i] >= 120)
				{
	    UsedFind[i] = 0;
				}
	  }
			if(MedicTime[i] > 0)
			{
	   if(MedicTime[i] == 3)
	   {
	    SetPlayerInterior(i, 5);
	    new Float:X, Float:Y, Float:Z;
	    GetPlayerPos(i, X,Y,Z);
	    SetPlayerCameraPos(i, X + 3, Y, Z);
	    SetPlayerCameraLookAt(i,X,Y,Z);
	   }
	   MedicTime[i] ++;
	   if(MedicTime[i] >= NeedMedicTime[i])
	   {
	  		new cut = deathcost; //PlayerInfo[playerid][pLevel]*deathcost;
					GivePlayerMoneyEx(i, -cut);
					format(string, sizeof(string), "Doktor: Twój rachunek opiewa na $%d. Mi³ego dnia.", cut);
					SendClientMessage(i, TEAM_CYAN_COLOR, string);
					TogglePlayerControllable(i, 1);
			  MedicBill[i] = 0;
			  MedicTime[i] = 0;
			  NeedMedicTime[i] = 0;
			  PlayerInfo[i][pDeaths] += 1;
			  PlayerFixRadio(i);
			  SpawnPlayer(i);
			 }
			}
			if(WantLawyer[i] >= 1)
			{
			 CallLawyer[i] = 111;
			 if(WantLawyer[i] == 1)
				{
				 SendClientMessage(i, COLOR_LIGHTRED, "Czy chcesz prawnika? (Napisz tak lub nie)");
				}
				WantLawyer[i] ++;
				if(WantLawyer[i] == 8)
				{
				 SendClientMessage(i, COLOR_LIGHTRED, "Czy chcesz prawnika? (Napisz tak lub nie)");
				}
    if(WantLawyer[i] == 15)
				{
				 SendClientMessage(i, COLOR_LIGHTRED, "Czy chcesz prawnika? (Napisz tak lub nie)");
				}
				if(WantLawyer[i] == 20)
				{
				 SendClientMessage(i, COLOR_LIGHTRED, "Wyczerpa³eœ swój limit porad prawnych.");
				 WantLawyer[i] = 0;
				 CallLawyer[i] = 0;
				}
			}
			if(PlayerTazeTime[i] >= 1)
			{
			 PlayerTazeTime[i] += 1;
			 if(PlayerTazeTime[i] == 15)
			 {
     PlayerTazeTime[i] = 0;
		  }
			 else
			 {
			  new Float:angle;
					GetPlayerFacingAngle(i, angle);
					SetPlayerFacingAngle(i, angle + 90);
			 }
			}
			if(PlayerInfo[i][pDrunkTime] > 0)
			{
				SetPlayerDrunkLevel(i, CalculatePlayerDrunkLevel(i));
				PlayerInfo[i][pDrunkTime] -= 1;
			}
			if(PlayerStoned[i] >= 2)
			{
		  PlayerStoned[i] += 1;
			 if(PlayerStoned[i] == 10)
			 {
			  PlayerStoned[i] = 2;
			  new Float:angle;
					GetPlayerFacingAngle(i, angle);
					if(IsPlayerInAnyVehicle(i))
					{
					 if(GetPlayerState(i) == PLAYER_STATE_DRIVER)
					 {
					  DrunkTime[i] = 1;
						}
					}
					else
					{
					 if(GetPlayerState(i) == PLAYER_STATE_ONFOOT)
					 {
					  ApplyAnimation(i, "CRACK", "crckdeth2", 4.0, 0, 0, 0, 0, 0);
				  }
					}
			 }
			}
			if(BoxWaitTime[i] > 0)
			{
			 if(BoxWaitTime[i] >= BoxDelay)
				{
				    BoxDelay = 0;
					BoxWaitTime[i] = 0;
					PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
					GameTextForPlayer(i, "~g~Mecz rozpoczety", 5000, 1);
					TogglePlayerControllable(i, 1);
					RoundStarted = 1;
				}
			    else
				{
				    format(string, sizeof(string), "%d", BoxDelay - BoxWaitTime[i]);
					GameTextForPlayer(i, string, 1500, 6);
					BoxWaitTime[i] += 1;
				}
			}
			if(RoundStarted > 0)
			{
			    if(PlayerBoxing[i] > 0)
			    {
			        new trigger = 0;
			        new Lost = 0;
		        	new Float:angle;
		            new Float:health;
					GetPlayerHealth(i, health);
		            if(health < 12)
					{
					    if(i == Boxer1) { Lost = 1; trigger = 1; }
			            else if(i == Boxer2) { Lost = 2; trigger = 1; }
					}
			        if(health < 28) { GetPlayerFacingAngle(i, angle); SetPlayerFacingAngle(i, angle + 85); }
			        if(trigger)
			        {
			            new winner[MAX_PLAYER_NAME];
			            new loser[MAX_PLAYER_NAME];
			            new titel[MAX_PLAYER_NAME];
			            if(Lost == 1)
			            {
			                if(IsPlayerConnected(Boxer1) && IsPlayerConnected(Boxer2))
			                {
					        	SetPlayerPosEx(Boxer1, 765.8433,3.2924,1000.7186); SetPlayerPosEx(Boxer2, 765.8433,3.2924,1000.7186);
					        	SetPlayerInterior(Boxer1, 5); SetPlayerInterior(Boxer2, 5);
			                	GetPlayerName(Boxer1, loser, sizeof(loser));
			                	GetPlayerName(Boxer2, winner, sizeof(winner));
		                		if(PlayerInfo[Boxer1][pJob] == 12) { PlayerInfo[Boxer1][pLoses] += 1; }
								if(PlayerInfo[Boxer2][pJob] == 12) { PlayerInfo[Boxer2][pWins] += 1; }
			                	if(TBoxer < 255)
			                	{
			                	    if(IsPlayerConnected(TBoxer))
			                	    {
				                	    if(TBoxer != Boxer2)
				                	    {
				                	        if(PlayerInfo[Boxer2][pJob] == 12)
				                	        {
				                	            TBoxer = Boxer2;
				                	            GetPlayerName(TBoxer, titel, sizeof(titel));
				                	            GetPlayerName(TBoxer, titel, sizeof(titel));
				                	            new titel2[MAX_PLAYER_NAME];
				                	            GetPlayerNameEx(TBoxer, titel2, sizeof(titel2));
					                	        new nstring[MAX_PLAYER_NAME];
												format(nstring, sizeof(nstring), "%s", titel);
												strmid(Titel[TitelName], nstring, 0, strlen(nstring), 255);
					                	        Titel[TitelWins] = PlayerInfo[TBoxer][pWins];
					                	        Titel[TitelLoses] = PlayerInfo[TBoxer][pLoses];
					                	        SaveBoxer();
							                	format(string, sizeof(string), "LS News Sport: %s wygra³ walke z by³ym mistrzem %s, tym samym przej¹³ jego miejsce.",  titel2, loser);
												OOCOff(COLOR_WHITE,string);
				                	        }
				                	        else
				                	        {
				                	            SendClientMessage(Boxer2, COLOR_LIGHTBLUE, "* Mo¿esz zostaæ mistrzem, pod warunkiem i¿ bêdziesz boxerem.");
				                	        }
										}
										else
										{
          	new titel2[MAX_PLAYER_NAME];
				       GetPlayerNameEx(TBoxer, titel2, sizeof(titel2));
										 GetPlayerName(TBoxer, titel, sizeof(titel));
										 format(string, sizeof(string), "LS News Sport: Mistrz %s ponownie wygra³ walkê z %s.",  titel2, loser);
											OOCOff(COLOR_WHITE,string);
											Titel[TitelWins] = PlayerInfo[TBoxer][pWins];
				                	        Titel[TitelLoses] = PlayerInfo[Boxer2][pLoses];
				                	        SaveBoxer();
										}
									}
								}//TBoxer
								format(string, sizeof(string), "* Przegra³eœ walkê z %s.", winner);
								SendClientMessage(Boxer1, COLOR_LIGHTBLUE, string);
								GameTextForPlayer(Boxer1, "~r~Przegrales", 3500, 1);
								format(string, sizeof(string), "* Wygra³eœ bitwê %s.", loser);
								SendClientMessage(Boxer2, COLOR_LIGHTBLUE, string);
								GameTextForPlayer(Boxer2, "~r~Wygra³eœ", 3500, 1);
								if(GetPlayerHealth(Boxer1, health) < 20)
								{
								    SendClientMessage(Boxer1, COLOR_LIGHTBLUE, "* Czujesz siê wykoñczony po ostatniej walce, idŸ coœ zjeœæ.");
								    SetPlayerHealthEx(Boxer1, 30.0);
								}
								else
								{
								    SendClientMessage(Boxer1, COLOR_LIGHTBLUE, "* Czujesz siê znakomicie po ostatniej walce.");
								    SetPlayerHealthEx(Boxer1, 50.0);
								}
								if(GetPlayerHealth(Boxer2, health) < 20)
								{
								    SendClientMessage(Boxer2, COLOR_LIGHTBLUE, "* Czujesz siê wykoñczony po ostatniej walce, idŸ coœ zjeœæ.");
							    	SetPlayerHealthEx(Boxer2, 30.0);
								}
								else
								{
								    SendClientMessage(Boxer2, COLOR_LIGHTBLUE, "* Czujesz siê znakomicie po ostatniej walce.");
								    SetPlayerHealthEx(Boxer2, 50.0);
								}
                                GameTextForPlayer(Boxer1, "~g~Koniec walki", 5000, 1); GameTextForPlayer(Boxer2, "~g~Koniec walki", 5000, 1);
								if(PlayerInfo[Boxer2][pJob] == 10) { PlayerInfo[Boxer2][pBoxSkill] += 1; }
								PlayerBoxing[Boxer1] = 0;
								PlayerBoxing[Boxer2] = 0;
							}
			            }
			            else if(Lost == 2)
			            {
			                if(IsPlayerConnected(Boxer1) && IsPlayerConnected(Boxer2))
			                {
					        	SetPlayerPosEx(Boxer1, 765.8433,3.2924,1000.7186); SetPlayerPosEx(Boxer2, 765.8433,3.2924,1000.7186);
					        	SetPlayerInterior(Boxer1, 5); SetPlayerInterior(Boxer2, 5);
			                	GetPlayerName(Boxer1, winner, sizeof(winner));
			                	GetPlayerName(Boxer2, loser, sizeof(loser));
		                		if(PlayerInfo[Boxer2][pJob] == 12) { PlayerInfo[Boxer2][pLoses] += 1; }
								if(PlayerInfo[Boxer1][pJob] == 12) { PlayerInfo[Boxer1][pWins] += 1; }
			                	if(TBoxer < 255)
			                	{
			                	    if(IsPlayerConnected(TBoxer))
			                	    {
				                	    if(TBoxer != Boxer1)
				                	    {
				                	        if(PlayerInfo[Boxer1][pJob] == 12)
				                	        {
					                	        TBoxer = Boxer1;
					                	        GetPlayerName(TBoxer, titel, sizeof(titel));
					                	        new nstring[MAX_PLAYER_NAME];
												format(nstring, sizeof(nstring), "%s", titel);
												strmid(Titel[TitelName], nstring, 0, strlen(nstring), 255);
					                	        Titel[TitelWins] = PlayerInfo[TBoxer][pWins];
					                	        Titel[TitelLoses] = PlayerInfo[TBoxer][pLoses];
					                	        SaveBoxer();
							                	format(string, sizeof(string), "LS News Sport: %s wygra³ walkê z Mistrzem %s a teraz przeja³ jego pozycje.",  titel, loser);
												OOCOff(COLOR_WHITE,string);
											}
				                	        else
				                	        {
				                	            SendClientMessage(Boxer1, COLOR_LIGHTBLUE, "* Aby zostac Mistrzem, musisz byæ bokserem. !");
				                	        }
										}
										else
										{
										    GetPlayerName(TBoxer, titel, sizeof(titel));
										    format(string, sizeof(string), "LS News Sport: %s wygra³ walkê z Mistrzem %s a teraz przeja³ jego pozycje.",  titel, loser);
											OOCOff(COLOR_WHITE,string);
											Titel[TitelWins] = PlayerInfo[TBoxer][pWins];
				                	        Titel[TitelLoses] = PlayerInfo[Boxer1][pLoses];
				                	        SaveBoxer();
										}
									}
								}//TBoxer
								format(string, sizeof(string), "* Przegra³eœ walkê z %s.", winner);
								SendClientMessage(Boxer2, COLOR_LIGHTBLUE, string);
								GameTextForPlayer(Boxer2, "~r~Przegrales", 3500, 1);
								format(string, sizeof(string), "* Ponownie wygra³eœ walkê z %s.", loser);
								SendClientMessage(Boxer1, COLOR_LIGHTBLUE, string);
								GameTextForPlayer(Boxer1, "~g~Wygrales", 3500, 1);
								if(GetPlayerHealth(Boxer1, health) < 20)
								{
								    SendClientMessage(Boxer1, COLOR_LIGHTBLUE, "* Jesteœ wyczerpany. Zjedz coœ na mieœcie.");
								    SetPlayerHealthEx(Boxer1, 30.0);
								}
								else
								{
								    SendClientMessage(Boxer1, COLOR_LIGHTBLUE, "* Czujesz sie wybornie.");
								    SetPlayerHealthEx(Boxer1, 50.0);
								}
								if(GetPlayerHealth(Boxer2, health) < 20)
								{
								    SendClientMessage(Boxer2, COLOR_LIGHTBLUE, "* Jesteœ wyczerpany. Zjedz coœ na mieœcie.");
							    	SetPlayerHealthEx(Boxer2, 30.0);
								}
								else
								{	
         SendClientMessage(Boxer2, COLOR_LIGHTBLUE, "* Czujesz sie wybornie.");
								 SetPlayerHealthEx(Boxer2, 50.0);
								}

        GameTextForPlayer(Boxer1, "~g~Koniec walki", 5000, 1); GameTextForPlayer(Boxer2, "~g~Koniec walki", 5000, 1);
								if(PlayerInfo[Boxer1][pJob] == 12) { PlayerInfo[Boxer1][pBoxSkill] += 1; }
								PlayerBoxing[Boxer1] = 0;
								PlayerBoxing[Boxer2] = 0;
							}
      }
      InRing = 0;
		    RoundStarted = 0;
		    Boxer1 = 255;
		    Boxer2 = 255;
		    TBoxer = 255;
		    trigger = 0;
		   }
		  }
			}
			if(FindTime[i] > 0)
			{
			    if(FindTime[i] == FindTimePoints[i]) { FindTime[i] = 0; FindTimePoints[i] = 0; DisablePlayerCheckpoint(i); PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0); GameTextForPlayer(i, "~r~Marker zniknal", 2500, 1); }
			    else
				{
				    format(string, sizeof(string), "%d", FindTimePoints[i] - FindTime[i]);
					GameTextForPlayer(i, string, 1500, 6);
					FindTime[i] += 1;
				}
			}
			if(TaxiCallTime[i] > 0)
			{
			    if(TaxiAccepted[i] < 999)
			    {
				    if(IsPlayerConnected(TaxiAccepted[i]))
				    {
				        new Float:X,Float:Y,Float:Z;
						GetPlayerPos(TaxiAccepted[i], X, Y, Z);
						SetPlayerCheckpoint(i, X, Y, Z, 5);
				    }
				}
			}
			if(MedicCallTime[i] > 0)
			{
			    if(MedicCallTime[i] == 30) { MedicCallTime[i] = 0; DisablePlayerCheckpoint(i); PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0); GameTextForPlayer(i, "~r~Marker zniknal", 2500, 1); }
			    else
				{
				    format(string, sizeof(string), "%d", 30 - MedicCallTime[i]);
					GameTextForPlayer(i, string, 1500, 6);
					MedicCallTime[i] += 1;
				}
			}
			if(MechanicCallTime[i] > 0)
			{
			    if(MechanicCallTime[i] == 30) { MechanicCallTime[i] = 0; DisablePlayerCheckpoint(i); PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0); GameTextForPlayer(i, "~r~Marker zniknal", 2500, 1); }
			    else
				{
				    format(string, sizeof(string), "%d", 30 - MechanicCallTime[i]);
					GameTextForPlayer(i, string, 1500, 6);
					MechanicCallTime[i] += 1;
				}
			}
			if(Robbed[i] == 1)
			{
			 if(RobbedTime[i] <= 0)
			 {
			  RobbedTime[i] = 0;
					Robbed[i] = 0;
			 }
			 else
			 {
			  RobbedTime[i] -= 1;
			 }
			}
			if(PlayerCuffed[i] == 1)
			{
			    if(PlayerCuffedTime[i] <= 0)
			    {
			        TogglePlayerControllable(i, 1);
			        PlayerCuffed[i] = 0;
			        PlayerCuffedTime[i] = 0;
			        PlayerTazeTime[i] = 1;
			    }
			    else
			    {
			        PlayerCuffedTime[i] -= 1;
			    }
			}
			if(PlayerCuffed[i] == 2)
			{
			    if(PlayerCuffedTime[i] <= 0)
			    {
			        GameTextForPlayer(i, "~r~Otworzyles kajdanki, jestes wolny!", 2500, 3);
			        TogglePlayerControllable(i, 1);
			        PlayerCuffed[i] = 0;
			        PlayerCuffedTime[i] = 0;
			    }
			    else
			    {
			        PlayerCuffedTime[i] -= 1;
			    }
			}
		}
	}
}

public Fillup(playerid)
{
 if(IsPlayerConnected(playerid))
 {
  new
     vehicleid = GetPlayerVehicleID(playerid),
     Float:fillup,
     costs,
     string[64];

  fillup = GasMax - Vehicles[vehicleid][vFuel];

  if(fillup < 0.0) fillup = 0;
  if(fillup == 0)
  {
   SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Bak paliwa jest pe³ny.");
   TogglePlayerControllable(playerid, 1);
   return 1;
  }

  costs = floatround(fillup * 2.5); //SBizzInfo[3][sbEntranceCost];

  if(GetPlayerMoneyEx(playerid) >= costs)
  {
   Gas[vehicleid] = GasMax;
	 Vehicles[vehicleid][vFuel] = 100.0;

   GivePlayerMoneyEx(playerid, -costs);
			/*SBizzInfo[3][sbTill] += costs;
			ExtortionSBiz(3, costs);*/
			
   TogglePlayerControllable(playerid, 1);

   format(string, sizeof(string), "* Pojazd zatankowany za $%d.", costs);
		 SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
		
		 UpdatePlayerHud(playerid);
  }
  else
  {
   format(string, sizeof(string), "* Brak pieniêdzy. Aby zatankowac potrzebujesz $%d.", costs);
			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
			
			TogglePlayerControllable(playerid, 1);
  }
 }

	return 1;
}

public SetPlayerWeapons(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	if(PlayerInfo[playerid][pJailed] > 0) return 1;
	
	ResetPlayerWeaponsEx(playerid);
	GivePlayerWeaponEx(playerid, 0, 1);
	Items_SetPlayerWeapons(playerid);

	gLogged2[playerid] = 1;

	return 1;
}

public ShowStats(playerid,targetid,admin)
{
	if(IsPlayerConnected(playerid) && IsPlayerConnected(targetid))
	{
		new sextext[2][] = {"Mê¿czyzna", "Kobieta"},
			ufid = GetPlayerUnofficialOrganization(targetid),
			ttext[40],
			rtext[32],
			string[128],
			jtext[40],
			Float:health,
			playername[MAX_PLAYER_NAME];
		
		// organizacja
		if(GetPlayerOrganization(targetid) > 0) { GetPlayerOffOrgName(targetid, ttext, sizeof(ttext)); }
		else if(PlayerInfo[targetid][pUFLeader] < MAX_UNOFFICIAL_FACTIONS+1 || PlayerInfo[targetid][pUFMember] < MAX_UNOFFICIAL_FACTIONS+1) { strmid(ttext, MiniFaction[ufid][mName], 0, strlen(MiniFaction[ufid][mName]), 255); }
		else { ttext = "Brak"; }

		if(GetPlayerOrganization(targetid) > 0)
		{
			GetPlayerOffRankName(targetid, rtext, sizeof(rtext));
		}
		else if(PlayerInfo[targetid][pUFMember] < MAX_UNOFFICIAL_FACTIONS+1 || PlayerInfo[targetid][pUFLeader] < MAX_UNOFFICIAL_FACTIONS+1)
		{
			switch(PlayerInfo[targetid][pRank])
			{		
				case 1: { strmid(rtext, MiniFaction[ufid][mRank1], 0, strlen(MiniFaction[ufid][mRank1]), 255); }
				case 2: { strmid(rtext, MiniFaction[ufid][mRank2], 0, strlen(MiniFaction[ufid][mRank2]), 255); }
				case 3: { strmid(rtext, MiniFaction[ufid][mRank3], 0, strlen(MiniFaction[ufid][mRank3]), 255); }
				case 4: { strmid(rtext, MiniFaction[ufid][mRank4], 0, strlen(MiniFaction[ufid][mRank4]), 255); }
				case 5: { strmid(rtext, MiniFaction[ufid][mRank5], 0, strlen(MiniFaction[ufid][mRank5]), 255); }
			}
		}
		else
		{
			rtext = "Brak";
		}

		// praca		
		GetPlayerJobName(targetid, jtext, sizeof(jtext));

		// biznes
		new businessindex = GetPlayerBusinessId(targetid);
		new bizzname[64];

		if(businessindex == INVALID_BUSINESS_ID)
		{
			strmid(bizzname, "Brak", 0, strlen("Brak"), 255);
		}
		else
		{
			strmid(bizzname, BizzInfo[businessindex][bName], 0, strlen(BizzInfo[businessindex][bName]), 255);
		}

		
		GetPlayerNameEx(targetid, playername, sizeof(playername));
		GetPlayerHealth(targetid, health);
		
		if (admin)
		{
	  	format(string, sizeof(string), "** Statystyki %s (UID: %d) **", playername, PlayerInfo[targetid][pId]);
	  	SendClientMessage(playerid, COLOR_LORANGE, string);
		  format(string, sizeof(string), "[Postaæ:] P³eæ:[%s] Wiek:[%d] ¯ycie:[%.2f] Ostrze¿enia:[%d] Skin:[%d]", sextext[GetPlayerSex(targetid)-1], PlayerInfo[targetid][pAge], health, PlayerInfo[targetid][pWarns], GetPlayerSkin(targetid));
		  SendClientMessage(playerid, COLOR_AWHITE, string);
	  	format(string, sizeof(string), "[Zatrudnienie:] Praca: [%s] Organizacja:[%s] Ranga:[%s] Firma:[%s]",jtext,ttext,rtext, bizzname);
		  SendClientMessage(playerid, COLOR_AWHITE, string);
	  	format(string, sizeof(string), "[Statystyki:] Morderstw:[%d] Zgonów:[%d] Przestêpstw:[%d] Czas Gry:[%d]",PlayerInfo[targetid][pKills],PlayerInfo[targetid][pDeaths],PlayerInfo[targetid][pCrimes],PlayerInfo[targetid][pConnectTime]);
	  	SendClientMessage(playerid, COLOR_AWHITE, string);
		  format(string, sizeof(string), "[Fundusze:] Pieni¹dze:[$%d] Fundusze w Banku:[$%d]", GetPlayerMoneyEx(targetid), PlayerInfo[targetid][pAccount]);
		  SendClientMessage(playerid, COLOR_AWHITE, string);

		  if (PlayerInfo[playerid][pAdmin] >= 1)
		  {
		  	format(string, sizeof(string), "HouseKey:[%d] Local:[%d,%d] Admin:[%d] BW:[%s] pWounded:[%d] dpDeath:[%d]", PlayerInfo[targetid][pPhousekey], PlayerInfo[targetid][pLocalType], PlayerInfo[targetid][pLocal],PlayerInfo[targetid][pAdmin],YesOrNo((PlayerInfo[targetid][pWounded] > 0 ? 1 : 0)),PlayerInfo[targetid][pWounded],deadPosition[playerid][dpDeath]);
			  SendClientMessage(playerid, COLOR_GRAD2, string);
	  	}
		
		}
		
		  new caption[64];
		  format(caption, sizeof(caption), "Informacje o %s (UID: %d)", playername, PlayerInfo[targetid][pId]);
		
		#define ShowDialogList(%1,%2,%3,%4,%5,%6) ShowPlayerDialog(%1, %2, DIALOG_STYLE_LIST, %3, %4, %5, %6)
		
		new data[1124];
		format(data, sizeof(data), 
				"Wiek:\t\t\t%d\n" \
				"P³eæ:\t\t\t%s\n" \
				"Czas gry:\t\t%d\n"\
				"¯ycie:\t\t\t%.1f%%\n" \
				"Praca:\t\t\t%s\n" \
				"Organizacja:\t\t%s\n" \
				"Ranga: \t\t\t%s\n" \
				"Firma:\t\t\t%s\n" \
				"Portfel:\t\t\t$%d\n" \
				"Bank:\t\t\t$%d\n"\ 
				"Wyp³ata:\t\t$%d\n" \
				"Skin:\t\t\t%d\n" \
				"--------------------------------------------\n" \
				"Morderstw:\t\t%d\n" \
				"Zgonów:\t\t%d\n" \
				"Textura Iphone:\t\t%s",
			PlayerInfo[targetid][pAge],
			sextext[GetPlayerSex(targetid)-1],
			PlayerInfo[targetid][pConnectTime],
			health,
			jtext,
			ttext,
			rtext,
			bizzname,
			GetPlayerMoneyEx(targetid),
			PlayerInfo[targetid][pAccount],
			PlayerInfo[targetid][pPayment],
			GetPlayerSkin(targetid),
			PlayerInfo[targetid][pKills],
			PlayerInfo[targetid][pDeaths],
			PlayerInfo[targetid][pTextureIphone]
		);
		
		new phonenumbers[256];
		new tmpstr[32];
		new pncount = 0;
		format(phonenumbers, sizeof(phonenumbers), "\nNumery telefonów:\n");
		
		for(new i = 0; i < MAX_ITEMS; i++)
		{
			if(Items[i][iId] != INVALID_ITEM_ID && Items[i][iItemId] == ITEM_CELLPHONE && Items[i][iOwner] == PlayerInfo[targetid][pId] && Items[i][iOwnerType] == CONTENT_TYPE_USER)
			{
				format(tmpstr, sizeof(tmpstr), "%d.\t\t\t%d", pncount + 1, Items[i][iAttr1]);
				if(Items[i][iFlags] & ITEM_FLAG_USING) strcat(tmpstr, " (w u¿ytku)");
				strcat(tmpstr, "\n");
				strcat(phonenumbers, tmpstr);
				
				pncount++;
			}
		}
		
		if(pncount == 0)
		{
			strcat(phonenumbers, "- brak");
		}
		
		strcat(data, phonenumbers);
		
		if (!admin) ShowDialogList(playerid, DIALOG_NONE, caption, data, "Ok", "Zamknij");//16
		
	}
}
//---------------------------------------------------------

public SetPlayerToTeamColor(playerid)
{/*
	if(IsPlayerConnected(playerid))
	{
		switch(GetPlayerOrganization(playerid))
		{
			case 1:  { SetPlayerColorStatement(playerid, OnDuty[playerid], COLOR_DBLUE, 					COLOR_YELLOW2); }
			case 2:  { SetPlayerColorStatement(playerid, OnDuty[playerid], TEAM_BLUE_COLOR, 			COLOR_YELLOW2); }
			case 3:  { SetPlayerColorStatement(playerid, OnDuty[playerid], COLOR_GREEN, 					COLOR_YELLOW2); }
			case 4:  { SetPlayerColorStatement(playerid, OnDuty[playerid], TEAM_BLUE2_COLOR, 			COLOR_YELLOW2); }
			case 7:  { SetPlayerColorStatement(playerid, OnDuty[playerid], TEAM_HIT_COLOR, 				COLOR_YELLOW2); }
			case 9:  { SetPlayerColorStatement(playerid, OnDuty[playerid], TEAM_REPORT_COLOR, 		COLOR_YELLOW2); }
			case 10: { SetPlayerColorStatement(playerid, OnDuty[playerid], TEAM_VAGOS_COLOR, 			COLOR_YELLOW2); }
			case 18: { SetPlayerColorStatement(playerid, OnDuty[playerid], TEAM_FIRE_DEPARTMENT, 	COLOR_YELLOW2); }
			case 11: { SetPlayerColorStatement(playerid, OnDuty[playerid], TEAM_INSTR_COLOR, 			COLOR_YELLOW2); }
			case 13: { SetPlayerColorStatement(playerid, OnDuty[playerid], COLOR_DBLUE, 					COLOR_YELLOW2); }
			default: { SetPlayerColor(playerid, COLOR_YELLOW2); }
		}*/
		SetPlayerColor(playerid, COLOR_YELLOW2);
		ToggleBlipVisibilty(playerid, true);
	//}
}

//---------------------------------------------------------

public GameModeInitExitFunc()
{
	KillTimer(healthtimer);
  KillTimer(AFKTimer);


	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			DisablePlayerCheckpoint(i);
			gPlayerCheckpointStatus[i] = CHECKPOINT_NONE;
			GameTextForPlayer(i, "Restart Mapy", 1500, 5);
			SetPlayerCameraPos(i,1460.0, -1324.0, 287.2);
			SetPlayerCameraLookAt(i,1374.5, -1291.1, 239.0);
			SetPlayerInterior(i, 0);
			SetPlayerVirtualWorld(i, 0);
			OnPlayerSave(i);
			MySQLSetPlayerNotLogged(i);
			gPlayerLogged[i] = 0;
		}
	}
	SetTimer("GameModeExitFunc", 2000, 0);
	return 1;
}

public GameModeExitFunc()
{
	KillTimer(synctimer);
	KillTimer(unjailtimer);
	KillTimer(othtimer);
	KillTimer(othtimer2);
	KillTimer(accountstimer);
	KillTimer(pickuptimer);
	KillTimer(productiontimer);
	KillTimer(spectatetimer);
	KillTimer(speedtimer);
	KillTimer(MysqlConnectionTimer);
	KillTimer(anticheattimer);


	Vehicles_GameModeExit();
	MySQLDisconnect();
	
	GameModeExit();
}

public LoadBoxer()
{
	new arrCoords[3][64];
	new strFromFile2[256];
	new File: file = fopen("boxer.ini", io_read);
	if (file)
	{
		fread(file, strFromFile2);
		split(strFromFile2, arrCoords, ',');
		Titel[TitelWins] = strval(arrCoords[0]);
		strmid(Titel[TitelName], arrCoords[1], 0, strlen(arrCoords[1]), 255);
		Titel[TitelLoses] = strval(arrCoords[2]);
		fclose(file);
	}
	return 1;
}

public SaveBoxer()
{
	new coordsstring[256];
	format(coordsstring, sizeof(coordsstring), "%d,%s,%d", Titel[TitelWins],Titel[TitelName],Titel[TitelLoses]);
	new File: file2 = fopen("boxer.ini", io_write);
	fwrite(file2, coordsstring);
	fclose(file2);
	return 1;
}

public LoadStuff()
{
 Tax = Config_ReadInt("tax");
 TaxValue = Config_ReadFloat("tax_value");
 ReservedSlots = Config_ReadInt("reserved_slots");

 return 1;
}

public SaveStuff()
{
	Config_WriteInt("tax", Tax);
	Config_WriteFloat("tax_value", TaxValue);
	
	return 1;
}

forward LoadMiniFactions();
public  LoadMiniFactions()
{
 // baza danych zamiast pliku tekstowego
	new query[256];
	
	//mysql_real_escape_string("SELECT * FROM game_house", query);
	format(query, sizeof(query), "SELECT * FROM organization_game_unofficial_factions ORDER BY id ASC");
	mysql_query(query);
	mysql_store_result();	

	new line[1024];
	
	new idx;
	new data[20][64];
	
	while(mysql_fetch_row_format(line) == 1)
	{
	  split(line, data, '|');

    idx = strval(data[0]);

		MiniFaction[idx][mId] = idx;
		strmid(MiniFaction[idx][mName], data[1], 0, strlen(data[1]), 255);
		strmid(MiniFaction[idx][mMOTD], data[2], 0, strlen(data[2]), 255);
		MiniFaction[idx][mLeader] = strval(data[3]);
		MiniFaction[idx][mSpawnX] = floatstr(data[4]);
		MiniFaction[idx][mSpawnY] = floatstr(data[5]);
		MiniFaction[idx][mSpawnZ] = floatstr(data[6]);
		MiniFaction[idx][mSpawnA] = floatstr(data[7]);
		MiniFaction[idx][mSpawnInterior] = strval(data[8]);
		MiniFaction[idx][mSpawnVW] = strval(data[9]);
		strmid(MiniFaction[idx][mRank1], data[10], 0, strlen(data[10]), 255);
		strmid(MiniFaction[idx][mRank2], data[11], 0, strlen(data[11]), 255);
		strmid(MiniFaction[idx][mRank3], data[12], 0, strlen(data[12]), 255);
		strmid(MiniFaction[idx][mRank4], data[13], 0, strlen(data[13]), 255);
		strmid(MiniFaction[idx][mRank5], data[14], 0, strlen(data[14]), 255);
		MiniFaction[idx][mType] = strval(data[15]);
	}
	
	mysql_free_result();
}

/*public LoadProperty()
{
	// baza danych zamiast pliku tekstowego
	new query[256];
	
	//mysql_real_escape_string("SELECT * FROM game_house", query);
	format(query, sizeof(query), "SELECT h.*, (SELECT username FROM auth_user WHERE id = h.owner_id) FROM `auth_game_house` h ORDER BY h.id ASC");
	mysql_query(query);
	mysql_store_result();	

	new line[1024];
	
	new idx;
	new data[21][64];
	
	while(mysql_fetch_row_format(line) == 1)
	{
	 split(line, data, '|');

		HouseInfo[idx][hId] = strval(data[0]);	
  HouseInfo[idx][hEntrancex] = floatstr(data[1]);
		HouseInfo[idx][hEntrancey] = floatstr(data[2]);
		HouseInfo[idx][hEntrancez] = floatstr(data[3]);
		HouseInfo[idx][hExitx] = floatstr(data[4]);
		HouseInfo[idx][hExity] = floatstr(data[5]);
		HouseInfo[idx][hExitz] = floatstr(data[6]);
		HouseInfo[idx][hOwner] = strval(data[7]);
		strmid(HouseInfo[idx][hDiscription], data[8], 0, strlen(data[8]), 255);
		HouseInfo[idx][hHel] = strval(data[9]);
		HouseInfo[idx][hArm] = strval(data[10]);
		HouseInfo[idx][hInt] = strval(data[11]);
		HouseInfo[idx][hLock] = strval(data[12]);
		HouseInfo[idx][hOwned] = strval(data[13]);
		HouseInfo[idx][hRent] = strval(data[14]);
		HouseInfo[idx][hRentabil] = strval(data[15]);
		HouseInfo[idx][hTakings] = strval(data[16]);
		HouseInfo[idx][hDate] = strval(data[17]);
		HouseInfo[idx][hRubbish] = strval(data[18]);
		HouseInfo[idx][hVW] = strval(data[19]);
		strmid(HouseInfo[idx][hOwnerName], data[20], 0, strlen(data[20]), 255);
		
  idx++;
	}
	
	mysql_free_result();
	
	return 1;
}*/

//------------------------------------------------------------------------------------------------------
public OnGameModeInit()
{
	MySQLConnect(MYSQL_HOST,MYSQL_USER,MYSQL_PASS,MYSQL_DB);
	
	MysqlConnectionTimer = SetTimer("MySQLCheckConnection", 10000, 1);
	
	mysql_query("SET NAMES 'cp1250';");
	mysql_query("UPDATE `auth_userprofile` SET online_game = 0");
	mysql_query("DELETE FROM `items_item` WHERE updated < DATE_SUB( NOW( ) , INTERVAL 3 DAY ) AND owner_id IS NULL");
	
	// sounds
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		PlayerSound[i][sObject] = -1;
		PlayerSound[i][sSound]  = 0;
	}
	Signals_Init();
	Audio_Init();
	Objects_Init();
	Objects_SpawnObjects();

	InitTextdraws();
	InitBets();

	InitOfficialOrganizations();
	InitOfficialOrganizationsRanks();
	
	Nametags_Init();
	Description_Init();

	#if CORPSES
	InitCorpses();
	#endif
	
	LoadJobs();
	InitVehicles();
	LoadItemsTypes();
	InitItems();
	LoadItems();
	LoadVehiclesCosts();
	//LoadProperty();
	InitDoorsInfo();
	LoadDoorsInfo();
	LoadBizz();
	LoadBoxer();
	LoadStuff();
	LoadVehicles();
	InitOffers();
	LoadMiniFactions();
	InitBushes();
	InitGates();
	//NickiTimer();
    //SetTimer("NickiTimer", 900, 1);



	// pogoda
	actWeather = Config_ReadInt("weather");
	SetWeather(actWeather);
	AutoChangeWeatherTimer = 1800 + random(900);

  // konfiguracja gamemode'a
	SetGameModeText("Los Santos RP " MODE_VERSION);
	
	SetNameTagDrawDistance(20);
	EnableZoneNames(0);
	AllowInteriorWeapons(1);
	AllowAdminTeleport(1);
	DisableInteriorEnterExits();
	ShowPlayerMarkers(1);
	
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		for(new j = 0; j < MAX_PLAYERS; j++)
		{
			SetPlayerMarkerForPlayer(i, j, 0xFFFFFF00);
		}
	}

	CreatePickup(1273, 2, CAR_HIDE_X,CAR_HIDE_Y,CAR_HIDE_Z, -1); 	// pierwszy pickup, fix na dziwne bledy

	/*for(new h = 0; h < sizeof(HouseInfo); h++)
	{
		HouseInfo[h][hPickup] =	CreatePickup(HouseInfo[h][hOwned] ? 1239 : 1273, 2, HouseInfo[h][hEntrancex], HouseInfo[h][hEntrancey], HouseInfo[h][hEntrancez], 0);
	}*/
 
	AddStaticPickup(1239, 2, 1381.0413,-1088.8511,27.3906, -1);   //Bill Board (old Job Department)
	AddStaticPickup(1239, 2, 2231.8022,-2267.1614,14.7647, -1);   //-2119.5469,-178.5679,35.3203); //Factory
	AddStaticPickup(1239, 2, 821.5608,-849.2943,69.9195, -1);  		//Hitman Agency entrance
	AddStaticPickup(1239, 2, 1122.7148,-2036.8737,69.8942, -1);   // Siedziba Rz¹d
	AddStaticPickup(1239, 2, 1532.4188,-1335.4871,16.6109, -1);   // Nadawanie Reklamy
	AddStaticPickup(1314, 1, 2254.8943,-1333.1936,23.9815, -1);   // koœciól ikonka
	AddStaticPickup(1240, 2, 2557.7437,-1301.2457,1060.9844, -1); // serduszko ykza
	AddStaticPickup(1240, 2, 144.5114,1385.4985,1083.8647, -1);   // serduszko lcn
	AddStaticPickup(1239, 2, 2127.7383,-2275.5435,20.6719, -1);   // zamowienia nielegalnych przedmiotow
	AddStaticPickup(1239, 2, 1666.2834,2235.5798,1001.0219, -1);  // Kasyno
	AddStaticPickup(1239, 2, 240.4544,112.7762,1003.2188, -1);    // swat pickup dla zbrojowni, /duty, /heal
	AddStaticPickup(1275, 2, 207.5627,-103.7291,1005.2578, -1);   // binco
	AddStaticPickup(1275, 2, 203.9068,-41.0728,1001.8047, -1);    // suburban
	AddStaticPickup(1275, 2, 214.4470,-7.6471,1001.2109, -1);     // zip
	AddStaticPickup(1275, 2, 161.3765,-83.8416,1001.8047, -1);    // victim
	AddStaticPickup(1239, 2, -1345.9856,492.5738,11.2027, -1); 		// materialy
	AddStaticPickup(1239, 2, -1376.2465,1493.3951,11.2031, -1); 	// materialy

  pickupGettingDrugs  = CreatePickup(1239, 2, 331.8978,1119.9894,1083.8903, -1);    //Getting Drugs for DrugDealers // LAWYER
	pickupHotel         = CreatePickup(1239, 2, 2216.5930,-1147.6163,1025.7969, -1); 	// Hotel Miejsce Zameldowaina
	pickupHotel2        = CreatePickup(1239, 2, 2269.7852,1628.7980,1084.2451, -1); 	// Hotel Miejsce Zameldowaina
	pickupAcademy       = CreatePickup(1239, 2, -2031.2834,-115.0051,1035.1719, -1); 	// bronie dla akademii
  pickupIllegalItems  = CreatePickup(1239, 2, 198.4999,-226.2708,1.7786, -1);      	// odbiór nielegalnych przedmiotów w Blueberry
	pickupPayment       = CreatePickup(1274, 2, 2309.8696,-8.3771,26.7422, -1);
	pickupPolicePark    = CreatePickup(1239, 2, 1526.1028,-1677.8374,5.8906, -1);   	// zbrojownia policji
	pickupOrderVehicle  = CreatePickup(1239, 2, 914.9579,-1229.8766,17.3020, -1);   	// bank
	pickupTaxi          = CreatePickup(1239, 2, 828.9884,-1364.3656,-0.5015, -1);  	// taxi

	if(realtime)
	{
		new tmphour, tmpminute, tmpsecond;
		gettime(tmphour, tmpminute, tmpsecond);
		FixHour(tmphour);
		tmphour = shifthour;
		SetWorldTimeEx(tmphour);
		ghour = tmphour;
	}
	
	// timery
	synctimer = SetTimer("SyncUp", 30000, 1);
	unjailtimer = SetTimer("SetPlayerUnjail", 1000, 1);
	othtimer = SetTimer("OtherTimer", 1000, 1);
	othtimer2 = SetTimer("OtherTimer2", 1000, 1);	
	pickuptimer = SetTimer("CustomPickups", 1000, 1);
	productiontimer = SetTimer("Production", 300000, 1); //5 mins (300000)
	accountstimer = SetTimer("SaveAccounts", 600000, 1); //30 mins every account saved
	speedtimer = SetTimer("SpeedCheck", 1000, 1); // predkosciomierz
	healthtimer = SetTimer("HealthTimer", 3000, 1);
	AFKTimer = SetTimer("CheckIfAFKing", 60000, 1);
	anticheattimer = SetTimer("AnticheatTimer", 100, 1);

	// bramy
	/*gatePoliceA = CreateDynamicObject(11327, 1587.6304, -1638.0895, 14.9000, 0, 0, 90, 0, 0, -1, 200); // komisariat brama A
	//gateDmv = CreateObject(969, 377.6370,169.6422,1010.2500, 0, 0, 90); // DMV krata
	//gateParkingPolice = CreateObject(968, 1544.6842, -1630.9032, 13.0421, 0, 269.7592, 270);
	//gatePrison = CreateObject(986, 1314.3499755859, 723.38000488281, 11.570300102234, 0, 0, 270);
	
	gateParkingPolice = CreateDynamicObject(968, 1544.6842, -1630.9032, 13.0421, 0, 269.7592, 270, 0, 0, -1,200.0);
	gatePrison = CreateDynamicObject(986, 1314.3499755859, 723.38000488281, 11.570300102234, 0, 0, 270, 0, 0, -1,200.0);
	
	//gateBorderIn = CreateDynamicObject(968, 425.76678466797, 619.88500976563, 18.532789230347, 0, 270, 35.285308837891, 0, 0, -1,200.0);
	//gateBorderOut = CreateDynamicObject(968, 420.83969116211, 602.84161376953, 18.633125305176, 0, 270, 214.29504394531, 0, 0, -1,200.0);
	gateBorderIn_new = CreateDynamicObject(980,411.65646362305, 625.54577636719, 20.010507583618, 0, 0, 32.675231933594,0,0,-1,200.0);
	gateBorderOut_new = CreateDynamicObject(980,429.54339599609, 603.01300048828, 20.895345687866, 0, 0, 35.1552734375,0,0,-1,200.0);*/

	//-------------------------------------------------------[Boxy przy logowaniu]-----------------------------------------------------
	Textdraw1 = TextDrawCreate(320.000000, 337.000000, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~");
	TextDrawAlignment(Textdraw1, 2);
	TextDrawBackgroundColor(Textdraw1, 255);
	TextDrawFont(Textdraw1, 0);
	TextDrawLetterSize(Textdraw1, 1.000000, 3.300000);
	TextDrawColor(Textdraw1, -1);
	TextDrawSetOutline(Textdraw1, 0);
	TextDrawSetProportional(Textdraw1, 1);
	TextDrawSetShadow(Textdraw1, 1);
	TextDrawUseBox(Textdraw1, 1);
	TextDrawBoxColor(Textdraw1, 0x00000055);
	TextDrawTextSize(Textdraw1, 0.000000, 640.000000);

	Textdraw2 = TextDrawCreate(650.000000, 0.000000, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~");
	TextDrawBackgroundColor(Textdraw2, 255);
	TextDrawFont(Textdraw2, 1);
	TextDrawLetterSize(Textdraw2, 0.500000, 1.000000);
	TextDrawColor(Textdraw2, -1);
	TextDrawSetOutline(Textdraw2, 0);
	TextDrawSetProportional(Textdraw2, 1);
	TextDrawSetShadow(Textdraw2, 1);
	TextDrawUseBox(Textdraw2, 1);
	TextDrawBoxColor(Textdraw2, 0x00000055);
	TextDrawTextSize(Textdraw2, -10.000000, 10.000000);
	
	// TextDraw z karami
	Kara = TextDrawCreate(1.000000, 428.000000, "~>~ ~r~Admin Jail ~<~");
	TextDrawBackgroundColor(Kara, 255);
	TextDrawFont(Kara, 1);
	TextDrawLetterSize(Kara, 0.280000, 0.799999);
	TextDrawColor(Kara, 0xB22222FF);
	TextDrawSetOutline(Kara, 0);
	TextDrawSetProportional(Kara, 1);
	TextDrawSetShadow(Kara, 1);
	TextDrawUseBox(Kara, 1);
	TextDrawBoxColor(Kara, 200);
	TextDrawTextSize(Kara, 710.000000, 0.000000);
	
foreachEx(playerid, MAX_PLAYERS)
{
	
	AudioPlugin[playerid] = TextDrawCreate(573.000000, 390.000000, "Wczytywanie klienta dzwieku ");
	TextDrawAlignment(AudioPlugin[playerid], 2);
	TextDrawBackgroundColor(AudioPlugin[playerid], 255);
	TextDrawFont(AudioPlugin[playerid], 1);
	TextDrawLetterSize(AudioPlugin[playerid], 0.2522, 1.1000);
	TextDrawColor(AudioPlugin[playerid], -1);
	TextDrawSetOutline(AudioPlugin[playerid], 0);
	TextDrawSetProportional(AudioPlugin[playerid], 1);
	TextDrawSetShadow(AudioPlugin[playerid], 1);
	TextDrawUseBox(AudioPlugin[playerid], 1);
	TextDrawBoxColor(AudioPlugin[playerid], 0x00000055);
	TextDrawTextSize(AudioPlugin[playerid], 27.000000, 114.000000);
}
/*
	//Telefon Textdrawn
	p4 = TextDrawCreate(492.0, 115.0, "~g~~<~~b~ Telefon ~g~~>~");
	//TextDrawLetterSize(p4, 0.60, 1.10);
	TextDrawLetterSize(p4, 0.60, 1.05);
	TextDrawAlignment(p4, 2);
	//TextDrawFont(p4, 1);

	p3 = TextDrawCreate(500.0, 110.0, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~");
	TextDrawUseBox(p3, 1);
	TextDrawBoxColor(p3, 0x00000055);
	//TextDrawLetterSize(p3, 0.60, 1.05);
	//TextDrawTextSize(p3, 120.0, 150.0);
	TextDrawAlignment(p3, 2);
	TextDrawLetterSize(p3, 0.60, 1.05);
	TextDrawTextSize(p3, 150.0, 180.0);
	
	p5 = TextDrawCreate(430.0, 135.0, "~n~~y~1~w~ - ~w~Zadzwon~n~~n~~y~2~w~ - ~w~Wyslij SMS~n~~n~~y~3~w~ - ~w~Kontakty~n~~n~~y~4~w~ - ~w~Wyslij vCard~n~~n~~y~5 ~w~- Dodatki~n~~n~~y~6~w~ - ~w~Opcje");
	//TextDrawLetterSize(p5, 0.60, 0.80);
	TextDrawAlignment(p5, 1);
	TextDrawLetterSize(p5, 0.60, 1.05);
	TextDrawFont(p5, 1);
	*/
	//tutaj nowy TD od telefonu, yoooooooooooooooooooooooooooooooooooooooooooooooo
	
	p3 = TextDrawCreate(500.0, 110.0, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~");
	TextDrawUseBox(p3, 1);
	TextDrawBoxColor(p3, 0x00000055);
	//TextDrawLetterSize(p3, 0.60, 1.05);
	//TextDrawTextSize(p3, 120.0, 150.0);
	TextDrawAlignment(p3, 2);
	TextDrawLetterSize(p3, 0.60, 1.05);
	TextDrawTextSize(p3, 150.0, 180.0);
	
	
	//End new phone
	//Iphone texture
	txtSprite1 = TextDrawCreate(500.0, 120.0, "telefon:bmp");
    TextDrawFont(txtSprite1, 4);
    TextDrawColor(txtSprite1,0xFFFFFFAA);
    TextDrawTextSize(txtSprite1,120.0,200.0);
    
    //Camera texture
	txtSprite2 = TextDrawCreate(0.0, 0.0, "telefon:bmp2");
    TextDrawFont(txtSprite2, 4);
    TextDrawColor(txtSprite2,0xFFFFFFAA);
    TextDrawTextSize(txtSprite2,640.0,480.0);
	
	  Audio_SetPack("ls-rp", true);
  	  Audio_SetPack("Iphone_Sounds", true);
  		
	//blocades
	for (new i=0; i<sizeof(blocades) ; i++)
	{
	  //blocades[i][blocadeobject] = CreateObject(3578,0,0,0,0,0,0);
		blocades[i][blocadeobject] = CreateDynamicObject(3578, 0,0, 0,0, 0, 0, 0, 0, -1, BLOCADE_STREAMER_DISTANCE);
	}
	
	//lotniskowiec
	/*CreateObject(10771, -1377.8713378906, -6230.3168945313, 4.9869999885559, 0, 0, 0);
	CreateObject(11145, -1440.7550048828, -6230.2978515625, 3.7999999523163, 0, 0, 0);
	CreateObject(11146, -1386.8599853516, -6229.755859375, 11.829999923706, 0, 0, 0);
	CreateObject(10770, -1374.5999755859, -6237.8598632813, 38.220001220703, 0, 0, 0);
	CreateObject(11149, -1383.9460449219, -6235.5004882813, 11.525799751282, 0, 0, 0);
	CreateObject(11237, -1374.6020507813, -6237.8618164063, 38.201988220215, 0, 0, 0);
	CreateObject(3114, -1434.6300048828, -6215.1586914063, 16.223812103271, 0, 0, 0);
	CreateObject(3115, -1476.8698730469, -6230.2998046875, 9.4600715637207, 0, 0, 179.9599609375);
	CreateObject(3113, -1485.9399414063, -6230.3505859375, 0.60000002384186, 0, 0, 0);
	CreateObject(10772, -1376.5268554688, -6230.5209960938, 16.776063919067, 0, 0, 0);*/

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		gAtmTimer[i]   = 0;
		mConvoy[i]     = 0;
	}
	
	CreateATM(0, 1498.155396, -1749.926392, 15.088212, 180.0000);
	CreateATM(1, 1010.918640, -929.179504, 41.971024,  7.8122);
	CreateATM(2, 1749.821411, -1863.530151, 13.217860, 180.0000);
	CreateATM(3, 821.170898,  -1356.465576, 13.186596,  180.0000);
	CreateATM(4, 1493.256958, -1022.165039, 23.470356, 0.0000);
	CreateATM(5, 2233.182373, -1165.223267, 25.54008, 270.0000);
	CreateATM(6, 1708.015015, -2309.602295, -3.001534, 0.0000);
    printf("blabla: %d", CountDynamic3DTextLabels());
	return 1;
}



public SyncUp()
{
 //
}

public SyncTime()
{
	new string[64];
	new tmphour;
	new tmpminute;
	new tmpsecond;
	gettime(tmphour, tmpminute, tmpsecond);
	FixHour(tmphour);
	tmphour = shifthour;
	
	if ((tmphour > ghour) || (tmphour == 0 && ghour == 23))
	{
		print("PAYDAY");
		format(string, sizeof(string), "SERWER: Aktualnie jest godzina %d:00",tmphour);
		WeaponDropByHour(tmphour);
		BroadCast(COLOR_WHITE,string);
		ghour = tmphour;
		PayDay();
		if (realtime)
		{
			SetWorldTimeEx(tmphour);
		}
	}
	
	DollahScoreUpdate();
}

public SaveAccounts()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			OnPlayerSave(i);
		}
	}
}

stock GetClosestPlayer(p1)
{
	new x,Float:dis,Float:dis2,player;
	player = -1;
	dis = 99999.99;
	for (x=0;x<MAX_PLAYERS;x++)
	{
		if(IsPlayerConnected(x))
		{
			if(x != p1)
			{
				dis2 = GetDistanceBetweenPlayers(x,p1);
				if(dis2 < dis && dis2 != -1.00)
				{
					dis = dis2;
					player = x;
				}
			}
		}
	}
	return player;
}

public  GetClosestVehicle(playerid)
{
	new Float:vx, Float:vy, Float:vz, Float:px, Float:py, Float:pz, Float:dis, Float:dis2, vehicle, x;
	vehicle = -1;
	dis = 99999.99;
	
	GetPlayerPos(playerid, px, py, pz);
	
	for (x=0;x<MAX_VEHICLES;x++)
	{
	 GetVehiclePos(x, vx, vy, vz);
		dis2 = GetDistanceBetweenPoints(vx, vy, vz, px, py, pz);
		if(dis2 < dis && dis2 != -1.00)
		{
			dis = dis2;
			vehicle = x;
		}
	}
	return vehicle;
}

forward GetClosestVehicleInRange(playerid, Float:range);
public GetClosestVehicleInRange(playerid, Float:range)
{
	new Float:vx, Float:vy, Float:vz, Float:px, Float:py, Float:pz, Float:dis, Float:dis2, vehicle, x;
	vehicle = -1;
	dis = range;
	
	GetPlayerPos(playerid, px, py, pz);
	
	for (x=0;x<MAX_VEHICLES;x++)
	{
	 GetVehiclePos(x, vx, vy, vz);
		dis2 = GetDistanceBetweenPoints(vx, vy, vz, px, py, pz);
		if(dis2 < dis && dis2 != -1.00)
		{
			dis = dis2;
			vehicle = x;
		}
	}
	return vehicle;
}

public Production()
{
	new string[128];

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
		 // czas
		 if(PlayerInfo[i][pWounded] > 0) { ApplyAnimationWounded(i); }
		 if(PlayerInfo[i][pFishes] >= 5) { if(FishCount[i] >= 3) { PlayerInfo[i][pFishes] = 0; } else { FishCount[i] += 1; } }
		 if(PlayerStoned[i] > 0) { PlayerStoned[i] = 0; GameTextForPlayer(i, "~p~Faza sie skonczyla", 3500, 1); }
		 if(PlayerInfo[i][pPayDay] < 6) { PlayerInfo[i][pPayDay] += 1; } //+ 5 min to PayDay anti-abuse
		 for(new k = 0; k < MAX_PLAYERS; k++)
			{
				if(IsPlayerConnected(k))
				{
				 if(GetPlayerOrganization(k) == 1 && CrimInRange(80.0, i,k))
				 {
					}
					else
					{
					 WantedPoints[i] -= 1;
					 SetPlayerWantedLevel(i, WantedLevel[i]);
					 if(WantedPoints[i] < 0) { WantedPoints[i] = 0; }
					 new points = WantedPoints[i];
					 new wlevel;
					 if(points > 0)
						{
						 new yesnox;
							if(points == 3) { if(WantedLevel[i] != 1) { WantedLevel[i] = 1; wlevel = 1; yesnox = 1; } }
							else if(points >= 4 && points <= 5) { if(WantedLevel[i] != 2) { WantedLevel[i] = 2; wlevel = 2; yesnox = 1; } }
							else if(points >= 6 && points <= 7) { if(WantedLevel[i] != 3) { WantedLevel[i] = 3; wlevel = 3; yesnox = 1; } }
							else if(points >= 8 && points <= 9) { if(WantedLevel[i] != 4) { WantedLevel[i] = 4; wlevel = 4; yesnox = 1; } }
							else if(points >= 10 && points <= 11) { if(WantedLevel[i] != 5) { WantedLevel[i] = 5; wlevel = 5; yesnox = 1; } }
							else if(points >= 12 && points <= 13) { if(WantedLevel[i] != 6) { WantedLevel[i] = 6; wlevel = 6; yesnox = 1; } }
							else if(points >= 14) { if(WantedLevel[i] != 10) { WantedLevel[i] = 10; wlevel = 10; yesnox = 1; } }
							else if(points <= 0) { if(WantedLevel[i] != 0) { ClearCrime(i); WantedLevel[i] = 0; wlevel = 0; yesnox = 1;} }
							if(yesnox)
							{
								format(string, sizeof(string), "Aktualny poziom poszukiwania: %d", wlevel);
								SendClientMessage(i, COLOR_YELLOW, string);
								SetPlayerWantedLevel(i, wlevel);
							}
						}
					}
				}
			}
		}
	}
}

/*public DateProp(playerid)
{
	new playername[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playername, sizeof(playername));
	new curdate = getdate();
	for(new h = 0; h < sizeof(HouseInfo); h++)
	{
		if(PlayerInfo[playerid][pId] == HouseInfo[h][hOwner])
		{
		 HouseInfo[h][hDate] = curdate;
		 OnHouseUpdate(h);
		}
	}
	return 1;
}*/

/*public Checkprop()
{
	new olddate;
	new curdate = getdate();
	for(new h = 0; h < sizeof(HouseInfo); h++)
	{
		if(HouseInfo[h][hOwned] == 1 && HouseInfo[h][hDate] > 9)
		{
			olddate = HouseInfo[h][hDate];
			if(curdate-olddate >= 14)
			{
				HouseInfo[h][hHel] = 0;
				HouseInfo[h][hArm] = 0;
				HouseInfo[h][hLock] = 1;
				HouseInfo[h][hOwned] = 0;
			 HouseInfo[h][hOwner] = 0;
				//format(string, sizeof(string), "REAL ESTATE: A House is available at a value of $%d",HouseInfo[h][hValue]);
				//SendClientMessageToAll(TEAM_BALLAS_COLOR, string);
				OnHouseUpdate(h);
			}
		}
	}
	return 1;
}*/

public PayDay()
{
	new string[128];
	new account,interest;
	new rent = 0;

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			// kontrakt
			if(PlayerInfo[i][pJob] > 0)
			{
				if(PlayerInfo[i][pContractTime] > 0)
				{
					PlayerInfo[i][pContractTime] -= 1;
				}
			}
			account = PlayerInfo[i][pAccount];
			new key = PlayerInfo[i][pPhousekey];
			if(key != 255)
			{
				rent = HouseInfo[key][hRent];
				
				if(PlayerInfo[i][pId] != HouseInfo[key][hOwner] && rent > GetPlayerMoneyEx(i))
				{
					PlayerInfo[i][pPhousekey] = 255;
					SendClientMessage(i, COLOR_WHITE, "Zosta³eœ wyeksmitowany.");
					rent = 0;
				}
				HouseInfo[key][hTakings] = HouseInfo[key][hTakings]+rent;
			}
			else if(PlayerInfo[i][pHotelId] != 0)
			{
				new businessindex = GetBusinessById(PlayerInfo[i][pHotelId]);
			
				rent = BizzInfo[businessindex][bPriceProd];
				BizzInfo[businessindex][bTill] += rent;
			}
				
			//new tmpintrate = 1;
			
			if(PlayerInfo[i][pPayDay] >= 5)
			{
				new checks = PlayerInfo[i][pPayCheck];
			
				switch(PlayerInfo[i][pJob])
				{
					case 1:   { checks += 200; } // detektyw
					case 2:   { checks += 200; } // prawnik
					case 3:   { checks += 100; } // prostytutka
					case 4:   { checks += 100; } // diler narkotykow
					case 5:   { checks += 100; } // z³odziej aut
					case 7:   { checks += 200; } // mechanik
					case 8:   { checks += 200; } // ochroniarz
					case 9:   { checks += 100; } // diler broni
					case 10:  { checks += 100; } // diler aut
					case 12:  { checks += 200; } // boxer
					case 15:  { checks += 200; } // gazeciarz
					case 16:  { checks += 100; } // kieszonkowiec
					case 17:  { checks += 200; } // rozwoziciel pizzy
					default:  { checks += 200; }
				}

				
				Tax += floatround(PlayerInfo[i][pAccount] * TaxValue);//obliczamy procent
				PlayerInfo[i][pAccount] -= floatround(PlayerInfo[i][pAccount] * TaxValue);
				
				#if LEVEL_MODE
				new ebill = (PlayerInfo[i][pAccount]/10000)*(PlayerInfo[i][pLevel]);
				#else
				new ebill = (PlayerInfo[i][pAccount]/10000);				
				#endif
				
				new sum = (checks - rent);
				if (sum <0 ) sum = 0;

				PlayerInfo[i][pPayment] += sum;
				if(PlayerInfo[i][pAccount] > 0)
				{
					PlayerInfo[i][pAccount] -= ebill;
					//SBizzInfo[4][sbTill] += ebill;
				}
				else
				{
					ebill = 0;
				}
				
				new Float:tmpintrate;
				
				if(PlayerInfo[i][pAccount] > 1000000)
				{
					interest = floatround(PlayerInfo[i][pAccount] * 0.0001);
					tmpintrate = 0.0001;
				}
				else if(PlayerInfo[i][pAccount] > 0)
				{
					interest = floatround(PlayerInfo[i][pAccount] * 0.001);
					tmpintrate = 0.001;
				}
				else
				{
					interest = 0;
					tmpintrate = 0.001;
				}
				
				PlayerPlayMusic(i);
				PlayerInfo[i][pAccount] = account+interest;
				SendClientMessage(i, COLOR_WHITE, "|___ BANK ___|");
				format(string, sizeof(string), "  Wyp³ata: $%d   Podatek: -$%d", checks, floatround(PlayerInfo[i][pAccount] * TaxValue));
				SendClientMessage(i, COLOR_GRAD1, string);
				if(PlayerInfo[i][pPhousekey] != 255 || PlayerInfo[i][pBusiness] != 255)
				{
					format(string, sizeof(string), "  Rachunek za pr¹d: -$%d", ebill);
					SendClientMessage(i, COLOR_GRAD1, string);
				}
				format(string, sizeof(string), "  Bilans: $%d", account);
				SendClientMessage(i, COLOR_GRAD1, string);
				format(string, sizeof(string), "  Oprocentowanie: %0.3f", tmpintrate);
				SendClientMessage(i, COLOR_GRAD2, string);
				format(string, sizeof(string), "  Uzyskany Procent $%d", interest);
				SendClientMessage(i, COLOR_GRAD3, string);
				SendClientMessage(i, COLOR_GRAD4, "|--------------------------------------|");
				format(string, sizeof(string), "  Nowy bilans: $%d", PlayerInfo[i][pAccount]);
				SendClientMessage(i, COLOR_GRAD5, string);
				format(string, sizeof(string), "  Czynsz: -$%d", rent);
				SendClientMessage(i, COLOR_GRAD5, string);
				// wyplata - czynsz
				format(string, sizeof(string), "~b~Wyplata $~w~%d", checks-rent);
				GameTextForPlayer(i, string, 5000, 1);
	 
				rent = 0;
				PlayerInfo[i][pPayDay] = 0;
				PlayerInfo[i][pPayCheck] = 0;
				PlayerInfo[i][pConnectTime] += 1;
			}
			else
			{
				SendClientMessage(i, COLOR_LIGHTRED, "* Nie grasz wystarczaj¹co d³ugo, aby dostaæ wyp³atê.");
			}
		}
	}
	//Checkprop();
	SaveStuff();
	return 1;
}

strtok(const string[], &index)
{
	new length = strlen(string);
	while ((index < length) && (string[index] <= ' '))
	{
		index++;
	}

	new offset = index;
	new result[20];
	while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}

public split(const strsrc[], strdest[][], delimiter)
{
	new i, li;
	new aNum;
	new len;
	while(i <= strlen(strsrc)){
	    if(strsrc[i]==delimiter || i==strlen(strsrc)){
	        len = strmid(strdest[aNum], strsrc, li, i, 128);
	        strdest[aNum][len] = 0;
	        li = i+1;
	        aNum++;
		}
		i++;
	}
	return 1;
}

public OnPlayerSave(playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(gPlayerLogged[playerid])
		{
		 // save pos
		 //if(PlayerInfo[playerid][pWounded] == 0 || (PlayerInfo[playerid][pLocalType]==CONTENT_TYPE_HOUSE))
		 {
		  new Float:saveX, Float:saveY, Float:saveZ;
		  GetPlayerPos(playerid, saveX, saveY, saveZ);
		  PlayerInfo[playerid][pPos_x] = saveX;
		 	PlayerInfo[playerid][pPos_y] = saveY;
		 	PlayerInfo[playerid][pPos_z] = saveZ;
		 	PlayerInfo[playerid][pPos_VW] =	GetPlayerVirtualWorld(playerid);
		 	PlayerInfo[playerid][pInt] = GetPlayerInterior(playerid);
		 	// end
	 	}
	 	
			PlayerInfo[playerid][pChangeSpawn] = SpawnChange[playerid];
			SavePlayerWeapons(playerid);
 	
 	 new query[512];
 	
  	/*format(query, sizeof(query), "UPDATE `auth_user` SET `admin` = %d WHERE `id` = %d",
    PlayerInfo[playerid][pLevel],
    PlayerInfo[playerid][pAdmin],
    PlayerInfo[playerid][pId]
   );

  	mysql_query(query);*/
  		
		 // pobieramy statystyki konta (kasa, œmierci, itp)
 	 format(query, sizeof(query), "UPDATE `auth_game_user_stats` SET `connect_time` = %d, `money` = %d, `bank` = %d, `payment` = %d, `crimes` = %d, `kills` = %d, `deaths` = %d, `arrested` = %d, `wanted_deaths` = %d, `biggest_fish` = %d, `wins` = %d, `loses` = %d WHERE `user_id` = %d",
 	  PlayerInfo[playerid][pConnectTime],
    PlayerInfo[playerid][pCash],
    PlayerInfo[playerid][pAccount],
    PlayerInfo[playerid][pPayment],
    PlayerInfo[playerid][pCrimes],
    PlayerInfo[playerid][pKills],
    PlayerInfo[playerid][pDeaths],
    PlayerInfo[playerid][pArrested],
    PlayerInfo[playerid][pWantedDeaths],
    PlayerInfo[playerid][pBiggestFish],
    PlayerInfo[playerid][pWins],
    PlayerInfo[playerid][pLoses],
    PlayerInfo[playerid][pId]
   );
	  mysql_query(query);

  	format(query, sizeof(query), "UPDATE `auth_game_user_data` SET `ck` = %d, `donate_rank` = %d, `muted` = %d, `sex` = %d, `health` = %f, `leader_id` = %d, `member_id` = %d, `ufmember_id` = %d, `rank` = %d, `char` = %d, `model` = %d, `job_id` = %d, `contract_time` = %d, `house_id` = %d, `business_id` = %d, `hotel_id` = %d, `change_spawn` = %d, `pay_check` = %d, `head_value` = %d,`jailed` = %d, `jail_time` = %d, wounded = %d, `admin` = %d, `iphone` = %d, `sound` = %d WHERE `user_id` = %d",
  	 PlayerInfo[playerid][pCK],
		 PlayerInfo[playerid][pJailCell],
    PlayerInfo[playerid][pMuted],
    PlayerInfo[playerid][pSex],
    PlayerInfo[playerid][pHealth],
    PlayerInfo[playerid][pLeader],
    PlayerInfo[playerid][pMember],
    PlayerInfo[playerid][pUFMember],
    PlayerInfo[playerid][pRank],
    PlayerInfo[playerid][pChar],
    PlayerInfo[playerid][pModel],
    PlayerInfo[playerid][pJob],
    PlayerInfo[playerid][pContractTime],
    PlayerInfo[playerid][pPhousekey],
    PlayerInfo[playerid][pBusiness] == INVALID_BUSINESS_ID ? 0 : PlayerInfo[playerid][pBusiness],
    PlayerInfo[playerid][pHotelId],
    PlayerInfo[playerid][pChangeSpawn],
    PlayerInfo[playerid][pPayCheck],
    PlayerInfo[playerid][pHeadValue],
    PlayerInfo[playerid][pJailed],
    PlayerInfo[playerid][pJailTime],
    PlayerInfo[playerid][pWounded],
    PlayerInfo[playerid][pAdmin],
    PlayerInfo[playerid][pTextureIphone],
    PlayerInfo[playerid][pSoundid],
    PlayerInfo[playerid][pId]
   );

  	mysql_query(query);

   format(query, sizeof(query), "UPDATE `auth_game_user_data` SET `pay_day` = %d, `pay_day_had` = %d, `married` = %d, `married_to` = '%s', `thief_interval` = %d, `pizza_timer` = %d, `warnings` = %d, `last_ip` = '%s', `was_crash` = %d, `blocked` = %d, `talk_style` = %d, `radiochannel` = %d, `drunk_time` = %d WHERE `user_id` = %d",
    PlayerInfo[playerid][pPayDay],
    PlayerInfo[playerid][pPayDayHad],
    PlayerInfo[playerid][pMarried],
    PlayerInfo[playerid][pMarriedTo],
    PlayerInfo[playerid][pThiefInterval],
    PlayerInfo[playerid][pPizzaTimer],
    PlayerInfo[playerid][pWarns],
    PlayerInfo[playerid][pLastIP],
    PlayerInfo[playerid][pWasCrash],
    PlayerInfo[playerid][pLevel],
    PlayerInfo[playerid][pTalkStyle],
    PlayerInfo[playerid][pRadioChannel],
		PlayerInfo[playerid][pDrunkTime],
    PlayerInfo[playerid][pId]
   );
  	mysql_query(query);

   // licencje
  	format(query, sizeof(query), "UPDATE `auth_game_user_licences` SET `car` = %d, `fly` = %d, `boat` = %d, `fish` = %d, `gun` = %d, `big_fly` = %d WHERE `user_id` = %d",
  	 PlayerInfo[playerid][pCarLic],
    PlayerInfo[playerid][pFlyLic],
    PlayerInfo[playerid][pBoatLic],
    PlayerInfo[playerid][pFishLic],
    PlayerInfo[playerid][pGunLic],
    PlayerInfo[playerid][pBigFlyLic],
    PlayerInfo[playerid][pId]
   );

  	mysql_query(query);

   // by³ crash ?
 	 format(query, sizeof(query), "UPDATE `auth_game_user_crash` SET `pos_x` = %f, `pos_y` = %f, `pos_z` = %f, `pos_a` = %f, `interior` = %d, `virtual_world` = %d, `local_type` = %d, `local` = %d, `duty` = %d, `death_reason` = %d WHERE `user_id` = %d",
 	  PlayerInfo[playerid][pPos_x],
    PlayerInfo[playerid][pPos_y],
    PlayerInfo[playerid][pPos_z],
    PlayerInfo[playerid][pPos_a],
    PlayerInfo[playerid][pInt],
    PlayerInfo[playerid][pPos_VW],
    PlayerInfo[playerid][pLocalType],
    PlayerInfo[playerid][pLocal],
    PlayerInfo[playerid][pDuty],
    deadPosition[playerid][dpDeathReason],
    PlayerInfo[playerid][pId]
   );
 	 mysql_query(query);

   // bronie
  	format(query, sizeof(query), "UPDATE `auth_game_user_items` SET `fishes` = %d, `materials` = %d, `drugs` = %d, `id_card` = %d, `mats_holding` = %d, `has_pass` = %d, `permit` = %d, `reserved_phone` = %d, `atm_card` = %d, `mask` = %d WHERE `user_id` = %d",
	   PlayerInfo[playerid][pFishes],
	   PlayerInfo[playerid][pMats],
	   PlayerInfo[playerid][pDrugs],
	   PlayerInfo[playerid][pIdCard],
	   PlayerInfo[playerid][pMatsHolding],
	   PlayerInfo[playerid][pPass],
	   PlayerInfo[playerid][pPermit],
	   PlayerInfo[playerid][pReservedPhone],
	   PlayerInfo[playerid][pATMCard],
	   PlayerInfo[playerid][pMask],
    PlayerInfo[playerid][pId]
   );

  	mysql_query(query);

   // umiejêtnoœci
  	format(query, sizeof(query), "UPDATE `auth_game_user_skills` SET `det` = %d, `sex` = %d, `box` = %d, `law` = %d, `mech` = %d, `jack` = %d, `car` = %d, `news` = %d, `drugs` = %d, `cook` = %d, `fish` = %d, `thief` = %d, `weapons` = %d, `colt` = %d WHERE `user_id` = %d",
    PlayerInfo[playerid][pDetSkill],
    PlayerInfo[playerid][pSexSkill],
    PlayerInfo[playerid][pBoxSkill],
    PlayerInfo[playerid][pLawSkill],
    PlayerInfo[playerid][pMechSkill],
    PlayerInfo[playerid][pJackSkill],
    PlayerInfo[playerid][pCarSkill],
    PlayerInfo[playerid][pNewsSkill],
    PlayerInfo[playerid][pDrugsSkill],
    PlayerInfo[playerid][pCookSkill],
    PlayerInfo[playerid][pFishSkill],
    PlayerInfo[playerid][pThiefSkill],
    PlayerInfo[playerid][pWeaponsSkill],
    PlayerInfo[playerid][pColtSkill],
    PlayerInfo[playerid][pId]
   );
  	mysql_query(query);
		}
	}
	return 1;
}

public OnPlayerLogin(playerid,password[])
{
 new playername2[MAX_PLAYER_NAME], playername[MAX_PLAYER_NAME];
 new escpassword[32];
 new query[368];
 new string2[128];
 new data[40][11];
 new line[512];
 new salt[12];

 GetPlayerName(playerid, playername2, sizeof(playername2));
	GetPlayerName(playerid, playername, sizeof(playername));

 format(query, sizeof(query), "SELECT `password` FROM `auth_user` WHERE `username`='%s' LIMIT 1", playername2);

	mysql_query(query);
 mysql_store_result();

 if (mysql_num_rows() > 0)
	{
	 mysql_fetch_row_format(line);

  split(line, data, '$');
  strmid(salt, data[1], 0, strlen(data[1]), 255); // salt dla has³a

  mysql_free_result();
 }
 else
 {
  mysql_free_result();

  return 1;
 }

 // najpierw sprawdzamy has³o i konto, pobieramy ID i jeœli pasuje to jedziemy ze statystykami
 mysql_real_escape_string(password, escpassword);

	format(query, sizeof(query), "SELECT `id`, `is_active` FROM `auth_user` WHERE `username`='%s' AND `password` = concat('sha1$%s$', SHA1('%s%s'))", playername2, salt, salt, escpassword);

	mysql_query(query);
 mysql_store_result();

 // mamy konto!
	if (mysql_num_rows() > 0)
	{
	 SafeTime[playerid] = -1;
	
	 mysql_fetch_row_format(line);
	
	 // rozbijamy string do tymczasowej tablicy
	 split(line, data, '|');
	
	 // zapisujemy dane do wlasciwej tablicy
	 PlayerInfo[playerid][pId]            = strval(data[0]);
	 PlayerInfo[playerid][pActivated]     = strval(data[1]);
  //PlayerInfo[playerid][pLevel]         = strval(data[1]);
	 //PlayerInfo[playerid][pAdmin]         = strval(data[2]);

  // mamy podstawowe dane, zwalniamy pamiêæ, pobieramy statystyki - JAZDAAAAA!
	 mysql_free_result();
	}
	// has³o jest nieprawid³owe ... ;(
	else
	{
	 mysql_free_result();
	
	 //SendClientMessage(playerid, COLOR_WHITE, "SERWER: Podane has³o jest nieprawid³owe.");

	 gPlayerLogTries[playerid] += 1;

	 // do 3 razy sztuka, co nie?
  if(gPlayerLogTries[playerid] == 3)
  {
	 ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, " ", "Niestety. I tym razem Ci siê nie uda³o. Zostajesz roz³¹czony z serwerem.", "OK", "");
   Kick(playerid);
  }
	else
	{
		new triesleft = 3 - gPlayerLogTries[playerid];
		if(triesleft == 1)
		{
		 format(string2, sizeof(string2), "Podane has³o jest nieprawid³owe. To Twoja ostatnia szansa.");
		}
		else
		{
		 format(string2, sizeof(string2), "Podane has³o jest nieprawid³owe. Pozosta³y Ci %d próby.", triesleft);
		}

		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Logowanie", string2, "Zaloguj siê", "WyjdŸ");
	}

	 return 1;
	}
	
	if(PlayerInfo[playerid][pActivated] != 1)
	{
	 SendClientMessage(playerid,COLOR_YELLOW,"Twoje konto nie zosta³o aktywowane!");
	 SendClientMessage(playerid,COLOR_YELLOW,"Aby je aktywowaæ kliknij w link aktywacyjny, który zosta³ wys³any na adres podany przy rejestracji konta.");
	 Kick(playerid);
	
	 return 1;
	}
	
	format(query, sizeof(query), "SELECT `born` FROM `auth_biography` WHERE `user_id` = %d AND `state` = 2", PlayerInfo[playerid][pId]);
	mysql_query(query);
 mysql_store_result();
	
	if (mysql_num_rows() == 0)
	{
	 SendClientMessage(playerid, COLOR_WHITE, "SERWER: Nie posiadasz zatwierdzonej biografii. Biografiê mo¿esz przes³aæ z poziomu kokpitu.");
	 mysql_free_result();
	 Kick(playerid);
	 return 1;
	}
	else
	{
	 mysql_fetch_row_format(line);
	
	 split(line, data, '|');
	
	 // wiek z biografii
	 new year, month, day;
 	getdate(year, month, day);
 	
 	PlayerInfo[playerid][pAge] = year - strval(data[0]);
	
	 mysql_free_result();
	}
	print("przed podst. statami");
	// pobieramy statystyki konta (kasa, œmierci, itp)
	format(query, sizeof(query), "SELECT `connect_time`, `money`, `bank`, `payment`, `crimes`, `kills`, `deaths`, `arrested`, `wanted_deaths`, `biggest_fish`, `wins`, `loses` FROM `auth_game_user_stats` WHERE `user_id` = %d", PlayerInfo[playerid][pId]);
	mysql_query(query);
 mysql_store_result();
 //new data2[13][11];

	if (mysql_num_rows() > 0)
	{
	 mysql_fetch_row_format(line);
	
	 // rozbijamy string do tymczasowej tablicy
	 split(line, data, '|');
	
	 // zapisujemy
	 PlayerInfo[playerid][pConnectTime]   = strval(data[0]);  // iloœæ przegranych godzin
	 PlayerInfo[playerid][pCash]          = strval(data[1]);  // pieni¹dze przy sobie
	 PlayerInfo[playerid][pAccount]       = strval(data[2]);  // pieni¹dze na koncie
	 PlayerInfo[playerid][pPayment]       = strval(data[3]);  // wyp³ata w banku
	 PlayerInfo[playerid][pCrimes]        = strval(data[4]);  // przestêpstwa
	 PlayerInfo[playerid][pKills]         = strval(data[5]);  // morderstwa
	 PlayerInfo[playerid][pDeaths]        = strval(data[6]);  // zgony
	 PlayerInfo[playerid][pArrested]      = strval(data[7]);  // aresztowañ
	 PlayerInfo[playerid][pWantedDeaths]  = strval(data[8]);  // œmierci z poziomem poszukwania
	 PlayerInfo[playerid][pBiggestFish]   = strval(data[9]); // najwiêksza z³owiona ryba
	 PlayerInfo[playerid][pWins]          = strval(data[10]); // wygranych na ringu
	 PlayerInfo[playerid][pLoses]         = strval(data[11]); // przegranych na ringu

	 mysql_free_result();
 }
 else
 {
  SendClientMessage(playerid, COLOR_WHITE, "SERWER: Twoje konto jest uszkodzone, aby wyjaœniæ sprawê, zg³oœ siê do administracji serwera.");
  return 1;
 }
	print("po podst. statami");
	// pobieramy dane konta
	// nie wypisuje pól, bo i tak pewnie przekrocze d³ugoœæ lini pawn..
	// zapisze sobie je tutaj, ¿eby wiedzieæ co i jak:
	
	// `id_user`, `ck`, `muted`, `donate_rank`, `sex`, `age`, `leader`, `member`, `ufmember`, `rank`, `team`, `char`, `model`,
 // `job`, `contract_time`, `house`, `business`, `hotel_room`, `change_spawn`, `pay_check`, `head_value`, `jailed`, `jail_time`,
 // `phone_number`, `car_time`, `pay_day`, `pay_day_had`, `married`, `married_to`, `punkty_karne`, `thief_interval`, `pizza_timer`,
 // `warnings`, `activation_key`, `activated`, `last_ip`

 // pamiêtaj baloniku zeby aktualizowaæ t¹ listê dla zgodnoœci i zmniejszenia iloœci problemów z tym
print("przed podst. frakcjami");
	format(query, sizeof(query), "SELECT `user_id`, `ck`, `muted`, `donate_rank`, `sex`, `health`, `leader_id`, `member_id`, `ufmember_id`, `rank`, `team`, `char`, `model`, `job_id`, `contract_time`, `house_id`, `business_id`, `hotel_id`, `change_spawn`, `admin`, `iphone`, `sound` FROM `auth_game_user_data` WHERE `user_id` = %d", PlayerInfo[playerid][pId]);
	mysql_query(query);
 mysql_store_result();

 //new data3[37][11];

	if (mysql_num_rows() > 0)
	{
	 mysql_fetch_row_format(line);
	
	 // rozbijamy string do tymczasowej tablicy
	 split(line, data, '|');
	
	 // zapisujemy
	 PlayerInfo[playerid][pCK]             = strval(data[1]);  // character kill
	 PlayerInfo[playerid][pMuted]          = strval(data[2]);  // wyciszony?
	 PlayerInfo[playerid][pJailCell]       = strval(data[3]);  // premium account
	 PlayerInfo[playerid][pSex]            = strval(data[4]);  // p³eæ
	 PlayerInfo[playerid][pHealth]         = floatstr(data[5]);  // ¿ycie
	 PlayerInfo[playerid][pLeader]         = strval(data[6]);  // lider
	 PlayerInfo[playerid][pMember]         = strval(data[7]);  // cz³onek
	 PlayerInfo[playerid][pUFMember]       = strval(data[8]) == 0 ? MAX_UNOFFICIAL_FACTIONS+1 : strval(data[8]);  // cz³onek minifrakcji
	 PlayerInfo[playerid][pRank]           = strval(data[9]);  // ranga
	 PlayerInfo[playerid][pChar]           = strval(data[11]); // skin - nadrzêdny
	 PlayerInfo[playerid][pModel]          = strval(data[12]); // skin - podstawowy
	 PlayerInfo[playerid][pJob]            = strval(data[13]); // praca
 	PlayerInfo[playerid][pContractTime]   = strval(data[14]); // d³ugoœæ kontraktu
 	PlayerInfo[playerid][pPhousekey]      = strval(data[15]); // klucz do domu
 	PlayerInfo[playerid][pBusiness]       = strval(data[16]) == 0 ? INVALID_BUSINESS_ID : strval(data[16]); // klucz do biznesu
 	PlayerInfo[playerid][pHotelId]        = strval(data[17]); // pokój w hotelu
 	PlayerInfo[playerid][pChangeSpawn]    = strval(data[18]); // zmiana spawnu?
 	PlayerInfo[playerid][pAdmin]          = strval(data[19]); // admin
 	PlayerInfo[playerid][pTextureIphone]  = strval(data[20]); // Textura Iphona
 	PlayerInfo[playerid][pSoundid]        = strval(data[21]); //DŸwiêk telefonu
	
	 mysql_free_result();
 }
 else
 {
  SendClientMessage(playerid, COLOR_WHITE, "SERWER: Twoje konto jest uszkodzone, aby wyjaœniæ sprawê, zg³oœ siê do administracji serwera.");
  return 1;
 }
 print("po podst. frakcjach");
 
  format(query, sizeof(query), "SELECT `description` FROM `auth_game_user_data` WHERE `user_id` = 1");
	mysql_query(query);
  mysql_store_result();
	
	if (mysql_num_rows() > 0)
	{
	  mysql_fetch_row(PlayerInfo[playerid][pDescription]);
		mysql_free_result();
	}

format(query, sizeof(query), "SELECT `user_id`, `pay_check`, `head_value`, `jailed`, `jail_time`, `drunk_time`, `pay_day`, `pay_day_had`, `married`, `married_to`, `permissions`, `thief_interval`, `pizza_timer`, `warnings`, `activation_key`, `last_ip`, `was_crash`, `wounded`, `blocked`, `talk_style`, `radiochannel` FROM `auth_game_user_data` WHERE `user_id` = %d", PlayerInfo[playerid][pId]);
	mysql_query(query);
 mysql_store_result();

 //new data3[37][11];

	if (mysql_num_rows() > 0)
	{
	 mysql_fetch_row_format(line);
	
	 // rozbijamy string do tymczasowej tablicy
	 split(line, data, '|');

  PlayerInfo[playerid][pPayCheck]       = strval(data[1]); // ekstra pieni¹dze do wyp³aty
 	PlayerInfo[playerid][pHeadValue]      = strval(data[2]); // pieni¹dze za g³owê (hitmani)
 	PlayerInfo[playerid][pJailed]         = strval(data[3]); // wiêzienie
 	PlayerInfo[playerid][pJailTime]       = strval(data[4]); // czas w wiêzieniu
	PlayerInfo[playerid][pDrunkTime]			= strval(data[5]); // drunk time
 	PlayerInfo[playerid][pPayDay]         = strval(data[6]); // wyp³ata
 	PlayerInfo[playerid][pPayDayHad]      = strval(data[7]); // wyp³ata
 	PlayerInfo[playerid][pMarried]        = strval(data[8]); // ma³¿eñstwo
 	strmid(PlayerInfo[playerid][pMarriedTo], data[9], 0, strlen(data[9]), 255);  // ma³¿eñstwo - z kim
 	PlayerInfo[playerid][pPermissions]    = strval(data[10]); // interwa³ dla z³odzieja
 	PlayerInfo[playerid][pThiefInterval]  = strval(data[11]); // interwa³ dla z³odzieja
 	PlayerInfo[playerid][pPizzaTimer]     = strval(data[12]); // interwa³ dla pizza boy'a
 	PlayerInfo[playerid][pWarns]          = strval(data[13]); // ostrze¿enia
 	strmid(PlayerInfo[playerid][pLastIP], data[15], 0, strlen(data[15]), 255);     // ostatni adres IP
 	PlayerInfo[playerid][pWasCrash]       = strval(data[16]); // by³ crash?
 	PlayerInfo[playerid][pWounded]        = strval(data[17]); // brutalnie pobity
  PlayerInfo[playerid][pLevel]          = strval(data[18]); // blokada
  PlayerInfo[playerid][pTalkStyle]      = strval(data[19]); // blokada
  PlayerInfo[playerid][pRadioChannel]   = strval(data[20]); // blokada

  mysql_free_result();
 }
 else
 {
  SendClientMessage(playerid, COLOR_WHITE, "SERWER: Twoje konto jest uszkodzone, aby wyjaœniæ sprawê, zg³oœ siê do administracji serwera.");
  return 1;
 }

 // licencje
	format(query, sizeof(query), "SELECT `car`, `fly`, `boat`, `fish`, `gun`, `big_fly` FROM `auth_game_user_licences` WHERE `user_id` = %d", PlayerInfo[playerid][pId]);
	mysql_query(query);
 mysql_store_result();

 //new data4[6][11];

	if (mysql_num_rows() > 0)
	{
	 mysql_fetch_row_format(line);
	
	 // rozbijamy string do tymczasowej tablicy
	 split(line, data, '|');
	
	 // zapisujemy
	 PlayerInfo[playerid][pCarLic]        = strval(data[0]);  // prawo jazdy
	 PlayerInfo[playerid][pFlyLic]        = strval(data[1]);  // licencja na latanie
	 PlayerInfo[playerid][pBoatLic]       = strval(data[2]);  // licencja na p³ywanie ³odziami
	 PlayerInfo[playerid][pFishLic]       = strval(data[3]);  // licencja na ³owienie
	 PlayerInfo[playerid][pGunLic]        = strval(data[4]);  // licencja na broñ
	 PlayerInfo[playerid][pBigFlyLic]     = strval(data[5]);  // licencja na du¿e samoloty
 	
	 mysql_free_result();
 }
 else
 {
  SendClientMessage(playerid, COLOR_WHITE, "SERWER: Twoje konto jest uszkodzone, aby wyjaœniæ sprawê, zg³oœ siê do administracji serwera.");
  return 1;
 }

 // by³ crash ?
 //if(PlayerInfo[playerid][pWasCrash] == 1 || PlayerInfo[playerid][pWounded] > 0)
 {
	 format(query, sizeof(query), "SELECT `pos_x`, `pos_y`, `pos_z`, `pos_a`, `interior`, `virtual_world`, `local_type`, `local`, `duty`, `death_reason` FROM `auth_game_user_crash` WHERE `user_id` = %d", PlayerInfo[playerid][pId]);
	 mysql_query(query);
  mysql_store_result();

  //new data6[7][11];

 	if (mysql_num_rows() > 0)
 	{
 	 mysql_fetch_row_format(line);
 	
 	 // rozbijamy string do tymczasowej tablicy
 	 split(line, data, '|');
	 
	 new loctype = strval(data[6]);
 	
 	 if(PlayerInfo[playerid][pWasCrash] == 1)
 	 {
 	  // zapisujemy
 	  PlayerInfo[playerid][pPos_x]           = floatstr(data[0]);
 	  PlayerInfo[playerid][pPos_y]           = floatstr(data[1]);
 	  PlayerInfo[playerid][pPos_z]           = floatstr(data[2]);
    PlayerInfo[playerid][pInt]             = strval(data[4]);
    PlayerInfo[playerid][pPos_VW]          = strval(data[5]);
    PlayerInfo[playerid][pLocalType]       = strval(data[6]);
    PlayerInfo[playerid][pLocal]           = strval(data[7]);
    PlayerInfo[playerid][pDuty]            = strval(data[8]);
    
   }
	 else if (loctype == CONTENT_TYPE_HOUSE)
 	 {
 	  // zapisujemy
 	  PlayerInfo[playerid][pPos_x]           = floatstr(data[0]);
 	  PlayerInfo[playerid][pPos_y]           = floatstr(data[1]);
 	  PlayerInfo[playerid][pPos_z]           = floatstr(data[2]);
    PlayerInfo[playerid][pInt]             = strval(data[4]);
    PlayerInfo[playerid][pPos_VW]          = strval(data[5]);
    PlayerInfo[playerid][pLocalType]       = strval(data[6]);
    PlayerInfo[playerid][pLocal]           = strval(data[7]);
    PlayerInfo[playerid][pDuty]            = strval(data[8]);
   }
   else if (PlayerInfo[playerid][pWounded] > 0)
   {
    PlayerInfo[playerid][pPos_x]           = floatstr(data[0]);
 	  PlayerInfo[playerid][pPos_y]           = floatstr(data[1]);
 	  PlayerInfo[playerid][pPos_z]           = floatstr(data[2]);
    PlayerInfo[playerid][pInt]             = strval(data[4]);
    PlayerInfo[playerid][pPos_VW]          = strval(data[5]);
    PlayerInfo[playerid][pLocalType]            = strval(data[6]);
    PlayerInfo[playerid][pLocal]           = strval(data[7]);

    deadPosition[playerid][dpX]            = floatstr(data[0]);
    deadPosition[playerid][dpY]            = floatstr(data[1]);
    deadPosition[playerid][dpZ]            = floatstr(data[2]);
	   deadPosition[playerid][dpA]            = floatstr(data[3]);
	
    deadPosition[playerid][dpInt]          = strval(data[4]);
    deadPosition[playerid][dpDeathReason]  = strval(data[5]);

	   deadPosition[playerid][dpDeath]        = 2;
   }

   mysql_free_result();
	 }
  else
  {
   SendClientMessage(playerid, COLOR_WHITE, "SERWER: Twoje konto jest uszkodzone, aby wyjaœniæ sprawê, zg³oœ siê do administracji serwera.");
   return 1;
  }
 }

 // bronie
	format(query, sizeof(query), "SELECT `lotto_number`, `fishes`, `materials`, `drugs`, `cd_player`, `fuel`, `pocket_clock`, `id_card`, `mats_holding`, `has_pass`, `permit`, `reserved_phone`, `atm_card`, `mask`, `drink`, `dice` FROM `auth_game_user_items` WHERE `user_id` = %d", PlayerInfo[playerid][pId]);
	mysql_query(query);
 mysql_store_result();

 //new data7[16][11];

	if (mysql_num_rows() > 0)
	{
	 mysql_fetch_row_format(line);
	
	 // rozbijamy string do tymczasowej tablicy
	 split(line, data, '|');
	
	 // zapisujemy
	 PlayerInfo[playerid][pFishes]           = strval(data[1]);
	 PlayerInfo[playerid][pMats]             = strval(data[2]);
	 PlayerInfo[playerid][pDrugs]            = strval(data[3]);
	 PlayerInfo[playerid][pIdCard]           = strval(data[7]);
	 PlayerInfo[playerid][pMatsHolding]      = strval(data[8]);
	 PlayerInfo[playerid][pPass]             = strval(data[9]);
	 PlayerInfo[playerid][pPermit]           = strval(data[10]);
	 PlayerInfo[playerid][pReservedPhone]    = strval(data[11]);
	 PlayerInfo[playerid][pATMCard]          = strval(data[12]);
	 PlayerInfo[playerid][pMask]             = strval(data[13]);
 	
 	mysql_free_result();
 }
 else
 {
  SendClientMessage(playerid, COLOR_WHITE, "SERWER: Twoje konto jest uszkodzone, aby wyjaœniæ sprawê, zg³oœ siê do administracji serwera.");
  return 1;
 }

 // umiejêtnoœci
	format(query, sizeof(query), "SELECT `det`, `sex`, `box`, `law`, `mech`, `jack`, `car`, `news`, `drugs`, `cook`, `fish`, `thief`, `weapons`, `colt` FROM `auth_game_user_skills` WHERE `user_id` = %d", PlayerInfo[playerid][pId]);
	mysql_query(query);
 mysql_store_result();

 //new data8[13][3];

	if (mysql_num_rows() > 0)
	{
	 mysql_fetch_row_format(line);
	
	 // rozbijamy string do tymczasowej tablicy
	 split(line, data, '|');
	
	 // zapisujemy
	 PlayerInfo[playerid][pDetSkill]        = strval(data[0]);
	 PlayerInfo[playerid][pSexSkill]        = strval(data[1]);
	 PlayerInfo[playerid][pBoxSkill]        = strval(data[2]);
	 PlayerInfo[playerid][pLawSkill]        = strval(data[3]);
	 PlayerInfo[playerid][pMechSkill]       = strval(data[4]);
	 PlayerInfo[playerid][pJackSkill]       = strval(data[5]);
	 PlayerInfo[playerid][pCarSkill]        = strval(data[6]);
	 PlayerInfo[playerid][pNewsSkill]       = strval(data[7]);
	 PlayerInfo[playerid][pDrugsSkill]      = strval(data[8]);
	 PlayerInfo[playerid][pCookSkill]       = strval(data[9]);
	 PlayerInfo[playerid][pFishSkill]       = strval(data[10]);
	 PlayerInfo[playerid][pThiefSkill]      = strval(data[11]);
	 PlayerInfo[playerid][pWeaponsSkill]    = strval(data[12]);
     PlayerInfo[playerid][pColtSkill]       = strval(data[13]);
 	mysql_free_result();
 }
 else
 {
  SendClientMessage(playerid, COLOR_WHITE, "SERWER: Twoje konto jest uszkodzone, aby wyjaœniæ sprawê, zg³oœ siê do administracji serwera.");
  return 1;
 }

 // profil
	format(query, sizeof(query), "SELECT (`premium_expire` > NOW()), `helped` FROM `auth_userprofile` WHERE `user_id` = %d", PlayerInfo[playerid][pId]);
	mysql_query(query);
 mysql_store_result();

	if (mysql_num_rows() > 0)
	{
	 mysql_fetch_row_format(line);
	
	 // rozbijamy string do tymczasowej tablicy
	 split(line, data, '|');
	
	 // zapisujemy
	 PlayerInfo[playerid][pPremium]         = strval(data[0]);
 	
 	mysql_free_result();
 }
 else
 {
  SendClientMessage(playerid, COLOR_WHITE, "SERWER: Twoje konto jest uszkodzone, aby wyjaœniæ sprawê, zg³oœ siê do administracji serwera.");
  return 1;
 }

		ResetPlayerMoney(playerid);
		
		GivePlayerMoney(playerid,PlayerInfo[playerid][pCash]);
		CurrentMoney[playerid] = PlayerInfo[playerid][pCash];
		
		#if TIKI_EVENT
		TextDrawShowForPlayer(playerid, tikiTextDraw);
		#endif
		
		// clear console
		ClearConsole(playerid);
		
		// konto zablokowane
		if(PlayerInfo[playerid][pLevel] == 1)
		{
			Kick(playerid);
		}
		else if(PlayerInfo[playerid][pCK] > 0)
		{
		 SendClientMessage(playerid,COLOR_LIGHTRED,"Twoja postaæ nie ¿yje! Najprawopodobniej zosta³eœ zamordowany!");
		 Kick(playerid);
		}

		if(PlayerInfo[playerid][pJob] == 5)
		{
		 SendClientMessage(playerid,COLOR_YELLOW,"Straci³eœ pracê Z³odzieja Aut, poniewa¿ jest ona nieaktywna.");
		 PlayerInfo[playerid][pJob] = 0;
		}
		
		if(PlayerInfo[playerid][pJob] == 3)
		{
		 SendClientMessage(playerid,COLOR_YELLOW,"Straci³eœ pracê Prostytutki, poniewa¿ jest ona nieaktywna.");
		 PlayerInfo[playerid][pJob] = 0;
		}
		
		if(PlayerInfo[playerid][pJob] == 10)
		{
		 SendClientMessage(playerid,COLOR_YELLOW,"Straci³eœ pracê Dilera Samochodów, poniewa¿ jest ona nieaktywna.");
		 PlayerInfo[playerid][pJob] = 0;
		}
		
		if(PlayerInfo[playerid][pUFMember] < MAX_UNOFFICIAL_FACTIONS+1 && MiniFaction[PlayerInfo[playerid][pUFMember]][mId] == -1)
		{
		 SendClientMessage(playerid,COLOR_YELLOW,"Nieoficjalna organizacja, której by³eœ cz³onkiem, zosta³a usuniêta.");
		 PlayerInfo[playerid][pUFMember] = MAX_UNOFFICIAL_FACTIONS+1;
		}
		
		if(PlayerInfo[playerid][pDuty] == 1)
		{
		 OnDuty[playerid] = 1;
		 PlayerInfo[playerid][pDuty] = 0;
		}
		
		SetPlayerVirtualWorldEx(playerid, 0);

  // ostatnio zalogowany (czas)
  format(query, sizeof(query), "UPDATE `auth_userprofile` SET `last_login_game` = NOW() WHERE user_id = %d", PlayerInfo[playerid][pId]);
  mysql_query(query);

  // domyœlny pojazd
  SpawnUserDefaultVehicle(playerid);
  LoadObjectItems(CONTENT_TYPE_USER, PlayerInfo[playerid][pId]);

  // zapisujemy IP klienta tu¿ po zalogowaniu
  GetPlayerIp(playerid,PlayerInfo[playerid][pLastIP],25);

  Log_SignIn(playerid);
		
		GetPlayerNameEx(playerid, playername2, sizeof(playername2));
		format(string2, sizeof(string2), "SERWER: Witaj %s.",playername2);
		SendClientMessage(playerid, COLOR_WHITE,string2);
		printf("%s zosta³ zalogowany.",playername2);
		
		if (PlayerInfo[playerid][pPremium] > 0)
		{
			SendClientMessage(playerid, COLOR_WHITE,"SERWER: Posiadasz Konto Premium.");
		}
		if (PlayerInfo[playerid][pAdmin] > 0)
		{
			format(string2, sizeof(string2), "SERWER: Zosta³eœ zalogowany jako Administrator z poziomem %d.",PlayerInfo[playerid][pAdmin]);
			SendClientMessage(playerid, COLOR_WHITE,string2);
			
			UpdateEverybodiesHud();
		}
		
		gPlayerLogged[playerid] = 1;
		MedicBill[playerid] = 0;

		//DateProp(playerid);
		ClearPMBlocks(playerid);
		
  new tmp2[40];
		format(tmp2, sizeof(tmp2), "~w~Witaj ~n~~y~   %s", playername2);

		SpawnChange[playerid] = PlayerInfo[playerid][pChangeSpawn];
		
  safeTimer[playerid] = SetTimerEx("SetPlayerUnsafe", 7500, 0, "d", playerid); // wylaczenie fixa na szpital

		if(PlayerInfo[playerid][pWasCrash] == 0)
		{
		 GameTextForPlayer(playerid, tmp2, 5000, 1);
	 }

  MySQLSetPlayerLogged(playerid);
  MySQLAssignMiniFaction(playerid);
		
		// motto
  if(PlayerInfo[playerid][pUFLeader] < MAX_UNOFFICIAL_FACTIONS+1 || PlayerInfo[playerid][pUFMember] < MAX_UNOFFICIAL_FACTIONS+1)
		{
		 new ufid2 = PlayerInfo[playerid][pUFMember];

   if(PlayerInfo[playerid][pUFLeader] < MAX_UNOFFICIAL_FACTIONS+1)
   {
    ufid2 = PlayerInfo[playerid][pUFLeader];
   }

		 format(motd, sizeof(motd), "Motto organizacji: %s.", MiniFaction[ufid2][mMOTD]);
		 SendClientMessage(playerid, COLOR_YELLOW, motd);
		}
		
		DollahScoreUpdate();
		
		if (!(PlayerInfo[playerid][pHealth]>0.0)) SetPlayerHealthEx(playerid,20.0);
		else SetPlayerHealthEx(playerid, PlayerInfo[playerid][pHealth]);
		
  // spawn
  
		SetPlayerSpawn(playerid, SET_SPAWN_POSITION);
		SpawnPlayer(playerid);
		SetPlayerSpawn(playerid, SET_SPAWN_WHERE_SPAWN);

 #if 0
	}
	#endif
	return 1;
}

/*public OnHouseUpdate(property)
{
	new escdescription[128];
	new query[280];
	
	mysql_real_escape_string(HouseInfo[property][hDiscription], escdescription);
	
	format(query, sizeof(query), "UPDATE auth_game_house SET owner_id = %d, description = '%s', health = %d, armour = %d, interior = %d, `lock` = %d, owned = %d, rent = %d, rentabil = %d, takings = %d, `date` = %d, rubbish = %d, vw = %d WHERE id = %d",
  HouseInfo[property][hOwner],
  escdescription,
	 HouseInfo[property][hHel],
	 HouseInfo[property][hArm],
	 HouseInfo[property][hInt],
	 HouseInfo[property][hLock],
	 HouseInfo[property][hOwned],
	 HouseInfo[property][hRent],
	 HouseInfo[property][hRentabil],
	 HouseInfo[property][hTakings],
	 HouseInfo[property][hDate],
  HouseInfo[property][hRubbish],
  HouseInfo[property][hVW],
  HouseInfo[property][hId]
 );

 mysql_query(query);
}*/

/*forward OnBusinessUpdate(property);
public OnBusinessUpdate(property)
{
 new escmessage[128];
	//new escowner[24];
	new query[1024];
		
	mysql_real_escape_string(BizzInfo[property][bMessage], escmessage);
	//mysql_real_escape_string(BizzInfo[property][bOwner], escowner);
	
	format(query, sizeof(query), "UPDATE auth_game_business SET owned = %d, owner_id = %d, message = '%s', extortion = %d, entrancecost = %d, till = %d, locked = %d, products = %d, maxproducts = %d, priceprod = %d WHERE id = %d",
  BizzInfo[property][bOwned],
	 BizzInfo[property][bOwner],
	 escmessage,
	 BizzInfo[property][bExtortion],
	 BizzInfo[property][bEntranceCost],
	 BizzInfo[property][bTill],
	 BizzInfo[property][bLocked],
	 BizzInfo[property][bProducts],
	 BizzInfo[property][bMaxProducts],
	 BizzInfo[property][bPriceProd],
	 BizzInfo[property][bId]
 );

 mysql_query(query);
}*/

public BroadCast(color,const string[])
{
	SendClientMessageToAll(color, string);
	return 1;
}

public ABroadCast(color,const string[],level)
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if (PlayerInfo[i][pAdmin] >= level)
			{
				SendClientMessage(i, color, string);
				printf("%s", string);
			}
		}
	}
	return 1;
}

public OOCOff(color,const string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			SendClientMessage(i, color, string);
		}
	}
}

public OOCNews(color,const string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			SendClientMessage(i, color, string);
		}
	}
}

public SendRadioMessage(member, color, string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
		 if(PlayerInfo[i][pMember] == member || PlayerInfo[i][pLeader] == member)
		 {
				SendClientMessage(i, color, string);
			}
		}
	}
}

public SendRadioMessageEx(playerid, color, channel, string[])
{
 new stringradio[256], playername[MAX_PLAYER_NAME];
 GetPlayerNameEx(playerid, playername, sizeof(playername));
 format(stringradio, sizeof(stringradio), "%s mówi (radio): %s", playername, string);
 ProxDetector(6.5, playerid, stringradio, COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);

 format(stringradio, sizeof(stringradio), "[K:%d] %s: %s", channel, playername, string);

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
		 new itemindex = GetUsedItemByItemId(i, ITEM_RADIO);
		
		 if(CanItemBeUsed(itemindex) && channel == Items[itemindex][iAttr1] && Items[itemindex][iFlags] & ITEM_FLAG_USING && playerid != i)
		 {
				SendClientMessage(i, color, stringradio);
			}
		}
	}
}

forward SendRadioMessageEx2(playerid, member, color, string[]);
public SendRadioMessageEx2(playerid, member, color, string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i) && GetPlayerOrganization(i) == member)
		{
		 new itemindex = GetUsedItemByItemId(i, ITEM_RADIO);
		
		 if(CanItemBeUsed(itemindex) && Items[itemindex][iFlags] & ITEM_FLAG_USING && playerid != i)
		 {
				SendClientMessage(i, color, string);
			}
		}
	}
}

forward SendRadioMessageDuty(member, color, string[]);
public  SendRadioMessageDuty(member, color, string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
		 if((PlayerInfo[i][pMember] == member || PlayerInfo[i][pLeader] == member) && OnDuty[i] == 1)
		 {
				SendClientMessage(i, color, string);
			}
		}
	}
}


public SendJobMessage(job, color, string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
		 if(PlayerInfo[i][pJob] == job)
		 {
				SendClientMessage(i, color, string);
			}
		}
	}
}

forward SendJobWithDutyMessage(job, color, string[]);
public  SendJobWithDutyMessage(job, color, string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
		 if(PlayerInfo[i][pJob] == job)
		 {
		  if(JobDuty[i] == 1)
		  {
				 SendClientMessage(i, color, string);
			 }
			}
		}
	}
}

public SendNewFamilyMessage(family, color, string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
   if(PlayerInfo[i][pUFMember] == family || PlayerInfo[i][pUFLeader] == family)
	  {
    if(!gFam[i])
    {
					SendClientMessage(i, color, string);
				}
			}
		}
	}
}

public SendFamilyMessage(family, color, string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
		    if(PlayerInfo[i][pMember] == family || PlayerInfo[i][pLeader] == family)
		    {
                if(!gFam[i])
                {
					SendClientMessage(i, color, string);
				}
			}
		}
	}
}

forward SendFamilyMessageEx(playerid, family, color, string[]);
public SendFamilyMessageEx(playerid, family, color, string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
		 if(PlayerInfo[i][pMember] == family || PlayerInfo[i][pLeader] == family)
		 {
    if(!gFam[i])
    {
     if(playerid != i)
     {
					 SendClientMessage(i, color, string);
				 }
				}
			}
		}
	}
}


public SendAdminMessage(color, string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
		    if(PlayerInfo[i][pAdmin] >= 1)
		    {
				SendClientMessage(i, color, string);
			}
		}
	}
}



/*public AddCar(carcoords)
{
	new randcol = random(126);
	new randcol2 = 1;
	if (rccounter == 14)
	{
		rccounter = 0;
	}
	AddStaticVehicleEx(carselect[rccounter], CarSpawns[carcoords][pos_x], CarSpawns[carcoords][pos_y], CarSpawns[carcoords][pos_z], CarSpawns[carcoords][z_angle], randcol, randcol2, 60000);
	rccounter++;
	return 1;
}*/

public PlayerPlayMusic(playerid)
{
	if(IsPlayerConnected(playerid))
	{
		SetTimer("StopMusic", 5000, 0);
		PlayerPlaySound(playerid, 1068, 0.0, 0.0, 0.0);
	}
}

public StopMusic()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			PlayerPlaySound(i, 1069, 0.0, 0.0, 0.0);
		}
	}
}

public PlayerFixRadio(playerid)
{
    if(IsPlayerConnected(playerid))
	{
	    SetTimer("PlayerFixRadio2", 1000, 0);
		PlayerPlaySound(playerid, 1068, 0.0, 0.0, 0.0);
		Fixr[playerid] = 1;
	}
}

public PlayerFixRadio2()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(Fixr[i])
			{
				PlayerPlaySound(i, 1069, 0.0, 0.0, 0.0);
				Fixr[i] = 0;
			}
		}
	}
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	new string[128];
	new playermoney;
	new sendername[MAX_PLAYER_NAME];
	new giveplayer[MAX_PLAYER_NAME];
	new playername[MAX_PLAYER_NAME];
	new cmd[32];
	new tmp[64];
	new giveplayerid, moneys, idx;
	
	cmd = strtok(cmdtext, idx);
	
	if(AFKCheck[playerid] >= 5)
		OnPlayerBackOfAFK(playerid);
	
	AFKCheck[playerid] = 0;

	if (strcmp(cmd, "/login", true) ==0 || strcmp(cmd, "/zaloguj", true) ==0 )
	{
	  if(IsPlayerConnected(playerid))
    {
			new tmppass[64];
			
			if(gPlayerLogged[playerid] == 1)
			{
				SendClientMessage(playerid, COLOR_WHITE, "SERWER: Jesteœ w³aœnie zalogowany.");
				return 1;
			}
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /zaloguj [has³o]");
				return 1;
			}
			strmid(tmppass, tmp, 0, strlen(cmdtext), 255);
			OnPlayerLogin(playerid,tmppass);
		}
		return 1;
	}

	if(!IsPlayerLoggedIn(playerid))
	{
		SendClientMessage(playerid, COLOR_GRAD1, "Nie jesteœ zalogowany.");
		return 1;
	}
	
	GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	printf("[cmd] [%s]: %s", sendername, cmdtext);
 
	switch (cmdtext[1] | 0x20)
	{
		case 0x20: // "/"
		{
		 return 1;
		}
		
		case 'a':
		{
			dcmd(a, 1, cmdtext);
			dcmd(ah, 2, cmdtext);
			dcmd(adminduty, 9, cmdtext);
			dcmd(admins, 6, cmdtext);
			dcmd(ado, 3, cmdtext);
			dcmd(afrisk, 6, cmdtext);
			dcmdalt(admins, 6, cmdtext, admini);
			dcmd(akceptujsmierc, 14, cmdtext);
			dcmd(awyrzuc, 7, cmdtext);
		 
			if(PlayerInfo[playerid][pWounded] > 0) return 1; // poni¿ej komendy, które s¹ niedostêpne podczas BW

			dcmd(asortyment, 10, cmdtext);
			dcmd(apojazd, 7, cmdtext);
			dcmd(adrzwi, 6, cmdtext);
		}
		
		case 'b':
		{
			dcmd(b, 1, cmdtext);
			dcmd(ban, 3, cmdtext);
			dcmd(block, 5, cmdtext);

			if(PlayerInfo[playerid][pWounded] > 0) return 1; // poni¿ej komendy, które s¹ niedostêpne podczas BW
			
			dcmd(blokada, 7, cmdtext);
			dcmd(brama, 5, cmdtext);
		}
		
		case 'c':
		{
			dcmd(check, 5, cmdtext);
			dcmd(clearplayer, 11, cmdtext);
			
			// animacje
			
			//dcmd(crack1, 6, cmdtext);
			//dcmd(crack2, 6, cmdtext);
			dcmd(crack, 5, cmdtext);

			if(PlayerInfo[playerid][pWounded] > 0) return 1; // poni¿ej komendy, które s¹ niedostêpne podczas BW

			dcmd(c, 1, cmdtext);
      dcmdalt(c,1,cmdtext,cicho);
			dcmd(chusta, 6, cmdtext);
		}
		
		case 'd':
		{
			dcmd(do, 2, cmdtext);
			dcmd(dajprawko, 9, cmdtext);
			dcmd(debug, 5, cmdtext);

			if(PlayerInfo[playerid][pWounded] > 0) return 1; // poni¿ej komendy, które s¹ niedostêpne podczas BW

			dcmd(dajbron, 7, cmdtext);
			dcmd(d, 1, cmdtext);
			//dcmd(dajradio, 8, cmdtext);
			dcmd(drzwi, 5, cmdtext);
			dcmd(dk, 2, cmdtext);
		}
		
		case 'e':
		{
			if(PlayerInfo[playerid][pWounded] > 0) return 1; // poni¿ej komendy, które s¹ niedostêpne podczas BW

			dcmd(enter, 5, cmdtext);
			dcmd(exit, 4, cmdtext);
			dcmd(endround, 8, cmdtext);
		}

		case 'f':
		{
			dcmd(freeze, 6, cmdtext);

			if(PlayerInfo[playerid][pWounded] > 0) return 1; // poni¿ej komendy, które s¹ niedostêpne podczas BW
			
			dcmd(frakcja, 7, cmdtext);
      dcmdalt(f,1,cmdtext,family);
			dcmd(f, 1, cmdtext);
			dcmd(fo, 2, cmdtext);
			dcmd(firma, 5, cmdtext);
			dcmd(frisk, 5, cmdtext);
			dcmd(fixveh, 6, cmdtext);
		}
		
		case 'g':
		{
			dcmd(getvw, 5, cmdtext);

			if(PlayerInfo[playerid][pWounded] > 0) return 1; // poni¿ej komendy, które s¹ niedostêpne podczas BW
			
			dcmd(giverank, 8, cmdtext);
			dcmd(goto, 4, cmdtext);
			dcmd(gethere, 7, cmdtext);
			dcmd(gotocar, 7, cmdtext);
			dcmd(gotols, 6, cmdtext);
			dcmd(gotolv, 6, cmdtext);
			dcmd(gotosf, 6, cmdtext);
			dcmd(gotomark, 8, cmdtext);

			#if TIKI_EVENT
			dcmd(glowafaraona, 12, cmdtext);
			#endif
		}
		
		case 'h':
		{
			if(PlayerInfo[playerid][pWounded] > 0) return 1; // poni¿ej komendy, które s¹ niedostêpne podczas BW

			dcmd(help, 4, cmdtext);
		}
		
		case 'i':
		{
			if(PlayerInfo[playerid][pWounded] > 0) return 1; // poni¿ej komendy, które s¹ niedostêpne podczas BW

			dcmd(info, 4, cmdtext);
			dcmd(ignoruj, 7, cmdtext);
			dcmd(invite, 6, cmdtext);
			dcmd(id, 2, cmdtext);
		}
		
		case 'j':
		{
			dcmdalt(me, 2, cmdtext, ja);
			dcmd(jail, 4, cmdtext);

			if(PlayerInfo[playerid][pWounded] > 0) return 1; // poni¿ej komendy, które s¹ niedostêpne podczas BW
		}
		
		case 'k':
		{
			dcmd(kick, 4, cmdtext);
			dcmd(kwarn, 5, cmdtext);

			if(PlayerInfo[playerid][pWounded] > 0) return 1; // poni¿ej komendy, które s¹ niedostêpne podczas BW
			
			dcmd(k, 1, cmdtext);
			dcmd(kup, 3, cmdtext);
			dcmd(kanister, 8, cmdtext);
		}
		
		case 'l':
		{
			if(PlayerInfo[playerid][pWounded] > 0) return 1; // poni¿ej komendy, które s¹ niedostêpne podczas BW

      dcmdalt(l,1,cmdtext,lokalny);
			dcmd(l, 1, cmdtext);
			dcmd(lock, 4, cmdtext);
			dcmd(logout, 6, cmdtext);
			dcmd(logoutpl, 8, cmdtext);
		}
		
		case 'm':
		{
			dcmd(me, 2, cmdtext);
			dcmd(mute, 4, cmdtext);
			dcmd(mark, 4, cmdtext);
			dcmd(makeadmin, 9, cmdtext);

			if(PlayerInfo[playerid][pWounded] > 0) return 1; // poni¿ej komendy, które s¹ niedostêpne podczas BW

			dcmd(materialy, 9, cmdtext);
			dcmd(miejsceodbioru, 14, cmdtext);
			dcmd(maska, 5, cmdtext);
		}
		
		case 'n':
		{
		//	dcmd(npc, 3, cmdtext);
		}
  
		case 'o':
		{
			dcmd(o, 1, cmdtext);
			dcmd(opis, 4, cmdtext);

			if(PlayerInfo[playerid][pWounded] > 0) return 1; // poni¿ej komendy, które s¹ niedostêpne podczas BW

			dcmd(obiekty, 7, cmdtext);
			dcmd(organizacje, 11, cmdtext);
		}
  
		case 'p':
		{
			dcmd(playername, 10, cmdtext);
			dcmd(pay, 3, cmdtext);
			dcmd(przedmioty, 10, cmdtext);
			dcmdalt(przedmioty, 1, cmdtext, p);
			dcmd(pojazdmodel, 11, cmdtext);

			if(PlayerInfo[playerid][pWounded] > 0) return 1; // poni¿ej komendy, które s¹ niedostêpne podczas BW

			dcmd(pojazd, 6, cmdtext);
			dcmd(pokoj, 5, cmdtext);
			dcmd(przypiszbiznes, 14, cmdtext);
			dcmdalt(w, 2, cmdtext, pm);
			dcmdalt(frisk, 10, cmdtext, przeszukaj);
			dcmdalt(help, 5, cmdtext, pomoc);
			dcmd(przepustka, 10, cmdtext);
			dcmd(przejedz, 8, cmdtext);

		}
		
		case 'r':
		{
			dcmdalt(report, 6, cmdtext, raport);
			dcmd(report, 6, cmdtext);
			dcmd(respawnautszybki, 16, cmdtext);
			dcmd(respawnstrefa, 13, cmdtext);
			dcmd(respawnaut, 10, cmdtext);
			dcmd(reload, 6, cmdtext);
			dcmd(removebw, 8, cmdtext);
			dcmd(reservedslots, 13, cmdtext);
			dcmd(recon, 5, cmdtext);

			if(PlayerInfo[playerid][pWounded] > 0) return 1; // poni¿ej komendy, które s¹ niedostêpne podczas BW

			dcmd(ro, 2, cmdtext);
			dcmd(r, 1, cmdtext);
			dcmd(radiopomoc, 10, cmdtext);
			dcmd(reanimuj, 8, cmdtext);
		}
		
		case 's':
		{
			dcmd(setint, 6, cmdtext);
			dcmd(setvw, 5, cmdtext);
			dcmd(setskin, 7, cmdtext);
			dcmd(setplayerint, 12, cmdtext);
			dcmd(setplayervw, 11, cmdtext);
			dcmd(sprawdzbronie, 13, cmdtext);
			dcmd(skick, 5, cmdtext);
			dcmd(sprawdzpojazdy, 14, cmdtext);
			dcmd(sethp, 5, cmdtext);
			dcmd(setarmor, 8, cmdtext);
			dcmd(setjob, 6, cmdtext);
			dcmd(sban, 4, cmdtext);
			dcmd(slap, 4, cmdtext);
            dcmd(stylwalki, 9, cmdtext);

			if(PlayerInfo[playerid][pWounded] > 0) return 1; // poni¿ej komendy, które s¹ niedostêpne podczas BW

      dcmdalt(k,1,cmdtext,shout);
			dcmd(slady, 5, cmdtext);
			dcmd(s, 1, cmdtext);
			dcmd(sprzedaj, 8, cmdtext);
			dcmd(setloc, 6, cmdtext);
			dcmd(stylrozmowy, 11, cmdtext);

			#if TIKI_EVENT
			dcmd(startevent, 10, cmdtext);
			#endif
		}
		
		case 't':
		{
			dcmd(tod, 3, cmdtext);
			dcmd(teleport, 8, cmdtext);
			dcmdalt(recon, 2, cmdtext, tv);

			if(PlayerInfo[playerid][pWounded] > 0) return 1; // poni¿ej komendy, które s¹ niedostêpne podczas BW

			dcmd(trasa, 5, cmdtext);
			dcmd(togf, 4, cmdtext);
		}

		case 'u':
		{
			dcmd(unfreeze, 8, cmdtext);
			dcmd(unwarn, 6, cmdtext);

			if(PlayerInfo[playerid][pWounded] > 0) return 1; // poni¿ej komendy, które s¹ niedostêpne podczas BW

			dcmd(ukryjnicki, 10, cmdtext);
			dcmd(usunkanal, 9, cmdtext);
			dcmd(ustawkanal, 10, cmdtext);
		}
		
		case 'v':
		{
			if(PlayerInfo[playerid][pWounded] > 0) return 1; // poni¿ej komendy, które s¹ niedostêpne podczas BW
			
			dcmdalt(pojazd, 1, cmdtext, v);
		}
		
		case 'w':
		{
			dcmd(weather, 7, cmdtext);
			dcmd(weapondrop, 10, cmdtext);
			dcmd(warn, 4, cmdtext);

			if(PlayerInfo[playerid][pWounded] > 0) return 1; // poni¿ej komendy, które s¹ niedostêpne podczas BW

			dcmd(w, 1, cmdtext);
			dcmd(wr, 2, cmdtext);
			dcmdalt(enter, 5, cmdtext, wejdz);
			dcmdalt(exit, 5, cmdtext, wyjdz);
			dcmd(wyscig, 6, cmdtext);
			dcmd(wymelduj, 8, cmdtext);
			dcmd(warsztat, 8, cmdtext);
			dcmd(wykupkanal, 10, cmdtext);
			dcmd(wykuphaslo, 10, cmdtext);
		}
		
		case 'z':
		{
			dcmd(zezwoleniepojazd, 16, cmdtext);
			dcmdalt(pay, 6, cmdtext, zaplac);

			if(PlayerInfo[playerid][pWounded] > 0) return 1; // poni¿ej komendy, które s¹ niedostêpne podczas BW

			dcmd(zaklad, 6, cmdtext);
			dcmd(zbieraj, 7, cmdtext);
			dcmd(zamelduj, 8, cmdtext);
			dcmdalt(lock, 7, cmdtext, zamknij);
			dcmd(zamowpojazd, 11, cmdtext);
			dcmd(zmienhaslo, 10, cmdtext);
			dcmdalt(invite, 9, cmdtext, zatrudnij);
		}
	}

	if(PlayerInfo[playerid][pWounded] > 0)
	{
		return 1;
	}

	/*if(strcmp(cmd, "/muzyka", true) == 0) {
              //Audio_Play(playerid, 1);

	foreach(Player, i)
	{
		//if(!Audio_IsClientConnected(i)) continue;
		new muzyka = Audio_Play(i, 2);
		Audio_Set3DPosition(i, muzyka, 1482.2539, -1838.7302, 13.5469, 50.0);
	}
    return 1;
	}
	if(strcmp("/nutkayo", cmdtext, true) == 0)
    {
for (new i = 0; i != MAX_PLAYERS; ++i)
{
    if (IsPlayerConnected(i))
    {
    new hehe = Audio_Play(i, 2);
		if(!Audio_IsClientConnected(i)) continue;
		//Audio_PlaySound3D(i, muzyka, 1482.2539, -1838.7302, 13.5469, 50.0);
		
		Audio_Set3DPosition(i, hehe, 1482.2539, -1838.7302, 13.5469, 50.0);
	}
 }
        return 1;
    }*/
 if (!strcmp(cmd, "/stworzorganizacje", true))
 {
  if(IsPlayerConnected(playerid))
  {
   if(PlayerInfo[playerid][pAdmin] == 1337)
   {
    tmp = strtok(cmdtext, idx);

    if(!strlen(tmp))
 	  {
 	  	SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /stworzoragnizacje [typ(1-gang,2-prywatna)] [IdGracza/CzêœæNazwy]");
 	  	return 1;
 	  }
 	
 	  new orgType = strval(tmp);
 	
 	  tmp = strtok(cmdtext, idx);
 	
    if(!strlen(tmp))
 	  {
 	  	SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /stworzoragnizacje [typ(1-gang,2-prywatna)] [IdGracza/CzêœæNazwy]");
 	  	return 1;
 	  }
 	
 	  giveplayerid = ReturnUser(tmp);
 	
 	  if(orgType < 1 || orgType > 2)
 	  {
 	   SendClientMessage(playerid, COLOR_GRAD1, "Niepoprawny typ organizacji (1-gang,2-organizacja prywatna).");
 	   return 1; 	
 	  }
 	
 	  if(!IsPlayerConnected(giveplayerid))
 	  {
 	   SendClientMessage(playerid, COLOR_GRAD1, "Ta osoba jest niedostêpna.");
 	   return 1;
 	  }
 	
 	  if(PlayerInfo[giveplayerid][pUFLeader] < MAX_UNOFFICIAL_FACTIONS+1 || PlayerInfo[giveplayerid][pLeader] > 0)
 	  {
 	   SendClientMessage(playerid, COLOR_GRAD1, "Ta osoba jest ju¿ liderem innej frakcji.");
 	   return 1;
 	  }
 	
 	  if(PlayerInfo[giveplayerid][pMember] > 0 || PlayerInfo[giveplayerid][pUFMember] < MAX_UNOFFICIAL_FACTIONS+1)
 	  {
 	   SendClientMessage(playerid, COLOR_GRAD1, "Ta osoba jest ju¿ cz³onkiem innej frakcji.");
 	   return 1;
 	  }
 	
 	  GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
 	  GetPlayerNameEx(playerid, sendername, sizeof(sendername));
 	
 	  GetPlayerName(giveplayerid, playername, sizeof(playername));
 	
 	  new query[512];
 	  format(query, sizeof(query), "INSERT INTO organization_game_unofficial_factions SET name = 'Nowa organizacja', `motd` = 'Brak', `leader_id` = %d, `spawnX` = '1685.7220', `spawnY` = '-2334.0012', `spawnZ` = '-2.6797', `spawnA` = '357.5278', `spawnInterior` = 0, `spawnVw` = 0, `type` = %d",
 	    PlayerInfo[giveplayerid][pId],
 	    orgType
 	  );
 	
 	  mysql_query(query);
 	
 	  MySQLAssignMiniFaction(giveplayerid);
 	
 	  new orggId = PlayerInfo[giveplayerid][pUFLeader];
 	
	   // konfiguracja
 	
 	  strmid(MiniFaction[orggId][mName], "Nowa organizacja", 0, strlen("Nowa organizacja"), 255);
 	
 	  MiniFaction[orggId][mId] = orggId;
 	  MiniFaction[orggId][mSpawnX] = 1685.7220;
 	  MiniFaction[orggId][mSpawnY] = -2334.0012;
 	  MiniFaction[orggId][mSpawnZ] = -2.6797;
 	  MiniFaction[orggId][mSpawnA] = 357.5278;
 	  MiniFaction[orggId][mSpawnA] = 357.5278;
 	  MiniFaction[orggId][mSpawnInterior] = 0;
 	  MiniFaction[orggId][mSpawnVW] = 0;
 	  MiniFaction[orggId][mType] = orgType;
 	
 	  strmid(MiniFaction[orggId][mRank1], "Brak", 0, strlen("Brak"), 255);
 	  strmid(MiniFaction[orggId][mRank2], "Brak", 0, strlen("Brak"), 255);
 	  strmid(MiniFaction[orggId][mRank3], "Brak", 0, strlen("Brak"), 255);
 	  strmid(MiniFaction[orggId][mRank4], "Brak", 0, strlen("Brak"), 255);
 	  strmid(MiniFaction[orggId][mRank5], "Brak", 0, strlen("Brak"), 255);
 	
 	  strmid(MiniFaction[orggId][mMOTD],  "Brak", 0, strlen("Brak"), 255);
 	
 	  format(string, sizeof(string), "Nieoficjalna organizacja zosta³a stworzona oraz przydzielona %s.", giveplayer);
 	  SendClientMessage(playerid, COLOR_AWHITE, string);
 	
 	  format(string, sizeof(string), "Administrator %s stworzy³ nieoficjaln¹ organizacjê i przydzieli³ j¹ tobie.", sendername);
 	  SendClientMessage(giveplayerid, COLOR_LORANGE, string);
 	  SendClientMessage(giveplayerid, COLOR_AWHITE, "Aby zarz¹dzaæ organizacj¹ u¿yj komendy /organizacja.");
 	  SendClientMessage(giveplayerid, COLOR_AWHITE, "Na wstêpie powinieneœ ustawiæ nazwê organizacji oraz miejsce spawnu.");
 	  return 1;
   }
   else
   {
    SendClientMessage(playerid, COLOR_GRAD1, "Nie masz uprawnieñ.");
    return 1;
   }
  }
  return 1;
 }
 if (!strcmp(cmd, "/organizacja", true))
 {
  if(IsPlayerConnected(playerid))
  {
   if(PlayerInfo[playerid][pUFLeader] == MAX_UNOFFICIAL_FACTIONS+1 || PlayerInfo[playerid][pUFLeader] == 0)
   {
    SendClientMessage(playerid, COLOR_GRAD1, "Nie jesteœ liderem ¿adnej organizacji.");
    return 1;
   }

   new orggId = PlayerInfo[playerid][pUFLeader];
   
   new
     command[256], query[512]
   ;

	  tmp = strtok(cmdtext, idx);
	  if(!strlen(tmp))
	  {
	  	/*SendClientMessage(playerid, COLOR_LORANGE, "** Zarz¹dzanie nieoficjaln¹ organizacj¹ **");
	  	SendClientMessage(playerid, COLOR_AWHITE,  "/organizacja nazwa [NowaNazwa]");
	  	SendClientMessage(playerid, COLOR_AWHITE,  "/organizacja motto [Treœæ]");
	  	SendClientMessage(playerid, COLOR_AWHITE,  "/organizacja ranga [IdRangi] [NazwaRangi]");
	  	SendClientMessage(playerid, COLOR_AWHITE,  "/organizacja spawn (Ustawia spawn w aktualnym miejscu pobytu)");
			SendClientMessage(playerid, COLOR_AWHITE,  "/organizacja zapros");
			SendClientMessage(playerid, COLOR_AWHITE,  "/organizacja dajrange");
			SendClientMessage(playerid, COLOR_AWHITE,  "/organizacja dajbron");*/
			
	SendClientMessage(playerid, COLOR_LORANGE, "** Zarz¹dzanie organizacj¹ **");
    SendClientMessage(playerid, COLOR_AWHITE,  "nazwa, motto, spawn, online");
    SendClientMessage(playerid, COLOR_AWHITE,  "ranga, dajrange, zapros");
    SendClientMessage(playerid, COLOR_AWHITE,  "dajbron");
	  	return 1;
	  }
	  strmid(command, tmp, 0, sizeof(tmp), sizeof(command));

	  if(!strcmp(command, "nazwa", true))
	  {		
			 new length = strlen(cmdtext);
		 	while ((idx < length) && (cmdtext[idx] <= ' '))
			 {
			 	idx++;
			 }
		 	new offset = idx;
		 	new result[32];
		 	while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
		 	{
		 		result[idx - offset] = cmdtext[idx];
		 		idx++;
			 }
		  result[idx - offset] = EOS;
		 	
    if(!strlen(result))
		 	{
			 	SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /organizacja nazwa [NowaNazwa]");
		 		return 1;
		 	}
		 	
		 	strmid(MiniFaction[orggId][mName], result, 0, strlen(result), 255);

		 	new escresult[64];
		 	mysql_real_escape_string(result, escresult);
    format(query, sizeof(query), "UPDATE organization_game_unofficial_factions SET name = '%s' WHERE id = %d", escresult, orggId);
    mysql_query(query);

    SendClientMessage(playerid, COLOR_GRAD1, "Nazwa organizacji zosta³a zmieniona.");
    return 1;
	  }
	  else if(!strcmp(command, "motto", true))
	  {		
			 new length = strlen(cmdtext);
		 	while ((idx < length) && (cmdtext[idx] <= ' '))
			 {
			 	idx++;
			 }
		 	new offset = idx;
		 	new result[32];
		 	while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
		 	{
		 		result[idx - offset] = cmdtext[idx];
		 		idx++;
			 }
		  result[idx - offset] = EOS;
		 	
    if(!strlen(result))
		 	{
			 	SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /organizacja motto [Treœæ]");
		 		return 1;
		 	}
		 	
		 	strmid(MiniFaction[orggId][mMOTD], result, 0, strlen(result), 255);

		 	new escresult[64];
		 	mysql_real_escape_string(result, escresult);
    format(query, sizeof(query), "UPDATE organization_game_unofficial_factions SET motd = '%s' WHERE id = %d", escresult, orggId);
    mysql_query(query);

    SendClientMessage(playerid, COLOR_GRAD1, "Nowe motto organizacji zosta³o zapisane.");
    return 1;
	  }
		else if(!strcmp(command, "dajbron", true))
	  {
			tmp = strtok(cmdtext, idx);
		
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /organizacja dajbron [IdGracza/CzêœæNazwy] [IdBroni]");
				return 1;
			}
			
		 	giveplayerid = ReturnUser(tmp);
			
			tmp = strtok(cmdtext, idx);
		
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /organizacja dajbron [IdGracza/CzêœæNazwy] [IdBroni]");
				return 1;
			}
			
		 	new weaponid = strval(tmp);
			
			if(!IsPlayerConnected(giveplayerid))
			{
				SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedostêpna.");
				return 1;
			}
			
			if(orggId != GetPlayerUnofficialOrganization(giveplayerid))
			{
				SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest nie jest cz³onkiem Twojej organizacji.");
				return 1;
			}
			
			if(!IsValidWeapon(weaponid))
			{
				SendClientMessage(playerid, COLOR_GREY, "Niepoprawne ID broni.");
				return 1;
			}
			
			if(weaponid != 41 && weaponid != 5 && weaponid != 1)
			{
				SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz przydzieliæ tej osobie takiej broni.");
				return 1;
			}
			
			if(GetPlayerMoneyEx(playerid) < weaponsPrices[weaponid])
			{
				CantAffordMsg(playerid,weaponsPrices[weaponid]);
				return 1;
			}
			
			new itemtypeindex = GetWeaponItemByWeaponId(weaponid);
  
			if(itemtypeindex == -1)
			{
				SendClientMessage(playerid, COLOR_GREY, "Wyst¹pi³ b³¹d. Nie znaleziono przedmiotu dla tej broni.");
				return 1;
			}
			
			new nitem[pItem];
						
			nitem[iItemId] = ItemsTypes[itemtypeindex][itId];
			nitem[iCount] = 0;
			nitem[iOwner] = PlayerInfo[giveplayerid][pId];
			nitem[iOwnerType] = CONTENT_TYPE_USER;
			nitem[iPosX] = 0.0;
			nitem[iPosY] = 0.0;
			nitem[iPosZ] = 0.0;
			nitem[iPosVW] = 0;
			nitem[iFlags] = 0;
			nitem[iAttr1] = ItemsTypes[itemtypeindex][itAttr1];
			nitem[iAttr2] = ItemsTypes[itemtypeindex][itAttr2];
			nitem[iRestrictedType] = CONTENT_TYPE_UNOFFICIAL_ORGANIZATION;
			nitem[iRestricted] = orggId;

			new itemid = CreateItem(nitem);
			
			if(itemid == HAS_REACHED_LIMIT)
			{
				SendClientMessage(playerid, COLOR_GREY, "Ta osoba nie mo¿e posiadaæ wiêcej przedmiotów.");
				return 1;
			}
			
			GivePlayerMoneyEx(playerid, -weaponsPrices[weaponid]);
			Tax += weaponsPrices[weaponid];
			
			GetPlayerNameEx(playerid, sendername, sizeof(sendername));
			GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
			
			format(string, sizeof(string), "Przekaza³eœ %s broñ (ID: %d) %s. Zap³aci³eœ za ni¹ $%d.", giveplayer, itemid, ItemsTypes[itemtypeindex][itName], weaponsPrices[weaponid]);
			SendClientMessage(playerid, COLOR_LORANGE, string);
			
			format(string, sizeof(string), "%s przekaza³ Ci broñ (ID: %d) %s.", sendername, itemid, ItemsTypes[itemtypeindex][itName]);
			SendClientMessage(giveplayerid, COLOR_LORANGE, string);
			
			printf("%s przekaza³ broñ (ID: %d) %s graczowi %s.", sendername, itemid, ItemsTypes[itemtypeindex][itName], giveplayer);
			
			return 1;
		}
		else if(!strcmp(command, "online", true))
		{
           	foreach(Player, i)
            {
 		        if(GetPlayerUnofficialOrganization(i) == GetPlayerUnofficialOrganization(playerid))
                    format(string, 512, "%s%d\t%s\n", string, i, pName(i));
            }
            ShowPlayerDialog(playerid, DIALOG_ONLINE, DIALOG_STYLE_LIST, "Frakcja online:", string, "Wybierz", "Zamknij");
			return 1;
		}
	  else if(!strcmp(command, "zapros", true))
	  {
	   tmp = strtok(cmdtext, idx);
		
   	if(!strlen(tmp))
			 {
				 SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /organizacja zapros [IdGracza/CzêœæNazwy]");
				 return 1;
			 }
			
		 	giveplayerid = ReturnUser(tmp);
		 	
	   if(PlayerInfo[giveplayerid][pUFLeader] < MAX_UNOFFICIAL_FACTIONS+1 || PlayerInfo[giveplayerid][pLeader] > 0)
	     {
			  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest liderem innej organizacji.");
				 return 1;
			 }

    if(PlayerInfo[giveplayerid][pUFMember] < MAX_UNOFFICIAL_FACTIONS+1 || PlayerInfo[giveplayerid][pMember] > 0)
	   {
     SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest cz³onkiem innej organizacji.");
				 return 1;
		  }
			
    GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
				GetPlayerNameEx(playerid, sendername, sizeof(sendername));
			
    new ufid = PlayerInfo[playerid][pUFLeader];

    SetPlayerVirtualWorldEx(giveplayerid,MiniFaction[ufid][mSpawnVW]);
    SetPlayerInterior(giveplayerid,MiniFaction[ufid][mSpawnInterior]);
			 SetPlayerPosEx(giveplayerid,MiniFaction[ufid][mSpawnX],MiniFaction[ufid][mSpawnY],MiniFaction[ufid][mSpawnZ]);
		  SetPlayerFacingAngle(giveplayerid,MiniFaction[ufid][mSpawnA]);
		  	
  	 PlayerInfo[giveplayerid][pUFMember] = PlayerInfo[playerid][pUFLeader];
  	 PlayerInfo[giveplayerid][pRank]     = 1;
		  	
  	 printf("UnofficialOrg: %s zaprosil %s do %s.", sendername, giveplayer, MiniFaction[ufid][mName]);
				format(string, sizeof(string), "* Zosta³eœ przyjêty do organizacji %s przez %s.", MiniFaction[ufid][mName], sendername);
				SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
				format(string, sizeof(string), "Przyj¹³eœ %s do organizacji %s.", giveplayer, MiniFaction[ufid][mName]);
				SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
				
				return 1;
	  }
	  else if(!strcmp(command, "spawn", true))
   {
	   GetPlayerPos(playerid, MiniFaction[orggId][mSpawnX], MiniFaction[orggId][mSpawnY], MiniFaction[orggId][mSpawnZ]);
	   GetPlayerFacingAngle(playerid, MiniFaction[orggId][mSpawnA]);
	   MiniFaction[orggId][mSpawnInterior] = GetPlayerInterior(playerid);
	   MiniFaction[orggId][mSpawnVW]  = GetPlayerVirtualWorld(playerid);
	
	   format(query, sizeof(query), "UPDATE organization_game_unofficial_factions SET spawnX = %f, spawnY = %f, spawnZ = %f, spawnA = %f, spawnInterior = %d, spawnVW = %d WHERE id = %d",
			MiniFaction[orggId][mSpawnX], MiniFaction[orggId][mSpawnY], MiniFaction[orggId][mSpawnZ], MiniFaction[orggId][mSpawnA], MiniFaction[orggId][mSpawnInterior], MiniFaction[orggId][mSpawnVW], orggId);
			
	   mysql_query(query);
	
	   SendClientMessage(playerid, COLOR_GRAD1, "Miejsce spawnu zosta³o zapisane.");
	   return 1;
	  }
		else if(!strcmp(command, "dajrange", true))
    {
	   tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /dajrange [IdGracza/CzêœæNazwy] [Liczby(1-6)]");
				return 1;
			}
			new para1;
			new level;
			para1 = ReturnUser(tmp);
			tmp = strtok(cmdtext, idx);
			level = strval(tmp);
			
			if((PlayerInfo[playerid][pUFLeader] < MAX_UNOFFICIAL_FACTIONS+1 && PlayerInfo[playerid][pUFLeader] == PlayerInfo[para1][pUFMember])
			 || (PlayerInfo[playerid][pUFLeader] < MAX_UNOFFICIAL_FACTIONS+1 && para1 == playerid)){}
		  else
		  {
			 SendClientMessage(playerid, COLOR_GREY, "   Ta osoba nie nale¿y do Twojej frakcji!");
		  	return 1;
		  }

		
		 // mini frakcje
		 if(PlayerInfo[para1][pUFMember] < MAX_UNOFFICIAL_FACTIONS+1 || PlayerInfo[para1][pUFLeader] < MAX_UNOFFICIAL_FACTIONS+1)
		 {
		  if(level > 5 || level < 0) { SendClientMessage(playerid, COLOR_GREY, "   Liczba od 1 do 5!"); return 1; }
		 }
		
			if (PlayerInfo[playerid][pUFLeader] < MAX_UNOFFICIAL_FACTIONS+1)
			{
			 if(IsPlayerConnected(para1))
			 {
			  if(para1 != INVALID_PLAYER_ID)
			  {
						GetPlayerNameEx(para1, giveplayer, sizeof(giveplayer));
						GetPlayerNameEx(playerid, sendername, sizeof(sendername));
						PlayerInfo[para1][pRank] = level;
						format(string, sizeof(string), "   Dosta³eœ awans od lidera %s", sendername);
						SendClientMessage(para1, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "   Da³eœ %s %d rangê.", giveplayer,level);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
					}
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "Nie jesteœ uprawniony do u¿ycia tej komendy!");
			}
	   return 1;
	  }
	  else if(!strcmp(command, "ranga", true))
	  {
	   tmp = strtok(cmdtext, idx);
	   if(!strlen(tmp))
	   {
	   	SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /organizacja ranga [NrRangi] [NowaNazwa]");
	   	return 1;
	   }
	   new rankId = strval(tmp);
	
	   if(rankId < 1 || rankId > 5)
	   {
	    SendClientMessage(playerid, COLOR_GRAD1, "Niepoprawny numer rangi. Dopuszczalne numery to od 1 do 5.");
	   	return 1;
	   }
	
			 new length = strlen(cmdtext);
		 	while ((idx < length) && (cmdtext[idx] <= ' '))
			 {
			 	idx++;
			 }
		 	new offset = idx;
		 	new result[32];
		 	while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
		 	{
		 		result[idx - offset] = cmdtext[idx];
		 		idx++;
			 }
		  result[idx - offset] = EOS;
		 	
    if(!strlen(result))
		 	{
			 	SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /organizacja ranga [NrRangi] [NowaNazwa]");
		 		return 1;
		 	}
		 	
		 	switch(rankId)
		 	{
		 	 case 1: { strmid(MiniFaction[orggId][mRank1], result, 0, strlen(result), 255); }
		 	 case 2: { strmid(MiniFaction[orggId][mRank2], result, 0, strlen(result), 255); }
		 	 case 3: { strmid(MiniFaction[orggId][mRank3], result, 0, strlen(result), 255); }
		 	 case 4: { strmid(MiniFaction[orggId][mRank4], result, 0, strlen(result), 255); }
		 	 case 5: { strmid(MiniFaction[orggId][mRank5], result, 0, strlen(result), 255); }
	 	 }
		 	
		 	new escresult[64];
		 	mysql_real_escape_string(result, escresult);
    format(query, sizeof(query), "UPDATE organization_game_unofficial_factions SET rank%d = '%s' WHERE id = %d", rankId, escresult, orggId);
    mysql_query(query);

    SendClientMessage(playerid, COLOR_GRAD1, "Nazwa rangi zosta³a zmieniona.");
    return 1;
	  }
  }
 }
 if (!strcmp(cmd, "/zamow", true) || !strcmp(cmd, "/zamów", true))
 {
  if(IsPlayerConnected(playerid))
  {
   if (!PlayerToPoint(3, playerid,2127.7383,-2275.5435,20.6719))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "   Nie znajdujesz siê w miejscu zamawiania nielegalnych przedmiotów !");
				return 1;
			}
			
   tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /zamów [numer przedmiotu]");
				SendClientMessage(playerid, COLOR_GREEN, "|_________________ Zamówienia _________________|");
				SendClientMessage(playerid, COLOR_GRAD1, "| 1: Maska   $7000");
				return 1;
			}
			
			new item = strval(tmp);

			switch(item)
			{
			 case 1:
 		 {
		   if(PlayerInfo[playerid][pMask] == 1)
		   {
		    SendClientMessage(playerid, COLOR_GRAD1, "Posiadasz ju¿ maskê.");
		    return 1;
		   }
		
		   if(PlayerInfo[playerid][pConnectTime] < 100)
		   {
		    SendClientMessage(playerid, COLOR_GRAD1, "Aby zamówiæ maskê musisz mieæ przegrane 100 godzin.");
		    return 1;
		   }
		
		   IllegalOrderReady[playerid] = item;
		
 	 		SendClientMessage(playerid, COLOR_GRAD5, "Udaj siê do miejsca odbioru nielegalnych przedmiotów (w Blueberry).");
		   return 1;
			 }
			 default:
			 {
			  SendClientMessage(playerid, COLOR_GRAD1, "Niepoprawny numer przedmiotu.");
			  return 1;
			 }
			}
  }
 }

 if (!strcmp(cmd, "/wyplata", true))
 {
  if(IsPlayerConnected(playerid))
  {
   if(PlayerToPoint(1.0, playerid, 2309.8696,-8.3771,26.7422))
   {
    if(PlayerInfo[playerid][pPayment])
    {
     format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~w~Odebrales wyplate~n~w wysokosci~n~~p~$%d", PlayerInfo[playerid][pPayment]);
     GameTextForPlayer(playerid, string, 4000, 3);
     GivePlayerMoneyEx(playerid,PlayerInfo[playerid][pPayment]);
     PlayerInfo[playerid][pPayment] = 0;
    }
    else
    {
     GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~r~Nie ma zadnej wyplaty", 4000, 3);
    }
    return 1;
   }
  }
 }

 if (!strcmp(cmd, "/rozpocznijtrening", true))
 {
  if(IsPlayerConnected(playerid))
  {
   if((PlayerInfo[playerid][pLeader] == 17 || PlayerInfo[playerid][pMember] == 17) && PlayerInfo[playerid][pRank] > 1)
   {
    if(academyTrening == 1)
    {
     academyTrening = 0;
     SendClientMessage(playerid, COLOR_GRAD1, "Zakoñczy³eœ trening kadetów Akademii Policyjnej.");

     for(new i = 0; i < MAX_PLAYERS; i++)
     {
      if(PlayerInfo[i][pMember] == 17 || PlayerInfo[i][pLeader] == 17)
      {
       ResetPlayerWeaponsEx(i);
       SetPlayerArmour(i, 0.0);
      }
     }
    }
    else
    {
     academyTrening = 1;
     SendClientMessage(playerid, COLOR_GRAD1, "Rozpocz¹³eœ trening kadetów Akademii Policyjnej.");

     for(new i = 0; i < MAX_PLAYERS; i++)
     {
      if(IsPlayerConnected(i))
      {
       if(PlayerInfo[i][pMember] == 17 || PlayerInfo[i][pLeader] == 17)
       {
        SetPlayerSkin(i, PlayerInfo[i][pModel]);
       }
      }
     }
    }
   }
  }
 }
 if (!strcmp(cmd, "/zakonczprace", true))
 {
  if(IsPlayerConnected(playerid))
  {
   if(PlayerInfo[playerid][pJob] == 17)
   {
    if(PizzaDuty[playerid] == 0)
    {
     SendClientMessage(playerid, COLOR_GRAD1, "Aktualnie nie pracujesz.");
     return 1;
    }

    PlayerInfo[playerid][pPizzaTimer] = 60 * 5;
    DisablePlayerCheckpoint(playerid);
    PizzaDuty[playerid] = 0;

    SendClientMessage(playerid, COLOR_GRAD1, "Zakoñczy³eœ pracê.");
    return 1;
   }
   else
   {
    SendClientMessage(playerid, COLOR_GRAD1, "Nie masz ¿adnej pracy.");
    return 1;
   }
  }
 }
 if (!strcmp(cmd, "/zamowienia", true))
 {
  if(IsPlayerConnected(playerid))
  {
   if(PlayerInfo[playerid][pJob] == 17)
   {
    if(PlayerToPoint(7.5, playerid, 379.4343,-119.5055,1001.4922))
    {
     if(pizzaOrders[playerid] > 0)
     {
      SendClientMessage(playerid, COLOR_GRAD1, "Musisz najpierw rozwieŸæ wszystkie pizze.");
     }
     else
     {
      pizzaOrders[playerid] = 5;
      SendClientMessage(playerid, TEAM_GROVE_COLOR, "Odebra³eœ zamówienia i kartony z pizz¹, udaj siê do skutera.");
     }
    }
   }
   else
   {
    SendClientMessage(playerid, COLOR_GRAD1, "Nie jesteœ rozwozicielem pizzy.");
    return 1;
   }
  }
 }
 if (!strcmp(cmd, "/zaklejusta", true))
 {
  if(IsPlayerConnected(playerid))
  {
   if(PlayerInfo[playerid][pLeader] == 1 || PlayerInfo[playerid][pMember] == 1 || PlayerInfo[playerid][pLeader] == 2 || PlayerInfo[playerid][pMember] == 2 || PlayerInfo[playerid][pLeader] == 3 || PlayerInfo[playerid][pMember] == 3 || PlayerInfo[playerid][pLeader] == 5 || PlayerInfo[playerid][pMember] == 5
   || PlayerInfo[playerid][pLeader] == 6 || PlayerInfo[playerid][pMember] == 6 || PlayerInfo[playerid][pLeader] == 7 || PlayerInfo[playerid][pMember] == 7 || PlayerInfo[playerid][pLeader] == 8 || PlayerInfo[playerid][pMember] == 8 || (PlayerInfo[playerid][pMember] >= 13 && PlayerInfo[playerid][pMember] <= 16) || (PlayerInfo[playerid][pLeader] >= 13 && PlayerInfo[playerid][pLeader] <= 16 
	 || GetPlayerOrganization(playerid) == 19)  )
   {
    tmp = strtok(cmdtext, idx);
 	
    if(!strlen(tmp))
 	  {
 	  	SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /zaklejusta [IdGracza/CzêœæNazwy]");
 	  	return 1;
 	  }
 	
 	  giveplayerid = ReturnUser(tmp);
 	
 	  if(GetDistanceBetweenPlayers(playerid, giveplayerid) > 3.0)
 	  {
 	   SendClientMessage(playerid, COLOR_GRAD1, "Nie ma takiej osoby w pobli¿u.");
 	   return 1;
 	  }
 	
 	  PlayerInfo[giveplayerid][pMuted] = 2;
 	
 	  GetPlayerNameMask(playerid, sendername, sizeof(sendername));
 	  GetPlayerNameMask(giveplayerid, giveplayer, sizeof(giveplayer));
 	
 	  format(string, sizeof(string), "zakleja usta %s", giveplayer);
 			ServerMe(playerid, string);
   }
  }
 }

 if (!strcmp(cmd, "/odklejusta", true))
 {
  if(IsPlayerConnected(playerid))
  {
   if(PlayerInfo[playerid][pLeader] == 1 || PlayerInfo[playerid][pMember] == 1 || PlayerInfo[playerid][pLeader] == 2 || PlayerInfo[playerid][pMember] == 2 || PlayerInfo[playerid][pLeader] == 3 || PlayerInfo[playerid][pMember] == 3 || PlayerInfo[playerid][pLeader] == 5 || PlayerInfo[playerid][pMember] == 5
   || PlayerInfo[playerid][pLeader] == 6 || PlayerInfo[playerid][pMember] == 6 || PlayerInfo[playerid][pLeader] == 7 || PlayerInfo[playerid][pMember] == 7 || PlayerInfo[playerid][pLeader] == 8 || PlayerInfo[playerid][pMember] == 8 || (PlayerInfo[playerid][pMember] >= 13 && PlayerInfo[playerid][pMember] <= 16) || (PlayerInfo[playerid][pLeader] >= 13 && PlayerInfo[playerid][pLeader] <= 16
		|| GetPlayerOrganization(playerid) == 19))
   {
    tmp = strtok(cmdtext, idx);
 	
    if(!strlen(tmp))
 	  {
 	  	SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /zaklejusta [IdGracza/CzêœæNazwy]");
 	  	return 1;
 	  }
 	
 	  giveplayerid = ReturnUser(tmp);
 	
 	  if(GetDistanceBetweenPlayers(playerid, giveplayerid) > 3.0)
 	  {
 	   SendClientMessage(playerid, COLOR_GRAD1, "Nie ma takiej osoby w pobli¿u.");
 	   return 1;
 	  }
 	
 	  PlayerInfo[giveplayerid][pMuted] = 0;
 	
 	  GetPlayerNameMask(giveplayerid, giveplayer, sizeof(giveplayer));
 	
 	  format(string, sizeof(string), "œci¹ga taœmê klej¹c¹ z ust %s", giveplayer);
 			ServerMe(playerid, string);
   }
  }
 }

 /*if (!strcmp(cmd, "/zabierztelefon", true))
 {
  if(IsPlayerConnected(playerid))
  {
   if(PlayerInfo[playerid][pLeader] == 1 || PlayerInfo[playerid][pMember] == 1 || PlayerInfo[playerid][pLeader] == 2 || PlayerInfo[playerid][pMember] == 2 || PlayerInfo[playerid][pLeader] == 3 || PlayerInfo[playerid][pMember] == 3 || PlayerInfo[playerid][pLeader] == 5 || PlayerInfo[playerid][pMember] == 5
   || PlayerInfo[playerid][pLeader] == 6 || PlayerInfo[playerid][pMember] == 6 || PlayerInfo[playerid][pLeader] == 7 || PlayerInfo[playerid][pMember] == 7 || PlayerInfo[playerid][pLeader] == 8 || PlayerInfo[playerid][pMember] == 8 || (PlayerInfo[playerid][pMember] >= 13 && PlayerInfo[playerid][pMember] <= 16) || (PlayerInfo[playerid][pLeader] >= 13 && PlayerInfo[playerid][pLeader] <= 16)  )
   {
    tmp = strtok(cmdtext, idx);
 	
    if(!strlen(tmp))
 	  {
 	  	SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /zabierztelefon [IdGracza/CzêœæNazwy]");
 	  	return 1;
 	  }
 	
 	  giveplayerid = ReturnUser(tmp);
 	
 	  if(GetDistanceBetweenPlayers(playerid, giveplayerid) > 3.0)
 	  {
 	   SendClientMessage(playerid, COLOR_GRAD1, "Nie ma takiej osoby w pobli¿u.");
 	   return 1;
 	  }

 	  if(PlayerInfo[giveplayerid][pPnumber] > 0)
 	  {	
 	   PlayerInfo[giveplayerid][pPnumber] = 0;
 	
  	  GetPlayerNameMask(playerid, sendername, sizeof(sendername));
  	  GetPlayerNameMask(giveplayerid, giveplayer, sizeof(giveplayer));
 	
  	  format(string, sizeof(string), "* %s wyci¹ga telefon %s z kieszeni", sendername, giveplayer);
  			ProxDetectorMask(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		  }
		  else
		  {
		   GetPlayerNameEx(playerid, sendername, sizeof(sendername));
  	  GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
 	
  	  format(string, sizeof(string), "* %s przeszukuje kieszenie %s", sendername, giveplayer);
  			ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		  }
   }
  }
  return 1;
 }*/
 /*if (!strcmp(cmd, "/resettuningu", true))
 {
  if(IsPlayerConnected(playerid))
  {
   if(OwnCar[playerid] != 999)
   {
    new vehicleid = OwnCar[playerid];

    RemoveVehicleComponent(OwnCar[playerid], gVehicles[vehicleid][vComp1]);
    RemoveVehicleComponent(OwnCar[playerid], gVehicles[vehicleid][vComp2]);
    RemoveVehicleComponent(OwnCar[playerid], gVehicles[vehicleid][vComp3]);
    RemoveVehicleComponent(OwnCar[playerid], gVehicles[vehicleid][vComp4]);
    RemoveVehicleComponent(OwnCar[playerid], gVehicles[vehicleid][vComp5]);
    RemoveVehicleComponent(OwnCar[playerid], gVehicles[vehicleid][vComp6]);
    RemoveVehicleComponent(OwnCar[playerid], gVehicles[vehicleid][vComp7]);
    RemoveVehicleComponent(OwnCar[playerid], gVehicles[vehicleid][vComp8]);
    RemoveVehicleComponent(OwnCar[playerid], gVehicles[vehicleid][vComp9]);
    RemoveVehicleComponent(OwnCar[playerid], gVehicles[vehicleid][vComp10]);
    RemoveVehicleComponent(OwnCar[playerid], gVehicles[vehicleid][vComp11]);
    RemoveVehicleComponent(OwnCar[playerid], gVehicles[vehicleid][vComp12]);
    RemoveVehicleComponent(OwnCar[playerid], gVehicles[vehicleid][vComp13]);
    RemoveVehicleComponent(OwnCar[playerid], gVehicles[vehicleid][vComp14]);
    RemoveVehicleComponent(OwnCar[playerid], gVehicles[vehicleid][vComp15]);
    RemoveVehicleComponent(OwnCar[playerid], gVehicles[vehicleid][vComp16]);
    RemoveVehicleComponent(OwnCar[playerid], gVehicles[vehicleid][vComp17]);
    ChangeVehiclePaintjob(vehicleid, -1);

    gVehicles[vehicleid][vComp1] = 0;
    gVehicles[vehicleid][vComp2] = 0;
    gVehicles[vehicleid][vComp3] = 0;
    gVehicles[vehicleid][vComp4] = 0;
    gVehicles[vehicleid][vComp5] = 0;
    gVehicles[vehicleid][vComp6] = 0;
    gVehicles[vehicleid][vComp7] = 0;
    gVehicles[vehicleid][vComp8] = 0;
    gVehicles[vehicleid][vComp9] = 0;
    gVehicles[vehicleid][vComp10] = 0;
    gVehicles[vehicleid][vComp11] = 0;
    gVehicles[vehicleid][vComp12] = 0;
    gVehicles[vehicleid][vComp13] = 0;
    gVehicles[vehicleid][vComp14] = 0;
    gVehicles[vehicleid][vComp15] = 0;
    gVehicles[vehicleid][vComp16] = 0;
    gVehicles[vehicleid][vComp17] = 0;
    gVehicles[vehicleid][vPaintJob] = -1;

    SendClientMessage(playerid, COLOR_GRAD1, "Tuning twojego pojazdu zosta³ usuniêty.");

    return 1;
   }
   else
   {
    SendClientMessage(playerid, COLOR_GRAD1, "Nie posiadasz ¿adnego auta.");
    return 1;
   }
  }
  return 1;
 }*/
	
	if (!strcmp(cmd, "/zbroja", true))
	{
	 if(IsPlayerConnected(playerid))
	 {
	  if(PlayerInfo[playerid][pMember] == 2 || PlayerInfo[playerid][pLeader] == 2)
	  {	
	   if(!PlayerToPoint(2.0, playerid, 240.4544,112.7762,1003.2188) || PlayerToPoint(3.0, playerid, 200.6801,167.1675,1003.0234))
	   {
	    SendClientMessage(playerid, COLOR_GRAD1, "Nie znajdujesz siê przy zbrojowni SWAT.");
	 	  return 1;
	   }
	
	   new Float:parmour;
	   GetPlayerArmour(playerid, parmour);
	
	   if(parmour == 0)
	   {
	    GetPlayerNameEx(playerid, sendername, sizeof(sendername));
			  format(string, sizeof(string), "zak³ada na siebie kamizelkê.");
					ServerMe(playerid, string);
					SetPlayerArmour(playerid, 100);
	   }
	   else
	   {
	    GetPlayerNameEx(playerid, sendername, sizeof(sendername));
			  format(string, sizeof(string), "œci¹ga kamizelkê.");
					ServerMe(playerid, string);
					SetPlayerArmour(playerid, 0);
	   }
   }
  }
  if(PlayerInfo[playerid][pMember] == 3 || PlayerInfo[playerid][pLeader] == 3)
	 {	
	  if(!PlayerToPoint(2.0, playerid, 308.9569,-137.2681,1004.0625))
	  {
	   SendClientMessage(playerid, COLOR_GRAD1, "Nie znajdujesz siê przy zbrojowni LSBG.");
	   return 1;
	  }
	
   new Float:parmour;
	  GetPlayerArmour(playerid, parmour);
	
   if(parmour == 0)
	  {
	   GetPlayerNameEx(playerid, sendername, sizeof(sendername));
		  format(string, sizeof(string), "zak³ada na siebie kamizelkê.");
				ServerMe(playerid, string);
				SetPlayerArmour(playerid, 100);
	  }
	  else
	  {
	   GetPlayerNameEx(playerid, sendername, sizeof(sendername));
		  format(string, sizeof(string), "œci¹ga kamizelkê.");
				ServerMe(playerid, string);
				SetPlayerArmour(playerid, 0);
	  }
  }
  if(PlayerInfo[playerid][pMember] == 13 || PlayerInfo[playerid][pLeader] == 13)
	 {	
	  if(!PlayerToPoint(2.0, playerid, 308.9569,-137.2681,1004.0625))
	  {
	   SendClientMessage(playerid, COLOR_GRAD1, "Nie znajdujesz siê przy zbrojowni FBI.");
	   return 1;
	  }
	
   new Float:parmour;
	  GetPlayerArmour(playerid, parmour);
	
   if(parmour == 0)
	  {
	   GetPlayerNameEx(playerid, sendername, sizeof(sendername));
		  format(string, sizeof(string), "* %s zak³ada na siebie kamizelkê.", sendername);
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				SetPlayerArmour(playerid, 100);
	  }
	  else
	  {
	   GetPlayerNameEx(playerid, sendername, sizeof(sendername));
		  format(string, sizeof(string), "* %s œci¹ga kamizelkê.", sendername);
				ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
				SetPlayerArmour(playerid, 0);
	  }
  }
	}

 
 if(strcmp(cmd, "/owned", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
	  tmp = strtok(cmdtext, idx);
	  if(!strlen(tmp))
	  {
	   SendClientMessage(playerid, COLOR_GRAD2, "    U¯YJ: /owned [id/ImiêLubNazwisko]");
	   SendClientMessage(playerid, COLOR_GRAD1, "    FUNKCJA: Gracz eksploduje.");
    return 1;
   }
	  new playa;
	  new Float:X,Float:Y,Float:Z;

  	playa = ReturnUser(tmp);
  	tmp = strtok(cmdtext, idx);
  	if (PlayerInfo[playerid][pAdmin] >= 4)
  	{
    if(IsPlayerConnected(playa))
	   {
	    if(playa != INVALID_PLAYER_ID)
	    {
	     GetPlayerNameEx(playa, giveplayer, sizeof(giveplayer));
      GetPlayerNameEx(playerid, sendername, sizeof(sendername));
     	GetPlayerPos(playa, X,Y,Z);
      CreateExplosion(X,Y,Z,2,7.0);
     	SetPlayerHealthEx(playa, -50.0);
     	GameTextForPlayer(playa, "OWNED", 16000, 1);
     	format(string, sizeof(string), "AdmCmd: %s zosta³ wysadzony(owned) przez %s",giveplayer ,sendername);
     	ABroadCast(COLOR_LIGHTRED,string,1);
    	}
   	}
	  }
	  else
	  {
	   SendClientMessage(playerid, COLOR_GRAD1, "   Nie masz uprawnieñ do u¿ycia tej komendy.");
	  }
	 }
	 return 1;
	}

 /*if (!strcmp(cmd, "/zaparkuj", true))
 {
  if(IsPlayerInAnyVehicle(playerid) && IsCarOwner(GetPlayerVehicleID(playerid), playerid))
  {
   if(GetPlayerInterior(playerid) > 0 )
   {
    SendClientMessage(playerid, COLOR_GRAD1, "Nie mo¿esz zaparkowaæ pojazdu w tym miejscu.");
	 	 return 1;
   }

   new Float:vParkX, Float:vParkY, Float:vParkZ, Float:vParkA;
   GetVehiclePos(GetPlayerVehicleID(playerid), vParkX, vParkY, vParkZ);
   GetVehicleZAngle(GetPlayerVehicleID(playerid), vParkA);
   GetPlayerName(playerid, sendername, sizeof(sendername));

   // sprawdzanie kolizji
   while (idx < sizeof(gVehicles))
  	{
	   if(strlen(gVehicles[idx][vOwner]) > 0)
	   {
	    if(idx == GetPlayerVehicleID(playerid)){}
	    else
	    {
	     if(GetPointDistanceToPointExMorph(gVehicles[idx][vPosX], gVehicles[idx][vPosY], gVehicles[idx][vPosZ], vParkX, vParkY, vParkZ) < 2.9)
	     {
	      SendClientMessage(playerid, COLOR_GRAD2, "To miejsce parkingowe jest ju¿ zajête.");
	      return 1;
	     }
     }
	   }
	   idx++;
   }

   for(new h = 0; h < sizeof(HouseInfo); h++)
   {
    if(GetPointDistanceToPointExMorph(HouseInfo[h][hEntrancex], HouseInfo[h][hEntrancey], HouseInfo[h][hEntrancez], vParkX, vParkY, vParkZ) < 15.0)
    {
     if(PlayerInfo[playerid][pId] == HouseInfo[h][hOwner]){}
     else
     {
      SendClientMessage(playerid, COLOR_GRAD2, "Nie mo¿esz parkowaæ na terenie nieswojej posiad³oœci.");
	     return 1;
     }
    }
   }

   if(IsVehicleInArea(GetPlayerVehicleID(playerid), 2177.5293, -1785.9414, 2194.6768, -1742.6968) || IsVehicleInArea(GetPlayerVehicleID(playerid), 1751.5269, -1941.1943, 1810.5826, -1882.1433))
   {
    SendClientMessage(playerid, COLOR_GRAD2, "Tutaj obowi¹zuje zakaz parkowania.");
    return 1;
   }

   gVehicles[GetPlayerVehicleID(playerid)][vPosX] = vParkX;
   gVehicles[GetPlayerVehicleID(playerid)][vPosY] = vParkY;
   gVehicles[GetPlayerVehicleID(playerid)][vPosZ] = vParkZ;
   gVehicles[GetPlayerVehicleID(playerid)][vPosA] = vParkA;
   SendClientMessage(playerid, COLOR_WHITE, "Miejsce parkingowe zostanie przyznane w ci¹gu 24h.");

   GetPlayerName(playerid, sendername, sizeof(sendername));
   printf("%s zaparkowa³ pojazd (ID: %d)",sendername, GetPlayerVehicleID(playerid));

   SaveCars();
   return 1;
  }
  else
  {
   SendClientMessage(playerid, COLOR_GRAD1, "Nie posiadasz w³asnego auta.");
	 	return 1;
  }
 }*/
 // dla testow
 #if DEBUG
 if (!strcmp(cmd, "/sound", true))
 {
  tmp = strtok(cmdtext, idx);
	 if(!strlen(tmp))
	 {
	 	SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /sound [IdDzwieku]");
	 	return 1;
	 }
	 new soundID = strval(tmp);
	 PlayerPlaySound(playerid, soundID, 0, 0, 0);
 }
 #endif
 #if 0
 if (!strcmp(cmd, "/okradnij", true))
 {
  if(PlayerInfo[playerid][pJob] != 16)
  {
   SendClientMessage(playerid, COLOR_GRAD1, "Nie jesteœ kieszonkowcem.");
	 	return 1;
  }

  tmp = strtok(cmdtext, idx);
	 if(!strlen(tmp))
	 {
	 	SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /okradnij [IdGracza/CzêœæNazwy]");
	 	return 1;
	 }
	 giveplayerid = ReturnUser(tmp);
	
	 if(playerid == giveplayerid)
  {
   SendClientMessage(playerid, COLOR_GRAD1, "Nie mo¿esz okraœæ samego siebie.");
	 	return 1;
  }
	
	 if (IsPlayerConnected(giveplayerid)){}
	 else
	 {
	  SendClientMessage(playerid, COLOR_GRAD1, "Ta osoba jest niedostêpna.");
			return 1;
	 }
	
	 if (GetDistanceBetweenPlayers(playerid,giveplayerid) > 2)
	 {
	  SendClientMessage(playerid, COLOR_GRAD1, "Nie ma takiej osoby w pobli¿u!");
			return 1;
	 }
	
	 if(PlayerInfo[playerid][pThiefInterval] > 0)
	 {
	  format(string, sizeof(string), "Masz wyrzuty sumienia po ostatniej kradzie¿y. Odpocznij trochê.");
	  SendClientMessage(playerid, COLOR_GRAD1, string);
			return 1;
	 }
	
  GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
 	GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	
	 if(random(100) > 75 - 5 * PlayerInfo[playerid][pThiefSkill] + 3 * random(4))
	 {
	  new money = GetPlayerMoneyEx(giveplayerid) / (random(10) + 10);

   if(money > 0)
   {	
	   GivePlayerMoneyEx(playerid,money);

 	  format(string, sizeof(string), "* Uda³o Ci siê okraœæ %s, ukrad³eœ $%d.", giveplayer, money);
 	  SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
 	
 	  PlayerInfo[playerid][pThiefSkill] += 1;
 	  RobbedMoney[giveplayerid] = money;
 	
		  WantedPoints[playerid] += 2;
				SetPlayerCriminal(playerid,255, "Kradzie¿ pieniêdzy");
 	
 	  printf("%s ukrad³ $%d graczowi %s", sendername, money, giveplayer);
 	
 	  SetTimerEx("RobMoney",10000,0,"d",giveplayerid);
   }
   else
   {
    SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Próbowa³eœ coœ ukraœæ, ale kieszenie okaza³y siê puste");
    format(string, sizeof(string), "* %s grzeba³ po kieszeniach %s.", sendername ,giveplayer);
 		 ProxDetector(15.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
   }
	
	  PlayerInfo[playerid][pThiefInterval] = 2700;
	  return 1;
	 }
	 else
	 { 		
	  format(string, sizeof(string), "* %s grzeba³ po kieszeniach %s.", sendername ,giveplayer);
 		ProxDetector(15.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
 		PlayerInfo[playerid][pThiefInterval] = 1800;
 		
 		return 1;
	 }
 }
 #endif
 if (!strcmp(cmd, "/tel", true))
 {
  tmp = strtok(cmdtext, idx);
	 if(!strlen(tmp))
	 {
	 	SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /tel [NumerTelefonu]");
	 	return 1;
	 }
	 new tel = strval(tmp);
	 	
  if(PlayerInfo[playerid][pAdmin] > 0 && PlayerInfo[playerid][pAdmin] != 3)
  {
   for(new i = 0; i < MAX_PLAYERS; i++)
   {
    new gpitemindex = GetUsedItemByItemId(i, ITEM_CELLPHONE);
			
 			if(!CanItemBeUsed(gpitemindex))
 	 	{
	 	  continue;
		  }
			
  		new gpphonenumber = Items[gpitemindex][iAttr1];

    if(gpphonenumber == tel)
    {
     GetPlayerName(i, playername, sizeof(playername));
     format(string, sizeof(string), "Gracz (ID: %d): %s", i, playername);

     SendClientMessage(playerid, COLOR_GRAD1, string);
     return 1;
    }
   }
  }
 }
 if (!strcmp(cmd, "/alkomat", true))
 {
  if(IsACop(playerid))
  {
   tmp = strtok(cmdtext, idx);
	 	if(!strlen(tmp))
	 	{
	 		SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /alkomat [IdGracza/CzêœæNazwy]");
	 		return 1;
	 	}
	 	giveplayerid = ReturnUser(tmp);
	 	
   if (!IsPlayerConnected(giveplayerid))
	  {
	   SendClientMessage(playerid, COLOR_GRAD1, "Osoba niedostêpna.");
		 	return 1;
	  }

   if (GetDistanceBetweenPlayers(playerid,giveplayerid) > 3)
	  {
	   SendClientMessage(playerid, COLOR_GRAD1, "Nie ma takiej osoby w pobli¿u");
		 	return 1;
	  }
	
	  GetPlayerNameEx(playerid, sendername, sizeof(sendername));
   GetPlayerNameEx(giveplayerid, playername, sizeof(playername));

	  format(string, sizeof(string), "* %s podaje alkomat %s", sendername, playername);	
		 ProxDetector(10.0, giveplayerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		
   SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, "Aby zaakceptowaæ test alkoholowy wpisz /akceptuj alkomat");

   alkomatAccept[giveplayerid] = playerid;
  }
  else
  {
   SendClientMessage(playerid, COLOR_GRAD1, "Nie nale¿ysz do s³u¿b porz¹dkowych.");
  }
 }
 if (!strcmp(cmd, "/przebierz", true))
 {
  if(PlayerInfo[playerid][pMember] == 1 || PlayerInfo[playerid][pLeader] == 1 || PlayerInfo[playerid][pMember] == 2 || PlayerInfo[playerid][pLeader] == 2 || PlayerInfo[playerid][pMember] == 3 || PlayerInfo[playerid][pLeader] == 3 || PlayerInfo[playerid][pMember] == 10 || PlayerInfo[playerid][pLeader] == 10 || PlayerInfo[playerid][pMember] == 13 || PlayerInfo[playerid][pLeader] == 13 || PlayerInfo[playerid][pMember] == 8 || PlayerInfo[playerid][pLeader] == 8
   || PlayerInfo[playerid][pMember] == 12 || PlayerInfo[playerid][pLeader] == 12 || PlayerInfo[playerid][pMember] == 11 || PlayerInfo[playerid][pLeader] == 11 || PlayerInfo[playerid][pMember] == 4 || PlayerInfo[playerid][pLeader] == 4 || PlayerInfo[playerid][pMember] == 17 || PlayerInfo[playerid][pLeader] == 17 || PlayerInfo[playerid][pMember] == 9 || PlayerInfo[playerid][pLeader] == 9 || PlayerInfo[playerid][pMember] == 7 || PlayerInfo[playerid][pLeader] == 7
   || PlayerInfo[playerid][pMember] == 18 || PlayerInfo[playerid][pLeader] == 18)
  {

   if( ((PlayerInfo[playerid][pMember] == 1 || PlayerInfo[playerid][pLeader] == 1) && OnDuty[playerid] == 1) || ((PlayerInfo[playerid][pMember] == 2 || PlayerInfo[playerid][pLeader] == 2) && OnDuty[playerid] == 1) || ((PlayerInfo[playerid][pMember] == 3 || PlayerInfo[playerid][pLeader] == 3) && OnDuty[playerid] == 1)
    || (PlayerInfo[playerid][pMember] == 17 || PlayerInfo[playerid][pLeader] == 17) && academyTrening == 1 || ((PlayerInfo[playerid][pMember] == 9 || PlayerInfo[playerid][pLeader] == 9) && OnDuty[playerid] == 1) || ((PlayerInfo[playerid][pMember] == 7 || PlayerInfo[playerid][pLeader] == 7) && OnDuty[playerid] == 1) && ((PlayerInfo[playerid][pMember] == 18 || PlayerInfo[playerid][pLeader] == 18) && OnDuty[playerid] == 1))
   {
    SendClientMessage(playerid, COLOR_GRAD1, "Nie mo¿esz zmieniæ skina.");
    return 1;
   }

   tmp = strtok(cmdtext, idx);
		 if(!strlen(tmp))
		 {
		 	SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /przebierz [IdSkina] (wpisz 'brak', aby przywróciæ zwyk³y skin)");
		 	SendClientMessage(playerid, COLOR_GRAD1, "Dostêpne skiny: 7, 22, 23, 24, 29, 50, 66, 95, 117, 170, 180, 182");
		 	SendClientMessage(playerid, COLOR_GRAD1, "187, 188, 190, 193, 210, 217, 227, 249, 250, 185");
		 	return 1;
		 }
		
		 new sid = strval(tmp);
		
		 if(!strcmp(tmp, "brak", true))
		 {
   	SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
   	
		  return 1;
		 }
		 else if(!IsInvalidSkin(sid) && sid > -1 && sid < 300)
		 {
		  if(sid == 7 || sid == 22 || sid == 23 || sid == 24 || sid == 29 || sid == 50 || sid == 66 || sid == 95 || sid == 117 || sid == 170 || sid == 180 || sid == 182 || sid == 187 || sid == 188 || sid == 189 || sid == 190 || sid == 193 || sid == 210 || sid == 217 || sid == 227 || sid == 249 || sid == 250 || sid == 185)
		  {
		   SetPlayerSkin(playerid, sid);
		 	 return 1;
	 	 }
	 	 else if(sid == 179 && (PlayerInfo[playerid][pMember] == 3 || PlayerInfo[playerid][pLeader] == 3))
	 	 {
	 	  SetPlayerSkin(playerid, sid);
		 	 return 1;
	 	 }
	 	 else if((sid == 98 || sid == 102 || sid == 107 || sid == 108 || sid == 115 || sid == 123 || sid == 124 || sid == 286) && (PlayerInfo[playerid][pMember] == 8 || PlayerInfo[playerid][pLeader] == 8))
	 	 {
	 	  SetPlayerSkin(playerid, sid);
		 	 return 1;
	 	 }
	 	 else
	 	 {
	 	  SendClientMessage(playerid, COLOR_GRAD1, "Dostêpne skiny: 7, 21, 22, 23, 24, 29, 50, 66, 95, 117, 170, 180, 182");
		  	SendClientMessage(playerid, COLOR_GRAD1, "187, 188, 190, 193, 210, 217, 227, 249, 250");
	 	  return 1;
	 	 }
		 }
		
		 SendClientMessage(playerid, COLOR_GRAD1, "Niepoprawny ID skina");
  }
  else
  {
   SendClientMessage(playerid, COLOR_GRAD1, "Nie masz uprawnieñ.");
  }
 }
 if (!strcmp(cmd, "/mundur", true))
 {
  if(PlayerInfo[playerid][pMember] == 2 || PlayerInfo[playerid][pLeader] == 2)
  {
   tmp = strtok(cmdtext, idx);
		 if(!strlen(tmp))
		 {
		 	SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /mundur [IdSkina] (wpisz 'brak', aby przywróciæ zwyk³y skin)");
		 	SendClientMessage(playerid, COLOR_GRAD1, "Dostêpne skiny: 280, 265, 266, 267");
		 	return 1;
		 }
		
		 new sid = strval(tmp);
		
		 if(!strcmp(tmp, "brak", true))
		 {
		 	SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
   	
		  return 1;
		 }
		 else if(!IsInvalidSkin(sid) && sid > -1 && sid < 300)
		 {
		  if(sid == 280 || sid == 265 || sid == 266 || sid == 267)
		  {
		   SetPlayerSkin(playerid, sid);
		 	 return 1;
	 	 }
	 	 else
	 	 {
	 	  SendClientMessage(playerid, COLOR_GRAD1, "Dostêpne skiny: 280, 265, 266, 267");
	 	  return 1;
	 	 }
		 }
		
		 SendClientMessage(playerid, COLOR_GRAD1, "Niepoprawny ID skina");
  }
  else
  {
   SendClientMessage(playerid, COLOR_GRAD1, "Nie masz uprawnieñ.");
  }
 }
 /*if (!strcmp(cmd, "/respawnaut", true))
 {
  if(PlayerInfo[playerid][pAdmin] >= 3)
		{
   RespawnAllCars();
   SendClientMessage(playerid, COLOR_GREY, "Wszystkie auta zosta³y zespawnowane!");
   return 1;
  }
  else
  {
   SendClientMessage(playerid, COLOR_GRAD1, "Nie jesteœ uprawniony do u¿ycia tej komendy!");
			return 1;
  }
 }*/

 if (!strcmp(cmd, "/pokazdowod", true))
 {
  tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /pokazdowod [IdGracza/CzêœæNazwy]");
			return 1;
		}
		
		giveplayerid = ReturnUser(tmp);
		if(!IsPlayerConnected(giveplayerid))
  {
			SendClientMessage(playerid, COLOR_GRAD1, "Nie ma takiego gracza");
			return 1;
	 }
	
	 if (!DistanceBetweenPlayers(5.0, playerid, giveplayerid, true))
	 {
	  SendClientMessage(playerid, COLOR_GRAD1, "Nie ma takiego gracza w pobli¿u");
			return 1;
	 }
	
	 if(PlayerInfo[playerid][pIdCard] != 1)
	 {
	  SendClientMessage(playerid, COLOR_GRAD1, "Nie masz dowodu osobistego, mo¿esz go wyrobiæ u gubernatora.");
			return 1;
	 }
	
	 // zapisujemy potrzebne informacje do zmiennych
	 new sex[20]; if(PlayerInfo[playerid][pSex] == 1) { sex = "mê¿czyzna"; }	else if(PlayerInfo[playerid][pSex] == 2) { sex = "kobieta"; } // p³eæ
	 new married[20];	strmid(married, PlayerInfo[playerid][pMarriedTo], 0, strlen(PlayerInfo[playerid][pMarriedTo]), 255);                 // ma³¿eñstwo
	
	 GetPlayerName(playerid, playername, sizeof(playername));
	 new nameArray[2][MAX_PLAYER_NAME/2+1];
	 split(playername, nameArray, '_');
	
	 SendClientMessage(giveplayerid, COLOR_WHITE, "|___ Dowód osobisty ___|");
	 format(string, sizeof(string), "Imiê: [%s] Nazwisko: [%s]", nameArray[0], nameArray[1]);
	 SendClientMessage(giveplayerid, COLOR_GRAD1, string);
	 #if LEVEL_MODE
	 format(string, sizeof(string), "Poziom:[%d] P³eæ:[%s] Wiek:[%d]", PlayerInfo[playerid][pLevel], sex, PlayerInfo[playerid][pAge]);
	 #else
	 format(string, sizeof(string), "P³eæ:[%s] Wiek:[%d]", sex, PlayerInfo[playerid][pAge]);
	 #endif
	 SendClientMessage(giveplayerid, COLOR_GRAD1, string);
	 format(string, sizeof(string), "Ma³¿eñstwo:[%s]", married );
	 SendClientMessage(giveplayerid, COLOR_GRAD1, string);
	
	 // komunikaty
	 // nicki bierzemys
  GetPlayerNameMask(giveplayerid, giveplayer, sizeof(giveplayer));
		GetPlayerNameMask(playerid, sendername, sizeof(sendername));

  format(string, sizeof(string), "* Pokaza³a³eœ dowód osobity %s.", giveplayer);
		SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
	
 	format(string, sizeof(string), "* %s pokaza³ Ci swój dowód osobisty", sendername);
		SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
	
		format(string, sizeof(string), "pokaza³ %s dowód osobisty.", giveplayer);
		ServerMe(playerid, string);
 }
 if (!strcmp(cmd, "/dajdowod", true))
 {
  if(PlayerInfo[playerid][pLeader] != 7 && PlayerInfo[playerid][pMember] != 7)
  {
   SendClientMessage(playerid, COLOR_GRAD1, "Nie jesteœ pracownikiem urzêdu.");
			return 1;
  }

  if(PlayerInfo[playerid][pRank] < 1 || PlayerInfo[playerid][pRank] > 12)
	 {
	  SendClientMessage(playerid, COLOR_GREY, "Tylko rangi 1-12 mog¹ wydawaæ dowody!");
	  return 1;
	 }

  tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /dajdowod [IdGracza/CzêœæNazwy]");
			return 1;
		}
		giveplayerid = ReturnUser(tmp);
		if(!IsPlayerConnected(giveplayerid))
  {
			SendClientMessage(playerid, COLOR_GRAD1, "Nie ma takiego gracza");
			return 1;
	 }
	
	 if(PlayerInfo[giveplayerid][pIdCard] == 1)
	 {
	  SendClientMessage(playerid, COLOR_GRAD1, "Ta osoba ma ju¿ dowód osobisty.");
			return 1;
	 }
	
	 // nicki bierzemys
  GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
		GetPlayerNameEx(playerid, sendername, sizeof(sendername));

  format(string, sizeof(string), "* Da³eœ dowód osobisty %s.", giveplayer);
		SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
	
 	format(string, sizeof(string), "* Dosta³eœ dowód osobisty od %s.", sendername);
		SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
	
		format(string, sizeof(string), "* Urzêdnik %s da³ dowód %s.", sendername ,giveplayer);
		ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);		
		
	 PlayerInfo[giveplayerid][pIdCard] = 1;
 }
 if (!strcmp(cmd, "/wepchnij", true))
 {
  tmp = strtok(cmdtext, idx);
  if (!strlen(tmp))
   return SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /wepchnij [IdGracza/CzêœæNazwy] [miejsce 2-4]");

  new person = strval(tmp);
  tmp = strtok(cmdtext, idx);

  if (!strlen(tmp))
   return SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /wepchnij [IdGracza/CzêœæNazwy] [miejsce 2-4]");

  if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
   return SendClientMessage(playerid, COLOR_GRAD1, "Musisz byæ w pojeŸdzie.");

  if(!IsACop(playerid) && PlayerInfo[person][pWounded] == 0)
   return SendClientMessage(playerid, COLOR_GRAD1, "Nie nale¿ysz do s³u¿b porz¹dkowych, ani nie chcesz podnieœæ rannej osoby.");

  if (GetDistanceBetweenPlayers(playerid,person) > 5)
   return SendClientMessage(playerid, COLOR_GRAD1, "Nie ma takiej osoby w pobli¿u.");

  if (IsPlayerInAnyVehicle(person))
  {
   if(IsACop(playerid) && PlayerInfo[person][pWounded] == 0)
   {
    return SendClientMessage(playerid, COLOR_GRAD1, "Podejrzany nie mo¿e byæ w pojeŸdzie.");
   }
   else
   {
    return SendClientMessage(playerid, COLOR_GRAD1, "Ranna osoba jest ju¿ w innym pojeŸdzie.");
   }
  }
	
	if(IsPlayerAFK(person))
	{
		return SendClientMessage(playerid, COLOR_GRAD1, "Ta osoba jest niedostêpna.");
	}

  new seat = strval(tmp);
  new Float:pos[6];
  GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
  GetPlayerPos(playerid, pos[3], pos[4], pos[5]);
  if (floatcmp(floatabs(floatsub(pos[0], pos[3])), 10.0) != -1 &&
  floatcmp(floatabs(floatsub(pos[1], pos[4])), 10.0) != -1 &&
  floatcmp(floatabs(floatsub(pos[2], pos[5])), 10.0) != -1) return false;
  PutPlayerInVehicle(person, GetPlayerVehicleID(playerid), seat);
  // zakuwamy
  TogglePlayerControllable(person, 0);
  if(PlayerInfo[person][pWounded] == 0)
  {
   PlayerCuffed[person] = 2;
		 PlayerCuffedTime[person] = 300;
		 GameTextForPlayer(person, "~r~Zakuty", 2500, 3);
	 }
	 else
	 {
	  SetCameraBehindPlayer(person);
	 }
	
		// nicki bierzemy
  GetPlayerNameMask(person, giveplayer, sizeof(giveplayer));
		GetPlayerNameMask(playerid, sendername, sizeof(sendername));
		// informacje
		if(IsACop(playerid) && PlayerInfo[person][pWounded] == 0)
  {
   format(string, sizeof(string), "* Zosta³eœ wrzucony do pojazdu i zakuty przez %s.", sendername);
  }
  else
  {
   format(string, sizeof(string), "* Zosta³eœ wrzucony do pojazdu %s.", sendername);
  }

		SendClientMessage(person, COLOR_LIGHTBLUE, string);
	
	 if(IsACop(playerid) && PlayerInfo[person][pWounded] == 0)
  {
 	 format(string, sizeof(string), "* Wrzuci³eœ do pojazdu i zaku³eœ %s.", giveplayer);
	 }
	 else
	 {
 	 format(string, sizeof(string), "* Wrzuci³eœ do pojazdu %s.", giveplayer);
	 }
	
		SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
	
	 if(IsACop(playerid) && PlayerInfo[person][pWounded] == 0)
  {
		 format(string, sizeof(string), "* %s wrzuci³ do pojazdu i zaku³ rêce %s.", sendername ,giveplayer);
	 }
	 else
	 {
	  format(string, sizeof(string), "* %s wrzuci³ %s do pojazdu.", sendername ,giveplayer);
	 }
	
		ProxDetector(20.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);		
  return 1;
 }
 if (strcmp(cmd, "/pobierz", true) == 0)
 {
  if(IsPlayerConnected(playerid))
  {
 	 for(new j = 0; j < sizeof(gAtm); j++)
			{
			 if(PlayerToPoint(5.0, playerid, gAtm[j][pX], gAtm[j][pY], gAtm[j][pZ]))
			 {
			 tmp = strtok(cmdtext, idx);
			 if(!strlen(tmp))
			 {
			 	SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /pobierz [kwota]");
			 	return 1;
			 }

			 if(gAtmTimer[playerid] > 0)
			 {
			  SendClientMessage(playerid, COLOR_GRAD1, "Mo¿esz skorzystaæ z bankomatu tylko raz na 15 minut.");
			  return 1;
			 }
			
    new money = strval(tmp); // kasa z komendy
			
    if(money < 0)
			 {
			 	SendClientMessage(playerid, COLOR_GRAD1, "Zbyt ma³o.");
			 	return 1;
			 }
			 else if(money > 5000)
			 {
			  SendClientMessage(playerid, COLOR_GRAD1, "Nie mo¿esz wyp³aciæ wiêcej ni¿ $5000 za jednym razem.");
			 	return 1;
			 }
			
			 if(money > PlayerInfo[playerid][pAccount])
			 {
			  SendClientMessage(playerid, COLOR_GRAD1, "Nie masz tylu pieniêdzy na koncie");
			  return 1;
			 }
			
    if((gAtm[j][atmAmount] - money) < 0)
			 {
			 	SendClientMessage(playerid, COLOR_GRAD1, "Nie ma tylu pieniêdzy w bankomacie.");
			 	return 1;
			 }

    gAtm[j][atmAmount]             -= money;  // zabieramy kase z bankomatu
    PlayerInfo[playerid][pAccount] -= money;  // zabieramy kase z konta
    //PlayerInfo[playerid][pAccount]=PlayerInfo[playerid][pAccount]-money;
			 GivePlayerMoneyEx(playerid, money);         // dajemy kase graczowi
			 gAtmTimer[playerid]             = 900;    // interwal czasowy
			 gAtmTimer[playerid]             = 900;    // interwal czasowy
			 format(string, sizeof(string), "Wyp³aci³eœ $%d. Stan Twojego konta: $%d", money, PlayerInfo[playerid][pAccount]);
	   SendClientMessage(playerid, COLOR_YELLOW, string);
	
	   ApplyAnimation(playerid, "ped", "ATM", 4.000000, 0, 1, 1, 0, -1); // /ATM
			 }
			}	
 	}
 }

	/*if (strcmp(cmd, "/brama", true) == 0)
	{
  if(IsPlayerConnected(playerid))
	 {

	  if(IsACop(playerid) || PlayerInfo[playerid][pMember] == 2 || PlayerInfo[playerid][pLeader] == 2 || PlayerInfo[playerid][pAdmin] == 1337)
	  {
	   if(PlayerToPoint(15.0, playerid, 1544.7006, -1630.9094, 13.2091))
	   {
	    if(gateParkingPoliceState == 1)
	    {
	     //SetObjectPos(gateParkingPolice, 1544.6995, -1630.7721, 11.4262);
	     //SetObjectRot(gateParkingPolice, 0, 0, 270);
	     MoveDynamicObject(gateParkingPolice, 1544.6842, -1630.7721, 13.0421, 2.5);
	     MoveObjectRotation(gateParkingPolice, 0, 360, 270, 2.0, 10, 0);
	     gateParkingPoliceState = 0;
	    }
	    else
	    {
	     //SetObjectPos(gateParkingPolice, 1544.6842, -1630.9032, 13.0421);
	     //SetObjectRot(gateParkingPolice, 0, 269.7592, 270);
	     MoveDynamicObject(gateParkingPolice, 1544.6842, -1630.9032, 13.0421, 2);
	     MoveObjectRotation(gateParkingPolice, 0, 269.7592, 270, 2.0, 10, 0);
      gateParkingPoliceState = 1;
	    }
	   }
	  }
				
		if(GetPlayerOrganization(playerid) == 1 || PlayerInfo[playerid][pAdmin] == 1337)
	  {
			if(PlayerToPoint(12.5, playerid, 1314.3499755859, 723.38000488281, 11.570300102234))
			{
				if(gatePrisonState == 1)
				{
					MoveDynamicObject(gatePrison, 1314.349609375, 731, 11.570300102234, 1.5);
					
					gatePrisonState = 0;
				}
				else
				{
				  
					MoveDynamicObject(gatePrison, 1314.3499755859, 723.38000488281, 11.570300102234, 1.5);
					gatePrisonState = 1;
				}
				PlayerPlaySoundForAll_Object(1035, 1036, gatePrisonState, 314.349609375, 731, 11.570300102234);
			}
		}

	  if(IsACop(playerid) || PlayerInfo[playerid][pAdmin] == 1337)
	  {
				if(PlayerToPoint(10.0, playerid, 1587.9784, -1637.8776, 13.4169))
				{
		   if(gatePoliceState == 1)
		   {
			 		//1587.9801,-1638.4778,13.3633
						MoveDynamicObject(gatePoliceA, 1577.5000, -1638.0895, 14.9000, 1.5);
						gatePoliceState = 0;
					}
					else
					{
						MoveDynamicObject(gatePoliceA, 1587.6304, -1638.0895, 14.9000, 1.5);
		  		gatePoliceState = 1;
					}
					PlayerPlaySoundForAll_Object(1035, 1036, gatePoliceA, 1587.9784, -1637.8776, 13.4169);
				}
			}
			if(PlayerInfo[playerid][pMember] == 11 || PlayerInfo[playerid][pLeader] == 11 || PlayerInfo[playerid][pAdmin] == 1337)
			{
				if(PlayerToPoint(10.0, playerid, 377.1481,173.8150,1008.3828))
				{
				 if(gateDmvState == 1)
				 {
				  MoveObject(gateDmv, 377.6370,169.6422,1010.2500, 1.5);
						gateDmvState = 0;
				 }
				 else
				 {
				  MoveObject(gateDmv, 377.6370,169.6422,1007.5000, 1.5);
						gateDmvState = 1;
				 }
				 PlayerPlaySoundForAll_Object(1035, 1036, gateDmv, 377.6370,169.6422,1010.2500);
				}
			}
	 //}
	 
		if(GetPlayerOrganization(playerid)==3 || PlayerInfo[playerid][pAdmin] == 1337) //granica zewnêtrzna
	  {
	   if(PlayerToPoint(2.5, playerid, 427,606.9,18.5))
	   {
	    if(gateBorderOutState == 1)
	    {
	     //SetObjectPos(gateParkingPolice, 1544.6995, -1630.7721, 11.4262);
	     //SetObjectRot(gateParkingPolice, 0, 0, 270);
	     //MoveDynamicObject(gateBorderOut, 1544.6842, -1630.7721, 13.0421, 2.5);
	     MoveObjectRotation(gateBorderOut, 0, 310, 214.29504394531, 2.0, 10, 0);
	     gateBorderOutState = 0;
	    }
	    else
	    {
	     //SetObjectPos(gateParkingPolice, 1544.6842, -1630.9032, 13.0421);
	     //SetObjectRot(gateParkingPolice, 0, 269.7592, 270);
	     //MoveDynamicObject(gateBorderOut, 1544.6842, -1630.9032, 13.0421, 2);
	     MoveObjectRotation(gateBorderOut, 0, 270, 214.29504394531, 2.0, 10, 0);
			 gateBorderOutState = 1;
	    }
	   }
		 
		 if(PlayerToPoint(2.5, playerid, 420,616,18.5))
	   {
	    if(gateBorderInState == 1)
	    {
	     //SetObjectPos(gateParkingPolice, 1544.6995, -1630.7721, 11.4262);
	     //SetObjectRot(gateParkingPolice, 0, 0, 270);
	     //MoveDynamicObject(gateBorderOut, 1544.6842, -1630.7721, 13.0421, 2.5);
	     MoveObjectRotation(gateBorderIn, 0, 310, 35.285308837891, 2.0, 10, 0);
	     gateBorderInState = 0;
	    }
	    else
	    {
	     //SetObjectPos(gateParkingPolice, 1544.6842, -1630.9032, 13.0421);
	     //SetObjectRot(gateParkingPolice, 0, 269.7592, 270);
	     //MoveDynamicObject(gateBorderOut, 1544.6842, -1630.9032, 13.0421, 2);
	     MoveObjectRotation(gateBorderIn, 0, 270, 35.285308837891, 2.0, 10, 0);
			 gateBorderInState = 1;
	    }
	   }
	  }
		
		if(GetPlayerOrganization(playerid)==3 || PlayerInfo[playerid][pAdmin] == 1337)
		{
			if (PlayerToPoint(7.0, playerid, 411.65646362305, 625.54577636719, 20.010507583618))//wewnêtrzna
			{
				if (gateBorderInState == 1)
				{
					MoveDynamicObject(gateBorderIn_new, 420.91635131836, 631.53814697266, 20.010507583618, 1.5);
					gateBorderInState = 0;
				}
				else if (gateBorderInState == 0)
				{
					MoveDynamicObject(gateBorderIn_new, 411.65646362305, 625.54577636719, 20.010507583618, 1.5);
					gateBorderInState = 1;
				}	
			}
			
			if (PlayerToPoint(7.0, playerid, 429.54339599609, 603.01300048828, 20.895345687866))//zewnêtrzna
			{
				if (gateBorderOutState == 1)
				{
					MoveDynamicObject(gateBorderOut_new, 438.43872070313, 609.443359375, 20.895345687866, 1.5);
					gateBorderOutState = 0;
				}
				else if (gateBorderOutState == 0)
				{
					MoveDynamicObject(gateBorderOut_new, 429.54339599609, 603.01300048828, 20.895345687866, 1.5);
					gateBorderOutState = 1;
				}	
			}
		
		
		}
	}*/
//-------------------------------[Pay]--------------------------------------------------------------------------
	if(strcmp(cmd, "/charity", true) == 0 || strcmp(cmd, "/dotacja", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /dotacja [iloœæ]");
				return 1;
			}
			if(PlayerInfo[playerid][pLocal] == 106)
			{
				SendClientMessage(playerid, COLOR_GRAD1, "Komenda niedostêpna w tej lokacji");
				return 1;
			}
			moneys = strval(tmp);
			if(moneys < 1)
			{
				SendClientMessage(playerid, COLOR_GRAD1, "Zbyt ma³o.");
				return 1;
			}
			if(GetPlayerMoneyEx(playerid) < moneys)
			{
			    SendClientMessage(playerid, COLOR_GRAD1, "Nie masz tyle pieniêdzy.");
				return 1;
			}
			Tax += moneys;
			
			//GivePlayerMoneyEx(playerid, -moneys);
			PlayerInfo[playerid][pAccount] -= moneys;
			GetPlayerNameEx(playerid, sendername, sizeof(sendername));
			format(string, sizeof(string), "%s, dziêkujemy za Twoj¹ dotacjê w wysokoœci $%d.",sendername, moneys);
			printf("%s", string);
			PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
			SendClientMessage(playerid, COLOR_GRAD1, string);
			PayLog(string);
		}
		return 1;
	}
//-------------------------------[Stats]--------------------------------------------------------------------------
	if (strcmp(cmd, "/stats", true) == 0 || strcmp(cmd, "/statystyki", true) == 0 || strcmp(cmd, "/staty", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
			if (gPlayerLogged[playerid] != 0)
			{
				ShowStats(playerid,playerid,0);
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   Nie jesteœ zalogowany !");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/dn", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			if (PlayerInfo[playerid][pAdmin] >= 1)
			{
				new Float:slx, Float:sly, Float:slz;
				GetPlayerPos(playerid, slx, sly, slz);
				SetPlayerPosEx(playerid, slx, sly, slz-2);
				return 1;
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   Nie jesteœ administratorem !");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/up", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			if (PlayerInfo[playerid][pAdmin] >= 1)
			{
				new Float:slx, Float:sly, Float:slz;
				GetPlayerPos(playerid, slx, sly, slz);
				SetPlayerPosEx(playerid, slx, sly, slz+2);
				return 1;
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   Nie jesteœ administratorem !");
			}
		}
		return 1;
	}
	if (strcmp(cmd, "/fly", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			if (PlayerInfo[playerid][pAdmin] >= 1)
			{
				new Float:px, Float:py, Float:pz, Float:pa;
				GetPlayerFacingAngle(playerid,pa);
				if(pa >= 0.0 && pa <= 22.5) //n1
				{
					GetPlayerPos(playerid, px, py, pz);
					SetPlayerPosEx(playerid, px, py+30, pz+5);
				}
				if(pa >= 332.5 && pa < 0.0) //n2
				{
					GetPlayerPos(playerid, px, py, pz);
					SetPlayerPosEx(playerid, px, py+30, pz+5);
				}
				if(pa >= 22.5 && pa <= 67.5) //nw
				{
					GetPlayerPos(playerid, px, py, pz);
					SetPlayerPosEx(playerid, px-15, py+15, pz+5);
				}
				if(pa >= 67.5 && pa <= 112.5) //w
				{
					GetPlayerPos(playerid, px, py, pz);
					SetPlayerPosEx(playerid, px-30, py, pz+5);
				}
				if(pa >= 112.5 && pa <= 157.5) //sw
				{
					GetPlayerPos(playerid, px, py, pz);
					SetPlayerPosEx(playerid, px-15, py-15, pz+5);
				}
				if(pa >= 157.5 && pa <= 202.5) //s
				{
					GetPlayerPos(playerid, px, py, pz);
					SetPlayerPosEx(playerid, px, py-30, pz+5);
				}
				if(pa >= 202.5 && pa <= 247.5)//se
				{
					GetPlayerPos(playerid, px, py, pz);
					SetPlayerPosEx(playerid, px+15, py-15, pz+5);
				}
				if(pa >= 247.5 && pa <= 292.5)//e
				{
					GetPlayerPos(playerid, px, py, pz);
					SetPlayerPosEx(playerid, px+30, py, pz+5);
				}
				if(pa >= 292.5 && pa <= 332.5)//e
				{
					GetPlayerPos(playerid, px, py, pz);
					SetPlayerPosEx(playerid, px+15, py+15, pz+5);
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   Nie jesteœ administratorem !");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/lt", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			if (PlayerInfo[playerid][pAdmin] >= 1)
			{
				new Float:slx, Float:sly, Float:slz;
				GetPlayerPos(playerid, slx, sly, slz);
				SetPlayerPosEx(playerid, slx, sly+2, slz);
				return 1;
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   Nie jesteœ administratorem !");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/rt", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			if (PlayerInfo[playerid][pAdmin] >= 1)
			{
				new Float:slx, Float:sly, Float:slz;
				GetPlayerPos(playerid, slx, sly, slz);
				SetPlayerPosEx(playerid, slx, sly-2, slz);
				return 1;
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   Nie jesteœ administratorem !");
			}
		}
		return 1;
	}
	
	
//-------------------------------[Check]--------------------------------------------------------------------------
	
	#if DEBUG
	if (strcmp(cmd, "/testtesttest", true) == 0)
	{
	 for(new i = 0; i < MAX_VEHICLES; i++)
	 {
	  SetVehicleHealthEx(i, 0.0);
	  new Float:pppX, Float:pppY, Float:pppZ;
   GetVehiclePos(i, pppX, pppY, pppZ);
	  CreateExplosion(pppX, pppZ, pppY, 6, 100);
	  CreateExplosion(pppX-2, pppZ+1, pppY-1, 6, 100);
	  CreateExplosion(pppX+2, pppZ-1, pppY+1, 6, 100);
	 }
	}
	if (strcmp(cmd, "/test", true) == 0)
	{
	 new i = playerid;
	 format(string, sizeof(string), "* UFLeader: %d, UFMember: %d, Interior: %d, IsPlayerSafe: %d, gPlayerSpawned: %d, Logged: %d, VW: %d", PlayerInfo[i][pUFLeader], PlayerInfo[i][pUFMember], GetPlayerInterior(i), IsPlayerSafe[i], gPlayerSpawned[i], gPlayerLogged[i], GetPlayerVirtualWorld(i));
	 SendClientMessage(playerid, COLOR_RED, string);
	 return 1;
	}
	if (strcmp(cmd, "/test2", true) == 0)
	{
	 SpawnPlayer(playerid);
	 return 1;
	}
	#endif
	if (strcmp(cmd, "/getdistance", true) == 0)
	{
	 tmp = strtok(cmdtext, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /getdistance [IdGracza/CzêœæNazwy]");
			return 1;
		}
		giveplayerid = ReturnUser(tmp);
		
	 format(string, sizeof(string), "* Odleg³oœæ: %f", GetDistanceBetweenPlayers(playerid,giveplayerid));
	 SendClientMessage(playerid, COLOR_RED, string);
	 return 1;
	}
	if (strcmp(cmd, "/numer", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
			if (HasPlayerItemByType(playerid, ITEM_PHONEBOOK))
			{
				tmp = strtok(cmdtext, idx);
				if(!strlen(tmp))
				{
					SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /numer [IdGracza/CzêœæNazwy]");
					return 1;
				}
				//giveplayerid = strval(tmp);
				giveplayerid = ReturnUser(tmp);
				if(IsPlayerConnected(giveplayerid))
				{
				 if(giveplayerid != INVALID_PLAYER_ID)
				 {
				  new gpitemindex = GetUsedItemByItemId(giveplayerid, ITEM_CELLPHONE);
			
  			 if(!CanItemBeUsed(gpitemindex))
	 	 	 {
		 	   format(string, 256, "Nie posiadamy numeru tej osoby.");
		 	   SendClientMessage(playerid, COLOR_GRAD1, string);
		 	   return 1;
			   }
			
    		new gpphonenumber = Items[gpitemindex][iAttr1];
   		
				  if(PlayerInfo[giveplayerid][pReservedPhone] == 0)
				  {
						 GetPlayerName(giveplayerid, sendername, sizeof(sendername));
						 format(string, 256, "Nick: %s, Telefon: %d",sendername, gpphonenumber);
					 }
					 else
					 {
					  format(string, 256, "Nie posiadamy numeru tej osoby.");
					 }
					
						SendClientMessage(playerid, COLOR_GRAD1, string);
					}
				}
				else
				{
					SendClientMessage(playerid, COLOR_GRAD1, "   Nie ma takiego gracza !");
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   Nie masz ksi¹¿ki telefonicznej !");
			}
		}
		return 1;
	}
//-------------------------------[BuyLevel]--------------------------------------------------------------------------
 /*#if LEVEL_MODE
	if (strcmp(cmd, "/buylevel", true) == 0 || strcmp(cmd, "/kuppoziom", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			if (gPlayerLogged[playerid] != 0)
			{
				PlayerInfo[playerid][pCash] = GetPlayerMoneyEx(playerid);
				if(PlayerInfo[playerid][pLevel] >= 0)
				{
					new nxtlevel = PlayerInfo[playerid][pLevel]+1;
					new costlevel = nxtlevel*levelcost;//10k for testing purposes
					new expamount = nxtlevel*levelexp;
					new infostring[256];
					if(GetPlayerMoneyEx(playerid) < costlevel)
					{
						format(infostring, 256, "   Nie masz wystarczaj¹cej iloœci pieniêdzy ($%d) !",costlevel);
						SendClientMessage(playerid, COLOR_GRAD1, infostring);
						return 1;
					}
					else if (PlayerInfo[playerid][pExp] < expamount)
					{
						format(infostring, 256, "   Potrzebujesz %d punktów respektu, aktualnie posiadasz [%d] !",expamount,PlayerInfo[playerid][pExp]);
						SendClientMessage(playerid, COLOR_GRAD1, infostring);
						return 1;
					}
					else
					{
						format(string, sizeof(string), "~g~Poziom ZWIEKSZONY~n~~w~Twój nowy poziom to %d", nxtlevel);
						PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
						PlayerPlayMusic(playerid);
						GivePlayerMoneyEx(playerid, (-costlevel));
						PlayerInfo[playerid][pLevel]++;
						if(PlayerInfo[playerid][pDonateRank] > 0)
						{
						    PlayerInfo[playerid][pExp] -= expamount;
						    new total = PlayerInfo[playerid][pExp];
						    if(total > 0)
						    {
						        PlayerInfo[playerid][pExp] = total;
						    }
						    else
						    {
						        PlayerInfo[playerid][pExp] = 0;
						    }
						}
						else
						{
							PlayerInfo[playerid][pExp] = 0;
						}
						PlayerInfo[playerid][gPupgrade] = PlayerInfo[playerid][gPupgrade]+2;
						GameTextForPlayer(playerid, string, 5000, 1);
						format(infostring, 256, "   Kupi³eœ nowy poziom: %d. Wpisz /ulepszenia", nxtlevel, costlevel);
						SendClientMessage(playerid, COLOR_GRAD1, infostring);
						format(infostring, 256, "   Posiadasz %d niewykorzystanych punktów Ulepszenia",PlayerInfo[playerid][gPupgrade]);
						SendClientMessage(playerid, COLOR_GRAD2, infostring);
					}
				}
				return 1;
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   Nie jesteœ zalogowany !");
			}
		}
		return 1;
	}
	#endif*/
//-------------------------------[UPGRADE]--------------------------------------------------------------------------
 /*if(strcmp(cmd, "/przydzielbiznes", true) == 0)
	{
	 if(PlayerInfo[playerid][pAdmin] != 1337)
	 {
	  SendClientMessage(playerid, COLOR_GRAD1, "Nie masz odpowiednich uprawnieñ.");
	  return 1;
	 }
	
	 tmp = strtok(cmdtext, idx);
	
	 if(!strlen(tmp))
	 {
	  SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /przydzielbiznes [IdBiznesu] [IdGracza/CzêœæNazwy]");
	  return 1;
  }
	
	 new b = strval(tmp);
	
	 tmp = strtok(cmdtext, idx);
	
	 if(!strlen(tmp))
	 {
	  SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /przydzielbiznes [IdBiznesu] [IdGracza/CzêœæNazwy]");
	  return 1;
  }
	
	 new userid = ReturnUser(tmp);
	
	 if(!IsPlayerConnected(userid))
	 {
	  SendClientMessage(playerid, COLOR_GRAD1, "Ta osoba jest niedostêpna.");
	  return 1;
	 }

		PlayerInfo[userid][pPbiskey] = b;
		BizzInfo[b][bOwned] = 1;
		GetPlayerName(playerid, playername, sizeof(playername));
		GetPlayerName(userid, sendername, sizeof(sendername));
		BizzInfo[b][bOwner] = PlayerInfo[userid][pId];
		PlayerPlayMusic(userid);
		SetPlayerInterior(userid,BizzInfo[b][bInterior]);
		PlayerInfo[userid][pInt] = BizzInfo[b][bInterior];
		SetPlayerPosEx(userid,BizzInfo[b][bExitX],BizzInfo[b][bExitY],BizzInfo[b][bExitZ]);
		GameTextForPlayer(userid, "~w~Witaj~n~Mozesz wyjsc z tego miejsca, podchodzac do drzwi i wpisujac /wyjdz", 5000, 3);
		PlayerInfo[userid][pInt] = BizzInfo[b][bInterior];
		PlayerInfo[userid][pLocal] = b ;
		SendClientMessage(userid, COLOR_WHITE, "Gratulacje! Kupiles udzialy w firmie!.");
	 SendClientMessage(userid, COLOR_WHITE, "Wpisz /pomoc aby zobaczyc dostpne komendy.");
  DateProp(userid);
		OnBusinessUpdate(b);
 	OnPlayerSave(userid);

		printf("ADMIN: %s przydzieli³ biznes %d graczowi %s", playername, b, sendername);
		
		SendClientMessage(playerid, COLOR_WHITE, "Biznes zosta³ przydzielony.");
		return 1;
	}*/
 /*if(strcmp(cmd, "/przydzieldom", true) == 0)
	{
	 if(PlayerInfo[playerid][pAdmin] != 1337)
	 {
	  SendClientMessage(playerid, COLOR_GRAD1, "Nie masz odpowiednich uprawnieñ.");
	  return 1;
	 }
	
	 tmp = strtok(cmdtext, idx);
	
	 if(!strlen(tmp))
	 {
	  SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /przydzieldom [IdDomu] [IdGracza/CzêœæNazwy]");
	  return 1;
  }
	
	 new houseid = strval(tmp);
	
	 tmp = strtok(cmdtext, idx);
	
	 if(!strlen(tmp))
	 {
	  SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /przydzieldom [IdDomu] [IdGracza/CzêœæNazwy]");
	  return 1;
  }
	
	 new userid = ReturnUser(tmp);
	
	 if(!IsPlayerConnected(userid))
	 {
	  SendClientMessage(playerid, COLOR_GRAD1, "Ta osoba jest niedostêpna.");
	  return 1;
	 }
	
	 GetPlayerName(userid, playername, sizeof(playername));
	 GetPlayerName(playerid, sendername, sizeof(sendername));
		PlayerInfo[userid][pPhousekey] = houseid;
		HouseInfo[houseid][hOwned]     = 1;
		HouseInfo[houseid][hOwner] = PlayerInfo[userid][pId];
		SetPlayerInterior(userid,HouseInfo[houseid][hInt]);
		SetPlayerVirtualWorldEx(userid,HouseInfo[houseid][hVW]);
		SetPlayerPosEx(userid,HouseInfo[houseid][hExitx],HouseInfo[houseid][hExity],HouseInfo[houseid][hExitz]);
		GameTextForPlayer(userid, "~w~Witaj w domu~n~Mozesz stad wyjsc podchodzac do drzwi i wpisujac /wyjdz", 5000, 3);
		PlayerInfo[userid][pInt]       = HouseInfo[houseid][hInt];
		PlayerInfo[userid][pLocal]     = houseid;
		SendClientMessage(userid, COLOR_WHITE, "Gratulujemy udanego zakupu !");
		SendClientMessage(userid, COLOR_WHITE, "Wpisz /pomoc aby zobaczyæ wszystkie dostêpne komendy !");
  DateProp(userid);
		//OnHouseUpdate(houseid);
		OnPlayerSave(userid);
		
		printf("ADMIN: %s przydzieli³ dom %d graczowi %s", sendername, houseid, playername);
		
		SendClientMessage(playerid, COLOR_WHITE, "Dom zosta³ przydzielony.");
	}*/
	/*#if DEBUG
	if(strcmp(cmd, "/dodajdom", true) == 0)
	{
	 tmp = strtok(cmdtext, idx);
	 new houseid = strval(tmp);
	 new File:file2;
	
	 new coordsstring[256];
	
	 new Float:hex, Float:hey, Float:hez;
	 GetPlayerPos(playerid, hex, hey, hez);
	
	 format(coordsstring, sizeof(coordsstring), "%f,%f,%f,%f,%f,%f,%d,%s,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n",
		 hex, hey, hez,
		 HouseInfo[houseid][hExitx],
		 HouseInfo[houseid][hExity],
		 HouseInfo[houseid][hExitz],
		 HouseInfo[houseid][hOwner],
		 HouseInfo[houseid][hDiscription],
		 HouseInfo[houseid][hHel],
		 HouseInfo[houseid][hArm],
		 HouseInfo[houseid][hInt],
		 HouseInfo[houseid][hLock],
		 HouseInfo[houseid][hOwned],
		 HouseInfo[houseid][hRent],
		 HouseInfo[houseid][hRentabil],
		 HouseInfo[houseid][hTakings],
		 HouseInfo[houseid][hDate],
   HouseInfo[houseid][hRubbish],
   HouseInfo[houseid][hVW]
  );
		
		file2 = fopen("houses_new.cfg", io_append);
		
		fwrite(file2, coordsstring);
		fclose(file2);
	}
	#endif*/
    if(strcmp(cmd, "/toglsn", true) == 0 || strcmp(cmd, "/ukryjlsn", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
     {
			if (!HideLSN[playerid])
			{
				HideLSN[playerid] = 1;
				TextDrawHideForPlayer(playerid, SanNews);
				SendClientMessage(playerid, COLOR_GRAD2, "Wyœwietlanie LSN zablokowane!");
			}
			else if (HideLSN[playerid])
			{
				HideLSN[playerid] = 0;
				TextDrawShowForPlayer(playerid, SanNews);
				SendClientMessage(playerid, COLOR_GRAD2, "Wyœwietlanie LSN odblokowane!");
			}
		}
		return 1;
	}

	if(strcmp(cmd, "/togwhisper", true) == 0 || strcmp(cmd, "/blokujpm", true) == 0 || strcmp(cmd, "/togw", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
  {
			if (!HidePM[playerid])
			{
				HidePM[playerid] = 1;
				SendClientMessage(playerid, COLOR_GRAD2, "Wiadomoœci prywatne zablokowane!");
			}
			else if (HidePM[playerid])
			{
				HidePM[playerid] = 0;
				SendClientMessage(playerid, COLOR_GRAD2, "Wiadomoœci prywatne odblokowane!");
			}
		}
		return 1;
	}
	    
	    if(strcmp(cmd, "/t", true) == 0 || strcmp(cmd, "/telefon", true) == 0)
		{
			new itemindex = GetUsedItemByItemId(playerid, ITEM_CELLPHONE);
			new str[32];
	 		if(IsPlayerConnected(playerid))
     		{
				switch(itemindex)
	  			{
	   				case INVALID_ITEM_ID:
	   				{
	    					SendClientMessage(playerid, COLOR_GREY, "Nie posiadasz telefonu komórkowego.");
 	  						return 1;
	   				}
	   			
	   				case HAS_UNUSED_ITEM_ID:
	   				{
	    					SendClientMessage(playerid, COLOR_GREY, "Twój telefon jest wy³¹czony. Aby go w³¹czyæ, u¿yj /przedmioty uzyj [IdPrzedmiotu].");
 	  						return 1;
	   				}
	  			}
	  			
				if(PlayerInfo[playerid][pJailTime] > 0)
				{
			 			SendClientMessage(playerid, COLOR_GRAD2, "Twój telefon zosta³ skonfiskowany na czas pobytu w wiêzieniu.");
						return 1;
				}
                if(PlayerInfo[playerid][pTextureIphone] == 1)
                {
					if(!CellularPhone[playerid])
					{
						CellularPhone[playerid] = 1;
						TextDrawShowForPlayer(playerid, txtSprite1);
						format(str, sizeof(str), "wyci¹ga telefon.");
 						ServerMe(playerid, str);
					}
					else if(CellularPhone[playerid])
					{
     					CellularPhone[playerid] = 0;
     					TextDrawHideForPlayer(playerid, txtSprite1);
						format(str, sizeof(str), "chowa telefon.");
 						ServerMe(playerid, str);

					}
				}
				else if(PlayerInfo[playerid][pTextureIphone] == 0)
				{
				    if(!CellularPhone[playerid])
					{
						CellularPhone[playerid] = 1;
						TextDrawShowForPlayer(playerid, p3);
						TextDrawShowForPlayer(playerid, p4);
						TextDrawShowForPlayer(playerid, p5);
						format(str, sizeof(str), "wyci¹ga telefon.");
 						ServerMe(playerid, str);
					}
					else if(CellularPhone[playerid])
					{
     					CellularPhone[playerid] = 0;
						TextDrawHideForPlayer(playerid, p3);
						TextDrawHideForPlayer(playerid, p4);
						TextDrawHideForPlayer(playerid, p5);
						format(str, sizeof(str), "chowa telefon.");
 						ServerMe(playerid, str);

					}
				}
			}
		  	return 1;
		}
	if(strcmp(cmd, "/iphone", true) == 0 || strcmp(cmd, "/ehe", true) == 0)
	{
	 	if(IsPlayerConnected(playerid))
  		{
			if (PlayerInfo[playerid][pTextureIphone] == 1)
			{
				PlayerInfo[playerid][pTextureIphone] = 0;
				ShowPlayerDialog(playerid, DIALOG_INFO_IPHONE, DIALOG_STYLE_MSGBOX, "Wyœwietlanie textury Iphone", "Wyœwietlanie textury Iphona wy³¹czona!\n\nUWAGA: By wyko¿ystaæ wszystkie atuty skryptu zaleca siê\npobranie aktualnego mod-packa.", "Zamknij", "");
			}
			else 
			{
				PlayerInfo[playerid][pTextureIphone] = 1;
				ShowPlayerDialog(playerid, DIALOG_INFO_IPHONE, DIALOG_STYLE_MSGBOX, "Wyœwietlanie textury Iphone", "Wyœwietlanie textury Iphona w³¹czone!", "Zamknij", "");
			}
		}
		return 1;
	}

//----------------------------------[Local]-----------------------------------------------
	if(strcmp(cmd, "/r", true) == 0)
	{
  if(IsPlayerConnected(playerid))
	 {
	  if(PlayerInfo[playerid][pWounded] > 0)
			{
			 SendClientMessage(playerid, COLOR_GREY, "Jesteœ nieprzytomny, nie mo¿esz siê odezwaæ.");
			 return 1;
			}
			
			new itemindex = GetUsedItemByItemId(playerid, ITEM_RADIO);
			
	  switch(itemindex)
	  {
	   case INVALID_ITEM_ID:
	   {
	    SendClientMessage(playerid, COLOR_GREY, "Nie posiadasz radia.");
    	return 1;
	   }
	   case HAS_UNUSED_ITEM_ID:
	   {
	    SendClientMessage(playerid, COLOR_GREY, "Twoje radio jest wy³¹czone. Aby je w³¹czyæ, u¿yj /przedmioty uzyj [IdPrzedmiotu].");
    	return 1;
	   }
	  }

   if(PlayerInfo[playerid][pJailTime] > 0)
			{
			 SendClientMessage(playerid, COLOR_GRAD2, "Twoje radio zosta³o skonfiskowane na czas pobytu w wiêzieniu.");
				return 1;
			}

			if(Items[itemindex][iAttr1] == INVALID_RADIO_CHANNEL)
			{
			 SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ po³¹czony z ¿adnym kana³em.");
			 return 1;
			}

   new result[128];

			idx++;
			strmid(result, cmdtext, idx, strlen(cmdtext), 255);
			
			if(!strlen(result))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: (/r)adio [wiadomoœæ]");
				return 1;
			}
			
			ucfirst(result);

			if(PlayerInfo[playerid][pMuted] >= 1)
  	{
  		SendClientMessage(playerid, TEAM_CYAN_COLOR, "Nie mo¿esz rozmawiaæ, zosta³eœ wyciszony");
  		return 1;
  	}
 	
	  if(!CheckIsTextIC(playerid, result))
	  {
	   return 0;
	  }

     SendRadioMessageEx(playerid, COLOR_NRADIO, Items[itemindex][iAttr1], result);
		}
		return 1;
	}
//----------------------------------[Shout]-----------------------------------------------
	if(strcmp(cmd, "/megafon", true) == 0 || strcmp(cmd, "/m", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
	  if(PlayerInfo[playerid][pWounded] > 0)
			{
			 SendClientMessage(playerid, COLOR_GREY, "Jesteœ nieprzytomny, nie mo¿esz siê odezwaæ.");
			 return 1;
			}

			//new tmpcar = GetPlayerVehicleID(playerid);
			GetPlayerNameMask(playerid, sendername, sizeof(sendername));
			new length = strlen(cmdtext);
			while ((idx < length) && (cmdtext[idx] <= ' '))
			{
				idx++;
			}
			new offset = idx;
			new result[64];
			while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
			{
				result[idx - offset] = cmdtext[idx];
				idx++;
			}
			result[idx - offset] = EOS;
			if(!strlen(result))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: (/m)egafon [wiadomoœæ]");
				return 1;
			}
			
			if(IsACop(playerid) || PlayerInfo[playerid][pMember] == 3 || PlayerInfo[playerid][pLeader] == 3 || PlayerInfo[playerid][pLeader] == 18 || PlayerInfo[playerid][pMember] == 18 || (GetPlayerOrganization(playerid)==7 && PlayerInfo[playerid][pRank] >=7 && PlayerInfo[playerid][pRank] <=10))
			{
			 // pojazdy swat
			 /*if(tmpcar == 186 || tmpcar == 187 || tmpcar == 185 || tmpcar == 188 || tmpcar == 189 || tmpcar == 190 || tmpcar == 191 || (tmpcar >= 192 && tmpcar <= 197)){}
			 else if(tmpcar == 112 || tmpcar == 111 || tmpcar == 110 || tmpcar == 95 || tmpcar == 46 || tmpcar == 50 || tmpcar == 51 || tmpcar == 55 || tmpcar == 59 || tmpcar == 77 || tmpcar == 45 || tmpcar == 76 || tmpcar == 91){}
				else if(IsACopCar(tmpcar)){}
				else
				{
					SendClientMessage(playerid, COLOR_GRAD2, "   Nie jesteœ w pojeŸdzie policji / stra¿y granicznej!");
					return 1;
				}*/
				
				if(PlayerInfo[playerid][pMuted] >= 1)
  	 {
  	 	SendClientMessage(playerid, TEAM_CYAN_COLOR, "Nie mo¿esz rozmawiaæ, zosta³eœ wyciszony");
  	 	return 1;
  	 }
 	
	   if(!CheckIsTextIC(playerid, result))
	   {
	    return 0;
	   }
		 
		 ucfirst(result);
				
				if(PlayerInfo[playerid][pMember] == 1||PlayerInfo[playerid][pLeader] == 1)
				{
					format(string, sizeof(string), "[%s:o< %s]", sendername, result);
				}
				else if(PlayerInfo[playerid][pMember] == 2||PlayerInfo[playerid][pLeader] == 2)
				{
					format(string, sizeof(string), "[%s:o< %s]", sendername, result);
				}
				else if(PlayerInfo[playerid][pMember] == 3||PlayerInfo[playerid][pLeader] == 3)
				{
				 format(string, sizeof(string), "[%s:o< %s]", sendername, result);
				}
				else if(PlayerInfo[playerid][pMember] == 13||PlayerInfo[playerid][pLeader] == 13)
				{
				 format(string, sizeof(string), "[%s:o< %s]", sendername, result);
				}
				else if(PlayerInfo[playerid][pMember] == 18||PlayerInfo[playerid][pLeader] == 18)
				{
				 format(string, sizeof(string), "[%s:o< %s]", sendername, result);
				}
				else if(PlayerInfo[playerid][pMember] == 7||PlayerInfo[playerid][pLeader] ==7)
				{
				 format(string, sizeof(string), "[%s:o< %s]", sendername, result);
				}
				
				ProxDetector(100.0, playerid, string,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
				printf("%s", string);
			}
			else
			{
			 SendClientMessage(playerid, COLOR_GRAD2, "Nie nale¿ysz do s³u¿b porz¹dkowych !");
				return 1;
			}
		}
		return 1;
	}
//----------------------------------[Team]-----------------------------------------------
	
//----------------------------------[offduty]-----------------------------------------------
	if(strcmp(cmd, "/duty", true) == 0 || strcmp(cmd, "/sluzba", true) == 0 || strcmp(cmd, "/s³u¿ba", true) == 0)
	{
  if(IsPlayerConnected(playerid))
  {
			GetPlayerNameMask(playerid, sendername, sizeof(sendername));
			if(PlayerInfo[playerid][pMember] == 1 || PlayerInfo[playerid][pLeader] == 1 || PlayerInfo[playerid][pMember] == 2 || PlayerInfo[playerid][pLeader] == 2)
			{
				if (PlayerToPoint(3, playerid,255.3,77.4,1003.6) || (PlayerToPoint(3,playerid, 255.137, -41.5322, 1002.0234) && GetPlayerVirtualWorld(playerid) == 0) || PlayerToPoint(3,playerid,-1616.1294,681.1594,7.1875) || PlayerToPoint(3, playerid, 240.4544,112.7762,1003.2188) || PlayerInfo[playerid][pLocal] != 0)
				{
				 if(PlayerInfo[playerid][pMember] == 1 || PlayerInfo[playerid][pLeader] == 1)
				 {
					 if(OnDuty[playerid]==0)
			   {
						ServerMe(playerid,"bierze odznakê i broñ z szafki.");
										
					 	OnDuty[playerid] = 1;
						SetPlayerArmour(playerid, 100);
					 	SetPlayerToTeamColor(playerid);
					 	
					 	SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
					 }
					 else if(OnDuty[playerid]==1)
					 {
					  ServerMe(playerid,"odk³ada odznakê i broñ do szafki.");

					 	OnDuty[playerid] = 0;
						SetPlayerArmour(playerid, 0);
					 	SetPlayerToTeamColor(playerid);

					 	SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
					 }
				 }
				 else if(PlayerInfo[playerid][pMember] == 2 || PlayerInfo[playerid][pLeader] == 2)
				 {
				  if(OnDuty[playerid]==0)
			   {
				  	format(string, sizeof(string), "* Agent SWAT %s bierze Odznakê oraz Broñ ze swojej szafki.", sendername);
					 	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					 	//GivePlayerWeaponEx2(playerid, 24, 70);
					 	//GivePlayerWeaponEx2(playerid, 3, 0);
					 	OnDuty[playerid] = 1;
					 	SetPlayerToTeamColor(playerid);
					 	
					 	SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
					 }
					 else if(OnDuty[playerid]==1)
					 {
					 	format(string, sizeof(string), "* Agent SWAT %s odk³ada Odznakê oraz Broñ do swojej szafki.", sendername);
					 	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					 	//GivePlayerWeaponEx2(playerid, 23, 150);
					 	//GivePlayerWeaponEx2(playerid, 5, 0);
					 	OnDuty[playerid] = 0;
					 	SetPlayerToTeamColor(playerid);
					 	
					 	SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
					 }
				 }
				}
				else
				{
					SendClientMessage(playerid, COLOR_GRAD2, "Nie jesteœ w komisariacie !");
					return 1;
				}
			}
			else if(PlayerInfo[playerid][pMember] == 3 || PlayerInfo[playerid][pLeader] == 3)
			{
				if (PlayerToPoint(3, playerid,308.9569,-137.2681,1004.0625))
				{
				 if(PlayerInfo[playerid][pMember] == 3 || PlayerInfo[playerid][pLeader] == 3)
				 {
					 if(OnDuty[playerid]==0)
			   {
				  	format(string, sizeof(string), "* ¯o³nierz %s bierze legitymacjê z pó³ki.", sendername);
				 	 ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
		
   		              GivePlayerWeaponEx2(playerid, 31, 600);
   		              SetPlayerArmour(playerid, 100);

					 	OnDuty[playerid] = 1;
					 	SetPlayerToTeamColor(playerid);

					 	SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
					 }
					 else if(OnDuty[playerid]==1)
					 {
					 	format(string, sizeof(string), "* ¯o³nierz %s odk³ada legitymacjê na pó³kê.", sendername);
					 	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					 	
                        OnDuty[playerid] = 0;
					 	SetPlayerToTeamColor(playerid);

					 	SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
					 }
				 }
				 else if(PlayerInfo[playerid][pMember] == 2 || PlayerInfo[playerid][pLeader] == 2)
				 {
				  if(OnDuty[playerid]==0)
			   {
				  	format(string, sizeof(string), "* Agent SWAT %s bierze Odznakê oraz Broñ ze swojej szafki.", sendername);
					 	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					 	//GivePlayerWeaponEx2(playerid, 24, 70);
					 	//GivePlayerWeaponEx2(playerid, 3, 0);
					 	OnDuty[playerid] = 1;
					 	SetPlayerToTeamColor(playerid);

					 	SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
					 }
					 else if(OnDuty[playerid]==1)
					 {
					 	format(string, sizeof(string), "* Agent SWAT %s odk³ada Odznakê oraz Broñ do swojej szafki.", sendername);
					 	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					 	//GivePlayerWeaponEx2(playerid, 23, 150);
					 	//GivePlayerWeaponEx2(playerid, 5, 0);
					 	OnDuty[playerid] = 0;
					 	SetPlayerToTeamColor(playerid);

					 	SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
					 }
				 }
				}
				else
				{
					SendClientMessage(playerid, COLOR_GRAD2, "Nie jesteœ w komisariacie !");
					return 1;
				}
			}
			else if(PlayerInfo[playerid][pMember] == 4||PlayerInfo[playerid][pLeader] == 4)
			{
			 if(OnDuty[playerid] == 1)
			 {
			  SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Nie jesteœ juz na s³u¿bie, nie bêdziesz otrzymywa³ zg³oszeñ.");
			  OnDuty[playerid] = 0;
			  SetPlayerToTeamColor(playerid);
			  Medics -= 1;
			 }
			 else
			 {
			  SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Jesteœ na s³u¿bie, bêdziesz otrzymywa³ zg³oszenia od ludzi.");
			  OnDuty[playerid] = 1;
			  SetPlayerToTeamColor(playerid);
			
			  // fix
			  if(Medics < 0)
			  {
			   Medics = 0;
			  }
			
			  Medics += 1;
			 }
			}
			else if(PlayerInfo[playerid][pMember] == 18 || PlayerInfo[playerid][pLeader] == 18)
			{
			 if(OnDuty[playerid]==0)
		  {
		  	SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Jesteœ na s³u¿bie.");
	
			 	OnDuty[playerid] = 1;
			 	SetPlayerToTeamColor(playerid);
			 	
			 	//if(PlayerInfo[playerid][pChar] > 0) { SetPlayerSkin(playerid, PlayerInfo[playerid][pChar]); }
     //else { SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]); }
			 }
			 else if(OnDuty[playerid]==1)
			 {
			 	SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Nie jesteœ juz na s³u¿bie.");
			 	
			 	OnDuty[playerid] = 0;
			 	
     SetPlayerToTeamColor(playerid);
					
     //if(PlayerInfo[playerid][pChar] > 0) { SetPlayerSkin(playerid, PlayerInfo[playerid][pChar]); }
     //else { SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]); }
				}
   }
			else if(PlayerInfo[playerid][pMember] == 7 || PlayerInfo[playerid][pLeader] == 7)
			{
			 if(OnDuty[playerid] == 1)
			 {
			  SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Nie jesteœ juz na s³u¿bie.");
			  OnDuty[playerid] = 0;
			  SetPlayerToTeamColor(playerid);
			 }
			 else
			 {
			  SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Jesteœ na s³u¿bie.");
			  OnDuty[playerid] = 1;
			  SetPlayerToTeamColor(playerid);
			 }
			}
			else if(PlayerInfo[playerid][pMember] == 9 || PlayerInfo[playerid][pLeader] == 9)
			{
			 if(OnDuty[playerid] == 1)
			 {
			  SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Nie jesteœ juz na s³u¿bie.");
			  OnDuty[playerid] = 0;
			  SetPlayerToTeamColor(playerid);
			 }
			 else
			 {
			  SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Jesteœ na s³u¿bie.");
			  OnDuty[playerid] = 1;
			  SetPlayerToTeamColor(playerid);
			 }
			}
			else if(PlayerInfo[playerid][pMember] == 11 || PlayerInfo[playerid][pLeader] == 11)
			{
			 if(OnDuty[playerid] == 1)
			 {
			  SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Nie jesteœ juz na s³u¿bie.");
			  OnDuty[playerid] = 0;
			  SetPlayerToTeamColor(playerid);
			 }
			 else
			 {
			  SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Jesteœ na s³u¿bie.");
			  OnDuty[playerid] = 1;
			  SetPlayerToTeamColor(playerid);
			 }
			}
			else if(PlayerInfo[playerid][pMember] == 10 || PlayerInfo[playerid][pLeader] == 10)
			{
			 if(OnDuty[playerid] == 1)
			 {
			  SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Nie jesteœ juz na s³u¿bie.");
			  OnDuty[playerid] = 0;
			  SetPlayerToTeamColor(playerid);
			 }
			 else
			 {
			  SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Jesteœ na s³u¿bie.");
			  OnDuty[playerid] = 1;
			  SetPlayerToTeamColor(playerid);
			 }
			}
			else if(PlayerInfo[playerid][pJob] == 7)
			{
    if(JobDuty[playerid] == 1)
    {
     SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Nie jesteœ juz na s³u¿bie, nie bêdziesz otrzymywa³ zg³oszeñ.");
			  JobDuty[playerid] = 0;
			  Mechanics -= 1;
			 }
			 else
			 {
			  SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Jesteœ na s³u¿bie, bêdziesz otrzymywa³ zg³oszenia od ludzi.");
			  JobDuty[playerid] = 1;
			  Mechanics += 1;
			 }
			}
			else
			{
	   SendClientMessage(playerid, COLOR_GRAD1, "   Nie jesteœ policjantem !");
			}
		}
		return 1;
	}
//----------------------------------[mdc]-----------------------------------------------
	if(strcmp(cmd, "/mdc", true) == 0 || strcmp(cmd, "/kartoteka", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
	  if(!IsACop(playerid))
	  {
	   SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ policjantem !");
	   return 1;
	  }
			new tmpcar = GetPlayerVehicleID(playerid);
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /kartoteka [IdGracza/CzêœæNazwy]");
				return 1;
			}
			//giveplayerid = strval(tmp);
			giveplayerid = ReturnUser(tmp);
			if(PlayerToPoint(5.0, playerid, 198.9127,168.3687,1003.0234)||PlayerToPoint(5.0, playerid, 230.4309,165.0516,1003.0234)||PlayerToPoint(5.0, playerid, 221.6854,186.7259,1003.0313) || tmpcar == 112 || tmpcar == 111 || tmpcar == 110 || tmpcar == 95 || (tmpcar >= 257 && tmpcar <= 275))
			{
				if(IsPlayerConnected(giveplayerid))
				{
				    if(giveplayerid != INVALID_PLAYER_ID)
				    {
				        GetPlayerNameEx(giveplayerid, sendername, sizeof(sendername));
						SendClientMessage(playerid, TEAM_BLUE_COLOR,"____________KOMPUTER PRZENOŒNY____________");
						format(string, sizeof(string), "Poszukiwany : %s", sendername);
						SendClientMessage(playerid, COLOR_WHITE,string);
						format(string, sizeof(string), "Przestêpstwo : %s", PlayerCrime[giveplayerid][pAccusedof]);
						SendClientMessage(playerid, COLOR_GRAD2,string);
						format(string, sizeof(string), "Zg³osi³ : %s", PlayerCrime[giveplayerid][pVictim]);
						SendClientMessage(playerid, COLOR_GRAD3,string);
						format(string, sizeof(string), "Doniós³ : %s", PlayerCrime[giveplayerid][pAccusing]);
						SendClientMessage(playerid, COLOR_GRAD4,string);
						format(string, sizeof(string), "Oskar¿y³ o: %s", PlayerCrime[giveplayerid][pBplayer]);
						SendClientMessage(playerid, COLOR_GRAD5,string);
						SendClientMessage(playerid, TEAM_BLUE_COLOR,"_________________________________________");
					}
				}
				else
				{
				    SendClientMessage(playerid, COLOR_GREY, "   Ten gracz jest niedostêpny !");
				    return 1;
				}
			}
			else
			{
			    SendClientMessage(playerid, COLOR_GRAD2, "   Nie jesteœ w radiowozie lub na komisariacie.");
				return 1;
			}
		}
		return 1;
	}
//----------------------------------[SetCrim]-----------------------------------------------
	if(strcmp(cmd, "/suspect", true) == 0 || strcmp(cmd, "/su", true) == 0 || strcmp(cmd, "/po", true) == 0 || strcmp(cmd, "/podejrzany", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
		 if(OnDuty[playerid] != 1  && PlayerInfo[playerid][pMember] == 1)
			{
			 SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ na s³u¿bie !");
			 return 1;
			}
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: (/po)dejrzany [IdGracza/CzêœæNazwy] [opis przestêpstwa]");
				return 1;
			}
			giveplayerid = ReturnUser(tmp);
			if (IsACop(playerid))
			{
				if(IsPlayerConnected(giveplayerid))
				{
				 if(giveplayerid != INVALID_PLAYER_ID)
				 {
						if (!IsACop(giveplayerid))
						{
							GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
							GetPlayerNameEx(playerid, sendername, sizeof(sendername));
							new length = strlen(cmdtext);
							while ((idx < length) && (cmdtext[idx] <= ' '))
							{
								idx++;
							}
							new offset = idx;
							new result[64];
							while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
							{
								result[idx - offset] = cmdtext[idx];
								idx++;
							}
							result[idx - offset] = EOS;
							if(!strlen(result))
							{
								SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: (/po)dejrzany [IdGracza/CzêœæNazwy] [opis przestêpstwa]");
								return 1;
							}
							GetPlayerNameEx(giveplayerid, sendername, sizeof(sendername));
							
							if(WantedPoints[giveplayerid] == 0) { WantedPoints[giveplayerid] = 3; }
							else { WantedPoints[giveplayerid]+= 2;}
							SetPlayerCriminal(giveplayerid,playerid, result);
							SetPlayerWantedLevel(giveplayerid, WantedLevel[giveplayerid]);
							
       format(string, sizeof(string), "Nada³eœ poziom poszukiwania %s.", sendername);
       SendClientMessage(playerid, COLOR_GRAD1, string);
							return 1;
						}
						else
						{
							SendClientMessage(playerid, COLOR_GRAD2, "Nie mo¿esz daæ poziomu poszukiwañ policjantowi !");
						}
					}
				}
				else
				{
						format(string, sizeof(string), "   %d nie jest dostêpny.", giveplayerid);
						SendClientMessage(playerid, COLOR_GRAD1, string);
						return 1;
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD2, "Nie jesteœ Policjantem / Agentem SWAT / Gwardi¹ Narodow¹ !");
			}
		}
		return 1;
	}
//----------------------------------[LOCK]-----------------------------------------------
	/*#if OLD_HOUSE
	if(strcmp(cmd, "/open", true) == 0 || strcmp(cmd, "/otworz", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
	  GetPlayerName(playerid, sendername, sizeof(sendername));
   for(new i = 0; i < sizeof(HouseInfo); i++)
			{
				if (PlayerToPoint(3, playerid,HouseInfo[i][hEntrancex], HouseInfo[i][hEntrancey], HouseInfo[i][hEntrancez]) || (PlayerToPoint(3, playerid,HouseInfo[i][hExitx], HouseInfo[i][hExity], HouseInfo[i][hExitz]) && GetPlayerVirtualWorld(playerid) == HouseInfo[i][hVW]))
				{
					if(PlayerInfo[playerid][pPhousekey] == i && PlayerInfo[playerid][pId] == HouseInfo[i][hOwner])
					{
						if(HouseInfo[i][hLock] == 1)
						{
							HouseInfo[i][hLock] = 0;
							GameTextForPlayer(playerid, "~w~Drzwi ~g~Otwarte", 5000, 6);
							PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
							return 1;
						}
						if(HouseInfo[i][hLock] == 0)
						{
							HouseInfo[i][hLock] = 1;
							GameTextForPlayer(playerid, "~w~Drzwi ~r~Zamkniete", 5000, 6);
							PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
							return 1;
						}
					}
					else
					{
						GameTextForPlayer(playerid, "~r~Nie masz klucza", 5000, 6);
						return 1;
					}
				}
			}
			#endif*/
			
			/*for(new i = 0; i < sizeof(BizzInfo); i++)
			{
			 if (BizzInfo[i][bId] != -1)
			 {
				 if (PlayerToPoint(3, playerid,BizzInfo[i][bEntranceX], BizzInfo[i][bEntranceY], BizzInfo[i][bEntranceZ]) || PlayerToPoint(3, playerid,BizzInfo[i][bExitX], BizzInfo[i][bExitY], BizzInfo[i][bExitZ]))
				 {
				 	if(PlayerInfo[playerid][pPbiskey] == i)
				 	{
					 	if(BizzInfo[i][bLocked] == 1)
					 	{
					 		BizzInfo[i][bLocked] = 0;
					 		GameTextForPlayer(playerid, "~w~Biznes ~g~Otwarty", 5000, 6);
					 		PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
					 		return 1;
					 	}
					 	if(BizzInfo[i][bLocked] == 0)
					 	{
					 		BizzInfo[i][bLocked] = 1;
					 		GameTextForPlayer(playerid, "~w~Biznes ~r~Zamkniety", 5000, 6);
					 		PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
					 		return 1;
					 	}
					 }
					 else
					 {
					 	GameTextForPlayer(playerid, "~r~Nie masz klucza", 5000, 6);
					 	return 1;
					 }
				 }
			 }
		 }
			for(new i = 0; i < sizeof(SBizzInfo); i++)
			{
				if (PlayerToPoint(3, playerid,SBizzInfo[i][sbEntranceX], SBizzInfo[i][sbEntranceY], SBizzInfo[i][sbEntranceZ]))
				{
					if(PlayerInfo[playerid][pPbiskey] == i+100)
					{
						if(SBizzInfo[i][sbLocked] == 1)
						{
							SBizzInfo[i][sbLocked] = 0;
							GameTextForPlayer(playerid, "~w~Biznes ~g~Otwarty", 5000, 6);
							PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
							return 1;
						}
						if(SBizzInfo[i][sbLocked] == 0)
						{
							SBizzInfo[i][sbLocked] = 1;
							GameTextForPlayer(playerid, "~w~Biznes ~r~Zamkniey", 5000, 6);
							PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
							return 1;
						}
					}
					else
					{
						GameTextForPlayer(playerid, "~r~Nie masz klucza", 5000, 6);
						return 1;
					}
				}
			}*/
	    /*}
	    return 1;
	}*/
//----------------------------------[Wisper]-----------------------------------------------
	
//----------------------------------[Bank System]-----------------------------------------------
 if(strcmp(cmd, "/withdraw", true) == 0 || strcmp(cmd, "/wyplac", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
	  if(!IsAtBank(playerid))
	  {
	   SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ w banku!");
	   return 1;
	  }
	
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /wyplac [iloœæ]");
				format(string, sizeof(string), "  Masz $%d na swoim koncie.", PlayerInfo[playerid][pAccount]);
				SendClientMessage(playerid, COLOR_GRAD3, string);
				return 1;
			}

			new cashdeposit = strval(tmp);
			if (cashdeposit > PlayerInfo[playerid][pAccount] || cashdeposit < 1)
			{
				SendClientMessage(playerid, COLOR_GRAD2, "   Nie posiadasz tyle pieniêdzy !");
				return 1;
			}
		
   
			GivePlayerMoneyEx(playerid,cashdeposit);
			GivePlayerAccountMoneyEx(playerid,-cashdeposit);
			format(string, sizeof(string), "  Wyp³aci³eœ $%d ze swojego konta. Stan konta: $%d ", cashdeposit,PlayerInfo[playerid][pAccount]);
			SendClientMessage(playerid, COLOR_YELLOW, string);
			
			if(PlayerInfo[playerid][pLeader] == 7)
			{
			 GetPlayerName(playerid, sendername, sizeof(sendername));
			 format(string, sizeof(string), "Gubernator %s wyplacil %d ze swojego konta bankowego", sendername, cashdeposit);
			 GLog(string);
			}
			return 1;
		}
		return 1;
	}
	if(strcmp(cmd, "/bank", true) == 0 || strcmp(cmd, "/depozyt", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
	  if(!IsAtBank(playerid))
	  {
	   SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ w banku!");
	   return 1;
	  }
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /depozyt [iloœæ]");
				format(string, sizeof(string), "  Masz $%d na swoim koncie.", PlayerInfo[playerid][pAccount]);
				SendClientMessage(playerid, COLOR_GRAD3, string);
				return 1;
			}
			new cashdeposit = strval(tmp);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /depozyt [iloœæ]");
				format(string, sizeof(string), "  Masz $%d na swoim koncie.", PlayerInfo[playerid][pAccount]);
				SendClientMessage(playerid, COLOR_GRAD3, string);
				return 1;
			}
			if (cashdeposit > GetPlayerMoneyEx(playerid) || cashdeposit < 1)
			{
				SendClientMessage(playerid, COLOR_GRAD2, "   Nie posiadasz tyle pieniêdzy !");
				return 1;
			}
			GivePlayerMoneyEx(playerid,-cashdeposit);
			new curfunds = PlayerInfo[playerid][pAccount];
			
			GivePlayerAccountMoneyEx(playerid, cashdeposit);
			SendClientMessage(playerid, COLOR_WHITE, "|___ BANK STATEMENT ___|");
			format(string, sizeof(string), "  Stary Bilans: $%d", curfunds);
			SendClientMessage(playerid, COLOR_GRAD2, string);
			format(string, sizeof(string), "  Depozyt: $%d",cashdeposit);
			SendClientMessage(playerid, COLOR_GRAD4, string);
			SendClientMessage(playerid, COLOR_GRAD6, "|-----------------------------------------|");
			format(string, sizeof(string), "  Nowy Bilans: $%d", PlayerInfo[playerid][pAccount]);
			SendClientMessage(playerid, COLOR_WHITE, string);
			return 1;
		}
		return 1;
	}
	if(strcmp(cmd, "/balance", true) == 0 || strcmp(cmd, "/balans", true) == 0)
	{
  if(IsPlayerConnected(playerid))
	 {
	  if(!IsAtBank(playerid))
	  {
	   SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ w banku!");
	   return 1;
	  }
			format(string, sizeof(string), "  Masz $%d na swoim koncie.",PlayerInfo[playerid][pAccount]);
			SendClientMessage(playerid, COLOR_YELLOW, string);
		}
		return 1;
	}
	if(strcmp(cmd, "/dice", true) == 0 || strcmp(cmd, "/kostka", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
			new dice = random(6)+1;
			if (HasPlayerItemByType(playerid, ITEM_DICE))
			{
				GetPlayerNameMask(playerid, sendername, sizeof(sendername));
				format(string, sizeof(string), "* %s rzuci³ kostk¹, na której wypad³a liczba %d", sendername,dice);
				ProxDetector(5.0, playerid, string, TEAM_GREEN_COLOR,TEAM_GREEN_COLOR,TEAM_GREEN_COLOR,TEAM_GREEN_COLOR,TEAM_GREEN_COLOR);
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD2, "Nie masz kostki!");
				return 1;
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/transfer", true) == 0 || strcmp(cmd, "/przelej", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
	  #if LEVEL_MODE
			if(PlayerInfo[playerid][pLevel] < 3)
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   Musisz mieæ 3 poziom !");
				return 1;
			}
			#endif
	  if(!IsAtBank(playerid))
	  {
	   SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ w banku!");
	   return 1;
	  }
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /przelej [IdGracza/CzêœæNazwy] [iloœæ]");
				return 1;
			}
			giveplayerid = ReturnUser(tmp);
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /przelej [IdGracza/CzêœæNazwy] [iloœæ]");
				return 1;
			}
			moneys = strval(tmp);
			if (IsPlayerConnected(giveplayerid))
			{
			 if(giveplayerid != INVALID_PLAYER_ID)
	   {
					GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
					GetPlayerNameEx(playerid, sendername, sizeof(sendername));
					playermoney = PlayerInfo[playerid][pAccount] ;
					if (moneys > 0 && playermoney >= moneys)
					{
						GivePlayerAccountMoneyEx(playerid, -moneys);
						GivePlayerAccountMoneyEx(giveplayerid, moneys);
						format(string, sizeof(string), "Przela³eœ $%s na konto %s.", format_number(moneys), giveplayer,giveplayerid);
						PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
						SendClientMessage(playerid, COLOR_GRAD1, string);
						format(string, sizeof(string), "Na Twoje konto wp³ynê³o $%s od %s.", format_number(moneys), sendername, playerid);
						SendClientMessage(giveplayerid, COLOR_GRAD1, string);
						
						format(string, sizeof(string), "%s wp³aci³ $%s na konto %s", sendername, format_number(moneys), giveplayer);
						if(PlayerInfo[playerid][pLeader] == 7)
						{
						 GLog(string);
						}
		    if(moneys >= 500000)
						{
							ABroadCast(COLOR_YELLOW,string,1);
						}
						printf("%s", string);
						PayLog(string);
						PlayerPlaySound(giveplayerid, 1052, 0.0, 0.0, 0.0);
					}
					else
					{
						SendClientMessage(playerid, COLOR_GRAD1, "   Nieprawid³owa iloœæ pieniêdzy.");
					}
				}
			}
			else
			{
				format(string, sizeof(string), "   %d jest niedostêpny.", giveplayerid);
				SendClientMessage(playerid, COLOR_GRAD1, string);
			}
		}
		return 1;
	}
	
 /*if(strcmp(cmd, "/rentroom", true) == 0 || strcmp(cmd, "/wynajmijpokoj", true) == 0)
	{
		if(IsPlayerConnected(playerid))
		{
			new Float:oldposx, Float:oldposy, Float:oldposz;
			GetPlayerName(playerid, playername, sizeof(playername));
			GetPlayerPos(playerid, oldposx, oldposy, oldposz);
			for(new h = 0; h < sizeof(HouseInfo); h++)
			{
				if(PlayerToPoint(2.0, playerid, HouseInfo[h][hEntrancex], HouseInfo[h][hEntrancey], HouseInfo[h][hEntrancez]) && HouseInfo[h][hOwned] == 1 &&  HouseInfo[h][hRentabil] == 1)// && HouseInfo[h][hVW] == GetPlayerVirtualWorld(playerid))
				{
				 if(PlayerInfo[playerid][pHotelId] != 0)
				 {
				  SendClientMessage(playerid, COLOR_GRAD5, "Najpierw musisz wymeldowaæ siê z hotelu !");
				  return 1;
				 }
					if(PlayerInfo[playerid][pPhousekey] != 255 && PlayerInfo[playerid][pId] == HouseInfo[PlayerInfo[playerid][pPhousekey]][hOwner])
					{
						SendClientMessage(playerid, COLOR_WHITE, "   Masz dom, wpisz /sellhouse je¿eli chcesz wynaj¹æ akurat to mieszkanie.");
						return 1;
					}
					if(GetPlayerMoneyEx(playerid) > HouseInfo[h][hRent])
					{
						PlayerInfo[playerid][pPhousekey] = h;
						GivePlayerMoneyEx(playerid,-HouseInfo[h][hRent]);
						HouseInfo[h][hTakings] = HouseInfo[h][hTakings]+HouseInfo[h][hRent];
						SetPlayerInterior(playerid,HouseInfo[h][hInt]);
						SetPlayerPosEx(playerid,HouseInfo[h][hExitx],HouseInfo[h][hExity],HouseInfo[h][hExitz]);
						SetPlayerVirtualWorldEx(playerid,HouseInfo[h][hVW]);
						GameTextForPlayer(playerid, "~w~Witaj w domu~n~Mozesz stad wyjsc podchodzac do drzwi i wpisujac /wyjdz", 5000, 3);
						PlayerInfo[playerid][pInt] = HouseInfo[h][hInt];
						PlayerInfo[playerid][pLocal] = h;
						PlayerInfo[playerid][pLocalType] = CONTENT_TYPE_HOUSE;
						SendClientMessage(playerid, COLOR_WHITE, "Gratulacje. Mo¿esz wchodziæ i wychodziæ jak ci sie podoba.");
						SendClientMessage(playerid, COLOR_WHITE, "Wpisz /pomoc aby zobaczæ wszystkie dostêpne komendy.");
						OnPlayerSave(playerid);
						return 1;
					}
					else
					{
						SendClientMessage(playerid, COLOR_WHITE, "Nie masz na to pieniêdzy!");
						return 1;
					}
				}
			}
		}
		return 1;
	}*/
	/*if(strcmp(cmd, "/przekazdom", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
		{
			tmp = strtok(cmdtext, idx);
//			new car;
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /przekazdom [IdGracza/CzêœæNazwy] [cena]");
				return 1;
			}
			giveplayerid = ReturnUser(tmp);
			
			GetPlayerName(playerid, sendername, sizeof(sendername));
			
			if(PlayerInfo[playerid][pId] == HouseInfo[PlayerInfo[playerid][pPhousekey]][hOwner]){}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "  Nie jesteœ w³aœcicielem ¿adnego domu.");
				return 1;
			}
			
			if(PlayerInfo[giveplayerid][pPhousekey] != 255)
			{
				SendClientMessage(playerid, COLOR_GRAD1, "  Ta osoba wynajmuje lub jest w³aœcicielem domu.");
				return 1;
			}
			
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /przekazdom [IdGracza/CzêœæNazwy] [cena]");
				return 1;
			}
			new price = strval(tmp);
			
			if(price < 0)
			{
			 SendClientMessage(playerid, COLOR_GRAD1, "Nie mo¿esz zaoferowaæ domu za tak¹ cenê.");
				return 1;
			}
			
			if (IsPlayerConnected(giveplayerid))
			{
    if(giveplayerid != INVALID_PLAYER_ID)
    {
					if(ProxDetectorS(5.0, playerid, giveplayerid))
					{
					 giveHouseKeyPrice[giveplayerid] = price;
      giveHouseKeyOffer[giveplayerid] = playerid;

					 GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));

      format(string, sizeof(string), "* Zaoferowa³eœ klucz do twojego domu %s.", giveplayer);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "* %s zaoferowa³ ci klucz do swojego domu za $%d (wybierz /akceptuj dom) by akceptowaæ.", sendername, price);
						SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
					}
				}
			}
		}
		return 1;
	}*/
	/*if(strcmp(cmd, "/unrent", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
		{
			GetPlayerNameEx(playerid, playername, sizeof(playername));
			if(PlayerInfo[playerid][pPhousekey] != 255 && PlayerInfo[playerid][pId] == HouseInfo[PlayerInfo[playerid][pPhousekey]][hOwner])
			{
				SendClientMessage(playerid, COLOR_WHITE, "   Ten dom jest twoj¹ w³asnoœci¹ !");
				return 1;
			}
			PlayerInfo[playerid][pPhousekey] = 255;
			SendClientMessage(playerid, COLOR_WHITE, "Jesteœ bezdomnym.");
		}
		return 1;
	}*/

	/*if(strcmp(cmd, "/asellhouse", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
		{
			GetPlayerName(playerid, playername, sizeof(playername));
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /asellhouse [numerdomu]");
				return 1;
			}
			new house = strval(tmp);
			if (PlayerInfo[playerid][pAdmin] >= 1337)
			{
				HouseInfo[house][hHel] = 0;
				HouseInfo[house][hArm] = 0;
				HouseInfo[house][hLock] = 1;
				HouseInfo[house][hOwned] = 0;
				HouseInfo[house][hOwner] = 0;
				PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
				format(string, sizeof(string), "~w~Sprzedales ta nieruchomosc");
				GameTextForPlayer(playerid, string, 10000, 3);
				OnHouseUpdate(house);
				return 1;
			}
			else
			{
				SendClientMessage(playerid, COLOR_WHITE, "Nie jesteœ administratorem.");
			}
		}
		return 1;
	}*/
	/*if(strcmp(cmd, "/setrent", true) == 0 || strcmp(cmd, "/ilewynajem", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
		{
			new bouse = PlayerInfo[playerid][pPhousekey];
			GetPlayerName(playerid, playername, sizeof(playername));
			if (bouse != 255 && PlayerInfo[playerid][pId] == HouseInfo[PlayerInfo[playerid][pPhousekey]][hOwner])
			{
				tmp = strtok(cmdtext, idx);
				if(!strlen(tmp))
				{
					SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /ilewynajem [cena]");
					return 1;
				}
				if(strval(tmp) < 1 || strval(tmp) > 99999)
				{
					SendClientMessage(playerid, COLOR_WHITE, "Minimalna kwota wynajmu to $1, a maxymalna to $99999.");
					return 1;
				}
				HouseInfo[bouse][hRent] = strval(tmp);
				OnHouseUpdate(bouse);
				format(string, sizeof(string), "Nieruchomoœc wynajêta $%d", HouseInfo[bouse][hRent]);
				SendClientMessage(playerid, COLOR_WHITE, string);
				return 1;
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD2, "   Nie masz nieruchomoœci");
				return 1;
			}
		}
		return 1;
	}*/
	/*if(strcmp(cmd, "/evictall", true) == 0 || strcmp(cmd, "/eksmitujwszystkich", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
		{
			new bouse = PlayerInfo[playerid][pPhousekey];
			if (bouse != 255 && PlayerInfo[playerid][pId] == HouseInfo[PlayerInfo[playerid][pPhousekey]][hOwner])
			{
				for(new i = 0; i < MAX_PLAYERS; i++)
				{
					if(IsPlayerConnected(i))
					{
						if(i != playerid)
						{
							if (PlayerInfo[i][pPhousekey] == PlayerInfo[playerid][pPhousekey] )
							{
								SendClientMessage(i, COLOR_WHITE, "Zosta³eœ wyrzucony ze swojego wynajmowanego domu.");
								SendClientMessage(playerid, COLOR_WHITE, "Wszyscy zostali wyrzuceni.");
								PlayerInfo[i][pPhousekey] = 255;
								return 1;
							}
						}
					}
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD2, "   Nie masz nieruchomoœci !");
				return 1;
			}
		}
		return 1;
	}*/
	/*if(strcmp(cmd, "/evict", true) == 0 || strcmp(cmd, "/eksmituj", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
		{
			new bouse = PlayerInfo[playerid][pPhousekey];
			GetPlayerName(playerid, playername, sizeof(playername));
			if (bouse != 255 && PlayerInfo[playerid][pId] == HouseInfo[PlayerInfo[playerid][pPhousekey]][hOwner])
			{
				tmp = strtok(cmdtext, idx);
				if(!strlen(tmp))
				{
					SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /eksmituj [IdGracza/CzêœæNazwy]");
				}
				new target;
				//target = strval(tmp);
				target = ReturnUser(tmp);
				if (target == playerid)
				{
					SendClientMessage(target, COLOR_WHITE, "Nie mo¿esz wyrzuciæ siebie samego.");
					return 1;
				}
				if(IsPlayerConnected(target))
				{
				    if(target != INVALID_PLAYER_ID)
				    {
						if(PlayerInfo[target][pPhousekey] == PlayerInfo[playerid][pPhousekey])
						{
							SendClientMessage(target, COLOR_WHITE, "Zosta³eœ wyrzucony ze swojego domu");
							SendClientMessage(playerid, COLOR_WHITE, "Gracze zostali wyrzuceni");
							PlayerInfo[target][pPhousekey] = 255;
							return 1;
						}
						else
						{
						    SendClientMessage(playerid, COLOR_WHITE, "Gracz nie wynajmuje twojego domu !");
						    return 1;
						}
					}
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD2, "Nie masz w³asnego domu !");
				return 1;
			}
		}
		return 1;
	}*/
	/*if(strcmp(cmd, "/setrentable", true) == 0 || strcmp(cmd, "/wynajmowanie", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
		{
			new bouse = PlayerInfo[playerid][pPhousekey];
			GetPlayerName(playerid, playername, sizeof(playername));
			if (bouse != 255 && PlayerInfo[playerid][pId] == HouseInfo[PlayerInfo[playerid][pPhousekey]][hOwner])
			{
				tmp = strtok(cmdtext, idx);
				if(!strlen(tmp))
				{
					SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /wynajmowanie [0/1]");
				}
				HouseInfo[bouse][hRentabil] = strval(tmp);
				OnHouseUpdate(bouse);
				format(string, sizeof(string), "Dom mo¿e byæ wynajmowany %d [0 = nie, 1 = tak].", HouseInfo[bouse][hRentabil]);
				SendClientMessage(playerid, COLOR_WHITE, string);
				return 1;
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD2, "   Nie masz nieruchomoœci !");
				return 1;
			}
		}
		return 1;
	}*/
if(strcmp(cmd, "/call", true) == 0 || strcmp(cmd, "/dzwon", true) == 0)
{
	if(IsPlayerConnected(playerid))
	{
		tmp = strtok(cmdtext, idx);
  		if(!strlen(tmp))
		{
			SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /dzwon [numer telefonu]");
			return 1;
		}

		new itemindex = GetUsedItemByItemId(playerid, ITEM_CELLPHONE);

  		switch(itemindex)
		{
			case INVALID_ITEM_ID:
			{
					SendClientMessage(playerid, COLOR_GREY, "Nie posiadasz telefonu komórkowego.");
					return 1;
			}
			case HAS_UNUSED_ITEM_ID:
			{
	    			SendClientMessage(playerid, COLOR_GREY, "Twój telefon jest wy³¹czony. Aby go w³¹czyæ, u¿yj /przedmioty uzyj [IdPrzedmiotu].");
 	  				return 1;
	   		}
	  	}

			new phonenumber = Items[itemindex][iAttr1];

   			if(PlayerInfo[playerid][pJailTime] > 0)
			{
			 		SendClientMessage(playerid, COLOR_GRAD2, "Twój telefon zosta³ skonfiskowany na czas pobytu w wiêzieniu.");
					return 1;
			}

			if(PlayerInfo[playerid][pWounded] > 0)
			{
			 		SendClientMessage(playerid, COLOR_GREY, "Jesteœ nieprzytomny, nie mo¿esz siê odezwaæ.");
			 		return 1;
			}

			GetPlayerNameMask(playerid, sendername, sizeof(sendername));

			if(CellularPhone[playerid] == 1)//Jak ma wyjêty telefon nie wysy³amy /me
			{
				//ServerMe(playerid, "wyjmuje telefon.");
			}
			else
			{
			    ServerMe(playerid, "wyjmuje telefon.");
			}
			new phonenumb = strval(tmp);
            			/*if(phonenumb == 966)
			{
		  SendClientMessage(playerid, COLOR_ALLDEPT, "Telefonistka: Dzieñ dobry, biuro numerów miasta Los Santos.");
    SendClientMessage(playerid, COLOR_ALLDEPT, "Telefonistka: Prosze podaæ dane osoby której numer jest poszukiwany.");
    NotPlayersMobile[playerid] = 1;
				Mobile[playerid] = 966;
				SetPlayerSpecialActionEx(playerid,SPECIAL_ACTION_USECELLPHONE);
				return 1;
			}
			if(phonenumb == 8686)
			{
			  if(TaxiDrivers < 1)
		   {
		    SendClientMessage(playerid, COLOR_ALLDEPT, "Centrala: Witam, niestety ¿aden z taksówkarzy nie jest aktualnie na s³u¿bie.");
		    return 1;
		   }
		   if(TransportDuty[playerid] > 0)
		   {
		    SendClientMessage(playerid, COLOR_GREY, "   Nie mo¿esz dzwoniæ po taxówkê w tym momencie !");
		    return 1;
		   }

     SendClientMessage(playerid, COLOR_ALLDEPT, "Centrala: Witaj, dodzwoni³eœ siê");
				 NotPlayersMobile[playerid] = 1;
				 Mobile[playerid] = 911;
				 SetPlayerSpecialActionEx(playerid,SPECIAL_ACTION_USECELLPHONE);
		  	return 1;
    }
			}*/
			new query[256];
        	new year, month, day;
			getdate(year, month, day);
			new hour, minute, second;
			gettime(hour, minute, second);
			
			if(phonenumb == 444)
			{
					OnPlayerCommandText(playerid, "/wezwij taxi");
     				format(query, 256, "INSERT INTO `call_history` (`gphonenumber`, `nick`, `date`, `phonenumber`) VALUES ('444', 'Taxi', '%d/%d/%d %02d:%02d:%02d', '%d')", year, month, day, hour, minute, second, phonenumber);
					mysql_query(query);
					printf(query);
					mysql_store_result();
				return 1;
			}
			if(phonenumb == 555)
			{
				SendClientMessage(playerid, COLOR_WHITE, "WSKAZÓWKA: Aby rozmawiaæ przez telefon u¿ywaj T, a aby zakoñczyæ rozmowê wpisz /(z)akoncz.");
				SendClientMessage(playerid, COLOR_ALLDEPT, "VIBE: Dodzwoni³eœ siê do stacji radiowej, w czym mo¿emy pomóc(konkurs)?");
				NotPlayersMobile[playerid] = 1;
				Mobile[playerid] = 555;
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
                SetPlayerAttachedObject(playerid, 4, 330, 6); // 4 = attachment slot, 330 = cellphone model, 6 = right hand
					format(query, 256, "INSERT INTO `call_history` (`gphonenumber`, `nick`, `date`, `phonenumber`) VALUES ('555', 'VIBE News', '%d/%d/%d %02d:%02d:%02d', '%d')", year, month, day, hour, minute, second, phonenumber);
					mysql_query(query);
					printf(query);
					mysql_store_result();
				return 1;
			}
			if(phonenumb == 911)
			{
				SendClientMessage(playerid, COLOR_WHITE, "WSKAZÓWKA: Aby rozmawiaæ przez telefon u¿ywaj T, a aby zakoñczyæ rozmowê wpisz /(z)akoncz.");
				SendClientMessage(playerid, COLOR_ALLDEPT, "Centrala: Do którego oddzia³u dzwonisz: policja, straz czy pogotowie?");
				NotPlayersMobile[playerid] = 1;
				Mobile[playerid] = 911;
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
                SetPlayerAttachedObject(playerid, 4, 330, 6); // 4 = attachment slot, 330 = cellphone model, 6 = right hand
                SetPlayerAttachedObject(playerid, 4, 330, 6); // 4 = attachment slot, 330 = cellphone model, 6 = right hand
					format(query, 256, "INSERT INTO `call_history` (`gphonenumber`, `nick`, `date`, `phonenumber`) VALUES ('911', 'Nr. Alarmowy', '%d/%d/%d %02d:%02d:%02d', '%d')", year, month, day, hour, minute, second, phonenumber);
					mysql_query(query);
					printf(query);
					mysql_store_result();
				return 1;
			}
			
			new nick[32];
			format(string, sizeof(string), "SELECT `nick` FROM `vcard` WHERE `phonenumber` = %d AND `gphonenumber` = %d", phonenumber, phonenumb);
			mysql_query(string);
			mysql_store_result();
			mysql_fetch_row(nick);

			if(mysql_num_rows())
			{
					format(query, 256, "INSERT INTO `call_history` (`gphonenumber`, `nick`, `date`, `phonenumber`) VALUES ('%d', '%s', '%d/%d/%d %02d:%02d:%02d', '%d')", phonenumb, nick, year, month, day, hour, minute, second, phonenumber);
					mysql_query(query);
					printf(query);
					mysql_store_result();
			}
			else
			{
					format(query, 256, "INSERT INTO `call_history` (`gphonenumber`, `nick`, `date`, `phonenumber`) VALUES ('%d', ' ', '%d/%d/%d %02d:%02d:%02d', '%d')", phonenumb, year, month, day, hour, minute, second, phonenumber);
					mysql_query(query);
					printf(query);
					mysql_store_result();
			}
			mysql_free_result();
			
			if(phonenumb == phonenumber)
			{
				SendClientMessage(playerid, COLOR_GRAD2, "Po³¹czenie nie mo¿e byæ zrealizowane...");
				return 1;
			}
			if(Mobile[playerid] != 255)
			{
				SendClientMessage(playerid, COLOR_GRAD2, "Aktualnie prowadzisz inn¹ rozmowê...");
				return 1;
			}
			for(new i = 0; i < MAX_PLAYERS; i++)
			{
				if(IsPlayerConnected(i))
				{
				 	new gpitemindex = GetUsedItemByItemId(i, ITEM_CELLPHONE);

  					if(!CanItemBeUsed(gpitemindex))
	 	 			{
		 	  				continue;
			  		}

   					new gpphonenumber = Items[gpitemindex][iAttr1];

					if(gpphonenumber == phonenumb && phonenumb != 0)
					{
						giveplayerid = i;
						Mobile[playerid] = giveplayerid; //caller connecting
						if(IsPlayerConnected(giveplayerid))
						{
						 	if(giveplayerid != INVALID_PLAYER_ID)
						 	{
						 	        if(CellTime[giveplayerid] != 0)
									{
											SendClientMessage(playerid, COLOR_GREY, "Zajête... Biip...Biip...biip");
											SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
                            				RemovePlayerAttachedObject(playerid, 4);
											return 1;
									}
									
                                	if(PlayerInfo[giveplayerid][pJailTime] > 0)
						  			{
						   					SendClientMessage(playerid, COLOR_GREY, "Abonament ma wy³¹czony telefon lub znajduje siê poza zasiêgiem sieci.");
						   					return 1;
						  			}
						  		
						  			if(PlayerInfo[giveplayerid][pWounded] > 0)
     					  			{
     			 						SendClientMessage(playerid, COLOR_GREY, "Abonament ma wy³¹czony telefon lub znajduje siê poza zasiêgiem sieci.");
     			 						return 1;
     					  			}
     					  			
									if(Mobile[giveplayerid] == 255)
									{
									new string2[128];
									    if(GetPVarInt(giveplayerid, "sound_off"))
     									{
															//new nick[32];
															format(string, sizeof(string), "SELECT `nick` FROM `vcard` WHERE `phonenumber` = %d AND `gphonenumber` = %d", gpphonenumber, phonenumber);
															mysql_query(string);
															mysql_store_result();
															mysql_fetch_row(nick);

															if(mysql_num_rows())
															{
															    SendClientMessage(giveplayerid, COLOR_PURPLE, "* Czujesz wibracje w kieszeni. *");
																format(string2, sizeof(string2), "Twój telefon wibruje... (wpisz /odbierz aby odebraæ) Dzwoni¹cy: %s", nick);
																format(query, 256, "INSERT INTO `received_history` (`gphonenumber`, `nick`, `date`, `phonenumber`) VALUES ('%d', '%s', '%d/%d/%d %02d:%02d:%02d', '%d')", phonenumber, nick, year, month, day, hour, minute, second, phonenumb);
																mysql_query(query);
																printf(query);
																mysql_store_result();
															}
															else
															{
																format(string2, sizeof(string2), "Twój telefon wibruje... (wpisz /odbierz aby odebraæ) Numer Dzwoni¹cego: %d", phonenumber);
																format(query, 256, "INSERT INTO `received_history` (`gphonenumber`, `nick`, `date`, `phonenumber`) VALUES ('%d', ' ', '%d/%d/%d %02d:%02d:%02d', '%d')", phonenumber, year, month, day, hour, minute, second, phonenumb);
																mysql_query(query);
																mysql_store_result();
															}
															mysql_free_result();

										}
										else if(PlayerInfo[playerid][pReservedPhone] == 1)
								 		{
								  			if(PlayerInfo[giveplayerid][pAdmin] > 0 && PlayerInfo[giveplayerid][pAdmin] != 3 && OnAdminDuty[giveplayerid] == 1)
								  			{
            												//new nick[32];
															format(string, sizeof(string), "SELECT `nick` FROM `vcard` WHERE `phonenumber` = %d AND `gphonenumber` = %d", gpphonenumber, phonenumber);
															mysql_query(string);
															mysql_store_result();
															mysql_fetch_row(nick);

															if(mysql_num_rows())
															{
																format(string2, sizeof(string2), "Twój telefon dzwoni... (wpisz /odbierz aby odebraæ) Dzwoni¹cy: %s", nick);
																format(query, 256, "INSERT INTO `received_history` (`gphonenumber`, `nick`, `date`, `phonenumber`) VALUES ('%d', '%s', '%d/%d/%d %02d:%02d:%02d', '%d')", phonenumber, nick, year, month, day, hour, minute, second, phonenumb);
																mysql_query(query);
																printf(query);
																mysql_store_result();
															}
															else
															{
																format(string2, sizeof(string2), "Twój telefon dzwoni... (wpisz /odbierz aby odebraæ) Numer Dzwoni¹cego: %d", phonenumber);
																format(query, 256, "INSERT INTO `received_history` (`gphonenumber`, `nick`, `date`, `phonenumber`) VALUES ('%d', ' ', '%d/%d/%d %02d:%02d:%02d', '%d')", phonenumber, year, month, day, hour, minute, second, phonenumb);
																mysql_query(query);
																mysql_store_result();
															}
															mysql_free_result();
								  			}
								  			else
								  			{
									  			format(string, sizeof(string), "Twój telefon dzwoni... (wpisz /odbierz aby odebraæ) Numer Dzwoni¹cego: Zastrze¿ony");
									  			format(query, 256, "INSERT INTO `received_history` (`gphonenumber`, `nick`, `date`, `phonenumber`) VALUES ('000000', 'Brak numeru', '%d/%d/%d %02d:%02d:%02d', '%d')", year, month, day, hour, minute, second, phonenumb);
												mysql_query(query);
												mysql_store_result();
								  			}
								 		}
								 		else
								 		{

															//new nick[32];
															format(string, sizeof(string), "SELECT `nick` FROM `vcard` WHERE `phonenumber` = %d AND `gphonenumber` = %d", gpphonenumber, phonenumber);
															mysql_query(string);
															mysql_store_result();
															mysql_fetch_row(nick);

															if(mysql_num_rows())
															{
																format(string2, sizeof(string2), "Twój telefon dzwoni... (wpisz /odbierz aby odebraæ) Dzwoni¹cy: %s", nick);
																format(query, 256, "INSERT INTO `received_history` (`gphonenumber`, `nick`, `date`, `phonenumber`) VALUES ('%d', '%s', '%d/%d/%d %02d:%02d:%02d', '%d')", phonenumber, nick, year, month, day, hour, minute, second, phonenumb);
																mysql_query(query);
																printf(query);
																mysql_store_result();
															}
															else
															{
																format(string2, sizeof(string2), "Twój telefon dzwoni... (wpisz /odbierz aby odebraæ) Numer Dzwoni¹cego: %d", phonenumber);
                                                                format(query, 256, "INSERT INTO `received_history` (`gphonenumber`, `nick`, `date`, `phonenumber`) VALUES ('%d', ' ', '%d/%d/%d %02d:%02d:%02d', '%d')", phonenumber, year, month, day, hour, minute, second, phonenumb);
																mysql_query(query);
																mysql_store_result();
															}
															mysql_free_result();
								 		}

										SendClientMessage(giveplayerid, COLOR_YELLOW, string2);
										GetPlayerPos(giveplayerid, PlayerInfo[giveplayerid][pPos_x], PlayerInfo[giveplayerid][pPos_y], PlayerInfo[giveplayerid][pPos_z]);
               							foreach(Player, id)
						    			{
        										if(!Audio_IsClientConnected(id)) continue;
								    			muzyka[id] = Audio_Play(id, PlayerInfo[giveplayerid][pSoundid]);
							   					Audio_Set3DPosition(id, muzyka[id], PlayerInfo[giveplayerid][pPos_x], PlayerInfo[giveplayerid][pPos_y], PlayerInfo[giveplayerid][pPos_z], 20.0);
										}
										GetPlayerNameMask(giveplayerid, sendername, sizeof(sendername));
										RingTone[giveplayerid] = 10;
										format(string, sizeof(string), "* Telefon %s dzwoni.", sendername);
										SendClientMessage(playerid, COLOR_WHITE, "WSKAZÓWKA: Aby rozmawiaæ przez telefon u¿ywaj T, a aby zakoñczyæ rozmowê wpisz /z.");
										ProxDetector(30.0, i, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
										CellTime[playerid] = 1;
										CellTime[giveplayerid] = 1;
										SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
                                    	SetPlayerAttachedObject(playerid, 4, 330, 6); // 4 = attachment slot, 330 = cellphone model, 6 = right hand
										return 1;
									}
								}
							}
						}
					}
				}
			SendClientMessage(playerid, COLOR_GRAD2, "Abonament ma wy³¹czony telefon lub znajduje siê poza zasiêgiem sieci.");
		}
		return 1;
	}
	if(strcmp(cmd, "/sms", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
		{
		 if(gPlayerLogged[playerid] == 0)
	  {
	   SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ zalogowany !");
	   return 1;
	  }
	
	  if(PlayerInfo[playerid][pWounded] > 0)
			{
			 SendClientMessage(playerid, COLOR_GREY, "Jesteœ nieprzytomny, nie mo¿esz siê odezwaæ.");
			 return 1;
			}
			
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /sms [numer telefonu] [tekst]");
				return 1;
			}
		
			new itemindex = GetUsedItemByItemId(playerid, ITEM_CELLPHONE);
			
			switch(itemindex)
	  {
	   case INVALID_ITEM_ID:
	   {
	    SendClientMessage(playerid, COLOR_GREY, "Nie posiadasz telefonu komórkowego.");
 	  	return 1;
	   }
	   case HAS_UNUSED_ITEM_ID:
	   {
	    SendClientMessage(playerid, COLOR_GREY, "Twój telefon jest wy³¹czony. Aby go w³¹czyæ, u¿yj /przedmioty uzyj [IdPrzedmiotu].");
 	  	return 1;
	   }
	  }
			
			new phonenumber = Items[itemindex][iAttr1];
			
			if(PlayerInfo[playerid][pJailTime] > 0)
			{
			 	SendClientMessage(playerid, COLOR_GRAD2, "Twój telefon zosta³ skonfiskowany na czas pobytu w wiêzieniu.");
			return 1;
			}
			
			GetPlayerNameMask(playerid, sendername, sizeof(sendername));
			if(CellularPhone[playerid] == 1)//Jak ma wyjêty telefon nie wysy³amy /me
			{
			}
			else
			{
			    ServerMe(playerid, "wyjmuje telefon.");
			}
			//format(string, sizeof(string), "* %s wyci¹ga telefon.", sendername);
			//ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			new phonenumb = strval(tmp);
			
   			
			// haxy
			new length = strlen(cmdtext);
			while ((idx < length) && (cmdtext[idx] <= ' '))
			{
				idx++;
			}
			new offset = idx;
			new result[128];
			while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
			{
				result[idx - offset] = cmdtext[idx];
				idx++;
			}
			result[idx - offset] = EOS;
			if(!strlen(result))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: (/t)ext [numer telefonu] [tekst]");
				return 1;
			}
	
			for(new i = 0; i < MAX_PLAYERS; i++)
			{
				if(IsPlayerConnected(i))
				{
				 new gpitemindex = GetUsedItemByItemId(i, ITEM_CELLPHONE);
			
  			if(!CanItemBeUsed(gpitemindex))
	 	 	{
		 	  continue;
			  }
			
   		new gpphonenumber = Items[gpitemindex][iAttr1];
   		
					if(gpphonenumber == phonenumb && phonenumb != 0)
					{
						giveplayerid = i;
						Mobile[playerid] = giveplayerid; //caller connecting
						if(IsPlayerConnected(giveplayerid))
						{
						 if(giveplayerid != INVALID_PLAYER_ID)
						 {
						  if(PhoneOnline[giveplayerid] > 0)
						  {
						   SendClientMessage(playerid, COLOR_GREY, "Gracz ma wy³¹czony telefon !");
						   return 1;
						  }

								GetPlayerName(giveplayerid, sendername, sizeof(sendername));
								RingTone[giveplayerid] =20;
								
								
								
								
								if(strlen(result) > SPLIT_TEXT_LIMIT)
								{
									new stext[128];

									strmid(stext, result, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
									format(string, sizeof(string), "Wys³ano SMS: %s...", stext);
									SendClientMessage(playerid, COLOR_YELLOW, string);

									strmid(stext, result, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
									format(string, sizeof(string), "...%s, na numer %d.", stext, gpphonenumber);
									SendClientMessage(playerid, COLOR_YELLOW, string);
									
									strmid(stext, result, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
									format(string, sizeof(string), "SMS: %s...", stext);
									SendClientMessage(giveplayerid, COLOR_YELLOW, string);

									strmid(stext, result, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
									format(string, sizeof(string), "...%s, Nadawca(%d).", stext,phonenumber);
									SendClientMessage(giveplayerid, COLOR_YELLOW, string);
								}
								else
								{
									format(string, sizeof(string), "Wys³ano SMS: %s, na numer %d.", result, gpphonenumber);
									SendClientMessage(playerid, COLOR_YELLOW, string);
									//format(string, sizeof(string), "SMS: %s, Nadawca(%d)", result, phonenumber);
									//SendClientMessage(giveplayerid, COLOR_YELLOW, string);
									
									new nick[32];
											format(string, sizeof(string), "SELECT `nick` FROM `vcard` WHERE `phonenumber` = %d AND `gphonenumber` = %d", gpphonenumber, phonenumber);
											mysql_query(string);
											mysql_store_result();
											mysql_fetch_row(nick);

											if(mysql_num_rows())
											{
													format(string, sizeof(string), "SMS: %s, Nadawca: %s.", result, nick);
													SendClientMessage(giveplayerid, COLOR_YELLOW, string);
											}
											else
											{
														format(string, sizeof(string), "SMS: %s, Nadawca(%d)", result, phonenumber);
														SendClientMessage(giveplayerid, COLOR_YELLOW, string);
											}
											mysql_free_result();
									
									
									
									
								}
	
								//SendClientMessage(playerid,  COLOR_YELLOW, string);
								format(string, sizeof(string), "~r~$-%d", txtcost);
								GameTextForPlayer(playerid, string, 5000, 1);
								GivePlayerMoneyEx(playerid,-txtcost);
								/*SBizzInfo[2][sbTill] += txtcost;
								ExtortionSBiz(2, txtcost);*/
					   			PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
					   			Mobile[playerid] = 255;
								return 1;
							}
						}
					}
				}
			}
			SendClientMessage(playerid, COLOR_GRAD2, "Wiadomoœæ tekstowa niedostarczona...");
		}
		return 1;
	}
//----------------------------------[pickup]-----------------------------------------------

	if(strcmp(cmd, "/odbierz", true) == 0 || strcmp(cmd, "/od", true) == 0)
	{
    if(IsPlayerConnected(playerid))
		{
			new item = GetUsedItemByItemId(playerid, ITEM_CELLPHONE);
			if (item == HAS_UNUSED_ITEM_ID || item == INVALID_ITEM_ID) return 1;
		
   			if(Mobile[playerid] != 255)
			{
				SendClientMessage(playerid, COLOR_GRAD2, "Akrualnie rozmawiasz przez telefon...");
				return 1;
			}
			
			for(new i = 0; i < MAX_PLAYERS; i++)
			{
				if(IsPlayerConnected(i))
				{
					if(Mobile[i] == playerid)
					{
						Mobile[playerid] = i; //caller connecting
						SendClientMessage(i,  COLOR_GRAD2, "Odebrano telefon.");
						GetPlayerNameEx(playerid, sendername, sizeof(sendername));
						format(string, sizeof(string), "* %s odebra³ rozmowe telefoniczn¹.", sendername);
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						foreach(Player, id)
    					{
							Audio_Stop(id, muzyka[id]);
						}
					    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
                        SetPlayerAttachedObject(playerid, 4, 330, 6); // 4 = attachment slot, 330 = cellphone model, 6 = right hand
						RingTone[playerid] = 0;
					}

				}
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/zakoncz", true) == 0 || strcmp(cmd, "/z", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
		{
			new caller = Mobile[playerid];
			if(IsPlayerConnected(caller))
			{
			 if(caller != INVALID_PLAYER_ID)
			 {
					if(caller != 255)
					{
						if(caller < 255)
						{
							SendClientMessage(caller,  COLOR_GRAD2, "   Roz³¹czy³ siê.");
							CellTime[caller] = 0;
							CellTime[playerid] = 0;
							SendClientMessage(playerid,  COLOR_GRAD2, "   Roz³¹czy³eœ siê.");
							Mobile[caller] = 255;
							foreach(Player, id)
    						{
								Audio_Stop(id, muzyka[id]);
							}
						    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
                            RemovePlayerAttachedObject(playerid, 4);
                            SetPlayerSpecialAction(caller, SPECIAL_ACTION_STOPUSECELLPHONE);
                            RemovePlayerAttachedObject(caller, 4);

						}
						Mobile[playerid] = 255;
						CellTime[playerid] = 0;
						RingTone[playerid] = 0;
						return 1;
					}
				}
			}
			else if(NotPlayersMobile[playerid] == 1)
			{
			 	Mobile[playerid] = 255;
				CellTime[playerid] = 0;
				RingTone[playerid] = 0;
				foreach(Player, id)
    			{
					Audio_Stop(id, muzyka[id]);
				}
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
                RemovePlayerAttachedObject(playerid, 4);
				SendClientMessage(playerid,  COLOR_GRAD2, "Roz³¹czy³eœ siê.");
				return 1;
			}
			SendClientMessage(playerid,  COLOR_GRAD2, "   Twój telefon jest w kieszeni.");
			CellTime[playerid] = 0;
			RingTone[playerid] = 0;
		}
		return 1;
	}
//----------------------------------[TIME]-----------------------------------------------
	if(strcmp(cmd, "/time", true) == 0 || strcmp(cmd, "/zegarek", true) == 0)
	{
  		if(IsPlayerConnected(playerid))
	 	{
	  		if(HasPlayerItemByType(playerid, ITEM_WATCH || ITEM_WATCH2))
	  		{
 				 new mtext[20];
				new year, month,day;
 				getdate(year, month, day);
 				if(month == 1) { mtext = "styczen"; }
 				else if(month == 2) { mtext = "luty"; }
 				else if(month == 3) { mtext = "marzec"; }
 				else if(month == 4) { mtext = "kwiecien"; }
 				else if(month == 5) { mtext = "maj"; }
 				else if(month == 6) { mtext = "czerwiec"; }
 				else if(month == 7) { mtext = "lipiec"; }
 				else if(month == 8) { mtext = "sierpien"; }
 				else if(month == 9) { mtext = "wrzesien"; }
 				else if(month == 10) { mtext = "pazdziernik"; }
 				else if(month == 11) { mtext = "listopad"; }
 				else if(month == 12) { mtext = "grudzien"; }
    			new hour,minuite,second;
	 			gettime(hour,minuite,second);
	 			FixHour(hour);
	 			hour = shifthour;
	 			
	 			if (minuite < 10)
	 			{
	 				if (PlayerInfo[playerid][pJailTime] > 0)
	 				{
	 					format(string, sizeof(string), "~y~%d %s~n~~g~|~w~%d:0%d~g~|~n~~w~Pozostaly czas wiezenia: %d sek", day, mtext, hour, minuite, PlayerInfo[playerid][pJailTime]-10);
	 				}
	 				else if (PlayerInfo[playerid][pNeedMedicTime] > 0)
	    			{
	     				format(string, sizeof(string), "~y~%d %s~n~~g~|~w~%d:0%d~g~|~n~~w~Pozostaly czas leczenia: %d sek", day, mtext, hour, minuite, PlayerInfo[playerid][pNeedMedicTime]);
	    			}
	 				else
	 				{
	 					format(string, sizeof(string), "~y~%d %s~n~~g~|~w~%d:0%d~g~|", day, mtext, hour, minuite);
	 				}
	 			}
	 			else
	 			{
	 				if (PlayerInfo[playerid][pJailTime] > 0)
	 				{
	 					format(string, sizeof(string), "~y~%d %s~n~~g~|~w~%d:%d~g~|~n~~w~Pozostaly czas wiezenia: %d sek", day, mtext, hour, minuite, PlayerInfo[playerid][pJailTime]-10);
	 				}
	 				else if (PlayerInfo[playerid][pNeedMedicTime] > 0)
	    			{
	     				format(string, sizeof(string), "~y~%d %s~n~~g~|~w~%d:%d~g~|~n~~w~Pozostaly czas leczenia: %d sek", day, mtext, hour, minuite, PlayerInfo[playerid][pNeedMedicTime]);
	    			}
 					else
	 				{
	 					format(string, sizeof(string), "~y~%d %s~n~~g~|~w~%d:%d~g~|", day, mtext, hour, minuite);
	 				}
	 			}
	 			GameTextForPlayer(playerid, string, 5000, 1);
	 		
    			GetPlayerNameMask(playerid, sendername, sizeof(sendername));
		 		format(string, sizeof(string), "* %s spogl¹da na zegarek.", sendername);
			 	ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			
			
		 		if (GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && !IsPlayerBusy(playerid))
			 	{
			  		ApplyAnimation(playerid, "cop_ambient", "Coplook_watch", 4.0, 0, 0, 0, 0, 0);
			 	}
	 	}
	 	else
	  	{
	   		if (PlayerInfo[playerid][pJailTime] > 0)
	   		{
	    		format(string, sizeof(string), "~w~Pozostaly czas wiezenia: %d sek", PlayerInfo[playerid][pJailTime]-10);
    			GameTextForPlayer(playerid, string, 5000, 1);
	   		}
	   		if (PlayerInfo[playerid][pNeedMedicTime] > 0)
	   		{
	    		format(string, sizeof(string), "~w~Pozostaly czas w szpitalu: %d sek", PlayerInfo[playerid][pNeedMedicTime]);
    			GameTextForPlayer(playerid, string, 5000, 1);
	   		}
	   		SendClientMessage(playerid, COLOR_GREY, "   Nie masz zegarka !");
		}
	return 1;
	}
}
//----------------------{HOUSES}-------------------
	/*if(strcmp(cmd, "/house", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
		{
		    if(PlayerInfo[playerid][pAdmin] >= 1337)
		    {
				tmp = strtok(cmdtext, idx);
				if(!strlen(tmp))
				{
					SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /house [numerdomu]");
					return 1;
				}
				new housenum = strval(tmp);
				SetPlayerInterior(playerid,HouseInfo[housenum][hInt]);
				SetPlayerPosEx(playerid,HouseInfo[housenum][hExitx],HouseInfo[housenum][hExity],HouseInfo[housenum][hExitz]);
				SetPlayerVirtualWorldEx(playerid, HouseInfo[housenum][hVW]);
				GameTextForPlayer(playerid, "~w~Teleportacja", 5000, 1);
				PlayerInfo[playerid][pInt] = HouseInfo[housenum][hInt];
				PlayerInfo[playerid][pLocal] = housenum;
				PlayerInfo[playerid][pLocalType] = CONTENT_TYPE_HOUSE;
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/houseo", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
		{
		    if(PlayerInfo[playerid][pAdmin] >= 1337)
		    {
				tmp = strtok(cmdtext, idx);
				if(!strlen(tmp))
				{
					SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /houseo [housenumber]");
					return 1;
				}
				new housenum = strval(tmp);
				SetPlayerPosEx(playerid,HouseInfo[housenum][hEntrancex],HouseInfo[housenum][hEntrancey],HouseInfo[housenum][hEntrancez]);
				GameTextForPlayer(playerid, "~w~Teleportacja", 5000, 1);
			}
		}
		return 1;
	}
	
	if(strcmp(cmd, "/edit", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
		{
			if(PlayerInfo[playerid][pAdmin] < 1337)
			{
				SendClientMessage(playerid, COLOR_GRAD2, "   Nie jesteœ administratorem !");
				return 1;
			}
			new x_job[64];
			x_job = strtok(cmdtext, idx);
			if(!strlen(x_job)) {
				SendClientMessage(playerid, COLOR_WHITE, "|__________________ Edytuj __________________|");
				SendClientMessage(playerid, COLOR_WHITE, "UZYJ: /edit [nazwa] [kwota] (U¿ywane przez domy i przedsiêbiorstwa)");
				SendClientMessage(playerid, COLOR_GREY, "Komndy: Poziom, Cena, Fundusze, Produkty, MaxProdukty");
				SendClientMessage(playerid, COLOR_WHITE, "|____________________________________________|");
				return 1;
			}
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /edit [nazwa] [iloœæ]");
				return 1;
			}
			new proplev = strval(tmp);
	  //if(strcmp(x_job,"car",true) == 0)
	  for(new i = 0; i < sizeof(HouseInfo); i++)
			{
				if (PlayerToPoint(3, playerid,HouseInfo[i][hEntrancex], HouseInfo[i][hEntrancey], HouseInfo[i][hEntrancez]))
				{
					format(string, sizeof(string), "Dom: %d", i);
					SendClientMessage(playerid, COLOR_GRAD2, string);
					if(proplev > 0)
					{
						else if(strcmp(x_job,"wejscie",true) == 0)
						{
						 new Float:p2X, Float:p2Y, Float:p2Z;
						 GetPlayerPos(playerid, p2X, p2Y, p2Z);
						 HouseInfo[i][hEntrancex] = p2X;
						 HouseInfo[i][hEntrancey] = p2Y;
						 HouseInfo[i][hEntrancez] = p2Z;
						}
					}
				}
			}
			for(new i = 0; i < sizeof(BizzInfo); i++)
			{
			 if(BizzInfo[i][bId] != -1)
			 {
				 if (PlayerToPoint(3, playerid,BizzInfo[i][bEntranceX], BizzInfo[i][bEntranceY], BizzInfo[i][bEntranceZ]))
				 {
				 	format(string, sizeof(string), "Biz: %d", i);
				 	SendClientMessage(playerid, COLOR_GRAD2, string);
				 	if(proplev > 0)
				 	{
       if(strcmp(x_job,"fundusze",true) == 0)
					  {
			 				BizzInfo[i][bTill] = proplev;
			 			}
			 			else if(strcmp(x_job,"produkty",true) == 0)
			 		 {
			 				BizzInfo[i][bProducts] = proplev;
			 			}
			 			else if(strcmp(x_job,"maxprodukty",true) == 0)
			 		 {
				 			BizzInfo[i][bMaxProducts] = proplev;
		 				}
		 			}
		 		}
		 	}
	 	}
			for(new i = 0; i < sizeof(SBizzInfo); i++)
			{
				if (PlayerToPoint(3, playerid,SBizzInfo[i][sbEntranceX], SBizzInfo[i][sbEntranceY], SBizzInfo[i][sbEntranceZ]))
				{
					format(string, sizeof(string), "SBiz: %d", i);
					SendClientMessage(playerid, COLOR_GRAD2, string);
					if(proplev > 0)
					{
					    if(strcmp(x_job,"poziom",true) == 0)
					    {
							SBizzInfo[i][sbLevelNeeded] = proplev;
						}
						else if(strcmp(x_job,"cena",true) == 0)
					    {
							SBizzInfo[i][sbBuyPrice] = proplev;
						}
						else if(strcmp(x_job,"fundusze",true) == 0)
					    {
							SBizzInfo[i][sbTill] = proplev;
						}
						else if(strcmp(x_job,"produkty",true) == 0)
					    {
							SBizzInfo[i][sbProducts] = proplev;
						}
						else if(strcmp(x_job,"maxprodukty",true) == 0)
					    {
							SBizzInfo[i][sbMaxProducts] = proplev;
						}
					}
				}
			}
			format(string, sizeof(string), "Zmieni³es wartoœæ: %s.", x_job);
			SendClientMessage(playerid, COLOR_WHITE, string);
		}
		return 1;
	}
	
	if(strcmp(cmd, "/home", true) == 0 || strcmp(cmd, "/dom", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
		{
		 if(PizzaDuty[playerid] == 1)
   {
    SendClientMessage(playerid, COLOR_GRAD1, "Nie mo¿esz tego teraz zrobiæ.");
    return 1;
   }

			if(PlayerInfo[playerid][pPhousekey] != 255)
			{
				SetPlayerCheckpoint(playerid,HouseInfo[PlayerInfo[playerid][pPhousekey]][hEntrancex], HouseInfo[PlayerInfo[playerid][pPhousekey]][hEntrancey], HouseInfo[PlayerInfo[playerid][pPhousekey]][hEntrancez], 4.0);
				GameTextForPlayer(playerid, "~w~Punkt orientacyjny - ~r~Dom", 5000, 1);
				gPlayerCheckpointStatus[playerid] = CHECKPOINT_HOME;
			}
			else
			{
				GameTextForPlayer(playerid, "~w~Jestes bezdomny", 5000, 1);
			}
		}
		return 1;
	}*/

//-----------------------------------[HEAL]-------------------------------------------------------------------------
	if(strcmp(cmd, "/heal", true) == 0 || strcmp(cmd, "/ulecz", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
		{
			tmp = strtok(cmdtext, idx);
			GetPlayerName(playerid, sendername, sizeof(sendername));
			//new location = PlayerInfo[playerid][pLocal];
			
			/*if(!strlen(tmp))
			{
			 if(PlayerToPoint(2.0, playerid, 240.4544,112.7762,1003.2188)||PlayerToPoint(2.0, playerid, 229.4013,155.1738,1003.0234))
			 {
			  SetPlayerHealthEx(playerid,100.0);
					PlayerPlaySound(playerid, 1150, 0.0, 0.0, 0.0);
					format(string, sizeof(string), "Zosta³eœ uzdrowiony");
					SendClientMessage(playerid, TEAM_GREEN_COLOR,string);
					return 1;
			 }
			 if(PlayerToPoint(3.0, playerid, 200.6801,167.1675,1003.0234) || PlayerToPoint(3.0, playerid, 1526.1028,-1677.8374,5.8906))
				{
					if(location < 99)
					{
						if(HouseInfo[location][hArm] == 1 && IsACop(playerid))
						{
							format(string, sizeof(string), "* %s zabra³ kamizelkê.", sendername);
							ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
							TogglePlayerControllable(playerid, 0);
							GetPlayerPos(playerid, Unspec[playerid][sPx], Unspec[playerid][sPy], Unspec[playerid][sPz]);
							Unspec[playerid][sPint] = PlayerInfo[playerid][pInt];
							Unspec[playerid][sLocal] = PlayerInfo[playerid][pLocal];
							SetPlayerPosEx(playerid,1527.5,-12.1,1002.0);
							PlayerInfo[playerid][pLocal] = 255;
							SetPlayerInterior(playerid,99);
							Spectate[playerid] = 257;
							SetPlayerArmour(playerid, 100);
						}
						else
						{
							format(string, sizeof(string), "To miejsce nie ma kamizelki.");
							SendClientMessage(playerid, TEAM_GREEN_COLOR,string);
						}
						
						if(HouseInfo[location][hHel] == 1)
						{
							new Float:tempheal;
							GetPlayerHealth(playerid,tempheal);
							if ( tempheal < 100.0)
							{
								SetPlayerHealthEx(playerid,100.0);
								PlayerPlaySound(playerid, 1150, 0.0, 0.0, 0.0);
								format(string, sizeof(string), "Zosta³eœ uzdrowiony o 100 hp.");
								SendClientMessage(playerid, TEAM_GREEN_COLOR,string);
							}
							else
							{
								SendClientMessage(playerid, TEAM_GREEN_COLOR,"Jesteœ zdrowy jak ryba! Nie ma co siê leczyæ!");
							}
						}
						else
						{
							format(string, sizeof(string), "Nie mo¿na dokonaæ tutaj aktualizacji.");
							//SendClientMessage(playerid, TEAM_GREEN_COLOR,string);
						}
						return 1;
					}
					else if(location == 101)//Restaurant
					{
					    new Float:tempheal;
						GetPlayerHealth(playerid,tempheal);
						if ( tempheal < 100.0)
						{
							SetPlayerHealthEx(playerid,100.0);
							PlayerPlaySound(playerid, 1150, 0.0, 0.0, 0.0);
							format(string, sizeof(string), "Zosta³eœ uzdrowiony");
							SendClientMessage(playerid, TEAM_GREEN_COLOR,string);
						}
						else
						{
							SendClientMessage(playerid, TEAM_GREEN_COLOR,"Jesteœ zdrów jak ryba! Nie ma co siê leczyæ!");
						}
					}
					else if((location == 102 || PlayerToPoint(3.0, playerid, 1526.1028,-1677.8374,5.8906))&& IsACop(playerid))//Police Armoury
					{
					    SetPlayerHealthEx(playerid,100.0);
					    format(string, sizeof(string), "* %s zalo¿y³ na siebie kamizelkê.", sendername);
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						TogglePlayerControllable(playerid, 0);
						GetPlayerPos(playerid, Unspec[playerid][sPx], Unspec[playerid][sPy], Unspec[playerid][sPz]);
						Unspec[playerid][sPint] = PlayerInfo[playerid][pInt];
						Unspec[playerid][sLocal] = PlayerInfo[playerid][pLocal];
						SetPlayerPosEx(playerid,1527.5,-12.1,1002.0);
						PlayerInfo[playerid][pLocal] = 255;
						SetPlayerInterior(playerid,99);
						Spectate[playerid] = 257;
						SetPlayerArmour(playerid, 100);
						return 1;
					}
				}
				else
				{
					SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /ulecz [IdGracza/CzêœæNazwy]");
					return 1;
				}
			}*/
			
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /ulecz [IdGracza/CzêœæNazwy]");
				return 1;			
			}
			
			giveplayerid = ReturnUser(tmp);
			
			if (giveplayerid == playerid)
			{
				SendClientMessage(playerid, COLOR_GRAD1, "Nie mo¿esz uleczyæ siebie samego!");
				return 1;
			}
			if (IsPlayerConnected(giveplayerid))
			{
			 if(giveplayerid != INVALID_PLAYER_ID)
			 {
					GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
					GetPlayerName(playerid, sendername, sizeof(sendername));
					//new giveambu = GetPlayerVehicleID(giveplayerid);
					//new playambu = GetPlayerVehicleID(playerid);
					if(PlayerInfo[playerid][pMember]==4||PlayerInfo[playerid][pLeader]==4 || ((PlayerInfo[playerid][pMember]==3 || PlayerInfo[playerid][pLeader]==3) && PlayerInfo[playerid][pRank] == 2))//model
					{
					  if(GetDistanceBetweenPlayers(playerid, giveplayerid) < 4)
					  {
							new Float:tempheal;
							GetPlayerHealth(giveplayerid,tempheal);
							if(tempheal >= 100.0)
							{
								SendClientMessage(playerid, TEAM_GREEN_COLOR,"Ten gracz nie potrzebuje uzdrowienia.");
								return 1;
							}
							//if(GetPlayerMoneyEx(playerid) > moneys)
							//{
							 format(string, sizeof(string), "~y~Uzdrowiles ~n~~w~%s", giveplayer);
							 GameTextForPlayer(playerid, string, 5000, 1);
							 //GivePlayerMoneyEx(playerid,moneys);
							 //GivePlayerMoneyEx(giveplayerid,-moneys);
							 new hp = 0;

					   hp = 100;
					   SetPlayerHealthEx(giveplayerid, 100);

						 	PlayerPlaySound(playerid, 1150, 0.0, 0.0, 0.0);
						 	PlayerPlaySound(giveplayerid, 1150, 0.0, 0.0, 0.0);
						 	format(string, sizeof(string), "Zosta³eœ uzdrowiony o %d pkt ¿ycia",hp);
						 	SendClientMessage(giveplayerid, TEAM_GREEN_COLOR,string);

					  /*}
					  else
					  {
					   SendClientMessage(playerid, COLOR_GRAD1, "Ta osoba nie ma tylu pieniêdzy !");
					   return 1;
					  }*/
						}
						/*else
						{
							SendClientMessage(playerid, COLOR_GRAD1, "   Nie jestes w pojezdzie medycznym! !");
							return 1;
						}*/
					}
					else
					{
						SendClientMessage(playerid, COLOR_GRAD1, "Nie jesteœ uprawniony do u¿ycia tej komendy!");
						return 1;
					}
				}
			}
			else
			{
				format(string, sizeof(string), "   %d nie jest aktywnym graczem.", giveplayerid);
				SendClientMessage(playerid, COLOR_GRAD1, string);
			}
		}
		return 1;
	}
//----------------------------------[RECON]-----------------------------------------------
	if(strcmp(cmd, "/uszy", true) == 0 && PlayerInfo[playerid][pAdmin] > 3)
	{
	    if(IsPlayerConnected(playerid))
	    {
			if (!BigEar[playerid])
			{
				BigEar[playerid] = 1;
				SendClientMessage(playerid, COLOR_GRAD2, "Twoje uszy uros³y");
			}
			else if (BigEar[playerid])
			{
				(BigEar[playerid] = 0);
				SendClientMessage(playerid, COLOR_GRAD2, "Twoje uszy zmala³y");
			}
		}
		
		return 1;
	}
	if(strcmp(cmd, "/setstat", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
	  if(PlayerInfo[playerid][pAdmin] != 1337)
	  {
	   SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ administratorem!");
	   return 1;
	  }
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /setstat [id/ImiêLubNazwisko] [statkod] [liczba]");
				SendClientMessage(playerid, COLOR_GRAD4, "|1 Level |4 Model ");
				SendClientMessage(playerid, COLOR_GRAD3, "|5 KwotaBankowa |6 NrTelefonu");
				SendClientMessage(playerid, COLOR_GRAD2, "|8 KluczDoDomu |9 KluczDoFirmy");
				SendClientMessage(playerid, COLOR_GRAD2, "|12 Det |13 Adwokat |14 Mechanik |15 Reporter |16 Z³odziej |17 Diler |18 Dziwka |19 Bokser");
				SendClientMessage(playerid, COLOR_GRAD2, "|20 Wiek |21 Member |22 Skin |24 Ostrze¿enia |25 Ma³¿eñstwo |26 Ma³¿eñstwo (z kim)");
				SendClientMessage(playerid, COLOR_GRAD2, "|55 CK |66 JailTime |77 Praca |88 Czas kontraktu");
				return 1;
			}
			giveplayerid = ReturnUser(tmp);
            if(IsPlayerConnected(giveplayerid))
	    	{
	    	    if(giveplayerid != INVALID_PLAYER_ID)
	    	    {
					tmp = strtok(cmdtext, idx);
					if(!strlen(tmp))
					{
						SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /setstat [id/ImiêLubNazwisko] [statkod] [liczba]");
						SendClientMessage(playerid, COLOR_GRAD4, "|1 Poziom |4 Model ");
						SendClientMessage(playerid, COLOR_GRAD3, "|5 KwotaBankowa");
						SendClientMessage(playerid, COLOR_GRAD2, "|8 KluczDoDomu |9 KluczDoFirmy");
						SendClientMessage(playerid, COLOR_GRAD2, "|12 Det |13 Adwokat |14 Mechanik |15 Reporter |16 Z³odziej |17 Diler |18 Dziwka |19 Bokser");
						SendClientMessage(playerid, COLOR_GRAD2, "|20 Wiek |21 Member |22 Skin |24 Ostrze¿enia |25 Ma³¿eñstwo |26 Ma³¿eñstwo (z kim)");
						SendClientMessage(playerid, COLOR_GRAD2, "|55 CK |66 JailTime |77 Praca |88 Czas kontraktu");
						return 1;
					}
					new stat;
					stat = strval(tmp);
					tmp = strtok(cmdtext, idx);
					if(!strlen(tmp))
					{
						SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /setstat [id/ImiêLubNazwisko] [statkod] [liczba]");
						SendClientMessage(playerid, COLOR_GRAD4, "|1 Poziom |4 Model ");
						SendClientMessage(playerid, COLOR_GRAD3, "|5 KwotaBankowa");
						SendClientMessage(playerid, COLOR_GRAD2, "|8 KluczDoDomu |9 KluczDoFirmy");
						SendClientMessage(playerid, COLOR_GRAD2, "|12 Det |13 Adwokat |14 Mechanik |15 Reporter |16 Z³odziej |17 Diler |18 Dziwka |19 Bokser");
						SendClientMessage(playerid, COLOR_GRAD2, "|20 Wiek |21 Member |22 Skin |24 Ostrze¿enia |25 Ma³¿eñstwo |26 Ma³¿eñstwo (z kim)");
						SendClientMessage(playerid, COLOR_GRAD2, "|55 CK |66 JailTime |77 Praca |88 Czas kontraktu");
						return 1;
					}
					new amount;
					amount = strval(tmp);
					if (PlayerInfo[playerid][pAdmin] >= 4)
					{
						switch (stat)
						{
							case 1:
							{
								PlayerInfo[giveplayerid][pLevel] = amount;
								format(string, sizeof(string), "   Zmieni³eœ poziom gracza na %d", amount);
							}
       case 4:
							{
								PlayerInfo[giveplayerid][pModel] = amount;
								format(string, sizeof(string), "   Gracz otrzyma³ model %d", amount);
							}
							case 5:
							{
								PlayerInfo[giveplayerid][pAccount] = amount;
								format(string, sizeof(string), "   Gracza konto bankowe wynosi $%d", amount);
							}
							case 8:
							{
								PlayerInfo[giveplayerid][pPhousekey] = amount;
								format(string, sizeof(string), "   Klucz do mieszkania gracza zmieniony na %d", amount);
							}
							case 9:
							{
								PlayerInfo[giveplayerid][pBusiness] = amount;
								format(string, sizeof(string), "   Klusz do przedsiêbiorstwa gracza zmieniony na %d", amount);
							}
							case 12:
							{
								PlayerInfo[giveplayerid][pDetSkill] = amount;
								format(string, sizeof(string), "   Umiejêtnoœc detektywistyczna gracza zmieniona na %d", amount);
							}
							case 13:
							{
								PlayerInfo[giveplayerid][pLawSkill] = amount;
								format(string, sizeof(string), "   Umiejêtnoœc adwokata gracza zmieniona na %d", amount);
							}
							case 14:
							{
								PlayerInfo[giveplayerid][pMechSkill] = amount;
								format(string, sizeof(string), "   Umiejêtnoœc mechanika gracza zmieniona na %d", amount);
							}
							case 15:
							{
								PlayerInfo[giveplayerid][pNewsSkill] = amount;
								format(string, sizeof(string), "   Umiejêtnoœc reporterska gracza zmieniona na %d", amount);
							}
							case 16:
							{
								PlayerInfo[giveplayerid][pJackSkill] = amount;
								format(string, sizeof(string), "   Umiejêtnoœc w³amywania gracza zmieniona na %d", amount);
							}
							case 17:
							{
								PlayerInfo[giveplayerid][pDrugsSkill] = amount;
								format(string, sizeof(string), "   Umiejêtnoœc handlowania dragami gracza zmieniona na %d", amount);
							}
							case 18:
							{
								PlayerInfo[giveplayerid][pSexSkill] = amount;
								format(string, sizeof(string), "   Umiejêtnoœc sprawiania przyjemnoœci gracza zmieniona na %d", amount);
							}
							case 19:
							{
								PlayerInfo[giveplayerid][pBoxSkill] = amount;
								format(string, sizeof(string), "   Umiejêtnoœc bokserska gracza zmieniona na %d", amount);
							}
							case 20:
							{
								PlayerInfo[giveplayerid][pAge] = amount;
								format(string, sizeof(string), "   Wiek gracza zmieniony na %d", amount);
							}
							case 21:
							{
								PlayerInfo[giveplayerid][pMember] = amount;
								format(string, sizeof(string), "   Cz³onkostwo gracza zmienione na %d", amount);
							}
							case 22:
							{
								PlayerInfo[giveplayerid][pChar] = amount;
								format(string, sizeof(string), "   Skin gracza zmieniony na %d", amount);
							}
							case 24:
							{
								PlayerInfo[giveplayerid][pWarns] = amount;
								format(string, sizeof(string), "   Zmieni³eœ iloœæ ostrze¿eñ gracza na %d", amount);
							}
							case 25:
							{
								PlayerInfo[giveplayerid][pMarried] = amount;
								format(string, sizeof(string), "   Gracz jest zamê¿ny (0-nie;1-tak): %d", amount);
							}
							case 26:
							{
								PlayerInfo[giveplayerid][pMarriedTo] = amount;
								format(string, sizeof(string), "   Gracz jest w zwi¹zku z %d", amount);
							}
							case 55:
							{
								PlayerInfo[giveplayerid][pCK] = amount;
								format(string, sizeof(string), "   Gracz nie zyje: %d [1-tak;0-nie]", amount);
								Kick(giveplayerid);
							}
							case 66:
							{
								PlayerInfo[giveplayerid][pJailTime] = amount;
								format(string, sizeof(string), "   Czas pobytu w wiezieniu zmieniono na %d sekund", amount);
							}
							case 77:
							{
								PlayerInfo[giveplayerid][pJob] = amount;
								format(string, sizeof(string), "   Praca gracza zmieniona na %d", amount);
							}
							case 88:
							{
								PlayerInfo[giveplayerid][pContractTime] = amount;
								format(string, sizeof(string), "   Czas kontraktu gracza zmieniony na %d", amount);
							}
							default:
							{
								format(string, sizeof(string), "   B³êdny kod statystyk", amount);
							}

						}
						SendClientMessage(playerid, COLOR_GRAD1, string);
					}
					else
					{
						SendClientMessage(playerid, COLOR_GRAD1, "Nie jesteœ uprawniony do u¿ycia tej komendy!");
					}
				}//not valid id
			}//not connected
		}
		return 1;
	}
//----------------------------------[SETINT]-----------------------------------------------
	
//----------------------------------[SKYDIVE]------------------------------------------------
	if(strcmp(cmd, "/skydive", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
			if(PlayerInfo[playerid][pAdmin] >= 2 && PlayerInfo[playerid][pAdmin] != 3)
			{
				new Float:posx, Float:posy, Float:posz;
				GetPlayerPos(playerid, posx, posy, posz);
				if (IsPlayerConnected(playerid))
				{
					GivePlayerWeaponEx2(playerid, 46, 0);
					SetPlayerPosEx(playerid,posx, posy, posz+1500);
					SendClientMessage(playerid, COLOR_WHITE, "GO!! GO!! GO!!");
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "Nie jesteœ uprawniony do u¿ycia tej komendy!");
			}
		}
		return 1;
	}
//----------------------------------[FOURDIVE]------------------------------------------------
	if(strcmp(cmd, "/fourdive", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
	  if (PlayerInfo[playerid][pAdmin] >= 1337)
			{
		 	tmp = strtok(cmdtext, idx);
		 	if(!strlen(tmp))
		 	{
			 	SendClientMessage(playerid, COLOR_GRAD2, "Wpisz: /fourdive [playerid1] [playerid2] [playerid3] [playerid4]");
		 		return 1;
		 	}
			 new para1;
		 	new para2;
		 	new para3;
			 new para4;
		 	para1 = strval(tmp);
		 	tmp = strtok(cmdtext, idx);
		 	para2 = strval(tmp);
		 	tmp = strtok(cmdtext, idx);
		 	para3 = strval(tmp);
		 	tmp = strtok(cmdtext, idx);
		 	para4 = strval(tmp);
				if (IsPlayerConnected(para1)){ GivePlayerWeaponEx2(para1, 46, 0); SetPlayerPosEx(para1,1536.0, -1360.0, 1350.0);SetPlayerInterior(para1,0);PlayerInfo[para1][pInt] = 0;SendClientMessage(para1, COLOR_WHITE, "GO!! GO!! GO!!");}
				if ((IsPlayerConnected(para2)) && (para2>0)) { GivePlayerWeaponEx2(para2, 46, 0); SetPlayerPosEx(para2,1536.0, -1345.0, 1350.0);SetPlayerInterior(para2,0);PlayerInfo[para2][pInt] = 0;SendClientMessage(para2, COLOR_RED, "GO!! GO!! GO!!");}
				if ((IsPlayerConnected(para3)) && (para3>0)) { GivePlayerWeaponEx2(para3, 46, 0); SetPlayerPosEx(para3,1552.0, -1345.0, 1350.0);SetPlayerInterior(para3,0);PlayerInfo[para3][pInt] = 0;SendClientMessage(para3, COLOR_RED, "GO!! GO!! GO!!");}
				if ((IsPlayerConnected(para4)) && (para4>0)) { GivePlayerWeaponEx2(para4, 46, 0); SetPlayerPosEx(para4,1552.0, -1360.0, 1350.0);SetPlayerInterior(para4,0);PlayerInfo[para4][pInt] = 0;SendClientMessage(para4, COLOR_RED, "GO!! GO!! GO!!");}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "Nie jesteœ uprawniony do u¿ycia tej komendy!");
			}
		}
		return 1;
	}
//----------------------------------[INVITE]------------------------------------------------
//----------------------------------[UNINVITE]------------------------------------------------
	if(strcmp(cmd, "/uninvite", true) == 0 || strcmp(cmd, "/zwolnij", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /zwolnij [IdGracza/CzêœæNazwy]");
				return 1;
			}
			new para1;
			para1 = ReturnUser(tmp);
			if (PlayerInfo[playerid][pLeader] >= 1)
			{
			 if(PlayerInfo[playerid][pLeader] == PlayerInfo[para1][pMember])
			 {
			  if(IsPlayerConnected(para1))
			  {
			   if(para1 != INVALID_PLAYER_ID)
			   {
				   if (PlayerInfo[para1][pMember] > 0)
				   {
				 			GetPlayerNameEx(para1, giveplayer, sizeof(giveplayer));
				 			GetPlayerNameEx(playerid, sendername, sizeof(sendername));
				 			printf("Admin: %s has uninvited %s.", sendername, giveplayer);
				 			format(string, sizeof(string), "* Zosta³eœ wyrzucony z frakcji przez lidera %s.", sendername);
				 			SendClientMessage(para1, COLOR_LIGHTBLUE, string);
				 			SendClientMessage(para1, COLOR_LIGHTBLUE, "* Znowu jesteœ cywilem.");
				 			PlayerInfo[para1][pMember] = 0;
				 			PlayerInfo[para1][pRank] = 0;
				 			new rand = random(sizeof(CIV));
				 			SetSpawnInfo(para1, TEAM_NONE, CIV[rand],0.0,0.0,0.0,0,0,0,0,0,0,0);
				 			PlayerInfo[para1][pModel] = CIV[rand];
				 			MedicBill[para1] = 0;
				 			SpawnPlayer(para1);
				 			format(string, sizeof(string), "   Wyrzuci³eœ %s z frakcji.", giveplayer);
				 			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
				 		}
				 	}
				 }//not connected
			 }
			 else
			 {
			 	SendClientMessage(playerid, COLOR_GRAD1, "Ten gracz nie nale¿y do twojej frakcji !");
			 	return 1;
			 }
			}
			else if(PlayerInfo[playerid][pUFLeader] < MAX_UNOFFICIAL_FACTIONS+1)
		 {
		  if(PlayerInfo[playerid][pUFLeader] == PlayerInfo[para1][pUFMember])
			 {
			  if(IsPlayerConnected(para1))
			  {
			   if(para1 != INVALID_PLAYER_ID)
			   {
				   if (PlayerInfo[para1][pUFMember] < MAX_UNOFFICIAL_FACTIONS+1)
				   {
				    PlayerInfo[para1][pUFMember] = MAX_UNOFFICIAL_FACTIONS+1;
				
				    GetPlayerNameEx(para1, giveplayer, sizeof(giveplayer));
				 			GetPlayerNameEx(playerid, sendername, sizeof(sendername));
				 			
				 			printf("Admin: %s wyrzucil %s.", sendername, giveplayer);
				
				    format(string, sizeof(string), "* Zosta³eœ wyrzucony z organizacji przez lidera %s.", sendername);
				 			SendClientMessage(para1, COLOR_LIGHTBLUE, string);
				 			
				 			format(string, sizeof(string), "   Wyrzuci³eœ %s z organizacji.", giveplayer);
				 			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
				 			
				 			MedicBill[para1] = 0;
				 			SpawnPlayer(para1);
				 			RespawnPlayer(para1);
				 			return 1;
			    }
		    }
	    }
    }
		  return 1;
		 }
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "Nie jesteœ uprawniony do u¿ycia tej komendy !");
				return 1;
			}
		}
		return 1;
	}
//----------------------------------[MAKELEADER]------------------------------------------------
	if(strcmp(cmd, "/makeleader", true) == 0)
	{
  if(IsPlayerConnected(playerid))
  {
		if (PlayerInfo[playerid][pAdmin] >= 3)
		{
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /makeleader [IdGracza/CzêœæNazwy] [Number(1-15)]");
				SendClientMessage(playerid, COLOR_GRAD2, "1-Policja, 2-SWAT, 3-NG, 4-Lekarz, 5-LCN, 6-Yakuza, 7-Gubernator, 8-P³atny Zabójca, 9-Reporter, ");
				SendClientMessage(playerid, COLOR_GRAD2, "10-Taksówkarz, 11-Instruktor, 12-Autobusiarze, 13-FBI, 14-Vagos, 15-Surside' Boulevard Family, 16-Ballas, 17-Akademia, 18-FD");
				return 1;
			}
			new para1;
			new level;
			para1 = ReturnUser(tmp);
			tmp = strtok(cmdtext, idx);
			level = strval(tmp);
			if(level > 19 || level < 0) { SendClientMessage(playerid, COLOR_GREY, "   Numer frakcji musi byæ wiêkszy od 0 i mniejszy od 18!"); return 1; }
			if(level == 12) { SendClientMessage(playerid, COLOR_GREY, "   Ta frakcja jest niedostêpna!"); return 1; }
			 if(IsPlayerConnected(para1))
			 {
			  if(para1 != INVALID_PLAYER_ID)
			  {
			   if(PlayerInfo[para1][pMember] > 0 || PlayerInfo[para1][pUFMember] < MAX_UNOFFICIAL_FACTIONS + 1)
			   {
			    SendClientMessage(playerid, COLOR_GREY, "   Ten gracz nale¿y ju¿ do frakcji !");
			    return 1;
			   }
						GetPlayerNameEx(para1, giveplayer, sizeof(giveplayer));
						GetPlayerNameEx(playerid, sendername, sizeof(sendername));
						PlayerInfo[para1][pLeader] = level;
						format(string, sizeof(string), "   Zosta³eœ promowany na lidera frakcji przez Administratora %s", sendername);
						SendClientMessage(para1, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "   Da³eœ kontrole graczowi %s nad Frakcj¹ numer %d.", giveplayer,level);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						if(level == 0) { PlayerInfo[para1][pModel] = 0; }
						else if(level == 1) { PlayerInfo[para1][pModel] = 282;  } //Police Force
						else if(level == 2) { PlayerInfo[para1][pModel] = 285;  } //Swat
						else if(level == 3) { PlayerInfo[para1][pModel] = 287;  } //National Guard
						else if(level == 4) { PlayerInfo[para1][pModel] = 228;  } //Fire/Ambulance
						else if(level == 5) { PlayerInfo[para1][pModel] = 113;  } //La Cosa Nostra
						else if(level == 6) { PlayerInfo[para1][pModel] = 120;  } //Yakuza
						else if(level == 7) { PlayerInfo[para1][pModel] = 147;  } //Mayor
						else if(level == 8) { PlayerInfo[para1][pModel] = 294;  } //Hitmans
						else if(level == 9) { PlayerInfo[para1][pModel] = 17;   } //News Reporters
						else if(level == 10) { PlayerInfo[para1][pModel] = 61;  } //Taxi Cab Company
						else if(level == 11) { PlayerInfo[para1][pModel] = 171; } //Driving/Flying School
						else if(level == 12) { PlayerInfo[para1][pModel] = 94;  } //Bus company
						else if(level == 13) { PlayerInfo[para1][pModel] = 295; } //FBI
						else if(level == 14) { PlayerInfo[para1][pModel] = 292; } //Vagos
						else if(level == 15) { PlayerInfo[para1][pModel] = 271; } //Surside' Boulevard Family
						else if(level == 16) { PlayerInfo[para1][pModel] = 102; } //Ballas
						else if(level == 17) { PlayerInfo[para1][pModel] = 283; } //Akademia
						else if(level == 18) { PlayerInfo[para1][pModel] = 279; } //FD

					 SetPlayerSkin(para1, PlayerInfo[para1][pModel]);
					}
				}//not connected
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   Nie masz uprawnieñ!");
			}
		}
		return 1;
	}

//----------------------------------[GIVERANK]------------------------------------------------
	
//----------------------------------[setteam]------------------------------------------------

//----------------------------------[GiveGun]------------------------------------------------
	if(strcmp(cmd, "/givegun", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /givegun [IdGracza/CzêœæNazwy] [weaponid(eg. 46 = Parachute)] [amunicja]");
				return 1;
			}
			new playa;
			new gun;
			new ammo;
			playa = ReturnUser(tmp);
			tmp = strtok(cmdtext, idx);
			gun = strval(tmp);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /givegun [id/ImiêLubNazwisko] [idbroni] [amunicja]");
				SendClientMessage(playerid, COLOR_GRAD4, "3(Golf) 4(Nó¿) 5(Kij) 6(£opata) 7(Cue) 8(Katana) 10-13(Wibrator) 14(Kwiaty) 16(Grenaty) 18(Mo³otowa) 22(Pistolet) 23(SPistolet)");
				SendClientMessage(playerid, COLOR_GRAD3, "24(Eagle) 25(Shotgun) 29(MP5) 30(AK47) 31(M4) 33(Rifle) 34(Snajperka) 37(MiotaczOgnia) 41(Spray) 42(Gaœnica) 43(Aparat) 46(Spadachron)");
				return 1;
			}
			if(gun < 1||gun > 46||gun==27||gun==9||gun==17||gun==19||gun==20||gun==21||gun==36||gun==38||gun==39||gun==40)
			{ SendClientMessage(playerid, COLOR_GRAD1, "   B³êdne ID Broni!"); return 1; }
			tmp = strtok(cmdtext, idx);
			ammo = strval(tmp);
			//if(ammo <1||ammo > 999)
			//{ SendClientMessage(playerid, COLOR_GRAD1, "   Iloœæ naboi nie mo¿e byæ mniejsza od 0 i wiêksza od 999!"); return 1; }
			if (PlayerInfo[playerid][pAdmin] == 1337)
			{
			 if(IsPlayerConnected(playa))
			 {
			  if(playa != INVALID_PLAYER_ID)
			  {
						GivePlayerWeaponEx(playa, gun, ammo);
					}
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "Nie masz uprawnieñ by uzyæ tej komendy!");
			}
		}
		return 1;
	}
//----------------------------------[sethp]------------------------------------------------
	
	#if DEBUG
	if(strcmp(cmd, "/veh", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
	  if(PlayerInfo[playerid][pAdmin] < 1337)
			{
			 SendClientMessage(playerid, COLOR_GRAD1, "Nie masz uprawnieñ by uzyæ tej komendy!");
			 return 1;
			}
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /veh [carid] [kolor 1] [kolor 2]");
				return 1;
			}
			new car;
			car = strval(tmp);
			if(car < 400 || car > 611) { SendClientMessage(playerid, COLOR_GREY, "   Numer pojazdu nie mo¿e byæ ni¿szy 400 ale i nie wiêkszy ni¿ 611 !"); return 1; }
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /veh [carid] [kolor 1] [kolor 2]");
				return 1;
			}
			new color1;
			color1 = strval(tmp);
			if(color1 < 0 || color1 > 126) { SendClientMessage(playerid, COLOR_GREY, "   Kolor pojazdu to liczby od 0 do 126 !"); return 1; }
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /veh [carid] [kolor 1] [kolor 2]");
				return 1;
			}
			new color2;
			color2 = strval(tmp);
			if(color2 < 0 || color2 > 126) { SendClientMessage(playerid, COLOR_GREY, "   Kolor pojazdu to liczby od 0 do 126 !"); return 1; }
			new Float:X,Float:Y,Float:Z;
			GetPlayerPos(playerid, X,Y,Z);
			new carid = CreateVehicle(car, X,Y,Z, 0.0, color1, color2, 60000);
			format(string, sizeof(string), "   Pojazd %d spawnowany.", carid);
			SendClientMessage(playerid, COLOR_GREY, string);
		}
		return 1;
	}
	#endif
//----------------------------------[Money]------------------------------------------------
	if(strcmp(cmd, "/money", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /money [IdGracza/CzêœæNazwy] [money]");
				return 1;
			}
			new playa;
			new money;
			playa = ReturnUser(tmp);
			tmp = strtok(cmdtext, idx);
			money = strval(tmp);
			if (PlayerInfo[playerid][pAdmin] == 1337)
			{
    if(IsPlayerConnected(playa))
    {
     if(playa != INVALID_PLAYER_ID)
     {
						ResetPlayerMoney(playa);
						
						GivePlayerMoney(playa, money);
						PlayerInfo[playa][pCash] = money;
						
					 GetPlayerNameEx(playa, giveplayer, sizeof(giveplayer));
						GetPlayerNameEx(playerid, sendername, sizeof(sendername));
						
						printf("/money : %s da³ %d graczowi %s", sendername, money, giveplayer);
					}
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "Nie jesteœ uprawniony do u¿ycia tej komendy !");
			}
		}
		return 1;
	}
//----------------------------------[GiveMoney]------------------------------------------------
	if(strcmp(cmd, "/givemoney", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /givemoney [IdGracza/CzêœæNazwy] [kwota]");
				return 1;
			}
			new playa;
			new money;
			playa = ReturnUser(tmp);
			tmp = strtok(cmdtext, idx);
			money = strval(tmp);
			if (PlayerInfo[playerid][pAdmin] == 1337)
			{
			 if(IsPlayerConnected(playa))
			 {
			  if(playa != INVALID_PLAYER_ID)
			  {
	     
	 				GivePlayerMoneyEx(playa, money);

      GetPlayerNameEx(playa, giveplayer, sizeof(giveplayer));
						GetPlayerNameEx(playerid, sendername, sizeof(sendername));
						
						printf("/givemoney : %s da³ %d graczowi %s", sendername, money, giveplayer);
     }
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "   Nie jestes autoryzowany do uzycia tej komendy!");
			}
		}
		return 1;
	}
//-----------------------------------[Slap]-----------------------------------------------
//----------------------------------[Kick]------------------------------------------------

	#if LEVEL_MODE
	if(strcmp(cmd, "/kickres", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
	        if (PlayerInfo[playerid][pAdmin] < 1)
			{
				return 1;
			}
	    	tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /kickres [level] [ammount]");
				return 1;
			}
			new level = strval(tmp);
			if(level < 0 || level > 5) { SendClientMessage(playerid, COLOR_GREY, "   Mo¿esz tylko ustawiæ kick rezerwacji slotów dla poziomów 0-5 !"); return 1; }
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /kickres [level] [wartoœæ]");
				return 1;
			}
			new ammount = strval(tmp);
			if(ammount < 1 || ammount > 10) { SendClientMessage(playerid, COLOR_GREY, "   Mo¿esz tylko kick rezerwacji slotów maksymalnie 10 graczom !"); return 1; }
			for(new i = 0; i < MAX_PLAYERS; i++)
			{
			    if(IsPlayerConnected(i))
			    {
			        if(PlayerInfo[i][pLevel] == level && PlayerInfo[i][pAdmin] < 1 && PlayerInfo[i][pDonateRank] < 1 && ammount > 0)
			        {
			            ammount -= 1;
						Kick(i);
			        }
			    }
			}
 		}
		return 1;
	}
	#endif
	

	
//----------------------------------[HELP]-----------------------------------------------
	if(strcmp(cmd, "/telefonpomoc", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
			if(HasPlayerItemByType(playerid, ITEM_CELLPHONE))
			{
				SendClientMessage(playerid, COLOR_LORANGE, "* Pomocne komendy - telefon *");
				SendClientMessage(playerid, COLOR_AWHITE,  "/dzwon /sms (/od)bierz (/z)akoncz /numer");
			}
			else
			{
				SendClientMessage(playerid, COLOR_WHITE,"Mo¿esz kupiæ telefon w ka¿dym sklepie 24-7");
			}
		}
		return 1;
	}
	
	/*#if OLD_HOUSE
	if(strcmp(cmd, "/dompomoc", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
			SendClientMessage(playerid, COLOR_WHITE,"*** DOM POMOC *** Wpisz komende aby uzyskaæ pomoc");
			SendClientMessage(playerid, COLOR_HELP5,"*** DOM *** /wejdz /wyjdz /otworz /home /ulecz /domulepszenia /wynajmowanie ");
			SendClientMessage(playerid, COLOR_HELP5,"*** DOM *** /eksmitujwszystkich /ilewynajem /eksmituj /domwyplac");
			SendClientMessage(playerid, COLOR_GRAD4,"*** INNE *** /telefonpomoc /pomoc /autopomoc /wynajempomoc /firma /liderpomoc /lowieniepomoc /gotowaniepomoc /ircpomoc");
		}
		return 1;
	}
	
	#endif*/
	
	if(strcmp(cmd, "/autopomoc", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
         SendClientMessage(playerid, COLOR_WHITE,"*** AUTO POMOC *** Wpisz komende aby uzyskaæ pomoc");
         SendClientMessage(playerid, COLOR_HELP5,"*** AUTO *** /pojazd /zamowpojazd /warsztat /zamknij /kluczyki");
         SendClientMessage(playerid, COLOR_GRAD4,"*** INNE *** /telefonpomoc /pomoc /wynajempomoc /firma /liderpomoc /lowieniepomoc /gotowaniepomoc /ircpomoc");
		}
		return 1;
	}
	if(strcmp(cmd, "/wynajempomoc", true) == 0)
	{
		if(IsPlayerConnected(playerid))
  {
   SendClientMessage(playerid, COLOR_WHITE,"*** WYNAJEM POMOC *** Wpisz komende aby uzyskaæ pomoc");
   SendClientMessage(playerid, COLOR_HELP5,"*** WYNAJEM *** /wynajmijpokoj /unrent /wejdz /wyjdz /zamknij /home");
   SendClientMessage(playerid, COLOR_GRAD4,"*** INNE *** /telefonpomoc /dompomoc /autopomoc /pomoc /firma /liderpomoc /lowieniepomoc");
		}
		return 1;
	}
	
	if(strcmp(cmd, "/liderpomoc", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
		 if (PlayerInfo[playerid][pLeader] >= 1)
		 {
				SendClientMessage(playerid, COLOR_WHITE,"*** LIDER POMOC *** Wpisz komende aby uzyskaæ pomoc");
				SendClientMessage(playerid, COLOR_HELP5,"*** LIDER *** /zatrudnij /zwolnij /dajrange");
				/*if(PlayerInfo[playerid][pLeader] == 5 || PlayerInfo[playerid][pLeader] == 6)
				{
				 //SendClientMessage(playerid, COLOR_HELP5,"*** LIDERZY *** /allowcreation /deletecreation /giveturf");
				}*/
				if(PlayerInfo[playerid][pLeader] == 7)
				{
					SendClientMessage(playerid, COLOR_HELP5,"*** LIDERZY *** /settax /givetax");
				}
			}
			else
			{
			 SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ liderem !");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/ircpomoc", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
	  SendClientMessage(playerid, COLOR_WHITE,"*** IRC *** (/irc dolacz [NrKana³u] or /irc dolacz [NrKana³u] [has³o])  (/irc Wyjdz)");
			SendClientMessage(playerid, COLOR_WHITE,"*** IRC *** (/irc Has³o [NrKana³u])  (/irc WymaganeHas³o [NrKana³u])  (/irc Zablokuj [NrKana³u])");
			SendClientMessage(playerid, COLOR_WHITE,"*** IRC *** (/irc Admini)  (/irc Motto [treœæ])  (/irc Status [NrKana³u])  (/i [tekst])");
	 }
	 return 1;
	}
	if(strcmp(cmd, "/lowieniepomoc", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
			SendClientMessage(playerid, COLOR_HELP5,"*** £OWIENIE *** /fish (Spróbuj z³owiæ rybê)   /ryby (Pokazuje ryby. które z³owi³eœ)");
			SendClientMessage(playerid, COLOR_HELP5,"*** £OWIENIE *** /wyrzucrybe (Wyrzuæ ostatnio z³apan¹ rybê)   /wyrzucryby");
			SendClientMessage(playerid, COLOR_HELP5,"*** £OWIENIE *** /uwolnijrybe (Uwolnij wybran¹ rybê)");
		}
		return 1;
	}
	/*if(strcmp(cmd, "/gotowaniepomoc", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
			SendClientMessage(playerid, COLOR_GREEN,"_______________________________________");
			SendClientMessage(playerid, COLOR_WHITE,"*** GOTOWANIE POMOC *** Wpisz komende aby uzyskaæ pomoc");
			SendClientMessage(playerid, COLOR_HELP5,"*** GOTOWANIE *** /jedzenie (Wyœwietla wszystkie dostêpne potrawy) /ugotowane (Wyœwietla wszystko co ugotowa³eœ!)");
			SendClientMessage(playerid, COLOR_HELP5,"*** GOTOWANIE *** /zjedz (jedzenie ugotowanych potraw)");
		}
		return 1;
	}*/
	
	if(strcmp(cmd,"/stopani",true)==0)
	{
	  if(IsPlayerConnected(playerid))
	  {
	    if(!IsPlayerBusy(playerid))
	    {
				if(GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_NONE)
				{
					SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
					return 1;
				}	
				
	      ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
      }
		}
	  return 1;
	}
	if(strcmp(cmd,"/skill",true)==0)
	{
	    if(IsPlayerConnected(playerid))
	    {
	        new x_nr[32];
			x_nr = strtok(cmdtext, idx);
			if(!strlen(x_nr)) {
				SendClientMessage(playerid, COLOR_WHITE, "|__________________ Skill Info __________________|");
				SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /skill [numer]");
		  		SendClientMessage(playerid, COLOR_GREY, "| 1: Detektyw            7: Mechanik");
		  		SendClientMessage(playerid, COLOR_GREY, "| 2: Prawnik             8: Sprzedawca Aut");
		  		SendClientMessage(playerid, COLOR_GREY, "| 3: Prostytutka         9: Boxer");
		  		SendClientMessage(playerid, COLOR_GREY, "| 4: Diler Narkotyków	  10: Rybactwo");
		  		SendClientMessage(playerid, COLOR_GREY, "| 5: Z³odziej Aut       11: Kieszonkowiec");
		  		SendClientMessage(playerid, COLOR_GREY, "| 6: Reporter LSN      12: Diler Broni");
				SendClientMessage(playerid, COLOR_WHITE, "|________________________________________________|");
				return 1;
			}
		 if(strcmp(x_nr,"1",true) == 0)//Detective
			{
			 new level = PlayerInfo[playerid][pDetSkill];
				if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Detektywistycznych = 1."); format(string, sizeof(string), "Musisz znaleŸæ jeszcze %d osób by zwiêkszyæ poziom umiejêtnoœci.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Detektywistycznych = 2."); format(string, sizeof(string), "Musisz znaleŸæ jeszcze %d osób by zwiêkszyæ poziom umiejêtnoœci.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Detektywistycznych = 3."); format(string, sizeof(string), "Musisz znaleŸæ jeszcze %d osób by zwiêkszyæ poziom umiejêtnoœci.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Detektywistycznych = 4."); format(string, sizeof(string), "Musisz znaleŸæ jeszcze %d osób by zwiêkszyæ poziom umiejêtnoœci.", 400 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Detektywistycznych = 5."); }
			}
			else if(strcmp(x_nr,"2",true) == 0)//Lawyer
			{
			 new level = PlayerInfo[playerid][pLawSkill];
				if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Adwokata = 1."); format(string, sizeof(string), "Musisz uwolniæ jeszcze %d osób by zwiêkszyæ poziom umiejêtnoœci.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Adwokata = 2."); format(string, sizeof(string), "Musisz uwolniæ jeszcze %d osób by zwiêkszyæ poziom umiejêtnoœci.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Adwokata = 3."); format(string, sizeof(string), "Musisz uwolniæ jeszcze %d osób by zwiêkszyæ poziom umiejêtnoœci.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Adwokata = 4."); format(string, sizeof(string), "Musisz uwolniæ jeszcze %d osób by zwiêkszyæ poziom umiejêtnoœci.", 400 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Adwokata = 5."); }
			}
			else if(strcmp(x_nr,"3",true) == 0)//Whore
			{
			    new level = PlayerInfo[playerid][pSexSkill];
				if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Dawania Przyjemnoœci = 1."); format(string, sizeof(string), "Musisz zadowoliæ jeszcze %d osób by zwiêkszyæ poziom umiejêtnoœci.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Dawania Przyjemnoœci = 2."); format(string, sizeof(string), "Musisz zadowoliæ jeszcze %d osób by zwiêkszyæ poziom umiejêtnoœci.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Dawania Przyjemnoœci = 3."); format(string, sizeof(string), "Musisz zadowoliæ jeszcze %d osób by zwiêkszyæ poziom umiejêtnoœci.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Dawania Przyjemnoœci = 4."); format(string, sizeof(string), "Musisz zadowoliæ jeszcze %d osób by zwiêkszyæ poziom umiejêtnoœci.", 400 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Dawania Przyjemnoœci = 5."); }
			}
			else if(strcmp(x_nr,"4",true) == 0)//Drugs Dealer
			{
			    new level = PlayerInfo[playerid][pDrugsSkill];
				if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Handlu Dragami = 1."); format(string, sizeof(string), "Musisz sprzedaæ jeszcze %d dragów by zwiêkszyæ poziom umiejêtnoœci.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Handlu Dragami = 2."); format(string, sizeof(string), "Musisz sprzedaæ jeszcze %d dragów by zwiêkszyæ poziom umiejêtnoœci.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Handlu Dragami = 3."); format(string, sizeof(string), "Musisz sprzedaæ jeszcze %d dragów by zwiêkszyæ poziom umiejêtnoœci.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Handlu Dragami = 4."); format(string, sizeof(string), "Musisz sprzedaæ jeszcze %d dragów by zwiêkszyæ poziom umiejêtnoœci.", 400 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Handlu Dragami = 5."); }
			}
			else if(strcmp(x_nr,"5",true) == 0)//Car Jacker
			{
			    new level = PlayerInfo[playerid][pJackSkill];
				if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umieje^tnooeci Kradzie?y Wozów = 1."); format(string, sizeof(string), "Musisz dostarczy? jeszcze %d samochodów by zwie^kszy? poziom umieje^tnooeci.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umieje^tnooeci Kradzie?y Wozów = 2."); format(string, sizeof(string), "Musisz dostarczy? jeszcze %d samochodów by zwie^kszy? poziom umieje^tnooeci.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umieje^tnooeci Kradzie?y Wozów = 3."); format(string, sizeof(string), "Musisz dostarczy? jeszcze %d samochodów by zwie^kszy? poziom umieje^tnooeci.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umieje^tnooeci Kradzie?y Wozów = 4."); format(string, sizeof(string), "Musisz dostarczy? jeszcze %d samochodów by zwie^kszy? poziom umieje^tnooeci.", 400 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umieje^tnooeci Kradzie?y Wozów = 5."); }
			}
			#if Skills_Weapons_All
			else if(strcmp(x_nr,"13",true) == 0)//test [wax]
			{
			    new level = PlayerInfo[playerid][pColtSkill];
				if(level >= 0 && level <= 2) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Pos³ógiwania Siê Desert Eagle = 1."); format(string, sizeof(string), "Musisz ustrzeliæ jeszcze %d osób by zwiêkszyæ poziom umiejêtnoœci.", 2 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 4 && level <= 5) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Pos³ógiwania Siê Desert Eagle = 2."); format(string, sizeof(string), "Musisz ustrzeliæ jeszcze %d osób by zwiêkszyæ poziom umiejêtnoœci.", 5 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 6 && level <= 7) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Pos³ógiwania Siê Desert Eagle = 3."); format(string, sizeof(string), "Musisz ustrzeliæ jeszcze %d osób by zwiêkszyæ poziom umiejêtnoœci.", 7 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 8 && level <= 9) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Pos³ógiwania Siê Desert Eagle = 4."); format(string, sizeof(string), "Musisz ustrzeliæ jeszcze %d osób by zwiêkszyæ poziom umiejêtnoœci.", 9 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 10) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Pos³ógiwania Siê Desert Eagle = 5(max)."); }
			}
			#endif
			else if(strcmp(x_nr,"6",true) == 0)//News Reporter
			{
			    new level = PlayerInfo[playerid][pNewsSkill];
				if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Pisania Reporta¿y = 1."); format(string, sizeof(string), "Musisz napisaæ jeszcze %d newsów by zwiêkszyæ poziom umiejêtnoœci.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Pisania Reporta¿y = 2."); format(string, sizeof(string), "Musisz napisaæ jeszcze %d newsów by zwiêkszyæ poziom umiejêtnoœci.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Pisania Reporta¿y = 3."); format(string, sizeof(string), "Musisz napisaæ jeszcze %d newsów by zwiêkszyæ poziom umiejêtnoœci.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Pisania Reporta¿y = 4."); format(string, sizeof(string), "Musisz napisaæ jeszcze %d newsów by zwiêkszyæ poziom umiejêtnoœci.", 400 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Pisania Reporta¿y = 5."); }
			}
			else if(strcmp(x_nr,"7",true) == 0)//Car Mechanic
			{
			    new level = PlayerInfo[playerid][pMechSkill];
				if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Naprawiania = 1."); format(string, sizeof(string), "Musisz naprawiæ/natankowaæ jeszcze %d samochodów by zwiêkszyæ poziom umiejêtnoœci.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Naprawiania = 2."); format(string, sizeof(string), "Musisz naprawiæ/natankowaæ jeszcze %d samochodów by zwiêkszyæ poziom umiejêtnoœci.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Naprawiania = 3."); format(string, sizeof(string), "Musisz naprawiæ/natankowaæ jeszcze %d samochodów by zwiêkszyæ poziom umiejêtnoœci.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Naprawiania = 4."); format(string, sizeof(string), "Musisz naprawiæ/natankowaæ jeszcze %d samochodów by zwiêkszyæ poziom umiejêtnoœci.", 400 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Naprawiania = 5."); }
			}
			else if(strcmp(x_nr,"8",true) == 0)//Car Dealer
			{
			    new level = PlayerInfo[playerid][pCarSkill];
				if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Handlu Pojazdami = 1."); format(string, sizeof(string), "Musisz sprzedaæ jeszcze %d samochodów by zwiêkszyæ poziom umiejêtnoœci.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Handlu Pojazdami = 2."); format(string, sizeof(string), "Musisz sprzedaæ jeszcze %d samochodów by zwiêkszyæ poziom umiejêtnoœci.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Handlu Pojazdami = 3."); format(string, sizeof(string), "Musisz sprzedaæ jeszcze %d samochodów by zwiêkszyæ poziom umiejêtnoœci.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Handlu Pojazdami = 4."); format(string, sizeof(string), "Musisz sprzedaæ jeszcze %d samochodów by zwiêkszyæ poziom umiejêtnoœci.", 400 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Handlu Pojazdami = 5."); }
			}
			else if(strcmp(x_nr,"9",true) == 0)//Boxer
			{
			    new level = PlayerInfo[playerid][pBoxSkill];
				if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Boksera = 1."); format(string, sizeof(string), "Musisz wygraæ jeszcze %d pojedynków by zwiêkszyæ poziom umiejêtnoœci.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Boksera = 2."); format(string, sizeof(string), "Musisz wygraæ jeszcze %d pojedynków by zwiêkszyæ poziom umiejêtnoœci.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Boksera = 3."); format(string, sizeof(string), "Musisz wygraæ jeszcze %d pojedynków by zwiêkszyæ poziom umiejêtnoœci.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Boksera = 4."); format(string, sizeof(string), "Musisz wygraæ jeszcze %d pojedynków by zwiêkszyæ poziom umiejêtnoœci.", 400 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Boksera = 5."); }
			}
			else if(strcmp(x_nr,"10",true) == 0)//Fishing
			{
			    new level = PlayerInfo[playerid][pFishSkill];
				if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Po³owu Ryb = 1."); format(string, sizeof(string), "Musisz z³owiæ jeszcze %d ryb by zwiêkszyæ poziom umiejêtnoœci.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Po³owu Ryb = 2."); format(string, sizeof(string), "Musisz z³owiæ jeszcze %d ryb by zwiêkszyæ poziom umiejêtnoœci.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Po³owu Ryb = 3."); format(string, sizeof(string), "Musisz z³owiæ jeszcze %d ryb by zwiêkszyæ poziom umiejêtnoœci.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Po³owu Ryb = 4."); format(string, sizeof(string), "Musisz z³owiæ jeszcze %d ryb by zwiêkszyæ poziom umiejêtnoœci.", 400 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Po³owu Ryb = 5."); }
			}
			else if(strcmp(x_nr,"11",true) == 0)//Kieszonkowiec
			{
			    new level = PlayerInfo[playerid][pThiefSkill];
				if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Kieszonkowca = 1."); format(string, sizeof(string), "Musisz okraœæ jeszcze %d osób by zwiêkszyæ poziom umiejêtnoœci.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Kieszonkowca = 2."); format(string, sizeof(string), "Musisz okraœæ jeszcze %d osób by zwiêkszyæ poziom umiejêtnoœci.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Kieszonkowca = 3."); format(string, sizeof(string), "Musisz okraœæ jeszcze %d osób by zwiêkszyæ poziom umiejêtnoœci.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 201 && level <= 300) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Kieszonkowca = 4."); format(string, sizeof(string), "Musisz okraœæ jeszcze %d osób by zwiêkszyæ poziom umiejêtnoœci.", 300 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 301) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Kieszonkowca = 5."); }
			}
			else if(strcmp(x_nr,"12",true) == 0)//Gun Dealer
			{
			    new level = PlayerInfo[playerid][pWeaponsSkill];
				if(level >= 0 && level <= 50) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Handlu Broñmi = 1."); format(string, sizeof(string), "Musisz sprzedaæ jeszcze %d broni by zwiêkszyæ poziom umiejêtnoœci.", 50 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 51 && level <= 100) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Handlu Broñmi = 2."); format(string, sizeof(string), "Musisz sprzedaæ jeszcze %d broni by zwiêkszyæ poziom umiejêtnoœci.", 100 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 101 && level <= 200) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Handlu Broñmi = 3."); format(string, sizeof(string), "Musisz sprzedaæ jeszcze %d broni by zwiêkszyæ poziom umiejêtnoœci.", 200 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 201 && level <= 400) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Handlu Broñmi = 4."); format(string, sizeof(string), "Musisz sprzedaæ jeszcze %d broni by zwiêkszyæ poziom umiejêtnoœci.", 400 - level); SendClientMessage(playerid, COLOR_YELLOW, string); }
				else if(level >= 401) { SendClientMessage(playerid, COLOR_YELLOW, "Poziom Umiejêtnoœci Handlu Broñmi = 5."); }
			}
			else
			{
			    SendClientMessage(playerid, COLOR_GREY, "Z³y numer umiejêtnoœci !");
			    return 1;
			}
	    }
	    return 1;
	}
	if(strcmp(cmd, "/dajlicencje", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
      if(IsAnInstructor(playerid) && (PlayerInfo[playerid][pRank] >=4))
	  {
	   new x_nr[32];
				x_nr = strtok(cmdtext, idx);
				if(!strlen(x_nr)) {
				 SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /dajlicencje [nazwa] [IdGracza/CzêœæNazwy]");
				 SendClientMessage(playerid, COLOR_WHITE, "Mo¿liwe Licencje: PrawoJazdy, LicencjaPilota, Du¿eSamoloty.");
     SendClientMessage(playerid, COLOR_WHITE, "Mo¿liwe Licencje: KartaRybacka, LicencjaNaBroñ, £odzie.");
					return 1;
				}
			
    if(strcmp(x_nr,"PrawoJazdy",true) == 0)
				{
				 if(PlayerInfo[playerid][pRank] < 4)
	    {
	     SendClientMessage(playerid, COLOR_GREY, "Musisz mieæ range 4 lub wiêksza aby dawaæ licencje!");
	     return 1;
	    }
				
				
		   tmp = strtok(cmdtext, idx);
					if(!strlen(tmp))
					{
					 SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /dajlicencje PrawoJazdy [IdGracza/CzêœæNazwy]");
					 return 1;
					}
					giveplayerid = ReturnUser(tmp);
					if(IsPlayerConnected(giveplayerid))
					{
					 if(giveplayerid != INVALID_PLAYER_ID)
					 {
					  if(GetDistanceBetweenPlayers(playerid, giveplayerid) > 5)
       {
        SendClientMessage(playerid, COLOR_WHITE, "Nie ma takiego gracza w pobli¿u.");
        return 1;
   	   }
   	   if(GetPlayerMoneyEx(giveplayerid) < 3000)
   	   {
   	    SendClientMessage(playerid, COLOR_WHITE, "Ta osoba nie ma tylu pieniêdzy.");
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
        SendClientMessage(playerid, COLOR_GREY, "Ta osoba nie mo¿e posiadaæ wiêcej przedmiotów.");
        return 1;
       }
   	
   	   GivePlayerMoneyEx(giveplayerid, -3000);
   	   Tax += 3000;
   	
					  GetPlayerNameEx(playerid, sendername, sizeof(sendername));
					  GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
				   format(string, sizeof(string), "* Da³eœ licencje kierowcy graczowi: %s.",giveplayer);
					  SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
					  format(string, sizeof(string), "* Instruktor %s da³ tobie licencje kierowcy.",sendername);
					  SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);

					  return 1;
				  }
					}
					else
					{
					 SendClientMessage(playerid, COLOR_GREY, "Tego gracza nie ma w grze!");
					 return 1;
					}
				}
				else if(strcmp(x_nr,"LicencjaPilota",true) == 0)
				{
				 if(PlayerInfo[playerid][pRank] < 5)
	    {
	     SendClientMessage(playerid, COLOR_GREY, "Musisz mieæ range 5 lub wiêksza aby dawaæ licencje!");
	     return 1;
	    }
	
		   tmp = strtok(cmdtext, idx);
					if(!strlen(tmp))
					{
					 SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /dajlicencje LicencjaPilota [IdGracza/CzêœæNazwy]");
					 return 1;
					}
					giveplayerid = ReturnUser(tmp);
					if(IsPlayerConnected(giveplayerid))
					{
					 if(giveplayerid != INVALID_PLAYER_ID)
					 {
					  if(GetDistanceBetweenPlayers(playerid, giveplayerid) > 5)
       {
        SendClientMessage(playerid, COLOR_WHITE, "Nie ma takiego gracza w pobli¿u.");
        return 1;
   	   }
   	   if(GetPlayerMoneyEx(giveplayerid) < 30000)
   	   {
   	    SendClientMessage(playerid, COLOR_WHITE, "Ta osoba nie ma tylu pieniêdzy.");
   	    return 1;
   	   }
   	
   	   GivePlayerMoneyEx(giveplayerid, -30000);
   	   Tax += 30000;
   	
					  GetPlayerNameEx(playerid, sendername, sizeof(sendername));
					  GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
				   format(string, sizeof(string), "* Da³eœ licencje pilota graczowi: %s.",giveplayer);
					  SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
					  format(string, sizeof(string), "* Instruktor %s da³ tobie licencje pilota.",sendername);
					  SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
					  PlayerInfo[giveplayerid][pFlyLic] = 1;
					  return 1;
						}
					}
					else
					{
					 SendClientMessage(playerid, COLOR_GREY, "Tego gracza nie ma w grze!");
					 return 1;
					}
				}
				else if(strcmp(x_nr,"Du¿eSamoloty",true) == 0 || strcmp(x_nr,"DuzeSamoloty",true) == 0)
				{
				 if(PlayerInfo[playerid][pRank] < 6)
	    {
	     SendClientMessage(playerid, COLOR_GREY, "Musisz mieæ range 6 lub wiêksza aby dawaæ licencje!");
	     return 1;
	    }
	
		   tmp = strtok(cmdtext, idx);
					if(!strlen(tmp))
					{
					 SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /dajlicencje Du¿eSamoloty [IdGracza/CzêœæNazwy]");
					 return 1;
					}
					giveplayerid = ReturnUser(tmp);
					if(IsPlayerConnected(giveplayerid))
					{
					 if(giveplayerid != INVALID_PLAYER_ID)
					 {
					  if(GetDistanceBetweenPlayers(playerid, giveplayerid) > 5)
       {
        SendClientMessage(playerid, COLOR_WHITE, "Nie ma takiego gracza w pobli¿u.");
        return 1;
   	   }
   	
   	   if(GetPlayerMoneyEx(giveplayerid) < 40000)
   	   {
   	    SendClientMessage(playerid, COLOR_WHITE, "Ta osoba nie ma tylu pieniêdzy.");
   	    return 1;
   	   }
   	
   	   GivePlayerMoneyEx(giveplayerid, -40000);
   	   Tax += 40000;
   	
					  GetPlayerNameEx(playerid, sendername, sizeof(sendername));
					  GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
				   format(string, sizeof(string), "* Da³eœ licencje na du¿e samoloty graczowi: %s.",giveplayer);
					  SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
					  format(string, sizeof(string), "* Instruktor %s da³ tobie licencje na du¿e samoloty.",sendername);
					  SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
					  PlayerInfo[giveplayerid][pBigFlyLic] = 1;
					  return 1;
						}
					}
					else
					{
			   SendClientMessage(playerid, COLOR_GREY, "Tego gracza nie ma w grze!");
					 return 1;
					}
				}
				else if(strcmp(x_nr,"£odzie",true) == 0 || strcmp(x_nr,"Lodzie",true) == 0)
				{
				 if(PlayerInfo[playerid][pRank] < 5)
	    {
	     SendClientMessage(playerid, COLOR_GREY, "Musisz mieæ range 5 lub wiêksza aby dawaæ licencje!");
	     return 1;
	    }
	
		   tmp = strtok(cmdtext, idx);
					if(!strlen(tmp))
					{
					    SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /dajlicencje £odzie [IdGracza/CzêœæNazwy]");
					    return 1;
					}
					giveplayerid = ReturnUser(tmp);
					if(IsPlayerConnected(giveplayerid))
					{
					 if(giveplayerid != INVALID_PLAYER_ID)
					 {
					  if(GetDistanceBetweenPlayers(playerid, giveplayerid) > 5)
       {
        SendClientMessage(playerid, COLOR_WHITE, "Nie ma takiego gracza w pobli¿u.");
        return 1;
   	   }
   	
   	   if(GetPlayerMoneyEx(giveplayerid) < 6000)
   	   {
   	    SendClientMessage(playerid, COLOR_WHITE, "Ta osoba nie ma tylu pieniêdzy.");
   	    return 1;
   	   }
   	
   	   GivePlayerMoneyEx(giveplayerid, -6000);
   	   Tax += 6000;
   	
					  GetPlayerName(playerid, sendername, sizeof(sendername));
					  GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
				   format(string, sizeof(string), "* Da³eœ licencje ¿eglarza graczowi: %s.",giveplayer);
					  SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
					  format(string, sizeof(string), "* Instruktor %s da³ tobie licencje ¿eglarza.",sendername);
					  SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
					  PlayerInfo[giveplayerid][pBoatLic] = 1;
					  return 1;
						}
					}
					else
					{
					 SendClientMessage(playerid, COLOR_GREY, "Tego gracza nie ma w grze!");
					 return 1;
					}
				}
				else if(strcmp(x_nr,"KartaRybacka",true) == 0)
				{
				 if(PlayerInfo[playerid][pRank] < 4)
	    {
	     SendClientMessage(playerid, COLOR_GREY, "Musisz mieæ range 4 lub wiêksza aby dawaæ licencje!");
	     return 1;
	    }
	
     tmp = strtok(cmdtext, idx);
					if(!strlen(tmp))
					{
					 SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /dajlicencje KartaRybacka [IdGracza/CzêœæNazwy]");
					 return 1;
					}
					giveplayerid = ReturnUser(tmp);
					if(IsPlayerConnected(giveplayerid))
					{
					 if(giveplayerid != INVALID_PLAYER_ID)
					 {
					  if(GetDistanceBetweenPlayers(playerid, giveplayerid) > 5)
       {
        SendClientMessage(playerid, COLOR_WHITE, "Nie ma takiego gracza w pobli¿u.");
        return 1;
   	   }
   	
   	   if(GetPlayerMoneyEx(giveplayerid) < 600)
   	   {
   	    SendClientMessage(playerid, COLOR_WHITE, "Ta osoba nie ma tylu pieniêdzy.");
   	    return 1;
   	   }
   	
   	   GivePlayerMoneyEx(giveplayerid, -600);
   	   Tax += 600;
   	
   	
					  GetPlayerNameEx(playerid, sendername, sizeof(sendername));
					  GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
				   format(string, sizeof(string), "* Da³eœ kartê ryback¹ graczowi: %s.",giveplayer);
					  SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
					  format(string, sizeof(string), "* Instruktor %s da³ tobie kartê ryback¹.",sendername);
					  SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
					  PlayerInfo[giveplayerid][pFishLic] = 1;
					  return 1;
						}
					}
					else
					{
					 SendClientMessage(playerid, COLOR_GREY, "Tego gracza nie ma w grze!");
					 return 1;
					}
				}
				 /*else if(strcmp(x_nr,"LicencjaNaBroñ",true) == 0 || strcmp(x_nr,"LicencjaNaBron",true) == 0)
				{
				 if(PlayerInfo[playerid][pRank] < 4)
	    {
	     SendClientMessage(playerid, COLOR_GREY, "Musisz mieæ range 4 lub wiêksza aby dawaæ licencje!");
	     return 1;
	    }
	
		   tmp = strtok(cmdtext, idx);
					if(!strlen(tmp))
					{
					 SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /dajlicencje LicencjaNaBroñ [IdGracza/CzêœæNazwy]");
					 return 1;
					}
					giveplayerid = ReturnUser(tmp);
					if(IsPlayerConnected(giveplayerid))
					{
					 if(giveplayerid != INVALID_PLAYER_ID)
					 {
					  if(GetDistanceBetweenPlayers(playerid, giveplayerid) > 5)
       {
        SendClientMessage(playerid, COLOR_WHITE, "Nie ma takiego gracza w pobli¿u.");
        return 1;
   	   }
   	
   	   if(GetPlayerMoneyEx(giveplayerid) < 2500)
   	   {
   	    SendClientMessage(playerid, COLOR_WHITE, "Ta osoba nie ma tylu pieniêdzy.");
   	    return 1;
   	   }
   	
   	   GivePlayerMoneyEx(giveplayerid, -2500);
   	   Tax += 2500;
   	
					  GetPlayerNameEx(playerid, sendername, sizeof(sendername));
					  GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
				   format(string, sizeof(string), "* Da³eœ licencje na broñ graczowi: %s.",giveplayer);
					  SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
					  format(string, sizeof(string), "* Instruktor %s da³ tobie licencje na broñ.",sendername);
					  SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
					  PlayerInfo[giveplayerid][pGunLic] = 1;
			    return 1;
						}
					}
					else
		 		{
		    SendClientMessage(playerid, COLOR_GREY, "Tego gracza nie ma w grze!");
		    return 1;
					}
				} */
	  }
	  else
	  {
	   SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ Instruktorem!");
	   return 1;
	  }
	 }
	 return 1;
	}
	if(strcmp(cmd, "/zacznijegzamin", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
	        if(IsAnInstructor(playerid))
	        {
	            tmp = strtok(cmdtext, idx);
				if(!strlen(tmp))
				{
				    SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /zacznijegzamin [IdGrazcza/CzêœæNazwy]");
				    return 1;
				}
				giveplayerid = ReturnUser(tmp);
				if(IsPlayerConnected(giveplayerid))
				{
				    if(giveplayerid != INVALID_PLAYER_ID)
				    {
				        GetPlayerNameEx(playerid, sendername, sizeof(sendername));
				        GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
				        format(string, sizeof(string), "* Rozpocz¹³eœ Egzamin z graczem: %s",giveplayer);
				        SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
				        format(string, sizeof(string), "* Instruktor %s rozpocz¹³ z egzamin.",sendername);
				        SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
				        TakingLesson[giveplayerid] = 1;
				    }
				}
				else
				{
				    SendClientMessage(playerid, COLOR_GREY, "Nie ma takiej osoby!");
				    return 1;
				}
	        }
	        else
	        {
	            SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ Instruktorem !");
	            return 1;
	        }
	    }
	    return 1;
	}
	if(strcmp(cmd, "/zakonczegzamin", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
	        if(IsAnInstructor(playerid))
	        {
	            tmp = strtok(cmdtext, idx);
				if(!strlen(tmp))
				{
				    SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /zakonczegzamin [IdGracza/CzêœæNazwy]");
				    return 1;
				}
				giveplayerid = ReturnUser(tmp);
				if(IsPlayerConnected(giveplayerid))
				{
				    if(giveplayerid != INVALID_PLAYER_ID)
				    {
				        if(TakingLesson[giveplayerid] != 1)
				        {
				            SendClientMessage(playerid, COLOR_GREY, "Ta osoba nie jest egzaminowana !");
				            return 1;
				        }
				        GetPlayerNameEx(playerid, sendername, sizeof(sendername));
				        GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
				        format(string, sizeof(string), "* Zakonczy³eœ Egzamin z %s.",giveplayer);
				        SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
				        format(string, sizeof(string), "* Instruktor %s zakoñczy³ egzamin.",sendername);
				        SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
				        TakingLesson[giveplayerid] = 0;
				    }
				}
				else
				{
				    SendClientMessage(playerid, COLOR_GREY, "Tego gracza nie ma w grze !");
				    return 1;
				}
	        }
	        else
	        {
	            SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ instruktorem !");
	            return 1;
	        }
	    }
	    return 1;
	}
	if(strcmp(cmd, "/ram", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
   if(GetPlayerOrganization(playerid) == 1 || GetPlayerOrganization(playerid) == 13 || GetPlayerOrganization(playerid) == 2 || PlayerInfo[playerid][pLeader] == 6 || PlayerInfo[playerid][pLeader] == 10 || PlayerInfo[playerid][pLeader] == 2)
   {
			new doorindex = GetClosestDoorID(playerid);
	 
		 if(doorindex == -1)
		 {
			SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê w pobli¿u ¿adnych drzwi.");
			return 1;
		 }
		 
		 if(dcmd_enter(playerid,"",1) != 2) dcmd_exit(playerid,"",1);
		 
		 GameTextForPlayer(playerid, "~r~Wywazyles drzwi", 5000, 1);
   }
   else
   {
			SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ upowa¿niony do u¿ycia tej komendy.");
			return 1;
   }
		}
		return 1;
	}
	if(strcmp(cmd, "/kamera", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
            if(IsACop(playerid))
            {
                if(!PlayerToPoint(2.0,playerid,198.9127,168.3687,1003.0234) || !PlayerToPoint(2.0,playerid,230.4309,165.0516,1003.0234))
				{
				    SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ przy komputerze monitoruj¹cym na komendzie !");
				    return 1;
				}
				tmp = strtok(cmdtext, idx);
				if(!strlen(tmp)) {
					SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /kamera [numer 1 - 4]  (5 = WY£)");
					return 1;
				}
				new number = strval(tmp);
				if(number < 1 || number > 5) { SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /kamera [numer 1 - 4]  (5 = WY£)"); return 1; }
				TogglePlayerControllable(playerid, 0);
				GetPlayerPos(playerid, Unspec[playerid][Coords][0],Unspec[playerid][Coords][1],Unspec[playerid][Coords][2]);
				if(number == 1) { SetPlayerCameraPos(playerid, 1553.5663,-1650.9232,28.0); SetPlayerCameraLookAt(playerid, 1536.5842,-1672.2537,13.4); SetPlayerInterior(playerid,0); PlayerInfo[playerid][pInt] = 0;}
				else if(number == 2) { SetPlayerCameraPos(playerid, 269.6512,75.7696,1002.5); SetPlayerCameraLookAt(playerid, 266.7669,85.1028,1001.00); SetPlayerInterior(playerid,6); PlayerInfo[playerid][pInt] = 6;}
				else if(number == 3) { SetPlayerCameraPos(playerid, 1512.5948,-1737.7196,16.5); SetPlayerCameraLookAt(playerid, 1483.2300,-1730.1188,13.0); SetPlayerInterior(playerid,0); PlayerInfo[playerid][pInt] = 0;}
				else if(number == 4) { SetPlayerCameraPos(playerid, 1483.9298,-1751.0502,33.4297); SetPlayerCameraLookAt(playerid, 1483.8347,-1735.1572,13.3828); SetPlayerInterior(playerid,0); PlayerInfo[playerid][pInt] = 0;}
				else if(number == 5)
				{
				    MedicBill[playerid] = 0;
					TogglePlayerControllable(playerid, 1);
					SetPlayerPosEx(playerid, 253.9280,69.6094,1003.6406);
					SetPlayerInterior(playerid,6);
					SetCameraBehindPlayer(playerid);
					//SetSpawnInfo(playerid, PlayerInfo[playerid][pTeam], PlayerInfo[playerid][pModel], Unspec[playerid][Coords][0], Unspec[playerid][Coords][1], Unspec[playerid][Coords][2], 10.0, -1, -1, -1, -1, -1, -1);
					//SpawnPlayer(playerid);
				}
			}
			else
			{
			    SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ funkcjonariuszem / ¿o³nierzem !");
			    return 1;
			}
		}
		return 1;
	}
	if(strcmp(cmd,"/settax",true)==0)
 {
  if(IsPlayerConnected(playerid))
	 {
	  if(PlayerInfo[playerid][pLeader] != 7)
	  {
				SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ gubernatorem !");
			 return 1;
	  }
	  tmp = strtok(cmdtext, idx);
	
	  if(!strlen(tmp))
   {
				SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /settax [wysokoœæ]");
				format(string, sizeof(string), "Wysokoœæ podatków: %0.3f.", TaxValue);
				SendClientMessage(playerid, COLOR_GREY, string);
				return 1;
			}
			
		 new Float:moneyss = floatstr(tmp);
		 if(moneyss < 0.002 || moneyss > 0.003) { SendClientMessage(playerid, COLOR_GREY, "   Podatki nie mog¹ byæ mniejsze od 0.002 i wiêksze od 0.003!"); return 1; }
			//Tax = moneys;
			TaxValue = moneyss;
			SaveStuff();
			format(string, sizeof(string), "* Od teraz, podatki wynosz¹ %0.3f.", TaxValue);
			SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
	 }
	 return 1;
	}
if(strcmp(cmd,"/podatki",true)==0)
	{
	 if(IsPlayerConnected(playerid))
	 {
	  if(PlayerInfo[playerid][pLeader] == 7)
	  {
	   format(string, sizeof(string), "Ilooa pieniedzy w kasie rz1du: %d", Tax);
	   SendClientMessage(playerid, COLOR_GRAD1, string);
   }
   else
   {
    SendClientMessage(playerid, COLOR_GRAD1, "Nie jesteo gubernatorem");
   }
	  return 1;
	 }
	}
if(strcmp(cmd,"/givetax",true)==0 || strcmp(cmd,"/przekazpodatek",true)==0)
 {
  if(IsPlayerConnected(playerid))
	 {
	  if(PlayerInfo[playerid][pLeader] != 7)
	  {
				SendClientMessage(playerid, COLOR_GREY, "   Nie jesteo gubernatorem !");
				return 1;
	  }
	  if(Tax < 1)
			{
			 SendClientMessage(playerid, COLOR_GREY, "   Nie ma ¿adnych pieniêdzy z podatków !");
				return 1;
			}
			
			new command[10];
			
			tmp = strtok(cmdtext, idx);
	  if(!strlen(tmp))
	  {
	  	SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /przekazpodatek [organizacja] [kwota]");
    SendClientMessage(playerid, COLOR_GRAD1, "Organizacje: policja, swat, lsbg, samers, fbi, akademia, rz¹d");
	  	return 1;
	  }
	  strmid(command, tmp, 0, sizeof(tmp), sizeof(command));
	
	  new orggId = -999;
	
	  if(!strcmp(command, "policja", true))
	  {
 	  orggId = 1;
	  }
	  else if(!strcmp(command, "swat", true))
	  {
	   orggId = 2;
	  }
	  else if(!strcmp(command, "lsbg", true))
	  {
	   orggId = 3;
	  }
	  else if(!strcmp(command, "samers", true))
	  {
	   orggId = 4;
	  }
	  else if(!strcmp(command, "rzad", true) || !strcmp(command, "rz¹d", true))
	  {
	   orggId = 7;
	  }
	  else if(!strcmp(command, "fbi", true))
	  {
	   orggId = 13;
	  }
	  else if(!strcmp(command, "akademia", true))
	  {
	   orggId = 17;
	  }
   else
   {
    SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /przekazpodatek [organizacja] [kwota]");
    SendClientMessage(playerid, COLOR_GRAD1, "Organizacje: policja, swat, lsbg, samers, fbi, akademia, rz¹d");
	  	return 1;
   }
	
	  tmp = strtok(cmdtext, idx);
	  if(!strlen(tmp))
	  {
	  	SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /przekazpodatek [organizacja] [kwota]");
    SendClientMessage(playerid, COLOR_GRAD1, "Organizacje: policja, swat, lsbg, samers, fbi, akademia, rz¹d");
	  	return 1;
	  }
	  new taxamount = strval(tmp);
	
	  if(taxamount > Tax)
	  {
	   SendClientMessage(playerid, COLOR_GRAD1, "Nie ma takiej iloœci pieniêdzy w kasie rz¹du.");
	  	return 1;
	  }
	
	  new Leaders = 0;
			for(new i = 0; i < MAX_PLAYERS; i++)
			{
			 if(IsPlayerConnected(i))
			 {
			  if(PlayerInfo[i][pLeader] == orggId)
			  {
			   Leaders += 1;
			  }
			 }
			}
			if(Leaders == 1)
			{		
    for(new i = 0; i < MAX_PLAYERS; i++)
				{
				 if(IsPlayerConnected(i))
				 {
				  if(PlayerInfo[i][pLeader] == orggId)
				  {
				   format(string, sizeof(string), "* Otrzyma³eœ $%d na konto bankowe z podatków od Gubernatora Miasta.", taxamount);
							SendClientMessage(i, COLOR_LIGHTBLUE, string);
							PlayerInfo[i][pAccount] += taxamount;
							Tax -= taxamount;
							
							// logujemy dzia³ania gubernatora
							GetPlayerName(playerid, sendername, sizeof(sendername));
							GetPlayerName(i, giveplayer, sizeof(giveplayer));
							format(string, sizeof(string), "Gubernator %s przekaza³ %d liderowi %s (ID frakcji: %d)", sendername, taxamount, giveplayer, orggId);
							GLog(string);
				  }
				 }
				}
				SaveStuff();
			}
			else if(Leaders == 0)
			{
			 SendClientMessage(playerid, COLOR_GREY, "W tej chwili nie ma ¿adnego lidra wybranej frakcji w grze !");
				return 1;
			}
			else
			{
			 SendClientMessage(playerid, COLOR_GREY, "Kolizja liderów frakcji (wiêcej ni¿ jeden lider na serwerze)!");
				return 1;
			}
		}
	  return 1;
	}
	if(strcmp(cmd, "/dostarcz", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
	  if(PlayerInfo[playerid][pJob] == 15 || GetPlayerOrganization(playerid) == 1 || PlayerInfo[playerid][pLeader] == 6 || PlayerInfo[playerid][pLeader] == 10)
	  {
	   if(IsACop(playerid))
	   {
	    if(!PlayerToPoint(8.0,playerid,96.9123,1920.5088,18.1473))
					{
					 SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ przy bramie Fortu DeMorgan !");
					 return 1;
					}
					tmp = strtok(cmdtext, idx);
					if(!strlen(tmp))
					{
						SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /dostarcz [IdGracza/CzêœæNazwy]");
						return 1;
					}
			        giveplayerid = ReturnUser(tmp);
					if (IsPlayerConnected(giveplayerid))
					{
					    if(giveplayerid != INVALID_PLAYER_ID)
					    {
					        if(giveplayerid == playerid) { SendClientMessage(playerid, COLOR_GREY, "   Nie mo¿esz siebie przenieœæ do Fort DeMorgan !"); return 1; }
					        if(WantedLevel[giveplayerid] < 1) { SendClientMessage(playerid, COLOR_GREY, "   Gracz musi posadaæ conajmniej 1 poziom poszukiwañ by go umieœciæ w Fort DeMorgan !"); return 1; }
					        if(GetPlayerOrganization(playerid) == 1 || PlayerInfo[giveplayerid][pLeader] == 6 || PlayerInfo[giveplayerid][pLeader] == 10) { return 1; }
							if (ProxDetectorS(8.0, playerid, giveplayerid))
							{
								GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
								GetPlayerName(playerid, sendername, sizeof(sendername));
								format(string, sizeof(string), "* Wrzuci³eœ %s do Fortu DeMorgan.", giveplayer);
								SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
								format(string, sizeof(string), "* %s wrzuci³ ciebie do Fortu DeMorgan.", sendername);
								SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
								GameTextForPlayer(giveplayerid, "~w~Witamy w ~n~~r~For DeMorgan", 5000, 3);
								WantedPoints[giveplayerid] = 0;
								WantedLevel[giveplayerid] = 0;
								SetPlayerWantedLevel(giveplayerid, WantedLevel[giveplayerid]);
								PlayerInfo[giveplayerid][pJailed] = 2;
								PlayerInfo[giveplayerid][pJailTime] = 3600;
								SetPlayerPosEx(giveplayerid, 107.2300,1920.6311,18.5208);
								SetPlayerWorldBounds(giveplayerid, 337.5694,101.5826,1940.9759,1798.7453); //285.3481,96.9720,1940.9755,1799.0811
							}
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GREY, "Nikogo tutaj nie ma !");
					    	return 1;
						}
					}
					else
					{
					    SendClientMessage(playerid, COLOR_GREY, "Ten gracz teraz nie gra !");
					    return 1;
					}
    }
   }
		}
		return 1;
	}
	if(strcmp(cmd, "/zmianaspawnu", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
	   /*if(Spectate[playerid] != 255 && PlayerInfo[playerid][pAdmin] < 1)
	   {
	    SendClientMessage(playerid, COLOR_GREY, "W tej chwili nie mo¿esz zmieniæ spawnu !");
	    return 1;
     }*/
		 
	   if(SpawnChange[playerid])
	   {
	    SendClientMessage(playerid, COLOR_GREY, "Teraz bêdziesz sie spawnowa³ w normalnym miejscu !");
	
      SpawnChange[playerid] = 0;
	    PlayerInfo[playerid][pChangeSpawn] = 0;
	   }
	   else
	   {
	    SendClientMessage(playerid, COLOR_GREY, "Aktualnie spawnujesz siê w swoim domu!");
	    SpawnChange[playerid] = 1;
	    PlayerInfo[playerid][pChangeSpawn] = 1;
	   }
	 }
	 return 1;
	}
	
	if(strcmp(cmd, "/take", true) == 0 || strcmp(cmd, "/zabierz", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
	        if(IsACop(playerid))
	        {
	            if(PlayerInfo[playerid][pRank] < 2)
	            {
	                SendClientMessage(playerid, COLOR_GREY, "   Musisz mieæ 2 rangê albo wy¿sz¹, aby zabraæ licencjê !");
	                return 1;
	            }
	            new x_nr[24];
				x_nr = strtok(cmdtext, idx);
				if(!strlen(x_nr)) {
					SendClientMessage(playerid, COLOR_WHITE, "|__________________ Zabierz licencje __________________|");
					SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /zabierz [nazwa] [IdGracza/CzêœæNazwy]");
			  		SendClientMessage(playerid, COLOR_GREY,  "Dostêpne Licencje: PrawoJazdy, LicencjePilota");
			  		SendClientMessage(playerid, COLOR_GREY,  "Dostêpne Licencje: Licencje¯eglarza, LicencjeNaBroñ");
                    SendClientMessage(playerid, COLOR_GREY,  "Dostêpne Nazwy: Broñ, Narkotyki, Materia³y");
					SendClientMessage(playerid, COLOR_WHITE, "|______________________________________________________|");
					return 1;
				}
			    if(strcmp(x_nr,"PrawoJazdy",true) == 0)
				{
				    tmp = strtok(cmdtext, idx);
					if(!strlen(tmp)) {
						SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /zabierz PrawoJazdy [IdGracza/CzêœæNazwy]");
						return 1;
					}
					giveplayerid = ReturnUser(tmp);
					if(IsPlayerConnected(giveplayerid))
					{
					    if(giveplayerid != INVALID_PLAYER_ID)
					    {
					        if (DistanceBetweenPlayers(8.0, playerid, giveplayerid, true))
							{
						        format(string, sizeof(string), "* Zabra³eœ %s licencjê na prowadzenie auta!", giveplayer);
						        SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						        format(string, sizeof(string), "* Policjant %s zabra³ Twoj¹ licencjê na prowadzenie auta.", sendername);
						        SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
						        PlayerInfo[giveplayerid][pCarLic] = 0;
							}
							else
							{
							    SendClientMessage(playerid, COLOR_GREY, "   Nie ma takiego gracza w pobli¿u !");
							    return 1;
							}
					    }
					}
					else
					{
					    SendClientMessage(playerid, COLOR_GREY, "   Gracz niedostêpny !");
					    return 1;
					}
				}
				else if(strcmp(x_nr,"LicencjePilota",true) == 0)
				{
				    tmp = strtok(cmdtext, idx);
					if(!strlen(tmp)) {
						SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /zabierz LicencjePilota [IdGracza/CzêœæNazwy]");
						return 1;
					}
					giveplayerid = ReturnUser(tmp);
					if(IsPlayerConnected(giveplayerid))
					{
					    if(giveplayerid != INVALID_PLAYER_ID)
					    {
					        if (DistanceBetweenPlayers(8.0, playerid, giveplayerid, true))
							{
						        format(string, sizeof(string), "* Zabra³eœ %s licencjê pilota!", giveplayer);
						        SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						        format(string, sizeof(string), "* Policjant %s zabra³ Twoj¹ licencjê pilota.", sendername);
						        SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
						        PlayerInfo[giveplayerid][pFlyLic] = 0;
							}
							else
							{
							    SendClientMessage(playerid, COLOR_GREY, "   Nie ma takiego gracza w pobli¿u !");
							    return 1;
							}
					    }
					}
					else
					{
					    SendClientMessage(playerid, COLOR_GREY, "   Gracz niedostêpny !");
					    return 1;
					}
				}
				else if(strcmp(x_nr,"LicencjeNaBroñ",true) == 0 || strcmp(x_nr,"LicencjeNaBron",true) == 0)
				{
				    tmp = strtok(cmdtext, idx);
					if(!strlen(tmp)) {
						SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /zabierz LicencjeNaBroñ [IdGracza/CzêœæNazwy]");
						return 1;
					}
					giveplayerid = ReturnUser(tmp);
					if(IsPlayerConnected(giveplayerid))
					{
					    if(giveplayerid != INVALID_PLAYER_ID)
					    {
					        if (DistanceBetweenPlayers(8.0, playerid, giveplayerid, true))
							{
						        format(string, sizeof(string), "* Zabra³eœ %s licencjê na broñ!", giveplayer);
						        SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						        format(string, sizeof(string), "* Policjant %s zabra³ Twoj¹ licencjê na broñ.", sendername);
						        SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
						        PlayerInfo[giveplayerid][pGunLic] = 0;
					        }
					        else
							{
							    SendClientMessage(playerid, COLOR_GREY, "   Nie ma takiego gracza w pobli¿u !");
							    return 1;
							}
					    }
					}
					else
					{
					    SendClientMessage(playerid, COLOR_GREY, "   Gracz niedostêpny !");
					    return 1;
					}
				}
				else if(strcmp(x_nr,"Licencje¯eglarza",true) == 0 || strcmp(x_nr,"LicencjeZeglarza",true) == 0)
				{
				    tmp = strtok(cmdtext, idx);
					if(!strlen(tmp)) {
						SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /zabierz Licencje¯eglarza [IdGracza/CzêœæNazwy]");
						return 1;
					}
					giveplayerid = ReturnUser(tmp);
					if(IsPlayerConnected(giveplayerid))
					{
					    if(giveplayerid != INVALID_PLAYER_ID)
					    {
					        if (DistanceBetweenPlayers(8.0, playerid, giveplayerid, true))
							{
						        format(string, sizeof(string), "* Zabra³eœ %s licencjê ¿eglarza!", giveplayer);
						        SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						        format(string, sizeof(string), "* Policjant %s zabra³ Twoj¹ licencjê na ³odki.", sendername);
						        SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
						        PlayerInfo[giveplayerid][pBoatLic] = 0;
					        }
					        else
							{
							    SendClientMessage(playerid, COLOR_GREY, "   Nie ma takiego gracza w pobli¿u !");
							    return 1;
							}
					    }
					}
					else
					{
					    SendClientMessage(playerid, COLOR_GREY, "   Gracz niedostêpny !");
					    return 1;
					}
				}
				else if(strcmp(x_nr,"broñ",true) == 0 || strcmp(x_nr,"bron",true) == 0)
				{
				 tmp = strtok(cmdtext, idx);
					if(!strlen(tmp)) {
						SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /zabierz broñ [IdGracza/CzêœæNazwy]");
						return 1;
					}
					giveplayerid = ReturnUser(tmp);
					if(IsPlayerConnected(giveplayerid))
					{
					 if(giveplayerid != INVALID_PLAYER_ID)
					 {
					  if (DistanceBetweenPlayers(8.0, playerid, giveplayerid, true))
							{
						  format(string, sizeof(string), "* Zabra³eœ %s wszystkie bronie!", giveplayer);
						  SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						  format(string, sizeof(string), "* Policjant %s skonfiskowa³ Twoje bronie.", sendername);
						  SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
						  ResetPlayerWeaponsEx(giveplayerid);
					  }
					  else
							{
							 SendClientMessage(playerid, COLOR_GREY, "   Nie ma takiego gracza w pobli¿u !");
							 return 1;
							}
					 }
					}
					else
					{
					 SendClientMessage(playerid, COLOR_GREY, "  Gracz niedostêpny !");
					 return 1;
					}
				}
				else if(strcmp(x_nr,"narkotyki",true) == 0)
				{
				    tmp = strtok(cmdtext, idx);
					if(!strlen(tmp)) {
						SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /zabierz narkotyki [IdGracza/CzêœæNazwy]");
						return 1;
					}
					giveplayerid = ReturnUser(tmp);
					if(IsPlayerConnected(giveplayerid))
					{
					    if(giveplayerid != INVALID_PLAYER_ID)
					    {
					        if (DistanceBetweenPlayers(8.0, playerid, giveplayerid, true))
							{
							    format(string, sizeof(string), "* Zabra³eœ %s wszystkie narkotyki!", giveplayer);
						        SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						        format(string, sizeof(string), "* Policjant %s zabra³ Twoje narkotyki.", sendername);
						        SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
						        PlayerInfo[giveplayerid][pDrugs] = 0;
							}
					        else
							{
							    SendClientMessage(playerid, COLOR_GREY, "   Nie ma takiego gracza w pobli¿u !");
							    return 1;
							}
					    }
					}
					else
					{
					    SendClientMessage(playerid, COLOR_GREY, "   Gracz niedostêpny !");
					    return 1;
					}
				}
				else if(strcmp(x_nr,"materia³y",true) == 0 || strcmp(x_nr,"materialy",true) == 0)
				{
				    tmp = strtok(cmdtext, idx);
					if(!strlen(tmp)) {
						SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /zabierz materia³y [IdGracza/CzêœæNazwy]");
						return 1;
					}
					giveplayerid = ReturnUser(tmp);
					if(IsPlayerConnected(giveplayerid))
					{
					    if(giveplayerid != INVALID_PLAYER_ID)
					    {
					        if (DistanceBetweenPlayers(8.0, playerid, giveplayerid, true))
							{
							    format(string, sizeof(string), "* Zabra³eœ %s wszystkie materia³y!", giveplayer);
						        SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						        format(string, sizeof(string), "* Policjant %s zabra³ Twoje materia³y.", sendername);
						        SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
						        PlayerInfo[giveplayerid][pMats] = 0;
							}
					        else
							{
							    SendClientMessage(playerid, COLOR_GREY, "   Nie ma takiego gracza w pobli¿u !");
							    return 1;
							}
					    }
					}
					else
					{
					    SendClientMessage(playerid, COLOR_GREY, "   Gracz niedostêpny !");
					    return 1;
					}
				}
				else
				{
					SendClientMessage(playerid, COLOR_GREY, "   Nieznana licencja !");
					return 1;
				}
	        }
	        else
	        {
	            SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ policjantem !");
	            return 1;
	        }
	    }
	    return 1;
	}
	if(strcmp(cmd, "/pokazmenu", true) == 0 || strcmp(cmd, "/poka¿menu", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
	  if(IsAtBar(playerid))
	  {
	   tmp = strtok(cmdtext, idx);
 	  if(!strlen(tmp))
 	  {
 	  	SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /poka¿menu [IdGracza/CzêœæNazwy]");
 	  	return 1;
 	  }
 	  giveplayerid = ReturnUser(tmp);
 	
 	  if(playerid == giveplayerid)
	   {
	    SendClientMessage(playerid, COLOR_GRAD1, "Nie mo¿esz pokazaæ menu samemu sobie.");
 	  	return 1;
	   }
	
	   if(!IsPlayerConnected(giveplayerid))
	   {
	    SendClientMessage(playerid, COLOR_GRAD1, "Nie ma takiej osoby w pobli¿u.");
 	  	return 1;
	   }
	
	   if(GetDistanceBetweenPlayers(playerid,giveplayerid)>4)
 	  {
 	   SendClientMessage(playerid, COLOR_GRAD1, "Nie ma takiej osoby w pobli¿u.");
 	  	return 1;
 	  }
 	
 	  GetPlayerNameEx(playerid, sendername, sizeof(sendername));
  	 GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
  	
 			format(string, sizeof(string), "* %s poda³ menu do r¹k %s", sendername, giveplayer);
 			ProxDetector(15.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
 	
 	  SendClientMessage(giveplayerid, COLOR_WHITE, "|_________________ Drinki _______________|");
		  SendClientMessage(giveplayerid, COLOR_GREY,  "Piwo ($2), Wódka ($5), Whiskey ($7)");
		  SendClientMessage(giveplayerid, COLOR_GREY,  "Soda ($1), Woda");
				SendClientMessage(giveplayerid, COLOR_WHITE, "|________________________________________|");
	  }
	 }
	}
	if(strcmp(cmd, "/setchamp", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
	  if(PlayerInfo[playerid][pAdmin] >= 1337)
	  {
	   tmp = strtok(cmdtext, idx);
				if(!strlen(tmp))
				{
					SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /setchamp [IdGracza/CzêœæNazwy]");
					return 1;
				}
		
		  giveplayerid = ReturnUser(tmp);
		  if(IsPlayerConnected(giveplayerid))
		  {
		   if(giveplayerid != INVALID_PLAYER_ID)
		   {
		    GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
		    new nstring[MAX_PLAYER_NAME];
						format(nstring, sizeof(nstring), "%s", giveplayer);
						strmid(Titel[TitelName], nstring, 0, strlen(nstring), 255);
						Titel[TitelWins] = PlayerInfo[giveplayerid][pWins];
						Titel[TitelLoses] = PlayerInfo[giveplayerid][pLoses];
						SaveBoxer();
						format(string, sizeof(string), "* Ustanowi³eœ %s nowym mistrzem w Boksie !", giveplayer);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
		   }
		  }
		  else
		  {
		   SendClientMessage(playerid, COLOR_GREY, "Ten gracz nie jest dostêpny !");
		   return 1;
	   }
   }
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "Nie jesteœ uprawniony do u¿ycia tej komendy !");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/boxstats", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
	  if(PlayerInfo[playerid][pJob] != 12)
	  {
	   SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ Bokserem !");
	   return 1;
	  }
	
   new ttext[20];//Title
	  new clevel = PlayerInfo[playerid][pBoxSkill];
			if(clevel >= 0 && clevel <= 50) { ttext = "Pocz¹tkuj¹cy"; }
			else if(clevel >= 51 && clevel <= 200) { ttext = "Amator"; }
			else if(clevel >= 201 && clevel <= 400) { ttext = "Profesionalista"; }
	  new ntext[20];//NickName
	  new level = PlayerInfo[playerid][pWins];
	  if(level > 0 && PlayerInfo[playerid][pLoses] == 0)
	  {
	   ntext = "Niepokonany";
	  }
	  else
	  {
	   if(level >= 0 && level <= 10) { ntext = "¯ó³todziób"; }
	   else if(level >= 11 && level <= 20) { ntext = "Delikatne r¹czki"; }
	   else if(level >= 21 && level <= 30) { ntext = "Rozgniatacz jaj"; }
	   else if(level >= 31 && level <= 40) { ntext = "Sczêko³amacz"; }
	   else if(level >= 41 && level <= 50) { ntext = "Go³ota"; }
	   else if(level >= 51 && level <= 60) { ntext = "Steryd"; }
    else if(level >= 61 && level <= 70) { ntext = "Niez³amany wojownik"; }
	   else if(level >= 71) { ntext = "¯elazna piêœæ"; }
	  }
	
   SendClientMessage(playerid, COLOR_WHITE, "|__________________ Rekordy Bokserskie __________________|");
	  format(string, sizeof(string), "| Aktualny mistrz: %s z [%d] Wygranymi i [%d] przegranymi.", Titel[TitelName],Titel[TitelWins],Titel[TitelLoses]);
			SendClientMessage(playerid, COLOR_GREY, string);
			format(string, sizeof(string), "| Aktualny Tytu³: %s.", ttext);
			SendClientMessage(playerid, COLOR_GREY, string);
			format(string, sizeof(string), "| Aktualny Przydomek: %s.", ntext);
			SendClientMessage(playerid, COLOR_GREY, string);
			format(string, sizeof(string), "| Wygranych ³¹cznie: %d.", PlayerInfo[playerid][pWins]);
			SendClientMessage(playerid, COLOR_GREY, string);
			format(string, sizeof(string), "| Przegranych ³¹cznie: %d.", PlayerInfo[playerid][pLoses]);
			SendClientMessage(playerid, COLOR_GREY, string);
	        SendClientMessage(playerid, COLOR_WHITE, "|____________________________________________________|");
		}
		return 1;
	}
	if(strcmp(cmd, "/fight", true) == 0 || strcmp(cmd, "/walka", true) == 0)
 {
  if(IsPlayerConnected(playerid))
  {
   if(PlayerInfo[playerid][pJob] != 12)
   {
    SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ bokserem !");
    return 1;
   }
   if(InRing > 0)
   {
    SendClientMessage(playerid, COLOR_GREY, "   Aktualnie trwa ju¿ walka, poczekaj a¿ siê zakoñczy !");
    return 1;
   }
   if(PlayerBoxing[playerid] > 0)
   {
    SendClientMessage(playerid, COLOR_GREY, "   Walczysz w tym momencie !");
    return 1;
   }
   if(!PlayerToPoint(20.0,playerid,765.9343,0.2761,1000.7173))
   {
    SendClientMessage(playerid, COLOR_GREY, "   Nie ma Ciê w Si³owni Groove Street !");
    return 1;
   }
   tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
   {
				SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /walka [IdGracza/CzêœæNazwy]");
				return 1;
			}
			giveplayerid = ReturnUser(tmp);
		 if(IsPlayerConnected(giveplayerid))
			{
			 if(giveplayerid != INVALID_PLAYER_ID)
			 {
			  if (ProxDetectorS(8.0, playerid, giveplayerid))
				 {
					 if(giveplayerid == playerid) { SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz walczyæ z samym sob¹!"); return 1; }
					 GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
						GetPlayerName(playerid, sendername, sizeof(sendername));
						format(string, sizeof(string), "* Zaoferowa³eœ Walkê Boksersk¹ bokserowi %s.", giveplayer);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "* Bokser %s chcê walczyæ z Tob¹ (wpisz /akceptuj walka aby zaakceptowaæ).", sendername);
						SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
				  BoxOffer[giveplayerid] = playerid;
					}
					else
					{
						SendClientMessage(playerid, COLOR_GREY, "   Nie ma takiej osoby w pobli¿u !");
						return 1;
					}
			 }
			}
			else
			{
			 SendClientMessage(playerid, COLOR_GREY, "   Ta osoba jest niedostêpna !");
			 return 1;
			}
	 }
	 return 1;
	}
	/*if(strcmp(cmd, "/ipod", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
	  if(PlayerInfo[playerid][pCDPlayer])
	  {
		  new x_nr[32];
				x_nr = strtok(cmdtext, idx);
				if(!strlen(x_nr)) {
					SendClientMessage(playerid, COLOR_WHITE, "|__________________ iPOD __________________|");
					SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /ipod [funkcja]");
			  SendClientMessage(playerid, COLOR_GREY, "Dostêpne funkcje: On, Off, Nastepna");
					SendClientMessage(playerid, COLOR_WHITE, "|___________________________________________|");
					return 1;
				}
			 if(strcmp(x_nr,"on",true) == 0)
				{
				 GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~g~iPod wlaczony", 5000, 5);
				 new channel = Music[playerid];
				 PlayerPlaySound(playerid, Songs[channel][0], 0.0, 0.0, 0.0);
				}
	   else if(strcmp(x_nr,"off",true) == 0)
				{
				 GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~r~iPod wylaczony", 5000, 5);
				 PlayerFixRadio(playerid);
				}
				else if(strcmp(x_nr,"nastepna",true) == 0)
				{
				 if(Music[playerid] == 0) { Music[playerid] = 1; }
				 else if(Music[playerid] == 1) { Music[playerid] = 2; }
				 else if(Music[playerid] == 2) { Music[playerid] = 3; }
				 else if(Music[playerid] == 3) { Music[playerid] = 4; }
				 else if(Music[playerid] == 4) { Music[playerid] = 5; }
				 else if(Music[playerid] == 5) { Music[playerid] = 6; }
				 else if(Music[playerid] == 6) { Music[playerid] = 0; }
				 new channel = Music[playerid];
				 PlayerPlaySound(playerid, Songs[channel][0], 0.0, 0.0, 0.0);
				}
				else
				{
				 SendClientMessage(playerid, COLOR_GREY, "   Nieznana komenda !");
				 return 1;
				}
			}
			else
			{
		  SendClientMessage(playerid, COLOR_GREY, "   Nie masz iPoda !");
		  return 1;
			}
	 }
	 return 1;
	}*/
	if(strcmp(cmd, "/wezwij", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
	  if(PlayerInfo[playerid][pWounded] > 0)
			{
			 SendClientMessage(playerid, COLOR_GREY, "Jesteœ nieprzytomny, nie mo¿esz siê odezwaæ.");
			 return 1;
			}
			
	  if(!HasPlayerItemByType(playerid, ITEM_CELLPHONE))
			{
			 SendClientMessage(playerid, COLOR_GRAD2, "  Nie masz telefonu komórkowego !");
				return 1;
			}
			
			new x_nr[32];
			x_nr = strtok(cmdtext, idx);
			if(!strlen(x_nr)) {
			SendClientMessage(playerid, COLOR_WHITE, "|__________________ Wezwij______________________|");
			SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /wezwij [nazwa]");
		 SendClientMessage(playerid, COLOR_GREY, "Mo¿esz wezwaæ: Taxi, Medyk, Mechanik, Straz");
			SendClientMessage(playerid, COLOR_WHITE, "|________________________________________________|");
				return 1;
			}
		 if(strcmp(x_nr,"taxi",true) == 0)
			{
			 if(PlayerInfo[playerid][pWounded] > 0)
			 {
			  SendClientMessage(playerid, COLOR_GREY, "Jesteœ nieprzytomny, nie mo¿esz siê odezwaæ.");
			  return 1;
			 }
			
			 if(TaxiDrivers < 1)
		  {
		   SendClientMessage(playerid, COLOR_GREY, "	Nie ma ¿adnych wolnych taxówkarzy. Spróbuj ponownie póŸniej !");
		   return 1;
		  }
		  if(TransportDuty[playerid] > 0)
		  {
		   SendClientMessage(playerid, COLOR_GREY, "	Nie mo¿esz dzwoniæ po taxówkê w tym momencie !");
		   return 1;
		  }
		
    GetPlayerNameMask(playerid, sendername, sizeof(sendername));
			 format(string, sizeof(string), "** %s wzywa taxówkê. (Wpisz /akceptuj taxi aby odebraæ wezwanie)", sendername);
		  SendFamilyMessage(10, TEAM_AZTECAS_COLOR, string);
		  SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Twoje zg³oszenie zosta³o wys³ane, poczekaj na odpowiedŸ.");
		  TaxiCall = playerid;
		  return 1;
			}
			else if(strcmp(x_nr,"medyk",true) == 0)
			{
			 if(PlayerInfo[playerid][pWounded] > 0)
			 {
			  SendClientMessage(playerid, COLOR_GREY, "Jesteœ nieprzytomny, nie mo¿esz siê odezwaæ.");
			  return 1;
			 }
			
			 if(Medics < 1)
		  {
		   SendClientMessage(playerid, COLOR_GREY, "   Nie ma ¿adnych medyków na s³u¿bie. Spróbuj ponownie póŸniej !");
		   return 1;
		  }
		  GetPlayerNameEx(playerid, sendername, sizeof(sendername));
			 format(string, sizeof(string), "** %s potrzebuje medyka. (Wpisz /akceptuj medyk aby odebraæ wezwanie)", sendername);
		  SendRadioMessage(4, TEAM_AZTECAS_COLOR, string);
		  SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Zadzwoni³eœ po medyka. Poczekaj na odpowiedŸ.");
		  MedicCall = playerid;
		  return 1;
			}
			else if(strcmp(x_nr,"straz",true) == 0)
			{
			 if(PlayerInfo[playerid][pWounded] > 0)
			 {
			  SendClientMessage(playerid, COLOR_GREY, "Jesteœ nieprzytomny, nie mo¿esz siê odezwaæ.");
			  return 1;
			 }

		  GetPlayerNameEx(playerid, sendername, sizeof(sendername));
			 format(string, sizeof(string), "** %s potrzebuje stra¿y po¿arnej. (Wpisz /akceptuj straz aby odebraæ wezwanie)", sendername);
		  SendRadioMessage(18, TEAM_AZTECAS_COLOR, string);
		  SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Zadzwoni³eœ po stra¿ po¿arn¹. Poczekaj na odpowiedŸ.");
		  MedicCall = playerid;
		  return 1;
			}
			else if(strcmp(x_nr,"mechanik",true) == 0)
			{
			 if(PlayerInfo[playerid][pWounded] > 0)
			 {
			  SendClientMessage(playerid, COLOR_GREY, "Jesteœ nieprzytomny, nie mo¿esz siê odezwaæ.");
			  return 1;
			 }
			 if(Mechanics < 1)
		  {
		   SendClientMessage(playerid, COLOR_GREY, "   Nie ma ¿adnych mechaników na s³u¿bie. Spróbuj ponownie póŸniej !");
		   return 1;
		  }
		  GetPlayerNameEx(playerid, sendername, sizeof(sendername));
			 format(string, sizeof(string), "** %s potrzebuje mechanika. (Wpisz /akceptuj mechanik aby odebraæ wezwanie)", sendername);
		  SendJobWithDutyMessage(7, TEAM_AZTECAS_COLOR, string);
		  SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Zadzwoni³eœ po mechanika. Poczekaj na odpowiedŸ.");
		  MechanicCall = playerid;
		  return 1;
			}
			else
			{
			 SendClientMessage(playerid, COLOR_GREY, "   B³êdna nazwa !");
			 return 1;
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/tie", true) == 0 || strcmp(cmd, "/zwiaz", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
			if(IsAMember(playerid) || IsUnofficialGangMember(playerid) || PlayerInfo[playerid][pLeader] == 14 || PlayerInfo[playerid][pMember] == 14 || PlayerInfo[playerid][pLeader] == 15 || PlayerInfo[playerid][pMember] == 15 || PlayerInfo[playerid][pLeader] == 16 || PlayerInfo[playerid][pMember] == 16
				|| GetPlayerOrganization(playerid) == 19)
			{
			 if(PlayerInfo[playerid][pRank] < 1)
			 {
			  SendClientMessage(playerid, COLOR_GREY, "Potrzebujesz 1 rangê lub wy¿sz¹ aby wi¹zaæ ludzi !");
			  return 1;
			 }
			
    tmp = strtok(cmdtext, idx);
				if(!strlen(tmp)) {
					SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /zwiaz [IdGracza/CzêœæNazwy]");
					return 1;
				}
				giveplayerid = ReturnUser(tmp);
			 if(IsPlayerConnected(giveplayerid))
				{
				 if(giveplayerid != INVALID_PLAYER_ID)
				 {
					 if(PlayerTied[giveplayerid] > 0)
					 {
					  SendClientMessage(playerid, COLOR_GREY, "   Ta osoba jest ju¿ zwi¹zana !");
					  return 1;
					 }
					
     	if (ProxDetectorS(8.0, playerid, giveplayerid))
						{
					  new car = GetPlayerVehicleID(playerid);
					  if(giveplayerid == playerid) { SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz zwi¹zaæ samego siebie!"); return 1; }
					  if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == 2 && IsPlayerInVehicle(giveplayerid, car))
					  {
					   GetPlayerNameMask(giveplayerid, giveplayer, sizeof(giveplayer));
								GetPlayerNameMask(playerid, sendername, sizeof(sendername));
						  format(string, sizeof(string), "* Zosta³eœ zwi¹zany przez %s.", sendername);
								SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
								format(string, sizeof(string), "* Zwi¹za³eœ %s.", giveplayer);
								SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
								format(string, sizeof(string), "* %s zwi¹za³ %s.", sendername ,giveplayer);
								ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
								GameTextForPlayer(giveplayerid, "~r~Zwiazany", 2500, 3);
								TogglePlayerControllable(giveplayerid, 0);
								PlayerTied[giveplayerid] = 1;
					  }
					  else
					  {
					   SendClientMessage(playerid, COLOR_GREY, "   Nie ma takiej osoby w Twoim pojeŸdzie lub nie jesteœ kierowc¹ !");
					   return 1;
					  }
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GREY, "   Nie ma takiej osoby w pobli¿u !");
						    return 1;
						}
					}
				}
				else
				{
				    SendClientMessage(playerid, COLOR_GREY, "   Gracz jest niedostêpny !");
				    return 1;
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ cz³onkiem, liderem rodziny !");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/untie", true) == 0 || strcmp(cmd, "/rozwiaz", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
			if(IsAMember(playerid) || IsUnofficialGangMember(playerid) || PlayerInfo[playerid][pLeader] == 14 || PlayerInfo[playerid][pMember] == 14 || PlayerInfo[playerid][pLeader] == 15 || PlayerInfo[playerid][pMember] == 15 || PlayerInfo[playerid][pLeader] == 16 || PlayerInfo[playerid][pMember] == 16
			 || GetPlayerOrganization(playerid) == 19)
			{
			 if(PlayerInfo[playerid][pRank] < 3)
			 {
			  SendClientMessage(playerid, COLOR_GREY, "   Potrzebujesz 3 rangê lub wy¿sz¹ aby wi¹zaæ ludzi !");
			  return 1;
			 }
			 tmp = strtok(cmdtext, idx);
				if(!strlen(tmp)) {
					SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /rozwiaz [IdGracza/CzêœæNazwy]");
					return 1;
				}
				giveplayerid = ReturnUser(tmp);
				if(IsPlayerConnected(giveplayerid))
				{
					if(giveplayerid != INVALID_PLAYER_ID)
					{
		    if (ProxDetectorS(8.0, playerid, giveplayerid))
						{
						 if(PlayerInfo[giveplayerid][pWounded] > 0)
			    {
			     SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest nieprzytomna.");
			     return 1;
   			 }
			    if(giveplayerid == playerid) { SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz rozwi¹Ÿaæ samego siebie!"); return 1; }
							if(PlayerTied[giveplayerid])
							{
							    GetPlayerNameMask(giveplayerid, giveplayer, sizeof(giveplayer));
								GetPlayerNameMask(playerid, sendername, sizeof(sendername));
							    format(string, sizeof(string), "* Zosta³eœ rozwi¹zany przez %s.", sendername);
								SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
								format(string, sizeof(string), "* Rozwi¹za³eœ %s.", giveplayer);
								SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
								GameTextForPlayer(giveplayerid, "~g~Rozwiazany", 2500, 3);
								TogglePlayerControllable(giveplayerid, 1);
								PlayerTied[giveplayerid] = 0;
							}
							else
							{
							    SendClientMessage(playerid, COLOR_GREY, "   Ta osoba nie jest zwi¹zana !");
							    return 1;
							}
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GREY, "   Nie ma takiej osoby w pobli¿u !");
						    return 1;
						}
					}
				}
				else
				{
				    SendClientMessage(playerid, COLOR_GREY, "   Ta osoba jest niedostêpna !");
				    return 1;
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ cz³onkiem, liderem rodziny !");
			}
		}//not connected
		return 1;
	}
	if(strcmp(cmd, "/sell", true) == 0 || strcmp(cmd, "/sprzedajjedzenie", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			new x_nr[32];
			x_nr = strtok(cmdtext, idx);
			if(!strlen(x_nr)) {
				SendClientMessage(playerid, COLOR_WHITE, "|__________________ Sprzeda¿ __________________|");
				SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /sprzedajjedzenie [nazwa]");
		  		SendClientMessage(playerid, COLOR_GREY, "Dostêpne nazwy: Ryba");
				SendClientMessage(playerid, COLOR_WHITE, "|______________________________________________|");
				return 1;
			}
		    if(strcmp(x_nr,"ryba",true) == 0)
			{
			    if (!PlayerToPoint(100, playerid,-30.875, -88.9609, 1004.53))//centerpoint 24-7
				{
					SendClientMessage(playerid, COLOR_GRAD2, "   Nie jesteœ w 24-7 !");
					return 1;
				}
			    tmp = strtok(cmdtext, idx);
				if(!strlen(tmp)) {
					SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /sprzedajjedzenie ryba [ryba]");
					return 1;
				}
				new price;
				new fishid = strval(tmp);
				if(fishid < 1 || fishid > 5) { SendClientMessage(playerid, COLOR_GREY, "   Numer ryby nie mo¿e byæ mniejszy od 1 i wiêkszy od 5 !"); return 1; }
				else if(fishid == 1 && Fishes[playerid][pWeight1] < 1) { SendClientMessage(playerid, COLOR_GREY, "   Nie posiadasz ryby o takim numerze(1) !"); return 1; }
				else if(fishid == 2 && Fishes[playerid][pWeight2] < 1) { SendClientMessage(playerid, COLOR_GREY, "   Nie posiadasz ryby o takim numerze(2) !"); return 1; }
				else if(fishid == 3 && Fishes[playerid][pWeight3] < 1) { SendClientMessage(playerid, COLOR_GREY, "   Nie posiadasz ryby o takim numerze(3) !"); return 1; }
				else if(fishid == 4 && Fishes[playerid][pWeight4] < 1) { SendClientMessage(playerid, COLOR_GREY, "   Nie posiadasz ryby o takim numerze(4) !"); return 1; }
				else if(fishid == 5 && Fishes[playerid][pWeight5] < 1) { SendClientMessage(playerid, COLOR_GREY, "   Nie posiadasz ryby o takim numerze(5) !"); return 1; }
				
				switch (fishid)
				{
		    case 1:
		    {
       if(Fishes[playerid][pWeight1] < 5)
       {
        SendClientMessage(playerid, COLOR_WHITE, "Jesteœmy zainsteresowani tylko rybami o wadze 5 Kg lub wiêkszej.");
        return 1;
       }
       price = FishCost(playerid, Fishes[playerid][pFid1]);
       price = price * (Fishes[playerid][pWeight1]/2);

       GameTextForPlayer(playerid, "~g~Ryba~n~~r~Sprzedana", 3000, 1);
       format(string, sizeof(string), "* Sprzeda³eœ rybê %s która wa¿y %d, za $%d.", Fishes[playerid][pFish1],Fishes[playerid][pWeight1],price);
			  		SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
				 		GivePlayerMoneyEx(playerid, price);
				 		ClearFishID(playerid, 1);
				  }
				  case 2:
				  {
				        if(Fishes[playerid][pWeight2] < 5)
				        {
				            SendClientMessage(playerid, COLOR_WHITE, "Jesteœmy zainsteresowani tylko rybami o wadze 5 Kg lub wiêkszej.");
				            return 1;
				        }
            			price = FishCost(playerid, Fishes[playerid][pFid2]);
                        price = price * (Fishes[playerid][pWeight2]/2);

                        GameTextForPlayer(playerid, "~g~Ryba~n~~r~Sprzedana", 3000, 1);
                        format(string, sizeof(string), "* Sprzeda³eœ rybê %s która wa¿y %d, za $%d.", Fishes[playerid][pFish2],Fishes[playerid][pWeight2],price);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						GivePlayerMoneyEx(playerid, price);
						ClearFishID(playerid, 2);
				    }
				    case 3:
				    {
				        if(Fishes[playerid][pWeight3] < 5)
				        {
				            SendClientMessage(playerid, COLOR_WHITE, "Jesteœmy zainsteresowani tylko rybami o wadze 5 Kg lub wiêkszej.");
				            return 1;
				        }
            			price = FishCost(playerid, Fishes[playerid][pFid3]);
                        price = price * (Fishes[playerid][pWeight3]/2);

                        GameTextForPlayer(playerid, "~g~Ryba~n~~r~Sprzedana", 3000, 1);
                        format(string, sizeof(string), "* Sprzeda³eœ rybê %s która wa¿y %d, za $%d.", Fishes[playerid][pFish3],Fishes[playerid][pWeight3],price);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						GivePlayerMoneyEx(playerid, price);
						ClearFishID(playerid, 3);
				    }
				    case 4:
				    {
				        if(Fishes[playerid][pWeight4] < 5)
				        {
				            SendClientMessage(playerid, COLOR_WHITE, "Jesteœmy zainsteresowani tylko rybami o wadze 5 Kg lub wiêkszej.");
				            return 1;
				        }
            			price = FishCost(playerid, Fishes[playerid][pFid4]);
                        price = price * (Fishes[playerid][pWeight4]/2);

                        GameTextForPlayer(playerid, "~g~Ryba~n~~r~Sprzedana", 3000, 1);
                        format(string, sizeof(string), "* Sprzeda³eœ rybê %s która wa¿y %d, za $%d.", Fishes[playerid][pFish4],Fishes[playerid][pWeight4],price);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						GivePlayerMoneyEx(playerid, price);
						ClearFishID(playerid, 4);
				    }
				    case 5:
				    {
				        if(Fishes[playerid][pWeight5] < 5)
				        {
				            SendClientMessage(playerid, COLOR_WHITE, "Jesteœmy zainsteresowani tylko rybami o wadze 5 Kg lub wiêkszej.");
				            return 1;
				        }
            			price = FishCost(playerid, Fishes[playerid][pFid5]);
                        price = price * (Fishes[playerid][pWeight5]/2);

                        GameTextForPlayer(playerid, "~g~Ryba~n~~r~Sprzedana", 3000, 1);
                        format(string, sizeof(string), "* Sprzeda³eœ rybê %s która wa¿y %d, za $%d.", Fishes[playerid][pFish5],Fishes[playerid][pWeight5],price);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						GivePlayerMoneyEx(playerid, price);
						ClearFishID(playerid, 5);
				    }
				}
				Fishes[playerid][pLastFish] = 0;
				Fishes[playerid][pFishID] = 0;
				return 1;
			}
			else
			{
			    SendClientMessage(playerid, COLOR_GREY, "   B³êdna nazwa !");
			    return 1;
			}
		}
		return 1;
	}
	if(strcmp(cmd,"/fare",true)==0)
 {
  if(IsPlayerConnected(playerid))
	 {
	  //if(PlayerInfo[playerid][pMember] == 10||PlayerInfo[playerid][pLeader] == 10|| PlayerInfo[playerid][pJob] == 14)
	  if(GetPlayerOrganization(playerid) == 10)
			{
				if(TransportDuty[playerid] > 0)
				{
				 if(TransportDuty[playerid] == 1)
				 {
				  TaxiDrivers -= 1;
				 }
				 TransportDuty[playerid] = 0;
					format(string, sizeof(string), "* Koñczysz s³u¿bê. Zarobi³eœ %d$.", TransportMoney[playerid]);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
					GivePlayerMoneyEx(playerid, TransportMoney[playerid]);
					TransportValue[playerid] = 0; TransportMoney[playerid] = 0;
					return 1;
				}
				new Veh = GetPlayerVehicleID(playerid);
				if(GetVehicleType(Veh) == VEHICLE_TYPE_TAXI)
				{
				    if(GetPlayerState(playerid) == 2)
				    {
					    tmp = strtok(cmdtext, idx);
						if(!strlen(tmp))
						{
							SendClientMessage(playerid, COLOR_WHITE, "U¿yj: /fare [cena]");
							return 1;
						}
						moneys = strval(tmp);
						if(moneys < 1 || moneys > 20) { SendClientMessage(playerid, COLOR_GREY, "   Cena musi byæ pomiêdzy 1$ a 20$ !"); return 1; }
					    TaxiDrivers += 1; TransportDuty[playerid] = 1; TransportValue[playerid] = moneys;
					    GetPlayerNameEx(playerid,sendername,sizeof(sendername));
	    				format(string, sizeof(string), "Taksówkarz %s jest w trasie, Cena: $%d.", sendername, TransportValue[playerid]);
	    				OOCNews(TEAM_GROVE_COLOR,string);
					}
					else
					{
					    SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ kierowc¹ !");
					    return 1;
					}
				}
				/*else if(Veh == 64 || Veh == 65)
				{
				 if(GetPlayerState(playerid) == 2)
				 {
					 tmp = strtok(cmdtext, idx);
						if(!strlen(tmp))
						{
							SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /fare [cena]");
							return 1;
						}
						moneys = strval(tmp);
						if(moneys < 1 || moneys > 50) { SendClientMessage(playerid, COLOR_GREY, "   Cena musi byæ pomiêdzy 1$ a 50$ !"); return 1; }
					 BusDrivers += 1; TransportDuty[playerid] = 2; TransportValue[playerid]= moneys;
					 GetPlayerName(playerid,sendername,sizeof(sendername));
	    	format(string, sizeof(string), "Kierowca Autobusu %s jest w trasie, Cena: $%d.", sendername, TransportValue[playerid]);
	    	OOCNews(TEAM_GROVE_COLOR,string);
					}
					else
					{
					 SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ kierowc¹ !");
					 return 1;
					}
				}*/
				else
				{
				    SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ w taksówce !");
				}
			}
			else
			{
			    SendClientMessage(playerid,COLOR_GREY,"   Nie jesteœ Taksówkarzem !");
			    return 1;
			}
	    }
	    return 1;
 	}

 if(strcmp(cmd,"/fish",true)==0)
 {
  if(IsPlayerConnected(playerid))
	 {
	  if(PlayerInfo[playerid][pFishes] > 5)
	  {
	   SendClientMessage(playerid, COLOR_GREY, "   Poczu³eœ siê zmêczony, odpocznij chwilê !");
	   return 1;
	  }
	
   if(Fishes[playerid][pWeight1] > 0 && Fishes[playerid][pWeight2] > 0 && Fishes[playerid][pWeight3] > 0 && Fishes[playerid][pWeight4] > 0 && Fishes[playerid][pWeight5] > 0)
	  {
	   SendClientMessage(playerid, COLOR_GREY, "Z³owi³eœ ju¿ 5 ryb, aby z³owiæ kolejne najpierw zjedz/sprzedaj/wypusæ poprzednie !");
	   return 1;
	  }
	
   new Veh = GetPlayerVehicleID(playerid);
	  if((IsAtFishPlace(playerid)) || IsABoat(Veh))
	  {
	   new Caught;
	   new rand;
	   new fstring[MAX_PLAYER_NAME];
	   new Level = PlayerInfo[playerid][pFishSkill];
	   if(Level >= 0 && Level <= 50) { Caught = random(3)-0; }
	   else if(Level >= 51 && Level <= 100) { Caught = random(5)-1; }
	   else if(Level >= 101 && Level <= 200) { Caught = random(10)-3; }
	   else if(Level >= 201 && Level <= 400) { Caught = random(15)-5; }
	   else if(Level >= 401) { Caught = random(25)-10; }
	   rand = random(sizeof(FishNames));
	
    if(Caught <= 0)
	   {
	    SendClientMessage(playerid, COLOR_GREY, "Urwa³eœ ¿y³kê !");
	    return 1;
	   }
	   else if(rand == 0)
	   {
	    SendClientMessage(playerid, COLOR_GREY, "Z³owi³eœ Nurka, wypuszczasz go !");
	    return 1;
	   }
	   else if(rand == 4)
	   {
	    SendClientMessage(playerid, COLOR_GREY, "Z³owi³eœ majtki, wyrzucasz je do wody !");
	    return 1;
	   }
	   else if(rand == 7)
	   {
	    SendClientMessage(playerid, COLOR_GREY, "Z³owi³eœ puszkê, wyrzucasz j¹ !");
	    return 1;
	   }
	   else if(rand == 10)
	   {
	    SendClientMessage(playerid, COLOR_GREY, "Z³owi³eœ stare kapcie, wyrzucasz je !");
	    return 1;
	   }
	   else if(rand == 13)
	   {
	    SendClientMessage(playerid, COLOR_GREY, "Straci³eœ równowagê jak zarzuca³eœ wêdk¹ !");
	    return 1;
	   }
	   else if(rand == 20)
	   {
	    new mrand = random(30);
	    format(string, sizeof(string), "* Z³owi³eœ torbê z pieniêdzmi, zarobi³eœ $%d.", mrand);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
	    GivePlayerMoneyEx(playerid, mrand);
	    return 1;
	   }
		  /*if(PlayerInfo[playerid][pFishLic] < 1)
		  {
	      WantedPoints[playerid] += 1;
	      SetPlayerWantedLevel(playerid, WantedLevel[playerid]);
			  SetPlayerCriminal(playerid,255, "Nielegalne ³owienie");
			}*/
		  if(Fishes[playerid][pWeight1] == 0)
		  {
		   PlayerInfo[playerid][pFishes] += 1;
		   PlayerInfo[playerid][pFishSkill] += 1;
		   format(fstring, sizeof(fstring), "%s", FishNames[rand]);
					strmid(Fishes[playerid][pFish1], fstring, 0, strlen(fstring), 255);
					Fishes[playerid][pWeight1] = Caught;
					format(string, sizeof(string), "* Z³owi³eœ %s, który wa¿y %d Kg.", Fishes[playerid][pFish1], Caught);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
					Fishes[playerid][pLastWeight] = Caught;
					Fishes[playerid][pLastFish] = 1;
					Fishes[playerid][pFid1] = rand;
					Fishes[playerid][pFishID] = rand;
					if(Caught > PlayerInfo[playerid][pBiggestFish])
					{
			   format(string, sizeof(string), "* Twój stary rekord %d Kg zosta³ przebity, twój nowy rekord to: %d Kg.", PlayerInfo[playerid][pBiggestFish], Caught);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						PlayerInfo[playerid][pBiggestFish] = Caught;
					}
    }
		  else if(Fishes[playerid][pWeight2] == 0)
		  {
		   PlayerInfo[playerid][pFishes] += 1;
		   PlayerInfo[playerid][pFishSkill] += 1;
		   format(fstring, sizeof(fstring), "%s", FishNames[rand]);
					strmid(Fishes[playerid][pFish2], fstring, 0, strlen(fstring), 255);
					Fishes[playerid][pWeight2] = Caught;
					format(string, sizeof(string), "* Z³owi³eœ %s, który wa¿y %d Kg.", Fishes[playerid][pFish2], Caught);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
					Fishes[playerid][pLastWeight] = Caught;
					Fishes[playerid][pLastFish] = 2;
					Fishes[playerid][pFid2] = rand;
					Fishes[playerid][pFishID] = rand;
					if(Caught > PlayerInfo[playerid][pBiggestFish])
					{
					 format(string, sizeof(string), "* Twój stary rekord %d Kg zosta³ przebity, twój nowy rekord to: %d Kg.", PlayerInfo[playerid][pBiggestFish], Caught);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						PlayerInfo[playerid][pBiggestFish] = Caught;
					}
		  }
		  else if(Fishes[playerid][pWeight3] == 0)
		  {
		   PlayerInfo[playerid][pFishes] += 1;
		   PlayerInfo[playerid][pFishSkill] += 1;
		   format(fstring, sizeof(fstring), "%s", FishNames[rand]);
					strmid(Fishes[playerid][pFish3], fstring, 0, strlen(fstring), 255);
					Fishes[playerid][pWeight3] = Caught;
					format(string, sizeof(string), "* Z³owi³eœ %s, który wa¿y %d Kg.", Fishes[playerid][pFish3], Caught);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
					Fishes[playerid][pLastWeight] = Caught;
					Fishes[playerid][pLastFish] = 3;
					Fishes[playerid][pFid3] = rand;
					Fishes[playerid][pFishID] = rand;
					if(Caught > PlayerInfo[playerid][pBiggestFish])
					{
					 format(string, sizeof(string), "* Twój stary rekord %d Kg zosta³ przebity, twój nowy rekord to: %d Kg.", PlayerInfo[playerid][pBiggestFish], Caught);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						PlayerInfo[playerid][pBiggestFish] = Caught;
					}
		  }
		  else if(Fishes[playerid][pWeight4] == 0)
		  {
		   PlayerInfo[playerid][pFishes] += 1;
		   PlayerInfo[playerid][pFishSkill] += 1;
		   format(fstring, sizeof(fstring), "%s", FishNames[rand]);
					strmid(Fishes[playerid][pFish4], fstring, 0, strlen(fstring), 255);
					Fishes[playerid][pWeight4] = Caught;
					format(string, sizeof(string), "* Z³owi³eœ %s, który wa¿y %d Kg.", Fishes[playerid][pFish4], Caught);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
					Fishes[playerid][pLastWeight] = Caught;
					Fishes[playerid][pLastFish] = 4;
					Fishes[playerid][pFid4] = rand;
					Fishes[playerid][pFishID] = rand;
					if(Caught > PlayerInfo[playerid][pBiggestFish])
					{
					 format(string, sizeof(string), "* Twój stary rekord %d Kg zosta³ przebity, twój nowy rekord to: %d Kg.", PlayerInfo[playerid][pBiggestFish], Caught);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						PlayerInfo[playerid][pBiggestFish] = Caught;
					}
		  }
		  else if(Fishes[playerid][pWeight5] == 0)
		  {
		   PlayerInfo[playerid][pFishes] += 1;
		   PlayerInfo[playerid][pFishSkill] += 1;
		   format(fstring, sizeof(fstring), "%s", FishNames[rand]);
					strmid(Fishes[playerid][pFish5], fstring, 0, strlen(fstring), 255);
					Fishes[playerid][pWeight5] = Caught;
					format(string, sizeof(string), "* Z³owi³eœ %s, który wa¿y %d Kg.", Fishes[playerid][pFish5], Caught);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
					Fishes[playerid][pLastWeight] = Caught;
					Fishes[playerid][pLastFish] = 5;
					Fishes[playerid][pFid5] = rand;
					Fishes[playerid][pFishID] = rand;
					if(Caught > PlayerInfo[playerid][pBiggestFish])
					{
					 format(string, sizeof(string), "* Twój stary rekord %d Kg zosta³ przebity, twój nowy rekord to: %d Kg.", PlayerInfo[playerid][pBiggestFish], Caught);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						PlayerInfo[playerid][pBiggestFish] = Caught;
					}
		  }
		  else
		  {
		   SendClientMessage(playerid, COLOR_GREY, "   Nie masz miejsca na ryby !");
		   return 1;
		  }
	   if(PlayerInfo[playerid][pFishSkill] == 50)
				{ SendClientMessage(playerid, COLOR_YELLOW, "* Twój poziom £owienia Ryb to 2, teraz mo¿esz z³apaæ wieksze ryby."); }
				else if(PlayerInfo[playerid][pFishSkill] == 250)
				{ SendClientMessage(playerid, COLOR_YELLOW, "* Twój poziom £owienia Ryb to 3, teraz mo¿esz z³apaæ wieksze ryby."); }
				else if(PlayerInfo[playerid][pFishSkill] == 500)
				{ SendClientMessage(playerid, COLOR_YELLOW, "* Twój poziom £owienia Ryb to 4, teraz mo¿esz z³apaæ wieksze ryby."); }
				else if(PlayerInfo[playerid][pFishSkill] == 1000)
				{ SendClientMessage(playerid, COLOR_YELLOW, "* Twój poziom £owienia Ryb to 5, teraz mo¿esz z³apaæ wieksze ryby."); }
	  }
	  else
	  {
	   SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ na rybackim moœcie (Molo Los Santos) lub na ³ódce !");
	   return 1;
	  }
	 }
  return 1;
 }
	if(strcmp(cmd, "/fishes", true) == 0 || strcmp(cmd, "/ryby", true) == 0)
 {
  if(IsPlayerConnected(playerid))
	 {
	  SendClientMessage(playerid, COLOR_WHITE, "|__________________ Ryby __________________|");
	  format(string, sizeof(string), "** (1) Ryba: %s.   Waga: %d kg.", Fishes[playerid][pFish1], Fishes[playerid][pWeight1]);
			SendClientMessage(playerid, COLOR_GREY, string);
			format(string, sizeof(string), "** (2) Ryba: %s.   Waga: %d kg.", Fishes[playerid][pFish2], Fishes[playerid][pWeight2]);
			SendClientMessage(playerid, COLOR_GREY, string);
			format(string, sizeof(string), "** (3) Ryba: %s.   Waga: %d kg.", Fishes[playerid][pFish3], Fishes[playerid][pWeight3]);
			SendClientMessage(playerid, COLOR_GREY, string);
			format(string, sizeof(string), "** (4) Ryba: %s.   Waga: %d kg.", Fishes[playerid][pFish4], Fishes[playerid][pWeight4]);
			SendClientMessage(playerid, COLOR_GREY, string);
			format(string, sizeof(string), "** (5) Ryba: %s.   Waga: %d kg.", Fishes[playerid][pFish5], Fishes[playerid][pWeight5]);
			SendClientMessage(playerid, COLOR_GREY, string);
			SendClientMessage(playerid, COLOR_WHITE, "|____________________________________________|");
		}
  return 1;
	}

	if(strcmp(cmd,"/uwolnijrybe",true)==0)
	{
	 if(IsPlayerConnected(playerid))
	 {
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /wyrzucrybe [numer ryby]");
				return 1;
			}
			new fishid = strval(tmp);
			if(fishid < 1 || fishid > 5) { SendClientMessage(playerid, COLOR_GREY, "   Numer ryby nie mo¿e byæ mniejszy od 1 i wiêkszy od 5 !"); return 1; }
			else if(fishid == 1 && Fishes[playerid][pWeight1] < 1) { SendClientMessage(playerid, COLOR_GREY, "   Nie posiadasz ryby o takim numerze(1) !"); return 1; }
			else if(fishid == 2 && Fishes[playerid][pWeight2] < 1) { SendClientMessage(playerid, COLOR_GREY, "   Nie posiadasz ryby o takim numerze(2) !"); return 1; }
			else if(fishid == 3 && Fishes[playerid][pWeight3] < 1) { SendClientMessage(playerid, COLOR_GREY, "   Nie posiadasz ryby o takim numerze(3) !"); return 1; }
			else if(fishid == 4 && Fishes[playerid][pWeight4] < 1) { SendClientMessage(playerid, COLOR_GREY, "   Nie posiadasz ryby o takim numerze(4) !"); return 1; }
			else if(fishid == 5 && Fishes[playerid][pWeight5] < 1) { SendClientMessage(playerid, COLOR_GREY, "   Nie posiadasz ryby o takim numerze(5) !"); return 1; }
			ClearFishID(playerid, fishid);
			Fishes[playerid][pLastFish] = 0;
   Fishes[playerid][pFishID] = 0;
   SendClientMessage(playerid, COLOR_GRAD2, "   Uwolni³eœ rybê !");
		}
		return 1;
	}
 if(strcmp(cmd,"/wyrzucrybe",true)==0)
 {
  if(IsPlayerConnected(playerid))
	 {
	  if(Fishes[playerid][pLastFish] > 0)
	  {
	   ClearFishID(playerid, Fishes[playerid][pLastFish]);
	   Fishes[playerid][pLastFish] = 0;
	   Fishes[playerid][pFishID] = 0;
	   SendClientMessage(playerid, COLOR_GRAD2, "   Wyrzuci³eœ wybran¹ rybê !");
	  }
	  else
	  {
	   SendClientMessage(playerid, COLOR_GREY, "   Nie z³apa³eœ ¿adnej ryby !");
	   return 1;
	  }
	 }
	 return 1;
 }
 if(strcmp(cmd,"/wyrzucryby",true)==0)
 {
  if(IsPlayerConnected(playerid))
	 {
	  if(Fishes[playerid][pWeight1] > 0 || Fishes[playerid][pWeight2] > 0 || Fishes[playerid][pWeight3] > 0 || Fishes[playerid][pWeight4] > 0 || Fishes[playerid][pWeight5] > 0)
	  {
	   ClearFishes(playerid);
    Fishes[playerid][pLastFish] = 0;
				Fishes[playerid][pFishID] = 0;
				SendClientMessage(playerid, COLOR_GRAD2, "   Wyrzuci³eœ wszystkie ryby !");
	        }
	        else
	        {
	            SendClientMessage(playerid, COLOR_GREY, "   Nie z³apa³eœ ¿adnej ryby !");
	            return 1;
	        }
	    }
	    return 1;
 	}
	if(strcmp(cmd, "/licencje", true) == 0)
 {
  if(IsPlayerConnected(playerid))
	 {
	  new text1[5];
	  new text2[5];
	  new text3[5];
	  new text4[5];
	  new text5[5];
	  new text6[5];
	
   if(PlayerInfo[playerid][pCarLic])    { text1 = "JEST"; } else { text1 = "Brak"; }
   if(PlayerInfo[playerid][pFlyLic])    { text4 = "JEST"; } else { text4 = "Brak"; }
			if(PlayerInfo[playerid][pBoatLic])   { text2 = "JEST"; } else { text2 = "Brak"; }
	  if(PlayerInfo[playerid][pFishLic])   { text3 = "JEST"; } else { text3 = "Brak"; }
	  if(PlayerInfo[playerid][pGunLic])    { text5 = "JEST"; } else { text5 = "Brak"; }
	  if(PlayerInfo[playerid][pBigFlyLic]) { text6 = "JEST"; } else { text6 = "Brak"; }
	
	  SendClientMessage(playerid, COLOR_WHITE, "|__________________ Licencje __________________|");
	  format(string, sizeof(string), "** Licencja na samochody: %s.", text1);
			SendClientMessage(playerid, COLOR_GREY, string);
			format(string, sizeof(string), "** Licencja na latanie: %s.", text4);
			SendClientMessage(playerid, COLOR_GREY, string);
			format(string, sizeof(string), "** Licencja na du¿e samoloty: %s.", text6);
			SendClientMessage(playerid, COLOR_GREY, string);
			format(string, sizeof(string), "** Licencja na ¿eglowanie: %s.", text2);
			SendClientMessage(playerid, COLOR_GREY, string);
			format(string, sizeof(string), "** Licencja na ³owienie: %s.", text3);
			SendClientMessage(playerid, COLOR_GREY, string);
			format(string, sizeof(string), "** Pozwolenie na broñ: %s.", text5);
			SendClientMessage(playerid, COLOR_GREY, string);
			SendClientMessage(playerid, COLOR_WHITE, "|______________________________________________|");
		}
	 return 1;
 }
	if(strcmp(cmd, "/pokazlicencje", true) == 0)
 {
  if(IsPlayerConnected(playerid))
	 {
	  tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /pokazlicencje [IdGracza/CzêœæNazwy]");
				return 1;
			}
			giveplayerid = ReturnUser(tmp);
			if(IsPlayerConnected(giveplayerid))
			{
				if(giveplayerid != INVALID_PLAYER_ID)
				{
				 if (ProxDetectorS(8.0, playerid, giveplayerid))
					{
			   if(giveplayerid == playerid) { SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz pokazaæ w³asnych licencji, od tego jest /licencje !"); return 1; }
					 GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
						GetPlayerNameEx(playerid, sendername, sizeof(sendername));
					
      new text1[5];
				  new text2[5];
				  new text3[5];
			   new text4[5];
				  new text5[5];
				  new text6[5];
				
						if(PlayerInfo[playerid][pCarLic])    { text1 = "JEST"; } else { text1 = "Brak"; }
      if(PlayerInfo[playerid][pFlyLic])    { text4 = "JEST"; } else { text4 = "Brak"; }
						if(PlayerInfo[playerid][pBoatLic])   { text2 = "JEST"; } else { text2 = "Brak"; }
      if(PlayerInfo[playerid][pFishLic])   { text3 = "JEST"; } else { text3 = "Brak"; }
      if(PlayerInfo[playerid][pGunLic])    { text5 = "JEST"; } else { text5 = "Brak"; }
      if(PlayerInfo[playerid][pBigFlyLic]) { text6 = "JEST"; } else { text6 = "Brak"; }
				
      format(string, sizeof(string), "|__________ Licencje %s __________|", sendername);
				  SendClientMessage(giveplayerid, COLOR_WHITE, string);
				  format(string, sizeof(string), "** Licencja na samochody: %s.", text1);
						SendClientMessage(giveplayerid, COLOR_GREY, string);
						format(string, sizeof(string), "** Licencja na latanie: %s.", text4);
						SendClientMessage(giveplayerid, COLOR_GREY, string);
						format(string, sizeof(string), "** Licencja na du¿e samoloty: %s.", text6);
						SendClientMessage(giveplayerid, COLOR_GREY, string);
						format(string, sizeof(string), "** Licencja na ¿eglowanie: %s.", text2);
						SendClientMessage(giveplayerid, COLOR_GREY, string);
						format(string, sizeof(string), "** Licencja na ³owienie: %s.", text3);
						SendClientMessage(giveplayerid, COLOR_GREY, string);
						format(string, sizeof(string), "** Licencja na bronie: %s.", text5);
						SendClientMessage(giveplayerid, COLOR_GREY, string);
						format(string, sizeof(string), "* %s pokaza³ Tobie swoje licencje.", sendername);
						SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "* Pokaza³eœ swoje licencje %s.", giveplayer);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
					}
					else
					{
					 SendClientMessage(playerid, COLOR_GREY, "   Nie ma takiego gracza w pobli¿u !");
					 return 1;
					}
				}
			}
	  else
	  {
	   SendClientMessage(playerid, COLOR_GREY, "   Gracz niedostêpny !");
	   return 1;
	  }
		}
	 return 1;
 }
	if(strcmp(cmd,"/get",true)==0 || strcmp(cmd,"/wez",true)==0)
 {
  if(IsPlayerConnected(playerid))
	 {
			new x_job[32];
			x_job = strtok(cmdtext, idx);

			if(!strlen(x_job)) {
 			SendClientMessage(playerid, COLOR_WHITE, "|_________________ Odbierz _______________|");
				SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /wez [komendy]");
	 		SendClientMessage(playerid, COLOR_GREY, "Dostêpne komendy: Narkotyki, Paliwo");
				SendClientMessage(playerid, COLOR_GREEN, "|_________________________________________|");
				return 1;
			}

	  if(strcmp(x_job,"narkotyki",true) == 0)
	  {
		  if(PlayerInfo[playerid][pDrugs] > 15)
		  {
		   format(string, sizeof(string), "  Aktualnie masz %d gramów ze sob¹, pozb¹dŸ siê ich !", PlayerInfo[playerid][pDrugs]);
			 	SendClientMessage(playerid, COLOR_GREY, string);
		   return 1;
		  }
		
//    new tel;
//			 new price;
			 new ammount;
			
    tmp = strtok(cmdtext, idx);
				if(!strlen(tmp))
				{
					SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /wez narkotyki [iloœæ]");
					return 1;
				}
				
				new level = PlayerInfo[playerid][pDrugsSkill];
				ammount = strval(tmp);
				if(level >= 0 && level <= 50)
				{ /*tel = 200;*/ if(ammount < 1 || ammount > 6) { SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz daæ wiêcej ni¿ 6 gram przy twoich umiejêtnoœciach !"); return 1; } }
				else if(level >= 51 && level <= 100)
				{ /*tel = 150;*/ if(ammount < 1 || ammount > 12) { SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz daæ wiêcej ni¿ 12 gramów przy twoich umiejêtnoœciach !"); return 1; } }
				else if(level >= 101 && level <= 200)
				{ /*tel = 100;*/ if(ammount < 1 || ammount > 20) { SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz daæ wiêcej ni¿ 20 gram przy twoich umiejêtnoœciach !"); return 1; } }
				else if(level >= 201 && level <= 400)
				{ /*tel = 50;*/ if(ammount < 1 || ammount > 30) { SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz daæ wiêcej ni¿ 30 gram przy twoich umiejêtnoœciach !"); return 1; } }
				else if(level >= 401)
				{ /*tel = 10;*/ if(ammount < 1 || ammount > 99) { SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz daæ wiêcej ni¿ 99 gram przy twoich umiejêtnoœciach !"); return 1; } }
			    if (PlayerInfo[playerid][pJob] == 4 && PlayerToPoint(2.0, playerid, 331.8978,1119.9894,1083.8903))
				{
				
				format(string, sizeof(string), "* Wzi¹³eœ %d gramów narkotyków.", ammount);
				SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
				//GivePlayerMoneyEx(playerid, -price);
				PlayerInfo[playerid][pDrugs] = ammount;
				}
				else
				{
				 SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ w magazynie lub nie jesteœ dillerem narkotyków !");
				 return 1;
				}
			}
			else { return 1; }
		}//not connected
		return 1;
	}
	if(strcmp(cmd, "/join", true) == 0 || strcmp(cmd, "/aplikuj", true) == 0)
	{
		if(PlayerInfo[playerid][pJob] == 0)
		{
		 for(new i = 0; i < sizeof(Jobs); i++)
		 {
		  if(Jobs[i][jActive] && PlayerToPoint(3.0, playerid,Jobs[i][jPosX], Jobs[i][jPosY], Jobs[i][jPosZ]))
		  {
		   new noffer[oOfferEnum];
		
		   noffer[ofId] = OFFER_ID_JOB;
		   noffer[ofType] = OFFER_TYPE_YESNO;
		   noffer[ofValue1] = Jobs[i][jId];
		   noffer[ofOfferer] = playerid;

 	   ServicePopUp(playerid, "Praca", noffer);
		  }
		 }
		}
		else
		{
		 SendClientMessage(playerid, COLOR_GREY, "   Aktualnie masz pracê, najpierw wpisz /opuscprace !");
		}
	
  return 1;
	}
	if(strcmp(cmd, "/fill", true) == 0 || strcmp(cmd, "/tankuj", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
 	 if(IsPlayerInAnyVehicle(playerid))
 	 {
			 if(IsAtGasStation(playerid))
			 {
			  new length = floatround((100-Vehicles[GetPlayerVehicleID(playerid)][vFuel])*100);
			  GameTextForPlayer(playerid,"~w~~n~~n~~n~~n~~n~~n~~n~~n~~n~Tankowanie pojazdu, prosze czekac",length > 0 ? length + 3000 : 2000,3);
			  TogglePlayerControllable(playerid, 0);
			 	SetTimerEx("Fillup", length > 0 ? length + 3000 : 2000, 0, "d", playerid);
			 }
			 else
			 {
			 	SendClientMessage(playerid,COLOR_GREY,"   Nie jesteœ na stacji benzynowej!");
			 }
		 }
		 else
		 {
		  SendClientMessage(playerid,COLOR_GREY,"   Musisz byæ w pojeŸdzie!");
		 }
		}
    	return 1;
	}
	
	if(strcmp(cmd, "/tazer", true) ==0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			/*if(IsACop(playerid) || ((PlayerInfo[playerid][pMember] == 11 || PlayerInfo[playerid][pLeader] == 1) 
				&& (PlayerInfo[playerid][pRank] == 3 || PlayerInfo[playerid][pRank] == 4 || PlayerInfo[playerid][pRank] == 5 || PlayerInfo[playerid][pRank] == 6 || PlayerInfo[playerid][pRank] == 7)))*/
				
			if	(GetPlayerOrganization(playerid)==1 ||
					(GetPlayerOrganization(playerid)==11 && PlayerInfo[playerid][pRank]>=4 && PlayerInfo[playerid][pRank] <=7) ||
					(GetPlayerOrganization(playerid)==7 && PlayerInfo[playerid][pRank]>=7 && PlayerInfo[playerid][pRank] <=10) ||
					GetPlayerOrganization(playerid)==2 ||
					GetPlayerOrganization(playerid)==17
					
					)
			{
			    if(IsPlayerInAnyVehicle(playerid))
			    {
			        SendClientMessage(playerid, COLOR_GREY, "   Jedziesz autem! Komenda zablokowana !");
			        return 1;
			    }
			    new suspect = GetClosestPlayer(playerid);
			    if(IsPlayerConnected(suspect))
				{
				    if(PlayerCuffed[suspect] > 0)
				    {
				        SendClientMessage(playerid, COLOR_GREY, "   Ta osoba jest ju¿ zakuta!");
				        return 1;
				    }
				    if(GetDistanceBetweenPlayers(playerid,suspect) < 5)
					{
					    if(GetPlayerOrganization(suspect) == 1)
					    {
					        SendClientMessage(playerid, COLOR_GREY, "   Nie mo¿esz atakowaæ innych cz³onków s³u¿b porz¹dkowych!");
					        return 1;
					    }
					    if(IsPlayerInAnyVehicle(suspect))
					    {
					        SendClientMessage(playerid, COLOR_GREY, "   Podejrzany jest w aucie, usuñ go z niego!");
					        return 1;
					    }
					    GetPlayerNameMask(suspect, giveplayer, sizeof(giveplayer));
						GetPlayerNameMask(playerid, sendername, sizeof(sendername));
						format(string, sizeof(string), "* Zosta³eœ sparali¿owany przez %s. Nie uciekaj!", sendername);
						SendClientMessage(suspect, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "* Sprali¿owa³eœ %s na 8 sekund .", giveplayer);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "* %s strzeli³ nabojem pora¿aj¹cym w %s, i sparali¿owa³ go.", sendername ,giveplayer);
						ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
						GameTextForPlayer(suspect, "~r~Sparalizowany", 2500, 3);
						TogglePlayerControllable(suspect, 0);
						PlayerCuffed[suspect] = 1;
						PlayerCuffedTime[suspect] = 8;
		            }
					else
					{
					    SendClientMessage(playerid, COLOR_GREY, "   Nie ma nikogo w pobli¿u!");
					    return 1;
					}
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ cz³onkiem s³u¿b porz¹dkowych.");
			}
		}//not connected
	    return 1;
	}
	if(strcmp(cmd, "/cuff", true) == 0 || strcmp(cmd, "/zakuj", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
			if(IsACop(playerid) || GetPlayerOrganization(playerid) == 13 || (GetPlayerOrganization(playerid) == 7 && PlayerInfo[playerid][pRank] >=7 && PlayerInfo[playerid][pRank] <=10))
			{
		  tmp = strtok(cmdtext, idx);
		 	if(!strlen(tmp)) {
					SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /zakuj [idGracza/CzêœæNazwy]");
					return 1;
				}
				giveplayerid = ReturnUser(tmp);
			 if(IsPlayerConnected(giveplayerid))
			 {
			  if(giveplayerid != INVALID_PLAYER_ID)
			  {
			   if(IsACop(giveplayerid))
				  {
				   SendClientMessage(playerid, COLOR_GREY, "   Nie mo¿esz zakuæ innych policjantów !");
				   return 1;
				  }
				  if(PlayerCuffed[giveplayerid] > 0)
				  {
				   SendClientMessage(playerid, COLOR_GREY, "Ten gracz jest ju¿ zakuty !");
				   return 1;
				  }
						if (ProxDetectorS(8.0, playerid, giveplayerid))
						{
					  new car = GetPlayerVehicleID(playerid);
					  if(giveplayerid == playerid) { SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz zakuæ samego siebie!"); return 1; }
					  if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == 2 && IsPlayerInVehicle(giveplayerid, car))
					  {
					   GetPlayerNameMask(giveplayerid, giveplayer, sizeof(giveplayer));
								GetPlayerNameMask(playerid, sendername, sizeof(sendername));
					   format(string, sizeof(string), "* Zosta³eœ zakuty przez %s.", sendername);
								SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
								format(string, sizeof(string), "* Zaku³eœ %s.", giveplayer);
								SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
								format(string, sizeof(string), "* %s zaku³ rêce %s.", sendername ,giveplayer);
								ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
								GameTextForPlayer(giveplayerid, "~r~Zakuty", 2500, 3);
								TogglePlayerControllable(giveplayerid, 0);
								PlayerCuffed[giveplayerid] = 2;
								PlayerCuffedTime[giveplayerid] = 300;
						 }
					  else
						 {
						  SendClientMessage(playerid, COLOR_GREY, "   Gracz nie jest w samochodzie, albo ty nie jesteœ kierowc¹ !");
						  return 1;
						 }
						}
						else
						{
						 SendClientMessage(playerid, COLOR_GREY, "   Gracz nie jest obok ciebie !");
						 return 1;
						}
					}
				}
				else
				{
				    SendClientMessage(playerid, COLOR_GREY, "   Gracz jest offline !");
				    return 1;
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ w s³u¿bach porz¹dkowych !");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/uncuff", true) == 0 || strcmp(cmd, "/rozkuj", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			if(GetPlayerOrganization(playerid) == 1 || GetPlayerOrganization(playerid) == 13)
			{
			    tmp = strtok(cmdtext, idx);
				if(!strlen(tmp)) {
					SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /rozkuj [idGracza/CzêœæNazwy]");
					return 1;
				}
				giveplayerid = ReturnUser(tmp);
				if(IsPlayerConnected(giveplayerid))
				{
					if(giveplayerid != INVALID_PLAYER_ID)
					{
		    if (ProxDetectorS(8.0, playerid, giveplayerid))
						{
			    if(giveplayerid == playerid) { SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz rozkuæ siebie samego !"); return 1; }
							if(PlayerCuffed[giveplayerid])
							{
				    GetPlayerNameMask(giveplayerid, giveplayer, sizeof(giveplayer));
								GetPlayerNameMask(playerid, sendername, sizeof(sendername));
				    format(string, sizeof(string), "* Zosta³eœ rozkuty przez %s.", sendername);
								SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
								format(string, sizeof(string), "* Rozku³eœ %s.", giveplayer);
								SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
								GameTextForPlayer(giveplayerid, "~g~Kajdanki zdjete", 2500, 3);
								TogglePlayerControllable(giveplayerid, 1);
								PlayerCuffed[giveplayerid] = 0;
							}
							else
							{
							    SendClientMessage(playerid, COLOR_GREY, "   Ten gracz nie jest zakuty !");
							    return 1;
							}
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GREY, "   Ten gracz nie jest obok ciebie !");
						    return 1;
						}
					}
				}
				else
				{
				    SendClientMessage(playerid, COLOR_GREY, "   Gracz jest aktualnie offline !");
				    return 1;
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ w s³u¿bach porz¹dkowych !");
			}
		}//not connected
		return 1;
	}
    if(strcmp(cmd, "/find", true) == 0 || strcmp(cmd, "/szukaj", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
		    if(PlayerInfo[playerid][pJob] != 1)
		    {
				SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ detektywem !");
				return 1;
		    }
			if(UsedFind[playerid] != 0 && PlayerInfo[playerid][pDetSkill] < 401)
			{
			    SendClientMessage(playerid, COLOR_GREY, "   Musisz odczekaæ 2 minuty od ostatniego szukania !");
			    return 1;
			}
		    tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /szukaj [IdGracza/CzêœæNazwy]");
				return 1;
			}
			giveplayerid = ReturnUser(tmp);
			if(IsPlayerConnected(giveplayerid))
			{
			    if(giveplayerid != INVALID_PLAYER_ID)
			    {
			        if(giveplayerid == playerid) { SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz szukaæ samego siebie!"); return 1; }
			        new points;
			        new level = PlayerInfo[playerid][pDetSkill];
					if(level >= 0 && level <= 50)
					{ points = 4; }
					else if(level >= 51 && level <= 100)
					{ points = 6; }
					else if(level >= 101 && level <= 200)
					{ points = 8; }
					else if(level >= 201 && level <= 400)
					{ points = 10; }
					else if(level >= 401)
					{ points = 12; }
				    GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
					new Float:X,Float:Y,Float:Z;
					GetPlayerPos(giveplayerid, X,Y,Z);
					SetPlayerCheckpoint(playerid, X,Y,Z, 6);
					FindTime[playerid] = 1;
					FindTimePoints[playerid] = points;
					PlayerInfo[playerid][pDetSkill] ++;
					UsedFind[playerid] = 1;
					if(PlayerInfo[playerid][pDetSkill] == 50)
					{ SendClientMessage(playerid, COLOR_YELLOW, "* Twój poziom umiejêtnoœci Detektywistycznych wzrós³, Wkrótce bêdziesz móg³ szukaæ cz³onków mafi."); }
					else if(PlayerInfo[playerid][pDetSkill] == 100)
					{ SendClientMessage(playerid, COLOR_YELLOW, "* Twój poziom umiejêtnoœci Detektywistycznych wzrós³, Wkrótce bêdziesz móg³ szukaæ bossów mafi."); }
					else if(PlayerInfo[playerid][pDetSkill] == 200)
					{ SendClientMessage(playerid, COLOR_YELLOW, "* Twój poziom umiejêtnoœci Detektywistycznych wzrós³, Mo¿esz teraz szukaæ cz³onków mafi."); }
					else if(PlayerInfo[playerid][pDetSkill] == 400)
					{ SendClientMessage(playerid, COLOR_YELLOW, "* Twój poziom umiejêtnoœci Detektywistycznych wzrós³, Mo¿esz teraz szukaæ bossów mafi."); }
				}
			}
			else
			{
			    SendClientMessage(playerid, COLOR_GREY, "   Nieprawid³owa Nazwa/ID !");
			}
		}
	    return 1;
	}
	if(strcmp(cmd, "/free", true) == 0 || strcmp(cmd, "/uwolnij", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
		    if(PlayerInfo[playerid][pJob] != 2)
		    {
		        SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ Prawnikiem !");
		        return 1;
		    }
		    if(PlayerInfo[playerid][pLawSkill] >= 401)
		    {
		        ApprovedLawyer[playerid] = 1;
		    }
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /uwolnij [IdGracza/CzêœæNazwy]");
				return 1;
			}
			giveplayerid = ReturnUser(tmp);

   if(IsPlayerConnected(giveplayerid))
   {
    if(giveplayerid != INVALID_PLAYER_ID)
    {
     if(giveplayerid == playerid) { SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz uwolniæ samego siebie !"); return 1; }
					if((PlayerInfo[giveplayerid][pJailed] == 1 || PlayerInfo[giveplayerid][pJailed] == 3) && ApprovedLawyer[playerid] == 1)
					{
						GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
						GetPlayerName(playerid, sendername, sizeof(sendername));
						format(string, sizeof(string), "* Uwolni³eœ %s z wiêzienia.", giveplayer);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "* Zosta³eœ wyci¹gniêty z wiêzienia, przez prawnika %s.", sendername);
						SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
						ApprovedLawyer[playerid] = 0;
						WantLawyer[giveplayerid] = 0;
						CallLawyer[giveplayerid] = 0;
						JailPrice[giveplayerid] = 0;
						PlayerInfo[giveplayerid][pJailTime] = 1;
						PlayerInfo[playerid][pLawSkill] ++;
						if(PlayerInfo[playerid][pLawSkill] == 50)
						{ SendClientMessage(playerid, COLOR_YELLOW, "* Twój poziom umiejêtnoœci Prawniczych wzrós³, Wkrótce bêdziesz zarabia³ wiêcej pieniêdzy."); }
						else if(PlayerInfo[playerid][pLawSkill] == 100)
						{ SendClientMessage(playerid, COLOR_YELLOW, "* Twój poziom umiejêtnoœci Prawniczych wzrós³, Wkrótce bêdziesz zarabia³ wiêcej pieniêdzy."); }
						else if(PlayerInfo[playerid][pLawSkill] == 200)
						{ SendClientMessage(playerid, COLOR_YELLOW, "* Twój poziom umiejêtnoœci Prawniczych wzrós³, Wkrótce bêdziesz zarabia³ wiêcej pieniêdzy."); }
						else if(PlayerInfo[playerid][pLawSkill] == 400)
						{ SendClientMessage(playerid, COLOR_YELLOW, "* Twój poziom umiejêtnoœci Prawniczych wzrós³, Wkrótce bêdziesz zarabia³ wiêcej pieniêdzy."); }
					}
					else
					{
						SendClientMessage(playerid, COLOR_GRAD1, "Ten gracz nie potrzebuje prawnika !");
					}
				}
			}
			else
			{
			    SendClientMessage(playerid, COLOR_GREY, "   Ta osoba jest niedostêpna !");
			}
		}//not connected
		return 1;
	}
	if(strcmp(cmd,"/cancel",true)==0 || strcmp(cmd,"/anuluj",true)==0)
    {
        if(IsPlayerConnected(playerid))
	    {
			new x_job[32];
			x_job = strtok(cmdtext, idx);
			if(!strlen(x_job)) {
				SendClientMessage(playerid, COLOR_WHITE, "|__________________ Anuluj __________________|");
				SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /anuluj [nazwa]");
				SendClientMessage(playerid, COLOR_GREY, "Mo¿liwe Nazwy: Narkotyki, Naprawa, Prawnik, Wywiad, Tankowanie, Boxing");
				SendClientMessage(playerid, COLOR_GREY, "Mo¿liwe Nazwy: Taxi, Medyk, Mechanik, Mandat");
				SendClientMessage(playerid, COLOR_WHITE, "|____________________________________________|");
				return 1;
			}
			if(strcmp(x_job,"narkotyki",true) == 0) { DrugOffer[playerid] = 999; DrugPrice[playerid] = 0; DrugGram[playerid] = 0; }
			else if(strcmp(x_job,"naprawa",true) == 0) { if(RepairOffer[playerid] < 999 && RepairingVehicle[RepairOffer[playerid]] > 0) return 1; RepairOffer[playerid] = 999; RepairPrice[playerid] = 0; RepairCar[playerid] = 0; }
			else if(strcmp(x_job,"prawnik",true) == 0) { WantLawyer[playerid] = 0; CallLawyer[playerid] = 0; }
			else if(strcmp(x_job,"wywiad",true) == 0) { LiveOffer[playerid] = 999; }
			else if(strcmp(x_job,"tankowanie",true) == 0) { RefillOffer[playerid] = 999; RefillPrice[playerid] = 0; }
			else if(strcmp(x_job,"boxing",true) == 0) { BoxOffer[playerid] = 999; }
			else if(strcmp(x_job,"mandat",true) == 0) { TicketOffer[playerid] = 999; TicketMoney[playerid] = 0; }
			else if(strcmp(x_job,"medyk",true) == 0) { if(IsPlayerConnected(MedicCall)) { if(MedicCall == playerid) { MedicCall = 999; } else { SendClientMessage(playerid, COLOR_GREY, "   You are not the current Caller !"); return 1; } } }
			else if(strcmp(x_job,"mechanik",true) == 0) { if(IsPlayerConnected(MechanicCall)) { if(MechanicCall == playerid) { MechanicCall = 999; } else { SendClientMessage(playerid, COLOR_GREY, "   You are not the current Caller !"); return 1; } } }
			else if(strcmp(x_job,"taxi",true) == 0)
			{
			    if(TaxiCall < 999)
			    {
			        if(TransportDuty[playerid] == 1 && TaxiCallTime[playerid] > 0)
			        {
			            TaxiAccepted[playerid] = 999;
						GameTextForPlayer(playerid, "~w~Anulowales~n~~r~zgloszenie", 5000, 1);
						TaxiCallTime[playerid] = 0;
						DisablePlayerCheckpoint(playerid);
						TaxiCall = 999;
			        }
			        else
			        {
						if(IsPlayerConnected(TaxiCall)) { if(TaxiCall == playerid) { TaxiCall = 999; } }
						for(new i = 0; i < MAX_PLAYERS; i++)
						{
						    if(IsPlayerConnected(i))
						    {
						        if(TaxiAccepted[i] < 999)
						        {
							        if(TaxiAccepted[i] == playerid)
							        {
							            TaxiAccepted[i] = 999;
							            GameTextForPlayer(i, "~w~Potrzebujacy taksowki~n~~r~anulowal zgloszenie", 5000, 1);
							            TaxiCallTime[i] = 0;
							            DisablePlayerCheckpoint(i);
							        }
						        }
						    }
						}
					}
				}
			}
			else { return 1; }
			format(string, sizeof(string), "* Anulowa³eœ: %s.", x_job);
			SendClientMessage(playerid, COLOR_YELLOW, string);
		}//not connected
		return 1;
	}
//ACCEPT COMMANDS (Cops)
if(strcmp(cmd, "/akceptuj", true) == 0 || strcmp(cmd, "/accept", true) == 0)
 {
  if(IsPlayerConnected(playerid))
	 {
			new x_job[32];
			x_job = strtok(cmdtext, idx);
			if(!strlen(x_job)) {
				SendClientMessage(playerid, COLOR_WHITE, "|__________________ Akceptuj __________________|");
				SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /akceptuj [nazwa]");
				SendClientMessage(playerid, COLOR_GREY, "Dostepne Nazwy: Przedmiot, Narkotyki, Naprawa, Prawnik, Wywiad, Tankowanie, Alkomat");
				SendClientMessage(playerid, COLOR_GREY, "Dostepne Nazwy: Taxi, Walka, Medyk, Mechanik, Mandat");
				SendClientMessage(playerid, COLOR_WHITE, "|____________________________________________|");
				return 1;
			}
			
			/*if(strcmp(x_job,"dom",true) == 0)
			{
			 if(giveHouseKeyOffer[playerid] == 999)
			 {
			  giveHouseKeyPrice[playerid] = 0;
			  giveHouseKeyOffer[playerid] = 999;
			
			  SendClientMessage(playerid, COLOR_GRAD1, "Nikt nie oferuje ci swojego domu.");
			  return 1;
			 }
			
			 if(!ProxDetectorS(5.0, playerid, giveHouseKeyOffer[playerid]))
				{
				 SendClientMessage(playerid, COLOR_GRAD1, "Nie ma w pobli¿u sprzedawcy.");
				 return 1;
				}
			
			 if(giveHouseKeyPrice[playerid] > GetPlayerMoneyEx(playerid))
			 {
			  giveHouseKeyPrice[playerid] = 0;
			  giveHouseKeyOffer[playerid] = 999;
			
			  SendClientMessage(playerid, COLOR_GRAD1, "Nie masz tylu pieniêdzy");
			  return 1;
			 }
			
			 new userid  = giveHouseKeyOffer[playerid];
			 new houseid = PlayerInfo[userid][pPhousekey];
					
			 GetPlayerName(playerid, playername, sizeof(playername));
	   GetPlayerName(userid, sendername, sizeof(sendername));
		  PlayerInfo[playerid][pPhousekey] = houseid;
		  HouseInfo[playerid][hOwned]      = 1;
		  HouseInfo[houseid][hOwner] = PlayerInfo[playerid][pId];

		  //SetPlayerInterior(playerid,HouseInfo[houseid][hInt]);
		  //SetPlayerVirtualWorldEx(playerid,HouseInfo[houseid][hVW]);
		  //SetPlayerPosEx(playerid,HouseInfo[houseid][hExitx],HouseInfo[houseid][hExity],HouseInfo[houseid][hExitz]);
		  //GameTextForPlayer(playerid,      "~w~Witaj w domu~n~Mozesz stad wyjsc podchodzac do drzwi i wpisujac /wyjdz", 5000, 3);
		  //PlayerInfo[playerid][pInt]       = HouseInfo[houseid][hInt];
		  //PlayerInfo[playerid][pLocal]     = houseid;
		  //SendClientMessage(playerid, COLOR_WHITE, "Gratulujemy udanego zakupu !");
		  //SendClientMessage(playerid, COLOR_WHITE, "Wpisz /pomoc aby zobaczyæ wszystkie dostêpne komendy !");
    DateProp(playerid);
    OnHouseUpdate(houseid);
  		OnPlayerSave(playerid);
  		
  		GivePlayerMoneyEx(playerid, -giveHouseKeyPrice[playerid]);
  		GivePlayerMoneyEx(giveHouseKeyOffer[playerid], giveHouseKeyPrice[playerid]);
  		
  		PlayerInfo[userid][pPhousekey] = 255;
  		
  		giveHouseKeyPrice[playerid] = 0;
		  giveHouseKeyOffer[playerid] = 999;
			}
			else*/

			if(strcmp(x_job,"alkomat",true) == 0)
			{
			 if(IsPlayerConnected(playerid) && IsPlayerConnected(alkomatAccept[playerid])){}
			 else
			 {
			  if(alkomatAccept[playerid] == 255){}
			  else
			  {
			   alkomatAccept[playerid] = 255;
			   SendClientMessage(playerid, COLOR_GREY, "   Nikt nie oferuje Ci dmuchania w balonik !");
					 return 1;
			  }
			 }
			 if(alkomatAccept[playerid] == 255)
			 {
			  SendClientMessage(playerid, COLOR_GREY, "   Nikt nie oferuje Ci dmuchania w balonik !");
					return 1;
			 }
			
			 GetPlayerName(playerid, sendername, sizeof(sendername));
    GetPlayerName(alkomatAccept[playerid], playername, sizeof(playername));
			
	   format(string, sizeof(string), "* %s dmucha w alkomat", sendername);	
 		 ProxDetector(10.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
	
  	 format(string, sizeof(string), "Iloœæ promili we krwi %s: %d", sendername, floatround(PlayerInfo[playerid][pDrunkTime]/100));
    SendClientMessage(alkomatAccept[playerid], COLOR_LIGHTBLUE, string);

    PlayerInfo[alkomatAccept[playerid]][pPayCheck] += 50;

    alkomatAccept[playerid] = 255;
			}
			else if(strcmp(x_job,"mandat",true) == 0)
			{
			 if(TicketOffer[playerid] < 999)
			 {
			  if(IsPlayerConnected(TicketOffer[playerid]))
			  {
			   if (ProxDetectorS(5.0, playerid, TicketOffer[playerid]))
						{
						 if(TicketOffer[playerid] > GetPlayerMoneyEx(playerid))
						 {
						  SendClientMessage(playerid, COLOR_GREY, "   Nie masz takiej iloœci pieniêdzy !");
						  SendClientMessage(TicketOffer[playerid], COLOR_GREY, "   Ta osoba nie ma tylu pieniêdzy !");
						  TicketOffer[playerid] = 999;
							 TicketMoney[playerid] = 0;
							 return 1;
						 }
						
				   GetPlayerNameMask(TicketOffer[playerid], giveplayer, sizeof(giveplayer));
							GetPlayerNameMask(playerid, sendername, sizeof(sendername));
							format(string, sizeof(string), "* Zap³aci³eœ mandat w wysokoœci $%d Oficerowi %s.", TicketMoney[playerid], giveplayer);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
							format(string, sizeof(string), "* %s zap³aci³ Ci mandat w wysokoœci $%d.", sendername, TicketMoney[playerid]);
							SendClientMessage(TicketOffer[playerid], COLOR_LIGHTBLUE, string);
							GivePlayerMoneyEx(playerid, - TicketMoney[playerid]);
							//GivePlayerMoneyEx(TicketOffer[playerid], TicketMoney[playerid]);
							Tax += TicketMoney[playerid];
							TicketOffer[playerid] = 999;
							TicketMoney[playerid] = 0;
							return 1;
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GREY, "   Nie ma Oficera w pobli¿u !");
						    return 1;
						}
			        }
				}
				else
				{
				    SendClientMessage(playerid, COLOR_GREY, "Nikt nie da³ tobie mandatu !");
				    return 1;
				}
			}
			else if(strcmp(x_job,"walka",true) == 0)
			{
			    if(BoxOffer[playerid] < 999)
			    {
			        if(IsPlayerConnected(BoxOffer[playerid]))
			        {
			            new points;
			            new mypoints;
			            GetPlayerName(BoxOffer[playerid], giveplayer, sizeof(giveplayer));
						GetPlayerName(playerid, sendername, sizeof(sendername));
			            new level = PlayerInfo[BoxOffer[playerid]][pBoxSkill];
						if(level >= 0 && level <= 50) { points = 40; }
						else if(level >= 51 && level <= 100) { points = 50; }
						else if(level >= 101 && level <= 200) { points = 60; }
						else if(level >= 201 && level <= 400) { points = 70; }
						else if(level >= 401) { points = 80; }
						if(PlayerInfo[playerid][pJob] == 12)
						{
							new clevel = PlayerInfo[playerid][pBoxSkill];
							if(clevel >= 0 && clevel <= 50) { mypoints = 40; }
							else if(clevel >= 51 && clevel <= 100) { mypoints = 50; }
							else if(clevel >= 101 && clevel <= 200) { mypoints = 60; }
							else if(clevel >= 201 && clevel <= 400) { mypoints = 70; }
							else if(clevel >= 401) { mypoints = 80; }
						}
						else
						{
						    mypoints = 30;
						}
						format(string, sizeof(string), "* Akceptowa³eœ walkê Boksersk¹ z %s, bêdziesz walczyæ z %d pkt. ¿ycia",giveplayer,mypoints);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "* %s zaakceptowa³ walkê Boksersk¹, bêdziesz walczyæ z %d pkt. ¿ycia.",sendername,points);
						SendClientMessage(BoxOffer[playerid], COLOR_LIGHTBLUE, string);
						SetPlayerHealthEx(playerid, mypoints);
						SetPlayerHealthEx(BoxOffer[playerid], points);
						SetPlayerInterior(playerid, 5); SetPlayerInterior(BoxOffer[playerid], 5);
						SetPlayerPosEx(playerid, 762.9852,2.4439,1001.5942); SetPlayerFacingAngle(playerid, 131.8632);
						SetPlayerPosEx(BoxOffer[playerid], 758.7064,-1.8038,1001.5942); SetPlayerFacingAngle(BoxOffer[playerid], 313.1165);
						TogglePlayerControllable(playerid, 0); TogglePlayerControllable(BoxOffer[playerid], 0);
						GameTextForPlayer(playerid, "~r~Oczekiwanie", 3000, 1); GameTextForPlayer(BoxOffer[playerid], "~r~Oczekiwanie", 3000, 1);
						new name[MAX_PLAYER_NAME];
						new name2[MAX_PLAYER_NAME];
						new give2[MAX_PLAYER_NAME];
						new dstring[MAX_PLAYER_NAME];
						new wstring[MAX_PLAYER_NAME];
						GetPlayerName(playerid, name, sizeof(name));
						GetPlayerNameEx(playerid, name2, sizeof(name2));
						GetPlayerNameEx(BoxOffer[playerid], give2, sizeof(give2));
						format(dstring, sizeof(dstring), "%s", name);
						strmid(wstring, dstring, 0, strlen(dstring), 255);
						if(strcmp(Titel[TitelName] ,wstring, true ) == 0 )
						{
		     format(string, sizeof(string), "LSNews Sport: Mistrz Bokserski %s bêdzie walczyæ z %s za 60 sekund (Si³ownia Groove StreetBoxing).",  name2, give2);
							OOCOff(COLOR_WHITE,string);
							TBoxer = playerid;
							BoxDelay = 60;
						}
						GetPlayerName(BoxOffer[playerid], name, sizeof(name));
						format(dstring, sizeof(dstring), "%s", name);
						strmid(wstring, dstring, 0, strlen(dstring), 255);
						if(strcmp(Titel[TitelName] ,wstring, true ) == 0 )
						{
						    format(string, sizeof(string), "LSNews Sport: Mistrz Bokserski %s bêdzie walczyæ z %s za 60 sekund (Si³ownia Groove StreetBoxing).",  name2, give2);
							OOCOff(COLOR_WHITE,string);
							TBoxer = BoxOffer[playerid];
							BoxDelay = 60;
						}
						BoxWaitTime[playerid] = 1; BoxWaitTime[BoxOffer[playerid]] = 1;
						if(BoxDelay < 1) { BoxDelay = 20; }
						InRing = 1;
						Boxer1 = BoxOffer[playerid];
						Boxer2 = playerid;
						PlayerBoxing[playerid] = 1;
						PlayerBoxing[BoxOffer[playerid]] = 1;
						BoxOffer[playerid] = 999;
						return 1;
			        }
			        return 1;
			    }
				else
				{
				    SendClientMessage(playerid, COLOR_GREY, "   Nikt nie zaoferowa³ Ci walki bokserskiej !");
				    return 1;
				}
			}
			else if(strcmp(x_job,"taxi",true) == 0)
			{
			    if(TransportDuty[playerid] != 1)
			    {
			        SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ taksówkarzem !");
				    return 1;
			    }
	            if(TaxiCallTime[playerid] > 0)
	            {
	                SendClientMessage(playerid, COLOR_GREY, "   Ju¿ zaakceptowa³eœ jedno wezwanie taxi !");
				    return 1;
	            }
	            if(TaxiCall < 999)
	            {
	                if(IsPlayerConnected(TaxiCall))
	                {
	                    GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	                	GetPlayerNameEx(TaxiCall, giveplayer, sizeof(giveplayer));
	                	format(string, sizeof(string), "* Akceptowa³eœ wezwanie taxówki %s, jedŸ do czerwonego markera.",giveplayer);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
                        format(string, sizeof(string), "* Taxówkarz %s akceptowa³ twoje zg³oszenie! Stój w tym miejscu.",sendername);
						SendClientMessage(TaxiCall, COLOR_LIGHTBLUE, string);
						GameTextForPlayer(playerid, "~r~Jedz do czerwonego markera", 5000, 1);
						TaxiCallTime[playerid] = 1;
						TaxiAccepted[playerid] = TaxiCall;
						TaxiCall = 999;
						return 1;
					}
	            }
	            else
	            {
	                SendClientMessage(playerid, COLOR_GREY, "   Nikt nie wzywa taxi w tym momencie !");
			    	return 1;
	            }
			}
			else if(strcmp(x_job,"medyk",true) == 0)
			{
			    if(PlayerInfo[playerid][pMember] == 4 || PlayerInfo[playerid][pLeader] == 4)
			    {
		            if(MedicCallTime[playerid] > 0)
		            {
		                SendClientMessage(playerid, COLOR_GREY, "   Ju¿ akceptowa³eœ jedno zg³oszenie !");
					    return 1;
		            }
		            if(MedicCall < 999)
		            {
		                if(IsPlayerConnected(MedicCall))
		                {
		                    GetPlayerNameEx(playerid, sendername, sizeof(sendername));
		                	GetPlayerNameEx(MedicCall, giveplayer, sizeof(giveplayer));
		                	format(string, sizeof(string), "* Akceptowa³eœ wezwanie %s, masz 30 sek na dotarcie do niego.",giveplayer);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, "* JedŸ do czerwonego markera.");
	                        format(string, sizeof(string), "* Medyk %s akceptowa³ twoje wezwanie, Stój w tym miejscu.",sendername);
							SendClientMessage(MedicCall, COLOR_LIGHTBLUE, string);
							new Float:X,Float:Y,Float:Z;
							GetPlayerPos(MedicCall, X, Y, Z);
							SetPlayerCheckpoint(playerid, X, Y, Z, 5);
							GameTextForPlayer(playerid, "~r~Jedz do czerwonego markera", 5000, 1);
							MedicCallTime[playerid] = 1;
							MedicCall = 999;
							return 1;
						}
		            }
		            else
		            {
		                SendClientMessage(playerid, COLOR_GREY, "   Nikt nie wzywa medyka !");
				    	return 1;
		            }
				}
				else
				{
				    SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ medykiem !");
				    return 1;
				}
			}
			else if(strcmp(x_job,"straz",true) == 0)
			{
			 if(PlayerInfo[playerid][pMember] == 18 || PlayerInfo[playerid][pLeader] == 18)
			 {
		   if(MedicCallTime[playerid] > 0)
		   {
		    SendClientMessage(playerid, COLOR_GREY, "   Ju¿ akceptowa³eœ jedno zg³oszenie !");
					 return 1;
		   }
		   if(MedicCall < 999)
		   {
		    if(IsPlayerConnected(MedicCall))
		    {
		     GetPlayerNameEx(playerid, sendername, sizeof(sendername));
		     GetPlayerNameEx(MedicCall, giveplayer, sizeof(giveplayer));
		     format(string, sizeof(string), "* Akceptowa³eœ wezwanie %s, masz 30 sek na dotarcie do niego.",giveplayer);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, "* JedŸ do czerwonego markera.");
	      format(string, sizeof(string), "* Stra¿ak %s akceptowa³ twoje wezwanie, stój w tym miejscu.",sendername);
							SendClientMessage(MedicCall, COLOR_LIGHTBLUE, string);
							new Float:X,Float:Y,Float:Z;
							GetPlayerPos(MedicCall, X, Y, Z);
							SetPlayerCheckpoint(playerid, X, Y, Z, 5);
							GameTextForPlayer(playerid, "~r~Jedz do czerwonego markera", 5000, 1);
							MedicCallTime[playerid] = 1;
							MedicCall = 999;
							return 1;
						}
		   }
		   else
		   {
		    SendClientMessage(playerid, COLOR_GREY, "   Nikt nie wzywa stra¿y po¿arnej!");
				  return 1;
		   }
				}
				else
				{
				 SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ stra¿akiem!");
				 return 1;
				}
			}
			else if(strcmp(x_job,"mechanik",true) == 0)
			{
			    if(PlayerInfo[playerid][pJob] != 7)
			    {
			        SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ mechanikiem !");
				    return 1;
			    }
	            if(MechanicCallTime[playerid] > 0)
	            {
	                SendClientMessage(playerid, COLOR_GREY, "   Akceptowa³eœ ju¿ jedno zg³oszenie !");
				    return 1;
	            }
	            if(MechanicCall < 999)
	            {
	                if(IsPlayerConnected(MechanicCall))
	                {
	                    GetPlayerName(playerid, sendername, sizeof(sendername));
	                	GetPlayerName(MechanicCall, giveplayer, sizeof(giveplayer));
	                	format(string, sizeof(string), "* Akceptowa³eœ wezwanie %s, masz 30 sek na dotarcie do niego.",giveplayer);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, "* JedŸ do czerwonego markera.");
                        format(string, sizeof(string), "* Mechanik %s akceptowa³ twoje wezwanie, Stój w tym miejscu.",sendername);
						SendClientMessage(MechanicCall, COLOR_LIGHTBLUE, string);
						new Float:X,Float:Y,Float:Z;
						GetPlayerPos(MechanicCall, X, Y, Z);
						SetPlayerCheckpoint(playerid, X, Y, Z, 5);
						GameTextForPlayer(playerid, "~r~Jedz do czerwonego markera", 5000, 1);
						MechanicCallTime[playerid] = 1;
						MechanicCall = 999;
						return 1;
					}
	            }
	            else
	            {
	                SendClientMessage(playerid, COLOR_GREY, "   Nikt nie wzywa mechanika !");
			    	return 1;
	            }
			}
			else if(strcmp(x_job,"tankowanie",true) == 0)
			{
			if(GetPlayerState(playerid) == 2)//*Musi byæ kierowc¹
			{
			 if(RefillOffer[playerid] < 999)
			 {
			  if(IsPlayerConnected(RefillOffer[playerid]))
			  {
			   if(GetPlayerMoneyEx(playerid) > RefillPrice[playerid])
			   {
			    GetPlayerNameEx(RefillOffer[playerid], giveplayer, sizeof(giveplayer));
							GetPlayerNameEx(playerid, sendername, sizeof(sendername));
			    new car = gLastCar[playerid];
			    new fuel;
			    PlayerInfo[RefillOffer[playerid]][pMechSkill] ++;
			    if(PlayerInfo[RefillOffer[playerid]][pMechSkill] == 50)
							{ SendClientMessage(RefillOffer[playerid], COLOR_YELLOW, "* Twoja umiejêtnoœæ Mechanika wzros³a do poziomu 2, mo¿esz teraz tankowaæ wiêcej benzyny."); }
							else if(PlayerInfo[RefillOffer[playerid]][pMechSkill] == 100)
							{ SendClientMessage(RefillOffer[playerid], COLOR_YELLOW, "* Twoja umiejêtnoœæ Mechanika wzros³a do poziomu 3, mo¿esz teraz tankowaæ wiêcej benzyny."); }
							else if(PlayerInfo[RefillOffer[playerid]][pMechSkill] == 200)
							{ SendClientMessage(RefillOffer[playerid], COLOR_YELLOW, "* Twoja umiejêtnoœæ Mechanika wzros³a do poziomu 4, mo¿esz teraz tankowaæ wiêcej benzyny."); }
							else if(PlayerInfo[RefillOffer[playerid]][pMechSkill] == 400)
							{ SendClientMessage(RefillOffer[playerid], COLOR_YELLOW, "* Twoja umiejêtnoœæ Mechanika wzros³a do poziomu 5, mo¿esz teraz tankowaæ wiêcej benzyny."); }
							new level = PlayerInfo[RefillOffer[playerid]][pMechSkill];
							if(level >= 0 && level <= 50)
							{ fuel = 15; }
							else if(level >= 51 && level <= 100)
							{ fuel = 40; }
							else if(level >= 101 && level <= 200)
							{ fuel = 60; }
							else if(level >= 201 && level <= 400)
							{ fuel = 80; }
							else if(level >= 401)
							{ fuel = 100; }
							
							
							new Float:fuel2 = 0;
							
							if(Vehicles[car][vFuel] + fuel > 100){ fuel2 = 100 - Vehicles[car][vFuel]; }
							else { fuel2 = fuel; }
							
			    format(string, sizeof(string), "* Paliwo zosta³o uzupe³nione o %.0f. Koszt $%d. Mechanik: %s.",fuel2,RefillPrice[playerid],giveplayer);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
							format(string, sizeof(string), "* Uzupe³ni³eœ bak samochodu %s o %.0f, zarabiaj¹c $%d (Pieni¹dze otrzymasz podczas wyp³aty).",sendername,fuel2,RefillPrice[playerid]);
							SendClientMessage(RefillOffer[playerid], COLOR_LIGHTBLUE, string);
							PlayerInfo[RefillOffer[playerid]][pPayCheck] += RefillPrice[playerid];
							GivePlayerMoneyEx(playerid, -RefillPrice[playerid]);

							if(Gas[car] + fuel > 100) { Gas[car] = 100; Vehicles[car][vFuel] = 100.0; }
							else { Vehicles[car][vFuel] += float(fuel); }
							
					  RefillOffer[playerid] = 999;
							RefillPrice[playerid] = 0;
							return 1;
			            }
						else
						{
						    SendClientMessage(playerid, COLOR_GREY, "   Nie masz tylu pieniêdzy !");
						    return 1;
						}
			        }
			        return 1;
			    }
				else
				{
				    SendClientMessage(playerid, COLOR_GREY, "   Nikt nie oferuje Ci tankowania !");
				    return 1;
				}
				}
				else
				{
				    SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ kierowc¹!");
				    return 1;
				}
			}
			else if(strcmp(x_job,"wywiad",true) == 0)
			{
			    if(LiveOffer[playerid] < 999)
			    {
			        if(IsPlayerConnected(LiveOffer[playerid]))
			        {
				        if (ProxDetectorS(5.0, playerid, LiveOffer[playerid]))
						{
							SendClientMessage(LiveOffer[playerid], COLOR_LIGHTBLUE, "* Wywiad Rozpoczêty (Aby zakonczyc wywiad wpisz ponownie: /wywiad).");
							TalkingLive[playerid] = LiveOffer[playerid];
							TalkingLive[LiveOffer[playerid]] = playerid;
							LiveOffer[playerid] = 999;
							return 1;
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GREY, "   Jesteœ za daleko !");
							return 1;
						}
					}
					return 1;
				}
				else
				{
				    SendClientMessage(playerid, COLOR_GREY, "   Nikt nie oferuje Ci wywiadu !");
				    return 1;
				}
			}
			else if(strcmp(x_job,"prawnik",true) == 0)
			{
			    tmp = strtok(cmdtext, idx);
				if(!strlen(tmp))
				{
					SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /akceptuj prawnik [IdGracza/CzêœæNazwy]");
					return 1;
				}
				giveplayerid = ReturnUser(tmp);
				if (GetPlayerOrganization(playerid) == 1)
				{
				    if(IsPlayerConnected(giveplayerid))
				    {
				        if(giveplayerid != INVALID_PLAYER_ID)
				        {
				            if(PlayerInfo[giveplayerid][pJob] == 2)
				            {
							    GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
								GetPlayerName(playerid, sendername, sizeof(sendername));
									format(string, sizeof(string), "* Pozwoli³eœ adwokatowi %s na uwolnienie wiêŸnia.", giveplayer);
								SendClientMessage(playerid, COLOR_LIGHTBLUE,string);
								format(string, sizeof(string), "* Oficer %s zgadza siê na uwolnienie wiêŸnia. (u¿yj /uwolnij)", sendername);
								SendClientMessage(giveplayerid, COLOR_LIGHTBLUE,string);
								ApprovedLawyer[giveplayerid] = 1;
							    return 1;
							}
						}
					}
					return 1;
				}
				else
				{
				    SendClientMessage(playerid, COLOR_GREY, "Nieprawid³owa akcja! (Nie jesteœ Policjantem / Osoba nie jest prawnikiem / Z³e ID)");
				    return 1;
				}
			}
			else if(strcmp(x_job,"narkotyki",true) == 0)
			{
			    if(DrugOffer[playerid] < 999)
			    {
			        if(GetPlayerMoneyEx(playerid) > DrugPrice[playerid])
				    {
				        if(PlayerInfo[playerid][pDrugs] < 7)
				        {
					        if(IsPlayerConnected(DrugOffer[playerid]))
					        {
					            GetPlayerName(DrugOffer[playerid], giveplayer, sizeof(giveplayer));
								GetPlayerName(playerid, sendername, sizeof(sendername));
								format(string, sizeof(string), "* Kupi³eœ %d gram za $%d od Dillera narkotyków %s.",DrugGram[playerid],DrugPrice[playerid],giveplayer);
								SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
								format(string, sizeof(string), "* %s kupi³ %d gram Twoich narkotyków, $%d zosta³o dodane do Twojej wyp³aty.",sendername,DrugGram[playerid],DrugPrice[playerid]);
								SendClientMessage(DrugOffer[playerid], COLOR_LIGHTBLUE, string);
								PlayerInfo[DrugOffer[playerid]][pPayCheck] += DrugPrice[playerid];
								PlayerInfo[DrugOffer[playerid]][pDrugsSkill] ++;
								GivePlayerMoneyEx(playerid, -DrugPrice[playerid]);
								PlayerInfo[playerid][pDrugs] += DrugGram[playerid];
								PlayerInfo[DrugOffer[playerid]][pDrugs] -= DrugGram[playerid];
								if(PlayerInfo[DrugOffer[playerid]][pDrugsSkill] == 50)
								{ SendClientMessage(DrugOffer[playerid], COLOR_YELLOW, "* Twój poziom umiejêtnoœci Dillera narkotyków to 2, mo¿esz kupowaæ wiêcej Gram i Taniej."); }
								else if(PlayerInfo[DrugOffer[playerid]][pDrugsSkill] == 100)
								{ SendClientMessage(DrugOffer[playerid], COLOR_YELLOW, "* Twój poziom umiejêtnoœci Dillera narkotyków to 3, mo¿esz kupowaæ wiêcej Gram i Taniej."); }
								else if(PlayerInfo[DrugOffer[playerid]][pDrugsSkill] == 200)
								{ SendClientMessage(DrugOffer[playerid], COLOR_YELLOW, "* Twój poziom umiejêtnoœci Dillera narkotyków to 4, mo¿esz kupowaæ wiêcej Gram i Taniej."); }
								else if(PlayerInfo[DrugOffer[playerid]][pDrugsSkill] == 400)
								{ SendClientMessage(DrugOffer[playerid], COLOR_YELLOW, "* Twój poziom umiejêtnoœci Dillera narkotyków to 5, mo¿esz kupowaæ wiêcej Gram i Taniej."); }
					            DrugOffer[playerid] = 999;
								DrugPrice[playerid] = 0;
								DrugGram[playerid] = 0;
								return 1;
							}
							return 1;
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GREY, "   Nie mo¿esz mieæ wiêcej narkotyków przy sobie, u¿yj ich najpierw !");
						    return 1;
						}
					}
					else
					{
					    SendClientMessage(playerid, COLOR_GREY, "   Nie masz tylu pieniêdzy !");
					    return 1;
					}
			    }
			    else
			    {
			        SendClientMessage(playerid, COLOR_GREY, "   Nikt nie oferowa³ Ci narkotyków !");
			        return 1;
			    }
			}
			else if(strcmp(x_job,"naprawa",true) == 0)
			{
			if(GetPlayerState(playerid) == 2)//*Musi byæ kierowc¹
			{
			 		if(RepairOffer[playerid] < 999)
					 {
			  			if(GetPlayerMoneyEx(playerid) > RepairPriceOffer[playerid])
				 		{
					  		if(IsPlayerConnected(RepairOffer[playerid]))
 				      		{
 				   				if(IsRepairing[playerid] > 0)
 				   				{
 				    					SendClientMessage(playerid, COLOR_GRAD1, "Aktualnie trwa naprawa twojego pojazdu.");
 				    					return 1;
 				   				}
 				
 				                GetPlayerNameEx(RepairOffer[playerid], giveplayer, sizeof(giveplayer));
								GetPlayerNameEx(playerid, sendername, sizeof(sendername));
								
								format(string, sizeof(string), "* Mechanik Samochodowy %s rozpoczyna naprawê Twojego pojazdu za $%d.",giveplayer,RepairPrice[playerid]);
								SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
								format(string, sizeof(string), "* Rozpocz¹³eœ naprawê pojazdu %s za $%d.",sendername,RepairPriceOffer[playerid]);
								SendClientMessage(RepairOffer[playerid], COLOR_LIGHTBLUE, string);
 				
								TogglePlayerControllable(playerid, 0);
 				
					   			IsRepairing[playerid] = 1;
					
 								// wg skilla
					  			 new level = PlayerInfo[playerid][pMechSkill];
    				  			 if(level >= 0 && level <= 50)         { RepairingVehicle[RepairOffer[playerid]] = 180; }
			   	      			 else if(level >= 51 && level <= 100)  { RepairingVehicle[RepairOffer[playerid]] = 150; }
				      			 else if(level >= 101 && level <= 200) { RepairingVehicle[RepairOffer[playerid]] = 120; }
				      			 else if(level >= 201 && level <= 400) { RepairingVehicle[RepairOffer[playerid]] = 90; }
				      			 else if(level >= 401)                 { RepairingVehicle[RepairOffer[playerid]] = 60; }

								 RepairingVehicleOwner[RepairOffer[playerid]] = playerid;
						
  								 RepairPrice[playerid] = RepairPriceOffer[playerid];
					   			 RepairOffer[playerid] = 999;
							return 1;
							}
						return 1;
                       }
                    }
                    else
			 		{
			 			 SendClientMessage(playerid, COLOR_GREY, "   Nikt nie oferowa³ Tobie naprawy !");
			  			return 1;
			 		}
	                }
			 		else
			 		{
			 			 SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ kierowc¹.");
			  			return 1;
			 		}
		}//not connected
		}
		return 1;
	}

	if(strcmp(cmd, "/refill", true) == 0 || strcmp(cmd, "/tankowanie", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
		    if(PlayerInfo[playerid][pJob] != 7)
		    {
		        SendClientMessage(playerid, COLOR_GREY, "   Nie jestes mechanikiem!");
		        return 1;
		    }
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "UZYJ: /tankowanie [IdGracza/CzêœæNazwy] [cena]");
				return 1;
			}
			new playa;
			new money;
			playa = ReturnUser(tmp);
			tmp = strtok(cmdtext, idx);
			money = strval(tmp);
			if(money < 1 || money > 99999) { SendClientMessage(playerid, COLOR_GREY, "   Cena nie mo¿e byæ ni¿sza od 1 i wy¿sza od 99999!"); return 1; }
			if(IsPlayerConnected(playa))
			{
			 if(playa != INVALID_PLAYER_ID)
	   {
     if(ProxDetectorS(8.0, playerid, playa)&& IsPlayerInAnyVehicle(playa))
					{
					 if(playa == playerid) { SendClientMessage(playerid, COLOR_GREY, "   Nie mo¿esz zrobiæ tego!"); return 1; }
					 GetPlayerNameEx(playa, giveplayer, sizeof(giveplayer));
						GetPlayerNameEx(playerid, sendername, sizeof(sendername));
					 format(string, sizeof(string), "* Zaoferowa³eœ %s zatankowanie wozu $%d .",giveplayer,money);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "* Mechanik %s oferuje Tobie tankowanie za $%d, (wpisz /akceptuj tankowanie aby zaakceptowac).",sendername,money);
						SendClientMessage(playa, COLOR_LIGHTBLUE, string);
						RefillOffer[playa] = playerid;
						RefillPrice[playa] = money;
					}
					else
					{
					    SendClientMessage(playerid, COLOR_GREY, "   Nie ma takiego gracza w pobli¿u / samochodzie.");
					}
				}
			}
			else
			{
			    SendClientMessage(playerid, COLOR_GREY, "   Ten gracz jest poza gr¹.");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/napraw", true) == 0)
	{
      if(IsPlayerConnected(playerid))
	  {
	    	if(IsPlayerInAnyVehicle(playerid))//*Nie mo¿e byæ w pojeŸdzie
	    	{
        	  SendClientMessage(playerid, COLOR_GREY, "   Nie mo¿esz znajdowaæ siê w pojeŸdzie!");
	   	    }
	    	else
	    	{
		  		 if(PlayerInfo[playerid][pJob] != 7)
		  		 {
		  		  	SendClientMessage(playerid, COLOR_GREY, "   Nie jestes mechanikiem!");
		  		  	return 1;
		  		 }
				 tmp = strtok(cmdtext, idx);
					if(!strlen(tmp))
					{
						SendClientMessage(playerid, COLOR_GRAD2, "UZYJ: /napraw [IdGracza/CzêœæNazwy] [cena]");
						return 1;
					}
						new playa;
						new money;
						playa = ReturnUser(tmp);
						tmp = strtok(cmdtext, idx);
						money = strval(tmp);
						if(money < 20 || money > 500)
						{
						 	SendClientMessage(playerid, COLOR_GREY, "   Cena nie mo¿e byæ ni¿sza 20 i wy¿sza ni¿ 500!");
							return 1;
						}
						if(RepairingVehicle[playerid] > 0)
						{
			 				SendClientMessage(playerid, COLOR_GREY, "   Aktualnie naprawiasz inny pojazd!");
		  					return 1;
						}
					if(IsPlayerConnected(playa))
					{
						 if(playa != INVALID_PLAYER_ID)
		 				 {
			      			if(ProxDetectorS(8.0, playerid, playa)&& IsPlayerInAnyVehicle(playa))
			      			{
	                		   		if(playa == playerid)
			      			   		{
				        			 	SendClientMessage(playerid, COLOR_GREY, "   Nie mo¿esz tego zrobiæ!");
					 					return 1;
			           		   		}
				 	    			GetPlayerNameEx(playa, giveplayer, sizeof(giveplayer));
									GetPlayerNameEx(playerid, sendername, sizeof(sendername));
				        			format(string, sizeof(string), "* Zaoferowa³eœ %s naprawê auta za $%d .",giveplayer,money);
									SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
									format(string, sizeof(string), "* Mechanik %s chce naprawiæ Twoje auto za $%d, (wpisz /akceptuj naprawa aby zaakceptowac).",sendername,money);
									SendClientMessage(playa, COLOR_LIGHTBLUE, string);
									RepairOffer[playa] = playerid;
									RepairPriceOffer[playa] = money;
				   			}
				   			else
				   			{
					 				SendClientMessage(playerid, COLOR_GREY, "  Nie ma takiego gracza w pobli¿u/samochodzie.");
                   			}
						}
					else
					{
			    		SendClientMessage(playerid, COLOR_GREY, "   Gracz nie jest w grze.");
					}
	    	}
	  }
    }
   return 1;
   }
	if(strcmp(cmd, "/news", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			if(PlayerInfo[playerid][pMember] == 9 || PlayerInfo[playerid][pLeader] == 9)
			{
			    new newcar = GetPlayerVehicleID(playerid);
		        if(PlayerInfo[playerid][pMuted] >= 1)
				{
					SendClientMessage(playerid, TEAM_CYAN_COLOR, "Nie mo¿esz siê odzywaæ poniewasz jesteœ wyciszony!");
					return 1;
				}
				if(Vehicles[newcar][vType] == VEHICLE_TYPE_NEWS || PlayerToPoint(7.0, playerid, 1534.5313,-1339.2731,16.6182)  || PlayerToPoint(7.0, playerid,1532.4188,-1335.4871,16.6109))
				{
					GetPlayerName(playerid, sendername, sizeof(sendername));
					new length = strlen(cmdtext);
					while ((idx < length) && (cmdtext[idx] <= ' '))
					{
						idx++;
					}
					new offset = idx;
					new result[128];
					while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
					{
						result[idx - offset] = cmdtext[idx];
						idx++;
					}
					result[idx - offset] = EOS;
					if(!strlen(result))
					{
						SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /news [tekst]");
						return 1;
					}
     //////////////////////
         TextDrawHideForAll(SanNews);
		 ConvertSpecialCharacters(result);
		 EscapePL(string);
         format(string, sizeof(string), "~>~ ~p~%s ~r~(news)~w~: ~w~%s", sendername, result);
         ShowNews(string);
     /////////////////////
					PlayerInfo[playerid][pNewsSkill] ++;
					if(PlayerInfo[playerid][pNewsSkill] == 50)
					{ SendClientMessage(playerid, COLOR_YELLOW, "* Awansowa³eœ na 2 level skillu reportera, nied³ugo bêdziesz móg³ lataæ helikopterem albo przeprowadzaæ wywiady."); }
					else if(PlayerInfo[playerid][pNewsSkill] == 100)
					{ SendClientMessage(playerid, COLOR_YELLOW, "* Awansowa³eœ na 3 level skillu reportera, nied³ugo bêdziesz móg³ lataæ helikopterem albo przeprowadzaæ wywiady."); }
					else if(PlayerInfo[playerid][pNewsSkill] == 200)
					{ SendClientMessage(playerid, COLOR_YELLOW, "* Awansowa³eœ na 4 level skillu reportera, mo¿esz lataæ helikopterem LSNu."); }
					else if(PlayerInfo[playerid][pNewsSkill] == 400)
					{ SendClientMessage(playerid, COLOR_YELLOW, "* Awansowa³eœ na 5 level skillu reportera, mo¿esz przeprowadzaæ wywiady z ludŸmi."); }
				}
				else
				{
				    SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ w wozie reporterskim, helikopterze lub studiu !");
				    return 1;
				}
			}
			else
			{
			    SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ reporterem !");
			}
		}//not connected
		return 1;
	}
		if(strcmp(cmd, "/lsnpomoc", true) == 0)
		{
			    SendClientMessage(playerid, COLOR_RED, "Komendy Reportera:");
			    SendClientMessage(playerid, COLOR_RED, "/news - Pisanie Newsa");
			    SendClientMessage(playerid, COLOR_RED, "/liven - Pisanie na ¿ywo");
			    SendClientMessage(playerid, COLOR_RED, "/reklama - Nadawanie Og³oszenia lub Reklamy");
			    SendClientMessage(playerid, COLOR_RED, "/wywiad - Wywiad z kimœ");
			        return 1;
				}
		if(strcmp(cmd, "/reklama", true) == 0)
	    {
	    if(IsPlayerConnected(playerid))
	    {
			if(PlayerInfo[playerid][pMember] == 9 || PlayerInfo[playerid][pLeader] == 9)
			{
			    new newcar = GetPlayerVehicleID(playerid);
		        if(PlayerInfo[playerid][pMuted] >= 1)
				{
					SendClientMessage(playerid, TEAM_CYAN_COLOR, "Nie mo¿esz siê odzywaæ poniewasz jesteœ wyciszony!");
					return 1;
				}
			if(Vehicles[newcar][vType] == VEHICLE_TYPE_NEWS || PlayerToPoint(7.0, playerid, 1534.5313,-1339.2731,16.6182) || PlayerToPoint(7.0, playerid,1532.4188,-1335.4871,16.6109))
				{
					GetPlayerName(playerid, sendername, sizeof(sendername));
					new length = strlen(cmdtext);
					while ((idx < length) && (cmdtext[idx] <= ' '))
					{
						idx++;
					}
					new offset = idx;
					new result[128];
					while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
					{
						result[idx - offset] = cmdtext[idx];
						idx++;
					}
					result[idx - offset] = EOS;
					if(!strlen(result))
					{
						SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /reklama [tekst]");
						return 1;
					}
					/////////////////////
					ConvertSpecialCharacters(result);
					EscapePL(string);
					format(string, sizeof(string), "~>~~r~(reklama)~w~: ~w~%s", result);
					ShowNews(string);
     //////////////////
                    print(result);
					PlayerInfo[playerid][pNewsSkill] ++;
					if(PlayerInfo[playerid][pNewsSkill] == 50)
					{ SendClientMessage(playerid, COLOR_YELLOW, "* Awansowa³eœ na 2 level skillu reportera, nied³ugo bêdziesz móg³ lataæ helikopterem albo przeprowadzaæ wywiady."); }
					else if(PlayerInfo[playerid][pNewsSkill] == 100)
					{ SendClientMessage(playerid, COLOR_YELLOW, "* Awansowa³eœ na 3 level skillu reportera, nied³ugo bêdziesz móg³ lataæ helikopterem albo przeprowadzaæ wywiady."); }
					else if(PlayerInfo[playerid][pNewsSkill] == 200)
					{ SendClientMessage(playerid, COLOR_YELLOW, "* Awansowa³eœ na 4 level skillu reportera, mo¿esz lataæ helikopterem LSNu."); }
					else if(PlayerInfo[playerid][pNewsSkill] == 400)
					{ SendClientMessage(playerid, COLOR_YELLOW, "* Awansowa³eœ na 5 level skillu reportera, mo¿esz przeprowadzaæ wywiady z ludŸmi."); }
				}
				else
				{
				    SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ w wozie reporterskim, helikopterze lub studiu !");
				    return 1;
				}
			}
			else
			{
			    SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ reporterem !");
			}
		}//not connected
		return 1;
	}
	
	if(strcmp(cmd, "/liven", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			if(PlayerInfo[playerid][pMember] == 9 || PlayerInfo[playerid][pLeader] == 9)
			{
			    new newcar = GetPlayerVehicleID(playerid);
		        if(PlayerInfo[playerid][pMuted] >= 1)
				{
					SendClientMessage(playerid, TEAM_CYAN_COLOR, "Nie mo¿esz siê odzywaæ poniewasz jesteœ wyciszony!");
					return 1;
				}
			if(Vehicles[newcar][vType] == VEHICLE_TYPE_NEWS || PlayerToPoint(7.0, playerid, 1534.5313,-1339.2731,16.6182)  || PlayerToPoint(7.0, playerid,1532.4188,-1335.4871,16.6109))
				{
					GetPlayerName(playerid, sendername, sizeof(sendername));
					new length = strlen(cmdtext);
					while ((idx < length) && (cmdtext[idx] <= ' '))
					{
						idx++;
					}
					new offset = idx;
					new result[128];
					while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
					{
						result[idx - offset] = cmdtext[idx];
						idx++;
					}
					result[idx - offset] = EOS;
					if(!strlen(result))
					{
						SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /liven [tekst]");
						return 1;
					}
					////////////////////////////
					ConvertSpecialCharacters(result);
					EscapePL(string);
                    format(string, sizeof(string), "~>~ ~p~%s ~r~(live)~w~: ~w~%s", sendername, result);
                    ShowNews(string);
     ////////////////////////////
					PlayerInfo[playerid][pNewsSkill] ++;
					if(PlayerInfo[playerid][pNewsSkill] == 50)
					{ SendClientMessage(playerid, COLOR_YELLOW, "* Awansowa³eœ na 2 level skillu reportera, nied³ugo bêdziesz móg³ lataæ helikopterem albo przeprowadzaæ wywiady."); }
					else if(PlayerInfo[playerid][pNewsSkill] == 100)
					{ SendClientMessage(playerid, COLOR_YELLOW, "* Awansowa³eœ na 3 level skillu reportera, nied³ugo bêdziesz móg³ lataæ helikopterem albo przeprowadzaæ wywiady."); }
					else if(PlayerInfo[playerid][pNewsSkill] == 200)
					{ SendClientMessage(playerid, COLOR_YELLOW, "* Awansowa³eœ na 4 level skillu reportera, mo¿esz lataæ helikopterem LSNu."); }
					else if(PlayerInfo[playerid][pNewsSkill] == 400)
					{ SendClientMessage(playerid, COLOR_YELLOW, "* Awansowa³eœ na 5 level skillu reportera, mo¿esz przeprowadzaæ wywiady z ludŸmi."); }
				}
				else
				{
				    SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ w wozie reporterskim, helikopterze lub studiu !");
				    return 1;
				}
			}
			else
			{
			    SendClientMessage(playerid, COLOR_GREY, "   Nie jesteœ reporterem !");
			}
		}//not connected
		return 1;
	}
	
	if(strcmp(cmd, "/gov", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			if(PlayerInfo[playerid][pLeader] == 7)
			{
		        if(PlayerInfo[playerid][pMuted] >= 1)
				{
					SendClientMessage(playerid, TEAM_CYAN_COLOR, "Nie mo¿esz siê odzywaæ poniewasz jesteœ wyciszony!");
					return 1;
				}
					GetPlayerName(playerid, sendername, sizeof(sendername));
					new length = strlen(cmdtext);
					while ((idx < length) && (cmdtext[idx] <= ' '))
					{
						idx++;
					}
					new offset = idx;
					new result[128];
					while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
					{
						result[idx - offset] = cmdtext[idx];
						idx++;
					}
					result[idx - offset] = EOS;
					if(!strlen(result))
					{
						SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: (/gov)ernment [Tekst]");
						return 1;
					}
     			//////////////////////
       			 TextDrawHideForAll(SanNews);
				 ConvertSpecialCharacters(result);
				 EscapePL(string);
       			 format(string, sizeof(string), "~>~ ~w~%s ~b~(Wiadomosc Rzadowa)~w~: ~w~%s", sendername, result);
       			  //format(string, sizeof(string), "~w~%s ~b~(Wiadomosc Rzadowa): ~n~%s", sendername, result);
       			 ShowNews(string);
     /////////////////////
			}
			else
			{
			    SendClientMessage(playerid, COLOR_GREY, "Nie masz do tego uprawnieñ!");
			}
		}//not connected
		return 1;
	}
	if(strcmp(cmd, "/wywiad", true) == 0 || strcmp(cmd, "/live", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
			if(PlayerInfo[playerid][pMember] == 9 || PlayerInfo[playerid][pLeader] == 9)
			{
			    if(TalkingLive[playerid] != 255)
			    {
			        SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Audycja na ¿ywo zakoñczona.");
			        SendClientMessage(TalkingLive[playerid], COLOR_LIGHTBLUE, "* Audycja na ¿ywo zakoñczona.");
		            TalkingLive[TalkingLive[playerid]] = 255;
			        TalkingLive[playerid] = 255;
			        return 1;
			    }
			    
				tmp = strtok(cmdtext, idx);
				if(!strlen(tmp))
				{
					SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /wywiad [IdGracza/CzêœæNazwy]");
					return 1;
				}
				//giveplayerid = strval(tmp);
		        giveplayerid = ReturnUser(tmp);
				if (IsPlayerConnected(giveplayerid))
				{
				    if(giveplayerid != INVALID_PLAYER_ID)
				    {
						if (ProxDetectorS(5.0, playerid, giveplayerid))
						{
						    if(giveplayerid == playerid) { SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz przeprowadzaæ wywiadu z samym sob¹!"); return 1; }
						    GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
							GetPlayerName(playerid, sendername, sizeof(sendername));
							format(string, sizeof(string), "* Zaproponowales %s wywiad na zywo.", giveplayer);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
							format(string, sizeof(string), "* %s zapronowal tobie wywiad na zywo, wpisz (/akceptuj wywiad) aby akceptowaæ.", sendername);
							SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
							LiveOffer[giveplayerid] = playerid;
						}
						else
						{
						    SendClientMessage(playerid, COLOR_GREY, "   Jestes zbyt daleko od danego gracza !");
						    return 1;
						}
					}
				}
				else
				{
				    SendClientMessage(playerid, COLOR_GREY, "   Zle id, nazwa !");
				    return 1;
				}
			}
			else
			{
			    SendClientMessage(playerid, COLOR_GREY, "   Nie jestes reporterem !");
			}
		}//not connected
		return 1;
	}
	if(strcmp(cmd, "/selldrugs", true) == 0 || strcmp(cmd, "/sprzedajdragi", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	    {
		    if(PlayerInfo[playerid][pJob] != 4)
		    {
				SendClientMessage(playerid, COLOR_GREY, "   Nie jestes dilerem !");
				return 1;
		    }
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "UZYJ: /sprzedajdragi [IdGracza/CzêœæNazwy] [iloœæ] [cena]");
				return 1;
			}
			new playa;
			new money;
			new needed;
			playa = ReturnUser(tmp);
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp)) { return 1; }
			needed = strval(tmp);
			if(needed < 1 || needed > 99) { SendClientMessage(playerid, COLOR_GREY, "   Nie mo¿esz sprzedaæ mniej ni¿ 1 i wiêcej ni¿ 99 gram narkotyków!"); return 1; }
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp)) { return 1; }
			money = strval(tmp);
			if(money < 1 || money > 99999) { SendClientMessage(playerid, COLOR_GREY, "   Cena nie mo¿e byæ ni¿sza od 1 i wiêksza od 99999!"); return 1; }
			if(needed > PlayerInfo[playerid][pDrugs]) { SendClientMessage(playerid, COLOR_GREY, "   Nie masz takiej iloœci narkotyków przy sobie !"); return 1; }
			if(IsPlayerConnected(playa))
			{
			    if(playa != INVALID_PLAYER_ID)
			    {
					if (ProxDetectorS(8.0, playerid, playa))
					{
					    if(playa == playerid)
					    {
					        SendClientMessage(playerid, COLOR_GREY, "   Nie mo¿esz sprzedaæ samemu sobie!");
					        return 1;
					    }
					    GetPlayerName(playa, giveplayer, sizeof(giveplayer));
						GetPlayerName(playerid, sendername, sizeof(sendername));
					    format(string, sizeof(string), "* Zaoferowa³eœ %s sprzeda¿ %d gram narkotyków za $%d .", giveplayer, needed, money);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "* Diller narkotyków %s chce sprzedaæ Tobie %d gram za $%d, (wpisz /akceptuj narkotyki aby kupiæ).", sendername, needed, money);
						SendClientMessage(playa, COLOR_LIGHTBLUE, string);
						DrugOffer[playa] = playerid;
						DrugPrice[playa] = money;
						DrugGram[playa] = needed;
					}
					else
					{
					    SendClientMessage(playerid, COLOR_GREY, "   Nie ma takiego gracza w pobli¿u !");
					}
				}
			}
			else
			{
			    SendClientMessage(playerid, COLOR_GREY, "   Ten gracz jest nieaktywny.");
			}
		}
		return 1;
	}
	if(strcmp(cmdtext, "/usedrugs", true) == 0 || strcmp(cmdtext, "/uzyjnarkotyki", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
	  if(PlayerBoxing[playerid] > 0)
	  {
	   SendClientMessage(playerid, COLOR_GREY, "   Nie mo¿esz u¿yæ narkotyków podczas walki !");
	   return 1;
	  }
			if(PlayerInfo[playerid][pDrugs] > 1)
			{
		  PlayerStoned[playerid] += 1;
		  if(PlayerStoned[playerid] >= 2) { GameTextForPlayer(playerid, "~w~Jestes~n~~p~Nacpany", 4000, 1); }
		  new Float:health;
			 GetPlayerHealth(playerid, health);

		  SetPlayerHealthEx(playerid, health + 20.0);

			 SendClientMessage(playerid, COLOR_GREY, "   U¿y³eœ 2 gramy narkotyków !");
			 PlayerInfo[playerid][pDrugs] -= 2;
			
			 // adrenalina
			 new Float:pax, Float:pay, Float:paz;
			 GetPlayerPos(playerid, pax, pay, paz);
			 SetTimerEx("BulletKiller",200,0,"d",CreatePickup(1241, 3, pax, pay, paz));

			}
			else
			{
			 SendClientMessage(playerid, COLOR_GREY, "   Nie masz narkotyków !");
			}
		}//not connected
		return 1;
	}
	else if(strcmp(cmd, "/eject", true) == 0 || strcmp(cmd, "/wyrzuc", true) == 0)
	{
  if(IsPlayerConnected(playerid))
 	{
	  new State;
	  if(IsPlayerInAnyVehicle(playerid))
	  {
    State=GetPlayerState(playerid);
		  if(State!=PLAYER_STATE_DRIVER)
		  {
		   SendClientMessage(playerid,COLOR_GREY,"   Mo¿esz wyrzucaæ ludzi z pojazdu tylko jako kierowca !");
		   return 1;
		  }
		
				tmp = strtok(cmdtext, idx);
				if(!strlen(tmp))
				{
					SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /wyrzuc [IdGracza/CzêœæNazwy]");
					return 1;
				}
				new playa;
				playa = ReturnUser(tmp);
				new test;
				test = GetPlayerVehicleID(playerid);
				if(IsPlayerConnected(playa))
				{
				 if(playa != INVALID_PLAYER_ID)
				 {
				  if(playa == playerid) { SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz wyrzuciæ samego siebie"); return 1; }
				  if(IsPlayerInVehicle(playa,test))
				  {
							new PName[MAX_PLAYER_NAME];
							GetPlayerNameMask(playerid,PName,sizeof(PName));
							GetPlayerNameMask(playa, giveplayer, sizeof(giveplayer));
							format(string, sizeof(string), "* Wyrzuci³eœ %s z pojazdu !", giveplayer);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
							format(string, sizeof(string), "* Zosta³eœ wyrzucony z pojazdu przez %s !", PName);
							SendClientMessage(playa, COLOR_LIGHTBLUE, string);
							
       if(PlayerInfo[playa][pWounded] > 0)
				   {
				    GetPlayerPos(playa,           deadPosition[playa][dpX], deadPosition[playa][dpY], deadPosition[playa][dpZ]);
	       GetPlayerFacingAngle(playa,   deadPosition[playa][dpA]);
        deadPosition[playa][dpInt]  = GetPlayerInterior(playa);
        deadPosition[playa][dpVW]   = GetPlayerVirtualWorld(playa);

        SetPlayerPosEx(playa,           deadPosition[playa][dpX], deadPosition[playa][dpY], deadPosition[playa][dpZ]);
        SetPlayerFacingAngle(playa,   deadPosition[playa][dpA]);

        SetPlayerCameraPos(playa,     deadPosition[playa][dpX], deadPosition[playa][dpY], deadPosition[playa][dpZ]+4.0);
        SetPlayerCameraLookAt(playa,  deadPosition[playa][dpX], deadPosition[playa][dpY], deadPosition[playa][dpZ]);

        SetPlayerHealthEx(playa,        1000.0);
        GodMode[playa]                = 1;

        SetTimerEx("ApplyAnimationWounded", 500,  0, "d", playa);
        SetTimerEx("ApplyAnimationWounded", 1000,  0, "d", playa);

        PlayerInfo[playa][pInt]       = deadPosition[playa][dpInt];

	       MedicBill[playa]              = 0;
				   }
				   else
				   {
				    RemovePlayerFromVehicle(playa);
				   }
						}
						else
						{
						 SendClientMessage(playerid, COLOR_GREY, "Ten gracz nie jest w twoim samochodzie!");
						 return 1;
						}
					}
				}
				else
				{
					SendClientMessage(playerid, COLOR_GREY, "Z³y ID/Nazwa!");
				}
			}
			else
			{
			    SendClientMessage(playerid, COLOR_GREY, "Musisz byæ w pojeŸdzie aby tego u¿yæ!");
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/poszukiwani", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	   	{
			if(IsACop(playerid))
			{
				new x;
				SendClientMessage(playerid, COLOR_GREEN, "Aktualnie poszukiwani podejrzani:");
			    for(new i=0; i < MAX_PLAYERS; i++) {
					if(IsPlayerConnected(i))
					{
					    if(WantedLevel[i] > 1)
					    {
							GetPlayerName(i, giveplayer, sizeof(giveplayer));
							format(string, sizeof(string), "%s%s: %d", string,giveplayer,WantedLevel[i]);
							x++;
							if(x > 3) {
							    SendClientMessage(playerid, COLOR_YELLOW, string);
							    x = 0;
								format(string, sizeof(string), "");
							} else {
								format(string, sizeof(string), "%s, ", string);
							}
						}
					}
				}
				if(x <= 3 && x > 0) {
					string[strlen(string)-2] = '.';
				    SendClientMessage(playerid, COLOR_YELLOW, string);
				}
			}
			else
			{
			    SendClientMessage(playerid, COLOR_GREY, "   Nie nale¿ysz do Policji / SWAT / Border Guard !");
			}
		}//not connected
		return 1;
	}
	if(strcmp(cmd, "/quitjob", true) == 0 || strcmp(cmd, "/opuscprace", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
		 if(PlayerInfo[playerid][pJob] > 0)
		 {
		  if(PlayerInfo[playerid][pContractTime] == 0)
				{
			  SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Kontrakt zakoñczy³ siê i zwolni³eœ siê.");
				 PlayerInfo[playerid][pJob] = 0;
				 PlayerInfo[playerid][pContractTime] = 0;
				}
				else
				{
				 format(string, sizeof(string), "* Masz %d godzin do koñca umowy.", PlayerInfo[playerid][pContractTime]);
					SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
				}
			}
			else
			{
			 SendClientMessage(playerid, COLOR_GREY, "   Nie masz ¿adnej pracy !");
			}
		}//not connected
		return 1;
	}
	if(strcmp(cmd, "/bail", true) == 0 || strcmp(cmd, "/kaucja", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	   	{
			if(PlayerInfo[playerid][pJailed]==1 || PlayerInfo[playerid][pJailed]==3)
			{
			    if(JailPrice[playerid] > 0)
			    {
			        if(GetPlayerMoneyEx(playerid) >= JailPrice[playerid])
			        {
			            format(string, sizeof(string), "Wp³aci³eœ kaucjê za siebie w wysokoœci: $%d", JailPrice[playerid]);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						GivePlayerMoneyEx(playerid, -JailPrice[playerid]);
						JailPrice[playerid] = 0;
						WantLawyer[playerid] = 0; CallLawyer[playerid] = 0;
						PlayerInfo[playerid][pJailTime] = 1;
			        }
			        else
			        {
			            SendClientMessage(playerid, COLOR_GRAD1, "   Nie masz pieni¹dzy aby op³aciæ kaucjê !");
			        }
			    }
			    else
			    {
			        SendClientMessage(playerid, COLOR_GRAD1, "   Nie masz ustalonej kaucji !");
			    }
			}
			else
			{
			    SendClientMessage(playerid, COLOR_GRAD1, "Nie jesteœ w wiêzieniu !");
			}
		}//not connected
		return 1;
	}
	if(strcmp(cmd, "/clear", true) == 0 || strcmp(cmd, "/oczysc", true) == 0)
	{
	    if(IsPlayerConnected(playerid))
	   	{
			new member = PlayerInfo[playerid][pMember];
			new leader = PlayerInfo[playerid][pLeader];
			new rank = PlayerInfo[playerid][pRank];
	 		if(GetPlayerOrganization(playerid) == 1)
			{
				if (PlayerToPoint(3.0, playerid, 253.9280,69.6094,1003.6406)){}
				else if(PlayerToPoint(3.0, playerid, 230.4309,165.0516,1003.0234)){}
    else if(PlayerToPoint(5.5, playerid, 223.2836,185.7456,1003.0313)){}
    else
				{
					SendClientMessage(playerid, COLOR_GRAD2, "   Nie jesteœ na Posterunku Policji!");
					return 1;
				}
				tmp = strtok(cmdtext, idx);
				if(!strlen(tmp))
				{
					SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /oczysc [IdGracza/CzêœæNazwy]");
					return 1;
				}
				giveplayerid = ReturnUser(tmp);
				if(IsPlayerConnected(giveplayerid))
				{
				    if(giveplayerid != INVALID_PLAYER_ID)
				    {
                        if(giveplayerid == playerid) { SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz oczyœciæ z zarzutów samego siebie!"); return 1; }
					    GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
						GetPlayerName(playerid, sendername, sizeof(sendername));
						format(string, sizeof(string), "* Oczyœci³eœ z zarzutów gracza %s.", giveplayer);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "* Policjant %s oczyœci³ ciebie z zarzutów.", sendername);
						SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
						WantedPoints[giveplayerid] = 0;
						WantedLevel[giveplayerid] = 0;
						SetPlayerWantedLevel(giveplayerid, WantedLevel[giveplayerid]);
						ClearCrime(giveplayerid);
					}
				}
				else
				{
					SendClientMessage(playerid, COLOR_GREY, "   Nieprawid³owy ID/Nazwa!");
				}
			}
			else if(member == 5||member == 6||leader == 5||leader == 6)
			{
			    tmp = strtok(cmdtext, idx);
				if(!strlen(tmp))
				{
					SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /oczysc [IdGracza/CzêœæNazwy]");
					return 1;
				}
				giveplayerid = ReturnUser(tmp);
				if(IsPlayerConnected(giveplayerid))
				{
				    if(giveplayerid != INVALID_PLAYER_ID)
				    {
				        if(giveplayerid == playerid) { SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz oczyœciæ z zarzutów samego siebie!"); return 1; }
					    if(rank < 4) { SendClientMessage(playerid, COLOR_GREY, "Musisz mieæ 4 rangê by oczysciæ kogoœ z zarzutów !"); return 1; }
					    if(GetPlayerMoneyEx(playerid) < 5000) { SendClientMessage(playerid, COLOR_GREY, "   Potrzebujesz $5000 aby oczyœciæ cz³onka frakcji !"); return 1; }
		                GetPlayerName(giveplayerid, giveplayer, sizeof(giveplayer));
						GetPlayerName(playerid, sendername, sizeof(sendername));
					    if(member > 0)
					    {
						    if(PlayerInfo[giveplayerid][pMember] != member)
							{
								SendClientMessage(playerid, COLOR_GREY, "   Ten gracz nie nale¿y do Twojej frakcji !");
								return 1;
							}
							format(string, sizeof(string), "* Wyczyœci³eœ wszystkie zarzuty %s za $5000.", giveplayer);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
							format(string, sizeof(string), "* Cz³onek frakcji %s z rang¹ %d, oczyœci³ Ciê z wszystkich zarzutów.", sendername, rank);
							SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
						}
						else if(leader > 0)
						{
			                if(PlayerInfo[giveplayerid][pMember] != leader)
							{
								SendClientMessage(playerid, COLOR_GREY, "   Ten gracz nie nale¿y do Twojej frakcji !");
								return 1;
							}
						    format(string, sizeof(string), "* Wyczyœci³eœ wszystkie zarzuty %s za $5000.", giveplayer);
							SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
							format(string, sizeof(string), "* Lider fakcji %s, oczyœci³ Ciê z wszystkich zarzutów.", sendername);
							SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
						}
						WantedPoints[giveplayerid] = 0;
						WantedLevel[giveplayerid] = 0;
						SetPlayerWantedLevel(giveplayerid, WantedLevel[giveplayerid]);
						ClearCrime(giveplayerid);
						GivePlayerMoneyEx(playerid, - 5000);
					}
				}
				else
				{
					SendClientMessage(playerid, COLOR_GREY, "   Nieprawid³owy ID/Nazwa!");
				}
			}
			else
			{
			    SendClientMessage(playerid, COLOR_GREY, "   Nie nale¿ysz do Policji / SWAT / Border Guard / Frakcji !");
			}
		}//not connected
		return 1;
	}
	if(strcmp(cmd, "/ticket", true) == 0 || strcmp(cmd, "/mandat", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
	  if(GetPlayerOrganization(playerid) == 1 || GetPlayerOrganization(playerid) == 2){}
	  else
			{
			 SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ policjantem !");
			 return 1;
			}
			if(PlayerInfo[playerid][pMember] == 1 || PlayerInfo[playerid][pLeader] == 1 || PlayerInfo[playerid][pLeader] == 2 || PlayerInfo[playerid][pMember] == 2){}
	  else
			{
			 SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ policjantem !");
			 return 1;
			}
			// tu wyzej sa tajne kombinacje tak zeby w ogole dzialal tten pieprzony gf
			
   if(OnDuty[playerid] != 1 && (PlayerInfo[playerid][pMember] != 1 || PlayerInfo[playerid][pLeader] != 1 || PlayerInfo[playerid][pLeader] != 2 || PlayerInfo[playerid][pMember] != 2))
			{
			    SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ na s³u¿bie !");
			    return 1;
			}
	    	tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /mandat [IdGracza/CzêœæNazwy] [koszt] [powód]");
				return 1;
			}
			giveplayerid = ReturnUser(tmp);
            tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /mandat [IdGracza/CzêœæNazwy] [koszt] [powód]");
				return 1;
			}
			moneys = strval(tmp);
			if(moneys < 1 || moneys > 2000) { SendClientMessage(playerid, COLOR_GREY, "   Koszt mandatu musi nie mo¿e byæ mniejszy od 1 i wiêkszy od 2000 !"); return 1; }
			if(IsPlayerConnected(giveplayerid))
			{
			 if(giveplayerid != INVALID_PLAYER_ID)
			 {
			  if (ProxDetectorS(8.0, playerid, giveplayerid))
					{
					 GetPlayerNameMask(giveplayerid, giveplayer, sizeof(giveplayer));
						GetPlayerNameMask(playerid, sendername, sizeof(sendername));
						new length = strlen(cmdtext);
						while ((idx < length) && (cmdtext[idx] <= ' '))
						{
							idx++;
						}
						new offset = idx;
						new result[64];
						while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
						{
							result[idx - offset] = cmdtext[idx];
							idx++;
						}
						result[idx - offset] = EOS;
						if(!strlen(result))
						{
							SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /mandat [IdGracza/CzêœæNazwy] [koszt] [powód]");
							return 1;
						}
						format(string, sizeof(string), "* Da³eœ %s mandat w wysokoœci $%d, powód: %s", giveplayer, moneys, (result));
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						format(string, sizeof(string), "* Oficer %s da³ Tobie mandat w wysokoœci $%d, powód: %s", sendername, moneys, (result));
						ApplyAnimation(playerid, "DEALER", "DEALER_DEAL", 4.0, 0, 0, 0, 0, 0); // animka
						SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
						SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, "* Wpiszy /akceptuj mandat, aby przyj¹æ mandat.");
						TicketOffer[giveplayerid] = playerid;
						TicketMoney[giveplayerid] = moneys;
						return 1;
					}
					else
					{
						SendClientMessage(playerid, COLOR_GREY, "   Nie ma takiego gracza w pobli¿u !");
						return 1;
					}
				}
			}
			else
			{
			 SendClientMessage(playerid, COLOR_GREY, "   Nie ma takiego gracza !");
			 return 1;
			}
		}
		return 1;
	}
	if(strcmp(cmd, "/arrest", true) == 0 || strcmp(cmd, "/aresztuj", true) == 0)
	{
	 if(IsPlayerConnected(playerid))
	 {
			if(IsACop(playerid))
			{
				if(OnDuty[playerid] != 1 && PlayerInfo[playerid][pMember] == 1)
				{
				 SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ na s³u¿bie !");
				 return 1;
				}
				
				new gotit = -1;

		    if(PlayerToPoint(6.0, playerid, 1339.8623,771.9606,10.8387)){}
		    else if(PlayerToPoint(12.0, playerid, 1318.5482,792.1910,10.8387)){}
		    else
				{
					new Float:sdistance = 50.0;
					new Float:px, Float:py, Float:pz;
					
					GetPlayerPos(playerid, px, py, pz);
					
				  for(new i = 0; i < sizeof(gJailSpawns); i++)
					{
						new Float:dist2 = GetDistanceBetweenPoints(gJailSpawns[i][0], gJailSpawns[i][1], gJailSpawns[i][2], px, py, pz);
						if(dist2 < sdistance)
						{
						  sdistance = dist2;
							gotit = i;
						}
					}

				// Jail spot
					
					if(gotit == -1)
					{
						SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ w zak³adzie karnym, nie mo¿esz aresztowaæ !");
						return 1;
					}
				}
				tmp = strtok(cmdtext, idx);
				if(!strlen(tmp))
				{
					SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /aresztuj [cena] [czas (minuty)] [kaucja (0=nie 1=tak)] [wysokoœæ kaucji]");
					return 1;
				}
				moneys = strval(tmp);
				if(moneys < 1 || moneys > 20000) { SendClientMessage(playerid, COLOR_GREY, "Wartoœæ kary musi wynosiæ od $1 do $20000 !"); return 1; }
				tmp = strtok(cmdtext, idx);
				if(!strlen(tmp))
				{
					SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /aresztuj [cena] [czas (minuty)] [kaucja (0=nie 1=tak)] [wysokoœæ kaucji]");
					return 1;
				}
				new time = strval(tmp);
				if(time < 1) { SendClientMessage(playerid, COLOR_GREY, "Czas wiêzienia musi wynosiæ przynajmniej jedn¹ minutê!"); return 1; }
				tmp = strtok(cmdtext, idx);
				if(!strlen(tmp))
				{
					SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /aresztuj [cena] [czas (minuty)] [kaucja (0=nie 1=tak)] [wysokoœæ kaucji]");
					return 1;
				}
				new bail = strval(tmp);
				if(bail < 0 || bail > 1) { SendClientMessage(playerid, COLOR_GREY, "   Mo¿liwoœæ zap³acenia kaucji: 0-Nie, 1-Tak !"); return 1; }
				tmp = strtok(cmdtext, idx);
				if(!strlen(tmp))
				{
					SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /aresztuj [cena] [czas (minuty)] [kaucja (0=nie 1=tak)] [wysokoœæ kaucji]");
					return 1;
				}
				new bailprice = strval(tmp);
				if(bailprice < 0 || bailprice > 100000) { SendClientMessage(playerid, COLOR_GREY, "   Kwota kaucji nie mo¿e byæ ni¿sza od $0 i wy¿sza od $100000 !"); return 1; }
				new suspect = GetClosestPlayer(playerid);
				if(IsPlayerConnected(suspect))
				{
					if(GetDistanceBetweenPlayers(playerid,suspect) < 5)
					{
						GetPlayerName(suspect, giveplayer, sizeof(giveplayer));
						GetPlayerName(playerid, sendername, sizeof(sendername));
						if(WantedLevel[suspect] < 1)
						{
						 SendClientMessage(playerid, COLOR_GREY, "   Ta osoba musi mieæ przynajmniej pierwszy poziom poszukiwania !");
						 return 1;
						}
						
						if(PlayerInfo[suspect][pJailTime] > 0)
						{
						 SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest ju¿ w wiêzieniu!");
						 return 1;
						}
						
						if(GetPlayerMoneyEx(suspect) < -15000)
						{
						 SendClientMessage(playerid, COLOR_GREY, "Ta osoba nie ma ju¿ ¿adnych pieniêdzy!");
						 return 1;
						}
						
						format(string, sizeof(string), "* Aresztowa³eœ %s !", giveplayer);
						SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
						GivePlayerMoneyEx(suspect, -moneys);
						Tax += moneys;
						
						format(string, sizeof(string), "Aresztowany przez %s ~n~    na $%d", sendername, moneys);
						GameTextForPlayer(suspect, string, 5000, 5);
						ResetPlayerWeaponsEx(suspect);
						if(PlayerInfo[playerid][pMember]==1||PlayerInfo[playerid][pLeader]==1)
						{
							format(string, sizeof(string), "<< Policjant %s aresztowa³ podejrzanego %s >>", sendername, giveplayer);
							//OOCNews(COLOR_LIGHTRED, string);
							SendFamilyMessage(1, COLOR_LIGHTRED, string);
							SendFamilyMessage(2, COLOR_LIGHTRED, string);
							SendFamilyMessage(3, COLOR_LIGHTRED, string);
							SendFamilyMessage(9, COLOR_LIGHTRED, string);
						}
						else if(PlayerInfo[playerid][pMember]==2||PlayerInfo[playerid][pLeader]==2)
						{
							format(string, sizeof(string), "<< Agent SWAT %s aresztowa³ podejrzanego %s >>", sendername, giveplayer);
							//OOCNews(COLOR_LIGHTRED, string);
							SendFamilyMessage(1, COLOR_LIGHTRED, string);
							SendFamilyMessage(2, COLOR_LIGHTRED, string);
							SendFamilyMessage(3, COLOR_LIGHTRED, string);
							SendFamilyMessage(9, COLOR_LIGHTRED, string);
						}
						else if(PlayerInfo[playerid][pMember]==3||PlayerInfo[playerid][pLeader]==3)
						{
							format(string, sizeof(string), "<< ¯o³nierz %s aresztowa³ podejrzanego %s >>", sendername, giveplayer);
							//OOCNews(COLOR_LIGHTRED, string);
							SendFamilyMessage(1, COLOR_LIGHTRED, string);
							SendFamilyMessage(2, COLOR_LIGHTRED, string);
							SendFamilyMessage(3, COLOR_LIGHTRED, string);
							SendFamilyMessage(9, COLOR_LIGHTRED, string);
						}
						else if(PlayerInfo[playerid][pMember]==13||PlayerInfo[playerid][pLeader]==13)
						{
							format(string, sizeof(string), "<< Agent FBI %s aresztowa³ podejrzanego %s >>", sendername, giveplayer);
							//OOCNews(COLOR_LIGHTRED, string);
							SendFamilyMessage(1, COLOR_LIGHTRED, string);
							SendFamilyMessage(2, COLOR_LIGHTRED, string);
							SendFamilyMessage(3, COLOR_LIGHTRED, string);
							SendFamilyMessage(9, COLOR_LIGHTRED, string);
						}
						
						ArrestLog(string);
						
						if(gotit != -1)
						{
							SetPlayerPosEx(suspect, gJailSpawns[gotit][0], gJailSpawns[gotit][1], gJailSpawns[gotit][2]);
							SetPlayerFacingAngle(suspect, gJailSpawns[gotit][3]);
							PlayerInfo[suspect][pJailCell] = gotit;
						}
						else if(PlayerToPoint(12.0, playerid, 1318.5482, 792.1910, 10.8387))//fbi
						{
						 SetPlayerInterior(suspect, 0);//3
 						SetPlayerPosEx(suspect,1318.5482, 792.1910, 10.8387);
						}
						else // PD
						{
 						SetPlayerInterior(suspect, 0);//3
 						SetPlayerPosEx(suspect,255.137, -41.5322, 1002.0234);
 						//SetPlayerPosEx(suspect,1318.5482, 792.1910, 10.8387);
						}
						
						PlayerInfo[suspect][pJailTime] = time * 60;
						if(bail == 1)
						{
							JailPrice[suspect] = bailprice;
							format(string, sizeof(string), "Jesteœ w wiêzieniu na %d sekund.   Kaucja: $%d", PlayerInfo[suspect][pJailTime], JailPrice[suspect]);
							SendClientMessage(suspect, COLOR_LIGHTBLUE, string);
						}
						else
						{
						 JailPrice[suspect] = 0;
							format(string, sizeof(string), "Jesteœ w wiêzieniu na %d sekund.   Kaucja: Niemo¿liwa", PlayerInfo[suspect][pJailTime]);
							SendClientMessage(suspect, COLOR_LIGHTBLUE, string);
						}
						if(gotit != -1)
						{
						 PlayerInfo[suspect][pJailed] = 5;
						}
						else if(PlayerToPoint(12.0, playerid, 194.1343,178.8516,1003.0234))//fbi
						{
						 PlayerInfo[suspect][pJailed] = 3;
					 }
					 else // PD
					 {
						 PlayerInfo[suspect][pJailed] = 1;
					 }
				  PlayerInfo[suspect][pArrested] += 1;
						SetPlayerFree(suspect,playerid, sendername);
						WantedPoints[suspect] = 0;
						WantedLevel[suspect] = 0;
						WantLawyer[suspect] = 1;
						SetPlayerWantedLevel(giveplayerid, WantedLevel[suspect]);
					}//distance
				}//not connected
				else
				{
				 SendClientMessage(playerid, COLOR_GREY, "   Nie ma nikogo w pobli¿u do aresztowania.");
				 return 1;
				}
			}
			else
			{
			 SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ Policjantem / Agentem SWAT / Gwardi¹ Narodow¹ !");
			 return 1;
			}
		}//not connected
		return 1;
	} 	
	dcmd(cellin, 6, cmdtext);
	dcmd(cellout, 7, cmdtext);	
	dcmd(bron, 4, cmdtext);
	dcmd(bar, 3, cmdtext);
	dcmd(aparat, 6, cmdtext);
	dcmd(pal, 3, cmdtext);
	dcmd(smokef, 6, cmdtext);
  dcmd(koszykowka, 10, cmdtext);
	dcmd(ciekawski, 9, cmdtext);
	dcmd(guma, 4, cmdtext);
	dcmd(idz, 3, cmdtext);
	dcmd(wow, 3, cmdtext);
	dcmd(neo, 3, cmdtext);
	dcmd(bitchslap, 9, cmdtext);
	dcmd(biuro, 5, cmdtext);
	dcmd(dance, 5, cmdtext);
	dcmdalt(dance, 5, cmdtext, tancz);
	dcmd(bilard, 6, cmdtext);
	dcmd(gwalk, 5, cmdtext);
	dcmd(yo1, 3, cmdtext);
	dcmd(odbierzrozmowe, 14, cmdtext);
	dcmd(zakonczrozmowe, 14, cmdtext);
	dcmd(przeladujde, 11, cmdtext);
	dcmd(mysl, 4, cmdtext);
	dcmd(stopp, 5, cmdtext);
	dcmd(stopl, 5, cmdtext);
	dcmd(kibel, 5, cmdtext);
	dcmd(wskaz, 5, cmdtext);
	dcmd(salutuj, 7, cmdtext);
	dcmd(rece, 4, cmdtext);
	dcmd(sikaj, 5, cmdtext);
	dcmd(plaskacz, 8, cmdtext);
	dcmd(pocaluj, 7, cmdtext);
	dcmd(napad, 5, cmdtext);
	dcmd(saturator, 9, cmdtext);
	dcmd(medyk, 5, cmdtext);
	dcmd(spij, 4, cmdtext);
	dcmd(klepnij, 7, cmdtext);
	dcmd(skuj, 4, cmdtext);
	dcmd(zebraj, 6, cmdtext);
	dcmd(stac, 4, cmdtext);
	dcmd(ruszaj, 6, cmdtext);
	dcmd(chodz, 5, cmdtext);
	dcmd(taranuj, 7, cmdtext);
	dcmd(czekam, 6, cmdtext);
	dcmd(taxi, 4, cmdtext);
	dcmd(upadnij, 7, cmdtext);
	dcmd(zmeczony, 8, cmdtext);
	dcmd(podaj, 5, cmdtext);
	dcmd(zaczep, 6, cmdtext);
	dcmd(umyjrece, 8, cmdtext);
	dcmd(przycisk, 8, cmdtext);
	dcmd(drapjaja, 8, cmdtext);
	dcmd(unik, 4, cmdtext);
	dcmd(naprawiaj, 9, cmdtext);
	dcmd(skoncznaprawiac, 15, cmdtext);
	dcmd(dajprezent, 10, cmdtext);
	dcmd(wezprezent, 10, cmdtext);
	dcmd(podnies, 7, cmdtext);
	dcmd(odlicz, 6, cmdtext);
	dcmd(postrzelony, 11, cmdtext);
	dcmd(placz, 5, cmdtext);
	dcmd(poloz, 5, cmdtext);
	dcmd(oh, 2, cmdtext);
	dcmd(recemaska, 9, cmdtext);
	dcmd(bagaznik, 8, cmdtext);
	dcmd(odpalblanta, 11, cmdtext);
	dcmd(spray2, 6, cmdtext);
	dcmd(piwo, 4, cmdtext);
	dcmd(yo2, 3, cmdtext);
	dcmd(yo3, 3, cmdtext);
	dcmd(yo4, 3, cmdtext);
	dcmd(yo5, 3, cmdtext);
	dcmd(yo6, 3, cmdtext);
	dcmd(yo7, 3, cmdtext);
	dcmd(yoyo, 4, cmdtext);
	//dcmd(gtalk1, 6, cmdtext);
	//dcmd(gtalk2, 6, cmdtext);
	//dcmd(gtalk3, 6, cmdtext);
	dcmd(gtalk, 5, cmdtext);
	dcmd(spray1, 6, cmdtext);
	dcmd(wyrzucblanta, 12, cmdtext);
	//dcmd(rhk1, 4, cmdtext);
	//dcmd(rhk2, 4, cmdtext);
	//dcmd(rhk3, 4, cmdtext);
	dcmd(recestan, 8, cmdtext);
	dcmd(rozgladaj, 9, cmdtext);
	dcmd(zalamka, 7, cmdtext);
	dcmd(kopnij, 6, cmdtext);
	dcmd(rhk, 3, cmdtext);
	dcmd(gru, 3, cmdtext);
	//dcmd(gru1, 4, cmdtext);
	//dcmd(gru2, 4, cmdtext);
	//dcmd(gru3, 4, cmdtext);
	//dcmd(norte1, 6, cmdtext);
	//dcmd(norte2, 6, cmdtext);
	//dcmd(norte3, 6, cmdtext);
	dcmd(norte, 5, cmdtext);
	dcmd(gsign, 5, cmdtext);
	//dcmd(gsign1, 6, cmdtext);
	//dcmd(gsign2, 6, cmdtext);
	dcmd(fuck1, 5, cmdtext);
	dcmd(wtf, 3, cmdtext);
	dcmd(tak, 3, cmdtext);
	dcmd(nie, 3, cmdtext);
	dcmd(wypij, 5, cmdtext);
	dcmd(pijak, 5, cmdtext);
	dcmd(opieraj, 7, cmdtext);
	dcmd(stan, 4, cmdtext);
	dcmd(rapuj, 5, cmdtext);
	//dcmd(rapuj2, 6, cmdtext);
	//dcmd(rapuj3, 6, cmdtext);
	dcmd(bomba, 5, cmdtext);
	dcmd(aresztowany, 11, cmdtext);
	dcmd(smiech, 6, cmdtext);
	dcmd(rozejrzyjsie, 12, cmdtext);
	dcmd(ramiona, 7, cmdtext);
	dcmd(lezec, 5, cmdtext);
	dcmd(chowaj, 6, cmdtext);
	dcmd(palka, 5, cmdtext);
	//dcmd(palka1, 6, cmdtext);
	dcmd(przewroc, 8, cmdtext);
	dcmd(caluj1, 6, cmdtext);
	dcmd(caluj2, 6, cmdtext);
	//dcmd(lezec1, 6, cmdtext);
	//dcmd(lezec2, 6, cmdtext);
	//dcmd(lezec3, 6, cmdtext);
	//dcmd(usiadz2, 7, cmdtext);
	//dcmd(palka2, 6, cmdtext);
	//dcmd(palka3, 6, cmdtext);
	//dcmd(crack1, 6, cmdtext);
	//dcmd(crack2, 6, cmdtext);
	//dcmd(crack3, 6, cmdtext);
	dcmd(crack, 6, cmdtext);
	dcmd(lozkol, 6, cmdtext);
	dcmd(lozkop, 6, cmdtext);
	dcmd(zejdzl, 6, cmdtext);
	dcmd(zejdzp, 6, cmdtext);
	dcmd(fotel, 5, cmdtext);
	dcmd(fotelzejdz, 10, cmdtext);
	dcmd(usiadzk, 7, cmdtext);
	dcmd(koks, 4, cmdtext);
	dcmd(koksidz, 7, cmdtext);
	dcmd(gogo, 4, cmdtext);
	dcmd(wymiotuj, 8, cmdtext);
	dcmd(jedz, 4, cmdtext);
	dcmd(machaj, 6, cmdtext);
	dcmd(narkotyki, 9, cmdtext);
	dcmd(crack, 5, cmdtext);
	//dcmd(papieros, 8, cmdtext);
	//dcmd(smokef, 6, cmdtext);
	dcmd(usiadz, 6, cmdtext);
	dcmd(fuck, 4, cmdtext);
	dcmd(taichi, 6, cmdtext);
	dcmd(krzeslo, 7, cmdtext);
	dcmd(ranny, 5, cmdtext);
	dcmd(siadaj, 6, cmdtext);
	dcmd(wstan, 5, cmdtext);
	dcmd(przeladujm4, 11, cmdtext);
	dcmd(lokiec, 6, cmdtext);
	dcmd(animacje, 8, cmdtext);
	dcmd(anim, 4, cmdtext);
	dcmd(sprobuj, 7, cmdtext);
	dcmd(przejedz, 8, cmdtext);
	dcmd(yo, 2, cmdtext);
	dcmd(waxls, 5, cmdtext);
	dcmd(kontakt, 7, cmdtext);


	return 1;
}
//------------------------------------------------------------------------------------------------------


forward ProxDetectorMaskPoint(Float:oldposx, Float:oldposy, Float:oldposz, Float:radi, playerid, vw, string[],col1,col2,col3,col4,col5);
public  ProxDetectorMaskPoint(Float:oldposx, Float:oldposy, Float:oldposz, Float:radi, playerid, vw, string[],col1,col2,col3,col4,col5)
{
	if(IsPlayerConnected(playerid))
	{
		new Float:posx, Float:posy, Float:posz;
		new Float:tempposx, Float:tempposy, Float:tempposz;
		new string2[512];
		
	 format(string2, sizeof(string2), "[ID:%d] %s", playerid, string);
		
		//radi = 2.0; //Trigger Radius
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(IsPlayerConnected(i))
			{
			 if(vw == GetPlayerVirtualWorld(i))
			 {
				if(!BigEar[i])
				{
					GetPlayerPos(i, posx, posy, posz);
					tempposx = (oldposx -posx);
					tempposy = (oldposy -posy);
					tempposz = (oldposz -posz);
					//printf("DEBUG: X:%f Y:%f Z:%f",posx,posy,posz);
					if (((tempposx < radi/16) && (tempposx > -radi/16)) && ((tempposy < radi/16) && (tempposy > -radi/16)) && ((tempposz < radi/16) && (tempposz > -radi/16)))
					{
					 if(OnAdminDuty[i] == 1 && hasMaskOn[playerid] == 1)
					 {
					  SendClientMessage(i, col1, string2);
					 }
					 else
					 {
						 SendClientMessage(i, col1, string);
					 }
					}
					else if (((tempposx < radi/8) && (tempposx > -radi/8)) && ((tempposy < radi/8) && (tempposy > -radi/8)) && ((tempposz < radi/8) && (tempposz > -radi/8)))
					{
						if(OnAdminDuty[i] == 1 && hasMaskOn[playerid] == 1)
					 {
					  SendClientMessage(i, col2, string2);
					 }
					 else
					 {
						 SendClientMessage(i, col2, string);
					 }
					}
					else if (((tempposx < radi/4) && (tempposx > -radi/4)) && ((tempposy < radi/4) && (tempposy > -radi/4)) && ((tempposz < radi/4) && (tempposz > -radi/4)))
					{
						if(OnAdminDuty[i] == 1 && hasMaskOn[playerid] == 1)
					 {
					  SendClientMessage(i, col3, string2);
					 }
					 else
					 {
						 SendClientMessage(i, col3, string);
					 }
					}
					else if (((tempposx < radi/2) && (tempposx > -radi/2)) && ((tempposy < radi/2) && (tempposy > -radi/2)) && ((tempposz < radi/2) && (tempposz > -radi/2)))
					{
						if(OnAdminDuty[i] == 1 && hasMaskOn[playerid] == 1)
					 {
					  SendClientMessage(i, col4, string2);
					 }
					 else
					 {
						 SendClientMessage(i, col4, string);
					 }
					}
					else if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
					{
						if(OnAdminDuty[i] == 1 && hasMaskOn[playerid] == 1)
					 {
					  SendClientMessage(i, col5, string2);
					 }
					 else
					 {
						 SendClientMessage(i, col5, string);
					 }
					}
				}
				else
				{
	 			if(OnAdminDuty[i] == 1 && hasMaskOn[playerid] == 1)
				 {
				  SendClientMessage(i, col1, string2);
				 }
				 else
				 {
					 SendClientMessage(i, col1, string);
				 }
 				}
				}
			}
		}
	}//not connected
	return 1;
}

public CrimInRange(Float:radi, playerid, copid)
{
	if(IsPlayerConnected(playerid)&&IsPlayerConnected(copid))
	{
		new Float:posx, Float:posy, Float:posz;
		new Float:oldposx, Float:oldposy, Float:oldposz;
		new Float:tempposx, Float:tempposy;
		GetPlayerPos(playerid, oldposx, oldposy, oldposz);
		GetPlayerPos(copid, posx, posy, posz);
		tempposx = (oldposx -posx);
		tempposy = (oldposy -posy);
		if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)))
		{
			return 1;
		}
	}
	return 0;
}

public ProxDetectorS(Float:radius, playerid, targetid)
{
	if(!IsPlayerConnected(playerid) || !IsPlayerConnected(targetid)) return 0;

	new Float:posx, Float:posy, Float:posz;
	GetPlayerPos(playerid, posx, posy, posz);

	new Float:tposx, Float:tposy, Float:tposz;
	GetPlayerPos(targetid, tposx, tposy, tposz);

	return (GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(targetid) && Type8(posx, posy, posz, tposx, tposy, tposz, radius));
}

public CustomPickups()
{
	new Float:oldposx, Float:oldposy, Float:oldposz;
	new string[128];
	//NameTimer();
	for(new i = 0; i < GetMaxPlayers(); i++)
	{
		if(IsPlayerConnected(i) && disableAntyCheat[i] == 0 && gLogged2[i] == 1)
		{
		 if(skipAntyCheat[i] == 0)
		 {
		  /**
		   * Antycheat - tu go dorzucamy :)
		   */
	   new isCheating = 0, cheatWeapon = 0;
	
	   for(new s = 1; s < 13; s++)
	   {
		   new weapon, ammo;
	 	
	   	GetPlayerWeaponData(i, s, weapon, ammo);
	 	
	 	  if(ammo > 0 && weapon > 0)
	 	  {
	 	   if(s == 1)
      {
       if(PlayerWeapons[i][pGun1] != weapon)
       {
        isCheating = 1;
        cheatWeapon = weapon;
       }
      }
      else if(s == 2)
      {
       if(PlayerWeapons[i][pGun2] != weapon)
       {
        isCheating = 1;
        cheatWeapon = weapon;
       }
      }
      else if(s == 3)
      {
       if(PlayerWeapons[i][pAmmo3] == -3 && weapon == 25)
       {
        SetPlayerAmmo(i, 25, 0);
        PlayerWeapons[i][pAmmo3] = 0;

        // pobieramy jeszcze raz dla pewnoœci
        GetPlayerWeaponData(i, s, weapon, ammo);

        if(weapon == 25)
        {
         PlayerWeapons[i][pAmmo3] = -3;
        }

        // anulujemy bana ponizej
        PlayerWeapons[i][pGun3] = 0;
        weapon = PlayerWeapons[i][pGun3];

        /*SendClientMessage(i, COLOR_RED, "usuwamy shotguna");
        new st[64];
        format(st, sizeof(st), "Weapon: %d, pGun3: %d", weapon, PlayerWeapons[i][pGun3]);
        SendClientMessage(i, COLOR_RED, st);*/
       }

       if(PlayerWeapons[i][pGun3] != weapon)
       {
        isCheating = 1;
        cheatWeapon = weapon;
       }
      }
      else if(s == 4)
      {
       if(PlayerWeapons[i][pGun4] != weapon)
       {
        isCheating = 1;
        cheatWeapon = weapon;
       }
      }
      else if(s == 5)
      {
       if(PlayerWeapons[i][pGun5] != weapon)
       {
        isCheating = 1;
        cheatWeapon = weapon;
       }
      }
      else if(s == 6)
      {
       if(PlayerWeapons[i][pGun6] != weapon)
       {
        isCheating = 1;
        cheatWeapon = weapon;
       }
      }
      else if(s == 7)
      {
       if(PlayerWeapons[i][pGun7] != weapon)
       {
        isCheating = 1;
        cheatWeapon = weapon;
       }
      }
      else if(s == 8)
      {
       if(PlayerWeapons[i][pGun8] != weapon)
       {
        isCheating = 1;
        cheatWeapon = weapon;
       }
      }
      else if(s == 9)
      {
       if(PlayerWeapons[i][pGun9] != weapon)
       {
        isCheating = 1;
        cheatWeapon = weapon;
       }
      }
      else if(s == 10)
      {
       if(PlayerWeapons[i][pGun10] != weapon)
       {
        isCheating = 1;
        cheatWeapon = weapon;
       }
      }
      else if(s == 11)
      {
       if(PlayerWeapons[i][pGun11] != weapon && weapon != 46)
       {
        isCheating  = 1;
        cheatWeapon = weapon;
       }
      }
      else if(s == 12)
      {
       if(PlayerWeapons[i][pGun12] != weapon)
       {
        isCheating = 1;
        cheatWeapon = weapon;
       }
      }
     }
		  }
		
	 	 if(isCheating == 1)
	 	 {
	 	  new giveplayer[MAX_PLAYER_NAME], str[315], giveplayerid;
	 	
	 	  if(PlayerInfo[i][pLocalType] != 0)
     {
      GetPlayerNameEx(i, giveplayer, sizeof(giveplayer));
      //format(string, sizeof(string), "Admin: %s zosta³ wyrzucony, Powód: Podnoszenie broni w domu", giveplayer);
     format(string, sizeof(string), "~>~ System ~<~ ~r~%s ~w~zostal wyrzucony, ~w~Powod: ~r~Podnoszenie broni w domu", giveplayer);
     KickLog(string);
     TextDrawSetString(Kara, string);
	 TextDrawShowForAll(Kara);
	 KillTimer(KaraTD);
	 KaraTD = SetTimer("textkara", 10000, 0);
	 format(str, sizeof(str), "Zosta³eœ wyrzucony z serwera przez: {9e1e1e}System, {a9c4e4}Powód: {9e1e1e}Gun Cheat (ID broni: %d) \n\n{9e1e1e}UWAGA:\n{a9c4e4}Jeœli kara by³a nies³uszna mo¿esz siê odwo³aæ na forum w odpowienim dziale.\nPamiêtaj równie¿ o screenie, który jest niezbêdny do apelacji.", cheatWeapon);
	 ShowPlayerDialog(giveplayerid, DIALOG_GUN_FOR_PLAYER, DIALOG_STYLE_MSGBOX, "Kick - Gun Cheat", str,"Zamknij", "");
	 TextDrawHideForPlayer(giveplayerid, Kara);
     
   		 //SendClientMessage(i, COLOR_LIGHTRED, string);
   		 Kick(i);
     }
     else
     {
      if(PlayerInfo[i][pMember] != 1 && PlayerInfo[i][pMember] != 1 && PlayerInfo[i][pLeader] != 3 && PlayerInfo[i][pLeader] != 3 && PlayerInfo[i][pMember] != 17 && PlayerInfo[i][pLeader] != 17)
      {
	 	   new year, month,day;
  			 getdate(year, month, day);
	     GetPlayerNameEx(i, giveplayer, sizeof(giveplayer));
	 			 //format(string, sizeof(string), "Admin: %s zosta³ wyrzucony, Powód: Gun Cheat (ID: %d)", giveplayer, cheatWeapon);

	 			 format(string, sizeof(string), "~>~ System ~<~ ~r~%s ~w~zostal wyrzucony, ~w~Powod: ~r~Gun Cheat (ID broni: %d)", giveplayer, cheatWeapon);
	             //SendClientMessageToAll(COLOR_LIGHTRED, string);
	             TextDrawSetString(Kara, string);
	             TextDrawShowForAll(Kara);
	             KillTimer(KaraTD);
	             KaraTD = SetTimer("textkara", 10000, 0);
	             format(str, sizeof(str), "Zosta³eœ wyrzucony z serwera przez: {9e1e1e}System, {a9c4e4}Powód: {9e1e1e}Gun Cheat (ID broni: %d) \n\n{9e1e1e}UWAGA:\n{a9c4e4}Jeœli kara by³a nies³uszna mo¿esz siê odwo³aæ na forum w odpowienim dziale.\nPamiêtaj równie¿ o screenie, który jest niezbêdny do apelacji.", cheatWeapon);
	             ShowPlayerDialog(giveplayerid, DIALOG_GUN_FOR_PLAYER, DIALOG_STYLE_MSGBOX, "Kick - Gun Cheat", str,"Zamknij", "");
	 			 KickLog(string);
   		         //SendClientMessageToAll(COLOR_LIGHTRED, string);
   		          Kick(i);
  	 	       PlayerInfo[i][pLevel]  = 1;
	 			 /*PlayerInfo[i][pMember] = 0;
	 			 PlayerInfo[i][pLeader] = 0;
	 			 PlayerInfo[i][pTeam]   = 3;
	 		 	format(string, sizeof(string), "Gun Cheat - ID broni: %d", cheatWeapon);
	 		 	      KickLog(string);
   		              Kick(i);*/
 		 	 }
	 	 	}
	 	 }
		 }
		 else
		 {
		  skipAntyCheat[i] -= 1;
		 }
		
			GetPlayerPos(i, oldposx, oldposy, oldposz);
		}
	}
	return 1;
}

public OnPlayerText(playerid, text[])
{
	new sendername[MAX_PLAYER_NAME];
	new tmp[32];
	new string[128];
	
	if(AFKCheck[playerid] >= 5)
		OnPlayerBackOfAFK(playerid);
	
	AFKCheck[playerid] = 0;

	if(PlayerInfo[playerid][pMuted] >= 1)
	{
		SendClientMessage(playerid, TEAM_CYAN_COLOR, "Nie mo¿esz rozmawiaæ, zosta³eœ wyciszony");
		return 0;
	}
	
    if(CellularPhone[playerid] >= 1)
    {
            if((strcmp("1", text, true, strlen(text)) == 0) || (strcmp("call", text, true, strlen(text)) == 0))
            {
                SetPVarInt(playerid, "call", strval(text));
             	ShowPlayerDialog(playerid, DIALOG_CALL, DIALOG_STYLE_INPUT, "Telefon » Nowe po³¹czenie", "WprowadŸ numer, na których chcesz wykonac po³¹czenie.\nJeœli numer zapisany jest w telefonie mo¿esz wykonaæ po³¹czenie\nbez wprowadzania numeru.", "Po³¹cz", "Anuluj");
			  	return 0;
            }
            if((strcmp("2", text, true, strlen(text)) == 0) || (strcmp("sms", text, true, strlen(text)) == 0))
            {
             	ShowPlayerDialog(playerid, DIALOG_SMS_NR, DIALOG_STYLE_INPUT, "Telefon » Wiadomoœæ SMS » Dodaj odbiorcê", "WprowadŸ numer, na których chcesz wys³aæ wiadomoœæ textow¹.", "Dalej", "Anuluj");
				return 0;
            }
            if((strcmp("3", text, true, strlen(text)) == 0) || (strcmp("kontakty", text, true, strlen(text)) == 0))
            {
            			new str[126], gphonenumber, nick[32], query[999], phonenumber;
   	 					new itemindex = GetUsedItemByItemId(playerid, ITEM_CELLPHONE);
   	 					phonenumber = Items[itemindex][iAttr1];

            				format(str, 126, "SELECT `gphonenumber`, `nick` FROM `vcard` WHERE `phonenumber`=%d ORDER BY `nick`, `gphonenumber`", phonenumber);
							mysql_query(str);
							mysql_store_result();

							while(mysql_fetch_row_format(str, "|"))
							{
   									sscanf(str, "p<|>is[32]", gphonenumber, nick);
									format(query, sizeof(query), "%s%d\t {DEB887}%s{FFFFFF}\n", query, gphonenumber, nick);

							}
							
							format(query, sizeof(query), "911\tNumer alarmowy\n444\tTaxi\n555\tVIBE News\n----------------------------------\n%s\n", query);
							ShowPlayerDialog(playerid, DIALOG_CONTACTS, DIALOG_STYLE_LIST, "Telefon » Kontakty", query, "Wybierz", "Zamknij");
							mysql_free_result();//zwalniamy pamiêæ
							return 0;
            }
            if((strcmp("4", text, true, strlen(text)) == 0) || (strcmp("vcard", text, true, strlen(text)) == 0))
            {
          			new list[512], find = 0, itemindex = GetUsedItemByItemId(playerid, ITEM_CELLPHONE);
   	 				PlayerInfo[playerid][pPnumber] = Items[itemindex][iAttr1];
   	 				new phonenumber = Items[itemindex][iAttr1];
   	 				
          			GetPlayerPos(playerid, PlayerInfo[playerid][pPos_x], PlayerInfo[playerid][pPos_y], PlayerInfo[playerid][pPos_z]);
					foreach(Player, i)
					{
						if(IsPlayerInRangeOfPoint(i, 5.0, PlayerInfo[playerid][pPos_x], PlayerInfo[playerid][pPos_y], PlayerInfo[playerid][pPos_z]) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i))
						{
							//if(i != playerid && PlayerInfo[i][pPnumber] != 0)
							if(i != playerid && phonenumber != 0)
							{
						        format(list, sizeof(list), "%s%d\t%s\n", list, i, pName(i));
								find++;
							}
						}
					}
					if(find == 0)
					{
							//SendClientMessage(playerid, COLOR_OOC, "W pobli¿u nie ma ¿adnego gracza!");
							GameTextForPlayer(playerid, NO_PLAYERS_MESSAGE, 2000, 3);
					}
					else
					{
							ShowPlayerDialog(playerid, DIALOG_VCARD, DIALOG_STYLE_LIST, "Telefon » Wyœlij kontakt » Wybierz gracza", list, "Wybierz", "Anuluj");
					}
					return 0;

            }
            if((strcmp("5", text, true, strlen(text)) == 0) || (strcmp("dodatki", text, true, strlen(text)) == 0))
            {
             	ShowPlayerDialog(playerid, DIALOG_ADDITVE, DIALOG_STYLE_LIST, "Telefon » Dodatki", "1. Odtwarzacz MP3\n2. Radio FM\n3. Zegarek", "Wybierz", "Anuluj");
				return 0;
            }
            if((strcmp("6", text, true, strlen(text)) == 0) || (strcmp("po³¹czenia", text, true, strlen(text)) == 0))
            {
				ShowPlayerDialog(playerid, DIALOG_CONNECTION_SELECTION, DIALOG_STYLE_LIST, "Telefon » Po³¹czenia", "1. Po³¹czenia wychodz¹ce\n2. Po³¹czenia przychodz¹ce", "Wybierz", "Zamknij");
				return 0;
            }
            if((strcmp("7", text, true, strlen(text)) == 0) || (strcmp("opcje", text, true, strlen(text)) == 0))
            {
             	ShowPlayerDialog(playerid, DIALOG_PHONE_OPTIONS, DIALOG_STYLE_LIST, "Telefon » Opcje", "1. Usuñ kontakt\n2. Zmieñ dzwonek\n3. Wycisz telefon", "Wybierz", "Anuluj");
				return 0;
            }
	}
	
	if (strlen(text) < 3)
	{
		if ((strcmp(":)", text, true, strlen(text)) == 0) && (strlen(text) == strlen(":)")))
		{
			ServerMe(playerid, "uœmiecha siê.");
			return 0;
		}

		if ((strcmp(":/", text, true, strlen(text)) == 0) && (strlen(text) == strlen(":/")))
		{
			ServerMe(playerid, "krzywi siê.");
			return 0;
		}

		if ((strcmp(":(", text, true, strlen(text)) == 0) && (strlen(text) == strlen(":(")))
		{
			ServerMe(playerid, "robi smutn¹ minê.");
			return 0;
		}

		if ((strcmp(":o", text, true, strlen(text)) == 0) && (strlen(text) == strlen(":o")))
		{
			ServerMe(playerid, "robi wielkie oczy.");
			return 0;
		}

		if ((strcmp(":*", text, true, strlen(text)) == 0) && (strlen(text) == strlen(":*")))
		{
			OnePlayAnim(playerid,"KISSING","Playa_Kiss_01",4.1,0,0,0,0,-1);
			return 0;
		}
		if ((strcmp(":D", text, true, strlen(text)) == 0) && (strlen(text) == strlen(":D")))
		{
			ApplyAnimation(playerid, "RAPPING", "Laugh_01", 4.1, 0, 0, 0, 0, 0);
			ServerMe(playerid, "œmieje siê.");
			return 0;
		}
	}

	if(!CheckIsTextIC(playerid, text))
	{
		return 0;
	}

	if(acceptDeath[playerid] == 1)
	{
		new idx;
		tmp = strtok(text, idx);
	
		if ((strcmp("tak", tmp, true, strlen(tmp)) == 0) && (strlen(tmp) == strlen("tak")))
		{
			PlayerInfo[playerid][pCK] = 1;
			SendClientMessage(playerid,COLOR_LIGHTRED,"Twoja postaæ zosta³a uœmiercona.");

			GetPlayerNameEx(playerid, sendername, sizeof(sendername));

			format(string, sizeof(string), "Komunikat: Postaæ %s zosta³a uœmiercona.", sendername);
			SendClientMessageToAll(COLOR_LIGHTRED, string);
		
			// zw³oki
			new nitem[pItem];

			nitem[iItemId] = ITEM_CORPSE;
			nitem[iCount] = 0;
			nitem[iOwner] = 0;
			nitem[iFlags] += ITEM_FLAG_DROPPED;

			GetPlayerPos(playerid, nitem[iPosX], nitem[iPosY], nitem[iPosZ]);
			nitem[iPosVW] = GetPlayerVirtualWorld(playerid);

			nitem[iAttr1] = deadPosition[playerid][dpDeathReason];
			nitem[iAttr2] = PlayerInfo[playerid][pId];
			GetPlayerNameEx(playerid, nitem[iAttr5], sizeof(nitem[iAttr5]));

			CreateItem(nitem);
			
			for(new i = 0; i < MAX_ITEMS; i++)
			{
				if(Items[i][iOwner] == PlayerInfo[playerid][pId] && Items[i][iOwnerType] == CONTENT_TYPE_USER)
				{
					new it = GetItemType(Items[i][iItemId]);
			
					if(!(ItemsTypes[it][itFlags] & ITEM_FLAG_DROPABLE))
					{
						continue;
					}
					
					if(Items[i][iFlags] & ITEM_FLAG_USING)
					{
						Items[i][iFlags] -= ITEM_FLAG_USING;
					}
					
					PlayerDropItem(playerid, i, 2.0);
				}
			}
			
			acceptDeath[playerid] = 0;
			
			GetPlayerName(playerid, sendername, sizeof(sendername));
			Kick(playerid);
			
			#if CORPSES
			InitCorpse(sendername);
			ConnectNPC(sendername, "corpse");
			#endif
			
			return 0;
		}	
		else if ((strcmp("nie", tmp, true, strlen(tmp)) == 0) && (strlen(tmp) == strlen("nie")))
		{
			SendClientMessage(playerid, COLOR_WHITE, "Podj¹³eœ decyzjê o nie uœmiercaniu twojej postaci, teraz musisz poczekaæ 15 minut, a¿ ktoœ udzieli Ci pomocy.");
			acceptDeath[playerid] = 0;
			return 0;
		}
		else
		{
			SendClientMessage(playerid, COLOR_WHITE, "Wpisz 'tak' lub 'nie'.");
			return 0;
		}
	}
	
  if(CallLawyer[playerid] == 111)
	{
		new idx;
		tmp = strtok(text, idx);
		if ((strcmp("tak", tmp, true, strlen(tmp)) == 0) && (strlen(tmp) == strlen("tak")))
		{
			GetPlayerName(playerid, sendername, sizeof(sendername));
			format(string, sizeof(string), "** % jest w wiêzieniu, i potrzebuje prawnika. JedŸ na posterunek.", sendername);
			SendJobMessage(2, TEAM_AZTECAS_COLOR, string);
			SendJobMessage(2, TEAM_AZTECAS_COLOR, "* Kiedy jesteœ na posterunku poproœ policjanta o zgodê na uwolnienie wiêŸnia.");
			SendClientMessage(playerid, COLOR_LIGHTRED, "Wiadomoœæ wys³ana do wszystkich prawników, proszê czekaæ.");
			WantLawyer[playerid] = 0;
			CallLawyer[playerid] = 0;
			return 0;
		}
		else
		{
			SendClientMessage(playerid, COLOR_LIGHTRED, "Nie ma ¿adnych prawników ! Musisz odbyæ karê !");
			WantLawyer[playerid] = 0;
			CallLawyer[playerid] = 0;
			return 0;
		}
	}
	
	if(TalkingLive[playerid] != 255)
	{
		GetPlayerNameEx(playerid, sendername, sizeof(sendername));
		if(PlayerInfo[playerid][pJob] == 6)
		{
			ConvertSpecialCharacters(text);
			format(string, sizeof(string), "~w~(Wywiad) %s: ~p~%s", sendername, text);
			ShowNews(string);
		}
		else
		{
			ConvertSpecialCharacters(text);
		  format(string, sizeof(string), "~w~(Wywiad) %s: ~p~%s", sendername, text);
		  ShowNews(string);
		}
		return 0;
	}
	if(Mobile[playerid] != 255)
	{
		new idx;
		tmp = strtok(text, idx);
		GetPlayerNameMask(playerid, sendername, sizeof(sendername));
		//format(string, sizeof(string), "%s Mówi (Telefon): %s", sendername, text);
		//format(string, sizeof(string), "%s mówi (Telefon): %s", sendername, text);
		//ProxDetector(6.5, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);

		GetPlayerNameEx(playerid, sendername, sizeof(sendername));
		//format(string, sizeof(string), "%s mówi (Telefon): %s", sendername, text);

		//printf("callers line %d called %d caller %d",Mobile[Mobile[playerid]],Mobile[playerid],playerid);

		if(strlen(text) > SPLIT_TEXT_LIMIT)
		{
			new stext[128];
            if(PlayerInfo[playerid][pSex] == 1)//Mê¿czyzna
            {
				strmid(stext, text, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
				format(string, sizeof(string), "%s mówi (Telefon, mê¿czyzna): %s...", sendername, stext);
				ProxDetector(6.5, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);

				strmid(stext, text, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
				format(string, sizeof(string), "%s mówi (Telefon, mê¿czyzna): ...%s", sendername, stext);
				ProxDetector(6.5, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
			}
			else if(PlayerInfo[playerid][pSex] == 2)//Kobieta
			{
			    strmid(stext, text, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
				format(string, sizeof(string), "%s mówi (Telefon, kobieta): %s...", sendername, stext);
				ProxDetector(6.5, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);

				strmid(stext, text, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
				format(string, sizeof(string), "%s mówi (Telefon, kobieta): ...%s", sendername, stext);
				ProxDetector(6.5, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
			}
			
		}
		else
		{
            if(PlayerInfo[playerid][pSex] == 1)
            {
					format(string, sizeof(string), "%s mówi (Telefon, mê¿czyzna): %s", sendername, text);
					ProxDetector(6.5, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
			}
			else if(PlayerInfo[playerid][pSex] == 2)
			{
			        format(string, sizeof(string), "%s mówi (Telefon, kobieta): %s", sendername, text);
					ProxDetector(6.5, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
			}
		}
		
		if(Mobile[playerid] == 966)
		{
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, TEAM_CYAN_COLOR, "Telefonistka: Proszê wyraŸniej! Nie zrozumia³am!");
				return 0;
			}

			new badguy = ReturnUser(tmp);

			if (IsPlayerConnected(badguy))
			{
				if(badguy != INVALID_PLAYER_ID)
				{
					if (badguy == playerid)
					{
						SendClientMessage(playerid, COLOR_DBLUE, "Telefonistka: Szukasz swojego numeru? Nie wyg³upiaj siê !");
						SendClientMessage(playerid, COLOR_DBLUE, "Telefonistka: Pamiêtaj, ¿e wszystkie rozmowy s¹ nagrywane.");
						SendClientMessage(playerid, COLOR_GRAD2, "   Roz³¹czyli siê...");
						SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
          			    RemovePlayerAttachedObject(playerid, 4);
						NotPlayersMobile[playerid] = 0;
						Mobile[playerid] = 255;
						return 0;
					}

					new gpitemindex = GetUsedItemByItemId(badguy, ITEM_CELLPHONE);
					new gpphonenumber = gpitemindex == -1 ? 0 : Items[gpitemindex][iAttr1];
					
					if(gpphonenumber == 0)
					{
						SendClientMessage(playerid, COLOR_DBLUE, "Telefonistka: Przykro mi, nie posiadamy danych tej osoby.");
						SendClientMessage(playerid, COLOR_GRAD2, "   Roz³¹czyli siê...");
						SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
            			RemovePlayerAttachedObject(playerid, 4);
						Mobile[playerid] = 255;
						NotPlayersMobile[playerid] = 0;
						return 0;
					}
					
					format(string, sizeof(string), "Telefonistka: Numer telefonu tej osoby to %d.", gpphonenumber);
					SendClientMessage(playerid, COLOR_DBLUE, string);
					SendClientMessage(playerid, COLOR_GRAD2, "   Roz³¹czyli siê...");
					SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
                    RemovePlayerAttachedObject(playerid, 4);
					Mobile[playerid] = 255;
					NotPlayersMobile[playerid] = 0;
					return 0;
				}
				return 0;
			}
			else
			{
				format(string, sizeof(string), "Telefonistka: Nie mam inforamcji o %s, jesteœ pewny ¿e to poprawne imiê?",tmp);
				SendClientMessage(playerid, COLOR_DBLUE, string);
				return 0;
			}
		}

		if(Mobile[playerid] == 914)
		{
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, TEAM_CYAN_COLOR, "Centrala: Proszê wyraŸniej! Nie zrozumia³am !");
				return 0;
			}
			new turner[MAX_PLAYER_NAME];
			new wanted[128];
			GetPlayerName(playerid, turner, sizeof(turner));
			SendClientMessage(playerid, TEAM_CYAN_COLOR, "Centrala: Informacja przekazana do patroli.");
			SendClientMessage(playerid, TEAM_CYAN_COLOR, "Dziêkujemy za zg³oszenie");
			format(wanted, sizeof(wanted), "Centrala: Uwaga - wszystkie oddzia³y. Dzwoni¹cy: %s",turner);
			SendRadioMessage(4, TEAM_CYAN_COLOR, wanted);
			format(wanted, sizeof(wanted), "Centrala: Wypadek: %s",text);
			SendRadioMessage(4, TEAM_CYAN_COLOR, wanted);
			SendClientMessage(playerid, COLOR_GRAD2, "   Rozmowa zakoñczona...");
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
            RemovePlayerAttachedObject(playerid, 4);
			Mobile[playerid] = 255;
			NotPlayersMobile[playerid] = 0;
			return 0;
		}

		if(Mobile[playerid] == 913)
		{
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_ALLDEPT, "Centrala: Przepraszam, nie rozumiem");
				return 0;
			}
			
			strmid(PlayerCrime[playerid][pPlace], text, 0, strlen(text), 255);
			
			new turner[MAX_PLAYER_NAME];
			new wanted[128];
			GetPlayerName(playerid, turner, sizeof(turner));
			SendClientMessage(playerid, COLOR_DBLUE, "Centrala: Zawiadomiliœmy wszystkie jednostki.");
			SendClientMessage(playerid, COLOR_DBLUE, "Dziêkujemy za zg³oszenie przestêpstwa");
			format(wanted, sizeof(wanted), "Centrala: Do wszystkich jednostek: Dostaliœmy informacje o przestêpstwie!");
			SendFamilyMessage(1, COLOR_DBLUE, wanted);
			format(wanted, sizeof(wanted), "Centrala: Opis: %s", PlayerCrime[playerid][pAccusing]);
			SendFamilyMessage(1, COLOR_DBLUE, wanted);
			format(wanted, sizeof(wanted), "Centrala: Miejsce: %s, Zg³osi³: %s",PlayerCrime[playerid][pPlace], turner);
			SendFamilyMessage(1, COLOR_DBLUE, wanted);
			SendClientMessage(playerid, COLOR_GRAD2, "   Roz³¹czyli siê...");
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
            RemovePlayerAttachedObject(playerid, 4);
			Mobile[playerid] = 255;
			NotPlayersMobile[playerid] = 0;
		 return 0;
		}
			
		if(Mobile[playerid] == 915)
		{
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, TEAM_CYAN_COLOR, "Centrala: Proszê wyraŸniej! Nie zrozumia³am !");
				return 0;
			}
			new turner[MAX_PLAYER_NAME];
			new wanted[128];
			GetPlayerName(playerid, turner, sizeof(turner));
			SendClientMessage(playerid, TEAM_CYAN_COLOR, "Centrala: Informacja przekazana do dy¿urnego.");
			SendClientMessage(playerid, TEAM_CYAN_COLOR, "Dziêkujemy za zg³oszenie");
			format(wanted, sizeof(wanted), "Centrala: Uwaga - wszystkie oddzia³y. Dzwoni¹cy: %s",turner);
			SendRadioMessage(18, TEAM_CYAN_COLOR, wanted);
			format(wanted, sizeof(wanted), "Centrala: Zdarzenie: %s",text);
			SendRadioMessage(18, TEAM_CYAN_COLOR, wanted);
			SendClientMessage(playerid, COLOR_GRAD2, "   Rozmowa zakoñczona...");
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
            RemovePlayerAttachedObject(playerid, 4);
			Mobile[playerid] = 255;
			NotPlayersMobile[playerid] = 0;
			return 0;
		}
        if(Mobile[playerid] == 556)
		{
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, TEAM_CYAN_COLOR, "VIBE: Proszê wyraŸniej! Nie zrozumia³am !");
				return 0;
			}
			new turner[MAX_PLAYER_NAME];
			new wanted[128];
			GetPlayerName(playerid, turner, sizeof(turner));
			SendClientMessage(playerid, TEAM_CYAN_COLOR, "VIBE: Informacja przekazana do prezentera.");
			SendClientMessage(playerid, TEAM_CYAN_COLOR, "Dziêkujemy za udzia³ w konkursie.");
			if(OnDuty[playerid] == 1)
			{
			format(wanted, sizeof(wanted), "VIBE: Konkurs, dzwoni¹cy: %s",turner);
			SendRadioMessage(9, TEAM_CYAN_COLOR, wanted);
			format(wanted, sizeof(wanted), "VIBE: OdpowiedŸ: %s",text);
			SendRadioMessage(9, TEAM_CYAN_COLOR, wanted);
			}
			SendClientMessage(playerid, COLOR_GRAD2, "   Rozmowa zakoñczona...");
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
            RemovePlayerAttachedObject(playerid, 4);
			Mobile[playerid] = 255;
			NotPlayersMobile[playerid] = 0;
			return 0;
		}
		if(Mobile[playerid] == 912)
		{
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_ALLDEPT, "Centrala: Przepraszam, nie rozumiem");
				return 0;
			}
			strmid(PlayerCrime[playerid][pAccusing], text, 0, strlen(text), 255);
			SendClientMessage(playerid, COLOR_DBLUE, "Centrala: Podaj miejsce swojego po³o¿enia.");
			Mobile[playerid] = 913;
			return 0;
		}
		if(Mobile[playerid] == 911)
		{
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_ALLDEPT, "Centrala: Przepraszam, nie rozumiem policja, pogotowie czy straz pozarna?");
				return 0;
			}
			else if ((strcmp("policja", tmp, true, strlen(tmp)) == 0) && (strlen(tmp) == strlen("policja")))
			{
				SendClientMessage(playerid, COLOR_ALLDEPT, "Centrala: Trwa ³¹czenie, proszê czekaæ.");
				Mobile[playerid] = 912;
				SendClientMessage(playerid, COLOR_DBLUE, "Centrala: Napisz krótki opis przestêpstwa.");
				return 0;
			}
			else if ((strcmp("pogotowie", tmp, true, strlen(tmp)) == 0) && (strlen(tmp) == strlen("pogotowie")))
			{
				SendClientMessage(playerid, COLOR_ALLDEPT, "Centrala: Trwa ³¹czenie, proszê czekaæ.");
				Mobile[playerid] = 914;
				SendClientMessage(playerid, TEAM_CYAN_COLOR, "Centrala: Podaj krótki opis wypadku i opisz miejsce jego zdarzenia.");
				return 0;
			}
			else if ((strcmp("straz", tmp, true, strlen(tmp)) == 0) && (strlen(tmp) == strlen("straz")))
			{
				SendClientMessage(playerid, COLOR_ALLDEPT, "Centrala: Trwa ³¹czenie, proszê czekaæ.");
				Mobile[playerid] = 915;
				SendClientMessage(playerid, TEAM_CYAN_COLOR, "Centrala: Wpisz krótki opis zdarzenia.");
				return 0;
			}
			else
			{
				SendClientMessage(playerid, COLOR_ALLDEPT, "Centrala: Przepraszam, nie rozumiem policja, pogotowie czy straz pozarna?");
				return 0;
			}
		}
		if(Mobile[playerid] == 555)
		{
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, COLOR_ALLDEPT, "Centrala: Przepraszam, nie rozumiem policja, pogotowie czy straz pozarna?");
				return 0;
			}
			else if ((strcmp("konkurs", tmp, true, strlen(tmp)) == 0) && (strlen(tmp) == strlen("Konkurs")))
			{
				SendClientMessage(playerid, COLOR_ALLDEPT, "VIBE: Trwa ³¹czenie, proszê czekaæ.");
				Mobile[playerid] = 556;
				SendClientMessage(playerid, COLOR_DBLUE, "VIBE-Konkurs: Prosimy podaæ odpowiedŸ na konkursowe pytanie.");
				return 0;
			}
			else
			{
				SendClientMessage(playerid, COLOR_ALLDEPT, "VIBE: Przepraszam, nie rozumiem.");
				return 0;
			}
		}
		if(IsPlayerConnected(Mobile[playerid]))
		{
			if(Mobile[Mobile[playerid]] == playerid)
			{
				if(PlayerInfo[playerid][pWounded] > 0)
				{
					SendClientMessage(playerid, COLOR_GRAD1, "Jesteœ nieprzytomny, nie mo¿esz siê odezwaæ.");
					return 0;
				}
				
				new string2[128];

				new gpitemindex = GetUsedItemByItemId(playerid, ITEM_CELLPHONE);
				new gpphonenumber = gpitemindex == -1 ? 0 : Items[gpitemindex][iAttr1];

				if (strlen(text) > SPLIT_TEXT_LIMIT)
				{
				  new stext[128];
				  
					if(PlayerInfo[playerid][pSex] == 1)//Mê¿czyzna
            		{
						strmid(stext, text, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
						format(string2, sizeof(string), "%d Mówi (Telefon, mê¿czyzna): %s...",gpphonenumber, stext);
						SendClientMessage(Mobile[playerid], COLOR_YELLOW, string2);

						strmid(stext, text, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
						format(string2, sizeof(string), "%d Mówi (Telefon, mê¿czyzna): %s",gpphonenumber, stext);
						SendClientMessage(Mobile[playerid], COLOR_YELLOW, string2);
					}
					else if(PlayerInfo[playerid][pSex] == 2)//Kobieta
					{
			    		strmid(stext, text, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
						format(string2, sizeof(string), "%d Mówi (Telefon, kobieta): %s...",gpphonenumber, stext);
						SendClientMessage(Mobile[playerid], COLOR_YELLOW, string2);

						strmid(stext, text, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
						format(string2, sizeof(string), "%d Mówi (Telefon, kobieta): %s",gpphonenumber, stext);
						SendClientMessage(Mobile[playerid], COLOR_YELLOW, string2);
					}
				
				}
				else
				{
				  	if(PlayerInfo[playerid][pSex] == 1)
            		{
						format(string2, sizeof(string2), "%d Mówi (Telefon, mê¿czyzna): %s", gpphonenumber, text);
				  		SendClientMessage(Mobile[playerid], COLOR_YELLOW, string2);
					}
					else if(PlayerInfo[playerid][pSex] == 2)
					{
			        	format(string2, sizeof(string2), "%d Mówi (Telefon, kobieta): %s", gpphonenumber, text);
				  		SendClientMessage(Mobile[playerid], COLOR_YELLOW, string2);
					}
				}
			}
		}
		else
		{
			SendClientMessage(playerid, COLOR_YELLOW,"Nikogo tu nie ma");
		}
		
		return 0;
	}
  if(gPlayerLogged[playerid] == 0)
  {
		return 0;
 	}
 	if(PlayerInfo[playerid][pWounded] > 0)
 	{
		SendClientMessage(playerid, COLOR_GRAD1, "Jesteœ nieprzytomny, nie mo¿esz siê odezwaæ.");
		return 0;
 	}
 	
	GetPlayerNameMask(playerid, sendername, sizeof(sendername));

	ucfirst(text);

	if(strlen(text) > SPLIT_TEXT_LIMIT)
	{
		new stext[128];

		strmid(stext, text, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
		format(string, sizeof(string), "%s mówi: %s...", sendername, stext);
		ProxDetector(6.5, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);

		strmid(stext, text, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
		format(string, sizeof(string), "%s mówi: ...%s", sendername, stext);
		ProxDetector(6.5, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
	}
	else
	{
		format(string, sizeof(string), "%s mówi: %s", sendername, text);
		ProxDetector(6.5, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
	}

	if(PlayerInfo[playerid][pNeedMedicTime] == 0)
	{
      if(Injured[playerid] == 0)
	  {
		ChatAnim(playerid, strlen(text));
	  }
	}

	return 0;
}

public SetCamBack(playerid)
{
    if(IsPlayerConnected(playerid))
    {
		new Float:plocx,Float:plocy,Float:plocz;
		GetPlayerPos(playerid, plocx, plocy, plocz);
		SetPlayerPosEx(playerid, -1863.15, -21.6598, 1060.15); // Warp the player
		SetPlayerInterior(playerid,14);
	}
}

public FixHour(hour)
{
	hour = timeshift+hour;
	if (hour < 0)
	{
		hour = hour+24;
	}
	else if (hour > 23)
	{
		hour = hour-24;
	}
	shifthour = hour;
	return 1;
}


/**
 * Funkcja do sprawdzania czy gracz znajduje siê w okreœlonym polu
 * @return bool
 */
stock IsPlayerInArea(playerid, Float:x1, Float:y1, Float:x2, Float:y2)
{
	if(IsPlayerConnected(playerid))
 {
		new Float:X, Float:Y, Float:Z;
		GetPlayerPos(playerid, X, Y, Z);
		if(X >= x1 && X <= x2 && Y >= y1 && Y <= y2) return 1;
	}
	return 0;
}

forward IsVehicleInArea(vehicleid, Float:x1, Float:y1, Float:x2, Float:y2);
public IsVehicleInArea(vehicleid, Float:x1, Float:y1, Float:x2, Float:y2)
{
	if(IsPlayerConnected(vehicleid))
 {
		new Float:X, Float:Y, Float:Z;
		GetVehiclePos(vehicleid, X, Y, Z);
		if(X >= x1 && X <= x2 && Y >= y1 && Y <= y2) return 1;
	}
	return 0;
}


/**
 * Funkcja na Tow Trucka START
 */

public TowPlayerVehicle(playerid)
{
	new vehiclet;
	if(IsPlayerInAnyVehicle(playerid))
	{
		new vehid = GetPlayerVehicleID(playerid);
		if(!IsTrailerAttachedToVehicle(vehid))
		{
			if(GetVehicleModel(vehid) == 525)
			{
				new Float:x, Float:y, Float:z;
				GetVehiclePos(vehid, x, y, z );
				GetVehicleWithinDistance(playerid, x, y, z, 100.0, vehiclet);
		
    if(IsPlayerInFrontOfVehicle(playerid,vehiclet))
		  {
					AttachTrailerToVehicle(vehiclet, vehid);
				}
			}
		}
	}
}

GetVehicleWithinDistance( playerid, Float:x1, Float:y1, Float:z1, Float:dist, &vehic){
	for(new i = 1; i < MAX_VEHICLES; i++){
		if(GetVehicleModel(i) > 0){
			if(GetPlayerVehicleID(playerid) != i ){
	        	new Float:x, Float:y, Float:z;
	        	new Float:x2, Float:y2, Float:z2;
				GetVehiclePos(i, x, y, z);
				x2 = x1 - x; y2 = y1 - y; z2 = z1 - z;
				new Float:iDist = (x2*x2+y2*y2+z2*z2);

				if( iDist < dist){
					vehic = i;
				}
			}
		}
	}
}

stock charfind(string[],character)
{
	for(new i; i < strlen(string); i++)
	{
	  if(string[i] == character) return i;
	}
	return -1;
}

public CreateATM(id, Float:x, Float:y, Float:z, Float:rot)
{
 //CreateObject(2942, x, y, z, 0, 0, Float:rot);
 CreateDynamicObject(2942, x, y, z, 0, 0, Float:rot, 0, 0, -1, 200.0);

 gAtm[id][pX]         = x;
 gAtm[id][pY]         = y;
 gAtm[id][pZ]         = z;
 gAtm[id][atmAmount]  = ATM_MONEY;

 //Minimap_AddIcon(52,x,y,z);   // ikonka
}

public loadMoneyToAtm(playerid)
{
 TogglePlayerControllable(playerid, 0);
 GameTextForPlayer(playerid,"~w~~n~~n~~n~~n~~n~~n~~n~~n~~n~Ladowanie pieniedzy do bankomatu, prosze czekac",5000,3);
 SetTimerEx("finishLoadMoney",5000,0,"d",playerid);
}

public finishLoadMoney(playerid)
{
 new string[64];
 for(new j = 0; j < sizeof(gAtm); j++)
	{
	 if(PlayerToPoint(60.0, playerid, gAtm[j][pX], gAtm[j][pY], gAtm[j][pZ]))
	 {
		 new diff           = ATM_MONEY - gAtm[j][atmAmount];
		 gAtm[j][atmAmount] = ATM_MONEY;
		
		 format(string, sizeof(string), "Za³adowa³eœ pieni¹dze do bankomatu ($%d)", diff);
	  SendClientMessage(playerid, COLOR_YELLOW, string);
	 }
	}	
 TogglePlayerControllable(playerid, 1);
}

public unfreeze(playerid)
{
 TogglePlayerControllable(playerid, 1);
}

public loadMoneyToConvoy(playerid)
{
 TogglePlayerControllable(playerid, 0);
 GameTextForPlayer(playerid,"~w~~n~~n~~n~~n~~n~~n~~n~~n~~n~Ladowanie pieniedzy do konwoju, prosze czekac",7000,3);
 SetTimerEx("unfreeze",7000,0,"d",playerid);
}

/**
 * blokujemy tpm
 */
public OnPlayerTeamPrivmsg(playerid, teamid, text[])
{
 SendClientMessage(playerid, COLOR_GRAD2, "   TPM zosta³o zablokowane!");
 return 0;
}

public KillAni(playerid)
{
 OnePlayAnim(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
}

/**
 * callback do klawiatury
 */
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
	{
		#if PPM
		if(IsKeyJustDown(KEY_HANDBRAKE,newkeys,oldkeys))
		{
		  /*new Float:x, Float:y, Float:z;
			GetPlayerPos(playerid, x, y, z);
			SetPlayerPosEx(playerid, x, y, z);
             if(GetPlayerAnimationIndex(playerid))
             {
            	new animlib[32],animname[32];
                GetAnimationName(GetPlayerAnimationIndex(playerid),animlib,32,animname,32);
                if(strcmp(animname, "crckidle1", true) == 0)*/
                if(Injured[playerid] == 1)
                {
    			}
		        else
	            {
		             StopLoopingAnim(playerid);
		             return 1;
		        }
        }
		#endif
		if(IsKeyJustDown(KEY_FIRE,newkeys,oldkeys))
		{
			if(PlayerInfo[playerid][pWounded] > 0) ApplyAnimationWounded(playerid);
		}	
		
		if (GetPlayerWeapon(playerid)==41)// vehicle respray
		{
			if ((newkeys & KEY_FIRE) == KEY_FIRE && !(oldkeys & KEY_FIRE))//press
			{
			  OnPlayerStartUsingSpray(playerid);
			}
			else if (!(newkeys & KEY_FIRE) && (oldkeys & KEY_FIRE) == KEY_FIRE)
			{
				OnPlayerEndUsingSpray(playerid);			
			}
			
		}
	}

	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		if(newkeys == KEY_FIRE)
		{
			// holowanie
			if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 525)
			{
				TowPlayerVehicle(playerid);
			}
		}

		if(newkeys == KEY_SECONDARY_ATTACK)
		{
			if(NoFuel[playerid] == 1)
			{
				TogglePlayerControllable(playerid, 1);
				RemovePlayerFromVehicle(playerid);
				NoFuel[playerid] = 0;
			}
		}
	}
	#if Skills_Weapons_All
	if(GetPlayerWeapon(playerid) == 22) //wax
    {
       if(HOLDING (KEY_HANDBRAKE))
       {
                new level = PlayerInfo[playerid][pColtSkill];
				if(level >= 0 && level <= 2)
				{
					SetPlayerDrunkLevel(playerid, 4999);
				}
				else if(level >= 4 && level <= 5)
				{
					SetPlayerDrunkLevel(playerid, 3500);
				}
				else if(level >= 6 && level <= 7)
				{
					SetPlayerDrunkLevel(playerid, 3000);
				}
				else if(level >= 8 && level <= 9)
				{
					SetPlayerDrunkLevel(playerid, 2050);
				}
				else if(level >= 10)
				{
					SetPlayerDrunkLevel(playerid, 0);
				}
       }
       else if(oldkeys - newkeys == KEY_HANDBRAKE)
       {
         SetPlayerDrunkLevel(playerid, 0);
       }
     return 1;
    }
    #endif
	if(GetPlayerSpecialAction(playerid) == 20 || GetPlayerSpecialAction(playerid) == 22)
	{
		if(newkeys & KEY_FIRE)
		{
			SetPlayerDrunkLevel(playerid, CalculatePlayerDrunkLevel(playerid));
		}
	}
	
	if(newkeys == 8192)
	{
		if(PlayerInfo[playerid][pMember] == 13 || PlayerInfo[playerid][pLeader] == 13)
		{
			if(IsPlayerInAnyVehicle(playerid) == 1)
	    	{
           		new car = GetPlayerVehicleID(playerid);
		   		new param[7];
		   		GetVehicleParamsEx(car,param[0],param[1],param[2],param[3],param[4],param[5],param[6]);
		   			if(Police[car][Use] == false)
	   				{
		       			 if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 415) //cheetah
		           		 {
		        			Police[car][Use]           = true;
		        			Police[car][Siren]         = CreateObject(18646,0.0,0.0,0.0,0.0,0.0,0.0,0.0);
		        			Police[car][Timer]         = SetTimerEx("OnPoliceSiren",200,1,"d",car);
		        			AttachObjectToVehicle(Police[car][Siren],car,-0.4,-0.2,0.6,0.0,0.0,0.0);
		        			SetVehicleParamsEx(car,1,param[1],param[2],param[3],param[4],param[5],param[5]);
     					 }

        			     if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 411) // infernus
		            	 {
		        			Police[car][Use]           = true;
		        			Police[car][Siren]         = CreateObject(18646,0.0,0.0,0.0,0.0,0.0,0.0,0.0);
      	    				Police[car][Timer]         = SetTimerEx("OnPoliceSiren",200,1,"d",car);
		        			AttachObjectToVehicle(Police[car][Siren],car,-0.4,0.0,0.7,0.0,0.0,0.0);
		        			SetVehicleParamsEx(car,1,param[1],param[2],param[3],param[4],param[5],param[5]);
		        		 }

		       		 	if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 426) // premier
		            	{
		        			Police[car][Use]           = true;
		        			Police[car][Siren]         = CreateObject(18646,0.0,0.0,0.0,0.0,0.0,0.0,0.0);
      	    				Police[car][Timer]         = SetTimerEx("OnPoliceSiren",200,1,"d",car);
		        			AttachObjectToVehicle(Police[car][Siren],car,-0.4,0.0,0.9,0.0,0.0,0.0);
		        			SetVehicleParamsEx(car,1,param[1],param[2],param[3],param[4],param[5],param[5]);
        		  		}

		        		if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 428) // securitycar
		            	{
		        			Police[car][Use]           = true;
		        			Police[car][Siren]         = CreateObject(18646,0.0,0.0,0.0,0.0,0.0,0.0,0.0);
      	    				Police[car][Timer]         = SetTimerEx("OnPoliceSiren",200,1,"d",car);
		        			AttachObjectToVehicle(Police[car][Siren],car,-1.0,0.7,1.38,0.0,0.0,0.0);
		        			SetVehicleParamsEx(car,1,param[1],param[2],param[3],param[4],param[5],param[5]);
		        		}

		        		if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 451) // turismo
          				{
		        			Police[car][Use]           = true;
		        			Police[car][Siren]         = CreateObject(18646,0.0,0.0,0.0,0.0,0.0,0.0,0.0);
      	    				Police[car][Timer]         = SetTimerEx("OnPoliceSiren",200,1,"d",car);
		        			AttachObjectToVehicle(Police[car][Siren],car,-0.4,-0.2,0.6,0.0,0.0,0.0);
		        			SetVehicleParamsEx(car,1,param[1],param[2],param[3],param[4],param[5],param[5]);
		        		}

          				if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 482) // buritto
		            	{
		        			Police[car][Use]           = true;
		        			Police[car][Siren]         = CreateObject(18646,0.0,0.0,0.0,0.0,0.0,0.0,0.0);
      	    				Police[car][Timer]         = SetTimerEx("OnPoliceSiren",200,1,"d",car);
           					AttachObjectToVehicle(Police[car][Siren],car,-0.5,0.7,0.94,0.0,0.0,0.0);
		        			SetVehicleParamsEx(car,1,param[1],param[2],param[3],param[4],param[5],param[5]);
		        		}

            			if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 525) // holownik
		            	{
		        			Police[car][Use]           = true;
		        			Police[car][Siren]         = CreateObject(18646,0.0,0.0,0.0,0.0,0.0,0.0,0.0);
      	    				Police[car][Timer]         = SetTimerEx("OnPoliceSiren",200,1,"d",car);
		        			AttachObjectToVehicle(Police[car][Siren],car,-0.5,0.5,1.44,0.0,0.0,0.0);
		        			SetVehicleParamsEx(car,1,param[1],param[2],param[3],param[4],param[5],param[5]);
		        		}

                		if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 560) // sultan
		            	{
		        			Police[car][Use]           = true;
		        			Police[car][Siren]         = CreateObject(18646,0.0,0.0,0.0,0.0,0.0,0.0,0.0);
      	    				Police[car][Timer]         = SetTimerEx("OnPoliceSiren",200,1,"d",car);
		        			AttachObjectToVehicle(Police[car][Siren],car,-0.4,0.0,0.87,0.0,0.0,0.0);
		        			SetVehicleParamsEx(car,1,param[1],param[2],param[3],param[4],param[5],param[5]);
		        		}

                	if(GetVehicleModel(GetPlayerVehicleID(playerid)) != 525 && GetVehicleModel(GetPlayerVehicleID(playerid)) != 482 && GetVehicleModel(GetPlayerVehicleID(playerid)) != 451 && GetVehicleModel(GetPlayerVehicleID(playerid)) != 428 && GetVehicleModel(GetPlayerVehicleID(playerid)) != 426 && GetVehicleModel(GetPlayerVehicleID(playerid)) != 415 && GetVehicleModel(GetPlayerVehicleID(playerid)) != 411 && GetVehicleModel(GetPlayerVehicleID(playerid)) != 560) // ró¿ne od
		            {
		        		SendClientMessage(playerid, COLOR_GREY, "Syreny nie przystosowane do tego pojazdu!");
		        	}

		    }
		    else if(Police[car][Use] == true)
		    {
			    Police[car][Use] = false;
			    AttachObjectToVehicle(Police[car][Siren],0,0.0,0.0,0.0,0.0,0.0,0.0);
			    AttachObjectToVehicle(Police[car][ObjectID],0,0.0,0.0,0.0,0.0,0.0,0.0);
			    KillTimer(Police[car][Timer]);
			    DestroyObject(Police[car][Siren]);
	    	}
		}
	}
 }
 return 0;
}

public IsInvalidSkin(skinid)
{
	#define	MAX_BAD_SKINS   14

	new badSkins[MAX_BAD_SKINS] = {
		3, 4, 5, 6, 8, 42, 65, 74, 86,
		119, 149, 208, 273, 289
	};

	for (new i = 0; i < MAX_BAD_SKINS; i++) {
	    if (skinid == badSkins[i]) return true;
	}

	return false;
}

#if 0
public ShockTimer()
{
 for(new i = 0; i < MAX_PLAYERS; i++)
 {
  if(IsPlayerConnected(i))
  {
   #if TIKI_EVENT
   if(tikiEvent == 1 && PlayerInfo[i][pConnectTime] >= 30 && (PlayerInfo[i][pAdmin] == 0 || PlayerInfo[i][pId] == 1 || PlayerInfo[i][pId] == 6))
   {
    if(PlayerToPoint(25.0, i, -2542.7837,1214.4309,37.4219) && PlayerInfo[i][pTiki] == 0)
    {
     PlayerInfo[i][pTikiObject] = CreatePlayerObject(i, 1276, -2542.7837,1214.4309,37.4219,0.0,0.0,0.0);
     PlayerInfo[i][pTiki] = 1;
    }
    else if(!PlayerToPoint(25.0, i, -2542.7837,1214.4309,37.4219) && PlayerInfo[i][pTiki] == 1)
    {
     DestroyPlayerObject(i, PlayerInfo[i][pTikiObject]);
     PlayerInfo[i][pTiki] = 0;
    }

    if(PlayerToPoint(2.0, i, -2542.7837,1214.4309,37.4219) && PlayerInfo[i][pTiki] == 1)
    {
     GameTextForPlayer(i, "Wpisz ~g~/glowafaraona~w~ aby zakonczyc event", 2500, 1);
    }
   }
   #endif
   if((GetPlayerState(i) == PLAYER_STATE_DRIVER || GetPlayerState(i) == PLAYER_STATE_PASSENGER))
   {
    if(vehHealth[i] == 0.0){}
    else
    {
     new Float:vHP, Float:pHP;
     new veh = GetPlayerVehicleID(i);
     GetVehicleHealth(veh, vHP);

     if(vehHealth[i] - vHP > 0)
     {
      GetPlayerHealth(i, pHP);
      SetPlayerHealthEx(i, pHP - (pHP * ((vehHealth[i] - vHP) * 0.003)));
     }

     vehHealth[i] = vHP;
    }
   }
  }
 }
}
#endif

public BulletKiller(pickupid)
{
 DestroyPickup(pickupid);
}

#if 0
public RobMoney(playerid)
{
 new sendername[MAX_PLAYER_NAME], string[128];
 GivePlayerMoneyEx(playerid, -RobbedMoney[playerid]);
	
 GetPlayerName(playerid, sendername, sizeof(sendername));

 format(string, sizeof(string), "* %s zauwa¿y³, ¿e zniknê³o mu trochê pieniêdzy z kieszeni.", sendername);
 ProxDetector(15.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);

 RobbedMoney[playerid] = 0;
}
#endif

public ChatAnim(playerid, strlen)
{
 if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT || GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)
 {
  if(!IsPlayerBusy(playerid))
  {
   ApplyChatAnimation(playerid, -1, strlen * 100);

	  //SetTimerEx("KillAni", strlen * 100, 0, "d", playerid);
  }
 }
}

stock ApplyChatAnimation(playerid, custom, length=-1)
{
 switch(custom == -1 ? PlayerInfo[playerid][pTalkStyle] : custom)
 {
  case 1:  { ApplyAnimation(playerid, "GANGS", "prtial_gngtlkA", 4.000000, 1, 0, 0, 0, length); }
  case 2:  { ApplyAnimation(playerid, "GANGS", "prtial_gngtlkB", 4.000000, 1, 0, 0, 0, length); }
  case 3:  { ApplyAnimation(playerid, "GANGS", "prtial_gngtlkC", 4.000000, 1, 0, 0, 0, length); }
  case 4:  { ApplyAnimation(playerid, "GANGS", "prtial_gngtlkD", 4.000000, 1, 0, 0, 0, length); }
  case 5:  { ApplyAnimation(playerid, "GANGS", "prtial_gngtlkE", 4.000000, 1, 0, 0, 0, length); }
  case 6:  { ApplyAnimation(playerid, "GANGS", "prtial_gngtlkF", 4.000000, 1, 0, 0, 0, length); }
  case 7:  { ApplyAnimation(playerid, "GANGS", "prtial_gngtlkG", 4.000000, 1, 0, 0, 0, length); }
  case 8:  { ApplyAnimation(playerid, "GANGS", "prtial_gngtlkH", 4.000000, 1, 0, 0, 0, length); }
  default: { ApplyAnimation(playerid, "PED", "IDLE_CHAT", 4.0, 0, 0, 0, 0, length); }
 }

 return 1;
}

stock NextVehicleId()
{
 new numcar=CreateVehicle(490,0,0,0,0,0,0,3000);
 DestroyVehicle(numcar);
 return numcar;
}

public GivePlayerMoneyEx(playerid, money)
{
 PlayerInfo[playerid][pCash] += money;
 ResetPlayerMoney(playerid);
 GivePlayerMoney(playerid, PlayerInfo[playerid][pCash]);
 
  new hour,minuite,second;
	gettime(hour,minuite,second);
 
 if(((hour == 4 && minuite < 10) || hour == 3))
 {
  new query[80];
  format(query, sizeof(query), "UPDATE `auth_game_user_stats` SET `money` = %d WHERE `user_id` = %d",
	PlayerInfo[playerid][pCash], PlayerInfo[playerid][pId]);
  mysql_query(query);
 }
}

forward GivePlayerAccountMoneyEx(playerid, money);
public GivePlayerAccountMoneyEx(playerid, money)
{
 PlayerInfo[playerid][pAccount] += money;
 
  new hour,minuite,second;
	gettime(hour,minuite,second);
 
 if(((hour == 4 && minuite < 10) || hour == 3))
 {
  new query[80];
  format(query, sizeof(query), "UPDATE `auth_game_user_stats` SET `bank` = %d WHERE `user_id` = %d",
	PlayerInfo[playerid][pAccount], PlayerInfo[playerid][pId]);
  mysql_query(query);
 }
}

public GetPlayerMoneyEx(playerid)
{
 return PlayerInfo[playerid][pCash];
}

public SetVehicleParamsForAll(vehicle,objective,doorslocked)
{
 for(new j=0; j<MAX_PLAYERS; j++)
 {
		SetVehicleParamsForPlayer(vehicle,j,objective,doorslocked);
	}
}

/**
 * Funkcja ktora podpina wszystkim graczom
 * dzwiek i wlacza endsound podczas onobjectmoved
 */
public  PlayerPlaySoundForAll_Object(soundid, endsoundid, object, Float:sx, Float:sy, Float:sz)
{
 for(new i = 0; i < MAX_PLAYERS; i++)
 {
  AttachSoundToObject(i, object, endsoundid, sx, sy, sz);
  PlayerPlaySound(i, soundid, sx, sy, sz);
 }
}

/**
 * Funkcja która odgrywa podany Dzwiek dla uzytkownika
 * podczas eventu onobjectmoved dla podanego Object
 */
public  AttachSoundToObject(playerid, object, sound, Float:sx, Float:sy, Float:sz)
{
 PlayerSound[playerid][sObject] = object;
 PlayerSound[playerid][sSound] = sound;
 PlayerSound[playerid][sX] = sx;
 PlayerSound[playerid][sY] = sy;
 PlayerSound[playerid][sZ] = sz;
}

/**
 * Usuwa dzwiek podczas eventu
 */
public  DetachSoundFromPlayer(playerid)
{
 PlayerSound[playerid][sObject] = -1;
 PlayerSound[playerid][sSound]  = 0;
}

/**
 * Callback dla sprejowni
 * EDIT: dla sprejowni callback nie dziala, tylko dla
 * tuningu (tuning -> zmiana koloru)
 */
public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	/*if(Vehicles[vehicleid][vId] != -1)
	{
	 Vehicles[vehicleid][vColor1] = color1;
	 Vehicles[vehicleid][vColor2] = color2;
	}*/
	
	ChangeVehicleColor(vehicleid, Vehicles[vehicleid][vColor1], Vehicles[vehicleid][vColor2]);
	
	return 1;
}

/**
 * Callback
 * glownie dla wyrzucania torby z pieniedzmi z konwoju
 */
public OnVehicleDeath(vehicleid)
{
    new car = vehicleid;
 	new param[7];
  	GetVehicleParamsEx(car,param[0],param[1],param[2],param[3],param[4],param[5],param[6]);
  	
  	if(Police[car][Use] == true)
   	{
    	Police[car][Use] = false;
    	AttachObjectToVehicle(Police[car][Siren],0,0.0,0.0,0.0,0.0,0.0,0.0);
	    AttachObjectToVehicle(Police[car][ObjectID],0,0.0,0.0,0.0,0.0,0.0,0.0);
    	KillTimer(Police[car][Timer]);
    	DestroyObject(Police[car][Siren]);
   	}
   	
 if(GetVehicleModel(vehicleid) == 428)
 {
  if(ConvoyMission > 0)
  {
   new Float:x, Float:y, Float:z;
   DestroyPickup(sackConvoyPickup);
   GetVehiclePos(vehicleid, x, y, z);
   sackConvoyPickup = CreatePickup(1550, 2, x, y, z);
  }
 }

 new string[128];

 if(Vehicles[vehicleid][vId] != -1)
 {
  if(Vehicles[vehicleid][vInsurances] <= 0)
  {
   Vehicles[vehicleid][vInsurances] = 0;

   new ownerid = GetVehicleOwnerID(vehicleid);

   if(ownerid != -1)
   {
    format(string, sizeof(string), "%s (ID: %d) uleg³ zniszczeniu.", GetVehicleName(vehicleid), Vehicles[vehicleid][vId]);
    SendClientMessage(ownerid, COLOR_LORANGE, string);

    format(string, sizeof(string), "Nie posiadasz ¿adnego ubezpieczenia, naprawa pojazdu bêdzie kosztowa³a %d$.", floatround(VehiclesCost[Vehicles[vehicleid][vModel]][vcCost] * 0.8));
    SendClientMessage(ownerid, COLOR_LORANGE, string);
   }

   SetVehicleDestroyed(vehicleid, 1);
   UnSpawnUserVehicle(Vehicles[vehicleid][vOwner], Vehicles[vehicleid][vId]);
  }
  else
  {
	 if(Vehicles[vehicleid][vOwnerType] == CONTENT_TYPE_USER)
	 {
    Vehicles[vehicleid][vInsurances] -= 1;
	 }

   OnVehicleDestroy(vehicleid);
   new ownerid = GetVehicleOwnerID(vehicleid);

   if(ownerid != -1)
   {
    format(string, sizeof(string), "%s (ID: %d) uleg³ zniszczeniu.", GetVehicleName(vehicleid), Vehicles[vehicleid][vId]);
    SendClientMessage(ownerid, COLOR_LORANGE, string);

    SendClientMessage(ownerid, COLOR_GREY, "Pojazd zosta³ automatycznie unspawnowany.");

    format(string, sizeof(string), "Naprawa pojazdu zostanie pokryta z ubezpieczenia. Pozosta³o ci %d ubezpieczeñ.", Vehicles[vehicleid][vInsurances]);
    SendClientMessage(ownerid, COLOR_LORANGE, string);
   }

   if(!(Vehicles[vehicleid][vFlags2] & VEHICLE_DESTROYED))
   {
    Vehicles[vehicleid][vFlags2] += VEHICLE_DESTROYED;
   }
	 
	 new vid = Vehicles[vehicleid][vId];

   UnSpawnVehicle(Vehicles[vehicleid][vId]);
	 
	 if(Vehicles[vehicleid][vOwnerType] != CONTENT_TYPE_USER)
	 {
			SpawnVehicle(vid);
	 }

   /*if(Vehicles[vehicleid][vFlags2] & VEHICLE_DESTROYED)
   {
    Vehicles[vehicleid][vFlags2] += VEHICLE_DESTROYED;
   }

   Vehicles[vehicleid][vTimer] = SetTimerEx("SetVehicleNotDestroyed", 1000, 0, "d", vehicleid);

   SetVehicleToRespawn(vehicleid);*/
  }
 }
}

public  StopConvoyMission()
{
 ConvoyMission = 0;

 for(new i = 0; i < MAX_VEHICLES; i++)
 {
  if(GetVehicleModel(i) == 428)
  {
   SetVehicleToRespawn(i);
	  gLastDriver[i] = 999;
  }
 }
}

public  SetPlayerUnsafe(playerid)
{
 IsPlayerSafe[playerid] = 0;
}

public  SpeedCheck()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			new Float:vx, Float:vy, Float:vz;
			
			if(GetPlayerState(i) == PLAYER_STATE_DRIVER)
			{
				new vehicleindex = GetPlayerVehicleID(i);
				GetVehicleVelocity(vehicleindex, vx, vy, vz);
				
				PlayerSpeed[i] = floatround(floatsqroot(vx * vx + vy * vy + vz * vz) * 161.0);
				
				// paliwo
				if(!IsAirVehicle(vehicleindex) && !IsABoat(vehicleindex) && !IsABike(vehicleindex) && Vehicles[vehicleindex][vId] != -1)
				{
					if(Vehicles[vehicleindex][vFuel] > 0)
					{
						switch(PlayerSpeed[i])
						{
							case  1 .. 50: Vehicles[vehicleindex][vFuel] -= 0.0095;
							case 51 .. 80: Vehicles[vehicleindex][vFuel] -= 0.0084;
							default:
							{
								if(PlayerSpeed[i] > 80) Vehicles[vehicleindex][vFuel] -= 0.0111;
							}
						}

						if(RepairingVehicle[i] == 0 || IsRepairing[i] == 0)
						{
							if(floatround(Vehicles[vehicleindex][vFuel]) != floatround(Gas[vehicleindex]))
							{
								Gas[vehicleindex] = Vehicles[vehicleindex][vFuel];
								UpdatePlayerHud(i);
							}
						}
					}
					else
					{
						Vehicles[vehicleindex][vFuel] = 0.0;
						NoFuel[i] = 1;
						TogglePlayerControllable(i, 0);
						UpdatePlayerHud(i);
					}
				}
			}
			
			// anti airbrake
			GetPlayerPos(i, vx, vy, vz);
			new Float:distance = GetDistanceBetweenPoints(vx,vy,vz,PlayerLastPos[i][0],PlayerLastPos[i][1],PlayerLastPos[i][2]);
	
			GetPlayerVelocity(i, vx, vy, vz);
			new Float:velocity = vx + vy + vz;
	
			new string[128];
			format(string, sizeof(string), "przebyty dystans: %f, velocity: %f, skip?: %d", distance, velocity, 0);
			//SendClientMessage(i, COLOR_WHITE, string);

			PlayerLastPos[i][0] = vx;
			PlayerLastPos[i][1] = vy;
			PlayerLastPos[i][2] = vz;

		}
	}
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
 return 1;
}

public  CheckChatText(cwords[][], text[], cwordsize)
{
 for(new i = 0; i < cwordsize; i++)
 {
  if(strfind(text, cwords[i], true) != -1)
  {
   return 0;
  }
 }
 return 1;
}

forward UnMutePlayer(playerid);
public UnMutePlayer(playerid)
{
	PlayerInfo[playerid][pMuted] = 0;
	return 1;
}

forward SetHadACrashOff(playerid);
public SetHadACrashOff(playerid)
{
	HadACrash[playerid] = 0;
	return 1;
}

public  CheckIsTextIC(playerid, text[])
{
 if(!CheckChatText(disallowedIcWords, text, sizeof(disallowedIcWords)))
 {
  PlayerInfo[playerid][pMuted] = 2; // czasowy mute

  SendClientMessage(playerid, TEAM_CYAN_COLOR, "Zosta³eœ wyciszony na 15 sekund za niedozwolone znaki.");

  KillTimer(UnMuteTimer[playerid]);
  UnMuteTimer[playerid] = SetTimerEx("UnMutePlayer", 15000, 0, "d", playerid);

  return 0;
 }

 return 1;
}

public  ClearConsole(playerid)
{
 for(new i = 0; i < 10; i++)
 {
  SendClientMessage(playerid, COLOR_WHITE, " ");
 }
}

public  SetPlayerMarkerForAll(playerid, color)
{
 for(new i = 0; i < MAX_PLAYERS; i++)
 {
  SetPlayerMarkerForPlayer(i, playerid,0xFF0000FF );
 }
}

public  HidPlayerMarkerForAll(playerid)
{
 for(new i = 0; i < MAX_PLAYERS; i++)
 {
  SetPlayerMarkerForPlayer(i, playerid, 0xFFFFFF00);
 }
}

stock ToggleBlipVisibilty(playerid, bool:visible) {
 new tmpcolor = GetPlayerColor(playerid);
	if(visible == true) tmpcolor &= 0xFFFFFF00;
	else tmpcolor |= 0x000000FF;
	SetPlayerColor(playerid, tmpcolor);
}

public  KillAniForBH(playerid)
{
 //bunnyHopped[playerid] = 0;
 KillAni(playerid);
}

public  MoveObjectRotation(objectid, Float:rx, Float:ry, Float:rz, Float:step, interval, dir)
{
 new Float:tRx, Float:tRy, Float:tRz;
 GetDynamicObjectRot(objectid, tRx, tRy, tRz);

 new bool:xFinished = false;
 new bool:yFinished = false;
 new bool:zFinished = false;

// SetObjectRot(gateParkingPolice, 0, 269.7592, 270);
// MoveObjectRotation(gateParkingPolice, 0, 0, 270, 2.0, 10);

 if(rx > tRx || dir == 1)
 {
  if(tRx + step > rx)
  {
   tRx = rx;
   xFinished = true;
  }
  else
  {
   tRx += step;
  }
 }
 else
 {
  if(tRx - step < rx)
  {
   tRx = rx;
   xFinished = true;
  }
  else
  {
   tRx -= step;
  }
 }

 if(ry > tRy || dir == 1)
 {
  if(tRy + step > ry)
  {
   tRy = ry;
   yFinished = true;
  }
  else
  {
   tRy += step;
  }
 }
 else
 {
  if(tRy - step < ry)
  {
   tRy = ry;
   yFinished = true;
  }
  else
  {
   tRy -= step;
  }
 }

 if(rz > tRz || dir == 1)
 {
  if(tRz + step > rz)
  {
   tRz = rz;
   zFinished = true;
  }
  else
  {
   tRz += step;
  }
 }
 else
 {
  if(tRz - step < rz)
  {
   tRz = rz;
   zFinished = true;
  }
  else
  {
   tRz -= step;
  }
 }

 if(yFinished == true && xFinished == true && zFinished == true){ return 1; }
 else
 {
  SetDynamicObjectRot(objectid, tRx, tRy, tRz);
  SetTimerEx("MoveObjectRotation", interval, 0, "dffffdd", objectid, Float:rx, Float:ry, Float:rz, Float:step, interval, dir);
 }
 return 1;
}

forward GivePlayerWeaponEx2(playerid, weaponid, ammo);
public  GivePlayerWeaponEx2(playerid, weaponid, ammo)
{
 disableAntyCheat[playerid] = 1;

 SetPlayerHasWeapon(playerid, weaponid, ammo);
 GivePlayerWeapon(playerid, weaponid, ammo);

 skipAntyCheat[playerid]    = 1; // fix na bany
 disableAntyCheat[playerid] = 0;
}

forward ResetPlayerWeaponsEx(playerid);
public  ResetPlayerWeaponsEx(playerid)
{
 disableAntyCheat[playerid] = 1;

 ResetPlayerWeapons(playerid);

 PlayerWeapons[playerid][pGun1]    = 0;
 PlayerWeapons[playerid][pAmmo1]   = 0;
 PlayerWeapons[playerid][pGun2]    = 0;
 PlayerWeapons[playerid][pAmmo2]   = 0;
 PlayerWeapons[playerid][pGun3]    = 0;
 PlayerWeapons[playerid][pAmmo3]   = 0;
 PlayerWeapons[playerid][pGun4]    = 0;
 PlayerWeapons[playerid][pAmmo4]   = 0;
 PlayerWeapons[playerid][pGun5]    = 0;
 PlayerWeapons[playerid][pAmmo5]   = 0;
 PlayerWeapons[playerid][pGun6]    = 0;
 PlayerWeapons[playerid][pAmmo6]   = 0;
 PlayerWeapons[playerid][pGun7]    = 0;
 PlayerWeapons[playerid][pAmmo7]   = 0;
 PlayerWeapons[playerid][pGun8]    = 0;
 PlayerWeapons[playerid][pAmmo8]   = 0;
 PlayerWeapons[playerid][pGun9]    = 0;
 PlayerWeapons[playerid][pAmmo9]   = 0;
 PlayerWeapons[playerid][pGun10]   = 0;
 PlayerWeapons[playerid][pAmmo10]  = 0;
 PlayerWeapons[playerid][pGun11]   = 0;
 PlayerWeapons[playerid][pAmmo11]  = 0;
 PlayerWeapons[playerid][pGun12]   = 0;
 PlayerWeapons[playerid][pAmmo12]  = 0;

 skipAntyCheat[playerid]    = 2; // fix na bany
 disableAntyCheat[playerid] = 0;
}

public  GivePlayerWeaponEx(playerid, weaponid, ammo)
{

 disableAntyCheat[playerid] = 1;

 SetPlayerHasWeapon(playerid, weaponid, ammo);
 GivePlayerWeapon(playerid, weaponid, ammo);

 skipAntyCheat[playerid]    = 1; // fix na bany
 disableAntyCheat[playerid] = 0;
}

public  GetWeaponSlot(weapon)
{
 if(weapon >= 0 && weapon <= 1)
 {
  return 0;
 }
 else if(weapon >= 2 && weapon <= 9)
 {
  return 1;
 }
 else if(weapon >= 22 && weapon <= 24)
 {
  return 2;
 }
 else if(weapon >= 25 && weapon <= 27)
 {
  return 3;
 }
 else if((weapon >= 28 && weapon <= 29) || weapon == 32)
 {
  return 4;
 }
 else if(weapon >= 30 && weapon <= 31)
 {
  return 5;
 }
 else if(weapon >= 33 && weapon <= 34)
 {
  return 6;
 }
 else if(weapon >= 35 && weapon <= 38)
 {
  return 7;
 }
 else if((weapon >= 16 && weapon <= 18) || weapon == 39)
 {
  return 8;
 }
 else if(weapon >= 41 && weapon <= 43)
 {
  return 9;
 }
 else if(weapon >= 10 && weapon <= 15)
 {
  return 10;
 }
 else if(weapon >= 44 && weapon <= 46)
 {
  return 11;
 }
 else if(weapon == 40)
 {
  return 12;
 }

 return -1;
}

public  IsVehicleInUse(vehicleid)
{
	for(new i=0; i<MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i) && IsPlayerInVehicle(i, vehicleid) && GetPlayerState(i) == PLAYER_STATE_DRIVER)
		{
		return 1;
		}
	}
	return 0;
}

forward SetPlayerHasWeapon(playerid, weaponid, ammo);
public SetPlayerHasWeapon(playerid, weaponid, ammo)
{
 new slotid = GetWeaponSlot(weaponid);

 if(slotid == 1)
 {
  PlayerWeapons[playerid][pGun1]    = weaponid;
  PlayerWeapons[playerid][pAmmo1]   = ammo;
 }
 else if(slotid == 2)
 {
  PlayerWeapons[playerid][pGun2]    = weaponid;
  PlayerWeapons[playerid][pAmmo2]   = ammo;
 }
 else if(slotid == 3)
 {
  PlayerWeapons[playerid][pGun3]    = weaponid;
  PlayerWeapons[playerid][pAmmo3]   = ammo;
 }
 else if(slotid == 4)
 {
  PlayerWeapons[playerid][pGun4]    = weaponid;
  PlayerWeapons[playerid][pAmmo4]   = ammo;
 }
 else if(slotid == 5)
 {
  PlayerWeapons[playerid][pGun5]    = weaponid;
  PlayerWeapons[playerid][pAmmo5]   = ammo;
 }
 else if(slotid == 6)
 {
  PlayerWeapons[playerid][pGun6]    = weaponid;
  PlayerWeapons[playerid][pAmmo6]   = ammo;
 }
 else if(slotid == 7)
 {
  PlayerWeapons[playerid][pGun7]    = weaponid;
  PlayerWeapons[playerid][pAmmo7]   = ammo;
 }
 else if(slotid == 8)
 {
  PlayerWeapons[playerid][pGun8]    = weaponid;
  PlayerWeapons[playerid][pAmmo8]   = ammo;
 }
 else if(slotid == 9)
 {
  PlayerWeapons[playerid][pGun9]    = weaponid;
  PlayerWeapons[playerid][pAmmo9]   = ammo;
 }
 else if(slotid == 10)
 {
  PlayerWeapons[playerid][pGun10]    = weaponid;
  PlayerWeapons[playerid][pAmmo10]   = ammo;
 }
 else if(slotid == 11)
 {
  PlayerWeapons[playerid][pGun11]    = weaponid;
  PlayerWeapons[playerid][pAmmo11]   = ammo;
 }
 else if(slotid == 12)
 {
  PlayerWeapons[playerid][pGun12]    = weaponid;
  PlayerWeapons[playerid][pAmmo12]   = ammo;
 }
 else
 {
  #if DEBUG
  SendClientMessage(playerid, COLOR_RED, "* Broñ nie zostanie zapisana");
  #endif
 }
}



OnePlayAnim(playerid,animlib[],animname[], Float:Speed, looping, lockx, locky, lockz, lp)

{
 if(!IsPlayerBusy(playerid))
 {
	 ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, lockz, lp);
 }
}

LoopingAnim(playerid,animlib[],animname[], Float:Speed, looping, lockx, locky, lockz, lp)

{
 if(!IsPlayerBusy(playerid))
 {
  gPlayerUsingLoopingAnim[playerid] = 1;
  ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, lockz, lp);

 }
}

StopLoopingAnim(playerid)
{
 if(!IsPlayerBusy(playerid))
 {
	if(GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_NONE && GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DRINK_BEER
		&& GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DRINK_WINE)
	{
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
		return 1;
	}	
 
 	gPlayerUsingLoopingAnim[playerid] = 0;
  ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
 }
 
 return 1;
}

public  SetPlayerSpecialActionEx(playerid,action)
{
 if(!IsPlayerBusy(playerid))
 {
  SetPlayerSpecialAction(playerid,action);
 }
}

forward AutoChangeWeather();
public  AutoChangeWeather()
{
 // obliczamy ilosc alternatyw
 new wCount = 0;
 for(new i = 0; i < 6; i++)
 {
  if(weathers[actWeather][i] > -1)
  {
   wCount++;
  }
 }

 // dobieramy pogodê
 new newWeather = weathers[actWeather][random(wCount)];

 SetWeather(newWeather);
 actWeather = newWeather;

 Config_WriteInt("weather", actWeather);

 for(new i = 0; i < MAX_PLAYERS; i++)
 {
  if(GetPlayerInterior(i) > 0)
  {
   SetPlayerWeather(i, 1);
  }
  else if(GetPlayerVirtualWorld(i) == FAKE_INTERIOR_VW_ID)
  {
   SetPlayerWeather(i, 3);
  }
 }

 AutoChangeWeatherTimer = 1800 + random(900);
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
 if(newinteriorid > 0)
 {
  SetPlayerWeather(playerid, 1);
 }
 else
 {
  SetPlayerWeather(playerid, actWeather);
 }

 if(newinteriorid != oldinteriorid)
 {
  for(new i = 0; i < MAX_PLAYERS; i++)
  {
   if(IsPlayerConnected(i) && Spectate[i] == playerid)
   {
    SetPlayerInterior(i, GetPlayerInterior(playerid));
   }
  }
 }
}

forward ClearPMBlocks(playerid);
public ClearPMBlocks(playerid)
{
 for(new i = 0; i < MAX_PLAYERS; i++) // MAX_PLAYERS = sizeof(BlockedPM[playerid])
 {
  BlockedPM[playerid][i] = 0;
 }
}


forward Float:GetDistanceBetweenPlayers2D(p1, p2);
public  Float:GetDistanceBetweenPlayers2D(p1, p2)
{
 new Float:p1x, Float:p1y, Float:p1z;
 new Float:p2x, Float:p2y, Float:p2z;

 GetPlayerPos(p1, p1x, p1y, p1z);
 GetPlayerPos(p2, p2x, p2y, p2z);

 return GetDistanceBetweenPoints(p1x,p1y,1.0,p2x,p2y,1.0);
}

forward GetRandomPizzaOrder(playerid);
public  GetRandomPizzaOrder(playerid)
{
 new houseId = random(sizeof(HouseInfo));

 SetPlayerCheckpoint(playerid, HouseInfo[houseId][hEntrancex], HouseInfo[houseId][hEntrancey], HouseInfo[houseId][hEntrancez], 1.5);
 gPlayerCheckpointStatus[playerid] = CHECKPOINT_PIZZA;
}

stock strreplace(trg[],newstr[],src[])
{
 new f=0;
 new s1[MAX_STRING];
 new tmp[MAX_STRING];
 format(s1,sizeof(s1),"%s",src);
 f = strfind(s1,trg);
 tmp[0]=0;

 while (f>=0)
 {
  strcat(tmp,ret_memcpy(s1, 0, f));
  strcat(tmp,newstr);
  format(s1,sizeof(s1),"%s",ret_memcpy(s1, f+strlen(trg), strlen(s1)-f));
  f = strfind(s1,trg);
 }

 strcat(tmp,s1);
 return tmp;
}

stock strreplace_simple(from, to, src[])
{
 for(new i = 0; i < strlen(src); i++)
 {
  if(src[i] == from) src[i] = to;
 }
 
 return src;
}

stock ConvertSpecialCharacters(src[])
{
	strreplace_fast('¹', 'a', src)
	strreplace_fast('æ', 'c', src)
	strreplace_fast('ê', 'e', src)
	strreplace_fast('³', 'l', src)
	strreplace_fast('ñ', 'n', src)
	strreplace_fast('ó', 'o', src)
	strreplace_fast('œ', 's', src)
	strreplace_fast('Ÿ', 'z', src)
	strreplace_fast('¿', 'z', src)
	strreplace_fast('¥', 'A', src)
	strreplace_fast('Æ', 'C', src)
	strreplace_fast('Ê', 'E', src)
	strreplace_fast('£', 'L', src)
	strreplace_fast('Ñ', 'N', src)
	strreplace_fast('Ó', 'O', src)
	strreplace_fast('Œ', 'S', src)
	strreplace_fast('', 'Z', src)
	strreplace_fast('¯', 'Z', src)
}

forward GetPlayerNameEx(playerid, name[], len);
public  GetPlayerNameEx(playerid, name[], len)
{
 GetPlayerName(playerid, name, len);
 
 strreplace_fast('_', ' ', name)
 //for(new i = 0; i < strlen(name); i++) { if(name[i] == %1) src[i] = %2; }

 //strmid(name, strreplace_simple('_', ' ', name), 0, MAX_PLAYER_NAME, len);
}

forward GetPlayerNameMask(playerid, name[], len);
public  GetPlayerNameMask(playerid, name[], len)
{
 if(hasMaskOn[playerid] == 1)
 {
  strmid(name, STRANGER_NAME, 0, MAX_PLAYER_NAME, len);
 }
 else
 {
  GetPlayerNameEx(playerid, name, len);
 }
}

ret_memcpy(source[],index=0,numbytes)
{
	new tmp[MAX_STRING];
	new i=0;
	tmp[0]=0;
	if (index>=strlen(source)) return tmp;
	if (numbytes+index>=strlen(source)) numbytes=strlen(source)-index;
	if (numbytes<=0) return tmp;
	for (i=index;i<numbytes+index;i++) {
		tmp[i-index]=source[i];
		if (source[i]==0) return tmp;
	}
	tmp[numbytes]=0;
	return tmp;
}

forward DisallowPizzaBike(playerid);
public DisallowPizzaBike(playerid)
{
 IsAllowedToPizzaBike[playerid] = 0;
}

forward ApplyAnimationHospital(playerid);
public ApplyAnimationHospital(playerid)
{
 ApplyAnimation(playerid, "INT_HOUSE","BED_Loop_L",4.0,1,0,0,1,0);

 return 1;
}

forward ApplyAnimationWounded(playerid);
public ApplyAnimationWounded(playerid)
{
  ApplyAnimation(playerid, "ped", "FLOOR_hit", 4.000000, 0, 1, 1, 1, -1);	
 return 1;
}

stock IntToHex(number)
{
	new m=1;
	new depth=0;
	while (number>=m) {
		m = m*16;
		depth++;
	}
	depth--;
	new str[MAX_STRING];
	for (new i = depth; i >= 0; i--)
	{
		str[i] = ( number & 0x0F) + 0x30; // + (tmp > 9 ? 0x07 : 0x00)
		str[i] += (str[i] > '9') ? 0x07 : 0x00;
		number >>= 4;
	}
	str[8] = '\0';
	return str;
}
/*
stock sscanf(string[], format[], {Float,_}:...)
{
	#if defined isnull
		if (isnull(string))
	#else
		if (string[0] == 0 || (string[0] == 1 && string[1] == 0))
	#endif
		{
			return format[0];
		}

	new
		formatPos = 0,
		stringPos = 0,
		paramPos = 2,
		paramCount = numargs(),
		delim = ' ';
	while (string[stringPos] && string[stringPos] <= ' ')
	{
		stringPos++;
	}
	while (paramPos < paramCount && string[stringPos])
	{
		switch (format[formatPos++])
		{
			case '\0':
			{
				return 0;
			}
			case 'i', 'd':
			{
				new
					neg = 1,
					num = 0,
					ch = string[stringPos];
				if (ch == '-')
				{
					neg = -1;
					ch = string[++stringPos];
				}
				do
				{
					stringPos++;
					if ('0' <= ch <= '9')
					{
						num = (num * 10) + (ch - '0');
					}
					else
					{
						return -1;
					}
				}
				while ((ch = string[stringPos]) > ' ' && ch != delim);
				setarg(paramPos, 0, num * neg);
			}
			case 'h', 'x':
			{
				new
					num = 0,
					ch = string[stringPos];
				do
				{
					stringPos++;
					switch (ch)
					{
						case 'x', 'X':
						{
							num = 0;
							continue;
						}
						case '0' .. '9':
						{
							num = (num << 4) | (ch - '0');
						}
						case 'a' .. 'f':
						{
							num = (num << 4) | (ch - ('a' - 10));
						}
						case 'A' .. 'F':
						{
							num = (num << 4) | (ch - ('A' - 10));
						}
						default:
						{
							return -1;
						}
					}
				}
				while ((ch = string[stringPos]) > ' ' && ch != delim);
				setarg(paramPos, 0, num);
			}
			case 'c':
			{
				setarg(paramPos, 0, string[stringPos++]);
			}
			case 'f':
			{
				setarg(paramPos, 0, _:floatstr(string[stringPos]));
			}
			case 'p':
			{
				delim = format[formatPos++];
				continue;
			}
			case '\'':
			{
				new
					end = formatPos - 1,
					ch;
				while ((ch = format[++end]) && ch != '\'') {}
				if (!ch)
				{
					return -1;
				}
				format[end] = '\0';
				if ((ch = strfind(string, format[formatPos], false, stringPos)) == -1)
				{
					if (format[end + 1])
					{
						return -1;
					}
					return 0;
				}
				format[end] = '\'';
				stringPos = ch + (end - formatPos);
				formatPos = end + 1;
			}
			case 'u':
			{
				new
					end = stringPos - 1,
					id = 0,
					bool:num = true,
					ch;
				while ((ch = string[++end]) && ch != delim)
				{
					if (num)
					{
						if ('0' <= ch <= '9')
						{
							id = (id * 10) + (ch - '0');
						}
						else
						{
							num = false;
						}
					}
				}
				if (num && IsPlayerConnected(id))
				{
					setarg(paramPos, 0, id);
				}
				else
				{
					#if !defined foreach
						#define foreach(%1,%2) for (new %2 = 0; %2 < MAX_PLAYERS; %2++) if (IsPlayerConnected(%2))
						#define __SSCANF_FOREACH__
					#endif
					string[end] = '\0';
					num = false;
					new
						name[MAX_PLAYER_NAME];
					id = end - stringPos;
					foreach (Player, playerid)
					{
						GetPlayerName(playerid, name, sizeof (name));
						if (!strcmp(name, string[stringPos], true, id))
						{
							setarg(paramPos, 0, playerid);
							num = true;
							break;
						}
					}
					if (!num)
					{
						setarg(paramPos, 0, INVALID_PLAYER_ID);
					}
					string[end] = ch;
					#if defined __SSCANF_FOREACH__
						#undef foreach
						#undef __SSCANF_FOREACH__
					#endif
				}
				stringPos = end;
			}
			case 's', 'z':
			{
				new
					i = 0,
					ch;
				if (format[formatPos])
				{
					while ((ch = string[stringPos++]) && ch != delim)
					{
						setarg(paramPos, i++, ch);
					}
					if (!i)
					{
						return -1;
					}
				}
				else
				{
					while ((ch = string[stringPos++]))
					{
						setarg(paramPos, i++, ch);
					}
				}
				stringPos--;
				setarg(paramPos, i, '\0');
			}
			default:
			{
				continue;
			}
		}
		while (string[stringPos] && string[stringPos] != delim && string[stringPos] > ' ')
		{
			stringPos++;
		}
		while (string[stringPos] && (string[stringPos] == delim || string[stringPos] <= ' '))
		{
			stringPos++;
		}
		paramPos++;
	}
	do
	{
		if ((delim = format[formatPos++]) > ' ')
		{
			if (delim == '\'')
			{
				while ((delim = format[formatPos++]) && delim != '\'') {}
			}
			else if (delim != 'z')
			{
				return delim;
			}
		}
	}
	while (delim > ' ');
	return 0;
}
*/
forward IsUnofficialGangMember(playerid);
public  IsUnofficialGangMember(playerid)
{
 new ufid = PlayerInfo[playerid][pUFMember];

 if(PlayerInfo[playerid][pUFLeader] < MAX_UNOFFICIAL_FACTIONS+1)
 {
  ufid = PlayerInfo[playerid][pUFLeader];
 }

	if(ufid < MAX_UNOFFICIAL_FACTIONS+1)
	{
	 if(MiniFaction[ufid][mType] == UFACTION_TYPE_GANG)
	 {
	  return 1;
	 }
 }

 return 0;
}

dcmd_frisk(playerid,params[])
{
 new tmp[24], idx;

 tmp = strtok(params, idx);
	
 if(!strlen(tmp))
	{
		SendClientMessage(playerid, COLOR_WHITE, "U¯YJ: /przeszukaj [IdGracza/CzêœæNazwy]");
		return 1;
	}
		
 new giveplayerid = ReturnUser(tmp);

 if (DistanceBetweenPlayers(8.0, playerid, giveplayerid, true))
	{
	 if(giveplayerid == playerid) { SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz przeszukaæ siebie samego."); return 1; }

	 new giveplayer[MAX_PLAYER_NAME];
		GetPlayerNameMask(giveplayerid, giveplayer, sizeof(giveplayer));
	
	 new string[128];
	
	 format(string, sizeof(string), "przeszuka³ %s.", giveplayer);
	 ServerMe(playerid,string);
	
	 format(string, sizeof(string), "Przedmioty %s (Pieniêdzy przy sobie: $%d):", giveplayer, GetPlayerMoneyEx(giveplayerid));
	 SendClientMessage(playerid, COLOR_LORANGE, string);
  ShowObjectItemsForPlayer(CONTENT_TYPE_USER, PlayerInfo[giveplayerid][pId], playerid, params, idx, "przeszukaj [IdGracza/CzêœæNazwy]");
	}
	else
	{
	 SendClientMessage(playerid, COLOR_WHITE, "Nie ma takiej osoby w pobli¿u.");
	}
	
	return 1;
}

dcmd_stylrozmowy(playerid,params[])
{
 #pragma unused params

 new Float:x, Float:y, Float:z;
 if(IsPlayerInAnyVehicle(playerid))//*Nie mo¿e byæ w pojeŸdzie
 {
   SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz znajdowaæ siê w pojeŸdzie!");
 }
 else
 {
   if(PlayerInfo[playerid][pStatus] == STATUS_SEL_TALKSTYLE)
   {
     SendClientMessage(playerid, COLOR_GRAD2, "Wybierasz aktualnie styl rozmowy.");
	 return 1;
   }

 	PlayerInfo[playerid][pStatus] = STATUS_SEL_TALKSTYLE;
 	SelectTalkStyle[playerid] = PlayerInfo[playerid][pTalkStyle];
 	GetPlayerPos(playerid, x, y, z);

 	SetPlayerCameraLookAt(playerid, x, y, z);
 	GetXYInFrontOfPlayer(playerid, x, y, 3.5);
 	SetPlayerCameraPos(playerid, x, y, z);

 	TogglePlayerControllable(playerid, 0);

 	SendClientMessage(playerid, COLOR_LORANGE, "Znajdujesz siê w trybie wyboru stylu rozmowy.");
 	SendClientMessage(playerid, COLOR_AWHITE, "Aby wybraæ inny styl rozmowy u¿yj strza³ek w prawo lub lewo.");
 	SendClientMessage(playerid, COLOR_AWHITE, "W celu wybrania stylu rozmowy naciœnij klawisz TAB.");

 	TalkStyleSelectTimer[playerid] = SetTimerEx("TalkStyleSelect", 200, 1, "i", playerid);
 }
 return 1;
}

//----------------------------------------------------------------------------------------

dcmd_ignoruj(playerid,params[])
{
 if(IsPlayerConnected(playerid))
 {
  new tmp[24], idx;

  tmp = strtok(params, idx);

  if(!strlen(tmp))
	 {
	 	SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /ignoruj [IdGracza/CzêœæNazwy]");
	 	return 1;
	 }
	
	 new giveplayerid = ReturnUser(tmp);
	
	 if(!IsPlayerConnected(giveplayerid))
	 {
	  SendClientMessage(playerid, COLOR_GRAD2, "Ta osoba jest niedostêpna.");
	 	return 1;
	 }
	
  if(giveplayerid == playerid)
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Nie mo¿esz zablokowaæ samego siebie.");
	 	return 1;
  }
	
	 new playername[MAX_PLAYER_NAME], string[64];
	 GetPlayerNameEx(giveplayerid, playername, sizeof(playername));

	 if(BlockedPM[playerid][giveplayerid] == 1)
	 {
 	 format(string, sizeof(string), "Odblokowa³eœ wiadomoœci od %s.", playername);
	  SendClientMessage(playerid, COLOR_WHITE, string);
	  BlockedPM[playerid][giveplayerid] = 0;
	 }
	 else
	 {
	  format(string, sizeof(string), "Zablokowa³eœ wiadomoœci od %s.", playername);
	  SendClientMessage(playerid, COLOR_WHITE, string);
	  BlockedPM[playerid][giveplayerid] = 1;
	 }
 }

 return 1;
}

dcmd_organizacje(playerid,params[])
{
 if(IsPlayerConnected(playerid))
 {
  new idx, tmp[24], string[230];

  tmp = strtok(params, idx);

  new pActPage = 0;
  new pLimit   = 8;
  new query[312];

	 format(query, sizeof(query), "SELECT * FROM organization_game_unofficial_factions");
  mysql_query(query);
  mysql_store_result();	
  // pobieramy ilosc nieoficjalnych frakcji
  new pRecords = mysql_num_rows();
  mysql_free_result();

  if(pRecords == 0)
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Nie mamy informacji o ¿adnych organizacjach.");
 		return 1;
  }

 	if(strlen(tmp))
 	{
 		pActPage = strval(tmp);

   if(pActPage < 1)
   {
    SendClientMessage(playerid, COLOR_GRAD2, "Niepoprawny numer strony.");
		  return 1;
   }

		 if(pActPage * pLimit > pRecords)
		 {
		  SendClientMessage(playerid, COLOR_GRAD2, "Strona o podanym numerze nie istnieje.");
		  return 1;
		 }
	 }
	  	
	 format(query, sizeof(query), "SELECT f.name, us.username, f.type, (SELECT COUNT(*) FROM auth_game_user_data d, auth_user u WHERE d.ufmember_id = f.id AND u.id = d.user_id AND d.blocked = 0) as `count` FROM organization_game_unofficial_factions f, auth_user us WHERE us.id = f.leader_id ORDER BY f.name ASC LIMIT %d, %d", (pActPage * pLimit), pLimit);
	 mysql_query(query);
	 mysql_store_result();

  new line[90];
  new data[4][64];

  SendClientMessage(playerid, COLOR_LORANGE, "Wykaz nieoficjalnych organizacji");

 	while(mysql_fetch_row_format(line) == 1)
  {
   split(line, data, '|');

   new ttype[30];
   new count = strval(data[3]);
   new type  = strval(data[2]);

	  switch(type)
   {
    case UFACTION_TYPE_GANG:       { ttype = "Organizacja przestêpcza"; }
    case UFACTION_TYPE_COMPANY:    { ttype = "Organizacja prywatna"; }
    default:                       { ttype = "B³¹d"; }
   }
			
   format(string, sizeof(string), "(%s) %s, Lider: %s, Iloœæ cz³onków: %d", ttype, data[0], strreplace("_", " ", data[1]), count);
   SendClientMessage(playerid, COLOR_AWHITE, string);

   print(data[0]);
  }

  mysql_free_result();

  if((pActPage + 1) * pLimit > pRecords)
	 {
   format(string, sizeof(string), "U¯YJ: /organizacje [NrStrony]");
	 }
	 else
	 {
	  format(string, sizeof(string), "U¯YJ: /organizacje [NrStrony] (Nr nastêpnej strony: %d)", (pActPage+1));
	 }

  SendClientMessage(playerid, COLOR_GRAD4, string);
  return 1;
 }

 return 1;
}


dcmd_ukryjnicki(playerid,params[])
{
 #pragma unused params

 if(IsPlayerConnected(playerid))
 {
  	if(PlayerInfo[playerid][pHiddenNametags] == 1)
  	{
   		for(new i = 0; i < MAX_PLAYERS; i++)
   		{
    		if(IsPlayerConnected(i))
    		{
		 		if(hasMaskOn[i] > 0) continue;
     			ShowPlayerNameTagForPlayer(playerid, i, 1);
    		}
   		}
   	PlayerInfo[playerid][pHiddenNametags] = 0;
  }
  else
  {
   	for(new i = 0; i < MAX_PLAYERS; i++)
   	{
    	if(IsPlayerConnected(i))
    	{
     		ShowPlayerNameTagForPlayer(playerid, i, 0);
    	}
   	}
   	PlayerInfo[playerid][pHiddenNametags] = 1;
  }
  return 1;
 }

 return 1;
}

dcmd_maska(playerid,params[])
{
 #pragma unused params

 if(IsPlayerConnected(playerid))
 {
  if(PlayerInfo[playerid][pMask] != 1)
	 {
	  SendClientMessage(playerid, COLOR_GRAD1, "Nie posiadasz maski.");
	  return 1;
	 }
		
  if(hasMaskOn[playerid] == 1)
  {
   	for(new i = 0; i < MAX_PLAYERS; i++)
   	{
    	if(IsPlayerConnected(i))
    	{
			  ShowPlayerNameTagForPlayer(i, playerid, 1);
    	}
   }
   
   GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~y~Sciagnales maske", 1500, 3);
   hasMaskOn[playerid] = 0;
  }
  else
  {
   	for(new i = 0; i < MAX_PLAYERS; i++)
   	{
    	if(IsPlayerConnected(i))
    	{
    		ShowPlayerNameTagForPlayer(i, playerid, 0);
    	}
   	}

   new playername[MAX_PLAYER_NAME];
   GetPlayerNameEx(playerid, playername, sizeof(playername));
   printf("[maska] %s za³o¿y³ maskê.", playername);

   GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~y~Zalozyles maske", 1500, 3);
   hasMaskOn[playerid] = 1;
  }
  return 1;
 }

 return 1;
}

dcmd_chusta(playerid,params[])
{
 #pragma unused params

 if(IsPlayerConnected(playerid))
 {
	if(GetPlayerOrganization(playerid) != 1 && GetPlayerOrganization(playerid) != 14 &&
		GetPlayerOrganization(playerid) != 15 && GetPlayerOrganization(playerid) != 16 && GetPlayerOrganization(playerid) != 19 && GetPlayerOrganization(playerid) != 6)
  {
	 new uforg = GetPlayerUnofficialOrganization(playerid);

	 if(uforg == MAX_UNOFFICIAL_FACTIONS+1 || MiniFaction[uforg][mType] != UFACTION_TYPE_GANG)
	 {
       SendClientMessage(playerid, COLOR_GRAD1, "Nie jesteo uprawniony do uzycia tej komendy!");
       return 1;
	 }
  }
  if(hasMaskOn[playerid] == 2)
  {
   for(new i = 0; i < MAX_PLAYERS; i++)
   {
    if(IsPlayerConnected(i))
    {
    		ShowPlayerNameTagForPlayer(i, playerid, 1);
    }
   }

   GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~y~Sciagnales chuste", 1500, 3);
   hasMaskOn[playerid] = 0;
  }
  else
  {
   for(new i = 0; i < MAX_PLAYERS; i++)
   {
    	if(IsPlayerConnected(i))
    	{
	 		if(OnAdminDuty[i] == 0)
     		{
      			ShowPlayerNameTagForPlayer(i, playerid, 0);
     		}
    	}
   }
   new playername[MAX_PLAYER_NAME];
   GetPlayerNameEx(playerid, playername, sizeof(playername));
   printf("[maska] %s zalozyl chuste.", playername);

   GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~y~Zalozyles chuste", 1500, 3);
   hasMaskOn[playerid] = 2;
  }
  return 1;
 }
 return 1;
}

dcmd_sprawdzbronie(playerid,params[])
{
 new idx, tmp[24], string[128];

 if(PlayerInfo[playerid][pAdmin] < 1)
 {
  SendClientMessage(playerid, COLOR_GRAD1, "Nie jesteœ uprawniony do u¿ycia tej komendy!");
  return 1;
 }

 tmp = strtok(params, idx);

 if(!strlen(tmp))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /sprawdzbronie [IdGracza/CzêœæNazwy]");
		return 1;
	}

 new giveplayerid = ReturnUser(tmp);

 if(!IsPlayerConnected(giveplayerid))
 {
  SendClientMessage(playerid, COLOR_GRAD1, "Ta osoba jest niedostêpna.");
  return 1;
 }

 new playername[MAX_PLAYER_NAME], j = 0;

 GetPlayerNameEx(giveplayerid, playername, sizeof(playername));

 format(string, sizeof(string), "* %s, iloœæ przegranych godzin: %d", playername, PlayerInfo[giveplayerid][pConnectTime]);
 SendClientMessage(playerid, COLOR_LORANGE, string);

 for(new i = 0; i < 12; i++)
	{
		new weapon, ammo, wname[24];
		
		GetPlayerWeaponData(giveplayerid, i, weapon, ammo);
		
		if(ammo > 0 && weapon > 0)
		{
		 GetWeaponName(weapon, wname, sizeof(wname));
	
 	 if(i == 1 || i == 10 || i == 12 || weapon == 43)
		 {
 			format(string, sizeof(string), "Broñ: %s", wname);		
 	 }
 	 else if(weapon == 44)
 	 {
 	  format(string, sizeof(string), "Broñ: Noktowizor");		
 	 }
   else if(weapon == 45)
 	 {
 	  format(string, sizeof(string), "Broñ: Termowizor");		
 	 }
   else if(weapon == 44)
 	 {
 	  format(string, sizeof(string), "Broñ: Spadochron");		
 	 }
 	 else
 	 {
 	  format(string, sizeof(string), "Broñ: %s, Amunicja: %d", wname, ammo);		
 	 }
 	
			SendClientMessage(playerid, COLOR_AWHITE, string);
			
			j++;
		}
	}
	
	if(j == 0)
	{
	 SendClientMessage(playerid, COLOR_AWHITE, "Brak informacji o broniach.");
	}
	
	return 1;
}

dcmd_akceptujsmierc(playerid, params[])
{
 #pragma unused params

 if(PlayerInfo[playerid][pWounded] == 0)
 {
  SendClientMessage(playerid, COLOR_GRAD1, "Nie mo¿esz u¿yæ tej komendy jeœli nie zosta³eœ brutalnie pobity!");
  return 1;
 }

 SendClientMessage(playerid, COLOR_WHITE, "Akceptacja œmierci oznacza trwa³¹ blokadê konta bez mo¿liwoœci dalszej gry.");
 SendClientMessage(playerid, COLOR_WHITE, "Aby zaakceptowaæ smieræ wpisz 'tak', jeœli jednak nie chcesz akceptowaæ œmierci postaci wpisz 'nie'.");

 acceptDeath[playerid] = 1;

 return 1;
}

dcmd_reanimuj(playerid, params[])
{
 new idx, tmp[24];

 //if(PlayerInfo[playerid][pMember] != 4 && PlayerInfo[playerid][pLeader] != 4 && PlayerInfo[playerid][pMember] != 3 && PlayerInfo[playerid][pLeader] != 3)
 //{
  if((PlayerInfo[playerid][pMember] == 3 || PlayerInfo[playerid][pLeader] == 3) && PlayerInfo[playerid][pRank] == 2){}
  else if(PlayerInfo[playerid][pMember] == 4 || PlayerInfo[playerid][pLeader] == 4){}
  else if(PlayerInfo[playerid][pMember] == 18 || PlayerInfo[playerid][pLeader] == 18){}
  else if((PlayerInfo[playerid][pMember] == 17 || PlayerInfo[playerid][pLeader] == 17) && PlayerInfo[playerid][pRank] > 1 && academyTrening == 1){}
  else
  {
   SendClientMessage(playerid, COLOR_GRAD1, "Nie jesteœ uprawniony do u¿ycia tej komendy!");
   return 1;
  }
 //}

 tmp = strtok(params, idx);

 if(!strlen(tmp))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /reanimuj [IdGracza/CzêœæNazwy]");
		return 1;
	}

 new giveplayerid = ReturnUser(tmp);

 if(!IsPlayerConnected(giveplayerid))
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Ta osoba jest niedostêpna.");
  return 1;
 }

 if(playerid == giveplayerid)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Nie mo¿esz reanimowaæ samego siebie.");
  return 1;
 }
 if (!DistanceBetweenPlayers(5.0, playerid, giveplayerid, true))
 {
		SendClientMessage(playerid, COLOR_GRAD2, "Nie ma takiej osoby w pobli¿u.");
		return 1;
 }
 /*if(GetDistanceBetweenPlayers(playerid, giveplayerid) > 2)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Nie ma takiej osoby w pobli¿u.");
  return 1;
 }*/

 if(PlayerInfo[giveplayerid][pWounded] == 0)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Ta osoba jest zdrowa i nie potrzebuje reanimacji.");
		return 1;
 }

 if((PlayerInfo[playerid][pMember] == 17 || PlayerInfo[playerid][pLeader] == 17) && PlayerInfo[playerid][pRank] > 1 && academyTrening == 1)
 {
  if(PlayerInfo[giveplayerid][pMember] != 17 && PlayerInfo[giveplayerid][pLeader] != 17)
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Reanimowaæ mo¿esz tylko osoby nale¿¹ce do Akademii Policyjnej.");
		return 1;
  }
 }

 KillAni(giveplayerid);
 SetCameraBehindPlayer(giveplayerid);
 
 TogglePlayerControllable(giveplayerid, true);

 PlayerInfo[giveplayerid][pWounded] = 0;
 deadPosition[giveplayerid][dpDeath] = 0;
 GodMode[giveplayerid] = 0;
 acceptDeath[giveplayerid] = 0;
 NameTag_RemoveState(giveplayerid, PLAYER_STATE_WOUNDED);

 SetPlayerHealthEx(giveplayerid, 100.0);

 new giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME], string[64];

 GetPlayerNameMask(giveplayerid, giveplayer, sizeof(giveplayer));
	GetPlayerNameMask(playerid, sendername, sizeof(sendername));
	format(string, sizeof(string), "* Zosta³eœ uratowany przez %s.", sendername);
	SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
 format(string, sizeof(string), "* Uda³o ci siê uratowaæ %s.", giveplayer);
	SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

 /*for(new i = 0; i < MAX_VEHICLES; i++)
	{
	 SetVehicleParamsForPlayer(i,playerid,0,1);
	}
	
	new idx;
	while (idx < sizeof(gVehicles))
	{
  if(strlen(gVehicles[idx][vOwner]) > 0)
	 {
	  if(gVehicles[idx][vLock] == 1)
	  {
	   SetVehicleParamsForPlayer(idx,playerid,0,1);
   }
	 }
	 idx++;
 }*/
 //InitLockDoors(playerid);

 return 1;
}

dcmd_removebw(playerid, params[])
{
 new idx, tmp[24];

 if(PlayerInfo[playerid][pAdmin] < 1)
 {
  SendClientMessage(playerid, COLOR_GRAD1, "Nie jesteœ uprawniony do u¿ycia tej komendy!");
  return 1;
 }

 tmp = strtok(params, idx);

 if(!strlen(tmp))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /removebw [IdGracza/CzêœæNazwy]");
		return 1;
	}

 new giveplayerid = ReturnUser(tmp);

 KillAni(giveplayerid);
 SetCameraBehindPlayer(giveplayerid);
 TogglePlayerControllable(giveplayerid,1);

 PlayerInfo[giveplayerid][pWounded] = 0;
 deadPosition[giveplayerid][dpDeath] = 0;
 GodMode[giveplayerid] = 0;

 SetPlayerHealthEx(giveplayerid, 100.0);

 new giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME], string[64];

 GetPlayerNameMask(giveplayerid, giveplayer, sizeof(giveplayer));
	GetPlayerNameMask(playerid, sendername, sizeof(sendername));
	format(string, sizeof(string), "* Administrator %s usuna³ BW z twojej postaæ.", sendername);
	SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
 format(string, sizeof(string), "* Usun¹³eœ BW z postaci %s.", giveplayer);
	SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
	
	NameTag_RemoveState(giveplayerid, PLAYER_STATE_WOUNDED);
	
	InitLockDoors(playerid);
 return 1;
}

dcmd_radiopomoc(playerid, params[])
{
 #pragma unused params

	if(IsPlayerConnected(playerid))
	{
		SendClientMessage(playerid, COLOR_GREEN,"_______________________________________");
		SendClientMessage(playerid, COLOR_HELP5,"*** RADIO *** /ustawkanal /wykupkanal /usunkanal /wykuphaslo /zmienhaslo");
	}	
	return 1;
}

/* dcmd_dajradio(playerid, params[])
{
 new idx, tmp[24], string[64];

 if(PlayerInfo[playerid][pLeader] == 1 || PlayerInfo[playerid][pLeader] == 3 || PlayerInfo[playerid][pLeader] == 4 || PlayerInfo[playerid][pLeader] == 7 || PlayerInfo[playerid][pLeader] == 17)
 {
  tmp = strtok(params, idx);

  if(!strlen(tmp))
	 {
	 	SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /dajradio [IdGracza/CzêœæNazwy]");
	 	return 1;
 	}

  new giveplayerid = ReturnUser(tmp);

  if(PlayerInfo[giveplayerid][pMember] != PlayerInfo[playerid][pLeader] && PlayerInfo[giveplayerid][pLeader] != PlayerInfo[playerid][pLeader] )
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Nie mo¿esz daæ radia osobie, która nie jest cz³onkiem twojej organizacji.");
	 	return 1;
  }

  new giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME];

  GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
 	GetPlayerNameEx(playerid, sendername, sizeof(sendername));
 	format(string, sizeof(string), "* %s da³ tobie radio.", sendername);
 	SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);
  format(string, sizeof(string), "* Da³eœ %s radio.", giveplayer);
 	SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
 	
 	new nitem[pItem];
				
  nitem[iItemId] = ITEM_RADIO;
  nitem[iCount] = 0;
  nitem[iOwner] = PlayerInfo[giveplayerid][pId];
  nitem[iOwnerType] = CONTENT_TYPE_USER;
  nitem[iPosX] = 0.0;
  nitem[iPosY] = 0.0;
  nitem[iPosZ] = 0.0;
  nitem[iPosVW] = 0;
  nitem[iFlags] = 0;
  nitem[iAttr1] = INVALID_RADIO_CHANNEL;

  new id = CreateItem(nitem);

  if(id == HAS_REACHED_LIMIT)
  {
   SendClientMessage(playerid, COLOR_GREY, "Ta osoba nie mo¿e posiadaæ wiêcej przedmiotów.");
   return 1;
  }
 	
 	return 1;
 }
 else
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ uprawniony do tego.");
	 return 1;
 }
} */

/*dcmd_wylaczradio(playerid, params[])
{
 #pragma unused params



 if(PlayerInfo[playerid][pRadioChannel] == RADIO_OFF)
 {
  PlayerInfo[playerid][pRadioChannel] = INVALID_RADIO_CHANNEL;
  SendClientMessage(playerid, COLOR_GREY, "W³¹czy³eœ radio.");
  return 1;
 }
 else
 {
  PlayerInfo[playerid][pRadioChannel] = RADIO_OFF;
  SendClientMessage(playerid, COLOR_GREY, "Wy³¹czy³eœ radio.");
  return 1;
 }
}*/

dcmd_usunkanal(playerid, params[])
{
 #pragma unused params

 new query[128];
 new line[64];
	
	format(query, sizeof(query), "SELECT id FROM `auth_radiochannel` WHERE owner_id = %d", PlayerInfo[playerid][pId]);

 mysql_query(query);
 mysql_store_result();
	
	if (mysql_num_rows() > 0)
	{
	 mysql_fetch_row_format(line);
	 mysql_free_result();
	
	 format(query, sizeof(query), "DELETE `auth_radiochannel` WHERE owner_id = %d", PlayerInfo[playerid][pId]);
	 mysql_query(query);
	
	 for(new i = 0; i < MAX_PLAYERS; i++)
	 {
	  if(IsPlayerConnected(i))
	  {
	   new radioitemindex = GetPlayerItemByType(playerid, ITEM_RADIO);
	   new radiochannel = strval(line);
	
	   if(radioitemindex != INVALID_ITEM_ID && Items[radioitemindex][iAttr1] == radiochannel)
	   {
	    PlayerInfo[i][pRadioChannel] = INVALID_RADIO_CHANNEL;
	
	    if(i != playerid)
	    {
	     SendClientMessage(i, COLOR_GREY, "Kana³ radiowy, z którego korzysta³eœ zosta³ usuniêty.");
     }
    }
	  }
	 }
	
	 SendClientMessage(playerid, COLOR_WHITE, "Usun¹³eœ swój kana³ radiowy.");
	 return 1;
	}
	else
	{
	 mysql_free_result();
	
	 SendClientMessage(playerid, COLOR_GREY, "Nie posiadasz ¿adnego kana³u.");
	 return 1;
	}
}

/*dcmd_wyrzucradio(playerid, params[])
{
 #pragma unused params

 if(PlayerInfo[playerid][pRadio] == 0)
	{
	 SendClientMessage(playerid, COLOR_GREY, "Nie posiadasz radia.");
	 return 1;
	}
	
	PlayerInfo[playerid][pRadioChannel] = INVALID_RADIO_CHANNEL;
	PlayerInfo[playerid][pRadio] = 1;
	SendClientMessage(playerid, COLOR_GREY, "Pozby³eœ siê radia.");
	return 1;
}*/

dcmd_zmienhaslo(playerid, params[])
{
 new idx, tmp[24], string[64], query[128];
	
	format(query, sizeof(query), "SELECT password FROM `auth_radiochannel` WHERE owner_id = %d", PlayerInfo[playerid][pId]);

 mysql_query(query);
 mysql_store_result();
	
	if (mysql_num_rows() > 0)
	{
	 mysql_free_result();
	
  new escpassword[12];
	
	 tmp = strtok(params, idx);

  if(!strlen(tmp))
  {
	  SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /zmienhaslo [has³o]");
	  return 1;
 	}
 	
 	mysql_real_escape_string(tmp, escpassword);
 	
 	format(query, sizeof(query), "UPDATE `auth_radiochannel` SET password = '%s' WHERE owner_id = %d", escpassword, PlayerInfo[playerid][pId]);
 	mysql_query(query);
	
	 format(string, sizeof(string), "Has³o dla kana³u zosta³o zmienione. Nowe has³o to: %s", escpassword);
 	SendClientMessage(playerid, COLOR_WHITE, string);
	
	 return 1;
	}
	else
	{
	 mysql_free_result();

	 SendClientMessage(playerid, COLOR_GREY, "Nie posiadasz ¿adnego kana³u.");
	 return 1;
	}
}

dcmd_wykuphaslo(playerid, params[])
{
 new idx, tmp[24], string[64], query[128];
	
	format(query, sizeof(query), "SELECT password FROM `auth_radiochannel` WHERE owner_id = %d", PlayerInfo[playerid][pId]);

 mysql_query(query);
 mysql_store_result();
	
	if (mysql_num_rows() > 0)
	{
	 if(GetPlayerMoneyEx(playerid) >= 5000)
	 {
   new line[20];

 	 mysql_fetch_row_format(line);
 	 mysql_free_result();
	
	  if(strlen(line) > 0)
	  {
	   SendClientMessage(playerid, COLOR_GRAD2, "Twój kana³ jest ju¿ zabezpieczony has³em. Aby je zmieniæ, wpisz /zmienhaslo.");
	   return 1;
	  }
	
	  new escpassword[12];
	
	  tmp = strtok(params, idx);

   if(!strlen(tmp))
   {
 	  SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /wykuphaslo [has³o]");
	   return 1;
  	}
 	
 	 mysql_real_escape_string(tmp, escpassword);
 	
  	format(query, sizeof(query), "UPDATE `auth_radiochannel` SET password = '%s' WHERE owner_id = %d", escpassword, PlayerInfo[playerid][pId]);
  	mysql_query(query);
 	
 	 GivePlayerMoneyEx(playerid, -5000);
 	
  	format(string, sizeof(string), "Has³o dla kana³u zosta³o wykupione. Nowe has³o to: %s", escpassword);
  	SendClientMessage(playerid, COLOR_WHITE, string);

 	 return 1;
  }
  else
  {
   SendClientMessage(playerid, COLOR_GREY, "Nie masz na to pieniêdzy!");
	  return 1;
  }
	}
	else
	{
	 mysql_free_result();
	
	 SendClientMessage(playerid, COLOR_GREY, "Nie posiadasz ¿adnego kana³u.");
	 return 1;
	}
}

dcmd_wykupkanal(playerid, params[])
{
 new idx, tmp[24], string[64], query[128];

 format(query, sizeof(query), "SELECT password FROM `auth_radiochannel` WHERE owner_id = %d", PlayerInfo[playerid][pId]);

 mysql_query(query);
 mysql_store_result();
	
	if (mysql_num_rows() > 0)
	{
	 mysql_free_result();
	
	 SendClientMessage(playerid, COLOR_GREY, "Posiadasz ju¿ w³asny kana³ radiowy.");
	 return 1;
	}
	else
	{
	 mysql_free_result();

	 tmp = strtok(params, idx);
	
	 if(!strlen(tmp))
	 {
	 	SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /wykupkana³ [NumerKana³u] (Koszt wykupienia kana³u to $5000)");
	 	return 1;
	 }
	
	 new channel = strval(tmp);
	
	 if(GetPlayerMoneyEx(playerid) >= 5000)
	 {
	  if(channel < 100 || channel > 9999)
	  {
	   SendClientMessage(playerid, COLOR_GREY, "Numer kana³u musi byæ liczb¹ z zakresu 100-9999.");
	   return 1;
	  }
	
	  format(query, sizeof(query), "SELECT * FROM `auth_radiochannel` WHERE id = %d", channel);
	
	  mysql_query(query);
   mysql_store_result();

   if (mysql_num_rows() > 0)
  	{
	   mysql_free_result();

    SendClientMessage(playerid, COLOR_GREY, "Ten kana³ zosta³ ju¿ przez kogoœ wykupiony.");
    return 1;
   }
   else
   {
    mysql_free_result();

    format(query, sizeof(query), "INSERT INTO `auth_radiochannel` SET id = %d, owner_id = %d", channel, PlayerInfo[playerid][pId]);
    mysql_query(query);

    GivePlayerMoney(playerid,-5000);

    format(string, sizeof(string), "Wykupi³eœ w³aœnie kana³ radiowy. Numer twojego kanalu to %d", channel);
    SendClientMessage(playerid, COLOR_WHITE, string);
    return 1;
   }
	 }
	 else
	 {
	  SendClientMessage(playerid, COLOR_GREY, "Nie masz na to pieniêdzy!");
	  return 1;
	 }
	}
}

dcmd_ustawkanal(playerid, params[])
{
 new idx, tmp[24], query[128], string[64];
	
	new itemindex = GetUsedItemByItemId(playerid, ITEM_RADIO);
			
	switch(itemindex)
	{
	 case INVALID_ITEM_ID:
	 {
	  SendClientMessage(playerid, COLOR_GREY, "Nie posiadasz radia.");
  	return 1;
	 }
	 case HAS_UNUSED_ITEM_ID:
	 {
	  SendClientMessage(playerid, COLOR_GREY, "Twoje radio jest wy³¹czone. Aby je w³¹czyæ, u¿yj /przedmioty uzyj [IdPrzedmiotu].");
  	return 1;
	 }
	}
	
	if(!(Items[itemindex][iFlags] & ITEM_FLAG_USING))
	{
	 SendClientMessage(playerid, COLOR_GREY, "Twoje radio jest wy³¹czone.");
	 return 1;
	}

 tmp = strtok(params, idx);

 if(!strlen(tmp))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /ustawkanal [NumerKana³u]");
		return 1;
	}

 new channel = strval(tmp);

 if(channel == 1)
 {
  format(string, sizeof(string), "Zmieni³eœ pomyœlnie kana³ na %d.", channel);
  SendClientMessage(playerid, COLOR_WHITE, string);

  Items[itemindex][iAttr1] = 1;

  UpdateItemAttributes(Items[itemindex]);

  return 1;
 }

 if(channel > 9 && channel < 100)
 {
  if(PlayerInfo[playerid][pMember] == 1 || PlayerInfo[playerid][pLeader] == 1 || PlayerInfo[playerid][pMember] == 2 || PlayerInfo[playerid][pLeader] == 2 || PlayerInfo[playerid][pMember] == 3 || PlayerInfo[playerid][pLeader] == 3 || PlayerInfo[playerid][pMember] == 4 || PlayerInfo[playerid][pLeader] == 4 || PlayerInfo[playerid][pMember] == 7 || PlayerInfo[playerid][pLeader] == 7 || PlayerInfo[playerid][pMember] == 17 || PlayerInfo[playerid][pLeader] == 17)
  {
   if(channel == PlayerInfo[playerid][pMember] + 9 || channel == PlayerInfo[playerid][pLeader] + 9)
   {
    format(string, sizeof(string), "Zmieni³eœ pomyœlnie kana³ na %d.", channel);
    SendClientMessage(playerid, COLOR_WHITE, string);

    Items[itemindex][iAttr1] = channel;

    UpdateItemAttributes(Items[itemindex]);

    return 1;
   }
   else
   {
    SendClientMessage(playerid, COLOR_GRAD2, "Nie mo¿esz uzyskaæ dostêpu do chronionego kana³u.");
 		 return 1;
   }
  }
  else
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Nie mo¿esz uzyskaæ dostêpu do chronionego kana³u.");
		 return 1;
  }
 }

 format(query, sizeof(query), "SELECT password FROM `auth_radiochannel` WHERE id = %d", channel);

 mysql_query(query);
 mysql_store_result();
	
	if (mysql_num_rows() > 0)
	{
  new line[32];//, password[12];//, data[3][12];

	 mysql_fetch_row_format(line);
  mysql_free_result();

  if(strlen(line) > 0)
  {
   tmp = strtok(params, idx);

   if(!strlen(tmp))
	  {
	   SendClientMessage(playerid, COLOR_GRAD2, "Aby wejœæ na ten kana³ potrzebujesz has³a.");
		  SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /ustawkanal [NumerKana³u] [has³o]");
		  return 1;
  	}

   if(strcmp(line, tmp) == 0)
   {
    format(string, sizeof(string), "Zmieni³eœ pomyœlnie kana³ na %d.", channel);
    SendClientMessage(playerid, COLOR_WHITE, string);

    Items[itemindex][iAttr1] = channel;

    UpdateItemAttributes(Items[itemindex]);

    return 1;
   }
   else
   {
    SendClientMessage(playerid, COLOR_GRAD1, "Has³o do kana³u jest nieprawid³owe.");
    return 1;
   }
  }
  else
  {
   format(string, sizeof(string), "Zmieni³eœ pomyœlnie kana³ na %d.", channel);
   SendClientMessage(playerid, COLOR_WHITE, string);

   Items[itemindex][iAttr1] = channel;

   UpdateItemAttributes(Items[itemindex]);

   return 1;
  }
	}
	else
	{
	 mysql_free_result();
	
	 SendClientMessage(playerid, COLOR_GRAD1, "Kana³ o podanym numerze nie istnieje!");
	 return 1;
	}
}

dcmd_reload(playerid,params[])
{
	if(PlayerInfo[playerid][pAdmin] < 2)
	{
		SendClientMessage(playerid, COLOR_GRAD1, "Nie masz odpowiednich uprawnieñ.");
		return 1;
	}

  if(!strlen(params))
  {
		SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /reload [modu³]");
		SendClientMessage(playerid, COLOR_GRAD1, "doors, itemstypes, businesses, organizations, orgranks, vehiclescosts, objects");
		return 1;
  }

       if(!strcmp(params, "doors", true))          { LoadDoorsInfo(); SendClientMessage(playerid, COLOR_GRAD2, "Drzwi zosta³y prze³adowane."); }
  else if(!strcmp(params, "itemstypes", true))
	{
		LoadItemsTypes();
		
		// odœwie¿amy kolorki
		// mo¿na pomyœleæ o przeniesiu tego do osobnej funkcji
		for(new i = 0; i < MAX_ITEMS_TYPES; i++)
		{
			if(Items[i][iId] != INVALID_ITEM_ID && Items[i][iFlags] & ITEM_FLAG_DROPPED)
			{
				UpdateItemLabel(i, 2);
			}
		}
		
		SendClientMessage(playerid, COLOR_GRAD2, "Przedmioty zosta³y prze³adowane.");
	}
  else if(!strcmp(params, "businesses", true))     { LoadBizz(); SendClientMessage(playerid, COLOR_GRAD2, "Biznesy zosta³y prze³adowane."); }
  else if(!strcmp(params, "organizations", true))  { InitOfficialOrganizations(); SendClientMessage(playerid, COLOR_GRAD2, "Organizacje oficjalne zosta³y prze³adowane."); }
  else if(!strcmp(params, "orgranks", true))       { InitOfficialOrganizationsRanks(); SendClientMessage(playerid, COLOR_GRAD2, "Rangi organizacji oficjalnych zosta³y prze³adowane."); }
	else if(!strcmp(params, "vehiclescosts", true))  { LoadVehiclesCosts(); SendClientMessage(playerid, COLOR_GRAD2, "Koszta pojazdów zosta³y prze³adowane."); }
	else if(!strcmp(params, "objects", true))  			 { Objects_Init(); Objects_SpawnObjects(); SendClientMessage(playerid, COLOR_GRAD2, "Obiekty zosta³y prze³adowane."); }

	return 1;
}


#if TIKI_EVENT
dcmd_startevent(playerid,params[])
{
 #pragma unused params

 if(PlayerInfo[playerid][pId] != 1 || tikiEvent == -1)
 {
		return 1;
 }

 tikiEvent = 1;

 tikiTextDraw = TextDrawCreate(472.000000,433.000000,"~r~Glowa Faraona: ~w~Nie znaleziona");
 TextDrawAlignment(tikiTextDraw,0);
 TextDrawBackgroundColor(tikiTextDraw,0x000000ff);
 TextDrawFont(tikiTextDraw,1);
 TextDrawLetterSize(tikiTextDraw,0.299999,1.400000);
 TextDrawColor(tikiTextDraw,0xffffffff);
 TextDrawSetOutline(tikiTextDraw,1);
 TextDrawSetProportional(tikiTextDraw,1);
 TextDrawSetShadow(tikiTextDraw,1);
 TextDrawShowForAll(tikiTextDraw);

 return 1;
}

dcmd_glowafaraona(playerid,params[])
{
 #pragma unused params

 if(tikiEvent == 1 && PlayerInfo[playerid][pConnectTime] >= 30 && (PlayerInfo[playerid][pAdmin] == 0 || PlayerInfo[playerid][pId] == 1 || PlayerInfo[playerid][pId] == 6) && PlayerToPoint(2.0, playerid, -2542.7837,1214.4309,37.4219))
 {
  tikiEvent = -1;

  new playername[MAX_PLAYER_NAME], string[128];
  GetPlayerNameEx(playerid, playername, sizeof(playername));
  GetPlayerNameEx(playerid, tikiWinner, sizeof(tikiWinner));

  format(string, sizeof(string), "~r~Glowa Faraona: ~w~%s", playername);
  TextDrawSetString(tikiTextDraw, string);

  for(new i = 0; i < MAX_PLAYERS; i++)
  {
   if(IsPlayerConnected(i))
   {
    if(PlayerInfo[i][pTiki] == 1)
    {
     DestroyPlayerObject(i, PlayerInfo[i][pTikiObject]);
     PlayerInfo[i][pTiki] = 0;
    }
   }
  }

  format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~w~Glowa faraona zostala odnaleziona przez~n~~r~%s", playername);
  GameTextForAll(string,7000,3);

  for(new i = 0; i < 50; i++)
  {
   printf("%s znalazl glowe Faraona", playername);
  }

  /*CreateObject(654, 1155.409912, -2053.347900, 68.204468, 0.0000, 0.0000, 0.0000);
  CreateObject(654, 1153.519165, -2019.044067, 68.211670, 0.0000, 0.0000, 0.0000);
  CreateObject(654, 1194.231079, -2018.789551, 68.211670, 0.0000, 0.0000, 0.0000);
  CreateObject(654, 1194.051758, -2053.349365, 68.211670, 0.0000, 0.0000, 0.0000);
  CreateObject(1262, 1156.115356, -2053.415039, 80.857834, 0.0000, 0.0000, 303.7500);
  CreateObject(1262, 1155.893433, -2053.080566, 76.867989, 0.0000, 0.0000, 56.2500);
  CreateObject(1262, 1193.727051, -2053.185791, 83.405823, 0.0000, 0.0000, 67.5000);
  CreateObject(1262, 1193.729370, -2053.082031, 77.998917, 0.0000, 0.0000, 337.5000);
  CreateObject(1262, 1194.168945, -2019.471436, 81.469536, 0.0000, 0.0000, 168.7499);
  CreateObject(1262, 1194.161255, -2019.471436, 79.255569, 0.0000, 0.0000, 22.5000);
  CreateObject(1262, 1192.305298, -2019.155762, 77.476738, 0.0000, 0.0000, 135.0000);
  CreateObject(1262, 1153.267578, -2019.725952, 80.340370, 0.0000, 0.0000, 168.7500);
  CreateObject(1262, 1153.329712, -2019.725952, 84.823219, 0.0000, 0.0000, 157.5000);
  CreateObject(1262, 1154.224609, -2019.573364, 78.315399, 0.0000, 0.0000, 258.7500);
  CreateObject(1262, 1154.224609, -2019.673584, 82.726791, 0.0000, 0.0000, 236.2501);
  CreateObject(1262, 1194.757202, -2053.125244, 78.186836, 0.0000, 0.0000, 315.0000);
  CreateObject(1262, 1194.557739, -2053.082031, 83.170578, 0.0000, 0.0000, 303.7500);
  CreateObject(1262, 1156.115356, -2053.319336, 77.369781, 0.0000, 0.0000, 315.0000);*/

		return 1;
 }
 return 1;
}
#endif

dcmd_sprawdzpojazdy(playerid,params[])
{
 if(PlayerInfo[playerid][pAdmin] < 1)
 {
  SendClientMessage(playerid, COLOR_GRAD1, "Nie masz odpowiednich uprawnieñ.");
  return 1;
 }

 new idx, tmp[64], line[16], data[2][16], string[64], query[128], giveplayer[MAX_PLAYER_NAME];

	tmp = strtok(params, idx);

 if(!strlen(tmp))
 {
 	SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /sprawdzpojazdy [IdGracza/CzêœæNazwy]");
 	return 1;
 }

 new giveplayerid = ReturnUser(tmp);

 if(!IsPlayerConnected(giveplayerid))
 {
  SendClientMessage(playerid, COLOR_GRAD1, "Ta osoba jest niedostêpna.");
 	return 1;
 }

 GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
 format(string, sizeof(string), "Pojazdy %s:", giveplayer);
 SendClientMessage(playerid, COLOR_LORANGE, string);

 format(query, sizeof(query), "SELECT `id`, `model` FROM `vehicles_vehicle` WHERE `owner_id` = %d AND `owner_type_id` = %d ORDER BY `id`", PlayerInfo[giveplayerid][pId], CONTENT_TYPE_USER);
 	
	mysql_query(query);
	mysql_store_result();

 if(mysql_num_rows() > 0)
	{
	 while(mysql_fetch_row_format(line) == 1)
	 {
   split(line, data, '|');

   format(string, sizeof(string), "(ID: %d) %s", strval(data[0]), GetVehicleNameByModel(strval(data[1])));
   SendClientMessage(playerid, COLOR_WHITE, string);
  }

  mysql_free_result();
 }
 else
 {
  mysql_free_result();

  SendClientMessage(playerid, COLOR_WHITE, "Brak pojazdów.");
 }

 return 1;
}

dcmd_setloc(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] < 2 && !HasPermission(playerid, CREATING_INTERIORS))
 {
  SendClientMessage(playerid, COLOR_GRAD1, "Nie masz odpowiednich uprawnieñ.");
  return 1;
 }

	new idx, string[128];
	string = strtok(params, idx);

	if (!strlen(string))
 {
	 SendClientMessage(playerid, COLOR_RED, "U¯YCIE: /setloc [X] [Y] [Z] [Interior]");
	 return 1;
	}

	new Float:X, Float:Y, Float:Z;
	new Interior;

	X = floatstr(string);
	Y = floatstr(strtok(params,idx));
	Z = floatstr(strtok(params,idx));
	Interior = strval(strtok(params,idx));

 new pVID = GetPlayerVehicleID(playerid);

	if(pVID)
	{
	 SetVehiclePos(pVID, X, Y, Z);
	 LinkVehicleToInterior(pVID, Interior);
	}
	else
	{
		SetPlayerPosEx(playerid, X, Y, Z);
	}
	
	SetPlayerInterior(playerid, Interior);
	
	return 1;
}

dcmd_kanister(playerid, params[])
{
 new command[16], tmp[32], idx;

 new itemindex = GetUsedItemByItemId(playerid, ITEM_CANISTER);
	
 switch(itemindex)
	{
	 case INVALID_ITEM_ID:
	 {
	  SendClientMessage(playerid, COLOR_GREY, "Nie posiadasz kanistra.");
  	return 1;
	 }
	 case HAS_UNUSED_ITEM_ID:
	 {
	  SendClientMessage(playerid, COLOR_GREY, "Wyci¹gnij kanister, aby go natankowaæ. U¿yj /przedmioty uzyj [IdPrzedmiotu].");
  	return 1;
	 }
	}
	
	new fuel = Items[itemindex][iAttr1];

 tmp = strtok(params, idx);

 if(!strlen(tmp))
 {
 	SendClientMessage(playerid, COLOR_LORANGE, "** Twój kanister **");
	 SendClientMessage(playerid, COLOR_AWHITE,  "napelnij, natankuj");
 	return 1;
 }

 strmid(command, tmp, 0, sizeof(tmp), sizeof(command));

 if(!strcmp(command, "napelnij", true))
 {
  if(IsAtGasStation(playerid))
  {
   if(fuel == 15)
	 	{
	 	 SendClientMessage(playerid, COLOR_GREY, "Twój kanister jest pe³ny.");
	 	 return 1;
	 	}
	 	else
	 	{		 
		 new costs = floatround(15 * 2.5);
		 
		 if(costs > GetPlayerMoneyEx(playerid))
		 {
		   CantAffordMsg(playerid, costs);
			 return 1;
		 }
		 
		 GivePlayerMoneyEx(playerid, -costs);
		 
	 	 Items[itemindex][iAttr1] = 15;
	 	 UpdateItemAttributes(Items[itemindex]);
	 	
    SendClientMessage(playerid, COLOR_GREY, "Twój kanister zosta³ natankowany.");
	 	 return 1;		
	 	}
  }
  else
  {
   SendClientMessage(playerid, COLOR_GREY, "Nie znajdujesz siê na stacji benzynowej.");
 	 return 1;		
  }
 }
 else if(!strcmp(command, "natankuj", true))
 {
  if(IsPlayerInAnyVehicle(playerid))
  {
   if(fuel <= 0)
	 	{
	 	 SendClientMessage(playerid, COLOR_GREY, "Kanister jest pusty.");
 	  return 1;
	 	}
	 	
   new vehicleid = GetPlayerVehicleID(playerid);

   Vehicles[vehicleid][vFuel] = Vehicles[vehicleid][vFuel] + fuel > 100 ? 100.0 : Vehicles[vehicleid][vFuel] + fuel;
   Items[itemindex][iAttr1] = 0;

   UpdateItemAttributes(Items[itemindex]);

   SendClientMessage(playerid, COLOR_GREY, "Zatankowa³eœ pojazd, w którym siê aktualnie znajdujesz.");
 	 return 1;
  }
  else
  {
   SendClientMessage(playerid, COLOR_GREY, "Nie znajdujesz siê w ¿adnym pojeŸdzie.");
 	 return 1;
  }
 }

 return 1;
}

dcmd_lock(playerid, params[])
{
 #pragma unused params

 new vehicleindex = GetPlayerVehicleInRange(playerid, 4.0);

 if(vehicleindex == -1)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Nie ma ciê w pobli¿u ¿adnego z Twoich pojazdów!");
  return 1;
 }

 switch(Vehicles[vehicleindex][vLocked])
 {
  case 1:
  {
   gCarLock[vehicleindex] = 0;
  	Vehicles[vehicleindex][vLocked] = 0;
  	
  	GameTextForPlayer(playerid, "~w~Pojazd ~g~OTWARTY", 5000, 6);
  }
  default:
  {
   gCarLock[vehicleindex] = 1;
   Vehicles[vehicleindex][vLocked] = 1;

   GameTextForPlayer(playerid, "~w~Pojazd ~r~ZAMKNIETY", 5000, 6);
  }
 }

	PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
	/*new Float:tmpX, Float:tmpY, Float:tmpZ;
	GetVehiclePos(vehicleindex, tmpX, tmpY, tmpZ);
	Audio_PlayInPlaceShort(1, tmpX, tmpY, tmpZ, 15.0, GetPlayerVirtualWorld(playerid));*/
  				
	if(!IsPlayerInAnyVehicle(playerid))
 {
  ApplyAnimation(playerid, "INT_HOUSE", "wash_up", 4.0, 0, 0, 0, 0, 0);
 }

 return 1;
}

forward PlayerSpectatePlayerOrVehicle(playerid, targetid);
public PlayerSpectatePlayerOrVehicle(playerid, targetid)
{
 new pstate = GetPlayerState(targetid);

 TogglePlayerSpectating(playerid, 1);

 if(pstate == PLAYER_STATE_DRIVER || pstate == PLAYER_STATE_PASSENGER)
	{
		PlayerSpectateVehicle(playerid, GetPlayerVehicleID(targetid));
	}
	else
	{
  PlayerSpectatePlayer(playerid, targetid);
	}
	
	SetPlayerVirtualWorldEx(playerid, GetPlayerVirtualWorld(targetid));
	SetPlayerInterior(playerid, GetPlayerInterior(targetid));
	
	return 1;
}



forward SetPlayerVirtualWorldEx(playerid, worldid);
public SetPlayerVirtualWorldEx(playerid, worldid)
{
 	OnPlayerVirtualWorldChange(playerid, GetPlayerVirtualWorld(playerid), worldid);
 	SetPlayerVirtualWorld(playerid, worldid);

  	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(PlayerInfo[i][pHiddenNametags] == 1)
			{
				ShowPlayerNameTagForPlayer(i, playerid, 0);
			}

			if(hasMaskOn[i] > 0 && OnAdminDuty[playerid] == 0)
			{
				ShowPlayerNameTagForPlayer(playerid, i, 0);
			}
			else
			{
				ShowPlayerNameTagForPlayer(playerid, i, 1);
			}
		}
	}
 return 1;
}


forward OnPlayerVirtualWorldChange(playerid, oldworldid, newworldid);
public OnPlayerVirtualWorldChange(playerid, oldworldid, newworldid)
{
 if(oldworldid != newworldid)
 {
  if(newworldid == FAKE_INTERIOR_VW_ID)
  {
   SetPlayerWeather(playerid, 3);
  }
  else
  {
   SetPlayerWeather(playerid, actWeather);
  }

  for(new i = 0; i < MAX_PLAYERS; i++)
  {
   if(IsPlayerConnected(i) && Spectate[i] == playerid)
   {
    SetPlayerVirtualWorldEx(i, newworldid);
   }
  }
 }

 return 1;
}


forward TalkStyleSelect(playerid);
public TalkStyleSelect(playerid)
{
 new keys, updown, leftright, string[128];

 GetPlayerKeys(playerid, keys, updown, leftright);

 if(PlayerInfo[playerid][pStatus] == STATUS_SEL_TALKSTYLE)
 {
  if (leftright == KEY_RIGHT)
  {
   if(SelectTalkStyle[playerid] >= TALK_STYLES_COUNT)
   {
    SelectTalkStyle[playerid] = 0;
   }
   else
   {
    SelectTalkStyle[playerid]++;
   }

   ApplyChatAnimation(playerid, SelectTalkStyle[playerid]);

   format(string, sizeof(string), "~n~~n~~n~~n~~w~%s", TalkStylesInfo[SelectTalkStyle[playerid]][tsName]);
   GameTextForPlayer(playerid, string, 1500, 3);
  }
  else if (leftright == KEY_LEFT)
  {
   if(SelectTalkStyle[playerid] <= 0)
   {
    SelectTalkStyle[playerid] = TALK_STYLES_COUNT;
   }
   else
   {
    SelectTalkStyle[playerid]--;
   }

   ApplyChatAnimation(playerid, SelectTalkStyle[playerid]);

   format(string, sizeof(string), "~n~~n~~n~~n~~w~%s", TalkStylesInfo[SelectTalkStyle[playerid]][tsName]);
   GameTextForPlayer(playerid, string, 1500, 3);
  }
  else if (keys & KEY_ACTION)
  {
   SetCameraBehindPlayer(playerid);
   TogglePlayerControllable(playerid, 1);

   PlayerInfo[playerid][pStatus] = STATUS_NONE;
   PlayerInfo[playerid][pTalkStyle] = SelectTalkStyle[playerid];
   KillTimer(TalkStyleSelectTimer[playerid]);

   SendClientMessage(playerid, COLOR_LORANGE, "Styl rozmowy zosta³ pomyœlnie zmieniony.");
  }
 }
}

forward SetWorldTimeEx(hour);
public SetWorldTimeEx(hour)
{
 new newhour;

 switch(hour)
 {
  case 18:
  {
   newhour = 22;
  }
  case 19 .. 20:
  {
   newhour = 23;
  }
  case 21 .. 24:
  {
   newhour = 24;
  }
  default:
  {
   newhour = hour;
  }
 }

 SetWorldTime(newhour);
}

/*forward NickiTimer(playerid);
public NickiTimer(playerid)
{
  new str[126];
  new Float:HP;
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
      GetPlayerHealth(i, HP);
      if(HP > PlayerInfo[i][pHealth])
      {
         SetPlayerHealth(i, PlayerInfo[i][pHealth]);
      }
      else if(HP < PlayerInfo[i][pHealth])
      {
         format(str, sizeof(str), "%s (%d)", pName(playerid), playerid);
         Update3DTextLabelText(PlayerInfo[playerid][pNicknames3D], COLOR_RED, str);
         SetTimerEx("Nicki", 1500, 0, "u", i);
         if(PlayerInfo[i][pHealth] - HP >= 20.0)
		 {
			  OnePlayAnim(i,"CRACK","crckidle1",2.5,1,1,1,1,1);
			  SetTimerEx("rozmowa", 35000, 0, "u", i);
		 }
		 PlayerInfo[i][pHealth] = HP;
	  }
    }
    return 1;
}*/


forward SetPlayerHealthEx(playerid, Float:health);
public SetPlayerHealthEx(playerid, Float:health)
{
 PlayerInfo[playerid][pHealth] = health;
 SetPlayerHealth(playerid, health);
}

forward HealthTimer();
public HealthTimer()
{
 new Float:health;

 for(new i = 0; i < MAX_PLAYERS; i++)
 {
		new pstate = GetPlayerState(i);

		if(IsPlayerConnected(i) && (pstate == PLAYER_STATE_DRIVER || pstate == PLAYER_STATE_PASSENGER || pstate == PLAYER_STATE_ONFOOT) && PlayerInfo[i][pWounded] == 0)
		{
			GetPlayerHealth(i, health);

			if(health > PlayerInfo[i][pHealth])
			{
				SetPlayerHealth(i, PlayerInfo[i][pHealth]);
			}
			else if(health < PlayerInfo[i][pHealth])
			{
				if(health <= PlayerInfo[i][pHealth] - 10)
				{
					PlayerInfo[i][pInjuriesTime] = 30;
				}

				PlayerInfo[i][pHealth] = health;
			}
		}

		// obracanie wozem
		
		if(pstate == PLAYER_STATE_DRIVER)
		{
			new vehicleindex = GetPlayerVehicleID(i);
			
			if(IsACar(vehicleindex) && !HasPlayerItemByTypeAttr1(i, ITEM_LICENSE_CAR, PlayerInfo[i][pId]) && !HasObjectItemByTypeAttr1(CONTENT_TYPE_VEHICLE, Vehicles[vehicleindex][vId], ITEM_LICENSE_CAR, PlayerInfo[i][pId]) && PlayerSpeed[i] > 40
			  && TakingLesson[i] == 0)
			{
				if(random(10) < 7)
				{
					new Float:angle;
				
					GetVehicleZAngle(vehicleindex, angle);
					SetVehicleZAngle(vehicleindex, random(10) < 5 ? (angle + 5 + random(15)) : (angle - 5 - random(15)));
				}
				else
				{
					if(random(100) < 5 && PlayerSpeed[i] > 20)
					{
						if(PlayerInfo[i][pStoppedVehicleInterval] == 0)
						{
							SendClientMessage(i, COLOR_GREY, "Pomyli³eœ peda³ gazu z peda³em hamulca.");
							TogglePlayerControllable(i, 0);
							SetTimerEx("UnfreezePlayer", 1500, 0, "d", i);
					
							PlayerInfo[i][pStoppedVehicleInterval] = 3;
						}
						else
						{
							PlayerInfo[i][pStoppedVehicleInterval]--;
							if(PlayerInfo[i][pStoppedVehicleInterval] < 0) PlayerInfo[i][pStoppedVehicleInterval] = 0;
						}
					}
				}
			}
		}
	}

	for(new i = 0; i < MAX_VEHICLES; i++)
	{
		if(Vehicles[i][vId] != -1)
		{
			GetVehicleHealth(i, health);

			if(health > Vehicles[i][vHealth])
			{
				SetVehicleHealth(i, Vehicles[i][vHealth]);
			}
			else if(health < Vehicles[i][vHealth])
			{
				Vehicles[i][vHealth] = health;
			}
		}
	}
}

forward UnfreezePlayer(playerid);
public UnfreezePlayer(playerid)
{
 TogglePlayerControllable(playerid, 1);
 return 1;
}

stock ChatBubble(playerid, text[], color, Float:distance, expiretime=0)
{
  SetPlayerChatBubble(playerid, text, color, distance, expiretime ? expiretime : 5000);
  
  return 1;
}

stock ServerMe(playerid,text[],dot=0,Float:distance=10.0)
{
  new string[128], playername[MAX_PLAYER_NAME];

  GetPlayerNameMask(playerid, playername, sizeof(playername));
  dcfirst(text);

  if(strlen(text) > SPLIT_TEXT_LIMIT)
  {
    new stext[128];

    strmid(stext, text, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
    format(string, sizeof(string), "* %s %s...", playername, stext);
    ProxDetector(distance, playerid, string,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);

    strmid(stext, text, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
    if(dot && text[strlen(text)-1] != '.')
    {
      format(string, sizeof(string), "* ...%s. ((%s))", stext, playername);
    }
    else
    {
      format(string, sizeof(string), "* ...%s ((%s))", stext, playername);
    }
    ProxDetector(distance, playerid, string,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
  }
  else
  {
    if(dot && text[strlen(text)-1] != '.')
    {
      format(string, sizeof(string), "* %s %s.", playername, text);
    }
    else
    {
      format(string, sizeof(string), "* %s %s", playername, text);
    }
    ProxDetector(distance, playerid, string,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
  }
  
  if(HasPremiumAccount(playerid))
  {
    //format(string, sizeof(string), "* %s %s", playername, text);
    //ChatBubble(playerid, text, COLOR_PURPLE, distance);
  }

  GetPlayerNameEx(playerid, playername, sizeof(playername));
  printf("* %s %s", playername, text);

  return 1;
}

stock CantAffordMsg(playerid, cost, bank=0)
{
 new string[128];

 format(string, sizeof(string), "Nie mo¿esz sobie na to pozwoliæ, brakuje Ci $%d.", bank == 0 ? cost-GetPlayerMoneyEx(playerid) : cost-PlayerInfo[playerid][pAccount]);
 SendClientMessage(playerid, COLOR_GREY, string);
}

dcmd_me(playerid, params[])
{
  if(PlayerInfo[playerid][pMuted] == 1)
	{
		SendClientMessage(playerid, TEAM_CYAN_COLOR, "Nie mo¿esz rozmawiaæ, zosta³eœ wyciszony");
		return 1;
	}
	
 if(!strlen(params))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /me [akcja]");
		return 1;
	}
	 	
 if(!CheckIsTextIC(playerid, params))
 {
  return 0;
 }

 ServerMe(playerid, params, 1);
	
	return 1;
}

dcmd_sprobuj(playerid, params[])
{
	   if(!strlen(params))
	   {
	        SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /sprobuj [Akcja].");
	        return 1;
	   }
    new sendername[MAX_PLAYER_NAME];
    GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	switch(random(4)+1)
	{
		case 1: format(params, 256, "** %s spróbowa³ %s i uda³o mu siê **", sendername, params);
		case 2: format(params, 256, "** %s spróbowa³ %s i nie uda³o mu siê **", sendername, params);
		case 3: format(params, 256, "** %s spróbowa³ %s i nie uda³o mu siê **", sendername, params);
		case 4: format(params, 256, "** %s spróbowa³ %s i uda³o mu siê **", sendername, params);
	}
	sprobuj(playerid, params);
	return 1;
}

dcmd_do(playerid, params[])
{
  if(PlayerInfo[playerid][pMuted] == 1)
  {
    SendClientMessage(playerid, TEAM_CYAN_COLOR, "Nie mo¿esz rozmawiaæ, zosta³eœ wyciszony");
    return 1;
  }

  if(!strlen(params))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /do [akcja]");
    return 1;
  }

  if(!CheckIsTextIC(playerid, params))
  {
    return 0;
  }

  new string[128], sendername[MAX_PLAYER_NAME];

  GetPlayerNameMask(playerid, sendername, sizeof(sendername));

  if(strlen(params) > SPLIT_TEXT_LIMIT)
  {
    new stext[128];

    strmid(stext, params, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
    format(string, sizeof(string), "* %s... ((%s))", stext, sendername);
    ProxDetector(10.0, playerid, string,COLOR_DO_BLUE,COLOR_DO_BLUE,COLOR_DO_BLUE,COLOR_DO_BLUE,COLOR_DO_BLUE);

    strmid(stext, params, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
    format(string, sizeof(string), "* ...%s ((%s))", stext, sendername);
    ProxDetector(10.0, playerid, string,COLOR_DO_BLUE,COLOR_DO_BLUE,COLOR_DO_BLUE,COLOR_DO_BLUE,COLOR_DO_BLUE);
  }
  else
  {
    format(string, sizeof(string), "* %s ((%s))", params, sendername);
    ProxDetector(10.0, playerid, string,COLOR_DO_BLUE,COLOR_DO_BLUE,COLOR_DO_BLUE,COLOR_DO_BLUE,COLOR_DO_BLUE);
  }

  GetPlayerNameEx(playerid, sendername, sizeof(sendername));
  printf("* %s %s.", sendername, params);

  return 1;
}

dcmd_b(playerid, params[])
{	
 if(!strlen(params))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /b [wiadomoœæ]");
		return 1;
	}
 
 new string[128], sendername[MAX_PLAYER_NAME];
 
 GetPlayerNameEx(playerid, sendername, sizeof(sendername));
 
 ucfirst(params);
 
 if(strlen(params) > SPLIT_TEXT_LIMIT)
	{
	 new stext[128];
	 	
	 strmid(stext, params, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
 	format(string, sizeof(string), "[ID:%d] %s: (( %s... ))",playerid, sendername, stext);
  ProxDetector(10.0, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);

 	strmid(stext, params, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
 	format(string, sizeof(string), "[ID:%d] %s: (( ...%s ))",playerid, sendername, stext);
  ProxDetector(10.0, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
 }
 else
 {
 	format(string, sizeof(string), "[ID:%d] %s: (( %s ))",playerid, sendername, params);
  ProxDetector(10.0, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
 }

	printf("[ID:%d] %s: (( %s ))", playerid, sendername, params);
	
	return 1;
}

dcmd_opis(playerid, params[])
{
  new text[128];
 
  if(sscanf(params, "s[128]", text))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /opis [treœæ] (Aby usun¹æ opis wpisz \"usun\")");
		
		return 1;
	}
	
	if(!strcmp(text, "usun", true))
	{
		strmid(PlayerInfo[playerid][pDescription], "", 0, 0, 255);
	}
	else
	{
		strmid(PlayerInfo[playerid][pDescription], text, 0, strlen(text), 255);
	}
	
	Description_Update(playerid);
	
	new escdesc[128];
	mysql_real_escape_string(PlayerInfo[playerid][pDescription], escdesc);
	
	new query[256];
	format(query, sizeof(query), "UPDATE `auth_game_user_data` SET `description` = '%s' WHERE `user_id` = %d", escdesc, PlayerInfo[playerid][pId]);
  mysql_query(query);
	
	if(!strcmp(text, "usun", true))
	{
		SendClientMessage(playerid, COLOR_LORANGE, "Usun¹³eœ opis swojej postaci.");
	}
	else
	{
		SendClientMessage(playerid, COLOR_LORANGE, "Ustawi³eœ opis swojej postaci:");
	}
	
	return 1;
}

dcmd_report(playerid, params[])
{
 new text[128], string[128], giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME], giveplayerid;
 
 if(sscanf(params, "us[128]", giveplayerid, text))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /raport [IdGracza/CzêœæNazwy] [Powód]");
		return 1;
	}
	
 if(giveplayerid == INVALID_PLAYER_ID)
	{
  SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedostêpna.");
  return 1;
 }
	
	GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));

 if(playerid == giveplayerid)
 {
  format(string, sizeof(string), "Raport (ID:%d) %s: %s", playerid, sendername, text);
 }
 else
 {
  format(string, sizeof(string), "Raport (ID:%d) %s -> (ID:%d) %s: %s", playerid, sendername, giveplayerid, giveplayer, text);
 }
			
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
  if(PlayerInfo[i][pAdmin] > 0 && PlayerInfo[i][pAdmin] != 3)
  {	
   if(OnAdminDuty[i] == 1)
   {
	   SendClientMessage(i, COLOR_RED, string);
   }
	}
 }
 
 print(string);
 SendClientMessage(playerid, COLOR_YELLOW, "Zg³oszenie zosta³o wys³ane do administracji.");

 return 1;
}

dcmd_id(playerid, params[])
{
	new giveplayerid = INVALID_PLAYER_ID, string[80], playername[MAX_PLAYER_NAME], playername2[MAX_PLAYER_NAME];
 
	if(!strlen(params))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /id [IdGracza/CzêœæNazwy]");
		return 1;
	}

	if(IsNumeric(params))
	{
		giveplayerid = strval(params);
		
		if(!IsPlayerConnected(giveplayerid))
		{
			SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedostêpna.");
			return 1;
		}
		
		SendClientMessage(playerid, COLOR_LORANGE, "Znalezione osoby:");
		
		GetPlayerNameEx(giveplayerid, playername, sizeof(playername));
		format(string, sizeof(string), "Gracz (ID: %d) %s.", giveplayerid, playername);
		SendClientMessage(playerid, GetPlayerColor(giveplayerid), string);
		
		return 1;
	}
	else
	{
		if(strlen(params) < 3)
		{
			SendClientMessage(playerid, COLOR_GREY, "Niepoprawna d³ugoœæ nazwy.");
			return 1;
		}

		SendClientMessage(playerid, COLOR_LORANGE, "Znalezione osoby:");
		
		new c = 0;

		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(!IsPlayerConnected(i)) continue;
			if(IsPlayerNPC(i)) continue;
			
			if(c >= 5) break;

			GetPlayerName(i, playername, sizeof(playername));
			GetPlayerNameEx(i, playername2, sizeof(playername2));

			if((strfind(playername, params, true) != -1 || strfind(playername2, params, true) != -1))
			{
				format(string, sizeof(string), "Gracz (ID: %d) %s.",i, playername2);
				SendClientMessage(playerid, GetPlayerColor(i), string);
				c++;
			}
		}
		
		if(c >= 5)
		{
			SendClientMessage(playerid, COLOR_GREY, "Zbyt du¿o wyników.");
			return 1;
		}
		
		if(c == 0)
		{
			SendClientMessage(playerid, COLOR_GREY, "Nie znaleziono ¿adnych osób.");
			return 1;
		}
	}

	return 1;
}

dcmd_d(playerid, params[])
{
	new organization = GetPlayerOrganization(playerid);

	if(organization != 1 && organization != 2 && organization != 3 && organization != 13 && organization != 17 && organization != 18 && organization != 4 && organization != 7)
	{
		SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz tego zrobiæ.");
		return 1;
	}
	
	new itemindex = GetUsedItemByItemId(playerid, ITEM_RADIO);
			
	switch(itemindex)
	{
		case INVALID_ITEM_ID:
		{
			SendClientMessage(playerid, COLOR_GREY, "Nie posiadasz radia.");
			return 1;
		}
		case HAS_UNUSED_ITEM_ID:
		{
			SendClientMessage(playerid, COLOR_GREY, "Twoje radio jest wy³¹czone. Aby je w³¹czyæ, u¿yj /przedmioty uzyj [IdPrzedmiotu].");
			return 1;
		}
	}
	
	if(!strlen(params))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: (/d)epartament [Wiadomoœæ]");
		return 1;
	}
	
	ucfirst(params);
	
	new rankname[32], playername[MAX_PLAYER_NAME], string[128];
				
  GetPlayerOffRankName(playerid, rankname, sizeof(rankname));
	GetPlayerNameMask(playerid, playername, sizeof(playername));
	
	if(strlen(params) > SPLIT_TEXT_LIMIT)
	{
		new stext[128];
			
		strmid(stext, params, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
		format(string, sizeof(string), "** %s %s: %s... **", rankname, playername, stext);

		SendRadioMessageEx2(playerid, 1, COLOR_ALLDEPT, string);
		SendRadioMessageEx2(playerid, 2, COLOR_ALLDEPT, string);
		SendRadioMessageEx2(playerid, 3, COLOR_ALLDEPT, string);
		SendRadioMessageEx2(playerid, 4, COLOR_ALLDEPT, string);
		SendRadioMessageEx2(playerid, 7, COLOR_ALLDEPT, string);
		SendRadioMessageEx2(playerid, 13, COLOR_ALLDEPT, string);
		SendRadioMessageEx2(playerid, 18, COLOR_ALLDEPT, string);
		
		format(string, sizeof(string), "%s mówi (radio): %s...", playername, stext);
		ProxDetector(20.0, playerid, string, COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
		
		////

		strmid(stext, params, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
		format(string, sizeof(string), "** %s %s: ...%s, odbiór. **", rankname, playername, stext);
		
		SendRadioMessageEx2(playerid, 1, COLOR_ALLDEPT, string);
		SendRadioMessageEx2(playerid, 2, COLOR_ALLDEPT, string);
		SendRadioMessageEx2(playerid, 3, COLOR_ALLDEPT, string);
		SendRadioMessageEx2(playerid, 4, COLOR_ALLDEPT, string);
		SendRadioMessageEx2(playerid, 7, COLOR_ALLDEPT, string);
		SendRadioMessageEx2(playerid, 13, COLOR_ALLDEPT, string);
		SendRadioMessageEx2(playerid, 18, COLOR_ALLDEPT, string);
		
		format(string, sizeof(string), "%s mówi (radio): ...%s", playername, stext);
		ProxDetector(20.0, playerid, string, COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
	}
	else
	{
	  format(string, sizeof(string), "** %s %s: %s, odbiór. **", rankname, playername, params);
		
		SendRadioMessageEx2(playerid, 1, COLOR_ALLDEPT, string);
		SendRadioMessageEx2(playerid, 2, COLOR_ALLDEPT, string);
		SendRadioMessageEx2(playerid, 3, COLOR_ALLDEPT, string);
		SendRadioMessageEx2(playerid, 4, COLOR_ALLDEPT, string);
		SendRadioMessageEx2(playerid, 7, COLOR_ALLDEPT, string);
		SendRadioMessageEx2(playerid, 13, COLOR_ALLDEPT, string);
		SendRadioMessageEx2(playerid, 18, COLOR_ALLDEPT, string);
		
		format(string, sizeof(string), "%s mówi (radio): %s", playername, params);
		ProxDetector(20.0, playerid, string, COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
	}

	format(string, sizeof(string), "%s mówi (radio-departament): %s", playername, params);
  printf("%s", string);
	
	return 1;
}

dcmd_togf(playerid, params[])
{
	#pragma unused params

	if (!gFam[playerid])
	{
		gFam[playerid] = 1;
		SendClientMessage(playerid, COLOR_GRAD2, "Czat rodzinny zosta³ zablokowany.");
	}
	else if (gFam[playerid])
	{
		gFam[playerid] = 0;
		SendClientMessage(playerid, COLOR_GRAD2, "Czat rodzinny zosta³ odblokowany.");
	}

	return 1;
}

dcmd_w(playerid, params[])
{
	new giveplayerid, msg[128], string[128];
 
	if(sscanf(params, "us[128]", giveplayerid, msg))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: (/w)iadomosc [IdGracza/CzêœæNazwy] [Wiadomoœæ]");
		return 1;
	}
 
	//if(giveplayerid == INVALID_PLAYER_ID)
	if(!IsPlayerConnected(giveplayerid))
	{
		SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedostêpna.");
		return 1;
	}
	
	if(giveplayerid == playerid)
	{
		ServerMe(playerid, "rozmawia sam ze sob¹.");
		return 1;
	}
	
	if(HidePM[giveplayerid] > 0 && PlayerInfo[playerid][pAdmin] < 1)
	{
		SendClientMessage(playerid, COLOR_GREY, "Ten gracz zablokowa³ prywatne wiadomoœci!");
		return 1;
	}
	
	if(BlockedPM[giveplayerid][playerid] == 1 && PlayerInfo[playerid][pAdmin] < 1)
	{
		SendClientMessage(playerid, COLOR_GREY, "Zosta³eœ zablokowany przez tego gracza!");
		return 1;
	}
	
	if(PlayerInfo[playerid][pWounded] > 0 && PlayerInfo[giveplayerid][pAdmin] < 1 && PlayerInfo[playerid][pAdmin] < 1)
	{
		SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz wys³aæ prywatnej wiadomoœci, poniewa¿ jesteœ brutalnie zraniony.");
		return 1;
	}
	
	if(PlayerInfo[giveplayerid][pWounded] > 0)
	{
		SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz napisaæ do tej osoby, poniewa¿ jest ona brutalnie zraniona (BW).");
		return 1;
	}
	
	PlayerInfo[playerid][pLastPmRecipient] = PlayerInfo[giveplayerid][pId];
	
	new sendername[MAX_PLAYER_NAME], giveplayer[MAX_PLAYER_NAME];
	
	GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
	
	ucfirst(msg);

	if(strlen(msg) > SPLIT_TEXT_LIMIT)
	{
		new stext[128];
			
		strmid(stext, msg, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
		format(string, sizeof(string), "(( %s (ID: %d) napisa³: %s... ))", sendername, playerid, stext);
		SendClientMessage(giveplayerid, COLOR_NEWS, string);
		format(string, sizeof(string), "(( Wys³ano do %s (ID: %d): %s... ))", giveplayer, giveplayerid, stext);
		SendClientMessage(playerid, COLOR_NEWS2, string);

		strmid(stext, msg, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
		format(string, sizeof(string), "(( %s (ID: %d) napisa³: ...%s ))", sendername, playerid, stext);
		SendClientMessage(giveplayerid, COLOR_NEWS, string);
		format(string, sizeof(string), "(( Wys³ano do %s (ID: %d): ...%s ))", giveplayer, giveplayerid, stext);
		SendClientMessage(playerid, COLOR_NEWS2, string);
	}
	else
	{
	  format(string, sizeof(string), "(( %s (ID: %d) napisa³: %s ))", sendername, playerid, msg);
		SendClientMessage(giveplayerid, COLOR_NEWS, string);
		format(string, sizeof(string), "(( Wys³ano do %s (ID: %d): %s ))", giveplayer, giveplayerid, msg);
		SendClientMessage(playerid, COLOR_NEWS2, string);
	}
	
	printf("[PW] (( %s napisa³ do %s : %s. ))", sendername, giveplayer, msg);
	
	PlayerPlaySound(giveplayerid, 1057, 0.0, 0.0, 0.0);

	return 1;
}

dcmd_wr(playerid, params[])
{
  if(PlayerInfo[playerid][pLastPmRecipient] == -2)
	{
	  SendClientMessage(playerid, COLOR_GREY, "Aby u¿yæ tej komendy, najpierw musisz napisaæ do kogoœ u¿ywaj¹c komendy /w.");
		return 1;
	}

	new giveplayerid = GetPlayerById(PlayerInfo[playerid][pLastPmRecipient]);
	new string[128];
	
	if(giveplayerid == INVALID_PLAYER_ID)
	{
		SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedostêpna.");
		return 1;
	}
	
	if(!strlen(params))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: (/wr)epeat [Wiadomoœæ]");
		return 1;
	}
	
	if(HidePM[giveplayerid] > 0 && PlayerInfo[playerid][pAdmin] < 1)
	{
		SendClientMessage(playerid, COLOR_GREY, "Ten gracz zablokowa³ prywatne wiadomoœci!");
		return 1;
	}
	
	if(BlockedPM[giveplayerid][playerid] == 1 && PlayerInfo[playerid][pAdmin] < 1)
	{
		SendClientMessage(playerid, COLOR_GREY, "Zosta³eœ zablokowany przez tego gracza!");
		return 1;
	}
	
	if(PlayerInfo[playerid][pWounded] > 0 && PlayerInfo[giveplayerid][pAdmin] < 1 && PlayerInfo[playerid][pAdmin] < 1)
	{
		SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz wys³aæ prywatnej wiadomoœci, poniewa¿ jesteœ brutalnie zraniony.");
		return 1;
	}
	
	if(PlayerInfo[giveplayerid][pWounded] > 0)
	{
		SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz napisaæ do tej osoby, poniewa¿ jest ona brutalnie zraniona (BW).");
		return 1;
	}

	new sendername[MAX_PLAYER_NAME], giveplayer[MAX_PLAYER_NAME];
	
	GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
	
	ucfirst(params);

	if(strlen(params) > SPLIT_TEXT_LIMIT)
	{
		new stext[128];
			
		strmid(stext, params, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
		format(string, sizeof(string), "(( %s (ID: %d) napisa³: %s... ))", sendername, playerid, stext);
		SendClientMessage(giveplayerid, COLOR_NEWS, string);
		format(string, sizeof(string), "(( Wys³ano do %s (ID: %d): %s... ))", giveplayer, giveplayerid, stext);
		SendClientMessage(playerid, COLOR_NEWS2, string);

		strmid(stext, params, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
		format(string, sizeof(string), "(( %s (ID: %d) napisa³: ...%s ))", sendername, playerid, stext);
		SendClientMessage(giveplayerid, COLOR_NEWS, string);
		format(string, sizeof(string), "(( Wys³ano do %s (ID: %d): ...%s ))", giveplayer, giveplayerid, stext);
		SendClientMessage(playerid, COLOR_NEWS2, string);
	}
	else
	{
	  format(string, sizeof(string), "(( %s (ID: %d) napisa³: %s ))", sendername, playerid, params);
		SendClientMessage(giveplayerid, COLOR_NEWS, string);
		format(string, sizeof(string), "(( Wys³ano do %s (ID: %d): %s ))", giveplayer, giveplayerid, params);
		SendClientMessage(playerid, COLOR_NEWS2, string);
	}
	
	printf("[PW] (( %s napisa³ do %s : %s. ))", sendername, giveplayer, params);
	
	PlayerPlaySound(giveplayerid, 1057, 0.0, 0.0, 0.0);
	
	return 1;
}

dcmd_l(playerid, params[])
{
	if(!strlen(params))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: (/l)okalny [Wiadomoœæ]");
		return 1;
	}

	if(PlayerInfo[playerid][pMuted] >= 1)
	{
		SendClientMessage(playerid, TEAM_CYAN_COLOR, "Nie mo¿esz rozmawiaæ, zosta³eœ wyciszony");
		return 1;
	}

	if(!CheckIsTextIC(playerid, params))
	{
		return 0;
	}
	
	new sendername[MAX_PLAYER_NAME];
	GetPlayerNameMask(playerid, sendername, sizeof(sendername));
	
	ucfirst(params);
	
	new string[128];

	if(strlen(params) > SPLIT_TEXT_LIMIT)
	{
		new stext[128];

		strmid(stext, params, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
		format(string, sizeof(string), "%s mówi: %s...", sendername, stext);
		ProxDetector(6.5, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);

		strmid(stext, params, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
		format(string, sizeof(string), "%s mówi: ...%s", sendername, stext);
		ProxDetector(6.5, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
	}
	else
	{
		format(string, sizeof(string), "%s mówi: %s", sendername, params);
		ProxDetector(6.5, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
	}

	GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	printf("%s mówi: %s.", sendername, params);

	return 1;
}

dcmd_c(playerid, params[])
{
	if(!strlen(params))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: (/c)icho [Wiadomoœæ]");
		return 1;
	}

	if(PlayerInfo[playerid][pMuted] >= 1)
	{
		SendClientMessage(playerid, TEAM_CYAN_COLOR, "Nie mo¿esz rozmawiaæ, zosta³eœ wyciszony");
		return 1;
	}

	if(!CheckIsTextIC(playerid, params))
	{
		return 0;
	}
	
	new sendername[MAX_PLAYER_NAME];
	GetPlayerNameMask(playerid, sendername, sizeof(sendername));
	
	ucfirst(params);
	
	new string[128];

	if(strlen(params) > SPLIT_TEXT_LIMIT)
	{
		new stext[128];

		strmid(stext, params, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
		format(string, sizeof(string), "%s szepcze: %s...", sendername, stext);
		ProxDetector(4.0, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);

		strmid(stext, params, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
		format(string, sizeof(string), "%s szepcze: ...%s", sendername, stext);
		ProxDetector(4.0, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
	}
	else
	{
		format(string, sizeof(string), "%s szepcze: %s", sendername, params);
		ProxDetector(4.0, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
	}

	GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	printf("%s szepcze: %s.", sendername, params);

	return 1;
}

dcmd_s(playerid, params[])
{
	if(!strlen(params))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: (/k)rzyk [Wiadomoœæ]");
		return 1;
	}

	if(PlayerInfo[playerid][pMuted] >= 1)
	{
		SendClientMessage(playerid, TEAM_CYAN_COLOR, "Nie mo¿esz rozmawiaæ, zosta³eœ wyciszony");
		return 1;
	}

	if(!CheckIsTextIC(playerid, params))
	{
		return 0;
	}
	
	new sendername[MAX_PLAYER_NAME];
	GetPlayerNameMask(playerid, sendername, sizeof(sendername));
	
	ucfirst(params);
	
	new string[128];

	if(strlen(params) > SPLIT_TEXT_LIMIT)
	{
		new stext[128];

		strmid(stext, params, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
		format(string, sizeof(string), "%s krzyczy: %s...", sendername, stext);
		ProxDetector(30.0, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
		if(Injured[playerid] == 0)
		{
		ApplyAnimation(playerid, "ON_LOOKERS", "shout_in", 4.0, 0, 0, 0, 0, 0);
		return 1;
		}

		strmid(stext, params, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
		format(string, sizeof(string), "%s krzyczy: ...%s!!", sendername, stext);
		ProxDetector(30.0, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
		if(Injured[playerid] == 0)
		{
		ApplyAnimation(playerid, "ON_LOOKERS", "shout_in", 4.0, 0, 0, 0, 0, 0);
		return 1;
		}
	}
	else
	{
		format(string, sizeof(string), "%s krzyczy: %s!!", sendername, params);
		ProxDetector(30.0, playerid, string,COLOR_FADE1,COLOR_FADE2,COLOR_FADE3,COLOR_FADE4,COLOR_FADE5);
		if(Injured[playerid] == 0)
		{
		ApplyAnimation(playerid, "ON_LOOKERS", "shout_in", 4.0, 0, 0, 0, 0, 0);
		return 1;
		}
	}
	
	GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	printf("%s krzyczy: %s!!", sendername, params);

	return 1;
}

dcmd_k(playerid, params[])
{
	return dcmd_s(playerid, params);
}

dcmd_r(playerid, params[])
{
	new itemindex = GetUsedItemByItemId(playerid, ITEM_RADIO);
			
	switch(itemindex)
	{
		case INVALID_ITEM_ID:
		{
			SendClientMessage(playerid, COLOR_GREY, "Nie posiadasz radia.");
			return 1;
		}
		case HAS_UNUSED_ITEM_ID:
		{
			SendClientMessage(playerid, COLOR_GREY, "Twoje radio jest wy³¹czone. Aby je w³¹czyæ, u¿yj /przedmioty uzyj [IdPrzedmiotu].");
			return 1;
		}
	}
	
	if(!strlen(params))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: (/r)adio [wiadomoœæ]");
		return 1;
	}
	
	if(PlayerInfo[playerid][pMuted] >= 1)
	{
		SendClientMessage(playerid, TEAM_CYAN_COLOR, "Nie mo¿esz rozmawiaæ, zosta³eœ wyciszony");
		return 1;
	}

	if(!CheckIsTextIC(playerid, params))
	{
		return 0;
	}
	
	ucfirst(params);
	
	new string[128];
	
	if(strlen(params) > SPLIT_TEXT_LIMIT)
	{
		new stext[128];

		strmid(stext, params, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
		format(string, sizeof(string), "%s...", stext);
		SendRadioMessageEx(playerid, COLOR_NRADIO, Items[itemindex][iAttr1], string);

		strmid(stext, params, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
		format(string, sizeof(string), "...%s", stext);
		SendRadioMessageEx(playerid, COLOR_NRADIO, Items[itemindex][iAttr1], string);
	}
	else
	{
		format(string, sizeof(string), "%s", params);
		SendRadioMessageEx(playerid, COLOR_NRADIO, Items[itemindex][iAttr1], string);
	}

	return 1;
}

dcmd_f(playerid, params[])
{
	if(!strlen(params))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: (/f)amilia [Wiadomoœæ]");
		return 1;
	}

	if(PlayerInfo[playerid][pMuted] >= 1)
	{
		SendClientMessage(playerid, TEAM_CYAN_COLOR, "Nie mo¿esz rozmawiaæ, zosta³eœ wyciszony.");
		return 1;
	}
	
	new string[128], sendername[MAX_PLAYER_NAME];
	GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	
	ucfirst(params);

	if(GetPlayerOrganization(playerid) == 5 || GetPlayerOrganization(playerid) == 6 || GetPlayerOrganization(playerid) == 14 
	 || GetPlayerOrganization(playerid) == 15 || GetPlayerOrganization(playerid) == 16 || GetPlayerOrganization(playerid) == 19)
	{
		new rankname[32];
			
		GetPlayerOffRankName(playerid, rankname, sizeof(rankname));

		if(strlen(params) > SPLIT_TEXT_LIMIT)
		{
			new stext[128];

			strmid(stext, params, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
			format(string, sizeof(string), "** %s %s: %s... )) **", rankname, sendername,stext);
			SendFamilyMessage(GetPlayerOrganization(playerid), TEAM_AZTECAS_COLOR, string);

			strmid(stext, params, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
			format(string, sizeof(string), "** %s %s: ...%s )) **", rankname, sendername,stext);
			SendFamilyMessage(GetPlayerOrganization(playerid), TEAM_AZTECAS_COLOR, string);
		}
		else
		{
			format(string, sizeof(string), "** %s %s: %s )) **", rankname, sendername,params);
			SendFamilyMessage(GetPlayerOrganization(playerid), TEAM_AZTECAS_COLOR, string);
		}
		// minifrakcje
		
		printf("** %s %s: %s )) **", rankname, sendername,params);
		return 1;
	}
	else if(PlayerInfo[playerid][pUFLeader] < MAX_UNOFFICIAL_FACTIONS+1 || PlayerInfo[playerid][pUFMember] < MAX_UNOFFICIAL_FACTIONS+1)
	{
		new ufid = PlayerInfo[playerid][pUFMember];

		if(PlayerInfo[playerid][pUFLeader] < MAX_UNOFFICIAL_FACTIONS+1)
		{
			ufid = PlayerInfo[playerid][pUFLeader];
		}

		new rankName[64];

		switch(PlayerInfo[playerid][pRank])
		{		
			case 1: { strmid(rankName, MiniFaction[ufid][mRank1], 0, strlen(MiniFaction[ufid][mRank1]), 255); }
			case 2: { strmid(rankName, MiniFaction[ufid][mRank2], 0, strlen(MiniFaction[ufid][mRank2]), 255); }
			case 3: { strmid(rankName, MiniFaction[ufid][mRank3], 0, strlen(MiniFaction[ufid][mRank3]), 255); }
			case 4: { strmid(rankName, MiniFaction[ufid][mRank4], 0, strlen(MiniFaction[ufid][mRank4]), 255); }
			case 5: { strmid(rankName, MiniFaction[ufid][mRank5], 0, strlen(MiniFaction[ufid][mRank5]), 255); }
		}
		
		if(strlen(params) > SPLIT_TEXT_LIMIT)
		{
			new stext[128];

			strmid(stext, params, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
			format(string, sizeof(string), "** %s %s: %s... )) **", rankName, sendername,stext);
			SendNewFamilyMessage(ufid, TEAM_AZTECAS_COLOR, string);

			strmid(stext, params, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
			format(string, sizeof(string), "** %s %s: ...%s. )) **", rankName, sendername,stext);
			SendNewFamilyMessage(ufid, TEAM_AZTECAS_COLOR, string);
		}
		else
		{
			format(string, sizeof(string), "** %s %s: %s. )) **", rankName, sendername,params);
			SendNewFamilyMessage(ufid, TEAM_AZTECAS_COLOR, string);
		}
		
		printf("** %s %s: %s. )) **", rankName, sendername,params);
		return 1;
	}

	SendClientMessage(playerid, COLOR_GRAD2, "Nie mo¿esz tego zrobiæ.");
	return 1;
}


dcmd_pay(playerid, params[])
{
  new giveplayerid, sendername[MAX_PLAYER_NAME], giveplayer[MAX_PLAYER_NAME], amount, string[128];
	
	if(sscanf(params, "ud", giveplayerid, amount))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /zaplac [IdGracza/CzêœæNazwy] [Kwota]");
		return 1;
	}
	
	if(giveplayerid == INVALID_PLAYER_ID)
  {
    SendClientMessage(playerid, COLOR_GRAD2, "Ta osoba jest niedostêpna.");
    return 1;
  } 
	
	if(giveplayerid == playerid)
  {
    SendClientMessage(playerid, COLOR_GRAD2, "Nie mo¿esz zap³aciæ samemu sobie.");
		return 1;
  }
	
	if(amount < 1)
	{
		SendClientMessage(playerid, COLOR_GRAD2, "Niepoprawna kwota pieniêdzy.");
		return 1;
	}
	
	if(amount > GetPlayerMoneyEx(playerid))
	{
		CantAffordMsg(playerid, amount);
		return 1;
	}
	
	if (!DistanceBetweenPlayers(5.0, playerid, giveplayerid, true))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "Nie ma takiej osoby w pobli¿u.");
		return 1; 
	}
	
	GetPlayerNameMask(giveplayerid, giveplayer, sizeof(giveplayer));
	GetPlayerNameMask(playerid, sendername, sizeof(sendername));
	
	GivePlayerMoneyEx(playerid, -amount);
	GivePlayerMoneyEx(giveplayerid, amount);
	
	format(string, sizeof(string), "Da³eœ $%s %s.", format_number(amount), giveplayer);
	SendClientMessage(playerid, COLOR_LORANGE, string);
	
	format(string, sizeof(string), "Dosta³eœ $%s od %s.", format_number(amount), sendername);
	SendClientMessage(giveplayerid, COLOR_LORANGE, string);
	
	PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
	PlayerPlaySound(giveplayerid, 1052, 0.0, 0.0, 0.0);
	
	if(!IsPlayerBusy(playerid))	ApplyAnimation(playerid,"DEALER","shop_pay",4.1,0,0,0,0,-1);
	
	format(string, sizeof(string), "daje trochê pieniêdzy %s.", giveplayer);
	ServerMe(playerid, string);
	
	GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
	GetPlayerNameEx(playerid, sendername, sizeof(sendername));

	format(string, sizeof(string), "%s da³ $%s graczowi %s", sendername, format_number(amount), giveplayer);
	PayLog(string);

	if(PlayerInfo[playerid][pLeader] == 7)
	{
		GLog(string);
	}
	if(amount >= 1000000)
	{
		ABroadCast(COLOR_YELLOW,string,1);
	}
	
	return 1;
}

stock format_number(num, places=3)
{
	new tmp[32], tmp2[4], ret[64], ret2[64];
	
	format(tmp, sizeof(tmp), "%d", num);
	
	new j = 0;
	for(new i = strlen(tmp)-1; i >= 0; i--)
	{
		if (tmp[i] < '0' || tmp[i] > '9') continue;
		j++;
		format(tmp2, sizeof(tmp2), "%c", tmp[i]);
		strcat(ret, tmp2);
		//printf("i: %d, j: %d, tmp[%d]: %c\t| tmp2: %s\t| ret: %s", i, j, i, tmp[i], tmp2, ret);
		if(j % places == 0 && i != 0) strcat(ret, ".");
	}
	
	new idx = strlen(ret);
	
	for(new i; i<strlen(ret); i++)
	{
		ret2[i] = ret[idx-1];
		idx--;
	}

	return ret2;
}

dcmd_ro(playerid, params[])
{
	new organization = GetPlayerOrganization(playerid);
	
	if(organization != 1 && organization != 8 && organization != 10
	 && organization != 2 && organization != 7 && organization != 3 && organization != 4 && organization != 13 && organization != 17 && organization != 18 && organization != 11 && organization != 9)
	{
		SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ uprawniony do u¿ycia tej komendy!");
	  return 1;
	}

	if(!strlen(params))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: (/ro)oc [Wiadomoœæ]");
		return 1;
	}
	
	if(PlayerInfo[playerid][pMuted] >= 1)
	{
		SendClientMessage(playerid, TEAM_CYAN_COLOR, "Nie mo¿esz rozmawiaæ, zosta³eœ wyciszony");
		return 1;
	}

	ucfirst(params);
	
	new sendername[MAX_PLAYER_NAME];
	GetPlayerNameEx(playerid, sendername, sizeof(sendername));
	
	new string[128];
	
	if(strlen(params) > SPLIT_TEXT_LIMIT)
	{
		new stext[128];

		strmid(stext, params, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
		format(string, sizeof(string), "(( %s: %s... ))", sendername, stext);
		SendRadioMessage(organization, TEAM_BLUE_COLOR, string);

		strmid(stext, params, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
		format(string, sizeof(string), "(( %s: ...%s ))", sendername, stext);
		SendRadioMessage(organization, TEAM_BLUE_COLOR, string);
	}
	else
	{
		format(string, sizeof(string), "(( %s: %s ))", sendername, params);
		SendRadioMessage(organization, TEAM_BLUE_COLOR, string);
	}
	
	printf("(( %s: %s ))", sendername, params);
	
	return 1;
}

forward CheckIfDriveVehicle(vehicleid, playerid);
public CheckIfDriveVehicle(vehicleid, playerid)
{
	new vehicleindex = GetVehicleByID(vehicleid);
	new playerindex = GetPlayerById(playerid);
	new string[128];

	if(playerindex != -1)
	{
		new actvehicleindex = GetPlayerVehicleID(playerindex);
		
		if(actvehicleindex == vehicleindex && GetPlayerState(playerindex) == PLAYER_STATE_DRIVER && Vehicles[actvehicleindex][vId] == Vehicles[vehicleindex][vId])
		{
			if((!CanAccessVehicleByIndex(playerindex, vehicleindex) && Vehicles[vehicleindex][vOwnerType] != CONTENT_TYPE_USER))
			{			
				new giveplayer[MAX_PLAYER_NAME];
				
				GetPlayerNameEx(playerindex, giveplayer, sizeof(giveplayer));
				format(string, sizeof(string), "Admin: %s zosta³ zbanowany, Powód: Nieautoryzowane wejœcie do pojazdu.", giveplayer);
				SendClientMessageToAll(COLOR_LIGHTRED, string);
				PlayerInfo[playerindex][pLevel]  = 1;

				format(string, sizeof(string), "Nieautoryzowane wejœcie do pojazdu - ID pojazdu: %d (Zamkniêty: %d)", Vehicles[vehicleindex][vId], Vehicles[vehicleindex][vLocked]);
				MySQLBanPlayer(playerindex, string, 999);
			}
		}
	}
	
	return 1;
}

public OnPlayerUpdate(playerid)
{
  #if defined DISABLED_WEAPONS
  new weapon = GetPlayerWeapon(playerid);
	
  switch(weapon)
  {
    case DISABLED_WEAPONS: 
    {
      GivePlayerWeapon(playerid, weapon, -GetPlayerAmmo(playerid));
      return 0; 
    }
  }
  #endif
	
  return 1;
}

dcmd_stylwalki(playerid, params[])
{
  if(PlayerInfo[playerid][pAdmin] != 1337)
	{
		SendClientMessage(playerid, COLOR_GREY, "Nie jesteœ uprawniony do u¿ycia tej komendy!");
		return 1;
	}

	new giveplayerid, fightingstyle;

	if(sscanf(params, "ud", giveplayerid, fightingstyle))
	{
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /stylwalki [IdGracza/CzêœæNazwy] [IdStylu]");
		SendClientMessage(playerid, COLOR_GRAD2, "Poprawne style walki to: 4, 5, 6, 7, 15, 26.");
		return 1;
	}

	if(giveplayerid == INVALID_PLAYER_ID)
	{
		SendClientMessage(playerid, COLOR_GRAD2, "Ta osoba jest niedostêpna.");
		return 1;
	}
	
	if(!IsValidFightStyle(fightingstyle))
	{
		SendClientMessage(playerid, COLOR_GRAD2, "Niepoprawny styl walki.");
		return 1;
	}

	SetPlayerFightingStyle(giveplayerid, fightingstyle);
  
  return 1;
}

/*dcmd_npc(playerid, params[])
{
  if(PlayerInfo[playerid][pAdmin] != 1337)
  {
    SendClientMessage(playerid, COLOR_GRAD1, "Nie masz uprawnieñ do u¿ycia tej komendy.");
    return 1;
  }
	
	new Float:ax, Float:ay, Float:az;
	GetPlayerPos(playerid, ax, ay, az);
	
	CreateDynamic3DTextLabel("TOMASZ TO CHUJ", COLOR_PURPLE, ax, ay, az + 0.3, 10.0);
	CreatePlayer3DTextLabel(playerid, "TOMASZ TO CHUJ", COLOR_PURPLE, ax, ay, az - 0.6, 10.0);
	CreatePlayer3DTextLabel(1, "TOMASZ TO CHUJ", COLOR_PURPLE, ax, ay, az - 0.6, 10.0, playerid);
	CreatePlayer3DTextLabel(2, "TOMASZ TO CHUJ", COLOR_PURPLE, ax, ay, az - 0.6, 10.0, playerid);
	CreatePlayer3DTextLabel(3, "TOMASZ TO CHUJ", COLOR_PURPLE, ax, ay, az - 0.6, 10.0, playerid);
	CreatePlayer3DTextLabel(0, "TOMASZ TO CHUJ", COLOR_PURPLE, ax, ay, az - 0.6, 10.0, playerid);
	
	for(new i = 0; i < 1000; i++)
	{
	  CreateDynamic3DTextLabel("TOMASZ TO CHUJ", COLOR_PURPLE, ax, ay, az + 0.3, 10.0);
	}
	
	CreateDynamic3DTextLabel("TOMASZ TO CHUJ", COLOR_PURPLE, ax, ay, az + 0.3, 10.0);
	CreateDynamic3DTextLabel("TOMASZ TO CHUJ", COLOR_PURPLE, ax, ay, az - 0.3, 10.0, playerid);

  //CreateDynamic3DTextLabel("TOMEK JEST TOTALNYM CHUJEM W OCZY JEBANYM", COLOR_YELLOW2, 0.0, 0.0, 0.09, 10.0, playerid, INVALID_VEHICLE_ID, playerid);

  new command[16], idx, tmp[32], string[128];
	
	format(string, sizeof(string), "Ilosc textow: %d, state: %d", Streamer_CountVisibleItems(playerid, STREAMER_TYPE_3D_TEXT_LABEL), GetPlayerState(playerid));
	SendClientMessage(playerid, COLOR_LORANGE, string);

	tmp = strtok(params, idx);

  if(!strlen(tmp))
  {
    SendClientMessage(playerid, COLOR_LORANGE, "** NPCs **");
    SendClientMessage(playerid, COLOR_AWHITE,  "zaladuj");
    return 1;
  }

  strmid(command, tmp, 0, sizeof(tmp), sizeof(command));

  if(!strcmp(command, "zaladuj", true))
	{
    idx++;

    strmid(string, params, idx, strlen(params), 255);
    ConnectNPC("Jan_Kowalski", "Jan_Kowalski");
  }
	else if(!strcmp(command, "przedmiot", true))
	{
    static objectest = INVALID_OBJECT_ID;
		static objectestid = 0;
		
		tmp = strtok(params, idx);
		new object = strval(tmp);
		tmp = strtok(params, idx);
		new Float:x = floatstr(tmp);
		tmp = strtok(params, idx);
		new Float:y = floatstr(tmp);
		tmp = strtok(params, idx);
		new Float:z = floatstr(tmp);
		tmp = strtok(params, idx);
		new Float:rx = floatstr(tmp);
		tmp = strtok(params, idx);
		new Float:ry = floatstr(tmp);
		tmp = strtok(params, idx);
		new Float:rz = floatstr(tmp);

		new Float:zx, Float:zy, Float:zz;
		GetPlayerPos(playerid, zx, zy, zz);
		
		if(objectest != INVALID_OBJECT_ID && object != objectestid)
		{
		  DestroyDynamicObject(objectest);
			objectest = INVALID_OBJECT_ID;
		}
		
		objectestid = object;
		
		if(objectest == INVALID_OBJECT_ID)
			objectest = CreateDynamicObject(object, zx + x, zy + y, zz+z-0.6, rx, ry, rz);
			
		SetDynamicObjectPos(objectest, zx + x, zy + y, zz+z-0.6);
		SetDynamicObjectRot(objectest, rx, ry, rz);
  }
	else if(!strcmp(command, "attach", true))
	{
		tmp = strtok(params, idx);
		new object = strval(tmp);
		tmp = strtok(params, idx);
		new b = strval(tmp);
		tmp = strtok(params, idx);
		new Float:x = floatstr(tmp);
		tmp = strtok(params, idx);
		new Float:y = floatstr(tmp);
		tmp = strtok(params, idx);
		new Float:z = floatstr(tmp);
		tmp = strtok(params, idx);
		new Float:rx = floatstr(tmp);
		tmp = strtok(params, idx);
		new Float:ry = floatstr(tmp);
		tmp = strtok(params, idx);
		new Float:rz = floatstr(tmp);
		
    SetPlayerHoldingObject(playerid, object, b, x, y, z, rx, ry, rz);
  }
	else if(!strcmp(command, "skill", true))
	{
		tmp = strtok(params, idx);
		new weapon = strval(tmp);
		tmp = strtok(params, idx);
		new skill = strval(tmp);
		
    SetPlayerSkillLevel(playerid, weapon, skill);
  }
  else if(!strcmp(command, "test", true))
	{
	  ACL_AddObject(CONTENT_TYPE_USER, PlayerInfo[playerid][pId]);
		ACL_AddObjectRight(CONTENT_TYPE_USER, PlayerInfo[playerid][pId], CONTENT_TYPE_USER, 666, 1);
		printf("%d", ACL_GetObjectRight(CONTENT_TYPE_USER, PlayerInfo[playerid][pId], CONTENT_TYPE_USER, 666));
		printf("%d", ACL_GetObjectRight(CONTENT_TYPE_USER, PlayerInfo[playerid][pId], CONTENT_TYPE_USER, 11));		
	}
	else if(!strcmp(command, "akcja", true))
	{
		tmp = strtok(params, idx);
		SetPlayerSpecialAction(playerid, strval(tmp));
	}
	
	else if(!strcmp(command, "upicie", true))
	{
		tmp = strtok(params, idx);
		SetPlayerDrunkLevel(playerid, strval(tmp));
	}
	
  return 1;
}*/

dcmd_kontakt(playerid, params[])
{
	new giveplayerid;
	new itemindex = GetUsedItemByItemId(giveplayerid, ITEM_CELLPHONE);
	new Float: x2, Float: y2, Float: z2;
	if(sscanf(params, "u", giveplayerid))
	{
     	SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /kontakt [IdGracza/CzêœæNazwy]");
		return 1;
	}
	
	if(giveplayerid == INVALID_PLAYER_ID)
	{
		SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedostêpna.");
		return 1;
	}
	if(giveplayerid == playerid)
	{
		SendClientMessage(playerid, COLOR_GRAD2, "Nie mo¿esz wys³aæ kontaktu samemu sobie!");
		return 1;
	}

	switch(itemindex)
	{
		case INVALID_ITEM_ID:
		{
			SendClientMessage(giveplayerid, COLOR_GREY, "Ta osoba nie posiada telefonu.");
			return 1;
	   	}

		case HAS_UNUSED_ITEM_ID:
		{
			SendClientMessage(playerid, COLOR_GREY, "Ta osoba ma wy³¹czony telefon.");
			SendClientMessage(giveplayerid, COLOR_GREY, "Twój telefon jest wy³¹czony. Aby go w³¹czyæ, u¿yj /przedmioty uzyj [IdPrzedmiotu].");
			return 1;
		}
	}
	GetPlayerPos(giveplayerid, x2, y2, z2);
	if(!PlayerToPoint(5, playerid, x2, y2, z2))
	{
		SendClientMessage(playerid, COLOR_GRAD1, "Nie ma takiej osoby w pobli¿u!");
		return 1;
	}
	else
	{
			new str[64];
			Offering[playerid][oPlayer] = giveplayerid;
			Offering[playerid][oPlayeruid] = PlayerInfo[giveplayerid][pId];
     		Offering[playerid][oPrice] = 0;
     		Offering[playerid][oType] = OFFERING_TOUCH;
			Offering[playerid][oPrice] = 0;
			Offering[playerid][oActive] = 1;
			Offering[playerid][oValue1] = PlayerInfo[playerid][pPnumber];

			Offering[giveplayerid][oPlayer] = playerid;
			Offering[giveplayerid][oPlayeruid] = PlayerInfo[playerid][pId];
  			Offering[giveplayerid][oPrice] = 0;
  			Offering[giveplayerid][oType] = OFFERING_TOUCH;
			Offering[giveplayerid][oActive] = 1;
			Offering[giveplayerid][oValue1] = PlayerInfo[playerid][pPnumber];

			GameTextForPlayer(playerid, VCARD_MESSAGE, 2000, 3);
			if(Offering[giveplayerid][oType] == OFFERING_TOUCH)format(str, sizeof(str), "%s oferuje Ci wizytówke vcard.", pName(playerid));
			ShowPlayerDialog(giveplayerid, DIALOG_ACCEPT, DIALOG_STYLE_MSGBOX, "Oferta vcard", str, "Akceptuj", "Odrzuæ");
 	}
 return 1;
}
dcmd_waxls(playerid, params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][pAdmin] >= 1) ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_LIST, "Pomoc", "Frakcja\nOrganizacja\nFirma\nPraca\nPodstawowe komendy\nPojazdy\nPrzedmioty\nAnimacje\nKomendy administratora", "Wybierz", "Zamknij");
	else ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_LIST, "Pomoc", "Frakcja\nOrganizacja\nFirma\nPraca\nPodstawowe komendy\nPojazdy\nPrzedmioty\nAnimacje", "Wybierz", "Zamknij");
	return 1;
}
dcmd_yo(playerid, params[])
{
				new giveplayer[MAX_PLAYER_NAME],
				sendername[MAX_PLAYER_NAME],
				giveplayerid,
				str[64],
				number;
				
				if(sscanf(params, "du", number, giveplayerid))
				{
	 					SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /yo [NumerAnimacji] [IdGracza/CzêœæNazwy]");
						return 1;
				}

				if(!IsPlayerConnected(giveplayerid))
				{
  						SendClientMessage(playerid, COLOR_GREY, "Ta osoba jest niedostêpna.");
  						return 1;
				}

				if(giveplayerid == playerid)
				{
						SendClientMessage(playerid, COLOR_GRAD2, "Nie mo¿esz u¿ywaæ animacji z samym sob¹!");
						return 1;
				}

 				if(GetDistanceBetweenPlayers(playerid, giveplayerid) > 1.5)
 	 			{
 			  			SendClientMessage(playerid, COLOR_GRAD1, "Nie ma takiej osoby w pobli¿u.");
 	  			 		return 1;
 	  			}
				GetPlayerNameEx(playerid, sendername, sizeof(sendername));
				GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));

				if(!IsPlayerFacingPlayer(playerid, giveplayerid, 20))
    			{
				    	SendClientMessage(playerid, COLOR_GRAD2, "Nie patrzysz siê w stronê tego gracza.");
				    	return 1;
				}
				if(number == 1)
				{
     					Offering[playerid][oPlayer] = giveplayerid;
						Offering[playerid][oPlayeruid] = PlayerInfo[giveplayerid][pId];
						Offering[playerid][oActive] = 1;

  						Offering[playerid][oPrice] = 0;
    					Offering[playerid][oType] = OFFERING_ANIM;
    					Offering[playerid][oValue1] = ANIM_YO;

      					Offering[giveplayerid][oActive] = 1;
       					Offering[giveplayerid][oPlayer] = playerid;
						Offering[giveplayerid][oPlayeruid] = PlayerInfo[playerid][pId];

  						Offering[giveplayerid][oPrice] = 0;
  						Offering[giveplayerid][oType] = OFFERING_ANIM;
    					Offering[giveplayerid][oValue1] = ANIM_YO;

						if(Offering[giveplayerid][oType] == OFFERING_ANIM) format(str, sizeof(str), "%s oferuje Ci u¿ycie animacji.", pName(playerid));
						ShowPlayerDialog(giveplayerid, DIALOG_ACCEPT, DIALOG_STYLE_MSGBOX, "Animacja", str,"Akceptuj","Odrzuæ");
						//SendClientMessage(playerid, COLOR_OOC, ANIM_MESSAGE);
				}
				else if(number == 2)
				{
      					Offering[playerid][oPlayer] = giveplayerid;
						Offering[playerid][oPlayeruid] = PlayerInfo[giveplayerid][pId];
						Offering[playerid][oActive] = 1;

  						Offering[playerid][oPrice] = 0;
    					Offering[playerid][oType] = OFFERING_ANIM2;
    					Offering[playerid][oValue1] = ANIM_YO2;

      					Offering[giveplayerid][oActive] = 1;
       					Offering[giveplayerid][oPlayer] = playerid;
						Offering[giveplayerid][oPlayeruid] = PlayerInfo[playerid][pId];

  						Offering[giveplayerid][oPrice] = 0;
  						Offering[giveplayerid][oType] = OFFERING_ANIM2;
    					Offering[giveplayerid][oValue1] = ANIM_YO2;

						if(Offering[giveplayerid][oType] == OFFERING_ANIM2) format(str, sizeof(str), "%s oferuje Ci u¿ycie animacji.", pName(playerid));
						ShowPlayerDialog(giveplayerid, DIALOG_ACCEPT, DIALOG_STYLE_MSGBOX, "Animacja", str,"Akceptuj","Odrzuæ");
						//SendClientMessage(playerid, COLOR_OOC, ANIM_MESSAGE);
				}
				else if(number == 3)
				{
      					Offering[playerid][oPlayer] = giveplayerid;
						Offering[playerid][oPlayeruid] = PlayerInfo[giveplayerid][pId];
						Offering[playerid][oActive] = 1;

  						Offering[playerid][oPrice] = 0;
    					Offering[playerid][oType] = OFFERING_ANIM3;
    					Offering[playerid][oValue1] = ANIM_YO3;

      					Offering[giveplayerid][oActive] = 1;
       					Offering[giveplayerid][oPlayer] = playerid;
						Offering[giveplayerid][oPlayeruid] = PlayerInfo[playerid][pId];

  						Offering[giveplayerid][oPrice] = 0;
  						Offering[giveplayerid][oType] = OFFERING_ANIM3;
    					Offering[giveplayerid][oValue1] = ANIM_YO3;

						if(Offering[giveplayerid][oType] == OFFERING_ANIM3) format(str, sizeof(str), "%s oferuje Ci u¿ycie animacji.", pName(playerid));
						ShowPlayerDialog(giveplayerid, DIALOG_ACCEPT, DIALOG_STYLE_MSGBOX, "Animacja", str,"Akceptuj","Odrzuæ");
						//SendClientMessage(playerid, COLOR_OOC, ANIM_MESSAGE);
				}
				else if(number == 4)
				{
      					Offering[playerid][oPlayer] = giveplayerid;
						Offering[playerid][oPlayeruid] = PlayerInfo[giveplayerid][pId];
						Offering[playerid][oActive] = 1;

  						Offering[playerid][oPrice] = 0;
    					Offering[playerid][oType] = OFFERING_ANIM4;
    					Offering[playerid][oValue1] = ANIM_YO4;

      					Offering[giveplayerid][oActive] = 1;
       					Offering[giveplayerid][oPlayer] = playerid;
						Offering[giveplayerid][oPlayeruid] = PlayerInfo[playerid][pId];

  						Offering[giveplayerid][oPrice] = 0;
  						Offering[giveplayerid][oType] = OFFERING_ANIM4;
    					Offering[giveplayerid][oValue1] = ANIM_YO4;

						if(Offering[giveplayerid][oType] == OFFERING_ANIM4) format(str, sizeof(str), "%s oferuje Ci u¿ycie animacji.", pName(playerid));
						ShowPlayerDialog(giveplayerid, DIALOG_ACCEPT, DIALOG_STYLE_MSGBOX, "Animacja", str,"Akceptuj","Odrzuæ");
						//SendClientMessage(playerid, COLOR_OOC, ANIM_MESSAGE);
				}
				else if(number == 5)
				{
      					Offering[playerid][oPlayer] = giveplayerid;
						Offering[playerid][oPlayeruid] = PlayerInfo[giveplayerid][pId];
						Offering[playerid][oActive] = 1;

  						Offering[playerid][oPrice] = 0;
    					Offering[playerid][oType] = OFFERING_ANIM5;
    					Offering[playerid][oValue1] = ANIM_YO5;

      					Offering[giveplayerid][oActive] = 1;
       					Offering[giveplayerid][oPlayer] = playerid;
						Offering[giveplayerid][oPlayeruid] = PlayerInfo[playerid][pId];

  						Offering[giveplayerid][oPrice] = 0;
  						Offering[giveplayerid][oType] = OFFERING_ANIM5;
    					Offering[giveplayerid][oValue1] = ANIM_YO5;

						if(Offering[giveplayerid][oType] == OFFERING_ANIM5) format(str, sizeof(str), "%s oferuje Ci u¿ycie animacji.", pName(playerid));
						ShowPlayerDialog(giveplayerid, DIALOG_ACCEPT, DIALOG_STYLE_MSGBOX, "Animacja", str,"Akceptuj","Odrzuæ");
						//SendClientMessage(playerid, COLOR_OOC, ANIM_MESSAGE);
				}
				else if(number == 6)
				{
      					Offering[playerid][oPlayer] = giveplayerid;
						Offering[playerid][oPlayeruid] = PlayerInfo[giveplayerid][pId];
						Offering[playerid][oActive] = 1;

  						Offering[playerid][oPrice] = 0;
    					Offering[playerid][oType] = OFFERING_ANIM6;
    					Offering[playerid][oValue1] = ANIM_YO6;

      					Offering[giveplayerid][oActive] = 1;
       					Offering[giveplayerid][oPlayer] = playerid;
						Offering[giveplayerid][oPlayeruid] = PlayerInfo[playerid][pId];

  						Offering[giveplayerid][oPrice] = 0;
  						Offering[giveplayerid][oType] = OFFERING_ANIM6;
    					Offering[giveplayerid][oValue1] = ANIM_YO6;

						if(Offering[giveplayerid][oType] == OFFERING_ANIM6) format(str, sizeof(str), "%s oferuje Ci u¿ycie animacji.", pName(playerid));
						ShowPlayerDialog(giveplayerid, DIALOG_ACCEPT, DIALOG_STYLE_MSGBOX, "Animacja", str,"Akceptuj","Odrzuæ");
						//SendClientMessage(playerid, COLOR_OOC, ANIM_MESSAGE);
				}
				else if(number == 7)
				{
      					Offering[playerid][oPlayer] = giveplayerid;
						Offering[playerid][oPlayeruid] = PlayerInfo[giveplayerid][pId];
						Offering[playerid][oActive] = 1;

  						Offering[playerid][oPrice] = 0;
    					Offering[playerid][oType] = OFFERING_ANIM7;
    					Offering[playerid][oValue1] = ANIM_YO7;

      					Offering[giveplayerid][oActive] = 1;
       					Offering[giveplayerid][oPlayer] = playerid;
						Offering[giveplayerid][oPlayeruid] = PlayerInfo[playerid][pId];

  						Offering[giveplayerid][oPrice] = 0;
  						Offering[giveplayerid][oType] = OFFERING_ANIM7;
    					Offering[giveplayerid][oValue1] = ANIM_YO7;

						if(Offering[giveplayerid][oType] == OFFERING_ANIM7) format(str, sizeof(str), "%s oferuje Ci u¿ycie animacji.", pName(playerid));
						ShowPlayerDialog(giveplayerid, DIALOG_ACCEPT, DIALOG_STYLE_MSGBOX, "Animacja", str,"Akceptuj","Odrzuæ");
						//SendClientMessage(playerid, COLOR_OOC, ANIM_MESSAGE);
				}
   return 1;
}


forward AnticheatTimer();
public AnticheatTimer()
{
  new Float:x, Float:y, Float:z;
	new string[80], str[315], giveplayerid;
  for(new i = 0; i < MAX_PLAYERS; i++)
  {
    if(IsPlayerConnected(i) && GetPlayerState(i) == PLAYER_STATE_DRIVER)
    {
      GetVehicleVelocity(GetPlayerVehicleID(i), x, y, z);
      if(floatabs(x + y + z) > 5.0)
      {
			  new playername[MAX_PLAYER_NAME];
				GetPlayerNameEx(i, playername, sizeof(playername));
				//format(string, sizeof(string), "Admin: %s zosta³ zbanowany, Powód: Warp kill", playername);
				format(string, sizeof(string), "~>~ System ~<~ ~r~%s ~w~zostal zbanowany, ~w~Powod: ~r~Warp kill", playername);
   	 			TextDrawSetString(Kara, string);
	 			TextDrawShowForAll(Kara);
	 			KillTimer(KaraTD);
	 			KaraTD = SetTimer("textkara", 10000, 0);
	 			format(str, sizeof(str), "Zosta³eœ zbanowany przez: {9e1e1e}System, {a9c4e4}Powód: {9e1e1e}Warp kill \n\n{9e1e1e}UWAGA:\n{a9c4e4}Jeœli kara by³a nies³uszna mo¿esz siê odwo³aæ na forum w odpowienim dziale.\nPamiêtaj równie¿ o screenie, który jest niezbêdny do apelacji.");
	            ShowPlayerDialog(giveplayerid, DIALOG_GUN_FOR_PLAYER, DIALOG_STYLE_MSGBOX, "Ban", str,"Zamknij", "");
	            TextDrawHideForPlayer(giveplayerid, Kara);
				//SendClientMessageToAll(COLOR_LIGHTRED, string);

				format(string, sizeof(string), "Warp kill (%f, %f, %f)", x, y, z);

				PlayerInfo[i][pLevel] = 1;
				PlayerInfo[i][pMember] = 0;
				PlayerInfo[i][pLeader] = 0;
				MySQLBanPlayer(i, "Warp kill", 999);
      }
     }
	}
}

SetPlayerPosEx(playerid,Float:x,Float:y,Float:z)
{
  if(PlayerInfo[playerid][pInteriorAudio] > 0) Audio_Stop(playerid, PlayerInfo[playerid][pInteriorAudio]);
	SetPlayerPos(playerid,x,y,z);
	Streamer_Update(playerid);
}
stock pName(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, MAX_PLAYER_NAME);
    for(new i=strlen(name); i > 0; i--)
    if(name[i] == '_') name[i] = ' ';
    return name;
}

PreloadAnimLib(playerid, animlib[])
{
    ApplyAnimation(playerid,animlib,"null",0.0,0,0,0,0,0);
}

stock SendClientMessageEx(Float:radi, playerid, string[], col1, col2, col3, col4, col5, echo=0)
{
	if(IsPlayerConnected(playerid))
	{
		new Float:posx, Float:posy, Float:posz;
		new Float:oldposx, Float:oldposy, Float:oldposz;
		new Float:tempposx, Float:tempposy, Float:tempposz;
		GetPlayerPos(playerid, oldposx, oldposy, oldposz);
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
		 if(IsPlayerConnected(i))
		 {
			if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i))
			{
	        		if(echo == 0)
	        		{
					GetPlayerPos(i, posx, posy, posz);
					tempposx = (oldposx -posx);
					tempposy = (oldposy -posy);
					tempposz = (oldposz -posz);
					if (((tempposx < radi/16) && (tempposx > -radi/16)) && ((tempposy < radi/16) && (tempposy > -radi/16)) && ((tempposz < radi/16) && (tempposz > -radi/16)))
						SendClientMessage(i, col1, string);
					else if (((tempposx < radi/8) && (tempposx > -radi/8)) && ((tempposy < radi/8) && (tempposy > -radi/8)) && ((tempposz < radi/8) && (tempposz > -radi/8)))
						SendClientMessage(i, col2, string);
					else if (((tempposx < radi/4) && (tempposx > -radi/4)) && ((tempposy < radi/4) && (tempposy > -radi/4)) && ((tempposz < radi/4) && (tempposz > -radi/4)))
						SendClientMessage(i, col3, string);
					else if (((tempposx < radi/2) && (tempposx > -radi/2)) && ((tempposy < radi/2) && (tempposy > -radi/2)) && ((tempposz < radi/2) && (tempposz > -radi/2)))
						SendClientMessage(i, col4, string);
					else if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
						SendClientMessage(i, col5, string);

				    }
					else if(echo == 1)
				  {
					if(i != playerid)
					{
						GetPlayerPos(i, posx, posy, posz);
						tempposx = (oldposx -posx);
						tempposy = (oldposy -posy);
						tempposz = (oldposz -posz);
						if (((tempposx < radi/16) && (tempposx > -radi/16)) && ((tempposy < radi/16) && (tempposy > -radi/16)) && ((tempposz < radi/16) && (tempposz > -radi/16)))
							SendClientMessage(i, col1, string);
						else if (((tempposx < radi/8) && (tempposx > -radi/8)) && ((tempposy < radi/8) && (tempposy > -radi/8)) && ((tempposz < radi/8) && (tempposz > -radi/8)))
							SendClientMessage(i, col2, string);
						else if (((tempposx < radi/4) && (tempposx > -radi/4)) && ((tempposy < radi/4) && (tempposy > -radi/4)) && ((tempposz < radi/4) && (tempposz > -radi/4)))
							SendClientMessage(i, col3, string);
						else if (((tempposx < radi/2) && (tempposx > -radi/2)) && ((tempposy < radi/2) && (tempposy > -radi/2)) && ((tempposz < radi/2) && (tempposz > -radi/2)))
							SendClientMessage(i, col4, string);
						else if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
							SendClientMessage(i, col5, string);
					}
				  }
			}
		}
	}
 }
 return 1;
}

