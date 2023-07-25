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
CREATE OR REPLACE PROCEDURE SPSRCSCAN
  (
  IN  FRONTEND_USER         VARCHAR(10),
  IN  RepoName              VARCHAR(10),
  IN  PAGE_SIZE             DECIMAL(9 , 0),
  IN  PAGE_NO               DECIMAL(9 , 0),
  IN  ExactSearch           VARCHAR(10),
  IN  SearchString          VARCHAR(10),
  IN  LibraryName           VARCHAR(10),
  IN  SourcePFName          VARCHAR(10),
  OUT SQL_MSGTXT            VARCHAR(1000),
  OUT SQL_STATUS            DECIMAL(1 , 0),
  OUT SQL_MSGID             DECIMAL(5 , 0)
  )
  LANGUAGE SQL
  RESULT SETS 1
  SPECIFIC SPSRCSCAN
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
  DECLARE W_OFFSET          DECIMAL(9 , 0);
  DECLARE W_LIMIT           VARCHAR(10000) DEFAULT '';
  DECLARE ProgramName char(10) DEFAULT 'SPSRCSCAN';
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
  SET SQL_STATEMENT='SELECT PRIMARYKEY, LIBRARY_NAME ,SOURCEPF_NAME, '
                  ||'MEMBER_NAME, SOURCE_RRN, SOURCE_SEQ, SOURCE_DATE ,'
                  ||' SOURCE_DATA, MEMBER_TYPE '
                  ||'from (SELECT IAQRPGSRC_PK as PRIMARYKEY, LIBRARY_NAME , '
                  ||'SOURCEPF_NAME, MEMBER_NAME, SOURCE_RRN, SOURCE_SEQ, '
                  ||' SOURCE_DATE, '
                  ||'SOURCE_DATA, MEMBER_TYPE FROM '
                  || TRIM(RepoName)
                  ||'.IAQRPGSRC UNION ALL SELECT IAQDDSSRC_PK as PRIMARYKEY, '
                  ||'LIBRARY_NAME , SOURCEPF_NAME, MEMBER_NAME, SOURCE_RRN, '
                  ||'SOURCE_SEQ, SOURCE_DATE , SOURCE_DATA, MEMBER_TYPE FROM '
                  || TRIM(RepoName)
                  ||'.IAQDDSSRC UNION ALL SELECT IAQCLSRC_PK as PRIMARYKEY, '
                  ||'LIBRARY_NAME ,SOURCEPF_NAME, MEMBER_NAME, SOURCE_RRN, '
                  ||'SOURCE_SEQ, SOURCE_DATE , SOURCE_DATA, '
                  ||'MEMBER_TYPE FROM '
                  || TRIM(RepoName)
                  ||'.IAQCLSRC) where UPPER(SOURCE_DATA) LIKE (CASE WHEN '''
                  ||TRIM(ExactSearch)
                  ||''' =''true'' THEN UPPER(''%% ' 
                  ||TRIM(SearchString)
                  ||' %%'') ELSE UPPER(''%%'
                  ||TRIM(SearchString)
                  ||'%%'') END)'
                  ||'ESCAPE ''!'' AND UPPER(LIBRARY_NAME)=(CASE WHEN '''
                  ||TRIM(LibraryName)
                  ||'''!='''' THEN UPPER('''
                  ||TRIM(LibraryName)
                  ||''') ELSE UPPER(LIBRARY_NAME) END) AND '
                  ||'UPPER(SOURCEPF_NAME)=(CASE WHEN '''
                  ||TRIM(SourcePFName)
                  ||'''!='''' THEN UPPER('''
                  ||TRIM(SourcePFName)
                  ||''') ELSE UPPER(SOURCEPF_NAME) END)'
                  ||' ORDER BY MEMBER_NAME';
  IF PAGE_NO < 0 THEN
    SET PAGE_NO = 0;
  END IF;

  SET W_OFFSET = PAGE_SIZE *  PAGE_NO ;
  SET W_LIMIT = 'LIMIT '||PAGE_SIZE||' OFFSET '||W_OFFSET;
  SET SQL_STATEMENT = TRIM(SQL_STATEMENT)||' '||TRIM(W_LIMIT);

  PREPARE RETURN_DATA FROM SQL_STATEMENT;
  OPEN RESULT_CURSOR;
  SET RESULT SETS WITH RETURN TO CLIENT CURSOR RESULT_CURSOR;
  SET SQL_STATUS = 0;
  SET SQL_MSGID  = 200;
  SET SQL_MSGTXT = 'SUCCESS';

 END;
