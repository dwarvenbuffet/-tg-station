/*
//////////////////////////////////////
Facial Hypertrichosis

	Noticeable.
	Resistant; the nature of cells emulating genetic variation.
	Concentration in face may slow spread, and therefore stages.
	No effect on transmittability.
	Intense Level.

BONUS
	Makes the mob grow a massive beard, regardless of gender.

//////////////////////////////////////
*/

/datum/symptom/beard

	name = "Facial Hypertrichosis"
	stealth = -3
	resistance = 1
	stage_speed = -3
	transmittable = 0
	level = 4
	severity = 1

/datum/symptom/beard/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			switch(A.stage)
				if(1, 2)
					if(H.facial_hair_style == "Shaved")
						H.facial_hair_style = "Jensen Beard"
						H.update_hair()
				if(3, 4)
					if(!(H.facial_hair_style == "Dwarf Beard") && !(H.facial_hair_style == "Very Long Beard") && !(H.facial_hair_style == "Full Beard"))
						H.facial_hair_style = "Full Beard"
						H.update_hair()
				else
					if(!(H.facial_hair_style == "Dwarf Beard") && !(H.facial_hair_style == "Very Long Beard"))
						H.facial_hair_style = pick("Dwarf Beard", "Very Long Beard")
						H.update_hair()
	return

	/*
//////////////////////////////////////
Vitiligo

	Extremely Noticable.
	No effect on resistance.
	No effect on stage speed..
	Slightly less transmittable; autoimmunce-centric diseases do not 'transfer'.
	Critical Level.

BONUS
	Makes the mob lose skin pigmentation.

//////////////////////////////////////
*/

/datum/symptom/vitiligo

	name = "Vitiligo"
	stealth = -4
	resistance = 0
	stage_speed = 0
	transmittable = -1
	level = 4
	severity = 1

/datum/symptom/vitiligo/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.skin_tone == "albino")
				return
			switch(A.stage)
				if(5)
					H.set_skin_tone("albino")
					H.update_body(0)
				else
					H.visible_message("<span class='warning'>[H] looks a bit pale...</span>", "<span class='notice'>You look a bit pale...</span>")

	return

/*
//////////////////////////////////////
Totumosis Nigricans
		Extremely Noticable.
		No effect on resistance.
		No effect on stage speed..
		Significantly less transmittable; autoimmunce-centric diseases do not 'transfer', and who wants to get near blacks?
		Critical Level.
BONUS
        wachu lookin at nygga
//////////////////////////////////////
*/

/datum/symptom/antivitiligo

        name = "Totumosis Nigricans"
        stealth = -4
        resistance = 0
        stage_speed = 0
        transmittable = -2
        level = 4
        severity = 3

/datum/symptom/antivitiligo/Activate(var/datum/disease/advance/A)
        ..()
        if(prob(SYMPTOM_ACTIVATION_PROB))
                var/mob/living/M = A.affected_mob
                if(istype(M, /mob/living/carbon/human))
                        var/mob/living/carbon/human/H = M
                        if(H.skin_tone == "african1")
                                return
                        switch(A.stage)
                                if(5)
                                        H.set_skin_tone("african1")
                                        H.update_body(0)
                                else
                                        H.visible_message("<span class='warning'>[H] looks a bit black.</span>", "<span class='notice'>You suddenly crave Fried Chicken.</span>")
        if(prob(SYMPTOM_ACTIVATION_PROB))
                var/mob/living/M = A.affected_mob
                if(istype(M, /mob/living/carbon/human))
                        var/mob/living/carbon/human/H = M
                        switch(A.stage)
                                if(5)
                                        var/random_name = ""
                                        switch(H.gender)
                                                if(MALE)
                                                        random_name = pick("Jamal", "Devon", "Ooga", "Bubba", "Manray", "Amos", "Da'Wan")
                                                else
                                                        random_name = pick("Shaniqua", "Jewel", "Latifa", "Aaliyah", "Shanice", "Asia", "Jazmin")
                                        random_name += " [pick("Melons, Jabongo, Dunwitty, Blak")]"
                                        H.SetSpecialVoice(random_name)
                                else
                                        return
        return
/datum/symptom/antivitiligo/End(var/datum/disease/advance/A)
	..()
	if(ishuman(A.affected_mob))
		var/mob/living/carbon/human/H = A.affected_mob
		H.UnsetSpecialVoice()
	return
/*
//////////////////////////////////////
Eternal Youth

	It's hard to notice yourself age. Virus may also be thought of as 'beneficial bacteria' or even stem cells by the body.
	Highly resistant; this sort of disease would necessitate multifunctionality.
	Multifunctionality means it's too complex to replicate quickly.
	The youthful body is the perfect place to 'overstock' viral bodies and eject from.
	Critical Level.

BONUS
	Gives you immortality and eternal youth!!!
	Can be used to buff your virus

//////////////////////////////////////
*/

/datum/symptom/youth

	name = "Eternal Youth"
	stealth = 1
	resistance = 3
	stage_speed = -3
	transmittable = 3
	level = 5

/datum/symptom/youth/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 2))
		var/mob/living/M = A.affected_mob
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			switch(A.stage)
				if(1)
					if(H.age > 41)
						H.age = 41
						H << "<span class='notice'>You haven't had this much energy in years!</span>"
				if(2)
					if(H.age > 36)
						H.age = 36
						H << "<span class='notice'>You're suddenly in a good mood.</span>"
				if(3)
					if(H.age > 31)
						H.age = 31
						H << "<span class='notice'>You begin to feel more lithe.</span>"
				if(4)
					if(H.age > 26)
						H.age = 26
						H << "<span class='notice'>You feel reinvigorated.</span>"
				if(5)
					if(H.age > 21)
						H.age = 21
						H << "<span class='notice'>You feel like you can take on the world!</span>"

	return

	/*
//////////////////////////////////////
Oh BOY
        The stats don't matter.
Bonus
        Get lynched/turned into a lizardman
//////////////////////////////////////
*/

/datum/symptom/liggeritis

        name = "Space Ichthyosis Vulgaris"
        stealth = -5
        resistance = -3
        stage_speed = 0
        transmittable = 1
        level = 6
        severity = 5

/datum/symptom/liggeritis/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2)
				if(prob(SYMPTOM_ACTIVATION_PROB))
					M << "<span class='notice'>[pick("Your skin feels awfully itchy", "Your tailbone feels like it's going to burst!")]</span>"
			if(3, 4)
				if(prob(SYMPTOM_ACTIVATION_PROB))
					M << A.affected_mob.say(pick("Hiss, Hiss?, Hiss!"))
					M << "<span class='notice'>[pick("You cannot resist the urge to hiss")]</span>"
			if(5)
				if(ishuman(A.affected_mob))
					var/mob/living/carbon/human/human = A.affected_mob
					if(human.dna && human.dna.species.id != "lizard")
						human.dna.species = new /datum/species/lizard()
						human.skin_tone = random_skin_tone()
						human.update_icons()
						human.update_body()
						human.update_hair()
						human.update_body_parts()
					else
						return
	return

/*
//////////////////////////////////////
Alopecia

	Noticable.
	Negative effect on resistance, a lot of the immune system is focused on the vulnerable skin and hair follicles- not any more.
	No effect on stage speed.
	Hair may have viral bodies left behind in it.
	Intense Level.

BONUS
	Makes the mob lose hair.

//////////////////////////////////////
*/

/datum/symptom/shedding

	name = "Alopecia"
	stealth = -2
	resistance = -2
	stage_speed = 0
	transmittable = 1
	level = 4
	severity = 1

/datum/symptom/shedding/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		M << "<span class='notice'>[pick("Your scalp itches.", "Your skin feels flakey.")]</span>"
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			switch(A.stage)
				if(3, 4)
					if(!(H.hair_style == "Bald") && !(H.hair_style == "Balding Hair"))
						H << "<span class='danger'>Your hair starts to fall out in clumps...</span>"
						spawn(50)
							H.hair_style = "Balding Hair"
							H.update_hair()
				if(5)
					if(!(H.facial_hair_style == "Shaved") || !(H.hair_style == "Bald"))
						H << "<span class='danger'>Your hair starts to fall out in clumps...</span>"
						spawn(50)
							H.facial_hair_style = "Shaved"
							H.hair_style = "Bald"
							H.update_hair()
	return

/*
//////////////////////////////////////

Voice Change

	Very Very noticable.
	Lowers resistance considerably.
	Decreases stage speed.
	Reduced transmittable.
	Fatal Level.

Bonus
	Changes the voice of the affected mob. Causing confusion in communication.

//////////////////////////////////////
*/

/datum/symptom/voice_change

	name = "Voice Change"
	stealth = -2
	resistance = -3
	stage_speed = -3
	transmittable = -1
	level = 6
	severity = 2

/datum/symptom/voice_change/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))

		var/mob/living/carbon/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3, 4)
				M << "<span class='notice'>[pick("Your throat hurts.", "You clear your throat.")]</span>"
			else
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					var/random_name = ""
					switch(H.gender)
						if(MALE)
							random_name = pick(first_names_male)
						else
							random_name = pick(first_names_female)
					random_name += " [pick(last_names)]"
					H.SetSpecialVoice(random_name)

	return

/datum/symptom/voice_change/End(var/datum/disease/advance/A)
	..()
	if(ishuman(A.affected_mob))
		var/mob/living/carbon/human/H = A.affected_mob
		H.UnsetSpecialVoice()
	return

/*
//////////////////////////////////////

Weight Gain

	Very Very Noticable.
	Decreases resistance.
	Decreases stage speed.
	Reduced transmittable.
	Intense Level.

Bonus
	Increases the weight gain of the mob,
	forcing it to eventually turn fat.
//////////////////////////////////////
*/

/datum/symptom/weight_gain

	name = "Weight Gain"
	stealth = -3
	resistance = -3
	stage_speed = -2
	transmittable = -2
	level = 4
	severity = 1

/datum/symptom/weight_gain/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3, 4)
				M << "<span class='notice'>[pick("You feel blubbery.", "You feel full.")]</span>"
			else
				M.overeatduration = min(M.overeatduration + 100, 600)
				M.nutrition = min(M.nutrition + 100, NUTRITION_LEVEL_FULL)

	return