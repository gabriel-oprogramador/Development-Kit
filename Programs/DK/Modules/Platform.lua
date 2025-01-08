local sys = {}

local windowsCmd = {
	mkdir = 'cmd.exe /c mkdir ',
	rmdir = 'rmdir /s /q ',
	checkPath = 'if exist "%s" (echo true) else (echo false)',
	findFilesType = 'dir "%s" /b /a | findstr "\\%s$"',
	findFilesTypeR = 'dir "%s" /b /s /a | findstr "\\%s$"',
	findFiles = 'dir "%s" /b /a ',
	findFilesR = 'dir "%s" /b /s /a ',
	copyDir = 'robocopy "%s" "%s" /E',
	moveDir = 'robocopy "%s" "%s" /E /MOVE',
	getAbs = 'for %%I in ("%s") do @echo %%~fI',
	isDir = 'dir "%s" 2>nul | find "DIR" >nul',
}

local linuxCmd = {
	mkdir = 'mkdir -p ',
	rmdir = 'rm -rf ',
	checkPath = 'test -d "%s" && echo true || echo false',
	findFilesType = 'find "%s" -maxdepth 1 -type f -name "*%s"',
	findFilesTypeR = 'find "$s" -type f -name "*%s"',
	findFiles = 'find "%s" -maxdepth 1 -type f ',
	findFilesR = 'find "%s" -type f ',
	copyDir = 'cp -r %s %s',
	moveDir = 'mv "%s" "%s"',
	getAbs = 'realpath "%s"',
	isDir = 'test -d "%s"',
}

local cmd = {
	mkdir = '',
	rmdir = '',
	checkPath = '',
	findFilesType = '',
	findFilesTypeR = '',
	findFiles = '',
	findFilesR = '',
	copyDir = '',
	moveDir = '',
	getAbs = '',
	isDir = '',
}

---@return string
function GetPlatform()
	local sep = package.config:sub(1, 1)
	if sep == "\\" then
		return "Windows"
	else
		return "Linux"
	end
end

local function SetPlatform()
	if GetPlatform() == 'Windows' then
		cmd = windowsCmd
	elseif GetPlatform() == 'Linux' then
		cmd = linuxCmd
	else
		error('Platform not supported!');
	end
end

SetPlatform();

---Check if the Directory exists
---@param Path string
function DirExists(Path)
	local command = string.format(cmd.checkPath, Path)
	local result = io.popen(command):read('*l')
	return result == 'true'
end

---@param Path string
---@return boolean
function IsDir(Path)
	local ext = GetFileExtension(Path)
	return (ext == nil) and true or false
end

---Make Directorie
---@param Path string
function MakeDir(Path)
	if DirExists(Path) then
		return;
	end
	local currentPath = ""
	for dir in string.gmatch(Path, "[^/\\]+") do
		currentPath = currentPath .. dir .. "/"
		if not DirExists(currentPath) then
			os.execute(cmd.mkdir .. '"' .. currentPath .. '"')
		end
	end
end

---@param Path string
function RemoveDir(Path)
	if not DirExists(Path) then
		return
	end
	os.execute(cmd.rmdir .. '"' .. Path .. '"');
end

function GetFilePath(FilePath)
	FilePath = FilePath:gsub("\\", "/")
	local dirPath = FilePath:match("(.*/)") or ""
	return dirPath:sub(1, -2)
end

---@param Path string
function GetAbsolutePath(Path)
	local command = string.format(cmd.getAbs, Path);
	local handle = io.popen(command);
	if handle == nil then
		return Path;
	end
	local result = handle:read("a");
	handle:close();
	local path = result:match("^%s*(.-)%s*$");
	path = path:gsub('\\', '/')
	return path
end

---@param From string
---@param To string
---@return string
function GetRelativePath(From, To)
	From = From:gsub("\\", "/")
	To = To:gsub("\\", "/")

	local fromParts = {}
	local toParts = {}

	for part in From:gmatch("([^/]+)") do
		table.insert(fromParts, part)
	end
	for part in To:gmatch("([^/]+)") do
		table.insert(toParts, part)
	end

	local i = 1
	while fromParts[i] == toParts[i] do
		i = i + 1
	end

	local relativePath = {}
	for j = i, #fromParts do
		table.insert(relativePath, "..")
	end

	for j = i, #toParts do
		table.insert(relativePath, toParts[j])
	end

	return table.concat(relativePath, "/")
end

---@FilePath string
---@return string
function GetFileExtension(FilePath)
	local ext = FilePath:match("^.+(%..+)$")
	return ext
end

function GetFileName(filePath)
	return filePath:match("^.+/(.+)$") or filePath:match("^.+\\(.+)$") or filePath
end

function GetFileBaseName(filePath)
	local fileName = GetFileName(filePath)
	return fileName:match("(.+)%..+$") or fileName
end

---@param FilePath string
---@param Types table
---@return boolean
function IsFileOfType(FilePath, Types)
	local ext = GetFileExtension(FilePath)
	for _, extH in ipairs(Types) do
		if ext == extH then
			return true
		end
	end
	return false
end

--@param Path string
---@param Type string
---@param Recursive boolean
---@return table
function FindFilesFronType(Path, Type, Recursive)
	local files = {};
	local command = ''
	if Recursive then
		command = string.format(cmd.findFilesTypeR, Path, Type)
	else
		command = string.format(cmd.findFilesType, Path, Type)
	end

	local file = io.popen(command);
	if file == nil then
		return files;
	end

	for fileName in file:lines() do
		fileName = fileName:gsub('\\', '/')
		fileName = string.match(fileName, "/(" .. Path .. "/(.*))") or Path .. '/' .. fileName
		table.insert(files, fileName);
	end
	file:close();
	return files;
end

function CopyFile(Path, Destiny, bMove)
	local file = io.open(Path, 'rb')
	if not file then
		print('File not loaded! -> ' .. Path)
		return
	end

	local content = file:read('*all')
	file:close()

	local outfile = io.open(Destiny, "wb")
	if not outfile then
		print('File not saved! -> ' .. Destiny)
		return
	end

	outfile:write(content)
	outfile:close()

	if not bMove then
		local result = os.remove(Path)
		if not result then
			print("Failed to remove the original file -> " .. Path)
			return false
		end
	end
end

function CopyDir(Path, Destiny)
	local command = string.format(cmd.copyDir, Path, Destiny)
	local p = io.popen(command)
	if not p then
		return
	end
	p:close()
end

function MoveDir(Path, Destiny)
	local command = string.format(cmd.moveDir, Path, Destiny)
	local p = io.popen(command)
	if not p then
		return
	end
	p:close()
end

local function IsDirectory(Path)
	local command = string.format(cmd.isDir, Path)
	return os.execute(command)
end

local function IsFile(Path)
	local file = io.open(Path, "rb")
	if file then
		file:close()
		return true
	end
	return false
end

---@param Source string
---@param Destiny string
function Copy(Source, Destiny)
	if IsDirectory(Source) then
		CopyDir(Source, Destiny)
	elseif IsFile(Source) then
		CopyFile(Source, Destiny, true)
	end
end

---@param Source string
---@param Destiny string
function Move(Source, Destiny)
	if IsDirectory(Source) then
		MoveDir(Source, Destiny)
	elseif IsFile(Source) then
		CopyFile(Source, Destiny, false)
	end
end

---@param Path string
---@param Content string
function NewFile(Path, Mode, Content)
	local file = io.open(Path, Mode)
	if not file then
		print("Failed to create file -> " .. Path)
		return;
	end
	file:write(Content)
	file:close()
end

function DeleteFile(Path)
	local result = os.remove(Path)
	if not result then
		print("Failed to delete file -> " .. Path)
		return false
	end
end
