select 
  distinct entity_id,
  report_name
from 
  cdw.d_entity_mv
where
  person_or_org = 'P'
  and record_status_code = 'A'