-- *--------------------------------------------------------------*
-- *          THIS MATERIAL IS LICENSED BY PIO                    *
-- *--------------------------------------------------------------*
-- *  DESIGNED BY: GAURAV LIMBA                                   *
-- *                                                              *
-- *  SPECIFIC NAME: SPFILFLDUS                                   *
-- *                                                              *
-- *  PROCEDURE NAME: SPFILFLDUS                                  *
-- *                                                              *
-- *  PURPOSE: This stored is used to get detail of the files we  *
-- *           we have and get the fields of that file on the     *
-- *           basis of that file.                                *
-- ****************************************************************
--
-- ****************************************************************
-- *                      MOD ID                                  *
-- *    DATE    INITIALS  NUMBER      DESCRIPTION                 *
-- *  --------  --------  --------    --------------------------- *
-- ****************************************************************
CREATE OR REPLACE PROCEDURE SPFILFLDUD
 (
 IN W_Repo                 CHAR(10),
 IN FRONTEND_USER          CHAR(10),
 IN W_File                 CHAR(10),
 IN W_File_Field           CHAR(10)
 )
 LANGUAGE SQL
 RESULT SETS 1
 SPECIFIC SPFILFLDUD
 --PROGRAM TYPE SUB

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
  DECLARE ProgramName char(10) DEFAULT 'SPFILFLDUD';
  DECLARE W_SQLSTATE  CHAR(5) ;
  DECLARE SQL_MSGTXT  VARCHAR(1000);
  DECLARE SQL_STATUS  DECIMAL(1 , 0);
  DECLARE SQL_MSGID   DECIMAL(5 , 0);
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
   IF W_File = '' THEN
      SET SQL_STATEMENT = '';
      SET SQL_STATEMENT =    'SELECT OBJECT_NAME AS FILE_NAME FROM '
                          || TRIM(W_Repo)
                          || '.iaobjmap where object_attr = ''LF'''
                          || ' OR object_attr = ''PF''';
   ELSEIF W_FILE <> '' AND W_File_Field = '' THEN
      SET SQL_STATEMENT = '';
      SET SQL_STATEMENT =    'SELECT WHFLDI AS FILE_FIELD_NAME FROM  '
                          || TRIM(W_Repo)
                          || '.IDSPFFD d INNER JOIN '
                          || TRIM(W_Repo)
                          || '.IAFILEDTL f ON d.WHFLDI = f.FIELD_NAME_INTERNAL'
                          || ' AND d.WHFILE =  f.DBFILENM AND '
                          || 'd.WHLIB =  f.DBLIBNAME WHERE WHFILE = '''
                          || TRIM(W_FILE)
                          || ''' AND WHFLDI <> ''''';
   END IF;

   PREPARE RETURN_DATA FROM SQL_STATEMENT;
   OPEN RESULT_CURSOR;
   SET RESULT SETS WITH RETURN TO CLIENT CURSOR RESULT_CURSOR;
 END;
