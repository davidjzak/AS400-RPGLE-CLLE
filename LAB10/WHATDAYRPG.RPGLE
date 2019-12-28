000100191206
000101191129            Ctl-Opt DatFmt(*USA) ;
000102191129            DCL-F WhatDayDsp Workstn;
000104191129            /Copy lab10,DateProtos
000106191129            DCL-S WorkDay  Zoned(1);
000107191129            Dcl-S WorkDate Date;
000109191129            EXFMT  Input;
000110191129
000111191129            Dow not *In03;
000114191129              WorkDate = DateIn;
000115191129              WorkDay = DayOfWeek(WorkDate);
000116191129
000117191206              Result1 = 'The Day of Week is ' + %Char(WorkDay);
000118191129              Result2 = 'That''s a ' + DayName(WorkDate);
000119191204              Result3 = '' + DateWords(WorkDate);
000120191129
000121191129              *IN90 = *ON;
000122191129              Write Input;
000123191129              ExFmt OutPut;
000124191129              *IN90= *Off;
000125191129
000126191129              If not *IN03;
000127191129                ExFmt Input;
000128191129              ENDIF;
000129191129            ENDDO;
000130191129
000131191129            *INLR = *ON;
000132191129            return;
000133191129
