/mob/living/carbon/human/proc/AdjustHumanity(value, limit, forced = FALSE)
	if(value < 0)
		for(var/mob/living/carbon/human/H in viewers(7, src))
			if(H != src && H.mind?.dharma)
				if("judgement" in H.mind.dharma.tenets)
					to_chat(H, "<span class='warning'>[src] is doing something bad, I need to punish them!")
					H.mind.dharma.judgement |= real_name
	if(!iskindred(src))
		return
	if(!GLOB.canon_event)
		return
	var/special_role_name = "Ambitious"
	if(mind)
		var/roles =	mind.get_special_roles()
		for(var/role in roles)
			special_role_name = role
	if(!is_antag() || special_role_name == "Ambitious" || forced)
		if(!in_frenzy || forced)
			var/mod = 1
			var/enlight = FALSE
			if(clane)
				mod = clane.humanitymod
				enlight = clane.enlightenment
			if(enlight)
				if(value < 0)
					if(humanity < 10)
						if (forced)
							humanity = max(0, humanity-(value * mod))
						else
							humanity = max(limit, humanity-(value*mod))
						SEND_SOUND(src, sound('code/modules/wod13/sounds/humanity_gain.ogg', 0, 0, 75))
						to_chat(src, "<span class='userhelp'><b>ENLIGHTENMENT INCREASED!</b></span>")
				if(value > 0)
					if(humanity > 0)
						if (forced)
							humanity = min(10, humanity-(value * mod))
						else
							humanity = min(limit, humanity-(value*mod))
						SEND_SOUND(src, sound('code/modules/wod13/sounds/humanity_loss.ogg', 0, 0, 75))
						to_chat(src, "<span class='userdanger'><b>ENLIGHTENMENT DECREASED!</b></span>")
			else
				if(value < 0)
					if((humanity > limit) || forced)
						if (forced)
							humanity = max(0, humanity+(value * mod))
						else
							humanity = max(limit, humanity+(value*mod))
						SEND_SOUND(src, sound('code/modules/wod13/sounds/humanity_loss.ogg', 0, 0, 75))
						to_chat(src, "<span class='userdanger'><b>HUMANITY DECREASED!</b></span>")
						if(humanity == limit)
							to_chat(src, "<span class='userdanger'><b>If I don't stop, I will succumb to the Beast.</b></span>")
					else
						var/msgShit = pick("<span class='userdanger'><b>I can barely control the Beast!</b></span>", "<span class='userdanger'><b>I SHOULD STOP.</b></span>", "<span class='userdanger'><b>I'm succumbing to the Beast!</b></span>")
						to_chat(src, msgShit) // [ChillRaccoon] - I think we should make's players more scared
				if(value > 0)				  // so please, do not say about that, they're in safety after they're humanity drops to limit
					if((humanity < limit) || forced)
						if (forced)
							humanity = min(10, humanity+(value * mod))
						else
							humanity = min(limit, humanity+(value*mod))
						SEND_SOUND(src, sound('code/modules/wod13/sounds/humanity_gain.ogg', 0, 0, 75))
						to_chat(src, "<span class='userhelp'><b>HUMANITY INCREASED!</b></span>")

	var/datum/preferences/P = GLOB.preferences_datums[ckey(key)]
	if(MyPath)
		MyPath.dot = humanity
	if(P)
		if(P.humanity != humanity)
			P.humanity = humanity
			P.save_preferences()
			P.save_character()
		if(!antifrenzy)
			if(P.humanity < 1)
				enter_frenzymod()
				reset_shit(src)
				to_chat(src, "<span class='userdanger'>You have lost control of the Beast within you, and it has taken your body. Be more humane next time.</span>")
				ghostize(FALSE)
				P.reason_of_death = "Lost control to the Beast ([time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")])."

/mob/living/carbon/human/proc/AdjustMasquerade(value, forced = FALSE)
	if(!iskindred(src) && !isghoul(src) && !iscathayan(src)  && !iszombie(src))
		return
	if(!GLOB.canon_event)
		return
	if(stat > 0)
		return
	if (!forced)
		if(value > 0)
			if(HAS_TRAIT(src, TRAIT_VIOLATOR))
				return
		if(istype(get_area(src), /area/vtm))
			var/area/vtm/V = get_area(src)
			if(V.zone_type != "masquerade")
				return
	var/special_role_name = "Ambitious"
	if(mind)
		var/roles =	mind.get_special_roles()
		for(var/role in roles)
			special_role_name = role
	if(!is_antag() || special_role_name == "Ambitious" || forced)
		if(((last_masquerade_violation + 10 SECONDS) < world.time) || forced)
			last_masquerade_violation = world.time
			if(value < 0)
				if(masquerade > 0)
					masquerade = max(0, masquerade+value)
					SEND_SOUND(src, sound('code/modules/wod13/sounds/masquerade_violation.ogg', 0, 0, 75))
					to_chat(src, "<span class='userdanger'><b>MASQUERADE VIOLATION!</b></span>")
				// No bad guys party
				//SSbad_guys_party.next_fire = max(world.time, SSbad_guys_party.next_fire - 2 MINUTES)
			if(value > 0)
				if(clane?.enlightenment && !forced)
					AdjustHumanity(1, 10)
				for(var/mob/living/carbon/human/H in GLOB.player_list)
					H.voted_for -= dna.real_name
				if(masquerade < 5)
					masquerade = min(5, masquerade+value)
					SEND_SOUND(src, sound('code/modules/wod13/sounds/general_good.ogg', 0, 0, 75))
					to_chat(src, "<span class='userhelp'><b>MASQUERADE REINFORCED!</b></span>")
				//SSbad_guys_party.next_fire = max(world.time, SSbad_guys_party.next_fire + 1 MINUTES)

	if(src in GLOB.masquerade_breakers_list)
		if(masquerade > 4)
			GLOB.masquerade_breakers_list -= src
	else if(masquerade < 5)
		GLOB.masquerade_breakers_list |= src

	var/datum/preferences/P = GLOB.preferences_datums[ckey(key)]
	if(P)
		if(P.masquerade != masquerade)
			P.masquerade = masquerade
			P.save_preferences()
			P.save_character()

	if(value < 0)
		if(masquerade <= 2)
			var/list/landmarkslist = list()
			for(var/obj/effect/landmark/start/S in GLOB.start_landmarks_list)
				if(S.name == "Caitiff")
					landmarkslist += S
			var/obj/effect/landmark/start/startmark = pick(landmarkslist)
			//H.forceMove(startmark.loc)
			var/list/candidates = SSpolling.poll_ghosts_for_targets(
				question = "Do you want to play as hunter to hunt [src]?",
				poll_time = 10 SECONDS,
				checked_targets = src,
				alert_pic = src,
			)

			for(var/mob/dead/observer/G in GLOB.player_list)
				if(G.key)
					to_chat(G, "<span class='ghostalert'>[src] revealed their abnormal nature, you can play as hunter to punish them.</span>")
			if(LAZYLEN(candidates))
//				var/mob/dead/observer/C = pick(candidates)
				for(var/i in 1 to 5)
					if(length(candidates))
						var/mob/candidate = pick(candidates)
						candidates -= candidate
						var/mob/living/carbon/human/npc/hunter/smallhunter = new (startmark.loc)
						new /obj/item/gun/ballistic/automatic/vampire/ak74 (startmark.loc)
						smallhunter.key = candidate.key
						if(!smallhunter.mind)
							smallhunter.mind = new /datum/mind
						var/datum/antagonist/ANTAG = smallhunter.mind.add_antag_datum(/datum/antagonist/small_hunter)
						var/datum/objective/assassinate/die_objective = new
						die_objective.owner = smallhunter
						die_objective.target = src
						ANTAG.objectives += die_objective
						smallhunter.remove_movespeed_modifier(/datum/movespeed_modifier/npc)


/mob/living/carbon/human/npc/proc/backinvisible(atom/A)
	switch(dir)
		if(NORTH)
			if(A.y >= y)
				return TRUE
		if(SOUTH)
			if(A.y <= y)
				return TRUE
		if(EAST)
			if(A.x >= x)
				return TRUE
		if(WEST)
			if(A.x <= x)
				return TRUE
	return FALSE

/mob/living/proc/CheckEyewitness(mob/living/source, mob/attacker, range = 0, affects_source = FALSE)
	var/actual_range = max(1, round(range*(attacker.alpha/255)))
	/*
	if(SScityweather.fogging)
		actual_range = round(actual_range/2)
	*/
	var/list/seenby = list()
	if(source.ignores_warrant)
		return
	else
//		for(var/mob/living/carbon/human/npc/NPC in oviewers(1, source))
//			if(!NPC.CheckMove())
//				if(get_turf(src) != turn(NPC.dir, 180))
//					seenby |= NPC
//					NPC.Aggro(attacker, FALSE)
		for(var/mob/living/carbon/human/npc/NPC in viewers(actual_range, source))
			if(!NPC.CheckMove())
				if(NPC != source && get_dist(NPC, source) <= 1)
					if(get_turf(src) != turn(NPC.dir, 180))
						seenby |= NPC
						NPC.Aggro(attacker, FALSE)
				if(affects_source)
					if(NPC == source)
						NPC.Aggro(attacker, TRUE)
						seenby |= NPC
				if(!NPC.pulledby)
					var/turf/LC = get_turf(attacker)
					if(LC.get_lumcount() > 0.25 || get_dist(NPC, attacker) <= 1)
						if(NPC.backinvisible(attacker))
							seenby |= NPC
							NPC.Aggro(attacker, FALSE)
		if(length(seenby) >= 1)
			return TRUE
		return FALSE

/mob/proc/can_respawn()
	if (client?.ckey)
		if (GLOB.respawn_timers[client.ckey])
			if ((GLOB.respawn_timers[client.ckey] + 10 MINUTES) > world.time)
				return FALSE
	return TRUE

/**
 * Rolls a number of dice according to Storyteller system rules to find
 * success or number of successes.
 *
 * Rolls a number of 10-sided dice, counting them as a "success" if
 * they land on a number equal to or greater than the difficulty. Dice
 * that land on 1 subtract a success from the total, and the minimum
 * difficulty is 2. The number of successes is returned if numerical
 * is true, or the roll outcome (botch, failure, success) as a defined
 * number if false.
 *
 * Arguments:
 * * dice - number of 10-sided dice to roll.
 * * difficulty - the number that a dice must come up as to count as a success.
 * * numerical - whether the proc returns number of successes or outcome (botch, failure, success)
 */
/proc/storyteller_roll(dice = 1, difficulty = 6, numerical = FALSE)
	var/successes = 0
	var/had_one = FALSE
	var/had_success = FALSE

	if (dice < 1)
		if (numerical)
			return 0
		else
			return ROLL_FAILURE

	for (var/i in 1 to dice)
		var/roll = rand(1, 10)

		if (roll == 1)
			successes--
			if (!had_one)
				had_one = TRUE
			continue

		if (roll >= difficulty)
			successes++
			if (!had_success)
				had_success = TRUE

	if (numerical)
		return successes
	else
		if (!had_success && had_one)
			return ROLL_BOTCH
		else if (successes <= 0)
			return ROLL_FAILURE
		else
			return ROLL_SUCCESS

/proc/vampireroll(dices_num = 1, hardness = 1, atom/rollviewer)
	var/wins = 0
	var/crits = 0
	var/brokes = 0
	for(var/i in 1 to dices_num)
		var/roll = rand(1, 10)
		if(roll == 10)
			crits += 1
		if(roll == 1)
			brokes += 1
		else if(roll >= hardness)
			wins += 1
	if(crits > brokes)
		if(rollviewer)
			to_chat(rollviewer, "<b>Critical <span class='nicegreen'>hit</span>!</b>")
			return DICE_CRIT_WIN
	if(crits < brokes)
		if(rollviewer)
			to_chat(rollviewer, "<b>Critical <span class='danger'>failure</span>!</b>")
			return DICE_CRIT_FAILURE
	if(crits == brokes && !wins)
		if(rollviewer)
			to_chat(rollviewer, "<span class='danger'>Failed</span>")
			return DICE_FAILURE
	if(wins)
		switch(wins)
			if(1)
				to_chat(rollviewer, "<span class='tinynotice'>Maybe</span>")
				return DICE_WIN
			if(2)
				to_chat(rollviewer, "<span class='smallnotice'>Okay</span>")
				return DICE_WIN
			if(3)
				to_chat(rollviewer, "<span class='notice'>Good</span>")
				return DICE_WIN
			if(4)
				to_chat(rollviewer, "<span class='notice'>Lucky</span>")
				return DICE_WIN
			else
				to_chat(rollviewer, "<span class='boldnotice'>Phenomenal</span>")
				return DICE_WIN

/proc/get_vamp_skin_color(value = "albino")
	switch(value)
		if("caucasian1")
			return "vamp1"
		if("caucasian2")
			return "vamp2"
		if("caucasian3")
			return "vamp3"
		if("latino")
			return "vamp4"
		if("mediterranean")
			return "vamp5"
		if("asian1")
			return "vamp6"
		if("asian2")
			return "vamp7"
		if("arab")
			return "vamp8"
		if("indian")
			return "vamp9"
		if("african1")
			return "vamp10"
		if("african2")
			return "vamp11"
		else
			return value

/mob/living/proc/get_health_difficulty()
	if(HAS_TRAIT(src, TRAIT_PAIN_NUMBING))
		return 0
	if(health > maxHealth*0.6)
		return 0
	else if(health > maxHealth*0.4)
		return 1
	else if(health > maxHealth*0.2)
		return 2
	else if(health > HEALTH_THRESHOLD_FULLCRIT)
		return 5
	else
		return 10

/mob/living/proc/torpor(source)
	if (HAS_TRAIT(src, TRAIT_TORPOR))
		return
	if (fakedeath(source))
		to_chat(src, "<span class='danger'>You have fallen into Torpor. Use the button in the top right to learn more, or attempt to wake up.</span>")
		ADD_TRAIT(src, TRAIT_TORPOR, source)
		if (iskindred(src))
			var/mob/living/carbon/human/vampire = src
			var/datum/species/human/kindred/vampire_species = vampire.dna.species
			var/torpor_length = 0 SECONDS
			switch(humanity)
				if(10)
					torpor_length = 1 MINUTES
				if(9)
					torpor_length = 3 MINUTES
				if(8)
					torpor_length = 4 MINUTES
				if(7)
					torpor_length = 5 MINUTES
				if(6)
					torpor_length = 10 MINUTES
				if(5)
					torpor_length = 15 MINUTES
				if(4)
					torpor_length = 30 MINUTES
				if(3)
					torpor_length = 1 HOURS
				if(2)
					torpor_length = 2 HOURS
				if(1)
					torpor_length = 3 HOURS
				else
					torpor_length = 5 HOURS
			COOLDOWN_START(vampire_species, torpor_timer, torpor_length)
		if (iscathayan(src))
			var/mob/living/carbon/human/cathayan = src
			var/datum/dharma/dharma = cathayan.mind.dharma
			var/torpor_length = 1 MINUTES * max_yin_chi
			COOLDOWN_START(dharma, torpor_timer, torpor_length)

/mob/living/verb/untorpor()
	set hidden = TRUE
	if(HAS_TRAIT(src, TRAIT_TORPOR))
		if(iskindred(src))
			if (bloodpool > 0)
				bloodpool -= 1
				cure_torpor()
				to_chat(src, "<span class='notice'>You have awoken from your Torpor.</span>")
			else
				to_chat(src, "<span class='warning'>You have no blood to re-awaken with...</span>")
		if(iscathayan(src))
			if (yang_chi > 0)
				yang_chi -= 1
				cure_torpor()
				to_chat(src, "<span class='notice'>You have awoken from your Little Death.</span>")
			else if (yin_chi > 0)
				yin_chi -= 1
				cure_torpor()
				to_chat(src, "<span class='notice'>You have awoken from your Little Death.</span>")
			else
				to_chat(src, "<span class='warning'>You have no Chi to re-awaken with...</span>")

/mob/living/proc/cure_torpor(source)
	if (!HAS_TRAIT(src, TRAIT_TORPOR))
		return

	while(health <= HEALTH_THRESHOLD_CRIT)
		if(get_stamina_loss() > 0)
			heal_overall_damage(stamina = 10)
		else if(get_oxy_loss() > 0)
			adjust_oxy_loss(-10)
		else if(get_brute_loss() > 0)
			heal_overall_damage(brute = 10)
		else if(get_tox_loss() > 0)
			adjust_tox_loss(-10)
		else if(get_fire_loss() > 0)
			heal_overall_damage(burn = 10)

	cure_fakedeath(source)
	REMOVE_TRAIT(src, TRAIT_TORPOR, source)
	if(iskindred(src))
		to_chat(src, "<span class='notice'>You have awoken from your Torpor.</span>")
	if(iscathayan(src))
		to_chat(src, "<span class='notice'>You have awoken from your Little Death.</span>")
