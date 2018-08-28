UPDATE checkitem
   SET checkitem_curr_rate=CASE WHEN checkitem_apopen_id IS NOT NULL
                                THEN (SELECT apopen_curr_rate
                                        FROM apopen
                                       WHERE apopen_id=checkitem_apopen_id)
                                WHEN checkitem_aropen_id IS NOT NULL
                                THEN (SELECT aropen_curr_rate
                                        FROM aropen
                                       WHERE aropen_id=checkitem_aropen_id)
                                ELSE NULL
                                 END;
