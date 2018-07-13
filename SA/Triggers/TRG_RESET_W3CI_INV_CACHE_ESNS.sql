CREATE OR REPLACE TRIGGER sa."TRG_RESET_W3CI_INV_CACHE_ESNS"
--
  ---------------------------------------------------------------------------------------------
  --$RCSfile: trg_reset_w3ci_inv_cache_esns.sql,v $
  --$Revision: 1.10 $
  --$Author: skota $
  --$Date: 2017/02/24 21:38:34 $
  --$ $Log: trg_reset_w3ci_inv_cache_esns.sql,v $
  --$ Revision 1.10  2017/02/24 21:38:34  skota
  --$ removed the DBMS printing
  --$
  --$ Revision 1.9  2016/10/14 14:02:45  vlaad
  --$ Added condition for not firing triggers for Go Smart Migration
  --$
  --$ Revision 1.8  2015/08/31 21:21:13  aganesan
  --$ CR37016 changes.
  --$
  --$ Revision 1.1  2015/08/04 14:18:05  jpena
  --$ Changes
  --$
  --$ Revision 1.1  2015/08/04 11:49:58  jpena
  --$ Trigger to process w3ci esns
  --$
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
AFTER INSERT OR UPDATE ON sa.x_account_group_member
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE

  l_min           VARCHAR2(30);
  l_bus_org_objid NUMBER(22);
  l_bus_org_id    VARCHAR2(100);
BEGIN
 -- Go Smart changes
 -- Do not fire trigger if global variable is turned off
  if not sa.globals_pkg.g_run_my_trigger then
    return;
  end if;
-- End Go Smart changes

  BEGIN
    SELECT bus_org_objid
    INTO   l_bus_org_objid
    FROM   x_account_group
    WHERE  objid = NVL(:NEW.account_group_id,:OLD.account_group_id);
   EXCEPTION
     WHEN others THEN
       --DBMS_OUTPUT.PUT_LINE('group not found');
       NULL;
  END;

  IF l_bus_org_objid IS NOT NULL THEN
    BEGIN
      SELECT org_id
      INTO   l_bus_org_id
      FROM   table_bus_org
      WHERE  objid = l_bus_org_objid;
     EXCEPTION
       WHEN others THEN
         --DBMS_OUTPUT.PUT_LINE('failed getting brand');
         NULL;
    END;
  END IF;

  --DBMS_OUTPUT.PUT_LINE('new reset started');

  -- ONLY perform this validation for TOTAL WIRELESS (shared groups)
  IF ( sa.brand_x_pkg.get_shared_group_flag ( ip_bus_org_id => sa.util_pkg.get_bus_org_id ( i_esn => NVL(:NEW.esn, :OLD.esn) ) ) = 'Y' OR
       sa.brand_x_pkg.get_shared_group_flag ( ip_bus_org_id => l_bus_org_id ) = 'Y'
     ) AND
     UPPER( NVL(:NEW.status, :OLD.status)) <> 'EXPIRED' -- for ACTIVE members only
  THEN

    --DBMS_OUTPUT.PUT_LINE('getting min');

    -- Get the MIN
    BEGIN
      SELECT pi_min.part_serial_no min
      INTO   l_min
      FROM   table_part_inst pi_esn,
             table_part_inst pi_min
      WHERE  1 = 1
      AND    pi_esn.part_serial_no = NVL(:NEW.esn, :OLD.esn)
      AND    pi_esn.x_domain = 'PHONES'
      AND    pi_min.part_to_esn2part_inst = pi_esn.objid
      AND    pi_min.x_domain = 'LINES'
      AND    ROWNUM = 1;
     EXCEPTION
       WHEN others THEN
         NULL;
    END;

    -- Blank out MIN with it's temporary
    IF l_min LIKE 'T%' THEN
      l_min := NULL;
    END IF;

    -- ONLY insert when the MIN is available
    --DBMS_OUTPUT.PUT_LINE('before insert statement');

    -- Insert into global temporary table
    BEGIN
      INSERT
      INTO   sa.gtt_reset_w3ci_esns
             ( esn,
               min,
               account_group_id,
               master_flag
             )
      VALUES
      ( NVL(:NEW.esn, :OLD.esn),
        l_min,
        NVL(:NEW.account_group_id,:OLD.account_group_id),
        NVL(:NEW.master_flag,:OLD.master_flag)
      );
      --DBMS_OUTPUT.PUT_LINE('gtt rowcount => ' || SQL%ROWCOUNT);
     EXCEPTION
       WHEN others THEN
         --DBMS_OUTPUT.PUT_LINE('error inserting => ' || SQLERRM);
         NULL;
    END;

    --
   -- DBMS_OUTPUT.PUT_LINE('after end if');

  END IF; -- IF sa.brand_x_pkg.get_shared_group_flag ...

  --DBMS_OUTPUT.PUT_LINE('ended reset');

 EXCEPTION
   WHEN OTHERS THEN
     --
     -- DBMS_OUTPUT.PUT_LINE('error in reset => ' || SQLERRM);
     -- Do not fail if there are exceptions
     NULL;
END;
/