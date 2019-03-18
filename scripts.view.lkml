view: scripts {
  sql_table_name: game_of_thrones_19.lines ;;


  dimension: id {
    type: number
    primary_key: yes
    sql: ${TABLE}.id ;;
  }


#   dimension: unique_line_id {
#     primary_key: yes
#     type: string
#     sql: concat(${episode},CAST(${linenum} AS STRING)) ;;
#   }


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

  measure: average_sentiment {
    type: average
    sql: ${sentiment} ;;
  }

  measure: count_negative_lines {
    type: count
    filters: {
      field: sentiment
      value: "<0"
    }
  }
  measure: count_positive_lines {
    type: count
    filters: {
      field: sentiment
      value: ">0"
    }
  }

  measure: count_neutral_lines {
    type: count
    filters: {
      field: sentiment
      value: "0"
    }
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
