#define MAX_BETS 200
#define UNUSED_BET 0
#define USED_BET 1
#define INVALID_BET_INDEX -1
#define MAX_BET_MEMBERS 15

#define BET_ID_RACE 1

enum ebBet {
 ebId,
 ebUsed,
 ebName[64],
 ebMaker, // id gracza
 ebTill,
 ebStake,
 ebMaxMembers,
 Float:ebCommission,
 Float:ebPrizes[MAX_BET_MEMBERS]
}
 
new Bets[MAX_BETS][ebBet];

enum ebMemberBet {
 ebmBetIndex,
 ebmPlace,  // miejsce po wygraniu, u¿ywane do obliczania kwoty nagrody
 ebmGotMoney,
 ebmData[5]
}

new BetMembers[MAX_PLAYERS][ebMemberBet];

forward CreateBet(playerid, Bet[ebBet], name[]);
public CreateBet(playerid, Bet[ebBet], name[])
{
 if(CountPlayerBets(playerid) > 0)
 {
  return -1;
 }
 
 Bet[ebUsed] = USED_BET;
 Bet[ebMaker] = PlayerInfo[playerid][pId];

 new betindex = InsertBet(Bet);
 
 strmid(Bets[betindex][ebName], name, 0, strlen(name), 255);
 
 return betindex;
}

forward ShowBetInfo(betindex, giveplayerid);
public ShowBetInfo(betindex, giveplayerid)
{
 new line[128];

 format(line, sizeof(line), "* Informacje o zak³adzie: (ID: %d) %s", betindex, Bets[betindex][ebName]);
 SendClientMessage(giveplayerid, COLOR_LORANGE, line);

 
 new playername[MAX_PLAYER_NAME];
 
 new makerindex = GetPlayerById(Bets[betindex][ebMaker]);
 
 if(makerindex == INVALID_PLAYER_ID)
 {
  playername = "Niedostêpny";
 }
 else
 {
  GetPlayerNameEx(makerindex, playername, sizeof(playername));
 }

 format(line, sizeof(line), "Stawka: [$%d] Pula: [$%d] Prowizja dla tworz¹cego zak³ad: [%.2f]", Bets[betindex][ebStake], Bets[betindex][ebTill], Bets[betindex][ebCommission]);
 SendClientMessage(giveplayerid, COLOR_AWHITE, line);
 format(line, sizeof(line), "Tworz¹cy zak³ad: [%s] Iloœæ cz³onków: [%d/%d]", playername, GetBetMembersCount(betindex), Bets[betindex][ebMaxMembers]);
 SendClientMessage(giveplayerid, COLOR_AWHITE, line);
 
 new line2[32];
 
 format(line, sizeof(line), "[Nagrody] ");
 
 new prizes = 1;
 
 for(new i = 0; i < MAX_BET_MEMBERS; i++)
 {
  if(Bets[betindex][ebPrizes][i] > 0.0)
  {
   if(prizes > 1) strcat(line, ", ");
   
   format(line2, sizeof(line2), "%d. %.2f", i+1, Bets[betindex][ebPrizes][i]);
   strcat(line, line2);

   prizes++;
  }
 }
 
 SendClientMessage(giveplayerid, COLOR_AWHITE, line);
 
 return 1;
}

forward InvitePlayerToBet(playerid, giveplayerid, betindex);
public InvitePlayerToBet(playerid, giveplayerid, betindex)
{
 if(BetMembers[giveplayerid][ebmBetIndex] != INVALID_BET_INDEX)
 {
  return -1; // ma ju¿ zak³ad
 }

 if(!DoesBetExist(betindex))
 {
  return -2; // nie istnieje
 }
 
 new noffer[oOfferEnum];
		
 noffer[ofId] = OFFER_ID_BET;
 noffer[ofType] = OFFER_TYPE_PAYMENT;
 noffer[ofValue1] = betindex;
 noffer[ofPrice] = Bets[betindex][ebStake];
 noffer[ofOfferer] = PlayerInfo[playerid][pId];
 noffer[ofOffererType] = CONTENT_TYPE_USER;
 noffer[ofFlags] = OFFER_FLAG_CHECK_DISTANCE + OFFER_FLAG_SINGLE_TRANSACTION + OFFER_FLAG_CAN_OFFER_HIMSELF + OFFER_FLAG_INFO_COMMAND;

 ServicePopUp(giveplayerid, "Zak³ad", noffer);
 
 return 1;
}

forward QuitBet(playerid);
public QuitBet(playerid)
{
 BetMembers[playerid][ebmBetIndex] = INVALID_BET_INDEX;
 
 return 1;
}

forward PlayerFinishBet(playerid, betindex);
public PlayerFinishBet(playerid, betindex)
{
 if(Bets[betindex][ebUsed] == UNUSED_BET) return 0;
 
 new string[128];
 
 for(new i = 0; i < MAX_BET_MEMBERS; i++)
 {
  if(Bets[betindex][ebPrizes][i] > 0.0 && (i + 1) == BetMembers[playerid][ebmPlace])
  {
   if(floatround(Bets[betindex][ebTill] * Bets[betindex][ebPrizes][i]) <= 0) break;
   
   GivePlayerMoneyEx(playerid, floatround(Bets[betindex][ebTill] * Bets[betindex][ebPrizes][i]));

   format(string, sizeof(string), "Dosta³eœ $%d w ramach nagrody w zak³adzie.", floatround(Bets[betindex][ebTill] * Bets[betindex][ebPrizes][i]));
   SendClientMessage(playerid, COLOR_GREY, string);

   break;
  }
 }
 
 BetMembers[playerid][ebmPlace] = 0;
 
 return 1;
}

forward FinishBet(betindex);
public FinishBet(betindex)
{
 if(Bets[betindex][ebUsed] == UNUSED_BET) return 0;

 new string[128];
 
 for(new i = 0; i < MAX_BET_MEMBERS; i++)
 {
  if(Bets[betindex][ebPrizes][i] > 0.0)
  {
   for(new j = 0; j < sizeof(BetMembers); j++)
   {
    if(IsPlayerConnected(j) && BetMembers[j][ebmBetIndex] == betindex && (i + 1) == BetMembers[j][ebmPlace] && BetMembers[j][ebmPlace] > 0)
    {
     if(floatround(Bets[betindex][ebTill] * Bets[betindex][ebPrizes][i]) <= 0) continue;

     GivePlayerMoneyEx(j, floatround(Bets[betindex][ebTill] * Bets[betindex][ebPrizes][i]));
     
     format(string, sizeof(string), "Dosta³eœ $%d w ramach nagrody w zak³adzie.", floatround(Bets[betindex][ebTill] * Bets[betindex][ebPrizes][i]));
     SendClientMessage(j, COLOR_GREY, string);
    }
   }
  }
 }
 
 for(new i = 0; i < sizeof(BetMembers); i++)
 {
  if(BetMembers[i][ebmBetIndex] == betindex) BetMembers[i][ebmBetIndex] = INVALID_BET_INDEX;
 }
 
 Bets[betindex][ebUsed] = UNUSED_BET;

 return 1;
}

forward CountPlayerBets(playerid);
public CountPlayerBets(playerid)
{
 new count;
 
 for(new i = 0; i < sizeof(Bets); i++)
 {
  if(Bets[i][ebMaker] == PlayerInfo[playerid][pId] && Bets[i][ebUsed] == USED_BET)
  {
   count++;
  }
 }

 return count;
}

forward GetBetMembersCount(betindex);
public GetBetMembersCount(betindex)
{
 new count;

 for(new i = 0; i < sizeof(BetMembers); i++)
 {
  if(IsPlayerConnected(i) && BetMembers[i][ebmBetIndex] == betindex)
  {
   count++;
  }
 }

 return count;
}

// przepisaæ
forward GetMadeByPlayerBet(playerid);
public GetMadeByPlayerBet(playerid)
{
 for(new i = 0; i < sizeof(Bets); i++)
 {
  if(Bets[i][ebMaker] == PlayerInfo[playerid][pId] && Bets[i][ebUsed] == USED_BET)
  {
   return i;
  }
 }

 return INVALID_BET_INDEX;
}

forward DoesBetExist(betindex);
public DoesBetExist(betindex)
{
 for(new i = 0; i < sizeof(Bets); i++)
 {
  if(betindex == i && Bets[i][ebUsed] == USED_BET)
  {
   return 1;
  }
 }
 
 return 0;
}

forward InsertBet(Bet[ebBet]);
public InsertBet(Bet[ebBet])
{
 for(new i = 0; i < sizeof(Bets); i++)
 {
  if(Bets[i][ebUsed] == UNUSED_BET)
  {
   Bets[i] = Bet;
   return i;
  }
 }
 
 return INVALID_BET_INDEX;
}

forward InitBets();
public InitBets()
{
 for(new i = 0; i < sizeof(Bets); i++)
 {
  Bets[i][ebUsed] = UNUSED_BET;
 }

 for(new i = 0; i < sizeof(BetMembers); i++)
 {
  BetMembers[i][ebmBetIndex] = INVALID_BET_INDEX;
 }
}

dcmd_zaklad(playerid, params[])
{
 new command[16], tmp[32], idx;

 tmp = strtok(params, idx);

 if(!strlen(tmp))
 {
 	SendClientMessage(playerid, COLOR_LORANGE, "** Zak³ady **");
	 SendClientMessage(playerid, COLOR_AWHITE,  "stworz, zapros");
 	return 1;
 }

 strmid(command, tmp, 0, sizeof(tmp), sizeof(command));

 if(!strcmp(command, "stworz", true))
	{
	 tmp = strtok(params, idx);

  if(!strlen(tmp))
	 {
	 	SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /zaklad stworz [Stawka]");
	 	return 1;
	 }

  new stake = strval(tmp);
  
  new Bet[ebBet];
  Bet[ebStake] = stake;
  
  new betindex = CreateBet(playerid, Bet, "Wyscig");
  
  Bets[betindex][ebPrizes][0] = 0.5;
  Bets[betindex][ebPrizes][1] = 0.2;
  Bets[betindex][ebPrizes][2] = 0.1;
  
  return 1;
	}
	else if(!strcmp(command, "info", true))
	{
	 new betindex = GetMadeByPlayerBet(playerid);
	 
	 ShowBetInfo(betindex, playerid);
	}
	else if(!strcmp(command, "zapros", true))
	{
	 if(CountPlayerBets(playerid) == 0)
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Nie masz ¿adnego zak³adu.");
   return 1;
  }
  
  if(GetBetMembersCount(GetMadeByPlayerBet(playerid)) >= MAX_BET_MEMBERS)
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Nie mo¿esz zaprosiæ wiêkszej iloœci osób do zak³adu.");
   return 1;
  }
	 
	 tmp = strtok(params, idx);

  if(!strlen(tmp))
	 {
	 	SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /zaklad zapros [IdGracza/CzêœæNazwy]");
	 	return 1;
	 }

  new giveplayerid = ReturnUser(tmp);
 
  InvitePlayerToBet(playerid, giveplayerid, GetMadeByPlayerBet(playerid));
	}
	
	return 1;
}

forward SendMessageToBetMembers(betindex, string[]);
public SendMessageToBetMembers(betindex, string[])
{
 for(new i = 0; i < MAX_PLAYERS; i++)
 {
  if(IsPlayerConnected(i) && BetMembers[i][ebmBetIndex] == betindex)
  {
   SendClientMessage(i, COLOR_GREY, string);
  }
 }
 
 new memberindex = GetPlayerById(Bets[betindex][ebMaker]);
 
 if(memberindex != INVALID_PLAYER_ID) SendClientMessage(memberindex, COLOR_GREY, string);
 
 return 1;
}

forward Bets_OnPlayerDisconnect(playerid, reason);
public Bets_OnPlayerDisconnect(playerid, reason)
{
 new betindex = BetMembers[playerid][ebmBetIndex];

 if(betindex != INVALID_BET_INDEX)
 {
  BetMembers[playerid][ebmBetIndex] = INVALID_BET_INDEX;
 
  new playername[MAX_PLAYER_NAME];
  new string[128];
 
  GetPlayerNameEx(playerid, playername, sizeof(playername));
 
  format(string, sizeof(string), "%s opuœci³ zak³ad (crash).", playername);
  SendMessageToBetMembers(betindex, string);
 }
 
 return 1;
}

