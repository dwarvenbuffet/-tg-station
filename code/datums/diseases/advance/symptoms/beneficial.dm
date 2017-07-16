/*
//////////////////////////////////////

Healing

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Heals toxins in the affected mob's blood stream.

//////////////////////////////////////
*/

/datum/symptom/heal

	name = "Toxic Filter"
	stealth = 1
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 6

/datum/symptom/heal/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 10))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				Heal(M, A)
	return

/datum/symptom/heal/proc/Heal(var/mob/living/M, var/datum/disease/advance/A)

	var/get_damage = rand(8, 14)
	M.adjustToxLoss(-get_damage)
	return 1

/*
//////////////////////////////////////

Metabolism

	Little bit hidden.
	Lowers resistance.
	Decreases stage speed.
	Decreases transmittablity temrendously.
	High Level.

Bonus
	Cures all diseases (except itself) and creates anti-bodies for them until the symptom dies.

//////////////////////////////////////
*/

/datum/symptom/heal/metabolism

	name = "Anti-Bodies Metabolism"
	stealth = -1
	resistance = -3
	stage_speed = -2
	transmittable = -1
	level = 3
	var/list/cured_diseases = list()

/datum/symptom/heal/metabolism/Heal(var/mob/living/M, var/datum/disease/advance/A)
	var/cured = 0
	for(var/datum/disease/D in M.viruses)
		if(D != A)
			cured = 1
			cured_diseases += D.GetDiseaseID()
			D.cure()
	if(cured)
		M << "<span class='notice'>You feel much better.</span>"

/datum/symptom/heal/metabolism/End(var/datum/disease/advance/A)
	// Remove all the diseases we cured.
	var/mob/living/M = A.affected_mob
	if(istype(M))
		if(cured_diseases.len)
			for(var/res in M.resistances)
				if(res in cured_diseases)
					M.resistances -= res
		M << "<span class='notice'>You feel weaker.</span>"

/*
//////////////////////////////////////

Longevity

	Medium hidden boost.
	Large resistance boost.
	Large stage speed boost.
	Large transmittablity boost.
	High Level.

Bonus
	After a certain amount of time the symptom will cure itself.

//////////////////////////////////////
*/

/datum/symptom/heal/longevity

	name = "Longevity"
	stealth = 0
	resistance = 5
	stage_speed = 5
	transmittable = 5
	level = 3
	var/longevity = 32

/datum/symptom/heal/longevity/Heal(var/mob/living/M, var/datum/disease/advance/A)
	longevity -= 1
	if(!longevity)
		A.cure()

/datum/symptom/heal/longevity/Start(var/datum/disease/advance/A)
	longevity = rand(initial(longevity) - 5, initial(longevity) + 5)

/datum/symptom/regen

	name = "Cellular Regeneration"
	stealth = 1
	resistance = 3
	stage_speed = -2
	transmittable = -4
	level = 10

/datum/symptom/regen/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 10))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(5)
				M.heal_organ_damage(2,2)
				M.adjustToxLoss(-2)
				M.adjustCloneLoss(-2)
			else
				if(prob(SYMPTOM_ACTIVATION_PROB * 5))
					M << "<span class='notice'>[pick("You feel like a new you.", "Your skin feels funny.")]</span>"
	return

/*
//////////////////////////////////////

Damage Converter

	Little bit hidden.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Reduced transmittablity
	Intense Level.

Bonus
	Slowly converts brute/fire damage to toxin.

//////////////////////////////////////
*/

/datum/symptom/damage_converter

	name = "Toxic Compensation"
	stealth = 1
	resistance = -4
	stage_speed = 0
	transmittable = -2
	level = 4

/datum/symptom/damage_converter/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 10))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				Convert(M)
	return

/datum/symptom/damage_converter/proc/Convert(var/mob/living/M)

	var/get_damage = rand(1, 2)

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M

		var/list/parts = H.get_damaged_organs(1,1) //1,1 because it needs inputs.

		if(!parts.len)
			return

		for(var/obj/item/organ/limb/L in parts)
			L.heal_damage(get_damage, get_damage, 0)

	else
		if(M.getFireLoss() > 0 || M.getBruteLoss() > 0)
			M.adjustFireLoss(-get_damage)
			M.adjustBruteLoss(-get_damage)
		else
			return

	M.adjustToxLoss(get_damage)
	return 1

/*
//////////////////////////////////////

Self-Respiration

	Slightly hidden.
	Lowers resistance significantly.
	Decreases stage speed significantly.
	Decreases transmittablity tremendously.
	Fatal Level.

Bonus
	The body generates Dexalin Plus.

//////////////////////////////////////
*/

/datum/symptom/oxygen

	name = "Self-Respiration"
	stealth = -1
	resistance = -2
	stage_speed = -2
	transmittable = -2
	level = 6

/datum/symptom/oxygen/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 100))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				if(M.stat != DEAD)
					M.adjustOxyLoss(-12)
					if(M.losebreath > 0)
						M.losebreath -= 2
					if(M.losebreath < 0)
						M.losebreath = 0
			else
				if(prob(SYMPTOM_ACTIVATION_PROB * 5))
					M << "<span class='notice'>[pick("Your lungs feel great.", "You are now breathing manually.", "You don't feel the need to breathe.")]</span>"
	return

/*
//////////////////////////////////////

Stimulant

	Noticable.
	Lowers resistance significantly.
	Decreases stage speed moderately..
	Decreases transmittablity tremendously.
	Moderate Level.

Bonus
	The body generates Ephedrine.

//////////////////////////////////////
*/

/datum/symptom/stimulant

	name = "Stimulant"
	stealth = -1
	resistance = -3
	stage_speed = 4
	transmittable = -4
	level = 4

/datum/symptom/stimulant/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 100))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(5)
				M.status_flags |= GOTTAGOFAST
				M.AdjustParalysis(-1)
				M.AdjustStunned(-1)
				M.AdjustWeakened(-1)
				M.adjustStaminaLoss(-1)
				M.dizziness = max(0,M.dizziness-5)
				M.drowsyness = max(0,M.drowsyness-3)
				M.sleeping = max(0,M.sleeping - 2)
				if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
					M.bodytemperature = min(310, M.bodytemperature + (25 * TEMPERATURE_DAMAGE_COEFFICIENT))
				if(M.stat != DEAD)
					if(prob(1))
						M.emote(pick("twitch","blink_r","shiver"))
				M.status_flags |= GOTTAGOFAST
			else
				if(prob(SYMPTOM_ACTIVATION_PROB * 5))
					M << "<span class='notice'>[pick("You feel restless.", "You feel like running laps around the station.", "You feel like GOING FAST around the station.")]</span>"
	return

/*
//////////////////////////////////////

Ocular Restoration

	Noticable.
	Lowers resistance significantly.
	Decreases stage speed moderately..
	Decreases transmittablity tremendously.
	High level.

Bonus
	Restores eyesight.

//////////////////////////////////////
*/

/datum/symptom/visionaid

	name = "Ocular Restoration"
	stealth = -1
	resistance = -3
	stage_speed = -2
	transmittable = -4
	level = 4

/datum/symptom/visionaid/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 5))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				if (M.reagents.get_reagent_amount("oculine") < 20)
					M.reagents.add_reagent("oculine", 20)
			else
				if(prob(SYMPTOM_ACTIVATION_PROB * 5))
					M << "<span class='notice'>[pick("Your eyes feel great.", "You are now blinking manually.", "You don't feel the need to blink.")]</span>"
	return


/*
//////////////////////////////////////

Weight Even

	Very Noticable.
	Decreases resistance.
	Decreases stage speed.
	Reduced transmittable.
	High level.

Bonus
	Causes the weight of the mob to
	be even, meaning eating isn't
	required anymore.

//////////////////////////////////////
*/

/datum/symptom/weight_even

	name = "Weight Even"
	stealth = -3
	resistance = -3
	stage_speed = -4
	transmittable = 0
	level = 4

/datum/symptom/weight_even/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				M.overeatduration = 0
				M.nutrition = NUTRITION_LEVEL_WELL_FED + 50

	return