/mob/living/simple_animal/mouse/spookmouse
	ventcrawler = 2
	healable = 1
	density = 0
	health = 30
	maxHealth = 30
	languages_spoken = MOUSE
	languages_understood = MOUSE
	pass_flags = PASSTABLE | PASSMOB
	sight = (SEE_MOBS)
	status_flags = (CANPUSH | CANSTUN | CANWEAKEN)
	gender = NEUTER
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 1)
	var/nightvision = 0
	var/quietmouse = 0
	var/under = 0
	var/sqc = 0

/mob/living/simple_animal/spookmouse/assess_threat() //Secbots won't hunt maintenance drones.
	return -10

/mob/living/simple_animal/attack_animal(mob/living/simple_animal/mouse/spookmouse/M)
	if(istype(M, /mob/living/simple_animal/mouse/spookmouse))
		var/repop
		if(repop == null || repop == 0)
			var/turf/curturf = get_turf(M)
			visible_message("<span class='warning'>[src] pops out another mouse! Space is quite strange, really.</span>")
			new /mob/living/simple_animal/mouse(curturf)
			repop = 1
			sleep(200)
			repop = 0