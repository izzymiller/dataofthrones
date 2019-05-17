view: scenes {
  sql_table_name: game_of_thrones_19.scenes ;;

  dimension: pk {
    #Generated Row_Number over the entire dataset, means nothing but uniqueness
    type: number
    sql: ${TABLE}.pk ;;
    hidden: yes
    primary_key: yes
  }

  dimension: unique_scene {
    type: string
    sql: concat(${unique_ep},"-", ${scene_id}) ;;
    primary_key: no
  }

  dimension: scene_id {
    description: "ID of Scene within the episode. In chronological order"
    ##The ID of the scene within the episode
    type: string
    sql: CONCAT(CAST(${TABLE}.scene_start AS string), '-', CAST(${TABLE}.scene_end AS string)) ;;
  }

  dimension: unique_ep {
    label: "Unique Episode"
    description: "Season/Episode combination"
#     hidden: yes
    ## The Season/Episode Number combo
    type: string
    sql: CONCAT(CAST(${season_num} AS string), "-",CAST(${episode_num} AS string)) ;;
  }

  dimension: season_num {
    label: "Season"
#     hidden: yes
    type: number
    sql: ${TABLE}.season_num ;;
  }

  dimension: episode_num {
    label: "Episode"
#     hidden: yes
    type: number
    sql: ${TABLE}.episode_num ;;
  }

  # dimension: alt_location {
  #   group_label: "Location"
  #   label: "Alternate Location"
  #   type: string
  #   sql: ${TABLE}.alt_location ;;
  # }

  dimension: flashback {
    label: "Is Flashback?"
    type: string
    sql: ${TABLE}.flashback ;;
  }

  dimension: greensight {
    label: "Has Greensight?"
    type: string
    sql: ${TABLE}.greensight ;;
  }

  dimension: location {
    group_label: "Location"
    label: "Location"
    type: string
    sql: ${TABLE}.location ;;
#     map_layer_name: major_locations
  }

  dimension: scene_end {
    label: "Scene End Time"
    description: "Timestamp in Episode that scene ended"
    type: string
    sql: ${TABLE}.scene_end ;;
  }

  dimension: scene_start {
    label: "Scene Start Time"
    description: "Timestamp in Episode that scene began"
    type: string
    sql: ${TABLE}.scene_start ;;
  }

  dimension: scene_length_secs {
    type: number
    hidden: yes
    sql: TIME_DIFF( ${TABLE}.scene_end,${TABLE}.scene_start,second) ;;
  }

  dimension: sub_location {
    group_label: "Location"
    label: "Sub Location"
    type: string
    sql: ${TABLE}.sub_location ;;
    map_layer_name: major_locations ##TODO ADD NEW LOCATIONS
  }

  dimension: warg {
    label: "Warg?"
    type: yesno
    sql: ${TABLE}.warg = "true" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: scene_length_seconds {
    label: "Scene Length (s)"
    type: sum_distinct
    group_label: "Scene Length"
    sql: ${scene_length_secs} ;;
    sql_distinct_key: ${unique_scene} ;;
    drill_fields: [detail*]
  }

  measure: scene_length_minutes {
    label: "Scene Length (m)"
    group_label: "Scene Length"
    type: sum_distinct
    sql: ${scene_length_secs}/60 ;;
    sql_distinct_key: ${unique_scene} ;;
    drill_fields: [detail*]
  }

  set: detail {
    fields: [season_num,episode_num,unique_scene,location,sub_location]
  }
}

###################################
###################################
###################################
###################################
###################################
###################################
###################################


view: scene_characters {
  sql_table_name: game_of_thrones_19.scenes ;;

  dimension: characters_name {
    type: string
    hidden: yes
    #For joining characters in
    sql: ${TABLE}.characters_name ;;
  }

  dimension: scene_id {
  description: "Unique Scene ID *within episode*. Scene start + scene_end"
    #Unique ID of scene within episode
    type: string
    sql: CONCAT(CAST(${TABLE}.scene_start AS string), '-', CAST(${TABLE}.scene_end AS string)) ;;
    primary_key: no
  }

  dimension: unique_ep {
    label: "Unique Episode"
    description: "Season + Episode combo"
    #The season/episode unique combo
    type: string
    sql: CONCAT(CAST(${TABLE}.season_num AS string), "-",CAST(${TABLE}.episode_num AS string)) ;;
  }

  dimension: pk {
    #Generated Row_Number over the entire dataset, means nothing but uniqueness
    type: number
    sql: ${TABLE}.pk ;;
    hidden: yes
    primary_key: yes
  }

  dimension: unique_scene {
    description: "Season - Episode - Scene combination"
    type: string
    sql: concat(${unique_ep},"-", ${scene_id}) ;;
    primary_key: no
  }

  dimension: characters_alive {
    description: "Was character alive in this scene?"
    label: "Is Alive?"
    type: yesno
    sql:${TABLE}.characters_alive IS NULL ;;
  }

  dimension: characters_born {
    description: "Was character born in this scene?"
    label: "Is Born?"
    type: yesno
    sql: ${TABLE}.characters_born ;;
  }

  dimension: characters_killed_by {
    description: "Who killed the selected character in the scene"
    label: "Is Killed By"
    type: string
    sql: ${TABLE}.characters_killed_by ;;
  }

  dimension: characters_manner_of_death {
    label: "Manner of Death"
    description: "How Character died. Sometimes a bit vague."
    type: string
    sql: ${TABLE}.characters_manner_of_death ;;
  }

  dimension: characters_married_consummated {
    group_label: "Marriage"
    label: "Is Marriage Consummated?"
    type: yesno
    sql: ${TABLE}.characters_married_consummated ;;
  }

  dimension: characters_married_to {
    group_label: "Marriage"
    label: "Married To"
    type: string
    sql: ${TABLE}.characters_married_to ;;
  }

  dimension: characters_married_type {
    group_label: "Marriage"
    label: "Marriage Type"
    type: string
    sql: ${TABLE}.characters_married_type ;;
  }

  dimension: characters_married_when {
    group_label: "Marriage"
    label: "Married When"
    type: string
    sql: ${TABLE}.characters_married_when ;;
  }

  dimension: characters_sex_type {
    group_label: "Sex"
    label: "Sex Type"
    description: "Type of Sex, from the raw data."
    type: string
    sql: ${TABLE}.characters_sex_type ;;
  }

  dimension: characters_sex_when {
    group_label: "Sex"
    label: "Sex When"
    description: "Past, Present, or Future"
    type: string
    sql: ${TABLE}.characters_sex_when ;;
  }

  dimension: characters_sex_with {
    group_label: "Sex"
    label: "Sex With"
    description: "Name of Character"
    type: string
    sql: ${TABLE}.characters_sex_with ;;
  }

  # dimension: characters_title {
  #   label: ""
  #   type: string
  #   sql: ${TABLE}.characters_title ;;
  # }

  dimension: characters_weapon_action {
    group_label: "Weapon"
    label: "Weapon Action"
    type: string
    sql: ${TABLE}.characters_weapon_action ;;
  }

  dimension: characters_weapon_name {
    group_label: "Weapon"
    label: "Weapon Name"
    type: string
    sql: ${TABLE}.characters_weapon_name ;;
  }

  measure: count_deaths {
  type: count
   filters: {
     field: characters_killed_by
     value: "-NULL"
   }
  sql_distinct_key: CONCAT(${characters_name}, CAST(${pk} AS string)) ;;
  drill_fields: [characters_name, characters_killed_by, characters_manner_of_death]
  }

#   measure: count_kills {
#     type: count
#     filters: {
#       field: characters_killed_by
#       value: "-NULL"
#     }
#     sql_distinct_key: CASE WHEN ${characters_killed_by} = ${characters_name} THEN CONCAT(${characters_name}, CAST(${pk} AS string)) ELSE NULL END ;;
#   }


}
