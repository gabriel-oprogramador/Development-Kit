require('Utils')

---@class FWorkspace
local workspace = {
	name = 'Workspace',
	location = './',
	projectFiles = 'Intermediate/ProjectFiles',
	binDir = 'Binaries/$(CONFIG)',
	objDir = 'Intermediate/Build/$(PROJECT_NAME)/$(CONFIG)',
	startProjectName = '',
	configurations = { 'Debug', 'Release' },
	platforms = { 'Windows', 'Linux' },
	projects = {},
	groups = {},
	filters = {}
}

---@type FProject
local projectCurrent = nil
local filterCurrent = 'Global'

function GetWorkspace()
	return workspace
end

function GetGeneratorType()
	return workspace.type
end

function GeneratorType(Type)
	local opts = {'Vs2019', 'Vs2022', 'Makefile'}
	if CheckValueInTable(opts, Type) then
		print('[ERROR] Type not valid! => ' .. Type)
	end
	workspace.type = Type
end

---@param Name string
---@return FWorkspace
function Workspace(Name)
	workspace.name = Name
	return workspace
end

---@param Configs table
function Configurations(Configs)
	workspace.configurations = Configs
end

---@param Platforms table
function Platforms(Platforms)
	workspace.platforms = Platforms
end

---@param Path string
function BinDir(Path)
	workspace.binDir = Path
end

---@param Path string
function ObjDir(Path)
	workspace.objDir = Path
end

---@param Name string
---@return FProject
function Project(Name)
	Filter() --Reset filter

	if not workspace.projects[Name] then
		---@class FProject
		local proj = {
			name = Name,
			guid = GenerateFakeGUID(),
			group = '',
			files = {},
			flags = {},
			defines = {},
			includeDirs = {},
			dependencies = {},
			libDirs = {},
			links = {},
			binDir = {},
			objDir = {},
		}
		workspace.projects[Name] = proj
	end
	projectCurrent = workspace.projects[Name]
	return workspace.projects[Name]
end

---@param Name string
function StartProject(Name)
	workspace.startProjectName = Name;
end

--- [Kind is used to define the type of binary]
---'ConsoleApp' => Open Command line program.
---'WindowedApp' => Program with graphical interface.
---'StaticLib' => Library for Estatica link.
---'SharedLib' => Library for Dynamic link.
---@param Kind string
function Kind(Kind)
	local opts = { 'ConsoleApp', 'WindowedApp', 'StaticLib', 'SharedLib' }
	if CheckValueInTable(opts, Kind) then
		projectCurrent.flags[filterCurrent] = projectCurrent.flags[filterCurrent] or {}
		projectCurrent.flags[filterCurrent]['Kind'] = Kind
		return
	end
	print('[ERROR] Kind is not valid! => ' .. Kind .. ' Filter:' .. filterCurrent)
end

--- On or Off
---@param Enable string
function Optimize(Enable)
	if Enable ~= 'On' and Enable ~= 'Off' then
		print('[ERROR] Symbol is not valid! => ' .. Enable .. ' Filter:' .. filterCurrent)
		return
	end
	projectCurrent.flags[filterCurrent] = projectCurrent.flags[filterCurrent] or {}
	projectCurrent.flags[filterCurrent]['Optimize'] = Enable
end

---@param Defines table
function Defines(Defines)
	projectCurrent.defines[filterCurrent] = projectCurrent.defines[filterCurrent] or {}
	for _, def in ipairs(Defines) do
		table.insert(projectCurrent.defines[filterCurrent], def)
	end
end

---@param Patterns table
function Files(Patterns)
	function AddFiles(Path, Extension, Recursive)
		local files = FindFilesFronType(Path, Extension, Recursive)
		for _, file in ipairs(files) do
			table.insert(projectCurrent.files, file)
		end
	end

	for _, pattern in ipairs(Patterns) do
		local ext = GetFileExtension(pattern)
		if pattern:match('/%*%*') then
			local path = pattern:match("^(.-)/?([^/]+%.%w+)$")
			AddFiles(path, ext, true)
		elseif pattern:match('/%*') then
			local path = pattern:match("^(.-)/?([^/]+%.%w+)$")
			AddFiles(path, ext, false)
		else
			table.insert(projectCurrent.files, pattern)
		end
	end
end

---@param IncludeDirs table
function IncludeDirs(IncludeDirs)
	projectCurrent.includeDirs[filterCurrent] = projectCurrent.includeDirs[filterCurrent] or {}
	for _, dirs in ipairs(IncludeDirs) do
		table.insert(projectCurrent.includeDirs[filterCurrent], dirs)
	end
end

---@param Dependencies table
function Dependencies(Dependencies)
	projectCurrent.dependencies[filterCurrent] = projectCurrent.dependencies[filterCurrent] or {}
	for _, deps in ipairs(Dependencies) do
		table.insert(projectCurrent.dependencies, deps)
	end
end

---@param LibDirs table
function LibDirs(LibDirs)
	projectCurrent.libDirs[filterCurrent] = projectCurrent.libDirs[filterCurrent] or {}
	for _, dir in ipairs(LibDirs) do
		table.insert(projectCurrent.libDirs[filterCurrent], dir)
	end
end

---@param Links table
function Links(Links)
	projectCurrent.links[filterCurrent] = projectCurrent.links[filterCurrent] or {}
	for _, link in ipairs(Links) do
		table.insert(projectCurrent.links[filterCurrent], link)
	end
end

--[Create or activate an existing filter]
--'Configurations:FilterName' => Configuration Filters
--'Platforms:FilterName' => Platform Filters
---@param FilterName string | nil
function Filter(FilterName)
	if not FilterName or FilterName == '' then
		filterCurrent = 'Global'
		return
	end

	local key, value = FilterName:match("^(.-):(.*)$")
	if not key or not value then
		print("Invalid filter format! (expected 'Key:Value') : " .. tostring(FilterName))
		filterCurrent = 'Global'
		return
	end

	local bValid = false
	if key == 'Configurations' and CheckValueInTable(workspace.configurations, value) then
		bValid = true
	elseif key == 'Platforms' and CheckValueInTable(workspace.platforms, value) then
		bValid = true
	else
		print("[ERROR] => Filter not exist! => " .. tostring(FilterName))
		filterCurrent = 'Global'
		return
	end

	if bValid then
		if not CheckValueInTable(workspace.filters, value) then
			table.insert(workspace.filters, value)
		end
		filterCurrent = value
	end
end

---@param Project FProject
function ShowProject(Project)
	print('/==========/ Project:' .. Project.name .. ' Group:' .. Project.group .. ' /==========/')
	print('GUID:' .. Project.guid)
	print('\n[BinDir]')
	for _, config in ipairs(workspace.configurations) do
		for _, platform in ipairs(workspace.platforms) do
			local output = workspace.binDir
			output = ReplaceMacro(output, 'CONFIG', tostring(config))
			output = ReplaceMacro(output, 'PLATFORM', tostring(platform))
			output = ReplaceMacro(output, 'PROJECT_NAME', tostring(projectCurrent.name))
			print('Property:' .. config .. '|' .. platform .. ' => Path:' .. output)
		end
	end
	print('\n[ObjDir]')
	for _, config in ipairs(workspace.configurations) do
		for _, platform in ipairs(workspace.platforms) do
			local output = workspace.objDir
			output = ReplaceMacro(output, 'CONFIG', tostring(config))
			output = ReplaceMacro(output, 'PLATFORM', tostring(platform))
			output = ReplaceMacro(output, 'PROJECT_NAME', tostring(projectCurrent.name))
			print('Property:' .. config .. '|' .. platform .. ' => Path:' .. output)
		end
	end

	print('\n[Flags]')
	for filter, settings in pairs(Project.flags) do
		local line = { 'Filter: ' .. filter .. ' => ' }
		for key, value in pairs(settings) do
			table.insert(line, key .. ':' .. tostring(value) .. ' ')
		end
		print(table.concat(line))
	end
	print('\n[Defines]')
	for filter, settings in pairs(Project.defines) do
		local line = { 'Filter: ' .. filter .. ' => ' }
		for _, value in ipairs(settings) do
			table.insert(line, tostring(value) .. ' ')
		end
		print(table.concat(line))
	end
	print('\n[IncludeDirs]')
	for filter, settings in pairs(Project.includeDirs) do
		local line = { 'Filter: ' .. filter .. ' => ' }
		for _, value in ipairs(settings) do
			table.insert(line, tostring(value) .. ' ')
		end
		print(table.concat(line))
	end
	print('\n[LibDirs]')
	for filter, settings in pairs(Project.libDirs) do
		local line = { 'Filter: ' .. filter .. ' => ' }
		for _, value in ipairs(settings) do
			table.insert(line, tostring(value) .. ' ')
		end
		print(table.concat(line))
	end

	print('\n[Links]')
	for filter, settings in pairs(Project.links) do
		local line = { 'Filter: ' .. filter .. ' => ' }
		for _, value in ipairs(settings) do
			table.insert(line, tostring(value) .. ' ')
		end
		print(table.concat(line))
	end

	print('\n[Dependencies]')
	for filter, settings in pairs(Project.dependencies) do
		local line = { 'Filter: ' .. filter .. ' => ' }
		for _, value in ipairs(settings) do
			table.insert(line, tostring(value) .. ' ')
		end
		print(table.concat(line))
	end

	print('\n[Files]')
	for _, file in ipairs(Project.files) do
		print('File -> ' .. file)
	end

	print('/==================/ Project /===================/\n')
end

function ShowState()
	print('\nWorkspace:' .. workspace.name)
	print('Configurations:' .. table.concat(workspace.configurations, ', '))
	print('Platforms:' .. table.concat(workspace.platforms, ', '))
	local projects = workspace.projects

	if workspace.startProjectName ~= '' then
		local projStart = projects[workspace.startProjectName]
		projects[workspace.startProjectName] = nil
		print('<<Start Project>>')
		ShowProject(projStart)
	end

	for _, proj in pairs(projects) do
		ShowProject(proj)
	end
end

