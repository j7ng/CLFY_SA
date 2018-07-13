CREATE OR REPLACE PROCEDURE sa."SP_DETACH_ICCID" ( ip_esn   IN  VARCHAR2 ,
                                              ip_iccid IN  VARCHAR2 ) AS
  l_objid  NUMBER;
  --- ----------------------------------------------------------------------------------------------
  -- Author: vnainar/usivaraman
  -- Date: 2016/01/31
  -- <CR# 39197>
  -- This procedure will Remove iccid(update to null) from table_part_inst when iccid exists for another new ESN with part_status=50
  -- -----------------------------------------------------------------------------------------------
  -- VERSION  DATE       WHO           PURPOSE
  -- -------  ---------- ----------     ------------------------------------------------------------
  --  1.0     01/31/2016 vnainar/       CR39197 Remove iccid(update to null) from table_part_inst when iccid exists
  --                     usivaraman             for another new ESN with part_status=50
  -- -------  ---------- ----------     ------------------------------------------------------------
BEGIN

  --
  IF  ip_esn IS NULL AND ip_iccid IS NULL THEN
    RETURN;
  END IF;

  BEGIN
    SELECT objid
    INTO   l_objid
    FROM   Table_part_inst
    WHERE  x_iccid        = ip_iccid
    AND    part_serial_no  <> ip_esn
    AND    x_part_inst_status = 50
    AND    x_domain = 'PHONES'
    AND    ROWNUM = 1;
   EXCEPTION
     WHEN OTHERS THEN
       RETURN;
  END;

  IF  l_objid IS NOT NULL THEN
    -- Remove iccid(update to null) from table_part_inst when iccid exists for another new ESN with part_status=50
    UPDATE table_part_inst tpi
    SET    tpi.x_iccid = null
    WHERE  objid = l_objid;
  END IF;

 EXCEPTION
   WHEN OTHERS THEN
     ota_util_pkg.err_log ( p_action       => 'Updating table_part_inst',
                            p_error_date   => SYSDATE,
                            p_key          => ip_esn,
                            p_program_name => 'sp_detach_iccid',
                            p_error_text   => sqlerrm );
END sp_detach_iccid;
/