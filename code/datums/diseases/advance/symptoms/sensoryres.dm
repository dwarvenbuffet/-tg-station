/*
//////////////////////////////////////

Sensory-Restoration

	Very very very very noticable.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity tremendously.
	Fatal Level.

Bonus
	The body generates Sensory restorational chemicals.

//////////////////////////////////////
*/

/datum/symptom/sensres

	name = "Sensory Restoration"
	stealth = -3
	resistance = -3
	stage_speed = -3
	transmittable = -4
	level = 10
	severity = 0

/datum/symptom/sensres/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 100))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1)
				M.setEarDamage(0,0)
				if(M.disabilities & DEAF)
					M.disabilities &= ~DEAF
			if(2)
				M.eye_blurry = max(M.eye_blurry-5 , 0)
				M.eye_blind = max(M.eye_blind-5 , 0)
				M.disabilities &= ~NEARSIGHT
				M.eye_stat = max(M.eye_stat-5, 0)
				M.setEarDamage(0,0)
				if(M.disabilities & DEAF)
					M.disabilities &= ~DEAF
			if(3)
				M.drowsyness = max(M.drowsyness-5, 0)
				M.AdjustParalysis(-1)
				M.AdjustStunned(-1)
				M.AdjustWeakened(-1)
				M.hallucination = max(0, M.hallucination - 10)
				if(prob(60))
					M.adjustToxLoss(1)
				M.eye_blurry = max(M.eye_blurry-5 , 0)
				M.eye_blind = max(M.eye_blind-5 , 0)
				M.disabilities &= ~NEARSIGHT
				M.eye_stat = max(M.eye_stat-5, 0)
				M.setEarDamage(0,0)
				if(M.disabilities & DEAF)
					M.disabilities &= ~DEAF
			if(4, 5)
				if(M != DEAD)
					M.adjustBrainLoss(-3)
				M.drowsyness = max(M.drowsyness-5, 0)
				M.AdjustParalysis(-1)
				M.AdjustStunned(-1)
				M.AdjustWeakened(-1)
				M.hallucination = max(0, M.hallucination - 10)
				if(prob(60))
					M.adjustToxLoss(1)
				M.eye_blurry = max(M.eye_blurry-5 , 0)
				M.eye_blind = max(M.eye_blind-5 , 0)
				M.disabilities &= ~NEARSIGHT
				M.eye_stat = max(M.eye_stat-5, 0)
				M.setEarDamage(0,0)
				if(M.disabilities & DEAF)
					M.disabilities &= ~DEAF
			else
				if(prob(SYMPTOM_ACTIVATION_PROB * 5))
					M << "<span class='notice'>[pick("Your eyes feel great.", "Your ears feel great.", "Your head feel great.")]</span>"
	return
