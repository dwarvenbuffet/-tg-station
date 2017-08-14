#define SOLID 1
#define LIQUID 2
#define GAS 3

/obj/machinery/chem_dispenser/drinks
	name = "soda dispenser"
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "soda_dispenser"
	energy = 100
	max_energy = 100
	amount = 30
	recharge_delay = 5
	uiname = "Soda Dispenser"
	dispensable_reagents = list("water","ice","coffee","cream","tea","icetea","cola","spacemountainwind","dr_gibb","space_up","tonic","sodawater","lemon_lime","sugar","orangejuice","limejuice","tomatojuice")

/obj/machinery/chem_dispenser/drinks/attackby(var/obj/item/O as obj, var/mob/user as mob)

		if(default_unfasten_wrench(user, O))
				return

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



/obj/machinery/chem_dispenser/drinks/beer
	name = "booze dispenser"
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "booze_dispenser"
	uiname = "Booze Dispenser"
	dispensable_reagents = list("lemon_lime","sugar","orangejuice","limejuice","sodawater","tonic","beer","kahlua","whiskey","wine","vodka","gin","rum","tequila","vermouth","cognac","ale")

