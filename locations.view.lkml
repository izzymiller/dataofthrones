view: locations {
  sql_table_name: game_of_thrones_19.locations ;;

  dimension: location {
    type: string
    sql: ${TABLE}.location ;;
  }
  dimension: sub_location {
    type: string
    sql: ${TABLE}.sub_location ;;
  }
  measure: count {
    type: count
    drill_fields: []
  }

}
