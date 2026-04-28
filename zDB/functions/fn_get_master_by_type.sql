CREATE OR REPLACE FUNCTION fn_get_master_by_type(
    p_type_code VARCHAR
)
RETURNS TABLE(
    id BIGINT,
    value_code VARCHAR,
    value_name VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

RETURN QUERY
SELECT 
v.id,
v.value_code,
v.value_name
FROM common_master_values v
JOIN common_master_types t
ON t.id = v.type_id
WHERE t.type_code = p_type_code
AND v.is_active = TRUE
ORDER BY v.value_name;

END;
$$;



CREATE OR REPLACE FUNCTION fn_get_states(
    p_country_id BIGINT
)
RETURNS TABLE(
    id BIGINT,
    value_name VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

RETURN QUERY
SELECT id,value_name
FROM common_master_values
WHERE parent_id = p_country_id
ORDER BY value_name;

END;
$$;


CREATE OR REPLACE FUNCTION fn_get_cities(
    p_state_id BIGINT
)
RETURNS TABLE(
    id BIGINT,
    value_name VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

RETURN QUERY
SELECT id,value_name
FROM common_master_values
WHERE parent_id = p_state_id
ORDER BY value_name;

END;
$$;



CREATE OR REPLACE FUNCTION fn_get_admission_metadata()
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
result JSON;
BEGIN

SELECT json_build_object(

'genders',(SELECT json_agg(row_to_json(x)) FROM fn_get_master_by_type('GENDER') x),

'religions',(SELECT json_agg(row_to_json(x)) FROM fn_get_master_by_type('RELIGION') x),

'castes',(SELECT json_agg(row_to_json(x)) FROM fn_get_master_by_type('CASTE') x),

'languages',(SELECT json_agg(row_to_json(x)) FROM fn_get_master_by_type('LANGUAGE') x),

'blood_groups',(SELECT json_agg(row_to_json(x)) FROM fn_get_master_by_type('BLOOD_GROUP') x),

'guardian_types',(SELECT json_agg(row_to_json(x)) FROM fn_get_master_by_type('GUARDIAN_TYPE') x),

'address_types',(SELECT json_agg(row_to_json(x)) FROM fn_get_master_by_type('ADDRESS_TYPE') x),

'hobbies',(SELECT json_agg(row_to_json(x)) FROM fn_get_master_by_type('HOBBY') x)

) INTO result;

RETURN result;

END;
$$;