
local can_be_sac = {}         -- array for custom new items that can be sacrificed 
local can_be_sac_favor = {}   -- holds amount of favor that is required for sacrifice and amount of favor to add after sacrifice
local awaiting_to_be_sac = {} -- array to store temporary PROTOSHOPKEEPER uid's

function add_sacrifice(entType, add_favor, required_favor)
	can_be_sac[#can_be_sac+1] = entType
	can_be_sac_favor[entType] = {required_favor, add_favor}
end

set_callback(function()

	for _, ent in ipairs(get_entities_by_type(can_be_sac)) do
		mov = get_entity(ent)
		ent_type = mov.type.id
		altar = mov.standing_on_uid
		
		if can_be_sac_favor[ent_type][1] == nil or state.kali_favor >= can_be_sac_favor[ent_type][1] then -- has required amount of favor?
		
			if awaiting_to_be_sac[ent] == nil then --wasn’t already on the altar?
			
				if get_entity_type(altar) == ENT_TYPE.FLOOR_ALTAR -- is on the altar
				and mov.velocityx == 0 and mov.velocityy == 0     --is not moving
				--and mov.stand_counter > 0 
				and mov.falling_timer == 0 then --is not in the air
					
					state.kali_favor = state.kali_favor + can_be_sac_favor[ent_type][2] --set the favor now so the kali gift can spawn
					x, y, layer = get_position(altar)
					spawned_uid = spawn(ENT_TYPE.MONS_PROTOSHOPKEEPER, x, y+1.0, layer, 0, 0) --spawn this ugly bastard 
					mov_spawned = get_entity(spawned_uid)
					mov_spawned.flags = 1091582984 --sets some flags so you can't interact with it
                    local org_blood_content = mov_spawned.type.blood_content
                    set_global_timeout(function() 
                        mov_spawned.type.blood_content = org_blood_content -- set back the original blood_content after 10s
                    end, 600)
					mov_spawned.type.blood_content = 0    --no blood
					mov_spawned.color.a = 0               --make it invisible
					mov_spawned.state = 18                --stunned
					mov_spawned.stun_timer = 999          --just to be sure
					mov_spawned.standing_on_uid = altar   --just to be sure
					awaiting_to_be_sac[ent] = spawned_uid --save the uid to check on him later
				end
			else
				if get_entity(awaiting_to_be_sac[ent]) == nil then --if spawned entity is gone (sacrificed)
				
					if get_entity(ent) == nil then --if the original is also gone, some frame perfect stuff?
					
						awaiting_to_be_sac[ent] = nil
						--message("this not supposed to happen")
					else
						kill_entity(ent) --sacrifice complete, remove the item
						awaiting_to_be_sac[ent] = nil
						if on_sacrifice ~= nil then 
                            on_sacrifice(ent_type, altar) -- call "callback" only if it exists
                        end
					end
				else --if spawned entity is still kicking (waiting  to sacrifice)
                    the_ent = get_entity(ent)
					if the_ent == nil then --if the original is gone (crushed maybe?)
                        
                        get_entity(awaiting_to_be_sac[ent]):destroy()
						awaiting_to_be_sac[ent] = nil
						state.kali_favor = state.kali_favor - can_be_sac_favor[ent_type][2] --remove the favor cause there was no sacrifice
						
					else --if both are still kicking

						if get_entity_type(the_ent.standing_on_uid) ~= ENT_TYPE.FLOOR_ALTAR then --if it's taken from the altar
						
							get_entity(awaiting_to_be_sac[ent]):destroy()
							awaiting_to_be_sac[ent] = nil
							state.kali_favor = state.kali_favor - can_be_sac_favor[ent_type][2] --remove the favor cause there was no sacrifice
						end
					end
				end
			end
		end
	end
end, ON.FRAME)
