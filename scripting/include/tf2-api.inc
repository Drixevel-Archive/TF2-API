#if defined _tf2_api_included
  #endinput
#endif
#define _tf2_api_included

//I'm not documenting this shit, feel free to make a push request if you have the free time of jesus who does nothing. :)

////////////////////////////
//Globals


////////////////////////////
//Natives

//native void PluginName_Native(const char[] sFlag, char[] sBuffer, int iSize);

////////////////////////////
//Forwards

forward Action TF2_OnPlayerDamaged(int victim, TFClassType victimclass, int& attacker, TFClassType attackerclass, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom, bool alive);
forward void TF2_OnPlayerDamagedPost(int victim, TFClassType victimclass, int attacker, TFClassType attackerclass, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom, bool alive);
forward Action TF2_OnObjectDamaged(int entity, TFObjectType type, int& attacker, int& inflictor, float& damage, int& damagetype);
forward void TF2_OnObjectDamagedPost(int entity, TFObjectType type, int& attacker, int& inflictor, float& damage, int& damagetype);
forward Action TF2_OnClassChange(int client, TFClassType& class);
forward void TF2_OnClassChangePost(int client, TFClassType class);
forward void TF2_OnWeaponFirePost(int client, int weapon);
forward void TF2_OnButtonPressPost(int client, int button);
forward void TF2_OnButtonReleasePost(int client, int button);
forward Action TF2_OnCallMedic(int client);
forward void TF2_OnCallMedicPost(int client);
forward Action TF2_OnRegeneratePlayer(int client);
forward void TF2_OnRegeneratePlayerPost(int client);
forward void TF2_OnMedicHealPost(int client, int target);
forward void TF2_OnMilkedPost(int client, int attacker);
forward void TF2_OnJaratedPost(int client, int attacker);
forward void TF2_OnGassedPost(int client, int attacker);
forward Action TF2_OnProjectileThink(int entity, const char[] classname, int& owner, int& launcher, bool& critical);
forward void TF2_OnProjectileThinkPost(int entity, const char[] classname, int owner, int launcher, bool critical);
forward void TF2_OnEnterSpawnRoomPost(int client, int respawnroom);
forward void TF2_OnLeaveSpawnRoomPost(int client, int respawnroom);
forward void TF2_OnTouchVisualizerPost(int client, int visualizer);
forward Action TF2_OnWeaponEquip(int client, const char[] classname, int itemdefindex);
forward void TF2_OnWeaponEquipPost(int client, const char[] classname, int itemdefindex, int level, int quality, int entity);
forward Action TF2_OnWearableEquip(int client, const char[] classname, int itemdefindex);
forward void TF2_OnWearableEquipPost(int client, const char[] classname, int itemdefindex, int level, int quality, int entity);
forward void TF2_OnRoundStart(bool full_reset);
forward void TF2_OnRoundActive();
forward void TF2_OnArenaRoundStart();
forward void TF2_OnRoundEnd(int team, int winreason, int flagcaplimit, bool full_round, float round_time, int losing_team_num_caps, bool was_sudden_death);
forward void TF2_OnPlayerSpawn(int client, int team, int class);
forward void TF2_OnPlayerDeath(int client, int attacker, int assister, int inflictor, int damagebits, int stun_flags, int death_flags, int customkill);
forward void TF2_OnPlayerHealed(int patient, int healer, int amount);
forward void TF2_OnPlayerTaunting(int client, int index, int defindex);
forward void TF2_OnPlayerTaunting(int client);
forward void TF2_OnZoomIn(int client);
forward void TF2_OnZoomOut(int client);
forward void TF2_OnFlagCapture(int team, int score);
forward void TF2_OnControlPointCapturing(int index, char[] name, int ownerteam, int cappingteam, char[] cappers, float captime);
forward void TF2_OnControlPointCaptured(int index, char[] name, int cappingteam, char[] cappers);

#if !defined REQUIRE_PLUGIN
public void __pl_tf2_api_SetNTVOptional()
{
	//MarkNativeAsOptional("PluginName_Native");
}
#endif

public SharedPlugin __pl_tf2_api =
{
	name = "tf2-api",
	file = "tf2-api.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};