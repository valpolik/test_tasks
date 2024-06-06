# frozen_string_literal: true

# https://gist.github.com/wwwermishel/fd2c7973520c270c508720ba3a20e09c

# lalala
class CreateUserInterests < ActiveRecord::Migration
  def change
    create_table :user_interests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :interest, null: false, foreign_key: true

      t.timestamps
    end
  end
end

# lalala
class CreateUserSkills < ActiveRecord::Migration
  def change
    create_table :user_skills do |t|
      t.references :user, null: false, foreign_key: true
      t.references :skill, null: false, foreign_key: { to_table: :skils }

      t.timestamps
    end
  end
end

# lalala
class User < ApplicationRecord
  has_many :user_interests, dependent: :destroy
  has_many :interests, through: :user_interests

  has_many :user_skills, dependent: :destroy
  has_many :skills, through: :user_skills
end

# lalala
class Interest < ApplicationRecord
  has_many :interest_users, class_name: 'UserInterest'
  has_many :users, through: :interest_users
end

# lalala
class Skil < ApplicationRecord
  has_many :skill_users, class_name: 'UserSkill', foreign_key: :skill_id
  has_many :users, through: :skill_users
end

# lalala
class UserInterest < ApplicationRecord
  belongs_to :user
  belongs_to :interest
end

# lalala
class UserSkill < ApplicationRecord
  belongs_to :user
  belongs_to :skill, class_name: 'Skil'
end

# In appliaction we are using ActiveInteraction gem => https://github.com/AaronLasseigne/active_interaction
module Users
  # lalala
  class Create < ActiveInteraction::Base
    hash :params

    def execute
      # don't do anything if params is empty
      required_fields = %w[name surname patronymic email age nationality country gender]
      return if params.blank?
      return unless required_fields.all? { |field| params[field].present? }

      ##########
      return if User.exists?(email: params['email'])
      return if params['age'].to_i <= 0 || params['age'].to_i > 90
      return if params['gender'] != 'male' && params['gender'] != 'female'

      user_full_name = "#{params['surname']} #{params['name']} #{params['patronymic']}"
      user_params = params.slice(*required_fields).merge(fullname: user_full_name)
      skills_array = params['skills']&.split(',')

      User.transaction do
        user = User.create!(user_params)
        user.interests = Interest.where(name: params['interests']) if params['interests'].present?
        user.skills = Skil.where(name: skills_array) if skills_array.present?
      end
    end
  end
end

# #User object in database
# name string
# surname string
# patronymic string
# fullname string
# email string
# age integer
# nationality string
# country string
# gender string

# #Interest object in database
# name string

# #Skil oject in database
# name string

# #UserInterest object in database
# user_id bigint
# interest_id bigint

# #UserSkill object in database
# user_id bigint
# skill_id bigint
