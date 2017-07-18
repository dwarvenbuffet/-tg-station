/mob/living/simple_animal/mouse/spookmouse
	ventcrawler = 2
	healable = 1
	density = 0
	health = 15
	maxHealth = 15
	canpull = 0
	languages_spoken = MOUSE
	languages_understood = MOUSE
	pass_flags = PASSTABLE | PASSMOB | PASSGRILLE
	sight = (SEE_MOBS)
	status_flags = (CANPUSH | CANSTUN | CANWEAKEN)
	gender = NEUTER
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 1)
	var/nightvision = 0
	var/quietmouse = 0
	var/under = 0
	var/sqc = 0
	var/current_food = 0
	var/max_food = 200
	var/tempticker = 0

/mob/living/simple_animal/spookmouse/assess_threat() //Secbots won't hunt maintenance drones.
	return -10
  
/mob/living/simple_animal/mouse/spookmouse/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Current Nutriment: [current_food]/[max_food]")

/mob/living/simple_animal/mouse/spookmouse/Life()
	..()
	current_food += 2

/mob/living/simple_animal/mouse/spookmouse/attack_animal(mob/living/simple_animal/mouse/spookmouse/M as mob)
	if(istype(M, /mob/living/simple_animal/mouse/spookmouse) && istype(src, /mob/living/simple_animal/mouse/spookmouse))
		if(current_food >= 50)
			var/turf/curturf = get_turf(M)
			visible_message("<span class='warning'>[src] pops out another mouse! Space is quite strange, really.</span>")
			new /mob/living/simple_animal/mouse(curturf)
			current_food -= 50
		else
			src << "<span class='notice'>You're too hungry to think about doing that...</span>"

/mob/living/simple_animal/mouse/spookmouse/death(gibbed)
	..(gibbed)
	src.alpha = 255
	src.layer = MOB_LAYER
