-- *--------------------------------------------------------------*
-- *          THIS MATERIAL IS LICENSED BY PIO                    *
-- *--------------------------------------------------------------*
-- *  DESIGNED BY: GAURAV LIMBA                                   *
-- *                                                              *
-- *  SPECIFIC NAME: SPLICENKEY                                   *
-- *                                                              *
-- *  PROCEDURE NAME: SPLICENKEY                                  *
-- *                                                              *
-- *  PURPOSE:                                                    *
-- *                                                              *
-- ****************************************************************
--
-- ****************************************************************
-- *                      MOD ID                                  *
-- *    DATE    INITIALS  NUMBER      DESCRIPTION                 *
-- *  --------  --------  --------    --------------------------- *
-- ****************************************************************
CREATE OR REPLACE PROCEDURE SPLICENKEY
  (
  OUT SQL_MSGTXT            VARCHAR(1000),
  OUT SQL_STATUS            DECIMAL(1 , 0),
  OUT SQL_MSGID             DECIMAL(5 , 0)
  )
  LANGUAGE SQL
  RESULT SETS 1
  SPECIFIC SPLICENKEY
  PROGRAM TYPE SUB

--  ******************************************************************
--  * SQL COMPILE OPTIONS                                            *
--  ******************************************************************

SET OPTION  DATFMT = *ISO,
  DLYPRP = *YES,
  DBGVIEW = *SOURCE,
  USRPRF = *OWNER,
  DYNUSRPRF = *OWNER,
  COMMIT = *NONE

-- ******************************************************************
-- * SQL COMPILE OPTIONS - END                                      *
-- ******************************************************************

-- *****************************************************************
-- * START OF THE PROGRAM                                          *
-- *****************************************************************
BEGIN
-- *****************************************************************
-- *DECLATATIONS                                                   *
-- *****************************************************************
  DECLARE SQL_STATEMENT     VARCHAR(10000);
  DECLARE SQLSTMT VARCHAR(1300) DEFAULT 'INSERT INTO  GAURAVTEST.ERRORLOG(
                                         USER,
                                         PROGRAM,
                                         SQL_STATEMENT,
                                         ERROR_CODE,
                                         ERROR_MESSAGE)
                                         VALUES(?,?,?,?,?)';
  DECLARE ProgramName char(10) DEFAULT 'SPLICENKEY';
  DECLARE W_SQLSTATE  CHAR(5) ;
  DECLARE FRONTEND_USER CHAR(10) DEFAULT 'LICENSCE';
--   DECLARE SKey  CHAR(20) ;
  -- DECLARE SQL_MSGTXT  VARCHAR(1000);
  -- DECLARE SQL_STATUS  DECIMAL(1 , 0);
  -- DECLARE SQL_MSGID   DECIMAL(5 , 0);
  DECLARE SKey  CHAR(10) DEFAULT '';
-- ******************************************************************
-- * CURSOR
-- ******************************************************************
  DECLARE RESULT_CURSOR CURSOR FOR RETURN_DATA;

-- *****************************************************************
-- * GLOBAL ERROR HANDLING ROUTINE                                 *
-- * CHECK IF ANY SQL ERROR EXIST, IF SO SET OUTPUT PARMS & RETURN *
-- *****************************************************************

  DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
    GET DIAGNOSTICS EXCEPTION 1
    SQL_MSGTXT = MESSAGE_TEXT,
    W_SQLSTATE = RETURNED_SQLSTATE;
    SET SQL_MSGID  = W_SQLSTATE;
    SET SQL_STATUS = 1;
    PREPARE STMT FROM SQLSTMT;
    EXECUTE STMT USING FRONTEND_USER , ProgramName , SQL_STATEMENT ,
                       W_SQLSTATE, SQL_MSGTXT;
  END;

-- *****************************************************************
-- *DECLARATION END                                                *
-- *****************************************************************

--******************************************************************
--MAIN LOGIC                                                       *
--******************************************************************
  SET SQL_STATEMENT = '';
  SELECT TRIM(CAST(CURRENT_CHARACTER_VALUE AS CHAR(10)))
                         INTO SKey
                         FROM QSYS2.SYSTEM_VALUE_INFO
                         WHERE SYSTEM_VALUE_NAME = 'QSRLNBR';
  if(trim(SKey) = '') THEN
    SET SQL_STATUS = 1;
    SET SQL_MSGID  = 0;
    SET SQL_MSGTXT = 'FAIL';
  else
    SET SQL_STATEMENT='SELECT TRIM(CAST(CURRENT_CHARACTER_VALUE AS CHAR(10)))'
                        || ', LICENSCE_KEY,'
                        || ' KEY_GENERATOR,'
                        || ' PORT_NUMBER, CURRENT_DATE AS CURRENTDATE'
                        || ' FROM #IADTA.AILICKEYP,'
                        || ' QSYS2.SYSTEM_VALUE_INFO d'
                        || ' WHERE d.SYSTEM_VALUE_NAME = ''QSRLNBR''';

    PREPARE RETURN_DATA FROM SQL_STATEMENT;
    OPEN RESULT_CURSOR;
    SET RESULT SETS WITH RETURN TO CLIENT CURSOR RESULT_CURSOR;

    SET SQL_STATUS = 0;
    SET SQL_MSGID  = 200;
    SET SQL_MSGTXT = 'SUCCESS';
  end if;
 END;
