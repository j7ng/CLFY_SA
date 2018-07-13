CREATE OR REPLACE PACKAGE BODY sa.TMO_WIFI_PKG IS
--********************************************************************************
 --$RCSfile: TMO_WIFI_PKGB.sql,v $
 --$Revision: 1.23 $
 --$Author: mdave $
 --$Date: 2018/02/01 18:54:23 $
 --$ $Log: TMO_WIFI_PKGB.sql,v $
 --$ Revision 1.23  2018/02/01 18:54:23  mdave
 --$ CR55568 minor changes
 --$
 --$ Revision 1.19  2017/04/13 21:15:39  jcheruvathoor
 --$ As part of CR47874
 --$
 --$ Revision 1.18  2016/08/25 15:27:14  tbaney
 --$ Modified logic to for carrier parent.
 --$
 --$ Revision 1.17  2016/08/19 14:23:15  tbaney
 --$ Added logic for CR44842.
 --$
 --$ Revision 1.16  2015/09/17 17:09:03  pvenkata
 --$ table_x_carrier
 --$
 --$ Revision 1.14  2015/09/16 19:45:25  PVENKATA
 --$ Added header comments for revision
 --$ CR38053 changes.
 --********************************************************************************
 --Cursor for the ESN wifi Capable.

 FUNCTION  ESN_BUSORG(IP_ESN IN VARCHAR2)  RETURN VARCHAR2
IS
 CURSOR C_ESN_WIFI (IP_ESN IN VARCHAR2)
 IS
 SELECT   PV.BUS_ORG
 FROM TABLE_PART_INST PI,TABLE_MOD_LEVEL ML,TABLE_PART_NUM PN,table_part_class PC, sa.PCPV_MV  PV
WHERE 1=1
AND PI.PART_SERIAL_NO= IP_ESN
AND PI.N_PART_INST2PART_MOD= ML.OBJID
AND ML.PART_INFO2PART_NUM=PN.OBJID
AND PN.part_num2part_class = pc.objid
AND PV.PART_CLASS =PC.NAME ;

 ESN_WIFI_REC    C_ESN_WIFI%ROWTYPE;
BEGIN
 --ESN wifi Capable.
            OPEN C_ESN_WIFI(IP_ESN);
             FETCH C_ESN_WIFI INTO ESN_WIFI_REC;
           CLOSE C_ESN_WIFI;
 RETURN ESN_WIFI_REC.BUS_ORG;
 EXCEPTION WHEN OTHERS THEN

DBMS_OUTPUT.PUT_LINE('Error Found');

END ESN_BUSORG;

 --CR55568, ATT WIFI Calling, mdave 01/20/2018. Added parent_name as input parameter for carrier validation
FUNCTION  ESN_WIFI(IP_ESN IN VARCHAR2, IP_PARENT_NAME IN VARCHAR2)  RETURN VARCHAR2
IS
 CURSOR C_ESN_WIFI (IP_ESN IN VARCHAR2)
 IS
 SELECT PV.HAS_WIFI_CALLING,PV.ATT_WIFI_CALLING
 FROM TABLE_PART_INST PI,TABLE_MOD_LEVEL ML,TABLE_PART_NUM PN,table_part_class PC, sa.PCPV_MV  PV
WHERE 1=1
AND PI.PART_SERIAL_NO= IP_ESN
AND PI.N_PART_INST2PART_MOD= ML.OBJID
AND ML.PART_INFO2PART_NUM=PN.OBJID
AND PN.part_num2part_class = pc.objid
AND PV.PART_CLASS =PC.NAME;

 ESN_WIFI_REC    C_ESN_WIFI%ROWTYPE;
BEGIN
 --ESN wifi Capable.
            OPEN C_ESN_WIFI(IP_ESN);
             FETCH C_ESN_WIFI INTO ESN_WIFI_REC;
           CLOSE C_ESN_WIFI;
 --RETURN ESN_WIFI_REC.HAS_WIFI_CALLING;
 --CR55568, ATT WIFI Calling, mdave 01/20/2018. ATT validation. Return values in sync with SOA
 IF IP_PARENT_NAME = 'ATT' THEN
		IF NVL(ESN_WIFI_REC.ATT_WIFI_CALLING,'N') = 'Y' THEN
			RETURN 'ATT_Y';
		ELSE
			RETURN 'ATT_N';
		END IF;
 ELSE
	RETURN ESN_WIFI_REC.HAS_WIFI_CALLING;

 END IF;
 EXCEPTION WHEN OTHERS THEN

	DBMS_OUTPUT.PUT_LINE('Error Found in ESN_WIFI fn call');
	RETURN NULL;
END ESN_WIFI;

FUNCTION SIM_WIFI (ip_sim IN VARCHAR2) RETURN VARCHAR2
 IS

--Cursor for the SIM wifi Capable.

 CURSOR C_SIM_WIFI (ip_sim IN VARCHAR2)
 IS
SELECT PV.HAS_WIFI_CALLING
FROM TABLE_X_SIM_INV SI ,TABLE_MOD_LEVEL ML ,TABLE_PART_NUM PN ,table_part_class PC,sa.PCPV_MV  PV
WHERE SI.X_SIM_SERIAL_NO= ip_sim
AND ML.OBJID=SI.X_SIM_INV2PART_MOD
AND ML.PART_INFO2PART_NUM= PN.OBJID
AND PN.part_num2part_class = pc.objid
AND PV.PART_CLASS =PC.NAME ;

 SIM_WIFI_REC    C_SIM_WIFI%ROWTYPE;
BEGIN

    --Sim wifi Capable.
            OPEN C_SIM_WIFI(ip_sim);
             FETCH C_SIM_WIFI INTO SIM_WIFI_REC;

         CLOSE C_SIM_WIFI;

   RETURN  SIM_WIFI_REC.HAS_WIFI_CALLING;
      EXCEPTION WHEN OTHERS THEN

DBMS_OUTPUT.PUT_LINE('Error Found in SIM WIFI Fn call');

END SIM_WIFI;

-- Changes starts as part of CR#47874
FUNCTION SIM_WIFI_128 (ip_sim IN VARCHAR2, IP_PARENT_NAME IN VARCHAR2) RETURN VARCHAR2
 IS

--Cursor for the SIM wifi Capable for 128 kb sim.

 CURSOR C_SIM_WIFI (ip_sim IN VARCHAR2)
 IS
	SELECT COUNT(1)
	FROM TABLE_X_SIM_INV SI ,TABLE_MOD_LEVEL ML ,TABLE_PART_NUM PN
	WHERE SI.X_SIM_SERIAL_NO= ip_sim
	AND ML.OBJID=SI.X_SIM_INV2PART_MOD
	AND ML.PART_INFO2PART_NUM= PN.OBJID
	AND SUBSTR(PN.PART_NUMBER,3,3) like '128' ;

 V_IS_SIM_128    NUMBER := 0;
BEGIN

    --Sim wifi Capable for 128 KB sim.
	OPEN C_SIM_WIFI(ip_sim);
	 FETCH C_SIM_WIFI INTO V_IS_SIM_128;
	CLOSE C_SIM_WIFI;

	IF V_IS_SIM_128 > 0 THEN

			IF IP_PARENT_NAME = 'ATT' THEN
				RETURN 'ATT_Y';
			ELSE
				RETURN  'Y';
			END IF;

	ELSE
			IF IP_PARENT_NAME = 'ATT' THEN
			    RETURN  'ATT_N';
			ELSE
				RETURN	'N';
			END IF;

	END IF;

    EXCEPTION WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('Error Found in SIM_WIFI_128');
RETURN NULL;
END SIM_WIFI_128;
--Changes Ends as part of CR#47874

PROCEDURE Update_insert_E911address (
                                      ip_action       in varchar2,
                                      ip_esn          in varchar2,
                                      ip_Address      in Varchar2,
                                      ip_Address2     in varchar2,
                                      ip_city         in varchar2,
                                      ip_state        in varchar2,
                                      ip_country      in varchar2,
                                      ip_zip          in  varchar2,
                                      op_errorcode    out number,
                                      op_errormessage out varchar2
                                      )
                                      AS

   l_add_objid     NUMBER := NULL;
   l_e911_objid    NUMBER := NULL;

--  Cursor
       Cursor C1_E911
         is
          Select ta.address2e911
          From X_E911_ESN  E911,TABLE_ADDRESS TA
          Where 1=1
             And E911.ESN2E911ADDRESS=TA.address2e911
             And E911.X_ESN= ip_esn;

 C1_REC C1_E911%ROWTYPE;

PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN

              IF ip_esn IS NULL
                    THEN
                      op_errorcode:=1;
                      op_errormessage:='Esn Has Null Value';
                      RETURN;

                  END IF;
            IF  upper(ip_action) NOT IN ('I','U')
				    THEN
                      op_errorcode:=1;
                      op_errormessage:='Invalid Action Type';
                      RETURN;
			  END IF;

  IF  upper(ip_action) in ('I')  THEN

            OPEN C1_E911;
           FETCH C1_E911 INTO C1_REC;
            IF C1_E911%FOUND THEN
             op_errorcode:=1;
             op_errormessage:='E911 already exist for the customer';
                RETURN;
            END IF;
           CLOSE C1_E911;
    --Insert for the X_E911_ESN
          INSERT INTO X_E911_ESN (
                                  X_ESN,
                                  ESN2E911ADDRESS
                                  )
             VALUES              (
                                 ip_esn,
                                  SEQU_E911_ESN.nextval
                                 )  RETURNING ESN2E911ADDRESS  INTO  l_e911_objid;
           DBMS_OUTPUT.PUT_LINE('Step1:');

            IF SQL%ROWCOUNT =1

               THEN
                     op_errorcode:=2;
                     op_errormessage:='X_E911_ESN  has created a record';
              END IF;

          l_add_objid := sa.seq('address');

    --Address for the E911
       INSERT INTO table_address
                         (
                         objid
                        ,address
                        ,s_address
                        ,city
                        ,s_city
                        ,state
                        ,s_state
                        ,zipcode
                       ,address_2
                       ,dev
                       ,address2time_zone
                       ,address2country
                      ,address2state_prov
                      ,update_stamp
                      ,address2e911
                      )
        VALUES       (
                       l_add_objid
                      ,ip_Address
                      ,UPPER(ip_Address)
                      ,ip_city
                      ,UPPER(ip_city)
                      ,ip_state
                      ,UPPER(ip_state)
                      ,ip_zip
                      ,UPPER(ip_Address2)
                      ,NULL
                      ,(SELECT objid FROM table_time_zone  WHERE name = 'EST') --SYSDATE ?
                      ,(SELECT objid FROM table_country  WHERE s_name = upper(ip_country))
                      ,(SELECT objid FROM table_state_prov WHERE s_name = UPPER(ip_state)
                        AND state_prov2country =(SELECT objid FROM table_country  WHERE s_name = upper(ip_country)))
                      ,SYSDATE
                     ,l_e911_objid
                     );

                        IF SQL%ROWCOUNT =1
                           THEN
                             op_errorcode:=0;
                             op_errormessage:='E911 Address created ';
                      END IF;

    COMMIT;
      DBMS_OUTPUT.PUT_LINE('Step2:');


 END IF;

  IF  upper(ip_action) in ('U')  THEN

           OPEN C1_E911;
           FETCH C1_E911 INTO C1_REC;
            IF C1_E911%NOTFOUND THEN
               DBMS_OUTPUT.PUT_LINE('There is no E911 address for the Customer');
                RETURN;
            END IF;
           CLOSE C1_E911;

             DBMS_OUTPUT.PUT_LINE('Step3:');
                        UPDATE table_address
                         SET
                                address              = NVL2(ip_Address,ip_Address,address)
                               ,s_address            = NVL2(ip_Address,UPPER(ip_Address),s_address)
                               ,city                 = NVL2(ip_city,ip_city,s_city)
                               ,s_city               = NVL2(ip_city,UPPER(ip_city),s_city)
                               ,state                = NVL2(ip_state,ip_state,state)
                               ,s_state              = NVL2(ip_state,UPPER(ip_state),state)
                               ,zipcode              = NVL2(ip_zip,ip_zip,zipcode)
                              ,address_2             = NVL2(ip_Address2,UPPER(ip_Address2),address_2)
                              ,address2country       = NVL2(ip_country,(SELECT objid FROM table_country  WHERE s_name = upper(ip_country)) ,address2country)
                             ,address2state_prov     = NVL2(ip_state,(SELECT objid FROM table_state_prov WHERE s_name = UPPER(ip_state)),address2state_prov)
                             ,update_stamp           = SYSDATE
                         WHERE address2e911 =C1_REC.address2e911;

                       IF SQL%ROWCOUNT =1
                           THEN
                             op_errorcode:=0;
                             op_errormessage:='E911 Address Updated';
                      END IF;
   COMMIT;
                DBMS_OUTPUT.PUT_LINE('Step4:');
  END IF;


 EXCEPTION

     WHEN OTHERS THEN

    op_errormessage :=  SUBSTR(sqlerrm, 1,100);

 END Update_insert_E911address;

PROCEDURE GetWifi_Eligibility(
                              ip_min               IN   VARCHAR2,
                              op_min               OUT  VARCHAR2,
                              op_esn               OUT  VARCHAR2,
                              op_addressln1        OUT  VARCHAR2,
                              op_addressln2        OUT  VARCHAR2,
                              op_city              OUT  VARCHAR2,
                              op_state             OUT  VARCHAR2,
                              op_zipcode           OUT  VARCHAR2,
                              op_esn_elg           OUT  VARCHAR2 ,
                              op_sim_elg           OUT  VARCHAR2 ,
                              op_errorcode         OUT  NUMBER ,
                              op_errormessage      OUT  VARCHAR2
                             )
                              AS
  c_parent_name    sa.table_x_parent.x_parent_name%type := NULL;

--Cursor for the E911 address.

 CURSOR C_E911(P_ESN IN VARCHAR2)
         IS
          Select ta.*
          From X_E911_ESN  E911,TABLE_ADDRESS TA
          Where 1=1
             And E911.ESN2E911ADDRESS=TA.address2e911
             And E911.X_ESN= p_esn;



--Cursor Variables


 E911_REC        C_E911%ROWTYPE;
l_esn_wifi  varchar2(30);
l_sim_wifi  varchar2(30);
--Varibles

 l_esn VARCHAR2(30);
 l_iccid VARCHAR2(30);
---CR55568, mdave, 02012018
l_parent_name varchar2(50):= NULL;
l_short_parent_name varchar2(30):= NULL;
--

BEGIN
op_esn_elg :='N' ;
op_sim_elg :='N';

 IF ip_min IS NULL
  THEN
    op_errorcode :=1;
    op_errormessage :='Min  has Null value';
  RETURN;

 END IF;

               --Get the ESN based on the min

				BEGIN
               select x_service_id INTO l_esn
			   from table_site_part
               where x_min= ip_min and part_status ='Active';
            EXCEPTION
                WHEN OTHERS THEN
               op_errorcode :=2;
               op_errormessage :='Esn Not found';
			   RETURN;
               END;

     IF l_esn IS  NULL
       THEN

       op_errorcode :=2;
       op_errormessage :='Esn Not found for the min';

      RETURN;
     END IF;

   --Sim  for the Corresponding ESN.
     BEGIN

        SELECT x_iccid INTO l_iccid
         FROM table_part_inst
          WHERE part_serial_no=l_esn;

        EXCEPTION

           WHEN OTHERS THEN
            op_errorcode :=3;
            op_errormessage :='SIM Not Availble';
     END;


   --E911 Address for the ESN.

          OPEN C_E911(l_esn);
          FETCH C_E911 INTO E911_REC;
          CLOSE C_E911;


   -- CR44842_TMO_WiFi_Calling_logic
   -- Get the parent name
   -- Only looking only for T-Mobile
   --
      BEGIN
        SELECT p.x_parent_name
          INTO c_parent_name
          FROM table_x_parent p,
               table_x_carrier_group cg,
               table_x_carrier c,
               table_part_inst pi_esn,
               table_part_inst pi_min
         WHERE 1 = 1
           AND p.objid = cg.X_CARRIER_GROUP2X_PARENT
           AND cg.objid = c.CARRIER2CARRIER_GROUP
           AND c.objid = pi_min.part_inst2carrier_mkt
           AND pi_esn.x_part_inst_status||'' = '52'
           AND pi_esn.x_iccid = l_iccid
           AND pi_esn.x_domain = 'PHONES'
           AND pi_esn.part_serial_no = l_esn
           AND pi_min.part_to_esn2part_inst = pi_esn.objid
           --AND sa.util_pkg.get_short_parent_name (x_parent_name) = 'TMO';
		   AND sa.util_pkg.get_short_parent_name (x_parent_name) IN ('TMO','ATT'); --CR55568, ATT WIFI Calling, mdave 01/20/2018

         EXCEPTION WHEN OTHERS THEN
            c_parent_name := NULL;
      END;

   --




dbms_output.put_line ( 'ph: '||l_esn);
dbms_output.put_line ( 'c_parent_name: '||c_parent_name);
        --
        -- Expecting only T-MOBILE and ATT / CINGULAR in c_parent_name.
        -- If T-MOBILE and ATT / CINGULAR THEN ACCEPT l_esn_wifi value else set N.
        -- CR44842_TMO_WiFi_Calling_logic
        --

   l_esn_wifi := 'N';

IF c_parent_name IS NOT NULL THEN
   -- It's a TMO or ATT
  -- l_esn_wifi :=ESN_WIFI(l_esn);
   --CR55568, ATT WIFI Calling, mdave 01/20/2018.
   -- added short_parent_name input parameter
   l_short_parent_name := sa.util_pkg.get_short_parent_name(c_parent_name);
   dbms_output.put_line ( 'ESN l_short_parent_name '||l_short_parent_name);
   l_esn_wifi :=ESN_WIFI(l_esn,l_short_parent_name);


END IF;

l_sim_wifi :=SIM_WIFI(l_iccid);
--Changes starts as part of CR#47874
IF c_parent_name IS NOT NULL THEN
   -- check only for TMO
   --CR55568, ATT WIFI Calling, mdave 01/20/2018.
   -- added parent_name input parameter to check for ATT carrier
     l_short_parent_name := sa.util_pkg.get_short_parent_name(c_parent_name);
	 dbms_output.put_line ( 'SIM l_short_parent_name '||l_short_parent_name);
   l_sim_wifi :=SIM_WIFI_128(l_iccid,l_short_parent_name);
END IF;
--Changes ends as part of CR#47874
dbms_output.put_line ( 'l_esn_wifi: '||l_esn_wifi);
dbms_output.put_line ( 'l_sim_wifi: '||l_sim_wifi);

        op_esn_elg     := NVL( l_esn_wifi,'N'); -- in case of ATT, return values to be ATT_Y or ATT_N for Portal/SOA to know if it's ATT
        op_sim_elg     := NVL( l_sim_wifi,'N');	-- in case of ATT, return values to be ATT_Y or ATT_N for Portal/SOA to know if it's ATT
        op_min         :=  NVL(ip_min,0);
        op_esn         :=  NVL(l_esn,0);
        op_addressln1  :=  NVL(E911_REC.s_address,'NA');
        op_addressln2  :=  NVL(E911_REC.address_2,'NA');
        op_city        :=  NVL(E911_REC.s_city,'NA');
        op_state       :=  NVL(E911_REC.s_state,'NA');
        op_zipcode     :=  NVL(E911_REC.zipcode,'NA');
        op_errorcode   :=  0;
        op_errormessage:= 'Success';


EXCEPTION

WHEN OTHERS THEN

op_errormessage :=  SUBSTR(sqlerrm, 1,100);

 END GetWifi_Eligibility;


PROCEDURE create_wifi_trans(
                           ip_transaction_id IN  NUMBER  ,
                           o_err_msg        OUT VARCHAR2
                          )
                          AS
  -- Get the ig row based on the transaction_id (pk)
  CURSOR c_get_ig IS
    SELECT *
    FROM   ig_transaction ig
    WHERE  transaction_id = ip_transaction_id
    AND    EXISTS ( SELECT 1
                        FROM   table_task tt,
                               table_x_call_trans ct
                        WHERE  tt.task_id = ig.action_item_id
                        AND    tt.x_task2x_call_trans = ct.objid
                        AND    ct.x_action_type IN ('1') -- Only for the  Activations
                      )
     AND NOT EXISTS (select * from sa.X_SOA_DEVICE_VERIFICATION  WHERE x_esn= ig.esn);


   /*  CURSOR c_get_cf ( p_rate_plan VARCHAR2,
                      p_carrier_id NUMBER ) IS
    SELECT  ca.X_MKT_SUBMKT_NAME
    FROM   table_x_carrier_features cf,
           table_x_carrier ca
    WHERE  1 = 1
    AND    cf.x_rate_plan = p_rate_plan
    AND    cf.x_feature2x_carrier = ca.objid
    AND    ca.x_carrier_id = p_carrier_id
    order by create_mform_ig_flag desc; */

 CURSOR c_get_cf(p_carrier  IN VARCHAR2 ) IS
select TC.X_MKT_SUBMKT_NAME
from  TABLE_X_CARRIER TC
where x_carrier_id = p_carrier;


 ig_rec       c_get_ig%ROWTYPE;
 cf_rec c_get_cf%ROWTYPE := NULL;  -- Record type to hold the ig transaction values to be inserted
 l_trans_id   NUMBER;

L_ORG  VARCHAR2(30);
l_min varchar2(30);
--CR55568
l_parent_name varchar2(50):= NULL;
l_short_parent_name varchar2(30):= NULL;

BEGIN

IF ip_transaction_id IS NULL THEN


 o_err_msg  := 'Transaction ID is NULL';
    -- exit process
  RETURN;
END IF;


  OPEN c_get_ig;
  FETCH c_get_ig INTO ig_rec;
    IF c_get_ig%NOTFOUND THEN

     o_err_msg  := 'ig record not found';
      CLOSE c_get_ig;
      RETURN;   -- Exit Process
    END IF;
   CLOSE c_get_ig;

  IF ig_rec.status != 'W' THEN
    o_err_msg  := 'ig status is not  W';
    -- exit process
    RETURN;
  END IF;

-- To derive parent_name from ESN, CR55568, mdave 01/29/2018
		BEGIN
		l_parent_name := sa.util_pkg.get_parent_name(to_char(ig_rec.esn));
		IF l_parent_name IS NULL THEN
			 o_err_msg  := 'NULL Parent Carrier Name';
			 RETURN;
		END IF;
		l_short_parent_name := sa.util_pkg.get_short_parent_name(l_parent_name);
		IF l_short_parent_name IS NULL THEN
			 o_err_msg  := 'NULL Parent Carrier short Name';
			 RETURN;
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
				o_err_msg := 'Error getting carrier short name ' ||SUBSTR(sqlerrm,1,100);
				RETURN;
		END;
        --ESN wifi Capable.
  IF NVL( ESN_WIFI(ig_rec.esn, l_short_parent_name) ,'N' ) in ('N','ATT_N') THEN
     o_err_msg :='ESN is NOT WIFI Capable';
      RETURN;
   END IF;

    OPEN c_get_cf(ig_rec.carrier_id);
    FETCH c_get_cf INTO cf_rec;
    CLOSE c_get_cf;

 L_ORG:=ESN_BUSORG(ig_rec.esn);


 BEGIN
  INSERT INTO sa.X_SOA_DEVICE_VERIFICATION
                                 (
                                  X_SOA_DEV_VER2IG_TRANSACTION ,
                                  X_ESN                        ,
                                  X_MIN                        ,
                                  X_CARRIER_NAME               ,
                                  X_ORG_ID                     ,
                                  X_INTERNAL_STATUS_FLAG       ,
                                  X_ACTION_TIMESTAMP
                                 )
                       VALUES   (
                                 ig_rec.transaction_id      ,
                                 ig_rec.esn                 ,
                                 ig_rec.msid                  ,
                                 cf_rec.x_mkt_submkt_name  ,
                                 NVL(L_ORG,'NA')            ,
                                'Q'                         ,
                                SYSDATE
                                 )
                                 RETURNING  X_SOA_DEV_VER2IG_TRANSACTION INTO l_trans_id;
         IF SQL%ROWCOUNT=1
             THEN
               o_err_msg :='Wifi transaction record has been created'||l_trans_id;
              END  IF;
 EXCEPTION
  WHEN OTHERS THEN
  o_err_msg := 'ERROR INSETING WIFI TRANSACTION: ' ||SUBSTR(sqlerrm,1,100);
 END;
-- added exception block and return statement. mdave, 01/20/2018
 EXCEPTION
  WHEN OTHERS THEN
  o_err_msg := 'ERROR create_wifi_trans: ' ||SUBSTR(sqlerrm,1,100);
   RETURN;
END create_wifi_trans;




PROCEDURE create_wifi_trans_wrap( ip_transaction_id IN  NUMBER  )
 IS
 O_ERR_MSG VARCHAR2(200);
BEGIN

  sa.TMO_WIFI_PKG.CREATE_WIFI_TRANS(
                                    IP_TRANSACTION_ID => ip_transaction_id,
                                    O_ERR_MSG => O_ERR_MSG
                                    );

 DBMS_OUTPUT.PUT_LINE('O_ERR_MSG = ' || O_ERR_MSG);

-- CR55568 added exception block and return statement.
  EXCEPTION
  WHEN OTHERS THEN
  o_err_msg := 'ERROR create_wifi_trans_wrap: ' ||SUBSTR(sqlerrm,1,100);
  RETURN;

END;


END TMO_WIFI_PKG;
/