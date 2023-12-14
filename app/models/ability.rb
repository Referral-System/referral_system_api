# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    # Referral abilities
    can :read, Referral, referred_by: user.id, active: true
    can :recruiters, User, active: true
    can [:create, :update], Referral, referrer: user
    can [:index, :create], ReferralComment, author: user
    can :read, Role, id: user.role_id

    # User abilities
    can :manage, User, id: user.id

    can [:read, :assign_recruiter, :download_cv, :update], Referral if user.role_id == 3

    return unless user.role_id == 1

    # Admin abilities
    can :manage, [Referral, Role, User, ReferralComment]
  end
end
