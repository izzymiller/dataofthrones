#Up to date through season 7
view: actor_screentime {
  sql_table_name: game_of_thrones_19.actor_screentime ;;

  dimension: actor {
    type: string
    sql: ${TABLE}.actor ;;
  }

  dimension: season_1 {
    type: number
    sql: ${TABLE}.season_1 ;;
  }

  dimension: season_2 {
    type: number
    sql: ${TABLE}.season_2 ;;
  }

  dimension: season_3 {
    type: number
    sql: ${TABLE}.season_3 ;;
  }

  dimension: season_4 {
    type: number
    sql: ${TABLE}.season_4 ;;
  }

  dimension: season_5 {
    type: number
    sql: ${TABLE}.season_5 ;;
  }

  dimension: season_6 {
    type: number
    sql: ${TABLE}.season_6 ;;
  }

  dimension: season_7 {
    type: number
    sql: ${TABLE}.season_7 ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
