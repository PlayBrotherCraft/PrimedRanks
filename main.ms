include('util.ms')

bind(player_join, null, null, @event,
	@p = @event['player']
	if(_has_time('join', @p)) {
		console(color('Red'). 'Player had invalid jointime (they may have lost time). Fixed!')
	}
	_store_time('join', time(), @p)
	if(!_has_time('play', @p)) {
		_store_time('play', 0, @p)
	}
	if(!_has_time('bonus', @p)) {
		_store_time('bonus', 0, @p)
	}
	_rankUp(@p)
)

bind(player_quit, null, null, @event,
	@p = @event['player']
	@play = _get_time('play', @p)
	@join = _get_time('join', @p)
	@play += time() - @join
	_store_time('play', @play, @p)
	_clear_jointime(@p)
)

bind(player_kick, null, null, @event,
	@play = _get_time('play', @p)
	@join = _get_time('join', @p)
	@play += time() - @join
	_store_time('play', @play, @p)
	_clear_jointime(@p)
)