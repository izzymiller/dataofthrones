view: episodes {
  sql_table_name: game_of_thrones_19.episodes ;;

  dimension: pk {
    type: string
    sql: CONCAT(CAST(${season_num} AS string),"-",CAST(${episode_num} AS string),"-",${opening_sequence_locations}) ;;
    primary_key: yes
    hidden: yes
  }

  dimension: unique_episode {
    type: string
    sql: CONCAT(CAST(${season_num} AS string),"-",CAST(${episode_num} AS string)) ;;
  }

  dimension: episode_num {
    label: "Episode"
    type: number
    sql: ${TABLE}.episode_num ;;
  }

  dimension: air_date {
    description: "Original Air Date of Episode"
    type: string
    sql: ${TABLE}.air_date ;;
  }

  dimension: description {
    description: "Episode Description"
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension: link {
    description: "IMDb Link to Episode"
    type: string
    html: <a href="https://www.imdb.com/{{value}}" ;;
    sql: ${TABLE}.link ;;
  }

  dimension: opening_sequence_locations {
    description: "Locations seen in the opening title sequence"
    type: string
    sql: ${TABLE}.opening_sequence_locations ;;
    map_layer_name: major_locations
  }

  dimension: season_num {
    label: "Season"
    type: number
    sql: ${TABLE}.season_num ;;
  }

  dimension: title {
    description: "Title of Episode"
    type: string
    sql: ${TABLE}.title ;;
  }

  measure: count_episodes {
    type: count_distinct
    sql: ${unique_episode} ;;
    drill_fields: [detail*]
  }

  measure: scene_length {
    label: "Length (s)"
    description: "Total length in seconds. Same as Screentime, but not tied to Character/Scene"
    type: sum_distinct
    sql_distinct_key: ${scenes.unique_scene} ;;
    sql: ${scenes.scene_length_secs} ;;
  }


  set: detail {
    fields: [season_num,episode_num,title,description]
  }
}
