select 
    distinct entity.household_entity_id as hh_id,
    'Y' as active_campaign_strategy
from 
    cdw.f_crm_campaign_strategy strategy
    left join cdw.d_prospect_mv prospect on strategy.prospect_id = prospect.prospect_id
    left join cdw.d_entity_mv entity on prospect.entity_id = entity.entity_id
where
    strategy.active = 'true'
    
