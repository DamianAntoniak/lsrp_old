forward LoadProperty();
forward LoadBizz();
forward LoadSBizz();
forward LoadStuff();
forward SaveStuff();
forward LoadFamilies();
forward SaveFamilies();
forward LoadBoxer();
forward SaveBoxer();
forward IsAtClothShop(playerid);
forward IsAtGasStation(playerid);
forward IsAtFishPlace(playerid);
forward IsAtCookPlace(playerid);
forward IsAtBar(playerid);
forward DollahScoreUpdate();
forward SetPlayerSpawn(playerid, mode);
forward CrimInRange(Float:radi, playerid,copid);
forward ABroadCast(color,const string[],level);
forward DateProp(playerid);
forward SetPlayerUnjail();
forward OtherTimer();
forward OtherTimer2();
forward BanLog(string[]);
forward KickLog(string[]);
forward PayLog(string[]);
forward CKLog(string[]);
forward Spectator();
forward GameModeExitFunc();
forward SetAllPlayerCheckpoint(Float:allx, Float:ally, Float:allz, Float:radi, num);
forward SetAllCopCheckpoint(Float:allx, Float:ally, Float:allz, Float:radi);
forward SetAllArmyCheckpoint(playerid);
forward SetPlayerCriminal(playerid,declare,reason[]);
forward SetPlayerFree(playerid,declare,reason[]);
forward SetPlayerWeapons(playerid);
forward ShowStats(playerid,targetid,admin);
forward SetPlayerToTeamColor(playerid);
forward GameModeInitExitFunc();
forward split(const strsrc[], strdest[][], delimiter);
forward OnPlayerLogin(playerid,password[]);
forward OnPlayerSave(playerid);
forward OnPlayerRegister(playerid, password[]);
forward BroadCast(color,const string[]);
forward OOCOff(color,const string[]);
forward OOCNews(color,const string[]);
forward SendJobMessage(job, color, string[]);
forward SendFamilyMessage(family, color, string[]);
forward SendNewFamilyMessage(family, color, string[]);
forward SendIRCMessage(channel, color, string[]);
forward SendTeamMessage(team, color, string[]);
forward SendRadioMessage(member, color, string[]);
forward SendRadioMessageEx(playerid, color, channel, string[]);
forward SendAdminMessage(color, string[]);
forward AddCar(carcoords);
forward ProxDetectorS(Float:radius, playerid, targetid);
forward ClearFamily(family);
forward ClearMarriage(playerid);
forward ClearPaper(paper);
forward ClearCrime(playerid);
forward FishCost(playerid, fish);
forward ClearFishes(playerid);
forward ClearFishID(playerid, fish);
forward ClearCooking(playerid);
forward ClearCookingID(playerid, cook);
forward ClearGroceries(playerid);
forward LockCar(carid);
forward UnLockCar(carid);
forward InitLockDoors(playerid);
forward Fillup(playerid);
forward SyncTime();
forward SyncUp();
forward SaveAccounts();
forward Production();
forward Checkprop();
forward PayDay();
forward PlayerPlayMusic(playerid);
forward StopMusic();
forward PlayerFixRadio(playerid);
forward PlayerFixRadio2();
forward CustomPickups();
forward SetCamBack(playerid);
forward FixHour(hour);
forward AddsOn();
// nowe
forward TowPlayerVehicle(playerid); // towcar
forward CreateATM(id, Float:x, Float:y, Float:z, Float:rot); // tworzenie bankomatow
forward loadMoneyToAtm(playerid); // funkcja dla konwoju
forward finishLoadMoney(playerid); // funkcja dla konwoju
forward loadMoneyToConvoy(playerid); // funkcja dla konwoju
forward unfreeze(playerid); // odmrazanie (uzywane dla timerow)
forward OnPlayerTeamPrivmsg(playerid, teamid, text[]); // blokada TPM
forward KillAni(playerid); // czyszczenie animacji (nie za pomoca Clear tylko animacji)
forward IsInvalidSkin(skinid); // sprawdzanie skinow (bezpieczenstwo)
forward ShockTimer(); // dla wypadkow
forward GivePlayerMoneyEx(playerid, money); // funkcja posrednia dla pieniedzy (anti-moneycheat)
forward GetPlayerMoneyEx(playerid); // funkcja posrednia dla pieniedzy (anti-moneycheat)
forward SetVehicleParamsForAll(vehicle,objective,doorslocked);
forward GetOwnedCarID(playerid); // id wlasnego pojazdu (-1 jesli nie ma)
forward PlayerPlaySoundForAll_Object(soundid, endsoundid, object, Float:sx, Float:sy, Float:sz); // dzwiek dla wszystkich graczy
forward AttachSoundToObject(playerid, object, sound, Float:sx, Float:sy, Float:sz); // podpinanie dzwiekow + eventu dla obiektu dla gracza
forward DetachSoundFromPlayer(playerid); // odpinanie dzwieku
forward StopConvoyMission(); // uzywane przez timer (konczy misje konwoju po minucie od opuszczenia pojazdu)
forward IsAnyPlayerInVehicle(vehicle); // przetlumacz sobie :P
forward RespawnAllCars(); // respawn wszystkich aut w ktorych nikt nie siedzi
forward BulletKiller(pickupid); // usuwanie pickupa adrenaliny
//forward RobMoney(playerid); // funkcja ktora jest uruchamiana po jakims czasie i okrada danego gracza (wywolywana przez tiemr)
forward ChatAnim(playerid, strlen); // animacja gracza podczas rozmowy (czas animacji jest zalezny od dlugosci tekstu)
forward WarnLog(string[]); // logowanie warnów
forward KWarnLog(string[]); // logowanie kwarnów
forward DisableArmyCheckpoint(playerid); // wylacza checkpoint dla armii
//forward BorderTimer(); // timer dla granic
forward GetClosestVehicle(playerid); // zwraca najblizszy pojazd
forward SetPlayerUnsafe(playerid); // funkcja dla timera
forward CreateMenus(); // funkcja zawierajaca menu
forward SpeedCheck(); // sprawdzanie predkosci (dla predkosciomierza)
forward CheckChatText(cwords[][], text[], cwordsize); // sprawdzamy tekst pod wzgledem fraz z tablicy
forward CheckIsTextIC(playerid, text[]); // funkcja sprawdzajaca tekst pod wzgledem wystepowania emotikonków
forward ClearConsole(playerid); // czyszczenie konsoli
forward SetPlayerMarkerForAll(playerid, color); // ustawia marker dla wszystkich
forward HidPlayerMarkerForAll(playerid); // ukrywa marker dla wszystkich
forward KillAniForBH(playerid); // funkcja dla timera
forward MoveObjectRotation(objectid, Float:rx, Float:ry, Float:rz, Float:step, interval, dir); // rekurencyjna animacja obiektów (wg. obrotu)
forward GivePlayerWeaponEx(playerid, weaponid, ammo); // funkcja posrednia do dawania broni, ktore maja zostac zapisane
forward GetWeaponSlot(weapon); // pobiera ID slotu broni
forward IsVehicleInUse(vehicleid); // czy pojazd jest w uzytku
forward SetPlayerSpecialActionEx(playerid,action); // metoda posrednia dla ustawiania akcji specjalnych (sprawdzanie IsPlayerBusy)
forward OnHouseUpdate(property);
forward TLeX(t3D_ID);


stock IsABoat(carid)
{
 new model = GetVehicleModel(carid);
 new Boats[] = { 472, 473, 493, 495, 484, 430, 454, 453, 452, 446 };

 for(new i = 0; i < sizeof(Boats); i++) { if(model == Boats[i]) return 1; }

 return 0;
}

stock IsABike(carid)
{
 new model = GetVehicleModel(carid);
 new Bikes[] = {509, 481, 510};

 for(new i = 0; i < sizeof(Bikes); i++) { if(model == Bikes[i]) return 1; }

 return 0;
}

stock IsAirVehicle(carid)
{
 new model = GetVehicleModel(carid);
 new AirVeh[] = { 592, 577, 511, 512, 593, 520, 553, 476, 519, 460, 513, 548, 425, 417, 487, 488, 497, 563, 447, 469 };

 for(new i = 0; i < sizeof(AirVeh); i++) { if(model == AirVeh[i]) return 1; }

 return 0;
}

stock Float:GetDistanceBetweenPlayers(p1,p2)
{
	new Float:x1,Float:y1,Float:z1,Float:x2,Float:y2,Float:z2;

	if(!IsPlayerConnected(p1) || !IsPlayerConnected(p2)) return -1.00;
	if(GetPlayerVirtualWorld(p1) != GetPlayerVirtualWorld(p2)) return -1.00;

  GetPlayerPos(p1,x1,y1,z1);
	GetPlayerPos(p2,x2,y2,z2);

	return GetDistanceBetweenPoints(x1,y1,z1,x2,y2,z2);
}

stock DistanceBetweenPlayers(Float:radi, playerid, targetid, checkstate=false)
{
	if(!IsPlayerConnected(playerid) || !IsPlayerConnected(targetid)) return 0;
	if(GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(targetid)) return 0;
 
	new playerstate = GetPlayerState(playerid), targetstate = GetPlayerState(targetid);
 
	if(checkstate &&
		((playerstate == PLAYER_STATE_SPECTATING || playerstate == PLAYER_STATE_NONE) ||
		(targetstate == PLAYER_STATE_SPECTATING || targetstate == PLAYER_STATE_NONE))) return 0;
 
	new Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2;
 
	GetPlayerPos(playerid, x1, y1, z1);
	GetPlayerPos(targetid, x2, y2, z2);
	
	return Type8(x1,y1,z1,x2,y2,z2,radi);
	//return floatsqroot(floatpower(floatabs(floatsub(x2,x1)),2)+floatpower(floatabs(floatsub(y2,y1)),2)+floatpower(floatabs(floatsub(z2,z1)),2)) < radi;
}

stock GetXYInFrontOfVehicle(vehicleid, &Float:x, &Float:y, Float:distance) //based on GetXYInFrontOfPlayer by Y_Less
{
 new Float:a;
 GetVehiclePos(vehicleid, x, y, a);
 GetVehicleZAngle(vehicleid, a);
 x += (distance * floatsin(-a, degrees));
 y += (distance * floatcos(-a, degrees));
}


stock IsPlayerInFrontOfVehicle(playerid,vehicleid) //credits to smugller for helping me with that
{
	new Float:X, Float:Y, Float:Z;
	GetPlayerPos(playerid, X, Y, Z);
	GetXYInFrontOfVehicle(vehicleid, X, Y, 5.0);
	return(1);
}

stock IsACop(playerid)
{
  return (GetPlayerOrganization(playerid) == 1 || GetPlayerOrganization(playerid) == 2
    || GetPlayerOrganization(playerid) == 3 || GetPlayerOrganization(playerid) == 13);
}

stock IsAMember(playerid)
{
  return (GetPlayerOrganization(playerid) == 5 || GetPlayerOrganization(playerid) == 6
    || GetPlayerOrganization(playerid) == 8);
}

stock IsPlayerFacingPlayer(playerid, targetid, Float:offset)
{
	new
	    Float:x[2], Float:y[2], Float:z[2],
	    Float:a[2];

	GetPlayerFacingAngle(playerid, a[0]);

	a[0] += 180.0;

	if(a[0] < 0.0)
	    a[0] += 360.0;
	if(a[0] > 360.0)
	    a[0] -= 360.0;

	GetPlayerPos(playerid, x[0], y[0], z[0]);
	GetPlayerPos(targetid, x[1], y[1], z[1]);

	a[1] = atan2(y[0] - y[1], x[0] - x[1]) - 90.0;

	if(a[1] < 0.0)
	    a[1] += 360.0;
	if(a[1] > 360.0)
	    a[1] -= 360.0;

	return AngleInRangeOfAngle(a[0], a[1], offset);
}
