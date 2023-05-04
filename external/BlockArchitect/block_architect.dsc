BlockArchitect_handler:
    type: world
    data:
        max-blocks-per-chunk: 1000
    debug: false
    events:
        on player places item_flagged:custom_block:
        - define location <context.location>
        - if <[location].chunk.entities[custom_block].size> > <static[<script[BlockArchitect_handler].data_key[data.max-blocks-per-chunk]>]>:
            - determine cancelled
        - inject BlockArchitect_create_custom_block
        on player breaks block location_flagged:custom_block:
        - define script <context.location.flag[custom_block.entity].item.script>
        - define data <[script].parsed_key[data.custom_block].if_null[null]>
        - if <[data]> == null:
            - run BlockArchitect_remove_custom_block def.location:<context.location>
            - stop
        - determine <[data].proc[BA_match_item].context[<list_single[<player.item_in_hand>].include[<[script]>]>]> passively
        - run BlockArchitect_remove_custom_block def.location:<context.location>
        on block destroyed by explosion location_flagged:custom_block:
        - run BlockArchitect_remove_custom_block def.location:<context.location>
        on piston extends:
        - if <context.blocks.filter[has_flag[custom_block]].any>:
            - determine cancelled
        on piston retracts:
        - if <context.blocks.filter[has_flag[custom_block]].any>:
            - determine cancelled
        on block burns location_flagged:custom_block:
        - if <context.location.flag[custom_block.burn].if_null[false]>:
            - run BlockArchitect_remove_custom_block def.location:<context.location>
        - else:
            - determine cancelled
BA_match_item:
    type: procedure
    debug: false
    definitions: data|hand|script
    script:
    - foreach <[data.item].if_null[<player.item_in_hand.material.name>]> as:matcher:
        - if <player.item_in_hand> matches <[matcher]>:
            - determine <[data.drops].if_null[<[script].name.as[item]>]>
    - determine nothing
BlockArchitect_create_custom_block:
    type: task
    debug: false
    definitions: location
    script:
    - define data <script[BlockArchitect_custom_block].data_key[mechanisms.display_entity_data]>
    - spawn BlockArchitect_custom_block[item=<player.item_in_hand.with[quantity=1]>;display_entity_data=<[data].include[brightness_sky=<[location].light.sky>;brightness_block=<[location].light.blocks>]>] <[location].center> save:custom
    - flag <[location]> custom_block.entity:<entry[custom].spawned_entity>
    - flag <[location]> custom_block.flood_fill:<[location].flood_fill[1].types[block]>
    - flag <[location].world> custom_blocks:->:<[location]>
BlockArchitect_remove_custom_block:
    type: task
    debug: false
    definitions: location
    script:
    - remove <[location].flag[custom_block.entity]>
    - flag <[location]> custom_block:!
    - flag <[location].world> custom_blocks:<-:<[location]>
BlockArchitect_custom_block_powered_event:
    type: event
    debug: false
    events:
        on noteblock plays note location_flagged:custom_block:
        - define script <context.location.flag[custom_block.entity].item.script>
        - define data <[script].parsed_key[data.custom_block].if_null[null]>
        - determine cancelled if:<[data].get[powerable].if_null[false].not>
        - determine passively cancelled
        - inject <[script]> path:data.custom_block.on_powered if:<[data].deep_get[custom_block.on_powered].exists>
BlockArchitect_light_engine:
    type: world
    debug: false
    events:
        after weather changes in world_flagged:custom_blocks:
        - foreach <context.world.flag[custom_blocks]> as:location:
            - if <[loop_index]> == 50:
                - wait 1t
            - if <[location].chunk.is_loaded>:
                - define entity <[location].flag[custom_block.entity].if_null[null]>
                - if <[entity]> == null:
                    - foreach next
                - define entities:++
                - inject BlockArchitect_reapply_light_time
        - debug log "Updated <[entities]> entities in <queue.time_ran.in_milliseconds>ms (avg:<queue.time_ran.in_milliseconds.div[<[entities]>].round_to[2]>ms)"
        after time changes in world_flagged:custom_blocks:
        - foreach <context.world.flag[custom_blocks]> as:location:
            - if <[loop_index]> == 50:
                - wait 1t
            - if <[location].chunk.is_loaded>:
                - define entity <[location].flag[custom_block.entity].if_null[null]>
                - if <[entity]> == null:
                    - foreach next
                - define entities:++
                - inject BlockArchitect_reapply_light_time
        - debug log "Updated <[entities]> entities in <queue.time_ran.in_milliseconds>ms (avg:<queue.time_ran.in_milliseconds.div[<[entities]>].round_to[2]>ms)"
        after player places block:
        - define location <context.location>
        - run BlockArchitect_reapply_light_range def.location:<[location]> def.range:10
        after player breaks block:
        - run BlockArchitect_reapply_light_range def.location:<context.location> def.range:10
BlockArchitect_reapply_light_time:
    type: task
    definitions: entity
    debug: false
    script:
    - define blocks <[location].flag[custom_block.flood_fill]>
    - define block_light <[blocks].parse[light.blocks].exclude[0]>
    - if <[block_light].is_empty>:
        - define block_light 0
    - else:
        - define block_light <[block_light].sum.div[<[block_light].size>]>
    - define sky_light <[blocks].parse[light.sky].highest.max[<[blocks].parse[light].highest>]>
    - define data <[entity].display_entity_data>
    - if <[data.brightness_sky]> == <[sky_light]> && <[data.brightness_block]> == <[block_light]>:
        - foreach next
    - adjust <[entity]> display_entity_data:<[data].include[brightness_sky=<[sky_light]>;brightness_block=<[block_light]>]>
BlockArchitect_reapply_light_range:
    type: task
    definitions: location|range
    debug: false
    script:
    - define entities <[location].find_blocks_flagged[custom_block].within[<[range]>].parse[flag[custom_block.entity]]>
    - foreach <[entities]> as:entity:
        - define location <[entity].location>
        - inject BlockArchitect_reapply_light_time
BlockArchitect_custom_block:
  type: entity
  debug: false
  entity_type: item_display
  mechanisms:
    item: dirt
    display_entity_data:
        transformation_scale: 1.001,1.001,1.001
        transformation_left_rotation: 0|0|0|1
        transformation_right_rotation: 0|0|0|1
        transformation_translation: 0,0,0
        view_range: 300
        brightness_block: 15
        brightness_sky: 15
        # These values are needed to use entry tags.
        item_transform: NONE
        width: 0
        height: 0
        interpolation_delay: 0s
        interpolation_duration: 0s