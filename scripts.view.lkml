view: scripts {
  sql_table_name: game_of_thrones_19.lines ;;

  dimension: unique_line_id {
    primary_key: yes
    type: string
    sql: concat(${episode},CAST(${linenum} AS STRING)) ;;
  }
  dimension: episode {
    type: string
    sql: ${TABLE}.episode ;;
  }

  dimension: linenum {
    #The number of the line within the episode-- Ordering.
    type: number
    sql: ${TABLE}.linenum ;;
  }

  dimension: line {
    type: string
    sql: ${TABLE}.line ;;
  }

  dimension: speaker {
    #Character Name. SCENEDIR for scene direction lines.
    type: string
    sql: ${TABLE}.speaker ;;
  }

  dimension: sentiment {
    type: number
    sql: ${TABLE}.compound ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
