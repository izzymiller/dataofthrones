view: opening_locations {
  sql_table_name: game_of_thrones_19.opening_locations ;;

  dimension: fx {
    type: number
    sql: ${TABLE}.fx ;;
  }

  dimension: fy {
    type: number
    sql: ${TABLE}.fy ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}.note ;;
  }

  measure: count {
    type: count
    drill_fields: [name]
  }
}
