view: deaths {
  sql_table_name: game_of_thrones_19.deaths ;;

  dimension: death_episode {
    type: number
    sql: ${TABLE}.death_episode ;;
  }

  dimension: unique_episode {
    #For joining into episodes
    type: string
    sql: CONCAT(CAST(${death_season} AS string),"-",CAST(${death_episode} AS string)) ;;
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
    label: "Manner of Death"
    type: string
    sql: ${TABLE}.execution ;;
  }

  dimension: likelihoodofreturn {
    label: "Likelihood of Return"
    type: string
    sql: ${TABLE}.likelihoodofreturn ;;
  }

  dimension: name {
    label: "Character Name"
    hidden: yes
    type: string
    sql: ${TABLE}.name ;;
    primary_key: yes
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
