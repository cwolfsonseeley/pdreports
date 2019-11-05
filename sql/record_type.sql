select
household_entity_id as hh_id,
listagg(record_type_desc, ', ') within group (order by record_type_desc) as record_types
from (
select distinct household_entity_id, record_type_desc
from cdw.d_entity_mv
)
group by household_entity_id
