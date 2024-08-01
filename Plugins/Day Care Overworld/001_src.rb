class Game_Character
	attr_accessor :step_anime
end
class Scene_Map
attr_reader :spritesets
end
class Spriteset_Map
attr_reader :character_sprites
end

class DayCare

	# Update overworld events
	def self.overworld_update()
		return if $game_map.events == nil
		for i in 0..$game_map.events.length do
			event = $game_map.events[i]
			if event == nil # Do nothing
			elsif [DAY_CARE_OVERWORLD_1, DAY_CARE_OVERWORLD_2].include?(event.name)
				day_care_id = event.name == DAY_CARE_OVERWORLD_1 ? 0 : 1
				pokemon = $PokemonGlobal.day_care[day_care_id].pokemon
				if pokemon == nil; event.character_name = "" # Reset sprite
				else
					# Apply transformation
					transform_condition = TRANSFORMATION_LIST.include?(pokemon.species)
					transform_condition = transform_condition && DayCare.count == 2
					transform_condition = transform_condition && !TRANSFORMATION_LIST.include?($PokemonGlobal.day_care[(day_care_id+1)%2].pokemon.species)
					pokemon = $PokemonGlobal.day_care[(day_care_id+1)%2].pokemon if transform_condition

					# Set character sprite
					dir = pokemon.shiny? ? "Followers shiny/" : "Followers/"
					event.character_name = dir + pokemon.name + ".png"
					# Set character properties
					event.move_speed     = 3
					event.move_frequency = 3
					event.walk_anime     = true
					event.step_anime     = true
					event.turn_random
					# Set character interaction command
					if ENABLE_INTERACTION
						event.list.append(RPG::EventCommand.new(355, 0, ["DayCare.overworld_interaction(get_self)"]))
						event.list.append(RPG::EventCommand.new(0))
					end

					#======================================
					# Pokemon Color Variants compatibility
					#======================================
					if PluginManager.installed?("Pokemon Color Variants")
						# Create and draw the pokémon sprite
						sprite = Sprite_Character.new(Spriteset_Map.viewport, event)
						$scene.spritesets[$game_map.map_id] = Spriteset_Map.new($game_map) if !$scene.spritesets[$game_map.map_id]
						$scene.spritesets[$game_map.map_id].character_sprites.push(sprite)
						# Set palette
						sprite.bitmap.palette_change(pokemon.palette_0, pokemon.palette_1) if pokemon.applicable_palette?
						# Set hue
						sprite.bitmap.hue = pokemon.hue if pokemon.applicable_hue?
					end
				end
			end
		end
	end

	# Update after deposit
	DayCare.singleton_class.alias_method :day_care_overworld_deposit, :deposit
	def self.deposit(party_index)
		day_care_overworld_deposit(party_index)
		overworld_update()
	end

	# Update after withdraw
	DayCare.singleton_class.alias_method :day_care_overworld_withdraw, :withdraw
	def self.withdraw(index)
		day_care_overworld_withdraw(index)
		overworld_update()
	end
	
	# Overworld pokemon interaction
	def self.overworld_interaction(event = nil)
		return if event == nil
		return if ![DAY_CARE_OVERWORLD_1, DAY_CARE_OVERWORLD_2].include?(event.name)
		day_care_id = event.name == DAY_CARE_OVERWORLD_1 ? 0 : 1
		pokemon = $PokemonGlobal.day_care[day_care_id].pokemon
		pokemon.play_cry if pokemon != nil
		if DayCare.count == 1; pbMessage(_INTL(pokemon.name + PHRASES[0]))
		elsif DayCare.count == 2
			DayCare.get_compatibility(1)
			case $game_variables[1]
			when 0; pbMessage(_INTL(PHRASES[1]))
			when 1; pbMessage(_INTL(PHRASES[2]))
			when 2; pbMessage(_INTL(PHRASES[3]))
			when 3; pbMessage(_INTL(PHRASES[4]))
			end
		end
	end
end

# Update overworld entering a map
EventHandlers.add(:on_map_or_spriteset_change, :day_care_overworld_pokemon, 
	proc { |_old_map_id| DayCare.overworld_update() }
)
