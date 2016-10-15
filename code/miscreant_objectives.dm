#ifdef CREW_OBJECTIVES

/datum/subsystem/ticker/proc

	generate_miscreant_objectives(var/datum/mind/crewMind)
		set background = 1

		//Requirements for individual objectives: 1) You have a mind (this eliminates 90% of our playerbase ~heh~)
												//2) You are not a traitor
		if (!crewMind)
			return
		if (!crewMind.current || !crewMind.objectives || crewMind.objectives.len || crewMind.special_role || (crewMind.assigned_role == "MODE"))
			return
		if (crewMind.current && (crewMind.current.stat == 2 || isobserver(crewMind.current) || issilicon(crewMind.current)))
			return

		var/list/objectiveTypes = typesof(/datum/objective/miscreant) - /datum/objective/miscreant

		var/obj_count = 1
		var/assignCount = 1
		while (assignCount && objectiveTypes.len)
			assignCount--
			var/selectedType = pick(objectiveTypes)
			var/datum/objective/miscreant/newObjective = new selectedType
			objectiveTypes -= newObjective.type

			newObjective.owner = crewMind
			crewMind.objectives += newObjective

			if (obj_count <= 1)
				crewMind.current << "<B>You are a miscreant!</B>"
				crewMind.current << "You should try to complete your objectives, but don't commit any traitorous acts."
				crewMind.current << "Your objective is as follows:"
			crewMind.current << "[newObjective.explanation_text]"
			obj_count++

		return

/datum/objective/miscreant

	protest
		explanation_text = "Try to incite a protest or riot."

	damage
		explanation_text = "Cause as much property damage as possible without killing anyone."

	troll
		explanation_text = "Try to get as many people as possible out for your blood."

	whiny
		explanation_text = "Complain incessantly about every minor issue you can find."

	blockade
		explanation_text = "Try to block off access to something under the pretense that it's too dangerous."

	bailout
		explanation_text = "Whenever someone gets arrested, try to bribe, blackmail or convince security to let them go."

	vigilante
		explanation_text = "Whenever someone gets arrested, try to bribe, blackmail or convince security to execute them."

	murder
		explanation_text = "Without touching or harming them, annoy someone so much that they murder you."

	heirlooms
		explanation_text = "Steal as many crew members' trinkets and heirlooms as possible."

	destroy_items
		explanation_text = "Choose a type of item. Try to destroy every instance of it on the station under the pretense of a market recall."

	litterbug
		explanation_text = "Make a huge mess wherever you go."

	stalk
		explanation_text = "Single out a crew member and stalk them everywhere."

	incompetent
		explanation_text = "Be as useless and incompetent as possible without getting killed."

	bureaucracy
		explanation_text = "Enforce as much unwieldy bureaucracy as possible."

	access
		explanation_text = "Make as much of the station as possible accessible to the public."

	paranoid
		explanation_text = "Construct an impenetrable fortress for yourself on the station."

	creepy
		explanation_text = "Sneak around looking as suspicious as possible without actually doing anything illegal."

	strike
		explanation_text = "Try to convince your department to go on strike and refuse to do any work."

	graft
		explanation_text = "See how much money you can amass by charging pointless fees, soliciting bribes or embezzling money from other crewmembers."

	steal_and_sell
		explanation_text = "Steal things from crew members and attempt to auction them off for profit."

	construction
		explanation_text = "Perform obnoxious construction and renovation projects. Insist that you're just doing your job."


#endif