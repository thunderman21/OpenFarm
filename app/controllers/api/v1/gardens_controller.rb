class Api::V1::GardensController < Api::V1::BaseController
  skip_before_action :authenticate_from_token!, only: [:index, :show]

  def index
    render json: serialize_models(User.find(params[:user_id]).gardens,
                                  include: 'garden_crops')
  end

  def create
    @outcome = Gardens::CreateGarden.run(
      params,
      user: current_user
    )
    @user = current_user
    respond_with_mutation(:created)
  end

  def show
    garden = Garden.find(params[:id])
    if Pundit.policy(current_user, garden).show?
      render json: serialize_model(garden)
    else
      raise OpenfarmErrors::NotAuthorized
    end
  end

  def update
    @outcome = Gardens::UpdateGarden.run(params,
                                         user: current_user,
                                         id: params[:id])
    respond_with_mutation(:ok)
  end

  # def index
  #   gardens = Pundit.policy_scope(current_user, Garden)
  #   render json: { gardens: gardens }
  # end

  def destroy
    @outcome = Gardens::DestroyGarden.run(params,
                                          user: current_user)
    respond_with_mutation(:no_content)
  end
end
