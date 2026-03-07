--select fn_get_user_access_json('filatex','superuser')
CREATE OR REPLACE FUNCTION fn_get_user_access_json
(
    p_client_code VARCHAR(50),
    p_user_code   VARCHAR(50)
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user   users%ROWTYPE;
    v_client clients%ROWTYPE;
BEGIN
    -- Resolve client
    SELECT *
    INTO v_client
    FROM clients
    WHERE client_code = p_client_code
      AND status = 1;

    IF NOT FOUND THEN
        RETURN json_build_object('error_id', 10, 'error_message', 'Invalid client');
    END IF;

    -- Resolve user
    SELECT *
    INTO v_user
    FROM users
    WHERE client_id = v_client.id
      AND user_code = p_user_code
      AND is_deleted = FALSE
      AND status = 1;

    IF NOT FOUND THEN
        RETURN json_build_object('error_id', 1, 'error_message', 'Invalid user');
    END IF;

    RETURN json_build_object(
        'error_id', 0,

        /* ================= USER ================= */
        'user', json_build_object(
            'id', v_user.id,
            'user_code', v_user.user_code,
            'user_name', v_user.user_name,
            'email', v_user.email
        ),

        /* ================= ROLES ================= */
        'roles', COALESCE((
            SELECT json_agg(
                json_build_object(
                    'role_code', r.role_code,
                    'role_name', r.role_name,
                    'default_role', urm.default_role
                )
            )
            FROM users_roles_mapping urm
            JOIN roles r ON r.id = urm.role_id
            WHERE urm.user_id = v_user.id
              AND urm.client_id = v_client.id
              AND urm.status = 1
        ), '[]'::json),

        /* ================= LOCATIONS ================= */
        'locations', COALESCE((
            SELECT json_agg(
                json_build_object(
                    'location_code', l.location_code,
                    'location_name', l.location_name,
                    'default_location', ulm.default_location
                )
            )
            FROM users_locations_mapping ulm
            JOIN locations l ON l.id = ulm.location_id
            WHERE ulm.user_id = v_user.id
              AND ulm.client_id = v_client.id
        ), '[]'::json),

        /* ================= NAVIGATION ================= */
        'pages', COALESCE((
            SELECT json_agg(
                json_build_object(
                    'page_code', p.page_code,
                    'page_name', p.page_name,
                    'route', p.route,
                    'api_base_path', p.api_base_path
                )
            )
            FROM role_page_access rpa
            JOIN pages p ON p.id = rpa.page_id
            JOIN users_roles_mapping urm ON urm.role_id = rpa.role_id
            WHERE urm.user_id = v_user.id
              AND rpa.client_id = v_client.id
              AND rpa.can_access = TRUE
        ), '[]'::json),

        /* ================= CONTROLS ================= */
        'controls', COALESCE((
            SELECT json_agg(
                json_build_object(
                    'page_code', p.page_code,
                    'control_code', c.control_code,
                    'control_name', c.control_name,
                    'control_type', c.control_type
                )
            )
            FROM role_page_control_access rpca
            JOIN pages p ON p.id = rpca.page_id
            JOIN controls c ON c.id = rpca.control_id
            JOIN users_roles_mapping urm ON urm.role_id = rpca.role_id
            WHERE urm.user_id = v_user.id
              AND rpca.client_id = v_client.id
              AND rpca.can_access = TRUE
        ), '[]'::json)
    );
END;
$$;