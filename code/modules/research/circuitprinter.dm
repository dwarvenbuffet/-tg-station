/*///////////////Circuit Imprinter (By Darem)////////////////////////
	Used to print new circuit boards (for computers and similar systems) and AI modules. Each circuit board pattern are stored in
a /datum/desgin on the linked R&D console. You can then print them out in a fasion similar to a regular lathe. However, instead of
using metal and glass, it uses glass and reagents (usually sulfuric acis).

*/
/obj/machinery/r_n_d/circuit_imprinter
	name = "Circuit Imprinter"
	desc = "Manufactures circuit boards for the construction of machines."
	icon_state = "circuit_imprinter"
	flags = OPENCONTAINER

	var/g_amount = 0
	var/gold_amount = 0
	var/diamond_amount = 0
	var/max_material_amount = 75000.0
	var/efficiency_coeff
	reagents = new(0)
	lubricity = 20 //% of lubricity

	var/list/categories = list(
								"AI Modules",
								"Computer Boards",
								"Teleportation Machinery",
								"Medical Machinery",
								"Engineering Machinery",
								"Exosuit Modules",
								"Hydroponics Machinery",
								"Subspace Telecomms",
								"Research Machinery",
								"Misc. Machinery"
								)

/obj/machinery/r_n_d/circuit_imprinter/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/circuit_imprinter(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(src)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(src)
	RefreshParts()
	reagents.my_atom = src

/obj/machinery/r_n_d/circuit_imprinter/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
		reagents.maximum_volume += G.volume
		G.reagents.trans_to(src, G.reagents.total_volume)
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	max_material_amount = T * 75000.0
	T = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		T += M.rating
	efficiency_coeff = 2 ** (T - 1) //Only 1 manipulator here, you're making runtimes Razharas

/obj/machinery/r_n_d/circuit_imprinter/blob_act()
	if (prob(50))
		qdel(src)


/obj/machinery/r_n_d/circuit_imprinter/proc/check_mat(datum/design/being_built, var/M)
	switch(M)
		if(MAT_GLASS)
			return (g_amount - (being_built.materials[M]/efficiency_coeff) >= 0)
		if(MAT_GOLD)
			return (gold_amount - (being_built.materials[M]/efficiency_coeff) >= 0)
		if(MAT_DIAMOND)
			return (diamond_amount - (being_built.materials[M]/efficiency_coeff) >= 0)
		if("sacid") //duly copy-pasted from rdconsole.dm
			if(reagents.has_reagent("pacid", being_built.materials["sacid"]/(4*efficiency_coeff))) //if we can use pacid first and exclusively pacid, we will
				return 1
			else if(reagents.has_reagent("pacid", 1)) //if we still have pacid but not enough to cover the whole cost, we use all of our pacid and back it up with sacid
				var/pacid_to_use = reagents.get_reagent_amount("pacid")
				var/sacid_to_use = (being_built.materials["sacid"] - pacid_to_use*4*efficiency_coeff)/efficiency_coeff
				return (reagents.has_reagent("pacid", pacid_to_use) && reagents.has_reagent("sacid", sacid_to_use))
			else //if we only have sacid
				return (reagents.has_reagent("sacid", being_built.materials["sacid"]/efficiency_coeff))
		else
			return (reagents.has_reagent(M, (being_built.materials[M]/efficiency_coeff)) != 0)

/obj/machinery/r_n_d/circuit_imprinter/proc/TotalMaterials()
	return g_amount + gold_amount + diamond_amount

/obj/machinery/r_n_d/circuit_imprinter/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if (shocked)
		shock(user,50)
	if (default_deconstruction_screwdriver(user, "circuit_imprinter_t", "circuit_imprinter", O))
		if(linked_console)
			linked_console.linked_imprinter = null
			linked_console = null
		return

	if(exchange_parts(user, O))
		return

	if (panel_open)
		if(istype(O, /obj/item/device/multitool) || istype(O,/obj/item/weapon/wirecutters))
			attack_hand(user)
		if(istype(O, /obj/item/weapon/crowbar))
			for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
				reagents.trans_to(G, G.reagents.maximum_volume)
			if(g_amount >= MINERAL_MATERIAL_AMOUNT)
				var/obj/item/stack/sheet/glass/G = new /obj/item/stack/sheet/glass(src.loc)
				G.amount = round(g_amount / MINERAL_MATERIAL_AMOUNT)
			if(gold_amount >= MINERAL_MATERIAL_AMOUNT)
				var/obj/item/stack/sheet/mineral/gold/G = new /obj/item/stack/sheet/mineral/gold(src.loc)
				G.amount = round(gold_amount / MINERAL_MATERIAL_AMOUNT)
			if(diamond_amount >= MINERAL_MATERIAL_AMOUNT)
				var/obj/item/stack/sheet/mineral/diamond/G = new /obj/item/stack/sheet/mineral/diamond(src.loc)
				G.amount = round(diamond_amount / MINERAL_MATERIAL_AMOUNT)
			default_deconstruction_crowbar(O)
			return
		else
			user << "<span class='warning'>You can't load the [src.name] while it's opened.</span>"
			return
	if (disabled)
		return
	if (!linked_console)
		user << "<span class='warning'>The [name] must be linked to an R&D console first!</span>"
		return 1
	if (O.is_open_container())
		return
	if (!istype(O, /obj/item/stack/sheet/glass) && !istype(O, /obj/item/stack/sheet/mineral/gold) && !istype(O, /obj/item/stack/sheet/mineral/diamond))
		user << "<span class='warning'>You cannot insert this item into the [name]!</span>"
		return
	if (stat)
		return
	if (busy)
		user << "<span class='warning'>The [name] is busy. Please wait for completion of previous operation.</span>"
		return
	var/obj/item/stack/sheet/stack = O
	if ((TotalMaterials() + stack.perunit) > max_material_amount)
		user << "<span class='warning'>The [name] is full. Please remove glass from the protolathe in order to insert more.</span>"
		return

	var/amount = round(input("How many sheets do you want to add?") as num)
	if(amount <= 0 || stack.amount <= 0)
		return
	if(amount > stack.amount)
		amount = min(stack.amount, round((max_material_amount-TotalMaterials())/stack.perunit))

	busy = 1
	use_power(max(1000, (MINERAL_MATERIAL_AMOUNT*amount/10)))
	user << "<span class='notice'>You add [amount] sheets to the [src.name].</span>"
	if(istype(stack, /obj/item/stack/sheet/glass))
		g_amount += amount * MINERAL_MATERIAL_AMOUNT
	else if(istype(stack, /obj/item/stack/sheet/mineral/gold))
		gold_amount += amount * MINERAL_MATERIAL_AMOUNT
	else if(istype(stack, /obj/item/stack/sheet/mineral/diamond))
		diamond_amount += amount * MINERAL_MATERIAL_AMOUNT
	stack.use(amount)
	busy = 0
	src.updateUsrDialog()

/obj/machinery/r_n_d/circuit_imprinter/proc/get_acid_amt() //not same args as get_lube_volume because this is a unique, creative machine with special needs
	var/amt = 0
	if (reagents.has_reagent("sacid", 1) || reagents.has_reagent("pacid", 1))
		amt += reagents.get_reagent_amount("sacid")
		amt += 2*reagents.get_reagent_amount("pacid")
	return amt

/obj/machinery/r_n_d/circuit_imprinter/process()
	var/turf/simulated/here = get_turf(loc)
	if(istype(here))
		atmos_machine_heat(here, 0.1, machinetemp)
	chem_machine_heat(reagents, machinetemp)