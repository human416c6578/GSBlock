#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <xs>

#define PLUGIN "Anti-GroundStrafe"
#define VERSION "2.0"
#define AUTHOR "MrShark45"

#define DEBUG 0

#define MAX_ERROR 1.5
#define MAX_TIMESPENT 0.5
#define MAX_DUCKS 2
#define MAX_TOUCHES 3

new duck_pressed[33];
new Float:push_speed[33];
new Float:start_time[33];
new Float:start_vel[33];

new touches[33];

new bool:g_bTouchingPush[33];
new g_iTouchingPushEnt[33];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_touch("trigger_push", "player", "TouchPush");
}

public client_putinserver(id)
{
    duck_pressed[id] = 0;
    push_speed[id] = 0.0;
    start_time[id] = 0.0;
    start_vel[id] = 0.0;
    touches[id] = 0;
    g_bTouchingPush[id] = false;
    g_iTouchingPushEnt[id] = 0;
}

public client_PreThink(id)
{
	if(!g_bTouchingPush[id]) return PLUGIN_CONTINUE;

	static oldbuttons;
	oldbuttons = pev(id, pev_oldbuttons);
	static buttons;
	buttons = pev(id, pev_button);

	if(buttons & IN_DUCK && !(oldbuttons & IN_DUCK))
		duck_pressed[id]++;

	if( !entity_intersects(id, g_iTouchingPushEnt[id]))
	{
		g_bTouchingPush[id] = false;
		g_iTouchingPushEnt[id] = 0;

		EndTouch(id);

		return PLUGIN_CONTINUE;
	}

	return PLUGIN_CONTINUE;
}

public TouchPush(ent, id)
{
	if(!g_bTouchingPush[id])
	{
		pev(ent, pev_speed, push_speed[id]);
		g_bTouchingPush[id] = true;
		StartTouch(id);
	}
		

	g_iTouchingPushEnt[id] = ent;
}

public StartTouch(id)
{
#if DEBUG
	client_print(id, print_chat, "Started Touching!");
#endif
	static Float:velocity[3];
	pev(id, pev_velocity, velocity);
	start_vel[id] = floatabs(xs_vec_len_2d(velocity));
	start_time[id] = get_gametime();
	duck_pressed[id] = 0;
}

public EndTouch(id)
{
	static Float:end_vel[3];
	pev(id, pev_velocity, end_vel);
	new Float:gain = floatabs(xs_vec_len_2d(end_vel)) - start_vel[id];
	new Float:time_spent = get_gametime() - start_time[id];

	if(time_spent > MAX_TIMESPENT)
		return;

#if DEBUG
	client_print(id, print_chat, "Stopped Touching!");
	client_print(id, print_chat, "Ent Normal Push: %f", push_speed[id]);
	client_print(id, print_chat, "Ducks: %d | Gain: %f | Time: %f", duck_pressed[id], floatabs(gain), time_spent);
#endif

	if((gain > push_speed[id] * MAX_ERROR) && duck_pressed[id] != 0 )
		set_player_speed(id, start_vel[id]);

	if(duck_pressed[id] > MAX_DUCKS)
		set_player_speed(id, start_vel[id]);

	if(gain > push_speed[id] * 0.5)
		touches[id]++;
	duck_pressed[id] = 0;

	set_task(1.0, "ResetTouches", id);
}

public ResetTouches(id)
{
#if DEBUG
	client_print(id, print_chat, "Total Touches: %d", touches[id]);
#endif

	if(touches[id] > MAX_TOUCHES)
		set_player_speed(id, 250.0);
		//ExecuteHamB(Ham_CS_RoundRespawn, id);

	touches[id] = 0;
}

stock set_player_speed(id, Float:value){
	new Float:velocity[3];
	new Float:fAimVector[3]

	pev( id, pev_v_angle, fAimVector )

	angle_vector( fAimVector, ANGLEVECTOR_FORWARD, fAimVector )

	get_user_velocity(id, velocity);

	velocity[0] = fAimVector[0] * value;
	velocity[1] = fAimVector[1] * value;

	set_user_velocity(id, velocity);
	return PLUGIN_CONTINUE;
}