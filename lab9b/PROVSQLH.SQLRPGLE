000100191208       //**************************************************************************
000200191105       //* THIS PROGRAM USES A CURSOR TO LOAD A TEMPORARY RESULT TABLE FROM 3
000300191105       //* SEPARATE TABLES, ONTARIO, QUEBEC AND MANITOBA. A NUMBER IS PASSED
000400191105       //* TO THE PROGRAM TO DETERMINE WHICH RECORDS ARE INLCUDED FROM THE 3 TABLES
000600190313       //**************************************************************************
000700190313           DCL-F PROVREPORT PRINTER OFLIND(*IN01) ;
000800190313           DCL-S ProvinceH    Char(10);
000900190313           DCL-S EndOfFile    IND;
001000190313           DCL-S TotalRecords PACKED(5:0) ;
001100190315             // LowLimit is passed to the program
001200191208               DCL-PI Main extpgm('TPRSQLH');
001201191208                 Lowlimit packed(15:5);
001202191208               END-PI;
001300190315
001400190315
001401190315             // All Host Variables available under a single name
001500190315
001501191208              DCL-DS CustomerRecord;
001502191208                Province char(10);
001503191208                CustId char(6);
001504191208                FullName char(31);
001505191208                City char(20);
001506191208                Purchase packed(7:2);
001511191208              End-Ds CustomerRecord;
001512190315
002200191208
002300070123     C/EJECT
002400070123     C**************************************************************************
002500070123     C*                        ***   M A I N   R O U T I N E   ***
002600070123     C**************************************************************************
002700070118      /FREE
002800100309                EXSR PrepareFiles;
002900190313                Write Title;
003000190313                Write HEADINGS;
003100100309                EXSR GetRow;
003200190313                Write NewProv;
003300070209                ProvinceH = Province;
003400070202                DOW NOT EndOfFile;
003500190313                    IF *IN01 = *ON;
003600190313                        Write Title;
003700190313                        Write HEADINGS;
003800190313                       *IN01 = *OFF;
003900070209                    ENDIF;
003901190315                    // Province may change
003902191208                      IF (ProvinceH = Province);
003903191208                           Write Detail;
003904191208                      ELSE;
003905191208                        ProvinceH = Province;
003906191208                        Write Totals;
003907191208                        TOTALPURCH = 0;
003908191208                         Write newprov;
003909191208                         write detail;
003910191208                      ENDIF;
003911190315
003912190315
003913190315
003914190315
004000190315
004900190313                    TotalPurch     = TotalPurch     + Purchase;
005000070202                    TotalRecords= TotalRecords + 1;
005100100309                    EXSR GetRow;
005200070119                ENDDO;
005300190313                Write Totals;
005400070202                EXSR   WRAPUP;
005500190313                Write UnderLimit;
005600070119                *INLR = *ON;
005700070119                RETURN;
005800100309        //**********************************************************************
005900100309        // O P E N F I L E S   S U B R O U T I N E
006000100309        //**********************************************************************
006100100309         BEGSR  PrepareFiles;
006200190315        // S E T   U P   T H E   T E M P O R A R Y   R E S U L T  STRUCTURE
006300191208               EXEC SQL
006301191208                 Declare allprovcursor  Cursor
006302191208                      For
006305191208                       Select CustId, trim(fname) || ' ' || lname,
006306191208                         city, purchase, 'Ontario' as province
006308191208                         from bci433lib/Ontario
006309191208                         where purchase >  LowLimit
006310191208                 Union ALl
006311191208                     Select CustId, trim(fname) ||  ' ' || lname as FullName,
006312191208                         city, purchase, 'Quebec' as province
006313191208                         from bci433lib/Quebec
006314191208                          where purchase > LowLimit
006315191208                Union ALl
006316191208                   Select CustId, trim(fname) || ' ' || lname as FullName,
006317191208                         city, purchase, 'Manitoba' as province
006318191208                         from bci433lib/Manitoba
006319191208                          where purchase >  LowLimit;
006339190315
006346190315
008500100309        // A   T E M P O R A R Y   R E S U L T   T A B L E   I S   C R E A T E D
009300100309
009301191208              Exec SQL
009302191208                Open AllProvCursor;
009303191208               IF (SQLCODE <> 0) OR (SQLWN0 = 'W');
009304191208                    EndOfFile = *ON;
009305191208              ENDIF;
009306190315
009307190315
009308190315
009309190315
009310190315
009400191208          ENDSR;
009500100309        //**********************************************************************
009600100309        //   G E T     R O W    S U B R O U T I N E
009700100309        //**********************************************************************
009800100309            BEGSR     GETROW;
010800191208                  EXEC SQL
010801191208                    Fetch Next
010802191208                       From AllProvCursor
010803191208                          Into :CustomerRecord;
010805191208                         If (SQLCode = 0) Or (SQLWN0 = 'W');
010806191208                           EndOfFile = *On;
010807191208                         ENDIF;
010900191208            ENDSR;
011000100309        //**********************************************************************
011100100309        // W R A P U P     S U B R O U T I N E
011200100309        //**********************************************************************
011300100309           BEGSR WRAPUP;
011301191208                EXEC SQL
011302191208                Close AllProvCursor;
011303191208                //check for error
011304191208                   IF SQLCODE <> 0 OR SQLWN0 = 'W';
011305191208                   EndOfFile = *ON;
011306191208                   ENDIF;
011307191208
011308191208
011309191208            EXEC SQL
011310191208            SELECT COUNT(*) INTO :ONTTOTAL FROM BCI433LIB/ONTARIO
011311191208              WHERE PURChase <= LOWLIMIT;
011312191208              IF (SQLCODE <> 0) OR (SQLWN0 = 'W');
011313191208              ENDOFFILE = *ON;
011314191208            ENDIF;
011315191208
011316191208
011317191208           EXEC SQL
011318191208             SELECT COUNT(*) INTO QUETOTAL FROM BCI433LIB/QUEBEC
011319191208              Where Purchase <= Lowlimit;
011320191208           IF (SQLCODE <> 0) OR (SQLWN0 = 'W');
011321191208             ENDOFFILE = *On;
011322191208           ENDIF;
011323191208
011324191208           EXEC SQL
011325191208             SElECT COUNT(*) INTO :MANTOTAL
011326191208               FROM BCI433LIB/MANITOBA
011327191208             WHERE PURCHASE <= LOWLIMIT;
011328191208           IF (SQLCODE <> 0) OR (SQLWN0 = 'W');
011329191208             endOFFILE = *ON;
011330191208           ENDIF;
014600100309          ENDSR;
014601190315
014602190315
014603190315
014604190315
014605190315
014606190315
014607190315
014608190315
014609190315
014610190315
014611190315
014612190315
014613190315
014614190315
014615190315
