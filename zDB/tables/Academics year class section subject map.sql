
drop table academic_years
CREATE TABLE academic_years
(
    id              BIGSERIAL PRIMARY KEY,

    client_id       INT,

    year_code       CHAR(4),   -- 2025
    year_name       VARCHAR(50),   -- Academic Year 2025-26

    start_date      DATE,
    end_date        DATE,

    is_current      BOOLEAN DEFAULT FALSE,

    status          SMALLINT DEFAULT 1,

    created_by      INT,
    created_dt      TIMESTAMP DEFAULT now()
);
SELECT *fROM clients
INSERT INTO academic_years
(client_id, year_code, year_name, start_date, end_date, is_current, status, created_by)
VALUES
(3,'2024','Academic Year 2024-25','2024-04-01','2025-03-31',FALSE,1,1),
(3,'2025','Academic Year 2025-26','2025-04-01','2026-03-31',TRUE,1,1),
(3,'2026','Academic Year 2026-27','2026-04-01','2027-03-31',FALSE,1,1);


CREATE TABLE classes
(
    id              BIGSERIAL PRIMARY KEY,

    client_id       INT,
    location_id     INT,

    class_code      VARCHAR(20),
    class_name      VARCHAR(100),

    display_order   INT,

    status          SMALLINT DEFAULT 1,

    created_by      INT,
    created_dt      TIMESTAMP DEFAULT now()
);
select *from locations
INSERT INTO classes
(client_id, location_id, class_code, class_name, display_order, status, created_by)
VALUES
(3,3,'NUR','Nursery',1,1,1),
(3,3,'LKG','LKG',2,1,1),
(3,3,'UKG','UKG',3,1,1),
(3,3,'C1','Class 1',4,1,1),
(3,3,'C2','Class 2',5,1,1),
(3,3,'C3','Class 3',6,1,1),
(3,3,'C4','Class 4',7,1,1),
(3,3,'C5','Class 5',8,1,1),
(3,3,'C6','Class 6',9,1,1),
(3,3,'C7','Class 7',10,1,1),
(3,3,'C8','Class 8',11,1,1),
(3,3,'C9','Class 9',12,1,1),
(3,3,'C10','Class 10',13,1,1);


CREATE TABLE sections
(
    id              BIGSERIAL PRIMARY KEY,

    client_id       INT NOT NULL,
    location_id     INT NOT NULL,

    section_code    VARCHAR(20),
    section_name    VARCHAR(50),

    capacity        INT,

    status          SMALLINT DEFAULT 1,

    created_by      INT,
    created_dt      TIMESTAMP DEFAULT now()
);

INSERT INTO sections
(client_id, location_id, section_code, section_name, capacity, status, created_by)
VALUES
(3,3,'A','Section A',40,1,1),
(3,3,'B','Section B',40,1,1),
(3,3,'C','Section C',40,1,1),
(3,3,'D','Section D',40,1,1);

CREATE TABLE subjects
(
    id              BIGSERIAL PRIMARY KEY,

    client_id       INT NOT NULL,
    location_id     INT NOT NULL,

    subject_code    VARCHAR(20),
    subject_name    VARCHAR(100),

    subject_type    VARCHAR(20),

    status          SMALLINT DEFAULT 1,

    created_by      INT,
    created_dt      TIMESTAMP DEFAULT now()
);
INSERT INTO subjects
(client_id, location_id, subject_code, subject_name, subject_type, status, created_by)
VALUES
(3,3,'ENG','English','CORE',1,1),
(3,3,'MAT','Mathematics','CORE',1,1),
(3,3,'SCI','Science','CORE',1,1),
(3,3,'SOC','Social Studies','CORE',1,1),
(3,3,'HIN','Hindi','LANGUAGE',1,1),
(3,3,'COMP','Computer','OPTIONAL',1,1),
(3,3,'GK','General Knowledge','OPTIONAL',1,1),
(3,3,'ART','Art & Craft','OPTIONAL',1,1),
(3,3,'PE','Physical Education','OPTIONAL',1,1);

drop table class_section_mapping
CREATE TABLE class_section_mapping
(
    id              BIGSERIAL PRIMARY KEY,

    client_id       INT,

    class_id        BIGINT REFERENCES classes(id),

    section_id      BIGINT REFERENCES sections(id),

    status          SMALLINT DEFAULT 1,

    created_by      INT,
    created_dt      TIMESTAMP DEFAULT now()
);
select *From class_section_mapping
INSERT INTO class_section_mapping
(client_id, class_id, section_id, status, created_by)
SELECT
3,
c.id,
s.id,
1,
1
FROM classes c
JOIN sections s
ON s.section_code IN ('A','B','C','D');


CREATE TABLE class_subject_mapping
(
    id              BIGSERIAL PRIMARY KEY,

    client_id       INT,

    class_id        BIGINT REFERENCES classes(id),

    subject_id      BIGINT REFERENCES subjects(id),

    is_optional     BOOLEAN DEFAULT FALSE,

    created_by      INT,
    created_dt      TIMESTAMP DEFAULT now()
);

INSERT INTO class_subject_mapping
(client_id, class_id, subject_id, is_optional, created_by)
SELECT
1,
c.id,
s.id,
CASE
WHEN s.subject_type='OPTIONAL' THEN TRUE
ELSE FALSE
END,
1
FROM classes c
CROSS JOIN subjects s;