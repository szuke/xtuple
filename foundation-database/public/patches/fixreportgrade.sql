UPDATE report r1 SET report_grade=0
 WHERE r1.report_grade=1
   AND NOT EXISTS(SELECT 1
                    FROM report r2
                   WHERE r2.report_grade=0
                     AND r2.report_name=r1.report_name);
