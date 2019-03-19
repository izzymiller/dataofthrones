view: death_episode {
  derived_table: {
    sql: SELECT
  CONCAT(CAST(episodes.season_num AS string),"-",CAST(episodes.episode_num AS string))  AS unique_episode,
  characters.characterName  AS character_name,
  scene_characters.characters_killed_by  AS killed_by,
  scene_characters.characters_manner_of_death  AS manner_of_death,
  CONCAT(CAST(scene_characters.scene_start AS string), '-', CAST(scene_characters.scene_end AS string))  AS scene_id
FROM game_of_thrones_19.episodes  AS episodes
LEFT JOIN game_of_thrones_19.scenes  AS scenes ON (CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))) = (CONCAT(CAST(episodes.season_num AS string),"-",CAST(episodes.episode_num AS string)))
LEFT JOIN game_of_thrones_19.scenes  AS scene_characters ON (concat((CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))),"-", (CONCAT(CAST(scenes.scene_start AS string), '-', CAST(scenes.scene_end AS string))))) = (concat((CONCAT(CAST(scene_characters.season_num AS string), "-",CAST(scene_characters.episode_num AS string))),"-", (CONCAT(CAST(scene_characters.scene_start AS string), '-', CAST(scene_characters.scene_end AS string)))))
LEFT JOIN game_of_thrones_19.characters  AS characters ON characters.characterName = scene_characters.characters_name

WHERE
  ((scene_characters.characters_manner_of_death IS NOT NULL))
GROUP BY 1,2,3,4,5
 ;;
sql_trigger_value: SELECT 1 ;;
  }

  dimension: pk {
    type: string
    hidden: yes
    sql: CONCAT(COALESCE(${unique_episode},'blank'),COALESCE(${character_name},'blank'),COALESCE(${killed_by},'blank'),COALESCE(${manner_of_death},'blank'),COALESCE(${scene_id},'blank')) ;;
    primary_key: yes
  }

  dimension: unique_episode {
    type: string
    sql: ${TABLE}.unique_episode ;;
  }

  dimension: character_name {
    type: string
    sql: ${TABLE}.character_name ;;
  }

  dimension: killed_by {
    type: string
    sql: ${TABLE}.killed_by ;;
  }

  dimension: scene_id {
    type: string
    sql: ${TABLE}.scene_id ;;
  }

  dimension: manner_of_death {
    type: string
    sql: ${TABLE}.manner_of_death ;;
  }


  measure: count_deaths {
    type: count_distinct
    label: "Count Deaths"
    sql: ${pk} ;;
  }

  measure: count_kills {
    type: count_distinct
    label: "Count Kills"
    sql: CASE WHEN ${killed_by} = ${character_name} THEN ${pk} ELSE NULL END ;;
  }

}
