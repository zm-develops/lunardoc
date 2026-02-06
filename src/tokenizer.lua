--- Tokenizer for Lua source code written in pure Lua.
--  Output has parity with LoganDark's Lua lexer.
--  @script             tokenizer
--  @license            MIT
--  @param              {string} text Lua source code to lex.
--  @return             {string} Table of line arrays containing lexemes.

local tokeniser = {}

local lexer = require('pl.lexer')

local options = { comments = false, space = false, number = false, string = false }

-- Split a string by a delimiter.
-- @function             split
-- @param                {string} str The string to split.
local function split(str, delimiter)
    local content = {}
    local from = 1
    local delim_from, delim_to = string.find(str, delimiter, from)

    while delim_from do
        content[#content + 1] = string.sub(str, from, delim_from - 1)
        from = delim_to + 1
        delim_from, delim_to = string.find(str, delimiter, from)
    end

    content[#content + 1] = string.sub(str, from)

    return content
end

local operators = {
    ['+'] = true,
    ['-'] = true,
    ['*'] = true,
    ['/'] = true,
    ['^'] = true,
    ['%'] = true,
    ['#'] = true,
    ["=="] = true,
    ["~="] = true,
    [">"] = true,
    ["<"] = true,
    [">="] = true,
    ["<="] = true
}

local symbols = {
    [","] = true,
    ["{"] = true,
    ["}"] = true,
    ["["] = true,
    ["]"] = true,
    ["("] = true,
    [")"] = true,
    [";"] = true,
    ["."] = true,
    [":"] = true
}

local function tokenize(text, lang)
    local lineno = 1
    local tokens = {}

    for t, v in lexer[lang](text, options) do
        if type(v) == 'string' and v:find('\n') then
            local lines = split(v, '\r?\n')

            for i, l in ipairs(lines) do
                if i > 1 then lineno = lineno + 1 end
                if i ~= 1 or l ~= '' then
                    table.insert(tokens, { type = t, data = tostring(l), line = lineno })
                end
            end
        end

        if type(v) ~= 'string' or not v:find('\n') then
            table.insert(tokens, { type = t, data = tostring(v), line = lineno })
        end
    end

    -- Remove blank string values that precede e non-blank string values on the same line.
    local deletemes = {}
    for i = #tokens, 2, -1 do
        if
            tokens[i].line == tokens[i - 1].line and
            tokens[i - 1].data == '' and
            tokens[i].data ~= '' and
            (tokens[i - 1] or {}).line ~= tokens[i - 2].line
        then
            deletemes[i - 1] = true
        end
    end

    local output = {}
    for i, t in ipairs(tokens) do
        if not deletemes[i] then
            output[#output + 1] = t
        end
    end

    -- Add position start and end indexes to the tokens.
    local current_line = 1
    local current_pos = 1

    for _, t in ipairs(output) do
        if t.line > current_line then
            current_pos = 1
            current_line = t.line
        end

        t.start = current_pos
        t.stop = current_pos + #t.data - 1

        current_pos = t.stop + 1
    end

    -- Modify the token types for punctuation and identties to match LoganDark's lexer.
    for _, t in ipairs(output) do
        if t.type == t.data and not t.type:find('%w') then
            if t.type == '...' then
                t.type = 'vararg'
            end
            if operators[t.type] then
                t.type = 'operator'
            elseif symbols[t.type] then
                t.type = 'symbol'
            else
                t.type = 'operator'
            end
        end

        if t.type == 'iden' then
            t.type = 'ident'
        end
    end

    return output
end

function tokeniser.lua(text)
    return tokenize(text, 'lua')
end

function tokeniser.cpp(text)
    return tokenize(text, 'cpp')
end

return tokeniser