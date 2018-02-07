UPDATE charass
   SET charass_target_type='W'
 WHERE charass_target_type='WO'
   AND NOT EXISTS(SELECT 1
                    FROM charass b
                   WHERE b.charass_target_type='W'
                     AND b.charass_target_id=charass.charass_target_id
                     AND b.charass_char_id=charass.charass_char_id);

DELETE FROM charass
 WHERE charass_target_type='WO';

UPDATE charuse
   SET charuse_target_type='W'
 WHERE charuse_target_type='WO'
   AND NOT EXISTS(SELECT 1
                    FROM charuse b
                   WHERE b.charuse_target_type='W'
                     AND b.charuse_char_id=charuse.charuse_char_id);

DELETE FROM charuse
 WHERE charuse_target_type='WO';

DELETE FROM source
 WHERE source_name='WO';
