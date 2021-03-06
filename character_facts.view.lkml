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
      ,SPLIT(UPPER(characters.characterName),' ')[SAFE_OFFSET(0)] AS firstname
      ,characters.characterLink
      ,characters.species
      ,CASE WHEN gender.gender = "male" THEN "Male" WHEN gender.gender = "female" THEN "Female" END AS gender
      ,kills.count_kills
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
      ELSE characters.houseName END AS character_house
      ,row_number() OVER() AS keyz
      FROM deaths
      LEFT JOIN game_of_thrones_19.characters  AS characters ON characters.characterName = deaths.characters_name
      LEFT JOIN game_of_thrones_19.char_gender AS gender ON gender.character_name = characters.characterName
      LEFT JOIN scene_screentime ON scene_screentime.character_name = characters.characterName
      LEFT JOIN kills ON kills.killer_name = characters.characterName
      WHERE deaths.characters_name IS NOT NULL
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,11,12,13,14,15
      ORDER BY 1
 ;;

sql_trigger_value: 2 ;;
  }

  dimension: id {
    hidden: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: name {
    label: "⁣Name"
    description: "Character Name"
    type: string
    sql: ${TABLE}.characters_name  ;;
  }
  dimension: firstname {
    type: string
    hidden: yes
    #for joining
    sql: ${TABLE}.firstname ;;
  }

  dimension: species {
    description: "Species of Character, assumed to be human if not clear."
    type: string
    sql: CASE WHEN ${TABLE}.species IS NULL THEN 'Human' ELSE ${TABLE}.species END ;;
  }

  dimension: death {
    description: "Manner of Death. Null if alive."
    type: string
    sql: ${TABLE}.character_death ;;
  }

  dimension: is_alive {
    description: "Is the character alive?"
    type: yesno
    sql: CASE WHEN ${TABLE}.character_is_alive = 'Yes' THEN TRUE
              WHEN ${TABLE}.characters_name = 'Jon Snow' THEN TRUE
              ELSE FALSE END;;
  }

  dimension: gender {
    type: string
    label: "Gender"
    description: "Gender of Character. Only populated for main characters!"
    sql: COALESCE(${TABLE}.gender,"Unspecified") ;;
  }

  dimension: has_killed {
    description: "Has the character killed anyone?"
    type: yesno
    sql: ${TABLE}.count_kills > 0 ;;
  }

  dimension: actor_link {
    hidden: yes
    type: string
    sql: ${TABLE}.actorLink ;;
  }

  dimension: actor_name {
    description: "Name of primary actor"
    type: string
    sql: ${TABLE}.actorName ;;
  }

  dimension: image_full {
    label: "Full Image"
    group_label: "Images"
    type: string
    html: <img src={{value}} </img> ;;
    sql: ${TABLE}.characterimageFull ;;
  }

  dimension: image_thumb {
    label: "Thumbnail Image"
    group_label: "Images"
    type: string
    html: <img src={{value}} </img> ;;
    sql: ${TABLE}.characterImageThumb ;;
  }

  dimension: character_link {
    hidden: yes
    description: "This links out to IMDb but I can't figure out exactly how to format the URL."
    type: string
    sql: ${TABLE}.characterLink ;;
  }

  dimension: house_derived {
    hidden: yes
    type: string
    sql:
      CASE
        WHEN ${name} = 'Jorah Mormont' THEN 'Mormont'
        WHEN ${name} = 'Samwell Tarly' THEN 'Tarly'
        WHEN ${name} = 'Brienne of Tarth' THEN 'Tarth'
        WHEN ${name} = 'Davos Seaworth' THEN 'Seaworth'
        WHEN ${name} = 'Petyr Baelish' THEN 'Baelish'
        WHEN ${name} = 'Sandor Clegane' THEN 'Clegane'
        WHEN ${name} = 'Barristan Selmy' THEN 'Selmy'
        WHEN ${name} = 'Ramsay Snow' THEN 'Bolton'
        WHEN ${name} = 'Gendry' THEN 'Baratheon'
        WHEN ${name} = 'Gregor Clegane' THEN 'Clegane'
        WHEN ${name} = 'Meera Reed' THEN 'Reed'
        WHEN ${name} = 'Roose Bolton' THEN 'Bolton'
        WHEN ${name} = 'Randyll Tarly' THEN 'Tarly'
        WHEN ${name} = 'Dickon Tarly' THEN 'Tarly'
      ELSE ${TABLE}.character_house
      END ;;
  }

  dimension: house {
    description: "Characters House. None if unclear."
    type: string
    sql:
      CASE
        WHEN TRIM(${house_derived}) = 'Include' THEN 'None'
        WHEN TRIM(${house_derived}) IS NULL THEN 'None'
      ELSE ${house_derived}
      END ;;
  }

  dimension: current_alliance {
    description: "Group currently allied with"
    type: string
    sql:
      CASE
        WHEN REGEXP_CONTAINS(${name}, 'Targaryen') THEN 'Targaryen'
        WHEN REGEXP_CONTAINS(${name}, 'Dothraki') THEN 'Targaryen'
        WHEN ${name} = 'Tyrion Lannister' THEN 'Targaryen'
        WHEN ${name} = 'Jorah Mormont' THEN 'Targaryen'
        WHEN ${name} = 'Lord Varys' THEN 'Targaryen'
        WHEN ${name} = 'Sandor Clegane' THEN 'Targaryen'
        WHEN ${name} = 'Missandei' THEN 'Targaryen'
        WHEN ${name} = 'Grey Worm' THEN 'Targaryen'
        WHEN ${name} = 'Drogon' THEN 'Targaryen'
        WHEN ${name} = 'Qhono' THEN 'Targaryen'
        WHEN ${name} = 'Unsullied' THEN 'Targaryen'
        WHEN ${name} = 'Illyrio Mopatis' THEN 'Targaryen'
        WHEN REGEXP_CONTAINS(${name}, 'Martell') THEN 'Targaryen'
        WHEN REGEXP_CONTAINS(${name}, 'Sand') THEN 'Targaryen'
        WHEN ${name} = 'Aeron Greyjoy' THEN 'Lannister'
        WHEN REGEXP_CONTAINS(${name}, 'Greyjoy') THEN 'Targaryen'
        WHEN REGEXP_CONTAINS(${name}, 'Lannister') THEN 'Lannister'
        WHEN REGEXP_CONTAINS(${name}, 'Frey') THEN 'Lannister'
        WHEN REGEXP_CONTAINS(${name}, 'Ironborn') THEN 'Lannister'
        WHEN ${name} = 'Bronn' THEN 'Lannister'
        WHEN ${name} = 'Gregor Clegane' THEN 'Lannister'
        WHEN ${name} = 'Qyburn' THEN 'Lannister'
        WHEN ${name} = 'Ilyn Payne' THEN 'Lannister'
        WHEN ${name} = 'Samwell Tarly' THEN 'Stark'
        WHEN REGEXP_CONTAINS(${name}, 'Tarly') THEN 'Lannister'
        WHEN REGEXP_CONTAINS(${name}, 'Stark') THEN 'Stark'
        WHEN REGEXP_CONTAINS(${name}, 'Mormont') THEN 'Stark'
        WHEN REGEXP_CONTAINS(${name}, 'Umber') THEN 'Stark'
        WHEN REGEXP_CONTAINS(${name}, 'Tully') THEN 'Stark'
        WHEN REGEXP_CONTAINS(${name}, 'Karstark') THEN 'Stark'
        WHEN REGEXP_CONTAINS(${name}, 'Reed') THEN 'Stark'
        WHEN REGEXP_CONTAINS(${name}, 'Watch') THEN 'Stark'
        WHEN ${name} = 'Jon Snow' THEN 'Stark'
        WHEN ${name} = 'Ghost' THEN 'Stark'
        WHEN ${name} = 'Davos Seaworth' THEN 'Stark'
        WHEN ${name} = 'Tormund Giantsbane' THEN 'Stark'
        WHEN ${name} = 'Yohn Royce' THEN 'Stark'
        WHEN ${name} = 'Robin Arryn' THEN 'Stark'
        WHEN ${name} = 'Brienne of Tarth' THEN 'Stark'
        WHEN ${name} = 'Podrick Payne' THEN 'Stark'
        WHEN ${name} = 'Eddison Tollett' THEN 'Stark'
        WHEN ${name} = 'Gendry' THEN 'Stark'
        WHEN ${name} = 'Gilly' THEN 'Stark'
        WHEN ${name} = 'Robett Glover' THEN 'Stark'
        WHEN REGEXP_CONTAINS(${name}, 'Wight') THEN 'White Walkers'
        WHEN ${name} = 'The Night King' THEN 'White Walkers'
        WHEN ${name} = 'Rhaegal' THEN 'White Walkers'


      ELSE 'None'
      END ;;
  }

  dimension: key {
    type: number
    sql: ${TABLE}.keyz ;;
    hidden: yes
    primary_key: yes
  }


  measure: count {
    label: "Number of Characters"
    type: count
    drill_fields: [detail*]
  }

  measure: count_house {
    label: "Number of Houses"
    type: count_distinct
    sql: ${house} ;;
    drill_fields: [detail*]
  }

  measure: kills {
    description: "Number of named kills made"
    type: sum
    sql: ${TABLE}.count_kills ;;
#     drill_fields: [death_episode.character_name,death_episode.manner_of_death,death_episode.unique_episode]
  }

   measure: total_screentime {
     hidden: no
     label: "Total Screentime"
     description: "Pre-Aggregated. Not as good as the other ones"
     type: sum
     sql: ${TABLE}.screentime ;;
   }

  measure: screentime_seconds {
    group_label:"Screentime"
    label: "Screentime (Seconds)"
    description: "Total length in seconds of scenes including Character.
    Not just their moments on screen, so slightly inflated from their genuine, precise, screen time"
    type: sum_distinct
    sql_distinct_key: ${scenes.unique_scene} ;;
    sql: ${scenes.scene_length_secs} ;;
    drill_fields: [detail*]
  }

  measure: screentime_minutes {
    group_label:"Screentime"
    label: "Screentime (Minutes)"
    description: "Total length in Minutes of scenes including Character.
    Not just their moments on screen, so slightly inflated from their genuine, precise, screen time"
    type: sum_distinct
    sql_distinct_key: ${scenes.unique_scene} ;;
    sql: ${scenes.scene_length_secs}/60 ;;
    value_format_name: decimal_0
    drill_fields: [detail*]
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
