view: screentimes_2 {
  sql_table_name: game_of_thrones_19.screentimes_2 ;;

  dimension: episodes {
    type: string
    sql: ${TABLE}.episodes ;;
  }

  dimension: imdb_url {
    type: string
    sql: ${TABLE}.imdb_url ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: portrayed_by_imdb_url {
    type: string
    sql: ${TABLE}.portrayed_by_imdb_url ;;
  }

  dimension: portrayed_by_name {
    type: string
    sql: ${TABLE}.portrayed_by_name ;;
  }

  dimension: screentime {
    type: number
    sql: ${TABLE}.screentime ;;
  }

  measure: count {
    type: count
    drill_fields: [name, portrayed_by_name]
  }
}
