{% set applications = ref("stg_applications") %}
{% set jobs = ref("stg_jobs") %}
{% set source_types = ref("stg_source_types") %}
{% set sources = ref("stg_sources") %}
{% set teams = ref("stg_teams") %}
{% set stage_groups = ref("stg_stage_groups") %}
{% set organization_names_seed = ref("organization_names") %}

WITH applications_enriched AS
(
    SELECT 
        a.organization_id,
        ons.organization_name,
        a.application_id,
        a.candidate_id,
        j.job_title,
        j.job_function,
        j.job_category,
        j.job_status,
        j.employment_type,
        t.team_name,

        -- A department (e.g. Engineering) is a team with no parent team ID - here shown as its own parent for simplicity
        COALESCE(pt.team_name, t.team_name) AS parent_team_name,

        -- Replacing boolean with readable types for ease of visulaization
        IFF(j.is_confidential_flag, 'Confidential', 'Regular') AS job_confidentiality,

        a.application_status,
        st.source_type_title,
        s.source_title,
        sg.stage_group_title AS current_stage_group_title,
        sg.stage_group_type AS current_stage_group_type,

        -- Creating a flag to show if the same applicant applied for the same job more than once
        COUNT(DISTINCT a.application_id) OVER (PARTITION BY a.candidate_id, a.job_id, a.organization_id) > 1 AS applicant_re_applied_flag,

        -- Adding a rank/order for applications by the same candidate for the same job, if applied multiple times
        -- Using ROW_NUMBER() instead of RANK() in case there were 2 applications created at the exact same time (unlikely but possible)
        ROW_NUMBER() OVER (PARTITION BY a.candidate_id, a.job_id, a.organization_id ORDER BY a.application_created_at ASC) AS application_order

    FROM {{ applications }} AS a

    LEFT JOIN {{ jobs }} AS j 
    USING (organization_id, job_id)

    LEFT JOIN {{ sources }} AS s 
    USING (organization_id, source_id)

    LEFT JOIN {{ source_types }} AS st 
    USING (organization_id, source_type_id)

    LEFT JOIN {{ teams }} AS t 
    USING (organization_id, team_id)

    -- Joining this dummy seed (CSV) that gives the 2 organizations in the dataset some readable names
    LEFT JOIN {{ organization_names_seed }} AS ons
    USING (organization_id)

    -- Joining again with teams table to pull the "parent team" name
    LEFT JOIN {{ teams }} AS pt 
    ON pt.team_id = t.parent_team_id AND pt.organization_id = t.organization_id

    -- Joining with stage groups table to pull the current interview stage details (to flag hired ones)
    LEFT JOIN {{ stage_groups }} AS sg
    ON sg.stage_id = a.current_interview_stage_id AND sg.organization_id = a.organization_id
)

SELECT 
    *
FROM 
    applications_enriched