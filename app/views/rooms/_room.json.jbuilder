json.extract! room, :id, :title, :master_id, :max_count, :admissions_count, :created_at, :updated_at
json.url room_url(room, format: :json)
