class BiensController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    if params[:query].present?
      sql_query = "name ILIKE :query OR country ILIKE :query"
      @biens = policy_scope(Bien).where(sql_query, query: "%#{params[:query]}%")
    else
      @biens = policy_scope(Bien)
      # the `geocoded` scope filters only flats with coordinates (latitude & longitude)
      @markers = @biens.geocoded.map do |bien|
        {
          lat: bien.latitude,
          lng: bien.longitude,
          info_window: render_to_string(partial: "info_window", locals: { bien: bien })
        }
      end
    end
  end

  def show
    @bien = Bien.find(params[:id])
    authorize @bien
  end

  def new
    @bien = Bien.new
    authorize @bien
  end

  def create
    @bien = Bien.new(bien_params)
    @bien.save
    redirect_to biens_path(@bien)
    authorize @bien
  end

  def bien_params
    params.require(:bien).permit(:address, :loyé, :meublé, :saisonnié, :disponible, :user_id)
  end
end
