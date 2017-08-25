DO $$
DECLARE
  _r RECORD;

BEGIN
  FOR _r IN SELECT flcol_id, flcol_name
            FROM flcol
            LEFT OUTER JOIN report ON flcol_report_id=report_id
            WHERE report_id IS NULL
  LOOP
    IF(_r.flcol_name IN ('Current', 'Month')) THEN
      UPDATE flcol SET flcol_report_id=(SELECT report_id
                                        FROM report
                                        WHERE report_name='FinancialReportMonth'
                                        LIMIT 1)
      WHERE flcol_id=_r.flcol_id;
    ELSIF(_r.flcol_name IN ('Current, Budget', 'Month, Budget')) THEN
      UPDATE flcol SET flcol_report_id=(SELECT report_id
                                        FROM report
                                        WHERE report_name='FinancialReportMonthBudget'
                                        LIMIT 1)
      WHERE flcol_id=_r.flcol_id;
    ELSIF(_r.flcol_name IN ('Current, Prior Month', 'Current, Prior Period', 'Current, Year Ago', 'Month, Prior Month', 'Month, Prior Year Month')) THEN
      UPDATE flcol SET flcol_report_id=(SELECT report_id
                                        FROM report
                                        WHERE report_name='FinancialReportMonthPriorMonth'                                  
                                        LIMIT 1)
      WHERE flcol_id=_r.flcol_id;
    ELSIF(_r.flcol_name IN ('Current, Prior Quarter')) THEN
      UPDATE flcol SET flcol_report_id=(SELECT report_id
                                        FROM report
                                        WHERE report_name='FinancialReportMonthPriorQuarter'                                  
                                        LIMIT 1)
      WHERE flcol_id=_r.flcol_id;
    ELSIF(_r.flcol_name IN ('Current, Prior Year')) THEN
      UPDATE flcol SET flcol_report_id=(SELECT report_id
                                        FROM report
                                        WHERE report_name='FinancialReportMonthPriorYear'                                  
                                        LIMIT 1)
      WHERE flcol_id=_r.flcol_id;
    ELSIF(_r.flcol_name IN ('Month, QTD')) THEN
      UPDATE flcol SET flcol_report_id=(SELECT report_id
                                        FROM report
                                        WHERE report_name='FinancialReportMonthQuarter'                                  
                                        LIMIT 1)
      WHERE flcol_id=_r.flcol_id;
    ELSIF(_r.flcol_name IN ('Current Period, YTD', 'Month, YTD')) THEN
      UPDATE flcol SET flcol_report_id=(SELECT report_id
                                        FROM report
                                        WHERE report_name='FinancialReportMonthYear'                                  
                                        LIMIT 1)
      WHERE flcol_id=_r.flcol_id;
    ELSIF(_r.flcol_name IN ('QTD')) THEN
      UPDATE flcol SET flcol_report_id=(SELECT report_id
                                        FROM report
                                        WHERE report_name='FinancialReportQuarter'                                  
                                        LIMIT 1)
      WHERE flcol_id=_r.flcol_id;
    ELSIF(_r.flcol_name IN ('QTD, Budget')) THEN
      UPDATE flcol SET flcol_report_id=(SELECT report_id
                                        FROM report
                                        WHERE report_name='FinancialReportQuarterBudget'                                  
                                        LIMIT 1)
      WHERE flcol_id=_r.flcol_id;
    ELSIF(_r.flcol_name IN ('Current Quarter, Prior Year Quarter', 'QTD, Prior Quarter', 'QTD, Prior Year Quarter')) THEN
      UPDATE flcol SET flcol_report_id=(SELECT report_id
                                        FROM report
                                        WHERE report_name='FinancialReportQuarterPriorQuarter'                                  
                                        LIMIT 1)
      WHERE flcol_id=_r.flcol_id;
    ELSIF(_r.flcol_name IN ('YTD')) THEN
      UPDATE flcol SET flcol_report_id=(SELECT report_id
                                        FROM report
                                        WHERE report_name='FinancialReportYear'                                  
                                        LIMIT 1)
      WHERE flcol_id=_r.flcol_id;
    ELSIF(_r.flcol_name IN ('YTD, Budget')) THEN
      UPDATE flcol SET flcol_report_id=(SELECT report_id
                                        FROM report
                                        WHERE report_name='FinancialReportYearBudget'                                  
                                        LIMIT 1)
      WHERE flcol_id=_r.flcol_id;
    ELSIF(_r.flcol_name IN ('YTD, Prior Full Year', 'YTD, Prior Year YTD')) THEN
      UPDATE flcol SET flcol_report_id=(SELECT report_id
                                        FROM report
                                        WHERE report_name='FinancialReportYearPriorYear'                                  
                                        LIMIT 1)
      WHERE flcol_id=_r.flcol_id;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;
