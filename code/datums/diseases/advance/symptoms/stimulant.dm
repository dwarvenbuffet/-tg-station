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
