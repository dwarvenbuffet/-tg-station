#define SOLID 1
#define LIQUID 2
#define GAS 3

/obj/machinery/chem_dispenser/constructable
	name = "portable chem dispenser"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "minidispenser"
	var/baseicon = "minidispenser"
	energy = 0
	max_energy = 5
	amount = 5
	recharge_delay = 30
	dispensable_reagents = list()
	var/list/special_reagents = list(list("hydrogen", "oxygen", "silicon", "phosphorus", "sulfur", "carbon", "nitrogen", "water"),
						 		list("lithium", "sugar", "sacid", "copper", "mercury", "sodium","iodine","bromine","tungsten"),
								list("ethanol", "chlorine", "potassium", "aluminium", "radium", "fluorine", "iron", "fuel","silver","stable_plasma"),
								list("oil", "phenol", "acetone", "ammonia", "diethylamine"))

/obj/machinery/chem_dispenser/constructable/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/chem_dispenser(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/cell/high(null)
	RefreshParts()

/obj/machinery/chem_dispenser/constructable/RefreshParts()
	var/time = 0
	var/temp_energy = 0
	var/i
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		temp_energy += M.rating
	temp_energy--
	max_energy = temp_energy * 5  //max energy = (bin1.rating + bin2.rating - 1) * 5, 5 on lowest 25 on highest
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		time += C.rating
	for(var/obj/item/weapon/stock_parts/cell/P in component_parts)
		time += round(P.maxcharge, 10000) / 10000
	recharge_delay /= time/2         //delay between recharges, double the usual time on lowest 50% less than usual on highest
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		for(i=1, i<=M.rating, i++)
			dispensable_reagents = dispensable_reagents | special_reagents[i]
		//the parameter to sortList() must be a list and not a product of a list operation.
		//Watch for hits on git grep -E 'sortList\([^)]+\|[^)]+\)' , for example.
	dispensable_reagents = sortList( dispensable_reagents )

/obj/machinery/chem_dispenser/constructable/attackby(var/obj/item/I, var/mob/user, params)
	..()

	if(default_unfasten_wrench(user, I))
		return

	if(default_deconstruction_screwdriver(user, "[baseicon]-o", "[baseicon]", I))
		return

	if(exchange_parts(user, I))
		return

	if(panel_open)
		if(istype(I, /obj/item/weapon/crowbar))
			if(beaker)
				var/obj/item/weapon/reagent_containers/glass/B = beaker
				B.loc = loc
				beaker = null
			default_deconstruction_crowbar(I)
			return 1

/obj/machinery/chem_dispenser/constructable/booze
	name = "portable booze dispenser"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "booze_dispenser"
	baseicon = "booze_dispenser"
	dispensable_reagents = list()
	uiname = "Booze Dispenser"
	special_reagents = list(list("lemon_lime","sugar","orangejuice","limejuice","sodawater","tonic","beer","kahlua","whiskey","wine","vodka","gin","rum","tequila","vermouth","cognac","ale"),
						 		list(),  //Ideas for higher tier reagents?
								list(),
								list())

/obj/machinery/chem_dispenser/constructable/drinks
	name = "portable soda dispenser"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "soda_dispenser"
	baseicon = "soda_dispenser"
	dispensable_reagents = list()
	uiname = "Soda Dispenser"
	special_reagents = list(list("water","ice","coffee","cream","tea","icetea","cola","spacemountainwind","dr_gibb","space_up","tonic","sodawater","lemon_lime","sugar","orangejuice","limejuice","tomatojuice"),
						 		list(),
								list(),
								list())