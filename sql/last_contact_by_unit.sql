select
  hh_id,
  contact_unit,
  max(contact_date) as last_unit_contact_date
from(select
distinct entity.household_entity_id as hh_id,
  contact.contact_date,
  contact.contact_credit_entity_id,
  contact.unit_code as contact_unit
from
  cdw.f_contact_reports_mv contact
  inner join cdw.d_entity_mv entity on contact.contact_entity_id = entity.entity_id
union
select
distinct entity.household_entity_id as hh_id,
  contact.contact_date,
  contact.contact_credit_entity_id,
  contact.unit_code as contact_unit
from
  cdw.f_contact_reports_mv contact
  inner join cdw.d_entity_mv entity on contact.contact_alt_entity_id = entity.entity_id
)
group by hh_id, contact_unit

