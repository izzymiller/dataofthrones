view: locations {
  sql_table_name: game_of_thrones_19.locations ;;

  dimension: regions {
    hidden: yes
    sql: ${TABLE}.regions ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}

view: locations__regions {
  dimension: location {
    type: string
    sql: ${TABLE}.location ;;
  }

  dimension: sub_location {
    type: string
    sql: ${TABLE}.subLocation ;;
  }
}
