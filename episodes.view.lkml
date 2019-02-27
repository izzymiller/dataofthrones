view: episodes {
  sql_table_name: game_of_thrones_19.episodes ;;

  dimension: pk {
    type: string
    sql: CONCAT(CAST(${season_num} AS string),"-",CAST(${episode_num} AS string),"-",${opening_sequence_locations}) ;;
    primary_key: yes
  }

  dimension: unique_episode {
    type: string
    sql: CONCAT(CAST(${season_num} AS string),"-",CAST(${episode_num} AS string)) ;;
  }

  dimension: episode_num {
    type: number
    sql: ${TABLE}.episode_num ;;
  }

  dimension: air_date {
    type: string
    sql: ${TABLE}.air_date ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension: link {
    type: string
    sql: ${TABLE}.link ;;
  }

  dimension: opening_sequence_locations {
    type: string
    sql: ${TABLE}.opening_sequence_locations ;;
  }

  dimension: season_num {
    type: number
    sql: ${TABLE}.season_num ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}.title ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  measure: count_episodes {
    type: count_distinct
    sql: ${unique_episode} ;;
  }
}
