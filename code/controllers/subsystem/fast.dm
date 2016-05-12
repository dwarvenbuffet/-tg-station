//before you niggers try and add this subsystem to EVERYTHING, this is only for conveyor belts, foam, smoke, and probably hydroponic trays

var/datum/subsystem/fastprocess/SSfastprocess

/datum/subsystem/fastprocess
	name = "Fast Process"
	priority = -1
	wait = 1
	dynamic_wait = 1
	dwait_upper = 300
	dwait_lower = 1
	dwait_delta = 7

	var/list/processing = list()
	var/list/currentrun = list()

/datum/subsystem/fastprocess/New()
	NEW_SS_GLOBAL(SSfastprocess)

/datum/subsystem/fastprocess/stat_entry()
	..("FP:[processing.len]")


/datum/subsystem/fastprocess/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/datum/thing = currentrun[1]
		currentrun.Cut(1, 2)
		if(thing)
			thing.process(wait)
		else
			SSfastprocess.processing -= thing
		if (MC_TICK_CHECK)
			return