--SELECT fn_get_user_access_json('SUPERUSER');

CREATE OR REPLACE FUNCTION fn_get_user_access_json
(
    p_user_id VARCHAR(20)
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user users%ROWTYPE;
BEGIN
    -- Fetch user
    SELECT *
    INTO v_user
    FROM users
    WHERE user_id = p_user_id
      AND is_deleted = FALSE
      AND status = 1;

    IF NOT FOUND THEN
        RETURN json_build_object(
            'error_id', 1,
            'error_message', 'Invalid user'
        );
    END IF;

    RETURN json_build_object(
        'error_id', 0,

        /* ================= USER ================= */
        'user', json_build_object(
            'id', v_user.id,
            'user_id', v_user.user_id,
            'user_name', v_user.user_name,
            'email', v_user.email,			
			'failed_attempts',v_user.failed_attempts,
			'last_failed_login',v_user.last_failed_login
        ),

        /* ================= ROLES ================= */
        'roles', COALESCE((
            SELECT json_agg(
                json_build_object(
                    'role_id', r.role_id,
                    'role_name', r.role_name,
                    'default_role', urm.default_role
                )
            )
            FROM users_roles_mapping urm
            JOIN roles r ON r.id = urm.role_id
            WHERE urm.user_id = v_user.id
              AND urm.status = 1
        ), '[]'::json),

        /* ================= LOCATIONS ================= */
        'locations', COALESCE((
            SELECT json_agg(
                json_build_object(
                    'location_id', l.location_id,
                    'location_name', l.location_name,
                    'default_location', ulm.default_location
                )
            )
            FROM users_locations_mapping ulm
            JOIN locations l ON l.id = ulm.location_id
            WHERE ulm.user_id = v_user.id
        ), '[]'::json),

        /* ================= PERMISSIONS ================= */
        'permissions', json_build_object(

            /* -------- FORMS -------- */
						'forms', COALESCE((
			    SELECT json_agg(
			        json_build_object(
			            'form_id', x.form_id,
			            'form_name', x.form_name,
			            'page_id', x.page_id,
			            'route', x.route
			        )
			    )
			    FROM (
			        SELECT DISTINCT
			            f.id AS form_id,
			            f.form_name,
			            f.page_id,
			            f.route
			        FROM users_roles_mapping urm
			        JOIN role_forms_access rfa ON rfa.role_id = urm.role_id
			        JOIN forms f ON f.id = rfa.form_id
			        WHERE urm.user_id = v_user.id
			          AND rfa.can_access = TRUE
			    ) x
			), '[]'::json),


            /* -------- CONTROLS -------- */
 'controls', COALESCE((
    SELECT json_agg(
        json_build_object(
            'form_id', x.form_id,
            'control_id', x.control_id,
            'control_name', x.control_name,
            'control_type', x.control_type
        )
    )
    FROM (
        SELECT DISTINCT
            f.id AS form_id,
            c.id AS control_id,
            c.control_name,
            c.control_type
        FROM users_roles_mapping urm
        JOIN role_form_control_access rfca
             ON rfca.role_id = urm.role_id
        JOIN controls c ON c.id = rfca.control_id
        JOIN forms f ON f.id = rfca.form_id
        WHERE urm.user_id = v_user.id
          AND rfca.can_access = TRUE
    ) x
), '[]'::json)
        )
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'error_id', 99,
            'error_message', SQLERRM
        );
END;
$$;
