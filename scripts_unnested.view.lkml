view: scripts_unnested {
  derived_table: {
    sql: WITH agg AS (SELECT
      scripts.speaker  AS scripts_speaker,
      scripts.episode AS episode,
      split(REPLACE(REPLACE(LOWER(REGEXP_REPLACE(line, r'[\.\",*:()\[\]/|\n]', ' ')),'!',''),'?',''),' ') AS word
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
    hidden: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: speaker_raw {
    #Character Name. SCENEDIR for scene direction lines.
    hidden: yes
    type: string
    sql:
        CASE
          WHEN TRIM(${TABLE}.scripts_speaker) = 'SANDOR' THEN 'HOUND'
          WHEN TRIM(${TABLE}.scripts_speaker) = 'BAELISH' THEN 'LITTLEFINGER'
          WHEN TRIM(UPPER(${TABLE}.scripts_speaker)) = 'PETYR BAELISH' THEN 'LITTLEFINGER'
        ELSE UPPER(TRIM(${TABLE}.scripts_speaker))
        END;;
  }

  dimension: speaker {
    description: "Character Name who Spoke. 'SCENEDIR' for scene directions"
    type: string
    sql: SPLIT(${speaker_raw}, ' ')[SAFE_OFFSET(0)] ;;
  }

  dimension: is_stopword {
    description: "Is word a 'Stopword'? Like the,to,a,and,of,etc. Useful for filtering, or seeing who has the most vocal clutter."
    type: yesno
    sql: ${word} IN ('the','to','a','and','of','is','i','that','in','it','i', 'me', 'my', 'myself', 'we', 'our', 'ours', 'ourselves', 'you', 'your', 'yours', 'yourself', 'yourselves', 'he', 'him', 'his', 'himself', 'she', 'her', 'hers', 'herself', 'it', 'its', 'itself', 'they', 'them', 'their', 'theirs', 'themselves', 'what', 'which', 'who', 'whom', 'this', 'that', 'these', 'those', 'am', 'is', 'are', 'was', 'were', 'be', 'been', 'being', 'have', 'has', 'had', 'having', 'do', 'does', 'did', 'doing', 'a', 'an', 'the', 'and', 'but', 'if', 'or', 'because', 'as', 'until', 'while', 'of', 'at', 'by', 'for', 'with', 'about', 'against', 'between', 'into', 'through', 'during', 'before', 'after', 'above', 'below', 'to', 'from', 'up', 'down', 'in', 'out', 'on', 'off', 'over', 'under', 'again', 'further', 'then', 'once', 'here', 'there', 'when', 'where', 'why', 'how', 'all', 'any', 'both', 'each', 'few', 'more', 'most', 'other', 'some', 'such', 'no', 'nor', 'not', 'only', 'own', 'same', 'so', 'than', 'too', 'very', 's', 't', 'can', 'will', 'just', 'don', 'should', 'now') ;;
  }


  dimension: word {
    description: "The word spoken"
    type: string
    sql: ${TABLE}.a ;;
  }

  dimension: episode {
    type: string
    sql: ${TABLE}.episode ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [episode,speaker,word]
  }


}
