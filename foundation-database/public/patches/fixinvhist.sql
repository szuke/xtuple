UPDATE invhist
   SET invhist_qoh_after=invhist_invqty
 WHERE invhist_qoh_before=0
   AND invhist_qoh_after=0
   AND invhist_ordnumber='Summary';

UPDATE invhist
SET invhist_invqty=0.0
WHERE invhist_transtype='SC';

UPDATE invhist
   SET invhist_invqty=invhist_invqty * -1
 WHERE invhist_transtype='TS'
   AND (invhist_qoh_after-invhist_qoh_before > 0) = (invhist_invqty > 0);
