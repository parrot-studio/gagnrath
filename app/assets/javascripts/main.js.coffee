fetch_guild_form = (e) ->
  str = $(e.target).data('list')
  list = str.split("\t")
  for i in [1..8]
    g = list[i-1] || ''
    $('#guild_' + i).val(g)
  @

clear_guild_form = ->
  for i in [1..8]
    $('#guild_' + i).val('')
  @

init_union_handler = ->
  $("a.history").click (e) ->
    fetch_guild_form(e)
    false
  $("a#guild-clear").click (e) ->
    clear_guild_form()
    false
  @

$ ->
  init_union_handler() if $("[id^=guild]").length > 0
