local M = {}

function M.number(x, name)
    assert(type(x) == 'number' and x == x and math.abs(x) < math.huge,
        (name or 'value') .. ' must be a finite number')
    return x
end

function M.integer(x, name, minimum)
    M.number(x, name)
    assert(x % 1 == 0 and x >= (minimum or 0), (name or 'value') .. ' must be an integer >= ' .. (minimum or 0))
    return x
end

function M.copy(value, memo)
    if type(value) ~= 'table' then return value end
    memo = memo or {}
    if memo[value] then return memo[value] end
    local result = {}
    memo[value] = result
    for k, v in pairs(value) do result[M.copy(k, memo)] = M.copy(v, memo) end
    return setmetatable(result, getmetatable(value))
end

function M.merge(a, b)
    local result = {}
    for k, v in pairs(a or {}) do result[k] = v end
    for k, v in pairs(b or {}) do result[k] = v end
    return result
end

function M.clamp(x, a, b) return math.max(a or 0, math.min(b or 1, x)) end

function M.shell_quote(s)
    assert(type(s) == 'string' and not s:find('\0', 1, true), 'invalid shell argument')
    return "'" .. s:gsub("'", "'\\''") .. "'"
end

function M.command(args)
    local quoted = {}
    for i, v in ipairs(args) do quoted[i] = M.shell_quote(tostring(v)) end
    local ok, why, code = os.execute(table.concat(quoted, ' '))
    assert(ok, 'command failed (' .. tostring(why) .. ':' .. tostring(code) .. '): ' .. table.concat(quoted, ' '))
end

function M.mkdir(path) M.command({'mkdir', '-p', path}) end

return M
