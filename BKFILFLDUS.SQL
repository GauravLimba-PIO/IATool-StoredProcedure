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
CREATE OR REPLACE PROCEDURE SPFILFLDUS
 (
 IN W_Repo                 CHAR(10),
 IN W_File                 CHAR(10),
 IN W_File_Field           CHAR(10)
 )
 LANGUAGE SQL
 RESULT SETS 1
 SPECIFIC SPFILFLDUS
 PROGRAM TYPE SUB

-- *****************************************************************
-- * START OF THE PROGRAM                                          *
-- *****************************************************************
 BEGIN
-- *****************************************************************
-- *DECLATATIONS                                                   *
-- *****************************************************************
   DECLARE SQL_STATEMENT     VARCHAR(10000);

-- ******************************************************************
-- * CURSOR
-- ******************************************************************
   DECLARE RESULT_CURSOR CURSOR FOR RETURN_DATA;
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
