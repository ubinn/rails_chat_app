class Room < ApplicationRecord
    has_many :admissions
    has_many :users, through: :admissions
    has_many :chats

  after_commit :create_room_notification, on: :create
  
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
    if (@thisR.admissions.count <= 1)
      Admission.where(user_id: user.id, room_id: self.id)[0].destroy
      p "방 폭파조건"
      @thisR.destroy
    else #방장여부 판별
      if (@thisR.master_id == user.email)
        p "if 문 들어옴"
        p @someone = User.find(@thisR.admissions.sample.user_id).email
        @thisR.update(master_id: @someone)
        
        Admission.where(user_id: user.id, room_id: self.id)[0].destroy
      end
      p @thisR.admissions.count
      p "방 사람들 수"
      p @thisR.master_id
    end
  end
  
  
  def user_ready(user)
    user_state = Admission.where(user_id: user.id, room_id: self.id)[0]
    user_state.update(ready_state: true)
  end
  
end
