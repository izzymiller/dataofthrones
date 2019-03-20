view: characters {
  sql_table_name: game_of_thrones_19.characters ;;

  dimension: abducted {
    group_label: "Relationships"
    type: string
    sql: ${TABLE}.abducted ;;
  }

  dimension: abducted_by {
    group_label: "Relationships"
    type: string
    sql: ${TABLE}.abductedBy ;;
  }

  dimension: actor_link {
    #IMDB actor link. Could join in other stuff from imdb dataset
    type: string
    sql: ${TABLE}.actorLink ;;
    hidden: yes
  }

  dimension: actor_name {
    hidden: yes
    #Does not contain everything
    type: string
    sql: ${TABLE}.actorName ;;
  }

  dimension: actors {
    hidden: yes
    type: string
    sql: ${TABLE}.actors ;;
  }

  dimension: allies {
    group_label: "Relationships"
    type: string
    sql: ${TABLE}.allies ;;
  }

  dimension: character_image_full {
    hidden: yes
    group_label: "Images"
    label: "Full"
    type: string
    html: <img src={{value}} </img> ;;
    sql: ${TABLE}.characterImageFull ;;
  }

  dimension: character_image_thumb {
    hidden: yes
    group_label: "Images"
    label: "Thumbnail"
    type: string
    html: <img src={{value}} </img> ;;
    sql: ${TABLE}.characterImageThumb ;;
  }

  dimension: character_link {
    #IMDB char link
    hidden: yes
    type: string
    sql: ${TABLE}.characterLink ;;
  }

  dimension: character_name {
    hidden: yes
    type: string
    sql: ${TABLE}.characterName ;;
  }

  dimension: guarded_by {
    group_label: "Relationships"
    type: string
    sql: ${TABLE}.guardedBy ;;
  }

  dimension: guardian_of {
    group_label: "Relationships"
    type: string
    sql: ${TABLE}.guardianOf ;;
  }

  dimension: house_name {
    hidden: yes
    #Small. Need to sync with characters_house?
    type: string
    sql: ${TABLE}.houseName ;;
  }

  dimension: int64_field_0 {
    #id
    hidden: yes
    type: number
    sql: ${TABLE}.int64_field_0 ;;
  }

  dimension: killed {
    group_label: "Relationships"
    hidden: yes
    type: string
    sql: ${TABLE}.killed ;;
  }

  dimension: killed_by {
    group_label: "Relationships"
    hidden: yes
    type: string
    sql: ${TABLE}.killedBy ;;
  }

  dimension: kingsguard {
    type: yesno
    sql: ${TABLE}.kingsguard ;;
  }

  dimension: married_engaged {
    group_label: "Relationships"
    type: string
    sql: ${TABLE}.marriedEngaged ;;
  }

  dimension: nickname {
    type: string
    sql: ${TABLE}.nickname ;;
  }

  dimension: parent_of {
    group_label: "Relationships"
    type: string
    sql: ${TABLE}.parentOf ;;
  }

  dimension: parents {
    group_label: "Relationships"
    type: string
    sql: ${TABLE}.parents ;;
  }

  dimension: royal {
    type: yesno
    sql: ${TABLE}.royal ;;
  }

  dimension: served_by {
    group_label: "Relationships"
    type: string
    sql: ${TABLE}.servedBy ;;
  }

  dimension: serves {
    group_label: "Relationships"
    type: string
    sql: ${TABLE}.serves ;;
  }

  dimension: sibling {
    group_label: "Relationships"
    type: string
    sql: ${TABLE}.sibling ;;
  }

  dimension: siblings {
    group_label: "Relationships"
    type: string
    sql: ${TABLE}.siblings ;;
  }

  measure: count {
    hidden: yes
    type: count_distinct
    sql: ${character_name} ;;
  }
}
