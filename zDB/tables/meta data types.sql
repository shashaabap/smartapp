
DROP TABLE IF EXISTS common_master_types CASCADE;
CREATE TABLE common_master_types
(
    id            BIGSERIAL PRIMARY KEY,
    type_code     VARCHAR(50) UNIQUE NOT NULL,
    type_name     VARCHAR(100) NOT NULL,
    description   TEXT,
    is_active     BOOLEAN DEFAULT TRUE,
    created_dt    TIMESTAMP DEFAULT now()
);
INSERT INTO common_master_types (type_code, type_name, description)
VALUES
('GENDER','Gender','Student gender'),
('RELIGION','Religion','Religion master'),
('CASTE','Caste','Caste master'),
('NATIONALITY','Nationality','Nationality master'),
('LANGUAGE','Language','Language master'),
('BLOOD_GROUP','Blood Group','Blood group master'),
('ADDRESS_TYPE','Address Type','Communication/Permanent'),
('GUARDIAN_TYPE','Guardian Type','Father/Mother/Guardian'),
('DOCUMENT_TYPE','Document Type','Admission documents'),
('HOBBY','Hobby','Student hobbies'),
('COUNTRY','Country','Country master'),
('STATE','State','State master'),
('CITY','City','City master'),
('BOARD','Education Board','School board'),
('RELATION','Relation','Sibling relation');


DROP TABLE IF EXISTS common_master_values CASCADE;
CREATE TABLE common_master_values
(
    id            BIGSERIAL PRIMARY KEY,

    type_id       BIGINT NOT NULL
                  REFERENCES common_master_types(id),

    client_id     INT NULL,
    -- NULL = global master shared by all clients
    -- value = client specific master

    value_code    VARCHAR(50),

    value_name    VARCHAR(150) NOT NULL,

    parent_id     BIGINT REFERENCES common_master_values(id),

    sort_order    INT DEFAULT 1,

    is_active     BOOLEAN DEFAULT TRUE,

    created_dt    TIMESTAMP DEFAULT now()
);
CREATE INDEX idx_master_parent
ON common_master_values(parent_id);
--gender
INSERT INTO common_master_values (type_id, value_code, value_name)
SELECT id,'M','Male' FROM common_master_types WHERE type_code='GENDER';

INSERT INTO common_master_values (type_id, value_code, value_name)
SELECT id,'F','Female' FROM common_master_types WHERE type_code='GENDER';

INSERT INTO common_master_values (type_id, value_code, value_name)
SELECT id,'O','Other' FROM common_master_types WHERE type_code='GENDER';




--Religion
INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Hindu' FROM common_master_types WHERE type_code='RELIGION';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Muslim' FROM common_master_types WHERE type_code='RELIGION';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Christian' FROM common_master_types WHERE type_code='RELIGION';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Sikh' FROM common_master_types WHERE type_code='RELIGION';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Jain' FROM common_master_types WHERE type_code='RELIGION';

--Cast

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'General' FROM common_master_types WHERE type_code='CASTE';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'OBC' FROM common_master_types WHERE type_code='CASTE';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'SC' FROM common_master_types WHERE type_code='CASTE';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'ST' FROM common_master_types WHERE type_code='CASTE';

--nationality

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Indian' FROM common_master_types WHERE type_code='NATIONALITY';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Other' FROM common_master_types WHERE type_code='NATIONALITY';

--Languages
INSERT INTO common_master_values (type_id,value_name)
SELECT id,'English' FROM common_master_types WHERE type_code='LANGUAGE';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Hindi' FROM common_master_types WHERE type_code='LANGUAGE';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Gujarati' FROM common_master_types WHERE type_code='LANGUAGE';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Marathi' FROM common_master_types WHERE type_code='LANGUAGE';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Tamil' FROM common_master_types WHERE type_code='LANGUAGE';

--Blood Groups
INSERT INTO common_master_values (type_id,value_name)
SELECT id,'A+' FROM common_master_types WHERE type_code='BLOOD_GROUP';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'A-' FROM common_master_types WHERE type_code='BLOOD_GROUP';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'B+' FROM common_master_types WHERE type_code='BLOOD_GROUP';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'B-' FROM common_master_types WHERE type_code='BLOOD_GROUP';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'AB+' FROM common_master_types WHERE type_code='BLOOD_GROUP';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'O+' FROM common_master_types WHERE type_code='BLOOD_GROUP';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'O-' FROM common_master_types WHERE type_code='BLOOD_GROUP';

--Address Types
INSERT INTO common_master_values (type_id,value_code,value_name)
SELECT id,'COMM','Communication'
FROM common_master_types WHERE type_code='ADDRESS_TYPE';

INSERT INTO common_master_values (type_id,value_code,value_name)
SELECT id,'PERM','Permanent'
FROM common_master_types WHERE type_code='ADDRESS_TYPE';


--Guardian Types
INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Father' FROM common_master_types WHERE type_code='GUARDIAN_TYPE';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Mother' FROM common_master_types WHERE type_code='GUARDIAN_TYPE';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Guardian' FROM common_master_types WHERE type_code='GUARDIAN_TYPE';


--Document Types
INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Student Photo' FROM common_master_types WHERE type_code='DOCUMENT_TYPE';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Birth Certificate' FROM common_master_types WHERE type_code='DOCUMENT_TYPE';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Aadhaar Card' FROM common_master_types WHERE type_code='DOCUMENT_TYPE';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Transfer Certificate' FROM common_master_types WHERE type_code='DOCUMENT_TYPE';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Previous Marksheet' FROM common_master_types WHERE type_code='DOCUMENT_TYPE';

--Hobbies
INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Drawing' FROM common_master_types WHERE type_code='HOBBY';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Painting' FROM common_master_types WHERE type_code='HOBBY';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Music' FROM common_master_types WHERE type_code='HOBBY';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Sports' FROM common_master_types WHERE type_code='HOBBY';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'Dance' FROM common_master_types WHERE type_code='HOBBY';

--Education Boards
INSERT INTO common_master_values (type_id,value_name)
SELECT id,'CBSE' FROM common_master_types WHERE type_code='BOARD';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'ICSE' FROM common_master_types WHERE type_code='BOARD';

INSERT INTO common_master_values (type_id,value_name)
SELECT id,'GSEB' FROM common_master_types WHERE type_code='BOARD';

--Country


INSERT INTO common_master_values (type_id, value_code, value_name)
SELECT id,'IND','India'
FROM common_master_types
WHERE type_code='COUNTRY';

--States (India Example)
INSERT INTO common_master_values (type_id,value_name,parent_id)
SELECT 
t.id,
'Gujarat',
c.id
FROM common_master_types t
JOIN common_master_values c
ON c.value_name='India'
WHERE t.type_code='STATE';

INSERT INTO common_master_values (type_id,value_name,parent_id)
SELECT 
t.id,
'Maharashtra',
c.id
FROM common_master_types t
JOIN common_master_values c
ON c.value_name='India'
WHERE t.type_code='STATE';

--Cities

INSERT INTO common_master_values (type_id,value_name,parent_id)
SELECT
t.id,
'Bharuch',
s.id
FROM common_master_types t
JOIN common_master_values s
ON s.value_name='Gujarat'
WHERE t.type_code='CITY';


INSERT INTO common_master_values (type_id,value_name,parent_id)
SELECT
t.id,
'Surat',
s.id
FROM common_master_types t
JOIN common_master_values s
ON s.value_name='Gujarat'
WHERE t.type_code='CITY';

INSERT INTO common_master_values (type_id,value_name,parent_id)
SELECT
t.id,
'Ahmedabad',
s.id
FROM common_master_types t
JOIN common_master_values s
ON s.value_name='Gujarat'
WHERE t.type_code='CITY';