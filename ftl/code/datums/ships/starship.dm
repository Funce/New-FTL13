/datum/starship
	var/name
	var/static/ship_count = 0
	var/unique_id

	var/obj/effect/landmark/ship_spawn/ship_spawn_slot //Slot this ship occupies in the ShipSpawnLocations assoc list from the ships subsystem

	var/hull_integrity
	var/shield_integrity
	var/traits
	var/status

	var/list/shiprooms = list()

	var/datum/map_template/ftl/combat/template
	var/prefix = "ftl/_maps/ships/"
	var/combat_map = "combat/generic_ship.dmm"

/datum/starship/New(turf/T, var/ship_spawn_slot)
	. = ..()
	unique_id = "[name] [++ship_count]"
	SSships.currentships[unique_id] = src

	var/map = "[prefix][combat_map]"
	template = new(map)
	template.load(T, TRUE)

	src.ship_spawn_slot = ship_spawn_slot
	SSships.ShipSpawnLocations[ship_spawn_slot] = FALSE //This slot is taken now, cya chump.

	var/shipareas
	for(var/turf/open/indestructible/ftlfloor/floor in template.get_affected_turfs(src.ship_spawn_slot.loc))
		floor.unique_id = unique_id

		var/area/ftl/shiproom/A = get_area(floor)
		if(!shiprooms.Find(A))
			continue

		shipareas += A
		CreateShipRoom(A)

/datum/starship/proc/CreateShipRoom(var/Atype)
	switch(Atype)
		if(BRIDGE)
			var/datum/shiproom/bridge/x = new(src)
			shiprooms[Atype] = x
		if(SHIELDS)
			var/datum/shiproom/shields/x = new(src)
			shiprooms[Atype] = x
		if(WEAPONS)
			var/datum/shiproom/weapons/x = new(src)
			shiprooms[Atype] = x
		if(ENGINE)
			var/datum/shiproom/engine/x = new(src)
			shiprooms[Atype] = x
		else
			var/datum/shiproom/x = new(src)
			shiprooms[Atype] = x


/datum/starship/proc/ShieldHit(var/datum/player_attack/attack_info)
	shield_integrity -= max(0, shield_integrity - attack_info.shield_damage)

/datum/starship/Destroy()
	. = ..()
	SSships.ShipSpawnLocations[ship_spawn_slot] = TRUE //This slot is free for a new ship now.
	SSships.currentships -= unique_id
	for(var/i in template.get_affected_turfs(ship_spawn_slot.loc, TRUE)) //this is so shit TODO: kill this unless this is our best way of cleaning up.
		var/turf/T = i
		for(var/x in T.contents)
			qdel(x)
		qdel(T)
		CHECK_TICK

/datum/starship/adjust_hull(value) //use this to change hull level or i kill you
	hull_integrity = max(hull_integrity + value, initial(hull_integrity))
	if(hull_integrity <= 0)
		qdel(src) //we dead

/datum/starship/testship
	hull_integrity = 5000
	shield_integrity = 0



