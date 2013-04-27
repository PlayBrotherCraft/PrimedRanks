# persistance -
#     aczchef.primedrank.
#        <player>.
#            time.
#                join: <nanotime>
#                play: <nanotime>
#                bonus: <nanotime>

proc(_groups, @g = 'null',
    @groups = array(
        'default': array(
            'pex': 'default',
            'time': 0),
        'player': array(
            'pex': 'player',
            'time': 5),
        'trusted': array(
            'pex': 'trusted',
            'time': 24),
        'veteran': array(
            'pex': 'veteran',
            'time': 120)
    )
    if(@g == 'null') {
        return(@groups)
    } else if(array_contains(@groups, @g)) {
        return(@groups[@g])
    } else {
        console(_format(Invalid Group:'. @g, 'error'))
        die(_format(Invalid Group:'. @g, 'error'))
    }
)

proc(_get_time, @t, @p = player(),
    @n = 'aczchef.primedrank.' .@p. '.time.'
    if(@t == 'total') {
        if(!_has_time('play', @p)) {
            console(_format('Player doesnt have a totaltime.', 'error'))
            die()
        } else {
            @time = get_value(@n. 'play')
            if(_has_time('bonus', @p)) {
                @time += get_value(@n. 'bonus')
            }
        }
    } else if(@t == 'bonus' || @t == 'join' || @t == 'play') {
        if(!_has_time(@t, @p)) {
            console(_formnat('Player doesnt have a' @t. 'time', 'error'))
            die()
        } else {
            @time = get_value(@n. @t)
        }
    } else {
        console(_format('Invalid Type:' @t, 'error'))
        die(_format('Invalid Type:' @t, 'error'))
    }
    return(@time)
)

proc(_store_time, @t, @time, @p = player(),
    @n = 'aczchef.primedrank.' .@p. '.time.'
    if(@t == 'join' || @t == 'play' || @t == 'bonus') {
        store_value(@n. @t, @time)
    } else {
        console(_format('Invalid type:' @t, 'error'))
        die(_format('Invalid type:' @t, 'error'))
    }
)

proc(_has_time, @t, @p = player(),
    @n = 'aczchef.primedrank.' .@p. '.time.'
    if(@t == 'join' || @t == 'play' || @t == 'bonus') {
        return(has_value(@n. @t))
    } else {
        console(_format('Invalid type:' @t, 'error'))
        die(_format('Invalid type:' @t, 'error'))
    }
)

proc(_clear_jointime, @p = player(),
    clear_value('aczchef.primedrank.' .@p. '.time.join')
)

proc(_format_time, @seconds,
    @seconds /= 1000

    @periods = array('second', 'minute', 'hour', 'day', 'week', 'month', 'year', 'decade')
    @duration = array('60', '60', '24', '7', '4.35', '12', '10')
    @intervals = array()

    while(@seconds > 1,
        for(@j = 0, @j <= array_size(@duration) - 1 && @seconds >= @duration[@j], @j++) {
            @seconds /= @duration[@j]
        }

        @time = floor(@seconds)
        @seconds -= @time

        if(@time != 1) {
            @periods[@j] .= 's'
        }

        for(@i = 0, @i < @j, @i++) {
            @seconds *= @duration[@i]
        }

        array_push(@intervals, @time @periods[@j])
    )

    foreach(@intervals, @interval) {
        @message .= @interval .' ' 
    }

    return(@message)
)

proc(_perm, @perm, @p = player(),
    if(has_permission('primed.rank.' .@perm) || pisop(@p)) {
        return(true)
    } else {
        return(false)
    }
)

proc(_rankUp, @p = player(),
    @groups = _groups()
    @time = _get_time('total', @p)
    ifelse(
        @time >= 3600000 * @groups['veteran']['time'],
            tmsg(@p, _format('You are rank Veteran', 'notification'))
            if(!array_contains(pgroup(@p), @groups['veteran']['pex'])) {
                foreach(@groups, @group) {
                    runas(~console, '/pex user' @p 'group remove' @group['pex'])
                } 
                runas(~console, '/pex user' @p 'group add' @groups['veteran']['pex'])
                broadcast(_format(@p 'has been promoted to Veteran. Congrats!', 'success'))
            }
            ,
        @time >= 3600000 * @groups['trusted']['time'],
            tmsg(@p, _format('You are rank Trusted', 'notification'))
            if(!array_contains(pgroup(@p), @groups['trusted']['pex'])) {
                foreach(@groups, @group) {
                    runas(~console, '/pex user' @p 'group remove' @group['pex'])
                }
                runas(~console, '/pex user' @p 'group add' @groups['trusted']['pex'])
                broadcast(_format(@p 'has been promoted to Trusted. Congrats!', 'success'))
            }
            ,
        @time >= 3600000 * @groups['player']['time'],
            tmsg(@p, _format('You are rank Player', 'notification'))
            if(!array_contains(pgroup(@p), @groups['player']['pex'])) {
                foreach(@groups, @group) {
                    runas(~console, '/pex user' @p 'group remove' @group['pex'])
                }
                runas(~console, '/pex user' @p 'group add' @groups['player']['pex'])
                broadcast(_format(@p 'has been promoted to Player. Congrats!', 'success'))
            }
            ,
        @time >= 3600000 * @groups['default']['time'],
            tmsg(@p, _format('You are rank Default', notification))
            if(!array_contains(pgroup(@p), @groups['default']['pex'])) {
                foreach(@groups, @group) {
                    runas(~console, '/pex user' @p 'group remove' @group['pex'])
                }
                runas(~console, '/pex user' @p 'group add default')
                broadcast(_format(@p 'has been promoted to Default. Congrats!', 'success'))
            }
    )
)

proc(_format, @message, @type,
    @type = to_lower(@type)
    if(@type == 'success') {
        return(color('Dark_Green'). '[' .color('Green'). 'Primed Ranks' .color('Dark_Green'). ']' color('Green'). '»' color('White'). @message)
    } else if(@type == 'error') {
        return(color('Dark_red'). '[' .color('Red'). 'Primed Ranks' .color('Dark_Red'). ']' color('Red'). '»' color('White'). @message)
    } else if(@type == 'notification') {
        return(color('Blue'). '[' .color('Yellow'). 'Primed Ranks' .color('Blue'). ']' color('Yellow'). '»' color('White'). @message)
    }
)