connection: "lookerdata_publicdata_standard_sql"

include: "*.view.lkml"                       # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

#
# map_layer: lands_of_ice_and_fire {
#   file: "ice_and_fire.topojson"
#   property_key: "id"
# }

map_layer: got_geo {
  file: "newmerged.topojson"
}


explore: characters {

  join: deaths {
    type: left_outer
    relationship: one_to_one
    sql_on: ${deaths.name} = ${characters.character_name} ;;
  }

  join: screentimes_2 {
    type: left_outer
    relationship: one_to_one
    sql_on: ${screentimes_2.name} = ${characters.character_name} ;;
  }

}


explore: episodes {
  join: scenes {
    type: left_outer
    relationship: many_to_many
    sql_on: ${scenes.unique_ep} = ${episodes.unique_episode} ;;
  }

  join: scene_characters {
    relationship: one_to_many
    view_label: "Scene Actions"
    type: left_outer
    sql_on: ${scenes.pk} = ${scene_characters.pk} ;;
  }

  join: characters {
    relationship: many_to_one
    view_label: "Characters"
    type: left_outer
    sql_on: ${characters.character_name} = ${scene_characters.characters_name} ;;
  }

#   join: opening_locations {
#     view_label: "Location"
#     fields: [opening_locations.name]
#     relationship: many_to_many
#     type: left_outer
#     sql_on: ${opening_locations.name} = ${episodes.opening_sequence_locations} ;;
#   }
#   join: locations {
#     view_label: "Location"
#
#     fields: [locations.sub_location,locations.location,opening_locations.note]
#     relationship: one_to_one
#     type: left_outer
#     sql_on: ${locations.sub_location} = ${scenes.sub_location} ;;
#   }
}


# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
# explore: order_items {
#   join: orders {
#     relationship: many_to_one
#     sql_on: ${orders.id} = ${order_items.order_id} ;;
#   }
#
#   join: users {
#     relationship: many_to_one
#     sql_on: ${users.id} = ${orders.user_id} ;;
#   }
# }
