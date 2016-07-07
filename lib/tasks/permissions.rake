#All hbx_roles can view families, employers, broker_agencies, brokers and general agencies
#The convention for a privilege group 'x' is  'modify_x', or view 'view_x'

namespace :permissions do
  desc "initial build hbx permissions table"
  task initial_hbx: :environment do
    Permission.where(name: /^hbx/).delete_all   
  	p_staff=Permission.create(name: 'hbx_staff', modify_family: true, modify_employer: true, revert_application: true, list_enrollments: true,
  	  send_broker_agency_message: true, approve_broker: true, approve_ga: true,
  	  modify_admin_tabs: true, view_admin_tabs: true)
  	p_read_only=Permission.create(name: 'hbx_read_only', modify_family: false, modify_employer: false, revert_application: false, list_enrollments: true,
  	  send_broker_agency_message: false, approve_broker: false, approve_ga: false,
  	  modify_admin_tabs: false, view_admin_tabs: true)  
  	p_supervisor = Permission.create(name: 'hbx_csr_supervisor', modify_family: true, modify_employer: true, revert_application: true, list_enrollments: false,
  	  send_broker_agency_message: false, approve_broker: false, approve_ga: false,
  	  modify_admin_tabs: false, view_admin_tabs: false)
  	p_tier2 = Permission.create(name: 'hbx_csr_tier2', modify_family: true, modify_employer: true, revert_application: true, list_enrollments: false,
  	  send_broker_agency_message: false, approve_broker: false, approve_ga: false,
  	  modify_admin_tabs: false, view_admin_tabs: false)  
  	p_tier1 = Permission.create(name: 'hbx_csr_tier1', modify_family: true, modify_employer: false, revert_application: true, list_enrollments: false,
  	  send_broker_agency_message: false, approve_broker: false, approve_ga: false,
  	  modify_admin_tabs: false, view_admin_tabs: false)
  end
  task migrate_hbx: :environment do
  	permission = Permission.hbx_staff
    Person.where(hbx_staff_role: {:$exists => true}).all.each{|p|p.hbx_staff_role.update_attributes(permission_id: permission.id)}
  end
  task build_test_hbx: :environment do
    User.where(email: /themanda.*dc.gov/).delete_all
    Person.where(last_name: /^amanda\d+$/).delete_all
    u1 = FactoryGirl.create(:user, email: 'themanda.staff@dc.gov', password: 'P@55word', password_confirmation: 'P@55word', oim_id: "ex#{rand(5999999)}")
    u2 = FactoryGirl.create(:user, email: 'themanda.readonly@dc.gov', password: 'P@55word', password_confirmation: 'P@55word',  oim_id: "ex#{rand(5999999)}")
    u3 = FactoryGirl.create(:user, email: 'themanda.csr_supervisor@dc.gov', password: 'P@55word', password_confirmation: 'P@55word', oim_id: "ex#{rand(5999999)}")
    u4 = FactoryGirl.create(:user, email: 'themanda.csr_tier1@dc.gov', password: 'P@55word', password_confirmation: 'P@55word',  oim_id: "ex#{rand(5999999)}")
    u5 = FactoryGirl.create(:user, email: 'themanda.csr_tier2@dc.gov', password: 'P@55word', password_confirmation: 'P@55word', oim_id: "ex#{rand(5999999)}")
  
  	p1 = FactoryGirl.create(:person, first_name: 'staff', last_name: "amanda#{rand(1000000)}", user: u1)
  	p2 = FactoryGirl.create(:person, first_name: 'read_only', last_name: "amanda#{rand(1000000)}", user: u2)
  	p3 = FactoryGirl.create(:person, first_name: 'supervisor', last_name: "amanda#{rand(1000000)}", user: u3)
  	p4 = FactoryGirl.create(:person, first_name: 'tier1', last_name: "amanda#{rand(1000000)}", user: u4)
  	p5 = FactoryGirl.create(:person, first_name: 'tier2', last_name: "amanda#{rand(1000000)}", user: u5)
    FactoryGirl.create(:hbx_staff_role, person: p1, permission_id: Permission.hbx_staff.id)
    FactoryGirl.create(:hbx_staff_role, person: p2, permission_id: Permission.hbx_readonly.id)
    FactoryGirl.create(:hbx_staff_role, person: p3, permission_id: Permission.hbx_csr_supervisor.id)
    FactoryGirl.create(:hbx_staff_role, person: p4, permission_id: Permission.hbx_csr_tier1.id)
    FactoryGirl.create(:hbx_staff_role, person: p5, permission_id: Permission.hbx_csr_tier2.id)
  end
end
