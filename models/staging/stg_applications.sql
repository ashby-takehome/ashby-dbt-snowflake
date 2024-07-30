{% set applications = source('ASHBY', 'APPLICATIONS') %}

WITH applications_cleaned AS
(
    SELECT 
        id AS application_id,
        organization_id,
        job_id,
        candidate_id,
        current_interview_stage_id,
        status AS application_status,
        source_id,
        last_activity_at,
        archive_reason_id,
        created_at AS application_created_at
    FROM 
        {{ applications }}
)

SELECT 
    *
FROM 
    applications_cleaned