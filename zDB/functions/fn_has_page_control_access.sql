CREATE OR REPLACE FUNCTION fn_has_page_control_access(
    p_client_code  VARCHAR,
    p_user_code    VARCHAR,
    p_page_code    VARCHAR,
    p_control_code VARCHAR
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM clients cl
        JOIN users u ON u.client_id = cl.id
        JOIN users_roles_mapping urm ON urm.user_id = u.id
        JOIN role_page_control_access rpca ON rpca.role_id = urm.role_id
        JOIN pages p ON p.id = rpca.page_id
        JOIN controls c ON c.id = rpca.control_id
        WHERE cl.client_code = p_client_code
          AND u.user_code = p_user_code
          AND p.page_code = p_page_code
          AND c.control_code = p_control_code
          AND rpca.can_access = TRUE
          AND urm.status = 1
    );
END;
$$;