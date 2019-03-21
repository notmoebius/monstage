module Users
  class MainTeacher < User
    belongs_to :school
    has_one :school_manager, through: :school
    belongs_to :class_room, optional: true

    validates :first_name,
              :last_name,
              presence: true

    validates :school_manager, presence: true,
                               if: :school_id_changed?
    validates :school_manager, presence: true,
                               on: :create

    before_update :notify_school_manager, if: :school_id_changed?
    after_create :notify_school_manager

    include NearbyIntershipOffersQueryable

    def notify_school_manager
      SchoolManagerMailer.new_main_teacher(school_manager: school_manager,
                                           main_teacher: self)
                         .deliver_later
    end
  end
end