000100190313         // **************************************************************************
000200190313        //  CUSTOMER19 READ BY NATIVE LANGUAGE (ILE RPG)
000300190313        //  CONTACTW19 ROW RETRIEVED WITH EMBEDDED SQL
000400190313        //  DETAIL REPORT LINE INCLUDES INFORMATION FROM CUSTOMER19 AND CONTACTW19
000500190313        //  SUMMARRY REPORT INFORMATION RETRIEVED WITH EMBEDDED SQL STATEMENTS
000600190314
000700190313           DCL-F PHNREPORT PRINTER OFLIND(*IN01) ;
000800190313           DCL-F CUSTOMER19 DISK(*EXT) KEYED USAGE(*INPUT)
000900190314                 RENAME(CUSTOMER19:CUSTR);
001000191115           // data structure for host variables from CONTACTW19
001001191115           DCL-DS ContactW19 EXT END-DS;
001100190314
001200191115           // Standalone fields for indicator variables
001400191115           DCL-S INDLastCDate BINDEC(4:0) ;  // for last callback date
001501191115           DCL-S INDNextCDate BINDEC(4:0) ;  // for next callback date
001600190314           DCL-S Dummy  Zoned(1);
001700190314
001800190314        //**************************************************************************
001900190314        //*                        ***   M A I N   R O U T I N E   ***
002000190314        //**************************************************************************
002100190314
002200070119                EXSR SummaryInfo;
002300190313                WRITE HEADINGS;
002400190313                READ CUSTOMER19;
002500070119                DOW NOT %EOF;
002600070119                    EXSR SQLSelect;
002601191118                    IF PHNLDC = OldestDate;
002602191118                      FLAG = '<-------';
002603191118                    ELSE;
002604191118                      FLAG = ' ';
002605191118                    ENDIF;
002700190313                    IF *IN01 = *ON;
002800190313                       Write HEADINGS;
002900190313                       *IN01 = *OFF;
003000070119                    ENDIF;
003100190313                    Write DETAIL;
003200190313                   READ CUSTOMER19;
003300070119                ENDDO;
003400190313                Write SUMMARY;
003500070119                *INLR = *ON;
003600070119                RETURN;
003700080923        //**********************************************************************
003800080923        //   S Q L S E L E C T   S U B R O U T I N E
003900080923   //   //********************************************************************
004000080923   //                  BEGSR    SQLSelect ;
004100080923   //    // A row from the contacts table that has the same customer number as t
004200190313   //    // read from the CUSTOMER19 file is retrieved to find out the last date
004300080923   //    // phone number, comments and the salesperson number.
004400080923   //
004500080923   //    //  The call back interval is added to the last date called to determin
004600080923   //    //  next date to call.  Since null values may be stored in the last dat
004700080923   //    // indicator variables are used.
004800190314
004900191118         EXEC SQL
004901191118             SELECT PHNLDC + PHNCIT DAYS, PHNLDC,
004902191118                     CstPhN, PHNCOM, CstSLN
004903191118             INTO  :NEXTCDATE :INDNEXTCDATE, :PHNLDC :INDLastCDate,
004904191118                   :CSTPHN, :PHNCOM, :CSTSLN
004905191118             FROM   BCI433LIB/CONTACTW19
004906191118             WHERE CSTNUM = :CSTNUM;
004907191118
004908191118            SELECT;
004909191118              WHEN SQLSTATE = '00000';
004910191118                Dummy = 0;
004911191118                WHEN SQLSTATE = '02000';
004912191118                  CstPhn = 'Not Found';
004913191118                  NEXTCDATE = D'9999-09-09';
004914191118                  PhnLDC = D'9999-09-09';
004915191118                  PhnCom = *All'*';
004916191118                  CstSln = *All'*';
004917191118                  When %Subst(SQLState :1 :2) = '01';//warning
004918191118                    NEXTCDATE = D'9999-09-09';
004919191118                    PhnLDC = D'9999-09-09';
004920191118                    PhnCom = *All'*';
004921191118                    CstSln = *All'*';
004922191118                    CstPhn = *All'*';
004923191118                    OTHER;                 // Success - SQL query
004924191118                      CstPhn = *ALL'*';
004925191118                      NEXTCDATE = D'9999-09-09';
004926191118                      PhnLDC =  D'9999-09-09';
004927191118                      PhnCom = *All'*';
004928191118                      CstSln = *All'*';
004929191118            ENDSL;
004930191118
004931191118           IF IndLastCdate = -1;
004932191118             CSTPHN = 'UNKNOWN DATE';
004933191118             NEXTCDATE = D'9999-09-09';
004934191118             PHNLDC = D'9999-09-09';
004935191118             ELSE;
004936191118               IF INDLASTCDATE <> 0;
004937191118                 CSTPHN = 'DATE PROBLEM';
004938191118                 NEXTCDATE = D'9999-09-09';
004939191118                 PHNLDC = D'9999-09-09';
004940191118               ENDIF;
004941191118           ENDIF;
004942191118                         ENDSR ;
007000080923        //**********************************************************************
007100080923        // S U M M A R Y I N F O   S U B R O U T I N E
007200080923        //**********************************************************************
007300080923                         BEGSR  SummaryInfo;
007400190313        //  D E T E R M I N E   T O T A L S   F O R   CONTACTW19 & CUSTOMER19
007401191115
007500191115        EXEC SQL
007600191115         SELECT Count(*) INTO :CONTACTT
007700191115         FROM BCI433Lib/ContactW19;
007800190314
007900191115         IF  (SQLCODE <> 0) OR (SQLWN0 = 'W');
008000191115             ContactT = -99999;
008100191115         ENDIF;
008300190314
008400191118        EXEC SQL
008401191118           SELECT COUNT(*) INTO :CUSTOMERT
008402191118           FROM BCI433LIB/CUSTOMER19;
008403191118
008404191118           IF (SQLCODE <> 0) OR (SQLWN0 = 'W');
008405191118                CUSTOMERT = -99999;
008407191118           ENDIF;
008408191118
009000190314        // D E T E R M I N E   N U M B E R   O F   U N K N O W N   LAST   DATE CALLED
009100190314
009200191115        EXEC SQL
009201191115             Select count(*)
009202191115             into  :UnknownT
009203191115             from  bci433lib/contactw19
009204191115             where CstLastCallDate IS NULL;
009300190314
009400191118         IF NOT (SQLCODE = 0) OR (SQLWN0 = 'W');
009401191118                UNKNOWNT  = -99999;
009402191118         ENDIF;
009403191118
010100080923        //  D E T E R M I N E   O L D E S T   &  M O S T   R E C E N T  L A S T
010200080923
010300190314
010400191118        EXEC SQL
010401191118          SELECT MIN(PHNLDC) INTO :OLDESTDATE
010402191118          FROM BCI433LIB/CONTACTW19;
010403191118
010404191118              IF (SQLCODE <> 0) OR(SQLWN0 = 'W') AND (SQLWN2 <> 'W');
010405191118                OLDESTDATE  = D'9999-09-09';
010406191118              ENDIF;
010407191118
010408191118        EXEC SQL
010409191118          SELECT MAX(PHNLDC) INTO :RECENTDATE
010410191118              FROM BCI433LIB/CONTACTW19;
010411191118
010412191118              IF (SQLCODE <> 0) OR  (SQLWN0 = 'W') AND (SQLWN2 <>  'W');
010414191118                 RECENTDATE = D'9999-09-09';
010415191118              ENDIF;
012000190314
012100080923       // D E T E R M I N E   T H E   U S E R   S E R V E R   &   T I M E S T A
012200080923
012300191115       Exec SQL
012400191115            Select User, current timestamp, current server
012401191115            INTO   :User, :TimeStamp, :Server
012500191115            FROM   SYSIBM/SYSDUMMY1;
012600190314
012700190314
012800191122                        ENDSR;
