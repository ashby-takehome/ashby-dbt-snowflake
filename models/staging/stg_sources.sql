{% set sources = source('ASHBY', 'SOURCES') %}

WITH sources_cleaned AS
(
    SELECT 
        id AS source_id,
        organization_id,
        title AS source_title,
        source_type_id,
        is_archived AS is_archived_flag,
        created_at AS source_created_at
    FROM 
        {{ sources }}
)

SELECT 
    *
FROM 
    sources_cleaned