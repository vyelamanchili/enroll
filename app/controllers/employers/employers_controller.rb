class Employers::EmployersController < ApplicationController

  def redirect_to_new
    redirect_to new_employers_employer_profile_path
  end

end