CREATE OR REPLACE PACKAGE sa."DEVICE_UTIL_PKG"
  IS

  /***************************************************************************************************/
  --$RCSfile: DEVICE_UTIL_PKG.sql,v $
  --$Revision: 1.8 $
  --$Author: vkashmire $
  --$Date: 2014/08/22 21:08:01 $
  --$ $Log: DEVICE_UTIL_PKG.sql,v $
  --$ Revision 1.8  2014/08/22 21:08:01  vkashmire
  --$ CR29489_CR22313
  --$
  --$ Revision 1.7  2014/08/01 19:28:55  jarza
  --$ CR26502 - Created a generic procedure to return device related information
  --$
  --$ Revision 1.6  2014/07/16 20:49:49  mvadlapally
  --$ CR29606  Warranty Car Connection - to determine old esn
  --$
  --$ Revision 1.5  2014/05/01 22:22:25  icanavan
  --$ added new function for car connect and tablet
  --$
  --$ Revision 1.4  2014/04/01 21:53:17  vtummalpally
  --$ Add ( function is_homealert) specification new signature
  --$
  --$ Revision 1.4  2014/03/18 11:39:27  vtummalpally
  --$ CR27269
  --$ Revision 1.3  2014/03/14 15:39:27  ymillan
  --$ CR27015
  --$
  --$ Revision 1.2  2013/10/07 14:46:01  ymillan
  --$ CR25435
  --$
  --$ Revision 1.1  2013/08/07 14:04:22  icanavan
  --$ Surepay new package
  --$
  --$
  /***************************************************************************************************/
    /*===============================================================================================*/
    /*                                                                                               */
    /* Purpose: GET_ANDROID_FUN IS TO VALIDATE ANDROID ESN                           */
    /*                0 ---> ANDROID NON-PPE                                         */
    /*                1 ---> NOT AN ANDROID                                                      */
    /*                2 ---> ANDRIOD PPE                                                         */
    /*                                                                                   */
    /* REVISIONS  DATE       WHO            PURPOSE                                                  */
    /* --------------------------------------------------------------------------------------------- */
    /*            7/25/2013 MVadlapally  Initial                             */
    /*===============================================================================================*/

FUNCTION get_smartphone_fun ( in_esn IN VARCHAR2)
  RETURN  NUMBER;
--CR25435
FUNCTION IS_HOTSPOTS(P_ESN IN VARCHAR2)
-- return 0 if ESN is hostpot device
-- return 1 if ESN is not hotspot device
-- return 2 if other errors
RETURN NUMBER;
--CR27015
FUNCTION IS_home_phone(P_ESN IN VARCHAR2)
-- return 0 if ESN is home_phone device
-- return 1 if ESN is not home_phone device
-- return 2 if other errors
-- CURSOR IS_ST_HOME_PHONE_CUR(P_ESN IN VARCHAR2) IS
RETURN NUMBER;
FUNCTION GET_ILD_PRD ( P_ESN  IN  VARCHAR2)
-- return  ILD PRODUCT CODE for ESN if not EXIST RETURN 'NOT_EXIST'
RETURN VARCHAR2;
FUNCTION GET_ILD_PRD_DEF (  V_BUS_ORG IN VARCHAR2)
--return  ILD PRODUCT CODE for default for Each Brand if not found brand return 'ERR_BRAND'
RETURN VARCHAR2;
FUNCTION IS_HOMEALERT(H_ESN IN VARCHAR2)
-- return 0 if ESN is homealert device
-- return 1 if ESN is not homealert device
-- return 2 if other errors
RETURN NUMBER ;


--CR27538
FUNCTION IS_TABLET(H_ESN IN VARCHAR2)
RETURN NUMBER ;

--CR27270
FUNCTION IS_CONNECT(H_ESN IN VARCHAR2)
RETURN NUMBER ;

-- FUNCTION TO DETERMINE OLD ESN
-- Caller: SOA - To determine old esn for Car Connection ESN's
FUNCTION sf_get_old_esn (in_esn IN ig_transaction.esn%TYPE)
RETURN VARCHAR2;

  PROCEDURE SP_GET_DEVICE_INFO(
		IN_ID					    IN	VARCHAR2,
		IN_TYPE     		        IN	VARCHAR2,
		OUT_CUR_DEVICE_INFO			OUT sys_refcursor);

  function F_REMOVE_REAL_ESN_LINK (IN_PSEUDO_ESN in varchar2 )
  return integer ;
  /*********************
  21 august 2014
  HPP BYOP CR29489
  vkashmire@tracfone.com
  function F_REMOVE_REAL_ESN_LINK : created to remove the real-esn linked to pseudo esn
  when a byop hadnset gets deactivated the link between pseudo esn and real-esn has to be removed
  **************************/

  function F_GET_REAL_ESN_FOR_PSEUDO_ESN (IN_PSEUDO_ESN in varchar2 )
  return varchar2 ;
  /**********
  21 August 2014
  HPP BYOP CR29489
  vkashmire@tracfone.com
  function f_get_byop_esn_for_pseudo_esn : created to return the pseudo ESN for the input BYOP ESN
  ************/

  function F_GET_PSEUDO_ESN_FOR_REAL_ESN (IN_BYOP_ESN in varchar2 )
  return varchar2 ;
  /**********
  21 August 2014
  HPP BYOP CR29489
  vkashmire@tracfone.com
  function f_get_pseudo_esn_for_byop_esn : created to return the pseudo ESN for the input BYOP ESN
  ************/

END;
/