#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <xs>

#define PLUGIN "Anti-GroundStrafe"
#define VERSION "1.0"
#define AUTHOR "MrShark45"

new duck_pressed[33];
new g_iTaskEnt;

#define TASK_TIME 0.3
#define MAX_DUCKS 4

new Float:old_vel[33][3];

public plugin_init(){
	register_plugin(PLUGIN, VERSION, AUTHOR)

	RegisterHam(Ham_Player_Duck, "player", "HAM_Player_Duck_Post", 0);
	CreateTask();
}

//Create task at the beging of the map to check key pressed and speed gain for each player
CreateTask()
{
	register_think("task_ent", "Task_DucksCheck");
	g_iTaskEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	set_pev(g_iTaskEnt, pev_classname, "task_ent");
	set_pev(g_iTaskEnt, pev_nextthink, get_gametime() + 1.01);
}

//Count key pressed and ignore if continuously pressed

public HAM_Player_Duck_Post( id )
{
	new oldbuttons = pev( id, pev_oldbuttons )
	
	if( oldbuttons & IN_DUCK )
	{
		return HAM_IGNORED;
	}
	else
	{
		duck_pressed[id]++;
	}
	return HAM_IGNORED;
}

//Check how many key pressed since Task_Time and how much speed gain since Task_Time, if key pressed > 4 in 0.2(TASK_TIME) set velocity[1]/[2] *= 0.2

public Task_DucksCheck(ent)
{
	//new Float:fVelocity[3];
	for(new id = 1; id < 33; id++)
	{
		if(!is_user_alive(id))
		{
			duck_pressed[id] = 0;
			continue;
		}
		if(IsUserSurfing(id))
		{
			pev(id, pev_velocity, old_vel[id]);
			continue;
		}
		
		new Float:gain = CompareVelocity(id);

		if(duck_pressed[id] >= MAX_DUCKS && gain > 250)
		{
			/*
			pev(id, pev_velocity, fVelocity);
			
			fVelocity[0] *= 0.2;
			fVelocity[1] *= 0.2;

			set_pev(id, pev_velocity, fVelocity);
			*/

			ExecuteHamB(Ham_CS_RoundRespawn, id);
		
		}
		duck_pressed[id] = 0;
		pev(id, pev_velocity, old_vel[id]);
	}

	set_pev(ent, pev_nextthink,  get_gametime() + TASK_TIME);
}

//Compare the current velocity and the old velocity since TASK_TIME
stock Float:CompareVelocity(id){
	static Float:velocity[3]
	static Float:speed
	static Float:old_speed

	pev(id, pev_velocity, velocity)
	speed = floatsqroot(floatpower(velocity[0], 2.0) + floatpower(velocity[1], 2.0))
	old_speed = floatsqroot(floatpower(old_vel[id][0], 2.0) + floatpower(old_vel[id][1], 2.0))

	return speed - old_speed;
}

bool:IsUserSurfing(id)
{
    if( is_user_alive(id) )
    {
        new flags = entity_get_int(id, EV_INT_flags);
        if( flags & FL_ONGROUND )
        {
            return false;
        }

        new Float:origin[3], Float:dest[3];
        entity_get_vector(id, EV_VEC_origin, origin);
        
        dest[0] = origin[0];
        dest[1] = origin[1];
        dest[2] = origin[2] - 1.0;

        new ptr = create_tr2();
        engfunc(EngFunc_TraceHull, origin, dest, 0, flags & FL_DUCKING ? HULL_HEAD : HULL_HUMAN, id, ptr);
        new Float:flFraction;
        get_tr2(ptr, TR_flFraction, flFraction);
        if( flFraction >= 1.0 )
        {
            free_tr2(ptr);
            return false;
        }
        
        get_tr2(ptr, TR_vecPlaneNormal, dest);
        free_tr2(ptr);

        // which one ?
        // static Float:flValue = 0.0;
        // if( !flValue )
        // {
            // flValue = floatcos(45.0, degrees);
        // }
        // return dest[2] <= flValue;
        // return dest[2] < flValue;
        return dest[2] <= 0.7;
        // return dest[2] < 0.7;

    }
    return false;
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