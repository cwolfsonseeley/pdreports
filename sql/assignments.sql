select
distinct entity.household_entity_id as hh_id,
  prospect.prospect_name,
                           assignment.prospect_id,
                           assignment.proposal_id,
                           proposal.stage_code as proposal_stage,
                           assignment.office_code as assignment_office,
                           assignment.office_desc as assignment_office_desc,
                           assignment.assignment_entity_id
                           from
                           cdw.f_assignment_mv assignment
                           inner join cdw.d_prospect_mv prospect on assignment.prospect_id = prospect.prospect_id
                           inner join cdw.f_proposal_mv proposal on assignment.proposal_id = proposal.proposal_id
                           inner join cdw.d_entity_mv entity on prospect.entity_id = entity.entity_id
                           where
                           assignment.start_date <= to_date('##date##', 'yyyymmdd')
                           and assignment.assignment_type = 'DO'
                           and assignment.active_ind = 'Y'
                           and proposal.proposal_type = 'ORT'

union
select
  distinct entity.household_entity_id as hh_id,
  prospect.prospect_name,
  assignment.prospect_id,
  assignment.proposal_id,
  proposal.stage_code as proposal_stage,
  assignment.office_code as assignment_office,
  assignment.office_desc as assignment_office_desc,
  assignment.assignment_entity_id
from
  cdw.f_assignment_mv assignment
  inner join cdw.d_prospect_mv prospect on assignment.prospect_id = prospect.prospect_id
  inner join cdw.f_proposal_mv proposal on assignment.proposal_id = proposal.proposal_id
  inner join cdw.d_entity_mv entity on prospect.entity_id = entity.entity_id
where
  assignment.assignment_type = 'DO'
  and assignment.active_ind = 'Y'
  and assignment.proposal_id in (select
                           assignment.proposal_id
                           from
                           cdw.f_assignment_mv assignment
                           inner join cdw.d_prospect_mv prospect on assignment.prospect_id = prospect.prospect_id
                           inner join cdw.f_proposal_mv proposal on assignment.proposal_id = proposal.proposal_id
                           inner join cdw.d_entity_mv entity on prospect.entity_id = entity.entity_id
                           where
                           assignment.start_date <= to_date('##date##', 'yyyymmdd')
                           and assignment.assignment_type = 'DO'
                           and assignment.active_ind = 'Y'
                           and proposal.proposal_type = 'ORT')
