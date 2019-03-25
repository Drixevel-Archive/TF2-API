/*****************************/
//Pragma
#pragma semicolon 1
#pragma newdecls required

/*****************************/
//Defines
#define PLUGIN_DESCRIPTION "Offers other plugins easy API for some basic TF2 features."
#define PLUGIN_VERSION "1.0.6"

#define MAX_BUTTONS 25

/*****************************/
//Includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>

/*****************************/
//Forwards

forward Action TF2_OnObjectDamaged(int entity, TFObjectType type, int& attacker, int& inflictor, float& damage, int& damagetype);
Handle g_Forward_OnObjectDamaged;

forward void TF2_OnObjectDamagedPost(int entity, TFObjectType type, int& attacker, int& inflictor, float& damage, int& damagetype);
Handle g_Forward_OnObjectDamagedPost;

forward Action TF2_OnClassChange(int client, TFClassType& class);
Handle g_Forward_OnClassChange;

forward void TF2_OnClassChangePost(int client, TFClassType class);
Handle g_Forward_OnClassChangePost;

forward void TF2_OnWeaponFirePost(int client, int weapon);
Handle g_Forward_OnWeaponFirePost;

forward void TF2_OnButtonPressPost(int client, int button);
Handle g_Forward_OnButtonPressPost;

forward void TF2_OnButtonReleasePost(int client, int button);
Handle g_Forward_OnButtonReleasePost;

forward Action TF2_OnCallMedic(int client);
Handle g_Forward_OnCallMedic;

forward void TF2_OnCallMedicPost(int client);
Handle g_Forward_OnCallMedicPost;

forward Action TF2_OnRegeneratePlayer(int client);
Handle g_Forward_OnRegeneratePlayer;

forward void TF2_OnRegeneratePlayerPost(int client);
Handle g_Forward_OnRegeneratePlayerPost;

forward void TF2_OnMedicHealPost(int client, int target);
Handle g_Forward_OnMedicHealPost;

/*****************************/
//Globals

int g_LastButtons[MAXPLAYERS + 1];

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
	g_Forward_OnClassChange = CreateGlobalForward("TF2_OnClassChange", ET_Event, Param_Cell, Param_CellByRef);
	g_Forward_OnClassChangePost = CreateGlobalForward("TF2_OnClassChangePost", ET_Ignore, Param_Cell, Param_Cell);
	g_Forward_OnWeaponFirePost = CreateGlobalForward("TF2_OnWeaponFirePost", ET_Ignore, Param_Cell, Param_Cell);
	g_Forward_OnButtonPressPost = CreateGlobalForward("TF2_OnButtonPressPost", ET_Ignore, Param_Cell, Param_Cell);
	g_Forward_OnButtonReleasePost = CreateGlobalForward("TF2_OnButtonReleasePost", ET_Ignore, Param_Cell, Param_Cell);
	g_Forward_OnCallMedic = CreateGlobalForward("TF2_OnCallMedic", ET_Event, Param_Cell);
	g_Forward_OnCallMedicPost = CreateGlobalForward("TF2_OnCallMedicPost", ET_Ignore, Param_Cell);
	g_Forward_OnRegeneratePlayer = CreateGlobalForward("TF2_OnRegeneratePlayer", ET_Event, Param_Cell);
	g_Forward_OnRegeneratePlayerPost = CreateGlobalForward("TF2_OnRegeneratePlayerPost", ET_Ignore, Param_Cell);
	g_Forward_OnMedicHealPost = CreateGlobalForward("TF2_OnMedicHealPost", ET_Ignore, Param_Cell, Param_Cell);
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	CreateConVar("sm_tf2_api_version", PLUGIN_VERSION, PLUGIN_DESCRIPTION, FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_SPONLY | FCVAR_DONTRECORD);
	
	HookEvent("player_changeclass", Event_OnChangeClass, EventHookMode_Pre);
	HookEvent("player_changeclass", Event_OnChangeClassPost, EventHookMode_Post);
	
	HookEvent("post_inventory_application", Event_OnRegeneratePlayer, EventHookMode_Pre);
	HookEvent("post_inventory_application", Event_OnRegeneratePlayerPost, EventHookMode_Post);
	
	AddCommandListener(Listener_VoiceMenu, "voicemenu");
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

public Action Event_OnChangeClass(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	int class = event.GetInt("class");
	
	Call_StartForward(g_Forward_OnClassChange);
	Call_PushCell(client);
	Call_PushCellRef(class);
	
	Action status = Plugin_Continue;
	Call_Finish(status);
	
	if (status == Plugin_Changed)
		event.SetInt("class", class);
	
	return status;
}

public void Event_OnChangeClassPost(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	int class = event.GetInt("class");
	
	Call_StartForward(g_Forward_OnClassChangePost);
	Call_PushCell(client);
	Call_PushCell(class);
	Call_Finish();
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool& result)
{
	Call_StartForward(g_Forward_OnWeaponFirePost);
	Call_PushCell(client);
	Call_PushCell(weapon);
	Call_Finish();
}

public void OnClientDisconnect_Post(int client)
{
	g_LastButtons[client] = 0;
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon)
{
	int button;
	for (int i = 0; i < MAX_BUTTONS; i++)
	{
		button = (1 << i);
		
		if ((buttons & button))
		{
			if (!(g_LastButtons[client] & button))
			{
				Call_StartForward(g_Forward_OnButtonPressPost);
				Call_PushCell(client);
				Call_PushCell(button);
				Call_Finish();
			}
		}
		else if ((g_LastButtons[client] & button))
		{
			Call_StartForward(g_Forward_OnButtonReleasePost);
			Call_PushCell(client);
			Call_PushCell(button);
			Call_Finish();
		}
	}
	
	g_LastButtons[client] = buttons;

	if (IsPlayerAlive(client) && TF2_GetPlayerClass(client) != TFClass_Medic)
	{
		int target;
		if ((target = TF2_GetHealingTarget(client)) != -1)
		{
			Call_StartForward(g_Forward_OnMedicHealPost);
			Call_PushCell(client);
			Call_PushCell(target);
			Call_Finish();
		}
	}
}

int TF2_GetHealingTarget(int client)
{
	int weapon = GetPlayerWeaponSlot(client, 1);

	if (!IsValidEntity(weapon) || weapon != GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"))
		return -1;

	char sClassname[32];
	GetEdictClassname(weapon, sClassname, sizeof(sClassname));

	if (StrContains(sClassname, "tf_weapon_med") == -1)
		return -1;

	return GetEntProp(weapon, Prop_Send, "m_bHealing") ? GetEntPropEnt(weapon, Prop_Send, "m_hHealingTarget") : -1;
}

public Action Listener_VoiceMenu(int client, const char[] command, int argc)
{
	char sVoice[32];
	GetCmdArg(1, sVoice, sizeof(sVoice));

	char sVoice2[32];
	GetCmdArg(2, sVoice2, sizeof(sVoice2));

	if (StringToInt(sVoice) != 0 && StringToInt(sVoice2) != 0)
		return Plugin_Continue;
	
	Call_StartForward(g_Forward_OnCallMedic);
	Call_PushCell(client);
	
	Action status = Plugin_Continue;
	Call_Finish(status);
	
	if (status != Plugin_Continue)
		return Plugin_Stop;
	
	Call_StartForward(g_Forward_OnCallMedicPost);
	Call_PushCell(client);
	Call_Finish();
	
	return Plugin_Continue;
}

public Action Event_OnRegeneratePlayer(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	Call_StartForward(g_Forward_OnRegeneratePlayer);
	Call_PushCell(client);
	
	Action status = Plugin_Continue;
	Call_Finish(status);
	
	return status;
}

public void Event_OnRegeneratePlayerPost(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	Call_StartForward(g_Forward_OnRegeneratePlayerPost);
	Call_PushCell(client);
	Call_Finish();
}