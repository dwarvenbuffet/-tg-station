#define SOLID 1
#define LIQUID 2
#define GAS 3

/obj/machinery/reagentgrinder

	name = "All-In-One Grinder"
	desc = "Used to grind things up into raw materials."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	layer = 2.9
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	pass_flags = PASSTABLE
	var/operating = 0
	var/obj/item/weapon/reagent_containers/beaker = null
	var/limit = 10

	var/list/dried_items = list(
		//Grinder stuff, but only if dry,
		/obj/item/weapon/reagent_containers/food/snacks/grown/coffee,
		/obj/item/weapon/reagent_containers/food/snacks/grown/tea,
	)

	var/list/holdingitems = list()


/obj/machinery/reagentgrinder/New()
	..()
	beaker = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/grinder(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(null)
	return

/obj/machinery/reagentgrinder/update_icon()
	icon_state = "juicer"+num2text(!isnull(beaker))
	return


/obj/machinery/reagentgrinder/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(default_unfasten_wrench(user, O))
		return

	if(default_deconstruction_screwdriver(user, "juicer-o", "juicer0", O))
		if(beaker)
			beaker.loc = src.loc
			beaker = null
		return

	if(exchange_parts(user, O))
		return

	if(panel_open)
		if(istype(O, /obj/item/weapon/crowbar))
			default_deconstruction_crowbar(O)
			return 1
		else
			user << "<span class='warning'>You can't use the [src.name] while it's panel is opened!</span>"
			return 1


	if (istype(O,/obj/item/weapon/reagent_containers/glass) || \
		istype(O,/obj/item/weapon/reagent_containers/food/drinks/drinkingglass) || \
		istype(O,/obj/item/weapon/reagent_containers/food/drinks/shaker))

		if (beaker)
			return 1
		else
			src.beaker =  O
			user.drop_item()
			O.loc = src
			update_icon()
			src.updateUsrDialog()
			return 0

	if(is_type_in_list(O, dried_items))
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown))
			var/obj/item/weapon/reagent_containers/food/snacks/grown/G = O
			if(!G.dry)
				user << "<span class='notice'>You must dry that first!</span>"
				return 1

	if(holdingitems && holdingitems.len >= limit)
		usr << "The machine cannot hold any more items."
		return 1

	//Fill machine with a bag!
	if(istype(O, /obj/item/weapon/storage/bag))
		var/obj/item/weapon/storage/bag/B = O

		for (var/obj/item/weapon/reagent_containers/food/snacks/grown/G in B.contents)
			B.remove_from_storage(G, src)
			holdingitems += G
			if(holdingitems && holdingitems.len >= limit) //Sanity checking so the blender doesn't overfill
				user << "You fill the All-In-One grinder to the brim."
				break

			if(!O.contents.len)
				user << "You empty the plant bag into the All-In-One grinder."

		src.updateUsrDialog()
		return 0

	if (isnull(O.grind_reagents) && isnull(O.juice_reagents))
		..()
		user << "Cannot refine into a reagent."
		return 1

	user.unEquip(O)
	O.loc = src
	holdingitems += O
	src.updateUsrDialog()
	return 0

/obj/machinery/reagentgrinder/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/reagentgrinder/attack_ai(mob/user as mob)
	return 0

/obj/machinery/reagentgrinder/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)

/obj/machinery/reagentgrinder/interact(mob/user) // The microwave Menu
	var/is_chamber_empty = 0
	var/is_beaker_ready = 0
	var/processing_chamber = ""
	var/beaker_contents = ""
	var/dat = ""

	if(!operating)
		for (var/obj/item/O in holdingitems)
			processing_chamber += "\A [O.name]<BR>"

		if (!processing_chamber)
			is_chamber_empty = 1
			processing_chamber = "Nothing."
		if (!beaker)
			beaker_contents = "<B>No beaker attached.</B><br>"
		else
			is_beaker_ready = 1
			beaker_contents = "<B>The beaker contains:</B><br>"
			var/anything = 0
			for(var/datum/reagent/R in beaker.reagents.reagent_list)
				anything = 1
				beaker_contents += "[R.volume] - [R.name]<br>"
			if(!anything)
				beaker_contents += "Nothing<br>"


		dat = {"
		<b>Processing chamber contains:</b><br>
		[processing_chamber]<br>
		[beaker_contents]<hr>
		"}
		if (is_beaker_ready && !is_chamber_empty && !(stat & (NOPOWER|BROKEN)))
			dat += "<A href='?src=\ref[src];action=grind'>Grind the reagents</a><BR>"
			dat += "<A href='?src=\ref[src];action=juice'>Juice the reagents</a><BR><BR>"
		if(holdingitems && holdingitems.len > 0)
			dat += "<A href='?src=\ref[src];action=eject'>Eject the reagents</a><BR>"
		if (beaker)
			dat += "<A href='?src=\ref[src];action=detach'>Detach the beaker</a><BR>"
	else
		dat += "Please wait..."

	var/datum/browser/popup = new(user, "reagentgrinder", "All-In-One Grinder")
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open(1)
	return

/obj/machinery/reagentgrinder/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	if(operating)
		updateUsrDialog()
		return
	switch(href_list["action"])
		if ("grind")
			grind()
		if("juice")
			juice()
		if("eject")
			eject()
		if ("detach")
			detach()

/obj/machinery/reagentgrinder/proc/detach()

	if (usr.stat != 0)
		return
	if (!beaker)
		return
	beaker.loc = src.loc
	beaker = null
	update_icon()
	updateUsrDialog()

/obj/machinery/reagentgrinder/proc/eject()

	if (usr.stat != 0)
		return
	if (holdingitems && holdingitems.len == 0)
		return

	for(var/obj/item/O in holdingitems)
		O.loc = src.loc
		holdingitems -= O
	holdingitems = list()
	updateUsrDialog()

/obj/machinery/reagentgrinder/proc/is_allowed(obj/item/weapon/reagent_containers/O)
	if(!isnull(O.grind_reagents))
		return 1
	return 0

/obj/machinery/reagentgrinder/proc/get_allowed_by_id(obj/item/O)
	return O.grind_reagents


/obj/machinery/reagentgrinder/proc/get_allowed_juice_by_id(obj/item/weapon/reagent_containers/food/snacks/O)
	return O.juice_reagents

/obj/machinery/reagentgrinder/proc/get_grownweapon_amount(obj/item/weapon/grown/O)
	if (!istype(O))
		return 5
	else if (O.potency == -1)
		return 5
	else
		return round(O.potency)

/obj/machinery/reagentgrinder/proc/get_juice_amount(obj/item/weapon/reagent_containers/food/snacks/grown/O)
	if (!istype(O))
		return 5
	else if (O.potency == -1)
		return 5
	else
		return round(5*sqrt(O.potency))

/obj/machinery/reagentgrinder/proc/remove_object(obj/item/O)
	holdingitems -= O
	qdel(O)

/obj/machinery/reagentgrinder/proc/juice()
	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	playsound(src.loc, 'sound/machines/juicer.ogg', 20, 1)
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 250) //start shaking
	operating = 1
	updateUsrDialog()
	spawn(50)
		pixel_x = initial(pixel_x) //return to its spot after shaking
		operating = 0
		updateUsrDialog()

	//Snacks
	for (var/obj/item/weapon/reagent_containers/food/snacks/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break

		var/allowed = get_allowed_juice_by_id(O)
		if(isnull(allowed))
			break

		for (var/r_id in allowed)
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = get_juice_amount(O)

			beaker.reagents.add_reagent(r_id, min(amount, space))

			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break

		remove_object(O)

/obj/machinery/reagentgrinder/proc/crystal_fail()

	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		var/shouldteleport = prob(5)
		if (shouldteleport)
			if (M.rating == 1)
				visible_message("<span class='warning'>The [src.name] sparkles and fizzes!</span>") //boy indenting is fucking hard
				explosion(get_turf(src.loc),0,1,2,3)
				for (var/atom/movable/teleportthis in view(3, src.loc)) //purloined from anomaly code
					if(istype(teleportthis, /obj/item/device/beacon))
						continue
					if(istype(teleportthis, /atom/movable/lighting_overlay))
						continue
					if(teleportthis.anchored)
						continue
					do_teleport(teleportthis, get_turf(src.loc), 4, asoundin = 'sound/effects/phasein.ogg')
			else if (M.rating == 2)
				for (var/atom/movable/teleportthis in view(2, src.loc)) //purloined from anomaly code
					if(istype(teleportthis, /obj/item/device/beacon))
						continue
					if(istype(teleportthis, /atom/movable/lighting_overlay))
						continue
					if(teleportthis.anchored)
						continue
					do_teleport(teleportthis, get_turf(src.loc), 2, asoundin = 'sound/effects/phasein.ogg')
			else //upgraded to tier 3 or above

/obj/machinery/reagentgrinder/proc/grind()

	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	playsound(src.loc, 'sound/machines/blender.ogg', 50, 1)
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 250) //start shaking
	operating = 1
	updateUsrDialog()
	spawn(60)
		pixel_x = initial(pixel_x) //return to its spot after shaking
		operating = 0
		updateUsrDialog()

	//Snacks and Plants
	for (var/obj/item/weapon/reagent_containers/food/snacks/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break

		var/list/allowed = get_allowed_by_id(O)
		if(isnull(allowed))
			break

		for (var/r_id in allowed)

			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			if(amount <= 0)
				if(amount == 0)
					if (O.reagents != null && O.reagents.has_reagent("nutriment"))
						beaker.reagents.add_reagent(r_id, min(O.reagents.get_reagent_amount("nutriment"), space))
						O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))
				else
					if (O.reagents != null && O.reagents.has_reagent("nutriment"))
						beaker.reagents.add_reagent(r_id, min(round(O.reagents.get_reagent_amount("nutriment")*abs(amount)), space))
						O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))

			else
				O.reagents.trans_id_to(beaker, r_id, min(amount, space))

		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		if(O.reagents.reagent_list.len == 0)
			remove_object(O)

	//Sheets
	for (var/obj/item/stack/sheet/O in holdingitems)
		var/list/allowed = get_allowed_by_id(O)
		if(isnull(allowed))
			break

		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		for (var/r_id in allowed)
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id] * O.amount
			beaker.reagents.add_reagent(r_id,min(amount, space))
			if (space < amount)
				break
		remove_object(O)

	//Plants
	for (var/obj/item/weapon/grown/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/list/allowed = get_allowed_by_id(O)
		if(isnull(allowed))
			break

		for (var/r_id in allowed)
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			if (amount == 0)
				if (O.reagents != null && O.reagents.has_reagent(r_id))
					beaker.reagents.add_reagent(r_id,min(O.reagents.get_reagent_amount(r_id), space))
				else
					beaker.reagents.add_reagent(r_id,min(amount, space))

			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break
		remove_object(O)

	//Crayons
	//With some input from aranclanos, now 30% less shoddily copypasta
	for (var/obj/item/toy/crayon/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/list/allowed = get_allowed_by_id(O)
		if(isnull(allowed))
			break
		for (var/r_id in allowed)
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			beaker.reagents.add_reagent(r_id,min(amount, space))
			if (space < amount)
				break
		remove_object(O)

	//Bluespace Crystals
	for (var/obj/item/bluespace_crystal/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/list/allowed = get_allowed_by_id(O)
		if(isnull(allowed))
			break
		for (var/r_id in allowed)
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			beaker.reagents.add_reagent(r_id,min(amount, space))
			crystal_fail()
			if (space < amount) //end of grindan loop
				break
		remove_object(O)

		//Everything else - Transfers reagents from it into beaker
	for (var/obj/item/weapon/reagent_containers/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/amount = O.reagents.total_volume
		O.reagents.trans_to(beaker, amount)
		if(!O.reagents.total_volume)
			remove_object(O)