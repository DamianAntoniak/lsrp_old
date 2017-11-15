#define EVENTS_SLOTS_COUNT 100
#define INVALID_EVENT_ID -1

#define Event_OnPlayerConnect 1
#define dcmd(%1,%2,%3)       if ((strcmp((%3)[1], #%1, true, (%2)) == 0) && ((((%3)[(%2) + 1] == 0) && (dcmd_%1(playerid, "")))||(((%3)[(%2) + 1] == 32) && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1
enum enumEvent {
 evId,
 evFuncName[32]
}

new Events[EVENTS_SLOTS_COUNT][enumEvent];
new EventsArguments[2][16] = {
 "d",
 "dd"
};

stock Events_BindEvent(eventid, funcname[])
{
 for(new i = 0; i < EVENTS_SLOTS_COUNT; i++)
 {
  if(Events[i][evId] != INVALID_EVENT_ID)
  {
   Events[i][evId] = eventid;
   strmid(Events[i][evFuncName], funcname, 0, strlen(funcname), 255);

   return 1;
  }
 }

 return 1;
}

stock Events_UnbindEvent(eventid, funcname[])
{
 for(new i = 0; i < EVENTS_SLOTS_COUNT; i++)
 {
  if(Events[i][evId] == eventid && strcmp(Events[i][evFuncName], funcname, true) == 0)
  {
   Events[i][evId] = INVALID_EVENT_ID;

   return 1;
  }
 }

 return 1;
}

stock Events_TriggerEvent(eventid, ...)
{
 new argumentCount = numargs();

 for(new i = 0; i < EVENTS_SLOTS_COUNT; i++)
 {
  if(Events[i][evId] == eventid)
  {
   switch(argumentCount)
   {
    case 0: { CallLocalFunction(Events[i][evFuncName], ""); }
    case 1: { CallLocalFunction(Events[i][evFuncName], EventsArguments[eventid], getarg(0)); }
    case 2: { CallLocalFunction(Events[i][evFuncName], EventsArguments[eventid], getarg(0), getarg(1)); }
    case 3: { CallLocalFunction(Events[i][evFuncName], EventsArguments[eventid], getarg(0), getarg(1), getarg(2)); }
    case 4: { CallLocalFunction(Events[i][evFuncName], EventsArguments[eventid], getarg(0), getarg(1), getarg(2), getarg(3)); }
    case 5: { CallLocalFunction(Events[i][evFuncName], EventsArguments[eventid], getarg(0), getarg(1), getarg(2), getarg(3), getarg(4)); }
   }
  }
 }

 return 1;
}
