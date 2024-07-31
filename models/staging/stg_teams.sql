{% set teams = source('ASHBY', 'TEAMS') %}

WITH teams_cleaned AS
(
    SELECT 
        id AS team_id,
        organization_id,
        team_name,
        parent_team_id,
        is_archived AS is_archived_flag,
        created_at AS team_created_at
    FROM 
        {{ teams }}
)

SELECT 
    *
FROM 
    teams_cleaned