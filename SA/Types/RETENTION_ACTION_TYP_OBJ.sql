CREATE OR REPLACE TYPE sa."RETENTION_ACTION_TYP_OBJ" FORCE IS OBJECT(dest_plan_id      NUMBER,
                                                              dest_red_card_pin VARCHAR2(20),
                                                              ret_action        VARCHAR2(50),
                                                              warning_id        VARCHAR2(50),
                                                              STATIC FUNCTION initialize RETURN retention_action_typ_obj)
/
CREATE OR REPLACE TYPE BODY sa."RETENTION_ACTION_TYP_OBJ" AS
  STATIC FUNCTION initialize RETURN retention_action_typ_obj IS
  BEGIN
    RETURN(retention_action_typ_obj(NULL,
                                    NULL,
                                    NULL,
									NULL));
  END initialize;
END;
/