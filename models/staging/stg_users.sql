{% set users = source('ASHBY', 'USERS') %}

WITH users_cleaned AS
(
    SELECT 
        id AS user_id,
        organization_id,
        global_role,
        enabled AS is_enabled_flag,
        created_at AS user_created_at
    FROM 
        {{ users }}
)

SELECT 
    *
FROM 
    users_cleaned