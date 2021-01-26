/*****************************/
//Credits

//Drixevel - The plugin itself and a good portion of the natives/forwards.
//Benoist3012 - Respawn Natives/Forwards
//Thrawn2 - Weapon fire position forward.

/*****************************/
//Pragma
#pragma semicolon 1
#pragma newdecls required

/*****************************/
//Defines
#define PLUGIN_NAME "[TF2] API"
#define PLUGIN_DESCRIPTION "Offers other plugins easy API for some basic TF2 features."
#define PLUGIN_VERSION "1.2.3"

#define MAX_BUTTONS 25

#define TF_TEAM_RED 2
#define TF_TEAM_BLUE 3

#define MAX_TEAM 4
#define INFINITE_RESPAWN_TIME 99999.0

/*****************************/
//Includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <dhooks>
#include <tf2_stocks>
#include <tf2items>
#include <tf2-api>

/*****************************/
//Forwards

Handle g_Forward_OnPlayerDamaged;
Handle g_Forward_OnPlayerDamagedPost;
Handle g_Forward_OnObjectDamaged;
Handle g_Forward_OnObjectDamagedPost;
Handle g_Forward_OnClassChange;
Handle g_Forward_OnClassChangePost;
Handle g_Forward_OnWeaponFirePost;
Handle g_Forward_OnButtonPressPost;
Handle g_Forward_OnButtonReleasePost;
Handle g_Forward_OnCallMedic;
Handle g_Forward_OnCallMedicPost;
Handle g_Forward_OnRegeneratePlayer;
Handle g_Forward_OnRegeneratePlayerPost;
Handle g_Forward_OnMedicHealPost;
Handle g_Forward_OnMilkedPost;
Handle g_Forward_OnJaratedPost;
Handle g_Forward_OnGassedPost;
Handle g_Forward_OnProjectileThink;
Handle g_Forward_OnProjectileThinkPost;
Handle g_Forward_OnEnterSpawnRoomPost;
Handle g_Forward_OnLeaveSpawnRoomPost;
Handle g_Forward_OnTouchVisualizerPost;
Handle g_Forward_OnWeaponEquip;
Handle g_Forward_OnWeaponEquipPost;
Handle g_Forward_OnWearableEquip;
Handle g_Forward_OnWearableEquipPost;
Handle g_Forward_OnRoundStart;
Handle g_Forward_OnRoundActive;
Handle g_Forward_OnArenaRoundStart;
Handle g_Forward_OnRoundEnd;
Handle g_Forward_OnPlayerSpawn;
Handle g_Forward_OnPlayerDeath;
Handle g_Forward_OnPlayerHealed;
Handle g_Forward_OnPlayerTaunting;
Handle g_Forward_OnZoomIn;
Handle g_Forward_OnZoomOut;
Handle g_Forward_OnFlagCapture;
Handle g_Forward_OnControlPointCapturing;
Handle g_Forward_OnControlPointCaptured;
Handle g_Forward_OnPlayerTouch;
Handle g_Forward_OnPlayerEat;
Handle g_Forward_OnRespawnSet;
Handle g_Forward_OnRespawnUpdated;
Handle g_Forward_OnTeamRespawnUpdated;
Handle g_Forward_OnWeaponFirePosition;

/*****************************/
//Globals

//Respawn Logic
//int g_PlayerManager;
float g_RespawnTime[MAXPLAYERS + 1];
float g_TeamRespawnTime[MAX_TEAM];
float g_OldRespawnTime[MAX_TEAM];
ConVar convar_RespawnWaveTimes;

//Buttons
int g_LastButtons[MAXPLAYERS + 1];
Handle g_OnWeaponFire;

Handle g_OnWeaponShootPos;

//bool g_IsRoundActive;

/*****************************/
//Plugin Info
public Plugin myinfo = 
{
	name = PLUGIN_NAME,
	author = "Drixevel", 
	description = PLUGIN_DESCRIPTION, 
	version = PLUGIN_VERSION, 
	url = "https://drixevel.dev/"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("tf2-api");

	CreateNative("TF2_IsClientRespawning", Native_IsClientRespawning);
	CreateNative("TF2_GetTeamRespawnTime", Native_GetTeamRespawnTime);
	CreateNative("TF2_GetClientRespawnTime", Native_GetClientRespawnTime);
	CreateNative("TF2_SetClientRespawnTime", Native_SetClientRespawnTime);
	CreateNative("TF2_UpdateClientRespawnTime", Native_UpdateClientRespawnTime);
	CreateNative("TF2_SetTeamRespawnTime", Native_SetTeamRespawnTime);
	CreateNative("TF2_UpdateTeamRespawnTime", Native_UpdateTeamRespawnTime);
	
	g_Forward_OnPlayerDamaged = CreateGlobalForward("TF2_OnPlayerDamaged", ET_Event, Param_Cell, Param_Cell, Param_CellByRef, Param_Cell, Param_CellByRef, Param_FloatByRef, Param_CellByRef, Param_CellByRef, Param_Array, Param_Array, Param_Cell, Param_Cell);
	g_Forward_OnPlayerDamagedPost = CreateGlobalForward("TF2_OnPlayerDamagedPost", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Float, Param_Cell, Param_Cell, Param_Array, Param_Array, Param_Cell, Param_Cell);
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
	g_Forward_OnMilkedPost = CreateGlobalForward("TF2_OnMilkedPost", ET_Ignore, Param_Cell, Param_Cell);
	g_Forward_OnJaratedPost = CreateGlobalForward("TF2_OnJaratedPost", ET_Ignore, Param_Cell, Param_Cell);
	g_Forward_OnGassedPost = CreateGlobalForward("TF2_OnGassedPost", ET_Ignore, Param_Cell, Param_Cell);
	g_Forward_OnProjectileThink = CreateGlobalForward("TF2_OnProjectileThink", ET_Event, Param_Cell, Param_String, Param_CellByRef, Param_CellByRef, Param_CellByRef);
	g_Forward_OnProjectileThinkPost = CreateGlobalForward("TF2_OnProjectileThinkPost", ET_Ignore, Param_Cell, Param_String, Param_Cell, Param_Cell, Param_Cell);
	g_Forward_OnEnterSpawnRoomPost = CreateGlobalForward("TF2_OnEnterSpawnRoomPost", ET_Ignore, Param_Cell, Param_Cell);
	g_Forward_OnLeaveSpawnRoomPost = CreateGlobalForward("TF2_OnLeaveSpawnRoomPost", ET_Ignore, Param_Cell, Param_Cell);
	g_Forward_OnTouchVisualizerPost = CreateGlobalForward("TF2_OnTouchVisualizerPost", ET_Ignore, Param_Cell, Param_Cell);
	g_Forward_OnWeaponEquip = CreateGlobalForward("TF2_OnWeaponEquip", ET_Event, Param_Cell, Param_String, Param_Cell);
	g_Forward_OnWeaponEquipPost = CreateGlobalForward("TF2_OnWeaponEquipPost", ET_Ignore, Param_Cell, Param_String, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_Forward_OnWearableEquip = CreateGlobalForward("TF2_OnWearableEquip", ET_Event, Param_Cell, Param_String, Param_Cell);
	g_Forward_OnWearableEquipPost = CreateGlobalForward("TF2_OnWearableEquipPost", ET_Ignore, Param_Cell, Param_String, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_Forward_OnRoundStart = CreateGlobalForward("TF2_OnRoundStart", ET_Ignore, Param_Cell);
	g_Forward_OnRoundActive = CreateGlobalForward("TF2_OnRoundActive", ET_Ignore);
	g_Forward_OnArenaRoundStart = CreateGlobalForward("TF2_OnArenaRoundStart", ET_Ignore);
	g_Forward_OnRoundEnd = CreateGlobalForward("TF2_OnRoundEnd", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Float, Param_Cell, Param_Cell);
	g_Forward_OnPlayerSpawn = CreateGlobalForward("TF2_OnPlayerSpawn", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_Forward_OnPlayerDeath = CreateGlobalForward("TF2_OnPlayerDeath", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_Forward_OnPlayerHealed = CreateGlobalForward("TF2_OnPlayerHealed", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_Forward_OnPlayerTaunting = CreateGlobalForward("TF2_OnPlayerTaunting", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_Forward_OnZoomIn = CreateGlobalForward("TF2_OnZoomIn", ET_Ignore, Param_Cell);
	g_Forward_OnZoomOut = CreateGlobalForward("TF2_OnZoomOut", ET_Ignore, Param_Cell);
	g_Forward_OnFlagCapture = CreateGlobalForward("TF2_OnFlagCapture", ET_Ignore, Param_Cell, Param_Cell);
	g_Forward_OnControlPointCapturing = CreateGlobalForward("TF2_OnControlPointCapturing", ET_Ignore, Param_Cell, Param_String, Param_Cell, Param_Cell, Param_String, Param_Float);
	g_Forward_OnControlPointCaptured = CreateGlobalForward("TF2_OnControlPointCaptured", ET_Ignore, Param_Cell, Param_String, Param_Cell, Param_String);
	g_Forward_OnPlayerTouch = CreateGlobalForward("TF2_OnPlayerTouch", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_Forward_OnPlayerEat = CreateGlobalForward("TF2_OnPlayerEat", ET_Ignore, Param_Cell, Param_Cell);
	g_Forward_OnRespawnSet = CreateGlobalForward("TF2_OnRespawnSet", ET_Hook, Param_Cell, Param_FloatByRef);
	g_Forward_OnRespawnUpdated = CreateGlobalForward("TF2_OnRespawnUpdated", ET_Hook, Param_Cell, Param_FloatByRef);
	g_Forward_OnTeamRespawnUpdated = CreateGlobalForward("TF2_OnTeamRespawnUpdated", ET_Hook, Param_Cell, Param_FloatByRef);
	g_Forward_OnWeaponFirePosition = CreateGlobalForward("TF2_OnWeaponFirePosition", ET_Ignore, Param_Cell, Param_Array);
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	CreateConVar("sm_tf2_api_version", PLUGIN_VERSION, PLUGIN_DESCRIPTION, FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_SPONLY | FCVAR_DONTRECORD);
	
	HookEvent("player_spawn", Event_OnPlayerSpawn, EventHookMode_Post);
	HookEvent("player_healed", Event_OnPlayerHealed, EventHookMode_Post);
	HookEvent("player_death", Event_OnPlayerDeath, EventHookMode_Post);
	
	HookEvent("player_changeclass", Event_OnChangeClass, EventHookMode_Pre);
	HookEvent("player_changeclass", Event_OnChangeClassPost, EventHookMode_Post);
	
	HookEvent("post_inventory_application", Event_OnRegeneratePlayer, EventHookMode_Pre);
	HookEvent("post_inventory_application", Event_OnRegeneratePlayerPost, EventHookMode_Post);
	
	HookEvent("teamplay_round_start", Event_OnRoundStart, EventHookMode_Post);
	HookEvent("teamplay_round_active", Event_OnRoundActive, EventHookMode_Post);
	HookEvent("arena_round_start", Event_OnArenaRoundStart, EventHookMode_Post);
	HookEvent("teamplay_round_win", Event_OnRoundFinished, EventHookMode_Post);
	HookEvent("ctf_flag_captured", Event_OnFlagCapture, EventHookMode_Post);
	HookEvent("teamplay_point_startcapture", Event_OnControlPointCapturing, EventHookMode_Post);
	HookEvent("teamplay_point_captured", Event_OnControlPointCaptured, EventHookMode_Post);
	
	AddCommandListener(Listener_VoiceMenu, "voicemenu");

	int entity = -1;
	while((entity = FindEntityByClassname(entity, "func_respawnroom")) != -1)
	{
		SDKHook(entity, SDKHook_StartTouchPost, OnRespawnRoomStartTouch);
		SDKHook(entity, SDKHook_EndTouchPost, OnRespawnRoomEndTouch);
	}

	entity = -1;
	while((entity = FindEntityByClassname(entity, "func_respawnroomvisualizer")) != -1)
		SDKHook(entity, SDKHook_StartTouchPost, OnVisualizerRoomStartTouch);
	
	Handle config;
	if ((config = LoadGameConfigFile("tf2.api")) != null)
	{
		int offset = GameConfGetOffset(config, "CBasePlayer::OnMyWeaponFired");
		
		if (offset != -1)
		{
			g_OnWeaponFire = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, OnMyWeaponFired);
			DHookAddParam(g_OnWeaponFire, HookParamType_Int);
		}

		offset = GameConfGetOffset(config, "CBasePlayer::Weapon_ShootPosition()");

		if (offset != -1)
			g_OnWeaponShootPos = DHookCreate(offset, HookType_Entity, ReturnType_Vector, ThisPointer_CBaseEntity, OnWeaponFirePosition);
		
		delete config;
	}
	
	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i))
			OnClientPutInServer(i);
	
	AddNormalSoundHook(OnPlaySound);

	convar_RespawnWaveTimes = FindConVar("mp_respawnwavetime");
	HookConVarChange(convar_RespawnWaveTimes, Cvar_RespawnWaveTimeChange);

	CreateTimer(1.0, Timer_AverageUpdateRespawnTime, _, TIMER_REPEAT);
}

public void Cvar_RespawnWaveTimeChange(ConVar convar, const char[] oldValue, const char[] newValue)
{
	float oldtime = StringToFloat(oldValue);
	float newtime = StringToFloat(newValue);
	
	for (int i = TF_TEAM_RED; i <= TF_TEAM_BLUE; i++)
	{
		g_TeamRespawnTime[i] -= oldtime;
		g_TeamRespawnTime[i] += newtime;
	}

	TF2_RecalculateRespawnTime();
}

public void OnMapStart()
{
	//g_PlayerManager = GetPlayerResourceEntity();
	
	g_TeamRespawnTime[TF_TEAM_BLUE] = GameRules_GetPropFloat("m_TeamRespawnWaveTimes", TF_TEAM_BLUE);
	g_TeamRespawnTime[TF_TEAM_RED] = GameRules_GetPropFloat("m_TeamRespawnWaveTimes", TF_TEAM_RED);
	
	if (g_TeamRespawnTime[TF_TEAM_BLUE] >= INFINITE_RESPAWN_TIME)
		g_TeamRespawnTime[TF_TEAM_BLUE] = 10.0;
	
	if (g_TeamRespawnTime[TF_TEAM_RED] >= INFINITE_RESPAWN_TIME)
		g_TeamRespawnTime[TF_TEAM_BLUE] = 10.0;
	
	g_TeamRespawnTime[TF_TEAM_BLUE] += convar_RespawnWaveTimes.FloatValue;
	g_TeamRespawnTime[TF_TEAM_RED] += convar_RespawnWaveTimes.FloatValue;
	
	g_OldRespawnTime[TF_TEAM_BLUE] = g_TeamRespawnTime[TF_TEAM_BLUE];
	g_OldRespawnTime[TF_TEAM_RED] = g_TeamRespawnTime[TF_TEAM_RED];
	
	GameRules_SetPropFloat("m_TeamRespawnWaveTimes", INFINITE_RESPAWN_TIME, TF_TEAM_BLUE);
	GameRules_SetPropFloat("m_TeamRespawnWaveTimes", INFINITE_RESPAWN_TIME, TF_TEAM_RED);
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
	SDKHook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
	SDKHook(client, SDKHook_OnTakeDamageAlivePost, OnTakeDamageAlivePost);
	
	SDKHook(client, SDKHook_StartTouch, OnStartTouch);
	SDKHook(client, SDKHook_StartTouchPost, OnStartTouchPost);
	SDKHook(client, SDKHook_Touch, OnTouch);
	SDKHook(client, SDKHook_TouchPost, OnTouchPost);
	SDKHook(client, SDKHook_EndTouch, OnEndTouch);
	SDKHook(client, SDKHook_EndTouchPost, OnEndTouchPost);
	
	if (g_OnWeaponFire != null)
		DHookEntity(g_OnWeaponFire, true, client);
	
	if (g_OnWeaponShootPos != null)
		DHookEntity(g_OnWeaponShootPos, true, client, RemovalCB);
}

public Action OnTakeDamage(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Call_StartForward(g_Forward_OnPlayerDamaged);
	Call_PushCell(victim);
	Call_PushCell(TF2_GetPlayerClass(victim));
	Call_PushCellRef(attacker);
	Call_PushCell((attacker > 0 && attacker <= MaxClients) ? TF2_GetPlayerClass(attacker) : TFClass_Unknown);
	Call_PushCellRef(inflictor);
	Call_PushFloatRef(damage);
	Call_PushCellRef(damagetype);
	Call_PushCellRef(weapon);
	Call_PushArrayEx(damageForce, sizeof(damageForce), SM_PARAM_COPYBACK);
	Call_PushArrayEx(damagePosition, sizeof(damagePosition), SM_PARAM_COPYBACK);
	Call_PushCell(damagecustom);
	Call_PushCell(false);
	
	Action results = Plugin_Continue;
	Call_Finish(results);
	
	return results;
}

public Action OnTakeDamageAlive(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Call_StartForward(g_Forward_OnPlayerDamaged);
	Call_PushCell(victim);
	Call_PushCell(TF2_GetPlayerClass(victim));
	Call_PushCellRef(attacker);
	Call_PushCell((attacker > 0 && attacker <= MaxClients) ? TF2_GetPlayerClass(attacker) : TFClass_Unknown);
	Call_PushCellRef(inflictor);
	Call_PushFloatRef(damage);
	Call_PushCellRef(damagetype);
	Call_PushCellRef(weapon);
	Call_PushArrayEx(damageForce, sizeof(damageForce), SM_PARAM_COPYBACK);
	Call_PushArrayEx(damagePosition, sizeof(damagePosition), SM_PARAM_COPYBACK);
	Call_PushCell(damagecustom);
	Call_PushCell(true);
	
	Action results = Plugin_Continue;
	Call_Finish(results);
	
	return results;
}

public void OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	Call_StartForward(g_Forward_OnPlayerDamagedPost);
	Call_PushCell(victim);
	Call_PushCell(TF2_GetPlayerClass(victim));
	Call_PushCell(attacker);
	Call_PushCell((attacker > 0 && attacker <= MaxClients) ? TF2_GetPlayerClass(attacker) : TFClass_Unknown);
	Call_PushCell(inflictor);
	Call_PushFloat(damage);
	Call_PushCell(damagetype);
	Call_PushCell(weapon);
	Call_PushArray(damageForce, sizeof(damageForce));
	Call_PushArray(damagePosition, sizeof(damagePosition));
	Call_PushCell(damagecustom);
	Call_PushCell(false);
	Call_Finish();
}

public void OnTakeDamageAlivePost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	Call_StartForward(g_Forward_OnPlayerDamagedPost);
	Call_PushCell(victim);
	Call_PushCell(TF2_GetPlayerClass(victim));
	Call_PushCell(attacker);
	Call_PushCell((attacker > 0 && attacker <= MaxClients) ? TF2_GetPlayerClass(attacker) : TFClass_Unknown);
	Call_PushCell(inflictor);
	Call_PushFloat(damage);
	Call_PushCell(damagetype);
	Call_PushCell(weapon);
	Call_PushArray(damageForce, sizeof(damageForce));
	Call_PushArray(damagePosition, sizeof(damagePosition));
	Call_PushCell(damagecustom);
	Call_PushCell(true);
	Call_Finish();
}

public Action OnStartTouch(int entity, int other)
{
	Call_StartForward(g_Forward_OnPlayerTouch);
	Call_PushCell(entity);
	Call_PushCell(other);
	Call_PushCell(Hook_OnStartTouch);
	Call_Finish();
}

public void OnStartTouchPost(int entity, int other)
{
	Call_StartForward(g_Forward_OnPlayerTouch);
	Call_PushCell(entity);
	Call_PushCell(other);
	Call_PushCell(Hook_OnStartTouchPost);
	Call_Finish();
}

public Action OnTouch(int entity, int other)
{
	Call_StartForward(g_Forward_OnPlayerTouch);
	Call_PushCell(entity);
	Call_PushCell(other);
	Call_PushCell(Hook_OnTouch);
	Call_Finish();
}

public void OnTouchPost(int entity, int other)
{
	Call_StartForward(g_Forward_OnPlayerTouch);
	Call_PushCell(entity);
	Call_PushCell(other);
	Call_PushCell(Hook_OnTouchPost);
	Call_Finish();
}

public Action OnEndTouch(int entity, int other)
{
	Call_StartForward(g_Forward_OnPlayerTouch);
	Call_PushCell(entity);
	Call_PushCell(other);
	Call_PushCell(Hook_OnEndTouch);
	Call_Finish();
}

public void OnEndTouchPost(int entity, int other)
{
	Call_StartForward(g_Forward_OnPlayerTouch);
	Call_PushCell(entity);
	Call_PushCell(other);
	Call_PushCell(Hook_OnEndTouchPost);
	Call_Finish();
}

public MRESReturn OnMyWeaponFired(int client, Handle hReturn, Handle hParams)
{
	if (client < 1 || client > MaxClients || !IsValidEntity(client) || !IsPlayerAlive(client))
		return MRES_Ignored;
	
	Call_StartForward(g_Forward_OnWeaponFirePost);
	Call_PushCell(client);
	Call_PushCell(GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"));
	Call_Finish();
	
	return MRES_Ignored;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (StrContains(classname, "obj_", false) != -1)
	{
		SDKHook(entity, SDKHook_OnTakeDamage, Object_OnTakeDamage);
		SDKHook(entity, SDKHook_OnTakeDamagePost, Object_OnTakeDamagePost);
	}

	if (StrEqual(classname, "func_respawnroom", false))
	{
		SDKHook(entity, SDKHook_StartTouchPost, OnRespawnRoomStartTouch);
		SDKHook(entity, SDKHook_EndTouchPost, OnRespawnRoomEndTouch);
	}

	if (StrEqual(classname, "func_respawnroomvisualizer", false))
		SDKHook(entity, SDKHook_StartTouchPost, OnVisualizerRoomStartTouch);
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

public void Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	Call_StartForward(g_Forward_OnPlayerSpawn);
	Call_PushCell(GetClientOfUserId(event.GetInt("userid")));
	Call_PushCell(event.GetInt("team"));
	Call_PushCell(event.GetInt("class"));
	Call_Finish();

	int client = GetClientOfUserId(event.GetInt("userid"));
	g_RespawnTime[client] = 0.0;
	//SDKUnhook(client, SDKHook_SetTransmit, OverrideRespawnHud);
}

public void Event_OnPlayerHealed(Event event, const char[] name, bool dontBroadcast)
{
	Call_StartForward(g_Forward_OnPlayerHealed);
	Call_PushCell(GetClientOfUserId(event.GetInt("patient")));
	Call_PushCell(GetClientOfUserId(event.GetInt("healer")));
	Call_PushCell(GetClientOfUserId(event.GetInt("amount")));
	Call_Finish();
}

public void Event_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	Call_StartForward(g_Forward_OnPlayerDeath);
	Call_PushCell(GetClientOfUserId(event.GetInt("userid")));
	Call_PushCell(GetClientOfUserId(event.GetInt("attacker")));
	Call_PushCell(GetClientOfUserId(event.GetInt("assister")));
	Call_PushCell(event.GetInt("inflictor_entindex"));
	Call_PushCell(event.GetInt("damagebits"));
	Call_PushCell(event.GetInt("stun_flags"));
	Call_PushCell(event.GetInt("death_flags"));
	Call_PushCell(event.GetInt("customkill"));
	Call_Finish();

	int client = GetClientOfUserId(event.GetInt("userid"));

	if (event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER)
		return;
	
	if (GetClientTeam(client) > 1 && g_RespawnTime[client] <= 0.0)
	{
		float flRespawnTime = g_TeamRespawnTime[GetClientTeam(client)];
		float flRespawnTime2 = flRespawnTime;

		Call_StartForward(g_Forward_OnRespawnSet);
		Call_PushCell(client);
		Call_PushFloatRef(flRespawnTime2);

		Action action;
		Call_Finish(action);

		if (action == Plugin_Changed)
			flRespawnTime = flRespawnTime2;
		
		TF2_SetClientRespawnTimeEx(client, flRespawnTime);
	}
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
	
	if (!StrEqual(sVoice, "0", false) || !StrEqual(sVoice2, "0", false))
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

public void OnEntityDestroyed(int entity)
{
	if (entity < MaxClients)
		return;
	
	if (HasClassname(entity, "tf_projectile_jar_milk"))
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hThrower");
		
		if (IsValidEntity(owner))
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetEntitiesDistance(i, entity) > 250.0 || !TF2_IsPlayerInCondition(i, TFCond_Milked))
					continue;
				
				Call_StartForward(g_Forward_OnMilkedPost);
				Call_PushCell(i);
				Call_PushCell(owner);
				Call_Finish();
			}
		}
	}
	
	if (HasClassname(entity, "tf_projectile_jar"))
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hThrower");
		
		if (IsValidEntity(owner))
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetEntitiesDistance(i, entity) > 250.0 || !TF2_IsPlayerInCondition(i, TFCond_Jarated))
					continue;
				
				Call_StartForward(g_Forward_OnJaratedPost);
				Call_PushCell(i);
				Call_PushCell(owner);
				Call_Finish();
			}
		}
	}
	
	if (HasClassname(entity, "tf_projectile_jar_gas"))
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hThrower");
		
		if (IsValidEntity(owner))
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientInGame(i) || !IsPlayerAlive(i) || GetEntitiesDistance(i, entity) > 250.0 || !TF2_IsPlayerInCondition(i, TFCond_Gas))
					continue;
				
				Call_StartForward(g_Forward_OnGassedPost);
				Call_PushCell(i);
				Call_PushCell(owner);
				Call_Finish();
			}
		}
	}
}

bool HasClassname(int entity, const char[] name, bool caseSensitive = true)
{
	char sBuffer[256];
	GetEntityClassname(entity, sBuffer, sizeof(sBuffer));
	return StrEqual(sBuffer, name, caseSensitive);
}

float GetEntitiesDistance(int entity1, int entity2)
{
	float fOrigin1[3];
	GetEntPropVector(entity1, Prop_Send, "m_vecOrigin", fOrigin1);

	float fOrigin2[3];
	GetEntPropVector(entity2, Prop_Send, "m_vecOrigin", fOrigin2);
	
	return GetVectorDistance(fOrigin1, fOrigin2);
}

public void OnGameFrame()
{
	int entity = -1; char classname[64]; Action results;
	int launcher; int owner; bool critical;
	while ((entity = FindEntityByClassname(entity, "tf_projectile_*")) != -1)
	{
		results = Plugin_Continue;
		GetEntityClassname(entity, classname, sizeof(classname));
		launcher = GetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher");
		owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		critical = HasEntProp(entity, Prop_Send, "m_bCritical") ? GetEntPropBool(entity, Prop_Send, "m_bCritical") : false;

		Call_StartForward(g_Forward_OnProjectileThink);
		Call_PushCell(entity);
		Call_PushString(classname);
		Call_PushCellRef(launcher);
		Call_PushCellRef(owner);
		Call_PushCellRef(critical);

		if (Call_Finish(results) != SP_ERROR_NONE || results >= Plugin_Handled)
			continue;
		
		if (results == Plugin_Changed)
		{
			SetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher", launcher);
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", owner);

			if (HasEntProp(entity, Prop_Send, "m_bCritical"))
				SetEntProp(entity, Prop_Send, "m_bCritical", critical);
		}

		Call_StartForward(g_Forward_OnProjectileThinkPost);
		Call_PushCell(entity);
		Call_PushString(classname);
		Call_PushCell(launcher);
		Call_PushCell(owner);
		Call_PushCell(critical);
		Call_Finish();
	}
}

bool GetEntPropBool(int entity, PropType type, const char[] prop, int size = 4, int element = 0)
{
	return view_as<bool>(GetEntProp(entity, type, prop, size, element));
}

public void OnRespawnRoomStartTouch(int entity, int other)
{
	if (other < 1 || other > MaxClients)
		return;
	
	Call_StartForward(g_Forward_OnEnterSpawnRoomPost);
	Call_PushCell(other);
	Call_PushCell(entity);
	Call_Finish();
}

public void OnRespawnRoomEndTouch(int entity, int other)
{
	if (other < 1 || other > MaxClients)
		return;
	
	Call_StartForward(g_Forward_OnLeaveSpawnRoomPost);
	Call_PushCell(other);
	Call_PushCell(entity);
	Call_Finish();
}

public void OnVisualizerRoomStartTouch(int entity, int other)
{
	if (other < 1 || other > MaxClients)
		return;
	
	Call_StartForward(g_Forward_OnTouchVisualizerPost);
	Call_PushCell(other);
	Call_PushCell(entity);
	Call_Finish();
}

public Action TF2Items_OnGiveNamedItem(int client, char[] classname, int iItemDefinitionIndex, Handle& hItem)
{
	Action results = Plugin_Continue;

	if (StrContains(classname, "tf_weapon", false) == 0)
	{
		Call_StartForward(g_Forward_OnWeaponEquip);
		Call_PushCell(client);
		Call_PushString(classname);
		Call_PushCell(iItemDefinitionIndex);
		Call_Finish(results);
	}
	else if (StrContains(classname, "tf_wearable", false) == 0)
	{
		Call_StartForward(g_Forward_OnWearableEquip);
		Call_PushCell(client);
		Call_PushString(classname);
		Call_PushCell(iItemDefinitionIndex);
		Call_Finish(results);
	}

	return results;
}

public void TF2Items_OnGiveNamedItem_Post(int client, char[] classname, int itemDefinitionIndex, int itemLevel, int itemQuality, int entityIndex)
{
	if (StrContains(classname, "tf_weapon", false) == 0)
	{
		Call_StartForward(g_Forward_OnWeaponEquipPost);
		Call_PushCell(client);
		Call_PushString(classname);
		Call_PushCell(itemDefinitionIndex);
		Call_PushCell(itemLevel);
		Call_PushCell(itemQuality);
		Call_PushCell(entityIndex);
		Call_Finish();
	}
	else if (StrContains(classname, "tf_wearable", false) == 0)
	{
		Call_StartForward(g_Forward_OnWearableEquipPost);
		Call_PushCell(client);
		Call_PushString(classname);
		Call_PushCell(itemDefinitionIndex);
		Call_PushCell(itemLevel);
		Call_PushCell(itemQuality);
		Call_PushCell(entityIndex);
		Call_Finish();
	}
}

public void Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	Call_StartForward(g_Forward_OnRoundStart);
	Call_PushCell(event.GetInt("full_reset"));
	Call_Finish();
	
	//g_IsRoundActive = true;
}

public void Event_OnRoundActive(Event event, const char[] name, bool dontBroadcast)
{
	Call_StartForward(g_Forward_OnRoundActive);
	Call_Finish();
}

public void Event_OnArenaRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	Call_StartForward(g_Forward_OnArenaRoundStart);
	Call_Finish();
}

public void Event_OnRoundFinished(Event event, const char[] name, bool dontBroadcast)
{
	Call_StartForward(g_Forward_OnRoundEnd);
	Call_PushCell(event.GetInt("team"));
	Call_PushCell(event.GetInt("winreason"));
	Call_PushCell(event.GetInt("flagcaplimit"));
	Call_PushCell(event.GetInt("full_round"));
	Call_PushFloat(event.GetFloat("round_time"));
	Call_PushCell(event.GetInt("losing_team_num_caps"));
	Call_PushCell(event.GetInt("was_sudden_death"));
	Call_Finish();
	
	//g_IsRoundActive = false;
}

public void TF2_OnConditionAdded(int client, TFCond condition)
{
	if (condition == TFCond_Taunting)
	{
		Call_StartForward(g_Forward_OnPlayerTaunting);
		Call_PushCell(client);
		Call_PushCell(GetEntProp(client, Prop_Send, "m_iTauntIndex"));
		Call_PushCell(GetEntProp(client, Prop_Send, "m_iTauntItemDefIndex"));
		Call_Finish();
	}
	else if (condition == TFCond_Zoomed)
	{
		Call_StartForward(g_Forward_OnZoomIn);
		Call_PushCell(client);
		Call_Finish();
	}
}

public void TF2_OnConditionRemoved(int client, TFCond condition)
{
	if (condition == TFCond_Zoomed)
	{
		Call_StartForward(g_Forward_OnZoomOut);
		Call_PushCell(client);
		Call_Finish();
	}
}

public void Event_OnFlagCapture(Event event, const char[] name, bool dontBroadcast)
{
	Call_StartForward(g_Forward_OnFlagCapture);
	Call_PushCell(event.GetInt("capping_team"));
	Call_PushCell(event.GetInt("capping_team_score"));
	Call_Finish();
}

public void Event_OnControlPointCapturing(Event event, const char[] name, bool dontBroadcast)
{
	Call_StartForward(g_Forward_OnControlPointCapturing);
	Call_PushCell(event.GetInt("cp"));
	
	char cpname[128];
	event.GetString("cpname", cpname, sizeof(cpname));
	Call_PushString(cpname);
	
	Call_PushCell(event.GetInt("team"));
	Call_PushCell(event.GetInt("capteam"));
	
	char cappers[128];
	event.GetString("cpname", cappers, sizeof(cappers));
	Call_PushString(cappers);
	
	Call_PushFloat(event.GetFloat("captime"));
	Call_Finish();
}

public void Event_OnControlPointCaptured(Event event, const char[] name, bool dontBroadcast)
{
	Call_StartForward(g_Forward_OnControlPointCaptured);
	Call_PushCell(event.GetInt("cp"));
	
	char cpname[128];
	event.GetString("cpname", cpname, sizeof(cpname));
	Call_PushString(cpname);
	
	Call_PushCell(event.GetInt("team"));
	
	char cappers[128];
	event.GetString("cappers", cappers, sizeof(cappers));
	Call_PushString(cappers);
	
	Call_Finish();
}

public Action OnPlaySound(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (StrEqual(sample, "vo/SandwichEat09.mp3", false))
	{
		Call_StartForward(g_Forward_OnPlayerEat);
		Call_PushCell(entity);
		Call_PushCell(GetEntPropEnt(entity, Prop_Send, "m_hActiveWeapon"));
		Call_Finish();
	}
	
	return Plugin_Continue;
}

public Action Timer_AverageUpdateRespawnTime(Handle timer)
{
	for (int i = TF_TEAM_RED; i <= TF_TEAM_BLUE; i++)
	{
		float currenttime = GameRules_GetPropFloat("m_TeamRespawnWaveTimes", i);
		
		if (currenttime != INFINITE_RESPAWN_TIME)
		{
			currenttime += convar_RespawnWaveTimes.FloatValue;

			float respawntime = currenttime;
			Call_StartForward(g_Forward_OnTeamRespawnUpdated);
			Call_PushCell(i);
			Call_PushFloatRef(respawntime);

			Action action;
			Call_Finish(action);

			if (action == Plugin_Changed)
				currenttime = respawntime;
		
			g_TeamRespawnTime[i] = currenttime;
			TF2_RecalculateRespawnTime();
			GameRules_SetPropFloat("m_TeamRespawnWaveTimes", INFINITE_RESPAWN_TIME, i);
		}
	}
}

void TF2_RecalculateRespawnTime()
{
	for (int i = TF_TEAM_RED; i <= TF_TEAM_BLUE; i++)
	{
		if (g_TeamRespawnTime[i] != g_OldRespawnTime[i])
		{
			float deltatime = g_TeamRespawnTime[i] - g_OldRespawnTime[i];
			TF2_UpdateTeamRespawnEx(i, deltatime);
			
			g_OldRespawnTime[i] = g_TeamRespawnTime[i];
		}
	}
}

void TF2_SetClientRespawnTimeEx(int client, float time)
{
	//SDKHook(client, SDKHook_SetTransmit, OverrideRespawnHud);
	g_RespawnTime[client] = GetGameTime() + time;
}

void TF2_UpdateTeamRespawnEx(int team, float time)
{
	for (int i=1; i<=MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == team && g_RespawnTime[i] > 0.0)
		{
			if (!IsPlayerAlive(i))
			{
				float newtime = time;

				Call_StartForward(g_Forward_OnRespawnUpdated);
				Call_PushCell(i);
				Call_PushFloatRef(newtime);

				Action action;
				Call_Finish(action);

				if (action == Plugin_Changed)
					time = newtime;
				
				g_RespawnTime[i] += time;
			}
		}
	}
}

void TF2_UpdateTeamRespawnEx2(int team, float time)
{
	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && !IsPlayerAlive(i) && GetClientTeam(i) == team && g_RespawnTime[i] > 0.0)
			g_RespawnTime[i] += time;
}

/*public Action OverrideRespawnHud(int client, int other)
{
	if (client != other)
		return;
	
	SetEntPropFloat(g_PlayerManager, Prop_Send, "m_flNextRespawnTime", g_RespawnTime[client], client);
	
	if (IsPlayerAlive(client))
	{
		g_RespawnTime[client] = 0.0;
		SDKUnhook(client, SDKHook_SetTransmit, OverrideRespawnHud);
	}

	if (g_RespawnTime[client] > 0.0 && g_RespawnTime[client] < GetGameTime() && g_IsRoundActive)
	{
		TF2_RespawnPlayer(client);
		g_RespawnTime[client] = 0.0;
		SDKUnhook(client, SDKHook_SetTransmit, OverrideRespawnHud);
	}
}*/

public int Native_IsClientRespawning(Handle hPlugin,int iNumParams)
{
	int client = GetNativeCell(1);
	
	if (g_RespawnTime[client] > 0.0 && !IsPlayerAlive(client))
		return view_as<bool>(true);
	
	return view_as<bool>(false);
}

public int Native_GetTeamRespawnTime(Handle hPlugin,int iNumParams)
{
	int team = GetNativeCell(1);
	float time = 0.0;
	
	if (1 < team < 4)
		time = GameRules_GetPropFloat("m_TeamRespawnWaveTimes", team);
	
	return view_as<int>(time);
}

public int Native_GetClientRespawnTime(Handle hPlugin,int iNumParams)
{
	int time = GetNativeCell(1);
	return view_as<int>(g_RespawnTime[time]);
}

public int Native_SetClientRespawnTime(Handle hPlugin,int iNumParams)
{
	int client = GetNativeCell(1);
	float time = view_as<float>(GetNativeCell(2));
	
	if (IsClientInGame(client) && !IsPlayerAlive(client) && g_RespawnTime[client] <= 0.0)
	{
		TF2_SetClientRespawnTimeEx(client, time);
		return view_as<bool>(true);
	}

	return view_as<bool>(false);
}

public int Native_UpdateClientRespawnTime(Handle hPlugin,int iNumParams)
{
	int client = GetNativeCell(1);
	float time = view_as<float>(GetNativeCell(2));
	
	if (IsClientInGame(client) && !IsPlayerAlive(client))
	{
		g_RespawnTime[client] += time;
		return view_as<bool>(true);
	}
	
	return view_as<bool>(false);
}

public int Native_SetTeamRespawnTime(Handle hPlugin,int iNumParams)
{
	int team = GetNativeCell(1);
	float time = view_as<float>(GetNativeCell(2));
	
	if (1 < team < 4)
	{
		GameRules_SetPropFloat("m_TeamRespawnWaveTimes", time, team);
		return view_as<bool>(true);
	}

	return view_as<bool>(false);
}

public int Native_UpdateTeamRespawnTime(Handle hPlugin,int iNumParams)
{
	int team = GetNativeCell(1);
	float time = view_as<float>(GetNativeCell(2));
	
	if (1 < team < 4)
	{
		TF2_UpdateTeamRespawnEx2(team, time);
		return view_as<bool>(true);
	}

	return view_as<bool>(false);
}

public MRESReturn OnWeaponFirePosition(int pThis, Handle hReturn)
{
	float vecPos[3];
	DHookGetReturnVector(hReturn, vecPos);

	Call_StartForward(g_Forward_OnWeaponFirePosition);
	Call_PushCell(pThis);
	Call_PushArray(vecPos, 3);
	Call_Finish();

	return MRES_Ignored;
}

public void RemovalCB(int hookid)
{

}