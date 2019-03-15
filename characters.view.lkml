explore: char_old {
  view_name: characters
}

view: characters {
  sql_table_name: game_of_thrones_19.characters ;;

  dimension: abducted {
    type: string
    sql: ${TABLE}.abducted ;;
  }

  dimension: abducted_by {
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
    #Does not contain everything
    type: string
    sql: ${TABLE}.actorName ;;
  }

  dimension: actors {
    type: string
    sql: ${TABLE}.actors ;;
  }

  dimension: allies {
    type: string
    sql: ${TABLE}.allies ;;
  }

  dimension: character_image_full {
    group_label: "Images"
    label: "Full"
    type: string
    html: <img src={{value}} </img> ;;
    sql: ${TABLE}.characterImageFull ;;
  }

  dimension: character_image_thumb {
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
    type: string
    sql: ${TABLE}.characterName ;;
  }

  dimension: guarded_by {
    type: string
    sql: ${TABLE}.guardedBy ;;
  }

  dimension: guardian_of {
    type: string
    sql: ${TABLE}.guardianOf ;;
  }

  dimension: house_name {
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
    type: string
    sql: ${TABLE}.killed ;;
  }

  dimension: killed_by {
    type: string
    sql: ${TABLE}.killedBy ;;
  }

  dimension: kingsguard {
    type: yesno
    sql: ${TABLE}.kingsguard ;;
  }

  dimension: married_engaged {
    type: string
    sql: ${TABLE}.marriedEngaged ;;
  }

  dimension: nickname {
    type: string
    sql: ${TABLE}.nickname ;;
  }

  dimension: parent_of {
    type: string
    sql: ${TABLE}.parentOf ;;
  }

  dimension: parents {
    type: string
    sql: ${TABLE}.parents ;;
  }

  dimension: royal {
    type: yesno
    sql: ${TABLE}.royal ;;
  }

  dimension: served_by {
    type: string
    sql: ${TABLE}.servedBy ;;
  }

  dimension: serves {
    type: string
    sql: ${TABLE}.serves ;;
  }

  dimension: sibling {
    type: string
    sql: ${TABLE}.sibling ;;
  }

  dimension: siblings {
    type: string
    sql: ${TABLE}.siblings ;;
  }

  measure: count {
    type: count_distinct
    sql: ${character_name} ;;
  }
}
