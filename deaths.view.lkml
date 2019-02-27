view: deaths {
  sql_table_name: game_of_thrones_19.deaths ;;

  dimension: death_episode {
    type: number
    sql: ${TABLE}.death_episode ;;
  }

  dimension: death_isflashback {
    type: yesno
    sql: ${TABLE}.death_isflashback ;;
  }

  dimension: death_season {
    type: number
    sql: ${TABLE}.death_season ;;
  }

  dimension: execution {
    type: string
    sql: ${TABLE}.execution ;;
  }

  dimension: likelihoodofreturn {
    type: string
    sql: ${TABLE}.likelihoodofreturn ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: role {
    type: string
    sql: ${TABLE}.role ;;
  }

  measure: count {
    type: count
    drill_fields: [name]
  }
}
