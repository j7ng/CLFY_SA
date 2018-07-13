CREATE OR REPLACE TRIGGER sa."TRG_IG_SPR_CONFIG_BIUR" BEFORE INSERT OR UPDATE ON sa.x_mtm_ig_spr_config REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
 --------------------------------------------------------------------------------------------
 --$RCSfile: trg_ig_spr_config_biur.sql,v $
  --$Revision: 1.1 $
  --$Author: aganesan $
  --$Date: 2015/07/06 15:39:32 $
  --$ $Log: trg_ig_spr_config_biur.sql,v $
  --$ Revision 1.1  2015/07/06 15:39:32  aganesan
  --$ CR36122 - New trigger created for insert or update on x_mtm_ig_spr_config table
  --$
  --$ Revision 1.9  2015/03/10 22:33:53  jpena
  --$ CR29586 - Super Carrier
  --$
  --------------------------------------------------------------------------------------------

BEGIN
  :NEW.update_timestamp := SYSDATE;
END;
/