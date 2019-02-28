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
    label: "Opening Location Name"
    type: string
    sql: ${TABLE}.name ;;
    map_layer_name: got_geo
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
