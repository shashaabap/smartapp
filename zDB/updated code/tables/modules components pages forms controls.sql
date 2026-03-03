
--Modules
DROP TABLE IF EXISTS modules CASCADE;

CREATE TABLE modules (
    id           BIGSERIAL PRIMARY KEY,
    module_code  VARCHAR(50)  NOT NULL UNIQUE,   -- admin, sales, general 
    module_name  VARCHAR(100) NOT NULL,
    description  VARCHAR(255),
    display_order INT,

    status SMALLINT NOT NULL DEFAULT 1
        CHECK (status IN (0,1)),				-- 0:InActive, 1:Active

    created_by  BIGINT NOT NULL,
    created_dt  TIMESTAMP NOT NULL DEFAULT NOW(),
    modified_by BIGINT,
    modified_dt TIMESTAMP
);


INSERT INTO modules (module_code,module_name, description, created_by)
VALUES
('admin','Administration', 'Administration', 1);

select *From modules
--Sub-Modules
DROP TABLE IF EXISTS sub_modules CASCADE;

CREATE TABLE sub_modules (
    id             BIGSERIAL PRIMARY KEY,
    module_id      BIGINT NOT NULL,
    sub_module_code VARCHAR(50) NOT NULL,         -- USER_ACCESS, SYSTEM PARAMETERS
    sub_module_name VARCHAR(100) NOT NULL,
    description    VARCHAR(255),
    display_order  INT,

    status SMALLINT NOT NULL DEFAULT 1
        CHECK (status IN (0,1)),					-- 0:InActive, 1:Active


    created_by  BIGINT NOT NULL,
    created_dt  TIMESTAMP NOT NULL DEFAULT NOW(),
    modified_by BIGINT,
    modified_dt TIMESTAMP,

    CONSTRAINT fk_submodule_module
        FOREIGN KEY (module_id)
        REFERENCES modules(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_module_submodule UNIQUE (module_id, sub_module_code)
);

INSERT INTO sub_modules (module_id, sub_module_code,sub_module_name, description, created_by)
SELECT id,'user_mgmt','User Mgmt. & Access',  'User Management & Access Rights', 1
FROM modules WHERE module_code = 'admin';

select *from sub_modules

--Pages (level 3 i.e. last level of navigation)
DROP TABLE IF EXISTS pages CASCADE;

CREATE TABLE pages (
    id              BIGSERIAL PRIMARY KEY,
    sub_module_id   BIGINT NOT NULL,

    page_code       VARCHAR(50)  NOT NULL,          -- user_master, po_entry
    page_name       VARCHAR(150) NOT NULL,
    description     VARCHAR(255),

    route           VARCHAR(255) NOT NULL,          -- /user-master
    api_base_path   VARCHAR(255),                   -- /api/admin/users

    display_order   INT,

    status SMALLINT NOT NULL DEFAULT 1
        CHECK (status IN (0,1)),                     -- 0:Inactive, 1:Active

    created_by      BIGINT NOT NULL,
    created_dt      TIMESTAMP NOT NULL DEFAULT NOW(),
    modified_by     BIGINT,
    modified_dt     TIMESTAMP,

    CONSTRAINT fk_pages_submodule
        FOREIGN KEY (sub_module_id)
        REFERENCES sub_modules(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_submodule_page UNIQUE (sub_module_id, page_code)
);

ALTER TABLE pages
ADD CONSTRAINT chk_pages_route
CHECK (route LIKE '/%');


CREATE INDEX idx_pages_submodule ON pages(sub_module_id);
CREATE INDEX idx_pages_submodule_status
ON pages(sub_module_id, status, display_order);


CREATE INDEX idx_pages_route ON pages(route);


INSERT INTO pages
(sub_module_id, page_code, page_name, description, route, api_base_path, created_by)
SELECT
    id,
    'user_master',
    'User Master',
    'User Master',
    '/user-master',
    '/api/admin/users',
    1
FROM sub_modules
WHERE sub_module_code = 'user_mgmt';

select *from pages
--FORMS (UI COMPOSITION ONLY – NO SECURITY)

DROP TABLE IF EXISTS forms CASCADE;

CREATE TABLE forms (
    id            BIGSERIAL PRIMARY KEY,
    page_id       BIGINT NOT NULL,

    form_code     VARCHAR(100) NOT NULL,             -- user_master_main
    form_name     VARCHAR(150) NOT NULL,

    form_type     VARCHAR(20) NOT NULL
        CHECK (form_type IN ('MAIN','SEARCH','HELP','MODAL','EMBEDDED')),

    render_mode   VARCHAR(20) NOT NULL
        CHECK (render_mode IN ('TAB','EMBEDDED','MODAL','DRAWER')),

    display_order INT,

    status SMALLINT NOT NULL DEFAULT 1
        CHECK (status IN (0,1)),                     -- 0:Inactive, 1:Active

    created_by    BIGINT NOT NULL,
    created_dt    TIMESTAMP NOT NULL DEFAULT NOW(),
    modified_by   BIGINT,
    modified_dt   TIMESTAMP,

    CONSTRAINT fk_forms_page
        FOREIGN KEY (page_id)
        REFERENCES pages(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_page_form UNIQUE (page_id, form_code)
);


CREATE INDEX idx_forms_page ON forms(page_id);
/*
📌 Rule
Forms are rendered inside pages
No routing
No role access here
*/

INSERT INTO forms
(page_id, form_code, form_name, form_type, render_mode, display_order, created_by)
SELECT
    id,
    'user_master_main',
    'User Master',
    'MAIN',
    'EMBEDDED',
    1,
    1
FROM pages
WHERE page_code = 'user_master';

select *From forms

--CONTROLS (Atomic Permissions)

DROP TABLE IF EXISTS controls CASCADE;

CREATE TABLE controls (
    id           BIGSERIAL PRIMARY KEY,
    control_code VARCHAR(50)  NOT NULL UNIQUE,     -- CREATE, EDIT, DELETE
    control_name VARCHAR(100) NOT NULL,
    control_type VARCHAR(50)  NOT NULL,             -- Button, Link
    display_order INT,

    status SMALLINT NOT NULL DEFAULT 1
        CHECK (status IN (0,1)),

    created_by  BIGINT NOT NULL,
    created_dt  TIMESTAMP NOT NULL DEFAULT NOW(),
    modified_by BIGINT,
    modified_dt TIMESTAMP
);

/*
📌 Rule:
Controls = what a user can do, not where they can go.
*/
select *From Controls
INSERT INTO controls
(control_code,control_name, control_type, display_order, created_by)
VALUES  ('view','View', 'Button', 1, 1),
('save','Save', 'Button', 2, 1),
 ('create','Create', 'Button', 3, 1),
 ('edit','Edit', 'Button',4, 1), 
 ('authorise','Authorise', 'Button', 5, 1),
 ('delete','Delete', 'Button', 6, 1),
 ('generate','Generate', 'Button', 7, 1);
 
--PAGE ↔ CONTROL MAPPING
select *from controls
DROP TABLE IF EXISTS page_controls CASCADE;

CREATE TABLE page_controls (
    id         BIGSERIAL PRIMARY KEY,
    page_id    BIGINT NOT NULL,
    control_id BIGINT NOT NULL,

    status SMALLINT NOT NULL DEFAULT 1
        CHECK (status IN (0,1)),

    CONSTRAINT fk_pc_page
        FOREIGN KEY (page_id)
        REFERENCES pages(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_pc_control
        FOREIGN KEY (control_id)
        REFERENCES controls(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_page_control UNIQUE (page_id, control_id)
);

CREATE INDEX idx_page_controls_page ON page_controls(page_id);


INSERT INTO page_controls (page_id, control_id, status)
SELECT p.id, c.id, 1
FROM pages p
JOIN controls c ON c.control_code = 'save'
WHERE p.page_code = 'user_master';
--ROLE → PAGE ACCESS (Navigation Security)

select *From role_page_access


DROP TABLE IF EXISTS role_page_access CASCADE;

CREATE TABLE role_page_access (
    id      BIGSERIAL PRIMARY KEY,
	client_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    page_id BIGINT NOT NULL,

    can_access BOOLEAN DEFAULT TRUE,

    CONSTRAINT fk_rpa_role
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_rpa_page
        FOREIGN KEY (page_id)
        REFERENCES pages(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_role_page UNIQUE (role_id, page_id)
);
INSERT INTO role_page_access (role_id,client_id, page_id)
SELECT r.id,r.client_id, p.id
FROM roles r
JOIN pages p ON p.page_code = 'user_master'
WHERE r.role_code = 'admin'
ON CONFLICT (role_id, page_id) DO NOTHING;
select *From role_page_access
CREATE INDEX idx_role_page_access_role ON role_page_access(role_id);

CREATE INDEX idx_rpa_role_page_access
ON role_page_access(role_id, page_id)
WHERE can_access = TRUE;

--ROLE → PAGE → CONTROL ACCESS (Final Permission Layer)
DROP TABLE IF EXISTS role_page_control_access CASCADE;

CREATE TABLE role_page_control_access (
    id         BIGSERIAL PRIMARY KEY,
	client_id BIGINT NOT NULL,
    role_id    BIGINT NOT NULL,
    page_id    BIGINT NOT NULL,
    control_id BIGINT NOT NULL,

    can_access BOOLEAN DEFAULT TRUE,

    CONSTRAINT fk_rpca_role
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_rpca_page
        FOREIGN KEY (page_id)
        REFERENCES pages(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_rpca_control
        FOREIGN KEY (control_id)
        REFERENCES controls(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_role_page_control UNIQUE (role_id, page_id, control_id)
);


CREATE INDEX idx_rpca_role_page_control
ON role_page_control_access(role_id, page_id, control_id)
WHERE can_access = TRUE;

INSERT INTO role_page_control_access (role_id,client_id, page_id, control_id)
SELECT
    r.id,r.client_id,    p.id,    c.id
FROM roles r
JOIN pages p    ON p.page_code = 'user_master'
JOIN controls c ON c.control_code = 'save'
WHERE r.role_code = 'admin';
SELECT *fROM role_page_control_access

DROP TABLE IF EXISTS page_status_master CASCADE;

CREATE TABLE page_status_master (
    page_id     BIGINT NOT NULL,
    status_code SMALLINT NOT NULL,
    status_name VARCHAR(50) NOT NULL,    -- DRAFT, ACTIVE
    status_desc TEXT,
    is_active   BOOLEAN DEFAULT TRUE,

    PRIMARY KEY (page_id, status_code),

    CONSTRAINT fk_psm_page
        FOREIGN KEY (page_id)
        REFERENCES pages(id)
        ON DELETE CASCADE
);

INSERT INTO page_status_master VALUES
(1, 0, 'DRAFT',   'User draft'),
(1, 1, 'ACTIVE',  'Active user'),
(1, 2, 'LOCKED',  'Locked due to security'),
(1, 3, 'INACTIVE','Inactive user'); 
select *From page_status_master
--FINAL ARCHITECTURE (LOCK THIS)
/*
Navigation:
Module → Sub-Module → Page

UI:
Page → Forms → Controls

Security:
Role → Page → Control
*/
--Final DDL: form_controls
DROP TABLE IF EXISTS form_controls CASCADE;

CREATE TABLE form_controls (
    id BIGSERIAL PRIMARY KEY,

    form_id    BIGINT NOT NULL,
    control_id BIGINT NOT NULL,

    display_order INT,

    status SMALLINT NOT NULL DEFAULT 1
        CHECK (status IN (0,1)),

    created_by  BIGINT NOT NULL,
    created_dt  TIMESTAMP NOT NULL DEFAULT NOW(),
    modified_by BIGINT,
    modified_dt TIMESTAMP,

    CONSTRAINT fk_fc_form
        FOREIGN KEY (form_id)
        REFERENCES forms(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_fc_control
        FOREIGN KEY (control_id)
        REFERENCES controls(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_form_control UNIQUE (form_id, control_id)
);


CREATE INDEX idx_form_controls_form ON form_controls(form_id);
INSERT INTO form_controls
(form_id, control_id, display_order, status, created_by)
SELECT
    f.id,    
	c.id,    1,          -- display_order
	1,          -- status
    1           -- created_by
FROM forms f
JOIN pages p    ON p.id = f.page_id
JOIN controls c ON c.control_code = 'save'
WHERE p.page_code = 'user_master'
  AND f.form_code = 'user_master_main';


/*
This table answers one simple but powerful question:
“Which controls are designed to appear on this form?”
It does NOT decide permissions.
It only defines UI capability.
*/
/*
Final Architecture (Now COMPLETE)
Navigation
Module → Sub-Module → Page

UI Composition
Page → Forms → Form_Controls

Security
Role → Page → Control
*/


