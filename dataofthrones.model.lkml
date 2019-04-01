connection: "lookerdata_publicdata_standard_sql"

include: "*.view.lkml"                       # include all views in this project



########
##MAPS##
########
map_layer: major_locations {
  file: "major_locations.topojson"
  property_key: "name"
  property_label_key: "name"
}


###############
####EXPLORES###
###############
explore: characters {
  view_name: character_facts
  label: "Characters"
  view_label: "Characters"
  join: characters {
    view_label: "Characters"
    fields: [characters.abducted,characters.abducted_by,characters.allies,characters.kingsguard,characters.married_engaged,characters.royal]
    type: left_outer
    relationship: one_to_one
    sql_on: ${character_facts.name} = ${characters.character_name} ;;
  }
  join: scene_characters {
    relationship: one_to_many
    fields: []
    sql_on: ${scene_characters.characters_name} = ${character_facts.name} ;;
  }
  join: scenes {
    relationship: one_to_one
    fields: []
    sql_on: ${scenes.scene_id} = ${scene_characters.scene_id};;
  }
}

explore: episodes {
  sql_always_where: ${season_num} != 8 ;; # Remove Season 8 null references
  label: "Episodes"
  description: "Episode Level Data"
  join: death_episode {
#  covered by view now. fields: [death_episode.killed_by,death_episode.count_named_deaths,death_episode.manner_of_death,death_episode.character_name]
    view_label: "Deaths"
    type: left_outer
    sql_on: ${episodes.unique_episode} = ${death_episode.unique_episode} AND ${death_episode.character_name} = ${characters.character_name}   ;;
    relationship: one_to_many
  }
  join: sex_episode {
    view_label: "Sex"
    type: left_outer
    sql_on: ${episodes.unique_episode} = ${sex_episode.unique_episode} AND ${sex_episode.character_name} = ${scene_characters.characters_name}  ;;
    relationship: one_to_many
  }
  join: scenes {
    fields: []
    type: left_outer
    relationship: one_to_many
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
#     fields: [characters.actor_name,characters.character_name,
#       characters.nickname,characters.kingsguard,characters.royal,characters.count]
    relationship: many_to_one
    view_label: "Characters"
    type: left_outer
    sql_on: ${characters.character_name} = ${scene_characters.characters_name} ;;
  }
  join: character_facts {
#     fields: [character_facts.is_alive,character_facts.house,character_facts.kills,character_facts.image_full,character_facts.total_screentime,character_facts.image_thumb]
    relationship: one_to_one
    view_label: "Characters"
    type: left_outer
    sql_on: ${character_facts.name} = ${characters.character_name} ;;
  }
}

explore: scene_level_detail {
  sql_always_where: ${season_num} != 8 ;; # Remove Season 8 null references
  view_name: episodes
  label: "Scene Level Detail"
  join: scenes {
    type: left_outer
    relationship: many_to_many
    sql_on: ${scenes.unique_ep} = ${episodes.unique_episode} ;;
  }

  join: scene_characters {
    view_label: "Scene Actions"
    type: left_outer
    relationship: one_to_many
    sql_on: ${scenes.pk} = ${scene_characters.pk} ;;
  }

  join: characters {
    view_label: "Characters"
    type: left_outer
    relationship: many_to_one
    sql_on: ${characters.character_name} = ${scene_characters.characters_name} ;;
  }
  join: character_facts {
    view_label: "Characters"
    type: left_outer
    relationship: one_to_one
    sql_on: ${characters.character_name} = ${character_facts.name} ;;
  }
}

explore: scripts {
  #This explore contains line-level script information.
  #Scripts_unnested is broken up by word, to do a word cloud with
  fields: [ALL_FIELDS*,-episodes.scene_length]
  #Lines
  join: scripts_unnested {
    type: left_outer
    relationship: many_to_many
    view_label: "Broken Up By Word"
    sql_on: ${scripts.episode} = ${scripts_unnested.episode} ;;
  }
  join: characters {
    type: left_outer
    relationship: many_to_many
    sql_on: ${characters.character_name} = ${scripts.speaker} ;;
  }
  join: episodes {
    type: left_outer
    relationship: many_to_many
    sql_on: ${scripts.episode} = ${episodes.title} ;;
  }
}

##UNDER CONSTRUCTION
explore: relationships {
  hidden: yes
  fields: [ALL_FIELDS*,-sex_with.screentime_seconds,-sex_with.screentime_minutes,-character_facts.screentime_seconds,-character_facts.screentime_minutes,-killed.screentime_seconds,-killed.screentime_minutes]
  view_label: "Base Character"
  view_name: character_facts
  description: "Relationships and Actions between Characters"
  join: characters {
    view_label: "Base Character"
    sql_on: ${character_facts.name} = ${characters.character_name} ;;
    type: left_outer
    relationship: many_to_many
  }
  join: sex_episode {
    view_label: "Sex With"
    fields: [sex_episode.sex_type,sex_episode.count_sex]
    relationship: one_to_many
    sql_on: ${sex_episode.character_name} = ${character_facts.name} ;;
    type: left_outer
  }
  join: sex_with {
    from: character_facts
    view_label: "Sex With"
    relationship: one_to_one
    sql_on: ${sex_with.name} = ${sex_episode.sex_with} ;;
    type: left_outer
  }

  join: death_episode {
    fields: [death_episode.manner_of_death,death_episode.count_named_deaths,death_episode.count_kills,death_episode.character_name]
    view_label: "Killed"
    relationship: one_to_many
    sql_on: ${death_episode.killed_by} = ${character_facts.name} ;;
    type: left_outer
  }

  join: killed {
    fields: [killed.name,killed.house,killed.image_thumb,killed.image_full,killed.count]
    from: character_facts
    view_label: "Killed"
    relationship: one_to_one
    type: left_outer
    sql_on: ${killed.name} = ${death_episode.character_name} ;;
  }

}
