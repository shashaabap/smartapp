
--users table

CREATE TABLE users (
    id            BIGSERIAL PRIMARY KEY,

    user_id       VARCHAR(20) UNIQUE NOT NULL,
    user_name     VARCHAR(100) NOT NULL,
    user_pw       VARCHAR(255) NOT NULL, -- hashed password

    email         VARCHAR(100),
    mobile        VARCHAR(20),

    status        SMALLINT NOT NULL
                  CHECK (status IN (1, 2, 3)), -- 1=Active, 2=Inactive, 3=Locked

    effective_fr  TIMESTAMP NOT NULL,
    effective_to  TIMESTAMP,

    is_deleted    BOOLEAN NOT NULL DEFAULT FALSE,

    created_by    BIGINT NOT NULL,
    created_dt    TIMESTAMP NOT NULL DEFAULT NOW(),

    modified_by   BIGINT,
    modified_dt   TIMESTAMP,
	failed_attempts SMALLINT NOT NULL DEFAULT 0,
    last_failed_login TIMESTAMP,
    last_login TIMESTAMP
);

CREATE UNIQUE INDEX idx_users_user_id ON users(user_id);
CREATE INDEX idx_users_status ON users(status);
--Prevent Overlapping Effective Dates (Advanced)
CREATE INDEX idx_users_effective
ON users (user_id, effective_fr, effective_to);

CREATE UNIQUE INDEX ux_active_user
ON users(user_id)
WHERE is_deleted = FALSE;

INSERT INTO users (
    user_id,
    user_name,
    user_pw,
    status,
    effective_fr,
    created_by
)
VALUES (
    'ADMINUSER',
    'Admin User',
    '123@abc',
    1,
    NOW(),
    1
);

INSERT INTO users (
    user_id,
    user_name,
    user_pw,
    status,
    effective_fr,
    created_by
)
VALUES (
    'SUPERUSER',
    'Super User',
    '123@abc',
    1,
    NOW(),
    1
);

UPDATE users
SET user_pw = crypt('123@abc', gen_salt('bf', 12))
WHERE user_id = 'ADMINUSER';

UPDATE users
SET user_pw = crypt('123@abc', gen_salt('bf', 12))
WHERE user_id = 'SUPERUSER';

select *From users

delete from users_roles_mapping
delete from roles
delete from users_locations_mapping
delete from users

--roles table
CREATE TABLE roles (
    id           BIGSERIAL PRIMARY KEY,

    role_id      VARCHAR(20) UNIQUE NOT NULL,
    role_name    VARCHAR(100) NOT NULL,

    status       SMALLINT NOT NULL
                 CHECK (status IN (1, 2)), -- 1 = Active, 2 = Inactive

    created_by   BIGINT NOT NULL,
    created_dt   TIMESTAMP NOT NULL DEFAULT NOW(),

    modified_by  BIGINT,
    modified_dt  TIMESTAMP
);


INSERT INTO roles (role_id, role_name, status, created_by)
VALUES ('ADMINROLE','Admin Role',1,1),
       ('SUPERROLE','Super Role',1,1);

select *from roles	   




--users roles mapping table
CREATE TABLE users_roles_mapping (
    id BIGSERIAL PRIMARY KEY,

    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,

    default_role SMALLINT,  -- 1 = Default, 0 / NULL = Not default

    status SMALLINT NOT NULL
           CHECK (status IN (1, 2)), -- 1 = Active, 2 = Inactive

    created_by BIGINT NOT NULL,
    created_dt TIMESTAMP NOT NULL DEFAULT NOW(),

    modified_by BIGINT,
    modified_dt TIMESTAMP
);
CREATE INDEX idx_urm_user_id ON users_roles_mapping(user_id);
CREATE INDEX idx_urm_role_id ON users_roles_mapping(role_id);

ALTER TABLE users_roles_mapping
ADD CONSTRAINT fk_urm_user
FOREIGN KEY (user_id)
REFERENCES users(id)
ON DELETE RESTRICT;

ALTER TABLE users_roles_mapping
ADD CONSTRAINT fk_urm_role
FOREIGN KEY (role_id)
REFERENCES roles(id)
ON DELETE RESTRICT;

ALTER TABLE users_roles_mapping
ADD CONSTRAINT uq_user_role UNIQUE (user_id, role_id);


CREATE UNIQUE INDEX ux_default_role_per_user
ON users_roles_mapping (user_id)
WHERE default_role = 1;

UPDATE users_roles_mapping
SET default_role = 0
WHERE default_role IS NULL;


ALTER TABLE users_roles_mapping
ADD CONSTRAINT chk_default_role
CHECK (default_role IN (0, 1));




select *from users
select *from roles


SELECT *fROM users_roles_mapping
INSERT INTO users_roles_mapping
(
    user_id,    role_id,    default_role,    status,    created_by
)
VALUES
--(1, 1, 1, 1, 1),  -- Default role
(2, 2,1, 1, 1);  -- Secondary role

--Location table

CREATE TABLE locations (
    id BIGSERIAL PRIMARY KEY,

    location_id VARCHAR(20) UNIQUE NOT NULL,
    location_name VARCHAR(100) NOT NULL,

    parent_location_id BIGINT NULL,

    status SMALLINT NOT NULL
           CHECK (status IN (1, 2)), -- 1 = Active, 2 = Inactive

    country VARCHAR(50),
    state VARCHAR(50),
    city VARCHAR(50),
    zip VARCHAR(20),

    phone VARCHAR(20),
    mobile VARCHAR(20),
    email VARCHAR(100),
    address VARCHAR(255),

    created_by BIGINT NOT NULL,
    created_dt TIMESTAMP NOT NULL DEFAULT NOW(),

    modified_by BIGINT,
    modified_dt TIMESTAMP
);
ALTER TABLE locations
ADD CONSTRAINT fk_locations_parent
FOREIGN KEY (parent_location_id)
REFERENCES locations(id)
ON DELETE SET NULL;

CREATE INDEX idx_locations_parent_id ON locations(parent_location_id);
CREATE INDEX idx_locations_status ON locations(status);

INSERT INTO locations
(
    location_id,    location_name,    parent_location_id,    status,    country,    state,    city,    zip,    
	phone,    mobile,    email,    address, created_by,    created_dt,    modified_by,    modified_dt
)
VALUES
(
    'DELHI',    'DELHI OFFICE',    NULL,    1,    'INDIA',    'DELHI',    'NEW DELHI',    '110025',    NULL,
    NULL,    NULL,    'Corporate office: 43, Community Centre, New Friends Colony',    1,    NOW(),    NULL,    NULL
),
(
    'DAHEJ',    'DAHEJ PLANT',    1,    1,    'INDIA',    'GUJARAT',    'BHARUCH',    '392130',    NULL,    NULL,    NULL,
    'Plot No. 2/6 A, Village Jolva Dahej-2, Industrial Estate, GIDC Dahej',    1,    NOW(),    NULL,    NULL
),
(
    'DADRA',    'DADRA PLANT',    1,    1,    'INDIA',    'DADRA & NAGAR HAVELI',    'DADRA',    '396193',    NULL,    NULL,
    NULL,    'Survey No.274, Demni Road',    1,    NOW(),    NULL,    NULL
);

select * from locations

update locations
set 

--users location mapping
CREATE TABLE users_locations_mapping (
    id BIGSERIAL PRIMARY KEY,

    user_id BIGINT NOT NULL,
    location_id BIGINT NOT NULL,

    default_location BOOLEAN NOT NULL DEFAULT FALSE,

    created_by BIGINT NOT NULL,
    created_dt TIMESTAMP NOT NULL DEFAULT NOW(),

    modified_by BIGINT,
    modified_dt TIMESTAMP
);
ALTER TABLE users_locations_mapping
ADD CONSTRAINT fk_ulm_user
FOREIGN KEY (user_id)
REFERENCES users(id)
ON DELETE RESTRICT;

ALTER TABLE users_locations_mapping
ADD CONSTRAINT fk_ulm_location
FOREIGN KEY (location_id)
REFERENCES locations(id)
ON DELETE RESTRICT;

ALTER TABLE users_locations_mapping
ADD CONSTRAINT uq_user_location UNIQUE (user_id, location_id);

CREATE UNIQUE INDEX ux_default_location_per_user
ON users_locations_mapping (user_id)
WHERE default_location = TRUE;


CREATE INDEX idx_ulm_user_id ON users_locations_mapping(user_id);
CREATE INDEX idx_ulm_location_id ON users_locations_mapping(location_id);


INSERT INTO users_locations_mapping
(
    user_id,    location_id,    default_location,    created_by,    created_dt,    modified_by,    modified_dt
)
VALUES
(
    1,          -- user_id
    1,          -- location_id
    TRUE,       -- default_location
    1,          -- created_by
    NOW(),
    NULL,
    NULL
);

INSERT INTO users_locations_mapping
(
    user_id,    location_id,    default_location,    created_by,    created_dt,    modified_by,    modified_dt
)
VALUES
(
    2,          -- user_id
    2,          -- location_id
    TRUE,       -- default_location
    1,          -- created_by
    NOW(),
    NULL,
    NULL
);


SELECT * FROM users_locations_mapping;


-- Table: audit_log
INSERT INTO audit_log (user_id, action, entity)
VALUES (1, 'TEST', 'users');

SELECT current_database(), current_schema();
-- DROP TABLE IF EXISTS audit_log;
select *From audit_log
CREATE TABLE audit_log
(
    id BIGSERIAL PRIMARY KEY,

    user_id BIGINT NULL,   -- ✅ must be nullable
    action VARCHAR(50) NOT NULL,
    entity VARCHAR(100) NOT NULL,
    entity_id BIGINT,

    old_value JSONB,
    new_value JSONB,

    ip_address INET,
    user_agent TEXT,

    created_dt TIMESTAMP NOT NULL DEFAULT now(),

    CONSTRAINT fk_audit_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE SET NULL
);
ALTER TABLE IF EXISTS public.audit_log
OWNER TO smartapp_user;

CREATE INDEX IF NOT EXISTS idx_audit_action
ON public.audit_log (action);

CREATE INDEX IF NOT EXISTS idx_audit_entity
ON public.audit_log (entity, entity_id);

CREATE INDEX IF NOT EXISTS idx_audit_user_dt
ON public.audit_log (user_id, created_dt DESC);

SELECT * FROM audit_log ORDER BY created_dt DESC;


