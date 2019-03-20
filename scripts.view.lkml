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
    description: "The number of the line within the episode, chronologically"
    #The number of the line within the episode-- Ordering.
    type: number
    sql: ${TABLE}.linenum ;;
  }

  dimension: line {
    description: "Actual line spoken"
    type: string
    sql: ${TABLE}.line ;;
  }

  dimension: speaker {
    description: "Character Name who Spoke. 'SCENEDIR' for scene directions"
    #Character Name. SCENEDIR for scene direction lines.
    type: string
    sql: ${TABLE}.speaker ;;
  }


  ##SENTIMENT ANALYSIS, DONE USING VADER

  dimension: sentiment {
    description: "Sentiment of line, calculated using VADER"
    type: number
    sql: ${TABLE}.compound ;;
  }

  measure: average_sentiment {
    description: "Overall Average Sentiment of lines"
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
