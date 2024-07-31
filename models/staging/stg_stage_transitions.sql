{% set stage_transitions = source('ASHBY', 'STAGE_TRANSITIONS') %}

WITH stage_transitions_cleaned AS
(
    SELECT 
        id AS stage_transition_id,
        organization_id,
        application_id,
        new_interview_stage_id,
        previous_interview_stage_id,
        entered_stage_at,
        left_stage_at,
        created_at AS stage_transition_created_at
    FROM 
        {{ stage_transitions }}
)

SELECT 
    *
FROM 
    stage_transitions_cleaned