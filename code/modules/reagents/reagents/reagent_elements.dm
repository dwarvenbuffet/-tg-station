/datum/reagent/oxygen
	name = "Oxygen"
	id = "oxygen"
	description = "A colorless, odorless gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128

/datum/reagent/oxygen/reaction_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))	return 0
	O.atmos_spawn_air(SPAWN_OXYGEN|SPAWN_20C, reac_volume/2)

/datum/reagent/oxygen/reaction_turf(turf/simulated/T, reac_volume)
	if(istype(T))
		T.atmos_spawn_air(SPAWN_OXYGEN|SPAWN_20C, reac_volume/2)
	return

/datum/reagent/copper
	name = "Copper"
	id = "copper"
	description = "A highly ductile metal."
	reagent_state = SOLID
	color = "#6E3B08" // rgb: 110, 59, 8

/datum/reagent/nitrogen
	name = "Nitrogen"
	id = "nitrogen"
	description = "A colorless, odorless, tasteless gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128

/datum/reagent/nitrogen/reaction_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))	return 0
	O.atmos_spawn_air(SPAWN_NITROGEN|SPAWN_20C, reac_volume)

/datum/reagent/nitrogen/reaction_turf(turf/simulated/T, reac_volume)
	if(istype(T))
		T.atmos_spawn_air(SPAWN_NITROGEN|SPAWN_20C, reac_volume)
	return

/datum/reagent/hydrogen
	name = "Hydrogen"
	id = "hydrogen"
	description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128

/datum/reagent/potassium
	name = "Potassium"
	id = "potassium"
	description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
	reagent_state = SOLID
	color = "#A0A0A0" // rgb: 160, 160, 160

/datum/reagent/mercury
	name = "Mercury"
	id = "mercury"
	description = "A chemical element."
	color = "#484848" // rgb: 72, 72, 72

/datum/reagent/mercury/on_mob_life(var/mob/living/M as mob)
	if(M.canmove && istype(M.loc, /turf/space))
		step(M, pick(cardinal))
	if(prob(5))
		M.emote(pick("twitch","drool","moan"))
	M.adjustBrainLoss(2)
	..()
	return

/datum/reagent/sulfur
	name = "Sulfur"
	id = "sulfur"
	description = "A chemical element."
	reagent_state = SOLID
	color = "#BF8C00" // rgb: 191, 140, 0

/datum/reagent/carbon
	name = "Carbon"
	id = "carbon"
	description = "A chemical element."
	reagent_state = SOLID
	color = "#1C1300" // rgb: 30, 20, 0

/datum/reagent/carbon/reaction_turf(turf/T, reac_volume)
	if(!istype(T, /turf/space))
		var/obj/effect/decal/cleanable/dirt/D = locate() in T.contents   //check for existing dirt
		if(!D)
			new /obj/effect/decal/cleanable/dirt(T)
			return 1 //dirted
		else
			var/icon/new_icon = D.icon
			if(istype(new_icon))
				new_icon.ChangeOpacity(2)
				D.icon = new_icon

/datum/reagent/chlorine
	name = "Chlorine"
	id = "chlorine"
	description = "A highly reactive chemical element."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128

/datum/reagent/chlorine/on_mob_life(var/mob/living/M as mob)
	M.take_organ_damage(1*REM, 0)
	..()
	return
	
/datum/reagent/chlorine/reaction_hydroponics_tray(var/obj/machinery/hydroponics/H, var/reac_volume, var/mob/user)
	if(reac_volume >= 1) //We use this shit to clean swimming pools and kill people, not water plants
		H.adjustHealth(-round(reac_volume) * 1)
		H.adjustToxic(round(reac_volume) * 1.5)
		H.adjustWater(-round(reac_volume) * 0.5)
		H.adjustWeeds(-rand(1,3))
	return

/datum/reagent/fluorine
	name = "Fluorine"
	id = "fluorine"
	description = "A highly reactive chemical element."
	reagent_state = GAS
	color = "#F0E46B"

/datum/reagent/fluorine/on_mob_life(var/mob/living/M as mob)
	M.adjustToxLoss(1*REM)
	..()
	return
	
/datum/reagent/fluorine/reaction_hydroponics_tray(var/obj/machinery/hydroponics/H, var/reac_volume, var/mob/user) //PURGE
	if(reac_volume >= 1)
		H.adjustHealth(-round(reac_volume) * 2)
		H.adjustToxic(round(reac_volume) * 2.5)
		H.adjustWater(-round(reac_volume) * 0.5)
		H.adjustWeeds(-rand(1,4))
	return

/datum/reagent/sodium
	name = "Sodium"
	id = "sodium"
	description = "A chemical element."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128

/datum/reagent/phosphorus
	name = "Phosphorus"
	id = "phosphorus"
	description = "A chemical element."
	reagent_state = SOLID
	color = "#832828" // rgb: 131, 40, 40
	
/datum/reagent/phosphorus/reaction_hydroponics_tray(var/obj/machinery/hydroponics/H, var/reac_volume, var/mob/user)
	if(reac_volume >= 1)
		H.adjustHealth(-round(reac_volume) * 0.75)
		H.adjustNutri(round(reac_volume) * 0.1)
		H.adjustWater(-round(reac_volume) * 0.5)
		H.adjustWeeds(-rand(1,2))
	return

/datum/reagent/lithium
	name = "Lithium"
	id = "lithium"
	description = "A chemical element."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128

/datum/reagent/lithium/on_mob_life(var/mob/living/M as mob)
	if(M.canmove && istype(M.loc, /turf/space))
		step(M, pick(cardinal))
	if(prob(5))
		M.emote(pick("twitch","drool","moan"))
	..()
	return
	
/datum/reagent/radium
	name = "Radium"
	id = "radium"
	description = "Radium is an alkaline earth metal. It is extremely radioactive."
	reagent_state = SOLID
	color = "#C7C7C7" // rgb: 199,199,199
	
/datum/reagent/radium/reaction_hydroponics_tray(var/obj/machinery/hydroponics/H, var/reac_volume, var/mob/user)
	if(reac_volume >= 10)
		switch(rand(100))
			if(91 to 100)	H.plantdies()
			if(81 to 90)	H.mutatespecie()
			if(66 to 80)	H.hardmutate()
			if(41 to 65)	H.mutate()
			if(21 to 41)	user << "The plants don't seem to react..."
			if(11 to 20)	H.mutateweed()
			if(1 to 10)		H.mutatepest()
			else 			user << "Nothing happens..."
	else if (reac_volume >= 5)
		H.hardmutate()
	else if (reac_volume >= 2)
		H.mutate()
	if(reac_volume >= 5) //tox and health damage from crude radioactives
		H.adjustHealth(-round(reac_volume) * 1)
		H.adjustToxic(round(reac_volume) * 3) //Funny how mutagen is in the toxins dm when it's not toxic to plants while this is
	return

/datum/reagent/radium/on_mob_life(var/mob/living/M as mob)
	M.apply_effect(2*REM/M.metabolism_efficiency,IRRADIATE,0)
	..()
	return

/datum/reagent/radium/reaction_turf(turf/T, reac_volume)
	if(reac_volume >= 3)
		if(!istype(T, /turf/space))
			var/obj/effect/decal/cleanable/reagentdecal = new/obj/effect/decal/cleanable/greenglow(T)
			reagentdecal.reagents.add_reagent("radium", reac_volume)
			
/datum/reagent/iron
	name = "Iron"
	id = "iron"
	description = "Pure iron is a metal."
	reagent_state = SOLID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/gold
	name = "Gold"
	id = "gold"
	synth_cost = 5
	can_synth = 0
	description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
	reagent_state = SOLID
	color = "#F7C430" // rgb: 247, 196, 48

/datum/reagent/silver
	name = "Silver"
	id = "silver"
	can_synth = 0
	description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
	reagent_state = SOLID
	color = "#D0D0D0" // rgb: 208, 208, 208

/datum/reagent/uranium
	name ="Uranium"
	id = "uranium"
	synth_cost = 5
	can_synth = 0
	description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
	reagent_state = SOLID
	color = "#B8B8C0" // rgb: 184, 184, 192

/datum/reagent/uranium/on_mob_life(var/mob/living/M as mob)
	M.apply_effect(1/M.metabolism_efficiency,IRRADIATE,0)
	..()
	return

/datum/reagent/uranium/reaction_hydroponics_tray(var/obj/machinery/hydroponics/H, var/reac_volume, var/mob/user)
	if(reac_volume >= 10)
		switch(rand(100))
			if(91 to 100)	H.plantdies()
			if(81 to 90)	H.mutatespecie()
			if(66 to 80)	H.hardmutate()
			if(41 to 65)	H.mutate()
			if(21 to 41)	user << "The plants don't seem to react..."
			if(11 to 20)	H.mutateweed()
			if(1 to 10)		H.mutatepest()
			else 			user << "Nothing happens..."
	else if (reac_volume >= 5)
		H.hardmutate()
	else if (reac_volume >= 2)
		H.mutate()
	if(reac_volume >= 5) //tox and health damage from crude radioactives
		H.adjustHealth(-round(reac_volume) * 1)
		H.adjustToxic(round(reac_volume) * 2)
	return

/datum/reagent/uranium/reaction_turf(turf/T, reac_volume)
	if(reac_volume >= 3)
		if(!istype(T, /turf/space))
			var/obj/effect/decal/cleanable/reagentdecal = new/obj/effect/decal/cleanable/greenglow(T)
			reagentdecal.reagents.add_reagent("uranium", reac_volume)

/datum/reagent/aluminium
	name = "Aluminium"
	id = "aluminium"
	description = "A silvery white and ductile member of the boron group of chemical elements."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168

/datum/reagent/silicon
	name = "Silicon"
	id = "silicon"
	description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168

/datum/reagent/iodine
	name = "Iodine"
	id = "iodine"
	description = "A stable halogen."
	reagent_state = SOLID
	color = "#C8A5DC"
	
/datum/reagent/iodine/on_mob_life(var/mob/living/M as mob)
	M.adjustToxLoss(1*REM) //Why do you think they use ionized iodine to disinfect water?
	..()
	return