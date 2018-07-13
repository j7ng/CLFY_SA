CREATE OR REPLACE PACKAGE sa."VERIFY_PHONE_UPGRADE_PKG" AS
/****************************************************************************
      NAME:       verify_phone_upgrade_pkg
      PURPOSE:
      REVISIONS:
      Version    Date        Author          Description
      ---------  ----------  --------------- --------------------------------
      1.1        10/25/2006  IC /            Initial Revision.
      1.2        01/23/08    CL              CR6578
*****************************************************************************/
--
--
  PROCEDURE verify (ip_str_old_esn   IN       VARCHAR2,
                    ip_str_new_esn   IN       VARCHAR2,
                    ip_str_zip       IN       VARCHAR2,
                    ip_str_iccid     IN       VARCHAR2,
                    op_carrier_id    OUT      VARCHAR2,
                    op_error_text    OUT      VARCHAR2,
                    op_error_num     OUT      VARCHAR2);
--
--
  PROCEDURE upgrade (ip_str_old_esn   IN       VARCHAR2,
                     ip_str_new_esn   IN       VARCHAR2,
                     ip_str_zip       IN       VARCHAR2,
                     ip_str_iccid     IN       VARCHAR2,
                     op_carrier_id    OUT      VARCHAR2,
                     op_error_text    OUT      VARCHAR2,
                     op_error_num     OUT      VARCHAR2);
--
--
  PROCEDURE validate_swap_sim_prc (p_from_esn         IN    VARCHAR2,
                                   p_to_esn           IN    VARCHAR2,
                                   p_zip              IN    VARCHAR2,
                                   p_org_id           IN    table_bus_org.org_id%TYPE,
                                   p_source_system    IN    VARCHAR2,
                                   op_swap_sim_flag   OUT   NUMBER, -- 1 or 0
                                   op_er_cd           OUT   NUMBER,
                                   op_msg             OUT   VARCHAR2);
--
--
  PROCEDURE verify_wrapper (ip_str_old_esn   IN    VARCHAR2,
                            ip_str_new_esn   IN    VARCHAR2,
                            ip_str_zip       IN    VARCHAR2,
                            ip_str_iccid     IN    VARCHAR2,
                            ip_channel       IN    VARCHAR2,
                            op_carrier_id    OUT   VARCHAR2,
                            op_error_text    OUT   VARCHAR2,
                            op_error_num     OUT   VARCHAR2,
                            op_warning_code  OUT   VARCHAR2);
--
--
  PROCEDURE update_contact_optout (ip_old_esn      IN    VARCHAR2,
                                   ip_new_esn      IN    VARCHAR2,
                                   ip_channel      IN    VARCHAR2 DEFAULT NULL,
                                   ip_org_id       IN    table_bus_org.org_id%TYPE DEFAULT 'WFM',
                                   ip_off_flag     IN    VARCHAR2 DEFAULT 'N',
                                   op_error_text   OUT   VARCHAR2,
                                   op_error_num    OUT   VARCHAR2);
--
--
END verify_phone_upgrade_pkg;
/