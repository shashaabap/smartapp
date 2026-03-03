-- FUNCTION: fn_has_form_control_access(character varying, character varying, character varying)

-- DROP FUNCTION IF EXISTS fn_has_form_control_access(character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION fn_has_form_control_access(
	p_user_id character varying,
	p_form_name character varying,
	p_control_name character varying)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE SECURITY DEFINER PARALLEL UNSAFE
    SET search_path=public
AS $BODY$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM users u
        JOIN users_roles_mapping urm
             ON urm.user_id = u.id
            AND urm.status = 1
        JOIN role_form_control_access rfca
             ON rfca.role_id = urm.role_id
            AND rfca.can_access = TRUE
        JOIN forms f
             ON f.id = rfca.form_id
            AND f.form_name = p_form_name
        JOIN controls c
             ON c.id = rfca.control_id
            AND c.control_name = p_control_name
        WHERE u.user_id = p_user_id
    );
END;
$BODY$;

ALTER FUNCTION fn_has_form_control_access(character varying, character varying, character varying)
    OWNER TO smartapp_user;

