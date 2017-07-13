/*
//////////////////////////////////////

Asthmosthia AKA horrorfiredeath

////////////
///DANGER///
////////////

TERROR RUN FLEE GO RUN

//////////////////////////////////////
*/

/datum/symptom/asthmothia

	name = "Asthmothia"
	stealth = 0
	resistance = -5
	stage_speed = -5
	transmittable = -3
	level = 5
	severity = 5

/datum/symptom/asthmothia/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB / 2))
		var/turf/simulated/T = get_turf(A.affected_mob)
		switch(A.stage)
			if(5)
				if(prob(6.66))
					A.affected_mob << "<span class='warning'>Your body has conjured the unholy lords of Atmospherics and it emitted a cloud of smoke and fire so strong that you cannot help gasp in awe! Also, you fucking exploded.</span>"
					T.atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 666.66)
					playsound(A.affected_mob.loc, 'sound/effects/Explosion1.ogg', 50, 1)
					A.affected_mob.gib()
				else
					A.affected_mob << "<span class='warning'>You cough up a plume of Plasma!</span>"
					T.atmos_spawn_air(SPAWN_20C | SPAWN_TOXINS, 30)
			else
				A.affected_mob << "<span class='warning'>Something feels wrong, very wrong. Everything looks just a bit purple.</span>"
				T.atmos_spawn_air(SPAWN_20C | SPAWN_TOXINS, 5)
				A.affected_mob.adjustToxLoss(5.666)
	return

/*
//////////////////////////////////////

Spontaneous Combustion

	It can strike at any time.
	To generate so much heat would mean sacrifices for the viral body's supplies of energy.
	However, the heat may interrupt homeostasis, which is a net even for the infection process at least.
	No impasct on transmittability.
	Fatal Level.

Bonus
	Ignites infected mob.

//////////////////////////////////////
*/

/datum/symptom/fire

	name = "Spontaneous Combustion"
	stealth = 1
	resistance = -3
	stage_speed = 0
	transmittable = 0
	level = 6
	severity = 5

/datum/symptom/fire/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4)
				M.adjust_fire_stacks(5)
				M.IgniteMob()
			if(5)
				M.adjust_fire_stacks(10)
				M.IgniteMob()
	return

/*
//////////////////////////////////////
Hotheaditis
		It's a meme.
BONUS
        Turns the infected into insufferable prick;
        actually it just burns the shit out of them.
//////////////////////////////////////
*/

/datum/symptom/hothead

        name = "Hothead-itis"
        stealth = -2
        resistance = -2
        stage_speed = -2
        transmittable = -2
        level = 6
        severity = 4

/datum/symptom/hothead/Activate(var/datum/disease/advance/A)
        ..()
        if(prob(SYMPTOM_ACTIVATION_PROB / 2))
                var/mob/living/carbon/M = A.affected_mob
                switch(A.stage)
                        if(4, 5)
                                if (M.bodytemperature < 500)
                                        M.bodytemperature = min(450, M.bodytemperature + (50 * TEMPERATURE_DAMAGE_COEFFICIENT))
                        else
                                if(prob(SYMPTOM_ACTIVATION_PROB * 2))
                                        M<< "<span class='notice'>[pick("You feel an intense desire to shitpost on an anonymous imageboard. Your armpits are sweating feverishly.")]</span>"
        return