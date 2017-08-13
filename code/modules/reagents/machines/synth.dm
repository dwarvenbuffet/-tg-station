#define SOLID 1
#define LIQUID 2
#define GAS 3

//this one is suposed to "learn" chems and then dispense them
//high power usage though.
/obj/machinery/chem_dispenser/constructable/synth
	name = "Advanced chem synthesizer"
	desc = "Synthesizes advanced chemicals."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "synth"
	recharging_power_usage = 5000
	var/default_power_usage = 5000 //default power usage without any upgrades
	energy = 0
	max_energy = 50
	amount = 10
	//beaker = null
	recharge_delay = 5  //Time it game ticks between recharges
	//var/image/icon_beaker = null //cached overlay, might not be needed here.
	uiname = "Advanced Chem Synthesizer"
	list/dispensable_reagents = list() //starts with no known chems

/obj/machinery/chem_dispenser/constructable/synth/fullenergy
	energy = 50

/obj/machinery/chem_dispenser/constructable/synth/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if(stat & (BROKEN)) return
	if(user.stat || user.restrained()) return
	ui = SSnano.push_open_or_new_ui(user, src, ui_key, ui, "chem_synth.tmpl", "[uiname]", 490, 710, 0)

/obj/machinery/chem_dispenser/constructable/synth/RefreshParts()
	var/time = 0
	var/temp_energy = 0
	var/i = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		temp_energy += M.rating
	temp_energy--
	max_energy = temp_energy * 20  //max energy = (bin1.rating + bin2.rating - 1) * 5, 20 on lowest 100 on highest
	energy = min(energy, max_energy)
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		time += C.rating
	for(var/obj/item/weapon/stock_parts/cell/P in component_parts)
		time += round(P.maxcharge, 10000) / 10000
	recharge_delay /= time/2         //delay between recharges, double the usual time on lowest 50% less than usual on highest
	i = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		if(i<=M.rating)
			i++
	if(i)
		recharging_power_usage = default_power_usage / i //better manipulator = less power consumed to recharge
	else
		recharging_power_usage = default_power_usage * 2 //shouldn't really happen, but wathever

/obj/machinery/chem_dispenser/constructable/synth/Topic(href, href_list)
	if(stat & (BROKEN))
		return 0 // don't update UIs attached to this object
	if(href_list["scanBeaker"])
		if(beaker)
			var/obj/item/weapon/reagent_containers/glass/B = beaker
			for(var/datum/reagent/R in B.reagents.reagent_list)
				if(R.can_synth)
					if(R.can_synth == 1 || (R.can_synth == 2 && emagged))
						add_known_reagent(R.id)
						usr << "Reagent analyzed, identified as [R.name] and added to database."
					else
						usr << "Illegal Reagent detected. NT safety regulations forbid replication of [R.name]."
				else
					usr << "Unable to scan reagent."
		return 1
	..()
	return 1

/obj/machinery/chem_dispenser/constructable/synth/proc/add_known_reagent(r_id)
	if(!(r_id in dispensable_reagents))
		dispensable_reagents += r_id
		return 1
	return 0

/obj/machinery/chem_dispenser/constructable/synth/emag_act(mob/user as mob)
	if(!emagged)
		playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
		emagged = 1
		user << "<span class='notice'> You you disable the safety regulation unit.</span>"
