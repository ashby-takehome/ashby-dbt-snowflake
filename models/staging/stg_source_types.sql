{% set source_types = source('ASHBY', 'SOURCE_TYPES') %}

WITH source_types_cleaned AS
(
    SELECT 
        id AS source_type_id,
        organization_id,
        title AS source_type_title,
        is_archived AS is_archived_flag,
        created_at AS source_type_created_at
    FROM 
        {{ source_types }}
)

SELECT 
    *
FROM 
    source_types_cleaned