view: scenes {
  sql_table_name: game_of_thrones_19.scenes ;;

  dimension: pk {
    type: string
    sql: concat(${unique_ep},"-", ${scene_id}) ;;
    primary_key: yes
  }

  dimension: scene_id {
    ##The ID of the scene within the episode
    type: string
    sql: CONCAT(CAST(${TABLE}.scene_start AS string), '-', CAST(${TABLE}.scene_end AS string)) ;;
  }

  dimension: unique_ep {
    ## The Season/Episode Number combo
    type: string
    sql: CONCAT(CAST(${season_num} AS string), "-",CAST(${episode_num} AS string)) ;;
  }

  dimension: season_num {
    type: number
    sql: ${TABLE}.season_num ;;
  }

  dimension: episode_num {
    type: number
    sql: ${TABLE}.episode_num ;;
  }

  dimension: alt_location {
    group_label: "Location"
    label: "Alternate Location"
    type: string
    sql: ${TABLE}.alt_location ;;
  }

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
  }

  dimension: scene_end {
    label: "Scene End"
    type: string
    sql: ${TABLE}.scene_end ;;
  }

  dimension: scene_start {
    label: "Scene Start"
    type: string
    sql: ${TABLE}.scene_start ;;
  }

  dimension: scene_length_secs {
    type: number
    sql: TIME_DIFF( ${TABLE}.scene_end,${TABLE}.scene_start,second) ;;
  }

  dimension: sub_location {
    group_label: "Location"
    label: "Sub Location"
    type: string
    sql: ${TABLE}.sub_location ;;
  }

  dimension: warg {
    label: "Warg?"
    type: yesno
    sql: ${TABLE}.warg = "true" ;;
  }

  measure: count {
    type: count
  }
}


view: scene_characters {
  sql_table_name: game_of_thrones_19.scenes ;;

  dimension: characters_name {
    type: string
    hidden: yes
    #For joining characters in
    sql: ${TABLE}.characters_name ;;
  }

  dimension: scene_id {
    #Unique ID of scene within episode
    type: string
    sql: CONCAT(CAST(${TABLE}.scene_start AS string), '-', CAST(${TABLE}.scene_end AS string)) ;;
    primary_key: no
  }

  dimension: unique_ep {
    #The season/episode unique combo
    type: string
    sql: CONCAT(CAST(${TABLE}.season_num AS string), "-",CAST(${TABLE}.episode_num AS string)) ;;
  }

  dimension: pk {
    #Primary Key
    type: string
    sql: concat(${unique_ep},"-", ${scene_id}) ;;
    primary_key: yes
  }

  dimension: characters_alive {
    label: "Is Alive?"
    type: yesno
    sql: ${TABLE}.characters_alive ;;
  }

  dimension: characters_born {
    label: "Is Born?"
    type: yesno
    sql: ${TABLE}.characters_born ;;
  }

  dimension: characters_killed_by {
    label: "Is Killed By"
    type: string
    sql: ${TABLE}.characters_killed_by ;;
  }

  dimension: characters_manner_of_death {
    label: "Manner of Death"
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
    type: string
    sql: ${TABLE}.characters_sex_type ;;
  }

  dimension: characters_sex_when {
    group_label: "Sex"
    label: "Sex When"
    type: string
    sql: ${TABLE}.characters_sex_when ;;
  }

  dimension: characters_sex_with {
    group_label: "Sex"
    label: "Sex With"
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


}