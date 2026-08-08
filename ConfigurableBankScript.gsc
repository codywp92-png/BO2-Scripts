#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;

main()
{
	replaceFunc(maps\mp\zombies\_zm_banking::bank_teller_init,::new_bank_teller_init);
	replaceFunc(maps\mp\zombies\_zm_banking::player_withdraw_fee,::new_player_withdraw_fee);
	replaceFunc(maps\mp\zombies\_zm_banking::bank_teller_give_money,::new_bank_teller_give_money);
	replaceFunc(maps\mp\zombies\_zm_banking::trigger_deposit_think,::new_trigger_deposit_think);
	replaceFunc(maps\mp\zombies\_zm_banking::trigger_withdraw_think,::new_trigger_withdraw_think);
	replaceFunc(maps\mp\zombies\_zm_banking::trigger_deposit_update_prompt,::new_trigger_deposit_update_prompt);
	replaceFunc(maps\mp\zombies\_zm_banking::trigger_withdraw_update_prompt,::new_trigger_withdraw_update_prompt);
}

init()
{
    level thread onplayerconnect();
	level.AllowBank = 1;
	level.AllowBankTranzit = 1;
	level.AllowBankBuried = 1;
	level.AllowBankDieRise = 1;
	level.AllowBankTeller = 1;
	level.AllowBankTellerTranzit = 1;
	level.AllowBankTellerBuried = 1;
	level.CustomBankTeller = 1;
	level.CustomBankTellerTranzit = 1;
	level.CustomBankTellerBuried = 1;
	level.TranzitTellerCost = 1000;
	level.TranzitTellerFee = 100;
	level.TranzitBankTransferValue = 1000;
	level.BuriedTellerCost = 1000;
	level.BuriedTellerFee = 100;
	level.BuriedBankTransferValue = 1000;
	level.DepositAmount = 1000;
	level.WithdrawAmount = 1000;
	level.WithdrawFee = 100;
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
		wait 10;
		if (level.script == "zm_buried" && level.AllowBankTellerBuried == 0 || level.script == "zm_transit" && is_classic() && level.AllowBankTellerTranzit == 0)
		{
			level thread new_bank_teller_give_money();
		}
	}	
}

new_bank_teller_init()
{
    level.bank_teller_dmg_trig = getent( "bank_teller_tazer_trig", "targetname" );

    if ( isdefined( level.bank_teller_dmg_trig ) )
    {
        level.bank_teller_transfer_trig = getent( level.bank_teller_dmg_trig.target, "targetname" );
        level.bank_teller_powerup_spot = getstruct( level.bank_teller_transfer_trig.target, "targetname" );
        level thread bank_teller_logic();
        level.bank_teller_transfer_trig.origin += vectorscale( ( -1, 0, 0 ), 25.0 );
        level.bank_teller_transfer_trig trigger_off();
		if (level.CustomBankTeller == 0)
		{
			level.bank_teller_transfer_trig sethintstring( &"ZOMBIE_TELLER_GIVE_MONEY", level.ta_tellerfee );
		}
		else
		{
			if (level.script == "zm_transit")
			{ 
				level.bank_teller_transfer_trig sethintstring("Cost:" + level.TranzitTellerCost + " Points ", "[Teller Fee:" + level.TranzitTellerFee + "]" + " [Transfer Amount:" + level.TranzitBankTransferValue + "]" );
			}
			if (level.script == "zm_buried")
			{ 
				level.bank_teller_transfer_trig sethintstring("Cost:" + level.BuriedTellerCost + " Points ", "[Teller Fee:" + level.BuriedTellerFee + "]" + " [Transfer Amount:" + level.BuriedBankTransferValue + "]" );
			}
		}
    }
}

new_bank_teller_give_money()
{
	if(level.AllowBankTeller == 0)
	{
		DisableBankTeller();
	}
	else
	{
		if (level.script == "zm_buried" && level.AllowBankTellerBuried == 0)
		{
			DisableBankTeller();
		}
		else
		{
			if (level.script == "zm_buried" && level.CustomBankTeller == 1)
			{
				CustomBankTellerBuried();
				return;
			}
			else
			{
				OriginalBankTeller();
			}
		}
		if (level.script == "zm_transit" && level.AllowBankTellerTranzit == 0)
		{
			DisableBankTeller();
		}
		else
		{
			if (level.script == "zm_transit" && level.CustomBankTeller == 1)
			{
				CustomBankTellerTranzit();
				return;
			}
			else
			{
				OriginalBankTeller();
			}
		}
    }
}

new_trigger_deposit_update_prompt( player )
{
	if (level.AllowBank == 0)
	{
		self sethintstring("Disabled");
	}
	else
	{
		if (level.script == "zm_transit" && level.AllowBankTranzit == 1)
		{
			original_trigger_deposit_update_prompt(player);
			return;
		}
		if (level.script == "zm_buried" && level.AllowBankBuried == 1)
		{
			original_trigger_deposit_update_prompt(player);
			return;
		}
		if (level.script == "zm_highrise" && level.AllowBankDieRise == 1)
		{
			original_trigger_deposit_update_prompt(player);
			return;
		}
		self sethintstring("Disabled");
	}
    return false;
}

new_trigger_withdraw_update_prompt( player )
{
	if (level.AllowBank == 0)
	{
		self sethintstring("Disabled" );
	}
	else
	{
		if (level.script == "zm_transit" && level.AllowBankTranzit == 1)
		{
			original_trigger_withdraw_update_prompt( player );
			return;
		}
		if (level.script == "zm_buried" && level.AllowBankBuried == 1)
		{
			original_trigger_withdraw_update_prompt( player );
			return;
		}
		if (level.script == "zm_highrise" && level.AllowBankDieRise == 1)
		{
			original_trigger_withdraw_update_prompt( player );
			return;
		}
		self sethintstring("Disabled" );
	}
    return false;
}

DisableBankTeller()
{
	level endon( "end_game" );
	level.bank_teller_transfer_trig trigger_on();
	level.bank_teller_transfer_trig sethintstring("Disabled");

	while ( true )
	{
		level.bank_teller_transfer_trig waittill( "trigger", player );
	}
}

OriginalBankTeller()
{
	level endon( "end_game" );
    level endon( "stop_bank_teller" );
    level.bank_teller_transfer_trig trigger_on();
    bank_transfer = undefined;

    while ( true )
    {
        level.bank_teller_transfer_trig waittill( "trigger", player );

        if ( !is_player_valid( player, 0 ) || player.score < 1000 + level.ta_tellerfee )
            continue;

        if ( !isdefined( bank_transfer ) )
        {
            bank_transfer = maps\mp\zombies\_zm_powerups::specific_powerup_drop( "teller_withdrawl", level.bank_teller_powerup_spot.origin + vectorscale( ( 0, 0, -1 ), 40.0 ) );
            bank_transfer thread stop_bank_teller();
            bank_transfer.value = 0;
        }

        bank_transfer.value += 1000;
        bank_transfer notify( "powerup_reset" );
        bank_transfer thread maps\mp\zombies\_zm_powerups::powerup_timeout();
        player maps\mp\zombies\_zm_score::minus_to_player_score( 1000 + level.ta_tellerfee );
        level notify( "bank_teller_used" );
    }
}

original_trigger_withdraw_update_prompt( player )
{
	if ( player.account_value <= 0 )
	{
		self sethintstring( "" );
		player show_balance();
		return false;
	}

	self sethintstring( &"ZOMBIE_BANK_WITHDRAW_PROMPT", level.WithdrawAmount, level.WithdrawFee );
	return true;
}

original_trigger_deposit_update_prompt( player )
{
	if ( player.score < level.bank_deposit_ddl_increment_amount || player.account_value >= level.bank_account_max )
	{
		player show_balance();
		self sethintstring( "" );
		return false;
	}

	self sethintstring( &"ZOMBIE_BANK_DEPOSIT_PROMPT", level.DepositAmount );
	return true;
}

CustomBankTellerTranzit()
{
	level endon( "end_game" );
	level endon( "stop_bank_teller" );
	level.bank_teller_transfer_trig trigger_on();
	bank_transfer = undefined;

	while ( true )
	{
		level.bank_teller_transfer_trig waittill( "trigger", player );

		if ( !is_player_valid( player, 0 ) || player.score < level.TranzitTellerCost + level.TranzitTellerFee )
			continue;

		if ( !isdefined( bank_transfer ) )
		{
			bank_transfer = maps\mp\zombies\_zm_powerups::specific_powerup_drop( "teller_withdrawl", level.bank_teller_powerup_spot.origin + vectorscale( ( 0, 0, -1 ), 40.0 ) );
			bank_transfer thread stop_bank_teller();
			bank_transfer.value = 0;
		}
		
		bank_transfer.value += level.TranzitBankTransferValue;
		bank_transfer notify( "powerup_reset" );
		bank_transfer thread maps\mp\zombies\_zm_powerups::powerup_timeout();
		player maps\mp\zombies\_zm_score::minus_to_player_score( level.TranzitTellerCost + level.TranzitTellerFee );
		level notify( "bank_teller_used" );
	}
}

CustomBankTellerBuried()
{
	level endon( "end_game" );
	level endon( "stop_bank_teller" );
	level.bank_teller_transfer_trig trigger_on();
	bank_transfer = undefined;

	while ( true )
	{
		level.bank_teller_transfer_trig waittill( "trigger", player );

		if ( !is_player_valid( player, 0 ) || player.score < level.BuriedTellerCost + level.BuriedTellerFee )
			continue;

		if ( !isdefined( bank_transfer ) )
		{
			bank_transfer = maps\mp\zombies\_zm_powerups::specific_powerup_drop( "teller_withdrawl", level.bank_teller_powerup_spot.origin + vectorscale( ( 0, 0, -1 ), 40.0 ) );
			bank_transfer thread stop_bank_teller();
			bank_transfer.value = 0;
		}
		
		bank_transfer.value += level.BuriedBankTransferValue;
		bank_transfer notify( "powerup_reset" );
		bank_transfer thread maps\mp\zombies\_zm_powerups::powerup_timeout();
		player maps\mp\zombies\_zm_score::minus_to_player_score( level.BuriedTellerCost + level.BuriedTellerFee );
		level notify( "bank_teller_used" );
	}
}

new_trigger_deposit_think()
{
    self endon( "kill_trigger" );

    while ( true )
    {
        self waittill( "trigger", player );

        if ( !is_player_valid( player ) )
            continue;

        if ( player.score >= level.DepositAmount && player.account_value < level.bank_account_max )
        {
            player playsoundtoplayer( "zmb_vault_bank_deposit", player );
            player.score -= level.DepositAmount;
            player.account_value += level.DepositAmount;
            player maps\mp\zombies\_zm_stats::set_map_stat( "depositBox", player.account_value, level.banking_map );

            if ( isdefined( level.custom_bank_deposit_vo ) )
                player thread [[ level.custom_bank_deposit_vo ]]();

            if ( player.account_value >= level.bank_account_max )
                self sethintstring( "" );
        }
        else
            player thread do_player_general_vox( "general", "exert_sigh", 10, 50 );

        player show_balance();
    }
}

new_trigger_withdraw_think()
{
    self endon( "kill_trigger" );

    while ( true )
    {
        self waittill( "trigger", player );

        if ( !is_player_valid( player ) )
            continue;

        if ( player.account_value >= level.bank_account_increment )
        {
            player playsoundtoplayer( "zmb_vault_bank_withdraw", player );
            player.score += level.WithdrawAmount;
            level notify( "bank_withdrawal" );
            player.account_value -= level.WithdrawAmount;
            player maps\mp\zombies\_zm_stats::set_map_stat( "depositBox", player.account_value, level.banking_map );

            if ( isdefined( level.custom_bank_withdrawl_vo ) )
                player thread [[ level.custom_bank_withdrawl_vo ]]();
            else
                player thread do_player_general_vox( "general", "exert_laugh", 10, 50 );

            player thread player_withdraw_fee();

            if ( player.account_value < level.WithdrawAmount )
                self sethintstring( "" );
        }
        else
            player thread do_player_general_vox( "general", "exert_sigh", 10, 50 );

        player show_balance();
    }
}

new_player_withdraw_fee()
{
    self endon( "disconnect" );
    wait_network_frame();
    self.score -= level.WithdrawFee;
}
