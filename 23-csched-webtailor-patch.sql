--
-- FILE NAME..: 23-csched-webtailor-patch.sql
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
--   Included explicit column lists.
-- v8.0.1.2r5                  May 10, 2014          DLD  Revisions
--   Added CSCHED.P_REDIRECT_GUEST for Guest Mode Sign-On.
--   Added LINK InfoText for CSCHED.P_REDIRECT.
-- v8.0.3                  October 19, 2015          DLD  Revisions
--   Added NOTERMS InfoText for CSCHED.P_REDIRECT.
-- v8.0.4                    April 07, 2017          DLD  Revisions
--   Added CSCHED.P_REDIRECT_ADVISOR for Advisor Mode Sign-On.
-- v8.0.4.1f              February 12, 2018          DLD  Revisions
--   Added FACULTY role to CSCHED.P_REGS supporting LOGOUT from GUEST and
--     ADVISOR Modes.
--
-- v8.0.4
Insert into WTAILOR.TWGBWMNU
  (twgbwmnu_name,twgbwmnu_desc,twgbwmnu_page_title,twgbwmnu_header,twgbwmnu_header_image,twgbwmnu_subtitle_image,twgbwmnu_top_right_image,twgbwmnu_top_left_image,twgbwmnu_bullet_image,twgbwmnu_sep_image,twgbwmnu_l_margin_width,twgbwmnu_main_text_width,twgbwmnu_r_margin_width,twgbwmnu_help_url,twgbwmnu_help_link,twgbwmnu_help_image,twgbwmnu_bgcolor,twgbwmnu_bg_image,twgbwmnu_comment,twgbwmnu_text_color,twgbwmnu_link_color,twgbwmnu_alink_color,twgbwmnu_vlink_color,twgbwmnu_back_url,twgbwmnu_back_link,twgbwmnu_back_image,twgbwmnu_back_menu_ind,twgbwmnu_module,twgbwmnu_enabled_ind,twgbwmnu_insecure_allowed_ind,twgbwmnu_activity_date,twgbwmnu_css_url,twgbwmnu_map_title,twgbwmnu_cache_override,twgbwmnu_exit_image,twgbwmnu_menu_image,twgbwmnu_source_ind,twgbwmnu_help_css,twgbwmnu_adm_access_ind)
  values
  ('csched.p_redirect_advisor','College Scheduler Redirect','College Scheduler Redirect','College Scheduler Redirect',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,'N','FAC','Y','N',sysdate,null,null,'S',null,null,'L',null,'N');
--
Insert into WTAILOR.TWGRWMRL
  (twgrwmrl_name,twgrwmrl_role,twgrwmrl_activity_date,twgrwmrl_source_ind)
  values
  ('csched.p_redirect_advisor','FACULTY',sysdate,'L');
--
-- v8.0.4.1f
Insert into WTAILOR.TWGRWMRL
  (twgrwmrl_name,twgrwmrl_role,twgrwmrl_activity_date,twgrwmrl_source_ind)
  values
  ('csched.p_regs','FACULTY',sysdate,'L');
--
COMMIT;
--
-- *****                   CONFIDENTIAL AND PROPRIETARY                    *****
-- *****        Copyright (c) 2013 - 2021 by Civitas Learning, Inc.        *****
--
