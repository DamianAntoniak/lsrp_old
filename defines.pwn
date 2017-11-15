#define dcmd(%1,%2,%3)       if ((strcmp((%3)[1], #%1, true, (%2)) == 0) && ((((%3)[(%2) + 1] == 0) && (dcmd_%1(playerid, "")))||(((%3)[(%2) + 1] == 32) && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1
#define dcmdalt(%1,%2,%3,%4) if ((strcmp((%3)[1], #%4, true, (%2)) == 0) && ((((%3)[(%2) + 1] == 0) && (dcmd_%1(playerid, "")))||(((%3)[(%2) + 1] == 32) && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1

#define benchmarkinit(); new bmi,bmt1=GetTickCount(),bmt2;
#define benchmark(%0,%1,%2); for(bmi=0;bmi<%0;bmi++)%1(%2);bmt2=GetTickCount(),bmt1=bmt2-bmt1,printf("\n"#%1"\n -> Average time per call : %8.f ns\n -> Total execution time  : %8d ms\n -> Calls per second      : %8.f calls",(float(bmt1)/%0)*1000000,bmt1,(%0.0/bmt1)*1000),bmt1=bmt2;

#define strreplace_fast(%1,%2,%3) for(new i = 0; i < strlen(%3); i++) { if(%3[i] == %1) %3[i] = %2; }
#define IsKeyJustDown(%1,%2,%3) ((%2 & %1) && !(%3 & %1))
#define IsPlayerBusy(%1) !(PlayerInfo[%1][pNeedMedicTime] == 0 && PlayerInfo[%1][pWounded] == 0)

#define SetDisabledWeapons(%1,%2) \
  new weapon = GetPlayerWeapon(%1); switch(weapon) { case %2: { GivePlayerWeapon(%1, weapon, -GetPlayerAmmo(%1)); return 0; } }

#define IsValidFightStyle(%1) ((%1 >= 4 && %1 <= 7) || %1 == 15 || %1 == 26)
#define GetPlayerOrganization(%1) (PlayerInfo[%1][pMember] > 0 ? PlayerInfo[%1][pMember] : PlayerInfo[%1][pLeader])
#define GetPlayerUnofficialOrganization(%1) (PlayerInfo[%1][pUFLeader] < MAX_UNOFFICIAL_FACTIONS+1 ? PlayerInfo[%1][pUFLeader] : PlayerInfo[%1][pUFMember])
#define GetPlayerBusiness(%1) (PlayerInfo[%1][pBusiness] != -1 ? PlayerInfo[%1][pBusiness] : GetOwnedBusiness(%1))
#define GetVehicleType(%1) Vehicles[%1][vType]
#define RespawnPlayer(%1) \
 SetPlayerSpawn(%1, SET_SPAWN_POSITION);\
 SetPlayerSpawn(%1, SET_SPAWN_WHERE_SPAWN);\
 SpawnPlayer(%1)
#define HasPremiumAccount(%1) (PlayerInfo[%1][pPremium])

#define YesOrNo(%1) yesorno[((%1 == 0 || %1 == 2) ? %1 : 1)]

#define IsPlayerLoggedIn(%1) (gPlayerLogged[%1] == 1)

#define IsValidJob(%1) ((%1 >= 0 && %1 < sizeof(Jobs)) && Jobs[%1][jId] != INVALID_JOB_ID)
#define IsValidOrganization(%1) ((%1 >= 0 && %1 < sizeof(Organizations)) && Organizations[%1][orgId] != -1)
#define IsActiveJob(%1) (IsValidJob(%1) && Jobs[%1][jActive] == 1)
#define GetPlayerSex(%1) ((PlayerInfo[%1][pSex] == 2 || PlayerInfo[%1][pSex] == 1) ? PlayerInfo[%1][pSex] : 1)

// playerid, statement, color1, color2
#define SetPlayerColorStatement(%1,%2,%3,%4) SetPlayerColor(%1, %2 ? %3 : %4)
#define IsAnInstructor(%1) (GetPlayerOrganization(%1) == 11)

#define IsSkinValid(%1) \
 ((%1 >= 0 && %1 <= 1)||(%1 == 2)||(%1 == 7)||(%1 >= 9 && %1 <= 41)||(%1 >= 43 && %1 <= 85)||(%1 >=87 && %1 <= 118)||(%1 >= 120 && %1 <= 148)|| \
   (%1 >= 150 && %1 <= 207)||(%1 >= 209 && %1 <= 272)||(%1 >= 274 && %1 <= 288)||(%1 >= 290 && %1 <= 299))
   
#define IsACar(%1) \
 (!IsABoat(%1) && !IsABike(%1) && !IsAirVehicle(%1))
  
#define chrtoupper(%1) \
	(((%1) > 0x60 && (%1) <= 0x7A) ? ((%1) ^ 0x20) : (%1))

#define chrtolower(%1) \
	(((%1) > 0x40 && (%1) <= 0x5A) ? ((%1) | 0x20) : (%1))

#define ucfirst(%1) \
  %1[0] = chrtoupper(%1[0])
  
#define dcfirst(%1) \
  %1[0] = chrtolower(%1[0])

#define isnull(%1) \
	((%1[0] == 0) || (%1[0] == 1 && %1[1] == 0))

 // Y_Less's macro for distance checking
#define Type8(%0,%1,%2,%3,%4,%5,%6) \
	((((%0) - (%3)) * ((%0) - (%3))) + (((%1) - (%4)) * ((%1) - (%4))) + (((%2) - (%5)) * ((%2) - (%5))) <= ((%6) * (%6)))

#define GetDistanceBetweenPoints(%0,%1,%2,%3,%4,%5) \
  floatsqroot((((%0) - (%3)) * ((%0) - (%3))) + (((%1) - (%4)) * ((%1) - (%4))) + (((%2) - (%5)) * ((%2) - (%5))))

#undef MAX_PLAYERS
#define MAX_PLAYERS 350

//#define DISABLED_WEAPONS 44, 45

#define TIKI_EVENT                 0

// czy kompilujemy dla beta serwera?
#define BETA                       1

#define MYSQL_HOST                 "178.63.33.130"

#if BETA
  #define MYSQL_USER                 "zbigniew"
  #define MYSQL_PASS                 "tapetanaryj1"
  #define MYSQL_DB                   "site-beta"
/*#else
  #define MYSQL_USER                 "rumcajs"
  #define MYSQL_PASS                 "d2Xatuja"
  #define MYSQL_DB                   "site"*/
#endif

#define STRANGER_NAME              "Nieznajomy"

#define MODE_VERSION               "1.6"

// position for hidden cars
#define CAR_HIDE_X                 643.3451
#define CAR_HIDE_Y                 -4103.5815
#define CAR_HIDE_Z                 -67.4484

#define CORPSES                    0

// unofficial factions
#define MAX_UNOFFICIAL_FACTIONS    400
#define UFACTION_TYPE_GANG         1
#define UFACTION_TYPE_COMPANY      2

#define LOCAL_AHK                  1001
#define LOCAL_LCN                  1002

#define FAKE_INTERIOR_VW_ID        150

#define MAX_STRING                 255
#define CHECKPOINT_NONE            0
#define CHECKPOINT_HOME            12
#define CHECKPOINT_VEHICLE         1
#define CHECKPOINT_PIZZA           2
#define CHECKPOINT_RACE            3

#define COLOR_GRAD1                0xB4B5B7FF
#define COLOR_GRAD2                0xBFC0C2FF
#define COLOR_HELP5                0xFFFF9DFF
#define COLOR_GRAD3                0xCBCCCEFF
#define COLOR_REKLAMA              0x00FF00FF
#define COLOR_GRAD4                0xD8D8D8FF
#define COLOR_YETI                 0x006291FF
#define COLOR_GRAD5                0xE3E3E3FF
#define COLOR_GRAD6                0xF0F0F0FF
#define COLOR_GREY                 0xAFAFAFAA
#define COLOR_GREEN                0x33AA33AA
#define COLOR_RED                  0xB44B4BFF
#define COLOR_LIGHTRED             0xFF6347AA
#define COLOR_LIGHTBLUE            0x33CCFFAA
#define COLOR_LIGHTGREEN           0x9ACD32AA
#define COLOR_YELLOW               0xFFFF00AA
#define COLOR_YELLOW2              0xF5DEB3AA
#define COLOR_WHITE                0xFFFFFFAA
#define COLOR_NEWSL                0x62FF62FF
#define COLOR_NEWS2                0xF3BE5EFF
#define COLOR_FADE1                0xE6E6E6E6
#define COLOR_FADE2                0xC8C8C8C8
#define COLOR_FADE3                0xAAAAAAAA
#define COLOR_FADE4                0x8C8C8C8C
#define COLOR_FADE5                0x6E6E6E6E
#define COLOR_PURPLE               0xC2A2DAAA
#define COLOR_PURPLEF              0xC2A2DAFF
#define COLOR_DBLUE                0x2641FEAA
#define COLOR_ALLDEPT              0xFF8282AA
#define COLOR_NEWS                 0xFFA500AA
#define COLOR_OOC                  0xE0FFFFAA
#define COLOR_OOC2                  0xE0FFFFAA
#define COLOR_CREAM                0xf0d9abff
#define TEAM_NONE                  0
#define TEAM_CYAN                  1
#define TEAM_BLUE                  2
#define TEAM_GREEN                 3
#define TEAM_ORANGE                4
#define TEAM_COR                   5
#define TEAM_BAR                   6
#define TEAM_TAT                   7
#define TEAM_CUN                   8
#define TEAM_STR                   9
#define TEAM_HIT                   10
#define TEAM_ADMIN                 11
#define OBJECTIVE_COLOR            0x64000064
#define TEAM_GREEN_COLOR           0xFFFFFFAA
#define TEAM_JOB_COLOR             0xFFB6C1AA
#define TEAM_HIT_COLOR             0xFFFFFF00
#define TEAM_BLUE_COLOR            0x8D8DFF00
#define COLOR_ADD                  0x63FF60AA
#define TEAM_GROVE_M_COLOR         0x46B13BFF
#define TEAM_GROVE_COLOR           0x00D900C8
#define TEAM_VAGOS_COLOR           0xFFC801C8
#define TEAM_BALLAS_COLOR          0xD900D3C8
#define TEAM_AZTECAS_COLOR         0x01FCFFC8
#define TEAM_CYAN_COLOR            0xFF8282AA
#define TEAM_ORANGE_COLOR          0xFF830000
#define TEAM_COR_COLOR             0x39393900
#define TEAM_BAR_COLOR             0x00D90000
#define TEAM_TAT_COLOR             0xBDCB9200
#define TEAM_CUN_COLOR             0xD900D300
#define TEAM_STR_COLOR             0x01FCFF00
#define TEAM_ADMIN_COLOR           0x00808000
#define TEAM_BLUE2_COLOR           0x00926968
#define COLOR_INVIS                0xAFAFAF00
#define COLOR_SPEC                 0xBFC0C200
#define COLOR_LORANGE              0xE87732FF
#define COLOR_AWHITE               0xEFEFEFFF
#define COLOR_DO_BLUE              0xA3A1C8AA
#define COLOR_NRADIO               0xFFF16E00
#define TEAM_FIRE_DEPARTMENT       0xFF8A00FF
#define MAX_POINTS                 1

#define COLOR_DROPPED_ITEM         0xEFEFEFFF

#define DRINK_BEER                 1
#define DRINK_VODKA                2
#define DRINK_WHISKEY              3
#define DRINK_WATER                4
#define DRINK_SODA                 5

#define SPECIAL_ACTION_USECELLPHONE      11
#define SPECIAL_ACTION_SITTING           12
#define SPECIAL_ACTION_STOPUSECELLPHONE  13
#define SPECIAL_ACTION_PISSING           68

#define ATM_MONEY                  60000
#define HOUSES_COUNT               34
#define ALARM_NONE                 0
#define ALARM_STANDARD             1
#define ALARM_TAZER                2
#define ALARM_TAZER_SMS            3
//Kolory teamów
#define TEAM_MEDIC_COLOR           0x00A0A601
#define TEAM_COP                   2
#define TEAM_COP_COLOR             0x33CCFFAA
#define TEAM_REPORT                9
#define TEAM_REPORT_COLOR          0xFF6347AA
#define TEAM_TAXI                  10
#define TEAM_TAXI_COLOR            0xFFFF00AA
#define TEAM_INSTR                 11
#define TEAM_INSTR_COLOR           0xAA3333AA
#define OWN_CAR_COST               4000000
#define INVALID_RADIO_CHANNEL      0
#define RADIO_OFF                  -1

// debug mode
#define DEBUG                      0
#define MOVIE_MODE                 0
// level mode (0 - wylaczony, 1 - wlaczony)
#define LEVEL_MODE                 0
#define STATIC_VEHICLE             0

#define VEHICLE_SELECTED           1
#define VEHICLE_DESTROYED          2
#define VEHICLE_MODDED             4

#define VEHICLE_FLAG_SPAWNED       1

#define VEHICLES_SPAWNED_LIMIT     1
#define VEHICLES_SPAWNED_LIMIT_PREMIUM     3

#define VEHICLE_TYPE_TAXI          1
#define VEHICLE_TYPE_PIZZA         2
#define VEHICLE_TYPE_NEWS          3

#define PLAYER_VCHECKPOINT         1

#define MAX_COMPONENTS             17

#define ITEM_VEHICLE_PROCESS_ACTIVATE 1
#define ITEM_VEHICLE_PROCESS_DEACTIVATE 0

#define SPLIT_TEXT_LIMIT           80
#define SPLIT_TEXT1_FROM           0
#define SPLIT_TEXT1_TO             65
#define SPLIT_TEXT2_FROM           65
#define SPLIT_TEXT2_TO             130

#define CONTENT_TYPE_NONE                        0
#define CONTENT_TYPE_USER                        3
#define CONTENT_TYPE_HOUSE                       14
#define CONTENT_TYPE_UNOFFICIAL_ORGANIZATION     26
#define CONTENT_TYPE_ORGANIZATION                27
#define CONTENT_TYPE_BUSINESS                    52
#define CONTENT_TYPE_VEHICLE                     43
#define CONTENT_TYPE_ITEM                        51
#define CONTENT_TYPE_ITEMTYPE                    50 

#define STATUS_NONE                              0
#define STATUS_SEL_TALKSTYLE                     1

#define MAX_JOBS 20
#define INVALID_JOB_ID -1

// offers

#define INVALID_OFFER_ID -1
#define HAS_ALREADY_GOT_OFFER -2
#define OFFER_FAILED -3

#define OFFER_TYPE_PAYMENT 1
#define OFFER_TYPE_YESNO   2

#define OFFER_ID_JOB       1
#define OFFER_ID_ITEM      2
#define OFFER_ID_VEHICLE   3
#define OFFER_ID_CHEQUE    4
#define OFFER_ID_BIUSINESS_PRODUCT 5
#define OFFER_ID_BET       6

#define OFFER_FLAG_CHECK_DISTANCE      1
#define OFFER_FLAG_INFO_COMMAND        2
#define OFFER_FLAG_CAN_OFFER_HIMSELF   4
#define OFFER_FLAG_SINGLE_TRANSACTION  8


// biznesy

#define INVALID_BUSINESS_ID -1
#define MAX_BUSINESS_COUNT  500
#define INVALID_BUSINESS_ID -1

#define CENTRAL_BUSINESS_ID 4

#define BUSINESS_TYPE_HOTEL 1

#define BUSINESS_MOTEL_JEFFERSON_ID  2
#define BUSINESS_MOTEL_IDLEWOOD_ID   3
#define BUSINESS_HOTEL_RODEO_ID      4

// spawn

#define SET_SPAWN_POSITION  1
#define SET_SPAWN_WHERE_SPAWN  2

// organizacje

#define MAX_ORGANIZATIONS 25
#define MAX_RANKS_PER_ORGANIZATION 15

// przedmioty

#define MAX_PLAYER_ITEMS 5
#define INVALID_ITEM_ID -1
#define HAS_UNUSED_ITEM_ID -2
#define HAS_REACHED_LIMIT -3
#define MAX_ITEMS 10000
#define MAX_ITEMS_TYPES 1000

#define ITEM_FLAG_SELLABLE    1
#define	ITEM_FLAG_DROPABLE    2
#define	ITEM_FLAG_USABLE      4
#define	ITEM_FLAG_STACKABLE   8
#define	ITEM_FLAG_DESTROYABLE 16
#define	ITEM_FLAG_UNIQUE      32
#define ITEM_FLAG_SINGLE      64
#define ITEM_FLAG_SINGLE_TYPE 128
// flaga ponizej jest nieuzywana
#define ITEM_FLAG_WEAPON      256
#define ITEM_FLAG_TOGGABLE    512
// flaga ponizej jest nieuzywana
#define ITEM_FLAG_WEAPON_MATS 1024
// flaga ponizej jest nieuzywana
#define ITEM_FLAG_CONTAINER   2048

#define ITEM_FLAG_DROPPED   1
#define ITEM_FLAG_USING     2

#define ITEM_FLAG_SELECTED  1

#define ITEM_WATCH          1
#define ITEM_DICE           2
#define ITEM_CELLPHONE      3
#define ITEM_PHONEBOOK      4
#define ITEM_RADIO          5
#define ITEM_SKATE          6
#define ITEM_CANISTER       7
#define ITEM_BAR            8
#define ITEM_SDPISTOL       9
#define ITEM_SPRAY          10
#define ITEM_CIGARETTE      46
#define ITEM_CORPSE         47
#define ITEM_CHEQUE_BOOK    56
#define ITEM_CHEQUE         57
#define ITEM_MARIHUANA      59
#define ITEM_CRACK          60
#define ITEM_AMPHETAMINE    61
#define ITEM_LICENSE_CAR    80
#define ITEM_MASK           81
#define ITEM_CAR_PAINT      261
#define ITEM_WATCH2         310
#define ITEM_PASS           313
#define ITEM_DRUG           314


#define ITEM_TYPE_NONE          0
#define ITEM_TYPE_WEAPON        1
#define ITEM_TYPE_WEAPON_MATS   2
#define ITEM_TYPE_CONTAINER     3
#define ITEM_TYPE_DRUGS         4
#define ITEM_TYPE_SKIN          5
#define ITEM_TYPE_CAR_COMPONENT 6
#define ITEM_TYPE_FOOD          7
#define ITEM_TYPE_ALCOHOL       8
#define ITEM_TYPE_HOLDABLE      9
//#define ITEM_TYPE_ARMOR         10

#define PLAYER_ITEMS_LIMIT  15
#define VEHICLE_ITEMS_LIMIT 10

// pojazdy

#define IsValidVehicleModel(%1) (%1 >= 400 && %1 < 611)
#define GetPlayerSpawnedVehiclesLimit(%1) (PlayerInfo[%1][pPremium] ? VEHICLES_SPAWNED_LIMIT_PREMIUM : VEHICLES_SPAWNED_LIMIT)
#define VehiclesLimit(%1) (PlayerInfo[%1][pPremium] ? 15 : 3)
#define GetVehicleName(%1) VehiclesName[((GetVehicleModel(%1))-(400))]
#define GetVehicleNameByModel(%1) VehiclesName[((%1)-(400))]
#define SpawnUserVehicle(%1,%2) SpawnVehicle(%2)
#define IsValidComponent(%1) (%1 >= 1000 && %1 <= 1193)
#define SetVehicleHealthEx(%1,%2) \
  Vehicles[%1][vHealth] = %2; \
  SetVehicleHealth(%1, %2)
#define SetVehicleModded(%1) Vehicles[%1][vFlags2] += VEHICLE_MODDED
#define SetVehicleNotModded(%1) if(Vehicles[%1][vFlags] & VEHICLE_MODDED) Vehicles[%1][vFlags] -= VEHICLE_MODDED
#define CalculatePlayerDrunkLevel(%1) (PlayerInfo[%1][pDrunkTime] <= 1 ? 0 : 2500 + floatround(PlayerInfo[%1][pDrunkTime]*0.55))

// dla samp03
#define PlayerToPoint(%1,%2,%3,%4,%5) \
	IsPlayerInRangeOfPoint(%2, %1, %3, %4, %5)

// dialogi
#define DIALOG_ITEMS_LIST   1
#define DIALOG_ITEM_OPTIONS 2
  #define DIALOG_IO__USE          1
  #define DIALOG_IO__SELL         2
  #define DIALOG_IO__LEAVE        3
  #define DIALOG_IO__DROP         4
  #define DIALOG_IO__DESTROY      5
  #define DIALOG_IO__INFO         6
  #define DIALOG_IO__SHOW_INFO    7
  #define DIALOG_IO__MARK         8
#define DIALOG_LOGIN        3
#define DIALOG_LOGIN_MSGBOX 4

#define DIALOG_HELP_LIST         5
#define DIALOG_HELP_SEARCH  6
#define DIALOG_HELP_SELECT  7
#define DIALOG_HELP_DESCRIPTION 8

#define DIALOG_RESPRAY 9
#define DIALOG_INT_RADIO 10
#define DIALOG_SEARCH_ITEMS_LIST 11
#define DIALOG_BUSINESS_P_LIST 12
#define DIALOG_NO_ACCOUNT 13
#define DIALOG_KICK_FOR_PLAYER 14
#define DIALOG_WARN_FOR_PLAYER 15
#define DIALOG_AJ_FOR_PLAYER 16
#define DIALOG_UNWARN_FOR_PLAYER 17
#define DIALOG_BLOCK_FOR_PLAYER 18
#define DIALOG_BAN_FOR_PLAYER 19
#define DIALOG_GUN_FOR_PLAYER 20
#define DIALOG_AUDIO_PLUGIN 21
#define DIALOG_ONLINE 22
#define DIALOG_YO 23
#define DIALOG_CALL 24
#define DIALOG_SMS 25
#define DIALOG_SMS_NR 26
#define DIALOG_CONTACTS 27
#define DIALOG_FM_2 28
#define DIALOG_PHONE_OPTIONS 29
#define DIALOG_ADDITVE 30
#define DIALOG_VCARD 31
#define DIALOG_ACCEPT 32
#define DIALOG_VCARD_DELETE 33
#define DIALOG_VCARD_DELETE_2 34
#define DIALOG_MP3 35
#define DIALOG_INFO_IPHONE 36
#define DIALOG_MUZYKA 37
#define DIALOG_MUZYKA_2 38
#define DIALOG_MUZYKA_3 39
#define DIALOG_FM 40
#define DIALOG_CONNECTION_SELECTION 41

#define DIALOG_HELP 500
#define DIALOG_INFO 550
#define DIALOG_NONE         1000

#pragma unused SkipAntiAirbrk
#pragma unused intrate

#define sprobuj(%1,%2) 	SendClientMessageEx(14.0, %1, %2, COLOR_PURPLE, COLOR_PURPLE2, COLOR_PURPLE3, COLOR_PURPLE4, COLOR_PURPLE5)
#define COLOR_PURPLE 	0xC2A2DAAA
#define COLOR_PURPLE2 	0xBB98D6FF
#define COLOR_PURPLE3 	0xAD83CDFF
#define COLOR_PURPLE4 	0xA778C9FF
#define COLOR_PURPLE5 	0x9963C0FF
// weapon system

#define MAX_LANDING_ZONES 6
#define LANDING_SPOT 3
#define PARACHUTE_SPEED 7.5
#define DROP_ZONE_SIZE 10.0

#define SpotCoords[%0] DropZones[paraspot][pararand][pc%0]

#define AUDIO_STATE_DISCONNECTED 0
#define AUDIO_STATE_DOWNLOADING 1
#define AUDIO_STATE_CONNECTED 2
//LSN
#define SAN_NEWS    "~>~ VIBE:~w~ Aktualnie nic nie jest nadawane."


#define VCARD_MESSAGE  "~w~Proba ~r~polaczenia ~w~z innym telefonem w toku..."
#define NO_PLAYERS_MESSAGE "~n~~n~~n~~n~~n~~n~~n~~y~Brak graczy w poblizu!"
#define ANIM_MESSAGE   "Oferta wys³ana."
#define OFFERING_VCARD  1 // Wizytówka vcard
#define OFFERING_ANIM   2 // Animacja YO test
#define OFFERING_ANIM2  3
#define OFFERING_ANIM3  4
#define OFFERING_ANIM4  5
#define OFFERING_ANIM5  6
#define OFFERING_ANIM6  7
#define OFFERING_ANIM7  8
#define OFFERING_TOUCH  9 //kontakt

#define PPM  1
#define Anim_After_Shot 1 //animacje po postrzale
//Skils to use weapons
#define Skills_Weapons_All 0  // Slot
  #define Skills_Weapons_22 0 // 2
  #define Skills_Weapons_23 0 // 2
  #define Skills_Weapons_24 0 // 2
  #define Skills_Weapons_25 0 // 3
  #define Skills_Weapons_26 0 // 3
  #define Skills_Weapons_27 0 // 3
  #define Skills_Weapons_28 0 // 4
  #define Skills_Weapons_29 0 // 4
  #define Skills_Weapons_32 0 // 4
  #define Skills_Weapons_30 0 // 5
  #define Skills_Weapons_31 0 // 5
  #define Skills_Weapons_33 0 // 6
  #define Skills_Weapons_34 0 // 6
  #define Skills_Weapons_35 0 // 7!

//In the testing phase!
#define Audio_Info 0
#define ANIM_YO 1
#define ANIM_YO2 2
#define ANIM_YO3 3
#define ANIM_YO4 4
#define ANIM_YO5 5
#define ANIM_YO6 6
#define ANIM_YO7 7

#define foreachEx(%2,%1) 	for(new %2 = 0; %2 < %1; %2++)
