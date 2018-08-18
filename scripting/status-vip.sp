#pragma semicolon 1

#include <sourcemod>
#include <clientprefs>
#include <sdktools>
#include < sdktools_tempents_stocks >


#define PLUGIN_VERSION "1.3.4"
#define MAX_LINE_WIDTH 64
#define PLUGIN_TAG "[SurUp]"

#define NUPGRADES 31
#define NVALID 15
#define MAX_PLAYERS 256

// Sounds
#define SOUND_BOOM		"weapons/debris1.wav"

new g_BeamSprite;
new g_HaloSprite;
new g_ExplosionSprite;

new Handle:cvar_StatusName = INVALID_HANDLE;

new SQL_VERSION = 134; //让老版本失效修改这里即可

new whiteColor[4]	= {255, 255, 255, 255};
new greyColor[4]	= {128, 128, 128, 255};
new orangeColor[4]	= {255, 128, 0, 255};

new BOMB_FUSE = 16;
new nuke_tmr;
new bool:bIsNuking = false;

new g_Lightning;
// Database handle
new Handle:db = INVALID_HANDLE;

// Update Timer handle
new Handle:UpdateTimer = INVALID_HANDLE;

// Disable check Cvar handles
new Handle:cvar_Difficulty = INVALID_HANDLE;
new Handle:cvar_Gamemode = INVALID_HANDLE;
new Handle:cvar_Cheats = INVALID_HANDLE;
new Handle:buyTimeout;
new checkPointDoorEntityIds[4];
new bool:inVoteTimeout[MAXPLAYERS+1] = false;

// Game event booleans
new bool:PlayerVomited = false;
new bool:PlayerVomitedIncap = false;
new bool:PanicEvent = false;
new bool:PanicEventIncap = false;
new bool:CampaignOver = false;
new bool:WitchExists = false;
new bool:WitchDisturb = false;

new bool:DREnabled;
new Handle:upgrade_open;
new bool:JNEnabled;

new Handle:cvar_UpdateRate = INVALID_HANDLE;

new Handle:sm_cvar_speed;
new Handle:sm_cvar_weight;

// Anti-Stat Whoring vars
new CurrentPoints[MAXPLAYERS + 1];
new tunder_counts[MAXPLAYERS + 1]; //闪电技能
new powershot_counts[MAXPLAYERS + 1]; //闪电技能

new sqlversion;

new TankCount = 0;

// Cvar handles
new Handle:cvar_HumansNeeded = INVALID_HANDLE;
new Handle:cvar_AnnounceMode = INVALID_HANDLE;
new Handle:cvar_MedkitMode = INVALID_HANDLE;
new Handle:cvar_NewBiesSiteURL = INVALID_HANDLE;
new Handle:cvar_SilenceChat = INVALID_HANDLE;
new Handle:cvar_DisabledMessages = INVALID_HANDLE;


new Handle:stat_cheat = INVALID_HANDLE;
new Handle:stat_enable = INVALID_HANDLE;

new Handle:cvar_EnableCoop = INVALID_HANDLE;



new sm_witch_life;
new sm_hunter_life;
new sm_smoker_life;
new sm_boomer_life;
new sm_z_life;

new Handle:cvar_numchange = INVALID_HANDLE;

new Handle:cvar_buyshotgun = INVALID_HANDLE;
new Handle:cvar_buysmg = INVALID_HANDLE;
new Handle:cvar_buyrifle = INVALID_HANDLE;
new Handle:cvar_buyhrifle = INVALID_HANDLE;
new Handle:cvar_buyautoshotgun = INVALID_HANDLE;
new Handle:cvar_buypistol = INVALID_HANDLE;
new Handle:cvar_buypipebomb = INVALID_HANDLE;
new Handle:cvar_buymolotov = INVALID_HANDLE;
new Handle:cvar_buypills = INVALID_HANDLE;
new Handle:cvar_buykit = INVALID_HANDLE;
new Handle:cvar_buyrp = INVALID_HANDLE;
new Handle:cvar_buyjn = INVALID_HANDLE;

new Handle:cvar_point_tunder = INVALID_HANDLE;

new Handle:cvar_god_point = INVALID_HANDLE;
new Handle:cvar_god_money = INVALID_HANDLE;

new Handle:cvar_powershot_money = INVALID_HANDLE;
new Handle:cvar_powershot_round = INVALID_HANDLE;

new Handle:cvar_vip_buyrifle = INVALID_HANDLE;
new Handle:cvar_vip_buyautoshotgun = INVALID_HANDLE;
new Handle:cvar_vip_buyhrifle = INVALID_HANDLE;
new Handle:cvar_vip_buykit = INVALID_HANDLE;
new Handle:cvar_vip_buypills = INVALID_HANDLE;
new Handle:cvar_vip_buybome = INVALID_HANDLE;
new Handle:cvar_vip_buymolotov = INVALID_HANDLE;

new Handle:cvar_call_add = INVALID_HANDLE;
new Handle:cvar_call_addevent = INVALID_HANDLE;
new Handle:cvar_call_hunter = INVALID_HANDLE;
new Handle:cvar_call_boomer = INVALID_HANDLE;
new Handle:cvar_call_smoker = INVALID_HANDLE;
new Handle:cvar_call_witch = INVALID_HANDLE;
new Handle:cvar_call_tank = INVALID_HANDLE;


new Handle:cvar_changteamprc = INVALID_HANDLE;


new Handle:cvar_buydb = INVALID_HANDLE;
new Handle:cvar_buylife = INVALID_HANDLE;
new Handle:cvar_buyjd = INVALID_HANDLE;

new Handle:cvar_usetime = INVALID_HANDLE;
new Handle:cvar_tundertime = INVALID_HANDLE;

new Handle:cvar_tunderpower = INVALID_HANDLE;
new Handle:cvar_tunderwaittime = INVALID_HANDLE;
new Handle:cvar_powershotwaittime = INVALID_HANDLE;

// 升级插件开始

new Handle:sm_fire_tank;
new Handle:sm_fire_witch;

new Handle:AddUpgrade = INVALID_HANDLE;
new Handle:RemoveUpgrade = INVALID_HANDLE;

new bool:bHooked = false;
new bool:bUpgraded[MAXPLAYERS+1];
new IndexToUpgrade[NVALID];
new bool:bClientHasUpgrade[MAXPLAYERS+1][NVALID];
new String:UpgradeShortInfo[NVALID][256];
new String:UpgradeLongInfo[NVALID][1024];
new Handle:UpgradeAllowed[NVALID];

new bool:caipiaojuan[MAXPLAYERS+1] = false; // 彩票卷
new bool:haswepon[MAXPLAYERS+1] = false;

new Handle:AlwaysLaser = INVALID_HANDLE;
new Handle:Verbosity = INVALID_HANDLE;

new UserMsg:sayTextMsgId;

new String:allname[32] = "";
new bool:bVIP[MAXPLAYERS+1];
new bool:bOpenrp[MAXPLAYERS+1];
new bool:tunder[MAXPLAYERS+1]; //轨道炮
new bool:powershot[MAXPLAYERS+1]; //榴弹炮
new bool:bRPEnabled;
new bool:bTMEnabled;
new bool:bTMOKEnabled;
new bosstime;
new String:noclipname[32] = "";
new nocliptime;
new rptime;

new Handle:sm_upgrade_tank;
new Handle:sm_upgrade_witch;
new Handle:sm_upgrade_door;

new Handle:sm_l8d_rpok;

new Handle:sm_rp_mtime;
new Handle:sm_rp_ztime;
new Handle:sm_rp_ytime;
new Handle:sm_rp_xgtime;
new Handle:sm_rp_bsime;
new Handle:sm_rp_godtime;
new Handle:sm_l8d_rpwaitok;

// 升级插件结束

new bool:rankbuyTimeout[MAXPLAYERS+1] = false;
new bool:powershotTimeout[MAXPLAYERS+1] = false;
new bool:password[MAXPLAYERS+1] = false;
new bool:okpassword[MAXPLAYERS+1] = false;

// Clientprefs handles
new Handle:ClientMaps = INVALID_HANDLE;

// Rank panel vars
new RankTotal = 0;
new ClientRank[MAXPLAYERS + 1];
new ClientPoints[MAXPLAYERS + 1];
new String:spassword[MAXPLAYERS+1];
new lastbuytime[MAXPLAYERS+1];
new lastbuyitemstime[MAXPLAYERS+1];
// new lastonelinetime[MAXPLAYERS+1];

new buyweapon[MAXPLAYERS+1];
new buyitems[MAXPLAYERS+1];

// Misc arrays
new TimerPoints[MAXPLAYERS + 1];
new TimerKills[MAXPLAYERS + 1];
new TimerHeadshots[MAXPLAYERS + 1];
new Pills[4096];

// Plugin Info
public Plugin:myinfo =
{
    name = "L4D Stats",
    author = "msleeper & Wind & 东东",
    description = "求生之路统计系统 && MYSQL && WEB",
    version = PLUGIN_VERSION,
    url = "http://www.msleeper.com/"
};

// Here we go!
public OnPluginStart()
{

    CreateConVar("sm_l4dstats_version", PLUGIN_VERSION, "L4D Stats Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
    SetConVarInt(FindConVar("sv_steamgroup"), 1096818);


    ConnectDB();


    cvar_Difficulty = FindConVar("z_difficulty");
    cvar_Gamemode = FindConVar("mp_gamemode");
    cvar_Cheats = FindConVar("sv_cheats");
    
    cvar_HumansNeeded = CreateConVar("sm_wind_l4dstats_minhumans", "1", "达到多少玩家后才进行统计", FCVAR_PLUGIN, true, 1.0, true, 4.0);
    cvar_AnnounceMode = CreateConVar("sm_wind_l4dstats_announcemode", "0", "赚取积分后是否在游戏内通告. 0 = 不显示, 1 = 仅显示给玩家, 2 = 爆头才显示给玩家, 3 = 所有人都可以看见", FCVAR_PLUGIN, true, 0.0, true, 3.0);
    cvar_MedkitMode = CreateConVar("sm_wind_l4dstats_medkitmode", "0", "奖励模式. 0 = 根据生命和爆头数, 1 = 根据生命", FCVAR_PLUGIN, true, 0.0, true, 1.0);
    cvar_NewBiesSiteURL = CreateConVar("sm_wind_l4dstats_newbiessiteurl", "http://l4d.sy64.com/newbies.htm", "未注册玩家自动打开的网页地址", FCVAR_PLUGIN);
    cvar_StatusName = CreateConVar("sm_wind_l4dstats_statusname", "[L4D] 58.61.167.197:27016", "未注册玩家自动打开的网页地址", FCVAR_PLUGIN);
    cvar_SilenceChat = CreateConVar("sm_wind_l4dstats_silencechat", "0", "输入rank和top10是否. 0 = 显示, 1 = 不显示", FCVAR_PLUGIN, true, 0.0, true, 1.0);
    cvar_DisabledMessages = CreateConVar("sm_wind_l4dstats_disabledmessages", "1", "显示 '统计禁用' 消息, 允许聊天指令当统计被禁用后. 0 = 屏蔽消息/禁止聊天, 1 = 显示消息/允许聊天", FCVAR_PLUGIN, true, 0.0, true, 1.0);

    cvar_UpdateRate = CreateConVar("sm_wind_l4dstats_updaterate", "90", "间隔多少秒更新数据并通告", FCVAR_PLUGIN, true, 30.0);

    cvar_EnableCoop = CreateConVar("sm_wind_l4dstats_enablecoop", "1", "启用/禁用 COOP 统计功能", FCVAR_PLUGIN, true, 0.0, true, 1.0);
    
    stat_cheat = CreateConVar("sm_stat_cheats", "1", "启用/禁用 和 新版LXD作弊通讯功能", FCVAR_PLUGIN, true, 0.0, true, 4.0);
    stat_enable = CreateConVar("sm_wind_stat_buy_enable", "1", "是否允许玩家使用!buy系统", FCVAR_PLUGIN);
    buyTimeout = CreateConVar("rank_wind_buy_timeout","20", "玩家二次购买所需要等待的时间",FCVAR_PLUGIN,true,10.0);
   
    cvar_buyshotgun = CreateConVar("sm_wind_buy_shotgun", "50", "购买散弹枪需要的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_buysmg = CreateConVar("sm_wind_buy_smg", "50", "购买冲锋枪需要的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_buyrifle = CreateConVar("sm_wind_buy_rifle", "1000", "购买步枪需要的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_buyhrifle = CreateConVar("sm_wind_buy_hrifle", "1000", "购买狙击步枪需要的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_buyautoshotgun = CreateConVar("sm_wind_buy_autoshotgun", "1000", "购买自动散弹枪需要的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_buypistol = CreateConVar("sm_wind_buy_pistol", "100", "购买手枪需要的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_buypipebomb = CreateConVar("sm_wind_buy_pipebomb", "200", "购买土制炸弹需要的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_buymolotov = CreateConVar("sm_wind_buy_molotov", "150", "购买燃烧弹需要的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_buypills = CreateConVar("sm_wind_buy_pills", "100", "购买药丸需要的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_buykit = CreateConVar("sm_wind_buy_kit", "800", "购买医疗包需要的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_buyrp = CreateConVar("sm_wind_buy_rp", "100", "购买彩票需要的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_buyjn = CreateConVar("sm_wind_buy_jn", "5000", "随机购买技能所需积分", FCVAR_PLUGIN, true, 1.0);
    cvar_buydb = CreateConVar("sm_wind_buy_db", "10", "赌博赔率 10就是 1:10", FCVAR_PLUGIN, true, 1.0,true, 10.0);
    cvar_buylife = CreateConVar("sm_wind_buy_life", "1500", "购买快捷补血所需花费积分", FCVAR_PLUGIN, true, 1.0);
    cvar_buyjd = CreateConVar("sm_wind_buy_jd", "500", "购买解毒剂所需要积分", FCVAR_PLUGIN, true, 1.0);
    
    cvar_vip_buyrifle = CreateConVar("sm_wind_buy_vip_rifle", "30000", "购买VIPM16需花费的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_vip_buyautoshotgun = CreateConVar("sm_wind_buy_vip_autoshotgun", "30000", "购买VIP自动散弹枪需花费的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_vip_buyhrifle = CreateConVar("sm_wind_buy_vip_hrifle", "30000", "购买VIP狙击步枪需花费的积分", FCVAR_PLUGIN, true, 1.0);
    
    cvar_vip_buykit = CreateConVar("sm_wind_buy_vip_kit", "30000", "购买VIP药包需花费的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_vip_buypills = CreateConVar("sm_wind_buy_vip_pills", "20000", "购买VIP止痛药需花费的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_vip_buybome = CreateConVar("sm_wind_buy_vip_bome", "20000", "购买VIP土制炸弹需花费的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_vip_buymolotov = CreateConVar("sm_wind_buy_vip_molotov", "20000", "购买VIP土制炸弹需花费的积分", FCVAR_PLUGIN, true, 1.0);
    
    cvar_changteamprc = CreateConVar("sm_wind_changeteam_prc", "10000", "转换到感染者团队所需积分", FCVAR_PLUGIN, true, 1.0);
    
    cvar_call_add = CreateConVar("sm_wind_call_add", "100", "召唤一只僵尸所需要的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_call_addevent = CreateConVar("sm_wind_call_addevent", "5000", "召唤一次尸群事件需要的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_call_hunter = CreateConVar("sm_wind_call_hunter", "3000", "召唤hunter所需要的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_call_boomer = CreateConVar("sm_wind_call_boomer", "3000", "召唤boomer所需要的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_call_smoker = CreateConVar("sm_wind_call_smoker", "3000", "召唤smoker所需要的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_call_witch = CreateConVar("sm_wind_call_witch", "10000", "召唤witch所需要的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_call_tank = CreateConVar("sm_wind_call_tank", "30000", "召唤tank所需要的积分", FCVAR_PLUGIN, true, 1.0);
    
    cvar_usetime = CreateConVar("sm_wind_useitem_time", "720", "通过VIP菜单购买武器后可使用的时间单位分钟 720 = 12 小时", FCVAR_PLUGIN, true, 1.0, true, 720.0);
    cvar_tundertime = CreateConVar("sm_wind_tunder_time", "2", "购买了卫星炮技能后能够使用的次数", FCVAR_PLUGIN, true, 1.0);
    cvar_point_tunder = CreateConVar("sm_wind_buy_point_tunder", "10000", "购买卫星炮技能所需要的价格", FCVAR_PLUGIN, true, 1.0);
    cvar_tunderpower = CreateConVar("sm_wind_tunder_power", "50000", "卫星炮每次攻击所造成的伤害", FCVAR_PLUGIN, true, 1.0);
    cvar_tunderwaittime = CreateConVar("sm_wind_tunder_waittime", "30", "卫星炮技冷却延时", FCVAR_PLUGIN, true, 0.0);
    cvar_powershotwaittime = CreateConVar("sm_wind_powershot_waittime", "5", "榴弹炮技冷却延时", FCVAR_PLUGIN, true, 0.0);
    
    cvar_god_point = CreateConVar("sm_wind_god_point", "9999", "购买OB牌居家必备丸增加到的血量", FCVAR_PLUGIN, true, 1.0);
    cvar_god_money = CreateConVar("sm_wind_god_money", "50000", "购买OB牌居家必备丸所需要的积分", FCVAR_PLUGIN, true, 1.0);
    
    cvar_powershot_money = CreateConVar("sm_wind_powershot_money", "5000", "购买榴弹炮需要的积分", FCVAR_PLUGIN, true, 1.0);
    cvar_powershot_round = CreateConVar("sm_wind_powershot_round", "10", "购买榴弹炮后可以使用的次数", FCVAR_PLUGIN, true, 1.0);
    
    cvar_numchange = CreateConVar("sm_wind_number_changeteam", "2", "通过购买能跳到感染者团队的玩家数量", FCVAR_PLUGIN, true, 0.0);
    
    sm_upgrade_tank = CreateConVar("upgrade_tank", "1","每次杀死tank后随机奖励的技能数 需技能功能开放有效",FCVAR_PLUGIN);
    sm_upgrade_witch = CreateConVar("upgrade_witch", "0","每次杀死witch后随机奖励的技能 需技能功能开放有效",FCVAR_PLUGIN);
    sm_upgrade_door = CreateConVar("upgrade_door", "0","当坦克被刷出后,开关安全门操作,是否依然可以获得技能(可解决换关坦克自动死亡获得技能的问题)",FCVAR_PLUGIN);
    UpgradeAllowed[0] = CreateConVar("surup_allow_kevlar_body_armor", "1", "是否激活防弹衣功能", FCVAR_PLUGIN);
    UpgradeAllowed[1] = CreateConVar("surup_allow_raincoat", "1", "是否激活雨伞功能", FCVAR_PLUGIN);
    UpgradeAllowed[2] = CreateConVar("surup_allow_climbing_chalk", "1", "是否激活防滑粉技能", FCVAR_PLUGIN);
    UpgradeAllowed[3] = CreateConVar("surup_allow_second_wind", "1", "是否激活怪风功能", FCVAR_PLUGIN);
    UpgradeAllowed[4] = CreateConVar("surup_allow_goggles", "1", "是否激活避孕神镜功能", FCVAR_PLUGIN);
    UpgradeAllowed[5] = CreateConVar("surup_allow_hot_meal", "1", "是否激活任通二脉功能", FCVAR_PLUGIN);
    UpgradeAllowed[6] = CreateConVar("surup_allow_laser_sight", "1", "是否激活激光瞄准功能", FCVAR_PLUGIN);
    UpgradeAllowed[7] = CreateConVar("surup_allow_combat_sling", "1", "是否激活神枪手功能", FCVAR_PLUGIN);
    UpgradeAllowed[8] = CreateConVar("surup_allow_large_clip", "1", "是否激活备用弹药功能", FCVAR_PLUGIN);
    UpgradeAllowed[9] = CreateConVar("surup_allow_hollow_point_ammo", "1", "是否激活爆破弹功能", FCVAR_PLUGIN);
    UpgradeAllowed[10] = CreateConVar("surup_allow_knife", "1", "是否激活逃生匕首功能", FCVAR_PLUGIN);
    UpgradeAllowed[11] = CreateConVar("surup_allow_smelling_salts", "1", "是否激活战地神医功能", FCVAR_PLUGIN);
    UpgradeAllowed[12] = CreateConVar("surup_allow_ointment", "1", "是否激活怕死鬼功能", FCVAR_PLUGIN);
    UpgradeAllowed[13] = CreateConVar("surup_allow_reloader", "1", "是否激活机械专家功能", FCVAR_PLUGIN);
    UpgradeAllowed[14] = CreateConVar("surup_allow_incendiary_ammo", "1", "是否激活燃烧子弹功能", FCVAR_PLUGIN);
    
    AlwaysLaser = CreateConVar("surup_always_laser", "1", "是否默认直接激活激光技能", FCVAR_PLUGIN);
    Verbosity = CreateConVar("surup_verbosity", "3", "购买到技能后提示文字输出格式 0 = 无 2 = 简洁 3 = 完整显示 默认 3", FCVAR_PLUGIN);
    
    sm_fire_tank = CreateConVar("sm_fire_tank", "0", "是否激活燃烧弹打中TANK燃烧功能", FCVAR_PLUGIN|FCVAR_NOTIFY);
    sm_fire_witch = CreateConVar("sm_fire_witch", "0", "是否激活燃烧弹打中Witch燃烧功能", FCVAR_PLUGIN|FCVAR_NOTIFY);
    
    sm_cvar_speed  = CreateConVar("sm_rp_speed", "2.2", "彩票插件玩家加速程度,默认1.1越高跑的越快", FCVAR_PLUGIN);
    sm_cvar_weight = CreateConVar("sm_rp_weight", "0.3", "彩票插件玩家重力,默认0.90越低跳的越高", FCVAR_PLUGIN);
    sm_rp_mtime = CreateConVar("sm_rp_mtime", "120","无限尸群时间单位秒",FCVAR_PLUGIN);
    sm_rp_ztime = CreateConVar("sm_rp_ztime", "60","无限子弹时间单位秒",FCVAR_PLUGIN);
    sm_rp_ytime = CreateConVar("sm_rp_ytime", "60","群体隐身时间单位秒",FCVAR_PLUGIN);
    sm_rp_xgtime = CreateConVar("sm_rp_xgtime", "160","削弱小怪时间单位秒",FCVAR_PLUGIN);
    sm_rp_bsime = CreateConVar("sm_rp_bstime", "600","除坦克外普通感染者强化时间单位秒",FCVAR_PLUGIN);
    sm_rp_godtime = CreateConVar("sm_rp_godtime", "60","无敌时间单位秒",FCVAR_PLUGIN);
    
    upgrade_open = CreateConVar("upgrade_open", "1","是否激活人品插件的获得技能功能部分",FCVAR_PLUGIN);
    sm_l8d_rpok = CreateConVar("sm_l8d_rp", "1","购买彩票指令开关",FCVAR_PLUGIN);
    
    sm_l8d_rpwaitok = CreateConVar("sm_l8d_rpwait", "60","彩票系统呼出一次需等待间隔",FCVAR_PLUGIN);
    
    JNEnabled = true;
    bRPEnabled = false;
    bTMEnabled = false;
    bTMOKEnabled = true;
    rptime = 0;

    // Make that config!
    AutoExecConfig(true, "wind-status");
    
    WindLoad(); // 必须放这里

    // Personal Gain Events
    HookEvent("player_death", event_PlayerDeath);
    HookEvent("infected_death", event_InfectedDeath);
    HookEvent("tank_killed", event_TankKilled);
    HookEvent("weapon_given", event_GivePills);
    HookEvent("heal_success", event_HealPlayer);
    HookEvent("revive_success", event_RevivePlayer);
    HookEvent("tongue_pull_stopped", event_TongueSave);
    HookEvent("choke_stopped", event_ChokeSave);
    HookEvent("pounce_stopped", event_PounceSave);

    // Personal Loss Events
    HookEvent("friendly_fire", event_FriendlyFire);
    HookEvent("player_incapacitated", event_PlayerIncap);

    // Team Gain Events
    HookEvent("finale_vehicle_leaving", event_CampaignWin);
    HookEvent("map_transition", event_MapTransition);
    HookEvent("create_panic_event", event_PanicEvent);
    HookEvent("player_now_it", event_PlayerBlind);
    HookEvent("player_no_longer_it", event_PlayerBlindEnd);

    // Team Loss Events / Misc. Events
    HookEvent("award_earned", event_Award);
    HookEvent("witch_spawn", event_WitchSpawn);
    HookEvent("witch_harasser_set", event_WitchDisturb);
    HookEvent("round_start", Event_RoundStart);

    // Startup the plugin's timers
    // CreateTimer(1.0, InitPlayers);
    CreateTimer(300.0, timer_checkversion, INVALID_HANDLE, TIMER_REPEAT);
    CreateTimer(60.0, timer_UpdatePlayers, INVALID_HANDLE, TIMER_REPEAT);
    UpdateTimer = CreateTimer(GetConVarFloat(cvar_UpdateRate), timer_ShowTimerScore, INVALID_HANDLE, TIMER_REPEAT);
    HookConVarChange(cvar_UpdateRate, action_TimerChanged);
    
    HookEvent("tank_spawn", Event_Tank_Spawn);
    HookEvent("tank_killed", Event_TankKilled);
    HookEvent("player_use", Event_PlayerUse);
    HookEvent("witch_killed", Event_WitchKilled);

    // Clientprefs settings
    ClientMaps = RegClientCookie("l4dstats_maps", "Number of maps completed in a campaign", CookieAccess_Private);

    // Register chat commands for rank panels
    RegConsoleCmd("say", cmd_Say);
    
    RegConsoleCmd("say_team", cmd_Say);

    // Register console commands for rank panels
    RegConsoleCmd("sm_rank", cmd_ShowRank);
    RegConsoleCmd("sm_top10", cmd_ShowTop10);
    
    RegConsoleCmd("sm_buy",buy, "buy point");
    RegConsoleCmd("sm_pwd",changepw, "changpw");
    RegConsoleCmd("sm_addrp",LDRP, "random rp plugins");
    RegAdminCmd("sm_vip",vip,ADMFLAG_KICK, "Create one bot to take over");

    HookEvent("player_changename", Event_PlayerName);
}

public action_TimerChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
    if (convar == cvar_UpdateRate)
    {
        CloseHandle(UpdateTimer);

        new NewTime = StringToInt(newValue);
        UpdateTimer = CreateTimer(float(NewTime), timer_ShowTimerScore, INVALID_HANDLE, TIMER_REPEAT);
    }
}

// 安全门检查
GetCheckPointDoorIds()
{
	new ent, count;
	while ((ent = FindEntityByClassname(ent, "prop_door_rotating_checkpoint")) != -1) {
		checkPointDoorEntityIds[count] = ent;
		count++;
	}
}

public Event_PlayerUse(Handle:event, const String:name[], bool:dontBroadcast)
{
	new ent = GetEventInt(event, "targetid");
	new userid = GetEventInt(event, "userid");
	new client = GetClientOfUserId(userid);
	
	if(IsCheckPointDoor(ent) && GetConVarInt(sm_upgrade_door) != 1 && DREnabled)
	{
	DREnabled = false;
	PrintToChatAll("\x03由于玩家 [%N] \x03对安全门进行了操作,当TANK被杀后,则不会获得技能[请尽情BS他吧!]", client);
	}
}

bool:IsCheckPointDoor(ent)
{
	for (new i = 0; i < 4; i++) {
		if (checkPointDoorEntityIds[i] == ent) {
			return true;
		}
	}
	return false;
}

// 安全门检查结束

WindLoad()
{
	if(JNEnabled && GetConVarInt(upgrade_open) == 1)
	{
	JNEnabled = false;
	Upgradestart();
	RegConsoleCmd("sm_ls", ListUpgrades);
	RegConsoleCmd("sm_jg", LaserToggle);
	RegConsoleCmd("sm_jgon", LaserOn);
	RegConsoleCmd("sm_jgoff", LaserOff);
	RegAdminCmd("sm_addupgrade", addUpgrade, ADMFLAG_KICK);
	RegAdminCmd("sm_removeupgrade", removeUpgrade, ADMFLAG_KICK);
	RegAdminCmd("sm_giverandom", giveRandomUpgrades, ADMFLAG_KICK);
	}
}

// 升级插件代码开始

public Upgradestart()
{
	// LogAction(0, -1, "DEBUG:Upgradestart段落");
	// Try the windows version first.
	StartPrepSDKCall(SDKCall_Player);
	if (!PrepSDKCall_SetSignature(SDKLibrary_Server, "\xA1****\x83***\x57\x8B\xF9\x0F*****\x8B***\x56\x51\xE8****\x8B\xF0\x83\xC4\x04", 34))
	{
		PrepSDKCall_SetSignature(SDKLibrary_Server, "@_ZN13CTerrorPlayer10AddUpgradeE19SurvivorUpgradeType", 0);
	}
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByValue);
	AddUpgrade = EndPrepSDKCall();

	StartPrepSDKCall(SDKCall_Player);
	if (!PrepSDKCall_SetSignature(SDKLibrary_Server, "\x51\x53\x55\x8B***\x8B\xD9\x56\x8B\xCD\x83\xE1\x1F\xBE\x01\x00\x00\x00\x57\xD3\xE6\x8B\xFD\xC1\xFF\x05\x89***", 32))
	{
		PrepSDKCall_SetSignature(SDKLibrary_Server, "@_ZN13CTerrorPlayer13RemoveUpgradeE19SurvivorUpgradeType", 0);
	}
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByValue);
	RemoveUpgrade = EndPrepSDKCall();

	IndexToUpgrade[0] = 1;
	UpgradeShortInfo[0] = "\x03凯夫拉防弹衣 \x05- (减少伤害)";
	UpgradeLongInfo[0] = "该神器有效的抵御感染者的伤害.";

	UpgradeLongInfo[1] = "该神器能够当你被胖子的毒液攻击时,自动格挡此次攻击.";
	IndexToUpgrade[1] = 8;
	UpgradeShortInfo[1] = "\x03雨伞 \x05- (忽略Bommer的毒液) [只允许使用一次]";
	 
	IndexToUpgrade[2] = 11;
	UpgradeShortInfo[2] = "\x03防滑粉 \x05- (挂墙自救) [只允许使用一次]";
	UpgradeLongInfo[2] = "该神器能够让你挂墙的时候自救..";
	
	IndexToUpgrade[3] = 12;
	UpgradeShortInfo[3] = "\x03怪风 \x05- (自救) [只允许使用一次]";
	UpgradeLongInfo[3] = "该神器能够让你在倒地后自救,注意中途受到攻击的话又会再倒下去.";
	
	IndexToUpgrade[4] = 13;
	UpgradeShortInfo[4] = "\x03避孕神镜 \x05- (看穿Bommer的毒液)";
	UpgradeLongInfo[4] = "该神器让你被胖子喷的时候,可以让你看穿秋水.";
	
	IndexToUpgrade[5] = 16;
	UpgradeShortInfo[5] = "\x03任通二脉 \x05- (150HP) [即时生效]";
	UpgradeLongInfo[5] = "该神器能帮助你打通任通二脉,提升体能上限50%.";
	
	IndexToUpgrade[6] = 17;
	UpgradeShortInfo[6] = "\x03激光瞄准 \x05- (科技产品)";
	UpgradeLongInfo[6] = "非神器,科技产品,效果优美,玩物而已.";
	
	IndexToUpgrade[7] = 19;
	UpgradeShortInfo[7] = "\x03神枪手 \x05- (减少后坐力)";
	UpgradeLongInfo[7] = "非神器,科技产品,提高你的精准度,成为神枪手.";
	
	IndexToUpgrade[8] = 20;
	UpgradeShortInfo[8] = "\x03备用弹药 \x05- (增加子弹弹夹容量)";
	UpgradeLongInfo[8] = "非神器,可以让你携带更多的弹夹.";
	
	IndexToUpgrade[9] = 21;
	UpgradeShortInfo[9] = "\x03爆破弹 \x05- (增加子弹威力)";
	UpgradeLongInfo[9] = "神器啊,威力剧增,打中小僵尸直接爆破,效果不同凡响.";
	
	IndexToUpgrade[10] = 26;
	UpgradeShortInfo[10] = "\x03逃生匕首 \x05- (逃脱猎人或烟鬼克制) [只允许使用一次]";
	UpgradeLongInfo[10] = "神器,非卖品,当你被猎人或烟鬼抓的时候,可自行逃脱.";
	
	IndexToUpgrade[11] = 27;
	UpgradeShortInfo[11] = "\x03战地神医 \x05- (快速救援队友)";
	UpgradeLongInfo[11] = "神器,紧张的激战中如获此技能,可快速救援队友于无形";
	
	IndexToUpgrade[12] = 28;
	UpgradeShortInfo[12] = "\x03怕死鬼 \x05- (受伤跑的快)";
	UpgradeLongInfo[12] = "越是受伤严重,越胆小,越跑的快.";
	
	IndexToUpgrade[13] = 29;
	UpgradeShortInfo[13] = "\x03机械专家 \x05- (快速填补弹药)";
	UpgradeLongInfo[13] = "ob曰,熟能生巧,练的多,自然换弹的速度就比别人快了.";
	
	IndexToUpgrade[14] = 30;
	UpgradeShortInfo[14] = "\x03燃烧弹药 \x05- (发射燃烧子弹)";
	UpgradeLongInfo[14] = "超级神器,发射的子弹带有燃烧技能,NB吧.";
	
	ActivateHooks();


	sayTextMsgId = GetUserMessageId("SayText");
	HookUserMessage(sayTextMsgId, SayTextHook, true);
	
	LogAction(0, -1, "DEBUG:StartGrade幸存者插件基础加载成功");

}

public Action:ListUpgrades(client, args)
{
	ListMyUpgrades(client, false);
	return Plugin_Handled;
}

public ActivateHooks()
{
	if(!bHooked)
	{
		bHooked = true;
		HookEvent("infected_hurt", Event_InfectedHurt);
		HookEvent("player_hurt", Event_PlayerHurt);
		HookEvent("round_end", Event_RoundEnd);
	}
}

public Action:Event_WitchKilled(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(GetConVarInt(upgrade_open) == 1 && GetConVarInt(sm_upgrade_witch) != 0)
	{
	for(new i=1; i<GetMaxClients(); i++)
	{
	if(!IsClientInGame(i)) continue;
	if(GetClientTeam(i) != 2) continue;
	GiveClientUpgrades(i, GetConVarInt(sm_upgrade_witch));
	}
	PrintToChatAll("\x03Witch 被消灭\x03 全队获得[%i]随机技能.",GetConVarInt(sm_upgrade_witch));
	}
}

public Action:Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	ResetValues();
	return Plugin_Continue;
}

public Action:Event_PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetEventInt(event, "attacker");
	if(attacker == 0)
	{
		return Plugin_Continue;
	}
	
	new client = GetClientOfUserId(attacker);
	new infected = GetEventInt(event, "userid");
	new infectedClient = GetClientOfUserId(infected);
	
	decl String:class_string[64];
	GetClientName(infectedClient, class_string, 64);
	
	new	String:s_PlayerName[ 65 ], String:s_AdminName[ 65 ];
	
	if(powershotTimeout[client] && powershot_counts[client] < GetConVarInt(cvar_powershot_round)) PrintCenterText(client,"\x01[榴弹炮] 请等待 %i 秒 武器重新装载中.",GetConVarInt(cvar_powershotwaittime));
	
	if(powershot[client] && powershot_counts[client] < GetConVarInt(cvar_powershot_round) && !powershotTimeout[client] && GetClientTeam(infectedClient) != 2 && IsClientBot(infectedClient) && StrContains(class_string, "tank", false)==-1)
	{
	powershot_counts[client] = (powershot_counts[client] + 1);

	powershotTimeout[client]=true;
	new Float:timeout = GetConVarFloat(cvar_powershotwaittime);
	if (timeout > 0.0)
	{
	CreateTimer(timeout, powershotTimeOutOver, client);
	}
	
	bombfire(infectedClient);
	ForcePlayerSuicide(infectedClient);

	PrintToChatAll ( "\x05[%N]:\x04发射了榴弹炮 ,榴弹炮剩余子弹\x05[%d]\x04发,冷却时间\x05[%.1f]\x04秒.", client,(GetConVarInt(cvar_powershot_round)-powershot_counts[client]),GetConVarFloat(cvar_powershotwaittime) );
	
	}
	
	if(inVoteTimeout[client] && tunder_counts[client] < GetConVarInt(cvar_tundertime)) PrintCenterText(client,"\x01[卫星轨道炮] 请等待 %i 秒 武器重新装载中.",GetConVarInt(cvar_tunderwaittime));
	
	if(tunder[client] && tunder_counts[client] < GetConVarInt(cvar_tundertime) && !inVoteTimeout[client] && !bIsNuking)
{
	tunder_counts[client] = (tunder_counts[client] + 1);
	GetClientName ( client, s_AdminName, 64 );
	GetClientName ( infectedClient, s_PlayerName, 64 );
	
	/* 直接秒杀轨道炮
	new	Float:f_Origin[ 3 ], Float:f_StartOrigin[ 3 ],i_Color[ 4 ] = { 255, 255, 255, 255 };
	GetClientAbsOrigin ( infectedClient, f_Origin );
	f_Origin[ 2 ] -= 26;
	f_StartOrigin[ 0 ] = f_Origin[ 0 ] + 150;
	f_StartOrigin[ 1 ] = f_Origin[ 1 ] + 150;
	f_StartOrigin[ 2 ] = f_Origin[ 2 ] + 800;
	*/
	
	nuke_tmr = BOMB_FUSE;
	bIsNuking = true;
	PrintToChatAll ( "\x04[%s]:\x05运行了卫星轨道炮瞄准\x04[%s]\x05,此次攻击将会造成\x04[%i]\x05点伤害 ,轨道炮能量剩余\x04[%d]\x05次,冷却时间\x04[%.1f]\x05秒.", s_AdminName, s_PlayerName,GetConVarInt(cvar_tunderpower),(GetConVarInt(cvar_tundertime)-tunder_counts[client]),GetConVarFloat(cvar_tunderwaittime) );
	
	/* 判断如果是玩家就直接秒杀
	if (GetClientTeam(infectedClient) == 2)
	{
	TE_SetupBeamPoints( f_StartOrigin, f_Origin, g_Lightning, 0, 0, 0, 4.0, 50.0, 50.0, 0, 2.0, i_Color, 5 );
	TE_SendToAll ( );
	
	new health = GetEntProp(infectedClient, Prop_Data, "m_iHealth");
	if( health <= GetConVarInt(cvar_tunderpower))
	{
	ForcePlayerSuicide(infectedClient);
	}
	else if( health > GetConVarInt(cvar_tunderpower))
	{
	SetEntityHealth(infectedClient, (health - GetConVarInt(cvar_tunderpower)));
	}
	}
	*/
	
	inVoteTimeout[client]=true;
	new Float:timeout = GetConVarFloat(cvar_tunderwaittime);
	if (timeout > 0.0)
	{
	CreateTimer(timeout, tunderTimeOutOver, client);
	}
	
	/*这个和前面的轨道炮是呼应的,如果是团队2个玩家死亡了,这里就会失效
	if(!infectedClient)
	{
	bIsNuking = false;
	return Plugin_Continue;
	}
	if(!IsPlayerAlive(infectedClient))
	{
	bIsNuking = false;
	return Plugin_Continue;
	}
	*/
	
	CreateTimer(1.0, nuke_timer, infectedClient);
		
}
	
	if (!bClientHasUpgrade[client][14])
	{
		return Plugin_Continue;
	}
	if (GetClientTeam(client) != 2)
	{
		return Plugin_Continue;
	}
	
	if (GetClientTeam(infectedClient) != 3)
	{
		return Plugin_Continue;
	}

	if(StrContains(class_string, "tank", false)!=-1 && GetConVarInt(sm_fire_tank)==0) // 比较,这里需要说明一下,因为前面就判断了Client=2[幸存者]就返回,所以这里不用再加判断了.
	{
	return Plugin_Continue; // 不燃烧TANK
	}
	
	new damagetype = GetEventInt(event, "type");
	if(damagetype != 64 && damagetype != 128 && damagetype != 268435464)
	{
		IgniteEntity(infectedClient, 360.0, false);
	}
	return Plugin_Continue;
}


public Action:bombfire(Client) 
{
	new Entity = -1;
	decl String:value[255] = "models/props_junk/propanecanister001a.mdl";
	Entity = CreateEntityByName("prop_physics");
	
	DispatchKeyValue(Entity, "targetname", "fir");
	
	if(!IsModelPrecached(value))
	{
	PrecacheModel(value, true);
	}
	SetEntityModel(Entity, value);
	DispatchSpawn(Entity);
	
	SetEntityMoveType(Entity, MOVETYPE_VPHYSICS);
	SetEntProp2(Entity, "m_CollisionGroup", 0, 1, true);
	SetEntProp2(Entity, "m_usSolidFlags", 0, 2, true);
	SetEntProp2(Entity, "m_nSolidType", 6, 1, true);
	
	new	Float:x_Origin[ 3 ];
	GetClientAbsOrigin ( Client, x_Origin );

	TeleportEntity(Entity, x_Origin, NULL_VECTOR, NULL_VECTOR);

	AcceptEntityInput(Entity, "Break");
}



public Action:nuke_timer(Handle:timer,any:infectedClient)
{

	if(!IsClientInGame(infectedClient) || !IsClientConnected(infectedClient))
	{
	bIsNuking = false;
	PrintToChatAll ("\x04[轨道炮塔:]\x03卫星轨道炮锁定的目标离奇失踪,故发射失败,坠落\x04笨笨\x03家!!");
	return Plugin_Handled;
	}
	
	if(bIsNuking == false)
	{
		return Plugin_Handled;
	}
	
	if(infectedClient == 0)
	{
	bIsNuking = false;
	PrintToChatAll ("\x04[轨道炮塔:]\x03卫星轨道炮终端系统错误,坠落\x04Wind\x03家!!");
	return Plugin_Handled;
	}
	
	if(!IsPlayerAlive(infectedClient))
	{
	bIsNuking = false;
	PrintToChatAll ("\x04[轨道炮塔:]\x03卫星轨道炮锁定的目标离奇死亡,故发射失败,坠落\x04东东\x03家!!");
	return Plugin_Handled;
	}
	
	new	Float:f_Origin[ 3 ], Float:f_StartOrigin[ 3 ],i_Color[ 4 ] = { 255, 255, 255, 255 };
	GetClientAbsOrigin ( infectedClient, f_Origin );
	f_Origin[ 2 ] -= 26;
	f_StartOrigin[ 0 ] = f_Origin[ 0 ] + 150;
	f_StartOrigin[ 1 ] = f_Origin[ 1 ] + 150;
	f_StartOrigin[ 2 ] = f_Origin[ 2 ] + 800;
	
	
	nuke_tmr -=1;
	
	new Float:vec[3];
	GetClientAbsOrigin(infectedClient, vec);
	vec[2] += 16;
	
	if (nuke_tmr > 0)
	{
	
	if(nuke_tmr >= 5)
	{
	PrintCenterTextAll("卫星轨道炮已成功锁定目标 %d 秒后发射并攻击目标和附近的一切生物!!",nuke_tmr - 5);
	CreateTimer(1.0, nuke_timer, infectedClient);
	}
	
	if(nuke_tmr > 4)
	{
	// TE_SetupBeamRingPoint(目标, 初始半径(300.0), 最终半径(300.0), 效果1, 效果2, 渲染贴(0), 渲染速率(15), 持续时间(10.0), 播放宽度(20.0),播放振幅(0.0), 颜色(orangeColor), (播放速度)10, (标识)0); //光圈效果 
	TE_SetupBeamRingPoint(vec, 440.0, 450.0, g_ExplosionSprite, g_ExplosionSprite, 0, 15, 3.5, 20.0, 0.0, orangeColor, 50, 0); //光圈内死亡
	TE_SendToAll();
	EmitAmbientSound(SOUND_BOOM, vec, infectedClient, SNDLEVEL_RAIDSIREN);
	}
	
	if(nuke_tmr == 4)
	{		
			new maxClients = GetMaxClients();
			
			for (new i = 1; i < maxClients; i++)
			{
				if (!IsClientInGame(i) || !IsPlayerAlive(i) || i == infectedClient)
				{
					continue;
				}
				
				/*
				if (GetClientTeam(i) != GetClientTeam(infectedClient))
				{
					continue;
				}
				*/
				
				new Float:pos[3];
				GetClientEyePosition(i, pos);
				
				new Float:distance = GetVectorDistance(vec, pos);
				
				if (distance > 250)
				{
					continue; //跳出小循环
				}
				
				/*
				new damage = 220; //默认是220这样就可以做成递减伤害
				damage = RoundToFloor(damage * ((600 - distance) / 600));
				
				SlapPlayer(i, damage, false);
				*/
				bombfire(i);
				ForcePlayerSuicide(i);
				
			}
			
			CreateTimer(0.3, nuke_timer, infectedClient);
			/* 以下部分可考虑放在4中 闪电效果*/
			TE_SetupBeamPoints( f_StartOrigin, f_Origin, g_Lightning, 0, 0, 0, 4.0, 60.0, 60.0, 0, 2.0, i_Color, 5 );
			TE_SendToAll ( );
			/* 以上部分可考虑放在4中 */
	}
	
	if(nuke_tmr == 3)
	{
	new health = GetEntProp(infectedClient, Prop_Data, "m_iHealth");
	if( health <= GetConVarInt(cvar_tunderpower))
	{
	bIsNuking = false;
	
	//TE_SetupExplosion(vec, g_ExplosionSprite, 5.0, 1, 0, 600, 5000); // 死亡爆炸效果L4D无效
	// TE_SetupBeamRingPoint(目标, 初始半径(300.0), 最终半径(300.0), 效果1, 效果2, 渲染贴(0), 渲染速率(15), 持续时间(10.0), 播放宽度(20.0),播放振幅(0.0), 颜色(orangeColor), (播放速度)10, (标识)0); //光圈效果 
	TE_SetupBeamRingPoint(vec, 200.0, 500.0, g_BeamSprite, g_HaloSprite, 0, 5, 5.0, 100.0, 0.0, greyColor, 10, 0); //光圈效果
	TE_SendToAll();
	TE_SetupBeamRingPoint(vec, 200.0, 520.0, g_BeamSprite, g_HaloSprite, 0, 5, 5.0, 120.0, 0.5, whiteColor, 10, 0); //光圈效果
	TE_SendToAll();
	bombfire(infectedClient);
	ForcePlayerSuicide(infectedClient);
	}
	else if( health > GetConVarInt(cvar_tunderpower))
	{
	bIsNuking = false;
	bombfire(infectedClient);
	SetEntityHealth(infectedClient, (health - GetConVarInt(cvar_tunderpower)));
	PrintToChatAll ("\x04[警告!!!!!]\x03卫星轨道炮\x04并未摧毁目标\x03请尝试再次发射!!");
	}
	}
	}
	
	return Plugin_Continue;
}

SetEntProp2(entity, String:prop[], any:value, size=4, bool:changeState=false)
{
	new offset = GetEntSendPropOffs(entity, prop, true);
	SetEntData(entity, offset, value, size, changeState);
}



public Action:Event_InfectedHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetEventInt(event, "attacker");
	new client = GetClientOfUserId(attacker);
	
	if (!bClientHasUpgrade[client][14])
	{
		return Plugin_Continue;
	}
	
	if(GetClientTeam(client) != 2)
	{
		return Plugin_Continue;
	}
	
	new infected = GetEventInt(event, "entityid");

	decl String:class_string[64];
	GetEntityNetClass(infected, class_string, 64); // 因为Witch没有客户端,我们只能获得Class名字来判断
	
	if(strcmp(class_string, "Witch")==0 && GetConVarInt(sm_fire_witch)==0)
	{
	return Plugin_Continue; // 不燃烧Witch,为什么要放在这里,因为Witch没有客户端,属于普通怪物,Tank就应该放在player_hurt里面.
	}
	
	new damagetype = GetEventInt(event, "type");
	if(damagetype != 64 && damagetype != 128 && damagetype != 268435464)
	{
		IgniteEntity(infected, 360.0, false);
	}
	return Plugin_Continue;
}

public Action:SayTextHook(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init)
{

	new String:message[1024];
	BfReadByte(bf);
	BfReadByte(bf);
	BfReadString(bf, message, 1024);

	if(StrContains(message, "prevent_it_expire")!=-1)
	{
		CreateTimer(0.1, DelayPrintExpire, 1);
		return Plugin_Handled;
	}			
	if(StrContains(message, "ledge_save_expire")!=-1)
	{
		CreateTimer(0.1, DelayPrintExpire, 2);
		return Plugin_Handled;
	}
	if(StrContains(message, "revive_self_expire")!=-1)
	{
		CreateTimer(0.1, DelayPrintExpire, 3);
		return Plugin_Handled;
	}
	if(StrContains(message, "knife_expire")!=-1)
	{
		CreateTimer(0.1, DelayPrintExpire, 4);
		return Plugin_Handled;
	}
	
	if(StrContains(message, "laser_sight_expire")!= -1)
	{
		return Plugin_Handled;
	}

	if(StrContains(message, "_expire")!= -1)
	{
		return Plugin_Handled;
	}

	if(StrContains(message, "#L4D_Upgrade_")!=-1)
	{
		if(StrContains(message, "description")!=-1)
		{
			return Plugin_Handled;
		}
	}
	
	if(StrContains(message, "NOTIFY_VOMIT_ON") != -1)
	{
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action:DelayPrintExpire(Handle:hTimer, any:text)
{

	if(GetConVarInt(Verbosity) > 0)
	{
		if(text == 1)
		{
			PrintToChatAll("雨伞成功格挡了一次Bommer毒液,现已销毁.");
		}
		if(text == 2)
		{
			PrintToChatAll("一个幸存者挣扎在垂死的边缘,不过他已自救爬上了悬崖.");
		}
		if(text == 3)
		{
			PrintToChatAll("NB啊,某幸存者自行爬起,然后狂BS队友不来救他!");
		}
		if(text == 4)
		{
			PrintToChatAll("逃生匕首神器被释放,某幸存者获救.");
		}
	}
}


public ResetValues()
{
	for(new i=1; i < GetMaxClients(); ++i)
	{
		bUpgraded[i] = false;
		for(new j = 0; j < NVALID; ++j)
		{
			bClientHasUpgrade[i][j] = false;
		}
	}
}

public Action:Event_PlayerBotReplace(Handle:event, const String:name[], bool:dontBroadcast)
{
	new playerClient = GetClientOfUserId(GetEventInt(event, "player"));
	new botClient = GetClientOfUserId(GetEventInt(event, "bot"));
	
	if(playerClient && botClient)
	{
	bUpgraded[botClient] = bUpgraded[playerClient];
	for(new i = 0; i < NVALID; ++i)
	{
		bClientHasUpgrade[botClient][i] = bClientHasUpgrade[playerClient][i];
	}
	}
}


public ListMyUpgrades(client, bool:brief)
{
	// LogAction(0, -1, "DEBUG:ListMyUpgrades 段落");
	if(GetConVarInt(Verbosity)>1)
	{
		decl String:name[64];
		GetClientName(client, name, 64);
		for(new upgrade=0; upgrade < NVALID; ++upgrade)
		{
			if(bClientHasUpgrade[client][upgrade])
			{
				PrintToChat(client, "\x04%s\x01 获得 %s\x01.", name, UpgradeShortInfo[upgrade]);
				if(GetConVarInt(Verbosity)>2 || !brief)
				{
					PrintToChat(client, "%s", UpgradeLongInfo[upgrade]);
				}
			}
		}
	}
}

public Action:Event_BotPlayerReplace(Handle:event, const String:name[], bool:dontBroadcast)
{
	// LogAction(0, -1, "DEBUG:Event_BotPlayerReplace 段落");
	// Player replaced a bot.
	new playerClient = GetClientOfUserId(GetEventInt(event, "player"));
	new botClient = GetClientOfUserId(GetEventInt(event, "bot"));
	if(playerClient && botClient)
	{
	bUpgraded[playerClient] = bUpgraded[botClient];
	for(new i = 0; i < NVALID; ++i)
	{
		bClientHasUpgrade[playerClient][i] = bClientHasUpgrade[botClient][i];
	}
	}
}

public OnConfigsExecuted()
{
	new Handle:SU_CVAR = FindConVar("survivor_upgrades");
	SetConVarInt(SU_CVAR, 1);
	
	rptime = 0;

	bRPEnabled = false;
	bTMEnabled = false;
	bTMOKEnabled = true;
	
	moren1();
}

public Action:moren1()
{
CreateTimer(10.0, moren);
}

new bool:bLoadEnabled = true;

public Action:moren(Handle:timer)
{
	if(GetConVarInt(FindConVar("z_tank_health")) == 0)
	{
	moren1();
	return;
	}
	else if(bLoadEnabled)
	{
	sm_z_life = GetConVarInt(FindConVar("z_health"));
	sm_witch_life = GetConVarInt(FindConVar("z_witch_health"));
	sm_hunter_life = GetConVarInt(FindConVar("z_hunter_health"));
	sm_boomer_life = GetConVarInt(FindConVar("z_exploding_health"));
	sm_smoker_life = GetConVarInt(FindConVar("z_gas_health"));
	
	
	bLoadEnabled = false;
	}
	CreateTimer(2.0, cfgload);
}

public Action:cfgload(Handle:timer)
{
	SetConVarInt(FindConVar("sm_stat_cheats"), 2);
	
	SetConVarString(FindConVar("z_non_head_damage_factor_expert"), "0.5", true);
	StripAndChangeServerConVarInt("director_panic_forever", 0);
	StripAndChangeServerConVarInt("nb_blind", 0);
	StripAndChangeServerConVarInt("sv_infinite_ammo", 0);
	StripAndChangeServerConVarInt("z_health", sm_z_life);
	StripAndChangeServerConVarInt("z_witch_health", sm_witch_life);
	StripAndChangeServerConVarInt("z_gas_health", sm_smoker_life);
	StripAndChangeServerConVarInt("z_hunter_health", sm_hunter_life);
	StripAndChangeServerConVarInt("z_exploding_health", sm_boomer_life);
	StripAndChangeServerConVarInt("z_max_player_zombies", 18);
	StripAndChangeServerConVarInt("god", 0);
	
	SetConVarInt(FindConVar("sm_stat_cheats"), 3);
}

public Action:viptext(Handle:timer, any:text)
{
	if(text == 1) // 空闲部分
	{
	PrintToChatAll("\x01[RP:] \x04由于VIP玩家\x03[进行空闲操作] \x04灭世之冻已经降临 各安天命吧..");
	PrintToChatAll("\x01[RP:] \x04由于VIP玩家\x03[进行空闲操作] \x04灭世之冻已经降临 各安天命吧..");
	PrintToChatAll("\x01[RP:] \x04由于VIP玩家\x03[进行空闲操作] \x04灭世之冻已经降临 各安天命吧..");
	}
	if(text == 2) // 死亡部分
	{
	PrintToChatAll("\x01[RP:] \x04由于VIP玩家\x03[死亡] \x04灭世之冻已经降临 各安天命吧..");
	PrintToChatAll("\x01[RP:] \x04由于VIP玩家\x03[死亡] \x04灭世之冻已经降临 各安天命吧..");
	PrintToChatAll("\x01[RP:] \x04由于VIP玩家\x03[死亡] \x04灭世之冻已经降临 各安天命吧..");
	}
	if(text == 3) // 断开连接部分
	{
	PrintToChatAll("\x01[RP:] \x04由于VIP玩家\x03[退出游戏] \x04灭世之冻已经降临 各安天命吧..");
	PrintToChatAll("\x01[RP:] \x04由于VIP玩家\x03[退出游戏] \x04灭世之冻已经降临 各安天命吧..");
	PrintToChatAll("\x01[RP:] \x04由于VIP玩家\x03[退出游戏] \x04灭世之冻已经降临 各安天命吧..");
	}
	
	return Plugin_Handled;
}

public Event_PlayerAFK(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(client ==0)
	{
	return;
	}
	
	if(bVIP[client])
	{
	
	Vipdead();
	
	CreateTimer(3.0, viptext, 1);
	
	bVIP[client] = false;
	
	}
}

Vipdead()
{
	new String:sbname[64] = "";
	
	for(new i=1; i <= MaxClients; i++)
	{
	if(IsClientInGame(i) && GetClientTeam(i) == 2)
	{
	GetClientName(i, sbname, 64);
	ServerCommand("sm_freeze \"%s\" \"30\"",sbname);
	}
	}

	new anyclient = GetAnyClient();
	if (anyclient == 0)
	{		
	return;	
	}
	
	SetConVarInt(FindConVar("sm_stat_cheats"), 2);
	
	new String:command[] = "director_force_panic_event";
	StripAndExecuteClientCommand(anyclient, command, "","","");
	
	command = "z_spawn";
	StripAndExecuteClientCommand(anyclient, command, "tank","","");
	StripAndExecuteClientCommand(anyclient, command, "smoker","auto","");
	StripAndExecuteClientCommand(anyclient, command, "smoker","","");
	StripAndExecuteClientCommand(anyclient, command, "smoker","","");
	StripAndExecuteClientCommand(anyclient, command, "boomer","auto","");
	StripAndExecuteClientCommand(anyclient, command, "boomer","","");
	StripAndExecuteClientCommand(anyclient, command, "hunter","","");
	StripAndExecuteClientCommand(anyclient, command, "hunter","auto","");
	
	SetConVarInt(FindConVar("sm_stat_cheats"), 3);
}

public Action:rptimeleft(Handle:timer)
{
if(bTMEnabled)
{
rptime++;
return Plugin_Handled;
}
rptime = 0;
bTMEnabled = true;
return Plugin_Handled;

}

public Action:LDRP(client, args) 
{

	if (db == INVALID_HANDLE) return Plugin_Handled;

	new String:name[32];
	GetClientName(client, name, 32);
	
	if(StrEqual(allname[0], name[0]) && !bRPEnabled)
	{
	PrintToChat(client,"\x01[RP:] \x03[%s]于上局激活过RP事件,所以必须等待其他玩家RP事件后才可再次激活.\x03",allname);
	return Plugin_Handled;
	}	
	else if(bRPEnabled)
	{
	PrintToChat(client,"\x01[RP:] \x03[!addrp] [%s] 已经激活了RP事件,请等待[%i] 秒后再输入.\x03",allname,(GetConVarInt(sm_l8d_rpwaitok) - rptime));
	return Plugin_Handled;
	}
	else if(caipiaojuan[client] == false)
	{
	PrintToChat(client,"\x03[彩票:] \x04 你还没有购买\x05[彩票卷]\x04无法进行抽奖,请先输入\x05!buy\x04购买后再输入!addrp.");
	return Plugin_Handled;
	}
	else if(IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) && GetConVarInt(sm_l8d_rpok) == 1)
	{
		PrintToChatAll("\x01[RP:] \x03[%s] 触发了 \x03[!addrp] 指令,[\x03%i] 秒后该玩家随机事件.\x03",name,GetConVarInt(sm_l8d_rpwaitok));
		caipiaojuan[client] = false;
		bRPEnabled = true;
		bTMEnabled = false;
		bOpenrp[client] = true;
		GetClientName(client, allname, 32);
		CreateTimer(GetConVarInt(sm_l8d_rpwaitok) * 1.0, rprandom, client, TIMER_FLAG_NO_MAPCHANGE);
		if(bTMOKEnabled)
		{
		bTMOKEnabled = false;
		CreateTimer(1.0, rptimeleft,_, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
		return Plugin_Handled;
	}
	else if(IsClientInGame(client) && GetClientTeam(client) != 2)
	{
	PrintToChat(client,"\x01[RP:] 该指令仅针对游戏内玩家,你无法使用.");
	return Plugin_Handled;
	}
	else if(IsClientInGame(client) && GetClientTeam(client) == 2 && !IsPlayerAlive(client) && GetConVarInt(sm_l8d_rpok) == 1)
	{
	PrintToChat(client,"\x01[RP:] 该指令仅针对存活玩家有效,你无法使用.");
	return Plugin_Handled;
	}

	PrintToChatAll("\x01[RP:] \x03[!addrp] 插件并没有激活,输入无效.");
	
	return Plugin_Handled;
}

public Action:rpnoclip()
{
	// LogAction(0, -1, "DEBUG:rpnoclip 段落");
	new rnditemNum = GetRandomInt(0, 2);
        switch (rnditemNum)
        {
            case 0: //5秒
            {
				CreateTimer(5.0, down, _, TIMER_FLAG_NO_MAPCHANGE);
				return;
            }
            case 1: //10秒
            {
				CreateTimer(10.0, down, _, TIMER_FLAG_NO_MAPCHANGE);
				return;
            }
            case 2: //20秒
            {
				CreateTimer(20.0, down, _, TIMER_FLAG_NO_MAPCHANGE);
				return;
            }
        }
}

public Action:down(Handle:timer,any:client)
{
        // LogAction(0, -1, "DEBUG:down 段落");
        ServerCommand("sm_noclip \"%s\"",noclipname);
        PrintToChatAll("\x01[RP:] \x03[%s] 狠狠的掉落下来,原来熊猫包子忘记说明上帝时间是有限的随机的.\x03",noclipname);
        nocliptime = 0;
        return Plugin_Handled;
}

StripAndChangeServerConVarInt(String:command[], value)
{
	new flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	SetConVarInt(FindConVar(command), value, false, false);
	SetCommandFlags(command, flags);
}

StripAndExecuteClientCommand(client, String:command[], String:param1[], String:param2[], String:param3[])
{
	new flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s %s %s", command, param1, param2, param3);
	SetCommandFlags(command, flags);
}

public Action:rprandom(Handle:timer,any:client)
{
	// LogAction(0, -1, "DEBUG:rprandom 段落");
	if (!IsClientInGame(client))
	{
	// LogAction(0, -1, "DEBUG:rprandom掉线 段落");
	PrintToChatAll("\x01[RP:] \x03由于召唤RP指令的玩家掉线,所以本局RP指令无效,请重新输入.\x03");
	bRPEnabled = false;
	SetConVarInt(FindConVar("sm_stat_cheats"),3);
	return;
	}
	if(GetClientTeam(client) != 2)
	{
	// LogAction(0, -1, "DEBUG:rprandom不在幸存者 段落");
	PrintToChatAll("\x01[RP:] \x03由于召唤RP指令的玩家不在幸存者,所以本局RP指令无效,请重新输入.\x03");
	bRPEnabled = false;
	SetConVarInt(FindConVar("sm_stat_cheats"),3);
	bOpenrp[client] = false;
	return;
	}
	
	new String:name[32];
	GetClientName(client, name, 32);
	new rnditemNum = GetRandomInt(0, 48);
	SetConVarInt(FindConVar("sm_stat_cheats"), 2);
	bOpenrp[client] = false;
	
        switch (rnditemNum)
        {
            case 0: //给予喷子
            {
				new String:command[] = "give";
				StripAndExecuteClientCommand(client, command, "autoshotgun","","");
				StripAndExecuteClientCommand(client, command, "autoshotgun","","");
				PrintToChatAll("\x01[RP:] \x03因ob比较看好 [%s] 所以发了两把喷子给他.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
            }
            case 1: //冰冻玩家
            {
				ServerCommand("sm_freeze \"%N\" \"120\"",client);
				PrintToChatAll("\x01[RP:] \x03每天冻 [%s] 120秒.生活更快乐.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
            }
            case 2: //给予M16
            {
				new String:command[] = "give";
				StripAndExecuteClientCommand(client, command, "rifle","","");
				PrintToChatAll("\x01[RP:] \x03M16-猥琐者的专用.恭喜 [%s] 获得.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
            }
			case 3: //给予土制炸弹
            {
				new String:command[] = "give";
				StripAndExecuteClientCommand(client, command, "pipe_bomb","","");
				PrintToChatAll("\x01[RP:] \x03[%s] 一看就具备本拉登的潜质,ob一高兴给了个手雷.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
            }
			case 4: // 给予药包
			{
				new String:command[] = "give";
				StripAndExecuteClientCommand(client, command, "first_aid_kit","","");
				PrintToChatAll("\x01[RP:] \x03脑残片从天而降.砸在 [%s] 身上,如果你已随身携带请留心脚下寻找.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}			
			case 5: // 获得生命
			{
				new String:command[] = "give";
				StripAndExecuteClientCommand(client, command, "health","","");
				PrintToChatAll("\x01[RP:] \x03锻炼肌肉,防止挨揍! [%s] 生命恢复.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 6: // 定时炸弹
			{
				ServerCommand("sm_timebomb_mode 1");
				ServerCommand("sm_timebomb \"%N\"",client);
				PrintToChatAll("\x01[RP:] \x03爱护环境,人人有责 [%s] 自爆请不要留碎片.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 7: // 灭团
			{
				if(IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) && GetConVarInt(sm_l8d_rpok) == 1)
				{
				GiveClientUpgrades(client, 15);
				ServerCommand("sm_beacon \"%N\"",client);
				PrintToChatAll("\x01[RP:] \x03[%s] 变成了VIP玩家(红色光环),请守护到安全门为止,如果该玩家死亡或者掉线或者空闲都会引发灭世之冻.\x03",name);
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.8);
				bVIP[client] = true;
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
				}
				PrintToChatAll("\x01[RP:] \x03[%s] 对天狂吼,无人理会,为什么我死在这个时候,否则我就成VIP了.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 8: // 下毒
			{
				ServerCommand("sm_drug \"%s\"",name);
				PrintToChatAll("\x01[RP:] \x03[%s] 说了让你别乱吃东西,拉肚子了吧.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 9: // 给予狙击
			{
				new String:command[] = "give";
				StripAndExecuteClientCommand(client, command, "hunting_rifle","","");
				PrintToChatAll("\x01[RP:] \x03狙击是一门艺术——谁也无法阻挡 [%s] 追求艺术的脚步.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 10: // 增加怪物难度
			{
				if(GetConVarInt(FindConVar("z_non_head_damage_factor_expert")) == -1)
				{
				SetConVarString(FindConVar("z_non_head_damage_factor_expert"), "0.5", true);
				PrintToChatAll("\x01[RP:] \x03[%s] 已练成葵花宝典.僵尸再也奈何不了你们了.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
				}
				StripAndChangeServerConVarInt("z_non_head_damage_factor_expert", -1);
				PrintToChatAll("\x01[RP:] \x03僵尸利用 [%s] 练成葵花宝典,大家自求多福吧.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 11: // 一直尸群事件
			{
				new String:command[] = "director_force_panic_event";
				if(GetConVarInt(FindConVar("director_panic_forever")) == 1)
				{
				StripAndChangeServerConVarInt("director_panic_forever", 0);
				PrintToChatAll("\x01[RP:] \x03因为[%s] 那张有创意的脸,僵尸们已经退散了,特此通告表扬.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
				}
				StripAndChangeServerConVarInt("director_panic_forever", 1);
				StripAndExecuteClientCommand(client, command, "","","");
				PrintToChatAll("\x01[RP:] \x03大家一起BS[%s]吧,他引发了无限尸群事件[%i]秒.\x03",name,GetConVarInt(sm_rp_mtime));
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				CreateTimer(GetConVarInt(sm_rp_mtime) * 1.0, wxjs, _, TIMER_FLAG_NO_MAPCHANGE);
				return;
			}
			case 12: // TANK
			{
				new String:command[] = "z_spawn";
				StripAndExecuteClientCommand(client, command, "tank","","");
				PrintToChatAll("\x01[RP:] \x03[%s] 在墙角画圈圈,结果一不小心把TANK召唤出来了.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 13: // Witch
			{
				new String:command[] = "z_spawn";
				StripAndExecuteClientCommand(client, command, "witch","","");
				PrintToChatAll("\x01[RP:] \x03[%s] 召唤了他的爱妃 Witch.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 14: // 召唤僵尸
			{
				new String:command[] = "director_force_panic_event";
				StripAndExecuteClientCommand(client, command, "","","");
				PrintToChatAll("\x01[RP:] \x03[%s] 这位帅哥,为大家引来了一群僵尸.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 15: // 发射
			{
				ServerCommand("sm_evilrocket \"%N\"",client);
				PrintToChatAll("\x01[RP:] \x03 骂熊猫包子的 [%s] 被放逐到外太空去了.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 16: // 隐身
			{
				if(GetConVarInt(FindConVar("nb_blind")) == 1)
				{
				StripAndChangeServerConVarInt("nb_blind", 0);
				PrintToChatAll("\x01[RP:] \x03[%s] 因为人品败坏,提前让[%i]秒群体隐身效果消失,大家一起BS他.\x03",name,GetConVarInt(sm_rp_ytime));
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
				}
				StripAndChangeServerConVarInt("nb_blind", 1);
				PrintToChatAll("\x01[RP:] \x03[%s] RP爆炸,激发超ob技能,群体隐身[%i]秒,该阶段不碰不攻击任何僵尸就不会被发现.\x03",name,GetConVarInt(sm_rp_ytime));
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				CreateTimer(GetConVarInt(sm_rp_ytime) * 1.0, qtys, _, TIMER_FLAG_NO_MAPCHANGE);
				return;
			}
			case 17: //给予燃烧炸弹
            {
				new String:command[] = "give";
				StripAndExecuteClientCommand(client, command, "molotov","","");
				PrintToChatAll("\x01[RP:] \x03[%s] 表扬ob,ob一个高兴就发了个燃烧炸弹给他.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
            }
			case 18: //给予氧气瓶
            {
				new String:command[] = "give";
				StripAndExecuteClientCommand(client, command, "oxygentank","","");
				PrintToChatAll("\x01[RP:] \x03[%s] 给我的这是啥,俺又不潜水.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
            }
			case 19: //给予煤气罐
            {
				new String:command[] = "give";
				StripAndExecuteClientCommand(client, command, "propanetank","","");
				PrintToChatAll("\x01[RP:] \x03[%s] 就快恨死ob了,什么不好给,给个煤气罐.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
            }
			case 20: //给予油桶
            {
				new String:command[] = "give";
				StripAndExecuteClientCommand(client, command, "gascan","","");
				PrintToChatAll("\x01[RP:] \x03[%s] 拿着这个油桶,想了又想,实在不知道该干吗.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
            }
			case 21: //给予药瓶
            {
				new String:command[] = "give";
				StripAndExecuteClientCommand(client, command, "pain_pills","","");
				PrintToChatAll("\x01[RP:] \x03[%s] 看着闪闪发光的药品,终于体会到ob的好了.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
            }
			case 22: //给予飞天权限
            {
        if(nocliptime == 1)
        {
        PrintToChatAll("\x01[RP:] \x03[%s] 正在远走高飞中,请等待降落.\x03",noclipname);
        bRPEnabled = false;
        SetConVarInt(FindConVar("sm_stat_cheats"),3);
        return;
        }
        GetClientName(client, noclipname, 32);
        ServerCommand("sm_noclip \"%s\"",name);
        PrintToChatAll("\x01[RP:] \x03[%s] 变成了上帝,大家仰天膜拜吧.\x03",name);
        nocliptime = 1;
        bRPEnabled = false;
        SetConVarInt(FindConVar("sm_stat_cheats"),3);
        rpnoclip();
        return;
            }
			case 23: // 无限子弹
			{
				if(GetConVarInt(FindConVar("sv_infinite_ammo")) == 1)
				{
				StripAndChangeServerConVarInt("sv_infinite_ammo", 0);
				PrintToChatAll("\x01[RP:] \x03无限子弹被 [%s] 提前结束了,全体BS他.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
				}
				StripAndChangeServerConVarInt("sv_infinite_ammo", 1);
				PrintToChatAll("\x01[RP:] \x03[%s] RP大爆炸,激发超ob技能,无限子弹[%i]秒,大家感激他吧.\x03",name,GetConVarInt(sm_rp_ztime));
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				CreateTimer(GetConVarInt(sm_rp_ztime) * 1.0, zidan, _, TIMER_FLAG_NO_MAPCHANGE);
				return;
			}
			case 24: // boomer
			{
				new String:command[] = "z_spawn";
				StripAndExecuteClientCommand(client, command, "boomer","","");
				PrintToChatAll("\x01[RP:] \x03Boomer跟随 [%s] 尾行而至.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 25: // ob表扬词
			{
				ServerCommand("sm_blind \"%N\" \"220\"",client);
				PrintToChatAll("\x01[RP:] \x03 因OB慈悲,虽说被[%s]骂,但是OB只是弄瞎了他一只眼睛还是马马虎虎能够看到一些.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 26: // 死亡召唤僵尸
			{
				if(IsClientInGame(client) && GetClientTeam(client) == 2 && !IsPlayerAlive(client) && GetConVarInt(sm_l8d_rpok) == 1)
				{
				new String:command[] = "director_force_panic_event";
				StripAndExecuteClientCommand(client, command, "","","");
				PrintToChatAll("\x01[RP:] \x03[%s] 因无人救他,对生还者表示仇视,引发尸群攻击.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
				}
				PrintToChatAll("\x01[RP:] \x03[%s] 当了一把泼妇,结果什么事情都没有发生.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 27: // 削弱小怪
			{
				if(GetConVarInt(FindConVar("z_health")) == 1)
				{
				StripAndChangeServerConVarInt("z_health", sm_z_life);
				PrintToChatAll("\x01[RP:] \x03削弱小怪被 [%s] 提前结束了,全体起立BS他.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
				}
				StripAndChangeServerConVarInt("z_health", 1);
				PrintToChatAll("\x01[RP:] \x03僵尸们对 [%s] 动了点怜悯之心,削弱小怪[%i]秒,大家感激他吧.\x03",name,GetConVarInt(sm_rp_xgtime));
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				CreateTimer(GetConVarInt(sm_rp_xgtime) * 1.0, xiaoguai, _, TIMER_FLAG_NO_MAPCHANGE);
				return;
			}
			case 28: // 增强小BOSS
			{
				if(bosstime == 1)
				{
				StripAndChangeServerConVarInt("z_witch_health", sm_witch_life);
				StripAndChangeServerConVarInt("z_gas_health", sm_smoker_life);
				StripAndChangeServerConVarInt("z_hunter_health", sm_hunter_life);
				StripAndChangeServerConVarInt("z_exploding_health", sm_boomer_life);
				bosstime = 0;
				PrintToChatAll("\x01[RP:] \x03特颁发 [%s] 好人卡,小BOSS强化效果被关闭,大家一起叩拜吧!\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
				}
				StripAndChangeServerConVarInt("z_witch_health", sm_witch_life*2);
				StripAndChangeServerConVarInt("z_gas_health", sm_smoker_life*2);
				StripAndChangeServerConVarInt("z_hunter_health", sm_hunter_life*2);
				StripAndChangeServerConVarInt("z_exploding_health", sm_boomer_life*2);
				PrintToChatAll("\x01[RP:] \x03[%s] 召唤恐怖地狱[%i]秒,除TANK外的小BOSS们防御增强一倍.\x03",name,GetConVarInt(sm_rp_bsime));
				bosstime = 1;
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				CreateTimer(GetConVarInt(sm_rp_bsime) * 1.0, kbboss, _, TIMER_FLAG_NO_MAPCHANGE);
				return;
			}
			case 29: // 无敌事件
			{
				if(GetConVarInt(FindConVar("god")) == 1)
				{
				StripAndChangeServerConVarInt("god", 0);
				new String:command[] = "god";
				StripAndExecuteClientCommand(client, command, "0","","");
				PrintToChatAll("\x01[RP:] \x03无敌门事件被 [%s] 提前结束了,全体起立BS他.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
				}
				StripAndChangeServerConVarInt("god", 1);
				CreateTimer(GetConVarInt(sm_rp_godtime) * 1.0, godok, client, TIMER_FLAG_NO_MAPCHANGE);
				PrintToChatAll("\x01[RP:] \x03服务器因 [%s] 发生无敌门事件[%i]秒,请尽快裸奔.\x03",name,GetConVarInt(sm_rp_godtime));
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 30: // 获得很多土制炸弹
			{
				new String:command[] = "give";
				StripAndExecuteClientCommand(client, command, "pipe_bomb","","");
				StripAndExecuteClientCommand(client, command, "pipe_bomb","","");
				StripAndExecuteClientCommand(client, command, "pipe_bomb","","");
				StripAndExecuteClientCommand(client, command, "pipe_bomb","","");
				StripAndExecuteClientCommand(client, command, "pipe_bomb","","");
				StripAndExecuteClientCommand(client, command, "pipe_bomb","","");
				StripAndExecuteClientCommand(client, command, "pipe_bomb","","");
				StripAndExecuteClientCommand(client, command, "pipe_bomb","","");
				PrintToChatAll("\x01[RP:] \x03[%s] 真能生,一次就生了8个土制炸弹.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 31: // 召唤灭团军队Hunter
			{
				new String:command[] = "z_spawn";
				StripAndExecuteClientCommand(client, command, "hunter","","");
				StripAndExecuteClientCommand(client, command, "hunter","","");
				StripAndExecuteClientCommand(client, command, "hunter","","");
				StripAndExecuteClientCommand(client, command, "hunter","","");
				StripAndExecuteClientCommand(client, command, "hunter","","");
				StripAndExecuteClientCommand(client, command, "hunter","","");
				StripAndExecuteClientCommand(client, command, "hunter","","");
				StripAndExecuteClientCommand(client, command, "hunter","","");                      //Hunter
				PrintToChatAll("\x01[RP:] \x03[%s] 也不知道惹恼了谁,召唤了一队灭团Hunter.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 32: // 当感染者
			{
				new String:command[] = "z_spawn";
				ChangeClientTeam(client, 3);
				StripAndExecuteClientCommand(client, command, "tank","","");
				PrintToChatAll("\x01[RP:] \x03[%s] 跳到了感染者当tank不过记住你只有30秒的时间,如人都可能只能当观看者了.[RP指令禁用30秒]\x03",name);
				CreateTimer(30.0, dangtank, client);
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 33: // 幸存者升级
			{
				if(GetConVarInt(upgrade_open) == 1)
				{
				PrintToChatAll("\x01[RP:] \x03[%s] RP真不错,抽到技能,即将随机获得.\x03",name);
				GiveClientUpgrades(client, 1);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
				}
				PrintToChatAll("\x01[RP:] \x03[%s] 触发RP事件,结果什么都没有发生.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 34: // 死亡光线
			{
				ServerCommand("sm_evilbeam \"%N\"",client);
				PrintToChatAll("\x01[RP:] \x03[%s] 获得了死亡光线,凡是更随着必死无疑.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 35: // 玩家加速
			{
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", GetConVarFloat(sm_cvar_speed));
				PrintToChatAll("\x01[RP:] \x03[%s] 从小劈腿,练就了了一身逃跑本领,跑的自然比TANK更快了.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 36: // 玩家重力
			{
				SetEntityGravity(client, GetConVarFloat(sm_cvar_weight));
				PrintToChatAll("\x01[RP:] \x03[%s] 从小挨飞刀,哪能跳不高,牛逼啊.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 37: // 变成透明的
			{
				SetEntityRenderMode(client, RenderMode:3);
				SetEntityRenderColor(client, 0, 0, 0, 0);
				PrintToChatAll("\x01[RP:] \x03[%s] 变成透明的了,大家小心不要误伤啊,这家伙爱乱串.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 38: // 变成TANK
			{
				SetEntityModel(client,"models/infected/hulk.mdl");                        //TANK
				PrintToChatAll("\x01[RP:] \x03[%s] 在墙角画圈圈,结果一不小心把TANK召唤出来了.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 39: // 变成红色
			{
				SetEntityRenderMode(client, RenderMode:3);
				SetEntityRenderColor(client, 255, 0, 0, 255);
				PrintToChatAll("\x01[RP:] \x03[%s] 变成红色的了,象征死亡天使(老是死亡的天使).\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 40: // 变成绿色
			{
				SetEntityRenderMode(client, RenderMode:3);
				SetEntityRenderColor(client, 0, 255, 0, 255);
				PrintToChatAll("\x01[RP:] \x03[%s] 营养不良,从小缺钙又缺爱,特办法绿色皮肤一套.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 41: // 变成蓝色
			{
				SetEntityRenderMode(client, RenderMode:3);
				SetEntityRenderColor(client, 0, 0, 255, 255);
				PrintToChatAll("\x01[RP:] \x03[%s] 是火星人,大家别管他的奇怪装扮,另外攻击他可以掉落RPG.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 42: // 变成蓝色
			{
				SetEntityRenderMode(client, RenderMode:3);
				SetEntityRenderColor(client, 255, 0, 0, 150);
				PrintToChatAll("\x01[RP:] \x03ob忍不住大叫,[%s]是个怪胎,哈哈,这个颜色真奇怪.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 43: // 灭团
			{
				if(IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) && GetConVarInt(sm_l8d_rpok) == 1)
				{
				GiveClientUpgrades(client, 15);
				ServerCommand("sm_beacon \"%N\"",client);
				PrintToChatAll("\x01[RP:] \x03[%s] 变成了VIP玩家(红色光环),请守护到安全门为止,如果该玩家死亡或者掉线或者空闲都会引发灭世之冻.\x03",name);
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.8);
				bVIP[client] = true;
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
				}
				PrintToChatAll("\x01[RP:] \x03[%s] 对天狂吼,无人理会,为什么我死在这个时候,否则我就成VIP了.\x03",name);
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 44: // 获得榴弹炮
			{
				powershot[client] = true;
				powershot_counts[client] = 0;
				PrintToChatAll("\x04[RP:] \x05[%s] 获得了榴弹炮\x04[%i]\x05发.",name,GetConVarInt(cvar_powershot_round));
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 45: // 获得榴弹炮
			{
				powershot[client] = true;
				powershot_counts[client] = 0;
				PrintToChatAll("\x04[RP:] \x05[%s] 获得了榴弹炮\x04[%i]\x05发.",name,GetConVarInt(cvar_powershot_round));
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 46: // 获得榴弹炮
			{
				powershot[client] = true;
				powershot_counts[client] = 0;
				PrintToChatAll("\x04[RP:] \x05[%s] 获得了榴弹炮\x04[%i]\x05发.",name,GetConVarInt(cvar_powershot_round));
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 47: // 获得轨道炮
			{
				tunder[client] = true;
				tunder_counts[client] = 0;
				PrintToChatAll("\x05[终极RP:] \x04[%s] 获得了轨道炮\x05[%i]\x04发.",name,GetConVarInt(cvar_tundertime));
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
			case 48: // 获得轨道炮
			{
				tunder[client] = true;
				tunder_counts[client] = 0;
				PrintToChatAll("\x05[终极RP:] \x04[%s] 获得了轨道炮\x05[%i]\x04发.",name,GetConVarInt(cvar_tundertime));
				bRPEnabled = false;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return;
			}
        }    
}

public Action:dangtank(Handle:timer,any:client)
{
// LogAction(0, -1, "DEBUG:dangtank 段落");
if(IsClientInGame(client))
{
ForcePlayerSuicide(client);
ChangeClientTeam(client, 1);
FakeClientCommand(client, "jointeam 2");
}
bRPEnabled = false;
PrintToChatAll("\x01[RP:] \x03[%s] 当TANK,30秒结束,RP指令还原.\x03",allname);
return Plugin_Handled;
}

public Action:godok(Handle:timer,any:client)
{
				// LogAction(0, -1, "DEBUG:godok 段落");
				SetConVarInt(FindConVar("sm_stat_cheats"), 2);
				if(GetConVarInt(FindConVar("god")) == 1)
				{
				StripAndChangeServerConVarInt("god", 0);
				new String:command[] = "god";
				StripAndExecuteClientCommand(client, command, "0","","");
				
				PrintToChatAll("\x01[RP:] \x03无敌门事件结束,请裸奔的赶快穿衣服.\x03");
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return Plugin_Handled;
				}
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return Plugin_Handled;
}
public Action:kbboss(Handle:timer)
{
				// LogAction(0, -1, "DEBUG:kbboss 段落");
				SetConVarInt(FindConVar("sm_stat_cheats"), 2);
				if(bosstime == 1)
				{
				StripAndChangeServerConVarInt("z_witch_health", sm_witch_life);
				StripAndChangeServerConVarInt("z_gas_health", sm_smoker_life);
				StripAndChangeServerConVarInt("z_hunter_health", sm_hunter_life);
				StripAndChangeServerConVarInt("z_exploding_health", sm_boomer_life);
				bosstime = 0;
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				PrintToChatAll("\x01[RP:] \x03无间地狱 [小BOSS强化效果%i秒结束!]\x03",GetConVarInt(sm_rp_bsime));
				return Plugin_Handled;
				}
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return Plugin_Handled;
}

public Action:xiaoguai(Handle:timer)
{
				// LogAction(0, -1, "DEBUG:xiaoguai 段落");
				SetConVarInt(FindConVar("sm_stat_cheats"), 2);
				if(GetConVarInt(FindConVar("z_health")) == 1)
				{
				StripAndChangeServerConVarInt("z_health", sm_z_life);
				PrintToChatAll("\x01[RP:] \x03削弱小怪 [%i] 秒 效果消失.\x03",GetConVarInt(sm_rp_xgtime));
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return Plugin_Handled;
				}
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return Plugin_Handled;
}

public Action:wxjs(Handle:timer)
{
				// LogAction(0, -1, "DEBUG:wxjs 段落");
				SetConVarInt(FindConVar("sm_stat_cheats"), 2);
				if(GetConVarInt(FindConVar("director_panic_forever")) == 1)
				{
				StripAndChangeServerConVarInt("director_panic_forever", 0);
				PrintToChatAll("\x01[RP:] \x03[%i] 秒 无限尸群效果消失.\x03",GetConVarInt(sm_rp_mtime));
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return Plugin_Handled;
				}
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return Plugin_Handled;
}

public Action:qtys(Handle:timer)
{
				// LogAction(0, -1, "DEBUG:qtys 段落");
				SetConVarInt(FindConVar("sm_stat_cheats"), 2);
				if(GetConVarInt(FindConVar("nb_blind")) == 1)
				{
				StripAndChangeServerConVarInt("nb_blind", 0);
				PrintToChatAll("\x01[RP:] \x03群体隐身[%i]秒效果消失,别乱晃了.\x03",GetConVarInt(sm_rp_ytime));
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return Plugin_Handled;
				}
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return Plugin_Handled;
}

public Action:zidan(Handle:timer)
{
				// LogAction(0, -1, "DEBUG:zidan 段落");
				SetConVarInt(FindConVar("sm_stat_cheats"), 2);
				if(GetConVarInt(FindConVar("sv_infinite_ammo")) == 1)
				{
				StripAndChangeServerConVarInt("sv_infinite_ammo", 0);
				PrintToChatAll("\x01[RP:] \x03[%i] 秒 无限子弹效果消失.\x03",GetConVarInt(sm_rp_ztime));
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return Plugin_Handled;
				}
				SetConVarInt(FindConVar("sm_stat_cheats"),3);
				return Plugin_Handled;
}

public Action:vip(client, args)
{
	if (client > 0 && IsClientInGame(client) && GetClientTeam(client) > 1 && IsPlayerAlive(client))
	{
	GiveClientUpgrades(client, 15);
	bVIP[client] = true;
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.8);
	ServerCommand("sm_beacon \"%N\"",client);
	PrintToChatAll("\x01[RP:] \x03[%N] 变成了VIP玩家(红色光环),请守护到安全门为止,如果该玩家死亡或者掉线或者空闲都会引发灭世之冻.\x03",client);
	PrintToChatAll("\x01[RP:] \x03[%N] 变成了VIP玩家(红色光环),请守护到安全门为止,如果该玩家死亡或者掉线或者空闲都会引发灭世之冻.\x03",client);
	PrintToChatAll("\x01[RP:] \x03[%N] 变成了VIP玩家(红色光环),请守护到安全门为止,如果该玩家死亡或者掉线或者空闲都会引发灭世之冻.\x03",client);
	return Plugin_Continue;
	}
	PrintToChat(client,"\x01[SM] 该指令需要在幸存的状态下输入才有效.\x03");
	return Plugin_Continue;
}

public OnClientConnected(client)
{
    decl String:SteamID[MAX_LINE_WIDTH];
    GetClientName(client, SteamID, sizeof(SteamID));
    
    /*
    if (strlen(SteamID) == 0 || strlen(SteamID) <= 2 || strlen(SteamID) >= 30)
    {
    KickClient(client, "请不要使用了 * 空名 | 字符小于等于2字节 | 字符最大不能超过29字节 | * 作为游戏账号! [QQ群:37624488]");
    return;
    }
    */
    
    if(!SteamID[0])
    {
    KickClient(client, "请不要使用了 * 空名 * 作为游戏账号! [QQ群:37624488]");
    return;
    }
    

    ReplaceString(SteamID, sizeof(SteamID), " ", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "　", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "<?php", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "<?PHP", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "?>", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "\\", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "\"", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "'", "Block");
    ReplaceString(SteamID, sizeof(SteamID), ";", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "?", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "`", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "屎", "Block");
	
    if( StrContains(SteamID, "Block", false)!= -1)
    {
    KickClient(client, "请不要使用包含了 * 空格 | Block | * 的名字当做游戏账号,部分字符也禁止使用,具体请到QQ群:37624488 咨询!");
    return;
    }
    
    bOpenrp[client] = false;
    bVIP[client] = false;
    caipiaojuan[client] = true;	
}

public GiveClientUpgrades(client, numUpgrades)
{	
	if(!IsClientInGame(client)) return;
	if(GetClientTeam(client) != 2) return;
	
	decl String:name[64];
	GetClientName(client, name, 64);
	for(new num=0; num<numUpgrades; ++num)
	{
		new numOwned = GetNumUpgrades(client);
		if(numOwned == NVALID)
		{
			if(GetConVarInt(Verbosity)>1)
			{
				PrintToChatAll("\x04%s\x01 已经获得全部技能无法继续获得.", name);
			}
			return;
		}
		new offset = GetRandomInt(0,NVALID-(numOwned+1));
		new val = 0;
		while(offset > 0 || bClientHasUpgrade[client][val] || GetConVarInt(UpgradeAllowed[val])!=1)
		{
			if((!bClientHasUpgrade[client][val]) && GetConVarInt(UpgradeAllowed[val])==1)
			{
				offset = offset - 1;
			}
			val = val + 1;
		}
		GiveClientSpecificUpgrade(client, val);
	}
}

public GiveClientSpecificUpgrade(any:client, upgrade)
{
	// LogAction(0, -1, "DEBUG:GiveClientSpecifiuUpgrade 段落");
	decl String:name[64];
	GetClientName(client, name, 64);
	new VerbosityVal = GetConVarInt(Verbosity);
	if(VerbosityVal > 2)
	{
		PrintToChatAll("\x04%s\x01 获得 %s\x01.", name, UpgradeShortInfo[upgrade]);
		PrintToChat(client, "%s", UpgradeLongInfo[upgrade]);
	}
	else if (VerbosityVal > 1)
	{
		PrintToChat(client, "\x04%s\x01 获得 %s\x01.", name, UpgradeShortInfo[upgrade]);
	}
	SDKCall(AddUpgrade, client, IndexToUpgrade[upgrade]);
	// We're just doing this for the sound effect, remove it immediately...
	if(IndexToUpgrade[upgrade] == 30)
	{
		SDKCall(RemoveUpgrade, client, IndexToUpgrade[upgrade]);
	}
	bClientHasUpgrade[client][upgrade]=true;
}

public TakeClientSpecificUpgrade(any:client, upgrade)
{
	// LogAction(0, -1, "DEBUG:TakeClientSpecificUpgrade 段落");
	SDKCall(RemoveUpgrade, client, IndexToUpgrade[upgrade]);
	bClientHasUpgrade[client][upgrade]=false;
}

public GetNumUpgrades(client)
{
	// LogAction(0, -1, "DEBUG:GetNumUpgrades 段落");
	new num = 0;
	for(new i = 0; i < NVALID; ++i)
	{
		if(bClientHasUpgrade[client][i] || GetConVarInt(UpgradeAllowed[i])!=1)
		{
			++num;
		}
	}
	return num;
}

public Action:addUpgrade(client, args)
{
	// LogAction(0, -1, "DEBUG:addupgrade 段落");
	if(GetCmdArgs() < 1)
	{
		ReplyToCommand(client, "用法: !addUpgrade [技能id] <user id | name> <user id | name> ...");
		return Plugin_Handled;
	}
	decl targetList[MAXPLAYERS];
	new targetCount = 1;
	targetList[0] = client;
	if(GetCmdArgs() > 1)
	{
		targetCount = 0;
		for(new i = 2; i<=GetCmdArgs(); ++i)
		{
			decl String:arg[65];
			GetCmdArg(i, arg, sizeof(arg));
			
			decl String:subTargetName[MAX_TARGET_LENGTH];
			decl subTargetList[MAXPLAYERS], subTargetCount, bool:tn_is_ml;
			
			subTargetCount = ProcessTargetString(arg, client, subTargetList, MAXPLAYERS, COMMAND_FILTER_ALIVE,
				subTargetName, sizeof(subTargetName), tn_is_ml);

			for(new j = 0; j < subTargetCount; ++j)
			{
				new bool:bAdd = true;
				for(new k = 0; k < targetCount; ++k)
				{
					if(targetList[k] == subTargetList[j])
					{
						bAdd = false;
					}
				}
				if(bAdd)
				{
					targetList[targetCount] = subTargetList[j];
					++targetCount;
				}
			}
		}
	}
	if(targetCount == 0)
	{
		ReplyToCommand(client, "该玩家不存在,请重新输入.");
		return Plugin_Handled;
	}
	
	decl String:arg[3];
	GetCmdArg(1, arg, sizeof(arg));
	new upgrade = StringToInt(arg)-1;
	if(upgrade<0 || upgrade >= NVALID)
	{
		ReplyToCommand(client, "错误的技能编码.有效值为 1 to %d.", NVALID);
		return Plugin_Handled;
	}
	
	for(new i = 0; i < targetCount; ++i)
	{
		GiveClientSpecificUpgrade(targetList[i], upgrade);
	}
	return Plugin_Handled;		
}

public Action:giveRandomUpgrades(client, args)
{
	// LogAction(0, -1, "DEBUG:GiveRandomUpgrade 段落");
	if(GetCmdArgs() < 1)
	{
		ReplyToCommand(client, "用法: !giverandom [15以内有效数值] <user id | name> <user id | name> ...");
		return Plugin_Handled;
	}
	decl targetList[MAXPLAYERS];
	new targetCount = 1;
	targetList[0] = client;
	if(GetCmdArgs() > 1)
	{
		targetCount = 0;
		for(new i = 2; i<=GetCmdArgs(); ++i)
		{
			decl String:arg[65];
			GetCmdArg(i, arg, sizeof(arg));
			
			decl String:subTargetName[MAX_TARGET_LENGTH];
			decl subTargetList[MAXPLAYERS], subTargetCount, bool:tn_is_ml;
			
			subTargetCount = ProcessTargetString(arg, client, subTargetList, MAXPLAYERS, COMMAND_FILTER_ALIVE,
				subTargetName, sizeof(subTargetName), tn_is_ml);
			
			for(new j = 0; j < subTargetCount; ++j)
			{
				new bool:bAdd = true;
				for(new k = 0; k < targetCount; ++k)
				{
					if(targetList[k] == subTargetList[j])
					{
						bAdd = false;
					}
				}
				if(bAdd)
				{
					targetList[targetCount] = subTargetList[j];
					++targetCount;
				}
			}
		}
	}
	if(targetCount == 0)
	{
		ReplyToCommand(client, "目标不在线,请重新输入.");
		return Plugin_Handled;
	}
	
	decl String:arg[3];
	GetCmdArg(1, arg, sizeof(arg));
	new upgrade = StringToInt(arg);
	
	for(new i = 0; i < targetCount; ++i)
	{
		GiveClientUpgrades(targetList[i], upgrade);
	}
	return Plugin_Handled;		
}

public Action:removeUpgrade(client, args)
{
	// LogAction(0, -1, "DEBUG:removeUpgrade 段落");
	if(GetCmdArgs() < 1)
	{
		ReplyToCommand(client, "用法: !removeUpgrade [技能 id] <user id | name> <user id | name> ...");
		return Plugin_Handled;
	}
	decl targetList[MAXPLAYERS];
	new targetCount = 1;
	targetList[0] = client;
	if(GetCmdArgs() > 1)
	{
		targetCount = 0;
		for(new i = 2; i<=GetCmdArgs(); ++i)
		{
			decl String:arg[65];
			GetCmdArg(i, arg, sizeof(arg));
			
			decl String:subTargetName[MAX_TARGET_LENGTH];
			decl subTargetList[MAXPLAYERS], subTargetCount, bool:tn_is_ml;
			
			subTargetCount = ProcessTargetString(arg, client, subTargetList, MAXPLAYERS, COMMAND_FILTER_ALIVE,
				subTargetName, sizeof(subTargetName), tn_is_ml);
			
			for(new j = 0; j < subTargetCount; ++j)
			{
				new bool:bAdd = true;
				for(new k = 0; k < targetCount; ++k)
				{
					if(targetList[k] == subTargetList[j])
					{
						bAdd = false;
					}
				}
				if(bAdd)
				{
					targetList[targetCount] = subTargetList[j];
					++targetCount;
				}
			}
		}
	}
	if(targetCount == 0)
	{
		ReplyToCommand(client, "目标不在线,请重新输入.");
		return Plugin_Handled;
	}
	
	decl String:arg[3];
	GetCmdArg(1, arg, sizeof(arg));
	new upgrade = StringToInt(arg)-1;
	if(upgrade<0 || upgrade >= NVALID)
	{
		ReplyToCommand(client, "技能编码错误.有效值为 1 to %d.", NVALID);
		return Plugin_Handled;
	}
	
	for(new i = 0; i < targetCount; ++i)
	{
		TakeClientSpecificUpgrade(targetList[i], upgrade);
	}
	return Plugin_Handled;
}

public Action:LaserOn(client, args)
{
	if(GetConVarInt(AlwaysLaser) != 1)
	{
		return;
	}
	SDKCall(AddUpgrade, client, 17);
	bClientHasUpgrade[client][6] = true;
}

public Action:LaserOff(client, args)
{
	if(GetConVarInt(AlwaysLaser) != 1)
	{
		return;
	}
	SDKCall(RemoveUpgrade, client, 17);
	bClientHasUpgrade[client][6] = false;
}

public Action:LaserToggle(client, args)
{
	if(GetConVarInt(AlwaysLaser) != 1)
	{
		return;
	}
	if (bClientHasUpgrade[client][6])
	{
		LaserOff(client, 0);
	}
	else
	{
		LaserOn(client, 0);
	}
}

// 升级插件代码结束


public GetAnyClient()
{
	for(new i=1; i<GetMaxClients(); i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i) && (!IsFakeClient(i)) && GetClientTeam(i) == 2)
		{
			return i;
		}
	}
	return 0;
}

public Action:Event_TankKilled(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(GetConVarInt(upgrade_open) == 1 && GetConVarInt(sm_upgrade_tank) != 0 && DREnabled)
	{
	for(new i=1; i<GetMaxClients(); i++)
	{
	if(!IsClientInGame(i)) continue;
	if(GetClientTeam(i) != 2) continue;
	GiveClientUpgrades(i, GetConVarInt(sm_upgrade_tank));
	}
	PrintToChatAll("\x03TANK 被消灭\x03 全队获得[%i]随机技能.",GetConVarInt(sm_upgrade_tank));
	}
}

public Action:Event_Tank_Spawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	DREnabled = true;
}

public Action:Event_PlayerName(Handle:event, const String:name[], bool:dontBroadcast)
{
new iClient = GetClientOfUserId(GetEventInt(event, "userid"));

password[iClient] = false;
okpassword[iClient] = false;

KickClient(iClient, "进入游戏后请勿改名字,否则踢出!");
return Plugin_Handled;
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	GetCheckPointDoorIds();
	DREnabled = false;
	bIsNuking = false;
	
	for(new i=1; i<=MaxClients; ++i)
	{
	bVIP[i] = false;
	haswepon[i] = false;
	inVoteTimeout[i]=false;
	powershotTimeout[i]=false;
	/* 暂时取消重新开局收回特殊技能
	powershot[i]=false;
	tunder[i]=false;
	*/
	}
	
	CreateTimer(60.0, UpdateCounts);
}

public Action:UpdateCounts(Handle:timer)
{
		
		for (new i = 1; i <= 32; i++)
		{
            okpassword[i] = false;
		}
}

public Action:timecheck1(Handle:timer,any:client)
{
    if(client <= 0)
    return;
    	
    if (!IsClientConnected(client) && !IsClientInGame(client))
    return;

    if (IsClientBot(client))
    return;

    new String:Wind[MAX_LINE_WIDTH];
    GetClientInfo(client, "wind", Wind, sizeof(Wind));
    
    if (strlen(spassword[client]) < 1)
    {
    password[client] = true;
    PrintToChatAll("\x04[Status:] \x02 非VIP玩家[%N]进入服务器,按Y输入 \x05!pwd 密码\x03 即可注册为vip玩家,不过切记要看提示否则下次进不来.\x03",client);
    new String:URL[MAX_LINE_WIDTH];
    GetConVarString(cvar_NewBiesSiteURL, URL, sizeof(URL));
    ShowMOTDPanel(client,"友情提示[务必看完,否则你将会迷失在旁观者团队]:",URL,MOTDPANEL_TYPE_URL);
    //CreateTimer(20.0, MOTDHELP, client);
    return;
    }
  
    if(spassword[client] == Wind[0])
    {
    password[client] = true;
    PrintToChatAll("\x04[Status:] \x03 VIP玩家 \x05[%N] \x03进入服务器.\x03",client);
    // LogAction(0,-1,"验证成功的:用户名 [%N]  用户SQL密码 [%s] 用户setinfo密码 [%s]",client,spassword[client],Wind[0]);
    return;
    }
    PrintToChatAll("\x04[Status:] \x05 [%N] \x03 用户验证失败,已被T出服务器.\x03",client);
    LogAction(0,-1,"失败的:用户名 [%N]  用户SQL密码 [%s] 用户setinfo密码 [%s]",client,spassword[client],Wind[0]);
    KickClient(client, "该名字为密码玩家名字,请在控制台输入 setinfo wind 你的密码 回车后再登陆 [遗忘密码请群里37624488申请] 或者 修改游戏名字即可进入");
    return;
}

public Action:MOTDHELP(Handle:timer,any:client)
{
		new String:URL[MAX_LINE_WIDTH];
		GetConVarString(cvar_NewBiesSiteURL, URL, sizeof(URL));
		ShowMOTDPanel(client,"友情提示[务必看完,否则你将会迷失在旁观者团队]:",URL,MOTDPANEL_TYPE_URL);
		return Plugin_Handled;
}

public Action:changepw(client, args)
{
	
	if (StatsDisabled()) return;
	
	if(password[client] == false)
	{
	ReplyToCommand(client, "\x01[SM] 你的原始密码输入有误,所以无法设置密码!\x03");
	return;
	}
	
	if (args < 1)
	{
	ReplyToCommand(client, "[SM] 用法: !pwd 密码 如果你不想别人看到你设置的密码你可以 在控制台输入 sm_pwd 密码 是同样的效果");
	return;
	}
	
	decl String:arg[65];
	GetCmdArg(1, arg, sizeof(arg));
	
	decl String:SteamID[MAX_LINE_WIDTH];
	
	GetClientName(client, SteamID, sizeof(SteamID));
	ReplaceString(SteamID, sizeof(SteamID), "l4d.sy64.com", "Block");
	ReplaceString(SteamID, sizeof(SteamID), "Noob-Emu", "Block");
	ReplaceString(SteamID, sizeof(SteamID), "REVOLUTiON", "Block");
	
	if( StrContains(SteamID, "Block", false)!= -1)
	{
	PrintToChat(client,"\x05[SM:] 密码设置\x04失败\x05,该账号为公用账号禁止设置密码.!");
	return;
	}
	
	// CheckPlayerDB(client);
	// SQL_TQuery(db, GetRankTotal, "SELECT COUNT(*) FROM players", client);
	decl String:query[1024];
	Format(query, sizeof(query), "UPDATE players SET password = '%s' WHERE steamid = '%s'", arg, SteamID);
	SendSQLUpdate(query);
	
	PrintToChat(client,"\x01[SM:] 密码设置成功,下次登陆游戏的时候,请先在控制台输入 该指令 再登陆游戏 setinfo wind %s",arg);
	password[client] = false;
	
} 

public Action:buy(client, args) 
{
	if (StatsDisabled()) return;
	
	if(client <= 0)
	{
		ReplyToCommand(client, "\x01[SM] 请在游戏中输入方可!");
		return;
	}
	
	if (!IsClientConnected(client) && !IsClientInGame(client))
	return;

	if (IsClientBot(client))
	return;
	
	if(GetConVarInt(stat_enable) == 0)
	{
		ReplyToCommand(client, "\x01[SM] 并未开启购买系统!");
		return;
	}
	
	if(GetConVarInt(stat_cheat) == 0)
	{
		ReplyToCommand(client, "\x01[SM] 由于管理员关闭了与LXD通讯作弊系统,所以无法使用!buy系统!");
		return;
	}
	
	if (strlen(spassword[client]) < 1)
	{
	PrintToChat(client, "\x04[SM] \x01 非注册玩家无法购买,输入!pwd 密码 注册,但是请牢记提示信息.");
	return;
	}
	
	decl String:SteamID[MAX_LINE_WIDTH];
	
	GetClientName(client, SteamID, sizeof(SteamID));

	decl String:query[256];
	Format(query, sizeof(query), "SELECT points FROM players WHERE steamid = '%s'", SteamID);
	SQL_TQuery(db, GetClientPoints, query, client);
	
	if (isInVoteTimeout(client))
	{
	PrintToChat(client, "\x04[SM] \x01你必须要等待 %.1f 秒才可以再次购买.",GetConVarFloat(buyTimeout));
	return;		
	}
	
	rankbuyTimeout[client]=true;
	new Float:timeout = GetConVarFloat(buyTimeout);
	if (timeout > 0.0)
	{
	CreateTimer(timeout, TimeOutOver, client);
	}
	
	
	fbuymenu(client, args);
}

public Action:fbuymenu(client, args) 
{
		new Handle:menu = CreateMenu(Rankcase);
		
		new String:menuname[512];
		
		SetMenuTitle(menu, "请选择你要执行的操作,输入!RANK查看积分");
		AddMenuItem(menu, "option1", "按键无效帮助说明");
		
		if (GetClientTeam(client) != 2 )
		{
		AddMenuItem(menu, "option2", "赌博积分-小赌怡情 内详");
		Format(menuname, sizeof(menuname), "转换团队到感染者 需 %i 积分", GetConVarInt(cvar_changteamprc));
		AddMenuItem(menu, "option3", menuname);
		AddMenuItem(menu, "option4", "召唤喽啰来捣乱");
		}
		else
		{
		Format(menuname, sizeof(menuname), "随机购买技能 需 %i 积分", GetConVarInt(cvar_buyjn));
		AddMenuItem(menu, "option2", menuname);
		Format(menuname, sizeof(menuname), "快捷补血 倒地玩家可站起 需 %i 积分", GetConVarInt(cvar_buylife));
		AddMenuItem(menu, "option3", menuname);
		AddMenuItem(menu, "option4", "赌博积分-小赌怡情 内详");
		AddMenuItem(menu, "option5", "选择购买装备 一次性");
		Format(menuname, sizeof(menuname), "购买彩票卷 需 %i 积分", GetConVarInt(cvar_buyrp));
		AddMenuItem(menu, "option6", menuname);
		if ( GetConVarInt(cvar_usetime) > 60 )
		 {
		Format(menuname, sizeof(menuname), "选择购买 VIP 装备 有效期 %.2f 小时", FloatDiv(float(GetConVarInt(cvar_usetime)), 60.0));
		 }
		else
		 {
		Format(menuname, sizeof(menuname), "选择购买 VIP 装备 有效期 %i 分钟", GetConVarInt(cvar_usetime));
		 }
		AddMenuItem(menu, "option7", menuname);
		Format(menuname, sizeof(menuname), "购买解毒剂 需 %i 积分", GetConVarInt(cvar_buyjd));
		AddMenuItem(menu, "option8", menuname);
		AddMenuItem(menu, "option9", "召唤喽啰来捣乱");
		AddMenuItem(menu, "option10", "购买对抗感染者的特殊技能");
		}
		
		
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
		return Plugin_Handled;
}



public Action:callboss(client, args) 
{
		new Handle:menu = CreateMenu(RankBuyBoss);
		
		new String:menuname[512];
		
		SetMenuTitle(menu, "除 大力神 外的召唤都是召唤到鼠标所指出!!");
		Format(menuname, sizeof(menuname), "购买人类需要 %i 积分", GetConVarInt(cvar_call_add));
		AddMenuItem(menu, "option1", menuname);
		Format(menuname, sizeof(menuname), "购买喽啰需要 %i 积分", GetConVarInt(cvar_call_addevent));
		AddMenuItem(menu, "option2", menuname);
		Format(menuname, sizeof(menuname), "购买猴怪需要 %i 积分", GetConVarInt(cvar_call_hunter));
		AddMenuItem(menu, "option3", menuname);
		Format(menuname, sizeof(menuname), "购买猪怪需要 %i 积分", GetConVarInt(cvar_call_boomer));
		AddMenuItem(menu, "option4", menuname);
		Format(menuname, sizeof(menuname), "购买蜥蜴怪需要 %i 积分", GetConVarInt(cvar_call_smoker));
		AddMenuItem(menu, "option5", menuname);
		Format(menuname, sizeof(menuname), "购买狐狸精需要 %i 积分", GetConVarInt(cvar_call_witch));
		AddMenuItem(menu, "option6", menuname);
		Format(menuname, sizeof(menuname), "购买大力神需要 %i 积分", GetConVarInt(cvar_call_tank));
		AddMenuItem(menu, "option7", menuname);
		
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
		return Plugin_Handled;
}

public RankBuyBoss(Handle:menu, MenuAction:action, client, itemNum)
{
		
    decl String:SteamID[MAX_LINE_WIDTH];
    
    if(client <= 0)
    {
    return;
    }
    
    if (!IsClientConnected(client) && !IsClientInGame(client))
    return;

    if (IsClientBot(client))
    return;
    
    GetClientName(client, SteamID, sizeof(SteamID));
    
    SetConVarInt(FindConVar("sm_stat_cheats"), 3);
    
    if ( action == MenuAction_Select ) {
        
        switch (itemNum)
        {
            case 0: // 小僵尸
            {
                new Score = GetConVarInt(cvar_call_add);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_call_add))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的怪物需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_call_add));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_call_add) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'",Score,SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x05恭喜您购买成功,当前剩余积分[%i],干坏事是缺德的!",ClientPoints[client]-GetConVarInt(cvar_call_add));
                PrintToChatAll("\x04[神技:]\x05 小心\x03[%N]\x05花费了\x03%i\x05大洋买通了一个小僵尸来暗算大家",client,GetConVarInt(cvar_call_add));             
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                new String:command[] = "z_spawn";
                StripAndExecuteClientCommand(client, command, "","","");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                }
            }
            case 1: //尸群
            {
                new Score = GetConVarInt(cvar_call_addevent);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_call_addevent))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],购买尸群需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_call_addevent));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_call_addevent) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'",Score,SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x05恭喜您购买成功,当前剩余积分[%i],干坏事是缺德的!",ClientPoints[client]-GetConVarInt(cvar_call_addevent));
                PrintToChatAll("\x04[神技:]\x05 小心\x03[%N]\x05送了\x03%i\x05大洋并加上色迷迷的眼神成功的串通了一群小僵尸来对付你们.",client,GetConVarInt(cvar_call_addevent));
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                new String:command[] = "director_force_panic_event";
                StripAndExecuteClientCommand(client, command, "","","");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                }
            }
            case 2: //hunter
            {
                new Score = GetConVarInt(cvar_call_hunter);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_call_hunter))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],召唤感染者需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_call_hunter));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_call_hunter) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'",Score,SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x05恭喜您购买成功,当前剩余积分[%i],干坏事是缺德的!",ClientPoints[client]-GetConVarInt(cvar_call_hunter));
                PrintToChatAll("\x04[神技:]\x05 小心\x03[%N]\x05花费了\x03%i\x05巨资,召唤了他的爱宠-HUNTER.",client,GetConVarInt(cvar_call_hunter));
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                new String:command[] = "z_spawn";
                StripAndExecuteClientCommand(client, command, "hunter","","");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                }
            }
            case 3: //boomer
            {
                new Score = GetConVarInt(cvar_call_boomer);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_call_boomer))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],召唤感染者需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_call_boomer));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_call_boomer) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'",Score,SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x05恭喜您购买成功,当前剩余积分[%i],干坏事是缺德的!",ClientPoints[client]-GetConVarInt(cvar_call_boomer));
                PrintToChatAll("\x04[神技:]\x05 小心\x03[%N]\x05花费了\x03%i\x05巨资,召唤了他的爱宠-Boomer.",client,GetConVarInt(cvar_call_boomer));
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                new String:command[] = "z_spawn";
                StripAndExecuteClientCommand(client, command, "boomer","","");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                }
            }
            case 4: //smoker
            {
                new Score = GetConVarInt(cvar_call_smoker);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_call_smoker))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],召唤感染者需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_call_smoker));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_call_smoker) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'",Score,SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x05恭喜您购买成功,当前剩余积分[%i],干坏事是缺德的!",ClientPoints[client]-GetConVarInt(cvar_call_smoker));
                PrintToChatAll("\x04[神技:]\x05 小心\x03[%N]\x05花费了\x03%i\x05巨资,召唤了他的爱宠-Smoker.",client,GetConVarInt(cvar_call_smoker));
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                new String:command[] = "z_spawn";
                StripAndExecuteClientCommand(client, command, "smoker","","");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                }
            }
            case 5: //witch
            {
                new Score = GetConVarInt(cvar_call_witch);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_call_witch))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],召唤感染者需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_call_witch));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_call_witch) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'",Score,SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x05恭喜您购买成功,当前剩余积分[%i],干坏事是缺德的!",ClientPoints[client]-GetConVarInt(cvar_call_witch));
                PrintToChatAll("\x04[神技:]\x05 小心\x03[%N]\x05花费了\x03%i\x05巨资勾引到了WITCH女王.",client,GetConVarInt(cvar_call_witch));
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                new String:command[] = "z_spawn";
                StripAndExecuteClientCommand(client, command, "witch","","");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                }
            }
            case 6: //tank
            {
                new Score = GetConVarInt(cvar_call_tank);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_call_tank))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],召唤感染者需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_call_tank));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_call_tank) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'",Score,SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x04恭喜您购买成功,当前剩余积分[%i],干坏事是缺德的!",ClientPoints[client]-GetConVarInt(cvar_call_tank));
                PrintToChatAll("\x04[神技:]\x05 小心\x03[%N]\x05花费了\x03%i\x05巨资引的我们的明星-坦克先生登台献艺.",client,GetConVarInt(cvar_call_tank));
                new anyclient = GetAnyClient();
                if (anyclient == 0) return;	
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                new String:command[] = "z_spawn";
                StripAndExecuteClientCommand(anyclient, command, "tank","","");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                }
            }
 
        }
    }
    SetConVarInt(FindConVar("sm_stat_cheats"), 3);
}

public Action:changetheteam(client, args)
{
    decl String:SteamID[MAX_LINE_WIDTH];
    
    if(client <= 0)
    {
    return;
    }
    
    if (!IsClientConnected(client) && !IsClientInGame(client))
    return;

    if (IsClientBot(client))
    return;
    
    GetClientName(client, SteamID, sizeof(SteamID));
    
    new Score = GetConVarInt(cvar_changteamprc);
    Score = Score * -1;
    
    if(ClientPoints[client] <= GetConVarInt(cvar_changteamprc))
    {
    PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_changteamprc));
    }
    else if(ClientPoints[client] > GetConVarInt(cvar_changteamprc) && ClientPoints[client] > 0)
    {
    decl String:query[1024];
    Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score, SteamID);
    SendSQLUpdate(query);
    UpdateMapStat("points", Score);
    
    PrintToChat(client,"\x04购买跳转到感染者技成功,当前剩余积分[%i]",ClientPoints[client]-GetConVarInt(cvar_changteamprc));
    
    PrintToChatAll("\x01[神技:] \x03 邪恶的\x04[%N]\x03 购买了跳转技,花费了\x05%i\x03积分,通过召唤喽啰召唤的感染者部分会受他控制!",client,GetConVarInt(cvar_changteamprc));
    PrintToChatAll("\x01[神技:] \x03 邪恶的\x04[%N]\x03 购买了跳转技,花费了\x05%i\x03积分,通过召唤喽啰召唤的感染者部分会受他控制!",client,GetConVarInt(cvar_changteamprc));
    
    ChangeClientTeam(client, 3);
    
    }
}

AliveInfected() //获得游戏内的非BOT幸存者玩家数量
{
	new numInfected;
	for(new i=1; i <= MaxClients; i++)
	{
		if(IsClientConnected(i) && IsClientInGame(i) && GetClientTeam(i) == 3 && !IsFakeClient(i)) 
			numInfected++;
	}
	
	return numInfected;
}

public Rankcase(Handle:menu, MenuAction:action, client, itemNum)
{
   if ( action == MenuAction_Select ) 
	{
	if (GetClientTeam(client) != 2 )
	{
       switch (itemNum)
        {
            case 0: // 帮助说明
            {
            PrintToChat(client,"\x01[SM] Wind 已帮你绑定按键,现在你可以使用 5 6 7 8 9 0 这几个键了.");
            ClientCommand(client,"bind 5 slot5");
            ClientCommand(client,"bind 6 slot6");
            ClientCommand(client,"bind 7 slot7");
            ClientCommand(client,"bind 8 slot8");
            ClientCommand(client,"bind 9 slot9");
            ClientCommand(client,"bind 0 slot10");
            }
            case 1: // 赌博
            {
            buydb(client, 0);
            }
            case 2: // 跳到感染者
            {
            if(AliveInfected() >= GetConVarFloat(cvar_numchange))
            {
            PrintToChat(client,"\x05[错误:]\x04购买跳转到感染者技失败,感染者团队玩家数量不得超过%i名.",GetConVarInt(cvar_numchange));
            return;
            }
            changetheteam(client, 0);
            }
            case 3: // 召唤喽啰
            {
            callboss(client, 0);
            }
        }
	}
	else
	{
        switch (itemNum)
        {
            case 0: // 帮助说明
            {
            PrintToChat(client,"\x01[SM] Wind 已帮你绑定按键,现在你可以使用 5 6 7 8 9 0 这几个键了.");
            ClientCommand(client,"bind 5 slot5");
            ClientCommand(client,"bind 6 slot6");
            ClientCommand(client,"bind 7 slot7");
            ClientCommand(client,"bind 8 slot8");
            ClientCommand(client,"bind 9 slot9");
            ClientCommand(client,"bind 0 slot10");
            }
            case 1: // 购买技能
            {
            buyjineng(client, 0);
            }
            case 2: // 快捷补血
            {
            buylife(client, 0);
            }
            case 3: // 赌博积分
            {
            buydb(client, 0);
            }
            case 4: // 购买装备
            {
            buymenu(client, 0);
            }
            case 5: // VIP购买
            {
            buycaipiao(client, 0);
            }
            case 6: // 彩票系统指令
            {
            vipbuy(client, 0);
            }
            case 7: // 购买解毒剂
            {
            buyjdj(client, 0);
            }
            case 8: // 召唤喽啰来帮忙
            {
            callboss(client, 0);
            }
            case 9: // 购买特殊技能
            {
            buytunder(client, 0);
            }
        }
    }
	}
}

public Action:buytunder(client, args) 
{
		new Handle:menu = CreateMenu(RankBuytunder);
		new String:menuname[512];
		Format(menuname, sizeof(menuname), "轨道炮每次购买后能使用 %i 次", GetConVarInt(cvar_tundertime));
		
		SetMenuTitle(menu, menuname);
		Format(menuname, sizeof(menuname), "购买卫星轨道炮 需 %i 积分", GetConVarInt(cvar_point_tunder));
		AddMenuItem(menu, "option1", menuname);
		
		Format(menuname, sizeof(menuname), "强壮体格到 %iHP 需 %i 积分", GetConVarInt(cvar_god_point),GetConVarInt(cvar_god_money));
		AddMenuItem(menu, "option2", menuname);
		
		Format(menuname, sizeof(menuname), "购买榴弹炮 需 %i 积分", GetConVarInt(cvar_powershot_money));
		AddMenuItem(menu, "option3", menuname);
		
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
		return Plugin_Handled;
}

public RankBuytunder(Handle:menu, MenuAction:action, client, itemNum)
{
		
    decl String:SteamID[MAX_LINE_WIDTH];
    
    if(client <= 0)
    {
    return;
    }
    
    if (!IsClientConnected(client) && !IsClientInGame(client))
    return;

    if (IsClientBot(client))
    return;
    
    GetClientName(client, SteamID, sizeof(SteamID)); 
    
    if ( action == MenuAction_Select ) {
        
        switch (itemNum)
        {
            case 0: //闪电炮
            {
                new Score = GetConVarInt(cvar_point_tunder);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_point_tunder))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_point_tunder));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_point_tunder) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score, SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                tunder[client] = true;
                tunder_counts[client] = 0;
                PrintToChat(client,"\x04恭喜您购买成功,当前剩余积分[%i]\x05卫星炮技能能对特殊感染者造成每次\x03%i\x05点的攻击伤害.",ClientPoints[client]-GetConVarInt(cvar_point_tunder),GetConVarInt(cvar_tunderpower));
                PrintToChatAll("\x04[%N]\x05在!buy系统中花费了\x04[%i]\x05点积分购买了杀伤力\x04[%i]\x05点的卫星炮.这家伙神志不清,请勿靠近..",client,GetConVarInt(cvar_point_tunder),GetConVarInt(cvar_tunderpower));
                PrintToChatAll("\x04[%N]\x05在!buy系统中花费了\x04[%i]\x05点积分购买了杀伤力\x04[%i]\x05点的卫星炮.这家伙神志不清,请勿靠近..",client,GetConVarInt(cvar_point_tunder),GetConVarInt(cvar_tunderpower));
                }
            }
            case 1: //ob牌居家必备丸
            {
                new Score = GetConVarInt(cvar_god_money);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_god_money))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_god_money));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_god_money) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score, SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x04恭喜您购买成功,当前剩余积分[%i]\x05该物品使得你的体格增加到了\x03%i\x05HP.",ClientPoints[client]-GetConVarInt(cvar_god_money),GetConVarInt(cvar_god_point));
                PrintToChatAll("\x04[%N]\x05在!buy系统中花费了\x04[%i]\x05点积分购买了OB牌居家必备丸,以使得其体格涨到了\x04[%i]\x05HP.",client,GetConVarInt(cvar_god_money),GetConVarInt(cvar_god_point));
                PrintToChatAll("\x04[%N]\x05在!buy系统中花费了\x04[%i]\x05点积分购买了OB牌居家必备丸,以使得其体格涨到了\x04[%i]\x05HP.",client,GetConVarInt(cvar_god_money),GetConVarInt(cvar_god_point));  
                //SetEntProp(client,Prop_Send,"m_iMaxHealth",GetConVarInt(cvar_god_point));
                //SetEntProp(client,Prop_Send,"m_iHealth",GetConVarInt(cvar_god_point));
                SetEntityHealth(client, GetConVarInt(cvar_god_point));
                }
            }
            case 2: //榴弹炮
            {
                new Score = GetConVarInt(cvar_powershot_money);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_powershot_money))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_powershot_money));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_powershot_money) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score, SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                powershot[client] = true;
                powershot_counts[client] = 0;
                PrintToChat(client,"\x04恭喜您购买成功,当前剩余积分[%i]\x05榴弹炮可以使用\x03%i\x05次.",ClientPoints[client]-GetConVarInt(cvar_powershot_money),GetConVarInt(cvar_powershot_round));
                PrintToChatAll("\x05[%N]\x04在!buy系统中花费了\x05[%i]\x04点积分购买了榴弹炮(突围弹)",client,GetConVarInt(cvar_powershot_money));
                }
            }
        }
    }
}


public Action:vipbuy(client, args) 
{
		new Handle:menu = CreateMenu(RankByyVIP);
		
		new String:menuname[512];
		
		if ( GetConVarInt(cvar_usetime) > 60 )
		{
		Format(menuname, sizeof(menuname), "每次新开局都免费赠送,有效期 %.2f 小时", FloatDiv(float(GetConVarInt(cvar_usetime)), 60.0));
		}
		else
		{
		Format(menuname, sizeof(menuname), "每次新开局都免费赠送,有效期 %i 分钟", GetConVarInt(cvar_usetime));
		}
		
		SetMenuTitle(menu, menuname);
		Format(menuname, sizeof(menuname), "购买步枪 需 %i 积分", GetConVarInt(cvar_vip_buyrifle));
		AddMenuItem(menu, "option1", menuname);
		Format(menuname, sizeof(menuname), "购买自动散弹枪 需 %i 积分", GetConVarInt(cvar_vip_buyautoshotgun));
		AddMenuItem(menu, "option2", menuname);
		Format(menuname, sizeof(menuname), "购买狙击步枪 需 %i 积分", GetConVarInt(cvar_vip_buyhrifle));
		AddMenuItem(menu, "option3", menuname);
		Format(menuname, sizeof(menuname), "购买药包 需 %i 积分", GetConVarInt(cvar_vip_buykit));
		AddMenuItem(menu, "option4", menuname);
		Format(menuname, sizeof(menuname), "购买止痛药 需 %i 积分", GetConVarInt(cvar_vip_buypills));
		AddMenuItem(menu, "option5", menuname);
		Format(menuname, sizeof(menuname), "购买土制炸弹 需 %i 积分", GetConVarInt(cvar_vip_buybome));
		AddMenuItem(menu, "option6", menuname);
		Format(menuname, sizeof(menuname), "购买燃烧弹 需 %i 积分", GetConVarInt(cvar_vip_buymolotov));
		AddMenuItem(menu, "option7", menuname);
		
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
		return Plugin_Handled;
}

public RankByyVIP(Handle:menu, MenuAction:action, client, itemNum)
{
		
    decl String:SteamID[MAX_LINE_WIDTH];
    
    if(client <= 0)
    {
    return;
    }
    
    if (!IsClientConnected(client) && !IsClientInGame(client))
    return;

    if (IsClientBot(client))
    return;
    
    GetClientName(client, SteamID, sizeof(SteamID));
    
    SetConVarInt(FindConVar("sm_stat_cheats"), 3);
    new flags = GetCommandFlags("give");
    
    if ( action == MenuAction_Select ) {
        
        switch (itemNum)
        {
            case 0: //rifle
            {
                new Score = GetConVarInt(cvar_vip_buyrifle);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_vip_buyrifle))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_vip_buyrifle));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_vip_buyrifle) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET lastbuytime = '2', points = points + %i, weapon = '1' WHERE steamid = '%s'",Score,SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x01恭喜您购买成功,当前剩余积分[%i],因为这是VIP物品,所以每次新开局都会自动发放给你!!\x03",ClientPoints[client]-GetConVarInt(cvar_vip_buyrifle));
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                SetCommandFlags("give", flags & ~FCVAR_CHEAT);
                FakeClientCommand(client, "give rifle");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                SetCommandFlags("give", flags|FCVAR_CHEAT);
                }
            }
            case 1: //auto shotgun
            {
                new Score = GetConVarInt(cvar_vip_buyautoshotgun);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_vip_buyautoshotgun))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_vip_buyautoshotgun));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_vip_buyautoshotgun) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET lastbuytime = '2', points = points + %i, weapon = '2' WHERE steamid = '%s'",Score,SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x01购买成功,当前剩余积分[%i],因为这是VIP物品,所以每次新开局都会自动发放给你!!\x03",ClientPoints[client]-GetConVarInt(cvar_vip_buyautoshotgun));
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                SetCommandFlags("give", flags & ~FCVAR_CHEAT);
                FakeClientCommand(client, "give autoshotgun");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                SetCommandFlags("give", flags|FCVAR_CHEAT);
                }
            }
            case 2: //hunting rifle
            {
                new Score = GetConVarInt(cvar_vip_buyhrifle);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_vip_buyhrifle))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_vip_buyhrifle));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_vip_buyhrifle) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET lastbuytime = '2', points = points + %i, weapon = '3' WHERE steamid = '%s'",Score,SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x01购买成功,当前剩余积分[%i],因为这是VIP物品,所以每次新开局都会自动发放给你!!\x03",ClientPoints[client]-GetConVarInt(cvar_vip_buyhrifle));
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                SetCommandFlags("give", flags & ~FCVAR_CHEAT);
                FakeClientCommand(client, "give hunting_rifle");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                SetCommandFlags("give", flags|FCVAR_CHEAT);
                }
            }
            case 3: //kit
            {
                new Score = GetConVarInt(cvar_vip_buykit);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_vip_buykit))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_vip_buykit));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_vip_buykit) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET lastbuyitem = '2', points = points + %i, items = '1' WHERE steamid = '%s'",Score,SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x01购买成功,当前剩余积分[%i],因为这是VIP物品,所以每次新开局都会自动发放给你!!\x03",ClientPoints[client]-GetConVarInt(cvar_vip_buykit));
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                SetCommandFlags("give", flags & ~FCVAR_CHEAT);
                FakeClientCommand(client, "give first_aid_kit");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                SetCommandFlags("give", flags|FCVAR_CHEAT);
                }
            }
            case 4: //pill
            {
                new Score = GetConVarInt(cvar_vip_buypills);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_vip_buypills))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_vip_buypills));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_vip_buypills) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET lastbuyitem = '2', points = points + %i, items = '2' WHERE steamid = '%s'",Score,SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x01购买成功,当前剩余积分[%i],因为这是VIP物品,所以每次新开局都会自动发放给你!!\x03",ClientPoints[client]-GetConVarInt(cvar_vip_buypills));
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                SetCommandFlags("give", flags & ~FCVAR_CHEAT);
                FakeClientCommand(client, "give pain_pills");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                SetCommandFlags("give", flags|FCVAR_CHEAT);
                }
            }
            case 5: //pipe_bomb
            {
                new Score = GetConVarInt(cvar_vip_buybome);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_vip_buybome))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_vip_buybome));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_vip_buybome) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET lastbuyitem = '2', points = points + %i, items = '3' WHERE steamid = '%s'",Score,SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x01购买成功,当前剩余积分[%i],因为这是VIP物品,所以每次新开局都会自动发放给你!!\x03",ClientPoints[client]-GetConVarInt(cvar_vip_buybome));
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                SetCommandFlags("give", flags & ~FCVAR_CHEAT);
                FakeClientCommand(client, "give pipe_bomb");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                SetCommandFlags("give", flags|FCVAR_CHEAT);
                }
            }
            case 6: //molotov
            {
                new Score = GetConVarInt(cvar_vip_buymolotov);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_vip_buymolotov))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_vip_buymolotov));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_vip_buymolotov) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET lastbuyitem = '2', points = points + %i, items = '4' WHERE steamid = '%s'",Score,SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x01购买成功,当前剩余积分[%i],因为这是VIP物品,所以每次新开局都会自动发放给你!!\x03",ClientPoints[client]-GetConVarInt(cvar_vip_buymolotov));
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                SetCommandFlags("give", flags & ~FCVAR_CHEAT);
                FakeClientCommand(client, "give molotov");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                SetCommandFlags("give", flags|FCVAR_CHEAT);
                }
            }
        }
    }

    //Add the CHEAT flag back to "give" command
    SetCommandFlags("give", flags|FCVAR_CHEAT);
    
    SetConVarInt(FindConVar("sm_stat_cheats"), 3);
}



public Action:buyjdj(client, args)
{
    decl String:SteamID[MAX_LINE_WIDTH];
    
    if(client <= 0)
    {
    return;
    }
    
    if (!IsClientConnected(client) && !IsClientInGame(client))
    return;

    if (IsClientBot(client))
    return;
    
    if(GetClientTeam(client) == 1)
    {
    PrintToChat(client, "\x04[SM] \x01 旁观者无法使用该功能.");
    return;
    }
    
    GetClientName(client, SteamID, sizeof(SteamID));
    
    new Score = GetConVarInt(cvar_buyjd);
    Score = Score * -1;
    
    if(ClientPoints[client] <= GetConVarInt(cvar_buyjd))
    {
    PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_buyjd));
    }
    else if(ClientPoints[client] > GetConVarInt(cvar_buyjd) && ClientPoints[client] > 0)
    {
    decl String:query[1024];
    Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score, SteamID);
    SendSQLUpdate(query);
    UpdateMapStat("points", Score);
    PrintToChat(client,"\x04购买解毒剂成功,当前剩余积分[%i]",ClientPoints[client]-GetConVarInt(cvar_buyjd));
    
    ServerCommand("sm_drug \"%N\"",client);
    
    }
}

public Action:buydb(client, args) 
{
		new Handle:menu = CreateMenu(RankBuyDb);
		
		new String:menuname[512];
		
		Format(menuname, sizeof(menuname), "请选择你要赌博的积分,赔率 1:%i", GetConVarInt(cvar_buydb));
	
		SetMenuTitle(menu, menuname);
		AddMenuItem(menu, "option1", "赌 100 分");
		AddMenuItem(menu, "option2", "赌 200 分");
		AddMenuItem(menu, "option3", "赌 500 分");
		AddMenuItem(menu, "option4", "赌 1000 分");
		AddMenuItem(menu, "option5", "赌 2000 分");
		SetMenuExitButton(menu, true);
	
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	
		return Plugin_Handled;
}

public RankBuyDb(Handle:menu, MenuAction:action, client, itemNum)
{
		
    decl String:SteamID[MAX_LINE_WIDTH];
    
    if(client <= 0)
    {
    return;
    }
    
    if (!IsClientConnected(client) && !IsClientInGame(client))
    return;

    if (IsClientBot(client))
    return;
    
    GetClientName(client, SteamID, sizeof(SteamID));
    
    if ( action == MenuAction_Select ) {
        
        switch (itemNum)
        {
            case 0: //100分
            {
                new Score = 100;
                if(ClientPoints[client] <= Score)
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],Score);
                }
                else if(ClientPoints[client] > Score && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                if (randomdb(client))
                {
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", (Score - (Score / 10)) * GetConVarInt(cvar_buydb), SteamID);
                PrintToChat(client,"\x04[恭喜你]\x05你的运气真好,你赢得了\x04%i\x05点积分,当前共有积分[%i]再接再厉哟!!",(Score - (Score / 10)) * GetConVarInt(cvar_buydb),ClientPoints[client] + (Score * GetConVarInt(cvar_buydb)));
                PrintToChatAll("\x04[恭喜 %N ]\x05在!buy系统赌博赢得了\x04%i\x05点积分.",client,(Score - (Score / 10)) * GetConVarInt(cvar_buydb));
                }
                else
                {
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score * -1, SteamID);
                PrintToChat(client,"\x03[赌输了]\x05差点就赢了,真可惜!,剩余[%i]积分~~\x03",ClientPoints[client] + ( Score * -1) );
                }
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                }
            }
            case 1: //200分
            {
                new Score = 200;
                if(ClientPoints[client] <= Score)
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],Score);
                }
                else if(ClientPoints[client] > Score && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                if (randomdb(client))
                {
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", (Score - (Score / 10)) * GetConVarInt(cvar_buydb), SteamID);
                PrintToChat(client,"\x04[恭喜你]\x05你的运气真好,你赢得了\x04%i\x05点积分,当前共有积分[%i]再接再厉哟!!",(Score - (Score / 10)) * GetConVarInt(cvar_buydb),ClientPoints[client] + (Score * GetConVarInt(cvar_buydb)));
                PrintToChatAll("\x04[恭喜%N]\x05在!buy系统赌博赢得了\x04%i\x05点积分.",client,(Score - (Score / 10)) * GetConVarInt(cvar_buydb));
                }
                else
                {
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score * -1, SteamID);
                PrintToChat(client,"\x03[赌输了]\x05差点就赢了,真可惜!,剩余[%i]积分~~\x03",ClientPoints[client] + ( Score * -1) );
                }
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                }
            }
            case 2: //500分
            {
                new Score = 500;
                if(ClientPoints[client] <= Score)
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],Score);
                }
                else if(ClientPoints[client] > Score && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                if (randomdb(client))
                {
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", (Score - (Score / 10)) * GetConVarInt(cvar_buydb), SteamID);
                PrintToChat(client,"\x04[恭喜你]\x05你的运气真好,你赢得了\x04%i\x05点积分,当前共有积分[%i]再接再厉哟!!",(Score - (Score / 10)) * GetConVarInt(cvar_buydb),ClientPoints[client] + (Score * GetConVarInt(cvar_buydb)));
                PrintToChatAll("\x04[恭喜%N]\x05在!buy系统赌博赢得了\x04%i\x05点积分.",client,(Score - (Score / 10)) * GetConVarInt(cvar_buydb));
                }
                else
                {
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score * -1, SteamID);
                PrintToChat(client,"\x03[赌输了]\x05差点就赢了,真可惜!,剩余[%i]积分~~\x03",ClientPoints[client] + ( Score * -1) );
                }
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                }
            }
            case 3: //1000分
            {
                new Score = 1000;
                if(ClientPoints[client] <= Score)
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],Score);
                }
                else if(ClientPoints[client] > Score && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                if (randomdb(client))
                {
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", (Score - (Score / 10)) * GetConVarInt(cvar_buydb), SteamID);
                PrintToChat(client,"\x04[恭喜你]\x05你的运气真好,你赢得了\x04%i\x05点积分,当前共有积分[%i]再接再厉哟!!",(Score - (Score / 10)) * GetConVarInt(cvar_buydb),ClientPoints[client] + (Score * GetConVarInt(cvar_buydb)));
                PrintToChatAll("\x04[恭喜%N]\x05在!buy系统赌博赢得了\x04%i\x05点积分.",client,(Score - (Score / 10)) * GetConVarInt(cvar_buydb));
                }
                else
                {
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score * -1, SteamID);
                PrintToChat(client,"\x03[赌输了]\x05差点就赢了,真可惜!,剩余[%i]积分~~\x03",ClientPoints[client] + ( Score * -1) );
                }
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                }
            }
            case 4: //2000分
            {
                new Score = 2000;
                if(ClientPoints[client] <= Score)
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],Score);
                }
                else if(ClientPoints[client] > Score && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                if (randomdb(client))
                {
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", (Score - (Score / 10)) * GetConVarInt(cvar_buydb), SteamID);
                PrintToChat(client,"\x04[恭喜你]\x05你的运气真好,你赢得了\x04%i\x05点积分,当前共有积分[%i]再接再厉哟!!",(Score - (Score / 10)) * GetConVarInt(cvar_buydb),ClientPoints[client] + (Score * GetConVarInt(cvar_buydb)));
                PrintToChatAll("\x04[恭喜%N]\x05在!buy系统赌博赢得了\x04%i\x05点积分.",client,(Score - (Score / 10)) * GetConVarInt(cvar_buydb));
                }
                else
                {
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score * -1, SteamID);
                PrintToChat(client,"\x03[赌输了]\x05差点就赢了,真可惜!,剩余[%i]积分~~\x03",ClientPoints[client] + ( Score * -1) );
                }
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                }
                
            }
        }
    }
            
}


public randomdb(client)
{
	new randomNum = GetRandomInt(0, 20);
	switch (randomNum)
	{
            case 0:
            {
            return false;
            }
            case 1:
            {
            return false;
            }
            case 2:
            {
            return false;
            }
            case 3:
            {
            return false;
            }
            case 4:
            {
            return false;
            }
            case 5:
            {
            return false;
            }
            case 6:
            {
            return true;
            }
            case 7:
            {
            return false;
            }
            case 8:
            {
            return false;
            }
            case 9:
            {
            return false;
            }
            case 10:
            {
            return false;
            }
            case 11:
            {
            return false;
            }
            case 12:
            {
            return false;
            }
            case 13:
            {
            return false;
            }
            case 14:
            {
            return false;
            }
            case 15:
            {
            return false;
            }
            case 16:
            {
            return false;
            }
            case 17:
            {
            return false;
            }
            case 18:
            {
            return false;
            }
            case 19:
            {
            return false;
            }
            case 20:
            {
            return false;
            }
	}
	PrintToChat(client,"\x03[DEBUG]\x05x~~\x03");
	return true;
}


public Action:buylife(client, args)
{
    decl String:SteamID[MAX_LINE_WIDTH];
    
    if(client <= 0)
    {
    return;
    }
    
    if (!IsClientConnected(client) && !IsClientInGame(client))
    return;

    if (IsClientBot(client))
    return;
    
    if(GetClientTeam(client) == 1)
    {
    PrintToChat(client, "\x04[SM] \x01 旁观者无法使用该功能.");
    return;
    }
    
    GetClientName(client, SteamID, sizeof(SteamID));
    
    new Score = GetConVarInt(cvar_buylife);
    Score = Score * -1;
    
    if(ClientPoints[client] <= GetConVarInt(cvar_buylife))
    {
    PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_buylife));
    }
    else if(ClientPoints[client] > GetConVarInt(cvar_buylife) && ClientPoints[client] > 0)
    {
    decl String:query[1024];
    Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score, SteamID);
    SendSQLUpdate(query);
    UpdateMapStat("points", Score);
    PrintToChat(client,"\x03购买补血成功,当前剩余积分[%i]",ClientPoints[client]-GetConVarInt(cvar_buylife));
    PrintToChatAll("\x04[快捷补血:]\x05 玩家\x03[%N]\x05花费了\x03%i\x05积分购买了快捷补血!!",client,GetConVarInt(cvar_buylife));
    SetConVarInt(FindConVar("sm_stat_cheats"),2);
    new String:command[] = "give";
    StripAndExecuteClientCommand(client, command, "health","","");
    SetConVarInt(FindConVar("sm_stat_cheats"),3);
    }
}

public Action:buycaipiao(client, args)
{
    decl String:SteamID[MAX_LINE_WIDTH];
    
    if(client <= 0)
    {
    return;
    }
    
    if (!IsClientConnected(client) && !IsClientInGame(client))
    return;

    if (IsClientBot(client))
    return;
    
    if(GetClientTeam(client) == 1)
    {
    PrintToChat(client, "\x04[SM] \x01 旁观者无法使用该功能.");
    return;
    }
    
    GetClientName(client, SteamID, sizeof(SteamID));
    
    new Score = GetConVarInt(cvar_buyrp);
    Score = Score * -1;
    
    if(ClientPoints[client] <= GetConVarInt(cvar_buyrp))
    {
    PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_buyrp));
    }
    else if(ClientPoints[client] > GetConVarInt(cvar_buyrp) && ClientPoints[client] > 0)
    {
    decl String:query[1024];
    Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score, SteamID);
    SendSQLUpdate(query);
    UpdateMapStat("points", Score);
    PrintToChat(client,"\x04[彩票卷]\x01购买成功,当前剩余积分[%i],按Y输入\x04!addrp\x01即可激活\x03",ClientPoints[client]-GetConVarInt(cvar_buyrp));
    caipiaojuan[client] = true;
    }
}

public Action:buyjineng(client, args) 
{
    decl String:SteamID[MAX_LINE_WIDTH];
    
    if(client <= 0)
    {
    return;
    }
    
    if (!IsClientConnected(client) && !IsClientInGame(client))
    return;

    if (IsClientBot(client))
    return;
    
    if(GetClientTeam(client) == 1)
    {
    PrintToChat(client, "\x04[SM] \x01 旁观者无法使用该功能.");
    return;
    }
    
    if(GetConVarInt(upgrade_open) != 1)
    {
    PrintToChat(client, "\x04[SM] \x01 服务器未开通此功能.");
    return;
    }
    
    GetClientName(client, SteamID, sizeof(SteamID));
    
    new Score = GetConVarInt(cvar_buyjn);
    Score = Score * -1;
    
    if(ClientPoints[client] <= GetConVarInt(cvar_buyjn))
    {
    PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_buyjn));
    }
    else if(ClientPoints[client] > GetConVarInt(cvar_buyjn) && ClientPoints[client] > 0)
    {
    decl String:query[1024];
    Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score, SteamID);
    SendSQLUpdate(query);
    UpdateMapStat("points", Score);
    PrintToChat(client,"\x01随机购买一个技能成功,当前剩余积分[%i],请加油赚分啦~~\x03",ClientPoints[client]-GetConVarInt(cvar_buyjn));
    PrintToChatAll("\x04[\x03RANK\x04] \x01[%N] \x04购买了随机技能\x01花费了[%i]积分!",client,GetConVarInt(cvar_buyjn));
    GiveClientUpgrades(client, 1);
    }
}

public Action:buymenu(client, args) 
{
		new Handle:menu = CreateMenu(RankBuyMenuHandler);
		
		new String:menuname[512];
		
		Format(menuname, sizeof(menuname), "散弹枪需 %i 积分", GetConVarInt(cvar_buyshotgun));
	
		SetMenuTitle(menu, "请选择要购买的物品,输入!RANK查看积分");
		Format(menuname, sizeof(menuname), "散弹枪需 %i 积分", GetConVarInt(cvar_buyshotgun));
		AddMenuItem(menu, "option1", menuname);
		Format(menuname, sizeof(menuname), "冲锋枪需 %i 积分", GetConVarInt(cvar_buysmg));
		AddMenuItem(menu, "option2", menuname);
		Format(menuname, sizeof(menuname), "步枪需 %i 积分", GetConVarInt(cvar_buyrifle));
		AddMenuItem(menu, "option3", menuname);
		Format(menuname, sizeof(menuname), "狙击步枪需 %i 积分", GetConVarInt(cvar_buyhrifle));
		AddMenuItem(menu, "option4", menuname);
		Format(menuname, sizeof(menuname), "自动散弹枪需 %i 积分", GetConVarInt(cvar_buyautoshotgun));
		AddMenuItem(menu, "option5", menuname);
		Format(menuname, sizeof(menuname), "手枪需 %i 积分", GetConVarInt(cvar_buypistol));
		AddMenuItem(menu, "option6", menuname);
		Format(menuname, sizeof(menuname), "土制炸弹需 %i 积分", GetConVarInt(cvar_buypipebomb));
		AddMenuItem(menu, "option7", menuname);
		Format(menuname, sizeof(menuname), "汽油桶需 %i 积分", GetConVarInt(cvar_buymolotov));
		AddMenuItem(menu, "option8", menuname);
		Format(menuname, sizeof(menuname), "药丸需 %i 积分", GetConVarInt(cvar_buypills));
		AddMenuItem(menu, "option9", menuname);
		Format(menuname, sizeof(menuname), "医疗包需 %i 积分", GetConVarInt(cvar_buykit));
		AddMenuItem(menu, "option10", menuname);
		SetMenuExitButton(menu, true);
	
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	
		return Plugin_Handled;
}

public RankBuyMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
		
    decl String:SteamID[MAX_LINE_WIDTH];
    
    if(client <= 0)
    {
    return;
    }
    
    if (!IsClientConnected(client) && !IsClientInGame(client))
    return;

    if (IsClientBot(client))
    return;
    
    if(GetClientTeam(client) == 1)
    {
    PrintToChat(client, "\x04[SM] \x01 旁观者无法使用该功能.");
    return;
    }
    
    if(haswepon[client])
    {
    PrintToChat(client, "\x04[SM] \x01 抱歉,一次生命机会只能购买一次这里的武器,想买死了或重新开局再来.");
    return;
    }

    GetClientName(client, SteamID, sizeof(SteamID));
    
    SetConVarInt(FindConVar("sm_stat_cheats"), 3);
    new flags = GetCommandFlags("give");
    
    if ( action == MenuAction_Select ) {
        
        switch (itemNum)
        {
            case 0: //shotgun
            {
                new Score = GetConVarInt(cvar_buyshotgun);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_buyshotgun))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_buyshotgun));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_buyshotgun) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score, SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x01购买成功,当前剩余积分[%i],请加油赚取积分了!!\x03",ClientPoints[client]-GetConVarInt(cvar_buyshotgun));
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                SetCommandFlags("give", flags & ~FCVAR_CHEAT);
                FakeClientCommand(client, "give pumpshotgun");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                SetCommandFlags("give", flags|FCVAR_CHEAT);
                haswepon[client] = true;
                }
            }
            case 1: //smg
            {
                new Score = GetConVarInt(cvar_buysmg);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_buysmg))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_buysmg));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_buysmg) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score, SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x01购买成功,当前剩余积分[%i],请加油赚取积分了!!\x03",ClientPoints[client]-GetConVarInt(cvar_buysmg));
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                SetCommandFlags("give", flags & ~FCVAR_CHEAT);
                FakeClientCommand(client, "give smg");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                SetCommandFlags("give", flags|FCVAR_CHEAT);
                haswepon[client] = true;
                }
            }
            case 2: //rifle
            {
                new Score = GetConVarInt(cvar_buyrifle);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_buyrifle))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_buyrifle));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_buyrifle) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score, SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x01购买成功,当前剩余积分[%i],请加油赚取积分了!!\x03",ClientPoints[client]-GetConVarInt(cvar_buyrifle));
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                SetCommandFlags("give", flags & ~FCVAR_CHEAT);
                FakeClientCommand(client, "give rifle");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                SetCommandFlags("give", flags|FCVAR_CHEAT);
                haswepon[client] = true;
                }
            }
            case 3: //hunting rifle
            {
                new Score = GetConVarInt(cvar_buyhrifle);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_buyhrifle))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_buyhrifle));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_buyhrifle) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score, SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x01购买成功,当前剩余积分[%i],请加油赚取积分了!!\x03",ClientPoints[client]-GetConVarInt(cvar_buyhrifle));
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                SetCommandFlags("give", flags & ~FCVAR_CHEAT);
                FakeClientCommand(client, "give hunting_rifle");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                SetCommandFlags("give", flags|FCVAR_CHEAT);
                haswepon[client] = true;
                }
            }
            case 4: //auto shotgun
            {
                new Score = GetConVarInt(cvar_buyautoshotgun);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_buyautoshotgun))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_buyautoshotgun));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_buyautoshotgun) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score, SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x01购买成功,当前剩余积分[%i],请加油赚取积分了!!\x03",ClientPoints[client]-GetConVarInt(cvar_buyautoshotgun));
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                SetCommandFlags("give", flags & ~FCVAR_CHEAT);
                FakeClientCommand(client, "give autoshotgun");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                SetCommandFlags("give", flags|FCVAR_CHEAT);
                haswepon[client] = true;
                }
            }
            case 5: //pistol
            {
                new Score = GetConVarInt(cvar_buypistol);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_buypistol))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_buypistol));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_buypistol) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score, SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x01购买成功,当前剩余积分[%i],请加油赚取积分了!!\x03",ClientPoints[client]-GetConVarInt(cvar_buypistol));
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                SetCommandFlags("give", flags & ~FCVAR_CHEAT);
                FakeClientCommand(client, "give pistol");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                SetCommandFlags("give", flags|FCVAR_CHEAT);
                haswepon[client] = true;
                }
            }
            case 6: //pipe_bomb
            {
                new Score = GetConVarInt(cvar_buypipebomb);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_buypipebomb))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_buypipebomb));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_buypipebomb) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score, SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x01购买成功,当前剩余积分[%i],请加油赚取积分了!!\x03",ClientPoints[client]-GetConVarInt(cvar_buypipebomb));
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                SetCommandFlags("give", flags & ~FCVAR_CHEAT);
                FakeClientCommand(client, "give pipe_bomb");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                SetCommandFlags("give", flags|FCVAR_CHEAT);
                haswepon[client] = true;
                }
            }
            case 7: //hunting molotov
            {
                new Score = GetConVarInt(cvar_buymolotov);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_buymolotov))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_buymolotov));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_buymolotov) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score, SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x01购买成功,当前剩余积分[%i],请加油赚取积分了!!\x03",ClientPoints[client]-GetConVarInt(cvar_buymolotov));
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                SetCommandFlags("give", flags & ~FCVAR_CHEAT);
                FakeClientCommand(client, "give molotov");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                SetCommandFlags("give", flags|FCVAR_CHEAT);
                haswepon[client] = true;
                }
            }
            case 8: //pain_pills
            {
                new Score = GetConVarInt(cvar_buypills);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_buypills))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_buypills));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_buypills) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score, SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x01购买成功,当前剩余积分[%i],请加油赚取积分了!!\x03",ClientPoints[client]-GetConVarInt(cvar_buypills));
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                SetCommandFlags("give", flags & ~FCVAR_CHEAT);
                FakeClientCommand(client, "give pain_pills");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                SetCommandFlags("give", flags|FCVAR_CHEAT);
                haswepon[client] = true;
                }
            }
            case 9: //first_aid_kit
            {
                new Score = GetConVarInt(cvar_buykit);
                Score = Score * -1;
                if(ClientPoints[client] <= GetConVarInt(cvar_buykit))
                {
                PrintToChat(client,"\x01你当前拥有积分[%i],你所购买的物品需要积分[%i],所以无法购买!\x03",ClientPoints[client],GetConVarInt(cvar_buykit));
                }
                else if(ClientPoints[client] > GetConVarInt(cvar_buykit) && ClientPoints[client] > 0)
                {
                decl String:query[1024];
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score, SteamID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                PrintToChat(client,"\x01购买成功,当前剩余积分[%i],请加油赚取积分了!!\x03",ClientPoints[client]-GetConVarInt(cvar_buykit));
                SetConVarInt(FindConVar("sm_stat_cheats"), 2);
                SetCommandFlags("give", flags & ~FCVAR_CHEAT);
                FakeClientCommand(client, "give first_aid_kit");
                SetConVarInt(FindConVar("sm_stat_cheats"), 3);
                SetCommandFlags("give", flags|FCVAR_CHEAT);
                haswepon[client] = true;
                }
            }
        }
    }

    //Add the CHEAT flag back to "give" command
    SetCommandFlags("give", flags|FCVAR_CHEAT);
    
    SetConVarInt(FindConVar("sm_stat_cheats"), 3);
}

public OnMapStart()
{

	PrecacheSound(SOUND_BOOM, true);
	
	ResetVars();
	for(new i=0;i<sizeof(rankbuyTimeout);i++) 
	rankbuyTimeout[i]=false;

	//g_Lightning = PrecacheModel ("sprites/lgtning.vmt" ); //闪电
	g_Lightning = PrecacheModel ("sprites/lgtning.vmt" ); //闪电
	g_BeamSprite = PrecacheModel("sprites/laser.vmt");
	g_HaloSprite = PrecacheModel("sprites/laser.vmt");
	g_ExplosionSprite = PrecacheModel("sprites/flyingember.vmt");

	
}

public Action:powershotTimeOutOver(Handle:timer, any:client)
{
	powershotTimeout[client] = false;
}

public Action:tunderTimeOutOver(Handle:timer, any:client)
{
	inVoteTimeout[client] = false;
}

public isInVoteTimeout(client)
{
	if (GetConVarBool(buyTimeout))
	{
		return rankbuyTimeout[client];	
	}
	return false;
}

public Action:TimeOutOver(Handle:timer, any:client)
{
	rankbuyTimeout[client] = false;
}

// Init player on connect, and update total rank and client rank.

public OnClientPostAdminCheck(client)
{
    if (db == INVALID_HANDLE)
        return;

    if (IsClientBot(client))
        return;
    
    CheckPlayerDB(client);
    
    decl String:SteamID[MAX_LINE_WIDTH];
    GetClientName(client, SteamID, sizeof(SteamID));

    TimerPoints[client] = 0;
    TimerKills[client] = 0;
    TimerHeadshots[client] = 0;

    SQL_TQuery(db, GetRankTotal, "SELECT COUNT(*) FROM players", client);

    decl String:query[256];
    Format(query, sizeof(query), "SELECT points FROM players WHERE steamid = '%s'", SteamID);
    SQL_TQuery(db, GetClientPoints, query, client);
    
    if (client == 10)
    {
    CreateTimer(40.0, passwordcheck, client);
    CreateTimer(45.0, lastonlinecheck, client);
    }
    else if (client != 10)
    {
    CreateTimer((client * 1.0), passwordcheck, client);
    CreateTimer(((client + 12.0 ) * 1.0), lastonlinecheck, client);
    }
}

// Show rank on connect.



public Action:lastonlinecheck(Handle:timer, any:client)
{
    if (StatsDisabled()) return;
    
    if(client <= 0)
		return;
	
    if (!IsClientConnected(client) && !IsClientInGame(client))
    return;

    if (IsClientBot(client))
    return;
    
    decl String:SteamID[MAX_LINE_WIDTH];
    GetClientName(client, SteamID, sizeof(SteamID));
    
    decl String:querypw[1024];
	
    Format(querypw, sizeof(querypw), "SELECT lastbuytime FROM players WHERE steamid = '%s'", SteamID);
    SQL_TQuery(db, GetClientlastbuyonline, querypw, client);
    
    Format(querypw, sizeof(querypw), "SELECT lastbuyitem FROM players WHERE steamid = '%s'", SteamID);
    SQL_TQuery(db, GetClientlastbuyitemstime, querypw, client);

/*
    Format(querypw, sizeof(querypw), "SELECT lastontime FROM players WHERE steamid = '%s'", SteamID);
    SQL_TQuery(db, GetLastOnlineTime, querypw, client);
*/
    
    Format(querypw, sizeof(querypw), "SELECT weapon FROM players WHERE steamid = '%s'", SteamID);
    SQL_TQuery(db, GetBuyWeapon, querypw, client);
    
    Format(querypw, sizeof(querypw), "SELECT items FROM players WHERE steamid = '%s'", SteamID);
    SQL_TQuery(db, GetBuyItems, querypw, client);
    
    CreateTimer(5.0, lastbuyetime1, client);
    CreateTimer(6.0, lastbuyetime2, client);
}

public Action:lastbuyetime2(Handle:timer,any:client)
{
    if (StatsDisabled()) return;
    
    if(client <= 0)
    return;
    	
    if (!IsClientConnected(client) && !IsClientInGame(client))
    return;

    if (IsClientBot(client))
    return;
    
    if (GetClientTeam(client) == 1)
    return;
    
    if (strlen(spassword[client]) < 1)
    return;

    new time = lastbuyitemstime[client];
    
    new String:Value[MAX_LINE_WIDTH];
   
    if ( GetConVarInt(cvar_usetime) > 60 )
		{
		Format(Value, sizeof(Value), "[%.2f]小时以上", FloatDiv(float(GetConVarInt(cvar_usetime)), 60.0));
		}
		else
		{
		Format(Value, sizeof(Value), "[%i] 分钟以上", GetConVarInt(cvar_usetime));
		}
    
    if ( time >= GetConVarFloat(cvar_usetime))
    {
    PrintToChat(client,"\x08[武器:] \x04 您的VIP道具离上次购买超过了%s,不再发放,如还需请购买,我们秉着童叟无欺的原则竭诚为你服务!",Value);
    return;
    }
    else if ( time < 2 )
    {
    return;
    }
    
    if ( GetConVarInt(cvar_usetime) > 60 )
		{
		Format(Value, sizeof(Value), "[%.2f]小时", FloatDiv(float(GetConVarInt(cvar_usetime)), 60.0) - FloatDiv(float(time), 60.0));
		}
		else
		{
		Format(Value, sizeof(Value), "[%i] 分钟", GetConVarInt(cvar_usetime) - time);
		}
    
    if (buyitems[client] == 1)
    {
    SetConVarInt(FindConVar("sm_stat_cheats"),2);
    new String:command[] = "give";
    StripAndExecuteClientCommand(client, command, "first_aid_kit","","");
    PrintToChatAll("\x04[VIP:]\x05[%N]\x03获得了\x04VIP道具\x03医疗包,他的\x04VIP\x03使用权还剩余\x05%s.",client,Value);
    SetConVarInt(FindConVar("sm_stat_cheats"),3);
    }
    
    if (buyitems[client] == 2)
    {
    SetConVarInt(FindConVar("sm_stat_cheats"),2);
    new String:command[] = "give";
    StripAndExecuteClientCommand(client, command, "pain_pills","","");
    PrintToChatAll("\x04[VIP:]\x05[%N]\x03获得了\x04VIP道具\x03止痛药,他的\x04VIP\x03使用权还剩余\x05%s.",client,Value);
    SetConVarInt(FindConVar("sm_stat_cheats"),3);
    }
    
    if (buyitems[client] == 3)
    {
    SetConVarInt(FindConVar("sm_stat_cheats"),2);
    new String:command[] = "give";
    StripAndExecuteClientCommand(client, command, "pipe_bomb","","");
    PrintToChatAll("\x04[VIP:]\x05[%N]\x03获得了\x04VIP道具\x03土制炸弹,他的\x04VIP\x03使用权还剩余\x05%s.",client,Value);
    SetConVarInt(FindConVar("sm_stat_cheats"),3);
    } 
    
    if (buyitems[client] == 4)
    {
    SetConVarInt(FindConVar("sm_stat_cheats"),2);
    new String:command[] = "give";
    StripAndExecuteClientCommand(client, command, "molotov","","");
    PrintToChatAll("\x04[VIP:]\x05[%N]\x03获得了\x04VIP道具\x03燃烧炸弹,他的\x04VIP\x03使用权还剩余\x05%s.",client,Value);
    SetConVarInt(FindConVar("sm_stat_cheats"),3);
    } 
}
public Action:lastbuyetime1(Handle:timer,any:client)
{
    if (StatsDisabled()) return;
    
    if(client <= 0)
    return;
    	
    if (!IsClientConnected(client) && !IsClientInGame(client))
    return;

    if (IsClientBot(client))
    return;
    
    if (GetClientTeam(client) == 1)
    return;
    
    if (strlen(spassword[client]) < 1)
    return;
    
    // new time = lastonelinetime[client] - lastbuytime[client];
    // new time = GetTime() - lastbuytime[client];
    new time = lastbuytime[client];
    
    new String:Value[MAX_LINE_WIDTH];
    
    if ( GetConVarInt(cvar_usetime) > 60 )
		{
		Format(Value, sizeof(Value), "[%.2f]小时以上", FloatDiv(float(GetConVarInt(cvar_usetime)), 60.0));
		}
		else
		{
		Format(Value, sizeof(Value), "[%i] 分钟以上", GetConVarInt(cvar_usetime));
		}
    
    
    if ( time >= GetConVarFloat(cvar_usetime))
    {
    PrintToChat(client,"\x08[武器:] \x04 您的VIP武器离上次购买超过了%s,不再发放,如还需请购买,我们秉着童叟无欺的原则竭诚为你服务!",Value);
    return;
    }
    else if ( time < 2 )
    {
    return;
    }
    
    if ( GetConVarInt(cvar_usetime) > 60 )
		{
		Format(Value, sizeof(Value), "[%.2f]小时", FloatDiv(float(GetConVarInt(cvar_usetime)), 60.0) - FloatDiv(float(time), 60.0));
		}
		else
		{
		Format(Value, sizeof(Value), "[%i] 分钟", GetConVarInt(cvar_usetime) - time);
		}
    
    if (buyweapon[client] == 1)
    {
    SetConVarInt(FindConVar("sm_stat_cheats"),2);
    new String:command[] = "give";
    StripAndExecuteClientCommand(client, command, "rifle","","");
    PrintToChatAll("\x04[VIP:]\x05[%N]\x03获得了\x04VIP武器\x03步枪,他的\x04VIP\x03使用权还剩余\x05%s.",client,Value);
    SetConVarInt(FindConVar("sm_stat_cheats"),3);
    }
    
    if (buyweapon[client] == 2)
    {
    SetConVarInt(FindConVar("sm_stat_cheats"),2);
    new String:command[] = "give";
    StripAndExecuteClientCommand(client, command, "autoshotgun","","");
    PrintToChatAll("\x04[VIP:]\x05[%N]\x03获得了\x04VIP武器\x03自动散弹枪,他的\x04VIP\x03使用权还剩余\x05%s.",client,Value);
    SetConVarInt(FindConVar("sm_stat_cheats"),3);
    }
    
    if (buyweapon[client] == 3)
    {
    SetConVarInt(FindConVar("sm_stat_cheats"),2);
    new String:command[] = "give";
    StripAndExecuteClientCommand(client, command, "hunting_rifle","","");
    PrintToChatAll("\x04[VIP:]\x05[%N]\x03获得了\x04VIP武器\x03狙击步枪,他的\x04VIP\x03使用权还剩余\x05%s.",client,Value);
    SetConVarInt(FindConVar("sm_stat_cheats"),3);
    } 
}

public Action:passwordcheck(Handle:timer, any:client)
{
    if (StatsDisabled()) return;
    
    if(client <= 0)
		return;
	
    if (!IsClientConnected(client) && !IsClientInGame(client))
    return;

    if (IsClientBot(client))
    return;
    
    if (okpassword[client])
    return;
    
    decl String:SteamID[MAX_LINE_WIDTH];
    GetClientName(client, SteamID, sizeof(SteamID));
    
    decl String:querypw[1024];
	
    Format(querypw, sizeof(querypw), "SELECT password FROM players WHERE steamid = '%s'", SteamID);
    SQL_TQuery(db, GetClientPassword, querypw, client);
    
    CreateTimer(5.0, timecheck1, client);
}

// Update the player's interstitial stats, since they may have
// gotten points between the last update and when they disconnect.

public OnClientDisconnect(client)
{
	// spassword[client] = '\0';
	
	password[client] = false;
		
	if(bOpenrp[client])
	{
		bRPEnabled = false;
		SetConVarInt(FindConVar("sm_stat_cheats"),3);
	}
	
	if(bVIP[client])
	{
	
	Vipdead();
	
	CreateTimer(3.0, viptext, 3);

	bVIP[client] = false;

	}
	
	if (IsClientBot(client))
        return;

	InterstitialPlayerUpdate(client);
}

// Update the Update Timer when the Cvar is changed.


// Make connection to database.


public Action:ReConnectDB(Handle:timer)
{
ConnectDB();
}

public ConnectDB()
{
        new String:Error[256];

        new Handle:kv = CreateKeyValues("");
        KvSetString(kv, "driver", "mysql");
        KvSetString(kv, "host", "localhost");
        KvSetString(kv, "database", "status");
        KvSetString(kv, "user", "status");
        KvSetString(kv, "pass", "QQ:264590");
        

        db = SQL_ConnectCustom(kv, Error, 256, false);

        CloseHandle(kv);

        if (db == INVALID_HANDLE)
        {
            LogError("Failed to connect to database: %s", Error);
            CreateTimer(60.0, ReConnectDB);
            PrintToChatAll ("\x04[STATUS插件失败警告:]\x05数据初始化失败,可能\x03数据服务器故障,或者你的IP被封了,请到WWW.SY64.COM查询.");
        }
        else
            SendSQLUpdate("SET NAMES 'utf8'");
}

/*
public ConnectDB()
{
    if (SQL_CheckConfig("l4dstats"))
    {
        new String:Error[256];
        db = SQL_Connect("l4dstats", true, Error, sizeof(Error));

        if (db == INVALID_HANDLE)
            LogError("Failed to connect to database: %s", Error);
        else
            SendSQLUpdate("SET NAMES 'utf8'");
    }
    else
        LogError("Database.cfg missing 'l4dstats' entry!");
}
*/

// Perform player init.

public Action:InitPlayers(Handle:timer)
{
    if (db == INVALID_HANDLE)
        return;

    SQL_TQuery(db, GetRankTotal, "SELECT COUNT(*) FROM players", 0);

    decl String:SteamID[MAX_LINE_WIDTH];
    decl String:query[256];
    new maxplayers = GetMaxClients();

    for (new i = 1; i <= maxplayers; i++)
    {
        if (IsClientConnected(i) && IsClientInGame(i) && !IsClientBot(i))
        {
            
            UpdatePlayerDB(i);
            
            GetClientName(i, SteamID, sizeof(SteamID));
            
    
            Format(query, sizeof(query), "SELECT points FROM players WHERE steamid = '%s'", SteamID);
            SQL_TQuery(db, GetClientPoints, query, i);

            TimerPoints[i] = 0;
            TimerKills[i] = 0;
            
        }
    }
}

// Check if a player is already in the DB, and update their timestamp and playtime.

CheckPlayerDB(client)
{
    if (StatsDisabled())
        return;
        
    if (IsClientBot(client))
        return;
        
    if (IsFakeClient(client))
        return;
        
    if (!IsClientConnected(client) || !IsClientInGame(client))
        return;
        
    decl String:SteamID[MAX_LINE_WIDTH];
    GetClientName(client, SteamID, MAX_NAME_LENGTH);
    
    ReplaceString(SteamID, sizeof(SteamID), " ", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "　", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "<?php", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "<?PHP", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "?>", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "\\", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "\"", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "'", "Block");
    ReplaceString(SteamID, sizeof(SteamID), ";", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "?", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "`", "Block");
	
    if( StrContains(SteamID, "Block", false)!= -1) return;
    if(!SteamID[0]) return;

    decl String:query[512];
    Format(query, sizeof(query), "SELECT steamid FROM players WHERE steamid = '%s'", SteamID);
    SQL_TQuery(db, InsertPlayerDB, query, client);
}

// Insert a player into the database if they do not already exist.

UpdatePlayerDB(client) //直接更新数据库,不检查是否存在
{
    if (db == INVALID_HANDLE || !client)
        return;

    if (StatsDisabled())
        return;
        
    if (IsClientBot(client))
        return;
        
    if (IsFakeClient(client))
        return;
        
    if (!IsClientConnected(client) || !IsClientInGame(client))
        return;
        
    decl String:SteamID[MAX_LINE_WIDTH];
    GetClientName(client, SteamID, MAX_NAME_LENGTH);
    
    if(!SteamID[0]) return;

    ReplaceString(SteamID, sizeof(SteamID), " ", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "　", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "<?php", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "<?PHP", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "?>", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "\\", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "\"", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "'", "Block");
    ReplaceString(SteamID, sizeof(SteamID), ";", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "?", "Block");
    ReplaceString(SteamID, sizeof(SteamID), "`", "Block");
	
    if( StrContains(SteamID, "Block", false)!= -1) return;

    CreateTimer((client * 1.0), UpdatePlayer, client);
}

public InsertPlayerDB(Handle:owner, Handle:hndl, const String:error[], any:data)
{
    if (db == INVALID_HANDLE)
        return;

    new client = data;

    if (!client || hndl == INVALID_HANDLE)
        return;

    if (StatsDisabled())
        return;
        
    if (IsClientBot(client))
        return;
        
    if (IsFakeClient(client))
        return;
        
    if (!IsClientConnected(client) || !IsClientInGame(client))
        return;

    if (!SQL_GetRowCount(hndl))
    {
        new String:SteamID[MAX_LINE_WIDTH];
        GetClientName(client, SteamID, sizeof(SteamID));

        new String:query[512];
        Format(query, sizeof(query), "INSERT IGNORE INTO players SET steamid = '%s'", SteamID);
        SQL_TQuery(db, SQLErrorCheckCallback, query);
    }

    CreateTimer((client * 1.0), UpdatePlayer, client);
}

// Run a SQL query, used for UPDATE's only.

public SendSQLUpdate(String:query[])
{
    if (db == INVALID_HANDLE)
        return;
        
    SQL_TQuery(db, SQLErrorCheckCallback, query);
}

// Report error on sql query;

public SQLErrorCheckCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
    if (db == INVALID_HANDLE)
        return;

    if(!StrEqual("", error))
        LogError("SQL Error: %s", error);
}

// Perform player update of name, playtime, and timestamp.

public Action:UpdatePlayer(Handle:timer,any:client)
{

    if (db == INVALID_HANDLE || !client)
        return;

    if (StatsDisabled())
        return;
    
    if (IsClientBot(client))
        return;
        
    if (IsFakeClient(client))
        return;
           
    /*
    decl String:ServerName[255];
    GetConVarString(FindConVar("hostname"),ServerName,255); */
    
    /*因为对中文支持,所以废弃以上办法*/
    
    decl String:ServerName[255];
    /*
    decl String:ServerIp[255];
    decl String:ServerPort[255];
    
    new longip = GetConVarInt(CvarHostIp);
    pieces[0] = (longip >> 24) & 0x000000FF;
    pieces[1] = (longip >> 16) & 0x000000FF;
    pieces[2] = (longip >> 8) & 0x000000FF;
    pieces[3] = longip & 0x000000FF;
    FormatEx(ServerIp, sizeof(ServerIp), "%d.%d.%d.%d", pieces[0], pieces[1], pieces[2], pieces[3]);
    GetConVarString(CvarPort, ServerPort, sizeof(ServerPort));
    
    Format(ServerName, sizeof(ServerName), "%s:%s", ServerIp,ServerPort);
    */
    
    
    GetConVarString(cvar_StatusName, ServerName, sizeof(ServerName));
    
    ReplaceString(ServerName, sizeof(ServerName), "<?php", "Block");
    ReplaceString(ServerName, sizeof(ServerName), "<?PHP", "Block");
    ReplaceString(ServerName, sizeof(ServerName), "?>", "Block");
    ReplaceString(ServerName, sizeof(ServerName), "\\", "Block");
    ReplaceString(ServerName, sizeof(ServerName), "\"", "Block");
    ReplaceString(ServerName, sizeof(ServerName), "'", "Block");
    ReplaceString(ServerName, sizeof(ServerName), ";", "Block");
    ReplaceString(ServerName, sizeof(ServerName), "?", "Block");
    ReplaceString(ServerName, sizeof(ServerName), "`", "Block");
	
    if( StrContains(ServerName, "Block", false)!= -1)
    {
    ServerName = "ServerName Error";
    }
    
    if(!ServerName[0])
    {
    ServerName = "ERROR SERVERNAME";
    }
    
    decl String:Name[MAX_LINE_WIDTH];
    GetClientName(client, Name, sizeof(Name));
    
    decl String:SteamID[MAX_LINE_WIDTH];
    GetClientAuthString(client, SteamID, sizeof(SteamID));
    
    decl String:query[512];
    
    if (lastbuytime[client] < 2 && lastbuyitemstime[client] < 2)
    {
    Format(query, sizeof(query), "UPDATE players SET lastontime = UNIX_TIMESTAMP(), ServerName = '%s' ,playtime = playtime + 1, name = '%s' WHERE steamid = '%s'",ServerName, SteamID, Name);
    }
    else if (lastbuytime[client] >= 2 && lastbuyitemstime[client] >= 2)
    {
    Format(query, sizeof(query), "UPDATE players SET lastontime = UNIX_TIMESTAMP(), ServerName = '%s' ,playtime = playtime + 1, lastbuyitem = lastbuyitem + 1, lastbuytime = lastbuytime + 1, name = '%s' WHERE steamid = '%s'",ServerName, SteamID, Name);
    }
    else if (lastbuytime[client] >= 2 && lastbuyitemstime[client] < 2)
    {
    Format(query, sizeof(query), "UPDATE players SET lastontime = UNIX_TIMESTAMP(), ServerName = '%s' ,playtime = playtime + 1, lastbuytime = lastbuytime + 1, name = '%s' WHERE steamid = '%s'",ServerName, SteamID, Name);
    }
    else if (lastbuytime[client] < 2 && lastbuyitemstime[client] >= 2)
    {
    Format(query, sizeof(query), "UPDATE players SET lastontime = UNIX_TIMESTAMP(), ServerName = '%s' ,playtime = playtime + 1, lastbuyitem = lastbuyitem + 1, name = '%s' WHERE steamid = '%s'",ServerName, SteamID, Name);
    }
    SendSQLUpdate(query);
}

// Perform a map stat update.
public UpdateMapStat(String:Field[MAX_LINE_WIDTH], Score)
{
    if (db == INVALID_HANDLE) return;
    
    if (!Score)
        Score = 1;

    decl String:MapName[64];
    GetCurrentMap(MapName, sizeof(MapName));

    decl String:DiffSQL[MAX_LINE_WIDTH];
    decl String:Difficulty[MAX_LINE_WIDTH];
    GetConVarString(cvar_Difficulty, Difficulty, sizeof(Difficulty));

    if (StrEqual(Difficulty, "Normal")) Format(DiffSQL, sizeof(DiffSQL), "nor");
    else if (StrEqual(Difficulty, "Hard")) Format(DiffSQL, sizeof(DiffSQL), "adv");
    else if (StrEqual(Difficulty, "Impossible")) Format(DiffSQL, sizeof(DiffSQL), "exp");
    else return;

    decl String:FieldSQL[MAX_LINE_WIDTH];
    Format(FieldSQL, sizeof(FieldSQL), "%s_%s", Field, DiffSQL);

    decl String:query[512];
    Format(query, sizeof(query), "UPDATE maps SET %s = %s + %i WHERE name = '%s'", FieldSQL, FieldSQL, Score, MapName);
    SendSQLUpdate(query);
}

// Perform minutely updates of player database.
// Reports Disabled message if in Versus, Easy mode, not enough Human players, and if cheats are active.


public Action:timer_checkversion(Handle:timer, Handle:hndl)
{
    if (db == INVALID_HANDLE) return Plugin_Handled;
    
    new client = 1;
    decl String:query[255];
    Format(query, sizeof(query), "SELECT version FROM version WHERE version");
    SQL_TQuery(db, getversion, query,client);
    
    if(!sqlversion) return Plugin_Handled;
    
    if(sqlversion != SQL_VERSION)
    {
    CloseHandle(db);
    CreateTimer(60.0, statuserror, TIMER_REPEAT);
    PrintToChatAll("\x04[\x03WIND\x04] \x01 STATUS插件 \x04已过期\x05,为保护玩家数据,排名系统将被禁用!请到WWW.SY64.COM更新.");
    LogAction(0, -1, "STATUS插件已过期,为保护玩家数据,排名系统将被禁用!请到WWW.SY64.COM更新.");
    }
    
    return Plugin_Handled;
}

public Action:statuserror(Handle:timer)
{
    PrintToChatAll("\x04[\x03WIND\x04] \x01 STATUS插件 \x04已过期\x05,为保护玩家数据,排名系统将被禁用!请到WWW.SY64.COM更新.");
    LogAction(0, -1, "STATUS插件已过期,为保护玩家数据,排名系统将被禁用!请到WWW.SY64.COM更新.");
    return Plugin_Handled;
}

public getversion(Handle:owner, Handle:hndl, const String:error[], any:data)
{
    new client = data;

    if (!client || hndl == INVALID_HANDLE)
        return;

    while (SQL_FetchRow(hndl))
        sqlversion = SQL_FetchInt(hndl, 0);
}

public Action:timer_UpdatePlayers(Handle:timer, Handle:hndl)
{
    if (CheckHumans() && GetConVarBool(cvar_DisabledMessages))
        PrintToChatAll("\x04[\x03RANK\x04] \x01Left 4 Dead 统计系统 \x04被禁用\x01, 没有足够的玩家!");
    
    if (StatsDisabled())
        return;

    UpdateMapStat("playtime", 1);

		
    new maxplayers = GetMaxClients();
    
    for (new i = 1; i <= maxplayers; i++)
    {
        if (IsClientConnected(i) && IsClientInGame(i) && !IsClientBot(i))
            UpdatePlayerDB(i);
    }
    
}

// Display common Infected scores to each player.

public Action:timer_ShowTimerScore(Handle:timer, Handle:hndl)
{
    if (StatsDisabled())
        return;

    new Mode = GetConVarInt(cvar_AnnounceMode);
    decl String:Name[MAX_LINE_WIDTH];

    new maxplayers = GetMaxClients();
    for (new i = 1; i <= maxplayers; i++)
    {
        if (IsClientConnected(i) && IsClientInGame(i) && !IsClientBot(i))
        {
            // if (CurrentPoints[i] > GetConVarInt(cvar_MaxPoints))
            //     continue;

            if (TimerKills[i] > 0)
            {
                if (Mode == 1 || Mode == 2)
                {
                    PrintToChat(i, "\x04[\x03RANK\x04] \x01你已经获得 \x04%i \x01点积分 因为你杀死了 \x05%i \x01个感染者!", TimerPoints[i], TimerKills[i]);
                }
                else if (Mode == 3)
                {
                    GetClientName(i, Name, sizeof(Name));
                    PrintToChatAll("\x04[\x03RANK\x04] \x05%s \x01获得 \x04%i \x01点积分 因为他杀死了 \x05%i \x01个感染者!", Name, TimerPoints[i], TimerKills[i]);
                }
            }

            InterstitialPlayerUpdate(i);
        }

        TimerPoints[i] = 0;
        TimerKills[i] = 0;
        TimerHeadshots[i] = 0;
    }

}

// Update a player's stats, used for interstitial updating.

public InterstitialPlayerUpdate(client)
{
    if (StatsDisabled()) return;
    
    decl String:ClientID[MAX_LINE_WIDTH];
    GetClientName(client, ClientID, sizeof(ClientID));    

    new len = 0;
    decl String:query[1024];
    len += Format(query[len], sizeof(query)-len, "UPDATE players SET points = points + %i, ", TimerPoints[client]);
    len += Format(query[len], sizeof(query)-len, "kills = kills + %i, kill_infected = kill_infected + %i, ", TimerKills[client], TimerKills[client]);
    len += Format(query[len], sizeof(query)-len, "headshots = headshots + %i ", TimerHeadshots[client]);
    len += Format(query[len], sizeof(query)-len, "WHERE steamid = '%s'", ClientID);
    SendSQLUpdate(query);

    UpdateMapStat("kills", TimerKills[client]);
    UpdateMapStat("points", TimerPoints[client]);

    CurrentPoints[client] = CurrentPoints[client] + TimerPoints[client];
}

// Player Death event. Used for killing AI Infected. +2 on headshot, and global announcement.
// Team Kill code is in the awards section. Tank Kill code is in Tank section.

public Action:event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{

    new client = GetClientOfUserId(GetEventInt(event, "userid"));
		
    if(bVIP[client])
    {
    Vipdead();
    CreateTimer(3.0, viptext, 2);
    bVIP[client] = false;
    }
    
    haswepon[client] = false;
    	
    
    if (StatsDisabled())
        return;

    new Mode = GetConVarInt(cvar_AnnounceMode);
    new Attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

    if (GetEventBool(event, "attackerisbot") || !GetEventBool(event, "victimisbot"))
        return;

    decl String:AttackerID[MAX_LINE_WIDTH];
    GetClientName(Attacker, AttackerID, sizeof(AttackerID));
    decl String:AttackerName[MAX_LINE_WIDTH];
    GetClientName(Attacker, AttackerName, sizeof(AttackerName));

    decl String:VictimName[MAX_LINE_WIDTH];
    GetEventString(event, "victimname", VictimName, sizeof(VictimName));

    new Score = 0;
    decl String:InfectedType[8];

    if (StrEqual(VictimName, "Hunter"))
    {
        Format(InfectedType, sizeof(InfectedType), "hunter");
        Score = ModifyScoreDifficulty(2, 2, 3);
    }
    else if (StrEqual(VictimName, "Smoker"))
    {
        Format(InfectedType, sizeof(InfectedType), "smoker");
        Score = ModifyScoreDifficulty(3, 2, 3);
    }
    else if (StrEqual(VictimName, "Boomer"))
    {
        Format(InfectedType, sizeof(InfectedType), "boomer");
        Score = ModifyScoreDifficulty(5, 2, 3);
    }
    else
        return;

    new String:Headshot[32];
    if (GetEventBool(event, "headshot"))
    {
        Format(Headshot, sizeof(Headshot), ", headshots = headshots + 1");
        Score = Score + 2;
    }

    new len = 0;
    decl String:query[1024];
    len += Format(query[len], sizeof(query)-len, "UPDATE players SET points = points + %i, ", Score);
    len += Format(query[len], sizeof(query)-len, "kills = kills + 1, kill_%s = kill_%s + 1", InfectedType, InfectedType);
    len += Format(query[len], sizeof(query)-len, "%s WHERE steamid = '%s'", Headshot, AttackerID);
    SendSQLUpdate(query);

    if (Mode)
    {
        if (GetEventBool(event, "headshot"))
        {
            if (Mode > 1)
                PrintToChatAll("\x04[\x03RANK\x04] \x05%s \x01获得了 \x04%i \x01点积分,因为他杀死了 \x05%s \x01女巫 并且还是\x04爆头!", AttackerName, Score, VictimName);
            else
                PrintToChat(Attacker, "\x04[\x03RANK\x04] \x01获得了 \x04%i \x01点积分,因为你杀死了 \x05%s \x01女巫 并且还是 \x04爆头!", Score, VictimName);
        }
        else
        {
            if (Mode > 2)
                PrintToChatAll("\x04[\x03RANK\x04] \x05%s \x01获得了 \x04%i \x01点积分 因为他杀死了 \x05%s!", AttackerName, Score, VictimName);
            else
                PrintToChat(Attacker, "\x04[\x03RANK\x04] \x01获得了 \x04%i \x01点积分,因为你杀死了 \x05%s!", Score, VictimName);
        }
    }

    UpdateMapStat("kills", 1);
    UpdateMapStat("points", Score);
    CurrentPoints[Attacker] = CurrentPoints[Attacker] + Score;
}

// Common Infected death code. +1 on headshot.

public Action:event_InfectedDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
    if (StatsDisabled())
        return;

    new Attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

    if (!Attacker || IsClientBot(Attacker))
        return;

    decl String:AttackerID[MAX_LINE_WIDTH];
    GetClientName(Attacker, AttackerID, sizeof(AttackerID));
    decl String:AttackerName[MAX_LINE_WIDTH];
    GetClientName(Attacker, AttackerName, sizeof(AttackerName));

    new Score = ModifyScoreDifficulty(1, 2, 3);

    if (GetEventBool(event, "headshot"))
    {
        Score = Score + 1;
        TimerHeadshots[Attacker] = TimerHeadshots[Attacker] + 1;
    }

    TimerPoints[Attacker] = TimerPoints[Attacker] + Score;
    TimerKills[Attacker] = TimerKills[Attacker] + 1;
}

// Tank death code. Points are given to all players.

public Action:event_TankKilled(Handle:event, const String:name[], bool:dontBroadcast)
{
    if (StatsDisabled())
        return;

    if (CampaignOver)
        return;

    if (TankCount >= 3)
        return;

    new Mode = GetConVarInt(cvar_AnnounceMode);
    new Score = ModifyScoreDifficulty(25, 2, 4);

    new Deaths = 0;
    new Modifier = 0;

    new maxplayers = GetMaxClients();
    for (new i = 1; i <= maxplayers; i++)
    {
        if (IsClientConnected(i) && IsClientInGame(i) && !IsClientBot(i))
        {
            if (IsPlayerAlive(i))
                Modifier++;
            else
                Deaths++;
        }
    }

    Score = Score * Modifier;

    decl String:iID[MAX_LINE_WIDTH];
    decl String:query[512];

    for (new i = 1; i <= maxplayers; i++)
    {
        if (IsClientConnected(i) && IsClientInGame(i) && !IsClientBot(i))
        {
            GetClientName(i, iID, sizeof(iID));
            Format(query, sizeof(query), "UPDATE players SET points = points + %i, award_tankkill = award_tankkill + 1 WHERE steamid = '%s'", Score, iID);
            SendSQLUpdate(query);

            CurrentPoints[i] = CurrentPoints[i] + Score;
        }
    }

    if (Mode)
        PrintToChatAll("\x04[\x03RANK\x04] \x03所有幸存者 \x01获得了 \x04%i \x01点积分 因为杀死了Tank \x05%i 死亡!", Score, Deaths);

    UpdateMapStat("kills", 1);
    UpdateMapStat("points", Score);
    TankCount = TankCount + 1;
}

// Pill give code. Special note, Pills can only be given once.

public Action:event_GivePills(Handle:event, const String:name[], bool:dontBroadcast)
{
    if (StatsDisabled())
        return;

    new Recepient = GetClientOfUserId(GetEventInt(event, "userid"));
    new Giver = GetClientOfUserId(GetEventInt(event, "giver"));
    new Mode = GetConVarInt(cvar_AnnounceMode);

    if (IsClientBot(Recepient) || IsClientBot(Giver))
        return;

    new PillsID = GetEventInt(event, "weaponentid");

    if (Pills[PillsID] == 1)
        return;
    else
        Pills[PillsID] = 1;

    decl String:RecepientName[MAX_LINE_WIDTH];
    GetClientName(Recepient, RecepientName, sizeof(RecepientName));
    decl String:RecepientID[MAX_LINE_WIDTH];
    GetClientName(Recepient, RecepientID, sizeof(RecepientID));

    decl String:GiverName[MAX_LINE_WIDTH];
    GetClientName(Giver, GiverName, sizeof(GiverName));
    decl String:GiverID[MAX_LINE_WIDTH];
    GetClientName(Giver, GiverID, sizeof(GiverID));

    decl String:Item[16];

    if (GetEventInt(event, "weapon") == 12)
        Format(Item, sizeof(Item), "Pain Pills");
    else
        return;

    new Score = ModifyScoreDifficulty(1, 2, 4);

    decl String:query[1024];
    Format(query, sizeof(query), "UPDATE players SET points = points + %i, award_pills = award_pills + 1 WHERE steamid = '%s'", Score, GiverID);
    SendSQLUpdate(query);

    UpdateMapStat("points", Score);
    CurrentPoints[Giver] = CurrentPoints[Giver] + Score;

    if (Mode == 1 || Mode == 2)
        PrintToChat(Giver, "\x04[\x03RANK\x04] \x01你获得了 \x04%i \x01点积分,因为你给予了 \x05%s 药丸!", Score, RecepientName);
    else if (Mode == 3)
        PrintToChatAll("\x04[\x03RANK\x04] \x05%s \x01获得了 \x04%i \x01点积分,因为他给予了 \x05%s 药丸!", GiverName, Score, RecepientName);
}

// Medkit give code.

public Action:event_HealPlayer(Handle:event, const String:name[], bool:dontBroadcast)
{
    if (StatsDisabled())
        return;

    new Recepient = GetClientOfUserId(GetEventInt(event, "subject"));
    new Giver = GetClientOfUserId(GetEventInt(event, "userid"));
    new Amount = GetEventInt(event, "health_restored");
    new Mode = GetConVarInt(cvar_AnnounceMode);

    if (IsClientBot(Recepient) || IsClientBot(Giver))
        return;

    if (Recepient == Giver)
        return;

    decl String:RecepientName[MAX_LINE_WIDTH];
    GetClientName(Recepient, RecepientName, sizeof(RecepientName));
    decl String:RecepientID[MAX_LINE_WIDTH];
    GetClientName(Recepient, RecepientID, sizeof(RecepientID));

    decl String:GiverName[MAX_LINE_WIDTH];
    GetClientName(Giver, GiverName, sizeof(GiverName));
    decl String:GiverID[MAX_LINE_WIDTH];
    GetClientName(Giver, GiverID, sizeof(GiverID));

    new Score = (Amount + 1) / 2;
    if (GetConVarInt(cvar_MedkitMode))
        Score = ModifyScoreDifficulty(20, 2, 4);
    else
        Score = ModifyScoreDifficulty(Score, 2, 3);

    decl String:query[1024];
    Format(query, sizeof(query), "UPDATE players SET points = points + %i, award_medkit = award_medkit + 1 WHERE steamid = '%s'", Score, GiverID);
    SendSQLUpdate(query);

    UpdateMapStat("points", Score);
    CurrentPoints[Giver] = CurrentPoints[Giver] + Score;

    if (Mode == 1 || Mode == 2)
        PrintToChat(Giver, "\x04[\x03RANK\x04] \x01你获得了 \x04%i \x01点积分,因为你治愈了 \x05%s!", Score, RecepientName);
    else if (Mode == 3)
        PrintToChatAll("\x04[\x03RANK\x04] \x05%s \x01获得了 \x04%i \x01点积分,因为他治愈了 \x05%s!", GiverName, Score, RecepientName);
}

// Friendly fire code.

public Action:event_FriendlyFire(Handle:event, const String:name[], bool:dontBroadcast)
{
    if (StatsDisabled())
        return;

    new Attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    new Victim = GetClientOfUserId(GetEventInt(event, "victim"));
    new Mode = GetConVarInt(cvar_AnnounceMode);

    if (!Attacker || !Victim)
        return;

    if (IsClientBot(Victim))
        return;

    decl String:AttackerName[MAX_LINE_WIDTH];
    GetClientName(Attacker, AttackerName, sizeof(AttackerName));
    decl String:AttackerID[MAX_LINE_WIDTH];
    GetClientName(Attacker, AttackerID, sizeof(AttackerID));
    
    decl String:VictimName[MAX_LINE_WIDTH];
    GetClientName(Victim, VictimName, sizeof(VictimName));

    new Score = ModifyScoreDifficulty(25, 2, 4);
    Score = Score * -1;

    decl String:query[1024];
    Format(query, sizeof(query), "UPDATE players SET points = points + %i, award_friendlyfire = award_friendlyfire + 1 WHERE steamid = '%s'", Score, AttackerID);
    SendSQLUpdate(query);

    if (Mode == 1 || Mode == 2)
        PrintToChat(Attacker, "\x04[\x03RANK\x04] \x01你 \x03被扣除了 \x04%i \x01点积分,因为你 \x03攻击了队友 \x05%s!", Score, VictimName);
    else if (Mode == 3)
        PrintToChatAll("\x04[\x03RANK\x04] \x05%s \x01被 \x03扣除了 \x04%i \x01点积分,因为他 \x03攻击了 \x05%s!", AttackerName, Score, VictimName);
}

// Campaign win code. Points are based on maps completed + survivors.

public Action:event_CampaignWin(Handle:event, const String:name[], bool:dontBroadcast)
{
    if (StatsDisabled())
        return;

    CampaignOver = true;
    new Mode = GetConVarInt(cvar_AnnounceMode);

    new Score = ModifyScoreDifficulty(5, 4, 12);
    new SurvivorCount = GetEventInt(event, "survivorcount");
    new BaseScore = Score * SurvivorCount;
    
    decl String:query[1024];
    decl String:iID[MAX_LINE_WIDTH];
    decl String:Name[MAX_LINE_WIDTH];
    decl String:cookie[MAX_LINE_WIDTH];
    new Maps = 0;
    new WinScore = 0;

    new maxplayers = GetMaxClients();
    for (new i = 1; i <= maxplayers; i++)
    {
        if (IsClientConnected(i) && IsClientInGame(i) && !IsClientBot(i))
        {
            GetClientName(i, iID, sizeof(iID));

            GetClientCookie(i, Handle:ClientMaps, cookie, 32);
            Maps = StringToInt(cookie) + 1;

            if (Maps > 5)
                Maps = 5;

            WinScore = BaseScore * Maps;

            if (Mode == 1 || Mode == 2)
            {
                PrintToChat(i, "\x04[\x03RANK\x04] \x01你获得了 \x04%i \x01点积分,因为你和 (%i / 5) \x05%i 幸存者完成了战役!", WinScore, Maps, SurvivorCount);
            }
            else if (Mode == 3)
            {
                GetClientName(i, Name, sizeof(Name));
                PrintToChatAll("\x04[\x03RANK\x04] \x05%s \x01获得了 \x04%i \x01点积分,因为他和 (%i / 5) \x05%i 幸存者完成了战役!", Name, WinScore, Maps, SurvivorCount);
            }
       
            Format(query, sizeof(query), "UPDATE players SET points = points + %i, award_campaigns = award_campaigns + 1 WHERE steamid = '%s'", WinScore, iID);
            SendSQLUpdate(query);

            SetClientCookie(i, ClientMaps, "0");
            UpdateMapStat("points", WinScore);
            CurrentPoints[i] = CurrentPoints[i] + WinScore;
        }
    }
}

// Safe House reached code. Points are given to all players.
// Also, Witch Not Disturbed code, points also given to all players.

public Action:event_MapTransition(Handle:event, const String:name[], bool:dontBroadcast)
{
    if (StatsDisabled())
        return;

    new Mode = GetConVarInt(cvar_AnnounceMode);

    decl String:iID[MAX_LINE_WIDTH];
    decl String:query[1024];
    new maxplayers = GetMaxClients();
    new Score = ModifyScoreDifficulty(10, 5, 10);
    
    for (new i = 1; i <= maxplayers; i++)
    {
    	if (IsClientConnected(i) && IsClientInGame(i))
    	{
            okpassword[i] = true;
      }
    }

    if (WitchExists && !WitchDisturb)
    {
        for (new i = 1; i <= maxplayers; i++)
        {
            if (IsClientConnected(i) && IsClientInGame(i) && !IsClientBot(i))
            {
                GetClientName(i, iID, sizeof(iID));

                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score, iID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                CurrentPoints[i] = CurrentPoints[i] + Score;
            }
        }

        if (Mode)
            PrintToChatAll("\x04[\x03RANK\x04] \x03所有幸存者 \x01获得了 \x04%i \x01点积分因为 \x05很绅士并未有打扰女巫!", Score);
    }

    Score = 0;
    new Deaths = 0;
    new BaseScore = ModifyScoreDifficulty(10, 2, 5);
    
    for (new i = 1; i <= maxplayers; i++)
    {
        if (IsClientConnected(i) && IsClientInGame(i) && !IsClientBot(i))
        {

            if (IsPlayerAlive(i))
                Score = Score + BaseScore;
            else
                Deaths++;
        }
    }

    new String:All4Safe[64] = "";
    if (Deaths == 0)
        Format(All4Safe, sizeof(All4Safe), ", award_allinsafehouse = award_allinsafehouse + 1");
   
    decl String:cookie[MAX_LINE_WIDTH];
    new Maps = 0;

    for (new i = 1; i <= maxplayers; i++)
    {
        if (IsClientConnected(i) && IsClientInGame(i) && !IsClientBot(i))
        {
            InterstitialPlayerUpdate(i);

            GetClientCookie(i, Handle:ClientMaps, cookie, 32);
            Maps = StringToInt(cookie) + 1;
            IntToString(Maps, cookie, sizeof(cookie));
            SetClientCookie(i, ClientMaps, cookie);

            GetClientName(i, iID, sizeof(iID));
            Format(query, sizeof(query), "UPDATE players SET points = points + %i%s WHERE steamid = '%s'", Score, All4Safe, iID);
            SendSQLUpdate(query);
            UpdateMapStat("points", Score);
            CurrentPoints[i] = CurrentPoints[i] + Score;
        }
    }

    if (Mode)
        PrintToChatAll("\x04[\x03RANK\x04] \x03所有幸存者 \x01获得了 \x04%i \x01点积分 到达了安全屋 \x05%i 死亡!", Score, Deaths);

    PlayerVomited = false;
    PanicEvent = false;
}

// Begin panic event.

public Action:event_PanicEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
    if (StatsDisabled())
        return;

    if (CampaignOver || PanicEvent)
        return;

    PanicEvent = true;
    CreateTimer(75.0, timer_PanicEventEnd);
}

// Panic Event with no Incaps code. Points given to all players.

public Action:timer_PanicEventEnd(Handle:timer, Handle:hndl)
{
    if (StatsDisabled())
        return;

    if (CampaignOver)
        return;

    new Mode = GetConVarInt(cvar_AnnounceMode);

    if (PanicEvent && !PanicEventIncap)
    {
        new Score = ModifyScoreDifficulty(25, 2, 4);

        decl String:query[1024];
        decl String:iID[MAX_LINE_WIDTH];

        new maxplayers = GetMaxClients();
        for (new i = 1; i <= maxplayers; i++)
        {
            if (IsClientConnected(i) && IsClientInGame(i) && !IsClientBot(i))
            {
                GetClientName(i, iID, sizeof(iID));
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s' ", Score, iID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                CurrentPoints[i] = CurrentPoints[i] + Score;
            }
        }

        if (Mode)
            PrintToChatAll("\x04[\x03RANK\x04] \x03所有幸存者 \x01获得了 \x04%i \x01点积分,因为 \x05没有人在尸群事件中倒下!", Score);
    }

    PanicEvent = false;
    PanicEventIncap = false;
}

// Begin Boomer blind.

public Action:event_PlayerBlind(Handle:event, const String:name[], bool:dontBroadcast)
{
    if (StatsDisabled())
        return;

    if (CampaignOver || PlayerVomited)
        return;

    PlayerVomited = true;
}

// Boomer Mob Survival with no Incaps code. Points are given to all players.

public Action:event_PlayerBlindEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
    if (StatsDisabled())
        return;

    new Mode = GetConVarInt(cvar_AnnounceMode);

    if (PlayerVomited && !PlayerVomitedIncap)
    {
        new Score = ModifyScoreDifficulty(10, 2, 5);

        decl String:query[1024];
        decl String:iID[MAX_LINE_WIDTH];

        new maxplayers = GetMaxClients();
        for (new i = 1; i <= maxplayers; i++)
        {
            if (IsClientConnected(i) && IsClientInGame(i) && !IsClientBot(i))
            {
                GetClientName(i, iID, sizeof(iID));            
                Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s' ", Score, iID);
                SendSQLUpdate(query);
                UpdateMapStat("points", Score);
                CurrentPoints[i] = CurrentPoints[i] + Score;
            }
        }

        if (Mode)
            PrintToChatAll("\x04[\x03RANK\x04] \x03所有幸存者 \x01获得了 \x04%i \x01点积分因为 \x05没有人在胖子炸弹事件后倒下!", Score);
    }

    PlayerVomited = false;
    PlayerVomitedIncap = false;
}

// Friendly Incapicitate code. Also handles if players should be awarded
// points for surviving a Panic Event or Boomer Mob without incaps.

public Action:event_PlayerIncap(Handle:event, const String:name[], bool:dontBroadcast)
{
    if (StatsDisabled())
        return;

    new Attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    new Victim = GetClientOfUserId(GetEventInt(event, "userid"));
    new Mode = GetConVarInt(cvar_AnnounceMode);

    if (PanicEvent)
        PanicEventIncap = true;

    if (PlayerVomited)
        PlayerVomitedIncap = true;

    if (!Attacker)
        return;

    if (IsClientBot(Attacker) || IsClientBot(Victim))
        return;

    decl String:AttackerID[MAX_LINE_WIDTH];
    GetClientName(Attacker, AttackerID, sizeof(AttackerID));
    decl String:AttackerName[MAX_LINE_WIDTH];
    GetClientName(Attacker, AttackerName, sizeof(AttackerName));

    decl String:VictimName[MAX_LINE_WIDTH];
    GetClientName(Victim, VictimName, sizeof(VictimName));

    new Score = ModifyScoreDifficulty(75, 2, 4);
    Score = Score * -1;

    decl String:query[512];
    Format(query, sizeof(query), "UPDATE players SET points = points + %i WHERE steamid = '%s'", Score, AttackerID);
    SendSQLUpdate(query);

    if (Mode == 1 || Mode == 2)
        PrintToChat(Attacker, "\x04[\x03RANK\x04] \x01你 \x03被扣除了 \x04%i \x01点积分,因为你 \x03由于 \x05%s 倒下了!", Score, VictimName);
    else if (Mode == 3)
        PrintToChatAll("\x04[\x03RANK\x04] \x05%s \x01被 \x03扣除了 \x04%i \x01点积分,因为他 \x03倒下了由于 \x05%s!", AttackerName, Score, VictimName);
}

// Save friendly from being dragged by Smoker.

public Action:event_TongueSave(Handle:event, const String:name[], bool:dontBroadcast)
{
    if (StatsDisabled())
        return;

    HunterSmokerSave(GetEventInt(event, "userid"), GetEventInt(event, "victim"), 5, 2, 3, "Smoker", "award_smoker");
}

// Save friendly from being choked by Smoker.

public Action:event_ChokeSave(Handle:event, const String:name[], bool:dontBroadcast)
{
    if (StatsDisabled())
        return;

    HunterSmokerSave(GetEventInt(event, "userid"), GetEventInt(event, "victim"), 10, 2, 3, "Smoker", "award_smoker");
}

// Save friendly from being pounced by Hunter.

public Action:event_PounceSave(Handle:event, const String:name[], bool:dontBroadcast)
{
    if (StatsDisabled())
        return;

    HunterSmokerSave(GetEventInt(event, "userid"), GetEventInt(event, "victim"), 10, 2, 3, "Hunter", "award_hunter");
}

// Revive friendly code.

public Action:event_RevivePlayer(Handle:event, const String:name[], bool:dontBroadcast)
{
    if (StatsDisabled())
        return;

    if (GetEventBool(event, "ledge_hang"))
        return;

    new Savior = GetClientOfUserId(GetEventInt(event, "userid"));
    new Victim = GetClientOfUserId(GetEventInt(event, "subject"));
    new Mode = GetConVarInt(cvar_AnnounceMode);

    if (IsClientBot(Savior) || IsClientBot(Victim))
        return;

    decl String:SaviorName[MAX_LINE_WIDTH];
    GetClientName(Savior, SaviorName, sizeof(SaviorName));
    decl String:SaviorID[MAX_LINE_WIDTH];
    GetClientName(Savior, SaviorID, sizeof(SaviorID));

    decl String:VictimName[MAX_LINE_WIDTH];
    GetClientName(Victim, VictimName, sizeof(VictimName));
    decl String:VictimID[MAX_LINE_WIDTH];
    GetClientName(Victim, VictimID, sizeof(VictimID));

    new Score = ModifyScoreDifficulty(15, 2, 3);

    decl String:query[1024];
    Format(query, sizeof(query), "UPDATE players SET points = points + %i, award_revive = award_revive + 1 WHERE steamid = '%s'", Score, SaviorID);
    SendSQLUpdate(query);

    UpdateMapStat("points", Score);
    CurrentPoints[Savior] = CurrentPoints[Savior] + Score;

    if (Mode == 1 || Mode == 2)
        PrintToChat(Savior, "\x04[\x03RANK\x04] \x01你获得了 \x04%i \x01点积分 因为你帮助了 \x05%s!", Score, VictimName);
    else if (Mode == 3)
        PrintToChatAll("\x04[\x03RANK\x04] \x05%s \x01获得了 \x04%i \x01点积分 因为他帮助了 \x05%s!", SaviorName, Score, VictimName);
}

// Miscellaneous events and awards. See specific award for info.

public Action:event_Award(Handle:event, const String:name[], bool:dontBroadcast)
{
    if (StatsDisabled())
        return;

    new PlayerID = GetEventInt(event, "userid");
    new SubjectID = GetEventInt(event, "subjectentid");
    new Mode = GetConVarInt(cvar_AnnounceMode);

    if (!PlayerID)
        return;
        
    new User = GetClientOfUserId(PlayerID);

    decl String:UserID[MAX_LINE_WIDTH];
    GetClientName(User, UserID, sizeof(UserID));
    decl String:UserName[MAX_LINE_WIDTH];
    GetClientName(User, UserName, sizeof(UserName));

    if (IsClientBot(User))
        return;

    new Recepient;
    decl String:RecepientName[MAX_LINE_WIDTH];

    new Score = 0;
    new String:AwardSQL[128];
    new AwardID = GetEventInt(event, "award");

    if (AwardID == 67) // Protect friendly
    {
        if (!SubjectID)
            return;

        Recepient = GetClientOfUserId(GetClientUserId(SubjectID));
        GetClientName(Recepient, RecepientName, sizeof(RecepientName));

        if (IsClientBot(Recepient))
            return;

        Format(AwardSQL, sizeof(AwardSQL), ", award_protect = award_protect + 1");
        Score = ModifyScoreDifficulty(3, 2, 3);
        UpdateMapStat("points", Score);
        CurrentPoints[User] = CurrentPoints[User] + Score;

        if (Mode == 1 || Mode == 2)
            PrintToChat(User, "\x04[\x03RANK\x04] \x01你获得了 \x04%i \x01点积分,因为你保护了 \x05%s!", Score, RecepientName);
        else if (Mode == 3)
            PrintToChatAll("\x04[\x03RANK\x04] \x05%s \x01获得了 \x04%i \x01点积分,因为他保护了 \x05%s!", UserName, Score, RecepientName);
    }
    else if (AwardID == 79) // Respawn friendly
    {
        if (!SubjectID)
            return;

        Recepient = GetClientOfUserId(GetClientUserId(SubjectID));
        GetClientName(Recepient, RecepientName, sizeof(RecepientName));

        if (IsClientBot(Recepient))
            return;

        Format(AwardSQL, sizeof(AwardSQL), ", award_rescue = award_rescue + 1");
        Score = ModifyScoreDifficulty(10, 2, 3);
        UpdateMapStat("points", Score);
        CurrentPoints[User] = CurrentPoints[User] + Score;

        if (Mode == 1 || Mode == 2)
            PrintToChat(User, "\x04[\x03RANK\x04] \x01你获得了 \x04%i \x01点积分,因为你拯救了 \x05%s!", Score, RecepientName);
        else if (Mode == 3)
            PrintToChatAll("\x04[\x03RANK\x04] \x05%s \x01获得了 \x04%i \x01点积分,因为他拯救了 \x05%s!", UserName, Score, RecepientName);
    }
    else if (AwardID == 80) // Kill Tank with no deaths
    {
        Format(AwardSQL, sizeof(AwardSQL), ", award_tankkillnodeaths = award_tankkillnodeaths + 1");
        Score = ModifyScoreDifficulty(0, 1, 1);
    }
    else if (AwardID == 83) // Team kill
    {
        if (!SubjectID)
            return;

        Recepient = GetClientOfUserId(GetClientUserId(SubjectID));

        if (IsClientBot(Recepient))
            return;

        Format(AwardSQL, sizeof(AwardSQL), ", award_teamkill = award_teamkill + 1");
        Score = ModifyScoreDifficulty(250, 2, 4);
        Score = Score * -1;

        if (Mode == 1 || Mode == 2)
            PrintToChat(User, "\x04[\x03RANK\x04] \x01你 \x03被扣除了 \x04%i \x01点积分因为你 \x03TK!", Score);
        else if (Mode == 3)
            PrintToChatAll("\x04[\x03RANK\x04] \x05%s \x01被 \x03扣除了 \x04%i \x01点积分,因为他 \x03TK!", UserName, Score);
    }
    else if (AwardID == 85) // Left friendly for dead
    {
        Format(AwardSQL, sizeof(AwardSQL), ", award_left4dead = award_left4dead + 1");
        Score = ModifyScoreDifficulty(0, 1, 1);
    }
    else if (AwardID == 94) // Let infected in safe room
    {
        Format(AwardSQL, sizeof(AwardSQL), ", award_letinsafehouse = award_letinsafehouse + 1");
        Score = ModifyScoreDifficulty(5, 2, 4);
        Score = Score * -1;

        if (Mode == 1 || Mode == 2)
            PrintToChat(User, "\x04[\x03RANK\x04] \x01你 \x03被扣除了 \x04%i \x01点积分因为你 \x03让感染者进到了安全屋!", Score);
        else if (Mode == 3)
            PrintToChatAll("\x04[\x03RANK\x04] \x05%s \x01被 \x03扣除了 \x04%i \x01点积分,因为他 \x03让感染者进到了安全屋!", UserName, Score);
    }
    else if (AwardID == 98) // Round restart
    {
        Score = ModifyScoreDifficulty(100, 2, 3);
        Score = (400 - Score) * -1;
        UpdateMapStat("restarts", 1);

        if (Mode)
            PrintToChat(User, "\x04[\x03RANK\x04] \x03所有幸存者 \x01被 \x03扣除了 \x04%i \x01点积分,因为你们不够勇猛 \x03全员阵亡!", Score);
    }
    else
        return;

    decl String:query[1024];
    Format(query, sizeof(query), "UPDATE players SET points = points + %i%s WHERE steamid = '%s'", Score, AwardSQL, UserID);
    SendSQLUpdate(query);
}

// Reset Witch existence in the world when a new one is created.

public Action:event_WitchSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
    if (StatsDisabled())
        return;

    WitchExists = true;
}

// Witch was disturbed!

public Action:event_WitchDisturb(Handle:event, const String:name[], bool:dontBroadcast)
{
    if (StatsDisabled())
        return;

    if (WitchExists)
    {
        WitchDisturb = true;

        if (!GetEventInt(event, "userid"))
            return;

        new User = GetClientOfUserId(GetEventInt(event, "userid"));

        if (IsClientBot(User))
            return;

        decl String:UserID[MAX_LINE_WIDTH];
        GetClientName(User, UserID, sizeof(UserID));

        decl String:query[1024];
        Format(query, sizeof(query), "UPDATE players SET award_witchdisturb = award_witchdisturb + 1 WHERE steamid = '%s'", UserID);
        SendSQLUpdate(query);
    }
}

/*
-----------------------------------------------------------------------------
Chat/command handling and panels for Rank and Top10
-----------------------------------------------------------------------------
*/

// Parse chat for RANK and TOP10 triggers.
public Action:cmd_Say(client, args)
{
    decl String:Text[192];
    new String:Command[64];
    new Start = 0;

    GetCmdArgString(Text, sizeof(Text));

    if (Text[strlen(Text)-1] == '"')
    {		
        Text[strlen(Text)-1] = '\0';
        Start = 1;	
    }

    if (strcmp(Command, "say2", false) == 0)
        Start += 4;

    if (strcmp(Text[Start], "rank", false) == 0)
    {
        cmd_ShowRank(client, 0);
        if (GetConVarBool(cvar_SilenceChat))
            return Plugin_Handled;
    }

    if (strcmp(Text[Start], "top10", false) == 0)
    {
        cmd_ShowTop10(client, 0);
        if (GetConVarBool(cvar_SilenceChat))
            return Plugin_Handled;
    }

    return Plugin_Continue;
}

// Begin generating the RANK display panel.
public Action:cmd_ShowRank(client, args)
{
    if (StatsDisabled()) return Plugin_Handled;
    
    if (!IsClientConnected(client) && !IsClientInGame(client))
        return Plugin_Handled;

    if (IsClientBot(client))
        return Plugin_Handled;

    decl String:SteamID[MAX_LINE_WIDTH];
    GetClientName(client, SteamID, sizeof(SteamID));

    decl String:query[256];
    Format(query, sizeof(query), "SELECT COUNT(*) FROM players");
    SQL_TQuery(db, GetRankTotal, query, client);

    Format(query, sizeof(query), "SELECT COUNT(*) FROM players WHERE points >=%i", ClientPoints[client]);
    SQL_TQuery(db, GetClientRank, query, client);

    Format(query, sizeof(query), "SELECT name, playtime, points, kills, headshots FROM players WHERE steamid = '%s'", SteamID);
    SQL_TQuery(db, DisplayRank, query, client);

    return Plugin_Handled;
}

// Generate client's point total.
public GetClientPoints(Handle:owner, Handle:hndl, const String:error[], any:data)
{
    new client = data;

    if (!client || hndl == INVALID_HANDLE)
        return;

    while (SQL_FetchRow(hndl))
        ClientPoints[client] = SQL_FetchInt(hndl, 0);
}

public GetClientPassword(Handle:owner, Handle:hndl, const String:error[], any:data)
{
    new client = data;

    if (!client || hndl == INVALID_HANDLE)
        return;

    while (SQL_FetchRow(hndl))
    		SQL_FetchString(hndl, 0,spassword[client],sizeof(spassword));
}

public GetClientlastbuyonline(Handle:owner, Handle:hndl, const String:error[], any:data)
{
    new client = data;

    if (!client || hndl == INVALID_HANDLE)
        return;

    while (SQL_FetchRow(hndl))
    		lastbuytime[client] = SQL_FetchInt(hndl, 0);
}

public GetClientlastbuyitemstime(Handle:owner, Handle:hndl, const String:error[], any:data)
{
    new client = data;

    if (!client || hndl == INVALID_HANDLE)
        return;

    while (SQL_FetchRow(hndl))
    		lastbuyitemstime[client] = SQL_FetchInt(hndl, 0);
}

/*
public GetLastOnlineTime(Handle:owner, Handle:hndl, const String:error[], any:data)
{
    new client = data;

    if (!client || hndl == INVALID_HANDLE)
        return;

    while (SQL_FetchRow(hndl))
    		lastonelinetime[client] = SQL_FetchInt(hndl, 0);
}
*/

public GetBuyItems(Handle:owner, Handle:hndl, const String:error[], any:data)
{
    new client = data;

    if (!client || hndl == INVALID_HANDLE)
        return;

    while (SQL_FetchRow(hndl))
    		buyitems[client] = SQL_FetchInt(hndl, 0);
}


public GetBuyWeapon(Handle:owner, Handle:hndl, const String:error[], any:data)
{
    new client = data;

    if (!client || hndl == INVALID_HANDLE)
        return;

    while (SQL_FetchRow(hndl))
    		buyweapon[client] = SQL_FetchInt(hndl, 0);
}

// Generate client's rank.
public GetClientRank(Handle:owner, Handle:hndl, const String:error[], any:data)
{
    new client = data;

    if (!client || hndl == INVALID_HANDLE)
        return;

    while (SQL_FetchRow(hndl))
        ClientRank[client] = SQL_FetchInt(hndl, 0);
}

// Generate total rank amount.
public GetRankTotal(Handle:owner, Handle:hndl, const String:error[], any:data)
{
    if (hndl == INVALID_HANDLE)
        return;

    while (SQL_FetchRow(hndl))
        RankTotal = SQL_FetchInt(hndl, 0);
}

// Send the RANK panel to the client's display.
public DisplayRank(Handle:owner, Handle:hndl, const String:error[], any:data)
{
    new client = data;

    if (!client || hndl == INVALID_HANDLE)
        return;

    new Playtime, Points, Kills, Headshots;
    new String:Name[32];

    while (SQL_FetchRow(hndl))
    {
        SQL_FetchString(hndl, 0, Name, sizeof(Name));
        Playtime = SQL_FetchInt(hndl, 1);
        Points = SQL_FetchInt(hndl, 2);
        Kills = SQL_FetchInt(hndl, 3);
        Headshots = SQL_FetchInt(hndl, 4);
    }

    new Handle:RankPanel = CreatePanel();
    new String:Value[MAX_LINE_WIDTH];

    new Float:HeadshotRatio = Headshots == 0 ? 0.00 : FloatDiv(float(Headshots), float(Kills))*100;

    Format(Value, sizeof(Value), "统计信息: %s" , Name);
    SetPanelTitle(RankPanel, Value);

    Format(Value, sizeof(Value), "排名: 第 %i 名 共 %i 玩家" , ClientRank[client], RankTotal);
    DrawPanelText(RankPanel, Value);

    if (Playtime > 60)
    {
        Format(Value, sizeof(Value), "游戏时间: %.2f 小时" , FloatDiv(float(Playtime), 60.0));
        DrawPanelText(RankPanel, Value);
    }
    else
    {
        Format(Value, sizeof(Value), "游戏时间: %i 分钟" , Playtime);
        DrawPanelText(RankPanel, Value);
    }

    Format(Value, sizeof(Value), "积分: %i" , Points);
    DrawPanelText(RankPanel, Value);

    Format(Value, sizeof(Value), "杀死僵尸: %i" , Kills);
    DrawPanelText(RankPanel, Value);

    Format(Value, sizeof(Value), "爆头: %i" , Headshots);
    DrawPanelText(RankPanel, Value);

    Format(Value, sizeof(Value), "爆头 比率: %.2f \%" , HeadshotRatio);
    DrawPanelText(RankPanel, Value);


    Format(Value, sizeof(Value), "完整的统计信息请访问 http://www.sy64.com/status/");
    DrawPanelText(RankPanel, Value);


    DrawPanelItem(RankPanel, "关闭");
    SendPanelToClient(RankPanel, client, RankPanelHandler, 30);
    CloseHandle(RankPanel);
}

// Generate the TOP10 display panel.
public Action:cmd_ShowTop10(client, args)
{
    if (StatsDisabled()) return Plugin_Handled;
    
    if (!IsClientConnected(client) && !IsClientInGame(client) && IsClientBot(client))
        return Plugin_Handled;

    decl String:query[256];
    Format(query, sizeof(query), "SELECT COUNT(*) FROM players");
    SQL_TQuery(db, GetRankTotal, query, client);

    Format(query, sizeof(query), "SELECT steamid FROM players ORDER BY points DESC LIMIT 10");
    SQL_TQuery(db, DisplayTop10, query, client);

    return Plugin_Handled;
}

// Find a player from Top 10 ranking.
public GetClientFromTop10(client, rank)
{
    if (StatsDisabled()) return;
    
    decl String:query[256];
    Format(query, sizeof(query), "SELECT points, steamid FROM players ORDER BY points DESC LIMIT %i,1", rank);
    SQL_TQuery(db, GetClientTop10, query, client);
}

// Send the Top 10 player's info to the client.
public GetClientTop10(Handle:owner, Handle:hndl, const String:error[], any:data)
{
    new client = data;

    if (!client || hndl == INVALID_HANDLE)
        return;

    decl String:query[256];
    decl String:SteamID[MAX_LINE_WIDTH];

    while (SQL_FetchRow(hndl))
    {
        Format(query, sizeof(query), "SELECT COUNT(*) FROM players WHERE points >=%i", SQL_FetchInt(hndl, 0));
        SQL_TQuery(db, GetClientRank, query, client);

        SQL_FetchString(hndl, 1, SteamID, sizeof(SteamID));
        Format(query, sizeof(query), "SELECT steamid, playtime, points, kills, headshots FROM players WHERE steamid = '%s'", SteamID);
        SQL_TQuery(db, DisplayRank, query, client);
    }
}

// Send the TOP10 panel to the client's display.
public DisplayTop10(Handle:owner, Handle:hndl, const String:error[], any:data)
{
    new client = data;

    if (!client || hndl == INVALID_HANDLE)
        return;

    new String:Name[32];

    new Handle:Top10Panel = CreatePanel();
    SetPanelTitle(Top10Panel, "排名前10的玩家");

    while (SQL_FetchRow(hndl))
    {
        SQL_FetchString(hndl, 0, Name, sizeof(Name));

        ReplaceString(Name, sizeof(Name), "&lt;", "<");
        ReplaceString(Name, sizeof(Name), "&gt;", ">");
        ReplaceString(Name, sizeof(Name), "&#37;", "%");
        ReplaceString(Name, sizeof(Name), "&#61;", "=");
        ReplaceString(Name, sizeof(Name), "&#42;", "*");

        DrawPanelItem(Top10Panel, Name);
    }

    SendPanelToClient(Top10Panel, client, Top10PanelHandler, 30);
    CloseHandle(Top10Panel);
}

// Handler for RANK panel.
public RankPanelHandler(Handle:menu, MenuAction:action, param1, param2)
{
}

// Handler for TOP10 panel.
public Top10PanelHandler(Handle:menu, MenuAction:action, param1, param2)
{
    if (action == MenuAction_Select)
    {
        if (param2 == 0)
            param2 = 10;

        GetClientFromTop10(param1, param2 - 1);
    }
}

/*
-----------------------------------------------------------------------------
Private functions
-----------------------------------------------------------------------------
*/

HunterSmokerSave(Savior, Victim, BasePoints, AdvMult, ExpertMult, String:SaveFrom[], String:SQLField[])
{
    if (StatsDisabled())
        return;

    Savior = GetClientOfUserId(Savior);
    Victim = GetClientOfUserId(Victim);

    if (IsClientBot(Savior) || IsClientBot(Victim))
        return;

    decl String:SaviorName[MAX_LINE_WIDTH];
    GetClientName(Savior, SaviorName, sizeof(SaviorName));
    decl String:SaviorID[MAX_LINE_WIDTH];
    GetClientName(Savior, SaviorID, sizeof(SaviorID));

    decl String:VictimName[MAX_LINE_WIDTH];
    GetClientName(Victim, VictimName, sizeof(VictimName));
    decl String:VictimID[MAX_LINE_WIDTH];
    GetClientName(Victim, VictimID, sizeof(VictimID));

    if (StrEqual(SaviorID, VictimID))
        return;

    new Score = ModifyScoreDifficulty(BasePoints, AdvMult, ExpertMult);

    decl String:query[1024];
    Format(query, sizeof(query), "UPDATE players SET points = points + %i, %s = %s + 1 WHERE steamid = '%s'", Score, SQLField, SQLField, SaviorID);
    SendSQLUpdate(query);

    PrintToChat(Savior, "\x04[\x03RANK\x04] \x01你获得了 \x04%i \x01点积分 因为你拯救了 \x05%s\x01 从特殊感染者 \x04%s 的镰刀之下!", Score, VictimName, SaveFrom);
    UpdateMapStat("points", Score);
    CurrentPoints[Savior] = CurrentPoints[Savior] + Score;
}

IsClientBot(client)
{
    decl String:SteamID[MAX_LINE_WIDTH];
    GetClientAuthString(client, SteamID, sizeof(SteamID));

    if (StrEqual(SteamID, "BOT"))
        return true;

    return false;
}

ModifyScoreDifficulty(BaseScore, AdvMult, ExpMult)
{
    decl String:Difficulty[MAX_LINE_WIDTH];
    GetConVarString(cvar_Difficulty, Difficulty, sizeof(Difficulty));

    if (StrEqual(Difficulty, "Hard")) BaseScore = BaseScore * AdvMult;
    if (StrEqual(Difficulty, "Impossible")) BaseScore = BaseScore * ExpMult;

    return BaseScore;
}

IsDifficultyEasy()
{
    decl String:Difficulty[MAX_LINE_WIDTH];
    GetConVarString(cvar_Difficulty, Difficulty, sizeof(Difficulty));

    if (StrEqual(Difficulty, "Easy"))
        return true;

    return false;
}

InvalidGameMode()
{
    new String:CurrentMode[16];
    GetConVarString(cvar_Gamemode, CurrentMode, sizeof(CurrentMode));

    // Currently will always return False in Survival and Versus gamemodes.
    // This will be removed in a future version when stats for those versions work.

    if (StrContains(CurrentMode, "coop", false) != -1 && GetConVarBool(cvar_EnableCoop))
        return false;
    else if (StrContains(CurrentMode, "survival", false) != -1)
        return true;
    else if (StrContains(CurrentMode, "versus", false) != -1)
        return true;

    return true;
}

CheckHumans()
{
    new MinHumans = GetConVarInt(cvar_HumansNeeded);
    new Humans = 0;
    new maxplayers = GetMaxClients();

    for (new i = 1; i <= maxplayers; i++)
    {
        if (IsClientConnected(i) && IsClientInGame(i) && !IsClientBot(i))
            Humans++;
    }

    if (Humans < MinHumans)
        return true;
    else
        return false;
}

ResetVars()
{
    PlayerVomited = false;
    PlayerVomitedIncap = false;
    PanicEvent = false;
    PanicEventIncap = false;
    CampaignOver = false;
    WitchExists = false;
    WitchDisturb = false;

    // Reset kill/point score timer amount
    CreateTimer(1.0, InitPlayers);

    TankCount = 0;

    new maxplayers = GetMaxClients();
    for (new i = 1; i <= maxplayers; i++)
    {
        CurrentPoints[i] = 0;
    }
}

StatsDisabled()
{
    if (InvalidGameMode())
        return true;

    if (IsDifficultyEasy())
        return true;

    if (CheckHumans())
        return true;

    if (GetConVarBool(cvar_Cheats))
        return true;

    if (db == INVALID_HANDLE)
        return true;

    return false;
}
