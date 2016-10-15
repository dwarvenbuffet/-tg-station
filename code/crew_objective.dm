#ifdef CREW_OBJECTIVES

/datum/subsystem/ticker/proc
	generate_crew_objectives()
		set background = 1
		for (var/datum/mind/crewMind in minds)
			if(prob(10)) generate_miscreant_objectives(crewMind)
			else generate_individual_objectives(crewMind)
		return

	generate_individual_objectives(var/datum/mind/crewMind)
		set background = 1
		//Requirements for individual objectives: 1) You have a mind
												//2) You are not an antag
		if (!crewMind)
			return
		if (!crewMind.current || !crewMind.objectives || crewMind.objectives.len || crewMind.special_role || (crewMind.assigned_role == "MODE"))
			return

		var/rolePathString = replacetext(lowertext(crewMind.assigned_role)," ","_")
		if (!rolePathString)
			return

		rolePathString = "/datum/objective/crew/[rolePathString]"
		var/rolePath = text2path(rolePathString)
		if (isnull(rolePathString))
			return

		var/list/objectiveTypes = typesof(rolePath) - rolePath
		if (!objectiveTypes.len)
			return

		var/obj_count = 1
		var/assignCount = min(rand(1,3), objectiveTypes.len)
		while (assignCount && objectiveTypes.len)
			assignCount--
			var/selectedType = pick(objectiveTypes)
			var/datum/objective/crew/newObjective = new selectedType
			objectiveTypes -= newObjective.type

			newObjective.owner = crewMind
			crewMind.objectives += newObjective
			newObjective.setup()

			if (obj_count <= 1)
				crewMind.current << "<B>Your OPTIONAL Crew Objectives are as follows:</b>"
			crewMind.current << "<B>Objective #[obj_count]</B>: [newObjective.explanation_text]"
			obj_count++

		return

/*
 *	HOW-TO: Make Crew Objectives
 *	It's literally as simple as defining an objective of type "/datum/objective/crew/[ckey(job title) goes here]/objective name"
 *	Please take note that it goes live as soon as you define it, so if it isn't ready you should probably comment it out!!
 */

/datum/objective/crew
	proc/setup()

	captain
		hat
			explanation_text = "Have your hat on at the end of the round!"
			
			check_completion()
				if(owner.current && owner.current.check_contents_for(/obj/item/clothing/head/caphat))
					return 1
				else
					return 0
		drunk
			explanation_text = "Have alcohol in your bloodstream at the end of the round."
			
			check_completion()
				if(owner.current && owner.current.reagents && owner.current.reagents.has_reagent_type(/datum/reagent/consumable/ethanol))
					return 1
				else
					return 0

	headofsecurity
		hat
			explanation_text = "Have your hat/beret on at the end of the round!"
			
			check_completion()
				if(owner.current && owner.current.check_contents_for(/obj/item/clothing/head/HoS))
					return 1
				else
					return 0
		brig
			explanation_text = "Have at least one antagonist cuffed in the brig at the end of the round." //can be dead as people usually suicide
			
			check_completion()
				for(var/datum/mind/M in ticker.minds)
					if(M.special_role && M.current && !istype(M.current,/mob/dead) && istype(get_area(M.current),/area/security/brig)) //think that's everything...
						var/mob/living/carbon/C = M.current
						if(C.handcuffed)
							return 1
				return 0
		centcom
			explanation_text = "Bring at least one antagonist back to CentCom in handcuffs for interrogation. You must accompany them on the primary escape shuttle." //can also be dead I guess
			
			check_completion()
				for(var/datum/mind/M in ticker.minds)
					if(M.special_role && M.current && !istype(M.current,/mob/dead) && istype(get_area(M.current),/area/shuttle/escape))
						if(owner.current && owner.current.stat != 2 && istype(get_area(owner.current),/area/shuttle/escape)) //split this up as it was long
							var/mob/living/carbon/C = M.current
							if(C.handcuffed)
								return 1
				return 0

	headofpersonnel
		vanish
			explanation_text = "End the round alive but not on the station or escape levels."
			
			check_completion()
				if(owner.current && owner.current.stat != 2 && owner.current.z != 1 && owner.current.z != 2) return 1
				else return 0

/*	chiefengineer MOST OF THE STUFF THAT'S BEEN COMMENTED OUT REQUIRES ADDITIONAL CODE
		power
			explanation_text = "Ensure that all APCs are powered at the end of the round."
			
			check_completion()
				if(score_powerloss == 0) return 1
				else return 0
		furnaces
			explanation_text = "Make sure all furnaces on the station are active at the end of the round."
			
			check_completion()
				for(var/obj/machinery/power/furnace/F in machines)
					if(F.z == 1 && F.active == 0)
						return 0
				return 1
*/

//	securityofficer

/*	quartermaster
		profit
			explanation_text = "End the round with a budget of over 50,000 credits."
			
			check_completion()
				if(wagesystem.shipping_budget > 50000) return 1
				else return 0
*/

	detective
		drunk
			explanation_text = "Have alcohol in your bloodstream at the end of the round."
			
			check_completion()
				if(owner.current && owner.current.reagents && owner.current.reagents.has_reagent_type(/datum/reagent/consumable/ethanol))
					return 1
				else
					return 0
		gear
			explanation_text = "Ensure that you are still wearing your coat, hat and uniform at the end of the round."
			
			check_completion()
				if(owner.current && ishuman(owner.current))
					var/mob/living/carbon/human/H = owner.current
					if(istype(H.w_uniform, /obj/item/clothing/under/rank/det) && istype(H.wear_suit, /obj/item/clothing/suit/det_suit) && istype(H.head, /obj/item/clothing/head/det_hat)) return 1
				return 0
		smoke
			explanation_text = "Be smoking a cigarette at the end of the round."
			
			check_completion()
				if(owner.current) 
					var/mob/living/carbon/H = owner.current
					if(istype(H.wear_mask,/obj/item/clothing/mask/cigarette))
						return 1
				else return 0

/*	botanist
		mutantplants
			explanation_text = "Have at least three mutant plants alive at the end of the round."
			
			check_completion()
				var/mutcount = 0
				for(var/obj/machinery/plantpot/PP in machines)
					if(PP.current)
						var/datum/plantgenes/DNA = PP.plantgenes
						var/datum/plantmutation/MUT = DNA.mutation
						if (MUT)
							mutcount++
							if(mutcount >= 3) return 1
				return 0
		noweed
			explanation_text = "Make sure there are no cannabis plants, seeds or products in Hydroponics at the end of the round."
			
			check_completion()
				for (var/obj/item/clothing/mask/cigarette/W in world)
					if (W.reagents.has_reagent("THC"))
						if (istype(get_area(W), /area/hydroponics) || istype(get_area(W), /area/hydroponics/lobby))
							return 0
				for (var/obj/item/plant/herb/cannabis/C in world)
					if (istype(get_area(C), /area/hydroponics) || istype(get_area(C), /area/hydroponics/lobby))
						return 0
				for (var/obj/item/seed/cannabis/S in world)
					if (istype(get_area(S), /area/hydroponics) || istype(get_area(S), /area/hydroponics/lobby))
						return 0
				for (var/obj/machinery/plantpot/PP in machines)
					if (PP.current && istype(PP.current, /datum/plant/cannabis))
						if (istype(get_area(PP), /area/hydroponics) || istype(get_area(PP), /area/hydroponics/lobby))
							return 0
				return 1
*/
	chaplain
		funeral
			explanation_text = "Have no corpses on the station level at the end of the round."
			
			check_completion()
				for(var/mob/living/carbon/human/H in mob_list)
					if(H.z == 1 && H.stat == 2)
						return 0
				return 1

	janitor
		cleanbar
			explanation_text = "Make sure the bar is spotless at the end of the round."
			
			check_completion()
				for(var/turf/T in get_area_turfs(/area/crew_quarters/bar, 0))
					if(/obj/effect/decal/cleanable in T)
						return 0
				return 1
		cleanmedbay
			explanation_text = "Make sure medbay is spotless at the end of the round."
			
			check_completion()
				for(var/turf/T in get_area_turfs(/area/medical/medbay, 0))
					if(/obj/effect/decal/cleanable in T)
						return 0
				return 1
		cleanbrig
			explanation_text = "Make sure the brig is spotless at the end of the round."
			
			check_completion()
				for(var/turf/T in get_area_turfs(/area/security/brig, 0))
					if(/obj/effect/decal/cleanable in T)
						return 0
				return 1

//	barman

//	chef

//	engineer

/*	miner
		// just fyi dont make a "gather ore" objective, it'd be a boring-ass grind (like mining is(dohohohoho))
		gems
			explanation_text = "Find at least ten gems between all miners."
			
			check_completion()
				if(score_gemsmined >= 10) return 1
				else return 0
		isa
			explanation_text = "Create at least three suits of Industrial Space Armor."
			
			check_completion()
				var/suitcount = 0
				for(var/obj/item/clothing/suit/space/industrial/I in world)
					suitcount++
				if(suitcount > 2) return 1
				else return 0

	mechanic
		scanned
			explanation_text = "Have at least ten items scanned and researched in the ruckingenur at the end of the round."
			
			check_completion()
				if(mechanic_controls.scanned_items.len > 9) return 1
				else return 0
		teleporter
			explanation_text = "Ensure that there are at least two teleporters on the station level at the end of the round, excluding the science teleporter."
			
			check_completion()
				var/telecount = 0
				for(var/obj/machinery/teleport/portal_generator/S in machines) //really shitty, I know
					if(S.z != 1) continue
					for(var/obj/machinery/teleport/portal_ring/H in orange(2,S))
						for(var/obj/machinery/computer/teleporter/C in orange(2,S))
							telecount++
							break
				if(telecount > 1) return 1
				else return 0
*/
/*
		cloner
			explanation_text = "Ensure that there are at least two cloners on the station level at the end of the round."
			check_completion()
				var/clonecount = 0
				for(var/obj/machinery/computer/cloning/C in machines) //ugh
					for(var/obj/machinery/dna_scannernew/D in orange(2,C))
						for(var/obj/machinery/clonepod/P in orange(2,C))
							clonecount++
							break
				if(clonecount > 1) return 1
				return 0
*/

/*	research_director
		heisenbee
			explanation_text = "Ensure that Heisenbee escapes on the shuttle."
			check_completion()
				for (var/obj/critter/domestic_bee/heisenbee/H in world)
					if (istype(get_area(H),/area/shuttle/escape/centcom) && H.alive)
						return 1
				return 0
		noscorch
			explanation_text = "Ensure that the floors of the chemistry lab are not scorched at the end of the round."
			
			check_completion()
				for(var/turf/simulated/floor/T in get_area_turfs(/area/station/chemistry, 0))
					if(T.burnt == 1) return 0
				return 1
		hyper
			explanation_text = "Have methamphetamine in your bloodstream at the end of the round."
			
			check_completion()
				if(owner.current && owner.current.reagents && owner.current.reagents.has_reagent("methamphetamine"))
					return 1
				else
					return 0
		void
			explanation_text = "Create a portal to the void using the science teleporter."
			
			check_completion()
				for(var/obj/dfissure_to/F in world)
					if(F.z == 1) return 1
				return 0
		onfire
			explanation_text = "Escape on the shuttle alive while on fire with silver sulfadiazine in your bloodstream."
			
			check_completion()
				if(owner.current && owner.current.stat != 2 && ishuman(owner.current))
					var/mob/living/carbon/human/H = owner.current
					if(istype(get_area(H),/area/shuttle/escape/centcom) && H.burning > 1 && owner.current.reagents.has_reagent("silver_sulfadiazine")) return 1
					else return 0
*/

/*	scientist

		noscorch
			explanation_text = "Ensure that the floors of the chemistry lab are not scorched at the end of the round."
			
			check_completion()
				for(var/turf/simulated/floor/T in get_area_turfs(/area/chemistry, 0))
					if(T.burnt == 1) return 0
				return 1
		hyper
			explanation_text = "Have methamphetamine in your bloodstream at the end of the round."
			
			check_completion()
				if(owner.current && owner.current.reagents && owner.current.reagents.has_reagent("methamphetamine"))
					return 1
				else
					return 0
		void
			explanation_text = "Create a portal to the void using the science teleporter."
			
			check_completion()
				for(var/obj/dfissure_to/F in world)
					if(F.z == 1) return 1
				return 0
		onfire
			explanation_text = "Escape on the shuttle alive while on fire with silver sulfadiazine in your bloodstream."
			
			check_completion()
				if(owner.current && owner.current.stat != 2 && ishuman(owner.current))
					var/mob/living/carbon/human/H = owner.current
					if(istype(get_area(H),/area/shuttle/escape/centcom) && H.burning > 1 && owner.current.reagents.has_reagent("silver_sulfadiazine")) return 1
					else return 0
*/

		/*artifact // This is going to be really fucking awkward to do so disabling for now
			explanation_text = "Activate at least one artifact on the station z level by the end of the round, excluding the test artifact."
			check_completion()
				for(var/obj/machinery/artifact/A in machines)
					if(A.z == 1 && A.activated == 1 && A.name != "Test Artifact") return 1 //someone could label it I guess but I don't want to go adding an istestartifact var just for this..
				return 0*/

	chief_medical_officer // so much copy/pasted stuff  :(
/*
		dr_acula
			explanation_text = "Ensure that Dr. Acula escapes on the shuttle."
			check_completion()
				for (var/obj/critter/bat/doctor/Dr in world)
					if (istype(get_area(Dr),/area/shuttle/escape/centcom) && Dr.alive)
						return 1
				return 0
		headsurgeon
			explanation_text = "Ensure that the Head Surgeon escapes on the shuttle."
			
			check_completion()
				for (var/obj/machinery/bot/medbot/head_surgeon/H in world)
					if (istype(get_area(H),/area/shuttle/escape/centcom))
						return 1
				for (var/obj/item/clothing/suit/cardboard_box/head_surgeon/H in world)
					if (istype(get_area(H),/area/shuttle/escape/centcom))
						return 1
				for (var/obj/machinery/bot/medbot/head_surgeon/H in world)
					if (istype(get_area(H),/area/shuttle/escape/centcom))
						return 1
				return 0
*/
		scanned
			explanation_text = "Have at least 5 people's DNA scanned in the cloning console at the end of the round." //HA! Good one!
			
			check_completion()
				for(var/obj/machinery/computer/cloning/C in machines)
					if(C.records.len > 4)
						return 1
				return 0
/*
		cyborgs
			explanation_text = "Ensure that there are at least three living cyborgs at the end of the round."
			
			check_completion()
				var/borgcount = 0
				for(var/mob/living/silicon/robot in mob_list) //borgs gib when they die so no need to check stat I think
					borgcount ++
				if(borgcount > 2) return 1
				else return 0
		medibots
			explanation_text = "Have at least five medibots on the station level at the end of the round."
			
			check_completion()
				var/medbots = 0
				for (var/obj/machinery/bot/medbot/M in machines)
					if (M.z == 1)
						medbots++
				if (medbots > 4) return 1
				else return 0
		buttbots
			explanation_text = "Have at least five buttbots on the station level at the end of the round."
			
			check_completion()
				var/buttbots = 0
				for(var/obj/machinery/bot/buttbot/B in machines)
					if(B.z == 1)
						buttbots ++
				if(buttbots > 4) return 1
				else return 0
*/
		cryo
			explanation_text = "Ensure that at least two cryo cells are online and below 225K at the end of the round."
			
			check_completion()
				var/cryocount = 0
				for(var/obj/machinery/atmospherics/components/unary/cryo_cell/C in machines)
					var/datum/gas_mixture/A = C.airs["a1"]
					if(C.on && A && A.temperature < 225)
						cryocount ++
				if(cryocount > 1) return 1
				else return 0
		healself
			explanation_text = "Make sure you are completely unhurt when the escape shuttle leaves."
			
			check_completion()
				if(owner.current && owner.current.stat != 2 && (owner.current.getBruteLoss() + owner.current.getOxyLoss() + owner.current.getFireLoss() + owner.current.getToxLoss()) == 0)
					return 1
				else
					return 0
/*
		heal
			var/patchesused = 0
			explanation_text = "Use at least 10 medical patches on injured people."
			
			check_completion()
				if(patchesused > 9) return 1
				else return 0
		oath
			explanation_text = "Do not commit a violent act all round - punching someone, hitting them with a weapon or shooting them with a laser will all cause you to fail."
			
			check_completion()
				if (owner && owner.violated_hippocratic_oath)
					return 0
				else
					return 1
*/
	geneticist
		scanned
			explanation_text = "Have at least 5 people's DNA scanned in the cloning console at the end of the round."
			
			check_completion()
				for(var/obj/machinery/computer/cloning/C in machines)
					if(C.records.len > 4)
						return 1
				return 0
				/*
		power
			explanation_text = "Save a DNA sequence with at least one superpower onto a floppy disk and ensure it reaches CentCom."
			check_completion()
				for(var/obj/item/disk/data/floppy/F in world)
					if(F.data_type == "se" && F.data && istype(get_area(F),/area/shuttle/escape/centcom)) //prerequesites
						if(isblockon(getblock(F.data,XRAYBLOCK,3),8) || isblockon(getblock(F.data,FIREBLOCK,3),10) || isblockon(getblock(F.data,HULKBLOCK,3),2) || isblockon(getblock(F.data,TELEBLOCK,3),12))
							return 1
				return 0
				*/

	roboticist
		cyborgs
			explanation_text = "Ensure that there are at least three living cyborgs at the end of the round."
			
			check_completion()
				var/borgcount = 0
				for(var/mob/living/silicon/robot in mob_list) //borgs gib when they die so no need to check stat I think
					borgcount ++
				if(borgcount > 2) return 1
				else return 0
		/*
		replicant
			explanation_text = "Make sure at least one replicant survives until the end of the round."
			
			check_completion()
				for(var/mob/living/silicon/robot/R in mob_list)
					if(R.replicant)
						return 1
				return 0
		*/
		medibots
			explanation_text = "Have at least five medibots on the station level at the end of the round."
			
			check_completion()
				var/medbots = 0
				for (var/obj/machinery/bot/medbot/M in machines)
					if (M.z == 1)
						medbots++
				if (medbots > 4) return 1
				else return 0
		buttbots
			explanation_text = "Have at least five buttbots on the station level at the end of the round." //Typical goons! Sad!
			
			check_completion()
				var/buttbots = 0
				for(var/obj/machinery/bot/buttbot/B in machines)
					if(B.z == 1)
						buttbots ++
				if(buttbots > 4) return 1
				else return 0

	medicaldoctor
		cryo
			explanation_text = "Ensure that both cryo cells are online and below 225K at the end of the round."
			
			check_completion()
				var/cryocount = 0
				for(var/obj/machinery/atmospherics/components/unary/cryo_cell/C in machines)
					var/datum/gas_mixture/A = C.airs["a1"]
					if(C.on && A && A.temperature < 225)
						cryocount ++
				if(cryocount > 1) return 1
				else return 0
		healself
			explanation_text = "Make sure you are completely unhurt when the escape shuttle leaves."
			
			check_completion()
				if(owner.current && owner.current.stat != 2 && (owner.current.getBruteLoss() + owner.current.getOxyLoss() + owner.current.getFireLoss() + owner.current.getToxLoss()) == 0)
					return 1
				else
					return 0
/*
		heal
			var/patchesused = 0
			explanation_text = "Use at least 10 medical patches on injured people."
			
			check_completion()
				if(patchesused > 9) return 1
				else return 0
		oath
			explanation_text = "Do not commit a violent act all round - punching someone, hitting them with a weapon or shooting them with a laser will all cause you to fail."
			
			check_completion()
				if (owner && owner.violated_hippocratic_oath)
					return 0
				else
					return 1
*/

	assistant
/*
		butt
			explanation_text = "Have your butt removed somehow by the end of the round." //Goony as fuck
			
			check_completion()
				if(owner.current && ishuman(owner.current))
					var/mob/living/carbon/human/H = owner.current
					if(H.butt_op_stage == 4) return 1
				return 0

		wearbutt
			explanation_text = "Wear your own butt on your head on the escape shuttle."
			
			check_completion()
				if(owner.current && ishuman(owner.current)) //You can be dead to do this.
					var/mob/living/carbon/human/H = owner.current
					if(istype(get_area(H),/area/shuttle/escape/centcom) && H.head && H.head.name == "[H.real_name]'s butt") return 1
				return 0
*/
		promotion
			explanation_text = "Escape on the shuttle alive with a non-assistant ID registered with your name."
			
			check_completion()
				if(owner.current && owner.current.stat != 2 && ishuman(owner.current))
					var/mob/living/carbon/human/H = owner.current
					if(istype(get_area(H),/area/shuttle/escape) && H.wear_id)
						var/obj/item/weapon/card/id/I = H.wear_id
						if(I.registered_name == H.real_name && I.assignment != ("Assistant"))
							return 1
					else return 0
		clown
			explanation_text = "Escape on the shuttle alive wearing at least one piece of clown clothing."
			
			check_completion()
				if(owner.current && ishuman(owner.current))
					var/mob/living/carbon/human/H = owner.current
					if(istype(H.wear_mask,/obj/item/clothing/mask/gas/clown_hat) || istype(H.w_uniform,/obj/item/clothing/under/rank/clown) || istype(H.shoes,/obj/item/clothing/shoes/clown_shoes)) return 1
				return 0
/*
		chompski
			explanation_text = "Ensure that Gnome Chompski escapes on the shuttle."
			
			check_completion()
				for(var/obj/item/gnomechompski/G in world)
					if (istype(get_area(G),/area/shuttle/escape/centcom)) return 1
				return 0
		mailman
			explanation_text = "Escape on the shuttle alive wearing at least one piece of mailman clothing."
			
			check_completion()
				if(owner.current && ishuman(owner.current))
					var/mob/living/carbon/human/H = owner.current
					if(istype(H.w_uniform,/obj/item/clothing/under/misc/mail) || istype(H.head,/obj/item/clothing/head/mailcap)) return 1
				else return 0
*/
		spacesuit
			explanation_text = "Get your grubby hands on a spacesuit."
			
			check_completion()
				if(owner.current)
					for(var/obj/item/clothing/suit/space/S in owner.current.contents)
						return 1
				return 0
		monkey
			explanation_text = "Escape on the shuttle alive as a monkey."
			
			check_completion()
				if(owner.current && owner.current.stat != 2 && istype(get_area(owner.current),/area/shuttle/escape) && ismonkey(owner.current)) return 1
				else return 0
/*
		headsurgeon
			explanation_text = "Ensure that the Head Surgeon escapes on the shuttle."
			
			check_completion()
				for (var/obj/machinery/bot/medbot/head_surgeon/H in world)
					if (istype(get_area(H),/area/shuttle/escape/centcom))
						return 1
				for (var/obj/item/clothing/suit/cardboard_box/head_surgeon/H in world)
					if (istype(get_area(H),/area/shuttle/escape/centcom))
						return 1
				return 0
*/
/*
	//Keeping this around just in case some idiot gets a medal in an admin gimmick or something
	technicalassistant
		wearbutt
			explanation_text = "Make sure that you are wearing your own butt on your head when the escape shuttle leaves."
			
			check_completion()
				if(owner.current && owner.current.stat != 2 && ishuman(owner.current))
					var/mob/living/carbon/human/H = owner.current
					if(istype(get_area(H),/area/shuttle/escape/centcom) && H.head && H.head.name == "[H.real_name]'s butt") return 1
				return 0
		mailman
			explanation_text = "Escape on the shuttle alive wearing at least one piece of mailman clothing."
			
			check_completion()
				if(owner.current && ishuman(owner.current))
					var/mob/living/carbon/human/H = owner.current
					if(istype(H.w_uniform,/obj/item/clothing/under/misc/mail) || istype(H.head,/obj/item/clothing/head/mailcap)) return 1
				else return 0
		promotion
			explanation_text = "Escape on the shuttle alive with a non-assistant ID registered to you."
			
			check_completion()
				if(owner.current && owner.current.stat != 2 && istype(get_area(owner.current),/area/shuttle/escape/centcom)) //checking basic stuff - they escaped alive and have an ID
					var/mob/living/carbon/human/H = owner.current
					if(H.wear_id && H.wear_id:registered == H.real_name && H.wear_id:assignment != ("Technical Assistant" || "Staff Assistant" || "Medical Assistant")) return 1
					else return 0
		spacesuit
			explanation_text = "Get your grubby hands on a spacesuit."
			
			check_completion()
				if(owner.current)
					for(var/obj/item/clothing/suit/space/S in owner.current.contents)
						return 1
				return 0

	medicalassistant
		monkey
			explanation_text = "Escape on the shuttle alive as a monkey."
			
			check_completion()
				if(owner.current && owner.current.stat != 2 && istype(get_area(owner.current),/area/shuttle/escape/centcom) && ismonkey(owner.current)) return 1
				else return 0
		promotion
			explanation_text = "Escape on the shuttle alive with a non-assistant ID registered to you."
			
			check_completion()
				if(owner.current && owner.current.stat != 2 && istype(get_area(owner.current),/area/shuttle/escape/centcom)) //checking basic stuff - they escaped alive and have an ID
					var/mob/living/carbon/human/H = owner.current
					if(H.wear_id && H.wear_id:registered == H.real_name && H.wear_id:assignment != ("Technical Assistant" || "Staff Assistant" || "Medical Assistant")) return 1
					else return 0
		healself
			explanation_text = "Make sure you are completely unhurt when the escape shuttle leaves."
			
			check_completion()
				if(owner.current && owner.current.stat != 2 && (owner.current.getBruteLoss() + owner.current.getOxyLoss() + owner.current.getFireLoss() + owner.current.getToxLoss()) == 0)
					return 1
				else
					return 0
		headsurgeon
			explanation_text = "Ensure that the Head Surgeon escapes on the shuttle."
			
			check_completion()
				for (var/obj/machinery/bot/medbot/head_surgeon/H in world)
					if (istype(get_area(H),/area/shuttle/escape/centcom)) return 1
				for (var/obj/item/clothing/suit/cardboard_box/head_surgeon/H in world)
					if (istype(get_area(H),/area/shuttle/escape/centcom)) return 1
				return 0
*/

//	cyborg

#endif