require_relative './base_event_handler'
require './lib/user_experience'

class ReviewSubmittedHandler < BaseEventHandler
  def target_user_login
    @data['review']['user']['login']
  end

  def execute!(redis)
    user = UserExperience::User.new(redis, target_user_login)
    user.increment
    if is_approved
    	return message(user, 'looks good')
    end
  end

  private

  def is_approved
    @data['review']['state'] == 'approved'
  end

  def review_preview
    @data['review']['body'].slice(0...255)
  end

  def review_link
    @data['review']['html_url']
  end

  def message(user, label)
    "[#{repository_link} #{review_link}] #{user.display}: #{label}\n>>>#{review_preview}"
  end
end