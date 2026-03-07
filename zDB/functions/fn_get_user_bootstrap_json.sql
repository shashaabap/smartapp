--SELECT fn_get_user_bootstrap_json('filatex','adminuser');

-- DROP FUNCTION IF EXISTS public.fn_get_user_bootstrap_json(character varying, character varying);

CREATE OR REPLACE FUNCTION public.fn_get_user_bootstrap_json(
    p_client_code VARCHAR,
    p_user_code   VARCHAR
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $BODY$

DECLARE
    v_client      clients%ROWTYPE;
    v_user        users%ROWTYPE;
    v_role        roles%ROWTYPE;
    v_location    locations%ROWTYPE;

    v_menu        JSONB;
    v_permissions JSONB;

BEGIN

    -- 1️ Resolve Client
    SELECT * INTO v_client
    FROM clients
    WHERE client_code = p_client_code
      AND status = 1;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('error','Invalid client');
    END IF;

    PERFORM set_config('app.client_id', v_client.id::text, true);

    -- 2️ Resolve User
    SELECT * INTO v_user
    FROM users
    WHERE client_id = v_client.id
      AND user_code = p_user_code
      AND is_deleted = false
      AND status = 1;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('error','Invalid user');
    END IF;

    -- 3️ Default Role
    SELECT r.*
    INTO v_role
    FROM users_roles_mapping urm
    JOIN roles r ON r.id = urm.role_id
    WHERE urm.user_id = v_user.id
      AND urm.default_role = TRUE
      AND urm.status = 1;

    -- 4️ Default Location
    SELECT l.*
    INTO v_location
    FROM users_locations_mapping ulm
    JOIN locations l ON l.id = ulm.location_id
    WHERE ulm.user_id = v_user.id
      AND ulm.default_location = TRUE;

    -- 5️ MENU (CTE Optimized)

    WITH role_pages AS (
        SELECT p.id,
               p.page_name,
               p.route,
               p.sub_module_id
        FROM role_page_access rpa
        JOIN pages p ON p.id = rpa.page_id
        WHERE rpa.role_id = v_role.id
          AND rpa.can_access = TRUE
          AND p.status = 1
    ),

    submodule_tree AS (
        SELECT sm.id,
               sm.sub_module_name,
               sm.module_id,
               jsonb_agg(
                   jsonb_build_object(
                       'page_name', rp.page_name,
                       'route', rp.route
                   )
                   ORDER BY rp.page_name
               ) AS pages
        FROM sub_modules sm
        JOIN role_pages rp ON rp.sub_module_id = sm.id
        WHERE sm.status = 1
        GROUP BY sm.id
    ),

    module_tree AS (
        SELECT m.id,
               m.module_name,
               jsonb_agg(
                   jsonb_build_object(
                       'sub_module', st.sub_module_name,
                       'pages', st.pages
                   )
                   ORDER BY st.sub_module_name
               ) AS sub_modules
        FROM modules m
        JOIN submodule_tree st ON st.module_id = m.id
        WHERE m.status = 1
        GROUP BY m.id
    )

    SELECT jsonb_agg(
               jsonb_build_object(
                   'module', module_name,
                   'sub_modules', sub_modules
               )
               ORDER BY module_name
           )
    INTO v_menu
    FROM module_tree;


    -- 6️ CONTROL PERMISSIONS (CTE Optimized)

    WITH role_controls AS (
        SELECT
            p.route,
            c.control_code
        FROM role_page_control_access rpca
        JOIN pages p    ON p.id = rpca.page_id
        JOIN controls c ON c.id = rpca.control_id
        WHERE rpca.role_id = v_role.id
          AND rpca.can_access = TRUE
    )

    SELECT jsonb_object_agg(route, controls_array)
    INTO v_permissions
    FROM (
        SELECT
            route,
            jsonb_agg(control_code ORDER BY control_code) AS controls_array
        FROM role_controls
        GROUP BY route
    ) t;

    -- 7️ Final JSON

    RETURN jsonb_build_object(
        'client', jsonb_build_object(
            'id', v_client.id,
            'code', v_client.client_code,
            'name', v_client.client_name
        ),
        'user', jsonb_build_object(
            'id', v_user.id,
            'user_code', v_user.user_code,
            'user_name', v_user.user_name
        ),
        'role', jsonb_build_object(
            'id', v_role.id,
            'role_code', v_role.role_code,
            'role_name', v_role.role_name
        ),
        'location', jsonb_build_object(
            'id', v_location.id,
            'code', v_location.location_code,
            'name', v_location.location_name
        ),
        'menu', COALESCE(v_menu, '[]'::jsonb),
        'permissions', COALESCE(v_permissions, '{}'::jsonb)
    );

END;
$BODY$;

