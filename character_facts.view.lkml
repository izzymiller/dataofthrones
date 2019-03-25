view: character_facts {
  derived_table: {
    sql: WITH scene_screentime AS (
    SELECT
  characters.characterName  AS character_name,
  COALESCE(ROUND(COALESCE(CAST( ( SUM(DISTINCT (CAST(ROUND(COALESCE((TIME_DIFF( scenes.scene_end,scenes.scene_start,second)) ,0)*(1/1000*1.0), 9) AS NUMERIC) + (cast(cast(concat('0x', substr(to_hex(md5(CAST(concat((CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))),"-", (CONCAT(CAST(scenes.scene_start AS string), '-', CAST(scenes.scene_end AS string))))  AS STRING))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(CAST(concat((CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))),"-", (CONCAT(CAST(scenes.scene_start AS string), '-', CAST(scenes.scene_end AS string))))  AS STRING))), 16, 8)) as int64) as numeric)) * 0.000000001 )) - SUM(DISTINCT (cast(cast(concat('0x', substr(to_hex(md5(CAST(concat((CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))),"-", (CONCAT(CAST(scenes.scene_start AS string), '-', CAST(scenes.scene_end AS string))))  AS STRING))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(CAST(concat((CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))),"-", (CONCAT(CAST(scenes.scene_start AS string), '-', CAST(scenes.scene_end AS string))))  AS STRING))), 16, 8)) as int64) as numeric)) * 0.000000001) )  / (1/1000*1.0) AS FLOAT64), 0), 6), 0) AS scene_length
FROM game_of_thrones_19.episodes  AS episodes
LEFT JOIN game_of_thrones_19.scenes  AS scenes ON (CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))) = (CONCAT(CAST(episodes.season_num AS string),"-",CAST(episodes.episode_num AS string)))
LEFT JOIN game_of_thrones_19.scenes  AS scene_characters ON (concat((CONCAT(CAST(scenes.season_num AS string), "-",CAST(scenes.episode_num AS string))),"-", (CONCAT(CAST(scenes.scene_start AS string), '-', CAST(scenes.scene_end AS string))))) = (concat((CONCAT(CAST(scene_characters.season_num AS string), "-",CAST(scene_characters.episode_num AS string))),"-", (CONCAT(CAST(scene_characters.scene_start AS string), '-', CAST(scene_characters.scene_end AS string)))))
LEFT JOIN game_of_thrones_19.characters  AS characters ON characters.characterName = scene_characters.characters_name

GROUP BY 1

),
deaths AS (
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
      ORDER BY 1),
kills AS (
WITH deaths AS (SELECT
  death_episode.character_name  AS character_name,
  death_episode.killed_by  AS death_episode_killed_by
FROM game_of_thrones_19.episodes  AS episodes
LEFT JOIN ${death_episode.SQL_TABLE_NAME} AS death_episode ON (CONCAT(CAST(episodes.season_num AS string),"-",CAST(episodes.episode_num AS string))) = death_episode.unique_episode

GROUP BY 1,2
ORDER BY 1 )
SELECT killers.characterName as killer_name,
COUNT(DISTINCT deaths.character_name) AS count_kills
FROM game_of_thrones_19.characters killers
LEFT JOIN deaths ON killers.characterName = deaths.death_episode_killed_by
GROUP BY 1
)

      SELECT
       deaths.characters_name
      ,deaths.character_death
      ,CASE WHEN deaths.character_is_alive IS NULL THEN 'Yes' ELSE 'No' END as character_is_alive
      ,characters.id
      ,characters.actorLink
      ,characters.actorName
      ,characters.characterimageFull
      ,characters.characterImageThumb
      ,characters.characterLink,
      kills.count_kills
      ,scene_screentime.scene_length AS screentime
      ,CASE
        WHEN REGEXP_CONTAINS(deaths.characters_name, 'Frey') THEN 'Frey'
        WHEN REGEXP_CONTAINS(deaths.characters_name, 'Greyjoy') THEN 'Greyjoy'
        WHEN REGEXP_CONTAINS(deaths.characters_name, 'Targaryen') THEN 'Targaryen'
        WHEN REGEXP_CONTAINS(deaths.characters_name, 'Lannister') THEN 'Lannister'
        WHEN REGEXP_CONTAINS(deaths.characters_name, 'Baratheon') THEN 'Baratheon'
        WHEN REGEXP_CONTAINS(deaths.characters_name, 'Ironborn') THEN 'Greyjoy'
        WHEN REGEXP_CONTAINS(deaths.characters_name, 'Khal') THEN 'Dothraki'
        WHEN REGEXP_CONTAINS(deaths.characters_name, 'Dothraki') THEN 'Dothraki'
        WHEN REGEXP_CONTAINS(deaths.characters_name, 'Tyrell') THEN 'Tyrell'
        WHEN REGEXP_CONTAINS(deaths.characters_name, 'Watchman') THEN 'Nights Watch'
      ELSE houses.string_field_1 END AS character_house
      ,row_number() OVER() AS key
      FROM deaths
      LEFT JOIN game_of_thrones_19.characters  AS characters ON characters.characterName = deaths.characters_name
      LEFT JOIN game_of_thrones_19.characters_houses AS houses ON deaths.characters_name = houses.string_field_0
      LEFT JOIN scene_screentime ON scene_screentime.character_name = characters.characterName
      LEFT JOIN kills ON kills.killer_name = characters.characterName
      WHERE deaths.characters_name IS NOT NULL
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,11,12
      ORDER BY 1
 ;;
sql_trigger_value: 1 ;;
  }

  dimension: id {
    hidden: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension:name {
    label: " ⁣Name"
    type: string
    sql: ${TABLE}.characters_name ;;
  }

  dimension: death {
    type: string
    sql: ${TABLE}.character_death ;;
  }

  dimension: is_alive {
    type: yesno
    sql: CASE WHEN ${TABLE}.character_is_alive = 'Yes' THEN TRUE
              WHEN ${TABLE}.characters_name = 'Jon Snow' THEN TRUE
              ELSE FALSE END;;
  }

  dimension: actor_link {
    hidden: yes
    type: string
    sql: ${TABLE}.actorLink ;;
  }

  dimension: actor_name {
    type: string
    sql: ${TABLE}.actorName ;;
  }

  dimension: image_full {
    label: "Full"
    group_label: "Images"
    type: string
    sql: ${TABLE}.characterimageFull ;;
  }

  dimension: image_thumb {
    label: "Thumbnail"
    group_label: "Images"
    type: string
    html: <img src={{value}} </img> ;;
    sql: ${TABLE}.characterImageThumb ;;
  }

  dimension: character_link {
    type: string
    sql: ${TABLE}.characterLink ;;
  }

  dimension: house {
    type: string
    sql: ${TABLE}.character_house ;;
  }

  dimension: key {
    type: number
    sql: ${TABLE}.key ;;
    hidden: yes
    primary_key: yes
  }


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: kills {
    type: sum
    sql: ${TABLE}.count_kills ;;
    drill_fields: [death_episode.character_name,death_episode.manner_of_death,death_episode.unique_episode]
  }

  measure: total_screentime {
    hidden: yes
    label: "Total Screentime"
    description: "Pre-Aggregated"
    type: sum
    sql: ${TABLE}.screentime ;;
  }

  measure: screentime_seconds {
    group_label:"screentime"
    label: "Seconds"
    description: "Total length in seconds of scenes including Character"
    type: sum_distinct
    sql_distinct_key: ${scenes.unique_scene} ;;
    sql: ${scenes.scene_length_secs} ;;
  }

  measure: screentime_minutes {
    group_label:"screentime"
    label: "Minutes"
    description: "Total length in Minutes of scenes including Character"
    type: sum_distinct
    sql_distinct_key: ${scenes.unique_scene} ;;
    sql: ${scenes.scene_length_secs} ;;
  }


  set: detail {
    fields: [
      image_thumb,
      id,
      name,
      death,
      is_alive,
      actor_name,
      character_link,
      house
    ]
  }
}
