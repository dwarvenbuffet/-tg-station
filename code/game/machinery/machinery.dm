var/global/list/multitool_var_whitelist = list(	"id_tag",
													"master_tag",
													"command",
													"input_tag",
													"output_tag",
													"tag_airpump",
													"tag_exterior_door",
													"tag_interior_door",
													"tag_chamber_sensor",
													"tag_interior_sensor",
													"tag_exterior_sensor",
													)

/*
Overview:
   Used to create objects that need a per step proc call.  Default definition of 'New()'
   stores a reference to src machine in global 'machines list'.  Default definition
   of 'Del' removes reference to src machine in global 'machines list'.

Class Variables:
   use_power (num)
      current state of auto power use.
      Possible Values:
         0 -- no auto power use
         1 -- machine is using power at its idle power level
         2 -- machine is using power at its active power level

   active_power_usage (num)
      Value for the amount of power to use when in active power mode

   idle_power_usage (num)
      Value for the amount of power to use when in idle power mode

   power_channel (num)
      What channel to draw from when drawing power for power mode
      Possible Values:
         EQUIP:0 -- Equipment Channel
         LIGHT:2 -- Lighting Channel
         ENVIRON:3 -- Environment Channel

   component_parts (list)
      A list of component parts of machine used by frame based machines.

   uid (num)
      Unique id of machine across all machines.

   gl_uid (global num)
      Next uid value in sequence

   stat (bitflag)
      Machine status bit flags.
      Possible bit flags:
         BROKEN:1 -- Machine is broken
         NOPOWER:2 -- No power is being supplied to machine.
         POWEROFF:4 -- tbd
         MAINT:8 -- machine is currently under going maintenance.
         EMPED:16 -- temporary broken by EMP pulse

Class Procs:
   New()                     'game/machinery/machine.dm'

   Destroy()                   'game/machinery/machine.dm'

   auto_use_power()            'game/machinery/machine.dm'
      This proc determines how power mode power is deducted by the machine.
      'auto_use_power()' is called by the 'master_controller' game_controller every
      tick.

      Return Value:
         return:1 -- if object is powered
         return:0 -- if object is not powered.

      Default definition uses 'use_power', 'power_channel', 'active_power_usage',
      'idle_power_usage', 'powered()', and 'use_power()' implement behavior.

   powered(chan = EQUIP)         'modules/power/power.dm'
      Checks to see if area that contains the object has power available for power
      channel given in 'chan'.

   use_power(amount, chan=EQUIP)   'modules/power/power.dm'
      Deducts 'amount' from the power channel 'chan' of the area that contains the object.

   power_change()               'modules/power/power.dm'
      Called by the area that contains the object when ever that area under goes a
      power state change (area runs out of power, or area channel is turned off).

   RefreshParts()               'game/machinery/machine.dm'
      Called to refresh the variables in the machine that are contributed to by parts
      contained in the component_parts list. (example: glass and material amounts for
      the autolathe)

      Default definition does nothing.

   assign_uid()               'game/machinery/machine.dm'
      Called by machine to assign a value to the uid variable.

	process()                  'game/machinery/machine.dm'
       Called by the 'machinery subsystem' once per machinery tick for each machine that is listed in its 'machines' list.

	process_atmos()
    	Called by the 'air subsystem' once per atmos tick for each machine that is listed in its 'atmos_machines' list.

   is_operational()
		Returns 0 if the machine is unpowered, broken or undergoing maintenance, something else if not

	Compiled by Aygar
*/

#define OVERHEAT_NONE 0
#define OVERHEAT_LOW_RELIABILITY 1
#define OVERHEAT_DISCONNECT 2
#define OVERHEAT_FAIL_PRODUCE 3
#define OVERHEAT_FIRE 4
#define OVERHEAT_EXPLOSION 5

/obj/machinery
	name = "machinery"
	icon = 'icons/obj/stationobjs.dmi'
	var/stat = 0
	var/emagged = 0
	var/use_power = 1
		//0 = dont run the auto
		//1 = run auto, use idle
		//2 = run auto, use active
	var/idle_power_usage = 0
	var/active_power_usage = 0
	var/power_channel = EQUIP
		//EQUIP,ENVIRON or LIGHT
	var/list/component_parts = null //list of all the parts used to build it, if made from certain kinds of frames.
	var/uid
	var/global/gl_uid = 1
	var/panel_open = 0
	var/state_open = 0
	var/mob/living/occupant = null
	var/unsecuring_tool = /obj/item/weapon/wrench
	var/interact_offline = 0 // Can the machine be interacted with while de-powered.
	var/state = 0 //0 is unanchored, 1 is anchored and unwelded, 2 is anchored and welded for most things
	//These are some values to automatically set the light power/range on machines if they have power
	var/light_range_on = 0
	var/light_power_on = 0
	var/use_auto_lights = 0//Incase you want to use it, set this to 0, defaulting to 1 so machinery with no lights doesn't call set_light()
	var/machine_flags = 0
	var/icon_open
	var/icon_closed
	var/closed_panel_decon = 0
	var/wrench_time = 20
	var/weld_time = 20
	var/speed_process = 0
	//Special research vars below
	var/lubricity = 0
	var/machinetemp = T20C //In kelvin; more or less room temp
	var/system_output = ""
	var/overheated = OVERHEAT_NONE

/obj/machinery/New()
	..()
	machines += src
	if(!speed_process)
		SSmachine.processing += src
	else
		SSfastprocess.processing += src

	power_change()
	auto_use_power()

/obj/machinery/Destroy()
	machines.Remove(src)
	if(!speed_process)
		SSmachine.processing -= src
	else
		SSfastprocess.processing -= src
	if(occupant)
		dropContents()
	..()

/obj/machinery/proc/locate_machinery()
	return

/obj/machinery/process()//If you dont use process or power why are you here
	return PROCESS_KILL

/obj/machinery/proc/process_atmos()//If you dont use process why are you here
	return PROCESS_KILL


/obj/machinery/emp_act(severity)
	if(use_power && stat == 0)
		use_power(7500/severity)

		var/obj/effect/overlay/pulse2 = new/obj/effect/overlay ( src.loc )
		pulse2.icon = 'icons/effects/effects.dmi'
		pulse2.icon_state = "empdisable"
		pulse2.name = "emp sparks"
		pulse2.anchored = 1
		pulse2.dir = pick(cardinal)

		spawn(10)
			qdel(pulse2)
	..()

/obj/machinery/proc/open_machine()
	state_open = 1
	density = 0
	dropContents()
	update_icon()
	updateUsrDialog()

/obj/machinery/allow_drop()
	return 0

/obj/machinery/proc/dropContents()
	var/turf/T = get_turf(src)
	T.contents += contents
	if(occupant)
		if(occupant.client)
			occupant.client.eye = occupant
			occupant.client.perspective = MOB_PERSPECTIVE
		occupant = null

/obj/machinery/proc/close_machine(mob/living/target = null)
	state_open = 0
	density = 1
	if(!target)
		for(var/mob/living/carbon/C in loc)
			if(C.buckled)
				continue
			else
				target = C
	if(target)
		if(target.client)
			target.client.perspective = EYE_PERSPECTIVE
			target.client.eye = src
		occupant = target
		target.loc = src
		target.stop_pulling()
	updateUsrDialog()
	update_icon()

/obj/machinery/blob_act()
	if(prob(50))
		qdel(src)

/obj/machinery/proc/auto_use_power()
	if(!powered(power_channel))
		return 0
	if(src.use_power == 1)
		use_power(idle_power_usage,power_channel)
	else if(src.use_power >= 2)
		use_power(active_power_usage,power_channel)
	return 1

/obj/machinery/Topic(href, href_list)
	..()
	if(!can_be_used_by(usr))
		return 1
	add_fingerprint(usr)
	handle_multitool_topic(href,href_list,usr)
	return 0

/obj/machinery/proc/can_be_used_by(mob/user)
	if(!interact_offline && stat & (NOPOWER|BROKEN))
		return 0
	if(!user.canUseTopic(src))
		return 0
	return 1

/obj/machinery/proc/is_operational()
	return !(stat & (NOPOWER|BROKEN|MAINT))

/obj/machinery/proc/is_lubricant(datum/reagent/C) //does it have a lub_c value? If so, return 1. You should probably indicate a lub_l value as well
	if (C.lub_c)
		return 1

/obj/machinery/proc/is_coolant(datum/reagent/C) //ditto
	if (C.cool_c)
		return 1

#define MODE_LUBRICATION 1
#define MODE_COOLING 2

/obj/machinery/proc/lubricant_process(datum/reagents/R, datum/reagent/C, volume = 0, mode = MODE_LUBRICATION) //Lubricant processing for machines. C should a reagent in R.
	if (C)
		if (mode == MODE_LUBRICATION) //lubrication
			if (is_lubricant(C))
				lubricate(R, C, volume)
				return
			else
				system_output = "ERROR: Invalid lubricant."
				return
		else if (mode == MODE_COOLING) //cooling
			if (is_coolant(C))
				coolinate(R, C, volume)
				return
			else
				system_output = "ERROR: Invalid coolant."
				return
		else
			system_output = "ERROR: Invalid operation."
			return
		return

/obj/machinery/proc/lubricate(datum/reagents/R, datum/reagent/C, volume = 0) //send everything to lubricant_process, not this
	if ((lubricity + volume*C.lub_c) < C.lub_l) //lub_l is an upper limit to lubricity using various chems
		lubricity += volume*C.lub_c
		playsound(loc, 'sound/machines/pneumatic.ogg', 50)
		R.remove_reagent(C.id, volume)
		system_output = "SUCCESS: Lubricant deployed. [volume] units of [C.name] were consumed in the operation. Lubricity increased to [lubricity]%."
		use_power(100) //that pump needs electricity to run!
		return
	else if (lubricity < C.lub_l)
		var/lube_used = (C.lub_l - lubricity)/C.lub_c
		if (lube_used < volume)
			lubricity = C.lub_l
			playsound(loc, 'sound/machines/pneumatic.ogg', 20)
			R.remove_reagent(C.id, lube_used)
			system_output = "SUCCESS: Lubricant deployed to temperature threshold. [lube_used] units of [C.name] were consumed in the operation. Lubricity increased to [lubricity]%. Not all of the selected volume was consumed."
			use_power(100)
			return
		else
			system_output = "ERROR: Insufficient lubricant for this operation."
			return
	else
		system_output = "ERROR: Lubricity cannot be increased any higher with current lubricant. A higher grade of lubricant is recommended."
		return
	return

/obj/machinery/proc/coolinate(datum/reagents/R, datum/reagent/C, volume = 0) //send everything to lubricant_process, not this
	if ((machinetemp - volume*C.cool_c*(1.6-R.chem_temp/500)) > C.cool_l) //cool_l is a lower limit, and no, you don't get to pump compressed steam into the machine to try to cool it down
		machinetemp -= volume*C.cool_c*(1.6-R.chem_temp/500) //say chems in the machine at the regular temperature, 300 K. machinetemp -= volume*cool_c.
		playsound(loc, 'sound/machines/pneumatic.ogg', 50)
		R.remove_reagent(C.id, volume) //say all chems in the machine at 1 K (you had a "chem heater" very nearby). machinetemp -= volume*cool_c*(1.6-1/500) = volume*cool_c*1.598
		system_output = "SUCCESS: Coolant deployed. [volume] units of [C.name] were consumed in the operation. Temperature is now at [machinetemp] K." //Why the fuck do some of these machines still use Celsius? This is a RESEARCH station, goddammit. People ought to be familiar with Kelvin.
		chem_machine_heat(R, machinetemp)
		use_power(250) //that compressor and pump both need electricity!
		return //say chems in the machine at 1000 K (and you're a fucking dumbass). machinetemp -= volume*cool_c*(1.6-1000/500); aka machinetemp += 0.4*volume*cool_c.
	else if (machinetemp > C.cool_l) //Fun fact: if you heat 600 blube to a nice, red-hot 1000 K and dump it into the machine for some reason, you can raise the machine's temperature by 480 K by trying to flush all of the "coolant" through the system.
		var/coolant_used = (machinetemp - C.cool_l)/(C.cool_c*(1.6-R.chem_temp/500)) //This scenario requires that you acquire at least 120 bluespace crystals and grind them all into jelly, then mix them into lube.
		if (coolant_used < volume)
			machinetemp = C.cool_l
			playsound(loc, 'sound/machines/pneumatic.ogg', 20)
			R.remove_reagent(C.id, coolant_used)
			system_output = "SUCCESS: Coolant deployed to temperature threshold. [coolant_used] units of [C.name] were consumed in the operation. Temperature is now at [machinetemp] K. Not all of the selected volume was consumed."
			chem_machine_heat(R, machinetemp)
			use_power(250) //that compressor and pump both need electricity!
			return
		else
			system_output = "ERROR: Insufficient coolant for this operation."
			return
	else
		system_output = "ERROR: Temperature cannot be decreased any further with current coolant. A higher grade of coolant is recommended."
		return
	return

/obj/machinery/proc/atmos_machine_heat(turf/simulated/L, mole_coeff = 0.25, target_temp = T20C) //specify turf, percentage of gas to cycle, and target temp
	if (istype(L)) //duly copy-pasted from space heater
		var/datum/gas_mixture/atmo = L.return_air()
		var/transfer_moles = mole_coeff*atmo.total_moles()
		var/datum/gas_mixture/inp = atmo.remove(transfer_moles)
		if (inp) //(ALL) heat exchange is just naturally much slower when the machine is much colder than its surroundings because fuck thermodynamics
			if (atmo.temperature < target_temp) //heat flows out of machine
				inp.temperature += target_temp/T20C //pseudoscience
				machinetemp = max(machinetemp - target_temp*mole_coeff/T20C, 0.025)
			else if (atmo.temperature > target_temp) //heat flows into machine
				inp.temperature = max(inp.temperature - target_temp/T20C, 10)
				machinetemp += target_temp*mole_coeff/T20C
			atmo.merge(inp)
			air_update_turf()
	return

/obj/machinery/proc/chem_machine_heat(datum/reagents/R, target_temp = 300)
	var/maybe = prob(1) //Don't want to fuck people over with this mechanic, let's see how it runs
	if(R.chem_temp && maybe)
		if((R.chem_temp < target_temp) && R.chem_temp < 1000)
			R.chem_temp++
			machinetemp-- //not physically correct at all, but who gives a shit; liquids basically don't even have heat capacities in this game
		else if ((R.chem_temp > target_temp) && R.chem_temp > 1)
			R.chem_temp--
			machinetemp++
	return

/obj/machinery/proc/overheat_check()
	if(machinetemp < T20C) //normal
		overheated = OVERHEAT_NONE
	if(machinetemp >= 328.15) //low reliability
		overheated = OVERHEAT_LOW_RELIABILITY
	if(machinetemp >= 398.15) //disconnection
		overheated = OVERHEAT_DISCONNECT
	if(machinetemp >= 468.15) //failed production
		overheated = OVERHEAT_FAIL_PRODUCE
	if(machinetemp >= 538.15) //porkchop sandwiches.
		overheated = OVERHEAT_FIRE
	if(machinetemp >= 600.15) //"OH SHIT! GET THE FUCK OUT OF HERE! WHAT ARE YOU DOING? GO! GET THE FUCK OUT OF HERE, YOU STUPID IDIOT! FUCK, WE'RE ALL DEAD! GET THE FUCK OUT!"
		overheated = OVERHEAT_EXPLOSION
	return
////////////////////////////////////////////////////////////////////////////////////////////

/mob/proc/canUseTopic() //TODO: once finished, place these procs on the respective mob files
	return

/mob/dead/observer/canUseTopic()
	if(check_rights(R_ADMIN, 0))
		return

/mob/living/canUseTopic(atom/movable/M, be_close = 0, no_dextery = 0)
	if(incapacitated())
		return
	if(no_dextery)
		if(be_close && in_range(M, src))
			return 1
	else
		src << "<span class='notice'>You don't have the dexterity to do this!</span>"
	return

/mob/living/carbon/human/canUseTopic(atom/movable/M, be_close = 0)
	if(incapacitated() || lying )
		return
	if(!Adjacent(M))
		if((be_close == 0) && (dna.check_mutation(TK)))
			if(tkMaxRangeCheck(src, M))
				return 1
		return
	if(!isturf(M.loc) && M.loc != src)
		return
	if(is_blind(src))
		src << "<span class='warning'>You cannot see [M]!</span>"
		return
	if(getBrainLoss() >= 60)
		visible_message("<span class='danger'>[src] stares cluelessly at [M] and drools.</span>")
		return
	if(prob(getBrainLoss()))
		src << "<span class='warning'>You momentarily forget how to use [M]!</span>"
		return
	return 1

/mob/living/silicon/ai/canUseTopic(atom/movable/M, be_close = 0)
	if(stat)
		return
	if(control_disabled)
		return
	if(be_close && !in_range(M, src))
		return
	//stop AIs from leaving windows open and using then after they lose vision
	//apc_override is needed here because AIs use their own APC when powerless
	//get_turf_pixel() is because APCs in maint aren't actually in view of the inner camera
	//get_turf_pixel() is not returning the right turf, get_turf will work for now because we don't have maint APCs - Zaers 2015-08-15
	if(cameranet && !cameranet.checkTurfVis(get_turf(M)) && !apc_override)
		return
	return 1

/mob/living/silicon/robot/canUseTopic(atom/movable/M, be_close = 0)
	if(stat || lockcharge || stunned || weakened)
		return
	if(be_close && !in_range(M, src))
		return
	return 1

/obj/machinery/attack_ai(mob/user as mob)
	if(isrobot(user))
		// For some reason attack_robot doesn't work
		// This is to stop robots from using cameras to remotely control machines.
		if(user.client && user.client.eye == user)
			return src.attack_hand(user)
	else
		return src.attack_hand(user)

/obj/machinery/attack_paw(mob/user as mob)
	return src.attack_hand(user)

//set_machine must be 0 if clicking the machinery doesn't bring up a dialog
/obj/machinery/attack_hand(mob/user as mob, var/check_power = 1, var/set_machine = 1)
	if(user.lying || user.stat)
		return 1
	if(!user.IsAdvancedToolUser())
		usr << "<span class='danger'>You don't have the dexterity to do this!</span>"
		return 1
/*
	//distance checks are made by atom/proc/DblClick
	if ((get_dist(src, user) > 1 || !istype(src.loc, /turf)) && !istype(user, /mob/living/silicon))
		return 1
*/
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 60)
			visible_message("<span class='danger'>[H] stares cluelessly at [src] and drools.</span>")
			return 1
		else if(prob(H.getBrainLoss()))
			user << "<span class='danger'>You momentarily forget how to use [src].</span>"
			return 1
		if(is_blind(H))
			src << "<span class='warning'>You cannot see [src]!</span>"
			return
	if(panel_open)
		src.add_fingerprint(user)
		return 0
	if(check_power && stat & NOPOWER)
		user << "<span class='danger'>\The [src] seems unpowered.</span>"
		return 1
	if(!interact_offline && stat & (BROKEN|MAINT))
		user << "<span class='danger'>\The [src] seems broken.</span>"
		return 1

	src.add_fingerprint(user)
	if(set_machine)
		user.set_machine(src)
	return 0

/obj/machinery/CheckParts()
	RefreshParts()
	return

/obj/machinery/proc/RefreshParts() //Placeholder proc for machines that are built using frames.
	return

/obj/machinery/proc/assign_uid()
	uid = gl_uid
	gl_uid++

/obj/machinery/proc/default_pry_open(var/obj/item/weapon/crowbar/C)
	. = !(state_open || panel_open || is_operational()) && istype(C)
	if(.)
		playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
		visible_message("<span class = 'notice'>[usr] pry open \the [src].</span>", "<span class = 'notice'>You pry open \the [src].</span>")
		open_machine()
		return 1

/obj/machinery/proc/default_deconstruction_crowbar(var/obj/item/weapon/crowbar/C, var/ignore_panel = 0)
	. = istype(C) && (panel_open || ignore_panel)
	if(.)
		playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
		var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
		M.status = 2
		M.icon_state = "box_1"
		M.machinetemp = src.machinetemp
		for(var/obj/item/I in component_parts)
			if(I.reliability != 100 && crit_fail)
				I.crit_fail = 1
			if((machine_flags & DELNOTEJECT) || machinetemp >= 600)
				qdel(I)
			else
				I.loc = src.loc
		if (machinetemp >= 600)
			visible_message("<span class = 'danger'>A disfigured piece of metal falls out of the machine!</span>")
		qdel(src)

/obj/machinery/proc/default_deconstruction_screwdriver(var/mob/user, var/icon_state_open, var/icon_state_closed, var/obj/item/weapon/screwdriver/S)
	if(istype(S))
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		if(!panel_open)
			panel_open = 1
			icon_state = icon_state_open
			user << "<span class='notice'>You open the maintenance hatch of [src].</span>"
		else
			panel_open = 0
			icon_state = icon_state_closed
			user << "<span class='notice'>You close the maintenance hatch of [src].</span>"
		return 1
	return 0

/obj/machinery/proc/default_change_direction_wrench(var/mob/user, var/obj/item/weapon/wrench/W)
	if(panel_open && istype(W))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		dir = turn(dir,-90)
		user << "<span class='notice'>You rotate [src].</span>"
		return 1
	return 0

/obj/machinery/proc/default_unfasten_wrench(mob/user, obj/item/weapon/wrench/W, time = 20)
	if(state == 2 && src.machine_flags & WELD_FIXED)
		user <<"\The [src] has to be unwelded from the floor first."
		return 0
	if(istype(W))
		user << "<span class='notice'>Now [anchored ? "un" : ""]securing [name].</span>"
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, time, target = src))
			user << "<span class='notice'>You've [anchored ? "un" : ""]secured [name].</span>"
			anchored = !anchored
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			if(machine_flags & FIXED2WORK)
				power_change() //updates us to turn on or off as necessary
			state = anchored //since these values will match as long as state isn't 2, we can do this safely
		return 1
	return 0


/obj/machinery/proc/default_floor_weld(mob/user, obj/item/weapon/weldingtool/W, time = 20)
	if(!anchored)
		state = 0 //since this might be wrong, we go sanity
		user << "You need to secure \the [src] before it can be welded."
		return -1
	if (W.remove_fuel(0,user))
		playsound(get_turf(src), 'sound/items/Welder2.ogg', 50, 1)
		user.visible_message("[user.name] starts to [state - 1 ? "unweld": "weld" ] the [src] [state - 1 ? "from" : "to"] the floor.", \
				"You start to [state - 1 ? "unweld": "weld" ] the [src] [state - 1 ? "from" : "to"] the floor.", \
				"You hear welding.")
		if (do_after(user, time, target = src))
			if(!src || !W.isOn())
				return -1
			switch(state)
				if(0)
					user <<"You have to keep \the [src] secure before it can be welded down."
					return -1
				if(1)
					state = 2
				if(2)
					state = 1
			user.visible_message(	"[user.name] [state - 1 ? "weld" : "unweld"]s \the [src] [state - 1 ? "to" : "from"] the floor.",
									"\icon [src] You [state - 1 ? "weld" : "unweld"] \the [src] [state - 1 ? "to" : "from"] the floor."
								)
			return 1
	else
		user << "<span class='rose'>You need more welding fuel to complete this task.</span>"
		return -1

/obj/machinery/proc/exchange_parts(mob/user, obj/item/weapon/storage/part_replacer/W)
	var/shouldplaysound = 0
	if(istype(W) && component_parts)
		if(panel_open || W.works_from_distance)
			var/obj/item/weapon/circuitboard/CB = locate(/obj/item/weapon/circuitboard) in component_parts
			var/P
			if(W.works_from_distance)
				user << "<span class='notice'>Following parts detected in the machine:</span>"
				for(var/var/obj/item/C in component_parts)
					user << "<span class='notice'>    [C.name]</span>"
			for(var/obj/item/weapon/A in component_parts) //"Feels good to me?" I wish it did to me.
				for(var/D in CB.req_components)
					if(ispath(A.type, D)) //if it's a req_component (aka not a circuit board)
						P = D //this is the part we're replacing in the machine and we're looking for in the rped
						break
				for(var/obj/item/weapon/B in W.contents)
					if(istype(B, P) && istype(A, P)) //if we have this part in the rped continue
						if(B.rating > A.rating)
							W.remove_from_storage(B, src)
							W.handle_item_insertion(A, 1)
							component_parts -= A
							component_parts += B
							B.loc = null
							user << "<span class='notice'>[A.name] replaced with [B.name].</span>"
							shouldplaysound = 1 //Only play the sound when parts are actually replaced!
							break
			RefreshParts()
		else
			user << "<span class='notice'>Following parts detected in the machine:</span>"
			for(var/var/obj/item/C in component_parts)
				user << "<span class='notice'>    [C.name]</span>"
		if(shouldplaysound)
			W.play_rped_sound()
		return 1
	return 0

//called on machinery construction (i.e from frame to machinery) but not on initialization
/obj/machinery/proc/construction()
	return


/obj/machinery/proc/multitool_topic(var/mob/user,var/list/href_list,var/obj/O)
	if("set_id" in href_list)
		if(!("id_tag" in vars))
			warning("set_id: [type] has no id_tag var.")
		var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag for this machine", src, src:id_tag) as null|text),1,MAX_MESSAGE_LEN)
		if(newid)
			src:id_tag = newid
			return MT_UPDATE|MT_REINIT
	if("set_freq" in href_list)
		if(!("frequency" in vars))
			warning("set_freq: [type] has no frequency var.")
			return 0
		var/newfreq=src:frequency
		if(href_list["set_freq"]!="-1")
			newfreq=text2num(href_list["set_freq"])
		else
			newfreq = input(usr, "Specify a new frequency (GHz). Decimals assigned automatically.", src, src:frequency) as null|num
		if(newfreq)
			if(findtext(num2text(newfreq), "."))
				newfreq *= 10 // shift the decimal one place
			if(newfreq < 10000)
				src:frequency = newfreq
				return MT_UPDATE|MT_REINIT
	return 0

/obj/machinery/proc/handle_multitool_topic(var/href, var/list/href_list, var/mob/user)
	var/obj/item/device/multitool/P = get_multitool(usr)
	if(P && istype(P))
		var/update_mt_menu=0
		var/re_init=0
		if("set_tag" in href_list)
			if(!(href_list["set_tag"] in multitool_var_whitelist))
				var/current_tag = src.vars[href_list["set_tag"]]
				var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag", src, current_tag) as null|text),1,MAX_MESSAGE_LEN)
				log_game("[key_name(usr)] attempted to modify variable(var = [href_list["set_tag"]], value = [newid]) using multitool")
				message_admins("[key_name_admin(usr)](<A HREF='?_src_=holder;adminplayerobservefollow=\ref[usr]'>FLW</A>) attempted to modify variable(var = [href_list["set_tag"]], value = [newid]) using multitool")
				return
			if(!(href_list["set_tag"] in vars))
				usr << "<span class='warning'>Something went wrong: Unable to find [href_list["set_tag"]] in vars!</span>"
				return 1
			var/current_tag = src.vars[href_list["set_tag"]]
			var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag", src, current_tag) as null|text),1,MAX_MESSAGE_LEN)
			if(newid)
				vars[href_list["set_tag"]] = newid
				re_init=1

		if("unlink" in href_list)
			var/idx = text2num(href_list["unlink"])
			if (!idx)
				return 1

			var/obj/O = getLink(idx)
			if(!O)
				return 1
			if(!canLink(O))
				usr << "<span class='warning'>You can't link with that device.</span>"
				return 1

			if(unlinkFrom(usr, O))
				usr << "<span class='confirm'>A green light flashes on \the [P], confirming the link was removed.</span>"
			else
				usr << "<span class='attack'>A red light flashes on \the [P].  It appears something went wrong when unlinking the two devices.</span>"
			update_mt_menu=1

		if("link" in href_list)
			var/obj/O = P.buffer
			if(!O)
				return 1
			if(!canLink(O,href_list))
				usr << "<span class='warning'>You can't link with that device.</span>"
				return 1
			if (isLinkedWith(O))
				usr << "<span class='attack'>A red light flashes on \the [P]. The two devices are already linked.</span>"
				return 1

			if(linkWith(usr, O, href_list))
				usr << "<span class='confirm'>A green light flashes on \the [P], confirming the link has been created.</span>"
			else
				usr << "<span class='attack'>A red light flashes on \the [P].  It appears something went wrong when linking the two devices.</span>"
			update_mt_menu=1

		if("buffer" in href_list)
			if(istype(src, /obj/machinery/telecomms))
				if(!hasvar(src, "id"))
					usr << "<span class='danger'>A red light flashes and nothing changes.</span>"
					return
			else if(!hasvar(src, "id_tag"))
				usr << "<span class='danger'>A red light flashes and nothing changes.</span>"
				return
			P.buffer = src
			usr << "<span class='confirm'>A green light flashes, and the device appears in the multitool buffer.</span>"
			update_mt_menu=1

		if("flush" in href_list)
			usr << "<span class='confirm'>A green light flashes, and the device disappears from the multitool buffer.</span>"
			P.buffer = null
			update_mt_menu=1

		var/ret = multitool_topic(usr,href_list,P.buffer)
		if(ret == MT_ERROR)
			return 1
		if(ret & MT_UPDATE)
			update_mt_menu=1
		if(ret & MT_REINIT)
			re_init=1

		if(re_init)
			initialize()
		if(update_mt_menu)
			//usr.set_machine(src)
			update_multitool_menu(usr)
			return 1

/obj/machinery/attackby(var/obj/O, var/mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	if(istype(O, /obj/item/weapon/card/emag))//&& machine_flags & EMAGGABLE) //Will do nothing if it has no emag_act
		emag_act(user)
		return

	if(istype(O, /obj/item/weapon/storage/part_replacer) && machine_flags & REPLACEPARTS)
		if(exchange_parts(user, O))
			return

	if(istype(O, /obj/item/weapon/crowbar) && machine_flags & CROWPRY)
		if(default_pry_open(O))
			return

	if(istype(O, /obj/item/weapon/wrench) && machine_flags & WRENCHMOVE) //make sure this is BEFORE the fixed2work check
		if(!panel_open)
			if(default_unfasten_wrench(user, O, wrench_time))
				return
			else
				user <<"<span class='warning'>\The [src]'s maintenance panel must be closed first!</span>"
				return -1 //we return -1 rather than 0 for the if(..()) checks

	if(istype(O, /obj/item/weapon/screwdriver) && machine_flags & SCREWTOGGLE)
		if(default_deconstruction_screwdriver(user, icon_open, icon_closed, O))
			return

	if(istype(O, /obj/item/weapon/weldingtool) && machine_flags & WELD_FIXED)
		if(default_floor_weld(user, O, weld_time))
			return

	if(istype(O, /obj/item/weapon/crowbar) && machine_flags & CROWDESTROY)
		default_deconstruction_crowbar(O, closed_panel_decon)

	if(istype(O, /obj/item/device/multitool) && machine_flags & MULTITOOL_MENU)
		update_multitool_menu(user)
		return 1

	if(istype(O, /obj/item/weapon/wrench) && machine_flags & WRENCHROTATE)
		if(default_change_direction_wrench(user, O))
			return

	if(!anchored && machine_flags & FIXED2WORK)
		return user << "<span class='warning'>\The [src] must be anchored first!</span>"

// Hook for html_interface module to prevent updates to clients who don't have this as their active machine.
/obj/machinery/proc/hiIsValidClient(datum/html_interface_client/hclient, datum/html_interface/hi)
	if (hclient.client.mob && hclient.client.mob.stat == 0)
		if (isAI(hclient.client.mob)) return TRUE
		else                          return hclient.client.mob.machine == src && src.Adjacent(hclient.client.mob)
	else
		return FALSE

// Hook for html_interface module to unset the active machine when the window is closed by the player.
/obj/machinery/proc/hiOnHide(datum/html_interface_client/hclient)
	if (hclient.client.mob && hclient.client.mob.machine == src) hclient.client.mob.unset_machine()
