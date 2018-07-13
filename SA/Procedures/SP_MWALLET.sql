CREATE OR REPLACE PROCEDURE sa."SP_MWALLET" (
    --------------------------------------------------------------------------------------------
    --$RCSfile: SP_MWALLET.sql,v $
    --$Revision: 1.7 $
    --$Author: ymillan $
    --$Date: 2013/05/07 18:32:50 $
    --$ $Log: SP_MWALLET.sql,v $
    --$ Revision 1.7  2013/05/07 18:32:50  ymillan
    --$ CR23514
    --$
    --$ Revision 1.4  2013/04/05 16:28:56  icanavan
    --$ break procedures into 2
    --$
    --$ Revision 1.3  2013/04/04 14:28:10  icanavan
    --$ ADDED A /
    --$
    --$ Revision 1.2  2012/12/24 17:33:43  icanavan
    --$ added new signature and remove link to ota database
    --$
    --------------------------------------------------------------------------------------------
    /*************************************************************************************************/
    /* Name    : SP_MWALLET                                                                          */
    /* Purpose : log with keys                                                                       */
    /* Platforms : Oracle 9i                                                                         */
    /* Author : CWL                                                                                  */
    /* Date : 12-18-2012                                                                             */
    /* REVISIONS:                                                                                    */
    /* VERSION DATE WHO PURPOSE                                                                      */
    /* ----- ----------  --------    --------------------------------------------                    */
    /* 1.1   12/18/2012  CLindner    Initial Version                                                 */
    /* 1.2   12/18/2012  CLindner    CR15626                                                         */
    /*************************************************************************************************/
    p_min IN VARCHAR2,
    p_mkey_num OUT NUMBER,
    p_mkey OUT VARCHAR2,
--
    p_out_objid out number,
    p_out_min  out varchar2,
    p_out_brand out varchar2,
    p_out_mkey_date out date,
    p_out_mkey_num out number,
    p_out_action_text out varchar2,
--
    p_brand out varchar2,
    p_status out varchar2)
IS
  CURSOR bus_org_curs
  IS
    SELECT (case when exists (SELECT 1
                                FROM x_sl_currentvals
                               WHERE x_current_esn= pi_esn.part_serial_no
                                 AND rownum         < 2) then
                   'SAFELINK'
                 else
                   bo.org_id
                 end) brand,
      --bo.org_id brand,
      NVL(
      (SELECT sp.part_status
      FROM table_site_part sp
      WHERE x_min      = pi_min.part_serial_no
      AND x_service_id = pi_esn.part_serial_no
      AND part_status  = 'Active'
      AND rownum       < 2
      ),'Inactive') part_status
    FROM table_part_inst pi_min,
      table_part_inst pi_esn,
      table_mod_level ml,
      table_part_num pn,
      table_bus_org bo
    WHERE pi_min.part_serial_no = p_min
    AND pi_esn.objid            = pi_min.part_to_esn2part_inst
    AND ml.objid                = pi_esn.n_part_inst2part_mod
    AND pn.objid                = ml.part_info2part_num
    AND bo.objid                = pn.part_num2bus_org;
    bus_org_rec bus_org_curs%rowtype;
  FUNCTION key_func(p_num IN NUMBER,
                    p_brand in varchar2)
    RETURN VARCHAR2
  IS
    CURSOR key_curs
    IS
      SELECT x_mkey
        FROM x_mwallet_key
       WHERE x_mkey_num = p_num
         and p_num != 3
         and x_brand = p_brand
      union
      SELECT x_mkey
        FROM x_mwallet_key
       WHERE x_mkey_num = p_num
         and p_num = 3
         and x_brand is null;
    key_rec key_curs%rowtype;
  BEGIN
    OPEN key_curs;
    FETCH key_curs INTO key_rec;
    CLOSE key_curs;
    RETURN key_rec.x_mkey;
  END;
  BEGIN
    OPEN bus_org_curs;
    FETCH bus_org_curs INTO bus_org_rec;
    IF bus_org_curs%notfound THEN
      p_mkey_num := 3;
      p_mkey     := key_func(p_mkey_num,null);
      p_brand    := null;
      p_status   := 'Inactive';
      CLOSE bus_org_curs;
      p_out_objid := sa.sequ_x_mwallet_log.nextval;
      p_out_min := p_min;
      p_out_brand := NULL;
      p_out_mkey_date := sysdate;
      p_out_mkey_num := 3;
      p_out_action_text := 'min not found';
      RETURN;
    END IF;
    CLOSE bus_org_curs;
    IF bus_org_rec.part_status = 'Active' AND bus_org_rec.brand = 'SAFELINK' THEN
      p_mkey_num              := 1;
      p_mkey                  := key_func(p_mkey_num,bus_org_rec.brand);
      p_brand                 := bus_org_rec.brand;
      p_status                := 'Active';
      p_out_objid := sa.sequ_x_mwallet_log.nextval;
      p_out_min := p_min;
      p_out_brand := bus_org_rec.brand;
      p_out_mkey_date := sysdate;
      p_out_mkey_num := 1;
      p_out_action_text := 'SAFELINK min found';
    elsif bus_org_rec.part_status = 'Active' AND bus_org_rec.brand != 'SAFELINK' THEN
      p_mkey_num                 := 2;
      p_mkey                     := key_func(p_mkey_num,bus_org_rec.brand);
      p_brand                    := bus_org_rec.brand;
      p_status                   := 'Active';
      p_out_objid := sa.sequ_x_mwallet_log.nextval;
      p_out_min := p_min;
      p_out_brand := bus_org_rec.brand;
      p_out_mkey_date := sysdate;
      p_out_mkey_num := 2;
      p_out_action_text :=  'non SAFELINK min found';
    ELSE
      p_mkey_num := 3;
      p_mkey     := key_func(p_mkey_num,null);
      p_brand    := null;
      p_status   := 'Inactive';
      p_out_objid := sa.sequ_x_mwallet_log.nextval;
      p_out_min := p_min;
      p_out_brand := null;
      p_out_mkey_date := sysdate;
      p_out_mkey_num := 3;
      p_out_action_text :=  'min not active';
    END IF;
  END;
/