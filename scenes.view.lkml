view: scenes {
  sql_table_name: game_of_thrones_19.scenes ;;

  dimension: scene_id {
    type: string
    sql: CONCAT(CAST(${TABLE}.scene_start AS string), '-', CAST(${TABLE}.scene_end AS string)) ;;
  }

  dimension: unique_ep {
    type: string
    sql: CONCAT(CAST(${season_num} AS string), "-",CAST(${episode_num} AS string)) ;;
  }

  dimension: pk {
    type: string
    sql: concat(${unique_ep},"-", ${scene_id}) ;;
    primary_key: yes
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
    type: string
    sql: ${TABLE}.alt_location ;;
  }

  dimension: flashback {
    type: string
    sql: ${TABLE}.flashback ;;
  }

  dimension: greensight {
    type: string
    sql: ${TABLE}.greensight ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}.location ;;
  }

  dimension_group: scene_end {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.scene_end ;;
  }

  dimension_group: scene_start {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.scene_start ;;
  }

  dimension: sub_location {
    type: string
    sql: ${TABLE}.sub_location ;;
  }

  dimension: warg {
    type: string
    sql: ${TABLE}.warg ;;
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
    type: string
    sql: CONCAT(CAST(${TABLE}.scene_start AS string), '-', CAST(${TABLE}.scene_end AS string)) ;;
    primary_key: no
  }

  dimension: unique_ep {
    type: string
    sql: CONCAT(CAST(${TABLE}.season_num AS string), "-",CAST(${TABLE}.episode_num AS string)) ;;
  }

  dimension: pk {
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
    label: "Is Marriage Consummated?"
    type: yesno
    sql: ${TABLE}.characters_married_consummated ;;
  }

  dimension: characters_married_to {
    label: "Married To"
    type: string
    sql: ${TABLE}.characters_married_to ;;
  }

  dimension: characters_married_type {
    label: "Marriage Type"
    type: string
    sql: ${TABLE}.characters_married_type ;;
  }

  dimension: characters_married_when {
    label: "Married When"
    type: string
    sql: ${TABLE}.characters_married_when ;;
  }

  dimension: characters_sex_type {
    label: "Sex Type"
    type: string
    sql: ${TABLE}.characters_sex_type ;;
  }

  dimension: characters_sex_when {
    label: "Sex When"
    type: string
    sql: ${TABLE}.characters_sex_when ;;
  }

  dimension: characters_sex_with {
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
    label: "Weapon Action"
    type: string
    sql: ${TABLE}.characters_weapon_action ;;
  }

  dimension: characters_weapon_name {
    label: "Weapon Name"
    type: string
    sql: ${TABLE}.characters_weapon_name ;;
  }


}
