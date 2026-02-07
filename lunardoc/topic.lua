--  @topic Lunardoc
--  @pragma strip true

--- A sequence of object tables that is also indexable by the name
--  key of each object. Indexing by name produces a list of the
--  objects with that name key.
--  @type Lunardoc.Hashmap

--- Describes the overall structure of the content in the Lua module
--  or topic. It's a collection of all the information the
--  taglet outputs. It is similar to the Documentation object JSDoc
--  generates for files.
--  @type Lunardoc.Documentation
--  @todo Add tokens field.

--- External variable name of the module when it is loaded by other
--  modules using `require`.
--  @member {string} Lunardoc.Documentation.name

--- Internal alias or label name of the module variable in the code,
--  often aliased by the developer. This can be found as the final `return`
--  in the module code. Generally, Lua 5.1 packages tend to use `p` as their
--  module variable.
-- @member {string} Lunardoc.Documentation.alias

--- Path to the target page on the server. Generally the path value of
--  the URL without the server in the Web Location API, e.g.
--  `"Module:Lunardoc"`.
--  @member {string} Lunardoc.Documentation.filename

--- Number of lines in the document. Includes the whitespace at the start
--  or end of the document. This count may optionally remove boilerspace
--  comments with license data at the end or start of the page.
--  @member {number} Lunardoc.Documentation.lineno

--- The overall type of the module page. This can be one of the following
--  values: `module`, `script`, `classmod`, `topic`, `submodule`,
--  `example` and `file`. The type is implied by the tag that provides
--  the @{Documentation.name} value, and thus, it defaults to `module`.
--  @member {string} Lunardoc.Documentation.type

--- Whether the script can be compiled as a standalone program and
--  executed. This is true for the following types - `module`, `script`
--  and `classmod`. This is false for `topic`, `submodule`, `example`
--  and `file`.
--  @member {boolean} Lunardoc.Documentation.executable

--- The first sentence of the byline comments describing the module.
--  This text is parsed from the top of the module page's content. This
--  sentence splitting supports Chinese, Japanese, Korean, Thai and
--  Vietnamese.
--  @member {string} Lunardoc.Documentation.summary
--  @todo **Deprecate** this for compatibility with JSDoc.

--- The full paragraph of the comment preface describing the module.
--  This field is terminous with the `summary` field - the first sentence
--  appears removed when summary is present.
--  @member {string} Lunardoc.Documentation.description

--- List of comments that appear at the top of the module page's content.
--  @member {sequence<string>} Lunardoc.Documentation.comments

--- The full text contents of the module page. This will have boilerplate
--  comments removed. Boilerplate comments appear as block comments at
--  the end or start of the page.
--  @member {string} Lunardoc.Documentation.code

--- A hashmap (sequence and dictionary) of objects that describe
--  `@tagname` documentation tags from the top level module comments.
--  Each of the tag comments is parsed into a @{Tag} object. Tags can be
--  accessed by iterating through the list (e.g. `documentation.tags[1]`)
--  or indexing the table (e.g. `documentation.tags['param']`). This
--  tag is a hashmap because indexing is done by their numerical order or
--  the tag name. Tags may also allow modifiers and types.
--  @member {Hashmap<Tag>} Lunardoc.Documentation.tags

--- A list of the subset of code items (functions and variables) with
--  markup that Lunardoc can understand. Each item is an object
--  describing the documentation markup and source of Lua code.
--  @todo Support linking capital version of lowercase types in Lua
--  references.
--  @member {sequence<string>} Lunardoc.Documentation.items

--- Describes the tag markup and code information for a Lunardoc code
--  item. It's a combination of the comment markup and code heuristic results 
--  that Lunardoc generates for a code item (or items). Items are naively 
--  delimited by tag markup and not delimited to separate code items via a
--  syntax AST.
--  @type Lunardoc.Item
--  @todo Parse items into a syntax AST.
--  @todo Add `Item.tokens` property.

--- The canonical name of the variable for the item within the Lua source code,
--  which the other Lua code in the module would use as a reference access.
--  @member {string} Lunardoc.Item.name

--- The external name of the module variable in the code, after it is exposed.
--  This value is the index code used by other modules or exported by factory
--  methods, class constructors and module accessors. Aligns
--  to the value of @{Docuentation.alias} (which is often `p`).
--  @member {string} Lunardoc.Item.alias

--- The hierarchy of Lua keys that lead from the global object `_G`
--  to the canonical alias of the code item in the module.
--  @member {sequence<string>} Lunardoc.Item.hierarcy

--- The line number of the first comment for an item.
--  Line numbers are 1-indexed and align with the number anchors in the code
--  editor and the article code block. This count may optionally disinclude
--  comments with license boilerspace at the end or start of the page.
--  @member {number} Lunardoc.Item.lineno

--- The overall type of the code item. This can be one of the following
--  values: `function`, ` table`, ` member`, ` variable`, ` section` 
--  and ` type`. The type is implied by the tag that provides the @{Item.name}
--  value, and thus, it defaults to `variable` or 'member'.
--  @member {sequence<string>} Lunardoc.Item.type

--- Additional types or data that are rendered next to the item definition term.
--  This will include a Lua primitive type or a metatable class which is
--  `Item.types[1]` and `Item.type`.
--  @member {sequence<string>} Lunardoc.Item.types

--- Whether the code variable is publicly available to other modules.
--  This is usually either A. a variable that is one of the module exports or
--  B. a variable that is exported as a type member or method.
--  @member {boolean} Lunardoc.Item.export

--- List of comments that are associated with the Lunardoc code item.
--  These appear at the start of the source code for the item.
--  They can be textual or `@`-tag comments.
--  @member {sequence<string>} Lunardoc.Item.comments

--- The first sentence of the comments that describe the @{Item}.
--  This comment generally precedes the Lua code item(s) and has the `---`
--  triple-comment mark preceding it. Alternatively, the `summary` property
--  can be overriden by the value of `@summary` in the tag block of an item.
--- When this is present, it coexists with the @{Item.description} field.
--  This sentence splitting supports Asian languages also.
--  @member {string} Lunardoc.Item.summary
--  @todo **Deprecate** this for compatibility with JSDoc.

--- The comment data associated with the tag markup block for each Lunardoc code
--  item. This information is sourced from the plain text of the comment byline
--  for a code item or items. The value can also be explicitly provided by the
--  `@description` tag - for example when in a `@section` code block.
--  This field is terminous with the @{Item.summary} field - the first sentence
--  appears removed when summary is present.
--  @member {string} Lunardoc.Item.description

--- Source code associated with the Lunardoc code item.
--  This consists of the source code of the Lua item and any other items that
--  appear adjacent to it before the next Lua `--- item` and `-- @tag`. Usually
--  this tends to be the singular Lua code item that the tag comments target.
--  
--  This can be more than one code item if the item documentation does not align
--  1:1 to the code items in the module. If a source variable doesn't have markup,
--  it will appear in the code field of a preceding item.
--  @member {string} Lunardoc.Item.code

--- Information sourced from the tag markup block for each Lunardoc code item.
--  Each of the tag comments is parsed from `@tagname` into a @{Tag} object.
--  This tag is a hashmap because tags can be accessed by iterating through the
--  list or indexing the table (e.g. `item.tags['param']`). Tags may also allow
--  modifiers and types. These tags can include [[#Module-level flags|flag tags]]
--  which have the value `true` and are rendered in the documentation as subtypes
--  in the item headline.
--  @member {Hashmap<Tag>} Lunardoc.Item.tags

--- An object that describes a single documentation tag.
--  The tag value and name are parsed from the `@tagname` markup in the
--  comment block for each item. Additional information such as any type and
--  modifiers present are stored in the object. The syntax for each tag
--  is `@tagname {type} name description`. Types can be made nullable with
--  a prefacing `?` character. The `@param` and `@field` tags can be made
--  optional by surrounding the `[name]` of the value in square brackets.
--  @type Lunardoc.Tag

--- The name of the tag without the `@` symbol prefix.
--  There are 42 canonical tag names and 38 aliases supported by Lunardoc.
--  @member {string} Lunardoc.Tag.name

--- The type of the tag value used in `@param`, `@return` and `@field` tags.
--  This value is enclosed in curly braces as `{type}` after the tag name.
--  @member {string} Lunardoc.Tag.type

--- The value of the tag. This is the description after the tag name and type.
--  For the `@param` and `@field` tags, this text is prefaced by the parameter
--  or field name, respectively.
--  @member {string} Lunardoc.Tag.value

--- Modifiers appended to the tag.
--  Known modifiers include:
--  - `opt` and `optchain` for `@param` and `@field` tags
--  - `@pragma[yesno]` values - see [[Global Lua Modules/Yesno]] for behavior
--  - `@error[line=number]` or `@error[number]` for line number links
--  @member {table} Lunardoc.Tag.modifiers
