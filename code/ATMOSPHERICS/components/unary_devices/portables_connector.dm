/obj/machinery/atmospherics/components/unary/portables_connector
	name = "connector port"
	desc = "For connecting portables devices related to atmospherics control."
	icon = 'icons/obj/atmospherics/components/unary_devices.dmi'
	icon_state = "connector_map" //Only for mapping purposes, so mappers can see direction
	can_buckle = 1
	can_unwrench = 1
	var/obj/machinery/portable_atmospherics/connected_device
	var/image/connect_overlay
	use_power = 0
	level = 0
/obj/machinery/atmospherics/components/unary/portables_connector/New()
	..()
	connect_overlay = image('icons/obj/atmos.dmi', "can-connector", layer=MOB_LAYER + 0.2)

/obj/machinery/atmospherics/components/unary/portables_connector/visible
	level = 2

/obj/machinery/atmospherics/components/unary/portables_connector/process_atmos()
	if(!connected_device)
		return
	update_parents()

/obj/machinery/atmospherics/components/unary/portables_connector/Destroy()
	if(connected_device)
		connected_device.disconnect()
	..()

/obj/machinery/atmospherics/components/unary/portables_connector/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench))
		if(connected_device)
			user << "<span class='warning'>You cannot unwrench this [src], dettach [connected_device] first!</span>"
			return 1
	return ..()

/obj/machinery/atmospherics/components/unary/portables_connector/portableConnectorReturnAir()
	return connected_device.portableConnectorReturnAir()

/obj/proc/portableConnectorReturnAir()


/obj/machinery/atmospherics/components/unary/portables_connector/user_buckle_mob(mob/living/M, mob/living/user)
	if(!user.Adjacent(M) || user.restrained() || user.stat || !istype(user))
		return
	if(!istype(M, /mob/living/silicon/robot))
		return //can only buckle atmosborgs to this thing
	var/mob/living/silicon/robot/R = M
	if(!istype(R.module, /obj/item/weapon/robot_module/atmospheric)) //This could probably be expressed better, but this will work for now
		return
	add_fingerprint(user)
	unbuckle_mob()

	if(buckle_mob(M))
		if(M == user)
			M.visible_message(\
				"<span class='notice'>[M.name] connects themselves to [src].</span>",\
				"<span class='notice'>You connect yourself to [src].</span>",\
				"<span class='notice'>You hear metal clanking.</span>")
		else
			M.visible_message(\
				"<span class='danger'>[M.name] is connected to [src] by [user.name]!</span>",\
				"<span class='danger'>You are connected to [src] by [user.name]!</span>",\
				"<span class='notice'>You heat metal clanking.</span>")

/obj/machinery/atmospherics/components/unary/portables_connector/post_buckle_mob(mob/living/M)
	if(M == buckled_mob)
		var/mob/living/silicon/robot/R = M
		if(istype(R))
			var/obj/item/weapon/robot_module/atmospheric/AM = R.module
			if(istype(AM) && AM.internal_canister)
				overlays += connect_overlay
				AM.internal_canister.connect(src)
	else
		var/mob/living/silicon/robot/R = M
		if(istype(R))
			var/obj/item/weapon/robot_module/atmospheric/AM = R.module
			if(istype(AM) && AM.internal_canister)
				overlays -= connect_overlay
				AM.internal_canister.disconnect()


/obj/machinery/atmospherics/components/unary/portables_connector/user_unbuckle_mob(mob/user)
	var/mob/living/M = unbuckle_mob()

	if(M)
		if(M != user)
			M.visible_message(\
				"<span class='notice'>[M.name] was disconnected by [user.name]!</span>",\
				"<span class='notice'>You were disconnected from [src] by [user.name].</span>",\
				"<span class='notice'>You hear metal clanking.</span>")
		else
			M.visible_message(\
				"<span class='notice'>[M.name] disconnected themselves!</span>",\
				"<span class='notice'>You disconnect yourself from [src].</span>",\
				"<span class='notice'>You hear metal clanking.</span>")
		add_fingerprint(user)
	return M

/obj/machinery/atmospherics/components/unary/portables_connector/attack_robot(mob/living/user)
	if(Adjacent(user))
		if(buckled_mob)
			user_unbuckle_mob(user)
	..()