/*****************************/
//Pragma
#pragma semicolon 1
#pragma newdecls required

/*****************************/
//Defines
#define PLUGIN_DESCRIPTION "Offers other plugins easy API for some basic TF2 features."
#define PLUGIN_VERSION "1.0.0"

/*****************************/
//Includes
#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>

/*****************************/
//Forwards

forward Action TF2_OnObjectDamaged(int entity, TFObjectType type, int& attacker, int& inflictor, float& damage, int& damagetype);
Handle g_Forward_OnObjectDamaged;

forward void TF2_OnObjectDamagedPost(int entity, TFObjectType type, int& attacker, int& inflictor, float& damage, int& damagetype);
Handle g_Forward_OnObjectDamagedPost;

/*****************************/
//Globals

/*****************************/
//Plugin Info
public Plugin myinfo = 
{
	name = "[TF2] API", 
	author = "Keith Warren (Drixevel)", 
	description = PLUGIN_DESCRIPTION, 
	version = PLUGIN_VERSION, 
	url = "https://github.com/drixevel"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("tf2-api");
	
	g_Forward_OnObjectDamaged = CreateGlobalForward("TF2_OnObjectDamaged", ET_Event, Param_Cell, Param_Cell, Param_CellByRef, Param_CellByRef, Param_FloatByRef, Param_CellByRef);
	g_Forward_OnObjectDamagedPost = CreateGlobalForward("TF2_OnObjectDamagedPost", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Float, Param_Cell);
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	CreateConVar("sm_tf2_api_version", PLUGIN_VERSION, PLUGIN_DESCRIPTION, FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_SPONLY | FCVAR_DONTRECORD);
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (StrContains(classname, "obj_", false) != -1)
	{
		SDKHook(entity, SDKHook_OnTakeDamage, Object_OnTakeDamage);
		SDKHook(entity, SDKHook_OnTakeDamagePost, Object_OnTakeDamagePost);
	}
}

public Action Object_OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype)
{
	Call_StartForward(g_Forward_OnObjectDamaged);
	Call_PushCell(victim);
	Call_PushCell(TF2_GetObjectType(victim));
	Call_PushCellRef(attacker);
	Call_PushCellRef(inflictor);
	Call_PushFloatRef(damage);
	Call_PushCellRef(damagetype);
	
	Action status = Plugin_Continue;
	Call_Finish(status);
	
	return status;
}

public void Object_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype)
{
	Call_StartForward(g_Forward_OnObjectDamagedPost);
	Call_PushCell(victim);
	Call_PushCell(TF2_GetObjectType(victim));
	Call_PushCell(attacker);
	Call_PushCell(inflictor);
	Call_PushFloat(damage);
	Call_PushCell(damagetype);
	Call_Finish();
}