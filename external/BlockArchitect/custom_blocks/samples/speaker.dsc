custom_speaker:
    type: item
    debug: false
    data:
        custom_block:
            drops: custom_speaker
    material: note_block
    mechanisms:
        custom_model_data: 3
    flags:
        custom_block:
            powerable: true
            burn: false
            
custom_speaker_activated:
    type: world
    debug: false
    events:
        after custom event id:BlockArchitect_custom_block_powered_event_custom_speaker:
            - playsound <context.location> sound:entity_experience_orb_pickup volume:1.0 pitch:1.0