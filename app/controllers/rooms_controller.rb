class RoomsController < ApplicationController
  before_action :set_room, only: [:show, :edit, :update, :destroy, :user_exit_room, :is_user_ready, :chat, :open_chat]
  before_action :authenticate_user!, except: [:index]
  # GET /rooms
  # GET /rooms.json
  def index
    @rooms = Room.all
  end

  # GET /rooms/1
  # GET /rooms/1.json
  def show
    @room.user_admit_room(current_user) unless current_user.joined_room?(@room)
    
    respond_to do |format|
      if @room.chat_started?
        format.html { render 'chat' }
      else
        format.html { render 'show' }
      end
    end
  end

  # GET /rooms/new
  def new
    @room = Room.new
  end

  # GET /rooms/1/edit
  def edit
  end

  # POST /rooms
  # POST /rooms.json
  def create
    @room = Room.new(room_params)
    @room.master_id = current_user.email
    
    respond_to do |format|
      if @room.save
        @room.user_admit_room(current_user)
        format.html { redirect_to @room, notice: 'Room was successfully created.' }
        format.json { render :show, status: :created, location: @room }
      else
        format.html { render :new }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rooms/1
  # PATCH/PUT /rooms/1.json
  def update
    respond_to do |format|
      if @room.update(room_params)
        format.html { redirect_to @room, notice: 'Room was successfully updated.' }
        format.json { render :show, status: :ok, location: @room }
      else
        format.html { render :edit }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rooms/1
  # DELETE /rooms/1.json
  def destroy
    @room.destroy
    respond_to do |format|
      format.html { redirect_to rooms_url, notice: 'Room was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def user_exit_room
    p "컨트롤러까지는 옴"
    @room.user_exit_room(current_user)
    # @room.zero_room_delete(current_user)
    @room.update(room_state: false)
  end
  
  def is_user_ready
    if current_user.is_ready?(@room) # 현재 레디상태라면
      render js: "console.log('이미 레디상태'); location.reload();"
    else  # 현재 레디상태가 아니라면
      @room.user_ready(current_user) # 현재유저의 레디상태 바꿔주기
      render js: "console.log('레디상태로 바뀌었습니다.'); location.reload();"
      # 현재 레디한 방 외에 모든방의 레디해제
      current_user.admissions.where.not(room_id: @room.id).destroy_all
      # if 
    end
    
  end
  
  def chat
    @room_id = @room.id
    p "으쌰"
     @room.chats.create(user_id: current_user.id, message: params[:message])
  end
  
  def open_chat
    @room.update(room_state: true)
    Pusher.trigger("room_#{@room.id}", 'chat_start', {})
    render nothing: true
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room
      @room = Room.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def room_params
      params.require(:room).permit(:title, :master_id, :max_count, :admissions_count)
    end
end
