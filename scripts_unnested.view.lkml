view: scripts_unnested {
  derived_table: {
    sql: WITH agg AS (SELECT
      scripts.speaker  AS scripts_speaker,
      scripts.episode AS episode,
      split(line,' ') AS word
    FROM game_of_thrones_19.lines  AS scripts
    WHERE scripts.speaker != 'SCENEDIR'

    )

    SELECT scripts_speaker, episode, a, GENERATE_UUID() AS id
    FROM agg
    CROSS JOIN UNNEST(agg.word) AS a ;;
  persist_for: "10000 hours"
  }

  dimension: pk {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: speaker {
    type: string
    sql: ${TABLE}.scripts_speaker ;;
  }


  dimension: word {
    type: string
    sql: ${TABLE}.a ;;
  }

  dimension: episode {
    type: string
    sql: ${TABLE}.episode ;;
  }

  measure: count {
    type: count
  }


}
