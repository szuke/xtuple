-- For some reason the system Cost Elements where not set as such
UPDATE costelem SET costelem_sys = true
WHERE costelem_type IN ('Material','Direct Labor','Overhead','Machine Overhead');

