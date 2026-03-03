
--CLIENTS (TENANTS)
DROP TABLE IF EXISTS clients CASCADE;

CREATE TABLE clients (
    id BIGSERIAL PRIMARY KEY,

    client_code VARCHAR(50) UNIQUE NOT NULL,     -- filatex, abc_edu
    client_name VARCHAR(150) NOT NULL,

    status SMALLINT NOT NULL CHECK (status IN (0,1)), --0=Inactive 1=Active, 

    effective_fr TIMESTAMP NOT NULL DEFAULT NOW(),
    effective_to TIMESTAMP,

    created_by BIGINT,
    created_dt TIMESTAMP NOT NULL DEFAULT NOW(),
    modified_by BIGINT,
    modified_dt TIMESTAMP
);

INSERT INTO clients (client_code, client_name, status)
VALUES
('default', 'Default Tenant', 1),
('filatex', 'Filatex India Ltd', 1),
('ra_bhageria', 'RA Bhageria Trust', 1);

--LOCATIONS (Schools / Offices / Plants)
DROP TABLE IF EXISTS locations CASCADE;

CREATE TABLE locations (
    id BIGSERIAL PRIMARY KEY,

    client_id BIGINT NOT NULL,

    location_code VARCHAR(50) NOT NULL,
    location_name VARCHAR(150) NOT NULL,

    parent_location_id BIGINT,

    status SMALLINT NOT NULL CHECK (status IN (0,1)), --0=Inactive 1=Active, 

    country VARCHAR(50),
    state   VARCHAR(50),
    city    VARCHAR(50),
    zip     VARCHAR(20),
    address VARCHAR(255),

    created_by BIGINT NOT NULL,
    created_dt TIMESTAMP NOT NULL DEFAULT NOW(),
    modified_by BIGINT,
    modified_dt TIMESTAMP,

    CONSTRAINT fk_location_client
        FOREIGN KEY (client_id) REFERENCES clients(id),

    CONSTRAINT fk_location_parent
        FOREIGN KEY (parent_location_id) REFERENCES locations(id),

    CONSTRAINT uq_location_client UNIQUE (client_id, location_code)
);

ALTER TABLE locations ENABLE ROW LEVEL SECURITY;


CREATE POLICY tenant_isolation_locations
ON locations
USING (client_id = current_setting('app.client_id')::bigint);




INSERT INTO locations
(client_id, location_code, location_name, parent_location_id, status, country, state, city, address, created_by)
SELECT c.id, 'DELHI_HO', 'Delhi Head Office', NULL, 1,
       'INDIA','DELHI','NEW DELHI','New Friends Colony',1
FROM clients c WHERE client_code='filatex';

INSERT INTO locations
(client_id, location_code, location_name, parent_location_id, status, country, state, city, address, created_by)
SELECT c.id, 'DAHEJ_PLANT', 'Dahej Plant', l.id, 1,
       'INDIA','GUJARAT','BHARUCH','GIDC Dahej',1
FROM clients c
JOIN locations l ON l.location_code='DELHI_HO'
WHERE c.client_code='filatex';


--USERS
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,

    client_id BIGINT NOT NULL,

    user_code VARCHAR(50) NOT NULL,          -- adminuser
    user_name VARCHAR(100) NOT NULL,
    user_pw   VARCHAR(255) NOT NULL,

    email  VARCHAR(100),
    mobile VARCHAR(20),

    status SMALLINT NOT NULL CHECK (status IN (0,1,2,3)), -- 0=Draft,1=Active,2=Locked,3=Inactive

    effective_fr TIMESTAMP NOT NULL,
    effective_to TIMESTAMP,

    failed_attempts SMALLINT NOT NULL DEFAULT 0,
    last_failed_login TIMESTAMP,
    last_login TIMESTAMP,

    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,

    created_by BIGINT NOT NULL,
    created_dt TIMESTAMP NOT NULL DEFAULT NOW(),
    modified_by BIGINT,
    modified_dt TIMESTAMP,

    CONSTRAINT fk_user_client
        FOREIGN KEY (client_id) REFERENCES clients(id),

    CONSTRAINT uq_user_client UNIQUE (client_id, user_code)
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY users_isolation
ON users
USING (client_id = current_setting('app.client_id')::bigint);

CREATE POLICY tenant_isolation_users
ON users
USING (client_id = current_setting('app.client_id')::bigint);

INSERT INTO users
(client_id, user_code, user_name, user_pw, status, effective_fr, created_by)
SELECT c.id, 'adminuser','Admin User',
       crypt('123@abc', gen_salt('bf',12)),
       1, NOW(), 1
FROM clients c WHERE client_code='filatex';

INSERT INTO users
(client_id, user_code, user_name, user_pw, status, effective_fr, created_by)
SELECT c.id, 'superuser','Super User',
       crypt('123@abc', gen_salt('bf',12)),
       1, NOW(), 1
FROM clients c WHERE client_code='filatex';

--ROLES
DROP TABLE IF EXISTS roles CASCADE;

CREATE TABLE roles (
    id BIGSERIAL PRIMARY KEY,

    client_id BIGINT NOT NULL,

    role_code VARCHAR(50) NOT NULL,       -- admin, super
    role_name VARCHAR(100) NOT NULL,

    status SMALLINT NOT NULL CHECK (status IN (0,1)), --0=Inactive 1=Active, 

    created_by BIGINT NOT NULL,
    created_dt TIMESTAMP NOT NULL DEFAULT NOW(),
    modified_by BIGINT,
    modified_dt TIMESTAMP,

    CONSTRAINT fk_role_client
        FOREIGN KEY (client_id) REFERENCES clients(id),

    CONSTRAINT uq_role_client UNIQUE (client_id, role_code)
);

ALTER TABLE roles ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation_roles
ON roles
USING (client_id = current_setting('app.client_id')::bigint);


INSERT INTO roles (client_id, role_code, role_name, status, created_by)
SELECT c.id,'admin','Admin Role',1,1
FROM clients c WHERE client_code='filatex';

INSERT INTO roles (client_id, role_code, role_name, status, created_by)
SELECT c.id,'super','Super Role',1,1
FROM clients c WHERE client_code='filatex';


--USER ↔ ROLE MAPPING
DROP TABLE IF EXISTS users_roles_mapping CASCADE;

CREATE TABLE users_roles_mapping (
    id BIGSERIAL PRIMARY KEY,

    client_id BIGINT NOT NULL,
    user_id   BIGINT NOT NULL,
    role_id   BIGINT NOT NULL,

    default_role BOOLEAN NOT NULL DEFAULT FALSE,

    status SMALLINT NOT NULL CHECK  (status IN (0,1)), --0=Inactive 1=Active, 

    created_by BIGINT NOT NULL,
    created_dt TIMESTAMP NOT NULL DEFAULT NOW(),
    modified_by BIGINT,
    modified_dt TIMESTAMP,

    CONSTRAINT fk_urm_client FOREIGN KEY (client_id) REFERENCES clients(id),
    CONSTRAINT fk_urm_user   FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_urm_role   FOREIGN KEY (role_id) REFERENCES roles(id),

    CONSTRAINT uq_user_role UNIQUE (client_id, user_id, role_id)
);

CREATE UNIQUE INDEX ux_default_role_per_user
ON users_roles_mapping (client_id, user_id)
WHERE default_role = TRUE;


ALTER TABLE users_roles_mapping ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation_users_roles_mapping
ON users_roles_mapping
USING (client_id = current_setting('app.client_id')::bigint);

INSERT INTO users_roles_mapping
(client_id, user_id, role_id, default_role, status, created_by)
SELECT
    c.id, u.id, r.id, TRUE, 1, 1
FROM clients c
JOIN users u ON u.user_code='adminuser'
JOIN roles r ON r.role_code='admin'
WHERE c.client_code='filatex';

CREATE INDEX idx_urm_user_default
ON users_roles_mapping(user_id)
WHERE default_role = TRUE AND status = 1;

--USER ↔ LOCATION MAPPING
DROP TABLE IF EXISTS users_locations_mapping CASCADE;
CREATE TABLE users_locations_mapping (
    id BIGSERIAL PRIMARY KEY,

    client_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    location_id BIGINT NOT NULL,

    default_location BOOLEAN NOT NULL DEFAULT FALSE,

    created_by BIGINT NOT NULL,
    created_dt TIMESTAMP NOT NULL DEFAULT NOW(),
    modified_by BIGINT,
    modified_dt TIMESTAMP,

    CONSTRAINT fk_ulm_client FOREIGN KEY (client_id) REFERENCES clients(id),
    CONSTRAINT fk_ulm_user   FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_ulm_loc    FOREIGN KEY (location_id) REFERENCES locations(id),

    CONSTRAINT uq_user_location UNIQUE (client_id, user_id, location_id)
);

CREATE UNIQUE INDEX ux_default_location_per_user
ON users_locations_mapping (client_id, user_id)
WHERE default_location = TRUE;

ALTER TABLE users_locations_mapping ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation_users_locations_mapping
ON users_locations_mapping
USING (client_id = current_setting('app.client_id')::bigint);

CREATE INDEX idx_ulm_user_default
ON users_locations_mapping(user_id)
WHERE default_location = TRUE;


INSERT INTO users_locations_mapping
(client_id, user_id, location_id, default_location, created_by)
SELECT c.id, u.id, l.id, TRUE, 1
FROM clients c
JOIN users u ON u.user_code='adminuser'
JOIN locations l ON l.location_code='DELHI_HO'
WHERE c.client_code='filatex';

--AUDIT LOG (TENANT-AWARE)
DROP TABLE IF EXISTS audit_log CASCADE;

CREATE TABLE audit_log (
    id BIGSERIAL PRIMARY KEY,

    client_id BIGINT NOT NULL,
    user_id BIGINT,

    action VARCHAR(50) NOT NULL,
    entity VARCHAR(100) NOT NULL,
    entity_id BIGINT,

    old_value JSONB,
    new_value JSONB,

    ip_address INET,
    user_agent TEXT,

    created_dt TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_audit_client FOREIGN KEY (client_id) REFERENCES clients(id),
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE SET NULL
);

ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;


CREATE POLICY tenant_isolation_audit_log
ON audit_log
USING (client_id = current_setting('app.client_id')::bigint);

--using posgres user
ALTER DATABASE smartapp_db
SET app.client_id = '0';


/*
🏁 FINAL SAAS CORE (LOCK THIS)
CLIENT
 ├── LOCATIONS (School / Office / Plant)
 │    └── USERS
 │         ├── ROLES
 │         └── LOCATIONS
 │
 └── AUDIT LOG

This foundation cleanly supports:
 School ERP (multi-school, multi-campus)
 HRMS / Payroll
 Manufacturing ERP
 SCM / Dispatch
 Secure SaaS isolation
*/
