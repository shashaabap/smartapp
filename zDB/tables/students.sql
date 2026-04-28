CREATE TABLE students
(
    id                BIGSERIAL PRIMARY KEY,

    client_id         INT NOT NULL,
    location_id       INT NOT NULL,

    admission_id      BIGINT NOT NULL
                      REFERENCES admission_applications(id),

    student_code      VARCHAR(30) UNIQUE,
    -- e.g. STU-2025-0001

    first_name        VARCHAR(100) NOT NULL,
    middle_name       VARCHAR(100),
    last_name         VARCHAR(100),

    gender_id         BIGINT REFERENCES common_master_values(id),

    dob               DATE,

    blood_group_id    BIGINT REFERENCES common_master_values(id),

    religion_id       BIGINT REFERENCES common_master_values(id),
    caste_id          BIGINT REFERENCES common_master_values(id),

    nationality_id    BIGINT REFERENCES common_master_values(id),

    aadhaar_no        VARCHAR(12),

    email             VARCHAR(150),

    status            SMALLINT DEFAULT 1,
    -- ACTIVE / INACTIVE / LEFT / PASSED OUT

    created_dt        TIMESTAMP DEFAULT now()
);



CREATE TABLE student_class_enrollment
(
    id                BIGSERIAL PRIMARY KEY,

    student_id        BIGINT NOT NULL
                      REFERENCES students(id),

    academic_year     INT NOT NULL
                      REFERENCES academic_years(id),

    class_id          BIGINT NOT NULL
                      REFERENCES class_master(id),

    section_id        BIGINT
                      REFERENCES section_master(id),

    roll_no           INT,

    is_current        BOOLEAN DEFAULT TRUE,

    created_dt        TIMESTAMP DEFAULT now()
);