if( not gaBroadcaster ) then
    gaBroadcaster = {};
end

gaBroadcaster.callbacks = {};

function gaBroadcaster.callbacks.deepCorruptionStacks( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16 )
    if( gaCore.showDebug == true ) then
        gaCore.debugMessageFrame:AddMessage( "Found " .. tostring( arg16 ) .. " stacks of " .. tostring( arg13 ) .. "." );
    end
    if( arg16 >= 4 ) then
        return true;
    else
        return false;
    end
end