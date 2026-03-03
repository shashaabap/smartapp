--select fn_validate_user_login_json('filatex','superuser','123@abc')
CREATE OR REPLACE FUNCTION fn_validate_user_login_json
(
    p_client_code VARCHAR(50),
    p_user_code   VARCHAR(50),
    p_password    VARCHAR(255)
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

    -- Fetch user
    SELECT *
    INTO v_user
    FROM users
    WHERE client_id = v_client.id
      AND user_code = p_user_code
      AND is_deleted = FALSE;

    IF NOT FOUND THEN
        RETURN json_build_object('error_id', 1, 'error_message', 'User not found');
    END IF;

    -- Password check
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
        'client', json_build_object(
            'client_id', v_client.id,
            'client_code', v_client.client_code,
            'client_name', v_client.client_name
        ),
        'user', json_build_object(
            'id', v_user.id,
            'user_code', v_user.user_code,
            'user_name', v_user.user_name,
            'email', v_user.email,
            'failed_attempts', v_user.failed_attempts,
            'last_failed_login', v_user.last_failed_login
        )
    );
END;
$$;