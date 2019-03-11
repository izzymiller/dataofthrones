view: character_facts {
  derived_table: {
    sql: WITH deaths AS (
      SELECT
        scene_characters.characters_name  AS characters_name,
        scene_characters.characters_manner_of_death  AS scene_characters_characters_manner_of_death,
        scene_characters.characters_alive  AS scene_characters_characters_alive,
        STRING_AGG(scene_characters.characters_manner_of_death) OVER (PARTITION BY scene_characters.characters_name) AS character_death,
        STRING_AGG(CAST(scene_characters.characters_alive AS STRING)) OVER (PARTITION BY scene_characters.characters_name) AS character_is_alive

      FROM game_of_thrones_19.episodes  AS episodes
      LEFT JOIN game_of_thrones_19.scenes  AS scenes ON (CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))) = (CONCAT(CAST(episodes.season_num AS string),"-",CAST(episodes.episode_num AS string)))
      LEFT JOIN game_of_thrones_19.scenes  AS scene_characters ON (concat((CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))),"-", (CONCAT(CAST(scenes.scene_start AS string), '-', CAST(scenes.scene_end AS string))))) = (concat((CONCAT(CAST(scene_characters.season_num AS string), "-",CAST(scene_characters.episode_num AS string))),"-", (CONCAT(CAST(scene_characters.scene_start AS string), '-', CAST(scene_characters.scene_end AS string)))))

      GROUP BY 1,2,3
      ORDER BY 1)
      SELECT
       deaths.characters_name
      ,deaths.character_death
      ,CASE WHEN deaths.character_is_alive IS NULL THEN 'Yes' ELSE 'No' END as character_is_alive
      ,characters.id
      ,characters.actorLink
      ,characters.actorName
      ,characters.characterimageFull
      ,characters.characterImageThumb
      ,characters.characterLink
      ,row_number() OVER() AS key
      FROM deaths
      LEFT JOIN game_of_thrones_19.characters  AS characters ON characters.characterName = deaths.characters_name
      WHERE deaths.characters_name IS NOT NULL
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
      ORDER BY 1
       ;;
  }

  dimension: key {
    hidden: yes
    type: number
    sql: ${TABLE}.key ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: characters_name {
    type: string
    sql: ${TABLE}.characters_name ;;
  }

  dimension: character_death {
    type: string
    sql: ${TABLE}.character_death ;;
  }

  dimension: character_is_alive {
    type: string
    sql: ${TABLE}.character_is_alive ;;
  }

  dimension: id {
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: actor_link {
    type: string
    sql: ${TABLE}.actorLink ;;
  }

  dimension: actor_name {
    type: string
    sql: ${TABLE}.actorName ;;
  }

  dimension: characterimage_full {
    type: string
    sql: ${TABLE}.characterimageFull ;;
  }

  dimension: character_image_thumb {
    type: string
    sql: ${TABLE}.characterImageThumb ;;
  }

  dimension: character_link {
    type: string
    sql: ${TABLE}.characterLink ;;
  }

  set: detail {
    fields: [
      characters_name,
      character_death,
      character_is_alive,
      id,
      actor_link,
      actor_name,
      characterimage_full,
      character_image_thumb,
      character_link
    ]
  }
}
