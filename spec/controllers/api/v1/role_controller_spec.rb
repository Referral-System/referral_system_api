RSpec.describe Api::V1::RolesController, type: :controller do
  describe '#create' do
    context 'with valid params' do
      it 'should return created response' do
        post :create, params: { name: 'logged user' }

        expect(JSON.parse(response.body)['name']).to eq 'logged user'
        expect(response.status).to eq 201
      end
    end

    context 'with invalid params' do
      it 'should return unprocessable entity' do
        expect_any_instance_of(Role).to receive(:save).and_return false
        post :create, params: { name: 'some invalid value' }

        expect(response.status).to eq 422
      end
    end

    context 'with no params' do
      it 'should raise an error' do
        post :create, params: {}

        expect(JSON.parse(response.body)['message']).to eq 'Parameter missing'
        expect(response.status).to eq 422
      end
    end
  end
end
