CREATE TABLE admission_applications
(
    id                BIGSERIAL PRIMARY KEY,

    client_id         INT NOT NULL,
    location_id       INT NOT NULL,

    application_no    VARCHAR(30),
	CONSTRAINT uq_admission_app_no
    UNIQUE (client_id, application_no)
    first_name        VARCHAR(100) NOT NULL,
    middle_name       VARCHAR(100),
    last_name         VARCHAR(100),

    gender_id         BIGINT NOT NULL REFERENCES common_master_values(id),

    dob               DATE NOT NULL,

    blood_group_id    BIGINT REFERENCES common_master_values(id),

    birth_place_id    BIGINT REFERENCES common_master_values(id),

    religion_id       BIGINT REFERENCES common_master_values(id),
    caste_id          BIGINT REFERENCES common_master_values(id),
    nationality_id    BIGINT REFERENCES common_master_values(id),
    mother_tongue_id  BIGINT REFERENCES common_master_values(id),

    aadhaar_no VARCHAR(12) CHECK (aadhaar_no ~ '^[0-9]{12}$'),

    email             VARCHAR(150),

    class_id          BIGINT REFERENCES classes(id),

    academic_year     INT REFERENCES academic_years(id),

    admission_date    DATE,

    udise_no          VARCHAR(20),
    apaar_id          VARCHAR(30),

    transport_required BOOLEAN DEFAULT FALSE,

    remarks           TEXT,

    status            SMALLINT DEFAULT 0,

    created_by        INT,
    created_dt        TIMESTAMP DEFAULT now(),

    modified_by       INT,
    modified_dt       TIMESTAMP
);

CREATE INDEX idx_admission_client
ON admission_applications(client_id);

CREATE INDEX idx_admission_class
ON admission_applications(class_id);

CREATE INDEX idx_admission_year
ON admission_applications(academic_year);



CREATE TABLE admission_guardians
(
    id              BIGSERIAL PRIMARY KEY,

    admission_id    BIGINT NOT NULL REFERENCES admission_applications(id),

    guardian_type_id BIGINT REFERENCES common_master_values(id),

    first_name      VARCHAR(100),
    middle_name     VARCHAR(100),
    last_name       VARCHAR(100),

    contact_no      VARCHAR(20),
    email           VARCHAR(150),

    occupation      VARCHAR(100),
    designation     VARCHAR(100),

    annual_income   NUMERIC(28,2),

    is_primary      BOOLEAN DEFAULT FALSE,

    created_by      INT,
    created_dt      TIMESTAMP DEFAULT now()
);

CREATE UNIQUE INDEX idx_primary_guardian
ON admission_guardians(admission_id)
WHERE is_primary = TRUE;


CREATE TABLE admission_documents
(
    id              BIGSERIAL PRIMARY KEY,

    admission_id    BIGINT NOT NULL REFERENCES admission_applications(id),

    guardian_id     BIGINT REFERENCES admission_guardians(id),

    document_type_id BIGINT REFERENCES common_master_values(id),

    document_name   VARCHAR(200),

    file_path       TEXT,

    uploaded_by     INT,
    uploaded_dt     TIMESTAMP DEFAULT now()
);


CREATE TABLE admission_medical_info
(
    id                  BIGSERIAL PRIMARY KEY,

    admission_id        BIGINT REFERENCES admission_applications(id),

    medical_condition_detail TEXT,

    allergy_detail      TEXT,

    created_dt          TIMESTAMP DEFAULT now()
);


--Previous School Information
CREATE TABLE admission_previous_school
(
    id                  BIGSERIAL PRIMARY KEY,

    admission_id        BIGINT NOT NULL REFERENCES admission_applications(id),

    school_name         VARCHAR(200),

    address_line1       TEXT,
    address_line2       TEXT,

    city_id             BIGINT REFERENCES common_master_values(id),
    state_id            BIGINT REFERENCES common_master_values(id),
    country_id          BIGINT REFERENCES common_master_values(id),

    last_class_studied  VARCHAR(50),

    medium_of_instruction_id BIGINT REFERENCES common_master_values(id),

    board_id            BIGINT REFERENCES common_master_values(id),

    result              VARCHAR(50),

    created_dt          TIMESTAMP DEFAULT now()
);

CREATE TABLE admission_siblings
(
    id              BIGSERIAL PRIMARY KEY,

    admission_id    BIGINT NOT NULL REFERENCES admission_applications(id),

    sibling_name    VARCHAR(150),

    relation_id     BIGINT REFERENCES common_master_values(id),

    studying_in_same_school BOOLEAN DEFAULT FALSE,

    class_id        BIGINT REFERENCES classes(id),

    created_dt      TIMESTAMP DEFAULT now()
);

CREATE TABLE admission_hobbies
(
    id              BIGSERIAL PRIMARY KEY,

    admission_id    BIGINT REFERENCES admission_applications(id),

    hobby_id        BIGINT REFERENCES common_master_values(id)
);
CREATE UNIQUE INDEX idx_unique_hobby
ON admission_hobbies(admission_id, hobby_id);

CREATE TABLE admission_addresses
(
    id              BIGSERIAL PRIMARY KEY,

    admission_id    BIGINT NOT NULL
                    REFERENCES admission_applications(id),

    address_type_id BIGINT REFERENCES common_master_values(id),
    -- COMMUNICATION / PERMANENT

    address_line1   TEXT,
    address_line2   TEXT,

    country_id      BIGINT REFERENCES common_master_values(id),
    state_id        BIGINT REFERENCES common_master_values(id),
    city_id         BIGINT REFERENCES common_master_values(id),

    pincode         VARCHAR(10),

    created_by      INT,
    created_dt      TIMESTAMP DEFAULT now()
);
CREATE UNIQUE INDEX idx_unique_address_type
ON admission_addresses(admission_id, address_type_id);

CREATE TABLE admission_staff_child
(
    id              BIGSERIAL PRIMARY KEY,

    admission_id    BIGINT NOT NULL
                    REFERENCES admission_applications(id),

    staff_id        BIGINT REFERENCES employees(id),

    department_id   BIGINT REFERENCES departments(id),

    created_dt      TIMESTAMP DEFAULT now()
);


CREATE TABLE workflow_logs
(
    id              BIGSERIAL PRIMARY KEY,

    client_id       INT NOT NULL,    
    page_id         BIGINT NOT NULL
                    REFERENCES pages(id),

    entity_id       BIGINT NOT NULL,
    -- record id (admission_id, student_id, fee_id etc)

    old_status      SMALLINT,
    new_status      SMALLINT,

    remarks         TEXT,

    action_by       INT,
    action_dt       TIMESTAMP DEFAULT now(),

    CONSTRAINT fk_old_status
        FOREIGN KEY (page_id, old_status)
        REFERENCES page_status_master(page_id, status_code),

    CONSTRAINT fk_new_status
        FOREIGN KEY (page_id, new_status)
        REFERENCES page_status_master(page_id, status_code)
);

CREATE INDEX idx_workflow_entity
ON workflow_logs(page_id, entity_id);

CREATE INDEX idx_workflow_client
ON workflow_logs(client_id);

CREATE INDEX idx_workflow_history
ON workflow_logs(page_id, entity_id, action_dt DESC);



CREATE TABLE entity_audit_log
(
    id              BIGSERIAL PRIMARY KEY,

    client_id       INT NOT NULL,

    page_id         BIGINT NOT NULL
                    REFERENCES pages(id),

    entity_id       BIGINT NOT NULL,
    -- admission_id / student_id / fee_id

    field_name      VARCHAR(100),

    old_value       TEXT,
    new_value       TEXT,

    action_type     VARCHAR(20),
    -- INSERT / UPDATE / DELETE

    action_by       INT,

    action_dt       TIMESTAMP DEFAULT now()
);

CREATE INDEX idx_audit_entity
ON entity_audit_log(page_id, entity_id);

CREATE INDEX idx_audit_date
ON entity_audit_log(action_dt);