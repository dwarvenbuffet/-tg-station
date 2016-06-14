/datum/symptom/limb_regen

	name = "Limb Regeneration"
	stealth = -1
	resistance = -3
	stage_speed = 4
	transmittable = -4
	level = 10

/datum/symptom/limb_regen/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 5))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(5)
				var/mob/living/carbon/human/H = M
				if(H.dna)
					for(var/organname in H.organsystem.organlist)
						var/datum/organ/organdata = H.organsystem.organlist[organname]
						if(istype(organdata) && !organdata.exists())
							if(organdata.name == "organ") continue
							organdata.regenerate_organitem(H.dna) //IT JUST WERKS
							if(organdata.exists())
								var/obj/item/organ/O = organdata.organitem
								if(istype(O))
									O.add_suborgans()
									O.on_insertion()
								M << "<span class='notice'>You regrow your [organdata.getDisplayName()]</span>"
				M.update_hud()
				H.update_body_parts()
				M.update_damage_overlays(0)
	return