new Menu:OfferMenu_YesNo;
new Menu:OfferMenu_Payment;
new OfferMenuCreated = 0;
new OfferTextdrawsCreated = 0;

stock AbortOffer(playerid)
{
  TextDrawHideForPlayer(playerid, OfferTextDraw[playerid]);
  Offer[playerid][ofId] = INVALID_OFFER_ID;
}

forward InitOffers();
public InitOffers()
{
  for(new i = 0; i < sizeof(Offer); i++)
  {
    Offer[i][ofId] = INVALID_OFFER_ID;
  }

  if(OfferMenuCreated == 0)
  {
    OfferMenu_YesNo = CreateMenu("Oferta",1,80,150,180,25);

    AddMenuItem(OfferMenu_YesNo,0,"Odrzuc");
    AddMenuItem(OfferMenu_YesNo,0,"Akceptuj");

    OfferMenu_Payment = CreateMenu("Oferta",1,80,150,180,25);

    AddMenuItem(OfferMenu_Payment,0,"Odrzuc");
    AddMenuItem(OfferMenu_Payment,0,"Akceptuj (Gotowka)");
    AddMenuItem(OfferMenu_Payment,0,"Akceptuj (Karta platnicza)");

    OfferMenuCreated = 1;
  }

  if(OfferTextdrawsCreated == 0)
  {
    for(new i = 0; i < sizeof(OfferTextDraw); i++)
    {
      OfferTextDraw[i] = TextDrawCreate(148.000000, 342.000000, "foo");

      TextDrawUseBox(OfferTextDraw[i], 1);
      TextDrawBoxColor(OfferTextDraw[i], 0x00000033);
      TextDrawTextSize(OfferTextDraw[i], 490.000000,282.000000);
      TextDrawAlignment(OfferTextDraw[i], 1);
      TextDrawBackgroundColor(OfferTextDraw[i], 0x000000ff);
      TextDrawFont(OfferTextDraw[i], 1);
      TextDrawLetterSize(OfferTextDraw[i], 0.299999, 1.000000);
      TextDrawColor(OfferTextDraw[i], 0xffffffff);
      TextDrawSetOutline(OfferTextDraw[i], 1);
      TextDrawSetProportional(OfferTextDraw[i], 1);
      TextDrawSetShadow(OfferTextDraw[i], 1);
    }

    OfferTextdrawsCreated = 1;
  }
}

stock ServicePopUp(playerid, title[], offer[oOfferEnum])
{
  if(offer[ofId] == INVALID_OFFER_ID) return 1;
  if(Offer[playerid][ofId] != INVALID_OFFER_ID)
  {
    return HAS_ALREADY_GOT_OFFER;
  }
 
  Offer[playerid] = offer;
 
  new string[256], string2[128], offerer[32], playername[MAX_PLAYER_NAME], thing[64], thingtype[24], offererindex = INVALID_PLAYER_ID;
 
  if(Offer[playerid][ofOfferer] != INVALID_PLAYER_ID)
  {
    switch(Offer[playerid][ofOffererType])
    {
      case CONTENT_TYPE_USER:
      {
        offererindex = GetPlayerById(Offer[playerid][ofOfferer]);

        if(!IsPlayerConnected(offererindex))
        {
          SendClientMessage(offererindex, COLOR_GREY, "Nie ma takiej osoby w pobli¿u.");

          Offer[playerid][ofId] = INVALID_OFFER_ID;

          return OFFER_FAILED;
        }

        if(Offer[playerid][ofFlags] & OFFER_FLAG_CHECK_DISTANCE && !DistanceBetweenPlayers(4, offererindex, playerid, true))
				{
          SendClientMessage(offererindex, COLOR_GREY, "Nie ma takiej osoby w pobli¿u.");
				
          Offer[playerid][ofId] = INVALID_OFFER_ID;
				
          return OFFER_FAILED;
				}
				
				if(!(Offer[playerid][ofFlags] & OFFER_FLAG_CAN_OFFER_HIMSELF) && offererindex == playerid)
        {
          SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz zaoferowaæ tego samemu sobie.");
				
          Offer[playerid][ofId] = INVALID_OFFER_ID;
				
          return OFFER_FAILED;
        }
      }
    }
  }
 
  switch(Offer[playerid][ofType])
  {
    case OFFER_TYPE_PAYMENT:
    {
      if(Offer[playerid][ofPrice] < 0)
      {
        SendClientMessage(offererindex, COLOR_GREY, "Niepoprawna kwota oferty.");

        Offer[playerid][ofId] = INVALID_OFFER_ID;

        return OFFER_FAILED;
      }
    }
  }
 
  format(string, sizeof(string), "Otrzyma³eœ ofertê.", title);
  SendClientMessage(playerid, COLOR_LORANGE, string);
 
  if(offererindex != INVALID_PLAYER_ID)
  {
    GetPlayerNameMask(playerid, playername, sizeof(playername));
  
    format(string, sizeof(string), "Z³o¿y³eœ ofertê %s.", playername);
    SendClientMessage(offererindex, COLOR_LORANGE, string);
  }
 
  switch(Offer[playerid][ofId])
  {
    case OFFER_ID_JOB:
    {
      offerer = "Pracodawca";
      thingtype = "Praca";
      strmid(thing, Jobs[Offer[playerid][ofValue1]][jName], 0, strlen(Jobs[Offer[playerid][ofValue1]][jName]), 255);
    }
  
    case OFFER_ID_ITEM:
    {
      GetPlayerNameMask(offererindex, offerer, sizeof(offerer));

      new itemtype = GetItemTypeByItemId(Offer[playerid][ofValue1]);

      thingtype = "Przedmiot";

      format(thing, sizeof(thing), "%s (ID:%d)", ItemsTypes[itemtype][itName], Offer[playerid][ofValue1]);
    }
  
    case OFFER_ID_VEHICLE:
    {
      GetPlayerNameMask(offererindex, offerer, sizeof(offerer));
      new vmodel = GetVehicleModelByID(Offer[playerid][ofValue1]);

      thingtype = "Pojazd";

      format(thing, sizeof(thing), "%s (ID:%d)", GetVehicleNameByModel(vmodel), Offer[playerid][ofValue1]);
    }

    case OFFER_ID_CHEQUE:
    {
      GetPlayerNameMask(offererindex, offerer, sizeof(offerer));
      thingtype = "Czek";

      format(thing, sizeof(thing), "Czek bankowy na kwote $%d", Offer[playerid][ofValue1]);
    }
  
    case OFFER_ID_BIUSINESS_PRODUCT:
    {
      GetPlayerNameMask(offererindex, offerer, sizeof(offerer));
      format(offerer, sizeof(offerer), "Sprzedawca %s", offerer);

      thingtype = "Produkt";

      new product[bProduct];
      new businessindex = GetBusinessById(Offer[playerid][ofValue2]);

      GetProductInfo(BizzInfo[businessindex][bId], Offer[playerid][ofValue1], product);

      new itemtype = GetItemType(product[bpItemId]);

      format(thing, sizeof(thing), "%s (ID:%d)", ItemsTypes[itemtype][itName], Offer[playerid][ofValue1]);
    }
  
    case OFFER_ID_BET:
    {
      GetPlayerNameMask(offererindex, offerer, sizeof(offerer));
      thingtype = "Zaklad";

      format(thing, sizeof(thing), "%s", Bets[Offer[playerid][ofValue1]][ebName]);
    }
  }

  format(string, sizeof(string), "%s oferuje Ci:~n~", offerer);

  if(strlen(thingtype) > 0)
  {
    format(string2, sizeof(string2), "~w~%s:", thingtype);
    strcat(string, string2);
  }
 
  format(string2, sizeof(string2), " ~y~%s", thing);
  strcat(string, string2);
 
  if(Offer[playerid][ofFlags] & OFFER_FLAG_INFO_COMMAND)
  {
    strcat(string, "~n~~w~Uzyj ~g~/info~w~ dla dokladniejszych informacji o ofercie.");
  }
 
  switch(Offer[playerid][ofType])
  {
    case OFFER_TYPE_YESNO:
    {
      ShowMenuForPlayer(OfferMenu_YesNo, playerid);
      TogglePlayerControllable(playerid, 0);
    }
    case OFFER_TYPE_PAYMENT:
    {
      ShowMenuForPlayer(Offer[playerid][ofPrice] > 0 ? OfferMenu_Payment : OfferMenu_YesNo, playerid);
      TogglePlayerControllable(playerid, 0);

      if(Offer[playerid][ofPrice] > 0)
      {
        format(string2, sizeof(string2), "~n~~n~~w~Cena: ~p~$%s", format_number(Offer[playerid][ofPrice]));
        strcat(string, string2);
      }
      else
      {
        format(string2, sizeof(string2), "~n~~n~~w~Cena: ~b~Za darmo", Offer[playerid][ofPrice]);
        strcat(string, string2);
      }
    }
  }
 
  TextDrawSetString(OfferTextDraw[playerid], string);
  TextDrawShowForPlayer(playerid, OfferTextDraw[playerid]);

  return 1;
}

stock OnPlayerAcceptOffer(playerid, choice)
{
  new string[128], offererindex, sendername[MAX_PLAYER_NAME], giveplayer[MAX_PLAYER_NAME];

  if(Offer[playerid][ofOfferer] != INVALID_PLAYER_ID)
  {
    switch(Offer[playerid][ofOffererType])
    {
      case CONTENT_TYPE_USER:
      {
        offererindex = GetPlayerById(Offer[playerid][ofOfferer]);
    
        if(!IsPlayerConnected(offererindex))
        {
          SendClientMessage(playerid, COLOR_GREY, "Osoba, która przedstawi³a Ci swoj¹ ofertê, jest niedostêpna.");

          AbortOffer(playerid);

          return 1;
        }
    
        if(Offer[playerid][ofFlags] & OFFER_FLAG_CHECK_DISTANCE && !ProxDetectorS(4.0, playerid, offererindex))
        {
          SendClientMessage(playerid, COLOR_GREY, "Nie ma w pobli¿u oferuj¹cego.");

          AbortOffer(playerid);

          return 1;
        }
      }
    }
  }
 
  switch(Offer[playerid][ofType])
  {
    case OFFER_TYPE_PAYMENT:
    {
      if(Offer[playerid][ofPrice] > 0)
      {
        switch(choice)
        {
          case 1:
          {
            if(GetPlayerMoneyEx(playerid) < Offer[playerid][ofPrice])
            {
              CantAffordMsg(playerid, Offer[playerid][ofPrice]);

              AbortOffer(playerid);

              return 1;
            }
          }

          case 2:
          {
            if(PlayerInfo[playerid][pAccount] < Offer[playerid][ofPrice])
            {
              CantAffordMsg(playerid, Offer[playerid][ofPrice], 1);

              AbortOffer(playerid);

              return 1;
            }
          }
        }
      }
    }
  }
  
  switch(Offer[playerid][ofOffererType])
  {
    case CONTENT_TYPE_USER:
    {
      switch(choice)
      {
        case 0:
        {
          GetPlayerNameMask(offererindex, sendername, sizeof(sendername));
          format(string, sizeof(string), "Odrzuci³eœ ofertê od %s.", sendername);
          SendClientMessage(playerid, COLOR_LORANGE, string);
          
          GetPlayerNameMask(playerid, sendername, sizeof(sendername));
          format(string, sizeof(string), "%s odrzuci³ Twoj¹ ofertê.", sendername);
          SendClientMessage(offererindex, COLOR_GREY, string);
        }

        case 1:
        {
          GetPlayerNameMask(offererindex, sendername, sizeof(sendername));
          format(string, sizeof(string), "Przyj¹³eœ ofertê od %s.", sendername);
          SendClientMessage(playerid, COLOR_LORANGE, string);
        
          GetPlayerNameMask(playerid, sendername, sizeof(sendername));
          format(string, sizeof(string), "%s przyj¹³ Twoj¹ ofertê.", sendername);
          SendClientMessage(offererindex, COLOR_LORANGE, string);
        }
      }
    }
  }

  switch(Offer[playerid][ofId])
  {
    case OFFER_ID_JOB:
    {
      switch(choice)
      {
        case 0:
        {
          SendClientMessage(playerid, COLOR_GREY, "Odrzuci³eœ ofertê pracy");
        }

        case 1:
        {
          format(string, sizeof(string), "Zatrudni³eœ siê jako %s.", Jobs[Offer[playerid][ofValue1]][jName]);
          SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

          PlayerInfo[playerid][pJob] = Offer[playerid][ofValue1];
          PlayerInfo[playerid][pContractTime] = 5;
        }
      }
    }
  
    case OFFER_ID_ITEM:
    {
      switch(choice)
      {
        case 0:
        {
          SendClientMessage(playerid, COLOR_GRAD2, "Odrzuci³eœ ofertê przedmiotu.");
        }

        default:
        {
          new itemindex = GetItemById(Offer[playerid][ofValue1]);
          new query[128];

          Items[itemindex][iOwner] = PlayerInfo[playerid][pId];
          format(query, sizeof(query), "UPDATE `items_item` SET `owner_id` = %d WHERE `id` = %d", PlayerInfo[playerid][pId], Offer[playerid][ofValue1]);
          mysql_query(query);

          new itemtypeindex = GetItemTypeByItemId(Items[itemindex][iId]);

          GetPlayerNameMask(playerid, sendername, sizeof(sendername));
          GetPlayerNameMask(offererindex, giveplayer, sizeof(giveplayer));

          format(string, sizeof(string), "Sprzeda³eœ przedmiot (ID: %d) %s %s za $%d.", Items[itemindex][iId], ItemsTypes[itemtypeindex][itName], sendername, Offer[playerid][ofPrice]);
          SendClientMessage(offererindex, COLOR_GRAD1, string);
          format(string, sizeof(string), "Kupi³eœ przedmiot (ID: %d) %s od %s za $%d.", Items[itemindex][iId], ItemsTypes[itemtypeindex][itName], giveplayer, Offer[playerid][ofPrice]);
          SendClientMessage(playerid, COLOR_GRAD1, string);
        }
      }
    }
  
    case OFFER_ID_VEHICLE:
    {
      switch(choice)
      {
        case 0:
        {
          SendClientMessage(playerid, COLOR_GREY, "Odrzuci³eœ ofertê pojazdu.");
        }

        default:
        {			
          if(PlayerVehiclesCount(playerid) >= VehiclesLimit(playerid))
          {
            SendClientMessage(playerid, COLOR_GRAD1, "Nie mo¿esz posiadaæ wiêkszej iloœci pojazdów.");
            AbortOffer(playerid);
            return 1;
          }

          if(!IsVehicleOwner(PlayerInfo[offererindex][pId], Offer[playerid][ofValue1]))
          {
            SendClientMessage(playerid, COLOR_GRAD1, "Ta osoba zaoferowa³a ci pojazd, który nie istnieje.");
            AbortOffer(playerid);
            return 1;
          }

          if(PlayerSpawnedVehiclesCount(playerid) >= GetPlayerSpawnedVehiclesLimit(playerid))
          {
            SendClientMessage(playerid, COLOR_GRAD1, "Nie mo¿esz mieæ wiêkszej iloœci zespawnowanych pojazdów.");
            AbortOffer(playerid);
            return 1;
          }

          GetPlayerNameEx(playerid, giveplayer, sizeof(giveplayer));
          GetPlayerNameEx(offererindex, sendername, sizeof(sendername));

          new vehicleindex = GetVehicleByID(Offer[playerid][ofValue1]);

          if(vehicleindex != -1)
          {
            Vehicles[vehicleindex][vOwner] = PlayerInfo[playerid][pId];
            strmid(Vehicles[vehicleindex][vOwnerName], giveplayer, 0, strlen(giveplayer), Vehicles[vehicleindex][vOwnerName]);
          }

          PassVehicle(Offer[playerid][ofValue1], PlayerInfo[offererindex][pId], playerid);

          format(string, sizeof(string), "Da³eœ %s klucz do twojego pojazdu za $%d", giveplayer, Offer[playerid][ofPrice]);
          PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
          SendClientMessage(offererindex, COLOR_GRAD1, string);
          format(string, sizeof(string), "Odebra³eœ klucz do pojazdu od %s za $%d", sendername, Offer[playerid][ofPrice]);
          SendClientMessage(playerid, COLOR_GRAD1, string);
          format(string, sizeof(string), "* %s wyj¹³ zestaw kluczy i rzuci³ je do %s.", sendername ,giveplayer);
          ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);

          print(string);
        }
      }
    }
  
    case OFFER_ID_CHEQUE:
    {
      switch(choice)
      {
        case 0:
        {
          SendClientMessage(playerid, COLOR_GREY, "Odrzuci³eœ ofertê czeku.");
        }

        default:
        {
          if(Offer[playerid][ofValue1] > PlayerInfo[offererindex][pAccount])
          {
            SendClientMessage(playerid, COLOR_GRAD2, "Ta osoba próbowa³a zaoferowaæ Ci czek bez pokrycia.");
            AbortOffer(playerid);
            return 1;
          }

          new nitem[pItem];

          nitem[iItemId] = ITEM_CHEQUE;
          nitem[iCount] = 0;
          nitem[iOwner] = PlayerInfo[playerid][pId];
          nitem[iOwnerType] = CONTENT_TYPE_USER;
          nitem[iPosX] = 0.0;
          nitem[iPosY] = 0.0;
          nitem[iPosZ] = 0.0;
          nitem[iPosVW] = 0;
          nitem[iFlags] = 0;
          nitem[iAttr1] = Offer[playerid][ofValue1];
          nitem[iAttr2] = PlayerInfo[offererindex][pId];
          nitem[iAttr3] = PlayerInfo[playerid][pId];
          GetPlayerNameEx(playerid, nitem[iAttr5], sizeof(nitem[iAttr5]));

          new createditemid = CreateItem(nitem);

          if(createditemid == HAS_REACHED_LIMIT)
          {
            SendClientMessage(offererindex, COLOR_GREY, "Ta osoba nie mo¿e posiadaæ wiêcej przedmiotów.");
            SendClientMessage(playerid, COLOR_GREY, "Transakcja nie mog³a zostaæ sfinalizowana, poniewa¿ nie mo¿esz posiadaæ wiêcej przedmiotów.");
            AbortOffer(playerid);
            return 1;
          }

          PlayerInfo[offererindex][pAccount] -= Offer[playerid][ofValue1];
        }
      }
    }
  
    case OFFER_ID_BIUSINESS_PRODUCT:
    {
      switch(choice)
      {
        case 0:
        {
          SendClientMessage(playerid, COLOR_GREY, "Odrzuci³eœ ofertê kupna produktu.");
        }

        default:
        {
          new product[bProduct];

          if(!GetProductInfo(Offer[playerid][ofValue2], Offer[playerid][ofValue1], product))
          {
            SendClientMessage(playerid, COLOR_GRAD2,  "Nie mo¿esz kupiæ takiego produktu w tym miejscu.");
            SendClientMessage(offererindex, COLOR_GREY, "Nie mo¿esz sprzedaæ tego produktu.");
            AbortOffer(playerid);
            return 1;
          }

          if(product[bpCount] <= 0)
          {
            SendClientMessage(playerid, COLOR_GRAD2,  "Zapasy tego produktu wyczerpane.");
            SendClientMessage(offererindex, COLOR_GREY, "Zapasy tego produktu wyczerpane.");
            AbortOffer(playerid);
            return 1;
          }

          new createditemid = PlayerBuyProduct(playerid, Offer[playerid][ofValue2], product);

          if(createditemid == HAS_REACHED_LIMIT)
          {
            SendClientMessage(offererindex, COLOR_GREY, "Ta osoba nie mo¿e posiadaæ wiêcej przedmiotów.");
            SendClientMessage(playerid, COLOR_GREY, "Transakcja nie mog³a zostaæ sfinalizowana, poniewa¿ nie mo¿esz posiadaæ wiêcej przedmiotów.");
            AbortOffer(playerid);
            return 1;
          }

          new itemtypeindex = GetItemTypeByItemId(createditemid);

          GetPlayerNameEx(playerid, giveplayer, sizeof(giveplayer));

          format(string, sizeof(string), "Zakupi³eœ (ID:%d) %s za $%d.", createditemid, ItemsTypes[itemtypeindex][itName], product[bpPrice]);
          SendClientMessage(playerid, COLOR_LORANGE, string);

          format(string, sizeof(string), "Sprzeda³eœ (ID:%d) %s %s za $%d. Wpieni¹dze wp³ynê³y do kasy firmy.", createditemid, giveplayer, ItemsTypes[itemtypeindex][itName], product[bpPrice]);
          SendClientMessage(offererindex, COLOR_LORANGE, string);
        }
      }
    }
  
    case OFFER_ID_BET:
    {
      switch(choice)
      {
        case 0:
        {
          SendClientMessage(playerid, COLOR_GREY, "Odrzuci³eœ ofertê zak³adu.");
        }

        default:
        {
          if(Bets[Offer[playerid][ofValue1]][ebUsed] == UNUSED_BET)
          {
            SendClientMessage(playerid, COLOR_GRAD2, "Ta osoba odwo³a³a zak³ad, do którego zosta³eœ zaproszony.");
            AbortOffer(playerid);
            return 1;
          }

          switch(Bets[Offer[playerid][ofValue1]][ebId])
          {
            case BET_ID_RACE:
            {
              AddPlayerToRace(playerid);
            }
          }

          GetPlayerNameEx(playerid, giveplayer, sizeof(giveplayer));

          format(string, sizeof(string), "Do³¹czy³eœ siê do zak³adu: %s. Kwota wejœcia do zak³adu wynosi³a $%d.", Bets[Offer[playerid][ofValue1]][ebName], Offer[playerid][ofPrice]);
          SendClientMessage(playerid, COLOR_LORANGE, string);

          format(string, sizeof(string), "%s do³¹czy³ siê do zak³adu.", giveplayer);
          SendClientMessage(offererindex, COLOR_LORANGE, string);

          BetMembers[playerid][ebmBetIndex] = Offer[playerid][ofValue1];
          BetMembers[playerid][ebmPlace] = GetBetMembersCount(Offer[playerid][ofValue1]);

          Bets[Offer[playerid][ofValue1]][ebTill] += Offer[playerid][ofPrice];
        }
      }
    }
  }
 
  switch(Offer[playerid][ofType])
  {
    case OFFER_TYPE_PAYMENT:
    {
      if(Offer[playerid][ofPrice] > 0)
      {
        switch(choice)
        {
          case 1:
          {
            GivePlayerMoneyEx(playerid, -Offer[playerid][ofPrice]);

            if(!(Offer[playerid][ofFlags] & OFFER_FLAG_SINGLE_TRANSACTION))
            {
              GivePlayerMoneyEx(offererindex, Offer[playerid][ofPrice]);
            }
          }

          case 2:
          {
            PlayerInfo[playerid][pAccount] -= Offer[playerid][ofPrice];

            if(!(Offer[playerid][ofFlags] & OFFER_FLAG_SINGLE_TRANSACTION))
            {
              PlayerInfo[offererindex][pAccount] += Offer[playerid][ofPrice];
            }
          }
        }
      }
    }
  }
 
  TextDrawHideForPlayer(playerid, OfferTextDraw[playerid]);
  Offer[playerid][ofId] = INVALID_OFFER_ID;
 
  return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
  new Menu:current;

  current = GetPlayerMenu(playerid);

  if(current == OfferMenu_Payment || current == OfferMenu_YesNo)
  {
    OnPlayerAcceptOffer(playerid, row);
  }

  if(!IsPlayerBusy(playerid))
  {
    TogglePlayerControllable(playerid, 1);
  }

  return 1;
}

public OnPlayerExitedMenu(playerid)
{
  if(Offer[playerid][ofId] != INVALID_OFFER_ID)
  {
    OnPlayerAcceptOffer(playerid, 0);
  }

  if(!IsPlayerBusy(playerid))
  {
    TogglePlayerControllable(playerid, 1);
  }

  return 1;
}

dcmd_info(playerid, params[])
{
  #pragma unused params

  if(Offer[playerid][ofId] == INVALID_OFFER_ID)
  {
    SendClientMessage(playerid, COLOR_GREY, "Nikt nie oferuje Ci niczego.");
    return 1;
  }

  if(!(Offer[playerid][ofFlags] & OFFER_FLAG_INFO_COMMAND))
  {
    SendClientMessage(playerid, COLOR_GREY, "¯adne dodatkowe informacje nie s¹ dostêpne dla tej oferty.");
    return 1;
  }

  switch(Offer[playerid][ofId])
  {
    case OFFER_ID_ITEM:
    {
      ShowItemInfo(Offer[playerid][ofValue1], playerid);
    }

    case OFFER_ID_VEHICLE:
    {
      ShowVehicleInfo(Offer[playerid][ofValue1], playerid);
    }

    case OFFER_ID_BET:
    {
      ShowBetInfo(Offer[playerid][ofValue1], playerid);
    }

    default:
    {
      SendClientMessage(playerid, COLOR_GREY, "¯adne dodatkowe informacje nie s¹ dostêpne dla tej oferty.");
    }
  }

  return 1;
}