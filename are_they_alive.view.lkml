explore: are_they_alive {
  always_filter: {
    filters: {
      field: are_they_alive.name
      value: ""
    }
  }
  join: who_killed {
    relationship: one_to_one
    sql_on: ${are_they_alive.name} = ${who_killed.name} ;;
  }
}

include: "dataofthrones.model.lkml"

view: are_they_alive {
  derived_table: {
    explore_source: characters {
      column: name { field: character_facts.name }
      column: is_alive { field: character_facts.is_alive }
      column: death { field: character_facts.death }
      column: house {field: character_facts.house}
    }
  }
  dimension: name {
    label: "Characters ⁣Name"
    description: "Character Name"
    case_sensitive: no
  }
  dimension: is_alive {
    label: "Characters Is Alive"
    description: "Is the character alive?"
    type: yesno
  }
  dimension: death {
    label: "Manner of Death"
  }
  dimension: house {
    label: "House Name"
  }
  dimension: what_happened{
    label: "Character's Fate"
    sql: CASE
      WHEN ${who_killed.killed_by} IS NULL THEN (
        CASE
        WHEN (${is_alive} = true AND ${death} IS NOT NULL) THEN CONCAT('Yes, they survived ',LOWER(${death}),'.')
        WHEN (${is_alive} = false AND ${death} IS NOT NULL) THEN CONCAT('No, they died of ',LOWER(${death}),'.')
        WHEN ${is_alive} = true THEN 'Yes.'
        WHEN ${is_alive} = false THEN 'No.'
        ELSE 'Unsure...' END)
      WHEN ${who_killed.killed_by} IS NOT NULL THEN (
        CASE
        WHEN (${is_alive} = true AND ${death} IS NOT NULL) THEN CONCAT('Yes, they survived ',LOWER(${death}),' from ',${who_killed.killed_by},'.')
        WHEN (${is_alive} = false AND ${death} IS NOT NULL) THEN CONCAT('No, they died of ',LOWER(${death}),' from ',${who_killed.killed_by},'.')
        WHEN ${is_alive} = true THEN 'Yes.'
        WHEN ${is_alive} = false THEN 'No.'
        ELSE 'Unsure...' END) ELSE NULL END ;;
  }
  dimension: death_image {
    type: string
    sql: CASE
      WHEN ${death} IN ('Flayed','Back stab','Chest stab','Eye stab','Face stab','Multiple stabs','Neck stab','Stab','Throat stab','Throat slash') THEN 'https://i.ibb.co/ftr8FZs/knife.jpg'
      WHEN ${death} IN ('Arrow') THEN 'https://i.ibb.co/9tHXzs5/bow-and-arrow-clip-art-cartoon-vector-1522404.jpg'
      WHEN ${death} IN ('Burning','Burning,Back stab,Chest stab,Chest stab','Wildfire','Molten gold') THEN 'https://i.ibb.co/SdLfznG/fire.jpg'
      WHEN ${death} IN ('Mauling') THEN 'https://i.ibb.co/9NLs70P/mauling.jpg'
      WHEN ${death} IN ('Beaten','Giant','Head crush') THEN 'https://i.ibb.co/vZnyrkq/fist.png'
      WHEN ${death} IN ('Hanging') THEN 'https://i.ibb.co/kXqZGdG/noose.jpg'
      WHEN ${death} IN ('Decapitation') THEN 'https://i.ibb.co/LdSpCH5/decapitation.jpg'
      ELSE 'https://i.ibb.co/Nx1WwC6/nope.png' END ;;
   html: <img src="{{ value }}" width="100" /> ;;
  }
}


# Arrow
# Back stab
# Beaten
# Boar
# Burning
# Burning,Back stab,Chest stab,Chest stab
# Chest stab
# Choking
# Decapitation
# Door
# Drowning
# Eye stab
# Face stab
# Falling
# Frozen
# Giant
# Gutted
# Hanging
# Head crush
# Horse
# Malformed Birth
# Mauling
# Molten gold
# Moon Door
# Multiple stabs
# Multiple stabs,Burning
# Neck snap
# Neck stab
# Old age
# Poison
# Poison dart
# Safe
# Shadow baby
# Stab
# Suffocation
# Throat slash
# Throat stab
# Tongue removal
# Torn apart
# Wight children
# Wildfire


view: who_killed {
  derived_table: {
    explore_source: episodes {
      column: killed_by { field: death_episode.killed_by }
      column: name { field: character_facts.name }
      filters: {
        field: death_episode.killed_by
        value: "-NULL"
      }
    }
  }
  dimension: killed_by {
    label: "Deaths Killed By"
  }
  dimension: name {
    label: "Characters ⁣Name"
    description: "Character Name"
  }
}
