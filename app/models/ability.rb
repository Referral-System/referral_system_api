# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    # Referral abilities
    can :read, Referral, referrer: user, active: true
    can [:create, :update, :assign_recruiter], Referral, referred_by: user.id

    # User abilities
    can :manage, User, id: user.id

    return unless user.role_id == 1

    # Admin abilities
    can :manage, [Referral, Role, User]
  end
end
