//new      Text:ringTextDraw;

#if TIKI_EVENT
new      Text:tikiTextDraw;
new      tikiEvent = 0;
new      tikiWinner[MAX_PLAYER_NAME];
#endif

new MySQLDebug = 0;
new ReservedSlots = 0;
new DrunkTime[MAX_PLAYERS];
new Tax = 0;
new Float:TaxValue = 0.1;
new InRing = 0;
new RoundStarted = 0;
new BoxDelay = 0;
new Boxer1 = 255;
new Boxer2 = 255;
new TBoxer = 255;
new PlayerBoxing[MAX_PLAYERS];
new Medics = 0;
new MedicCall = 999;
new MedicCallTime[MAX_PLAYERS];
new Mechanics = 0;
new MechanicCall = 999;
new MechanicCallTime[MAX_PLAYERS];
new TaxiDrivers = 0;
new TaxiCall = 999;
new TaxiCallTime[MAX_PLAYERS];
new TaxiAccepted[MAX_PLAYERS];
new BusAccepted[MAX_PLAYERS];
new TransportDuty[MAX_PLAYERS];
new TransportValue[MAX_PLAYERS];
new TransportMoney[MAX_PLAYERS];
new TransportTime[MAX_PLAYERS];
new TransportCost[MAX_PLAYERS];
new TransportDriver[MAX_PLAYERS];
new JobDuty[MAX_PLAYERS];
new PizzaDuty[MAX_PLAYERS];
new SchoolSpawn[MAX_PLAYERS];
new TakingLesson[MAX_PLAYERS];
new UsedFind[MAX_PLAYERS];
new WatchingTV[MAX_PLAYERS];
new NoFuel[MAX_PLAYERS];
new MatsHolding[MAX_PLAYERS];
new TicketOffer[MAX_PLAYERS];
new TicketMoney[MAX_PLAYERS];
new PlayerStoned[MAX_PLAYERS];
new FishCount[MAX_PLAYERS];
new SpawnChange[MAX_PLAYERS];
new PlayerDrunk[MAX_PLAYERS];
new PlayerDrunkTime[MAX_PLAYERS];
new PlayerTazeTime[MAX_PLAYERS];
new FindTimePoints[MAX_PLAYERS];
new FindTime[MAX_PLAYERS];
new BoxWaitTime[MAX_PLAYERS];
new BoxOffer[MAX_PLAYERS];
new MedicTime[MAX_PLAYERS];
new NeedMedicTime[MAX_PLAYERS];
new MedicBill[MAX_PLAYERS];
new PlayerTied[MAX_PLAYERS];
new PlayerCuffed[MAX_PLAYERS];
new PlayerCuffedTime[MAX_PLAYERS];
new LiveOffer[MAX_PLAYERS];
new SelectTalkStyle[MAX_PLAYERS];
new TalkingLive[MAX_PLAYERS];
new GettingJob[MAX_PLAYERS];
new ApprovedLawyer[MAX_PLAYERS];
new CallLawyer[MAX_PLAYERS];
new WantLawyer[MAX_PLAYERS];
new CurrentMoney[MAX_PLAYERS];
new KickPlayer[MAX_PLAYERS];
new Robbed[MAX_PLAYERS];
new RobbedTime[MAX_PLAYERS];
new CP[MAX_PLAYERS];
new RepairOffer[MAX_PLAYERS];
new RepairPriceOffer[MAX_PLAYERS];
new RepairPrice[MAX_PLAYERS];
new RefillOffer[MAX_PLAYERS];
new RefillPrice[MAX_PLAYERS];
new RepairCar[MAX_PLAYERS];
new DrugOffer[MAX_PLAYERS];
new DrugPrice[MAX_PLAYERS];
new DrugGram[MAX_PLAYERS];
new JailPrice[MAX_PLAYERS];
new WantedPoints[MAX_PLAYERS];
new WantedLevel[MAX_PLAYERS];
new OnDuty[MAX_PLAYERS];
new OnAdminDuty[MAX_PLAYERS];
new gPlayerCheckpointStatus[MAX_PLAYERS];
new gPlayerLogged[MAX_PLAYERS];
new gPlayerLogged2[MAX_PLAYERS];
new gLogged2[MAX_PLAYERS];
new gPlayerLogTries[MAX_PLAYERS];
new gPlayerSpawned[MAX_PLAYERS];
new gLastCar[MAX_VEHICLES];
new gLastCarPassenger[MAX_VEHICLES];
new gFam[MAX_PLAYERS];
new BigEar[MAX_PLAYERS];
new Spectate[MAX_PLAYERS];
new CellTime[MAX_PLAYERS];
new HireCar[MAX_PLAYERS];
new SafeTime[MAX_PLAYERS];
new HidePM[MAX_PLAYERS];
new HideLSN[MAX_PLAYERS];
new PhoneOnline[MAX_PLAYERS];
new CellularPhone[MAX_PLAYERS];
//new gSpentCash[MAX_PLAYERS];
new Fixr[MAX_PLAYERS];
new Mobile[MAX_PLAYERS];
new RingTone[MAX_PLAYERS];
new CallCost[MAX_PLAYERS];
new gPlayerAccount[MAX_PLAYERS];
new pizzaOrders[MAX_PLAYERS];
new IllegalOrderReady[MAX_PLAYERS];
new Float:armourFix[MAX_PLAYERS];
new gLastDriver[302];
new gCarLock[MAX_VEHICLES];
new cbjstore[128];
new motd[128];
new realtime = 1;
#if LEVEL_MODE
new levelcost = 25000;
#endif
new deathcost = 1200;
new callcost = 10; //20 seconds
new timeshift = 0;
new shifthour;
new othtimer;
new othtimer2;
new healthtimer;
new synctimer;
new speedtimer;
new unjailtimer;
//new turftimer;
new pickuptimer;
new spectatetimer;
new productiontimer;
new accountstimer;
new anticheattimer;
new UnMuteTimer[MAX_PLAYERS];
new intrate = 1;
#if LEVEL_MODE
new levelexp = 4;
#endif
new cchargetime = 60;
new txtcost = 4;
new CIV[] = {7,19,20,23,73,101,122};
new Float:PlayerLastPos[MAX_PLAYERS][3];
new SkipAntiAirbrk[MAX_PLAYERS];
new PlayerSpeed[MAX_PLAYERS];
new Float:TeleportDest[MAX_PLAYERS][7];
new NotPlayersMobile[MAX_PLAYERS] = 0;
//new giveHouseKeyPrice[MAX_PLAYERS];
//new giveHouseKeyOffer[MAX_PLAYERS] = 999;
new setSpawnOnSpawn[MAX_PLAYERS];
new hasMaskOn[MAX_PLAYERS] = 0;
new academyTrening = 0;
new onlogin[MAX_PLAYERS] = 0;
new acceptDeath[MAX_PLAYERS] = 0;
new GodMode[MAX_PLAYERS] = 0;
new disableAntyCheat[MAX_PLAYERS] = 0;
new skipAntyCheat[MAX_PLAYERS] = 0;
new ghour;
new Injured[MAX_PLAYERS];

//Boxy
new Text:Textdraw1;
new Text:Textdraw2;
//Kary :)
new Text:Kara;
new KaraTD;

//Telefon
new Text:p3;
new Text:p4;
new Text:p5;
new Text:txtSprite1;
new Text:txtSprite2;

new muzyka[MAX_PLAYERS];
new mp3[MAX_PLAYERS];
new Text:AudioPlugin[MAX_PLAYERS];

/**
 * Bramy
 */
/*// hangar policyjny
new gatePoliceA;
new gatePoliceState = 1;
// dmv w srodku
//new gateDmv;
//new gateDmvState = 0;
// szlaban kolo PD
new gateParkingPolice;
new gateParkingPoliceState = 1;
new gatePrison;
new gatePrisonState = 1;

//new gateBorderIn;
//new gateBorderOut;
new gateBorderInState = 1;
new gateBorderOutState = 1;
new gateBorderIn_new;
new gateBorderOut_new;*/


new AutoChangeWeatherTimer = 3600;
new IsAllowedToPizzaBike[MAX_PLAYERS] = 0;
new PizzaBikeTimer[MAX_PLAYERS];
new TalkStyleSelectTimer[MAX_PLAYERS];
new RepairingVehicle[MAX_PLAYERS]; // czy naprawia pojazd
new RepairingVehicleOwner[MAX_PLAYERS]; // id w³aœciciela naprawianego pojazdu
new IsRepairing[MAX_PLAYERS] = 0;
new DeadReason[MAX_PLAYERS] = 0;
new BlockedPM[MAX_PLAYERS][MAX_PLAYERS];

/**
 * Blokady
 */
 
 enum BlocadeInfo
 {
   blocadeobject,
	 blocadeowner
 }
 
 //blokady frakcji musz¹ byæ razem (jedna pod drugim), inaczej bêdzie bug przy info i tym które blokady s¹ dostêpne dla danej frakcji
 new blocades[][BlocadeInfo] =
 {
   {INVALID_OBJECT_ID,1},
	 {INVALID_OBJECT_ID,1},
	 {INVALID_OBJECT_ID,1},
	 {INVALID_OBJECT_ID,1},
	 {INVALID_OBJECT_ID,1},
	 {INVALID_OBJECT_ID,1},
	 {INVALID_OBJECT_ID,1},
	 {INVALID_OBJECT_ID,1},
	 {INVALID_OBJECT_ID,1},
	 {INVALID_OBJECT_ID,1},
	 
	 {INVALID_OBJECT_ID,2},
	 {INVALID_OBJECT_ID,2},
	 {INVALID_OBJECT_ID,2},
	 {INVALID_OBJECT_ID,2},
	 {INVALID_OBJECT_ID,2},
	 
	 {INVALID_OBJECT_ID,3},
	 {INVALID_OBJECT_ID,3},
	 {INVALID_OBJECT_ID,3},
	 {INVALID_OBJECT_ID,3},
	 {INVALID_OBJECT_ID,3},
	 
	 {INVALID_OBJECT_ID,4},
	 {INVALID_OBJECT_ID,4},
	 
	 {INVALID_OBJECT_ID,7},
	 
	 {INVALID_OBJECT_ID,11},
	 {INVALID_OBJECT_ID,11},
	 {INVALID_OBJECT_ID,11},
	 
	 {INVALID_OBJECT_ID,18},
	 {INVALID_OBJECT_ID,18},
	 {INVALID_OBJECT_ID,18},
	 {INVALID_OBJECT_ID,18},
	 {INVALID_OBJECT_ID,18}
 };
 
 new BlocadePlayerIsSetting[MAX_PLAYERS];

/**
 * Other
 */
new mConvoy[MAX_PLAYERS];
new alkomatAccept[MAX_PLAYERS] = 255;
new sackConvoyPickup; // pickup torby z pieniedzmi po zniszczeniu konwoju
new ConvoyMission = 0;// zabezpieczenie do konwojow
new safeTimer[MAX_PLAYERS]; // fix na spawn w szpitalu
new IsPlayerSafe[MAX_PLAYERS] = 0;
new HadACrash[MAX_PLAYERS] = 0;
new HadACrashTimer[MAX_PLAYERS] = 0;
new syncUpTimer = 30;
new MysqlConnectionTimer;

new gPlayerUsingLoopingAnim[MAX_PLAYERS];
new gPlayerAnimLibsPreloaded[MAX_PLAYERS];

// pickupy
new pickupNewsReporterReg;
new pickupGettingDrugs;
new pickupHotDog1;
new pickupHotDog2;
new pickupHotDog3;
new pickupHotDog4;
new pickupHotDog5;
new pickupHotDog6;
new pickupHotel;
new pickupHotel2;
new pickupPayment;
new pickupAcademy;
new pickupIllegalItems;
new pickupPolicePark;
new pickupOrderVehicle;
new pickupTaxi;

enum deadPositionEnum {
	Float:dpX,
	Float:dpY,
	Float:dpZ,
	Float:dpA,
	dpInt,
	dpVW,
	dpDeath,
	dpWeapon,
	dpDeathReason
};

new deadPosition[MAX_PLAYERS][deadPositionEnum];
new hadPlayerBw[MAX_PLAYERS];

enum minifactionsEnum {
	mId,
	mName[MAX_PLAYER_NAME],
	mMOTD[64],
	mLeader,
	Float:mSpawnX,
	Float:mSpawnY,
	Float:mSpawnZ,
	Float:mSpawnA,
	mSpawnInterior,
	mSpawnVW,
	mRank1[32],
	mRank2[32],
	mRank3[32],
	mRank4[32],
	mRank5[32],
	mType // 1 - gang, 2 - firma
};

new MiniFaction[MAX_UNOFFICIAL_FACTIONS][minifactionsEnum];

#define GasMax 100.0
#define RunOutTime 40000
#define RefuelWait 7500

new Float:Gas[MAX_VEHICLES];

new disallowedIcWords[24][] = {
 {";d"}, {":d"}, {":)"}, {";)"}, {":D"}, {"^_^"}, {"xD"}, {";("}, {"x)"}, {":P"}, {":("}, {":*"}, {":-)"}, {":-D"}, {":-X"}, {":-("}, {":-/"}, {":>"}, {":<"}, {";>"}, {";<"}, {";d"}, {";D"}, {"-.-"}
};

new weathers[10][6] = {
  {1, 2, 2, 3, 5, 6},
  {2, 2, 3, 5, 6, 0},
  {0, 4,-1,-1,-1,-1},
  {1, 2, 2, 5, 6, 0},
  {2, 7,-1,-1,-1,-1},
  {1, 2, 2, 3, 6,-1},
  {1, 2, 2, 3, 5,-1},
  {2, 8, 9,-1,-1,-1},
  {9, 2,-1,-1,-1,-1},
  {8, 2,-1,-1,-1,-1}
};

new actWeather = 1;

// enumeratory dla dzwiekow (interakcja z obiektami)
enum PlayerSoundEnum
{
 sObject,
 sSound,              // dzwiek podczas onobjectmoved dla danego object
 Float:sX,
 Float:sY,
 Float:sZ
}

new PlayerSound[MAX_PLAYERS][PlayerSoundEnum];

// enumerator dla bankomatow (po eng. ATM)
enum gAtmEnum
{
  Float:pX,
  Float:pY,
  Float:pZ,
  atmAmount
}

new gAtm[10][gAtmEnum];
new gAtmTimer[MAX_PLAYERS];

new FishNames[22][] = {
 {"Marynarka"},
 {"SledŸ"},
 {"Granik"},
 {"Proteza"},
 {"Majtki Balona"},
 {"Pstr¹g"},
 {"Niebieski Marlin"},
 {"Puszka"},
 {"Makrela"},
 {"Strzêpiciel"},
 {"Buty"},
 {"Szczupak"},
 {"Ryba Pi³a"},
 {"Œmieci"},
 {"Tuñczyk"},
 {"Sardynka"},
 {"Karp"},
 {"Dorsz"},
 {"¯ó³w"},
 {"Okoñ"},
 {"Worek pieniêdzy"},
 {"Miecznik"}
};

/*new Float:gHospSpawns[3][4] = {
 {1143.7264,1356.8403,10.8704,270.8568},
 {1146.3030,1356.8711,10.8704,270.5435},
 {1148.5492,1356.8198,10.8704,271.1701}
};

new Float:gHospCameras[3][3] = {
 {1146.3882,1353.2935,10.8954},
 {1146.3882,1353.2935,10.8954},
 {1146.3882,1353.2935,10.8954}
};

 {1235.5867,764.6609,10.8356,267.3903}, // cela1
 {1235.8129,769.5248,10.8356,275.2237}, // cela2
 {1236.1121,774.0002,10.8357,269.2703}, // cela3
 {1235.8862,778.6633,10.8356,273.9703}, // cela4
 {1235.8954,783.6500,10.8356,268.3303}, // cela5
 {1235.7051,788.3821,10.8356,271.7770}, // cela6
 {1235.8441,792.9019,10.8356,276.4771}, // cela7
 {1235.8580,797.6321,10.8356,271.1504} // cela8*/
 
new Float:gJailSpawns[][4] = {
 {1346.2169,775.3088,10.8387,91.8146}, // cela1
 {1346.1331,769.1191,10.8387,87.2270}, // cela2
 {1325.9590,787.1713,10.8387,88.4972}, // cela3
 {1325.6172,792.9227,10.8387,88.8706}, // cela4
 {1326.2332,799.2473,10.8387,91.2065}, // cela5
 {1326.0564,799.0145,14.7243,86.1280}, // cela6
 {1326.4325,793.3958,14.7243,92.7485}, // cela7
 {1325.7131,787.0074,14.7243,91.7029} // cela8
};

enum pBoxingStats
{
 TitelName[MAX_PLAYER_NAME],
 TitelWins,
 TitelLoses,
};
new Titel[pBoxingStats];

enum pFishing
{
	pFish1[20],
	pFish2[20],
	pFish3[20],
	pFish4[20],
	pFish5[20],
	pWeight1,
	pWeight2,
	pWeight3,
	pWeight4,
	pWeight5,
	pFid1,
	pFid2,
	pFid3,
	pFid4,
	pFid5,
	pLastFish,
	pFishID,
	pLastWeight,
};
new Fishes[MAX_PLAYERS][pFishing];

enum pSpec
{
 Float:Coords[3],
	Float:sPx,
	Float:sPy,
	Float:sPz,
	sPint,
	sLocal,
	sLocalType,
	sVW
};

new Unspec[MAX_PLAYERS][pSpec];

enum dCInfoEnum {
 dPlayerId,
 Float:dEnterX,
 Float:dEnterY,
 Float:dEnterZ,
 Float:dEnterA,
 Float:dExitX,
 Float:dExitY,
 Float:dExitZ,
 Float:dExitA,
 dEnterInterior,
 dExitInterior,
 dEnterVW,
 dExitVW,
 dEnterMessage[64],
 dExitMessage[64],
 dName[64],
 dEnterPickup,
 dExitPickup
};

new DoorCreate[dCInfoEnum];

enum pInfo
{
 pId,
	pLevel,
	pAdmin,
	pPremium,
	pConnectTime,
	pJailCell,
	pSex,
	pAge,
	pCK,
	pMuted,
	pCash,
	pAccount,
	pCrimes,
	pKills,
	pDeaths,
	pArrested,
	pWantedDeaths,
	pFishes,
	pBiggestFish,
	pJob,
	pPayCheck,
	pHeadValue,
	pJailed,
	pJailTime,
	pMats,
	pDrugs,
	pLeader,
	pMember,
	pUFMember,
	pUFLeader,
	pRank,
	pChar,
	pContractTime,
	pDetSkill,
	pSexSkill,
	pBoxSkill,
	pLawSkill,
	pMechSkill,
	pJackSkill,
	pCarSkill,
	pNewsSkill,
	pDrugsSkill,
	pCookSkill,
	pFishSkill,
	pWeaponsSkill,
	pColtSkill,
	Float:pHealth,
	pInt,
	pLocal,
	pLocalType,
	pLocal2,
	pModel,
	pPnumber,
	pPhousekey,
	pBusiness,
	Float:pPos_x,
	Float:pPos_y,
	Float:pPos_z,
	Float:pPos_a,
	pPos_VW,
	pCarLic,
	pFlyLic,
	pBigFlyLic,
	pBoatLic,
	pFishLic,
	pGunLic,
	pPayDay,
	pPayDayHad,
	pWins,
	pLoses,
	pWarns,
	pFuel,
	pMarried,
	pMarriedTo[MAX_PLAYER_NAME],
	pWasCrash,
	pNeedMedicTime,
	pIdCard,
	pHotelId,
	pHotelLocked,
	pThiefInterval,
	pThiefSkill,
	pChangeSpawn,
	pLastIP[25],
	pMatsHolding,
	pPass,
	pPermit,
	pPayment,
	pATMCard,
	pReservedPhone,
	pPizzaTimer,
	pActivated,
	pDuty,
	pMask,
	pWounded,
	pState,
	#if TIKI_EVENT
	pTiki,
	pTikiObject,
	pTalkStyle,
	#endif
	pRadioChannel,
	pOrderVehicle,
	pOrderVehicleCost,
	pOrderVehicleColor,
	pVehiclesInterval,
	pVehicleSpawnInterval,
	pVehicleBuyPermission,
	pStoppedVehicleInterval,
	pStatus,
	pPermissions,
	Text:pHud,
	pTalkStyle,
	pHiddenNametags,
	pInjuriesTime,
	Float:pFoodHealthGrowth,
	pFoodTimer,
	pDialogData[3],
	pDrunkTime,
	pLastPmRecipient,
	pAudioState,
	Text3D:pNametag,
	pInteriorAudio,
	pState2,
	Text3D:pDescriptionText,
	Text3D:opis,
	Text3D:pNicknames3D,
	pDescription[128],
	pDeagle,
	pTextureIphone,
	pSoundid
};
new PlayerInfo[MAX_PLAYERS][pInfo];

enum hInfo
{
 hId,
	Float:hEntrancex,
	Float:hEntrancey,
	Float:hEntrancez,
	Float:hExitx,
	Float:hExity,
	Float:hExitz,
	hOwner,
	hOwnerName[MAX_PLAYER_NAME],
	hDiscription[32],
	hHel,
	hArm,
	hInt,
	hLock,
	hOwned,
	hRent,
	hRentabil,
	hTakings,
	hDate,
	hRubbish,
	hVW,
	hPickup
};

new HouseInfo[104][hInfo];

enum pCrime
{
	pBplayer[MAX_PLAYER_NAME],
	pAccusing[64],
	pPlace[64],
	pAccusedof[32],
	pVictim[MAX_PLAYER_NAME]
};
new PlayerCrime[MAX_PLAYERS][pCrime];

// @TODO: Do przepisania!
enum weaponEnum {
	pGun1,
	pGun2,
	pGun3,
	pGun4,
	pGun5,
	pGun6,
	pGun7,
	pGun8,
	pGun9,
	pGun10,
	pGun11,
	pGun12,
	pAmmo1,
	pAmmo2,
	pAmmo3,
	pAmmo4,
	pAmmo5,
	pAmmo6,
	pAmmo7,
	pAmmo8,
	pAmmo9,
	pAmmo10,
	pAmmo11,
	pAmmo12,
};
new PlayerWeapons[MAX_PLAYERS][weaponEnum];

#define TALK_STYLES_COUNT 10

enum TalkStyleEnum {
 tsName[32],
 tsPremium
}

new TalkStylesInfo[TALK_STYLES_COUNT][TalkStyleEnum] = {
	{"Zwykly", 0},
	{"Gangster 1", 0},
	{"Gangster 2", 0},
	{"Gangster 3", 0},
	{"Gangster 4", 0},
	{"Gangster 5", 0},
	{"Gangster 6", 0},
	{"Gangster 7", 0},
	{"Gangster 8", 0},
	{"Gangster 9", 0}
};

enum jJobEnum {
 jId,
 jName[32],
 Float:jPosX,
 Float:jPosY,
 Float:jPosZ,
 jActive,
 jPickup
}

new Jobs[MAX_JOBS][jJobEnum];

new Text:OfferTextDraw[MAX_PLAYERS];

enum oOfferEnum {
 ofId,
 ofType,
 ofOfferer,
 ofOffererType,
 ofPrice,
 ofValue1,
 ofValue2,
 ofValue3[32],
 ofFlags
}

new Offer[MAX_PLAYERS][oOfferEnum];

enum gOffering   //Oferowanie (z Ang. Offering !UP=/= Down!)
{
	oActive,
	oPlayer,
	oPlayeruid,
	oType,
	oPrice,
	oValue1,
	oValue2,
	oValue3,
	oValue4[64],
}

new Offering[MAX_PLAYERS][gOffering]; //Nie mog³em uzyæ oOfferEnum

enum bInfo
{
 bId,
	bOwnerId,
	bOwnerName[MAX_PLAYER_NAME],
	bName[64],
	bEntranceCost,
	bTill,
	bLocked,
	bInterior,
	bProducts,
	bMaxProducts,
	bPriceProd,
	bType,
	bSelfService
};

new BizzInfo[MAX_BUSINESS_COUNT][bInfo];

// organizacje
enum orgEnum
{
 orgId,
 orgName[32],
 orgHidden,
 Float:orgSpawnX,
 Float:orgSpawnY,
 Float:orgSpawnZ,
 Float:orgSpawnA,
 orgSpawnInterior,
 orgSpawnVw
};

enum orgRankEnum
{
 orRank,
 orOrganization,
 orName[32]
};

new Organizations[MAX_ORGANIZATIONS][orgEnum];
new OrganizationsRanks[MAX_ORGANIZATIONS * MAX_RANKS_PER_ORGANIZATION][orgRankEnum];

// przedmioty
enum pItem {
 iId,
 iItemId,
 iOwner,
 iOwnerType,
 iRestricted,
 iRestrictedType,
 iCount,
 Float:iPosX,
 Float:iPosY,
 Float:iPosZ,
 iPosVW,
 iFlags,
 iFlags2,
 iAttr1,
 iAttr2,
 iAttr3,
 iAttr4,
 iAttr5[32],
 iCreatedAt[24],
 Text3D:iLabel,
 iObject
}

enum pItemType {
 itId,
 itName[32],
 itFlags,
 itType,
 itCount,
 itAttr1,
 itAttr2,
 itAttr3,
 itAttr4,
 itAttr5[32],
 itAttr1Name[32],
 itAttr2Name[32],
 itAttr3Name[32],
 itAttr4Name[32],
 itAttr5Name[32],
 itHelp[64],
 itColor,
 Float:itObject[7]
}


new Items[MAX_ITEMS][pItem];
new ItemsTypes[MAX_ITEMS_TYPES][pItemType];

// pojazdy
enum vEnum
{
  vId,
  vOwner,
  vOwnerType,
  vModel,
  Float:vPosx,
  Float:vPosy,
  Float:vPosz,
  Float:vPosa,
  vColor1,
  vColor2,
  vFlags,
  vFlags2,
  vLocked,
  Float:vFuel,
  vInsurances,
  vDestroyed,
  vGarage,
  Float:vHealth,
  vOwnerName[50],
  vTimer,
  vType,
  vPaintJob,
  Text3D:vDescriptionText,
  vDescription[128],
  vSpawned // dla zabezpieczenia - kiedy dochodzi do pierwszego spawnu, komponenty pokaz¹ siê szybciej ni¿ po respawnie wozów przyk³adowo
};

enum vcEnum
{
  vcModel,
  vcName[32],
  vcCost,
  vcInsurances,
  vcInsuranceCost,
	vcCapacity
}

new Vehicles[MAX_VEHICLES+1][vEnum];
new VehiclesCost[MAX_VEHICLES+1][vcEnum];

new yesorno[2][5] = {"Nie", "Tak"};

// weapon system

new MatsTaken[MAX_PLAYERS];
