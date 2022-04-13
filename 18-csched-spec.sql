--
alter session set nls_length_semantics = char;
--
create or replace 
PACKAGE         csched
AS
--
-- FILE NAME..: 18-csched-spec.sql
-- OBJECT NAME: csched
-- PRODUCT....: College Scheduler
-- USAGE......: The College Scheduler Package provides a sign-on interface to
--              the College Scheduler host and a data service that fulfills
--              requests for Banner data.
--
-- *****  Civitas Learning Support Helpdesk:  support@civitaslearning.com  *****
--
-- DESCRIPTION:
--
-- College Scheduler by Civitas Learning offers a web based class scheduling
-- system for student use at colleges and universities. Students can build
-- optimized class schedules that take into account their personal needs (work,
-- athletics, leisure, etc.)
-- https://www.civitaslearning.com/
--
-- *****                   CONFIDENTIAL AND PROPRIETARY                    *****
-- *****        Copyright (c) 2013 - 2021 by Civitas Learning, Inc.        *****
--
-- CSCHED was created for College Scheduler by
-- Daniel L. DeBower, Senior Software Engineer + Banner Specialist
-- College Scheduler by Civitas Learning, Inc.
-- 1501 South MoPac Expressway, Suite 100, Austin, TX  78746
-- dan.debower@civitaslearning.com
-- https://www.linkedin.com/in/daniel-debower-bb885121
--
-- Customer agrees that it shall not, without the express written consent of
-- Civitas Learning, decompile, disassemble, or reverse engineer the enclosed
-- Software, or modify, enhance, or otherwise change or supplement enclosed
-- Software, in whole or in part.  Customer agrees that it shall not sublicense
-- the enclosed Software or any alterations thereto, derivative works thereof,
-- or related materials provided by Civitas Learning to Customer hereunder.
-- Customer agrees that it shall not install, use, reproduce, market, promote,
-- sell, display, or otherwise provide the enclosed Software or any alterations
-- thereto, derivative works thereof, or related materials provided by Civitas
-- Learning to Customer hereunder to any third party for any other purpose than
-- is permitted by this License.
--
-- v8.0   (STUDENT v8.5.2)   March 11, 2013          DLD  Initial Release
-- v8.0.1 (STUDENT v8.5.2)    June 07, 2013          DLD  Revisions
--   Added Course Levels to the Schedule job with CSCHED.F_FLAT_LEVELS.
--   Added ID Obfuscation with CSCHED.F_DECRYPT_ID.
--   Added Section Attributes to the Schedule job with CSCHED.F_FLAT_SECTION_ATTR.
--   Added Course Attributes to the Schedule job with CSCHED.F_FLAT_COURSE_ATTR.
-- v8.0.1.2r4             November 07, 2013          DLD  Revisions
--   Added Section Text to the Schedule job with CSCHED.F_FLAT_SECTION_TEXT.
--   Added Course Text to the Schedule job with CSCHED.F_FLAT_COURSE_TEXT.
-- v8.0.1.2r5                  May 10, 2014          DLD  Revisions
--   Removed in-line version comments.
--   Added Alternate PIN Status to the Sign On Packet with CSCHED.F_GET_APINSTATUS.
--   Added dynamic client data to the Sign On Packet with CSCHED.F_GET_SIGNONFUNCTION.
-- v8.0.1.2r6                  May 23, 2014          DLD  Revisions
--   Added Section Fees to the Schedule Job with CSCHED.F_FLAT_FEES.
-- v8.0.1.2r6b               March 06, 2015          DLD  Patch
--   Added CSCHED.F_AUTHFILTER to implment hybrid URL/XML encoding in SQL.
-- v8.0.3                  October 19, 2015          DLD  Revisions
--   Added CSCHED.F_SCHEDULE_FILE, a manual Schedule extract for FTP.
--   Added CSCHED.P_JOB_QUEUE, a multiprocess queue for DBMS_SCHEDULER.
--   Adjusted CSCHED.P_JOB_SCHEDULE to use CSCHED.P_JOB_QUEUE.
--   Added CSCHED.F_GET_CURRICULA to return Curricula data with the Sign On Packet.
--   Added CSCHED.F_GET_OVERRIDES to return student Special Approvals, Permits,
--     and Overrides with the Sign On Packet.
--   Added the ReserveCapacity job with CSCHED.P_JOB_RESCAP and CSCHED.F_GET_RESCAP.
--   Added CSCHED.F_GET_STUATTR to return Student Attribute data with the Sign On Packet.
--   Added CSCHED.F_GET_COHORTS to return Cohort data with the Sign On Packet.
--   Added the Catalog job with CSCHED.P_JOB_CATALOG.
--   Added the TermValidation job with CSCHED.P_JOB_TERMVALIDATION.
--   Added CSCHED.F_GET_SCHEDULEFUNCTION to return the text results of the client
--     Schedule Function.
--   Added the Statistics job with CSCHED.P_JOB_STATS and CSCHED.F_GET_STATS.
--   Adjusted CSCHED.F_CLEAN_BREAK to process CLOBs and removed from spec.
--   Added CSCHED.F_FLAT_SECTION_LONG_TEXT to extract Section Descriptions.
--   Added CSCHED.F_FLAT_COURSE_LONG_TEXT to extract Course Descriptions.
-- v8.0.3.1                October 21, 2015          DLD  Revisions
--   Added CSCHED.F_GET_HOLD_DETAILS to return Hold Details with the Sign On Packet.
-- v8.0.3.2                January 05, 2017          DLD  Revisions
--   Added Course Grade Modes to the Schedule Job in
--     CSCHED.F_FLAT_COURSE_GRADE_MODES.
--   Added Instructor Name Format parameter to CSCHED.F_GET_SCHEDULE.
--   Made the error logging procedure CSCHED.P_RECORD_FAULT public.
-- v8.0.4                    April 07, 2017          DLD  Revisions
--   Added CSCHED.P_REDIRECT_ADVISOR to implement College Scheduler Advisor Mode.
-- v8.0.4.1b                   May 24, 2017          DLD  Revisions
--   Added optional TERM parameter to CSCHED.P_REDIRECT_ADVISOR.
-- v8.0.4.1e              December 20, 2017          DLD  Revisions
--   Added Section Restriction Rules to the Schedule Job with
--     CSCHED.F_FLAT_RESTRICTIONS.
--   Removed unnecessary Term parameter from CSCHED.F_GET_REGHOLD.
-- v8.0.4.1g                   May 07, 2018          DLD  Revisions
--   Added optional p_soap_body parameter to CSCHED.P_SERVICES to support
--     ORDS and MOD_OWA deployments of Self-Service Banner.
-- v8.0.4.1i               October 21, 2021          DLD  Revisions
--   Added alter session set nls_length_semantics = char.
--   Adjusted CSCHED.F_FLAT_LINKS for revised JSON format representing each
--     separate link connector as an array.
--
PROCEDURE p_record_fault(p_system             varchar2,  -- ***** AUTONOMOUS TRANSACTION *****
                         p_faultcode          number,
                         p_faultstring        varchar2,
                         p_detail             varchar2,
                         p_receiveddate       timestamp default systimestamp,
                         p_soap_body          clob      default null);
--
-- Records errors and service faults in the CSCHED_FAULT table.
--
FUNCTION f_authfilter(p_text  varchar2)
   RETURN varchar2;
--
-- Returns p_text XML AND URL encoded for transactions through the AUTH server.
-- ***** DESIGNED FOR AUTH TRANSACTIONS ONLY. DO NOT REUSE. *****
--
FUNCTION f_decrypt_id(p_obfuscated_id       varchar2)
   RETURN varchar2;
--
-- Returns decrypted Base64 AES 256bit Encrypted / Obfuscated Banner ID.
--
FUNCTION f_get_RegHold(p_pidm           number,
                       p_reg_date       date)
   RETURN varchar2;
--
-- Returns c_not_eligible_msg for fatal registration holds,
-- else returns c_eligible_msg.
--
FUNCTION f_get_APINStatus(p_pidm          number,
                          p_reg_term      varchar2)
   RETURN varchar2;
--
-- Returns c_not_eligible_msg if an Alternate PIN is required,
-- else returns c_eligible_msg.
--
FUNCTION f_get_StuStatus(p_pidm          number,
                         p_reg_term      varchar2)
   RETURN sormaud.sormaud_msg%TYPE;
--
-- Returns student registration eligibility message(s) or c_eligible_msg.
--
FUNCTION f_get_TicketStatus(p_pidm          number,
                            p_reg_term      varchar2)
   RETURN varchar2;
--
-- Returns c_eligible_msg if student's registration time ticket is open, else
-- returns c_not_eligible_msg.
--
FUNCTION f_get_overrides(p_pidm           number,
                         p_term_code      varchar2,
                         p_override_ind   varchar2)
   RETURN xmltype;
--
-- Returns student Special Approvals, Permits, and Overrides for the SignOnPacket.
--
FUNCTION f_get_Curricula(p_pidm           number,
                         p_term_code      varchar2,
                         p_Curricula_ind  varchar2)
   RETURN xmltype;
--
-- Returns student Curricula for the SignOnPacket.
--
FUNCTION f_get_stuattr(p_pidm           number,
                       p_term_code      varchar2,
                       p_stuattr_ind    varchar2)
   RETURN xmltype;
--
-- Returns Student Attributes for the SignOnPacket.
--
FUNCTION f_get_Cohorts(p_pidm           number,
                       p_term_code      varchar2,
                       p_cohort_ind     varchar2)
   RETURN xmltype;
--
-- Returns Student Cohorts for the SignOnPacket.
--
FUNCTION f_get_hold_details(p_pidm              number,
                            p_hold_details_ind  varchar2)
   RETURN xmltype;
--
-- Returns Student Hold Details for the SignOnPacket.
--
FUNCTION f_get_SignOnFunction(p_pidm            number,
                              p_SignOnFunction  varchar2)
   RETURN xmltype;
--
-- Returns XML containing the coded results of the Client Sign On Function.
--
PROCEDURE p_redirect;                                           -- WEB PROCEDURE
--
-- Redirects a Banner SSB link to the College Scheduler Service.
-- 1.  SSB requests a ticket via SSL from the College Scheduler ticket server
--     containing the user id and College Scheduler Private Key.
-- 2.  The Ticket Server replies with an XML encoded URI for the College
--     Scheduler Service.
-- 3.  If the ticket is valid, the browser will be redirected to the
--     College Scheduler Service URI encoded in the reply.
-- 4.  If the ticket is INvalid, an error page will be returned.
--
PROCEDURE p_redirect_guest;                                     -- WEB PROCEDURE
--
-- Redirects a Banner SSB link to the College Scheduler Service for a GUEST.
-- Guest sign-ons deliver only the <GuestId> without any student related detail.
--
PROCEDURE p_redirect_advisor(xyz   varchar2 default null,
                             term  varchar2 default null);      -- WEB PROCEDURE
--
-- Redirects a Banner SSB link to the College Scheduler Service for an ADVISOR.
-- Advisor sign-ons deliver the <AdvisorId> with any student related detail.
--
FUNCTION f_clean(p_text  varchar2)
   RETURN varchar2;
--
-- f_clean removes embedded Tabs, Linefeeds, and Carriage Returns from p_text.
--
FUNCTION f_flat_coursecoreqs(p_term_code  varchar2,
                             p_subj_code  varchar2,
                             p_crse_numb  varchar2)
   RETURN varchar2;
--
FUNCTION f_flat_sectioncoreqs(p_term_code  varchar2,
                              p_crn        varchar2)
   RETURN varchar2;
--
FUNCTION f_flat_links(p_term_code   varchar2,
                      p_crn         varchar2,
                      p_subj_code   varchar2,
                      p_crse_numb   varchar2,
                      p_schd_code   varchar2)
   RETURN varchar2;
--
FUNCTION f_flat_crosslists(p_term_code   varchar2,
                           p_xlst_group  varchar2,
                           p_crn         varchar2)
   RETURN varchar2;
--
FUNCTION f_flat_levels(p_subj_code  varchar2,
                       p_crse_numb  varchar2,
                       p_term_code  varchar2)
   RETURN varchar2;
--
FUNCTION f_flat_section_attr(p_term_code  varchar2,
                             p_crn        varchar2)
   RETURN varchar2;
--
FUNCTION f_flat_course_attr(p_subj_code  varchar2,
                            p_crse_numb  varchar2,
                            p_term_code  varchar2)
   RETURN varchar2;
--
FUNCTION f_flat_course_text(p_subj_code  varchar2,
                            p_crse_numb  varchar2,
                            p_term_code  varchar2)
   RETURN clob;
--
FUNCTION f_flat_fees(p_term_code  varchar2,
                     p_crn        varchar2)
   RETURN varchar2;
--
FUNCTION f_flat_course_long_text(p_subj_code  varchar2,
                                 p_crse_numb  varchar2,
                                 p_term_code  varchar2)
   RETURN clob;
--
FUNCTION f_flat_course_grade_modes(p_subj_code  varchar2,
                                   p_crse_numb  varchar2,
                                   p_term_code  varchar2)
   RETURN varchar2;
--
FUNCTION f_flat_restrictions(p_term_code  varchar2,
                             p_crn        varchar2)
   RETURN clob;
--
-- The "Flat Functions" return flattened, comma delimited lists for each
-- type of course relationship.  Functions are Public to be available in SQL.
--
PROCEDURE p_job_logs;
--
-- p_job_logs generates a fault logging report and saves the output in the
-- CSCHED_SERVICES table.  p_job_logs is executed asynchronously as a
-- dbms_scheduler job by p_job_queue.
--
FUNCTION f_get_schedulefunction(p_term_code         varchar2,
                                p_crn               varchar2,
                                p_schedulefunction  varchar2)
   RETURN varchar2;
--
-- Returns the text results of the client Schedule Function.
--
FUNCTION f_get_schedule(p_term_code               varchar2,
                        p_schedulefunction        varchar2,
                        p_instructor_name_format  varchar2)
   RETURN clob;
--
-- f_get_schedule accepts a Term Code and returns the Schedule report, tab
-- delimited, as a Character Large Object (CLOB).
--
PROCEDURE p_job_schedule;
--
-- p_job_schedule calls f_get_schedule to generate schedule data for
-- current College Scheduler terms and saves the output in the
-- CSCHED_SERVICES table.  p_job_schedule is executed asynchronously as a
-- dbms_scheduler job by p_job_queue.
--
PROCEDURE p_job_catalog;
--
-- p_job_catalog generates catalog data for the earliest enrollment term that
-- has not yet ended and saves the output in the CSCHED_SERVICES table.
-- p_job_catalog is executed asynchronously as a dbms_scheduler job by p_job_queue.
--
PROCEDURE p_job_termvalidation;
--
-- p_job_termvalidation generates term validation data from the STVTERM table
-- and saves the output in the CSCHED_SERVICES table.  p_job_termvalidation is
-- executed asynchronously as a dbms_scheduler job by p_job_queue.
--
FUNCTION f_get_stats
   RETURN clob;
--
-- f_get_stats returns College Scheduler statistics, tab delimited, as a
--   Character Large Object (CLOB).
--
PROCEDURE p_job_stats;
--
-- p_job_stats calls f_get_stats to generate College Scheduler statistics and
-- saves the output in the CSCHED_SERVICES table.  p_job_stats is executed
-- asynchronously as a dbms_scheduler job by p_job_queue.
--
FUNCTION f_schedule_file
   RETURN clob;
--
-- f_schedule_file generates Schedule data as a formatted XML extract for
-- FTP or other alternative delivery methods.
--
FUNCTION f_get_rescap(p_term_code  varchar2)
   RETURN clob;
--
-- f_get_rescap accepts a Term Code and returns the Reserve Capacity report,
-- tab delimited, as a Character Large Object (CLOB).
--
PROCEDURE p_job_rescap;
--
-- p_job_rescap calls f_get_rescap to generate Reserve Capacity data for
-- current College Scheduler terms and saves the output in the
-- CSCHED_SERVICES table.  p_job_rescap is executed asynchronously as a
-- dbms_scheduler job by p_job_queue.
--
PROCEDURE p_job_queue;
--
-- p_job_queue serially executes underlying jobs and reports ready for processing
-- in the CSCHED_SERVICES table.  p_job_queue is executed asynchronously as a
-- dbms_scheduler job.
--
PROCEDURE p_services(p_soap_body  varchar2 default null);       -- WEB PROCEDURE
--
-- p_services establishes a simple SOAP/XML messaging service within
-- Self Service Banner.  p_services responds to requests from College Scheduler
-- to communicate with Banner.
--
PROCEDURE p_addfromsearch(term_in        OWA_UTIL.ident_arr,
                          assoc_term_in  OWA_UTIL.ident_arr,
                          sel_crn        OWA_UTIL.ident_arr,
                          add_btn        OWA_UTIL.ident_arr);
--
-- p_addfromsearch wraps the Banner baseline registration procedure
-- bwckcoms.p_addfromsearch to provide registration processing to CSCHED.
--
PROCEDURE p_regs_ssb(term_in  varchar2 default null);           -- WEB PROCEDURE
--
-- p_regs_ssb calls p_regs_internal to build the p_regs "Registration Cart"
-- page.  p_regs_ssb is intended for links from within Self Service Banner.
--
PROCEDURE p_regs(term      varchar2 default null,               -- WEB PROCEDURE
                 opt       varchar2 default null);
--
-- p_regs calls p_regs_internal to build the p_regs "Registration Cart" page.
-- p_regs is intended for links from College Scheduler.
--
-- *****                   CONFIDENTIAL AND PROPRIETARY                    *****
-- *****        Copyright (c) 2013 - 2021 by Civitas Learning, Inc.        *****
--
END csched;        /* Package Spec */
--
/
--
