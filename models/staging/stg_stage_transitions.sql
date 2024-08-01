{% set stage_transitions = source('ASHBY', 'STAGE_TRANSITIONS') %}

WITH stage_transitions_cleaned AS
(
    SELECT 
        id AS stage_transition_id,
        organization_id,
        application_id,
        new_interview_stage_id,
        previous_interview_stage_id,
        created_at AS stage_transition_created_at,
        entered_stage_at,
        left_stage_at,
       -- Calculating the Time-In-Process in days (will show NULL if a stage is still open)
       TIMESTAMPDIFF('days', entered_stage_at, left_stage_at) AS time_in_process_days
    FROM 
        {{ stage_transitions }}
)

SELECT 
    *
FROM 
    stage_transitions_cleaned