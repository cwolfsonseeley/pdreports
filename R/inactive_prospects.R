#' Inactive Prospects Report
#'
#' Output list of assigned prospects who have not been contacted in the last year
#'
#' @examples
#' ## run reports as of today
#' inactive_prospects()
#'
#' @export


inactive_prospects <- function() {
  today <- Sys.Date()
  date <- today - lubridate::years(1)
  date <- format(date, "%Y%m%d")
  
  mgo_assignments_query <- getcdw::parameterize_template("R:/Prospect Development/Prospect Analysis/pdreports/sql/assignments.sql")
  mgo_assignments <- dplyr::distinct(getcdw::get_cdw(mgo_assignments_query(date = date)))
  
  contacts_query <- getcdw::parameterize_template("R:/Prospect Development/Prospect Analysis/pdreports/sql/contacts.sql")
  contacts <- dplyr::distinct(getcdw::get_cdw(contacts_query(date = date)))
  
  assignments_with_contacts <- mgo_assignments %>%
    left_join(contacts, by = "hh_id")
  
  assignments_with_contacts <- assignments_with_contacts %>%
    mutate(contacted_by_do = ifelse(assignment_entity_id == contact_credit_entity_id, 1, 0)) %>%
    mutate(contacted_by_unit = ifelse(assignment_office == contact_unit, 1, 0)) %>%
    mutate(contacted_by_do = ifelse(is.na(contacted_by_do), 0, contacted_by_do)) %>%
    mutate(contacted_by_unit = ifelse(is.na(contacted_by_unit), 0, contacted_by_unit))
  
  proposals <- assignments_with_contacts %>%
    group_by(proposal_id) %>%
    summarise(contacted_by_proposal_assignment = max(contacted_by_do),
              contacted_by_unit = max(contacted_by_unit))
  
  assignments_with_contacts <- assignments_with_contacts %>%
    left_join(proposals, by = "proposal_id") %>%
    mutate(contacted_by_unit = contacted_by_unit.y)
  
  inactive_prospects <- assignments_with_contacts %>%
    select(hh_id, proposal_id, contacted_by_proposal_assignment, contacted_by_unit) %>%
    distinct %>%
    filter(contacted_by_proposal_assignment == 0, contacted_by_unit == 0) %>%
    select(hh_id, proposal_id)
  
  last_unit_contact <- getcdw::get_cdw("R:/Prospect Development/Prospect Analysis/pdreports/sql/last_contact_by_unit.sql") %>% distinct
  last_mgo_contact <- getcdw::get_cdw("R:/Prospect Development/Prospect Analysis/pdreports/sql/last_contact_by_do.sql")
  primary_manager <- getcdw::get_cdw("R:/Prospect Development/Prospect Analysis/pdreports/sql/primary_manager.sql")
  record_type <- getcdw::get_cdw("R:/Prospect Development/Prospect Analysis/pdreports/sql/record_type.sql")
  mgo_names <- getcdw::get_cdw("R:/Prospect Development/Prospect Analysis/pdreports/sql/mg_names.sql")
  
  inactive_prospects <- inactive_prospects %>%
    left_join(mgo_assignments, by = "proposal_id") %>%
    mutate(hh_id = hh_id.x) %>%
    select(hh_id, prospect_name, proposal_id, proposal_stage, assignment_office, assignment_office_desc, assignment_entity_id) %>%
    distinct %>%
    left_join(last_mgo_contact, by = c("hh_id" = "hh_id", "assignment_entity_id" = "contact_credit_entity_id")) %>%
    left_join(last_unit_contact, by = c("hh_id" = "hh_id", "assignment_office" = "contact_unit"))
  
  last_assignment_contact <- inactive_prospects %>%
    group_by(proposal_id) %>%
    summarise(last_assignment_contact_date = max(last_fundraiser_contact_date))
  
  inactive_prospects <- inactive_prospects %>%
    left_join(last_assignment_contact, by = "proposal_id") %>%
    left_join(primary_manager, by = "hh_id") %>%
    left_join(record_type, by = "hh_id") %>%
    left_join(mgo_names, by = c("assignment_entity_id" = "entity_id")) %>%
    mutate(assignment_name = report_name) %>%
    select(-report_name) %>%
    left_join(mgo_names, by = c("primary_manager" = "entity_id")) %>%
    mutate(primary_manager_name = report_name) %>%
    select(hh_id, prospect_name, record_types, proposal_id, proposal_stage, assignment_name, assignment_office_desc, primary_manager_name, last_fundraiser_contact_date, last_assignment_contact_date, last_unit_contact_date) %>%
    distinct
  
  report_title <- paste0("inactive_prospects", format(today, "%Y%m%d"), ".csv")
  
  write.csv(inactive_prospects, report_title, row.names = FALSE)
  
}