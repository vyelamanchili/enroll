class HealthCareServicesUsage
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :health_care_services_countable, polymorphic: true

  field :service_list, type: Array, default: []

  after_initialize :initialize_service_list

private

  def initialize_service_list

    if service_list.size == 0 
      self.service_list = [
        { service_kind: "chiropractor",           count: 0, title: "Chiropractor Care" },
        { service_kind: "er_visit",               count: 0, title: "Emergency Room Visit" },
        { service_kind: "hospitalization",        count: 0, title: "Hospitalization" },
        { service_kind: "imaging",                count: 0, title: "Imaging (MRI, CT Scan, Ultrasound)" },
        { service_kind: "lab_test",               count: 0, title: "Lab Test " },
        { service_kind: "mental_health",          count: 0, title: "Mental Health Visit" },
        { service_kind: "outpatient_non_surgery", count: 0, title: "Outpatient Non-Surgery" },
        { service_kind: "outpatient_surgery",     count: 0, title: "Outpatient Surgery" },
        { service_kind: "doctor_visit",           count: 0, title: "Primary Care Doctor Visit" },
        { service_kind: "specialist_visit",       count: 0, title: "Specialist Doctor Visit (i.e. OB/Gyn, dermatologist, eye doctor)" },
        { service_kind: "urgent_care",            count: 0, title: "Urgent Care Visit" },
        { service_kind: "checkup",                count: 0, title: "Well Visits/Checkup" },
        { service_kind: "x_ray",                  count: 0, title: "X-Ray" }
      ]
    end
  end


end
