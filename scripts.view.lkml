view: scripts {
  sql_table_name: game_of_thrones_19.lines ;;


  dimension: id {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.id ;;
  }


#   dimension: unique_line_id {
#     primary_key: yes
#     type: string
#     sql: concat(${episode},CAST(${linenum} AS STRING)) ;;
#   }


  dimension: episode {
    hidden: yes
    label: "Episode"
    description: "Episode Title"
    type: string
    sql: ${TABLE}.episode ;;
  }

  dimension: linenum {
    label: "Line Number"
    description: "The number of the line within the episode, chronologically"
    #The number of the line within the episode-- Ordering.
    type: number
    sql: ${TABLE}.linenum ;;
  }

  dimension: line {
    label: "Line"
    description: "Actual words spoken"
    type: string
    sql: ${TABLE}.line ;;
  }

  dimension: speaker_raw {
    #Character Name. SCENEDIR for scene direction lines.
    hidden: yes
    type: string
    sql:
        ${TABLE}.speaker;;
  }

  dimension: speaker {
    description: "Character Name who Spoke. 'SCENEDIR' for scene directions"
    type: string
    sql: ${TABLE}.speaker ;;
  }


  ##SENTIMENT ANALYSIS, DONE USING VADER

  dimension: sentiment {
    description: "Sentiment of line, calculated using VADER (https://github.com/cjhutto/vaderSentiment)"
    type: number
    sql: ${TABLE}.compound ;;
  }

  measure: average_sentiment {
    label: "Average Sentiment of lines"
    description: "Sentiment calculated using VADER (https://github.com/cjhutto/vaderSentiment)"
    type: average
    sql: ${sentiment} ;;
    drill_fields: [detail*]
  }

  measure: count_negative_lines {
    label: "Number of Negative Lines"
    description: "Sentiment calculated using VADER (https://github.com/cjhutto/vaderSentiment)"
    type: count
    filters: {
      field: sentiment
      value: "<0"
    }
    drill_fields: [detail*]
  }
  measure: count_positive_lines {
    label: "Number of Positive lines"
    description: "Sentiment calculated using VADER (https://github.com/cjhutto/vaderSentiment)"
    type: count
    filters: {
      field: sentiment
      value: ">0"
    }
    drill_fields: [detail*]
  }

  measure: count_neutral_lines {
    label: "Number of Neutral Lines"
    description: "Sentiment calculated using VADER (https://github.com/cjhutto/vaderSentiment)"
    type: count
    filters: {
      field: sentiment
      value: "0"
    }
    drill_fields: [detail*]
  }

  measure: count {
    label: "Count of all lines"
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [episode,linenum,line,speaker,sentiment]
  }

}
