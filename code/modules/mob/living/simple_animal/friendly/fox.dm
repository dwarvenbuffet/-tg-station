//Foxxy
/mob/living/simple_animal/fox
	name = "fox"
	desc = "It's a fox."
	icon_state = "fox"
	icon_living = "fox"
	icon_dead = "fox_dead"
	speak = list("Bark","Geckers","Awoo")
	speak_emote = list("geckers","barks")
	emote_hear = list("howls","barks")
	emote_see = list("shakes its head", "shivers")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/slab
	response_help = "pets"
	response_disarm = "pushes aside"
	response_harm = "kicks"

//Captain fox
/mob/living/simple_animal/fox/Renault
	name = "Renault"
	desc = "Renault, the Captain's trustworthy fox."