view: sex_episode {
  derived_table: {
    sql: SELECT
  CONCAT(CAST(episodes.season_num AS string),"-",CAST(episodes.episode_num AS string))  AS unique_episode,
  characters.characterName  AS character_name,
  scene_characters.characters_sex_with  AS sex_with,
  CONCAT(CAST(scenes.scene_start AS string), '-', CAST(scenes.scene_end AS string))  AS scene_id,
  scene_characters.characters_sex_type  AS sex_type,
  scene_characters.characters_sex_when  AS sex_when
FROM game_of_thrones_19.episodes  AS episodes
LEFT JOIN game_of_thrones_19.scenes  AS scenes ON (CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))) = (CONCAT(CAST(episodes.season_num AS string),"-",CAST(episodes.episode_num AS string)))
LEFT JOIN game_of_thrones_19.scenes  AS scene_characters ON (concat((CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))),"-", (CONCAT(CAST(scenes.scene_start AS string), '-', CAST(scenes.scene_end AS string))))) = (concat((CONCAT(CAST(scene_characters.season_num AS string), "-",CAST(scene_characters.episode_num AS string))),"-", (CONCAT(CAST(scene_characters.scene_start AS string), '-', CAST(scene_characters.scene_end AS string)))))
LEFT JOIN game_of_thrones_19.characters  AS characters ON characters.characterName = scene_characters.characters_name

WHERE
  ((scene_characters.characters_sex_with IS NOT NULL))
GROUP BY 1,2,3,4,5,6
 ;;
sql_trigger_value: SELECT 1 ;;
  }

  dimension: pk {
    type: string
    hidden: yes
    sql: concat(${unique_episode},${character_name},${sex_with},${scene_id}) ;;
    primary_key: yes
  }

  dimension: unique_episode {
    type: string
    sql: ${TABLE}.unique_episode ;;
  }

  dimension: character_name {
    hidden: no
    type: string
    sql: ${TABLE}.character_name ;;
  }

  dimension: sex_with {
    type: string
    sql: ${TABLE}.sex_with ;;
  }

  dimension: sex_type {
    type: string
    sql: ${TABLE}.sex_type ;;
  }

  dimension: sex_when {
    type: string
    sql: ${TABLE}.sex_when ;;
  }

  dimension: scene_id {
    type: string
    sql: ${TABLE}.scene_id ;;
  }

  measure: count_sex {
    type: count_distinct
    sql: ${pk} ;;
  }


}
