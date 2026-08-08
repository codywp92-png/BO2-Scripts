#include maps\mp\zombies\_zm_magicbox;
#include common_scripts\utility;

main()
{
    replaceFunc(maps\mp\zombies\_zm_magicbox::treasure_chest_chooseweightedrandomweapon,::new_treasure_chest_chooseweightedrandomweapon);
	replaceFunc(maps\mp\zombies\_zm_pers_upgrades_functions::pers_treasure_chest_choosespecialweapon,::new_pers_treasure_chest_choosespecialweapon);
}

init()
{
    level thread onplayerconnect();
}

onplayerconnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread onplayerspawned();
    }
}

onplayerspawned()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill("spawned_player");
    }
}

new_treasure_chest_chooseweightedrandomweapon( player )
{
	iprintln("Regular:" + level.chest_accessed);
    keys = array_randomize( getarraykeys( level.zombie_weapons ) );

    if ( isdefined( level.customrandomweaponweights ) )
        keys = player [[ level.customrandomweaponweights ]]( keys );
    
    pap_triggers = getentarray( "specialty_weapupgrade", "script_noteworthy" );

    for ( i = 0; i < keys.size; i++ )
    {
	if ( level.chest_accessed == 0 && level.script == "zm_buried")
	{
	    if ( treasure_chest_canplayerreceiveweapon( player, "slowgun_zm", pap_triggers ) )
		return "slowgun_zm";
	}
	if ( treasure_chest_canplayerreceiveweapon( player, keys[i], pap_triggers ) )
	    return keys[i];
    }
    return keys[0];
}

new_pers_treasure_chest_choosespecialweapon( player )
{
	iprintln("Perma:" + level.chest_accessed);
    rval = randomfloat( 1 );

    if ( !isdefined( player.pers_magic_box_weapon_count ) )
        player.pers_magic_box_weapon_count = 0;

    if ( player.pers_magic_box_weapon_count < 2 && ( player.pers_magic_box_weapon_count == 0 || rval < 0.6 ) )
    {
/#

#/
        player.pers_magic_box_weapon_count++;

        if ( isdefined( level.pers_treasure_chest_get_weapons_array_func ) )
            [[ level.pers_treasure_chest_get_weapons_array_func ]]();
        else
            pers_treasure_chest_get_weapons_array();

        keys = array_randomize( level.pers_box_weapons );
/#
        forced_weapon = getdvar( _hash_45ED7744 );

        if ( forced_weapon != "" && isdefined( level.zombie_weapons[forced_weapon] ) )
            arrayinsert( keys, forced_weapon, 0 );
#/
        pap_triggers = getentarray( "specialty_weapupgrade", "script_noteworthy" );

        for ( i = 0; i < keys.size; i++ )
        {
			if ( level.chest_accessed == 0 && level.script == "zm_buried")
			{
				if ( treasure_chest_canplayerreceiveweapon( player, "slowgun_zm", pap_triggers ) )
					return "slowgun_zm";
			}
            if ( maps\mp\zombies\_zm_magicbox::treasure_chest_canplayerreceiveweapon( player, keys[i], pap_triggers ) )
                return keys[i];
        }

        return keys[0];
    }
    else
    {
/#

#/
        player.pers_magic_box_weapon_count = 0;
        weapon = maps\mp\zombies\_zm_magicbox::treasure_chest_chooseweightedrandomweapon( player );
        return weapon;
    }
}