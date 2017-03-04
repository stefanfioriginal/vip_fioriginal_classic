#include <amxmodx>
#include <cstrike>
#include <fun>
#include <hamsandwich>
#include <engine>
#include <fakemeta>
#include <colorchat>

#define VIP_LEVEL_ACCES ADMIN_LEVEL_F

#define SCOREATTRIB_NONE    0
#define SCOREATTRIB_DEAD    ( 1 << 0 )
#define SCOREATTRIB_BOMB    ( 1 << 1 )
#define SCOREATTRIB_VIP     ( 1 << 2 )

#define REMOVE_FLAGS "r"

new const RMaps [ ] [ ] =
{
	"35hp",
	"35hp_2",
	"31hp",
	"1hp",
	"100hp"
};

new const g_szBeginning[ ] = "Membrii VIP"

const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90);
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE);

new g_szMessage[ 256 ];
new cvar_vip_maxap, cvar_vip_maxhp, cvar_vip_showC, cvar_vip_showH, cvar_vip_in_out, cvar_tag, cvar_start_hp, cvar_start_ap, cvar_start_money, cvar_vip_jump, cvar_hp_kill, cvar_ap_kill, jumpnum[33], bool: dojump[33], SyncHudMessage, contor;

public plugin_init() 
{
	register_plugin("Classic VIP-FIROGINAL.RO", "5.1.2", "Devil aKa. StefaN@CSX");
	
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
	
	register_clcmd("say /vip", "vip_info");
	register_clcmd("say", "handle_say");
	register_clcmd("say_team", "handle_say");
	
	register_event("DeathMsg", "eDeathMsg", "a");
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0");
	register_message(get_user_msgid( "ScoreAttrib" ), "MessageScoreAttrib");	

	cvar_tag = register_cvar("amx_vip_tag", "VIP");
	cvar_start_hp = register_cvar("amx_start_hp", "150");
	cvar_start_ap = register_cvar("amx_start_ap", "180");
	cvar_start_money = register_cvar("amx_start_money", "8000");
	cvar_vip_jump = register_cvar("amx_vip_jump", "1" );
	cvar_hp_kill = register_cvar("amx_vip_addhp", "10");	
	cvar_ap_kill = register_cvar("amx_vip_addap", "10");
	cvar_vip_in_out = register_cvar("amx_vip_in_out", "1");
	cvar_vip_showC = register_cvar("amx_vip_show_chat", "1");
	cvar_vip_showH = register_cvar("amx_vip_show_hud", "1");
	cvar_vip_maxhp = register_cvar("amx_vip_maxhp", "180");
	cvar_vip_maxap = register_cvar("amx_vip_maxap", "200");	

	set_task(120.0, "mesaj_info", _, _, _, "b");
	set_task( 1.0, "TaskDisplayVips", _, _, _, "b", 0 );
	SyncHudMessage = CreateHudSyncObj( );
		
}

public Event_NewRound()
{	
	if (++contor > 3)
		{
			new players[32], matchedplayers;
			get_players(players, matchedplayers, "ch")
			for(new i = 0; i < matchedplayers; ++i)
					vip_menu(players[i])
		}
}

public vip_menu(id) 
{	
	if( !(get_user_flags(id) & VIP_LEVEL_ACCES) )
		return;
	
	new menu
	switch(cs_get_user_team(id))
	{
		case CS_TEAM_CT:
		{
			menu = menu_create("\y[\rVIP Classic\y] \wMeniu \yVIP", "menu_ammunition");
			menu_additem(menu, "M4a1+Deagle+Set grenăzi", "1");
			menu_additem(menu, "Famas+Deagle+Set grenăzi", "2");
			menu_additem(menu, "Awp+Deagle+Set grenăzi", "3");
		}
	
		case CS_TEAM_T:
		{
			menu = menu_create("\y[\rVIP Classic\y] \wMeniu \yVIP", "menu_ammunition");
			menu_additem(menu, "Ak47+Deagle+Set grenăzi", "1");
			menu_additem(menu, "Galil+Deagle+Set grenăzi", "2");
			menu_additem(menu, "Awp+Deagle+Set grenăzi", "3");
		}
	}
	menu_display(id, menu, 0)
}

public menu_ammunition ( id, menu, item ) 
{
	new tag[32];
	get_pcvar_string(cvar_tag, tag, charsmax(tag));
	
	if(item == MENU_EXIT)
	{
		return PLUGIN_HANDLED;
	}

	new data[6], szName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback);
	new key = str_to_num(data);

	if(cs_get_user_team(id) == CS_TEAM_CT)
		switch(key)
	{
		case 1:
	{
			drop_weapons(id, 1)
			drop_weapons(id, 2)
			give_item(id, "weapon_knife");	
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_deagle");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			cs_set_user_bpammo(id, CSW_HEGRENADE, 1);
			cs_set_user_bpammo(id, CSW_FLASHBANG, 2);
			cs_set_user_bpammo(id, CSW_M4A1, 90);
			cs_set_user_bpammo(id, CSW_DEAGLE, 35);
			ColorChat(id,GREEN,"^4[%s] ^1Ai ales ^4M4a1^1+^4Deagle^1+^4Set grenazi^1.",tag);
	}
		case 2:
	{
			drop_weapons(id, 1)
			drop_weapons(id, 2)
			give_item(id, "weapon_knife");
			give_item(id, "weapon_famas");
			give_item(id, "weapon_deagle");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			cs_set_user_bpammo(id, CSW_HEGRENADE, 1);
			cs_set_user_bpammo(id, CSW_FLASHBANG, 2);
			cs_set_user_bpammo(id, CSW_FAMAS, 90);
			cs_set_user_bpammo(id, CSW_DEAGLE, 35);
			ColorChat(id,GREEN,"^4[%s] ^1Ai ales ^4Famas^1+^4Deagle^1+^4Set grenazi^1.",tag);
	}
		case 3:
	{
			drop_weapons(id, 1)
			drop_weapons(id, 2)
			give_item(id, "weapon_knife");
			give_item(id, "weapon_awp");
			give_item(id, "weapon_deagle");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			cs_set_user_bpammo(id, CSW_HEGRENADE, 1);
			cs_set_user_bpammo(id, CSW_FLASHBANG, 2);
			cs_set_user_bpammo(id, CSW_AWP, 30);
			cs_set_user_bpammo(id, CSW_DEAGLE, 35);
			ColorChat(id,GREEN,"^4[%s] ^1Ai ales ^4Awp^1+^4Deagle^1+^4Set grenazi^1.",tag);
	}      
}
	if(cs_get_user_team(id) == CS_TEAM_T)
		switch(key)
	{
		case 1:
	{
			drop_weapons(id, 1)
			drop_weapons(id, 2)
			give_item(id, "weapon_knife");
			give_item(id, "weapon_ak47");
			give_item(id, "weapon_deagle");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			cs_set_user_bpammo(id, CSW_HEGRENADE, 1);
			cs_set_user_bpammo(id, CSW_FLASHBANG, 2);
			cs_set_user_bpammo(id, CSW_AK47, 90);
			cs_set_user_bpammo(id, CSW_DEAGLE, 35);
			ColorChat(id,GREEN,"^4[%s] ^1Ai ales ^4Ak47^1+^4Deagle^1+^4Set grenazi^1.",tag);
	}      
		case 2:
	{
			drop_weapons(id, 1)
			drop_weapons(id, 2)
			give_item(id, "weapon_knife");
			give_item(id, "weapon_galil");
			give_item(id, "weapon_deagle");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			cs_set_user_bpammo(id, CSW_HEGRENADE, 1);
			cs_set_user_bpammo(id, CSW_FLASHBANG, 2);
			cs_set_user_bpammo(id, CSW_GALIL, 90);
			cs_set_user_bpammo(id, CSW_DEAGLE, 35);
			ColorChat(id,GREEN,"^4[%s] ^1Ai ales ^4Galil^1+^4Deagle^1+^4Set grenazi^1.",tag);
	}
		case 3:
	{
			drop_weapons(id, 1)
			drop_weapons(id, 2)
			give_item(id, "weapon_knife");
			give_item(id, "weapon_awp");
			give_item(id, "weapon_deagle");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			give_item(id, "weapon_smokegrenade");
			cs_set_user_bpammo(id, CSW_FLASHBANG, 2);
			cs_set_user_bpammo(id, CSW_AWP, 30);
			cs_set_user_bpammo(id, CSW_DEAGLE, 35);
			ColorChat(id,GREEN,"^4[%s] ^1Ai ales ^4Awp^1+^4Deagle^1+^4Set grenazi^1.",tag);
	}      
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;  
}

public Spawn(id) 
{ 
	if(!is_user_alive(id))
		return;
    
	new CsTeams:team = cs_get_user_team(id) 
	if(get_user_flags(id) & VIP_LEVEL_ACCES) 
	{
		switch(team) 
	    {
		case CS_TEAM_T: 
		{
			set_user_health(id, get_pcvar_num(cvar_start_hp));
			set_user_armor(id, get_pcvar_num(cvar_start_ap));
			cs_set_user_money(id, cs_get_user_money(id) + get_pcvar_num(cvar_start_money));
		}
		case CS_TEAM_CT: 
		{
			set_user_health(id, get_pcvar_num( cvar_start_hp ));
			set_user_armor(id, get_pcvar_num( cvar_start_ap ));
			cs_set_user_money(id, cs_get_user_money(id) + get_pcvar_num(cvar_start_money));
		}
	    }
	}
	
	new MapName[32]; get_mapname(MapName, sizeof(MapName));
	for (new i = 0; i < sizeof (RMaps); i ++)
	{
		if(equali (MapName, RMaps[i])) 
		{
			remove_user_flags (id, read_flags(REMOVE_FLAGS));
		}
	}
}

public client_putinserver(id) 
{	
	set_task(2.0, "in", id);
	
	jumpnum[id] = 0;
	dojump[id] = false;
}

public client_disconnect(id)
{
	set_task(2.0, "out", id);

	jumpnum[id] = 0;
	dojump[id] = false;
}

public client_PreThink( id )
{
	if(!is_user_alive(id)) 
		return PLUGIN_CONTINUE;

	new BUTON = get_user_button(id)
	new OLDBUTON = get_user_oldbutton(id)
	new JUMP_VIP = get_pcvar_num(cvar_vip_jump) 

	if((BUTON & IN_JUMP) && !(get_entity_flags(id) & FL_ONGROUND) && !(OLDBUTON & IN_JUMP))
	{
		if(((get_user_flags(id) & VIP_LEVEL_ACCES) && (jumpnum[id] < JUMP_VIP)))
		{
			dojump[id] = true
			jumpnum[id]++
		}
	}

	if((BUTON & IN_JUMP) && (get_entity_flags(id) & FL_ONGROUND))
	{
		jumpnum[id] = 0
	}

	return PLUGIN_CONTINUE;
}

public client_PostThink(id) 
{
	if(!is_user_alive(id)) 
		return PLUGIN_CONTINUE;

	if(dojump[id] == true)
	{
		new Float: velocity[3]	
		entity_get_vector(id, EV_VEC_velocity, velocity)
		velocity[2] = random_float(265.0, 285.0)
		entity_set_vector(id, EV_VEC_velocity, velocity)
		dojump[id] = false
	}
	return PLUGIN_CONTINUE;
}

public eDeathMsg()
{
	new id_Killer = read_data(1);
	new VIP_MAXHP = get_pcvar_num(cvar_vip_maxhp);
	new VIP_MAX_HP = get_user_health(id_Killer);
	new VIP_MAXAP = get_pcvar_num(cvar_vip_maxap);
	new VIP_MAX_AP = get_user_armor(id_Killer);

	if(is_user_alive(id_Killer))
	{
		if(get_user_flags(id_Killer) & VIP_LEVEL_ACCES )
			{
				set_user_health(id_Killer, get_user_health(id_Killer) + get_pcvar_num(cvar_hp_kill));
				set_user_armor(id_Killer, get_user_armor(id_Killer) + get_pcvar_num(cvar_ap_kill));
			}
	}

	if(VIP_MAX_HP >= VIP_MAXHP)
	{
               	set_user_health(id_Killer, get_pcvar_num(cvar_vip_maxhp));
		return PLUGIN_HANDLED;
	}
	
	if(VIP_MAX_AP >= VIP_MAXAP)
	{
               	set_user_armor(id_Killer, get_pcvar_num(cvar_vip_maxap));
		return PLUGIN_HANDLED;
	}

	return PLUGIN_HANDLED;
}

public in(id) 	
{
	if(get_pcvar_num(cvar_vip_in_out))
	{
		new tag[32], name[32];

		get_pcvar_string(cvar_tag, tag, charsmax(tag)); 
		get_user_name(id, name, charsmax(name)); 

		if(get_user_flags(id) & VIP_LEVEL_ACCES)   
		{ 
			ColorChat(0, GREEN, "^4[%s] ^1VIP: ^4%s ^1s-a conectat.", tag, name); 
		}
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public out(id) 	
{	
	if(get_pcvar_num(cvar_vip_in_out))
	{
		new tag[32], name[32];

		get_pcvar_string(cvar_tag, tag, charsmax(tag)); 
		get_user_name(id, name, charsmax(name)); 

		if(get_user_flags(id) & VIP_LEVEL_ACCES)   
		{ 
			ColorChat(0, GREEN, "^4[%s] ^1VIP: ^4%s ^1s-a deconectat.", tag, name); 
		}
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public vip_info(id)
{
	show_motd(id, "/addons/amxmodx/configs/vip_info.html");
}

public mesaj_info()	
{
	new tag[32];
	get_pcvar_string(cvar_tag, tag, charsmax(tag));
	
	ColorChat(0, GREEN, "^4[%s] ^1Tastati in chat ^4/vip ^1pentru a vedea beneficiile si pretul vip-ului.", tag);
}

public TaskDisplayVips( )
{
	if(get_pcvar_num(cvar_vip_showH))
	{
		static iPlayers[ 32 ];
		static iPlayersNum;
	
		get_players( iPlayers, iPlayersNum, "ch" );
		if( !iPlayersNum )
			return 1;
	
		static iVipsConnected, szVipsNames[ 128 ], szName[ 32 ];
		formatex( szVipsNames, sizeof ( szVipsNames ) -1, "" ); // Is this needed ?
		iVipsConnected = 0;
	
		static id, i;
		for( i = 0; i < iPlayersNum; i++ )
		{
			id = iPlayers[ i ];
			if( get_user_flags( id ) & VIP_LEVEL_ACCES )
			{
				get_user_name( id, szName, sizeof ( szName ) -1 );
			
				add( szVipsNames, sizeof ( szVipsNames ) -1, szName );
				add( szVipsNames, sizeof ( szVipsNames ) -1, "^n" );
			
				iVipsConnected++;
			}
		}
	
		formatex( g_szMessage, sizeof ( g_szMessage ) -1, "%s ( %i )^n%s",
			g_szBeginning, iVipsConnected, szVipsNames );
		
		set_hudmessage( 25, 255, 25, 0.01, 0.25, 0, 0.0, 1.0, 0.1, 0.1, -1 );
		ShowSyncHudMsg( 0, SyncHudMessage, g_szMessage );
	}
	return PLUGIN_CONTINUE;
		
}

public handle_say(id) 
{
	new said[192];
	read_args(said,192);
	if(contain(said, "/vips") != -1)
	set_task(0.1,"print_adminlist",id);
	return PLUGIN_CONTINUE;
}

public print_adminlist(user) 
{
	if(get_pcvar_num(cvar_vip_showC))
	{
		new tag[32];
		get_pcvar_string(cvar_tag, tag, charsmax(tag));
	
		new adminnames[33][32];
		new message[256];
		new id, count, x, len;

		for(id = 1 ; id <= get_maxplayers() ; id++)
			if(is_user_connected(id))
				if(get_user_flags(id) & VIP_LEVEL_ACCES)
					get_user_name(id, adminnames[count++], charsmax(adminnames[ ]));
    
		len = format(message, 255, "^4[%s] ^1VIP-ii online sunt:^4 " ,tag);
		if(count > 0) 
			{
			for(x = 0 ; x < count ; x++) 
				{
				len += format(message[len], 255-len, "%s%s ", adminnames[x], x < (count-1) ? ", ":"");
				if(len > 96) 
				{
					print_message(user, message);
					len = format(message, 255, " ");
				}
				}
			print_message(user, message);
			}
		else 
		{
			ColorChat(0, GREEN, "^4[%s] ^1Nu sunt ^4VIP^1-i online.", tag);
		} 
	}
	return PLUGIN_CONTINUE;  
}

print_message(id, msg[]) 
{
	message_begin(MSG_ONE, get_user_msgid("SayText"), {0,0,0}, id);
	write_byte(id);
	write_string(msg);
	message_end();
}

public MessageScoreAttrib(iMsgID, iDest, iReceiver) 
{
    	new iPlayer = get_msg_arg_int(1);
    	if(is_user_connected( iPlayer )
    	&& (get_user_flags( iPlayer ) & VIP_LEVEL_ACCES)) 
		{
        		set_msg_arg_int(2, ARG_BYTE, is_user_alive(iPlayer) ? SCOREATTRIB_VIP : SCOREATTRIB_DEAD);
    		}
}

stock fm_find_ent_by_owner ( entity, const classname[], owner )
{
	while((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", classname)) && pev(entity, pev_owner) != owner) {  }
	return entity;
}

stock drop_weapons(id, dropwhat)
{
	static Weapons[32], Num, i, WeaponID;
	Num = 0;
	get_user_weapons(id, Weapons, Num);
	for(i = 0; i < Num; i ++)
	{
		WeaponID = Weapons[i];
		if((dropwhat == 1 && ((1 << WeaponID) & PRIMARY_WEAPONS_BIT_SUM)) || (dropwhat == 2 && ((1 << WeaponID) & SECONDARY_WEAPONS_BIT_SUM )))
		{
			static DropName[32], WeaponEntity;
			get_weaponname(WeaponID, DropName, charsmax(DropName));
			WeaponEntity = fm_find_ent_by_owner(-1, DropName, id);
			set_pev(WeaponEntity, pev_iuser1, cs_get_user_bpammo (id, WeaponID));
			engclient_cmd(id, "drop", DropName);
			cs_set_user_bpammo(id, WeaponID, 0);
		}
	}
}
