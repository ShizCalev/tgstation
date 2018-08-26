/turf/open/floor/grating
	name = "grate-covered plating" //it's pretty great, isn't it?
	desc = "A section of plating covered by a metal grate."
	icon_state = "grating_map"
	intact = FALSE
	floor_tile = /obj/item/stack/sheet/metal

	broken_states = list("broken_grate")
	burnt_states = list("burnt_grate")
	var/burnt_and_broken_state = list("burnt_broken_grate")

	var/mutable_appearance/grate_overlay
	var/cover_unscrewed = FALSE

/turf/open/floor/grating/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>The grate appears to be [cover_unscrewed ? "firmly screwed in place." : "unfastened. You might be able to lift it off with a <i>crowbar</i>."]</span>")

/turf/open/floor/grating/Initialize(mapload)
	. = ..()
	if(mapload)
		baseturfs += /turf/open/floor/plating
	icon_state = "plating"
	grate_overlay = mutable_appearance(icon, "grate_overlay", TURF_GRATE_LAYER)
	add_overlay(grate_overlay)

/turf/open/floor/grating/break_tile()
	if(broken)
		return
	cut_overlay(grate_overlay)
	if(burnt)
		grate_overlay = mutable_appearance(icon, pick(burnt_and_broken_state), TURF_GRATE_LAYER)
	else
		grate_overlay = mutable_appearance(icon, pick(broken_states, TURF_GRATE_LAYER))
	add_overlay(grate_overlay)
	broken = TRUE

/turf/open/floor/grating/burn_tile()
	if(burnt)
		return
	cut_overlay(grate_overlay)
	if(broken)
		grate_overlay = mutable_appearance(icon, pick(burnt_and_broken_state), TURF_GRATE_LAYER)
	else
		grate_overlay = mutable_appearance(icon, pick(burnt_states), TURF_GRATE_LAYER)
	add_overlay(grate_overlay)
	burnt = TRUE

/turf/open/floor/grating/try_replace_tile()
	return

/turf/open/floor/grating/screwdriver_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='notice'>You start to [cover_unscrewed ? "unfasten" : "fasten"] the grate to the floor with [I].</span>")
	if(!I.use_tool(src, user, 30, volume=50))
		cover_unscrewed = !cover_unscrewed
		to_chat(user, "<span class='notice'>You [cover_unscrewed ? "unfastened" : "fasten"] the grate with [I].</span>")
		return TRUE

/turf/open/floor/grating/crowbar_act(mob/living/user, obj/item/I)
	if(!cover_unscrewed)
		return
	to_chat(user, "<span class='notice'>You start trying to pry up the unfastened grate with [I].</span>")
	if(I.use_tool(src, user, 30, volume=80))
		to_chat(user, "<span class='notice'>You managed to lift up the grate from the floor with [I]!</span>")
		playsound(src, 'sound/mecha/mechmove04.ogg', 80, 1)
		make_plating(FALSE, TRUE)
		return TRUE

/turf/open/floor/grating/make_plating(force, drop_tile)
	cut_overlay(grate_overlay)
	if(!broken && drop_tile)
		new floor_tile(src)

	ScrapeAway()
	return TRUE

/turf/open/floor/grating/blob_act(obj/structure/blob/B)
	. = ..()
	make_plating()

/turf/open/floor/grating/gets_drilled()
	visible_message("<span class='danger'>\The [src]'s cover smashes into pieces!</span>")
	playsound(src, 'sound/items/deconstruct.ogg', 80, 1)
	make_plating()
	return TRUE

/turf/open/floor/grating/acid_melt()
	make_plating()
