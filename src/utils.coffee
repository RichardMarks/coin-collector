
camelMatcher = (match) -> match[1].toUpperCase()
camelize = (name) ->
  ###
  transforms a string in the format foo-bar to fooBar
  ###
  name.replace /-[a-z]/g, camelMatcher

pascalMatcher = (match, group) -> 
  "#{group[0].toUpperCase()}#{group[1..-1].toLowerCase()}"

pascalize = (name) ->
  ###
  transforms a string in the format foo-bar to FooBar
  ###
  name.replace /-?([a-z|0-9|A-Z]+)/g, pascalMatcher

utils =
  camelize: camelize
  pascalize: pascalize

module.exports = utils
