{% set jobs = source('ASHBY', 'JOBS') %}

WITH jobs_cleaned AS
(
    SELECT 
        id AS job_id,
        organization_id,
        title AS job_title,
        confidential AS is_confidential_flag,
        job_status,
        job_category,
        job_function,
        team_id,
        location_id,
        employment_type,
        created_at AS job_created_at
    FROM 
        {{ jobs }}
)

SELECT 
    *
FROM 
    jobs_cleaned