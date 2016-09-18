/obj/item/device/canistermanipulator
	name = "Canister Manipulator"
	desc = "This device is used to modify a linked canister"
	icon_state = "canmanip-0"
	var/obj/machinery/portable_atmospherics/canister/can

/obj/item/device/canistermanipulator/Destroy()
	can = null
	..()

/obj/item/device/canistermanipulator/attack_self(mob/user)
	if(can)
		can.ui_interact(user)
	else
		user << "<span class='warning'>There's no canister linked to this device.</span>"
	return

/obj/item/device/canistermanipulator/update_icon()
	if(can)
		icon_state = "canmanip-1"
	else
		icon_state = "canmanip-0"
	return

/obj/item/device/canistermanipulator/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/device/analyzer) && can)
		can.atmosanalyzer_scan(can.air_contents, user)
	return

/obj/item/device/canistermanipulator/proc/set_canister(obj/machinery/portable_atmospherics/canister/C)
	can = C
	update_icon()

/obj/item/device/canistermanipulator/proc/unlink_canister()
	can = null
	update_icon()


/obj/item/device/tankmanipulator
	name = "Tank Manipulator"
	desc = "This device is used to manipulate gas tanks"
	icon_state = "tankmanip-0"
	var/obj/item/weapon/tank/tank

/obj/item/device/tankmanipulator/Destroy()
	tank = null
	..()

/obj/item/device/tankmanipulator/attack_self(mob/user)
	ui_interact(user)

/obj/item/device/tankmanipulator/update_icon()
	if(tank)
		icon_state = "tankmanip-1"
	else
		icon_state = "tankmanip-0"
	return

/obj/item/device/tankmanipulator/interact(mob/user, ui_key = "main")
	SSnano.try_update_ui(user, src, ui_key, null, src.get_ui_data())

/obj/item/device/tankmanipulator/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	ui = SSnano.push_open_or_new_ui(user, src, ui_key, ui, "tankmanip.tmpl", "Tank Manipulator", 500, 300, 0)

/obj/item/device/tankmanipulator/get_ui_data()
	// this is the data which will be sent to the ui
	var/data = list()
	data["hasTank"] = tank ? 1 : 0
	if(tank)
		data["tankPressure"] = round(tank.air_contents.return_pressure() ? tank.air_contents.return_pressure() : 0)
		data["tankName"] = tank.name

	return data

/obj/item/device/tankmanipulator/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/device/analyzer) && tank)
		tank.atmosanalyzer_scan(tank.air_contents, user)
	return

/obj/item/device/tankmanipulator/Topic(href, href_list)
	..()
	if (usr.stat|| usr.restrained())
		return
	if (loc == usr)
		usr.set_machine(src)
		if(href_list["eject"])
			pop_tank(usr.loc)
		src.add_fingerprint(usr)
		src.attack_self(usr)
	else
		usr << browse(null, "window=tankmanip")
		return
	return

/obj/item/device/tankmanipulator/proc/load_tank(var/obj/item/weapon/tank/T)
	if(!T) //edge case
		return
	T.loc = src
	tank = T
	update_icon()
	return

/obj/item/device/tankmanipulator/proc/pop_tank(new_loc)
	if(!tank)
		return null
	var/obj/item/weapon/tank/T = tank
	T.loc = new_loc
	tank = null
	update_icon()
	return T