dosString = {}
--lots of interesting things for dosString, can poll many things with net.dostring_in

--get flag from server enviroment
function dosString.getFlagValue(_flag)
    local _status,_error  = net.dostring_in('server', " return trigger.misc.getUserFlag(\"".._flag.."\"); ")
    if not _status and _error then
        net.log("error getting flag: ".._error)
        return 0
    else
        net.log("flag value ".._flag.." value: ".._status)
        --disabled
        return tonumber(_status)
    end
end