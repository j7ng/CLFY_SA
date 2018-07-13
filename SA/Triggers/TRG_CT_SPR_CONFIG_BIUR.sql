CREATE OR REPLACE TRIGGER sa."TRG_CT_SPR_CONFIG_BIUR" BEFORE INSERT OR UPDATE ON sa.x_mtm_ct_spr_config REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
 --------------------------------------------------------------------------------------------
 --$RCSfile: trg_ct_spr_config_biur.sql,v $
  --$Revision: 1.1 $
  --$Author: aganesan $
  --$Date: 2015/07/06 15:38:04 $
  --$ $Log: trg_ct_spr_config_biur.sql,v $
  --$ Revision 1.1  2015/07/06 15:38:04  aganesan
  --$ CR36122 - New trigger created on insert or update on x_mtm_ig_spr_config table.
  --$
  --$ Revision 1.9  2015/03/10 22:33:53  jpena
  --$ CR29586 - Super Carrier
  --$
  --------------------------------------------------------------------------------------------

BEGIN
  :NEW.update_timestamp := SYSDATE;
END;
/