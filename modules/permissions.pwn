#define HAS_ALREADY_PERMISSION -1
#define HAS_NO_PERMISSION -1

#define NO_PERMISSIONS 0
#define PERM_MATS_SUPPLIER 1

#define SUBMACHINE_SUPPLIER 2
#define RIFLE_SUPPLIER 4
#define ALL_SUPPLIER 8

#define CREATING_INTERIORS 16

forward HasPermission(playerid, permission);
public HasPermission(playerid, permission)
{
 return PlayerInfo[playerid][pPermissions] & permission;
}

forward AddPermission(playerid, permission);
public AddPermission(playerid, permission)
{
 if(HasPermission(playerid, permission)) return HAS_ALREADY_PERMISSION;

 PlayerInfo[playerid][pPermissions] += permission;
 return 1;
}

forward RemovePermission(playerid, permission);
public RemovePermission(playerid, permission)
{
 if(!HasPermission(playerid, permission)) return HAS_NO_PERMISSION;

 PlayerInfo[playerid][pPermissions] -= permission;
 return 1;
}