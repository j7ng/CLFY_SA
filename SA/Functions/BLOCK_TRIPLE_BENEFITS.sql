CREATE OR REPLACE FUNCTION sa.BLOCK_TRIPLE_BENEFITS (i_esn in varchar2)
RETURN VARCHAR2 IS
 /*****************************************************************
 * Purpose : To get BLOCK_TRIPLE_MIN_CONV PartClass attribute value for the provided ESN
 *
 * Platform : Oracle 8.0.6 and newer versions.
 * Created by : Maulik Dave (mdave)
 * Date : 03/13/2017
 * History
 * REVISIONS VERSION DATE WHO PURPOSE
 * ------------------------------------------------------------- */
l_block_triple_benefits_flag varchar2(1);
BEGIN

    IF i_esn IS NULL THEN
      RETURN 'N';
    END IF;

    BEGIN --{
    SELECT
     DISTINCT pv.PARAM_VALUE INTO l_block_triple_benefits_flag
     FROM sa.TABLE_PART_INST pi,
     sa.TABLE_MOD_LEVEL ml,
     sa.TABLE_PART_NUM pn,
     sa.TABLE_BUS_ORG bo,
     sa.TABLE_PART_CLASS pc,
     sa.PC_PARAMS_VIEW pv
     WHERE 1=1
     AND pi.x_domain             = 'PHONES'
     AND pi.n_part_inst2part_mod = ml.objid
     AND ml.part_info2part_num   = pn.objid
     And pn.part_num2bus_org     = bo.objid
     AND pn.part_num2part_class  = pc.objid
     AND pc.objid                = pv.pc_objid
     AND pv.param_name           = 'BLOCK_TRIPLE_MIN_CONV'
     AND pi.part_serial_no       = i_esn
     AND ROWNUM                  <= 1;
    EXCEPTION
    WHEN OTHERS THEN
     NULL;
    END;  --}

IF NVL(l_block_triple_benefits_flag,'N') = 'Y'
THEN --{
    BEGIN --{
     SELECT 'N'
     INTO   l_block_triple_benefits_flag
     FROM   table_x_group2esn g2e,
            table_x_promotion txp,
            table_part_inst   pi
     WHERE  g2e.GROUPESN2PART_INST   =  pi.objid
     AND    g2e.GROUPESN2X_PROMOTION =  txp.objid
     AND    g2e.X_END_DATE           >=  SYSDATE
     AND    txp.x_promo_code         =  '3XMN_UPG'
     AND    pi.x_domain              =  'PHONES'
     AND    pi.part_serial_no        =  i_esn
     AND    ROWNUM                   <= 1;
    EXCEPTION
    WHEN OTHERS THEN
     l_block_triple_benefits_flag := 'Y';
    END; --}
END IF; --}

RETURN NVL(l_block_triple_benefits_flag,'N');



  EXCEPTION
  WHEN no_data_found THEN
       RETURN 'N';

   WHEN OTHERS THEN
	   RETURN null;
END;
/