select 
  distinct entity.household_entity_id as hh_id,
  assignment.assignment_entity_id as primary_manager
from 
  cdw.f_assignment_mv assignment
  inner join cdw.d_entity_mv entity  on assignment.entity_id = entity.entity_id
where
  assignment.assignment_type = 'PM'
  and assignment.active_ind = 'Y'
                           
