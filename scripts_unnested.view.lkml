view: scripts_unnested {
  sql_table_name: game_of_thrones_19.script_by_word ;;
#   derived_table: {
#     sql: WITH agg AS (SELECT
#       scripts.speaker  AS scripts_speaker,
#       scripts.episode AS episode,
#       split(REPLACE(REPLACE(LOWER(REGEXP_REPLACE(line, r'[\.\",*:()\[\]/|\n]', ' ')),'!',''),'?',''),' ') AS word
#     FROM game_of_thrones_19.lines  AS scripts
#     WHERE scripts.speaker != 'SCENEDIR'
#
#     )
#
#     SELECT scripts_speaker, episode, a, GENERATE_UUID() AS id
#     FROM agg
#     CROSS JOIN UNNEST(agg.word) AS a ;;
# #   persist_for: "10000 hours"
#   }

  dimension: pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.scripts_unnested_pk ;;
  }

#   dimension: speaker_raw {
#     #Character Name. SCENEDIR for scene direction lines.
#     hidden: yes
#     type: string
#     sql:
#         CASE
#           WHEN TRIM(${TABLE}.scripts_speaker) = 'SANDOR' THEN 'HOUND'
#           WHEN TRIM(${TABLE}.scripts_speaker) = 'BAELISH' THEN 'LITTLEFINGER'
#           WHEN TRIM(UPPER(${TABLE}.scripts_speaker)) = 'PETYR BAELISH' THEN 'LITTLEFINGER'
#         ELSE UPPER(TRIM(${TABLE}.scripts_speaker))
#         END;;
#   }

  dimension: speaker {
    description: "Character Name who Spoke. 'SCENEDIR' for scene directions"
    type: string
    sql: ${TABLE}.scripts_unnested_speaker ;;
  }

  dimension: is_stopword {
    description: "Is word a 'Stopword'? Like the,to,a,and,of,etc. Useful for filtering, or seeing who has the most vocal clutter."
    type: yesno
    sql: ${TABLE}.scripts_unnested_is_stopword = 'Yes' ;;
    }


  dimension: word {
    description: "The word spoken"
    type: string
    sql: ${TABLE}.scripts_unnested_word ;;
  }

  dimension: episode {
    type: string
    sql: ${TABLE}.scripts_unnested_episode ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [episode,speaker,word]
  }


}
