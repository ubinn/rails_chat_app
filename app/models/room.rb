class Room < ApplicationRecord
    has_many :admissions
    has_many :users, through: :admissions
    has_many :chats

  after_commit :create_room_notification, on: :create
  # after_commit :update_room_for_chatting, on: :update
  
  def create_room_notification
    #방만들었을때 index에서 방리스트에 append해주는 트리거
    Pusher.trigger('room', 'create', self.as_json)
  end


  def user_admit_room(user)
    # ChatRoom이 하나 만들어 지고 나면 다음 메소드를 같이 실행한다.
    # ChatRoom controller create에서 실행.
    Admission.create(user_id: user.id, room_id: self.id)
  end
  
  def user_exit_room(user)
    @thisR = Room.where(id: self.id)[0]
    if (@thisR.admissions.count < 1)
      Admission.where(user_id: user.id, room_id: self.id)[0].destroy
      p "방 폭파조건"
      @thisR.destroy
    else #방장여부 판별
      if (@thisR.master_id == user.email)
        p "if 문 들어옴"
        p @someone = User.find(@thisR.admissions.sample.user_id).email
        @thisR.update(master_id: @someone)
        
      end
      p @thisR.admissions.count
      p "방 사람들 수"
      p @thisR.master_id
      Admission.where(user_id: user.id, room_id: self.id)[0].destroy
    end
  end
  
  
  def user_ready(user)
    Admission.where(user_id: user.id, room_id: self.id).update(ready_state: true)
  end
  
  # def update_room_for_chatting
  #   p "와우"
  #   p user_id_array = self.admissions
  #   @b = []
  #   user_id_array.each do |user|
  #     @a = User.find(user.user_id).email
  #     @b.append(@a)
  #   end
  #   Pusher.trigger("room_#{self.id}","go_to_chat", self.as_json.merge({email: @b}))
  # end
  
end
