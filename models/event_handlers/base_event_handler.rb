class BaseEventHandler
  EMOJI = %w[
    :parrot: :pacman: :pig: :octopus: :chicken: :crickets: :bee: :bird:
    :crocodile: :ghost2: :rooster: :best: :turkey: :corgi: :doge:
  ]
  TITLES   = [ '☹₀', '♙₁', '♘₂', '♗₃', '♖₄', '♕₅', '♔₆', '☃₇', '☼₈', '⚛₉', '☯₁₀', '⌘₁₁', '⍟₁₂', '⌹₁₃', '⍰₁₄', '⏏₁₅', '▜₁₆', '☆₁₇', '☕₁₈', '☢₁₉', '☘₂₀', ':cuteghost:₂₁', ':tiltlogo:₂₂', ':ship3:₂₃', ':ocean:₂₄', ':zap:₂₅', ':cherries:₂₆', ':heart_decoration:₂₇', ':game_die:₂₈', ':helicopter:₂₉', ':science:₃₀' ]
  EXPBAR   = [ '▁', '▂', '▃', '▅', '▆', '▇', '█' ]
  FACTOR   = 100
  INTERVAL = FACTOR.to_f / EXPBAR.size.to_f

  def random!(redis, slack, channel_id)
    event = rand(3)
    random_emoji = EMOJI[rand(EMOJI.size)]
    if event === 0
      push_pet(redis, target_user_login, random_emoji)
      slack.post_message(channel_id, "A wild #{random_emoji} appears.\n#{target_user_login} captured #{random_emoji}")
      slack.post_message(channel_id, "#{target_user_login}'s collection #{pets(redis, target_user_login).join(' ')}")
    elsif event == 1
      slack.post_message(channel_id, "#{target_user_login}. A wild #{random_emoji} appears. But it got away...")
    end
  end

  def initialize(data)
    @data = data
  end

  def increment_user(redis, login)
    redis.set login, user_experience(redis, login) + 1
  end

  def push_pet(redis, login, pet)
    redis.lpush("#{login}_pets", pet)
  end

  def pets(redis, login)
    redis.lrange("#{login}_pets", 0, 10)
  end

  def repository_link
    full_name = @data['repository']['full_name']
    name = @data['repository']['name']
    "<http://github.com/#{full_name}|review:#{name}>"
  end

  def pull_request_link
    url = @data['pull_request']['html_url']
    number = @data['pull_request']['number']
    "<#{url}|##{number}>"
  end

  def pull_request_user_login
    @data['pull_request']['user']['login']
  end

  def target_user_login
    @data['pull_request']['user']['login']
  end

  def user_display(redis, login)
    "#{exp_icon(redis, login)}#{score_icon(redis, login)} #{login}"
  end

private

  def user_experience(redis, login)
    redis.get(login).to_i
  end

  def exp_icon(redis, login)
    score = user_experience(redis, login)
    return '' if score <= 0
    return EXPBAR[ ((score % FACTOR) / INTERVAL).to_i ]
  end

  def score_icon(redis, login)
    score = user_experience(redis, login)
    return '☃'   if login == 'tildedave'
    return '☠'           if score <= 0
    return ':godmode:₉₉' if score >= (TITLES.size * FACTOR)
    return TITLES[ score / FACTOR ]
  end
end
