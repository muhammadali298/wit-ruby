require 'wit'
require 'date'

if ARGV.length == 0
  puts("usage: #{$0} <wit-access-token>")
  exit 1
end

access_token = ARGV[0]
ARGV.shift

def first_entity_value(entities, entity)
  return nil unless entities.has_key? entity
  val = entities[entity][0]['value']
  return nil if val.nil?
  return val.is_a?(Hash) ? val['value'] : val
end

actions = {
  send: -> (request, response) {
    puts("sending... #{response['text']}")
  },
  set_appointment: -> (request) {
    context = request['context']
    entities = request['entities']
    date_time = first_entity_value(entities, 'datetime')
    if date_time
      context['message'] = "is set at #{DateTime.parse(date_time).strftime("%d/%m/%Y %H:%M")}"
      context.delete('missing_time')
    else
      context['missing_time'] = true
      context.delete('message')
    end
    return context
  },
}

client = Wit.new(access_token: access_token, actions: actions)
client.interactive
