CREATE OR REPLACE PROCEDURE sa."NAP_DIGITAL" (
   /***********************************************************************************************/
   /* Copyright (r) 2001 Tracfone Wireless Inc. All rights reserved                               */
   /*                                                                                             */
   /* Name         :   nap_digital                                                                */
   /* Purpose      :   Reserves a line                                                            */
   /* Parameters   :                                                                              */
   /* Platforms    :   Oracle 8.0.6 AND newer versions                                            */
   /* Author       :                                                                              */
   /* Date         :   07/11/2001                                                                 */
   /* Revisions    :                                                                              */
   /*                                                                                             */
   /* Version  PVCS Revision  Date        Who             Purpose                                 */
   /* -------  -------------  ----------  -------         --------------------------------------  */
   /* **************************************************************************************************/
   /* NEW CVS STRUCTURE /PLSQL/SA/PROCEDURES
   /* 1.3    05/05/2010   NGuada    CR10777 Zip code Activation - Phase 1 TMO
                                            Add table CARRIERSIMPREF to cursor c_sim_carr_info
   /* 1.4    05/10/2010   Skuthadi  CR11971 ST_GSM NON_PPE will use brand name and 1,0 values
                                            also modified gsm_get_default_carrier_prc              */
   /* 1.5    07/14/2010   Skuthadi  CR13250 ST_GSM_II
   /* 1.6    08/18/2010   PM        CR13531 STCC PM We found Multiple Part Num with different Domain. */
   /* 1.8    09/08/2010   NGuda     CR13085                                         */
   /*1.10    10/20/2010   NGuda     CR14598           */
   /*1.11    10/22/2010   NGuda     CR14598           */
   /*1.12    12/02/2010   CLindner  CR15018 --12/02/10 invalid number fix                                     */
   /*1.15    01/06/2010   KACOSTA   CR14714 (Change was done by CLINDER) In get_carriers_prc procedure for both
                                            c_prf_carrier and c_dflt_carrier added an AND clause to make sure the
                                            carrier feature works for same bus org*/
   /*1.16    04/06/2011   CLindner  CR13234                                      */
   /*1.18    08/16/2011   Skuthadi  CR16308 SPRINT                                      */
   /*1.25    10/24/2012   ICanavan  ACMI    ACME project
   /*1.27    04/04/2013   Clindner  CR22451 Simple Mobile System Integration - WEBCSR */
   /*2.00    09/08/2016   vboddeda  CR40137 NAP fix to return a NEW phone part number as exchange option if
                                            exchange is for a NEW phone or within first X days from activation*/
/****************************************************************************************/
   /* OLD PVCS STRUCTURE /NEW_PLSQL/CODE
   /* 1.20       08/31/09     NGuada   BRAND_SEP Separate the Brand and Source System
   /*                                  incorporate use of new table TABLE_BUS_ORG to retrieve
   /*                                  brand information that was previously identified by the fields
   /*                                  x_restricted_use and/or amigo from table_part_num
   /* 1.19       06/02/2009   Ymillan  Merge 8663 and 8396
   /* 1.17/1.18  05/14/09     VAdapa   Fix for dealer preferred
   /* 1.16       04/24/09     CLindner CR8663 WALMART SWITCHBASED LOGIC
   /* 1.15       03/24/2009   Ymillan  Merge CR8396 and 8406
   /* 1.12- 1.13 02/03/09     CLindner CR8396  create GSM default Carrier List with
   /*                                  the SafeLink DealerID and not the Default DealerID.
   /* 1.5.2.11  11/03/08        Vadapa      Applied proper grants
   /* 1.5.2.10  09/24/08        CLindner    Latest fix for port-ins
   /* 1.5.2.9   09/10/08        CLindner    Latest code changes to return the right reserved lines
   /* 1.5.2.8   09/05/08        CLindner    CDMA NA
   /* 1.5.2.7    05/21/08       NGuada      TMOData fixes
   /* 1.5.2.6   05/15/08        VAdapa      TMOData merged with latest production copy as of 05/15/08
   /*1.5.2.4/5   05/13/08        VAdapa      CR7356 - LG 300 fix
    /*1.5.2.3   04/30/08        Clindner    POST 10G fixes
    /*1.5.2.2   04/24/08        Clindner    POST 10G fixes
    /*1.5.2.1   02/08/08        CLindner    CR6925 - Fixed for a defect logged against CR6916 (added the NETCSR sourcesystem)
/*1.11      04/15/08        VAdapa    Removed CR7105 changes as per the business owner
/*1.10      04/14/08        VAdapa    Removed the grants to PUBLIC
/*1.9       04/11/08        VAdapa    Merged the latest code with TMODATA
/*1.7/1.8   01/29/08        VAdapa    Merged CR7105
/*1.5.1.0   01/28/08        Clindner    CR7105 - NAP 'No lines Available'
    /*1.5.2.1   02/08/08        CLindner    CR6925 - Fixed for a defect logged against CR6916 (added the NETCSR sourcesystem)
    /*1.5.2.0   11/06/07        CLindner    CR6925 - Carrier preference changes (NAP)
/*1.6   01/21/07        NGuada      TMODATA -TMO Data - Block Not Certify Models
/*1.5   10/31/07        Clindner    CR6911 - Fix Nap DIGITAL  invalid cursor issue(CBO)
/*1.4   10/30/07        CLindner    CR6909 - Fix for reactivations of '51' with new SIMs
/*1.3   10/09/07        CLindner    CR6830 (Carrier pref logic added in CR6623 is deployed using this CR)
/****************************************************************************************************/
   /* 4.66     1.94.1.3       08/29/07       Clindner           CR6623 Tmobile reativation
/* 4.65     1.94.1.2       08/21/07       Clindner           CR6623 Tmobile reativation
/* 4.64     1.94.1.1       08/20/07       Clindner           CR6623 Tmobile reativation
/* 4.63     1.94/1.94.1.0  07/27/07       CLindner           CR6520 - SIM Card Exchange Issue
/* 4.62        1.93           07/19/07       CLindner           CR6049 - Q2 Handsets --> Modfied to return replacement part
/*                                                               for the new NET10 models (CDMA)
/* 4.61     1.92.0         06/12/07    ABarrera         Merged CR6363
/* 4.61     1.91.0         06/12/07    ABarrera         CR6254 Meid modifications to handle 18 digits
/* 4.60     1.90.1.0       06/12/07      CLindner           CR6363 - Reactivations of past due customers beyond their grace period.
/* 4.59        1.90           05/11/07      CLindner           CR6269 - MINC ERRORS
/* 4.58        1.89           04/04/07   CLindner            CR6125 - Dobson changes
/* 4.58        1.87           04/04/07   CLindner            CR6125 - Dobson changes
/* 4.57        1.86           `02/28/07 VAdapa               Merged CR5150
/* 4.56     1.82.2.4    11/20/06    VAdapa         Fixed CR5757
/* 4.55     1.82.2.2 /3    11/14/06      TZhou       Changed to the correct revision
/* 4.55     1.82.2.1     11/10/06      TZhou       Changed to the correct revision
/* 4.54     1.82.2.0     11/10/06      TZhou       CR5757
/* 4.53     1.82        10/24/06       N. Lalovic      CR5568
/*                                     Changes in GSM Activatiion logic:
/*                                     If line is reserved AND min carrier is the same as esn carrier
/*                                     return the reserved line
/* 4.52     1.81        10/20/06       N. Lalovic      CR5568
/*                                     Changes in GSM Activatiion logic:
/*                                     1. If carrier is T-MOBILE and phone IS data capable -
/*                                        DON'T even go into "is line reserved" logic exit the program here.
/*                                        Get the SIM card replacement number and RETURN "SIM Exchange" msg.
/*                                     2. Do "is line resrved" logic. Find out if we have reserved line.
/*                                     4. If YES - RETURN reserved line. No additional conditions, just return it.
/*                                     5. If NO  - check if our carrier is "No inventory carrier".
/*                                        case YES: - stop the program here.
/*                                                    For T-MOBILE carrier return "No inventory carrier" msg.
/*                                                    For Cingular carrier return either "No inventory carrier" msg
/*                                                    or "Cingular rate center does not exist for given ZIP code."
/*                                        case NO - continue
/* 4.51     1.80  110/13/06      NL                CR5568
/* 4.50     1.79      10/10/06   VA          CR5653 -  Fix the NAP DIGITAL
/* 4.59     1.78        07/27/06    VA          CR4902 - Fix to return the correct technology exchange message
/* 4.58     1.77        07/10/06    VA          CR4902 - Fix to return the ACTIVE parent
/* 4.57     1.76        06/28/06    VA          CR4902 - Added extra OUT parameter to return the preferred carrier
/* 4.56     1.75      06/13/06     VA        CR4960-1 Defects fix for data services #603
/* 4.55     1.74        06/08/06     VA            CR5349 - Fix for OPEN_CURSORS
/* 4.54     1.73        05/19/06     VA            Fix for CR4981_4982 - Defect #477 & #509
/* 4.55     1.72        05/19/06     VA            Fix for CR4981_4982 - Defect #350
                                          To return replacement part if activating a data phone in
                                          a CDMA/TDMA only zip
/* 4.54     1.71        05/19/06     VA            Fix for CR4981_4982 - Used the right array
/* 4.53     1.70        05/17/06     VA            Merged cR4981_4982 changes with CR4588  */
   /* 4.52     1.69           05/09/06     NL             Merged changes for:                     */
   /*                                                     Fix FOR CR5028                          */
   /*                                                     Emergency fix for CR5028                */
   /*                                                     CR5192                                  */
   /*                                                     Fix FOR CR5192                          */
   /*                                                     into CR4588 version.                    */
   /* 4.51     1.68           03/16/06     NL             Merged CR5028 chg into CR4588 version.  */
   /*                                                     Changes in TDMA logic for Cingular.     */
   /* 4.50                    02/23/06     NL             Merged CR5040 changes into CR4588 ver.  */
   /*                                                     Changes in Carrier Prefference logic    */
   /* 4.49                    02/15/06     NL             For Cingular GSM reactivations:         */
   /*                                                     When NAP finds out that the status of an*/
   /*                                                     ESN is used and that the status of the  */
   /*                                                     SIM card is used, it checks to see if   */
   /*                                                     there is a line reserved for that ESN.  */
   /*                                                     If there is no line reserved for the    */
   /*                                                     given ESN, instead of returning         */
   /*                                                     "No Inventory carrier", it returns      */
   /*                                                     "SIM exchange".                         */
   /*                                                     If there is a line reserved for the     */
   /*                                                     ESN it returns "No Inventory carrier"   */
   /* 4.48                    02/02/06     NL             For Cingular GSM activations:           */
   /*                                                     Return reserved number if phone upgrade */
   /*                                                     was requested and the phone is reserved */
   /*                                                     in our database. It doesn't matter if we*/
   /*                                                     we have no inventory carrier or not     */
   /* 4.47                    01/31/06     NL             For Cingular GSM activations:           */
   /*                                                     Return MIN number if the line is        */
   /*                                                     reserved and line status is 37 or 39,   */
   /*                                                     if not - return message                 */
   /*                                                     "No inventory carrier"                  */
   /*                                                     PVCS revision 1.63                      */
   /* 4.46                    01/23/06     NL             For Cingular Next Available logic:      */
   /*                                      ****************************************************** */
   /*                                      **** NOTE ***  THIS IS ONLY TEMPORARY SOLUTION TO TURN */
   /*                                      *************  ON OR OFF NEXT AVAILABLE LOGIC FOR      */
   /*                                      *************  PARTICULAR CINGULAR MARKET.             */
   /*                                      *************  THIS LOGIC WILL EVENTUALY BE REMOVED!!! */
   /*                                      ****************************************************** */
   /*                                                     If next available flag on table_x_parent*/
   /*                                                     is turned ON (value set to 1) we need to*/
   /*                                                     query temp table X_NEXT_AVAIL_CARRIER to*/
   /*                                                     see if the particular X_CARRIER_ID from table*/
   /*                                                     TABLE_X_CARRIER exists in the temp table*/
   /*                                                     If yes, we will proceed with Next Available*/
   /*                                                     logic (No inventory carrier). If not, we*/
   /*                                                     will bypass it and try to reserve the   */
   /*                                                     number from inventory in our database.  */
   /* 4.45                    01/19/06     NL             For Cingular GSM reactivations:         */
   /*                                                     Modified gsm_is_iccid_valid4react_fun.  */
   /*                                                     If GSM carrier is Cingular, regardless  */
   /*                                                     of is it "no inventory carrier" or not, */
   /*                                                     we will always execute the logic that   */
   /*                                                     queries c_cingular_mrkt_info table which*/
   /*                                                     determines if the phone needs sim       */
   /*                                                     card exchange.                          */
   /* 4.44                    01/04/06     NL             For Cingular GSM reactivations:         */
   /*                                                     Return MIN number if the line is        */
   /*                                                     reserved with status 37 or 39           */
   /*                                                     PVCS revision 1.60                      */
   /* 4.33                    12/29/05     NL             For GSM reactivation No Inventory       */
   /*                                                     carrier logic happens before "MIN       */
   /*                                                     is already attached" logic              */
   /*                                                     PVCS version 1.59                       */
   /* 4.32                    12/29/05     NL             For GSM activation SIM card validation  */
   /*                                                     logic goes before No inventory carrier  */
   /*                                                     logic. PVCS version 1.58                */
   /* 4.31                    12/19/05     NL             Changes for Cingular next available     */
   /*                                                     PVCS version 1.57                       */
   /* 4.30                    12/07/05     GC             Completely changed technology selection */
   /*                                                     policy in get_repl_part sub-proc        */
   /*                                                     All techs are evaluated looking for best*/
   /*                                                     priority phone (PVCS Revision 1.53)     */
   /* 4.29                    11/23/05     GC             Removed technology rank supremacy over  */
   /*                                                     exchange options x_priority             */
   /*                                                     Allows to analize all options of all    */
   /*                                                     technologies and decide over x_priority */
   /*                                                     value                                   */
   /*                                                     (PVCS Revision 1.52)                    */
   /* 4.28                    11/16/05     GC             Fixed issue with priority on            */
   /*                                                     get_repl_part , added 'asc' on cursor   */
   /*                                                     c_repl_part                             */
   /*                                                     (PVCS Revision 1.51)                    */
   /* 4.27                    11/09/05     VA             Changed a SIM exchange message for      */
   /*                                                     profile check (PVCS Revision 1.50)      */
   /* 4.26                    11/08/05     GC             Added SIM marriage verification by-pass */
   /*                                                     in "is_valid_iccid" function            */
   /*                                                     (PVCS revision 1.49)                    */
   /* 4.25                    11/07/05     VA             Combined changes (CR4590 and CR4579)    */
   /*                                                     PVCS Revision 1.48                      */
   /* 4.24                    10/13/05     GP             CR4579 - Get Carrier Rules by Technology*/
   /*                                                     (PVCS Revision 1.47)                    */
   /* 4.22                    08/08/05     VA             Checked in with the correct version     */
   /*                                                     label CR4375 (PVCS Revision 1.43)       */
   /* 4.21                    08/08/05     VA             CR4347 - Insert a record into           */
   /*                                                     NAP_C_CHOICE for "No NET-10 Coverage"   */
   /*                                                     (PVCS Revision 1.42)                    */
   /* 4.20                    08/02/05     VA             CR4371 - Emergency Fix (Modifed based   */
   /*                                                     on Curt's recommendations to improve    */
   /*                                                     the performance)                        */
   /*                                                     (PVCS Revision 1.41)                    */
   /* 4.19                    06/27/05     VA             CR4212 - Bug Fix (PVCS Revision 1.40)   */
   /* 4.18                    06/24/05     VA             EME Fix for CR3918 (PVCS Revision 1.39) */
   /*                                                     (No MIN change if the latest deact      */
   /*                                                     reason is "NON TOPP LINE"               */
   /* 4.17                    06/14/05     VA             CR4017 - SIM Errors and ACT/REACT FLOW  */
   /*                                                     WEBCSR (1.38)                           */
   /* 4.16                    06/09/05     VA             CR3918 - Fix added to get the previous  */
   /*                                                     sim only for non-T MIN numbers (1.37)   */
   /*                                                     Since CR3918 was rolled back, used the  */
   /*                                                     same CR# in the header                  */
   /* 4.15                    06/03/05     VA             CR4117 - Check for markets only if old  */
   /*                                                     and new sim are same (1.36)             */
   /* 4.14                    05/31/05     VA             Check for different markets only if it  */
   /*                                                     is Cingular (1.35)                      */
   /* 4.13                    05/26/05     VA             Correct PVCS Revision # 1.34            */
   /* 4.12                    05/26/05     VA             Fix to check for "150" status           */
   /*                                                     - gsm_is_a_react_fun                    */
   /*                                                     (PVCS Version 1.33)                     */
   /* 4.11                    05/11/05     VA             Merged CR3918 with CR3824               */
   /*                                                     (PVCS Revision 1.32)                    */
   /* 4.10                    05/10/05     VA             Fix for CR3918                          */
   /*                                                     Same zip return "no min"                */
   /*                                                     PVCS Version 1.31)                      */
   /* 4.9                     05/09/05     VA             Fix for CR3918                          */
   /*                                                     - No same zone/st check for Cingular    */
   /*                                                     - Return "NO CINGULAR COVERAGE" message */
   /*                                                     - Check for market only for same sims   */
   /* 4.8                     05/04/05     VA             Fix for a bug for CR3918 found during   */
   /*                                                     testing (PVCS Version 1.29)             */
   /* 4.7                     05/03/05     VA             CR3918 - New Project_ Cingular change   */
   /*                                                     MSISDN (PVCS Version 1.28)              */
   /* 4.6                     05/10/05     VA             CR3824 - WEBCSR upgrade flow            */
   /* 4.5                     05/02/05     VA             CR3885 -  Project SIM 4 for all Cingular*/
   /*                                                     GSM activations (PVCS Revision 1.27)    */
   /* 4.4                     04/18/05     VA             CR3910 - NEW LINES for GSM customers    */
   /*                                                     whenever possible (PVCS Revision 1.26)  */
   /* 4.3                     03/14/05     VA             CR3647 - T-Mobile Min Change            */
   /* 4.2                     12/09/04     VA             CR3327(1)-Portability Automation changes*/
   /* 4.1                     12/14/04     VA             CR3190 - NET10 Changes                  */
   /* 4.0                     02/01/05     VA             CR3614 - EME Nap Changes                */
   /* 3.9                     01/07/05     VA             CR3527 - EME Nap Verify Fix             */
   /* 3.8                     12/07/04     VA             CR3459 - Fix for GSM reacts that give   */
   /*                                                     "No Lines Available" message in non-GSM */
   /*                                                     zipcodes                                */
   /* 3.7                     11/30/04     VA             CR3437(MT57585) Modify Nap Verify to not*/
   /*                                                     reserve lines                           */
   /* 3.6                     11/03/04     VA             CR3338 Changes : GSM Activation /       */
   /*                                                     Reactivation Logic                      */
   /* 3.5                     11/03/04     VA             CR3310 - Check for inactive site part   */
   /*                                                     record (gsm_react_65_90_fun)            */
   /* 3.4                     10/15/04     VA             CR2620 - Carrier Automation Phase III   */
   /* 3.3                     08/08/04     CL             CR3153: Return new message for no       */
   /*                                                     inventory carrier                       */
   /* 3.2                     07/09/04     VA             CR2739: CASE Modifications              */
   /*                                                     Use x_gsm_grace_period field instead of */
   /*                                                     x_line_expire_days                      */
   /* 3.1                     05/26/04     VA             CR2672: Fix to return the reserved line */
   /*                                                     for a new activation                    */
   /* 3.0                     05/20/04     GP             CR2824: Changed p_msg when no carrier   */
   /*                                                     found.                                  */
   /* 2.9                     04/13/04     CWL            To put the carriers (preferred/default) */
   /*                                                     in the right order - Separate in 2 loops*/
   /* 2.8                     04/07/04     VAdapa         change to check for pref technology     */
   /*                                                     (as per Dan Driscoll)                   */
   /* 2.7                     11/14/03     VAdapa         change for # portability (technology)   */
   /* 2.6                     11/09/03     CWL            change for # portability                */
   /* 2.5                     08/22/03     ML             Added branching logic fro GSM. It was   */
   /*                                                     to the developer to 'clone' the exiting */
   /*                                                     nap logic for GSM.                      */
   /* 2.4                     03/25/03     SL             Optimize quries that use bad index      */
   /*                                                                                             */
   /* 2.3                     12/30/02     D. Driscoll    Motorola Digital (1900 MHz) addition    */
   /* 2.2                     10/03/02     VAdapa         AMIGO Changes                           */
   /* 2.1                     08/14/02     ???            ???                                     */
   /* 2.0                     06/18/02     VAdapa         Remove D Choice logic, but keep         */
   /*                                                     reporting                               */
   /* 1.1                                                                                         */
   /* 1.0                     07/11/01                    Initial revision                        */
   /* NEW CVS STRUCTURE PLEASE SEE ON THE TOP                                                     */
   /*                                                                                             */
   /***********************************************************************************************/
   p_zip IN VARCHAR2,
   p_esn IN VARCHAR2,
   p_commit IN VARCHAR2
   DEFAULT 'YES',
   p_language IN VARCHAR2
   DEFAULT 'English',
   p_sim IN VARCHAR2,
   p_source IN VARCHAR2,
   p_upg_flag IN VARCHAR2
   DEFAULT 'N',
   p_repl_part OUT VARCHAR2,
   p_repl_tech OUT VARCHAR2,
   p_sim_profile OUT VARCHAR2,
   p_part_serial_no OUT VARCHAR2,
   p_msg OUT VARCHAR2,
   p_pref_parent OUT VARCHAR2, --CR4902
   p_pref_carrier_objid OUT VARCHAR2 --CR4902
)
IS
-- ************************************************************************** --
   -- * NAP_DIGITAL procedure                                                  * --
   -- * DECLARATION section of the local variables, types etc STARTS here      * --
   -- ************************************************************************** --
   -------
   -- * --
   -------
   TYPE carrier_tab
   IS
   TABLE OF sa.table_x_carrier.objid%TYPE INDEX BY BINARY_INTEGER;
   -------
   -- * --
   -------
   phone_dll NUMBER := 0;
   err_msg varchar2(200);
   l_language varchar2(50);     -- CR13249.
   --CR8406
   carrier_prf_array carrier_tab;
   carrier_dflt_array carrier_tab;
   carrier_tmp_array carrier_tab;
   carrier_prf_cnt INTEGER := 0;
   carrier_dflt_cnt INTEGER := 0;
   carrier_tmp_cnt INTEGER := 0;
   global_dealer_id VARCHAR2 (100);
   global_part_serial_no VARCHAR2 (100);
   global_technology VARCHAR2 (100);
   global_zip VARCHAR2 (100) := p_zip;
   -- *** for readability, always USE global_zip in the code
   global_esn VARCHAR2 (100) := p_esn;
   -- *** for readability, always USE global_esn in the code
   global_try_sid VARCHAR2 (30) := 'N';
   global_resource_busy VARCHAR2 (30) := 'Y';
   global_resource_busy_cnt NUMBER := 1;
   global_carr_found_flag NUMBER := 0;
   -------
   -- * --
   -------
   -- Variables flagged when one of the D Choices is found
   global_d_choice_found BOOLEAN := FALSE;
   global_d2_choice_found BOOLEAN := FALSE;
   -------
   -- * --
   -------
   -- BRAND_SEP
   -- Variables for Amigo
   --global_restricted_use NUMBER := 0;
   --global_amigo_yn NUMBER := 0;
   -------
   global_brand_name VARCHAR2(30);
   -- * --
   -------
   -- Variables for Motorola Digital
   global_carrier_frequency NUMBER := 800;
   global_phone_frequency NUMBER := 800;
   global_phone_frequency2 NUMBER := 1900;
   global_part_good_flag NUMBER;
   global_new_handset BOOLEAN := FALSE;
   global_react_new_line BOOLEAN := FALSE;
   -------
   -- * --
   -------
   global_react_sim NUMBER := 0;
   global_sim_profile VARCHAR2 (20);
   global_commit VARCHAR2 (10);
   global_sim_valid_check NUMBER := 0;
   global_gsm_same_zone BOOLEAN := FALSE;
   global_same_zone BOOLEAN := FALSE;
   global_line_status table_part_inst.x_part_inst_status%TYPE;
   global_min_carrier_name table_x_parent.x_parent_name%TYPE;
   global_esn_carrier_name table_x_parent.x_parent_name%TYPE;
   global_is_min_change_needed BOOLEAN := FALSE;
   global_new_msg_flag CHAR (1) := 'N';
   global_repl_sim VARCHAR2(30) := NULL;
   global_safelink varchar2(30) := 'NOT FOUND'; --CR38885   number :=0; --CR13234
   -------
   -- * --
   -------
   ------------------------------------------------------------------------
   -- Variable for GSM No Inventory Carriers (T-MOBILE and CINGULAR)     --
   -- They are also called JIT carriers (Just In Time)                   --
   -- We don't have an inventory of line numbers in our database         --
   -- for JIT carriers.                                                  --
   -- Carrier directly assigns the line number to the customer's phone,  --
   -- not TracFone.                                                      --
   ------------------------------------------------------------------------
   ----------------
   -- CR5192 START:
   ----------------
   global_no_service NUMBER := 0;
   -------------
   -- CR5192 END
   -------------
   --CR4981_4982
   global_data_phone VARCHAR2 (10) := 'F';
   global_data_sim VARCHAR2 (10) := 'T';
   l_carrier               table_x_carrier.x_mkt_submkt_name%TYPE := NULL; --CR52744
   l_count                 NUMBER := NULL; --CR52744
   l_volte_flag            VARCHAR2(1) := NULL; --CR52744
   l_allow_non_hd_acts     table_x_carrier_rules.allow_non_hd_acts%TYPE := NULL; --CR52744
   l_allow_non_hd_reacts   table_x_carrier_rules.allow_non_hd_reacts%TYPE := NULL; --CR52744
  cursor valid_cdma_lte_curs is
    select (select count(*)
              from table_part_inst pi
             where pi.x_iccid = si.x_sim_serial_no
               and pi.x_part_inst_status = '52'
               and pi.part_serial_no != p_esn) others_active,
            si.x_sim_inv_status
      from sa.table_x_sim_inv si
    where si.x_sim_serial_no = p_sim
      and si.x_sim_inv_status not in ('252','255','250');
  valid_cdma_lte_rec valid_cdma_lte_curs%rowtype;
   -- ACMI ACMI project start
   cursor technology_curs
     (p_esn VARCHAR2) is
     --CR52744
     SELECT pn.*,pi.x_part_inst_status
       FROM table_part_num pn, table_mod_level ml, table_part_inst pi
      WHERE 1 = 1
        AND pn.objid = ml.part_info2part_num
        AND ml.objid = pi.n_part_inst2part_mod
        AND pi.part_serial_no = p_esn;
   technology_rec technology_curs%rowtype;
   -- ACMI ACMI project end
   CURSOR not_certify_cur(
      carrier_objid NUMBER,
      repl_part_num VARCHAR2
   )
   IS
   SELECT cm.*
   FROM table_x_not_certify_models cm, table_part_num pn, table_x_parent p,
   table_x_carrier_group cg, table_x_carrier c
   WHERE 1 = 1
   AND cm.X_PART_CLASS_OBJID = pn.PART_NUM2PART_CLASS
   AND cm.X_PARENT_ID = p.x_parent_id
   AND p.objid = cg.X_CARRIER_GROUP2X_PARENT
   AND cg.objid = c.CARRIER2CARRIER_GROUP
   AND c.objid = carrier_objid
   AND pn.PART_NUMBER = repl_part_num;
   not_certify_rec not_certify_cur%ROWTYPE;
   --CR4981_4982
   -------
   -- * --
   ------
   CURSOR c_check_analog_order(
      c_carrier_objid IN VARCHAR2,
      c_rank IN VARCHAR2
   )
   IS
   SELECT 1 hold
   FROM carrierpref e, table_x_carrier c, carrierzones a
   WHERE e.county = a.county
   AND e.st = a.st
   AND e.carrier_id = c.x_carrier_id
   AND c.objid = c_carrier_objid
   AND e.new_rank = c_rank
   AND a.zip = global_zip;
   c_check_analog_order_rec c_check_analog_order%ROWTYPE;
   -------
   -- * --
   -------
   CURSOR c_check_digital_order(
      c_carrier_objid IN VARCHAR2,
      c_rank IN VARCHAR2
   )
   IS
   SELECT 1 hold
   FROM carrierpref e, table_x_carrier c, npanxx2carrierzones b, carrierzones a
   WHERE a.county = e.county
   AND e.st = b.state
   AND e.carrier_id = b.carrier_id
   AND e.carrier_id = c.x_carrier_id
   AND c.objid = c_carrier_objid
   AND e.new_rank = c_rank
   AND b.frequency1 IN ('1900', '800')
   AND ( b.tdma_tech = global_technology
   OR b.cdma_tech = global_technology
   OR b.gsm_tech = global_technology )
   AND a.ZONE = b.ZONE
   AND b.state = a.st
   AND a.zip = global_zip;
   c_check_digital_order_rec c_check_digital_order%ROWTYPE;
   new_carrier_dflt_cnt NUMBER := 0;
   -------
   -- * --
   -------
   CURSOR c_line_port(
      ip_min IN VARCHAR2
   )
   IS
   SELECT x_port_in
   FROM table_part_inst
   WHERE part_serial_no = ip_min;
   c_line_port_rec c_line_port%ROWTYPE;
   -------
   -- * --
   -------
   CURSOR c_same_zone(
      ip_line IN VARCHAR2
   )
   IS
   SELECT DISTINCT a.zip,
      a.rate_cente,
      a.ZONE,
      a.county,
      a.st,
      b.npa,
      b.nxx
   FROM carrierzones a, npanxx2carrierzones b
   WHERE b.nxx = SUBSTR (ip_line, 4, 3)
   AND b.npa = SUBSTR (ip_line, 1, 3)
   AND a.st = b.state
   AND a.ZONE = b.ZONE
   AND a.zip = global_zip;
   c_same_zone_rec c_same_zone%ROWTYPE;
   -------
   -- * --
   -------
   CURSOR c_sim_carr_info(
      c_ip_profile IN VARCHAR2
   )
   IS
   --CR5757 Begin
   --CR5757 Begin
   SELECT DISTINCT c.objid carr_objid,
      c.x_carrier_id,
      --f.x_acct_num, --CR8396
      e.x_no_inventory,
      c.carrier2rules,
      c.carrier2rules_gsm
   FROM --table_x_account f, --CR8396
   table_x_parent e, sa.table_x_carrier_group d, sa.table_x_carrier c, (
      SELECT DISTINCT b.carrier_id
      FROM sa.npanxx2carrierzones b, (
         SELECT DISTINCT a.st,
            a.ZONE
         FROM sa.carrierzones a, sa.carriersimpref s,
         --cwl 10/20/10  ------CR14598
         (
            SELECT pn.x_dll
            FROM table_part_num pn, table_mod_level ml, table_part_inst pi
            WHERE 1 = 1
            AND pn.objid = ml.part_info2part_num
            AND ml.objid = pi.n_part_inst2part_mod
            AND pi.part_serial_no = p_esn) tab1
         --cwl 10/20/10  --------------CR14598
         WHERE 1 = 1
         AND s.min_dll_exch <= tab1.x_dll
         AND s.max_dll_exch >= tab1.x_dll
         --AND s.rank != 0
         AND a.CARRIER_NAME = s.CARRIER_NAME
         AND s.sim_profile = c_ip_profile
         AND a.zip = global_zip
         AND ROWNUM < 1000000000) a
      WHERE 1 = 1
      AND b.gsm_tech || '' = 'GSM'
      AND a.st = b.state
      AND a.ZONE = b.ZONE
      AND ROWNUM < 1000000000) tab1
   WHERE 1 = 1
   AND TAB1.CARRIER_ID = C.X_CARRIER_ID
   AND C.CARRIER2CARRIER_GROUP = D.OBJID
   AND c.x_status = 'ACTIVE'
   AND d.x_carrier_group2x_parent = e.objid;
   --AND f.account2x_carrier = c.objid --CR8396
   --AND f.x_status = 'Active'; --CR8396
   --CR5757 End
   c_sim_carr_info_rec c_sim_carr_info%ROWTYPE;
   -------
   -- * --
   -------
   CURSOR c_cingular_mrkt_info(
      ip_zip IN VARCHAR2
   )
   IS
   SELECT DISTINCT mkt
   FROM x_cingular_mrkt_info
   WHERE zip = ip_zip;
   c_cingular_mrkt_info_rec c_cingular_mrkt_info%ROWTYPE;
   -------
   -- * --
   -------  -----------CR14598
   CURSOR gsm_phone_frequency_curs(
      c_part_number IN VARCHAR2
   )
   IS
   SELECT MAX (DECODE (f.x_frequency, 800, 800, 0)) phone_frequency,
      MAX (DECODE (f.x_frequency, 1900, 1900, 0)) phone_frequency2,
      x_dll
   FROM table_x_frequency f, mtm_part_num14_x_frequency0 pf, table_part_num pn
   WHERE pf.x_frequency2part_num = f.objid
   AND pn.objid = pf.part_num2x_frequency
   AND pn.part_number = c_part_number
   GROUP BY x_dll;
   gsm_phone_frequency_rec gsm_phone_frequency_curs%ROWTYPE;
   -------
   -- * --
   -------
   CURSOR gsm_phone_frequency_curs2
   IS
   SELECT MAX (DECODE (f.x_frequency, 800, 800, 0)) phone_frequency,
      MAX (DECODE (f.x_frequency, 1900, 1900, 0)) phone_frequency2,
      x_dll
   FROM table_x_frequency f, mtm_part_num14_x_frequency0 pf, table_part_num pn
   WHERE pf.x_frequency2part_num = f.objid
   AND pn.objid = pf.part_num2x_frequency
   AND pn.part_number = (
   SELECT pn.part_number
   FROM table_part_num pn, table_mod_level ml, table_part_inst pi
   WHERE pn.objid = ml.part_info2part_num
   AND ml.objid = pi.n_part_inst2part_mod
   AND pi.part_serial_no = p_esn
   AND ROWNUM < 2 )
   GROUP BY x_dll;
   gsm_phone_frequency_rec2 gsm_phone_frequency_curs2%ROWTYPE;
   ---CR14598
   -- ************************************************************************** --
   -- * NAP_DIGITAL procedure                                                  * --
   -- * DECLARATION section of the local variables ENDS here                   * --
   -- ************************************************************************** --
   -- ************************************************************************** --
   -- * NAP_DIGITAL procedure                                                  * --
   -- * DECLARATION section of the sub procedures STARTS here                  * --
   -- ************************************************************************** --
--CR22615
   FUNCTION gsm_min_change RETURN BOOLEAN IS
--
     CURSOR min_change_allowed_curs  IS
       SELECT sp.x_zipcode,
              DECODE(p.x_parent_id, '63', '7', p.x_parent_id) x_parent_id,
              c.X_CARRIER_ID,
              p.x_parent_name
         FROM table_x_parent p,
              table_x_carrier_group cg,
              table_x_carrier c,
              table_part_inst pi_min,
              table_site_part sp,
              table_part_inst pi
        WHERE 1 = 1
          AND p.objid = cg.X_CARRIER_GROUP2X_PARENT
          AND cg.objid = c.CARRIER2CARRIER_GROUP
          AND c.objid = pi_min.part_inst2carrier_mkt
          AND pi_min.part_serial_no = sp.x_min
          AND sp.objid = pi.X_PART_INST2SITE_PART
          AND UPPER(sp.part_status) in('CARRIERPENDING', 'ACTIVE')
          AND pi.x_part_inst_status||'' = '52'
          --AND pi.x_iccid||'' = p_sim
          AND pi.x_domain = 'PHONES'
          AND pi.part_serial_no = p_esn;
     min_change_allowed_rec min_change_allowed_curs%ROWTYPE;
--
     CURSOR cingular_curs( c_zipcode IN VARCHAR2 ) IS
       SELECT 'OK' col1
         FROM ( SELECT mkt
                 FROM x_cingular_mrkt_info
                 WHERE zip = c_zipcode INTERSECT
                SELECT mkt
                  FROM x_cingular_mrkt_info
                 WHERE zip = p_zip);
     cingular_rec cingular_curs%ROWTYPE;
--
     CURSOR same_parent_curs(c_parent_name in varchar2) IS
       select 1
         FROM table_x_parent p,
              table_x_carrier_group cg,
              table_x_carrier c,
              (SELECT DISTINCT b.carrier_id
                 FROM npanxx2carrierzones b,
                      carrierzones a
                WHERE 1 = 1
                  AND b.gsm_tech = 'GSM'
                  AND b.ZONE = a.ZONE
                  AND b.state = a.st
                  AND a.zip = p_zip) tab1
        WHERE 1 = 1
          AND p.x_parent_name like c_parent_name
          AND p.objid = cg.X_CARRIER_GROUP2X_PARENT
          AND cg.objid = c.CARRIER2CARRIER_GROUP
          AND c.X_CARRIER_ID IN (tab1.carrier_id);
     same_parent_rec same_parent_curs%rowtype;
--
     CURSOR non_cingular_curs(c_parent_id IN VARCHAR2,
                              c_old_carrier_id IN NUMBER ,
                                              c_old_zip in varchar2) IS
       SELECT p.x_parent_id,
              p.x_parent_name,
              cg.x_carrier_name,
              c.x_mkt_submkt_name
         FROM table_x_parent p,
              table_x_carrier_group cg,
              table_x_carrier c,
              (SELECT DISTINCT b.carrier_id
                 FROM npanxx2carrierzones b,
                      carrierzones a
                WHERE 1 = 1
                  AND b.gsm_tech = 'GSM'
                  AND b.ZONE = a.ZONE
                  AND b.state = a.st
                  AND a.zip = p_zip) tab1
        WHERE 1 = 1
          AND p.x_parent_id = c_parent_id
          AND p.objid = cg.X_CARRIER_GROUP2X_PARENT
          AND cg.objid = c.CARRIER2CARRIER_GROUP
          AND c.X_CARRIER_ID = tab1.carrier_id
          and exists ( SELECT b.state, b.zone
                         FROM npanxx2carrierzones b,carrierzones a
                        WHERE 1 = 1
                          AND b.gsm_tech = 'GSM'
                          AND b.carrier_id = tab1.carrier_id
                          AND b.state = a.st
                          AND b.zone = a.zone
                          AND a.zip = p_zip
                       INTERSECT
                       SELECT b.state, b.zone
                         FROM npanxx2carrierzones b, carrierzones a
                        WHERE 1 = 1
                          AND b.gsm_tech = 'GSM'
                          AND b.carrier_id = c_old_carrier_id
                          AND b.state = a.st
                          AND b.zone = a.zone
                          AND a.zip = c_old_zip);
     non_cingular_rec non_cingular_curs%ROWTYPE;
--
   BEGIN
      OPEN min_change_allowed_curs;
        FETCH min_change_allowed_curs INTO min_change_allowed_rec;
        IF min_change_allowed_curs%notfound THEN
          DBMS_OUTPUT.put_line(' min_change_allowed_curs%notfound');
          CLOSE min_change_allowed_curs;
          RETURN FALSE;
        END IF;
      CLOSE min_change_allowed_curs;
--
      IF min_change_allowed_rec.x_parent_name = 'CINGULAR' or min_change_allowed_rec.x_parent_name like 'AT%' then
        DBMS_OUTPUT.put_line('min_change_allowed_rec.x_parent_name= CINGULAR');
        OPEN cingular_curs(min_change_allowed_rec.x_zipcode);
          FETCH cingular_curs INTO cingular_rec;
          IF cingular_curs%found THEN
            DBMS_OUTPUT.put_line('cingular_curs%found');
            CLOSE cingular_curs;
            RETURN TRUE;
          else
            DBMS_OUTPUT.put_line('cingular_curs%notfound');
            CLOSE cingular_curs;
            RETURN FALSE;
          END IF;
        CLOSE cingular_curs;
      elsIF min_change_allowed_rec.x_parent_name like 'T-MOB%' then
        DBMS_OUTPUT.put_line('min_change_allowed_rec.x_parent_name= '||min_change_allowed_rec.x_parent_name);
        open same_parent_curs('T-MOB%');
          fetch same_parent_curs into same_parent_rec;
          if same_parent_curs%found then
            DBMS_OUTPUT.put_line('T-MOB found');
            close same_parent_curs;
            return true;
          else
            DBMS_OUTPUT.put_line('T-MOB not found');
            close same_parent_curs;
            return false;
          end if;
        close same_parent_curs;
      elsIF min_change_allowed_rec.x_parent_name like '%SPRINT%' then
        DBMS_OUTPUT.put_line('min_change_allowed_rec.x_parent_name= '||min_change_allowed_rec.x_parent_name);
        open same_parent_curs('%SPRINT%');
          fetch same_parent_curs into same_parent_rec;
          if same_parent_curs%found then
            DBMS_OUTPUT.put_line('SPRINT found');
            close same_parent_curs;
            return true;
          else
            DBMS_OUTPUT.put_line('SPRINT not found');
            close same_parent_curs;
            return false;
          end if;
        close same_parent_curs;
      elsIF min_change_allowed_rec.x_parent_name like '%VERIZON%' then
        DBMS_OUTPUT.put_line('min_change_allowed_rec.x_parent_name= '||min_change_allowed_rec.x_parent_name);
        open same_parent_curs('%VERIZON%');
          fetch same_parent_curs into same_parent_rec;
          if same_parent_curs%found then
            DBMS_OUTPUT.put_line('VERIZON found');
            close same_parent_curs;
            return true;
          else
            DBMS_OUTPUT.put_line('VERIZON not found');
            close same_parent_curs;
            return false;
          end if;
        close same_parent_curs;
      ELSE
        OPEN non_cingular_curs(min_change_allowed_rec.x_parent_id,
                               min_change_allowed_rec.x_carrier_id,
                                               min_change_allowed_rec.x_zipcode);
          FETCH non_cingular_curs INTO non_cingular_rec;
          IF non_cingular_curs%found THEN
            DBMS_OUTPUT.put_line('non_cingular_curs%found');
            CLOSE non_cingular_curs;
            RETURN TRUE;
          ELSE
            DBMS_OUTPUT.put_line('non_cingular_curs%notfound');
            CLOSE non_cingular_curs;
            RETURN FALSE;
          END IF;
        CLOSE non_cingular_curs;
      END IF;
   END;
--CR22615
   PROCEDURE digital_order
   IS
      TYPE carrier_rank_type
      IS
      REF CURSOR;
      -- define weak REF CURSOR type
      carrier_rank_curs carrier_rank_type;
      -- declare cursor variable
      exec_stmt VARCHAR2(10000);
      l_carrier_objid_list VARCHAR2(1000) := '0';
      l_new_rank NUMBER := NULL;
      l_carrier_objid NUMBER := NULL;
      cnt NUMBER := 0;
   BEGIN
      FOR i IN 1..carrier_dflt_cnt
      LOOP
         l_carrier_objid_list := l_carrier_objid_list||','||carrier_dflt_array(
         i) ;
      END LOOP;
      DBMS_OUTPUT.put_line('digital order l_carrier_objid_list:'||
      l_carrier_objid_list );
      exec_stmt :=
      'SELECT min(e.new_rank) new_rank,c.objid
         FROM carrierpref e,
              table_x_carrier c,
              npanxx2carrierzones b,
              carrierzones a
        WHERE a.county = e.county
          AND e.st = b.state
          AND e.carrier_id = b.carrier_id
          AND e.carrier_id = c.x_carrier_id
          AND c.objid in ('||l_carrier_objid_list||
          ')
          AND b.frequency1 IN (''1900'', ''800'')
          AND (   b.tdma_tech = '''||global_technology||
          '''
               OR b.cdma_tech = '''||global_technology||
               '''
               OR b.gsm_tech = '''||global_technology||
               '''
              )
          AND a.ZONE = b.ZONE
          AND b.state = a.st
          AND a.zip = '''||global_zip||
          '''
        group by c.objid
          order by to_number(min(e.new_rank)) asc';
      OPEN carrier_rank_curs FOR exec_stmt;
      LOOP
         FETCH carrier_rank_curs
         INTO l_new_rank, l_carrier_objid;
         EXIT
         WHEN carrier_rank_curs%notfound;
         cnt := cnt + 1;
         carrier_dflt_array(cnt) := l_carrier_objid;
         DBMS_OUTPUT.put_line(l_new_rank||':'||l_carrier_objid);
      END LOOP;
      CLOSE carrier_rank_curs;
   END digital_order;
   --cwl new 03/21/07
   --CR4902 Start
   PROCEDURE get_carrier_info(
      c_carr_objid IN NUMBER,
      c_noinv_carr IN VARCHAR2,
      c_parent OUT VARCHAR2
   )
   IS
      CURSOR c_get_parent
      IS
      SELECT p.*
      FROM table_x_parent p, table_x_carrier_group cg, table_x_carrier c
      WHERE p.objid = cg.x_carrier_group2x_parent
      AND UPPER (p.x_status) = 'ACTIVE'
      AND cg.objid = c.carrier2carrier_group
      AND cg.x_status = 'ACTIVE'
      AND c.objid = c_carr_objid;
     r_get_parent c_get_parent%ROWTYPE;
      CURSOR c_get_id
      IS
      SELECT x_parent_id
      FROM table_x_parent
      WHERE x_parent_name = c_noinv_carr
      AND UPPER (x_status) = 'ACTIVE';
      --1.77
      r_get_id c_get_id%ROWTYPE;
   BEGIN
      IF c_noinv_carr
      IS
      NULL
      THEN
         DBMS_OUTPUT.put_line('*****c_get_id:'||c_carr_objid );
         OPEN c_get_parent;
         FETCH c_get_parent
         INTO r_get_parent;
         IF c_get_parent%FOUND
         THEN
           c_parent := r_get_parent.x_parent_id;
         ELSE
            c_parent := NULL;
         END IF;
         CLOSE c_get_parent;
      ELSE
         DBMS_OUTPUT.put_line('c_get_id:'||c_carr_objid );
         OPEN c_get_id;
         FETCH c_get_id
         INTO r_get_id;
         IF c_get_id%FOUND
         THEN
            c_parent := r_get_id.x_parent_id;
         ELSE
            c_parent := NULL;
         END IF;
         CLOSE c_get_id;
      END IF;
      EXCEPTION
      WHEN OTHERS
      THEN
         IF c_get_parent%ISOPEN
         THEN
            CLOSE c_get_parent;
         END IF;
         IF c_get_id%ISOPEN
         THEN
            CLOSE c_get_id;
         END IF;
         c_parent := NULL;
   END get_carrier_info;
   --CR4902 End
   PROCEDURE sim_order
   IS
      TYPE carrier_rank_type
      IS
      REF CURSOR;
      -- define weak REF CURSOR type
      carrier_rank_curs carrier_rank_type;
      -- declare cursor variable
      exec_stmt VARCHAR2(10000);
      l_carrier_objid_list VARCHAR2(1000) := '0';
      l_new_rank NUMBER := NULL;
      l_carrier_objid NUMBER := NULL;
      cnt NUMBER := 0;
      CURSOR c_sim_repl(
         c_carrier_objid IN NUMBER
      )
      IS
      --CR32498 begin --commented below part and added below
      /*
      SELECT DISTINCT s.sim_profile,
         s.rank
      FROM sa.carrierzones a, sa.npanxx2carrierzones b, carriersimpref s,
      --cwl 10/20/10  ----CR14598
      (
         SELECT pn.x_dll
         FROM table_part_num pn, table_mod_level ml, table_part_inst pi
         WHERE 1 = 1
         AND pn.objid = ml.part_info2part_num
         AND ml.objid = pi.n_part_inst2part_mod
         AND pi.part_serial_no = p_esn) tab1
      --cwl 10/20/10  CR14598
      WHERE 1 = 1
      AND b.carrier_id + 0 IN (
      SELECT x_carrier_id
      FROM table_x_carrier
      WHERE objid = c_carrier_objid)
      AND b.gsm_tech = 'GSM'
      AND b.state = a.st
      AND b.ZONE = a.ZONE
      AND a.CARRIER_NAME = s.CARRIER_NAME
      AND a.zip = global_zip
      --cwl 10/20/10
      AND s.min_dll_exch <= tab1.x_dll
      AND s.max_dll_exch >= tab1.x_dll
      AND s.rank != 0
      --cwl 10/20/10

       -- CR32498 Begin
        --ORDER BY s.rank ASC;
         ORDER BY sa.is_shippable(s.sim_profile)DESC, s.rank ASC;
      -- CR32498 End
      */

      SELECT a.sim_profile
      FROM   TABLE_X_CARRIER ca,
             CARRIERPREF cp,
             NPANXX2CARRIERZONES b,
             ( SELECT DISTINCT a.zone,
                               a.st,
                               s.sim_profile,
                               a.county,
                               s.rank
               FROM   CARRIERZONES a,
                      CARRIERSIMPREF s,
                      ( SELECT pn.x_dll
                        FROM   TABLE_PART_NUM pn,
                               TABLE_MOD_LEVEL ml,
                               TABLE_PART_INST pi
                        WHERE  1 = 1 AND
                               pn.objid = ml.part_info2part_num AND
                               ml.objid = pi.n_part_inst2part_mod AND
                               pi.part_serial_no = p_esn ) tab1
               WHERE  a.zip = p_zip AND
                      a.carrier_name = s.carrier_name AND
                      tab1.x_dll BETWEEN s.min_dll_exch AND s.max_dll_exch ) a
      WHERE  1 = 1 AND
             ca.objid = c_carrier_objid AND
             ca.x_carrier_id = cp.carrier_id AND
             cp.st = b.state AND
             cp.carrier_id = b.carrier_id AND
             cp.county = a.county AND
             b.gsm_tech = 'GSM' AND
             b.zone = a.zone AND
             b.state = a.st AND
			 a.rank != 0
      ORDER  BY sa.is_shippable(a.sim_profile) DESC, a.rank ASC;
      --CR32498 End

      c_sim_repl_rec c_sim_repl%ROWTYPE;
   BEGIN
      IF carrier_dflt_cnt = 0
      THEN
         p_msg := 'No Phone Carriers Found';
         RETURN;
      END IF;
      global_repl_sim := NULL;
      DBMS_OUTPUT.put_line('global_sim_profile:'||global_sim_profile);
      FOR sim_carr_info_rec IN c_sim_carr_info (global_sim_profile)
      LOOP
         cnt := cnt + 1;
         l_carrier_objid_list := l_carrier_objid_list||','||sim_carr_info_rec.carr_objid
         ;
      END LOOP;
      DBMS_OUTPUT.put_line('l_carrier_objid_list:'||l_carrier_objid_list);
      IF cnt = 0
      THEN
--       p_msg := 'No SIM Carriers Found';
         --       return;
         l_carrier_objid_list := '0';
      END IF;
      DBMS_OUTPUT.put_line( l_carrier_objid_list );
      carrier_tmp_cnt := 0;
      FOR i IN 1..carrier_dflt_cnt
      LOOP
         exec_stmt := 'SELECT '||carrier_dflt_array(i)||
         '
            FROM dual
           where '||carrier_dflt_array(i)||' in ('||l_carrier_objid_list||')';
         DBMS_OUTPUT.put_line(SUBSTR(exec_stmt, 1, 80));
         DBMS_OUTPUT.put_line(SUBSTR(exec_stmt, 81, 80));
         DBMS_OUTPUT.put_line(SUBSTR(exec_stmt, 161, 80));
         OPEN carrier_rank_curs FOR exec_stmt;
         FETCH carrier_rank_curs
         INTO l_carrier_objid;
         IF carrier_rank_curs%found
         THEN
            DBMS_OUTPUT.put_line('phone and sim intersection:'||
            carrier_dflt_array(i));
            carrier_tmp_cnt := carrier_tmp_cnt + 1;
            carrier_tmp_array(carrier_tmp_cnt) := l_carrier_objid;
            DBMS_OUTPUT.put_line(l_carrier_objid);

            --CR32498 begin -- added below and commented few statement down below
            OPEN c_sim_repl(l_carrier_objid);

            FETCH c_sim_repl INTO c_sim_repl_rec;

            IF c_sim_repl%FOUND THEN
              dbms_output.Put_line( 'c_sim_repl found for carrier list' );
              global_repl_sim := c_sim_repl_rec.sim_profile;
            END IF;
            CLOSE c_sim_repl;

            /*
            DBMS_OUTPUT.put_line('global_repl_sim set to global_sim_profile:'||
            global_repl_sim);
            IF global_repl_sim
            IS
            NULL
            THEN
               global_repl_sim := global_sim_profile;
--             close carrier_rank_curs;
            --             exit;
            END IF;
            */
            --CR32498 ends
         ELSIF carrier_rank_curs%notfound
         AND global_repl_sim
         IS
         NULL
         THEN
            DBMS_OUTPUT.put_line('global_repl_sim:'||global_repl_sim);
            OPEN c_sim_repl(carrier_dflt_array(i));
            FETCH c_sim_repl
            INTO c_sim_repl_rec;
            IF c_sim_repl%FOUND
            THEN
               DBMS_OUTPUT.put_line('c_sim_repl found for carrier list');
               global_repl_sim := c_sim_repl_rec.sim_profile;
/*             IF ( c_sim_repl_rec.sim_profile
               IS
               NOT NULL
            -              AND c_sim_repl_rec.sim_profile_2
               IS
               NOT NULL)
               THEN
                  global_repl_sim := c_sim_repl_rec.sim_profile_2;
            --                 close c_sim_repl;
               --                 close carrier_rank_curs;
               --                 exit;
               ELSE
                  global_repl_sim := c_sim_repl_rec.sim_profile;
            --                 close c_sim_repl;
               --                 close carrier_rank_curs;
               --                 exit;
               END IF;
            */
            END IF;
            CLOSE c_sim_repl;
         END IF;
         CLOSE carrier_rank_curs;
         DBMS_OUTPUT.put_line('global_repl_sim set to global_sim_profile:'||
         global_repl_sim);
      END LOOP;
      DBMS_OUTPUT.put_line('carrier_tmp_cnt:'||carrier_tmp_cnt);
      IF carrier_tmp_cnt = 0
      THEN
         carrier_dflt_cnt := 0;
         IF global_repl_sim
         IS
         NULL
         THEN
            p_msg := 'No SIM Found in Carrier List';
            RETURN;
         ELSE
            DBMS_OUTPUT.put_line('get_carrier_info');
            IF carrier_dflt_array. EXISTS (1)
            AND carrier_dflt_cnt <> 0
            THEN
               get_carrier_info (carrier_dflt_array (1), NULL, p_pref_parent);
               p_pref_carrier_objid := carrier_dflt_array(1);
            END IF;
            p_msg := 'SIM Exchange';
            RETURN;
         END IF;
      END IF;
      carrier_dflt_cnt := carrier_tmp_cnt;
      FOR i IN 1..carrier_tmp_cnt
      LOOP
         carrier_dflt_array(i) := carrier_tmp_array(i);
      END LOOP;
   END sim_order;
   -----------------------------------------------------
   -- * sub function is_next_avail_market_on *        --
   --   Returns the first install_date of a given ESN --
   -----------------------------------------------------
   --cwl changed 03/21/07
   FUNCTION find_min_mkt_objid(
      c_min IN VARCHAR2
   )
   RETURN NUMBER
   IS
      CURSOR c1
      IS
      SELECT part_inst2carrier_mkt carr_objid
      FROM table_part_inst
      WHERE part_serial_no = c_min
      AND x_domain = 'LINES';
      c1_rec c1%ROWTYPE;
   BEGIN
      OPEN c1;
      FETCH c1
      INTO c1_rec;
      RETURN c1_rec.carr_objid;
      CLOSE c1;
   END;
   FUNCTION is_next_avail_market_on_fun(
      p_x_carrier_objid IN table_x_carrier.objid%TYPE
   )
   RETURN BOOLEAN
   IS
      CURSOR c_next_avail_carrier
      IS
      SELECT nac.*
      FROM x_next_avail_carrier nac, table_x_carrier c
      WHERE nac.x_carrier_id = c.x_carrier_id
      AND c.objid = p_x_carrier_objid;
      r_next_avail_carrier c_next_avail_carrier%ROWTYPE;
   BEGIN
      OPEN c_next_avail_carrier;
      FETCH c_next_avail_carrier
      INTO r_next_avail_carrier;
      IF c_next_avail_carrier%FOUND
      THEN
         CLOSE c_next_avail_carrier;
         DBMS_OUTPUT.put_line(p_x_carrier_objid||': is found');
         RETURN TRUE;
      ELSE
         CLOSE c_next_avail_carrier;
         DBMS_OUTPUT.put_line(p_x_carrier_objid||': is found');
         RETURN FALSE;
      END IF;
      CLOSE c_next_avail_carrier;
   END is_next_avail_market_on_fun;
   -------------------------------------------------
   -- * sub procedure  check_data_phone*                  --
   --   Checks if the phone is "DATA CAPABLE" or not --
   -------------------------------------------------
   --cwl changed 03/21/07
   PROCEDURE check_data_phone
   IS
      CURSOR phone_data_curs
      IS
      SELECT NVL(x_data_capable, 0) x_data_capable
      FROM table_part_num pn, table_mod_level ml, table_part_inst pi
      WHERE pn.objid = ml.part_info2part_num
      AND ml.objid = pi.n_part_inst2part_mod
      AND pi.part_serial_no = p_esn;
      phone_data_rec phone_data_curs%ROWTYPE;
      CURSOR carrier_data_curs(
         c_carrier_objid IN NUMBER
      )
      IS
      SELECT NVL(c.x_data_service, 0) x_data_service
      FROM table_x_carrier c
      WHERE c.objid = c_carrier_objid;
      carrier_data_rec carrier_data_curs%ROWTYPE;
      l_data_service NUMBER := 0;
   BEGIN
      carrier_tmp_cnt := 0;
      OPEN phone_data_curs;
      FETCH phone_data_curs
      INTO phone_data_rec;
      IF phone_data_curs%FOUND
      AND phone_data_rec.x_data_capable = 1
      THEN
         DBMS_OUTPUT.put_line('DATA FONE');
         global_data_phone := 'T';
         FOR i IN 1 .. carrier_dflt_cnt
         LOOP
            OPEN carrier_data_curs (carrier_dflt_array (i));
            FETCH carrier_data_curs
            INTO carrier_data_rec;
            IF Carrier_Data_Curs%Found
            --And Carrier_Data_Rec.X_Data_Service = 1
            AND Carrier_Data_Rec.X_Data_Service IN (0, 1) --CR11268/1112/11269/11437
            THEN
               DBMS_OUTPUT.put_line('carrier_data_curs%FOUND DATA FONE');
               carrier_tmp_cnt := carrier_tmp_cnt + 1;
               carrier_tmp_array (carrier_tmp_cnt) := carrier_dflt_array (i);
               DBMS_OUTPUT.put_line('Data Carrier: '|| carrier_dflt_array (i));
            END IF;
            CLOSE carrier_data_curs;
         END LOOP;
         IF carrier_tmp_cnt > 0
         THEN
            carrier_dflt_cnt := carrier_tmp_cnt;
            FOR i IN 1 .. carrier_tmp_cnt
            LOOP
               carrier_dflt_array (i) := carrier_tmp_array (i);
            END LOOP;
         ELSE
            p_msg := 'Exchange Phone. No Carrier in this area is data capable';
         END IF;
      END IF;
      CLOSE phone_data_curs;
   END check_data_phone;
   -----------------------------------------------------
   -- * sub procedure get_days_prc *                  --
   --   Returns the first install_date of a given ESN --
   -----------------------------------------------------
   PROCEDURE get_days_prc(
      p_days OUT NUMBER,
      p_err_msg OUT VARCHAR2
   )
   IS
      l_inst_date DATE := NULL;
   BEGIN
      p_err_msg := NULL;
      p_days := 0;
      SELECT MIN (install_date) init_act_date
      INTO l_inst_date
      FROM table_site_part sp_c
      WHERE sp_c.x_service_id = global_esn
      AND sp_c.part_status || '' IN ('Active', 'Inactive');
      IF l_inst_date
      IS
      NULL
      THEN
         p_days := 0;
      ELSE
         p_days := SYSDATE - l_inst_date;
      END IF;
      EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         p_days := 0;
      WHEN OTHERS
      THEN
         p_err_msg := 'Error while retrieving install date for ESN: ' ||
         global_esn || ' ' || SQLERRM;
         p_days := 0;
   END get_days_prc;
   --------------------------------------------
   -- * sub procedure gsm_get_repl_sim_prc * --
   --   get SIM card replacement             --
   --------------------------------------------
   --cwl change 03/21/07
   --need to chech all carriers not just the first one
   PROCEDURE gsm_get_repl_sim_prc(
      p_in_dll IN NUMBER,
      p_out_msg OUT VARCHAR2,
      p_repl_sim OUT VARCHAR2
   )
   IS
      CURSOR c_pref_gsm_carr(
         ip_phone_freq1 IN NUMBER,
         ip_phone_freq2 IN NUMBER
      )
      IS
      SELECT DISTINCT tab2.carrier_id pref_carr_id,
         cp.new_rank,
         cp.carrier_name,
         ca.objid carrier_objid
      FROM carrierpref cp, table_x_carrier ca, (
         SELECT DISTINCT b.state,
            b.county,
            b.carrier_id
         FROM npanxx2carrierzones b, (
            SELECT DISTINCT a.ZONE,
               a.st
            FROM carrierzones a
            WHERE a.zip = global_zip
            AND ROWNUM < 1000000000) tab1
         WHERE b.ZONE = tab1.ZONE
         AND b.state = tab1.st
         AND b.gsm_tech || '' = 'GSM'
         AND ( b.frequency1 IN (ip_phone_freq1, ip_phone_freq2 )
         OR b.frequency2 IN (ip_phone_freq1, ip_phone_freq2 ) )
         AND ROWNUM < 1000000000) tab2
      WHERE 1 = 1
      AND cp.county = tab2.county
      AND cp.st = tab2.state
      AND cp.carrier_id = tab2.carrier_id
      AND ca.x_carrier_id = tab2.carrier_id
      AND ca.x_status || '' = 'ACTIVE'
      AND ROWNUM < 1000000000
      ORDER BY TO_NUMBER(cp.new_rank) ASC;
      c_pref_gsm_carr_rec c_pref_gsm_carr%ROWTYPE;
      CURSOR c_sim_repl(
         c_ip_carr IN VARCHAR2
      )
      IS
      SELECT DISTINCT s.sim_profile,
         s.rank
      --a.sim_profile,
      --a.sim_profile_2
      FROM sa.carrierzones a, sa.npanxx2carrierzones b, carriersimpref s
      WHERE 1 = 1
      AND b.carrier_id + 0 = c_ip_carr
      AND b.gsm_tech = 'GSM'
      AND b.state = a.st
      AND b.ZONE = a.ZONE
      AND a.zip = global_zip
      AND a.CARRIER_NAME = s.CARRIER_NAME
      AND s.min_dll_exch <= p_in_dll
      AND s.max_dll_exch >= p_in_dll
      AND s.rank != 0

       -- CR32498 Begin
      --ORDER BY s.rank ASC;
       ORDER BY sa.is_shippable(s.sim_profile) desc, s.rank ASC;
      -- CR32498 End
      c_sim_repl_rec c_sim_repl%ROWTYPE;
      phone_freq1 NUMBER := global_phone_frequency;
      phone_freq2 NUMBER := global_phone_frequency2;
      l_carr_cnt NUMBER := 0;
----------------------------------------------------
   -- sub procedure gsm_get_repl_sim_prc starts here --
   ----------------------------------------------------
   BEGIN
     DBMS_OUTPUT.Put_Line('func1');
     IF global_phone_frequency = 0 THEN
       phone_freq1 := global_phone_frequency2;
     END IF;
     IF global_phone_frequency2 = 0 THEN
       phone_freq2 := global_phone_frequency;
     END IF;
     DBMS_OUTPUT.put_line('(phone_freq1, phone_freq2):'||phone_freq1||':'|| phone_freq2);
     FOR c_pref_gsm_carr_rec IN c_pref_gsm_carr (phone_freq1, phone_freq2) LOOP
       DBMS_OUTPUT.put_line('c_pref_gsm_carr_rec.carrier_name:'||c_pref_gsm_carr_rec.carrier_name);
       OPEN c_sim_repl (c_pref_gsm_carr_rec.pref_carr_id);
         FETCH c_sim_repl INTO c_sim_repl_rec;
         IF c_sim_repl%FOUND THEN
           l_carr_cnt := l_carr_cnt + 1;
           DBMS_OUTPUT.put_line('found:'||l_carr_cnt);
           DBMS_OUTPUT.put_line('carrier_dflt_cnt:'||carrier_dflt_cnt);
           FOR i IN 1..carrier_dflt_cnt LOOP
             IF carrier_dflt_array(i) = c_pref_gsm_carr_rec.carrier_objid THEN
               p_repl_sim := c_sim_repl_rec.sim_profile;
               CLOSE c_sim_repl;
               get_carrier_info (c_pref_gsm_carr_rec.carrier_objid, NULL, p_pref_parent); --1.4 10/30/07
               p_pref_carrier_objid := c_pref_gsm_carr_rec.carrier_objid;
               p_out_msg := 'SIM Exchange';
               RETURN;
             END IF;
           END LOOP;
         END IF;
       CLOSE c_sim_repl;
     END LOOP;
     FOR c_pref_gsm_carr_rec IN c_pref_gsm_carr (phone_freq1, phone_freq2) LOOP
       OPEN c_sim_repl (c_pref_gsm_carr_rec.pref_carr_id);
         FETCH c_sim_repl INTO c_sim_repl_rec;
         IF c_sim_repl%FOUND THEN
           p_repl_sim := c_sim_repl_rec.sim_profile;
           get_carrier_info (c_pref_gsm_carr_rec.carrier_objid, NULL, p_pref_parent); --1.4 10/30/07
           p_pref_carrier_objid := c_pref_gsm_carr_rec.carrier_objid;
           CLOSE c_sim_repl;
           p_out_msg := 'SIM Exchange';
                   return;
                end if;
       CLOSE c_sim_repl;
     END LOOP;
     IF l_carr_cnt = 0 THEN
       p_out_msg := 'No preferred carrier for SIM';
       p_repl_sim := NULL;
       RETURN;
     ELSE
       p_out_msg := 'Failure - Sim replacement';
       p_repl_sim := NULL;
       RETURN;
     END IF;
   END gsm_get_repl_sim_prc;
   -----------------------------------------
   -- * sub procedure get_repl_part_prc * --
   --   get replacement part              --
   -----------------------------------------
   PROCEDURE get_repl_part_prc( p_out_msg OUT VARCHAR2,
                                p_repl_part OUT VARCHAR2,
                                p_repl_tech OUT VARCHAR2,
                                p_repl_sim OUT VARCHAR2) IS
      CURSOR c_repl_carr(c_technology       in varchar2,
                         c_dll              in varchar2,
                         c_esn_part_number  in varchar2,
                                                c_bus_org_objid    in number,
                                                c_data_speed       in number,
                                                c_non_ppe          in number,
                                                c_phone_frequency  in number,
                                                c_phone_frequency2 in number,
                                                c_meid_phone       in number,
                                                c_dealer_id        in number,
                                                c_part_inst_status in number,
                                                c_phone_gen        in varchar2,
                         c_parent_name      in varchar2) IS
        select distinct
                       ca.objid,
                       p.x_parent_name,
                       tab1.sim_profile,
                       (select cr.x_allow_2g_react
                  from table_x_carrier_rules cr
                 where cr.objid = decode(c_technology,'CDMA', nvl(ca.CARRIER2RULES_CDMA, ca.CARRIER2RULES),
                                                       'GSM', nvl(ca.CARRIER2RULES_GSM , ca.CARRIER2RULES), ca.CARRIER2RULES)) x_allow_2g_react,
                       (select cr.x_allow_2g_act
                  from table_x_carrier_rules cr
                 where cr.objid = decode(c_technology,'CDMA', nvl(ca.CARRIER2RULES_CDMA, ca.CARRIER2RULES),
                                                       'GSM', nvl(ca.CARRIER2RULES_GSM , ca.CARRIER2RULES), ca.CARRIER2RULES)) x_allow_2g_act
          FROM (SELECT min(to_number(cp.new_rank)) new_rank,  b.carrier_id,a.sim_profile,a.min_dll_exch,a.max_dll_exch
                  FROM carrierpref cp,
                               npanxx2carrierzones b,
                                       (SELECT DISTINCT a.ZONE,
                                    a.st,
                                    s.sim_profile,
                                    a.county,
                                    s.min_dll_exch,
                                    s.max_dll_exch,
                                                                    s.rank
                          FROM carrierzones a, carriersimpref s
                         WHERE a.zip = p_zip
                           and a.CARRIER_NAME=s.CARRIER_NAME
                           and c_dll between s.MIN_DLL_EXCH and s.MAX_DLL_EXCH

                          order by s.rank asc


                         ) a
                 WHERE 1=1
                   AND cp.st = b.state
                   and cp.carrier_id = b.carrier_ID
                           and cp.county = a.county
                   AND (   b.cdma_tech = c_technology OR b.gsm_tech  = c_technology )
                           --and a.sim_profile = decode(c_sim_part_number,null,a.sim_profile,c_sim_part_number)
                   AND b.ZONE = a.ZONE
                   AND b.state = a.st
                 group by b.carrier_id,a.sim_profile,a.min_dll_exch,a.max_dll_exch) tab1,
               table_x_carrierdealer c,
               table_x_carrier ca,
               table_x_carrier_group cg,
               table_x_parent p
         WHERE 1=1
           and not exists (SELECT 1
                             FROM table_x_not_certify_models cm,
                                  table_part_num pn
                            WHERE 1 = 1
                              AND cm.X_PARENT_ID = p.x_parent_id
                              AND cm.X_PART_CLASS_OBJID = pn.PART_NUM2PART_CLASS
                              AND pn.PART_NUMBER = c_esn_part_number)
           and exists (select cf.X_FEATURES2BUS_ORG
                         from table_x_carrier_features cf
                        where cf.X_FEATURE2X_CARRIER = ca.objid
                          and cf.x_technology        = c_technology
                          and cf.X_FEATURES2BUS_ORG  = c_bus_org_objid
                          and cf.x_data              = c_data_speed
                                          and decode(cf.X_SWITCH_BASE_RATE,null,c_non_ppe,1) = c_non_ppe
                                union
                       select cf.X_FEATURES2BUS_ORG
                         from table_x_carrier_features cf
                        where cf.X_FEATURE2X_CARRIER in( SELECT c2.objid
                                                           FROM table_x_carrier_group cg2,
                                                                table_x_carrier c2
                                                          WHERE cg2.x_carrier_group2x_parent = p.objid
                                                            AND c2.carrier2carrier_group = cg2.objid)
                          and cf.x_technology        = c_technology
                          and cf.X_FEATURES2BUS_ORG  = (select bo.objid
                                                          from table_bus_org bo
                                                         where bo.org_id = 'NET10'
                                                           and bo.objid  = c_bus_org_objid)
                          and cf.x_data              = c_data_speed
                                          and decode(cf.X_SWITCH_BASE_RATE,null,c_non_ppe,1) = c_non_ppe)
                --CR38885
           AND c.x_dealer_id ||'' = case when global_safelink = 'FOUND' then
                                           '24920'
                                         else
                                           decode(c.x_dealer_id,'24920','XXXXXXX',c.x_dealer_id)
                                         end
                --CR38885
           AND c.x_carrier_id = tab1.carrier_id
           AND ca.x_status || '' = 'ACTIVE'
           AND ca.x_carrier_id = tab1.carrier_id
           AND cg.objid = ca.CARRIER2CARRIER_GROUP
           and p.objid = cg.X_CARRIER_GROUP2X_PARENT
                   and 1 = (case when c_parent_name is null then
                                           1
                         when c_parent_name = 'ATT' and (p.x_parent_name like 'AT%' or p.x_parent_name like 'CING%') then
                           1
                         when c_parent_name = 'TMO' and (p.x_parent_name like 'T-M%' ) then
                           1
                                                else
                           0
                                                end )
           and exists(select 1
                    FROM table_x_frequency f,
                         mtm_x_frequency2_x_pref_tech1 f2pt,
                         table_x_pref_tech pt
                   WHERE f.objid = f2pt.x_frequency2x_pref_tech
                     AND f.x_frequency + 0 in (c_phone_frequency,c_phone_frequency2)
                     AND f2pt.x_pref_tech2x_frequency = pt.objid
                     AND pt.x_pref_tech2x_carrier = ca.objid)
           and 1=(case when c_phone_gen = '2G' then
                       (select count(*)
                         from table_x_carrier_rules cr
                        where (   (    cr.objid = decode(c_technology,'CDMA', nvl(ca.CARRIER2RULES_CDMA, ca.CARRIER2RULES),
                                                                       'GSM' , nvl(ca.CARRIER2RULES_GSM, ca.CARRIER2RULES), ca.CARRIER2RULES)
                                   and cr.x_allow_2g_react = '2G'
                                   and c_part_inst_status not in ('50','150'))
                               or (    cr.objid = decode(c_technology,'CDMA', nvl(ca.CARRIER2RULES_CDMA, ca.CARRIER2RULES),
                                                                        'GSM' , nvl(ca.CARRIER2RULES_GSM, ca.CARRIER2RULES), ca.CARRIER2RULES)
                                   and cr.x_allow_2g_act = '2G'
                                   and c_part_inst_status in ('50','150')))
                          and rownum < 2)
                     else
                       1
                     end)
           and decode( p.x_meid_carrier,1,c_meid_phone,null,0,p.x_meid_carrier) = c_meid_phone
           -- CR32498 BEGIN
           order by sa.is_shippable(tab1.sim_profile) DESC
            -- CR32498 END
           ;
      CURSOR c_old_esn_info IS
        SELECT pn.objid,
               pn.x_technology technology,
               pn.part_number esn_part_number,
               pn.x_dll dll,
               pn.PART_NUM2BUS_ORG bus_org_objid,
               pi.x_part_inst2site_part, -- CR40137
               nvl((select v.x_param_value
                  from table_x_part_class_values v,
                       table_x_part_class_params n
                 where 1=1
                   and v.value2part_class     = pn.part_num2part_class
                   and v.value2class_param    = n.objid
                   and n.x_param_name         = 'DATA_SPEED'
                   and rownum <2),NVL(pn.x_data_capable, 0)) data_speed,
               (select count(*) sr
                  from table_x_part_class_values v,
                       table_x_part_class_params n
                 where 1=1
                   and v.value2part_class     = pn.part_num2part_class
                   and v.value2class_param    = n.objid
                   and n.x_param_name         = 'NON_PPE'
                   and v.x_param_value       in ('0','1')
                   and rownum <2) non_ppe,
                       (SELECT MAX (DECODE (f.x_frequency, 800, 800, 0)) phone_frequency
                  FROM sa.table_x_frequency f,
                       sa.mtm_part_num14_x_frequency0 pf
                 WHERE pf.x_frequency2part_num = f.objid
                   AND pn.objid = pf.part_num2x_frequency) phone_frequency,
               (SELECT MAX (DECODE (f.x_frequency, 1900, 1900, 0)) phone_frequency2
                  FROM sa.table_x_frequency f,
                       sa.mtm_part_num14_x_frequency0 pf
                WHERE pf.x_frequency2part_num = f.objid
                   AND pn.objid = pf.part_num2x_frequency) phone_frequency2,
               NVL(pn.x_meid_phone, 0) meid_phone,
               pi.x_part_inst_status part_inst_status,
               nvl((select v.x_param_value
                  from table_x_part_class_values v,
                       table_x_part_class_params n
                 where 1=1
                   and v.value2part_class     = pn.part_num2part_class
                   and v.value2class_param    = n.objid
                   and n.x_param_name         = 'PHONE_GEN'
                   and rownum <2),'2G') phone_gen,
               (select ib.bin_name
                                  from table_inv_bin ib
                                where ib.objid =pi.part_inst2inv_bin) dealer_id
          FROM table_part_inst pi,
               table_mod_level ml,
               table_part_num pn
         WHERE pn.objid = ml.part_info2part_num
           AND ml.objid = pi.n_part_inst2part_mod
           AND pi.part_serial_no = global_esn;
      c_old_esn_info_rec c_old_esn_info%ROWTYPE;
      --cdma meid change 05/16/07 add c_meid_carrier
      CURSOR c_repl_part( c_ip_tech IN VARCHAR2,
                          c_ip_esn_objid IN NUMBER,
                          c_ip_site_objid IN NUMBER, --CR40137
                          c_ip_part_inst_status in varchar2) is
        SELECT
               pn.x_technology technology,
               pn.x_dll dll,
      			   case when c_ip_part_inst_status = '50' then --CR40137 Start
                                                  exch.x_new_part_num
                    when not exists ( select 1
                                        from table_site_part sp_a
                                       where sp_a.objid = c_ip_site_objid
                                         and sp_a.x_refurb_flag = 1)
                     and not exists ( select 1
                                        from table_site_part sp_b
                                       where sp_b.objid = c_ip_site_objid
                                         and sp_b.install_date < sysdate -15) then

                                                  exch.x_new_part_num
                    else
                                                  exch.x_used_part_num
               end esn_part_number,
               --decode(c_ip_part_inst_status,'50',exch.x_new_part_num, exch.x_used_part_num ) esn_part_number, CR40137 End
               pn.PART_NUM2BUS_ORG bus_org_objid,
               nvl((select v.x_param_value
                  from table_x_part_class_values v,
                       table_x_part_class_params n
                 where 1=1
                   and v.value2part_class     = pn.part_num2part_class
                   and v.value2class_param    = n.objid
                   and n.x_param_name         = 'DATA_SPEED'
                   and rownum <2),NVL(pn.x_data_capable, 0)) data_speed,
               (select count(*) sr
                  from table_x_part_class_values v,
                       table_x_part_class_params n
                 where 1=1
                   and v.value2part_class     = pn.part_num2part_class
                   and v.value2class_param    = n.objid
                   and n.x_param_name         = 'NON_PPE'
                   and v.x_param_value       in ('0','1')
                   and rownum <2) non_ppe,
                       (SELECT MAX (DECODE (f.x_frequency, 800, 800, 0)) phone_frequency
                  FROM sa.table_x_frequency f,
                       sa.mtm_part_num14_x_frequency0 pf
                 WHERE pf.x_frequency2part_num = f.objid
                   AND pn.objid = pf.part_num2x_frequency) phone_frequency,
               (SELECT MAX (DECODE (f.x_frequency, 1900, 1900, 0)) phone_frequency2
                  FROM sa.table_x_frequency f,
                       sa.mtm_part_num14_x_frequency0 pf
                 WHERE pf.x_frequency2part_num = f.objid
                   AND pn.objid = pf.part_num2x_frequency) phone_frequency2,
               NVL(pn.x_meid_phone, 0) meid_phone,
                       c_ip_part_inst_status part_inst_status,
               nvl((select v.x_param_value
                  from table_x_part_class_values v,
                       table_x_part_class_params n
                 where 1=1
                   and v.value2part_class     = pn.part_num2part_class
                   and v.value2class_param    = n.objid
                   and n.x_param_name         = 'PHONE_GEN'
                   and rownum <2),'2G') phone_gen,
               ( SELECT pn2.PART_NUM2BUS_ORG
                   FROM table_part_num pn2
                  WHERE PN2.S_PART_NUMBER = UPPER(EXCH.X_NEW_PART_NUM)
                    AND pn2.domain = 'PHONES') new_bus_org,
               exch.x_used_part_num,
               exch.x_new_part_num,
               exch.x_days_for_used_part,
                       exch.x_priority
          FROM table_x_class_exch_options exch,
                       table_part_num pn
         WHERE exch.source2part_class = ( SELECT part_num2part_class
                                            FROM table_part_num
                                           WHERE objid = c_ip_esn_objid)
           AND pn.x_technology = decode(c_ip_tech,'GSM','GSM',pn.x_technology) --CR38677
           AND pn.part_number = exch.x_new_part_num
           AND exch.x_exch_type in ('WAREHOUSE','TECHNOLOGY') --CR38677
         ORDER BY decode(exch.x_exch_type,'TECHNOLOGY',1,2), exch.x_priority ASC;
      c_repl_part_rec c_repl_part%ROWTYPE;
      cursor sim_junk_curs is
        select case when upper(csp.carrier_name) like 'AT%'
                                      or upper(csp.carrier_name) like 'CING%' then
                      'ATT'
                    when upper(csp.carrier_name) like 'T-MOB%' then
                      'TMO'
                    else
                      'OTHER'
                                    end carrier_name,
              csp.carrier_name carrier_name2,
                      pn2.part_number
          from
                table_x_sim_inv si
               ,table_mod_level ml2
               ,table_part_num pn2
               ,carriersimpref csp
         where 1=1
           and si.x_sim_serial_no = p_sim
           and ml2.objid = si.x_sim_inv2part_mod
           and pn2.objid = ml2.part_info2part_num
           and csp.sim_profile = pn2.part_number
                   and substr(csp.carrier_name,1,2) in ('AT','CI','T-');
      sim_junk_rec sim_junk_curs%rowtype;
      l_days NUMBER;
      l_days_err_msg VARCHAR2 (100);
      l_temp_part_num table_part_num.part_number%TYPE;
      l_temp_priority table_x_class_exch_options.x_priority%TYPE;
      l_temp_technology table_part_num.x_technology%TYPE;
      l_flag_cdma BOOLEAN := FALSE;
      l_flag_tdma BOOLEAN := FALSE;
      l_flag_gsm BOOLEAN := FALSE;
      TYPE tech_list_type IS TABLE OF table_part_num.x_technology%TYPE INDEX BY BINARY_INTEGER;
      tech_list tech_list_type;
      i NUMBER := 0;
      ct NUMBER := 0;
   BEGIN
      OPEN c_old_esn_info;
        FETCH c_old_esn_info INTO c_old_esn_info_rec;
        IF c_old_esn_info%NOTFOUND THEN
           p_out_msg := 'Esn Not Found';
           CLOSE c_old_esn_info;
           RETURN;
        END IF;
      CLOSE c_old_esn_info;
      DBMS_OUTPUT.put_line('c_old_esn_info_rec.part_inst_status:'||c_old_esn_info_rec.part_inst_status) ;
      dbms_output.put_line('c_old_esn_info_rec.technology:'||c_old_esn_info_rec.technology);
      dbms_output.put_line('c_old_esn_info_rec.objid:'||c_old_esn_info_rec.objid);
      dbms_output.put_line('c_old_esn_info_rec.x_part_inst2site_part:'||c_old_esn_info_rec.x_part_inst2site_part); --CR40137
      if c_old_esn_info_rec.technology = 'GSM' then
        open sim_junk_curs;
          fetch sim_junk_curs into sim_junk_rec;
                close sim_junk_curs;
        dbms_output.put_line('sim_junk_rec.carrier_name:'||sim_junk_rec.carrier_name );
        dbms_output.put_line('sim_junk_rec.carrier_name2:'||sim_junk_rec.carrier_name2 );
        dbms_output.put_line('sim_junk_rec.part_number:'||sim_junk_rec.part_number );
        FOR c_repl_part_rec IN c_repl_part (c_old_esn_info_rec.technology,
                                            c_old_esn_info_rec.objid,
                                            c_old_esn_info_rec.x_part_inst2site_part, --CR40137
                                            c_old_esn_info_rec.part_inst_status) LOOP
          DBMS_OUTPUT.put_line('c_repl_part_rec.phone_gen:'||c_repl_part_rec.phone_gen);
          DBMS_OUTPUT.put_line('c_repl_part_rec.esn_part_number:'||c_repl_part_rec.esn_part_number);
          for repl_carr_rec in c_repl_carr(c_repl_part_rec.technology,
                                           c_repl_part_rec.dll,
                                           c_repl_part_rec.esn_part_number,
                                           c_repl_part_rec.bus_org_objid,
                                           c_repl_part_rec.data_speed  ,
                                           c_repl_part_rec.non_ppe    ,
                                           c_repl_part_rec.phone_frequency ,
                                           c_repl_part_rec.phone_frequency2,
                                           c_repl_part_rec.meid_phone     ,
                                           c_old_esn_info_rec.dealer_id     ,
                                           c_repl_part_rec.part_inst_status,
                                           c_repl_part_rec.phone_gen,
                                           sim_junk_rec.carrier_name) loop
            dbms_output.put_line(repl_carr_rec.objid||':'||repl_carr_rec.x_parent_name );
            dbms_output.put_line('c_repl_part_rec.technology:'||c_repl_part_rec.technology );
            dbms_output.put_line('sim_junk_rec.carrier_name:'||sim_junk_rec.carrier_name );
            dbms_output.put_line('c_repl_part_rec.phone_gen:'||c_repl_part_rec.phone_gen );
            dbms_output.put_line('c_old_esn_info_rec.phone_gen:'||c_old_esn_info_rec.phone_gen );
            dbms_output.put_line('repl_carr_rec.x_allow_2g_react:'||repl_carr_rec.x_allow_2g_react );
            dbms_output.put_line('repl_carr_rec.x_allow_2g_act:'||repl_carr_rec.x_allow_2g_act );
            dbms_output.put_line('repl_carr_rec.sim_profile:'||repl_carr_rec.sim_profile );
            p_repl_part := c_repl_part_rec.esn_part_number;
            p_repl_tech := c_repl_part_rec.technology;
            p_repl_sim  := repl_carr_rec.sim_profile;
                          dbms_output.put_line('partfound');
            goto partfound;
          end loop;
                      end loop;
        for repl_carr_rec in c_repl_carr(c_old_esn_info_rec.technology,
                                         c_old_esn_info_rec.dll,
                                         c_old_esn_info_rec.esn_part_number,
                                         c_old_esn_info_rec.bus_org_objid,
                                         c_old_esn_info_rec.data_speed  ,
                                         c_old_esn_info_rec.non_ppe    ,
                                         c_old_esn_info_rec.phone_frequency ,
                                         c_old_esn_info_rec.phone_frequency2,
                                         c_old_esn_info_rec.meid_phone     ,
                                         c_old_esn_info_rec.dealer_id     ,
                                         c_old_esn_info_rec.part_inst_status,
                                         c_old_esn_info_rec.phone_gen,
                                         null) loop
          dbms_output.put_line(repl_carr_rec.objid||':'||repl_carr_rec.x_parent_name );
          dbms_output.put_line('c_repl_part_rec.technology:'||c_repl_part_rec.technology );
          dbms_output.put_line('sim_junk_rec.carrier_name:'||sim_junk_rec.carrier_name );
          dbms_output.put_line('c_repl_part_rec.phone_gen:'||c_repl_part_rec.phone_gen );
          dbms_output.put_line('c_old_esn_info_rec.phone_gen:'||c_old_esn_info_rec.phone_gen );
          dbms_output.put_line('repl_carr_rec.x_allow_2g_react:'||repl_carr_rec.x_allow_2g_react );
          dbms_output.put_line('repl_carr_rec.x_allow_2g_act:'||repl_carr_rec.x_allow_2g_act );
          dbms_output.put_line('repl_carr_rec.sim_profile:'||repl_carr_rec.sim_profile );
          p_repl_tech := c_old_esn_info_rec.technology;
          p_repl_sim  := repl_carr_rec.sim_profile;
          dbms_output.put_line('partfound');
          goto partfound;
        end loop;
      end if;
      FOR c_repl_part_rec IN c_repl_part ('BOTH', --CR38677
                                          c_old_esn_info_rec.objid,
                                          c_old_esn_info_rec.x_part_inst2site_part, --CR40137
                                          c_old_esn_info_rec.part_inst_status) LOOP
        DBMS_OUTPUT.put_line('c_repl_part_rec.phone_gen:'||c_repl_part_rec.phone_gen);
        DBMS_OUTPUT.put_line('c_repl_part_rec.esn_part_number:'||c_repl_part_rec.esn_part_number);
        for repl_carr_rec in c_repl_carr(c_repl_part_rec.technology,
                                         c_repl_part_rec.dll,
                                         c_repl_part_rec.esn_part_number,
                                         c_repl_part_rec.bus_org_objid,
                                         c_repl_part_rec.data_speed  ,
                                         c_repl_part_rec.non_ppe    ,
                                         c_repl_part_rec.phone_frequency ,
                                         c_repl_part_rec.phone_frequency2,
                                         c_repl_part_rec.meid_phone     ,
                                         c_old_esn_info_rec.dealer_id     ,
                                         c_repl_part_rec.part_inst_status,
                                         c_repl_part_rec.phone_gen,
                                         null) loop
          dbms_output.put_line(repl_carr_rec.objid||':'||repl_carr_rec.x_parent_name );
          dbms_output.put_line('c_repl_part_rec.technology:'||c_repl_part_rec.technology );
          dbms_output.put_line('sim_junk_rec.carrier_name:'||sim_junk_rec.carrier_name );
          dbms_output.put_line('c_repl_part_rec.phone_gen:'||c_repl_part_rec.phone_gen );
          dbms_output.put_line('c_old_esn_info_rec.phone_gen:'||c_old_esn_info_rec.phone_gen );
          dbms_output.put_line('repl_carr_rec.x_allow_2g_react:'||repl_carr_rec.x_allow_2g_react );
          dbms_output.put_line('repl_carr_rec.x_allow_2g_act:'||repl_carr_rec.x_allow_2g_act );
          dbms_output.put_line('repl_carr_rec.sim_profile:'||repl_carr_rec.sim_profile );
          p_repl_part := c_repl_part_rec.esn_part_number;
          p_repl_tech := c_repl_part_rec.technology;
          if c_repl_part_rec.technology  = 'GSM' then
            p_repl_sim  := repl_carr_rec.sim_profile;
                  end if;
          dbms_output.put_line('partfound');
          goto partfound;
        end loop;
      end loop;
      <<partfound>>
      IF p_repl_part IS NOT NULL THEN
         p_out_msg := 'Replacement Part Found';
      ELSE
         p_out_msg := 'No Replacement Part Found';
      END IF;
   END get_repl_part_prc;
---------------------------------------------
   -- * sub function gsm_is_valid_iccid_fun * --
   --   is SIM card valid                     --
   ---------------------------------------------
--cwl 6/30/2014 CR29254
   FUNCTION gsm_is_valid_iccid_fun
     RETURN NUMBER
   IS
     CURSOR c_sim_status IS
       SELECT pn.part_number,
              sim.x_sim_mnc,
              sim.x_sim_inv_status
         FROM table_x_sim_inv sim,
              table_mod_level ml,
              table_part_num pn
        WHERE 1 = 1
          AND sim.x_sim_inv2part_mod = ml.objid
          AND ml.part_info2part_num = pn.objid
          AND sim.x_sim_serial_no = p_sim;
     c_sim_status_rec c_sim_status%ROWTYPE;
     CURSOR c_is_sim_married IS
       SELECT part_serial_no
         FROM table_part_inst
        WHERE x_iccid = p_sim
          and part_serial_no = global_esn;
     c_is_sim_married_rec c_is_sim_married%ROWTYPE;
     l_sim_mnc_cnt NUMBER := 0;
   BEGIN
     OPEN c_sim_status;
       FETCH c_sim_status  INTO c_sim_status_rec;
       IF c_sim_status%notfound THEN
         CLOSE c_sim_status;
         RETURN 10;
       END IF;
       global_sim_profile := c_sim_status_rec.part_number;
       DBMS_OUTPUT.put_line('global_sim_profile gsm_is_valid_iccid_fun:'||global_sim_profile );
       DBMS_OUTPUT.put_line('c_sim_status_rec.x_sim_inv_status:'||  c_sim_status_rec.x_sim_inv_status );
       IF c_sim_status_rec.x_sim_inv_status IN ('251', '253') THEN
         null;
       elsif c_sim_status_rec.x_sim_inv_status ='254' then
         OPEN c_is_sim_married;
           FETCH c_is_sim_married INTO c_is_sim_married_rec;
           IF c_is_sim_married%NOTFOUND THEN
             DBMS_OUTPUT.put_line('c_is_sim_married%NOTFOUND' );
             CLOSE c_sim_status;
             CLOSE c_is_sim_married;
             RETURN 1;
           END IF;
         close c_is_sim_married;
       ELSE
         DBMS_OUTPUT.put_line('BAD SIM STATUS:'|| c_sim_status_rec.x_sim_inv_status);
         CLOSE c_sim_status;
         RETURN 2;
       END IF;
    CLOSE c_sim_status;
    IF carrier_dflt_cnt = 0 THEN
      DBMS_OUTPUT.put_line('251,253:3' );
      RETURN 11;
    END IF;
    RETURN 0;
   END gsm_is_valid_iccid_fun;
--cwl 6/30/2014 CR29254
   ---------------------------------------
   -- * sub procedure update_line_prc * --
   --   updates the line record         --
   --   in table_part_inst              --
   ---------------------------------------
   PROCEDURE update_line_prc(
      p_part_serial_no IN VARCHAR2
   )
   IS
      CURSOR c1
      IS
      SELECT phones.objid
      FROM table_part_inst phones
      WHERE phones.x_domain = 'PHONES'
      AND phones.part_serial_no = global_esn;
      c1_rec c1%ROWTYPE;
      hold_part_inst_status VARCHAR (200);
-----------------------------------------------
   -- sub procedure update_line_prc starts here --
   -----------------------------------------------
   BEGIN
      IF global_commit = 'YES'
      THEN
         OPEN c1;
         FETCH c1
         INTO c1_rec;
         CLOSE c1;
         SELECT x_part_inst_status,
            part_inst2carrier_mkt
         INTO hold_part_inst_status, p_pref_carrier_objid
         FROM table_part_inst
         WHERE part_serial_no = p_part_serial_no
         AND x_part_inst_status IN ('11', '12')
         AND x_domain = 'LINES' FOR UPDATE NOWAIT;
         UPDATE table_part_inst SET x_part_inst_status = DECODE (
         x_part_inst_status, '11', '37', '12', '39' ), part_to_esn2part_inst =
         c1_rec.objid, status2x_code_table = DECODE (x_part_inst_status, '11',
         969, '12', 1040 ), last_cycle_ct = SYSDATE
         WHERE part_serial_no = p_part_serial_no
         AND x_part_inst_status IN ('11', '12')
         AND x_domain = 'LINES';
      END IF;
      DBMS_OUTPUT.put_line ('global_commit = ' || global_commit);
      global_resource_busy := 'N';
      EXCEPTION
      WHEN OTHERS
      THEN
         global_resource_busy := 'Y';
   END update_line_prc;
   -------------------------------------------
   -- * sub procedure update_c_choice_prc * --
   --   inserts new record into             --
   --   nap_c_choice table                  --
   -------------------------------------------
   PROCEDURE update_c_choice_prc(
      c_phone IN VARCHAR2,
      c_choice IN VARCHAR2
   )
   IS
   BEGIN
      IF global_commit = 'YES'
      THEN
         INSERT
         INTO nap_c_choice(
            zip,
            esn,
            given_line,
            choice,
            action_date
         )         VALUES(
            global_zip,
            global_esn,
            c_phone,
            c_choice,
            SYSDATE
         );
      END IF;
   END update_c_choice_prc;
   ------------------------------------
   -- * sub function valid_zip_fun * --
   ------------------------------------
   FUNCTION valid_zip_fun
   RETURN BOOLEAN
   IS
      CURSOR c_check_zip
      IS
      SELECT 1
      FROM carrierzones
      WHERE zip = global_zip;
      c_check_zip_rec c_check_zip%ROWTYPE;
      b_return_value BOOLEAN;
--------------------------------------------
   -- sub function valid_zip_fun starts here --
   --------------------------------------------
   BEGIN
      OPEN c_check_zip;
      FETCH c_check_zip
      INTO c_check_zip_rec;
      b_return_value := c_check_zip%FOUND;
      CLOSE c_check_zip;
      -------
      -- * --
      -------
      RETURN b_return_value;
   END valid_zip_fun;
   ----------------
   -- CR5192 START:
   ----------------
   --------------------------------------------
   -- * sub function is_no_service_zip_fun * --
   --------------------------------------------
   FUNCTION is_no_service_zip_fun
   RETURN BOOLEAN
   IS
-------------------------------------
      -- x_no_service_zip                --
      -- (table that contains zipcodes   --
      -- where service is not available) --
      -------------------------------------
      CURSOR c_check_no_service
      IS
      SELECT 1
      FROM x_no_service_zip
      WHERE zip = global_zip;
      c_check_no_service_rec c_check_no_service%ROWTYPE;
      b_return_value BOOLEAN := TRUE;
----------------------------------------------------
   -- sub function is_no_service_zip_fun starts here --
   ----------------------------------------------------
   BEGIN
      OPEN c_check_no_service;
      FETCH c_check_no_service
      INTO c_check_no_service_rec;
      IF c_check_no_service%FOUND
      THEN
         -- CLOSE c_check_no_service; --fix 06/08/06 OPEN_CURSORS
         b_return_value := FALSE;
      END IF;
      CLOSE c_check_no_service;
      -------
      -- * --
      -------
      RETURN b_return_value;
   END;
   -------------
   -- CR5192 END
   -------------
   --CR13234
   -------------------------------------------
   -- * sub function check_safelink_proc * --
   --   global_safelink := 1 if safelink
   --   global_safelink := 0 if not
   -------------------------------------------
   procedure check_safelink_proc IS
        --CR38885
      CURSOR c_cell_num IS
       SELECT /*+ ORDERED */
              lineparent.x_parent_name
         FROM
              table_part_inst pi_old,
              table_mod_level ml_old,
              table_part_num pn_old,
--
              table_part_inst lines,
              table_x_carrier linecarrier,
              table_x_carrier_group linegroup,
              table_x_parent lineparent
        WHERE 1=1
          AND pi_old.part_serial_no = p_esn
          AND pi_old.x_domain = 'PHONES'
          and ml_old.objid = pi_old.n_part_inst2part_mod
          and pn_old.objid = ml_old.part_info2part_num
--
          AND lines.part_to_esn2part_inst = pi_old.objid
          and lines.x_domain||'' = 'LINES'
          AND lines.x_part_inst_status||'' IN ('37', '39', '73')
          AND linecarrier.objid = lines.part_inst2carrier_mkt
          AND linegroup.objid = linecarrier.carrier2carrier_group
          AND lineparent.objid = linegroup.x_carrier_group2x_parent;
     c_cell_num_rec c_cell_num%ROWTYPE;
     CURSOR c_cell_num2 IS
       select 'FOUND' x_safelink
         from table_part_inst pi,
              table_inv_bin ib
        where pi.part_serial_no = p_esn
          and ib.objid = pi.part_inst2inv_bin
          and ib.bin_name IN (select x_param_value from table_x_parameters where  x_param_name = 'SL_DEALER_ID');--( '24920','42356');CR42560 changes
     c_cell_num_rec2 c_cell_num2%ROWTYPE;
   ---------------------------------------------------
   -- sub function check_safelink_fun starts here --
   ---------------------------------------------------
   BEGIN
     --CR38885
     OPEN c_cell_num;
       FETCH c_cell_num INTO c_cell_num_rec;
       IF c_cell_num%FOUND then
         if c_cell_num_rec.x_parent_name like '%SAFELINK%' then
           CLOSE c_cell_num;
           global_safelink := 'FOUND';
           dbms_output.put_line('line attached is SAFELINK');
           return;
         else
           CLOSE c_cell_num;
           global_safelink := 'NOT FOUND';
           dbms_output.put_line('line attached is NOT SAFELINK');
           return;
         end if;
       END IF;
     CLOSE c_cell_num;
     OPEN c_cell_num2;
       FETCH c_cell_num2 INTO c_cell_num_rec2;
       IF c_cell_num2%FOUND then
         global_safelink := 'FOUND';
         dbms_output.put_line('line attached is SAFELINK');
       else
         global_safelink := 'NOT FOUND';
         dbms_output.put_line('line attached is NOT SAFELINK');
       end if;
     close c_cell_num2;
   END check_safelink_proc;
   -------------------------------------------
   -- * sub function check_line_locks_fun * --
   --   returns MIN number from             --
   --   table_part_inst                     --
   -------------------------------------------
   --CR13234
   FUNCTION check_line_locks_fun
   RETURN BOOLEAN
   IS
      CURSOR c_cell_num
      IS
      SELECT lines.objid,
         lines.part_serial_no,
         lineparent.x_parent_name line_parent_name,
         -- Cr5568: will be used to compare MIN and ESN carriers
         lines.x_part_inst_status line_status,
         lines.x_port_in,
         lines.part_inst2carrier_mkt,
         NVL(lineparent.x_no_msid, 0) x_no_msid
      FROM table_part_inst lines, table_part_inst phones, table_x_parent
      lineparent, table_x_carrier_group linegroup, table_x_carrier linecarrier
      WHERE lines.x_domain = 'LINES'
      AND lines.part_to_esn2part_inst = phones.objid
      AND lines.part_inst2carrier_mkt = linecarrier.objid
      AND linecarrier.carrier2carrier_group = linegroup.objid
      AND linegroup.x_carrier_group2x_parent = lineparent.objid
      AND lines.x_part_inst_status IN ('37', '39', '73', '110')
      AND phones.x_domain = 'PHONES'
      AND phones.part_serial_no = global_esn;
      c_cell_num_rec c_cell_num%ROWTYPE;
      CURSOR c_no_msid_line(
         c_ip_min IN VARCHAR2
      )
      IS
      SELECT 1
      FROM table_x_parent cp, table_x_carrier_group cg, table_x_carrier ca,
      table_part_inst pimin
      WHERE pimin.part_inst2carrier_mkt = ca.objid
      AND ca.carrier2carrier_group = cg.objid
      AND cg.x_carrier_group2x_parent = cp.objid
      AND cp.x_no_msid = 1
      AND pimin.part_serial_no = c_ip_min;
      c_no_msid_line_rec c_no_msid_line%ROWTYPE;
---------------------------------------------------
   -- sub function check_line_locks_fun starts here --
   ---------------------------------------------------
   BEGIN
      global_line_status := NULL;
      global_min_carrier_name := NULL;
      OPEN c_cell_num;
      FETCH c_cell_num
      INTO c_cell_num_rec;
      IF c_cell_num%FOUND
      AND (c_cell_num_rec.line_status != '110'
      OR c_cell_num_rec.x_no_msid != 1)
      THEN
         DBMS_OUTPUT.put_line('port_in:1 c_cell_num%found');
         global_line_status := c_cell_num_rec.line_status;
         global_min_carrier_name := c_cell_num_rec.line_parent_name;
         global_part_serial_no := c_cell_num_rec.part_serial_no;
      END IF;
      CLOSE c_cell_num;
      --CR6925
      ---------------------------------------------------------------------------------------------------
      -- new locks logic
      ---------------------------------------------------------------------------------------------------
      IF global_part_serial_no
      IS
      NOT NULL
      THEN
         DBMS_OUTPUT.put_line('global_part_serial_no               :'||
         global_part_serial_no );
         DBMS_OUTPUT.put_line('c_cell_num_rec.part_inst2carrier_mkt:'||
         c_cell_num_rec.part_inst2carrier_mkt);
         DBMS_OUTPUT.put_line('global_technology:'|| global_technology );
         IF global_technology != 'GSM'
         THEN
            FOR i IN 1..carrier_prf_cnt
            LOOP
               IF carrier_prf_array(i) = c_cell_num_rec.part_inst2carrier_mkt
               THEN
                  carrier_prf_cnt := 1;
                  carrier_prf_array(1) := carrier_prf_array(i);
                  carrier_dflt_cnt := 0;
                  DBMS_OUTPUT.put_line('lock carrier_prf_cnt:found');
                  RETURN TRUE;
               END IF;
            END LOOP;
         END IF;
         FOR i IN 1..carrier_dflt_cnt
         LOOP
            IF carrier_dflt_array(i) = c_cell_num_rec.part_inst2carrier_mkt
            THEN
               carrier_dflt_cnt := 1;
               carrier_dflt_array(1) := carrier_dflt_array(i);
               carrier_prf_cnt := 0;
               DBMS_OUTPUT.put_line('lock carrier_dflt_cnt:found');
               RETURN TRUE;
            END IF;
         END LOOP;
         DBMS_OUTPUT.put_line('NO lock carrier_dflt_cnt:found');
         RETURN FALSE;
      ELSE
         DBMS_OUTPUT.put_line('NO lock carrier_dflt_cnt:found2');
         RETURN FALSE;
      END IF;
---------------------------------------------------------------------------------------------------
   -- new locks logic
   ---------------------------------------------------------------------------------------------------
   --CR6925
   END check_line_locks_fun;
   -------------------------------------------------------
   -- * sub procedure get_carriers_prc *                --
   --   Finds default and preferred lists of carriers   --
   --   for the given ESN.                              --
   --   This procedure is called for the phones with    --
   --   NO GSM technology.                              --
   --   It's the largest sub in the code.               --
   -------------------------------------------------------
   PROCEDURE get_carriers_prc
   IS
     cursor sim_part_num_curs is
       SELECT pn2.part_number
         FROM table_x_sim_inv sim,
                            table_mod_level ml,
                                    table_part_num pn2
        WHERE 1 = 1
          AND ml.part_info2part_num = pn2.objid
          AND sim.x_sim_inv2part_mod = ml.objid
          AND sim.x_sim_serial_no = p_sim;      -- BRAND_SEP
      sim_part_num_rec sim_part_num_curs%rowtype;
      CURSOR c_dealer
      IS
      SELECT s.site_id,
         pn.x_technology,
         pn.x_dll,
         NVL (pi.part_good_qty, 0) part_good_flag,
         pi.part_bin,  -- CR5028
         NVL(pn.x_meid_phone, 0) x_meid_phone,  --cdma meid check 5/16/07
         bo.org_id
      FROM table_part_num pn, table_mod_level ml, table_site s, table_inv_role
      ir, table_inv_bin ib, table_part_inst pi, table_bus_org bo
      WHERE pn.objid = ml.part_info2part_num
      AND ml.objid = pi.n_part_inst2part_mod
      AND s.objid = ir.inv_role2site
      AND ir.inv_role2inv_locatn = ib.inv_bin2inv_locatn
      AND ib.objid = pi.part_inst2inv_bin
      AND pi.x_domain = 'PHONES'
      AND pi.part_serial_no = global_esn
      AND pn.PART_NUM2BUS_ORG = bo.objid;
      c_dealer_rec c_dealer%ROWTYPE;
      -------
      -- * --
      -------
      ----cdma meid check 5/16/07 add c_meid_phone for check
      -- BRAND_SEP
      CURSOR c_prf_carrier( c_dealer IN VARCHAR2,
                            c_meid_phone IN NUMBER,
                            c_sim_part_num in varchar2,
                            c_dll in number) IS
      SELECT ca.objid,
             ca.x_carrier_id,
             ca.x_react_analog,
             ca.x_react_technology ca_react_technology,
             ca.x_act_analog,
             ca.x_act_technology ca_act_technology,
             pt.x_technology pref_technology,
             f.x_frequency,
             pt.x_activation,  --CR5028
             pt.x_reac_exception_code,  --CR5028
             pt.x_reactivation--CR5028
        FROM table_x_frequency f,
             mtm_x_frequency2_x_pref_tech1 f2pt,
             table_x_pref_tech pt,
             table_x_carrier ca,
             table_x_carrierdealer c,
             table_x_carrier_group cg,
             table_x_parent p,
             (SELECT min(to_number(cp.new_rank)) new_rank, b.carrier_id,a.sim_profile,a.min_dll_exch,a.max_dll_exch
                FROM carrierpref cp,
                                   npanxx2carrierzones b,
                     (SELECT DISTINCT
                             a.ZONE,
                             a.st,
                             s.sim_profile,
                             a.county,
                             s.min_dll_exch,
                             s.max_dll_exch,
                                                                                     s.rank
                        FROM carrierzones a,
                             carriersimpref s
                       WHERE a.zip = p_zip
                         and a.CARRIER_NAME=s.CARRIER_NAME
                         and c_dll between s.MIN_DLL_EXCH and s.MAX_DLL_EXCH) a
               WHERE 1=1
                 AND cp.st = b.state
                 and cp.carrier_id = b.carrier_ID
                               and cp.county = a.county
                 AND (   b.cdma_tech = 'CDMA' )
                               and a.sim_profile = decode(c_sim_part_num,null,'NA',c_sim_part_num)
                 AND b.ZONE = a.ZONE
                 AND b.state = a.st
               group by b.carrier_id,a.sim_profile,a.min_dll_exch,a.max_dll_exch) tab1,
             (select pn.part_num2bus_org,
                     pn.x_technology,
                     pn.PART_NUM2PART_CLASS,
                     NVL(pn.x_meid_phone, 0) meid_phone,
                     pi.x_part_inst_status,
                     nvl((select v.x_param_value
                            from table_x_part_class_values v,
                                 table_x_part_class_params n
                           where 1=1
                             and v.value2part_class     = pn.part_num2part_class
                             and v.value2class_param    = n.objid
                             and n.x_param_name         = 'PHONE_GEN'
                             and rownum <2),'2G') PHONE_GEN,
                     nvl((select v.x_param_value
                            from table_x_part_class_values v,
                                 table_x_part_class_params n
                           where 1=1
                             and v.value2part_class     = pn.part_num2part_class
                             and v.value2class_param    = n.objid
                             and n.x_param_name         = 'DATA_SPEED'
                             and rownum <2),NVL(pn.x_data_capable, 0)) data_speed,
                     nvl((SELECT COUNT(*) sr
                           FROM table_x_part_class_values v, table_x_part_class_params n
                          WHERE 1 = 1
                            AND v.value2part_class = pn.part_num2part_class
                            AND v.value2class_param = n.objid
                            AND n.x_param_name = 'NON_PPE'
                            AND v.x_param_value in ( '1','0') -- CR15018 --12/02/10 invalid number fix
                            AND ROWNUM < 2),0) non_ppe,
                      bo.org_id
               from table_bus_org bo ,
                     table_part_num pn,
                     sa.table_mod_level ml,
                     table_part_inst pi
               where 1=1
                 and bo.objid          = pn.part_num2bus_org
                 and pn.objid          = ml.part_info2part_num
                 and ml.objid          = pi.n_part_inst2part_mod
                 AND pi.part_serial_no = p_esn) tab2
       WHERE 1=1
         AND NOT EXISTS (SELECT 1
                           FROM table_x_not_certify_models cm
                          WHERE 1 = 1
                            AND cm.X_PART_CLASS_OBJID = tab2.PART_NUM2PART_CLASS
                            AND cm.X_PARENT_ID = p.x_parent_id)
         and f.objid = f2pt.x_frequency2x_pref_tech
         AND f.x_frequency + 0 <= NVL (global_phone_frequency, 800)
         AND f2pt.x_pref_tech2x_frequency = pt.objid
         AND pt.x_pref_tech2x_carrier = ca.objid
         AND ca.x_status || '' = 'ACTIVE' --CR5757
         AND ca.x_carrier_id = tab1.carrier_id
         AND c.x_carrier_id = tab1.carrier_id
                --CR38885
         AND c.x_dealer_id ||'' = case when global_safelink = 'FOUND' then
                                         '24920'
                                       else
                                         decode(c.x_dealer_id,'24920','XXXXXX','DEFAULT','XXXXXX',c.x_dealer_id)
                                       end
                --CR38885
         AND cg.objid = ca.CARRIER2CARRIER_GROUP
         and p.objid = cg.X_CARRIER_GROUP2X_PARENT
         and decode( p.x_meid_carrier,1,tab2.meid_phone,null,0,p.x_meid_carrier) = tab2.meid_phone
--CR23419
         and exists(select 1
                      from table_x_carrier_features cf
                     where 1=1
         and cf.X_FEATURES2BUS_ORG = tab2.part_num2bus_org
         and cf.x_technology = tab2.x_technology
         and cf.x_data=tab2.data_speed
         and decode(cf.X_SWITCH_BASE_RATE,null,tab2.non_ppe,1) = tab2.non_ppe
         and (  cf.x_feature2x_carrier = ca.objid
              or (      tab2.org_id = 'NET10'
                   and  exists(SELECT 1
                               FROM table_x_carrier_group cg2,
                                    table_x_carrier c2
                              WHERE cg2.x_carrier_group2x_parent = p.objid
                                AND c2.carrier2carrier_group = cg2.objid
                                and c2.objid = cf.x_feature2x_carrier))))
         and 1=(case when tab2.phone_gen = '2G' then
                       (select count(*)
                         from table_x_carrier_rules cr
                        where (   (    cr.objid = decode(tab2.x_technology,'CDMA', nvl(ca.CARRIER2RULES_CDMA, ca.CARRIER2RULES),
                                                                       'GSM' , nvl(ca.CARRIER2RULES_GSM, ca.CARRIER2RULES), ca.CARRIER2RULES)
                                   and cr.x_allow_2g_react = '2G'
                                   and tab2.x_part_inst_status not in ('50','150'))
                               or (    cr.objid = decode(tab2.x_technology,'CDMA', nvl(ca.CARRIER2RULES_CDMA, ca.CARRIER2RULES),
                                                                        'GSM' , nvl(ca.CARRIER2RULES_GSM, ca.CARRIER2RULES), ca.CARRIER2RULES)
                                   and cr.x_allow_2g_act = '2G'
                                   and tab2.x_part_inst_status in ('50','150')))
                          and rownum < 2)
                     else
                       1
                     end)
--CR23419
      ORDER BY f.x_frequency DESC;
      -------
      -- * --
      -------
      -------------------------------------
      -- check to see if this is a react --
      -------------------------------------
      ----------------------------------
      -- Emergency fix for CR5028: START
      ----------------------------------
      CURSOR c_react
      IS
      SELECT 'X' col1
      FROM table_part_inst
      WHERE part_serial_no = p_esn
      AND x_domain = 'PHONES'
      AND x_part_inst_status || '' IN ('50', '150');
      ----------------------------------
      -- Emergency fix for CR5028: END
      ----------------------------------
      c_react_rec c_react%ROWTYPE;
      l_c_react_found BOOLEAN := FALSE;
      -------
      -- * --
      -------
      ----------------------------------------------------------
      -- determine the frequency of the phone being activated --
      ----------------------------------------------------------
      CURSOR c_phone_frequency
      IS
      SELECT MAX (f.x_frequency) phone_frequency
      FROM table_x_frequency f, mtm_part_num14_x_frequency0 pf, table_part_num
      pn, table_mod_level ml, table_part_inst pi
      WHERE pf.x_frequency2part_num = f.objid
      AND pn.objid = pf.part_num2x_frequency
      AND pn.objid = ml.part_info2part_num
      AND ml.objid = pi.n_part_inst2part_mod
      AND pi.part_serial_no = global_esn
      AND pi.x_domain = 'PHONES';
      -------
      -- * --
      -------
      ---------------------
      -- DEFAULT carrier --
      ---------------------
      ----cdma meid check 5/16/07 add c_meid_phone for check
      -- BRAND_SEP
      CURSOR c_dflt_carrier(c_dealer IN VARCHAR2,
                            c_meid_phone IN NUMBER,
                            c_sim_part_num in varchar2,
                            c_dll in number) IS
      SELECT ca.objid,
             ca.x_carrier_id,
             ca.x_react_analog,
             ca.x_react_technology ca_react_technology,
             ca.x_act_analog,
             ca.x_act_technology ca_act_technology,
             pt.x_technology pref_technology,
             f.x_frequency,
             pt.x_activation,  --CR5028
             pt.x_reac_exception_code,  --CR5028
             pt.x_reactivation--CR5028
             ,tab1.sim_profile
        FROM table_x_frequency f,
             mtm_x_frequency2_x_pref_tech1 f2pt,
             table_x_pref_tech pt,
             table_x_carrier ca,
             table_x_carrierdealer c,
             table_x_carrier_group cg,
             table_x_parent p,
             (SELECT min(to_number(cp.new_rank)) new_rank, b.carrier_id,a.sim_profile,a.min_dll_exch,a.max_dll_exch
                FROM carrierpref cp,
                                   npanxx2carrierzones b,
                     (SELECT DISTINCT
                             a.ZONE,
                             a.st,
                             s.sim_profile,
                             a.county,
                             s.min_dll_exch,
                             s.max_dll_exch,
                                                                                     s.rank
                        FROM carrierzones a,
                             carriersimpref s
                       WHERE a.zip = p_zip
                         and a.CARRIER_NAME=s.CARRIER_NAME
                         and c_dll between s.MIN_DLL_EXCH and s.MAX_DLL_EXCH) a
               WHERE 1=1
                 AND cp.st = b.state
                 and cp.carrier_id = b.carrier_ID
                               and cp.county = a.county
                 AND (   b.cdma_tech = 'CDMA' )
                               and a.sim_profile = decode(c_sim_part_num,null,'NA',c_sim_part_num)
                 AND b.ZONE = a.ZONE
                 AND b.state = a.st
               group by b.carrier_id,a.sim_profile,a.min_dll_exch,a.max_dll_exch) tab1,
             (select pn.part_num2bus_org,
                     pn.x_technology,
                     pn.PART_NUM2PART_CLASS,
                     NVL(pn.x_meid_phone, 0) meid_phone,
                     pi.x_part_inst_status,
                     nvl((select v.x_param_value
                            from table_x_part_class_values v,
                                 table_x_part_class_params n
                           where 1=1
                             and v.value2part_class     = pn.part_num2part_class
                             and v.value2class_param    = n.objid
                             and n.x_param_name         = 'PHONE_GEN'
                             and rownum <2),'2G') phone_gen,
                     nvl((select v.x_param_value
                            from table_x_part_class_values v,
                                 table_x_part_class_params n
                           where 1=1
                             and v.value2part_class     = pn.part_num2part_class
                             and v.value2class_param    = n.objid
                             and n.x_param_name         = 'DATA_SPEED'
                             and rownum <2),NVL(pn.x_data_capable, 0)) data_speed,
                     nvl((SELECT COUNT(*) sr
                           FROM table_x_part_class_values v, table_x_part_class_params n
                          WHERE 1 = 1
                            AND v.value2part_class = pn.part_num2part_class
                            AND v.value2class_param = n.objid
                            AND n.x_param_name = 'NON_PPE'
                            AND v.x_param_value in ( '1','0') -- CR15018 --12/02/10 invalid number fix
                            AND ROWNUM < 2),0) non_ppe,
                      bo.org_id
               from table_bus_org bo ,
                     table_part_num pn,
                     sa.table_mod_level ml,
                     table_part_inst pi
               where 1=1
                 and bo.objid          = pn.part_num2bus_org
                 and pn.objid          = ml.part_info2part_num
                 and ml.objid          = pi.n_part_inst2part_mod
                 AND pi.part_serial_no = p_esn) tab2
       WHERE f.objid = f2pt.x_frequency2x_pref_tech
         AND f.x_frequency + 0 <= NVL (global_phone_frequency, 800)
         AND f2pt.x_pref_tech2x_frequency = pt.objid
         AND pt.x_pref_tech2x_carrier = ca.objid
         AND ca.x_status || '' = 'ACTIVE' --CR5757
         AND ca.x_carrier_id = tab1.carrier_id
                --CR38885
         AND c.x_dealer_id ||'' = case when global_safelink = 'FOUND' then
                                         'XXXXXX'
                                       else
                                         'DEFAULT'
                                       end
                --CR38885
         AND c.x_carrier_id = tab1.carrier_id
         AND cg.objid = ca.CARRIER2CARRIER_GROUP
         and p.objid = cg.X_CARRIER_GROUP2X_PARENT
         AND NOT EXISTS (SELECT 1
                           FROM table_x_not_certify_models cm
                          WHERE 1 = 1
                             AND cm.X_PART_CLASS_OBJID = tab2.PART_NUM2PART_CLASS
                             AND cm.X_PARENT_ID = p.x_parent_id)
         and decode( p.x_meid_carrier,1,tab2.meid_phone,null,0,p.x_meid_carrier) = tab2.meid_phone
--CR23419
         and exists(select 1
                      from table_x_carrier_features cf
                     where 1=1
         and cf.X_FEATURES2BUS_ORG = tab2.part_num2bus_org
         and cf.x_technology = tab2.x_technology
         and cf.x_data=tab2.data_speed
         and decode(cf.X_SWITCH_BASE_RATE,null,tab2.non_ppe,1) = tab2.non_ppe
         and (  cf.x_feature2x_carrier = ca.objid
              or (      tab2.org_id = 'NET10'
                   and  exists(SELECT 1
                               FROM table_x_carrier_group cg2,
                                    table_x_carrier c2
                              WHERE cg2.x_carrier_group2x_parent = p.objid
                                AND c2.carrier2carrier_group = cg2.objid
                                and c2.objid = cf.x_feature2x_carrier))))
         and 1=(case when tab2.phone_gen = '2G' then
                       (select count(*)
                          from table_x_carrier_rules cr
                         where (   (    cr.objid = decode(tab2.x_technology,'CDMA', nvl(ca.CARRIER2RULES_CDMA, ca.CARRIER2RULES),
                                                                         'GSM', nvl(ca.CARRIER2RULES_GSM, ca.CARRIER2RULES), ca.CARRIER2RULES)
                                    and cr.x_allow_2g_react = '2G'
                                    and tab2.x_part_inst_status not in ('50','150'))
                                or (    cr.objid = decode(tab2.x_technology,'CDMA', nvl(ca.CARRIER2RULES_CDMA, ca.CARRIER2RULES),
                                                                        'GSM' , nvl(ca.CARRIER2RULES_GSM, ca.CARRIER2RULES), ca.CARRIER2RULES)
                                    and cr.x_allow_2g_act = '2G'
                                    and tab2.x_part_inst_status in ('50','150')))
                            and rownum < 2)
                     else
                       1
                     end)
--CR23419
      ORDER BY f.x_frequency DESC;
      -------
      -- * --
      -------
      CURSOR c_carrier_group(
         c_carrier_objid IN NUMBER
      )
      IS
      SELECT TO_NUMBER (p.x_parent_id) x_carrier_group_id
      FROM table_x_parent p, table_x_carrier_group cg, table_x_carrier c
      WHERE p.objid = cg.x_carrier_group2x_parent
      AND UPPER (p.x_status) = 'ACTIVE'
      AND cg.objid = c.carrier2carrier_group
      AND cg.x_status = 'ACTIVE'
      AND c.objid = c_carrier_objid;
      c_carrier_group_rec c_carrier_group%ROWTYPE;
      -------
      -- * --
      -------
      ----------------------------------------------------------------------------------------
      -- check to see if this is a cingular fcc market where analog reactivation is allowed --
      ----------------------------------------------------------------------------------------
      CURSOR c_react_cingular
      IS
      SELECT cm.market_id
      FROM x_cingular_fcc_mkt cm, carrierzones zm
      WHERE zm.marketid = cm.market_id
      AND zm.zip = global_zip;
      c_react_cingular_rec c_react_cingular%ROWTYPE;
      l_c_react_cingular_found BOOLEAN := FALSE;
      l_carrier_group_id2check1 NUMBER;
      l_carrier_group_id2check2 NUMBER;
      ---------------------------------------
      -- CR5040                         dflt   --
      -- Carrier preferrence logic changes --
      ---------------------------------------
      l_position_found BOOLEAN := FALSE;
      l_position_found_rank NUMBER := 1;
------------------------------------------------
   -- sub procedure get_carriers_prc starts here --
   ------------------------------------------------
   BEGIN
      OPEN c_dealer;
      FETCH c_dealer
      INTO c_dealer_rec;
      global_dealer_id := c_dealer_rec.site_id;
      global_technology := c_dealer_rec.x_technology;
      -- BRAND_SEP
      global_brand_name := c_dealer_rec.org_id; -- Amigo
      CLOSE c_dealer;
      DBMS_OUTPUT.put_line ('dealer_id :' || c_dealer_rec.site_id);
      if p_sim is not null and sa.LTE_SERVICE_PKG.IS_ESN_LTE_CDMA (P_ESN)=1 then
        open sim_part_num_curs;
          fetch sim_part_num_curs into sim_part_num_rec;
        close sim_part_num_curs;
      end if;
      ----------------------------------------------
      -- Check Phone Frequency - Motorola Digital --
      ----------------------------------------------
      OPEN c_phone_frequency;
      FETCH c_phone_frequency
      INTO global_phone_frequency;
      CLOSE c_phone_frequency;
      OPEN c_react;
      FETCH c_react
      INTO c_react_rec;
      l_c_react_found := c_react%FOUND;
      CLOSE c_react;
      -----------------------------------
      -- Populate DEFAULT carrier list --
      -- step 1                        --
      -----------------------------------
      --FOR carrier_dflt_rec IN c_dflt_carrier (c_dealer_rec.site_id,
      --global_amigo_yn, c_dealer_rec.x_meid_phone --cdma meid check 5/16/07--
      --)
      FOR carrier_dflt_rec IN c_dflt_carrier (c_dealer_rec.site_id,
      c_dealer_rec.x_meid_phone,
      sim_part_num_rec.part_number,
      c_dealer_rec.x_dll
      )
      LOOP
-----------------------------------------------------------------------------
         -- This loop populates carrier DEFAULT list/array                          --
         -- with the values of X_CARRIER_ID column from c_dflt_carrier cursor.      --
         -- Note: The loop below this one, will continue to populate the same list, --
         -- going through the same cursor again.                                    --
         -- Not sure why do we need to loop twice through the same cursor ???       --
         -- Probably because the list order is important and conditions in          --
         -- the first loop take precedance over those in the second loop.           --
         -- Anyway, it makes you believe that this could be done in a better,       --
         -- simpler and more efficient way...                                       --
         -----------------------------------------------------------------------------
         DBMS_OUTPUT.put_line ( 'c_dealer_rec.x_technology        :' ||
         c_dealer_rec.x_technology );
         DBMS_OUTPUT.put_line ( 'carrier_dflt_rec.X_ACT_ANALOG      :' ||
         carrier_dflt_rec.x_act_analog );
         DBMS_OUTPUT.put_line ( 'carrier_dflt_rec.X_REACT_ANALOG    :' ||
         carrier_dflt_rec.x_react_analog );
         DBMS_OUTPUT.put_line ( 'carrier_dflt_rec.X_ACT_TECHNOLOGY  :' ||
         carrier_dflt_rec.pref_technology );
         DBMS_OUTPUT.put_line ( 'carrier_dflt_rec.X_REACT_TECHNOLOGY:' ||
         carrier_dflt_rec.pref_technology );
         DBMS_OUTPUT.put_line ( 'carrier_dflt_rec.x_carrier_id      :' ||
         TO_CHAR (carrier_dflt_rec.x_carrier_id) );
         DBMS_OUTPUT.put_line ( 'carrier_dflt_rec.x_frequency       :' ||
         carrier_dflt_rec.x_frequency );
         DBMS_OUTPUT.put_line ( 'global_phone_frequency         :' ||
         global_phone_frequency );
         IF ( l_c_react_found
         AND c_dealer_rec.x_technology = carrier_dflt_rec.pref_technology
         AND carrier_dflt_rec.ca_act_technology = 'Yes'
         AND carrier_dflt_rec.x_activation <> 0 -- CR5028
         )
         OR ( l_c_react_found
         AND c_dealer_rec.x_technology = 'ANALOG'
         AND carrier_dflt_rec.x_act_analog = 1 )
         OR ( NOT l_c_react_found
         AND c_dealer_rec.x_technology = 'ANALOG'
         AND carrier_dflt_rec.x_react_analog = 1 )
         OR ( NOT l_c_react_found
         AND c_dealer_rec.x_technology = carrier_dflt_rec.pref_technology
         AND carrier_dflt_rec.ca_react_technology = 'Yes' )
         THEN
            carrier_dflt_cnt := carrier_dflt_cnt + 1;
            carrier_dflt_array (carrier_dflt_cnt) := carrier_dflt_rec.objid;
            DBMS_OUTPUT.put_line ( 'carrier_dflt_rec.x_carrier_id :' || TO_CHAR
            ( carrier_dflt_rec.x_carrier_id) );
         END IF;
         IF carrier_dflt_rec.x_frequency = 1900
         THEN
            global_carrier_frequency := 1900;
         END IF;
         ----------------
         -- CR5192 START:
         ----------------
         IF carrier_dflt_rec.x_activation = 0
         THEN
            global_no_service := 1;
         END IF;
-------------
      -- CR5192 END
      -------------
      END LOOP;
      -----------------------------------
      -- Populate DEFAULT carrier list --
      -- step 2                        --
      -----------------------------------
     -----------------------------------------------------------------------
      -- Looping through the same cursor again, is it really necessary ??? --
      -----------------------------------------------------------------------
      --FOR carrier_dflt_rec IN c_dflt_carrier (c_dealer_rec.site_id,
      --global_amigo_yn, c_dealer_rec.x_meid_phone --cdma meid check 5/16/07--
      --)
      FOR carrier_dflt_rec IN c_dflt_carrier (c_dealer_rec.site_id,
      c_dealer_rec.x_meid_phone,
      sim_part_num_rec.part_number,
      c_dealer_rec.x_dll
      )
      LOOP
         IF ( l_c_react_found
         AND c_dealer_rec.x_technology != 'ANALOG'
         AND c_dealer_rec.x_technology = carrier_dflt_rec.pref_technology
         AND ( carrier_dflt_rec.ca_act_technology
         IS
         NULL
         OR carrier_dflt_rec.ca_act_technology = 'No' )
         AND ( carrier_dflt_rec.ca_react_technology
         IS
         NULL
         OR carrier_dflt_rec.ca_react_technology = 'No' )
         AND carrier_dflt_rec.x_act_analog = 1 )
         OR ( NOT l_c_react_found
         AND c_dealer_rec.x_technology != 'ANALOG'
         AND c_dealer_rec.x_technology = carrier_dflt_rec.pref_technology
         AND ( carrier_dflt_rec.ca_react_technology
         IS
         NULL
         OR carrier_dflt_rec.ca_react_technology = 'No' )
         AND ( carrier_dflt_rec.ca_act_technology
         IS
         NULL
         OR carrier_dflt_rec.ca_act_technology = 'No' )
         AND carrier_dflt_rec.x_react_analog = 1 )
         THEN
            carrier_dflt_cnt := carrier_dflt_cnt + 1;
            carrier_dflt_array (carrier_dflt_cnt) := carrier_dflt_rec.objid;
            DBMS_OUTPUT.put_line ( 'carrier_dflt_rec.x_carrier_id :' || TO_CHAR
            ( carrier_dflt_rec.x_carrier_id) );
         END IF;
         IF carrier_dflt_rec.x_frequency = 1900
         THEN
            global_carrier_frequency := 1900;
         END IF;
      END LOOP;
      -------
      -- * --
      -------
      -------------------------------------
      -- Populate PREFERRED carrier list --
      -- step 1                          --
      -------------------------------------
      --FOR c_prf_carrier_rec IN c_prf_carrier (c_dealer_rec.site_id,
      --global_amigo_yn, c_dealer_rec.x_meid_phone --cdma meid check 5/16/07--
      --)
      FOR c_prf_carrier_rec IN c_prf_carrier (c_dealer_rec.site_id,
      c_dealer_rec.x_meid_phone,
      sim_part_num_rec.part_number,
      c_dealer_rec.x_dll)
      LOOP
-----------------------------------------------------------------------------
         -- This loop populates carrier PREFERRED list/array                        --
         -- with the values of X_CARRIER_ID column from c_prf_carrier cursor.       --
         -- Note: The loop below this one, will populate the same list with         --
         -- the value of OBJID, going through the same cursor again.                --
         -- Not sure why we need to loop twice through the same cursor ???          --
         -- Probably because the list order is important and what's in              --
         -- X_CARRIER_ID takes precedence over what's in OBJID.                     --
         -- Anyway, this could be done in a better, simpler and                     --
         -- more efficient way...                                                   --
         -----------------------------------------------------------------------------
         DBMS_OUTPUT.put_line ( 'c_dealer_rec.x_technology        :' ||
         c_dealer_rec.x_technology );
         DBMS_OUTPUT.put_line ( 'c_prf_carrier_rec.X_ACT_ANALOG       :' ||
         c_prf_carrier_rec.x_act_analog );
         DBMS_OUTPUT.put_line ( 'c_prf_carrier_rec.X_REACT_ANALOG     :' ||
         c_prf_carrier_rec.x_react_analog );
         DBMS_OUTPUT.put_line ( 'c_prf_carrier_rec.X_ACT_TECHNOLOGY   :' ||
         c_prf_carrier_rec.pref_technology );
         DBMS_OUTPUT.put_line ( 'c_prf_carrier_rec.X_REACT_TECHNOLOGY :' ||
         c_prf_carrier_rec.pref_technology );
         DBMS_OUTPUT.put_line ( 'c_prf_carrier_rec.x_carrier_id       :' ||
         TO_CHAR (c_prf_carrier_rec.x_carrier_id) );
         DBMS_OUTPUT.put_line ( 'c_prf_carrier_rec.x_frequency        :' ||
         c_prf_carrier_rec.x_frequency );
         DBMS_OUTPUT.put_line ( 'global_phone_frequency         :' ||
         global_phone_frequency );
         IF ( l_c_react_found
         AND c_dealer_rec.x_technology = c_prf_carrier_rec.pref_technology
         AND c_prf_carrier_rec.ca_act_technology = 'Yes'
         AND c_prf_carrier_rec.x_activation <> 0 -- CR5028
         )
         OR ( l_c_react_found
         AND c_dealer_rec.x_technology = 'ANALOG'
         AND c_prf_carrier_rec.x_act_analog = 1 )
         OR ( NOT l_c_react_found
         AND c_dealer_rec.x_technology = 'ANALOG'
         AND c_prf_carrier_rec.x_react_analog = 1 )
         OR ( NOT l_c_react_found
         AND c_dealer_rec.x_technology = c_prf_carrier_rec.pref_technology
         AND c_prf_carrier_rec.ca_react_technology = 'Yes'
         AND ( c_prf_carrier_rec.x_reactivation <> 0
         OR ( c_prf_carrier_rec.x_reactivation = 0
         AND c_dealer_rec.part_bin = c_prf_carrier_rec.x_reac_exception_code )
         ) )
         THEN
            carrier_prf_cnt := carrier_prf_cnt + 1;
            carrier_prf_array (carrier_prf_cnt) := c_prf_carrier_rec.objid;
            DBMS_OUTPUT.put_line ( 'c_prf_carrier_rec.x_carrier_id :' ||
            TO_CHAR ( c_prf_carrier_rec.x_carrier_id) );
         END IF;
         ----------------
         -- CR5192 START:
         ----------------
         IF c_prf_carrier_rec.x_activation = 0
         THEN
            global_no_service := 1;
         END IF;
-------------
      -- CR5192 END
      -------------
      END LOOP;
      -------------------------------------
      -- Populate PREFERRED carrier list --
      -- step 2                          --
      -------------------------------------
      -----------------------------------------------------------------------
      -- Looping through the same cursor again, is it really necessary ??? --
      -----------------------------------------------------------------------
      --FOR c_prf_carrier_rec IN c_prf_carrier (c_dealer_rec.site_id,
      --global_amigo_yn, c_dealer_rec.x_meid_phone --cdma meid check 5/16/07--
      --)
      FOR c_prf_carrier_rec IN c_prf_carrier (c_dealer_rec.site_id,
      c_dealer_rec.x_meid_phone,
      sim_part_num_rec.part_number,
      c_dealer_rec.x_dll)
      LOOP
         IF ( l_c_react_found
         AND c_dealer_rec.x_technology != 'ANALOG'
         AND c_dealer_rec.x_technology = c_prf_carrier_rec.pref_technology
         AND c_prf_carrier_rec.x_act_analog = 1
         AND ( c_prf_carrier_rec.ca_act_technology
         IS
         NULL
         OR c_prf_carrier_rec.ca_act_technology = 'No' )
         AND ( c_prf_carrier_rec.ca_react_technology
         IS
         NULL
         OR c_prf_carrier_rec.ca_react_technology = 'No' ) )
         OR ( NOT l_c_react_found
         AND c_dealer_rec.x_technology != 'ANALOG'
         AND c_dealer_rec.x_technology = c_prf_carrier_rec.pref_technology
         AND c_prf_carrier_rec.x_react_analog = 1
         AND ( c_prf_carrier_rec.ca_react_technology
         IS
         NULL
         OR c_prf_carrier_rec.ca_react_technology = 'No' )
         AND ( c_prf_carrier_rec.ca_act_technology
         IS
         NULL
         OR c_prf_carrier_rec.ca_act_technology = 'No' ) )
         THEN
            carrier_prf_cnt := carrier_prf_cnt + 1;
            carrier_prf_array (carrier_prf_cnt) := c_prf_carrier_rec.objid;
            DBMS_OUTPUT.put_line ( 'c_prf_carrier_rec.x_carrier_id :' ||
            TO_CHAR ( c_prf_carrier_rec.x_carrier_id) );
         END IF;
      END LOOP;
      --------------------------------------
      -- Check if any carriers were found --
      --------------------------------------
      IF (carrier_dflt_cnt = 0)
      AND (carrier_prf_cnt = 0)
      THEN
      FOR c_dflt_carrier_rec IN c_dflt_carrier (c_dealer_rec.site_id,
                                                c_dealer_rec.x_meid_phone,
                                                null,
                                                c_dealer_rec.x_dll) LOOP
        if nvl(c_dflt_carrier_rec.sim_profile,'NA') != 'NA' then
          global_repl_sim := c_dflt_carrier_rec.sim_profile;
          exit;
        end if;
      end loop;
         -- BRAND_SEP
         -- Amigo
         --IF global_amigo_yn = 0
         --THEN
         ----------------
         -- CR5192 START:
         ----------------
         IF global_no_service = 1
         THEN
            p_msg := 'No available service.';
         ELSE
            p_msg := 'No carrier found for technology.';
         END IF;
         -------------
         -- CR5192 END
         -------------
         --ELSIF global_amigo_yn = 1
         --THEN
         --   p_msg := 'NO AMIGO';
         --END IF;
         -- End Amigo
         global_carr_found_flag := 0;
      else
         IF l_language = 'English'
         THEN
            p_msg :=
            'AGENT:  There are no lines available for this zip code.  Please advise the customer to call back in 24-48 hours.'
            ;
         ELSE
            p_msg :=
            'Las lmneas no estan disponibles temporalmente para el area que usted desea. Por favor llamenos en 24 a 48 horas. '
            || 'Pedimos una disculpa por las molestias ocasionadas';
         END IF;
         global_carr_found_flag := 1;
      END IF;
      -------
      -- * --
      -------
      FOR i IN 1 .. carrier_dflt_cnt
      LOOP
         -- DEBUG:
         DBMS_OUTPUT.put_line ( 'pre carrier_dflt_array(' || TO_CHAR (i) ||
         '):' || TO_CHAR (carrier_dflt_array (i)) );
      END LOOP;
      ------------------------------
      -- NO CINGULAR REACTIVATION --
      -- Technology is ANALOG     --
      ------------------------------
      OPEN c_react_cingular;
      FETCH c_react_cingular
      INTO c_react_cingular_rec;
      l_c_react_cingular_found := c_react_cingular%FOUND;
      IF l_c_react_cingular_found
      THEN
         DBMS_OUTPUT.put_line ( 'found cingular fcc: ' || c_react_cingular_rec.market_id
         );
      END IF;
      CLOSE c_react_cingular;
      IF ( NOT l_c_react_found)
      AND c_dealer_rec.x_technology = 'ANALOG'
      THEN
---------------------------------------------
         -- Filter out the list of DEFAULT carriers --
         -- Leave in the list only those carriers   --
         -- that satisfy the conditions below:      --
         ---------------------------------------------
         IF carrier_dflt_cnt > 0
         THEN
            IF c_dealer_rec.part_good_flag = 6
            THEN
               l_carrier_group_id2check1 := 7;
               l_carrier_group_id2check2 := l_carrier_group_id2check1;
            ELSIF c_dealer_rec.part_good_flag = 7
            THEN
               l_carrier_group_id2check1 := 6;
               l_carrier_group_id2check2 := l_carrier_group_id2check1;
            ELSE
               l_carrier_group_id2check1 := 6;
               l_carrier_group_id2check2 := 7;
            END IF;
            carrier_tmp_cnt := 0;
            FOR i IN 1 .. carrier_dflt_cnt
            LOOP
               OPEN c_carrier_group (carrier_dflt_array (i));
               FETCH c_carrier_group
               INTO c_carrier_group_rec;
               IF c_carrier_group_rec.x_carrier_group_id NOT IN (
               l_carrier_group_id2check1, l_carrier_group_id2check2)
               OR l_c_react_cingular_found
               THEN
                  carrier_tmp_cnt := carrier_tmp_cnt + 1;
                  carrier_tmp_array (carrier_tmp_cnt) := carrier_dflt_array (i)
                  ;
               END IF;
               DBMS_OUTPUT.put_line ( 'part_good_qty                  :' ||
               c_dealer_rec.part_good_flag );
               DBMS_OUTPUT.put_line (
               '**c_carrier_group_rec.x_carrier_group_id:' || TO_CHAR (
               c_carrier_group_rec.x_carrier_group_id) );
               CLOSE c_carrier_group;
            END LOOP;
            carrier_dflt_cnt := carrier_tmp_cnt;
            ------------------------------------
            -- Recreate DEFAULT carriers list --
            ------------------------------------
            FOR i IN 1 .. carrier_tmp_cnt
            LOOP
               carrier_dflt_array (i) := carrier_tmp_array (i);
            END LOOP;
         END IF;
      END IF;
      -------------------------------------
      -- End of NO CINGULAR REACTIVATION --
      -- Technology is ANALOG            --
      -------------------------------------
      -------
      -- * --
      -------
      FOR i IN 1 .. carrier_prf_cnt
      LOOP
         -- DEBUG:
         DBMS_OUTPUT.put_line ( 'pre carrier_prf_array(' || TO_CHAR (i) || '):'
         || TO_CHAR (carrier_prf_array (i)) );
      END LOOP;
      --------------------------
      -- NO REACTIVATION      --
      -- Technology is ANALOG --
      --------------------------
      IF ( NOT l_c_react_found)
      AND c_dealer_rec.x_technology = 'ANALOG'
      THEN
-----------------------------------------------
         -- Filter out the list of PREFERRED carriers --
         -- Leave in the list only those carriers     --
         -- that satisfy the conditions below:        --
         -----------------------------------------------
         IF carrier_prf_cnt > 0
         THEN
            IF c_dealer_rec.part_good_flag = 6
            THEN
               l_carrier_group_id2check1 := 7;
               l_carrier_group_id2check2 := l_carrier_group_id2check1;
            ELSIF c_dealer_rec.part_good_flag = 7
            THEN
               l_carrier_group_id2check1 := 6;
               l_carrier_group_id2check2 := l_carrier_group_id2check1;
            ELSE
               l_carrier_group_id2check1 := 6;
               l_carrier_group_id2check2 := 7;
            END IF;
            carrier_tmp_cnt := 0;
            FOR i IN 1 .. carrier_prf_cnt
            LOOP
               OPEN c_carrier_group (carrier_prf_array (i));
               FETCH c_carrier_group
               INTO c_carrier_group_rec;
               IF c_carrier_group_rec.x_carrier_group_id NOT IN (
               l_carrier_group_id2check1, l_carrier_group_id2check2)
               OR l_c_react_cingular_found
               THEN
                  carrier_tmp_cnt := carrier_tmp_cnt + 1;
                  carrier_tmp_array (carrier_tmp_cnt) := carrier_prf_array (i);
               END IF;
               DBMS_OUTPUT.put_line ( 'part_good_qty                  :' ||
               c_dealer_rec.part_good_flag );
               DBMS_OUTPUT.put_line (
               '**c_carrier_group_rec.x_carrier_group_id:' || TO_CHAR (
               c_carrier_group_rec.x_carrier_group_id) );
               CLOSE c_carrier_group;
            END LOOP;
            carrier_prf_cnt := carrier_tmp_cnt;
            --------------------------------------
            -- Recreate PREFERRED carriers list --
            --------------------------------------
            FOR i IN 1 .. carrier_tmp_cnt
            LOOP
               carrier_prf_array (i) := carrier_tmp_array (i);
            END LOOP;
         END IF;
      END IF;
      ----------------------------
      -- End of NO REACTIVATION --
      -- Technology is ANALOG   --
      ----------------------------
      -------
      -- * --
      -------
      IF (carrier_dflt_cnt = 0)
      AND (carrier_prf_cnt = 0)
      AND global_carr_found_flag = 1
      THEN
         p_msg := 'NO REACT';
      END IF;
      -------
      -- * --
      -------
      ---------------------------------
      -- New Preferred carrier logic --
      ---------------------------------
      IF carrier_dflt_cnt > 1
      THEN
         l_position_found_rank := 1;
         ---------------------------------------------
         -- Reordering the list of DEFAULT carriers --
         -- Sort routine                            --
         ---------------------------------------------
         FOR i IN 1 .. carrier_dflt_cnt - 1
         LOOP
            l_position_found := FALSE;
            FOR j IN l_position_found_rank .. 15
            LOOP
               FOR k IN i .. carrier_dflt_cnt
               LOOP
                  IF l_position_found = FALSE
                  THEN
                     IF global_technology = 'ANALOG'
                     THEN
                        OPEN c_check_analog_order (carrier_dflt_array (k),
                        TO_CHAR (j) );
                        FETCH c_check_analog_order
                        INTO c_check_analog_order_rec;
                        IF c_check_analog_order%FOUND
                        THEN
                           DBMS_OUTPUT.put_line ( 'analog:found:i:j;k:' || i ||
                           ':' || j || ':' || k );
                           carrier_dflt_array (carrier_dflt_cnt + 1) :=
                           carrier_dflt_array (i);
                           carrier_dflt_array (i) := carrier_dflt_array (k);
                           carrier_dflt_array (k) := carrier_dflt_array (
                           carrier_dflt_cnt + 1);
                           l_position_found := TRUE;
                           l_position_found_rank := j;
                        END IF;
                        CLOSE c_check_analog_order;
                     ELSE
                        OPEN c_check_digital_order (carrier_dflt_array (k),
                        TO_CHAR (j) );
                        FETCH c_check_digital_order
                        INTO c_check_analog_order_rec;
                        IF c_check_digital_order%FOUND
                        THEN
                           DBMS_OUTPUT.put_line ( 'digital:found:i:j;k:' || i
                           || ':' || j || ':' || k );
                           carrier_dflt_array (carrier_dflt_cnt + 1) :=
                           carrier_dflt_array (i);
                           carrier_dflt_array (i) := carrier_dflt_array (k);
                           carrier_dflt_array (k) := carrier_dflt_array (
                           carrier_dflt_cnt + 1);
                           l_position_found := TRUE;
                           l_position_found_rank := j;
                        END IF;
                        CLOSE c_check_digital_order;
                     END IF;
-- global_technology = 'ANALOG'
                  END IF;
-- l_position_found = FALSE
               END LOOP;
-- k loop
            END LOOP;
-- j loop
         END LOOP;
-- i loop
      END IF; -- carrier_dflt_cnt > 1
      ------------------------------------------------
      -- Reset global_carrier_frequency to default: --
      ------------------------------------------------
      global_carrier_frequency := 800;
      -------
      -- * --
      -------
      FOR i IN 1 .. carrier_prf_cnt
      LOOP
         -- DEBUG:
         DBMS_OUTPUT.put_line ( 'post carrier_prf_array(' || TO_CHAR (i) ||
         '):' || TO_CHAR (carrier_prf_array (i)) );
      END LOOP;
      -------
      -- * --
      -------
      FOR i IN 1 .. carrier_dflt_cnt
      LOOP
         -- DEBUG:
         DBMS_OUTPUT.put_line ( 'post carrier_dflt_array(' || TO_CHAR (i) ||
         '):' || TO_CHAR (carrier_dflt_array (i)) );
      END LOOP;
      -------
      -- * --
      -------
      -- DEBUG:
      DBMS_OUTPUT.put_line ('carrier_prf_cnt:' || TO_CHAR (carrier_prf_cnt));
      DBMS_OUTPUT.put_line ('x_technology:' || c_dealer_rec.x_technology);
      DBMS_OUTPUT.put_line ( 'c_dealer_rec.part_good_qty:' || TO_CHAR (
      c_dealer_rec.part_good_flag) );
      -------
      -- * --
      -------
      -- DEBUG:
      DBMS_OUTPUT.put_line ('carrier_dflt_cnt:' || TO_CHAR (carrier_dflt_cnt));
      DBMS_OUTPUT.put_line ('x_technology:' || c_dealer_rec.x_technology);
      DBMS_OUTPUT.put_line ( 'c_dealer_rec.part_good_qty:' || TO_CHAR (
      c_dealer_rec.part_good_flag) );
   END get_carriers_prc;
   ------------------------------------------------
   -- sub procedure get_carriers_prc ends here   --
   -- the largest sub in the code                --
   ------------------------------------------------
   -----------------------------------------------
   -- * sub function get_line_pref_county_fun * --
   -----------------------------------------------
   --cwl change proc 03/21/07
   FUNCTION get_line_pref_county_fun(
      p_choice IN VARCHAR2
   )
   RETURN BOOLEAN
   IS
      CURSOR c1(
         c_carrier_objid IN NUMBER
      )
      IS
      SELECT /*+ INDEX(l ,IND_PART_INST_NPANXX_N4) */  --POST_10G
         l.part_serial_no,
         l.x_part_inst_status,
         l.last_trans_time,
         l.x_insert_date
      FROM table_part_inst l, (
         SELECT DISTINCT lt.npa,
            lt.nxx
         FROM npanxx2carrierzones lt, carrierzones z
         WHERE lt.ZONE = z.ZONE
         AND lt.state = z.st
         AND z.zip = global_zip) tab1
      WHERE DECODE (l.x_part_inst_status, '12', NVL (x_cool_end_date, SYSDATE),
      '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status,
      '12', SYSDATE, '11', SYSDATE )
      AND l.x_domain = 'LINES'
      AND l.x_npa = tab1.npa
      AND l.x_nxx = tab1.nxx
      AND l.x_part_inst_status = '12'
      AND l.part_inst2carrier_mkt = c_carrier_objid UNION ALL
      SELECT /*+ INDEX(l ,IND_PART_INST_NPANXX_N4) */  --POST_10G
         l.part_serial_no,
         l.x_part_inst_status,
         l.last_trans_time,
         l.x_insert_date
      FROM table_part_inst l, (
         SELECT DISTINCT lt.npa,
            lt.nxx
         FROM npanxx2carrierzones lt, carrierzones z
         WHERE lt.ZONE = z.ZONE
         AND lt.state = z.st
         AND z.zip = global_zip) tab1
      WHERE DECODE (l.x_part_inst_status, '12', NVL (x_cool_end_date, SYSDATE),
      '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status,
      '12', SYSDATE, '11', SYSDATE )
      AND l.x_domain = 'LINES'
      AND l.x_npa = tab1.npa
     AND l.x_nxx = tab1.nxx
      AND l.x_part_inst_status = '11'
      AND l.part_inst2carrier_mkt = c_carrier_objid;
--------------------------------------------------------
   -- sub function get_line_pref_county_fun starts here  --
   -- finds the line number in the preferred county      --
   -- (if available)                                     --
   --------------------------------------------------------
   BEGIN
      IF p_choice = 'B1'
      THEN
         FOR i IN 1 .. carrier_prf_cnt
         LOOP
            IF global_technology = 'CDMA'
            AND is_next_avail_market_on_fun(carrier_prf_array (i))
            THEN
               p_msg := 'No inventory carrier.';
               get_carrier_info (carrier_prf_array (i), NULL, p_pref_parent);
              p_pref_carrier_objid := carrier_prf_array(i);
               global_resource_busy := 'N';
               global_part_serial_no := NULL;
               RETURN TRUE;
            END IF;
            FOR c1_rec IN c1 (carrier_prf_array (i))
            LOOP
               update_line_prc (c1_rec.part_serial_no);
               IF global_resource_busy = 'N'
               THEN
                  global_part_serial_no := c1_rec.part_serial_no;
                  IF carrier_prf_array. EXISTS (i)
                 AND carrier_prf_cnt <> 0
                  THEN
                     get_carrier_info (carrier_prf_array (i), NULL,
                     p_pref_parent) ;
                     p_pref_carrier_objid := carrier_prf_array(i);
                  END IF;
                  update_c_choice_prc (global_part_serial_no, 'B');
                  IF l_language = 'English'
                  THEN
                     p_msg :=
                     'B1 Choice: Preferred local, non-roaming, and non-long distance from Tracfone MIN.'
                     ;
                  ELSE
                     p_msg :=
                     'Seleccion B1: Preferible para Local, sin Roaming, y sin larga distancia de TracFone MIN'
                     ;
                  END IF;
                  RETURN TRUE;
               END IF;
            END LOOP;
         END LOOP;
      ELSE
         FOR i IN 1 .. carrier_dflt_cnt
         LOOP
            IF global_technology = 'CDMA'
            AND is_next_avail_market_on_fun(carrier_dflt_array (i))
            THEN
               p_msg := 'No inventory carrier.';
               get_carrier_info (carrier_dflt_array (i), NULL, p_pref_parent);
               p_pref_carrier_objid := carrier_dflt_array(i);
               global_resource_busy := 'N';
               global_part_serial_no := NULL;
               RETURN TRUE;
            END IF;
            FOR c1_rec IN c1 (carrier_dflt_array (i))
            LOOP
               update_line_prc (c1_rec.part_serial_no);
               IF global_resource_busy = 'N'
               THEN
                  global_part_serial_no := c1_rec.part_serial_no;
                  IF carrier_dflt_array. EXISTS (i)
                  AND carrier_dflt_cnt <> 0
                 THEN
                     get_carrier_info (carrier_dflt_array (i), NULL,
                     p_pref_parent );
                     p_pref_carrier_objid := carrier_dflt_array(i);
                  END IF;
                  update_c_choice_prc (global_part_serial_no, 'B');
                  IF l_language = 'English'
                  THEN
                     p_msg :=
                     'B2 Choice: Local, non-roaming, and non-long distance from Tracfone MIN.'
                     ;
                  ELSE
                     p_msg :=
                     'Seleccion B2: Local, sin Roaming, y sin larga distancia de TracFone MIN'
                     ;
                  END IF;
                  RETURN TRUE;
               END IF;
            END LOOP;
         END LOOP;
      END IF;
      RETURN FALSE;
   END get_line_pref_county_fun;
   --------------------------------------------------------
   -- sub function get_line_pref_county_fun ends here   --
   --------------------------------------------------------
   -------------------------------------------------------
   -- * sub function get_line_pref_sid_fun *            --
   --   this function is called for the phones with     --
   --   NO GSM technology                               --
   -------------------------------------------------------
   --cwl change 03/21/07
   FUNCTION get_line_pref_sid_fun
   RETURN BOOLEAN
   IS
      CURSOR c0(
         c_carrier_objid IN NUMBER
      )
      IS
      SELECT l.part_serial_no
      FROM table_part_inst l, (
         SELECT DISTINCT z.nxx,
            z.npa
         FROM npanxx2carrierzones z, carrierzones a
         WHERE a.county = z.county
         AND a.marketid = z.marketid
         AND a.st = z.state
         AND a.zip = global_zip) tab1
      WHERE DECODE (l.x_part_inst_status, '12', NVL (x_cool_end_date, SYSDATE),
      '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status,
      '12', SYSDATE, '11', SYSDATE )
      AND l.x_domain = 'LINES'
      AND l.part_inst2carrier_mkt = c_carrier_objid
      AND l.x_part_inst_status = '12'
      AND l.x_nxx = tab1.nxx
      AND l.x_npa = tab1.npa UNION ALL
      SELECT l.part_serial_no
      FROM table_part_inst l, (
         SELECT DISTINCT z.nxx,
            z.npa
         FROM npanxx2carrierzones z, carrierzones a
         WHERE a.county = z.county
         AND a.marketid = z.marketid
         AND a.st = z.state
         AND a.zip = global_zip) tab1
      WHERE DECODE (l.x_part_inst_status, '12', NVL (x_cool_end_date, SYSDATE),
      '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status,
      '12', SYSDATE, '11', SYSDATE )
      AND l.x_domain = 'LINES'
      AND l.part_inst2carrier_mkt = c_carrier_objid
      AND l.x_part_inst_status = '11'
      AND l.x_nxx = tab1.nxx
      AND l.x_npa = tab1.npa;
      CURSOR c2(
         c_carrier_objid IN NUMBER
      )
      IS
      SELECT part_serial_no
      FROM (
         SELECT l.part_serial_no,
            DECODE (l.x_part_inst_status, '12', 1, '11', 2),
            DECODE (l.x_part_inst_status, '12', l.last_trans_time, '11', l.x_insert_date
            )
         FROM table_part_inst l
         WHERE DECODE (l.x_part_inst_status, '12', NVL (x_cool_end_date,
         SYSDATE), '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status
         , '12', SYSDATE, '11', SYSDATE )
         AND l.x_domain || '' = 'LINES'
         AND l.part_inst2carrier_mkt = c_carrier_objid
         AND l.x_part_inst_status || '' = '12'
         AND ROWNUM < 101 UNION ALL
         SELECT l.part_serial_no,
            DECODE (l.x_part_inst_status, '12', 1, '11', 2),
            DECODE (l.x_part_inst_status, '12', l.last_trans_time, '11', l.x_insert_date
            )
         FROM table_part_inst l
         WHERE DECODE (l.x_part_inst_status, '12', NVL (x_cool_end_date,
         SYSDATE), '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status
         , '12', SYSDATE, '11', SYSDATE )
         AND l.x_domain || '' = 'LINES'
         AND l.part_inst2carrier_mkt = c_carrier_objid
         AND l.x_part_inst_status || '' = '11'
         AND ROWNUM < 101
         ORDER BY 2, 3);
------------------------------------------------------
   -- sub function get_line_pref_sid_fun starts here   --
  ------------------------------------------------------
   BEGIN
---------------------------------------------------------------------
      -- No C or D choices should be made for 1900 MHz or greater phones --
      ---------------------------------------------------------------------
      IF global_phone_frequency < 1900
      THEN
         global_d_choice_found := FALSE;
         global_d2_choice_found := FALSE;
         FOR i IN 1 .. carrier_prf_cnt
         LOOP
            IF global_technology = 'CDMA'
            AND is_next_avail_market_on_fun(carrier_prf_array (i))
            THEN
               p_msg := 'No inventory carrier.';
               global_resource_busy := 'N';
               global_part_serial_no := NULL;
               get_carrier_info (carrier_prf_array (i), NULL, p_pref_parent);
               p_pref_carrier_objid := carrier_prf_array(i);
               RETURN TRUE;
            END IF;
            FOR c0_rec IN c0 (carrier_prf_array (i))
            LOOP
               update_line_prc (c0_rec.part_serial_no);
               IF global_resource_busy = 'N'
               THEN
                  global_part_serial_no := c0_rec.part_serial_no;
                  --1.5 10/31/07
                  IF carrier_prf_array. EXISTS (i)
                  AND carrier_prf_cnt <> 0
                  THEN
                     get_carrier_info (carrier_prf_array (i), NULL,
                     p_pref_parent) ;
                     p_pref_carrier_objid := carrier_prf_array(i);
                  END IF;
                  update_c_choice_prc (global_part_serial_no, 'PC1');
                  IF l_language = 'English'
                  THEN
                     p_msg :=
                     'C Choice: Alternate MIN issued outside of customer zipcode.'
                     ||
                     ' We were unable to assign the best number in this area.'
                     || ' The MIN is non-roaming, but may be long-distance.'||
                     ' Ask customer to call back in 24-48 hrs';
                  ELSE
                     p_msg :=
                     'Seleccion C: MIN Alternativo para fuera del area del cliente.'
                     ||
                     ' No nos fue posible asignar el mejor nzmero en esta area.'
                     ||
                     ' El MIN es no-Roaming pero puede ser de larga distancia.'
                     || ' Pmdale al cliente llamar en 24 a 48 horas.';
                  END IF;
                  RETURN TRUE;
               END IF;
           END LOOP;
         END LOOP;
         FOR i IN 1 .. carrier_dflt_cnt
         LOOP
            IF global_technology = 'CDMA'
            AND is_next_avail_market_on_fun(carrier_dflt_array (i))
            THEN
               p_msg := 'No inventory carrier.';
               global_resource_busy := 'N';
               global_part_serial_no := NULL;
               get_carrier_info (carrier_dflt_array (i), NULL, p_pref_parent);
               p_pref_carrier_objid := carrier_dflt_array(i);
               RETURN TRUE;
            END IF;
            FOR c0_rec IN c0 (carrier_dflt_array (i))
            LOOP
               update_line_prc (c0_rec.part_serial_no);
               IF global_resource_busy = 'N'
               THEN
                  global_part_serial_no := c0_rec.part_serial_no;
                  --1.5 10/31/07
                  IF carrier_dflt_array. EXISTS (i)
                  AND carrier_dflt_cnt <> 0
                  THEN
                     get_carrier_info (carrier_dflt_array (i), NULL,
                     p_pref_parent );
                     p_pref_carrier_objid := carrier_dflt_array(i);
                  END IF;
                  update_c_choice_prc (global_part_serial_no, 'PC2');
                  IF l_language = 'English'
                  THEN
                     p_msg :=
                     'C Choice: Alternate MIN issued outside of customer zipcode.'
                     ||
                     ' We were unable to assign the best number in this area.'
                     || ' The MIN is non-roaming, but may be long-distance.'||
                     ' Ask customer to call back in 24-48 hrs';
                  ELSE
                     p_msg :=
                     'Seleccion C: MIN Alternativo para fuera del area del cliente.'
                     ||
                     ' No nos fue posible asignar el mejor nzmero en esta area.'
                     ||
                     ' El MIN es no-Roaming pero puede ser de larga distancia.'
                     || ' Pmdale al cliente llamar en 24 a 48 horas.';
                  END IF;
                  RETURN TRUE;
               END IF;
            END LOOP;
         END LOOP;
         FOR i IN 1 .. carrier_prf_cnt
         LOOP
            IF global_technology = 'CDMA'
            AND is_next_avail_market_on_fun(carrier_prf_array (i))
            THEN
               p_msg := 'No inventory carrier.';
               global_resource_busy := 'N';
               global_part_serial_no := NULL;
               get_carrier_info (carrier_prf_array (i), NULL, p_pref_parent);
               p_pref_carrier_objid := carrier_prf_array(i);
               RETURN TRUE;
            END IF;
            FOR c2_rec IN c2 (carrier_prf_array (i))
            LOOP
               global_part_serial_no := c2_rec.part_serial_no;
               global_d_choice_found := true;
               IF l_language = 'English'
               THEN
                  p_msg :=
                  'AGENT:  There are no lines available for this zip code.'||
                  ' Please advise the customer to call back in 24-48 hours.';
               ELSE
                  p_msg := 'Seleccion D: '||
                  ' Las lmneas no estan disponibles temporalmente para el area que usted desea.'
                  || ' Por favor llamenos en 24 a 48 horas. '||
                  ' Pedimos una disculpa por las molestias ocasionadas';
               END IF;
               --1.5 10/31/07
               IF carrier_prf_array. EXISTS (i)
               AND carrier_prf_cnt <> 0
               THEN
                  get_carrier_info (carrier_prf_array (i), NULL, p_pref_parent)
                  ;
                  p_pref_carrier_objid := carrier_prf_array(i);
               END IF;
               RETURN FALSE;
            END LOOP;
         END LOOP;
         FOR i IN 1 .. carrier_dflt_cnt
         LOOP
            IF global_technology = 'CDMA'
            AND is_next_avail_market_on_fun(carrier_dflt_array (i))
            THEN
               p_msg := 'No inventory carrier.';
               global_resource_busy := 'N';
               global_part_serial_no := NULL;
               get_carrier_info (carrier_dflt_array (i), NULL, p_pref_parent);
               p_pref_carrier_objid := carrier_dflt_array(i);
               RETURN TRUE;
            END IF;
            FOR c2_rec IN c2 (carrier_dflt_array (i))
            LOOP
               global_part_serial_no := c2_rec.part_serial_no;
               global_d2_choice_found := true;
               IF l_language = 'English'
               THEN
                  p_msg :=
                  'AGENT:  There are no lines available for this zip code.'||
                  ' Please advise the customer to call back in 24-48 hours.';
               ELSE
                  p_msg := 'Seleccion D:'||
                  ' Las lmneas no estan disponibles temporalmente para el area que usted desea.'
                  || ' Por favor llamenos en 24 a 48 horas.'||
                  ' Pedimos una disculpa por las molestias ocasionadas';
               END IF;
               RETURN FALSE;
            END LOOP;
         END LOOP;
      END IF;
      RETURN FALSE;
   END get_line_pref_sid_fun;
   ----------------------------------------------------
   -- sub function get_line_pref_sid_fun ends here   --
   ----------------------------------------------------
   ------------------------------------------
   -- * sub procedure gsm_get_dealer_prc * --
   ------------------------------------------
   -- BRAND_SEP
   PROCEDURE gsm_get_dealer_prc
   IS
      /* Cursor to get the dealer associated with the esn */
      CURSOR c_dealer
      IS
      SELECT s.site_id,
         pn.x_technology,
         NVL (pi.part_good_qty, 0) part_good_flag,
         bo.org_id
      FROM table_part_num pn, table_mod_level ml, table_site s, table_inv_role
      ir, table_inv_bin ib, table_part_inst pi, table_bus_org bo
      WHERE pn.objid = ml.part_info2part_num
      AND ml.objid = pi.n_part_inst2part_mod
      AND s.objid = ir.inv_role2site
      AND ir.inv_role2inv_locatn = ib.inv_bin2inv_locatn
      AND ib.objid = pi.part_inst2inv_bin
      AND pi.x_domain = 'PHONES'
      AND pi.part_serial_no = global_esn
      AND pn.PART_NUM2BUS_ORG = bo.objid;
      c_dealer_rec c_dealer%ROWTYPE;
----------------------------------------------------
   -- sub procedure gsm_get_dealer_prc starts here   --
   ----------------------------------------------------
   BEGIN
      OPEN c_dealer;
      FETCH c_dealer
      INTO c_dealer_rec;
      global_dealer_id := c_dealer_rec.site_id;
      global_technology := c_dealer_rec.x_technology;
      global_brand_name := c_dealer_rec.org_id;
      global_part_good_flag := c_dealer_rec.part_good_flag; -- new
      CLOSE c_dealer;
      DBMS_OUTPUT.put_line ('dealer_id :' || c_dealer_rec.site_id);
   END gsm_get_dealer_prc;
   -----------------------------------------------
   -- * procedure gsm_get_phone_frequency_prc * --
   -----------------------------------------------
   PROCEDURE gsm_get_phone_frequency_prc
   IS
      CURSOR c_phone_frequency
      IS
      SELECT MAX (DECODE (f.x_frequency, 800, 800, 0)) phone_frequency,
         MAX (DECODE (f.x_frequency, 1900, 1900, 0)) phone_frequency2
      FROM table_x_frequency f, mtm_part_num14_x_frequency0 pf, table_part_num
      pn, table_mod_level ml, table_part_inst pi
      WHERE pf.x_frequency2part_num = f.objid
      AND pn.objid = pf.part_num2x_frequency
      AND pn.objid = ml.part_info2part_num
      AND ml.objid = pi.n_part_inst2part_mod
      AND pi.part_serial_no = global_esn
      AND pi.x_domain = 'PHONES';
-------------------------------------------------------------
   -- sub procedure gsm_get_phone_frequency_prc starts here   --
   -------------------------------------------------------------
   BEGIN
      /** get phone frequency info and set to global variable **/
      global_phone_frequency := 0;
      global_phone_frequency2 := 0;
      OPEN c_phone_frequency;
      FETCH c_phone_frequency
      INTO global_phone_frequency, global_phone_frequency2;
      CLOSE c_phone_frequency;
   END gsm_get_phone_frequency_prc;
   -----------------------------------------
   -- * sub function gsm_is_a_react_fun * --
   -----------------------------------------
   FUNCTION gsm_is_a_react_fun
   RETURN BOOLEAN
   IS
      CURSOR c_is_new
      IS
      SELECT 'X' col1
      FROM table_part_inst
      WHERE part_serial_no = global_esn
      AND x_domain = 'PHONES'
      AND x_part_inst_status || '' IN ('50', '150');
      c_is_new_rec c_is_new%ROWTYPE;
      l_return_value BOOLEAN := FALSE;
---------------------------------------------------
   -- sub function gsm_is_a_react_fun starts here   --
   ---------------------------------------------------
   BEGIN
      /* of gsm_is_a_react_fun */
      OPEN c_is_new;
      FETCH c_is_new
      INTO c_is_new_rec;
      IF c_is_new%FOUND
      THEN
         l_return_value := FALSE;
      /* is a new phone **/
      ELSE
         l_return_value := TRUE;
      /* is a react **/
      END IF;
      CLOSE c_is_new;
      -------
      -- * --
      -------
      RETURN l_return_value;
   END gsm_is_a_react_fun;
   ---------------------------------------------------
   -- * sub procedure gsm_get_default_carrier_prc * --
   ---------------------------------------------------
   PROCEDURE gsm_get_default_carrier_prc(technology_ip IN VARCHAR2) IS
      CURSOR c_dflt_carrier IS
      SELECT ca.objid,
             ca.x_carrier_id,
             ca.x_react_analog,
             ca.x_react_technology ca_react_technology,
             ca.x_act_analog,
             ca.x_act_technology ca_act_technology,
             pt.x_technology pref_technology,
             f.x_frequency,
             pt.x_technology,
             tab2.phone_gen old_phone_gen
        FROM table_x_frequency f,
             mtm_x_frequency2_x_pref_tech1 f2pt,
             table_x_pref_tech pt,
             table_x_carrier ca,
             table_x_carrierdealer c,
             --table_x_carrier_features cf,
             table_x_carrier_group cg,
             table_x_parent p,
             (SELECT DISTINCT b.carrier_id
                FROM npanxx2carrierzones b,
                     carrierzones a
               WHERE b.frequency1 IN ('1900', '800')
                 AND (   b.cdma_tech = technology_ip
                      OR b.gsm_tech = technology_ip )
                 AND b.ZONE = a.ZONE
                 AND b.state = a.st
                 AND a.zip = global_zip) tab1,
             (select pn.part_num2bus_org,
                     pn.x_technology,
                     pn.PART_NUM2PART_CLASS,
                     NVL(pn.x_meid_phone, 0) meid_phone,
                     pi.x_part_inst_status,
                     nvl((select 1
                            from table_x_part_class_values v,
                                 table_x_part_class_params n
                           where 1=1
                             and v.value2part_class     = pn.part_num2part_class
                             and v.value2class_param    = n.objid
                             and n.x_param_name         = 'UNLIMITED_PLAN'
                             AND v.x_param_value        = 'NTU'
                             and rownum <2),0) ntu,
                     nvl((select v.x_param_value
                            from table_x_part_class_values v,
                                 table_x_part_class_params n
                           where 1=1
                             and v.value2part_class     = pn.part_num2part_class
                             and v.value2class_param    = n.objid
                             and n.x_param_name         = 'PHONE_GEN'
                             and rownum <2),'2G') phone_gen,
                     nvl((select v.x_param_value
                            from table_x_part_class_values v,
                                 table_x_part_class_params n
                           where 1=1
                             and v.value2part_class     = pn.part_num2part_class
                             and v.value2class_param    = n.objid
                             and n.x_param_name         = 'DATA_SPEED'
                             and rownum <2),NVL(pn.x_data_capable, 0)) data_speed,
                     nvl((SELECT COUNT(*) sr
                           FROM table_x_part_class_values v, table_x_part_class_params n
                          WHERE 1 = 1
                            AND v.value2part_class = pn.part_num2part_class
                            AND v.value2class_param = n.objid
                            AND n.x_param_name = 'NON_PPE'
                            AND v.x_param_value in ( '1','0') -- CR15018 --12/02/10 invalid number fix
                            AND ROWNUM < 2),0) non_ppe,
                      bo.org_id
               from table_bus_org bo ,
                     table_part_num pn,
                     sa.table_mod_level ml,
                     table_part_inst pi
               where 1=1
                 and bo.objid          = pn.part_num2bus_org
                 and pn.objid          = ml.part_info2part_num
                 and ml.objid          = pi.n_part_inst2part_mod
                 AND pi.part_serial_no = p_esn) tab2
       WHERE 1 = 1
         AND NOT EXISTS (SELECT 1
                           FROM table_x_not_certify_models cm
                          WHERE 1 = 1
                            AND cm.X_PART_CLASS_OBJID = tab2.PART_NUM2PART_CLASS
                            AND cm.X_PARENT_ID = p.x_parent_id)
         AND f.objid = f2pt.x_frequency2x_pref_tech
         AND f.x_frequency + 0 IN (global_phone_frequency, global_phone_frequency2)
         AND f2pt.x_pref_tech2x_frequency = pt.objid
         AND pt.x_pref_tech2x_carrier = ca.objid
         AND pt.x_technology || '' = technology_ip --CR5757
         AND ca.x_carrier_id = c.x_carrier_id
         AND ca.x_status || '' = 'ACTIVE' --CR5757
         AND c.x_carrier_id = tab1.carrier_id
                --CR38885
         AND c.x_dealer_id ||'' = case when global_safelink = 'FOUND' then
                                         '24920'
                                       else
                                         decode(c.x_dealer_id,'24920','XXXXXXX',c.x_dealer_id)
                                       end
                --CR38885
                                          --case when global_safelink = 1 then ----CR13234
                                  --       c.x_dealer_id
                                  --     else
                                  --       DECODE(global_dealer_id, '24920', '24920', 'DEFAULT')
                                  --     end
         AND cg.objid = ca.CARRIER2CARRIER_GROUP
         and p.objid = cg.X_CARRIER_GROUP2X_PARENT
         AND decode( p.x_meid_carrier,1,tab2.meid_phone,null,0,p.x_meid_carrier) = tab2.meid_phone
         AND DECODE(p.x_parent_id, '74', 1, 0) = tab2.ntu
--CR23419
         and exists(select 1
                      from table_x_carrier_features cf
                     where 1=1
         and cf.X_FEATURES2BUS_ORG = tab2.part_num2bus_org
         and cf.x_technology = tab2.x_technology
         and cf.x_data=tab2.data_speed
         and decode(cf.X_SWITCH_BASE_RATE,null,tab2.non_ppe,1) = tab2.non_ppe
         and (  cf.x_feature2x_carrier = ca.objid
              or (      tab2.org_id = 'NET10'
                   and  exists(SELECT 1
                               FROM table_x_carrier_group cg2,
                                    table_x_carrier c2
                              WHERE cg2.x_carrier_group2x_parent = p.objid
                                AND c2.carrier2carrier_group = cg2.objid
                                and c2.objid = cf.x_feature2x_carrier))))
/*
         AND (  cf.x_feature2x_carrier = ca.objid
              or (    tab2.org_id = 'NET10'
                  and cf.x_feature2x_carrier in( SELECT c2.objid
                                                   FROM table_x_carrier_group cg2,
                                                        table_x_carrier c2
                                                      WHERE cg2.x_carrier_group2x_parent = p.objid
                                                        AND c2.carrier2carrier_group = cg2.objid))
              )
         and cf.X_FEATURES2BUS_ORG = tab2.part_num2bus_org
         and cf.x_technology = tab2.x_technology
         and cf.x_data=tab2.data_speed
         and decode(cf.X_SWITCH_BASE_RATE,null,tab2.non_ppe,1) = tab2.non_ppe
*/
         and 1=(case when tab2.phone_gen = '2G' then
                       (select count(*)
                          from table_x_carrier_rules cr
                         where (   (    cr.objid = decode(tab2.x_technology,'CDMA', nvl(ca.CARRIER2RULES_CDMA, ca.CARRIER2RULES),
                                                                       'GSM' , nvl(ca.CARRIER2RULES_GSM, ca.CARRIER2RULES), ca.CARRIER2RULES)
                                     and cr.x_allow_2g_react = '2G'
                                     and tab2.x_part_inst_status not in ('50','150'))
                                 or (    cr.objid = decode(tab2.x_technology,'CDMA', nvl(ca.CARRIER2RULES_CDMA, ca.CARRIER2RULES),
                                                                        'GSM' , nvl(ca.CARRIER2RULES_GSM, ca.CARRIER2RULES), ca.CARRIER2RULES)
                                     and cr.x_allow_2g_act = '2G'
                                     and tab2.x_part_inst_status in ('50','150')))
                           and rownum < 2)
                     else
                       1
                     end)
      ORDER BY f.x_frequency DESC;
--
      cursor react_att_check_curs is
        select /*+ ORDERED */ pa.x_parent_name
          from
                       table_site_part sp,
               table_x_call_trans ct,
               table_x_carrier ca,
               table_x_carrier_group cg,
               table_x_parent pa,
               table_x_carrier_rules cr
         where 1=1
           and sp.x_service_id = p_esn
           and sp.part_status = 'Inactive'
           and ct.call_trans2site_part = sp.objid
           and ca.objid = ct.x_call_trans2carrier
           and cg.objid = ca.carrier2carrier_group
           and pa.objid = cg.x_carrier_group2x_parent
           and (pa.x_parent_name like 'CI%' or pa.x_parent_name like 'AT%')
           and cr.objid = ca.CARRIER2RULES_GSM
           and nvl(cr.x_allow_2g_react,'XX') != '2G'
           and nvl(cr.x_allow_2g_act,'XX') != '2G'
         order by sp.install_date desc;
      react_att_check_rec react_att_check_curs%rowtype;
      cursor esn_junk_curs is
        select pi.part_serial_no,
                       pn.x_dll,
                       pn.x_technology
          from table_part_inst pi
              ,table_mod_level ml
              ,table_part_num pn
         where 1=1
           and pi.part_serial_no = p_esn
                   and pi.x_domain = 'PHONES'
           and pi.x_part_inst_status||'' = '50'
           and ml.objid = n_part_inst2part_mod
           and pn.objid = ml.part_info2part_num
           and nvl((select v.x_param_value
                      from table_x_part_class_values v,
                           table_x_part_class_params n
                     where 1=1
                       and v.value2part_class     = pn.part_num2part_class
                       and v.value2class_param    = n.objid
                       and n.x_param_name         = 'PHONE_GEN'
                       and rownum <2),'2G') = '2G';
      esn_junk_rec esn_junk_curs%rowtype;
      cursor sim_junk_curs is
        select pn2.part_number,
               csp.carrier_name
          from
                table_x_sim_inv si
               ,table_mod_level ml2
               ,table_part_num pn2
               ,carriersimpref csp
         where 1=1
           and si.x_sim_serial_no = p_sim
           and ml2.objid = si.x_sim_inv2part_mod
           and pn2.objid = ml2.part_info2part_num
           and csp.sim_profile = pn2.part_number
           and exists(select 1
                        from carriersimpref csp2
                       where csp2.rowid = csp.rowid
                         and (csp2.carrier_name like 'AT%' or csp2.carrier_name like 'CING%'));
      sim_junk_rec sim_junk_curs%rowtype;
      cursor act_att_check_curs(c_sim_profile in varchar2,
                                c_dll         in number,
                                c_technology  in varchar2) is
        SELECT b.carrier_id,a.sim_profile,pa.x_parent_name
          FROM carrierpref cp,
               npanxx2carrierzones b,
               (SELECT DISTINCT a.ZONE,
                       a.st,
                       s.sim_profile,
                       a.county,
                       s.min_dll_exch,
                       s.max_dll_exch,
                       s.rank
                  FROM carrierzones a,
                       carriersimpref s
                 WHERE a.zip = p_zip
                   and a.CARRIER_NAME=s.CARRIER_NAME
                   and c_dll between s.MIN_DLL_EXCH and s.MAX_DLL_EXCH) a,
               table_x_carrier ca,
               table_x_carrier_group cg,
               table_x_parent pa,
                       table_x_carrier_rules cr
         WHERE 1=1
           AND cp.st = b.state
           and cp.carrier_id = b.carrier_ID
                   and cp.county = a.county
           AND b.gsm_tech  = c_technology
                   and a.sim_profile = c_sim_profile
           AND b.ZONE = a.ZONE
           AND b.state = a.st
           AND ca.x_carrier_id = b.carrier_id
           AND ca.x_status || '' = 'ACTIVE'
           AND cg.objid = ca.CARRIER2CARRIER_GROUP
           and pa.objid = cg.X_CARRIER_GROUP2X_PARENT
           and (pa.x_parent_name like 'CI%' or pa.x_parent_name like 'AT%')
                   and cr.objid = nvl(ca.CARRIER2RULES_GSM, ca.CARRIER2RULES)
                   and cr.x_allow_2g_react = '2G'
           and cr.x_allow_2g_act = '2G';
      act_att_check_rec act_att_check_curs%rowtype;
      cursor act_att_check_curs2(c_sim_profile in varchar2,
                                c_dll         in number,
                                c_technology  in varchar2) is
        SELECT b.carrier_id,a.sim_profile,pa.x_parent_name
          FROM carrierpref cp,
               npanxx2carrierzones b,
               (SELECT DISTINCT a.ZONE,
                       a.st,
                       s.sim_profile,
                       a.county,
                       s.min_dll_exch,
                       s.max_dll_exch,
                       s.rank
                  FROM carrierzones a,
                       carriersimpref s
                 WHERE a.zip = p_zip
                   and a.CARRIER_NAME=s.CARRIER_NAME
                   and c_dll between s.MIN_DLL_EXCH and s.MAX_DLL_EXCH) a,
               table_x_carrier ca,
               table_x_carrier_group cg,
               table_x_parent pa,
                       table_x_carrier_rules cr
         WHERE 1=1
           AND cp.st = b.state
           and cp.carrier_id = b.carrier_ID
                   and cp.county = a.county
           AND b.gsm_tech  = c_technology
                   and a.sim_profile = c_sim_profile
           AND b.ZONE = a.ZONE
           AND b.state = a.st
           AND ca.x_carrier_id = b.carrier_id
           AND ca.x_status || '' = 'ACTIVE'
           AND cg.objid = ca.CARRIER2CARRIER_GROUP
           and pa.objid = cg.X_CARRIER_GROUP2X_PARENT
           and (pa.x_parent_name like 'CI%' or pa.x_parent_name like 'AT%')
                   and cr.objid = nvl(ca.CARRIER2RULES_GSM, ca.CARRIER2RULES);
v_prog_type  table_part_num.prog_type%TYPE;  --CR45813 Vishnu
   -------------------------------------------------------------
   -- sub procedure gsm_get_default_carrier_prc starts here   --
   -------------------------------------------------------------
   BEGIN
      open esn_junk_curs;
        fetch esn_junk_curs into esn_junk_rec;
                      if esn_junk_curs%found then
                        dbms_output.put_line('esn_junk_curs%found');
                        open sim_junk_curs;
                          fetch sim_junk_curs into sim_junk_rec;
                          if sim_junk_curs%found then
                            dbms_output.put_line('sim_junk_curs%found');
              open act_att_check_curs(sim_junk_rec.part_number,esn_junk_rec.x_dll,esn_junk_rec.x_technology);
                              fetch act_att_check_curs into act_att_check_rec;
                                            if act_att_check_curs%notfound then
                                dbms_output.put_line('act_att_check_curs%notfound');
                  open act_att_check_curs2(sim_junk_rec.part_number,esn_junk_rec.x_dll,esn_junk_rec.x_technology);
                                  fetch act_att_check_curs2 into act_att_check_rec;
                    if act_att_check_curs2%found then
                                    dbms_output.put_line('act_att_check_curs2%found');
                      close act_att_check_curs;
                      close act_att_check_curs2;
                                    close sim_junk_curs;
                      close esn_junk_curs;
                                                  goto att_2g_turn_down;
                                                end if;
                  close act_att_check_curs2;
                end if;
              close act_att_check_curs;
            end if;
                        close sim_junk_curs;
        end if;
      close esn_junk_curs;
      FOR carrier_dflt_rec IN c_dflt_carrier LOOP
         DBMS_OUTPUT.put_line ( 'carrier_dflt_rec.old_phone_gen      :' || carrier_dflt_rec.old_phone_gen );
         DBMS_OUTPUT.put_line ( 'carrier_dflt_rec.X_ACT_ANALOG      :' || carrier_dflt_rec.x_act_analog );
         DBMS_OUTPUT.put_line ( 'carrier_dflt_rec.X_REACT_ANALOG    :' || carrier_dflt_rec.x_react_analog );
         DBMS_OUTPUT.put_line ( 'carrier_dflt_rec.X_ACT_TECHNOLOGY  :' || carrier_dflt_rec.pref_technology );
         DBMS_OUTPUT.put_line ( 'carrier_dflt_rec.X_REACT_TECHNOLOGY:' || carrier_dflt_rec.pref_technology );
         DBMS_OUTPUT.put_line ( 'carrier_dflt_rec.x_carrier_id      :' || TO_CHAR (carrier_dflt_rec.x_carrier_id) );
         DBMS_OUTPUT.put_line ( 'carrier_dflt_rec.x_frequency       :' || carrier_dflt_rec.x_frequency );
         DBMS_OUTPUT.put_line ( 'global_phone_frequency         :' || global_phone_frequency );
                       if carrier_dflt_rec.old_phone_gen = '2G' then
						----CR45813 Vishnu START
					    BEGIN
						 SELECT prog_type into v_prog_type
						 FROM TABLE_X_SIM_INV si, TABLE_MOD_LEVEL ml,
							  TABLE_PART_NUM pn
						WHERE si.x_sim_inv2part_mod = ml.objid
						AND ml.part_info2part_num = pn.objid
						and x_sim_serial_no = p_sim;
						EXCEPTION
						WHEN OTHERS THEN
						v_prog_type :=NULL;
						END;
					   IF NVL(v_prog_type,0) <>5 THEN  --CR45813 Vishnu END
					   --
                         open react_att_check_curs;
             fetch react_att_check_curs into react_att_check_rec;
                           if react_att_check_curs%found then
               dbms_output.put_line('dont allow react');
                             close react_att_check_curs;
                             exit;
                           end if;
                         close react_att_check_curs;
						 	END IF;--CR45813 Vishnu END IF
                       end if;
         carrier_dflt_cnt := carrier_dflt_cnt + 1;
         carrier_dflt_array (carrier_dflt_cnt) := carrier_dflt_rec.objid;
         DBMS_OUTPUT.put_line ( 'carrier_dflt_rec.x_carrier_id :' || TO_CHAR ( carrier_dflt_rec.x_carrier_id) );
         IF carrier_dflt_rec.x_frequency = 1900 THEN
           global_carrier_frequency := 1900;
         END IF;
      END LOOP;
      <<att_2g_turn_down>>
      FOR i IN 1 .. carrier_dflt_cnt LOOP
         DBMS_OUTPUT.put_line ( 'pre carrier_dflt_array(' || TO_CHAR (i) || '):' || TO_CHAR (carrier_dflt_array (i)) );
      END LOOP;
   END gsm_get_default_carrier_prc;
   ---------------------------------------------
   -- * sub procedure get_carrier_group_prc * --
   ---------------------------------------------
/*
   PROCEDURE get_carrier_group_prc
   IS
      CURSOR c_carrier_group(
         c_carrier_objid IN NUMBER
      )
      IS
      SELECT TO_NUMBER (p.x_parent_id) x_carrier_group_id
      FROM table_x_parent p, table_x_carrier_group cg, table_x_carrier c
      WHERE p.objid = cg.x_carrier_group2x_parent
      AND UPPER (p.x_status) = 'ACTIVE'
      AND cg.objid = c.carrier2carrier_group
      AND cg.x_status = 'ACTIVE'
      AND c.objid = c_carrier_objid;
      c_carrier_group_rec c_carrier_group%ROWTYPE;
      l_carrier_group_id2check1 NUMBER;
      l_carrier_group_id2check2 NUMBER;
-------------------------------------------------------
   -- sub procedure get_carrier_group_prc starts here   --
   -------------------------------------------------------
   BEGIN
      IF global_part_good_flag = 6
      THEN
         l_carrier_group_id2check1 := 7;
         l_carrier_group_id2check2 := l_carrier_group_id2check1;
      ELSIF global_part_good_flag = 7
      THEN
         l_carrier_group_id2check1 := 6;
         l_carrier_group_id2check2 := l_carrier_group_id2check1;
      ELSE
         l_carrier_group_id2check1 := 6;
         l_carrier_group_id2check2 := 7;
      END IF;
      carrier_tmp_cnt := 0;
      FOR i IN 1 .. carrier_dflt_cnt
      LOOP
         OPEN c_carrier_group (carrier_dflt_array (i));
         FETCH c_carrier_group
         INTO c_carrier_group_rec;
         IF c_carrier_group_rec.x_carrier_group_id NOT IN (
         l_carrier_group_id2check2, l_carrier_group_id2check1)
         THEN
            carrier_tmp_cnt := carrier_tmp_cnt + 1;
            carrier_tmp_array (carrier_tmp_cnt) := carrier_dflt_array (i);
         END IF;
         DBMS_OUTPUT.put_line ( 'part_good_qty                  :' ||
         global_part_good_flag );
         DBMS_OUTPUT.put_line ( '**c_carrier_group_rec.x_carrier_group_id:' ||
         TO_CHAR (c_carrier_group_rec.x_carrier_group_id) );
         CLOSE c_carrier_group;
      END LOOP;
      carrier_dflt_cnt := carrier_tmp_cnt;
      FOR i IN 1 .. carrier_tmp_cnt
      LOOP
         carrier_dflt_array (i) := carrier_tmp_array (i);
      END LOOP;
      -- at this point I need to check if carrier count 2 has changed..
      IF (carrier_dflt_cnt = 0)
      AND global_carr_found_flag = 1
      THEN
         p_msg := 'NO REACT';
      END IF;
   END get_carrier_group_prc;
*/
   -----------------------------------------------------
   -- * sub procedure gsm_get_preferred_carrier_prc * --
   -----------------------------------------------------
   PROCEDURE gsm_get_preferred_carrier_prc
   IS
-------------------------------------------------------------
   -- sub procedure gsm_get_preferred_carrier_prc starts here --
   -------------------------------------------------------------
   ---------------------------------------------------------------------
   -- The procedure reads every carrier in default carrier list/array --
   -- and checks if it is a digital carrier. If yes, it reorders      --
   -- the list and pops the digital carrier to the top of the list,   --
   -- making it a preferred carrier, and pushes the                   --
   ---------------------------------------------------------------------
   BEGIN
      IF carrier_dflt_cnt > 1
      THEN
         new_carrier_dflt_cnt := 0;
         -------------------------------------
         -- Reordering the list of carriers --
         -- Bubble sort routine             --
         -------------------------------------
         FOR i IN 1 .. carrier_dflt_cnt
         LOOP
            FOR j IN 1 .. carrier_dflt_cnt
            LOOP
               DBMS_OUTPUT.put_line ( 'carrier_dflt_array(' || j || '):' ||
               carrier_dflt_array (j) );
               DBMS_OUTPUT.put_line ('i:' || TO_CHAR (i));
               OPEN c_check_digital_order (carrier_dflt_array (j), TO_CHAR (i))
               ;
               FETCH c_check_digital_order
               INTO c_check_digital_order_rec;
               IF c_check_digital_order%FOUND
               THEN
                  DBMS_OUTPUT.put_line ('digital:found');
                  new_carrier_dflt_cnt := new_carrier_dflt_cnt + 1;
                  carrier_dflt_array (carrier_dflt_cnt + 1) :=
                  carrier_dflt_array (new_carrier_dflt_cnt);
                  carrier_dflt_array (new_carrier_dflt_cnt) :=
                  carrier_dflt_array (j);
                  carrier_dflt_array (j) := carrier_dflt_array (
                  carrier_dflt_cnt + 1);
               END IF;
               CLOSE c_check_digital_order;
            END LOOP;
         END LOOP;
      END IF;
      FOR i IN 1 .. carrier_dflt_cnt
      LOOP
         DBMS_OUTPUT.put_line ( 'post carrier_dflt_array(' || TO_CHAR (i) ||
         '):' || TO_CHAR (carrier_dflt_array (i)) );
      END LOOP;
      DBMS_OUTPUT.put_line ('carrier_dflt_cnt:' || TO_CHAR (carrier_dflt_cnt));
      DBMS_OUTPUT.put_line ('x_technology:' || global_technology);
      DBMS_OUTPUT.put_line ( 'c_dealer_rec.part_good_qty:' || TO_CHAR (
      global_part_good_flag) );
   END gsm_get_preferred_carrier_prc;
   ---------------------------------------------------
   -- * sub function gsm_get_line_pref_county_fun * --
   --not used be still he if needed
  ---------------------------------------------------
   FUNCTION gsm_get_line_pref_county_fun
   RETURN BOOLEAN
   IS
      CURSOR c1(
         c_carrier_objid IN NUMBER
      )
      IS
      SELECT part_serial_no
      FROM (
         SELECT l.part_serial_no,
            DECODE (l.x_part_inst_status, '11', 1, '12', 2),
            DECODE (l.x_part_inst_status, '11', l.x_insert_date, '12', l.last_trans_time
            )
         FROM table_part_inst l, (
            SELECT DISTINCT lt.npa,
               lt.nxx
            FROM npanxx2carrierzones lt, carrierzones z
            WHERE lt.ZONE = z.ZONE
            AND lt.state = z.st
            AND lt.gsm_tech = global_technology
            AND z.zip = global_zip) tab1
         WHERE DECODE (l.x_part_inst_status, '12', NVL (x_cool_end_date,
         SYSDATE), '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status
         , '12', SYSDATE, '11', SYSDATE )
         AND l.x_domain = 'LINES'
         AND l.x_npa = tab1.npa
         AND l.x_nxx = tab1.nxx
         AND l.x_part_inst_status = '12'
         AND l.part_inst2carrier_mkt = c_carrier_objid
         AND ROWNUM < 101 UNION ALL
         SELECT l.part_serial_no,
            DECODE (l.x_part_inst_status, '11', 1, '12', 2),
            DECODE (l.x_part_inst_status, '11', l.x_insert_date, '12', l.last_trans_time
            )
         FROM table_part_inst l, (
            SELECT DISTINCT lt.npa,
               lt.nxx
            FROM npanxx2carrierzones lt, carrierzones z
            WHERE lt.ZONE = z.ZONE
            AND lt.state = z.st
            AND lt.gsm_tech = global_technology
            AND z.zip = global_zip) tab1
         WHERE DECODE (l.x_part_inst_status, '12', NVL (x_cool_end_date,
         SYSDATE), '11', NVL (x_cool_end_date, SYSDATE) ) <= DECODE (l.x_part_inst_status
         , '12', SYSDATE, '11', SYSDATE )
         AND l.x_domain = 'LINES'
         AND l.x_npa = tab1.npa
         AND l.x_nxx = tab1.nxx
         AND l.x_part_inst_status = '11'
         AND l.part_inst2carrier_mkt = c_carrier_objid
         AND ROWNUM < 101
         ORDER BY 2, 3);
   BEGIN
      FOR i IN 1 .. carrier_dflt_cnt
      LOOP
         FOR c1_rec IN c1 (carrier_dflt_array (i))
         LOOP
            update_line_prc (c1_rec.part_serial_no);
            IF global_resource_busy = 'N'
            THEN
               global_part_serial_no := c1_rec.part_serial_no;
               IF carrier_dflt_array. EXISTS (i)
               AND carrier_dflt_cnt <> 0
               THEN
                  get_carrier_info (carrier_dflt_array (i), NULL, p_pref_parent
                  );
                  p_pref_carrier_objid := carrier_dflt_array(i);
               END IF;
               update_c_choice_prc (global_part_serial_no, 'GSM');
               IF l_language = 'English'
               THEN
                  p_msg :=
                  'GSM Choice: Local, non-roaming, and non-long distance from '
                  ;
                  p_msg := p_msg||global_brand_name||' MIN.';
               ELSE
--Spanish
                  p_msg :=
                  'Seleccion GSM: Local, sin Roaming, y sin larga distancia de '
                  ;
                  p_msg := p_msg||global_brand_name||' MIN.';
               end if;
               /*IF l_language = 'English'
               AND global_restricted_use = 0
               THEN
                  p_msg :=
                  'GSM Choice: Local, non-roaming, and non-long distance from Tracfone MIN.'
                  ;
               ELSIF l_language = 'English'
               AND global_restricted_use = 3
               THEN
                  p_msg :=
                  'GSM Choice: Local, non-roaming, and non-long distance from NET10 MIN.'
                  ;
               ELSIF l_language != 'English'
               AND global_restricted_use = 0
               THEN
                  p_msg :=
                  'Seleccion GSM: Local, sin Roaming, y sin larga distancia de TracFone MIN'
                  ;
               ELSIF l_language != 'English'
               AND global_restricted_use = 3
               THEN
                  p_msg :=
                  'Seleccion GSM: Local, sin Roaming, y sin larga distancia de NET10 MIN'
                  ;
               END IF;
               */
               RETURN TRUE;
            END IF;
         END LOOP;
      END LOOP;
      global_part_serial_no := NULL;
      RETURN FALSE;
   END gsm_get_line_pref_county_fun;
   ---------------------------------------------------
   -- * sub function gsm_get_no_inv_carr_name_fun * --
   ---------------------------------------------------
   -- cwl changed 03/21/07
   FUNCTION gsm_get_no_inv_carr_name_fun
   RETURN VARCHAR2
   IS
      CURSOR c_next_available_carr_name(
         c_carrier_objid IN NUMBER
      )
      IS
      SELECT p.x_parent_name,  -- 'CINGULAR'
         NVL(p.x_no_inventory, 0) x_no_inventory,
         NVL(p.x_next_available, 0) x_next_available
      FROM table_x_parent p, table_x_carrier_group cg, table_x_carrier c
      WHERE p.objid = cg.x_carrier_group2x_parent
      AND UPPER (p.x_status) = 'ACTIVE'
      AND cg.objid = c.carrier2carrier_group
      AND UPPER(cg.x_status) = 'ACTIVE'
      AND c.objid = c_carrier_objid;
      r_next_available_carr_name c_next_available_carr_name%ROWTYPE;
      l_return_value VARCHAR2 (60) := NULL;
   BEGIN
      l_return_value := NULL;
      OPEN c_next_available_carr_name (carrier_dflt_array(1));
      FETCH c_next_available_carr_name
      INTO r_next_available_carr_name;
      CLOSE c_next_available_carr_name;
      l_return_value := r_next_available_carr_name.x_parent_name;
      RETURN l_return_value;
   END gsm_get_no_inv_carr_name_fun;
   ---------------------------------------------------
   -- * sub function gsm_is_esn_and_sim_used_fun  * --
   ---------------------------------------------------
   FUNCTION gsm_is_esn_and_sim_used_fun
   RETURN BOOLEAN
   IS
      -------
      -- * --
      -------
      CURSOR c_used_esn
      IS
      SELECT 1
      FROM table_part_inst phones
      WHERE phones.x_domain = 'PHONES'
      AND phones.part_serial_no = global_esn
      AND phones.x_part_inst_status IN ('51', '54');
      -- * 51 means USED, 54 is PASTDUE
      -------
      -- * --
      -------
      CURSOR c_used_sim_card
      IS
      SELECT 1
      FROM table_x_sim_inv sim
      WHERE sim.x_sim_inv_status = '251' -- * 251 means RESERVED
      AND sim.x_sim_serial_no = p_sim;
      n_dummy NUMBER;
      b_return_value BOOLEAN := FALSE;
   BEGIN
      OPEN c_used_esn;
      OPEN c_used_sim_card;
      FETCH c_used_esn
      INTO n_dummy;
      FETCH c_used_sim_card
      INTO n_dummy;
      IF (c_used_esn%FOUND)
      AND (c_used_sim_card%FOUND)
      THEN
         b_return_value := TRUE;
      END IF;
      CLOSE c_used_esn;
      CLOSE c_used_sim_card;
      -----------------------------------------------------------
      -- Function returns TRUE only if                         --
      -- ESN and SIM Card are both in the USED status          --
      -- and the Line is in DELETED status (deactivation case) --
      -----------------------------------------------------------
      RETURN b_return_value;
   END gsm_is_esn_and_sim_used_fun;
   -------------------------------------------
   -- * sub function gsm_is_line_deleted  * --
   -------------------------------------------
   FUNCTION gsm_is_line_deleted
   RETURN BOOLEAN
   IS
      -------
      -- * --
      -------
      CURSOR c_deleted_line
      IS
      SELECT 1
      FROM table_part_inst phones, table_part_inst lines
      WHERE phones.x_domain = 'PHONES'
      AND phones.part_serial_no = global_esn
      AND lines.part_to_esn2part_inst = phones.objid
      AND lines.x_domain = 'LINES'
      AND lines.x_part_inst_status = '17';
      -- * 17 means DELETED Note: This is the deactivation case
      b_return_value BOOLEAN := FALSE;
      n_dummy NUMBER;
   BEGIN
----------------------------------------------------------
      -- Function determines if the line is in DELETED status --
      ----------------------------------------------------------
      OPEN c_deleted_line;
      FETCH c_deleted_line
      INTO n_dummy;
      b_return_value := c_deleted_line%FOUND;
      CLOSE c_deleted_line;
      RETURN b_return_value;
   END gsm_is_line_deleted;
   ---------------------------------------------------
   -- * sub function gsm_is_iccid_valid4react_fun * --
   ---------------------------------------------------
   FUNCTION gsm_is_iccid_valid4react_fun RETURN NUMBER IS
     cursor same_zone_curs( c_old_carrier_objid in number,
                            c_new_carrier_objid in number,
                            c_old_zip           in varchar2,
                            c_new_zip           in varchar2) is
       select
              pa.x_parent_name old_parent_name,
              pa2.x_parent_name new_parent_name,
              (case when ca.objid = ca2.objid then
                      1
                    WHEN (pa.x_parent_name like '%CINGULAR%' or pa.x_parent_name like 'AT%')
                     AND (pa2.x_parent_name like '%CINGULAR%' or pa2.x_parent_name like 'AT%')
                     and exists ( SELECT mkt
                                    FROM sa.x_cingular_mrkt_info
                                   WHERE zip = c_old_zip INTERSECT
                                  SELECT mkt
                                    FROM sa.x_cingular_mrkt_info
                                   WHERE zip = c_new_zip) then
                     1
                   WHEN pa.x_parent_name like 'T-MO%' AND pa2.x_parent_name like 'T-MO%' then
                     1
                   ELSE
                     0
                   END ) same_zone
         from table_x_carrier ca,
              table_x_carrier_group cg,
                      table_x_parent pa,
              table_x_carrier ca2,
              table_x_carrier_group cg2,
                      table_x_parent pa2
        where ca.objid  = c_old_carrier_objid
          AND cg.objid  = ca.CARRIER2CARRIER_GROUP
          and pa.objid  = cg.X_CARRIER_GROUP2X_PARENT
          and ca2.objid = c_new_carrier_objid
          AND cg2.objid = ca2.CARRIER2CARRIER_GROUP
          and pa2.objid = cg2.X_CARRIER_GROUP2X_PARENT;
     same_zone_rec same_zone_curs%rowtype;
     CURSOR c_gsm_grace_time( c_carrier_objid IN NUMBER) IS
       SELECT cr.x_gsm_grace_period
         FROM table_x_carrier_rules cr, table_x_carrier c
        WHERE cr.objid = c.CARRIER2RULES_gsm
          AND c.objid = c_carrier_objid;
     c_gsm_grace_time_rec c_gsm_grace_time%ROWTYPE;
     cursor valid_sim_carriers_curs(c_sim_part_number in varchar2,
                                    c_technology in varchar2,
                                    c_dll in varchar2,
                                    c_carrier_objid in number) is
       SELECT distinct ca.objid carrier_objid
         FROM table_x_carrier ca,
              carrierpref cp,
              npanxx2carrierzones b,
              (SELECT DISTINCT a.ZONE,
                               a.st,
                               s.sim_profile,
                               a.county,
                               s.min_dll_exch,
                               s.max_dll_exch,
                               s.rank
                          FROM carrierzones a, carriersimpref s
                         WHERE a.zip = p_zip
                           and a.CARRIER_NAME=s.CARRIER_NAME
                           and c_dll between s.MIN_DLL_EXCH and s.MAX_DLL_EXCH
                         order by s.rank asc) a
        WHERE 1=1
          and ca.objid = c_carrier_objid
          and ca.x_carrier_id = b.carrier_id
          AND cp.st = b.state
          and cp.carrier_id = b.carrier_ID
          and cp.county = a.county
          AND b.gsm_tech  = c_technology
          and a.sim_profile = c_sim_part_number
          AND b.ZONE = a.ZONE
          AND b.state = a.st;
     valid_sim_carriers_rec valid_sim_carriers_curs%rowtype;
     cursor last_deact_date_curs3 is
       select sp.service_end_dt last_deact_date,
                      sp.install_date,
              sp.x_zipcode,
                      (select pi_min.part_inst2carrier_mkt
                 from table_part_inst pi_min
                where pi_min.part_serial_no = sp.x_min
                  and pi_min.x_domain = 'LINES') carrier_objid
         from table_part_inst pi,
                      table_site_part sp
        where 1=1
                  and pi.x_iccid      = p_sim
          and sp.x_service_id = pi.part_serial_no
                  and sp.x_iccid      = p_sim
          and sp.part_status in ('Active','Inactive','CarrierPending')
         order by sp.install_date;
     cursor last_deact_date_curs2 is
       select sp.service_end_dt last_deact_date,
                      sp.install_date,
              sp.x_zipcode,
                      (select pi_min.part_inst2carrier_mkt
                 from table_part_inst pi_min
                where pi_min.part_serial_no = sp.x_min
                  and pi_min.x_domain = 'LINES') carrier_objid
         from table_site_part sp
        where 1=1
          and sp.x_service_id = p_esn
                  and sp.x_iccid      = p_sim
          and sp.part_status in ('Active','Inactive','CarrierPending')
                order by install_date desc;
     cursor last_deact_date_curs1 is
       select sp.service_end_dt last_deact_date,
                      sp.install_date,
              sp.x_zipcode,
                      (select pi_min.part_inst2carrier_mkt
                 from table_part_inst pi_min
                where pi_min.part_serial_no = sp.x_min
                  and pi_min.x_domain = 'LINES') carrier_objid
         from table_site_part sp
        where 1=1
          and sp.x_service_id = p_esn
          and sp.part_status in ('Active','Inactive','CarrierPending')
                order by install_date desc;
     last_deact_date_rec last_deact_date_curs1%rowtype;
     cursor sim_curs is
       select si.X_SIM_SERIAL_NO,
              si.X_SIM_INV_STATUS,
              pn.part_number
         from sa.table_x_sim_inv si,
              table_mod_level ml,
              table_part_num pn
        where si.X_SIM_SERIAL_NO = p_sim
          and ml.objid = si.x_sim_inv2part_mod
          and pn.objid = ml.part_info2part_num;
     sim_rec sim_curs%rowtype;
     cursor esn_sim_curs is
       select pn.x_technology,
              pn.x_dll,
              pi.x_iccid sim,
              pn.part_number
         from table_part_inst pi,
              table_mod_level ml,
              table_part_num pn
        where pi.part_serial_no = p_esn
          and pi.x_domain = 'PHONES'
          and ml.objid = pi.n_part_inst2part_mod
          and pn.objid = ml.part_info2part_num;
     esn_sim_rec esn_sim_curs%rowtype;
  BEGIN
    DBMS_OUTPUT.put_line('4react func');
    open sim_curs;
      fetch sim_curs into sim_rec;
      if sim_curs%notfound then
        close sim_curs;
        return 1;
      end if;
      dbms_output.put_line('sim_rec.x_sim_inv_status:'||sim_rec.x_sim_inv_status);
    close sim_curs;
    open esn_sim_curs;
      fetch esn_sim_curs into esn_sim_rec;
      IF esn_sim_curs%NOTFOUND THEN
        DBMS_OUTPUT.put_line('esn_sim_curs%notfound');
        CLOSE esn_sim_curs;
        RETURN 1;
      end if;
      dbms_output.put_line('esn_sim_rec.sim:'||esn_sim_rec.sim);
      dbms_output.put_line('p_sim:'||p_sim);
    close esn_sim_curs;
    carrier_tmp_cnt := 0;
    FOR i IN 1..carrier_dflt_cnt LOOP
      open valid_sim_carriers_curs(sim_rec.part_number,
                                   esn_sim_rec.x_technology,
                                   esn_sim_rec.x_dll,
                                   carrier_dflt_array(i));
        fetch valid_sim_carriers_curs into valid_sim_carriers_rec;
        if valid_sim_carriers_curs%found then
          carrier_tmp_cnt := carrier_tmp_cnt + 1;
          carrier_tmp_array(carrier_tmp_cnt) := carrier_dflt_array(i);
        end if;
      close valid_sim_carriers_curs;
    END LOOP;
    if carrier_tmp_cnt = 0 then
      return 1;
    else
      carrier_dflt_cnt := carrier_tmp_cnt;
      FOR i IN 1..carrier_tmp_cnt LOOP
        carrier_dflt_array(i) := carrier_tmp_array(i);
      END LOOP;
    end if;
    if sim_rec.x_sim_inv_status = '253' then
      open last_deact_date_curs1;
        fetch last_deact_date_curs1 into last_deact_date_rec;
        dbms_output.put_line('last_deact_date_rec.carrier_objid:'||last_deact_date_rec.carrier_objid);
      close last_deact_date_curs1;
      FOR i IN 1..carrier_dflt_cnt LOOP
        if last_deact_date_rec.carrier_objid = carrier_dflt_array(i) then
          carrier_dflt_cnt := 1;
          carrier_dflt_array(1) := carrier_dflt_array(i);
          DBMS_OUTPUT.put_line('found new sim same carrier');
          return 5;
        end if;
      end loop;
      FOR i IN 1..carrier_dflt_cnt LOOP
        open same_zone_curs(last_deact_date_rec.carrier_objid,
                            carrier_dflt_array(i),
                            last_deact_date_rec.x_zipcode,
                            p_zip);
          fetch same_zone_curs into same_zone_rec;
          if same_zone_curs%found and same_zone_rec.same_zone = 1 then
            carrier_dflt_cnt := 1;
            carrier_dflt_array(1) := carrier_dflt_array(i);
            DBMS_OUTPUT.put_line('found new sim same zone');
            close same_zone_curs;
            return 5;
          end if;
        close same_zone_curs;
      end loop;
      DBMS_OUTPUT.put_line('new sim');
      return 5;
    end if;
    open last_deact_date_curs2;
      fetch last_deact_date_curs2 into last_deact_date_rec;
      if last_deact_date_curs2%notfound then
        open last_deact_date_curs3;
          fetch last_deact_date_curs3 into last_deact_date_rec;
          if last_deact_date_curs3%notfound then
            open last_deact_date_curs1;
              fetch last_deact_date_curs1 into last_deact_date_rec;
              if last_deact_date_curs1%notfound then
                close last_deact_date_curs1;
                close last_deact_date_curs2;
                close last_deact_date_curs3;
                return 1;
                    end if;
            close last_deact_date_curs1;
          end if;
        close last_deact_date_curs3;
      end if;
    close last_deact_date_curs2;
    DBMS_OUTPUT.put_line('last_deact_date_rec.last_deact_date:'||last_deact_date_rec.last_deact_date);
    DBMS_OUTPUT.put_line('last_deact_date_rec.carrier_objid:'||last_deact_date_rec.carrier_objid);
    DBMS_OUTPUT.put_line('last_deact_date_rec.x_zipcode:'||last_deact_date_rec.x_zipcode);
    DBMS_OUTPUT.put_line('p_zip:'||p_zip);
    DBMS_OUTPUT.put_line('last_deact_date_rec.carrier_objid:'||last_deact_date_rec.carrier_objid);
    OPEN c_gsm_grace_time (last_deact_date_rec.carrier_objid);
      FETCH c_gsm_grace_time INTO c_gsm_grace_time_rec;
      DBMS_OUTPUT.put_line('(SYSDATE - last_deact_date_rec.last_deact_date):'||(SYSDATE - last_deact_date_rec.last_deact_date));
      DBMS_OUTPUT.put_line('c_gsm_grace_time_rec.x_gsm_grace_period:'||c_gsm_grace_time_rec.x_gsm_grace_period);
      IF c_gsm_grace_time%FOUND AND (SYSDATE - last_deact_date_rec.last_deact_date) > c_gsm_grace_time_rec.x_gsm_grace_period THEN
        DBMS_OUTPUT.put_line('sim expired');
        CLOSE c_gsm_grace_time;
        return 2;
      end if;
    CLOSE c_gsm_grace_time;
    FOR i IN 1..carrier_dflt_cnt LOOP
      if last_deact_date_rec.carrier_objid = carrier_dflt_array(i) then
        carrier_dflt_cnt := 1;
        carrier_dflt_array(1) := carrier_dflt_array(i);
        DBMS_OUTPUT.put_line('found old sim same carrier');
        return 6;
      end if;
    end loop;
    FOR i IN 1..carrier_dflt_cnt LOOP
      open same_zone_curs(last_deact_date_rec.carrier_objid,
                          carrier_dflt_array(i),
                          last_deact_date_rec.x_zipcode,
                          p_zip);
        fetch same_zone_curs into same_zone_rec;
        if same_zone_curs%found and same_zone_rec.same_zone = 1 then
          carrier_dflt_cnt := 1;
          carrier_dflt_array(1) := carrier_dflt_array(i);
          DBMS_OUTPUT.put_line('found old sim same zone');
          close same_zone_curs;
          return 6;
        end if;
      close same_zone_curs;
    end loop;
    RETURN 4;
  END gsm_is_iccid_valid4react_fun;
   ---------------------------------------------------
   -- * sub function get_cingular_market_info_fun * --
   ---------------------------------------------------
   FUNCTION get_cingular_market_info_fun
   RETURN BOOLEAN
   IS
      l_return_value BOOLEAN;
   BEGIN
      OPEN c_cingular_mrkt_info (global_zip);
      FETCH c_cingular_mrkt_info
      INTO c_cingular_mrkt_info_rec;
      l_return_value := c_cingular_mrkt_info%FOUND;
      CLOSE c_cingular_mrkt_info;
      -------
      -- * --
      -------
      RETURN l_return_value;
   END get_cingular_market_info_fun;
-- ************************************************************************** --
-- * NAP_DIGITAL procedure                                                  * --
-- * DECLARATION section of the sub procedures ENDS here                    * --
-- ************************************************************************** --
-- ************************************************************************** --
-- * NAP_DIGITAL procedure                                                  * --
-- * Executional section STARTS here                                        * --
-- ************************************************************************** --
begin
  -- CR13249 Start
  if upper(nvl(p_language,'X')) <> 'SPANISH' then
    l_language := 'English';
  end if;
  -- CR13249 End
  --CR8406
   sa.Clean_Tnumber_Prc(p_esn, err_msg, p_msg);
  -- CR8406
   global_commit := upper (nvl (p_commit, 'no'));
   IF l_language = 'English'
   THEN
      p_msg := 'AGENT:  There are no lines available for this zip code. '||
      'Please advise the customer to call back in 24-48 hours.';
   ELSE
      p_msg := 'No hay lineas disponibles en el codigo de area que ingreso. '||
      'Por favor informe al cliente que llame en un periodo de 24 a 48 horas';
   END IF;
   ------------------------------------------------------
   -- GSM/OTHER TECHNOLOGIES (CDMA, TDMA) CHECK        --
   ------------------------------------------------------
   -- GSM check is a NAP LOGIC that routes             --
   -- transactions to the correct process branch based --
   -- on the part number technology.                   --
   -- There are two process branches:                  --
   -- One for all other technologies (CDMA, TDMA), and --
   -- the second one for GSM                           --
   ------------------------------------------------------
   --cdma meid change 05/16/07 add c_meid_carrier
   -- ACMI ACME project start
    OPEN technology_curs (P_esn);
      FETCH technology_curs INTO technology_rec;
    CLOSE technology_curs;
    check_safelink_proc;
    if technology_rec.x_technology <> 'GSM' THEN
-----------------------------------------------------
      -- CDMA, TDMA: 1st Process Branch:                 --
      -----------------------------------------------------
      -- Branch for non GSM technologies (CDMA, TDMA):   --
      -- because ESN number is 11 characters long        --
      -----------------------------------------------------
      -----------------------------------------------------
      -- CDMA, TDMA: (1) VALID ZIP CHECK                 --
      -----------------------------------------------------
      -- Valid Zip is a function that checks  the        --
      -- validity of the Zip Code.                       --
      -- If the given zip code is invalid, the function  --
      -- returns an error message and                    --
      -- NAP_DIGITAL procedure stops.                    --
      -----------------------------------------------------
      IF NOT valid_zip_fun
      then
         IF l_language = 'English'
         THEN
            p_msg := 'Invalid zipcode.';
         ELSE
            p_msg := 'area no valida.';
         END IF;
         RETURN;
      END IF;
      ----------------
      -- CR5192 START:
      ----------------
      IF NOT is_no_service_zip_fun
      then
         IF l_language = 'English'
         THEN
            p_msg := 'No available service.';
         ELSE
           p_msg := 'No available service.';
         END IF;
         RETURN;
      END IF;
      if sa.LTE_SERVICE_PKG.IS_ESN_LTE_CDMA (P_ESN)=1 then
        if p_sim is null then
          p_msg := 'SIM Exchange-ICCID profile not valid';
          return;
        else
          open valid_cdma_lte_curs;
            fetch valid_cdma_lte_curs into valid_cdma_lte_rec;
            if valid_cdma_lte_curs%notfound then
              p_msg := 'SIM Exchange-ICCID status is invalid';
              close valid_cdma_lte_curs;
              return;
            elsif valid_cdma_lte_rec.others_active > 0 then
              p_msg := 'SIM Exchange-ICCID is already attached to an IMEI';
              close valid_cdma_lte_curs;
              return;
            end if;
          close valid_cdma_lte_curs;
        end if;
      end if;
      -------------
      -- CR5192 END
      -------------
      --------------------------------------------------------
      -- CDMA, TDMA: (2) GET CARRIERS DEFAULT AND PREFERRED --
      --------------------------------------------------------
      -- Get carriers is a procedure that creates two       --
      -- lists/arrays of carriers to choose from when       --
      -- selecting a line for the customer.                 --
      -- The first list is the default list, driven by the  --
      -- zip code.                                          --
      -- The second list is the preferred list, driven by   --
      -- the ESN's dealer ID                                --
      --------------------------------------------------------
      get_carriers_prc;
      -------------------------------------------------------
      -- CDMA, TDMA: (3) CARRIER FOUND CHECK               --
      -------------------------------------------------------
      -- CDMA, TDMA: This system check consists on         --
      -- identifying whether there is a carrier from whom  --
      -- to reserve a line.                                --
      -- If yes, continue with the program execution to    --
      -- try to assign the line to the phone.              --
      -- Otherwise, EXIT nap_digital PROCEDURE             --
      -------------------------------------------------------
      IF     (carrier_dflt_cnt = 0)
         AND (carrier_prf_cnt  = 0) THEN
        if p_sim is not null and global_repl_sim is not null then
          p_msg := 'SIM Exchange';
          p_sim_profile := global_repl_sim;
        ELSE
          get_repl_part_prc (p_msg, p_repl_part, p_repl_tech, p_sim_profile);
          IF p_msg IS NULL THEN
            IF global_no_service = 1 THEN
              p_msg := 'No available service.';
            ELSE
              p_msg := 'No carrier found for technology.';
            END IF;
          END IF;
        END IF;
        DBMS_OUTPUT.put_line ('No carrier found for technology.(carrier_dflt_cnt = 0) and (carrier_prf_cnt = 0)');
        RETURN;
      END IF;
      -------------------------------------------------------
      -- CDMA, TDMA: (3) End of CARRIER FOUND CHECK        --
      -------------------------------------------------------
      ----------------------------------------------------------
      -- CDMA, TDMA: (6) CARRIER FOUND LOGIC                  --
      ----------------------------------------------------------
      -- CR5150                                         --
      -- CDMA, TDMA: get preferred carrier name         --
      -- and put it into p_pref_parent OUT parameter    --
      ----------------------------------------------------
      ----------------------------------------------------------
      -- CDMA, TDMA: (7) CHECK FOR LINE LOCKS                 --
      ----------------------------------------------------------
      -- This system check consists of identifying if         --
      -- there is a lock on the lines before checking for     --
      -- line availability.                                   --
      -- This is to avoid reserving the same line for two     --
      -- different customers, as multiple customer service    --
      -- representatives (CSR's) will try to search lines     --
      -- for different customers.                             --
      -- The check verifies if any line is reserved for the   --
      -- given ESN.  If there is a line reserved for the      --
      -- given ESN, the system then checks if the line        --
      -- reserved for the given ESN is a "PORT-IN line",      --
      -- "No MSID carrier upgrade" or "Nap verify reserved".  --
      -- A line reserved for "PORT-IN", "No MSID carrier      --
      -- upgrade" or "NAP verify reserved" is a locked line.  --
      -- The process of searching for locks is tried 3 times. --
      -- If there are locks, assign choice "F"                --
      -- Otherwise, There are no lines reserved for the       --
      -- given ESN, search for the next available line.       --
      ----------------------------------------------------------
      IF check_line_locks_fun
      THEN
         DBMS_OUTPUT.put_line('check_line_locks_fun:TRUE');
         update_c_choice_prc (global_part_serial_no, 'F');
         IF l_language = 'English'
         THEN
            p_msg := 'F Choice: MIN already attached to ESN.  Please verify.';
         ELSE
            p_msg :=
            'Seleccion F: MIN ya esta adjunto al ESN. Por Favor verifique';
         END IF;
         p_part_serial_no := global_part_serial_no;
         global_same_zone := TRUE;
         global_resource_busy := 'N';
         IF ( carrier_dflt_array. EXISTS (1)
         AND carrier_dflt_cnt <> 0 )
         THEN
            get_carrier_info (carrier_dflt_array (1), NULL, p_pref_parent);
            p_pref_carrier_objid := carrier_dflt_array(1);
         ELSE
            get_carrier_info (carrier_prf_array (1), NULL, p_pref_parent);
            p_pref_carrier_objid := carrier_prf_array(1);
         END IF;
      END IF;
      ---------------------------------------------------------------------
      -- CDMA, TDMA: End of (7) CHECK FOR LINE LOCKS                     --
      ---------------------------------------------------------------------
      -----------------------------------------------------------------------------
      -- CDMA, TDMA: (8) LINE AVAILABLE CHECK                                    --
      -----------------------------------------------------------------------------
      -- This system check consists on finding an available line for the given   --
      -- ESN. The process of searching for line is tried 3 times before returning--
      -- 'Resource Busy' error message to the CSR.                               --
      -- If the line is available and the choice that was found satisfies        --
      -- business criteria (choices "B" or "C") , the program ends with success. --
      -- If the line is available but the choice that was found doesn't satisfy  --
      -- the business criteria (choice "D"), the program ends and customer will  --
      -- be asked to call back because we were unable to assign the line to his  --
      -- phone at this time.                                                     --
      -- When he calls back, Cust Rep will make another attempt to assign the    --
      -- line number to the phone (call this procedure again).                   --
      -- The same thing will happen if we can't assign the line to the phone     --
      -- because there are NO any lines available (choice "N").                  --
      -----------------------------------------------------------------------------
      IF global_same_zone = FALSE
      THEN
         DBMS_OUTPUT.put_line('global_same_zone = FALSE');
         -------------------------------------------------------------------
         -- CDMA, TDMA: At this point here, we know that there is no      --
         -- lock/reservation the line.                                    --
         -- The logic below will either find the available                --
         -- line and assign choice "B" or "C" or maybe stop search        --
         -- (if the available choice is "D" or "D2")and tell customer to  --
         -- call back in 24 hours because at this point we are unable  to --
         -- assign the line to his ESN for given zip code                 --
         -------------------------------------------------------------------
         -------------------------------------------------------
         -- CDMA, TDMA: LINE  "B" OR "C" CHOICE               --
         -------------------------------------------------------
         -- This system check consists of identifying whether --
         -- the line available is a choice "B" or choice "C". --
         -- If the line is choice "B" or choice "C", that     --
         -- line will be assigned to the phone.               --
         -- Otherwise, no line will be assigned, and          --
         -- NAP_DIGITAL procedure will exit with no success.  --
         -------------------------------------------------------
         IF (get_line_pref_county_fun ('B1') = TRUE)
         THEN
            -----------------------------------------------------
            -- CDMA, TDMA: (8.a) LINE IS CHOICE "B"            --
            -----------------------------------------------------
            -----------------------------------------------------
            -- CDMA, TDMA: RESERVE THAT LINE                   --
            -----------------------------------------------------
            -- Reserve that Line is a NAP LOGIC that           --
            -- reserves a line to the given ESN based on the   --
            -- technology, frequency and zip code provided by  --
            -- the customer.                                   --
            -- The line is reserved and recorded in a table as --
            -- RESERVED if the line is new or RESERVED USED if --
            -- the line is a used line. Lines are not reserved --
            -- for line choices 'D', 'F', 'N',                 --
            -----------------------------------------------------
            p_part_serial_no := global_part_serial_no;
         ELSIF (get_line_pref_county_fun ('B2') = TRUE)
         THEN
            -----------------------------------------------------
            -- CDMA, TDMA: (8.b) LINE IS CHOICE "B2"           --
            -----------------------------------------------------
            -----------------------------------------------------
            -- CDMA, TDMA: RESERVE THAT LINE                   --
            -----------------------------------------------------
            -- Reserve that Line is a NAP LOGIC that           --
            -- reserves a line to the given ESN based on the   --
            -- technology, frequency and zip code provided by  --
            -- the customer.                                   --
            -- The line is reserved and recorded in a table as --
            -- RESERVED if the line is new or RESERVED USED if --
            -- the line is a used line. Lines are not reserved --
            -- for line choices 'D', 'F', 'N',                 --
            -----------------------------------------------------
            p_part_serial_no := global_part_serial_no;
         ELSIF (get_line_pref_sid_fun = TRUE)
         THEN
            -----------------------------------------------------
            -- CDMA, TDMA: (8.c) LINE IS CHOICE "C"            --
            -----------------------------------------------------
            -----------------------------------------------------
            -- CDMA, TDMA: RESERVE THAT LINE                   --
            -----------------------------------------------------
            -- Reserve that Line is a NAP LOGIC that           --
            -- reserves a line to the given ESN based on the   --
            -- technology, frequency and zip code provided by  --
            -- the customer.                                   --
            -- The line is reserved and recorded in a table as --
            -- RESERVED if the line is new or RESERVED USED if --
            -- the line is a used line. Lines are not reserved --
            -- for line choices 'D', 'F', 'N',                 --
            -----------------------------------------------------
            p_part_serial_no := global_part_serial_no;
         ELSE
            -------------------------------------------------------------
            -- CDMA, TDMA: (9) LINE IS NOT AVAILABLE                   --
            -- This logic here is to NOT RESERVE THE LINE              --
            -------------------------------------------------------------
            IF global_d_choice_found
            THEN
               ----------------------------------------------------------
               -- CDMA, TDMA: (9.a) LINE IS CHOICE "D"                 --
               ----------------------------------------------------------
               -- When the line available is not of the type/choice    --
               -- "B" or "C" the system assigns a line choice "D".     --
               -- A line choice "D" is assigned. The assignment is     --
               -- recorded in the Line Choice Table. No line gets      --
               -- reserved. Therefore a "D" choice is like not having  --
               -- a line and is treated as an "N" choice.              --
               ----------------------------------------------------------
               update_c_choice_prc (NULL, 'D');
            ELSIF global_d2_choice_found
            THEN
               ----------------------------------------------------------
               -- CDMA, TDMA: (9.b) LINE IS CHOICE "D"                 --
               ----------------------------------------------------------
               -- When the line available is not of the type/choice    --
               -- "B" or "C" the system assigns a line choice "D".     --
               -- A line choice "D" is assigned. The assignment is     --
               -- recorded in the Line Choice Table. No line gets      --
               -- reserved. Therefore a "D" choice is like not having  --
               -- a line and is treated as an "N" choice.              --
               ----------------------------------------------------------
               update_c_choice_prc (NULL, 'D2');
            ELSE
               -----------------------------------------------------------
               -- CDMA, TDMA: (9.c) LINE IS CHOICE "N"                  --
               -----------------------------------------------------------
               -- "N" = No line available                               --
               -----------------------------------------------------------
               -- In cases of lack of inventory a line                  --
               -- choice "N" is assigned. The assignment is recorded in --
               -- the Line Choice Table. No line gets reserved.         --
               -- The assignment of a choice "N" line triggers the      --
               -- creation of a No Lines Available Case.                --
               -----------------------------------------------------------
               -- When a No Lines Available Case is created;            --
               -- a turnaround  time (TAT) is given to customer.        --
               -- No Lines Available Cases are managed by: the Line     --
               -- Activations and the Line Management Support teams.    --
               -----------------------------------------------------------
               update_c_choice_prc (NULL, 'N');
            END IF;
         ----------------------------------------------------------------
         -- CDMA, TDMA: The line was NOT assigned for this ESN either  --
         -- because there was NO any lines available (choice "N") or   --
         -- the available choice was not good enough to satisfy        --
         -- business criteria (choices "D" and "D2").                  --
         -- Stop searching for the available lines.                    --
         -- Exit while loop and NAP_DIGITAL procedure                  --
         ----------------------------------------------------------------
         END IF;
      END IF;
      ---------------------------------------------------------------------------------
      -- CDMA, TDMA: End of "LINE LOCKS CHECK" and "LINE AVAILABLE CHECK" WHILE loop --
      ---------------------------------------------------------------------------------
      IF global_resource_busy = 'Y'
      THEN
         IF l_language = 'English'
         THEN
            p_msg := 'Resource was busy try again.';
         ELSE
            p_msg := 'El recurso esta ocupado. Por favor llame mas tarde.';
         END IF;
         p_part_serial_no := NULL;
      ELSE
         IF global_commit = 'YES'
         THEN
            DBMS_OUTPUT.put_line ('global_commit = ' || global_commit);
            COMMIT;
         END IF;
      END IF;
   -----------------------------------------------
   -- End of 1st Process Branch:                --
   -- CDMA, TDMA technologies.                  --
   -- ESN number is 11 characters long.         --
   -----------------------------------------------
   ELSE
      -----------------------------------------------
      -- GSM: 2nd Branch                           --
      -- This is a GSM technology                  --
      -- It has > 11 characters long ESN number    --
      -- Btw, it's 15 characters long              --
      -----------------------------------------------
      --cwl changes to gsm logic 03/21/07
      p_msg := NULL;
      IF NOT valid_zip_fun
      then
         IF l_language = 'English'
         THEN
            p_msg := 'Invalid zipcode.';
         ELSE
            p_msg := 'area no valida.';
         END IF;
         RETURN;
      END IF;
      IF NOT is_no_service_zip_fun
      then
         IF l_language = 'English'
         THEN
            p_msg := 'No available service.';
         ELSE
            p_msg := 'No available service.';
         END IF;
         RETURN;
      END IF;
      IF gsm_min_change
      THEN
         p_msg := 'MIN CHANGE ALLOWED';
         RETURN;
      END IF;
      DBMS_OUTPUT.put_line('gsm_get_dealer_prc'||p_msg);
      gsm_get_dealer_prc;
      DBMS_OUTPUT.put_line('gsm_get_phone_frequency_prc'||p_msg);
      gsm_get_phone_frequency_prc;
      DBMS_OUTPUT.put_line('gsm_get_default_carrier_prc '||p_msg);
      gsm_get_default_carrier_prc (global_technology);
      DBMS_OUTPUT.put_line('global_sim_valid_check:'||p_msg);
      global_sim_valid_check := gsm_is_valid_iccid_fun;
      DBMS_OUTPUT.put_line('global_sim_valid_check:'|| global_sim_valid_check);
      DBMS_OUTPUT.put_line('p_msg1:'||p_msg);
      digital_order;
      DBMS_OUTPUT.put_line('p_msg2:'||p_msg);
      check_data_phone;
      DBMS_OUTPUT.put_line('p_msg3:'||p_msg);
      IF p_msg = 'Exchange Phone. No Carrier in this area is data capable'
      THEN
         get_repl_part_prc (p_msg, p_repl_part, p_repl_tech, p_sim_profile);
        RETURN;
      END IF;
      DBMS_OUTPUT.put_line('p_msg4:'||p_msg);
      sim_order;
      DBMS_OUTPUT.put_line('p_msg5:'||p_msg);
      global_sim_valid_check := gsm_is_valid_iccid_fun;
      IF global_sim_valid_check IN (1, 2, 10, 11)
      AND p_msg
      IS
      NULL
      THEN
         IF global_repl_sim
         IS
         NULL
         THEN
            p_msg := 'No SIM Found in Carrier List';
         ELSE
            p_msg := 'SIM Exchange';
         END IF;
      END IF;
      DBMS_OUTPUT.put_line('global_sim_valid_check:'|| global_sim_valid_check);
      DBMS_OUTPUT.put_line('p_msg:'||p_msg);
      IF p_msg
      IS
      NOT NULL
      THEN
         IF p_msg = 'SIM Exchange'
         AND p_source IN ('TAS','WEBCSR', 'NETCSR')
         THEN
--added sourcesystem NETCSR (rev 1.5.2.1)
            p_sim_profile := global_repl_sim;
         ELSIF p_source IN ('TAS','WEBCSR', 'NETCSR')
         THEN
            get_repl_part_prc (p_msg, p_repl_part, p_repl_tech, p_sim_profile);
            IF p_msg
            IS
            NULL
            AND global_new_msg_flag = 'Y'
            THEN
               p_msg := 'NO CINGULAR COVERAGE';
            END IF;
         END IF;
         IF global_sim_valid_check = 1
         THEN
            p_msg := p_msg ||'-ICCID is already attached to an IMEI';
         ELSIF global_sim_valid_check = 2
         THEN
            p_msg := p_msg ||'-ICCID status is invalid';
         ELSIF global_sim_valid_check = 10
         THEN
            p_msg := p_msg ||'-ICCID profile not valid';
         ELSIF global_sim_valid_check = 11
         THEN
            p_msg := p_msg ||'-ICCID Preferred Carrier Not Found';
         END IF;
         IF carrier_dflt_array. EXISTS (1)
         AND carrier_dflt_cnt <> 0
         THEN
            get_carrier_info (carrier_dflt_array (1), NULL, p_pref_parent);
            p_pref_carrier_objid := carrier_dflt_array(1);
         END IF;
         RETURN;
      END IF;
      -----------------------------------------------------------------------------------------------------------------
      DBMS_OUTPUT.put_line('pre check_line_locks_fun');
      IF check_line_locks_fun
      THEN
         DBMS_OUTPUT.put_line('check_line_locks_fun:TRUE');
         update_c_choice_prc (global_part_serial_no, 'F');
         IF l_language = 'English'
         THEN
            p_msg := 'F Choice: MIN already attached to ESN.  Please verify.';
         ELSE
            p_msg :=
            'Seleccion F: MIN ya esta adjunto al ESN. Por Favor verifique';
         END IF;
         p_part_serial_no := global_part_serial_no;
         IF carrier_dflt_array. EXISTS (1)
         AND carrier_dflt_cnt <> 0
         THEN
            get_carrier_info (carrier_dflt_array (1), NULL, p_pref_parent);
            p_pref_carrier_objid := carrier_dflt_array(1);
         END IF;
         RETURN;
      END IF;
      -----------------------------------------------------------------------------------------------------------------
      IF gsm_is_a_react_fun THEN
        global_react_sim := gsm_is_iccid_valid4react_fun;
        IF global_react_sim IN (5, 6) THEN
          p_msg := 'No Inventory carrier.';
          IF carrier_dflt_array. EXISTS (1) AND carrier_dflt_cnt <> 0 THEN
            get_carrier_info (carrier_dflt_array (1), NULL, p_pref_parent);
            p_pref_carrier_objid := carrier_dflt_array(1);
          END IF;
          RETURN;
        ELSIF global_react_sim IN (1, 2, 4) THEN
          DBMS_OUTPUT.put_line('**global_react_sim:'||global_react_sim);
          DBMS_OUTPUT.put_line('carrier_dflt_array(1):'||carrier_dflt_array(1));
          IF carrier_dflt_array. EXISTS (1) AND carrier_dflt_cnt <> 0 THEN
            get_carrier_info (carrier_dflt_array (1), NULL, p_pref_parent);
            p_pref_carrier_objid := carrier_dflt_array(1);
          END IF;
          OPEN gsm_phone_frequency_curs2;
            FETCH gsm_phone_frequency_curs2 INTO Gsm_Phone_Frequency_Rec2;
            DBMS_OUTPUT.put_line('phone_dll:'||Gsm_Phone_Frequency_Rec2.x_dll);
          CLOSE Gsm_Phone_Frequency_Curs2;
          gsm_get_repl_sim_prc (Gsm_Phone_Frequency_Rec2.x_dll, p_msg, p_sim_profile);
          IF global_react_sim = 1 THEN
            p_msg := p_msg || '-ICCID profile not valid';
          ELSIF global_react_sim = 2 THEN
            p_msg := p_msg || '-ICCID Expired';
          ELSIF global_react_sim = 4 THEN
            p_msg := p_msg || '-Different Markets';
          END IF;
          RETURN;
        ELSE
          update_c_choice_prc (global_part_serial_no, 'F');
          IF l_language = 'English' THEN
            p_msg := 'F Choice: MIN already attached to ESN.  Please verify.';
          ELSE
            p_msg := 'Seleccion F: MIN ya esta adjunto al ESN. Por Favor verifique';
          END IF;
          p_part_serial_no := global_part_serial_no; --CR7356
          IF carrier_dflt_array. EXISTS (1) AND carrier_dflt_cnt <> 0 THEN
            get_carrier_info (carrier_dflt_array (1), NULL, p_pref_parent);
            p_pref_carrier_objid := carrier_dflt_array(1);
          END IF;
          RETURN;
        END IF;
      END IF;
      ------------------------------------------------------------------------------------------
      IF carrier_dflt_array. EXISTS (1)
      AND carrier_dflt_cnt <> 0
      THEN
         get_carrier_info (carrier_dflt_array (1), NULL, p_pref_parent);
         p_pref_carrier_objid := carrier_dflt_array(1);
      END IF;
      p_msg := 'No inventory carrier.';
      RETURN;
   -----------------------------------------------
   -- End of 2nd Process Branch:                --
   -- GSM technology                            --
   -- ESN number is > 11 characters long.       --
   -----------------------------------------------
   END IF;
   ----------------------------------------
   -- End of CDMA, TDMA and GSM branches --
   ----------------------------------------
   -------------------------
   -- The end of story... --
   -------------------------
   -- DEBUG:              --
   -------------------------
   -------------------------
   IF p_pref_carrier_objid IS NOT NULL THEN
       BEGIN
           SELECT x_mkt_submkt_name
             INTO l_carrier
             FROM table_x_carrier
            WHERE objid = p_pref_carrier_objid;
       EXCEPTION WHEN OTHERS THEN NULL;
       END;
   END IF;

   DBMS_OUTPUT.put_line ('ip_to_esn     = ' || p_esn);
   DBMS_OUTPUT.put_line ('l_carrier     = ' || l_carrier);
   DBMS_OUTPUT.put_line ('technology_rec.part_number     = ' || technology_rec.part_number);
   DBMS_OUTPUT.put_line ('x_part_inst_status     = ' || technology_rec.x_part_inst_status);
   DBMS_OUTPUT.put_line ('x_technology     = ' || technology_rec.x_technology);
   IF UPPER(l_carrier) LIKE 'VERIZON%' THEN
       l_volte_flag := sa.util_pkg.get_volte_flag(technology_rec.part_number);

        BEGIN
            SELECT allow_non_hd_acts,
                   allow_non_hd_reacts
              INTO l_allow_non_hd_acts,
                   l_allow_non_hd_reacts
              FROM table_x_carrier_rules cr,
                   table_x_carrier c
                --CR4579 Commented Out: WHERE cr.objid = c.carrier2rules
             WHERE cr.objid = DECODE(technology_rec.x_technology ,'GSM' ,c.carrier2rules_gsm ,'TDMA' ,c.carrier2rules_tdma ,'CDMA' ,c.carrier2rules_cdma ,c.carrier2rules)
               AND c.objid    = p_pref_carrier_objid;

        EXCEPTION
            WHEN OTHERS THEN
                l_allow_non_hd_reacts := 0;
        END;
        DBMS_OUTPUT.put_line ('l_volte_flag:'||l_volte_flag);
        DBMS_OUTPUT.put_line ('l_allow_non_hd_reacts:'||l_allow_non_hd_reacts);
        DBMS_OUTPUT.put_line ('l_allow_non_hd_acts:'||l_allow_non_hd_acts);

        --Verify for Verizon activation.
        IF NVL(technology_rec.x_part_inst_status,'0')  IN ('50' , '150') THEN
            DBMS_OUTPUT.put_line ('Validate for Verizon activation:');
            IF l_allow_non_hd_acts = 0 AND NVL(l_volte_flag,'N') = 'N' THEN
                p_pref_carrier_objid := NULL;
                p_msg := 'Not Eligible as Non-HD';
                DBMS_OUTPUT.put_line ('Not Eligible as Non-HD');
                RETURN;
            END IF;
        END IF;

        --Verify for Verizon Reactivation.
        IF NVL(technology_rec.x_part_inst_status,'0') NOT IN ('50' ,'150', '52') THEN
            DBMS_OUTPUT.put_line ('Validate for Verizon reactivation:');
            BEGIN
                SELECT COUNT(1)
                  INTO l_count
                  FROM table_part_inst pi_esn,
                       table_part_inst pi_min
                 WHERE 1=1
                   AND pi_esn.x_domain              = 'PHONES'
                   AND pi_esn.part_serial_no        = p_esn
                   AND pi_min.part_to_esn2part_inst = pi_esn.objid
                   AND pi_min.x_domain              = 'LINES'
                   AND pi_min.x_part_inst_status in ('37' , '39' , '73')
                     ;
            EXCEPTION WHEN OTHERS THEN
                NULL;
            END;
            --If No Reserved line and l_allow_non_hd_reacts = 0 then consider as Non-HD.
            IF l_count = 0 THEN
                IF l_allow_non_hd_reacts = 0 AND NVL(l_volte_flag,'N') = 'N' THEN
                    p_pref_carrier_objid := NULL;
                    p_msg := 'Not Eligible as Non-HD';
                    DBMS_OUTPUT.put_line ('Not Eligible as Non-HD');
                    RETURN;
                END IF;
            END IF; --    IF l_count >0 THEN
      	END IF;--IF NVL(technology_rec.x_part_inst_status,'0') NOT IN ('50' ,'150', '52') THEN
   END IF; --   IF UPPER(l_carrier) LIKE 'VERIZON%' THEN

   DBMS_OUTPUT.put_line (SUBSTR ('p_msg                = ' || p_msg, 1, 255));
   DBMS_OUTPUT.put_line ('*************** ');
   DBMS_OUTPUT.put_line ('FLAGS STATUSES: ');
   DBMS_OUTPUT.put_line ('*************** ');
   DBMS_OUTPUT.put_line ('global_commit              = ' || global_commit);
   DBMS_OUTPUT.put_line ( 'global_resource_busy       = ' ||
   global_resource_busy );
   DBMS_OUTPUT.put_line ('carrier_prf_cnt            = ' || carrier_prf_cnt);
   DBMS_OUTPUT.PUT_LINE ('carrier_dflt_cnt           = ' || CARRIER_DFLT_CNT);
END;
/