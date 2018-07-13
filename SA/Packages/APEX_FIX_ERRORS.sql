CREATE OR REPLACE PACKAGE sa."APEX_FIX_ERRORS" AS
/* =====================================================================================
Author: Daryl de Silva
Date  : 7/26/2016
Description:
This is a master 1052 script. Meant to replace the FIX ESN button, and do every fix we have
under the sun

Changelog:
-----------------------------------------------------------------------------------------
Build 1.011     11/16/2016      ISOLATED THE GLOBAL ESN VARIABLE CAUSING ISSUES WITH THE BUTTON CALL FOR FIX ESN IN TAS
                                MODIFIED CREATING A NEW WEB USER TO INCLUDE THE SITE EXTENSION
                                ADDED AN OVERLADED CALL FOR CALL_1052. THE BUTTON CREATES INTERACTIONS, A SCRIPT CALL DOES NOT.

Build 1.011     10/21/2016      FIXED THE CHECK_CARRIER_PENDING PROCEDURE.

Build 1.010     10/21/2016      CALL BACK LOOP WHEN UPDATES ARE MADE TO THE MAIN CURSOR, PART_INST
                                ENABLED THE
                                ENABLED THE CREATION OF MISSING WEB_USER, OTA_FEATURES, AND CONTACT RECORDS


Build 1.009     10/21/2016      ADDED BLOCK OF CODE TO CLEAR OTA_PENDING RECORDS WHEN CALL
                                TRANS IS COMPLETED


Build 1.008     10/19/2016      ADDED FIX_SITE_PART_MULTIPLE_ACTIVE
                                ADDED BLOCK OF CODE TO FIX_MIN TO DEACTIVATE PART_INST IF THERE
                                ARE NO ACTIVE SITE_PART RECORDS.
                                ADDED CALL TO RESET SIM WHEN A LINE IS DETACHED.
                                NOT NULL CHECKS WERE INCORRECT IN 4 PLACES. CHANGED.

Build 1.007     10/4/2016       FUNCTIONS WITHOUT A RETURN VALUE WERE FAILING. ADDED EXCEPTION
                                HANDLING.

Build 1.006     10/4/2016       ADDED A BLOCK TO UPDATE CARRIER PENDING, IF TMIN TO
                                INACTIVE, ELSE TO OBSOLETE

Build 1.005     10/3/2016       ADDED TMIN RESET
                                MODIFIED FIX_GROUP_NO_MASTER
                                ADDED DUGGI'S SUGGESTIONS FOR FIX_GROUP_WRONGBRAND (TW)
                                ADDED FIX_GROUP_DUPLICATE_MASTER
                                ADDED FIX_GROUP_ORDER
                                ADDED EXCEPTION HANDLING FOR ALL PROCEDURES

Build 1.004     9/26/2016       ADDED DUGGI'S SUGGESTIONS FOR CASE PENDING (TW)
                                ADDED FIX_SITE_PART_MOST_RECENT
                                ADDED FIX_SITE_PART_OBSOLETE
                                USE A MORE READER FRIENDLY LOGGED_IN_USER VALUE FOR LOGGING

Build 1.003     9/23/2016       ADDED REFURBISH CLEANUP PROCEDURE FIX_REFURBISH
                                FIXED THE LOGGED IP ADDRESS MISSING.

Build 1.002     9/7/2016        ADDED CLICK_PLAN LOGIC TO THE FIX_MIN PROCEDURE

Build 1.001     8/10/2016       RETIRED THE RULE FOR "MULTIPLE ADD INFO RECORDS ARE IN
                                TABLE_X_CONTACT_ADD_INFO". IN FIX_ACCOUNT PROCEDURE NO ENTRIES
                                SINCE JULY 2015.


========================================================================================*/

  ----------------------------------------------------------------------------------
  -- FUNCTIONS
  ----------------------------------------------------------------------------------
  FUNCTION GET_CLICKPLAN_PN(PART_OBJID IN VARCHAR2) RETURN NUMBER;

  FUNCTION GET_CLICKPLAN_TECH(PART_NUMBER IN VARCHAR2, TECH IN VARCHAR2) RETURN NUMBER;

  FUNCTION GET_WEB_USER_OBJID(P_CONTACT IN VARCHAR2) RETURN NUMBER;

  FUNCTION IS_SAFELINK(V_ESN IN VARCHAR2) RETURN NUMBER;

  FUNCTION IS_FEATURE_PHONE(V_ESN IN VARCHAR2) RETURN NUMBER;

  FUNCTION GET_MIN_FROM_ESN(V_ESN IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION GET_SITE_PART_ID(P_ESN IN VARCHAR2) RETURN NUMBER;

  FUNCTION CHECK_SITE_PART(ESN  IN VARCHAR2, LINE IN VARCHAR2) RETURN NUMBER;

  FUNCTION GET_CARRIER(ESN IN VARCHAR2, CREATE_DATE IN DATE) RETURN NUMBER;

 --- PROCEDURES  --------------------------------------------------------------------------

  /*=======================================================================================
  PROCEDURE: LOG_MSG
  DETAILS  : CREATES A LOG ENTRY IN THE RESOLUTION TABLE, EVEN IF NO FIX WAS FOUND
  =======================================================================================*/
  PROCEDURE LOG_MSG(
      ESN      IN VARCHAR2,
      MSG      IN VARCHAR2,
      BRAND_IN IN VARCHAR2,
      LOG_TYPE IN VARCHAR2);

   /*=======================================================================================
  PROCEDURE: CREATE_INTERACTION
  DETAILS  : CREATES AN INTERACTION WITH RESULTS FOR THE USER
  =======================================================================================*/
 PROCEDURE CREATE_INTERACTION
      (
        ESN     IN VARCHAR2,
        MSG     IN VARCHAR2,
        OUTCOME IN VARCHAR2
      );

  /*=======================================================================================
PROCEDURE: RESET_SIM
DETAILS  : SET SIM STATUS BACK TO 253
=======================================================================================*/
PROCEDURE RESET_SIM(P_ESN IN VARCHAR2,P_BRAND IN VARCHAR2,P_ICCID IN VARCHAR2,V_MSG OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: UPDATE_LINE
DETAILS  : UPDATES THE X_PART_INST_STATUS TO PASSED STATUS FOR LINE PARAMETER
=======================================================================================*/
PROCEDURE UPDATE_LINE(ESN_IN  IN VARCHAR2,LINE  IN VARCHAR2,V_BRAND IN VARCHAR2,STATUS  IN VARCHAR2);

/*=======================================================================================
PROCEDURE: ATTACH_LINE
DETAILS  : UPDATES THE PART_TO_ESN2PART_INST TO TABLE_PART_INST OBJID
=======================================================================================*/
PROCEDURE ATTACH_LINE(ESN IN VARCHAR2,V_BRAND IN VARCHAR2,LINE  IN VARCHAR2,V_MSG OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: DETACH_LINE
DETAILS  : UPDATES THE PART_TO_ESN2PART_INST TO NULL FOR THE PARAMETER ESN
NOTE : IT BRANCHES OUT IF THE MIN IS A TMIN. CALLS THE UPDATE_LINE, SETS THE LINE TO
RETURNED (17)
=======================================================================================*/
PROCEDURE DETACH_LINE(LINE  IN VARCHAR2,V_BRAND IN VARCHAR2,ESN_ID  IN NUMBER,V_MSG OUT VARCHAR2);
/*=======================================================================================
PROCEDURE: FIX_LINE_PART
DETAILS  : SETS PART_MOD TO 23070541, WHICH MAPS TO 'LINE' IN TABLE_PART_NUM
=======================================================================================*/
PROCEDURE FIX_LINE_PART(LINE  IN VARCHAR2,V_BRAND IN VARCHAR2,V_MSG OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: SET_PH_FROM_IG
DETAILS  : A LOGIC PROCEDURE. SETS THE OUTBOUND MIN BASED ON RULES
=======================================================================================*/
PROCEDURE SET_PH_FROM_IG(TECHNOLOGY_FLAG VARCHAR2,P_MSID IG_TRANSACTION.MSID%TYPE,P_MIN IG_TRANSACTION.MIN%TYPE ,V_MIN OUT TABLE_SITE_PART.X_MIN%TYPE,V_MSID OUT TABLE_SITE_PART.X_MSID%TYPE );

/*=======================================================================================
PROCEDURE: INSERT_NPANXX
DETAILS  :
=======================================================================================*/
PROCEDURE INSERT_NPANXX(ESN IN VARCHAR2,V_BRAND IN VARCHAR2,MIN_IN  IN VARCHAR2,CARRIER_ID_IN IN VARCHAR2,ZIP IN VARCHAR2);

/*=======================================================================================
PROCEDURE: INSERT_MIN
DETAILS  : ONCE THERE IS A CARRIER AND ESN IS NOT ACTIVE, THEN SET ESN (PART_INST) TO ACTIVE
CHECK THE NUMBER OF LINES. IF NONE FOUND THEN CALL A CREATE LINE PACKAGE.
CHECK NUMBER OF LINES AFTER THIS, IF ONE IS FOUND THEN FIND THE LINE IN PART_INST
AND SET TO ACTIVE (13)
=======================================================================================*/
PROCEDURE INSERT_MIN(MIN_IN  IN VARCHAR2,ESN_OBJID IN VARCHAR2,P_ESN IN VARCHAR2,P_BRAND IN VARCHAR2,MSID  IN VARCHAR2,P_CARRIER IN VARCHAR2,EXP_DT  IN VARCHAR2,P_STATUS  IN VARCHAR2,P_ZIP IN VARCHAR2);

/*=======================================================================================
PROCEDURE: CHECK_MIN_IG
DETAILS  : COMPARES THE MIN INFORMATION IN THE CALL_TRANS AGAINST THE IG_TRANSACTION TABLE
=======================================================================================*/
PROCEDURE CHECK_MIN_IG(ESN IN VARCHAR2,CREATE_DATE IN DATE,EXP_DT  IN VARCHAR2,V_BRAND IN VARCHAR2);

/*=======================================================================================
PROCEDURE: CHECK_MIN_SITE_PART
DETAILS  :
=======================================================================================*/
PROCEDURE CHECK_MIN_SITE_PART(MIN_INP IN VARCHAR2,EXP_DT  IN VARCHAR2,V_ESN IN VARCHAR2,V_BRAND IN VARCHAR2,V_STATUS  IN VARCHAR2,V_ZIP IN VARCHAR2);

/*=======================================================================================
PROCEDURE: FIX_MIN
DETAILS  : This procedure calls multiple procedures and a function
INSERT_MIN, CHECK_MIN_SITE_PART, CHECK_MIN_IG, GET_CARRIER.
The idea is to fix any MIN issues that may be found
=======================================================================================*/
PROCEDURE FIX_MIN(ESN_IN  IN VARCHAR2,V_BRAND IN VARCHAR2,V_STATUS IN VARCHAR2,V_ICCID IN VARCHAR2,V_MSG OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: FIX_SITE_PART
DETAILS  :
NOTES  :
=======================================================================================*/
PROCEDURE FIX_SITE_PART(ESN IN VARCHAR2,V_BRAND IN VARCHAR2,V_MSG OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: CHECK_CARRIER_PENDING
DETAILS  : CHECKS IF THE ESN IS IN CARRIER PENDING STATUS, AND WITHIN THE 4 HOUR TIME FRAME
=======================================================================================*/
PROCEDURE CHECK_CARRIER_PENDING(ESN_IN IN VARCHAR2, IS_C_PENDING OUT VARCHAR2);


/*=======================================================================================
PROCEDURE: CHECK_SWITCHBASE
DETAILS  : IF SWITCHBASED TRANSACTION HAS A STATUS OF CARRIER PENDING, SET TO COMPLETED
=======================================================================================*/
PROCEDURE CHECK_SWITCHBASE(ESN_IN  IN VARCHAR2,BRAND_IN  IN VARCHAR2,V_MSG OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: CHECK_LINE_NOT_ACTIVE_ESN
DETAILS  : IF LINE IS ACTIVE
=======================================================================================*/
PROCEDURE CHECK_LINE_NOT_ACTIVE_ESN(ESN_IN IN VARCHAR2,V_BRAND IN VARCHAR2,ESN_STATUS IN VARCHAR2,V_MSG OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: FIX_REFURBISH
DETAILS  : SERIES OF REFURBISHMENT FIXES
1. IF STATUS IN 150 THEN CHANGE TO 50
=======================================================================================*/
PROCEDURE FIX_REFURBISH(ESN IN VARCHAR2,V_BRAND IN VARCHAR2,V_ESN_STATUS IN VARCHAR2,V_MSG OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: FIX_PORT_IN
DETAILS  : IF X_PORT_IN IS ANYTHING BUT ZERO SET IT TO NULL. THIS CLEARS THE PORT IN FLAG.
=======================================================================================*/
PROCEDURE FIX_PORT_IN(ESN IN VARCHAR2,V_BRAND IN VARCHAR2,X_PORT_IN IN VARCHAR2,V_MSG OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: FIX_INCORRECT_SIZE
DETAILS  : CHECKS TO SEE IF WE HAVE DUPLICATE DEACTIVATION RECORDS IN CALL TRANS WHERE
ESN AND TRANSACT DATE ARE THE SAME. IF THEY ARE, SET EACH TO ONE SECOND EARLIER
=======================================================================================*/
PROCEDURE FIX_INCORRECT_SIZE(ESN IN VARCHAR2,V_BRAND IN VARCHAR2,V_MSG OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: FIX_NPA
DETAILS  : FIX NPA, NXX, EXT
=======================================================================================*/
PROCEDURE FIX_NPA(LINE  IN VARCHAR2,V_BRAND IN VARCHAR2,V_MSG OUT VARCHAR2);


/*=======================================================================================
PROCEDURE: FIX_CARD
DETAILS  : IF CARD STATUS IS 42, 263 (NOT REDEEMED, OTA REDEMPTION PENDING), SET TO RESERVED (40)
=======================================================================================*/
PROCEDURE FIX_CARD(ESN  IN VARCHAR2,BRAND_IN IN VARCHAR2,V_MSG OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: FIX_100
DETAILS  : IF PART_INST2X_NEW_PERS IS NOT NULL, THEN UPDATE PART_INST2X_PERS TO THIS VALUE
AND SET PART_INST2X_NEW_PERS = NULL
=======================================================================================*/
PROCEDURE FIX_100(ESN  IN VARCHAR2,BRAND_IN IN VARCHAR2,V_MSG OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: FIX_ACTIVE_LINE
DETAILS  : FIXES TO AN ACTIVE LINE
=======================================================================================*/
PROCEDURE FIX_ACTIVE_LINE(ESN_IN IN VARCHAR2,V_BRAND IN VARCHAR2,V_MSG OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: FIX_CONTACT
DETAILS  : CHECKS FOR MISSING CONTACT IN PART_INST. IF MISSING GETS IT FROM SITE_PART.
ALSO CHECKS FOR VALID CONTACT ROLE(DEFAULT). IF NONE IT CREATES ONE. IF DUPLICATE
IT NULLS THE DUPLICATES. IF ONE, MAKE SURE IT SAYS DEFAULT.
ALSO CHECKS VARIOUS SMALL FIELDS LIKE ZIP AND COUNTRY ETC.
=======================================================================================*/
PROCEDURE FIX_CONTACT(ESN IN VARCHAR2,V_BRAND IN VARCHAR2,V_MSG OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: FIX_SITE_PART_OBSOLETE
DETAILS  : ITERATE THROUGH ALL THE SITE PART RECORDS WITH A STATUS OF OBSOLETE AND UPDATE
TO INACTIVE
=======================================================================================*/
PROCEDURE FIX_SITE_PART_OBSOLETE(ESN IN VARCHAR2,V_BRAND IN VARCHAR2,V_MSG OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: FIX_SITE_PART_MULTIPLE_ACTIVE
DETAILS  : IF THERE ARE MULTIPLE ACTIVE RECORDS
=======================================================================================*/
PROCEDURE FIX_SITE_PART_MULTIPLE_ACTIVE(ESN IN VARCHAR2,V_BRAND IN VARCHAR2,V_MSG OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: FIX_SITE_PART_MOST_RECENT
DETAILS  : IF ANY INACTIVE RECORDS ARE NEWER THAN THE ACTIVE RECORD, DISCONNECT BY UPDATING
THE X_SERVICE_ID TO X_SERVICE_ID || 'R'
=======================================================================================*/
PROCEDURE FIX_SITE_PART_MOST_RECENT(ESN IN VARCHAR2,V_BRAND IN VARCHAR2,V_MSG OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: FIX_SP_OBS_TIME
DETAILS  : IF THERE IS A SITE_PART RECORD FLAGGED AS OBSOLETE WITH THE EXACT SAME TIME AS A
RECORD THAT IS MARKED AS ACTIVE, THEN SET THE OBSOLETE RECORD BACK BY 1 SECOND
=======================================================================================*/
PROCEDURE FIX_SP_OBS_TIME(ESN_IN  IN VARCHAR2,V_BRAND IN VARCHAR2,V_MSG OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: CHECK_OTA
DETAILS  : FOR A NON OTA PHONE, IF THERE IS A CALL TRANS OTA TYPE OF WITH 273, CHANGE IT TO 264
=======================================================================================*/
PROCEDURE CHECK_OTA(ESN IN VARCHAR2,V_BRAND IN VARCHAR2,ESN_OBJID IN VARCHAR2,V_MSG OUT VARCHAR2);


/*=======================================================================================
PROCEDURE: CHECK_ATTACHED_LINES
DETAILS  : IF ESN HAS NO LINE ATTACHED, THEN ATTACH ONE
=======================================================================================*/
PROCEDURE CHECK_ATTACHED_LINES(ESN IN VARCHAR2,V_BRAND IN VARCHAR2,V_MSG OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: CHECK_ADD_INFO
DETAILS  :  IF NO ADD_INFO FOR THIS CONTACT, THEN CHECK FOR A WEB USER (WITH SAME CONTACT AND BUS ORG)
IF A WEB USER EXISTS, THEN USE THAT TO CREATE AN ADD INFO RECORD
IF ADD_INFO DOES EXIST FOR THIS CONTACT, IF THE BUS ORG IS DIFFERENT, UPDATE IT TO THE PARAMETER BUS_ORG
IF MULTIPLE EXIST FOR THIS CONTACT, REMOVE ALL BUT THE MOST RECENT.
=======================================================================================*/
PROCEDURE CHECK_ADD_INFO(P_ESN IN VARCHAR2,P_CONTACT IN NUMBER,P_BRAND IN VARCHAR2,P_BUS_ORG IN VARCHAR2);

/*=======================================================================================
PROCEDURE: CHECK_WEB_USER
DETAILS  :  IF THE WEB USER TABLE HAS NO RECORDS FOR THE CONTACT AND BUS ORG COMBO, THEN CREATE ONE
IF MULTIPLE ARE FOUND, KEEP THE MOST RECENT, NULL OUT THE OTHERS.
=======================================================================================*/
PROCEDURE CHECK_WEB_USER(P_ESN IN VARCHAR2,P_CONTACT IN NUMBER,P_BRAND IN VARCHAR2,P_BUS_ORG IN VARCHAR2);


/*=======================================================================================
PROCEDURE: CHECK_SIM_ATTACHMENT
DETAILS  : IF SIM IS ACTIVE, AND SIM IS NOT ATTACHED TO THE RIGHT ESN, DETACH IT
=======================================================================================*/
PROCEDURE CHECK_SIM_ATTACHMENT(P_ESN IN VARCHAR2,P_BRAND IN VARCHAR2,P_ICCID IN VARCHAR2,V_MSG OUT VARCHAR2);


/*=======================================================================================
PROCEDURE: ACTIVATE_SIM
DETAILS  : IF SIM STATUS IN '253','251', THEN SET IT TO 254
=======================================================================================*/
PROCEDURE ACTIVATE_SIM(P_ESN IN VARCHAR2,P_BRAND IN VARCHAR2,P_ICCID IN VARCHAR2,V_MSG OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: CHECK_SIM
DETAILS  : IF ESN IS ACTIVE AND THERE IS AN ICCID ATTACHED, THEN TRY ACTIVATE SIM
IF ESN IS NOT ACTIVE AND THERE IS AN ICCID ATTACHED, CHECK STATUS TO TRY AND DETACH SIM
=======================================================================================*/
PROCEDURE CHECK_SIM(P_ESN IN VARCHAR2,P_BRAND IN VARCHAR2,P_ESN_STATUS  IN VARCHAR2,P_ICCID IN VARCHAR2,V_MSG OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: FIX_LIMITS_EXCEEDED
DETAILS  : IF ESN HAS COMP UNITS ON A CASE THAT ARE MORE THAN AN HOUR OLD, THEN CREATE MORE
REPLACEMENT UNITS AND UPDATE THE TABLE_CASE RECORD.
=======================================================================================*/
PROCEDURE FIX_LIMITS_EXCEEDED(P_ESN  IN VARCHAR2,P_BRAND  IN VARCHAR2,V_MSG  OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: CR_DUMMY_ACCT
DETAILS  : THIS WILL CREATE A LINK TO TABLE_X_CONTACT_ADD_INFO, A NEW WEB USER AS WELL
=======================================================================================*/
PROCEDURE CR_DUMMY_ACCT(P_ESN IN VARCHAR2,P_BRAND IN VARCHAR2,P_BUS_ORG IN NUMBER,P_ESN_OBJID IN VARCHAR2,P_ESN_CONTACT IN VARCHAR2);

/*=======================================================================================
PROCEDURE: FIX_ACCOUNT
DETAILS  : SERIES OF FIXES AND CHECKS FOR THE ACCOUNT OF AN ESN
=======================================================================================*/
PROCEDURE FIX_ACCOUNT(P_ESN IN VARCHAR2,P_BRAND IN VARCHAR2,P_BUS_ORG IN NUMBER,P_ESN_OBJID IN VARCHAR2,P_ESN_CONTACT IN VARCHAR2,P_CNT OUT NUMBER);

/*=======================================================================================
PROCEDURE: COMMON_ENROLLMENT_ISSUES
DETAILS  :
=======================================================================================*/
PROCEDURE COMMON_ENROLLMENT_ISSUES(P_ESN IN VARCHAR2,P_BRAND IN VARCHAR2,P_BUS_ORG IN NUMBER,P_ESN_CONTACT IN NUMBER);

/*=======================================================================================
PROCEDURE: FIX_EP_RECORDS_NOT_ACTIVE
DETAILS  : CHECKS TO SEE IF THERE IS AN ENROLLMENT (ENROLLMENTPENDING) FOR A PART INST
ESN THAT IS NOT IN STATE 52 (ACTIVE). IF THERE IS A RECORD THEN
UPDATE X_PROGRAM_ENROLLED AND SET X_ENROLLMENT_STATUS = ENROLLMENTFAILED
FOR THAT ESN.
=======================================================================================*/
PROCEDURE FIX_EP_RECORDS_NOT_ACTIVE(P_ESN IN VARCHAR2,P_BRAND IN VARCHAR2);

/*=======================================================================================
PROCEDURE: CHECK_SERVICE_PLAN
DETAILS  : CHECKS FOR AN ACTIVE SITE PART RECORD AND MAPS THE SERVICE PLAN TO THE ENROLLED RECORD
IF THE ENROLLMENT RECORD IS NOT 'ENROLLED' THEN ALERT AGENT SAYING
'ESN IS NOT ENROLLED IN ANY PROGRAM'.
=======================================================================================*/
PROCEDURE CHECK_SERVICE_PLAN(P_ESN IN VARCHAR2,P_BRAND IN VARCHAR2);

/*=======================================================================================
PROCEDURE: UPDATE_PGM_ENROLL
DETAILS  : UPDATES X_PROGRAM_ENROLLED AND SETS THE PGM_ENROLL2PGM_GROUP TO NULL FOR A
GIVEN OBJID
=======================================================================================*/
PROCEDURE UPDATE_PGM_ENROLL(OBJID_IN IN NUMBER,P_ESN IN VARCHAR2,P_BRAND IN VARCHAR2);


/*=======================================================================================
PROCEDURE: FIX_MISSING_SERVICE_PLAN
DETAILS  : IF A GROUP SERVICE_PLAN_ID IS NULL, BUT THE ESN FOR A GROUP MEMBER VIA SITEPART
HAS A SERVICE PLAN, THEN UDPATE ACCOUNT GROUP TO THAT SERVICE PLAN ID
=======================================================================================*/
PROCEDURE FIX_MISSING_SERVICE_PLAN(P_ESN IN VARCHAR2,P_BRAND IN VARCHAR2,P_ESN_STATUS  IN VARCHAR2);

/*=======================================================================================
PROCEDURE: FIX_EXPIRED_GROUP
DETAILS  : IF MEMBER IS ACTIVE (AND ESN IS ACTIVE), AND GROUP IS EXPIRED, THEN SET GROUP TO ACTIVE
=======================================================================================*/
PROCEDURE FIX_EXPIRED_GROUP(P_ESN IN VARCHAR2,P_BRAND IN VARCHAR2,P_ESN_STATUS  IN VARCHAR2);

/*=======================================================================================
PROCEDURE: FIX_GROUP_MEMBER
DETAILS  : IF GROUP IS ACTIVE (AND ESN AND LINE IS ACTIVE), AND MEMBER IS EXPIRED, THEN SET MEMBER TO ACTIVE
=======================================================================================*/
PROCEDURE FIX_GROUP_MEMBER( P_ESN IN VARCHAR2,P_BRAND IN VARCHAR2,P_ESN_STATUS  IN VARCHAR2);


/*=======================================================================================
PROCEDURE: FIX_DUPLICATE_GROUP_MEMBER
DETAILS  : IF A GROUP HAS THE SAME MEMBER OCCURRING MORE THAN ONCE, WE EXPIRE ALL BUT
THE MOST RECENT COPY OF THAT MEMBER.
=======================================================================================*/
PROCEDURE FIX_DUPLICATE_GROUP_MEMBER( P_ESN IN VARCHAR2,P_BRAND IN VARCHAR2,P_ESN_STATUS  IN VARCHAR2);

/*=======================================================================================
PROCEDURE: FIX_GROUP_DUPLICATE_MASTER
DETAILS  : IF A GROUP MEMBER IS IN A GROUP THAT HAS MORE THAN ONE MASTER, SET ALL BUT ONE TO 'N'
=======================================================================================*/
PROCEDURE FIX_GROUP_DUPLICATE_MASTER( P_ESN IN VARCHAR2,P_BRAND IN VARCHAR2,P_ESN_STATUS  IN VARCHAR2);

/*=======================================================================================
PROCEDURE: FIX_GROUP_NO_MASTER
DETAILS  : IF AN ACTIVE GROUP WITH ACTIVE MEMBERS HAS NONE OF THE MEMBERS WITH THE MASTER
FLAG=Y, WE TAKE THE ESN AND MAKE THAT ONE THE MASTER.
=======================================================================================*/
PROCEDURE FIX_GROUP_NO_MASTER( P_ESN IN VARCHAR2,P_BRAND IN VARCHAR2,P_ESN_STATUS  IN VARCHAR2);

/*=======================================================================================
PROCEDURE: FIX_GROUP_WRONGBRAND
DETAILS  : IF ESN IS IN A DIFFERENT BRAND THAN THE GROUP THEN EXPIRE THE GROUP AND THE ESN

=======================================================================================*/
PROCEDURE FIX_GROUP_WRONGBRAND( P_ESN IN VARCHAR2,P_BRAND IN VARCHAR2,P_ESN_STATUS  IN VARCHAR2);

/*=======================================================================================
PROCEDURE: FIX_GROUP_CASEPENDING
DETAILS  : IF ESN IS IN STATUS NEW, GROUP MEMBER IS CASE PENDING, ITS A ONE MEMBER GROUP
AND GROUP ITSELF IS IN EXPIRED STATE, THEN SET GROUP TO NEW

=======================================================================================*/
PROCEDURE FIX_GROUP_CASEPENDING( P_ESN IN VARCHAR2,P_BRAND IN VARCHAR2,P_ESN_STATUS  IN VARCHAR2);


/*=======================================================================================
PROCEDURE: FIX_GROUPS
DETAILS  : COLLECTION OF FIXES FOR THE GROUPS
=======================================================================================*/
PROCEDURE FIX_GROUPS(P_ESN IN VARCHAR2,P_BRAND IN VARCHAR2,P_ESN_STATUS  IN VARCHAR2,V_MSG OUT VARCHAR2);


/*=======================================================================================
PROCEDURE: FAMILY_PLAN_DEENROLL
DETAILS  : CHECKS FOR DISCREPANCIES WITH CHILD MEMBERS AND PARENT MEMBER OF A GROUP ENROLLMENT
1. IF CHILD IS NOT ENROLLED, BUT PARENT IS, THEN DISCONNECT FROM GROUP
2. IF PARENT IS ENROLLMENTSCHEDULED AND CHILD IS ANYTHING ELSE, DISCONNECT CHILD FROM GROUP
3. IF PARENT IS SUSPENDED AND CHILD IS NOT SUSPENDED, DISCONNECT CHILD FROM GROUP
4. WHEN PARENT IS NOT ENROLLED, NOT ENROLLMENTSCHEDULED, NOT SUSPENDED, THEN DISCONNECT CHILD FROM GROUP
5. IF CHILD IS ENROLLED, BUT PARENT IS NOT ENROLLED,ENROLLMENTSCHEDULED OR SUSPENDED, THEN DISCONNECT CHILD
6. IF CHILD IS ENROLLMENTSCHEDULED AND PARENT IS NOT, DISCONNECT CHILD
7. IF CHILD IS SUSPENDED AND PARENT IS NOT SUSPENDED, DISCONNECT CHILD FROM GROUP
8. WHEN CHILD IS NOT ENROLLED, NOT ENROLLMENTSCHEDULED, NOT SUSPENDED, THEN DISCONNECT CHILD FROM GROUP
=======================================================================================*/
PROCEDURE FAMILY_PLAN_DEENROLL(P_ESN IN VARCHAR2,P_BRAND IN VARCHAR2);


/*=======================================================================================
PROCEDURE: FIX_BILLING_ISSUES
DETAILS  : SERIES OF FIXES FOR ENROLLMENT ISSUES
=======================================================================================*/
PROCEDURE FIX_BILLING_ISSUES(P_ESN IN VARCHAR2,P_BRAND IN VARCHAR2,P_BUS_ORG IN NUMBER,P_ESN_OBJID IN VARCHAR2,P_ESN_CONTACT IN VARCHAR2,P_ESN_STATUS  IN VARCHAR2);


/*=======================================================================================
PROCEDURE: GENERAL_CHECKS
DETAILS  : SERIES OF FIXES AND CHECKS GROUPED BECAUSE IT GETS CALLED IN DIFFERENT SCENARIOS
=======================================================================================*/
PROCEDURE GENERAL_CHECKS(ESN IN VARCHAR2,ESN_OBJID IN NUMBER,ESN_STATUS  IN VARCHAR2,P_PART_NUMBER IN VARCHAR2,ESN_CONTACT IN VARCHAR2,BRAND_IN  IN VARCHAR2,P_BUS_ORG IN NUMBER,X_TECHNOLOGY  IN VARCHAR2,X_ICCID IN VARCHAR2,X_PORT_IN IN VARCHAR2,ERROR_IN  IN VARCHAR2,V_MSG OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: FIX_ESN
DETAILS  : MAIN 1052 SCRIPT. CALLS ALL FIXES
=======================================================================================*/
PROCEDURE FIX_ESN(ESN_IN IN VARCHAR2,ERROR_IN IN VARCHAR2,BRAND  IN VARCHAR2,BRAND_ID IN VARCHAR2,STATUS IN VARCHAR2,RESULTS OUT VARCHAR2);

/*=======================================================================================
PROCEDURE: CALL_1052
DETAILS  : MAIN 1052 SCRIPT. CALLS ALL FIXES. VIA THE BUTTON
=======================================================================================*/
PROCEDURE CALL_1052(ESN IN VARCHAR2,ERROR IN VARCHAR2 ,IP_USER IN VARCHAR2,RESULT  OUT VARCHAR2);


/*=======================================================================================
PROCEDURE: CALL_1052
DETAILS  : MAIN 1052 SCRIPT. CALLS ALL FIXES. VIA THE SCRIPT
=======================================================================================*/
PROCEDURE CALL_1052(ESN IN VARCHAR2,ERROR IN VARCHAR2 ,IP_USER IN VARCHAR2,IS_SCRIPT IN BOOLEAN,RESULT  OUT VARCHAR2);


END APEX_FIX_ERRORS;
/