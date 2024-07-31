{% set stage_transitions = ref("stg_stage_transitions") %}
{% set stage_groups = ref("stg_stage_groups") %}


WITH stage_transitions_enriched AS
(
    SELECT 
       st.organization_id,
       application_id,
       stage_transition_id,
       
       -- Focusing on stage groups only
       stage_group_order,
       stage_group_title,
       stage_group_type,
       entered_stage_at,
       left_stage_at,
       
       -- Calculating the Time In Process (in days)
       TIMESTAMPDIFF('days', entered_stage_at, IFNULL(left_stage_at, CURRENT_TIMESTAMP())) AS time_in_process_days
    
    FROM {{ stage_transitions }} AS st

    LEFT JOIN {{ stage_groups }} AS sg
    ON st.new_interview_stage_id = sg.stage_id AND st.organization_id = sg.organization_id

    WHERE 
        -- Excluding transitions to 'Archived' or 'Hired' stage as they are the final stages to the hiring cycle and stay open
        stage_group_type NOT IN ('Archived', 'Hired')
)

SELECT 
    *
FROM 
    stage_transitions_enriched