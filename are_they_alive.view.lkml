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
    }
  }
  dimension: name {
    label: "Characters ⁣Name"
    description: "Character Name"
  }
  dimension: is_alive {
    label: "Characters Is Alive"
    description: "Is the character alive?"
    type: yesno
  }
}
