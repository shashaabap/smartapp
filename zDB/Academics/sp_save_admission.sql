CREATE OR REPLACE FUNCTION sp_save_admission(
    p_data JSONB,
    p_user_id INT,
    p_page_id INT
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE

v_admission JSONB;
v_addresses JSONB;
v_guardians JSONB;
v_siblings JSONB;
v_hobbies JSONB;
v_medical JSONB;

v_admission_id BIGINT;

rec JSONB;

BEGIN

v_admission := p_data->'admission';
v_addresses := p_data->'addresses';
v_guardians := p_data->'guardians';
v_siblings := p_data->'siblings';
v_hobbies := p_data->'hobbies';
v_medical := p_data->'medical_info';

------------------------------------------------
-- INSERT ADMISSION
------------------------------------------------
DECLARE
v_application_no VARCHAR;


INSERT INTO admission_applications
(
client_id,
location_id,
first_name,
middle_name,
last_name,
gender_id,
dob,
blood_group_id,
birth_place_id,
religion_id,
caste_id,
nationality_id,
mother_tongue_id,
aadhaar_no,
email,
class_id,
academic_year,
admission_date,
transport_required,
remarks,
created_by
)
VALUES
(
(v_admission->>'client_id')::INT,
(v_admission->>'location_id')::INT,
v_admission->>'first_name',
v_admission->>'middle_name',
v_admission->>'last_name',
(v_admission->>'gender_id')::BIGINT,
(v_admission->>'dob')::DATE,
(v_admission->>'blood_group_id')::BIGINT,
(v_admission->>'birth_place_id')::BIGINT,
(v_admission->>'religion_id')::BIGINT,
(v_admission->>'caste_id')::BIGINT,
(v_admission->>'nationality_id')::BIGINT,
(v_admission->>'mother_tongue_id')::BIGINT,
v_admission->>'aadhaar_no',
v_admission->>'email',
(v_admission->>'class_id')::BIGINT,
(v_admission->>'academic_year')::INT,
(v_admission->>'admission_date')::DATE,
(v_admission->>'transport_required')::BOOLEAN,
v_admission->>'remarks',
p_user_id
)
RETURNING id INTO v_admission_id;

------------------------------------------------
-- INSERT ADDRESSES
------------------------------------------------

FOR rec IN SELECT * FROM jsonb_array_elements(v_addresses)
LOOP

INSERT INTO admission_addresses
(
admission_id,
address_type_id,
address_line1,
address_line2,
country_id,
state_id,
city_id,
pincode,
created_by
)
VALUES
(
v_admission_id,
(rec->>'address_type_id')::BIGINT,
rec->>'address_line1',
rec->>'address_line2',
(rec->>'country_id')::BIGINT,
(rec->>'state_id')::BIGINT,
(rec->>'city_id')::BIGINT,
rec->>'pincode',
p_user_id
);

END LOOP;

------------------------------------------------
-- INSERT GUARDIANS
------------------------------------------------

FOR rec IN SELECT * FROM jsonb_array_elements(v_guardians)
LOOP

INSERT INTO admission_guardians
(
admission_id,
guardian_type_id,
first_name,
last_name,
contact_no,
is_primary,
created_by
)
VALUES
(
v_admission_id,
(rec->>'guardian_type_id')::BIGINT,
rec->>'first_name',
rec->>'last_name',
rec->>'contact_no',
(rec->>'is_primary')::BOOLEAN,
p_user_id
);

END LOOP;

------------------------------------------------
-- INSERT HOBBIES
------------------------------------------------

FOR rec IN SELECT * FROM jsonb_array_elements(v_hobbies)
LOOP

INSERT INTO admission_hobbies
(
admission_id,
hobby_id
)
VALUES
(
v_admission_id,
(rec)::BIGINT
);

END LOOP;

------------------------------------------------
-- MEDICAL INFO
------------------------------------------------

IF v_medical IS NOT NULL THEN

INSERT INTO admission_medical_info
(
admission_id,
medical_condition_detail,
allergy_detail
)
VALUES
(
v_admission_id,
v_medical->>'medical_condition_detail',
v_medical->>'allergy_detail'
);

END IF;

------------------------------------------------
-- WORKFLOW LOG
------------------------------------------------

INSERT INTO workflow_logs
(
client_id,
page_id,
entity_id,
old_status,
new_status,
action_by
)
VALUES
(
(v_admission->>'client_id')::INT,
p_page_id,
v_admission_id,
NULL,
0,
p_user_id
);

------------------------------------------------
-- AUDIT LOG
------------------------------------------------

INSERT INTO entity_audit_log
(
client_id,
page_id,
entity_id,
field_name,
action_type,
action_by
)
VALUES
(
(v_admission->>'client_id')::INT,
p_page_id,
v_admission_id,
'ADMISSION_CREATED',
'INSERT',
p_user_id
);

RETURN v_admission_id;

END;
$$;