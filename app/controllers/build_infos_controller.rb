class BuildInfosController < ApplicationController
  before_action :set_build_info, only: [:show, :edit, :update, :destroy]

  # GET /build_infos
  # GET /build_infos.json
  def index
    @build_infos = BuildInfo.all
  end

  # GET /build_infos/1
  # GET /build_infos/1.json
  def show
  end

  # GET /build_infos/new
  def new
    @build_info = BuildInfo.new
  end

  # GET /build_infos/1/edit
  def edit
  end

  # POST /build_infos
  # POST /build_infos.json
  def create
    @build_info = BuildInfo.new(build_info_params)

    respond_to do |format|
      if @build_info.save
        format.html { redirect_to @build_info, notice: 'Build info was successfully created.' }
        format.json { render :show, status: :created, location: @build_info }
      else
        format.html { render :new }
        format.json { render json: @build_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /build_infos/1
  # PATCH/PUT /build_infos/1.json
  def update
    respond_to do |format|
      if @build_info.update(build_info_params)
        format.html { redirect_to @build_info, notice: 'Build info was successfully updated.' }
        format.json { render :show, status: :ok, location: @build_info }
      else
        format.html { render :edit }
        format.json { render json: @build_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /build_infos/1
  # DELETE /build_infos/1.json
  def destroy
    @build_info.destroy
    respond_to do |format|
      format.html { redirect_to build_infos_url, notice: 'Build info was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_build_info
      @build_info = BuildInfo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def build_info_params
      params.require(:build_info).permit(:display, :colour, :time)
    end
end
