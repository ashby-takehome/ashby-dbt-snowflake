{% set applications = ref("stg_applications") %}
{% set jobs = ref("stg_jobs") %}
{% set source_types = ref("stg_source_types") %}
{% set sources = ref("stg_sources") %}
{% set teams = ref("stg_teams") %}
{% set stage_groups = ref("stg_stage_groups") %}
{% set organization_names_seed = ref("organization_names") %}
{% set stage_transitions = ref("stg_stage_transitions") %}

WITH application_time_in_process AS
(
    SELECT
        st.organization_id,
        st.application_id,
        -- Calculating the "Time In Process" for the entire application cycle
        SUM(st.time_in_process_days) AS time_in_process_days
    
    FROM {{ stage_transitions }} AS st

    LEFT JOIN {{applications}} AS a
    USING (organization_id, application_id)

    WHERE 
        -- Calculating the aaplication-level Time in Process for hired and archived applications only
        LOWER(a.application_status) IN ('hired', 'archived')
    
    GROUP BY 1,2
),

applications_enriched AS
(
    SELECT 
        a.organization_id,
        ons.organization_name,
        a.application_id,
        a.candidate_id,
        a.application_created_at,
        tip.time_in_process_days,
        a.job_id,
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

        -- Standardizing the casing to be proper case
        INITCAP(a.application_status) AS application_status,

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

    -- Joining with stage groups table to pull the current interview stage details
    LEFT JOIN {{ stage_groups }} AS sg
    ON sg.stage_id = a.current_interview_stage_id AND sg.organization_id = a.organization_id

    -- Joining with CTE above to add the "Time In Process" for the entire application cycle
    LEFT JOIN application_time_in_process AS tip
    ON tip.application_id = a.application_id AND tip.organization_id = a.organization_id

    WHERE
        -- Excluding Draft jobs (assuming that draft jobs are not posted and safe to exclude)
        j.job_status != 'draft'
        -- Excluding the applications in "Lead" state (assuming that they are not yet active applications)
        AND a.application_status != 'lead'
)

SELECT 
    *
FROM 
    applications_enriched