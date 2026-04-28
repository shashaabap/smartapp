CREATE OR REPLACE FUNCTION fn_generate_application_no(
    p_client_id INT,
    p_academic_year INT
)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE

v_prefix TEXT := 'ADM';
v_year TEXT;
v_next INT;
v_app_no TEXT;

BEGIN

SELECT year_code
INTO v_year
FROM academic_years
WHERE id = p_academic_year;

SELECT COALESCE(MAX(
CAST(SPLIT_PART(application_no,'-',3) AS INT)
),0) + 1
INTO v_next
FROM admission_applications
WHERE client_id = p_client_id
AND application_no LIKE v_prefix||'-'||v_year||'%';

v_app_no :=
v_prefix||'-'||v_year||'-'||LPAD(v_next::TEXT,6,'0');

RETURN v_app_no;

END;
$$;