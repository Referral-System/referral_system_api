RSpec.describe ' Referrals API', type: :request do
  let(:admin_role) { FactoryBot.create(:role, :role_admin) }
  let(:user_role) { FactoryBot.create(:role, :role_user) }
  let(:ta_role) { FactoryBot.create(:role, :role_ta) }
  let(:ta_user) { FactoryBot.create(:user, role_id: ta_role.id) }
  let(:regular_user) { FactoryBot.create(:user, role_id: user_role.id) }

  describe '#Index' do

    before do
      FactoryBot.create(:referral,
        referred_by: regular_user.id,
        tech_stack: 'ruby, RoR',
        ta_recruiter: ta_user.id,
        signed_date: Time.now
      )

      FactoryBot.create(:referral,
        referred_by: ta_user.id,
        linkedin_url: 'https://linkedin.com/example.2',
        tech_stack: 'ruby, RoR, ',
        ta_recruiter: ta_user.id,
        signed_date: Time.now
      )

      FactoryBot.create(:referral,
        referred_by: ta_user.id,
        linkedin_url: 'https://linkedin.com/example.3',
        tech_stack: 'ruby, RoR, ',
        ta_recruiter: ta_user.id,
        signed_date: Time.now,
        active: false
      )
    end
    context 'When call referral index endpoint' do
      it 'returns all the active referrals' do
        get '/api/v1/referrals'

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body).size).to eq(2)
      end
    end
  end
  describe '#create' do
    context 'When call referral create endpoint with valid data' do
      let(:data_referral) do
        {
          full_name: 'Daniel Haro',
          referred_by: regular_user.id,
          linkedin_url: 'https://linkedin.com/example.5',
          tech_stack: 'ruby, RoR, ',
          ta_recruiter: ta_user.id,
          email: 'example@example.com'
        }
      end

      it 'create a new referral' do
        post '/api/v1/referrals', params: data_referral

        expect(response).to have_http_status(:created)
      end
    end
  end
end
