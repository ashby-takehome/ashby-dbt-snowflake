{% set stage_groups = source('ASHBY', 'STAGE_GROUPS') %}

WITH stage_groups_cleaned AS
(
    SELECT 
        stage_id,
        organization_id,
        archived AS is_archived_flag,
        title AS stage_title,
        stage_order,
        stage_type,
        -- Excluding interview_stage_group_id as it consistently shows the same ID as stage_group_id
        stage_group_id,
        stage_group_title,
        stage_group_order,
        stage_group_type,
        created_at AS stage_created_at
    FROM 
        {{ stage_groups }}
)

SELECT 
    *
FROM 
    stage_groups_cleaned