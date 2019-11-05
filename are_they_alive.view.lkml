explore: are_they_alive {
  always_filter: {
    filters: {
      field: are_they_alive.name
      value: ""
    }
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
      WHEN (${is_alive} = true AND ${death} IS NOT NULL) THEN CONCAT('Yes, they survived ',LOWER(${death}),'.')
      WHEN (${is_alive} = false AND ${death} IS NOT NULL) THEN CONCAT('No, they died of ',LOWER(${death}),'.')
      WHEN ${is_alive} = true THEN 'Yes.'
      WHEN ${is_alive} = false THEN 'No.'
      ELSE 'Unsure...' END ;;
  }
}
