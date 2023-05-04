custom_speaker:
    type: item
    debug: false
    data:
        custom_block:
            drops: custom_speaker
            on_powered: custom_speaker_activated
    material: note_block
    mechanisms:
        custom_model_data: 3
    flags:
        custom_block:
            powerable: true
            burn: false

custom_speaker_activated:
    type: task
    debug: false
    script:
        - playsound <context.location> sound:entity_experience_orb_pickup volume:1.0 pitch:1.0