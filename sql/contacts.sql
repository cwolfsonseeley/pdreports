select
distinct entity.household_entity_id as hh_id,
  contact.report_id,
  contact.contact_credit_entity_id,
  contact.unit_code as contact_unit,
  contact.unit_desc as contact_unit_desc
from
  cdw.f_contact_reports_mv contact
  inner join cdw.d_entity_mv entity on contact.contact_entity_id = entity.entity_id
where
  contact.contact_date >= to_date('##date##', 'yyyymmdd')
union
select
distinct entity.household_entity_id as hh_id,
  contact.report_id,
  contact.contact_credit_entity_id,
  contact.unit_code as contact_unit,
  contact.unit_desc as contact_unit_desc
from
  cdw.f_contact_reports_mv contact
  inner join cdw.d_entity_mv entity on contact.contact_alt_entity_id = entity.entity_id
where
  contact.contact_date >= to_date('##date##', 'yyyymmdd')
