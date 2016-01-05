require 'rails_helper'

describe 'shared/_message.html.erb' do
  let(:message) {FactoryGirl.build(:message)}


  it 'should have message subject' do
    expect(message.subject).to eq("phoenix project")
  end

  it 'should pass variable to template' do
    render "shared/inboxes/message", :message => message
    expect(rendered).to match /phoenix project/
  end
  
end