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
	stealth = 1
	resistance = -3
	stage_speed = -3
	transmittable = -4
	level = 6

/datum/symptom/oxygen/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 5))
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
