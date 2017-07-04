var/global/datum/robo_ticker/roboTicker = new()

/datum/robo_ticker
	var/list/lawset_list = new/list() //list of lawset strings as returned by return_laws().
	var/list/name_lists = new/list() //indexed by lawset.
	
/datum/robo_ticker/proc/addMind(datum/mind/M, mob/living/silicon/S) //Called upon gibbing. M is the mind of the mob and S is the mob.

	var/lawset = S.laws.return_laws() //Get the lawset
	
	if(!(lawset in lawset_list)) //If it ain't there, add it.
		lawset_list += lawset

	name_lists[lawset] += "<BR><font size='1'>[S.name] (played by: [M.key])</font>"
	return

/datum/robo_ticker/proc/printList() //Prints the list of gibbed sillies to the world.
	for(var/lawset in lawset_list)
		world << "<BR>The following <b>DESTROYED</b> silicons:"
		world << name_lists[lawset]
		world << "<BR>played under the following lawset:"
		world << lawset
	return
