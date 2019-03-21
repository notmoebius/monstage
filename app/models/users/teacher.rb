module Users
  class Teacher < User
    belongs_to :class_room, optional: true
    include ManagedUser
  end
end
