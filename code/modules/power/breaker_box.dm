// Updated version of old powerswitch by Atlantis
// Has better texture, and is now considered electronic device
// AI has ability to toggle it in 5 seconds
// Humans need 30 seconds (AI is faster when it comes to complex electronics)
// Used for advanced grid control (read: Substations)

// Shamelessly stolen from Bay

/obj/machinery/power/breakerbox
	name = "Breaker Box"
	icon = 'icons/obj/power.dmi'
	icon_state = "bbox_off"
	//directwired = 0
	var/icon_state_on = "bbox_on"
	var/icon_state_off = "bbox_off"
	density = 1
	anchored = 1
	var/on = 0
	var/busy = 0
	var/directions = list(1,2,4,8,5,6,9,10)
	var/RCon_tag = "NO_TAG"
	var/update_locked = 0
	var/obj/structure/cable/breaker_cable = null
	var/obj/item/weapon/breaker/breaker_item = null

/obj/machinery/power/breakerbox/activated
	icon_state = "bbox_on"

/obj/machinery/power/breakerbox/New()
	..()
	breaker_item = new /obj/item/weapon/breaker(src)

	// Enabled on server startup. Used in substations to keep them in bypass mode.
/obj/machinery/power/breakerbox/activated/initialize()
	set_state(1)

/obj/machinery/power/breakerbox/examine(mob/user)
	user << "Large machine with heavy duty switching circuits used for advanced grid control"
	if(!breaker_item)
		user << "<span class='warning'>The breaker unit seems to be missing!</span>"
		return
	if(on)
		user << "\green It seems to be online."
	else
		user << "\red It seems to be offline"

/obj/machinery/power/breakerbox/attack_ai(mob/user)
	if(update_locked)
		user << "\red System locked. Please try again later."
		return

	if(busy)
		user << "\red System is busy. Please wait until current operation is finished before changing power settings."
		return

	busy = 1
	user << "\green Updating power settings.."
	if(do_after(user, 50))
		set_state(!on)
		user << "\green Update Completed. New setting:[on ? "on": "off"]"
	busy = 0


/obj/machinery/power/breakerbox/attack_hand(mob/user)
	if(update_locked)
		user << "\red System locked. Please try again later."
		return

	if(busy)
		user << "\red System is busy. Please wait until current operation is finished before changing power settings."
		return

	busy = 1
	for(var/mob/O in viewers(user))
		O.show_message(text("\red [user] started reprogramming [src]!"), 1)

	if(do_after(user, 50))
		set_state(!on)
		user.visible_message(\
		"<span class='notice'>[user.name] [on ? "enabled" : "disabled"] the breaker box!</span>",\
		"<span class='notice'>You [on ? "enabled" : "disabled"] the breaker box!</span>")
	busy = 0

/obj/machinery/power/breakerbox/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/device/multitool))
		var/newtag = stripped_input(user, "Enter new RCON tag. Use \"NO_TAG\" to disable RCON or leave empty to cancel.", "SMES RCON system")
		if(newtag)
			RCon_tag = newtag
			user << "<span class='notice'>You changed the RCON tag to: [newtag]</span>"
	if(istype(W, /obj/item/weapon/crowbar))
		if(!breaker_item)
			user << "<span class='notice'>The breaker box has no breaker in it.</span>"
			return
		if(on)
			user << "<span class='notice'>The [name] must be offline to remove the breaker unit.</span>"
			return
		user << "<span class='notice'>You start removing the breaker from the [name].</span>"
		if(do_after(user, 50, target = src))
			user << "<span class='notice'>You remove the breaker from the [name].</span>"
			breaker_item.remove_from_box(src)
	if(istype(W, /obj/item/weapon/breaker))
		var/obj/item/weapon/breaker/B = W
		if(breaker_item)
			user << "<span class='notice'>The [name] already has a breaker in it.</span>"
			return
		user << "<span class='notice'>You start inserting the breaker into the [name].</span>"
		if(do_after(user, 50, target = src))
			B.insert_into_box(src, user)
			user << "<span class='notice'>You insert the breaker into the [name].</span>"




/obj/machinery/power/breakerbox/proc/set_state(var/state)
	on = state
	if(on)
		icon_state = icon_state_on
		var/list/connection_dirs = list()
		for(var/direction in directions)
			for(var/obj/structure/cable/C in get_step(src,direction))
				if(C.d1 == turn(direction, 180) || C.d2 == turn(direction, 180))
					connection_dirs += direction
					break

		if(connection_dirs[2])
			var/obj/structure/cable/C = new/obj/structure/cable(src.loc)
			C.d1 = connection_dirs[1]
			C.d2 = connection_dirs[2]
			C.icon_state = "[C.d1]-[C.d2]"
			C.breaker_box = 1

			var/datum/powernet/PN = new()
			PN.add_cable(C)

			C.mergeConnectedNetworks(C.d1)
			C.mergeConnectedNetworks(C.d2)
			C.mergeConnectedNetworksOnTurf()

			if(C.d2 & (C.d2 - 1))// if the cable is layed diagonally, check the others 2 possible directions
				C.mergeDiagonalsNetworks(C.d2)
			breaker_cable = C

	else
		icon_state = icon_state_off
		for(var/obj/structure/cable/C in src.loc)
			qdel(C)
		breaker_cable = null
	for (var/obj/machinery/computer/monitor/mon in machines)
		mon.forceupdate()

// Used by RCON to toggle the breaker box.
/obj/machinery/power/breakerbox/proc/auto_toggle()
	if(!update_locked)
		set_state(!on)

/obj/machinery/power/breakerbox/process()
	if(!on)
		return 0
	if(!breaker_item)
		return 0
	if(breaker_cable && breaker_cable.powernet)
		breaker_item.handle_process(breaker_cable.powernet.avail)
	return 1

/obj/item/weapon/breaker //Balance values as needed
	icon = 'icons/obj/power.dmi'
	icon_state = "breaker"
	name = "breaker"
	var/max_power = 1000000
	var/obj/machinery/power/breakerbox/breaker = null

/obj/item/weapon/breaker/Destroy()
	if(breaker)
		remove_from_box(breaker)
	return ..()

/obj/item/weapon/breaker/proc/insert_into_box(var/obj/machinery/power/breakerbox/B, mob/living/user)
	user.unEquip(src)
	breaker = B
	B.breaker_item = src
	loc = B

/obj/item/weapon/breaker/proc/remove_from_box(var/obj/machinery/power/breakerbox/B)
	breaker = null
	B.breaker_item = null
	B.set_state(0)
	loc = get_turf(B)

/obj/item/weapon/breaker/proc/handle_process(breaker_power)
	if(!breaker)
		return
	if(breaker_power)
		if(breaker_power > max_power)
			breaker.set_state(0)
			return 1
	return 0


/obj/item/weapon/breaker/high_capacity
	name = "high-capacity breaker"
	icon_state = "breaker_high_capacity"
	max_power = 100000000

/obj/item/weapon/breaker/syndie
	icon_state = "breaker_syndie"
	//Has the same max power and name so you could disguise it as a regular breaker
	var/obj/item/device/assembly/signaler/embedded/signaler = null

/obj/item/weapon/breaker/syndie/New()
	..()
	signaler = new /obj/item/device/assembly/signaler/embedded(src)

/obj/item/weapon/breaker/syndie/embedded_pulse()
	if(breaker)
		breaker.auto_toggle()

/obj/item/weapon/breaker/syndie/attack_self(mob/user)
	if(signaler)
		signaler.attack_self(user) //pass it on to the signaler so the user can set it