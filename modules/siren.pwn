#include <a_samp>

#define COLOR_GREY 0xAFAFAFAA

enum PoliceEnum
{
	bool:Use,
	Siren,
	ObjectID,
	Value,
	Timer
};
new Police[MAX_VEHICLES][PoliceEnum];
forward OnPoliceSiren(vehicleid);

public OnPoliceSiren(vehicleid)
{
    if(Police[vehicleid][Use] == true)
    {
        new param[4];
	    GetVehicleDamageStatus(vehicleid,param[0],param[1],param[2],param[3]);
		if(Police[vehicleid][Value] == 0)
		{
	        UpdateVehicleDamageStatus(vehicleid,param[0],param[1],1,param[3]);
			AttachObjectToVehicle(Police[vehicleid][ObjectID],vehicleid,0.7,0.0,-0.7,0.0,0.0,0.0);
			Police[vehicleid][Value] = 1;
		}
		else if(Police[vehicleid][Value] == 1)
		{
	        UpdateVehicleDamageStatus(vehicleid,param[0],param[1],4,param[3]);
            AttachObjectToVehicle(Police[vehicleid][ObjectID],vehicleid,-0.7,0.0,-0.7,0.0,0.0,0.0);
            Police[vehicleid][Value] = 0;
		}
    }
}
