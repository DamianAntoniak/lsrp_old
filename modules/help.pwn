#define MAX_COMMAND 36
#define NEW_HELP 1

dcmd_help(playerid, params[])
{
  #pragma unused params
  ShowHelpSelectDialog(playerid);
  
  return 1;
}

stock ShowHelpSelectDialog(playerid)
{
  ShowPlayerDialog(playerid,DIALOG_HELP_SELECT,DIALOG_STYLE_MSGBOX,"Pomoc","Chcesz zobaczyæ listê dostêpnych komend \nczy wyszukaæ konkretn¹ komendê?","Lista","Szukaj");
}

stock ShowHelpListDialog(playerid)
{
  new string[1024], buffor[1024], line[MAX_COMMAND], charsleft = 1024;
  
  mysql_query("SELECT `command` FROM `help_content` ORDER BY `command` ASC");
  mysql_store_result();
  
  while (mysql_fetch_row_format(line) == 1)
  {
    buffor = string;
    charsleft = charsleft - strlen(line) - 2;
    format(string,sizeof(string),"%s\n%s",buffor,line);
    
    if (charsleft<=0) break;
  }
  mysql_free_result();
  
  ShowPlayerDialog(playerid,DIALOG_HELP_LIST,DIALOG_STYLE_LIST,"Pomoc -> Dostêpne komendy",string,"Wiêcej","Anuluj");
}

stock ShowHelpInfoDialog(playerid, command[])
{
  new query[90+MAX_COMMAND*2], line[MAX_STRING], title[40 + MAX_COMMAND],commandsafe[MAX_COMMAND];
	mysql_real_escape_string(command,commandsafe);
  format(query,sizeof(query),"SELECT `description` FROM `help_content` WHERE `command`= '%s' OR `altcommand`= '%s'",commandsafe,commandsafe);
  mysql_query(query);
  mysql_store_result();
  
  if (mysql_num_rows() <= 0){ line = "Brak danych lub taka komenda nie istnieje."; title = "Pomoc -> Informacje o komendzie -> B³¹d";}
  else { mysql_fetch_row_format(line); format (title,sizeof(title),"Pomoc -> Informacje o komendzie -> '%s'",command); }
  
  mysql_free_result();
  
  new offset = strfind(line,"|");
  
  while (offset != -1)
  {  
    strdel(line,offset,offset+1);
    strins(line,"\n",offset,1);
    offset = strfind(line,"|");
  }
	
  ShowPlayerDialog(playerid,DIALOG_HELP_DESCRIPTION,DIALOG_STYLE_MSGBOX,title,line,"Powrót","Anuluj");
}

stock ShowHelpSearchDialog(playerid)
{
  ShowPlayerDialog(playerid,DIALOG_HELP_SEARCH,DIALOG_STYLE_INPUT,"Pomoc -> Wyszukiwarka komend","Wpisz szukan¹ komende (np. '/help')","Szukaj","Anuluj");
}

//------------------------------------------------- OLD COMMAND -------------------------------------------------------------------------------------------

#if !NEW_HELP

dcmd_help(playerid, params[])
{
	#pragma unused params
 
	SendClientMessage(playerid, COLOR_LORANGE, "** Pomocne komendy **");
	SendClientMessage(playerid, COLOR_AWHITE,"(/w)iadomosc (/o)oc (/k)rzycz (/dk)rzycz (/c)icho (/l)okalny (/b) /do (/f) /ja /anim /stylrozmowy /stats");
	SendClientMessage(playerid, COLOR_AWHITE,"/(z)ap³aæ /dotacja /kup /koniecwynajmu /id /pokazlicencje /zamknij /skill /licencje /zmianaspawnu");
	SendClientMessage(playerid, COLOR_AWHITE,"/wepchnij /pokazdowod /raport /anuluj /akceptuj /wyrzuc /uzyjnarkotyki /tankuj /kanister /oczysc /wezwij");
	SendClientMessage(playerid, COLOR_AWHITE,"/balans /wyplac /depozyt /przelej /przedmioty /pojazd /togf /togwhisper /ignoruj /ukryjnicki");
	SendClientMessage(playerid, COLOR_AWHITE,"/telefonpomoc /dompomoc /autopomoc /wynajempomoc /firma /liderpomoc /lowieniepomoc /radiopomoc");
	
	switch(PlayerInfo[playerid][pJob])
	{
		case 1:  { SendClientMessage(playerid, COLOR_AWHITE, "/szukaj"); }
		case 2:  { SendClientMessage(playerid, COLOR_AWHITE, "/uwolnij"); }
		case 4:  { SendClientMessage(playerid, COLOR_AWHITE, "/sprzedajdragi"); }
		case 5:  { SendClientMessage(playerid, COLOR_AWHITE, "/dropcar"); }
		case 7:  { SendClientMessage(playerid, COLOR_AWHITE, "/live /news [tekst]"); }
		case 8:  { SendClientMessage(playerid, COLOR_AWHITE, "/ochrona"); }
		case 10: { SendClientMessage(playerid, COLOR_AWHITE, "/sprzedaj"); }
		case 12: { SendClientMessage(playerid, COLOR_AWHITE, "/walka /boxstats"); }
		case 15: { SendClientMessage(playerid, COLOR_AWHITE, "/odbierzgazety /dostarcz"); }
		case 16: { SendClientMessage(playerid, COLOR_AWHITE, "/okradnij"); }
		case 17: { SendClientMessage(playerid, COLOR_AWHITE, "/zamowienia"); }
 }
	
	switch(GetPlayerOrganization(playerid))
	{
		case 1:
		{
			SendClientMessage(playerid, COLOR_LORANGE, "** Komendy organizacji **");
			SendClientMessage(playerid, COLOR_AWHITE, "(/r)adio (/d)epartament (/m)egafon (/po)dejrzany /kartoteka /aresztuj /sluzba /poszukiwani /zakuj /tazer");
			SendClientMessage(playerid, COLOR_AWHITE, "/przeszukaj /wepchnij /zabierz /mandat (/gov)ernment /dostarcz /kamera /ram /(ro)oc");
		}

		case 4:
		{
			SendClientMessage(playerid, COLOR_LORANGE, "** Komendy organizacji **");
			SendClientMessage(playerid, COLOR_AWHITE, "(/r)adio (/d)epartments /ulecz /duty /reanimuj");
		}

		case 10:
		{
			SendClientMessage(playerid, COLOR_LORANGE, "** Komendy organizacji **");
			SendClientMessage(playerid, COLOR_AWHITE, "/fare");
		}

		case 11:
		{
			SendClientMessage(playerid, COLOR_LORANGE, "** Komendy organizacji **");
			SendClientMessage(playerid, COLOR_AWHITE, "/zacznijegzamin /zakonczegzamin /dajlicencje");
		}
	}
	
	return 1;
}

#endif