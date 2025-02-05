export type DocumentPosition = {
	line: number,
	character: number
}

export type AutocompleteRequest = {
	position: {
		line: number,
		character: number,
	},
	textDocument: {
		document: ScriptDocument?,
		script: LuaSourceContainer?,
	},
}

export type AutocompleteResponseItem = {
	label: string,
	kind: Enum.CompletionItemKind?,
	
	tags: { Enum.CompletionItemTag }?,
	detail: string?,
	
	documentation: {
		value: string,
	}?,
	
	overloads: number?,
	learnMoreLink: string?,
	codeSample: string?,
	preselect: boolean?,
	
	textEdit: {
		newText: string,
		replace: {
			start: DocumentPosition,
			["end"]: DocumentPosition,
		},
	}?,
}

export type AutocompleteResponse = {
	items: {
		[number]: AutocompleteResponseItem
	},
}

local pluginFolder = script.Parent.Parent

local PluginShared = require(pluginFolder.Libraries.Shared)
local MacroManager = require(pluginFolder.Libraries.MacroManager)

local Editor = {}
Editor.CurrentDocument = nil :: ScriptDocument?
Editor.CurrentPosition = nil :: DocumentPosition?

Editor.ClassTypes = {}

Editor.REGISTER_PRIORITY = 10

local function filterEnvValue(value: string)
	local filtered = value:gsub('[\n\r\'"]', ''):gsub('%s+$', '')
	
	return filtered
end


local function getFunctionDetail(class, name: string)
	local details = class.__FunctionDetails
	
	if not details or not details[name] then
		return '() -> nil'
	end
	
	return details[name]
end

local function getIndent(line: string)
	local _, count = line:gsub('^\t', '')
	
	return string.rep('\t', count)
end


local function getType(value: any)
	if value == 'any' then
		return 'any'
	end
	
	local valueType = typeof(value)
	
	if valueType == 'EnumItem' then
		valueType = `Enum.{value.EnumType}`
	end
	
	return valueType
end


function Editor:FindDelimiterPair(cursor: number, pair: string, size: number?)
	local source = self.CurrentDocument:GetText()
	
	size = size or math.ceil(#pair / 2)
	
	local start, finish = nil, nil
	local pairStart, pairEnd = pair:sub(1, size), pair:sub(size + 1)
	
	local c = 0
	
	for offset = cursor, 1, -1 do
		local sub = source:sub(offset, offset + size - 1)
		
		if sub == pairEnd then
			c += 1
		elseif sub == pairStart then
			if c == 0 then
				start = offset
				
				break
			end
			
			c -= 1
		end
	end
	
	if start then
		c = 0
		
		for offset = start + 1, #source do
			local sub = source:sub(offset, offset + size - 1)
			
			if sub == pairStart then
				c += 1
			elseif sub == pairEnd then
				if c == 0 then
					finish = offset
					
					break
				end
				
				c -= 1
			end
		end
	end
	
	return start, finish
end


function Editor:InitializeClasses()
	-- custom macro item so that it has autocomplete aswell
	self.ClassTypes.Macro = {
		Order = -1,
		Icon = '',
		Items = {},
		
		Init = function()
			return
		end,
		Setup = function()
			return
		end,
		Cleanup = function()
			return
		end,
		GetDetail = function()
			return
		end,
		
		
		SendAlert = function()
			return
		end,
		SetVisible = function()
			return
		end,
		SetMinimized = function()
			return
		end,
		ScrollTo = function()
			return
		end,
		
		
		__FunctionDetails = {
			SetVisible = '(visible: boolean) -> nil!',
			SetMinimized = '(minimized: boolean) -> nil!',
			ScrollTo = '(duration: number?, alignment: Enum.VerticalAlignment?) -> nil!',
			SendAlert = '(scrollTo: boolean?) -> nil!',
			
			GetDetail = '() -> string',
			
			Cleanup = '(plugin: Plugin, macroSettings) -> nil',
			Setup = '(plugin: Plugin, macroSettings) -> nil',
			Init = '(plugin: Plugin, macroSettings) -> nil'
		}
	}
	
	for _, classModule in ipairs(pluginFolder.Classes:GetChildren()) do
		local classData = table.clone(require(classModule)) -- clone so we're not modifying the original class
		
		classData.SetVisible = function()
			return
		end
		
		classData.ScrollTo = function()
			return
		end
		
		classData.__FunctionDetails = classData.__FunctionDetails or {}
		classData.__FunctionDetails.SetVisible = '(visible: boolean) -> nil!'
		classData.__FunctionDetails.ScrollTo = '(duration: number?, alignment: Enum.VerticalAlignment?) -> nil!'
		
		self.ClassTypes[classModule.Name] = classData
	end
	
	for new, original in pairs(PluginShared.ITEM_REMAP) do
		self.ClassTypes[new] = self.ClassTypes[original]
	end
end

function Editor:GetSourceCursor()
	local document = self.CurrentDocument
	local position = self.CurrentPosition
	
	local globalCursor = -((#document:GetLine() + 1) - position.character + 1)
	
	for index = 1, position.line do
		globalCursor += #document:GetLine(index) + 1
	end
	
	return globalCursor
end

function Editor:GetSourceEnv()
	local document = self.CurrentDocument
	
	if not document then
		return
	end
	
	local source = document:GetText()
	
	local vars = {}
	
	-- find all table assignments (hello = {})
	for variable, tableContents in source:gmatch('local%s*([%w_]+)%s*=%s*{(.-)}') do
		local properties = {}
		
		-- convert table contents
		for key, value in tableContents:gmatch('([%w_]+)%s*=%s*([^,;]+)[,;\n\r]?') do
			properties[key] = filterEnvValue(value)
		end
		
		vars[variable] = properties
	end
	
	-- find all table index operations (hello.foo = "bar")
	for variable, key, value in source:gmatch('([%w_]+)%.([%w_]+)%s*=%s*([^;\n\r]+)') do
		if not vars[variable] then
			vars[variable] = {}
		end
		
		vars[variable][key] = filterEnvValue(value)
	end
	
	local macroName = source:match('return ([%w_]+)$')
	
	if macroName then
		vars[macroName] = vars[macroName] or {}
		vars[macroName].Type = 'Macro'
	end
	
	-- filter for macro items
	for itemName, properties in pairs(vars) do
		if properties.Type then
			continue
		end
		
		vars[itemName] = nil
	end
	
	for variable, funcName in source:gmatch('function%s*(%w+):(%w+)%(.-%)') do
		if vars[variable] then
			vars[variable][funcName] = 'function'
		end
	end
	
	local currentLine = document:GetLine()
	
	if currentLine:match('self') then
		local cursor = Editor:GetSourceCursor()
		local sub = source:sub(1, cursor)
		
		local currentVar = nil
		
		for offset = cursor, 1, -1 do
			local var = sub:match('function%s+(%w+):%w+%(', offset)
				
			if var and vars[var] then
				currentVar = vars[var]
				
				break
			end
		end
		
		if currentVar then
			vars['self'] = currentVar
		end
	end
	
	local env = {}
	env.vars = vars
	
	return env
end

function Editor:GetClassItems(name: string, indexType: string, ignore: {string}?): {AutocompleteResponseItem}
	local class = self.ClassTypes[name]
	
	if not class then
		return {}
	end
	
	local currentPosition = self.CurrentPosition
	local currentLine = self.CurrentDocument:GetLine()
	
	local isFuncAssign = currentLine:match('function .-:') ~= nil
	local isVarAssign = currentLine:match('=%s*.-:') ~= nil
	
	local responseItems = {}
	
	for index, value in pairs(class) do
		if index:match('^__') then
			continue
		end
		
		if ignore and ignore[index] then
			continue
		end
		
		local vType = getType(value)
		
		local sub = currentLine:sub(1, currentPosition.character)
		local start = sub:reverse():find('[%.%s\t\n\r:]')
		
		if start then
			start = currentPosition.character - start + 1
		end
		
		start = start or currentPosition.character
		
		local item: AutocompleteResponseItem = {
			label = index,
			detail = vType,
			kind = Enum.CompletionItemKind.Property,
			tags = {},
			textEdit = {
				newText = index,
				replace = {
					start = {
						line = currentPosition.line,
						character = start
					},
					['end'] = {
						line = currentPosition.line,
						character = currentPosition.character
					}
				}
			}
		}
		
		if vType == 'function' then
			local detail = getFunctionDetail(class, index)
			
			-- details that have ! at the end mean the function is marked as "locked"
			-- when a function is locked it won't show up in autocomplete depending on if its external or internal
			local isLockedMethod = detail:match('!$') ~= nil
			
			-- i'm not sure about this but its ok
			-- don't show externally set methods when assigning
			-- don't show interally set methods when calling
			if isLockedMethod == isFuncAssign then
				continue
			end
			
			detail = detail:gsub('!$', '')
			
			item.kind = Enum.CompletionItemKind.Function
			item.detail = index .. detail:gsub(' %->', ':')
			item.tags = {
				Enum.CompletionItemTag.AddParens,
				Enum.CompletionItemTag.PutCursorInParens,
				indexType == ':' and Enum.CompletionItemTag.TypeCorrect or Enum.CompletionItemTag.IncorrectIndexType,
			}
			
			if isFuncAssign then
				table.remove(item.tags, 1)
				table.remove(item.tags, 1)
				table.insert(item.tags, Enum.CompletionItemTag.PutCursorBeforeEnd)
				
				local _, editStart = string.find(currentLine, 'function .-:')
				
				local indent = getIndent(currentLine)
				local newText = `{index}{detail:match('(.-) %->')}\n{indent}\t\n{indent}end`
				
				item.textEdit = {
					newText = newText,
					replace = {
						start = {
							line = currentPosition.line,
							character = editStart + 1
						},
						['end'] = {
							line = currentPosition.line,
							character = currentPosition.character
						}
					}
				}
			elseif isVarAssign then
				local _, editStart = string.find(currentLine, '=%s*.-:')
				
				local returnType = detail:match('%-> (.+)$')
				
				if returnType ~= 'nil' then
					table.remove(item.tags, 1)
					table.remove(item.tags, 1)
					table.insert(item.tags, Enum.CompletionItemTag.PutCursorBeforeEnd)
					
					local newText = `{index}() :: {returnType}` -- cast type
					
					item.textEdit = {
						newText = newText,
						replace = {
							start = {
								line = currentPosition.line,
								character = editStart + 1
							},
							['end'] = {
								line = currentPosition.line,
								character = currentPosition.character
							}
						}
					}
				end
			end
		elseif indexType == ':' then
			item.tags = {Enum.CompletionItemTag.IncorrectIndexType}
		end
		
		table.insert(responseItems, item)
	end
	
	return responseItems
end

Editor.AutocompleteCallback = function(request: AutocompleteRequest, response: AutocompleteResponse): AutocompleteResponse
	local instance = request.textDocument.script
	local document = request.textDocument.document
	
	if not instance or not MacroManager.SearchFolder or not instance:IsDescendantOf(MacroManager.SearchFolder) then
		return response
	end
	
	local position = request.position
	
	Editor.CurrentDocument = document
	Editor.CurrentPosition = position
	
	local currentLine = document:GetLine()
	
	local env = Editor:GetSourceEnv() -- very poor simulation of an actual script environment
	
	for name, props in pairs(env.vars) do
		local indexType = currentLine:sub(1, position.character - 1):match(`{name}([.:])[%w_]*$`)
		
		if indexType == nil then
			continue
		end
		
		local items = Editor:GetClassItems(props.Type, indexType, props)
		
		if items then
			for _, item in items do
				table.insert(response.items, item)
			end
		end
	end
	
	if currentLine:match('Type%s*=%s*[\'"].-[\'"]') then -- type autocomplete
		local startIndex, endIndex = currentLine:find('[\'"].-[\'"]')
		
		for classType, classData in pairs(Editor.ClassTypes) do
			if classType == 'Macro' then -- Macro is not a valid item type, ignore it
				continue
			end
			
			local item: AutocompleteResponseItem = {
				textEdit = {
					newText = classType,
					replace = {
						start = {
							line = position.line,
							character = startIndex + 1
						},
						['end'] = {
							line = position.line,
							character = endIndex
						}
					}
				},
				
				label = classType,
				kind = Enum.CompletionItemKind.Text,
				detail = classData.Detail,
			}
			
			table.insert(response.items, item)
		end
	end
	
	local functionName = currentLine:match('function ([%w_]+)$')
	if functionName then
		for name, _ in pairs(env.vars) do
			local item = {
				label = name,
				textEdit = {
					newText = name,
					replace = {
						start = {
							line = position.line,
							character = position.character - #functionName
						},
						['end'] = {
							line = position.line,
							character = position.character
						}
					},
				}
			}
			
			table.insert(response.items, item)
		end
	end
	
	if not currentLine:match('.-%s*=%s*') then
		local source = document:GetText()
		local cursor = Editor:GetSourceCursor()
		
		local start, finish = Editor:FindDelimiterPair(cursor, '{}', 1)
		local inBrackets = (start and finish) and (start < cursor and finish > cursor) or false
		
		if inBrackets then
			local sub = source:sub(1, finish)
			local currentVar = nil
			
			for offset = start, 1, -1 do
				local var = sub:match('([%w_]+)%s*=%s*{', offset)
				
				if var and env.vars[var] then
					currentVar = env.vars[var]
					
					break
				end
			end
			
			if currentVar then
				local items = Editor:GetClassItems(currentVar.Type, '.', currentVar)
				
				if items then
					for _, item in items do
						table.insert(response.items, item)
					end
				end
			end
		end
	end
	
	return response
end

Editor:InitializeClasses()

return Editor