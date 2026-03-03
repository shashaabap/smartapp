DROP TABLE IF EXISTS modules CASCADE;

CREATE TABLE modules (
    id BIGSERIAL PRIMARY KEY,

    module_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255),
    display_order INT,

    status SMALLINT NOT NULL DEFAULT 1
        CHECK (status IN (0,1)),--1 is for active and 0 for inactive

    created_by BIGINT NOT NULL,
    created_dt TIMESTAMP NOT NULL DEFAULT NOW(),
    modified_by BIGINT,
    modified_dt TIMESTAMP
);
select *From modules
INSERT INTO modules (module_name, description, created_by)
VALUES
--('Authentication Module', 'Module handling user login/logout', 1),			
--('User Management & Access Rights', 'Managing users and roles access', 1);
select *from modules
INSERT INTO modules (module_name, description, created_by)
VALUES
('Administration', 'Administration', 1);


select *from modules
delete from modules



DROP TABLE IF EXISTS components CASCADE;

CREATE TABLE components (
    id BIGSERIAL PRIMARY KEY,

    component_name VARCHAR(100) NOT NULL,
    module_id BIGINT NOT NULL,
    description VARCHAR(255),
    display_order INT,

    status SMALLINT NOT NULL DEFAULT 1
        CHECK (status IN (0,1)),

    created_by BIGINT NOT NULL,
    created_dt TIMESTAMP NOT NULL DEFAULT NOW(),
    modified_by BIGINT,
    modified_dt TIMESTAMP,

    CONSTRAINT fk_components_module
        FOREIGN KEY (module_id)
        REFERENCES modules(id)
        ON DELETE RESTRICT
);

INSERT INTO components (component_name, module_id, description, created_by)
SELECT 'User Mgmt. & Access', id, 'User Management & Access Rights', 1
FROM modules WHERE module_name = 'Administration';



INSERT INTO components (component_name, module_id, description, created_by)
SELECT 'IRN & EWAYBILL Generation', id, 'IRN & EWAYBILL Generation', 1
FROM modules WHERE module_name = 'Sales & Shipping';

select *From components
delete from components
DROP TABLE IF EXISTS components CASCADE;

CREATE TABLE pages (
    id BIGSERIAL PRIMARY KEY,

    page_name VARCHAR(150) NOT NULL,
    route VARCHAR(255) NOT NULL,
    component_id BIGINT NOT NULL,
    description VARCHAR(255),
    display_order INT,

    status SMALLINT NOT NULL DEFAULT 1
        CHECK (status IN (0,1)),

    created_by BIGINT NOT NULL,
    created_dt TIMESTAMP NOT NULL DEFAULT NOW(),
    modified_by BIGINT,
    modified_dt TIMESTAMP,

    CONSTRAINT fk_pages_component
        FOREIGN KEY (component_id)
        REFERENCES components(id)
        ON DELETE RESTRICT
);

INSERT INTO pages (page_name, route, component_id, description, created_by)
SELECT 'User Master', '/usermaster', id, 'User Master', 1
FROM components WHERE component_name = 'User Mgmt. & Access';


INSERT INTO pages (page_name, route, component_id, description, created_by)
SELECT 'EWAY-BILL Generation', '/ewaybillgen', id, 'EWAY-BILL Generation', 1
FROM components WHERE component_name = 'IRN & EWAYBILL Generation';


select *From pages
delete from pages
DROP TABLE IF EXISTS forms CASCADE;

CREATE TABLE forms (
    id BIGSERIAL PRIMARY KEY,

    form_name VARCHAR(150) NOT NULL,
    page_id BIGINT NOT NULL,

    form_type VARCHAR(50) NOT NULL
        CHECK (form_type IN ('Page','Popup','Dialog','Help','Hyperlink','Embedded')),

    route VARCHAR(255),
    target_url VARCHAR(500),
    description VARCHAR(255),
    display_order INT,

    status SMALLINT NOT NULL DEFAULT 1
        CHECK (status IN (0,1)),

    created_by BIGINT NOT NULL,
    created_dt TIMESTAMP NOT NULL DEFAULT NOW(),
    modified_by BIGINT,
    modified_dt TIMESTAMP,

    CONSTRAINT fk_forms_page
        FOREIGN KEY (page_id)
        REFERENCES pages(id)
        ON DELETE RESTRICT
);

INSERT INTO forms
(form_name, page_id, form_type, description, created_by)
SELECT 'User Master', id, 'Embedded', 'User login form', 1
FROM pages WHERE page_name = 'User Master';





select *from forms


DROP TABLE IF EXISTS controls CASCADE;

CREATE TABLE controls (
    id BIGSERIAL PRIMARY KEY,

    control_name VARCHAR(100) NOT NULL,
    control_type VARCHAR(50) NOT NULL,
    control_label VARCHAR(255),
    display_order INT,

    is_mandatory BOOLEAN DEFAULT FALSE,
    is_visible BOOLEAN DEFAULT TRUE,
    is_enabled BOOLEAN DEFAULT TRUE,

    status SMALLINT NOT NULL DEFAULT 1
        CHECK (status IN (0,1)),

    created_by BIGINT NOT NULL,
    created_dt TIMESTAMP NOT NULL DEFAULT NOW(),
    modified_by BIGINT,
    modified_dt TIMESTAMP
);

INSERT INTO controls
(control_name, control_type, control_label, display_order, created_by)
VALUES ('Generate', 'Button', 'Generate', 1, 1);
SELECT *fROM forms
select *From controls
delete from forms
delete from controls

delete from form_controls_mapping
DROP TABLE IF EXISTS form_controls_mapping CASCADE;

CREATE TABLE form_controls_mapping (
    id BIGSERIAL PRIMARY KEY,

    form_id BIGINT NOT NULL,
    control_id BIGINT NOT NULL,

    status SMALLINT NOT NULL DEFAULT 1
        CHECK (status IN (0,1)),  --0 for in inactive and 1 for active

    CONSTRAINT fk_fcm_form
        FOREIGN KEY (form_id)
        REFERENCES forms(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_fcm_control
        FOREIGN KEY (control_id)
        REFERENCES controls(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_form_control UNIQUE (form_id, control_id)
);
SELECT *fROM form_controls_mapping
INSERT INTO form_controls_mapping (form_id, control_id)
SELECT f.id, c.id
FROM forms f
JOIN controls c ON c.control_name = 'Generate'
WHERE f.form_name = 'EWAY-BILL Generation';
delete from form_controls_mapping

CREATE TABLE role_forms_access (
    id BIGSERIAL PRIMARY KEY,

    role_id BIGINT NOT NULL,
    form_id BIGINT NOT NULL,

    can_access BOOLEAN DEFAULT TRUE,

    CONSTRAINT fk_rfa_role
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_rfa_form
        FOREIGN KEY (form_id)
        REFERENCES forms(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_role_form UNIQUE (role_id, form_id)
);
INSERT INTO role_forms_access (role_id, form_id)
VALUES (2, 2);


select *from role_forms_access
delete from role_forms_access

select *from role_form_control_access
CREATE TABLE role_form_control_access (
    id BIGSERIAL PRIMARY KEY,

    role_id BIGINT NOT NULL,
    form_id BIGINT NOT NULL,
    control_id BIGINT NOT NULL,

    can_access BOOLEAN DEFAULT TRUE,

    CONSTRAINT fk_rfca_role
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_rfca_form
        FOREIGN KEY (form_id)
        REFERENCES forms(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_rfca_control
        FOREIGN KEY (control_id)
        REFERENCES controls(id)
        ON DELETE CASCADE,


    CONSTRAINT uq_role_form_control UNIQUE (role_id, form_id, control_id)
);

INSERT INTO role_form_control_access (role_id, form_id,control_id)
VALUES (2, 2,1);

select *from role_form_control_access
delete from role_form_control_access
CREATE TABLE form_status_master (
  form_id INT NOT NULL,
  status_code SMALLINT NOT NULL,
  status_name VARCHAR(50) NOT NULL,
  status_desc TEXT,
  is_active BOOLEAN DEFAULT true,
  PRIMARY KEY (form_id, status_code),
  FOREIGN KEY (form_id) REFERENCES forms(id)
);

INSERT INTO form_status_master VALUES
(1, 0, 'DRAFT',   'User draft'),
(1, 1, 'ACTIVE',  'Active user'),
(1, 2, 'LOCKED',  'Locked due to security'),
(1, 3, 'INACTIVE','Inactive user'); 


