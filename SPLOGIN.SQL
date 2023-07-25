-- *--------------------------------------------------------------*
-- *          THIS MATERIAL IS LICENSED BY PIO                    *
-- *--------------------------------------------------------------*
-- *  DESIGNED BY: GAURAV LIMBA                                   *
-- *                                                              *
-- *  SPECIFIC NAME: SPLOGIN                                      *
-- *                                                              *
-- *  PROCEDURE NAME: SPLOGIN                                     *
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
CREATE OR REPLACE PROCEDURE SPLOGIN
  (
  IN  USER_ID               CHAR(10),
  OUT SQL_MSGTXT            VARCHAR(1000),
  OUT SQL_STATUS            DECIMAL(1 , 0),
  OUT SQL_MSGID             DECIMAL(5 , 0)
  )
  LANGUAGE SQL
  RESULT SETS 1
  SPECIFIC SPLOGIN
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
  DECLARE ProgramName char(10) DEFAULT 'SPLOGIN';
  DECLARE W_SQLSTATE  CHAR(5) ;
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
    EXECUTE STMT USING USER_ID , ProgramName , SQL_STATEMENT ,
                       W_SQLSTATE, SQL_MSGTXT;
  END;

-- *****************************************************************
-- *DECLARATION END                                                *
-- *****************************************************************

--******************************************************************
--MAIN LOGIC                                                       *
--******************************************************************
  IF(trim(USER_ID) = '') THEN
    SET SQL_STATUS = 3;
    SET SQL_MSGID  = 0;
    SET SQL_MSGTXT = 'USER ID is blank';
  END IF;

  IF SQL_STATUS IS NULL THEN
    SET SQL_STATEMENT = '';
    SET SQL_STATEMENT=   'SELECT * FROM #IADTA.AIAUTCTLP '
                       ||'WHERE UPPER(AIUSER) = UPPER('''
                       ||TRIM(USER_ID)
                       ||''')'
                       ||'ORDER BY DSPL_ORDER';

    PREPARE RETURN_DATA FROM SQL_STATEMENT;
    OPEN RESULT_CURSOR;
    SET RESULT SETS WITH RETURN TO CLIENT CURSOR RESULT_CURSOR;

    SET SQL_STATUS = 0;
    SET SQL_MSGID  = 200;
    SET SQL_MSGTXT = 'SUCCESS';
  END IF;
 END;
