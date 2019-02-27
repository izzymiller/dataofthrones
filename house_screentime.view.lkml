view: house_screentime {
  sql_table_name: game_of_thrones_19.house_screentime ;;

  dimension: house {
    type: string
    sql: ${TABLE}.house ;;
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
