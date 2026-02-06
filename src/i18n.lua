--- I18n library for message storage in Lua datastores.
--  The module is designed to enable message separation from modules &
--  templates. It has support for handling language fallbacks. This
--  module is a Lua port of [[I18n-js]] and i18n modules that can be loaded
--  by it are editable through [[I18nEdit]].
--  
--  @module         i18n
--  @version        1.4.0
--  @require        Module:Fallbacklist
--  @release        stable
--  @see            [[I18n|I18n guide]]
--  @see            [[I18n-js]]
--  @see            [[I18nEdit]]
local i18n, _i18n = {}, {}

--  Library dependencies.
local file = require('pl.file')
local path = require('pl.path')
local json = require('src.json')
local fallbacks = require('src.fallbacks')

--- Argument substitution as $n where n > 0.
--  @function           _i18n.handleArgs
--  @param              {string} msg Message to substitute arguments into.
--  @param              {table} args Arguments table to substitute.
--  @return             {string} Resulting message.
--  @local
function _i18n.handleArgs(msg, args)
    for i, a in ipairs(args) do
        msg = (string.gsub(msg, '%$' .. tostring(i), tostring(a)))
    end
    return msg
end

--- Checks whether a language code is valid.
--  @function           _i18n.isValidCode
--  @param              {string} code Language code to check.
--  @return             {boolean} Whether the language code is valid.
--  @local
function _i18n.isValidCode(code)
    return type(code) == 'string' and code:find('^%a%a%a?%f[%z-]') == 1
end

--  Module variables.
local locale = os.setlocale():match('^%w[^_]+')
local userlang = _i18n.isValidCode(locale) and locale or 'en'
local uselang

--- I18n datastore class.
--  This is used to control language translation and access to individual
--  messages. The datastore instance provides language and message
--  getter-setter methods, which can be used to internationalize Lua modules.
--  The language methods (any ending in `Lang`) are all **chainable**.
--  @type            Data
local Data = {}
Data.__index = Data

--- Datastore message getter utility.
--  This method returns localized messages from the datastore corresponding
--  to a `key`. These messages may have `$n` parameters, which can be
--  replaced by optional argument strings supplied by the `msg` call.
--  
--  This function supports [[#pdf-named_arguments|named
--  arguments]]. The named argument syntax is more versatile despite its
--  verbosity; it can be used to select message language & source(s).
--  @function           Data:msg
--  @usage
--  
--      ds:msg{
--          key = 'message-name',
--          lang = '',
--          args = {...}
--      }
--  
--  @usage
--  
--      ds:msg('message-name', ...)
--  
--  @param              {string|table} opts Message configuration or key.
--  @param[opt]         {string} opts.key Message key to return from the
--                      datastore.
--  @param[opt]         {table} opts.args Arguments to substitute into the
--                      message (`$n`).
--  @param[opt]         {table} opts.lang Temporary language to use (see
--                      `Data:inLang`).
--  @param[opt]         {string} ... Arguments to substitute into the message
--                      (`$n`).
--  @error[115]         {string} 'missing arguments in Data:msg'
--  @return             {string} Localised datastore message or `'<key>'`.
function Data:msg(opts, ...)
    -- Argument normalization.
    if not self or not opts then
        error('missing arguments in Data:msg')
    end
    local key = type(opts) == 'table' and opts.key or opts
    local args = opts.args or {...}
    -- Configuration parameters.
    if opts.lang then
        self:inLang(opts.lang)
    end
    -- Language handling.
    local lang = self.tempLang or self.defaultLang
    self.tempLang = nil
    -- Message fetching.
    local msg = (self._messages[lang] or {})[key]
    -- Fallback support (experimental).
    for _, l in ipairs((fallbacks[lang] or {})) do
        if msg == nil then
            msg = (self._messages[l] or {})[key]
        end
    end
    -- Internal fallback to 'en'.
    msg = msg ~= nil and msg or self._messages.en[key]
    -- Handling argument substitution from Lua.
    if msg and #args > 0 then
        msg = _i18n.handleArgs(msg, args)
    end
    if msg and lang ~= 'qqx' then
        return msg
    end

    return '<' .. key .. '>'
end

--- Datastore default language getter.
--  @function           Data:getLang
--  @return             {string} Default language to serve datastore messages in.
function Data:getLang()
    return self.defaultLang
end

--- Datastore language setter to `wgUserLanguage`.
--  @function           Data:useUserLang
--  @return             {Data} Datastore instance.
--  @note               Scribunto only registers `wgUserLanguage` when an
--                      invocation is at the top of the call stack.
function Data:useUserLang()
    self.defaultLang = userlang or self.defaultLang
    return self
end

--- Datastore language setter to specificed language.
--  @function           Data:useLang
--  @param              {string} code Language code to use.
--  @return             {Data} Datastore instance.
function Data:useLang(code)
    self.defaultLang = _i18n.isValidCode(code)
        and code
        or  self.defaultLang
    return self
end

--- Temporary datastore language setter to `wgUserLanguage`.
--  The datastore language reverts to the default language in the next
--  @{Data:msg} call.
--  @function           Data:inUserLang
--  @return             {Data} Datastore instance.
function Data:inUserLang()
    self.tempLang = userlang or self.tempLang
    return self
end

--- Temporary datastore language setter to a specificed language.
--  Only affects the next @{Data:msg} call.
--  @function           Data:inLang
--  @param              {string} code Language code to use.
--  @return             {Data} Datastore instance.
function Data:inLang(code)
    self.tempLang = _i18n.isValidCode(code)
        and code
        or  self.tempLang
    return self
end

--  Package functions.

--- I18n message datastore loader.
--  @function           i18n.loadMessages
--  @param              {string} ... ROOTPAGENAME/path for target i18n
--                      submodules.
--  @error[322]         {string} 'no source supplied to i18n.loadMessages'
--  @return             {table} I18n datastore instance.
--  @usage              require('i18n').loadMessages('1', '2')
function i18n.loadMessages()
    local ds = {}

    ds._messages = {}
    setmetatable(ds, Data)
    ds:useUserLang()

    local l10n = require('data.messages')

    ds._messages = {}

    for lang in pairs(l10n) do
        ds._messages[lang] = l10n[lang] or {}
    end

    -- Return datastore instance.
    return ds
end

--- Language code getter.
--  Can validate a template's language code through `uselang` parameter.
--  @function           i18n.getLang
--  @usage              {{i18n|getLang|uselang {{=}} code}}
--  @return             {string} Language code.
function i18n.getLang()
    return uselang or userlang
end

return i18n