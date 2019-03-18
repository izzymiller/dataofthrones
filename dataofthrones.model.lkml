connection: "lookerdata_publicdata_standard_sql"

include: "*.view.lkml"                       # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

#
# map_layer: lands_of_ice_and_fire {
#   file: "ice_and_fire.topojson"
#   property_key: "id"
# }

map_layer: got_geo {
  file: "newmerged.topojson"
}

explore: characters {
  view_name: character_facts
  label: "Characters"
}


# explore: characters_old {
#   view_name: characters
#   join: deaths {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${deaths.name} = ${characters.character_name} ;;
#   }
#
#   join: screentimes_2 {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${screentimes_2.name} = ${characters.character_name} ;;
#   }
#
# }


explore: scripts {
  #Lines
  join: scripts_unnested {
    type: left_outer
    relationship: many_to_many
    view_label: "Broken Up By Word"
    sql_on: ${scripts.episode} = ${scripts_unnested.episode} ;;
  }
}

explore: episodes {
  label: "Episodes"
  join: death_episode {
    view_label: "Deaths"
    type: left_outer
    sql_on: ${episodes.unique_episode} = ${death_episode.unique_episode}  ;;
    relationship: one_to_many
  }
  join: sex_episode {
    view_label: "Sex"
    type: left_outer
    sql_on: ${episodes.unique_episode} = ${sex_episode.unique_episode}  ;;
    relationship: one_to_many
  }
  join: scenes {
    fields: []
    type: left_outer
    relationship: many_to_many
    sql_on: ${scenes.unique_ep} = ${episodes.unique_episode} ;;
  }
  join: scene_characters {
    fields: []
    relationship: one_to_many
    view_label: "Scene Actions"
    type: left_outer
    sql_on: ${scenes.pk} = ${scene_characters.pk} ;;
  }

  join: characters {
    fields: [characters.actor_name,characters.character_name,
      characters.nickname,characters.kingsguard,characters.royal,characters.count]
    relationship: many_to_one
    view_label: "Characters"
    type: left_outer
    sql_on: ${characters.character_name} = ${scene_characters.characters_name} ;;
  }

  join: character_facts {
    fields: [character_facts.is_alive,character_facts.house,character_facts.kills,character_facts.image_full,character_facts.total_screentime,character_facts.image_thumb]
    relationship: one_to_one
    view_label: "Characters"
    type: left_outer
    sql_on: ${character_facts.name} = ${characters.character_name} ;;
  }
}


explore: scene_level_information {
  view_name: episodes
  label: "Scene Level Detail"
  join: scenes {
    type: left_outer
    relationship: many_to_many
    sql_on: ${scenes.unique_ep} = ${episodes.unique_episode} ;;
  }

  join: scene_characters {
    relationship: one_to_many
    view_label: "Scene Actions"
    type: left_outer
    sql_on: ${scenes.pk} = ${scene_characters.pk} ;;
  }

  join: characters {
    relationship: many_to_one
    view_label: "Characters"
    type: left_outer
    sql_on: ${characters.character_name} = ${scene_characters.characters_name} ;;
  }

#   join: opening_locations {
#     view_label: "Location"
#     fields: [opening_locations.name]
#     relationship: many_to_many
#     type: left_outer
#     sql_on: ${opening_locations.name} = ${episodes.opening_sequence_locations} ;;
#   }
#   join: locations {
#     view_label: "Location"
#
#     fields: [locations.sub_location,locations.location,opening_locations.note]
#     relationship: one_to_one
#     type: left_outer
#     sql_on: ${locations.sub_location} = ${scenes.sub_location} ;;
#   }
}
