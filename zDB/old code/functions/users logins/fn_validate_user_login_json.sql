
--SELECT fn_validate_user_login_json('SUPERUSER','123@abc')
CREATE OR REPLACE FUNCTION fn_validate_user_login_json
(
    p_user_id VARCHAR(20),
    p_password VARCHAR(255)
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user users%ROWTYPE;
BEGIN
    SELECT *
    INTO v_user
    FROM users
    WHERE user_id = p_user_id
      AND is_deleted = FALSE;

    IF NOT FOUND THEN
        RETURN json_build_object('error_id', 1, 'error_message', 'User not found');
    END IF;

    -- Secure password validation
    IF v_user.user_pw <> crypt(p_password, v_user.user_pw) THEN
        RETURN json_build_object('error_id', 2, 'error_message', 'Invalid password');
    END IF;

    IF v_user.status <> 1 THEN
        RETURN json_build_object('error_id', 3, 'error_message', 'User inactive');
    END IF;

    IF v_user.effective_fr > CURRENT_TIMESTAMP THEN
        RETURN json_build_object('error_id', 4, 'error_message', 'Account not active');
    END IF;

    IF v_user.effective_to IS NOT NULL
       AND v_user.effective_to < CURRENT_TIMESTAMP THEN
        RETURN json_build_object('error_id', 5, 'error_message', 'Account expired');
    END IF;

    RETURN json_build_object(
        'error_id', 0,
        'error_message', 'Login successful',
        'user', json_build_object(
            'id', v_user.id,
            'user_id', v_user.user_id,
            'user_name', v_user.user_name,
            'email', v_user.email,
			'failed_attempts',v_user.failed_attempts,
			'last_failed_login',v_user.last_failed_login
        ),
        'roles', COALESCE((
            SELECT json_agg(
                json_build_object(
                    'id', r.id,
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
        'locations', COALESCE((
            SELECT json_agg(
                json_build_object(
                    'id', l.id,
                    'location_id', l.location_id,
                    'location_name', l.location_name,
                    'default_location', ulm.default_location
                )
            )
            FROM users_locations_mapping ulm
            JOIN locations l ON l.id = ulm.location_id
            WHERE ulm.user_id = v_user.id
        ), '[]'::json)
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'error_id', 99,
            'error_message', SQLERRM
        );
END;
$$;


select *from users

UPDATE users
SET user_pw = crypt('123@abc', gen_salt('bf', 12))
WHERE user_id = 'SUPERUSER';

SELECT
  crypt('123@abc', user_pw) = user_pw AS password_ok
FROM users
WHERE user_id = 'SUPERUSER';
SELECT sp_validate_user_login_json('SUPERUSER', '123@abc');
