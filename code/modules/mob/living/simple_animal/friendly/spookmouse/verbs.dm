/mob/living/simple_animal/mouse/spookmouse/verb/spooksqueek()
	set category = "Mouse"
	set name = "Squeek"
	var/sound = 'sound/effects/mousesqueek.ogg'
	var/vol = 160
	if(sqc == 0)
		playsound_local(get_turf(src), sound, vol)
		sqc = 1
		sleep(80)
		sqc = 0
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

/mob/living/simple_animal/mouse/spookmouse/verb/toggle_sneak()
	set category = "Mouse"
	set name = "Sneak about"
	if(quietmouse == 0)
		src.alpha = 74
		quietmouse = 1
		src << "<span class='notice'>You begin to move through the shadows, tapping into your prey-animal instincts...</span>"
	else
		src.alpha = 255
		quietmouse = 0
		src << "<span class='notice'>You stop hiding.</span>"

/mob/living/simple_animal/mouse/spookmouse/verb/toggle_hiding()
	set category = "Mouse"
	set name = "Hide"
	if(under == 0)
		src.layer = TURF_LAYER+0.2
		under = 1
		src << "<span class='notice'>You take advantage of your miniscule stature to duck under nearby objects...</span>"
	else
		src.layer = MOB_LAYER
		under = 0
		src << "<span class='notice'>You stop hiding under nearby objects.</span>"