view: locations {
  sql_table_name: game_of_thrones_19.locations ;;

  dimension: location {
    type: string
    sql: ${TABLE}.location ;;
    map_layer_name: got_geo
  }
  dimension: sub_location {
    type: string
    sql: ${TABLE}.sub_location ;;
    map_layer_name: got_geo
  }
  measure: count {
    type: count
    drill_fields: []
  }

}
