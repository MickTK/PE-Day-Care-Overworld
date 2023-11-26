#=============================================================================
# Day Care Overworld
#=============================================================================
class DayCare
  
  # Overworld identifiers
  DAY_CARE_OVERWORLD_1 = "poke1" # First pokémon overworld name event
  DAY_CARE_OVERWORLD_2 = "poke2" # Second pokémon overworld name event

  # The pokémons that can assume the aspect of the other pokémon
  TRANSFORMATION_LIST = [:DITTO]

  # Overworld interaction
  ENABLE_INTERACTION = true
  PHRASES = [
    " is doing just fine.",
    "The two prefer to play with other Pokémon more than with each other.",
    "The two don't seem to like each other much.",
    "The two seem to get along.",
    "The two seem to get along very well."
  ]
end
