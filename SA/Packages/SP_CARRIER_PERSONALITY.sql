CREATE OR REPLACE PACKAGE sa."SP_CARRIER_PERSONALITY"
AS
/******************************************************************************
* Package Specification: SP_CARRIER_PERSONALITY
* Description: This Package is designed to perform carrier personality updates/
*              create including updating personality flag for each related
*              lines.
*              Basically, the package is called by clarify form 1150
*
*   Digital TDMA updates:
*
*     If a change is made to any of the TDMA digital fields and only the
*     TDMA digital fields Part_inst2x_new_pers is flagged with the objid of
*     the new personality record for TDMA only
*     Part_inst2x _pers is set equal to the objid of the new personality
*     record for CDMA and Analog and part_inst2x_new_pers is left as NULL
*
*   Digital TDMA and Analog  updates:
*
*    If a change is made to any of the TDMA digital fields and the analog fields
*    Part_inst2x_new_pers is flagged with the objid of the new personality
*    record for all cases except for CDMA.
*    Part_inst2x _pers is set equal to the objid of the new personality record
*    for CDMA and part_inst2x_new_pers is left as NULL
*
*   Digital CDMA updates:
*     Not available
* Created by: SL
* Date:  06/14/2000
*
* History           Author             Reason
* -------------------------------------------------------------
* 06/14/01          SL                 Initail version
* 01/10/03          SU				   Added 3 new parameters for DMO
*********************************************************************************/
 procedure save(p_old_pers_objid number,
              p_carrier_id  number,
			  p_country_code number,
              p_soc_id varchar2,
              p_analog_change varchar2,
   		      p_digital_change varchar2,
			  p_restrict_ld number,
			  p_restrict_callop number,
			  p_restrict_intl number,
			  p_restrict_roam number,
			  p_restrict_inbound number,
			  p_restrict_outbound number,
			  p_inoutchange_flag varchar2,
			  p_master_sid varchar2,
			  p_master_type varchar2,
			  p_lsid_string varchar2,
			  p_lac_string varchar2,
			  p_freenum1 varchar2,
			  p_freenum2 varchar2,
			  p_freenum3 varchar2,
              p_favored  varchar2,
              p_neutral  varchar2,
              p_partner  varchar2,
			  p_status OUT varchar2,
			  p_msg OUT varchar2);
END SP_CARRIER_PERSONALITY;
/