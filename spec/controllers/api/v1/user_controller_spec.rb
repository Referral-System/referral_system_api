RSpec.describe Api::V1::UsersController, type: :controller do
  before do
    Role.create(:id => 1, :name => 'administrator')
    Role.create(:id => 2, :name => 'authenticated user')
  end

  describe '#create' do
    context 'with valid params' do
      it 'should return created response' do
        post :create, params: { name: 'juan', email: 'juan@test.com', role_id: 2 }

        expect(JSON.parse(response.body)['name']).to eq 'juan'
        expect(response.status).to eq 201
      end
    end

    context 'with missing param' do
      it 'should return error response' do
        post :create, params: { name: 'juan', email: 'juan@test.com' }

        expect(JSON.parse(response.body)['message']).to eq 'Error while creating a new user'
        expect(response.status).to eq 422
      end
    end

    context 'with admin role' do
      it 'should return error response' do
        post :create, params: { name: 'juan', email: 'juan@test.com', role_id: 1 }

        expect(JSON.parse(response.body)['message']).to eq 'Role not allowed'
        expect(response.status).to eq 403
      end
    end
  end

  describe '#show' do
    context 'with non-existent ID' do
      it 'should return error response' do
        get :show, params: { id: 1 }

        expect(JSON.parse(response.body)['message']).to eq 'Record not found'
        expect(response.status).to eq 404
      end
    end

    context 'with invalid parameters' do
      it 'should return error response' do
        get :show, params: { id: 'abc' }

        expect(JSON.parse(response.body)['message']).to eq 'Invalid parameter'
        expect(response.status).to eq 422
      end
    end
  end
end
