/mob/living/simple_animal/mouse/spookmouse/verb/spooksqueek()
	set category = "Mouse"
	set name = "Squeek"
	var/sound = 'sound/effects/mousesqueek.ogg'
	var/vol = 250
	if(current_food >= 20)
		playsound_local(get_turf(src), sound, vol)
		current_food -= 20
	else
		src << "<span class='notice'>You aren't ready to squeak again yet.</span>"

/mob/living/simple_animal/mouse/spookmouse/verb/toggle_vision()
	set category = "Mouse"
	set name = "Toggle mouse nightvision"
	if(nightvision == 0)
		src.see_invisible = SEE_INVISIBLE_MINIMUM
		nightvision = 1
		src << "<span class='notice'>You squint your little eyes very hard.</span>"
	else
		src.see_invisible = SEE_INVISIBLE_LEVEL_TWO
		nightvision = 0
		src << "<span class='notice'>You stop squinting.</span>"

/mob/living/simple_animal/mouse/spookmouse/verb/toggle_sneak() //merged hide + sneak because if you're using one, you're using both. Declutters space for future verbs.
	set category = "Mouse"
	set name = "Sneak about"
	if(quietmouse == 0)
		src.alpha = 74
		src.layer = TURF_LAYER+0.2
		quietmouse = 1
		src << "<span class='notice'>You begin to move through the shadows, tapping into your prey-animal instincts...</span>"
	else
		src.alpha = 255
		src.layer = MOB_LAYER
		quietmouse = 0
		src << "<span class='notice'>You stop hiding.</span>"