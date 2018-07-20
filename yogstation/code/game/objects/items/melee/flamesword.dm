/obj/effect/temp_visual/soul_sword
	icon = 'yogstation/icons/obj/soulsword.dmi'
	icon_state = "soulwall"
	randomdir = 0
	duration = 50


/obj/item/melee/soul_sword
	name = "\improper soulbound sword"
	desc = "It is said that these swords can manifest the magical power of gifted individuals into raw power, performing many feats. The stronger the wielder, the more powerful the attack."
	icon = 'yogstation/icons/obj/soulsword.dmi'
	icon_state = "spectral"
	item_state = "spectral"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags = CONDUCT
	sharpness = IS_SHARP
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	throwforce = 1
	hitsound = 'sound/effects/ghost2.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "rended")
	var/ignited = FALSE
	var/mob/living/owner
	var/active = FALSE
	var/block_chance = 0

/obj/item/melee/soul_sword/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/melee/soul_sword/process()
	if(active && ingnited)
		owner.staminaloss *= 5


/obj/item/melee/soul_sword/attack_self(mob/user)
	if(!owner)
		playsound(loc, 'sound/effects/ghost2.ogg', 50, 1)
		visible_message("[user] begins to channel their energy into [src]!")
		if(do_after(user,130, target = src))
			visible_message("[src] glows faintly")

	else
		if(user == owner)
			ignite()

/obj/item/melee/soul_sword/proc/ignite()
	switch(ignite)
		if(TRUE)
			visible_message("[src] shrinks as the wind dies down a bit.")
			playsound(loc, 'sound/magic/castsummon.ogg', 50, 1)
			ignite = FALSE
		if(FALSE)
			visible_message("[src] bursts into flames!")
			playsound(loc, 'sound/magic/fireball.ogg', 100, 1)
			ignite = TRUE

/obj/item/melee/soul_sword/proc/interdict()
	if(owner)
		if(!active && ignited)
			owner.say("Awaken!, [src]!")
			playsound(loc, 'sound/magic/clockwork/invoke_general.ogg', 100, 1)
			visible_message("A huge wall of purple mist appears around [owner]!")
			active = TRUE
			block_chance = 100
			owner.cloneloss *= 8 //Using this sword drains the energy of a soul in exchange for powers.
			to_chat(owner, "You can feel a screaming pain inside your chest")
			addtimer(CALLBACK(src, .proc/remove_interdict), 50)
			for(var/mob/living/M in urange(10, owner))
				if(!M.stat)
					shake_camera(M, 15, 2)

/obj/item/melee/soul_sword/proc/remove_interdict()
	active = FALSE
	visible_message("The veil surrounding [owner] fizzles away!")
	block_chance = initial(block_chance)


/obj/item/melee/soul_sword/proc/cut()
	if(owner)
		if(!active && ignited)
			owner.say("Lend me your speed, [src]!")
			playsound(loc, 'sound/magic/smoke.ogg', 100, 1)
			visible_message("[owner] channels their energy into [src]!")
			active = TRUE
			if(do_after(user,30, target = src))
				owner.cloneloss *= 15 //Using this sword drains the energy of a soul in exchange for powers.
				to_chat(owner, "You can feel a screaming pain inside your chest")
				addtimer(CALLBACK(src, .proc/remove_interdict), 50)
				for(var/mob/living/M in oview(7, owner))
					owner.spin(7, 1)
					owner.SpinAnimation(7,1)
					user.throw_at(M, 200, 4,owner)
					sleep(5)
					if(attack(M,owner))
						shake_camera(M, 5, 2)
						playsound(M.loc, 'sound/magic/wandodeath.ogg', 30, 1)

/obj/item/melee/soul_sword/IsReflect()
	if(active)
		playsound(src, pick('sound/weapons/effects/ric1.ogg', 'sound/weapons/effects/ric2.ogg', 'sound/weapons/effects/ric3.ogg', 'sound/weapons/effects/ric4.ogg', 'sound/weapons/effects/ric5.ogg'), 100, 1)
		return TRUE
	else
		..()

/obj/item/melee/soul_sword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	playsound(loc, 'sound/magic/repulse.ogg', 100, 1)
	if(prob(block_chance))
		if(attack_type == PROJECTILE_ATTACK)
			owner.visible_message("<span class='danger'>the [attack_text] sinks into [src]!</span>")
			playsound(src, pick('sound/weapons/effects/curse1.ogg', 'sound/weapons/effects/curse2.ogg', 'sound/weapons/effects/curse3.ogg', 'sound/weapons/effects/curse4.ogg', 'sound/weapons/effects/curse5.ogg'), 100, 1)
			return TRUE
		else
			playsound(src, 'sound/weapons/effects/curse1.ogg', 75, 1)
			owner.visible_message("<span class='danger'>the [attack_text] bounces off [owner]'s spiritual field [src]!</span>")
			return TRUE
	return FALSE