require 'rails_helper'

describe ConsumerRole, dbclean: :after_each do
  it { should delegate_method(:hbx_id).to :person }
  it { should delegate_method(:ssn).to :person }
  it { should delegate_method(:no_ssn).to :person}
  it { should delegate_method(:dob).to :person }
  it { should delegate_method(:gender).to :person }

  it { should delegate_method(:is_incarcerated).to :person }

  it { should delegate_method(:race).to :person }
  it { should delegate_method(:ethnicity).to :person }
  it { should delegate_method(:is_disabled).to :person }

  it { should validate_presence_of :gender }
  it { should validate_presence_of :dob }

  let(:address)       {FactoryGirl.build(:address)}
  let(:saved_person)  {FactoryGirl.create(:person, gender: "male", dob: "10/10/1974", ssn: "123456789")}
  let(:saved_person_no_ssn)  {FactoryGirl.create(:person, gender: "male", dob: "10/10/1974", ssn: "", no_ssn: '1')}
  let(:saved_person_no_ssn_invalid)  {FactoryGirl.create(:person, gender: "male", dob: "10/10/1974", ssn: "", no_ssn: '0')}
  let(:is_applicant)          { true }
  let(:citizen_error_message) { "test citizen_status is not a valid citizen status" }

  describe ".new" do
    let(:valid_params) do
      {
        is_applicant: is_applicant,
        person: saved_person
      }
    end

    context "with no person" do
      let(:params) {valid_params.except(:person)}

      it "should raise" do
        expect(ConsumerRole.new(**params).valid?).to be_falsey
      end
    end

    context "with all valid arguments" do
      let(:consumer_role) { saved_person.build_consumer_role(valid_params) }

      it "should save" do
        expect(consumer_role.save).to be_truthy
      end

      context "and it is saved" do
        before do
          consumer_role.save
        end

        it "should be findable" do
          expect(ConsumerRole.find(consumer_role.id).id).to eq consumer_role.id
        end

        it "should have a state of verifications_pending" do
          expect(consumer_role.aasm_state).to eq "verifications_pending"
        end
      end
    end

    context "with all valid arguments including no ssn" do
      let(:consumer_role) { saved_person_no_ssn.build_consumer_role(valid_params) }

      it "should save" do
        expect(consumer_role.save).to be_truthy
      end

      context "and it is saved" do
        before do
          consumer_role.save
        end

        it "should be findable" do
          expect(ConsumerRole.find(consumer_role.id).id).to eq consumer_role.id
        end

        it "should have a state of verifications_pending" do
          expect(consumer_role.aasm_state).to eq "verifications_pending"
        end
      end
    end
  end
end

describe "#find_document" do
  let(:consumer_role) {ConsumerRole.new}
  context "consumer role does not have any vlp_documents" do
    it "it creates and returns an empty document of given subject" do
      doc = consumer_role.find_document("Certificate of Citizenship")
      expect(doc).to be_a_kind_of(VlpDocument)
      expect(doc.subject).to eq("Certificate of Citizenship")
    end
  end

  context "consumer role has a vlp_document" do
    it "it returns the document" do
      document = consumer_role.vlp_documents.build({subject: "Certificate of Citizenship"})
      found_document = consumer_role.find_document("Certificate of Citizenship")
      expect(found_document).to be_a_kind_of(VlpDocument)
      expect(found_document).to eq(document)
      expect(found_document.subject).to eq("Certificate of Citizenship")
    end
  end
end

describe "#find_vlp_document_by_key" do
  let(:person) {Person.new}
  let(:consumer_role) {ConsumerRole.new({person:person})}
  let(:key) {"sample-key"}
  let(:vlp_document) {VlpDocument.new({subject: "Certificate of Citizenship", identifier:"urn:openhbx:terms:v1:file_storage:s3:bucket:bucket_name##{key}"})}

  context "has a vlp_document without a file uploaded" do
    before do
      consumer_role.vlp_documents.build({subject: "Certificate of Citizenship"})
    end

    it "return no document" do
      found_document = consumer_role.find_vlp_document_by_key(key)
      expect(found_document).to be_nil
    end
  end

  context "has a vlp_document with a file uploaded" do
    before do
      consumer_role.vlp_documents << vlp_document
    end

    it "returns vlp_document document" do
      found_document = consumer_role.find_vlp_document_by_key(key)
      expect(found_document).to eql(vlp_document)
    end
  end
end

describe "#build_nested_models_for_person" do
  let(:person) {FactoryGirl.create(:person)}
  let(:consumer_role) {ConsumerRole.new}

  before do
    allow(consumer_role).to receive(:person).and_return person
    consumer_role.build_nested_models_for_person
  end

  it "should get home and mailing address" do
    expect(person.addresses.map(&:kind)).to include "home"
    expect(person.addresses.map(&:kind)).to include 'mailing'
  end

  it "should get home and mobile phone" do
    expect(person.phones.map(&:kind)).to include "home"
    expect(person.phones.map(&:kind)).to include "mobile"
  end

  it "should get emails" do
    Email::KINDS.each do |kind|
      expect(person.emails.map(&:kind)).to include kind
    end
  end
end

describe "#latest_active_tax_household_with_year" do
  include_context "BradyBunchAfterAll"
  before :all do
    create_tax_household_for_mikes_family
    @consumer_role = mike.consumer_role
    @taxhouhold = mikes_family.latest_household.tax_households.last
  end

  it "should rerturn active taxhousehold of this year" do
    expect(@consumer_role.latest_active_tax_household_with_year(TimeKeeper.date_of_record.year)).to eq @taxhouhold
  end

  it "should rerturn nil when can not found taxhousehold" do
    expect(ConsumerRole.new.latest_active_tax_household_with_year(TimeKeeper.date_of_record.year)).to eq nil
  end
end

context "Verification process and notices" do
  let(:person) { FactoryGirl.create(:person, :with_consumer_role) }
  let(:consumer) { person.consumer_role }
  verification_types = [ :ssn, :citizenship, :immigration ]
  verification_states = [ :pending, :outstanding, :verified ]
  describe "#has_docs_for_type?" do
    before do
      consumer.vlp_documents=[]
    end
    context "vlp exist but document is NOT uploaded" do
      it "returns false for vlp doc without uploaded copy" do
        consumer.vlp_documents << FactoryGirl.build(:vlp_document, :identifier => nil )
        expect(consumer.has_docs_for_type?("Citizenship")).to be_falsey
      end
      it "returns false for Immigration type" do
        consumer.vlp_documents << FactoryGirl.build(:vlp_document, :identifier => nil, :verification_type  => "Immigration type")
        expect(consumer.has_docs_for_type?("Immigration type")).to be_falsey
      end
    end
    context "vlp with uploaded copy" do
      it "returns true if person has uploaded documents for this type" do
        consumer.vlp_documents << FactoryGirl.build(:vlp_document, :identifier => "identifier", :verification_type  => "Citizenship")
        expect(consumer.has_docs_for_type?("Citizenship")).to be_truthy
      end
      it "returns false if person has NO documents for this type" do
        consumer.vlp_documents << FactoryGirl.build(:vlp_document, :identifier => "identifier", :verification_type  => "Immigration type")
        expect(consumer.has_docs_for_type?("Immigration type")).to be_truthy
      end
    end
  end
  describe "#ssn_applied?" do
    it "returns true if person has SSN verification type" do
      expect(consumer.ssn_applied?).to be_truthy
    end
    it "returns false if person has NO SSN verification type" do
      person.ssn = nil
      expect(consumer.ssn_applied?).to be_falsey
    end
  end
  describe "#citizenship_applied?" do
    it "returns true if person has Citizenship verification type" do
      expect(consumer.citizenship_applied?).to be_truthy
    end
    it "returns false if person has NO Citizenship verification type" do
      person.us_citizen = nil
      expect(consumer.citizenship_applied?).to be_falsey
    end
  end
  describe "#immigration_applied?" do
    it "returns true if person has Immigration verification type" do
      person.us_citizen = nil
      expect(consumer.immigration_applied?).to be_truthy
    end
    it "returns false if person has NO Immigration verification type" do
      person.us_citizen = true
      expect(consumer.immigration_applied?).to be_falsey
    end
  end

  verification_types.each do |type|
    v_type = "Social Security Number" if type == :ssn
    v_type = 'Citizenship' if type == :citizenship
    v_type = 'Immigration status' if type == :immigration

    describe "#{type}_verified?" do
      verification_states.each do |state|
        it "returns #{ state == :verified } if #{type} has #{state} state" do
          consumer.aasm("#{type}_state").current_state = state
          expect(consumer.send("#{type}_verified?")).to eq state == :verified
        end
      end
    end

    describe "#record_transition_info for #{type}" do
      let(:args) { OpenStruct.new({:verification_type => v_type, :authority => "hbx", :update_reason => "#{type} in Curam"}) }
      it "updates #{type}_update_info attribute" do
        consumer.record_transition_info(args)
        expect(consumer.send("#{type}_update_info")).to be_a Hash
        expect(consumer.send("#{type}_update_info")).to eq ({ :authority => "hbx", :update_reason => "#{type} in Curam" })
      end
    end

    describe "#update_type (#{v_type})" do
      it "moves #{v_type} verification type to verified status with proper info records" do
        consumer.update_type(v_type, "Curam")
        expect(consumer.aasm("#{type}_state").current_state).to eq :verified
      end
    end
  end

  describe "#all_types_verified?" do
    it "returns true if all types are verified" do
      consumer.aasm(:ssn_state).current_state = :verified
      consumer.aasm(:citizenship_state).current_state = :verified
      expect(consumer.all_types_verified?).to be_truthy
    end
    it "returns false if any type is not verified" do
      expect(consumer.all_types_verified?).to be_falsey
    end
  end
end

