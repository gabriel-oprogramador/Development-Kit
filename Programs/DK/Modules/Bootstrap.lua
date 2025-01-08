require('Generator')
require('Platform')

function Generator(Args, Index)
	print('Generator')
	dofile('TargetRules.lua')
end

function MakeDirectory(Args, Index)
	local path = Args[Index + 1]
	MakeDir(path)
end

function RemoveDirectory(Args, Index)
	local path = Args[Index + 1]
	RemoveDir(path)
end

function CopyCommand(Args, Index)
	local src = Args[Index + 1]
	local dst = Args[Index + 2]
	Copy(src, dst)
end

function MoveCommand(Args, Index)
	local src = Args[Index + 1]
	local dst = Args[Index + 2]
	Move(src, dst)
end

function TouchCommand(Args, Index)
	local path = Args[Index + 1]
	local content = Args[Index + 2] or ''
	local mode = Args[Index + 3]
	if mode == 'append' then
		NewFile(path, 'a', content)
	else
		NewFile(path, 'w', content)
	end
end

function DeleteFileCommand(Args, Index)
	local path = Args[Index + 1]
	DeleteFile(path)
end

local commands = {
	['-G'] = Generator,
	['mkdir'] = MakeDirectory,
	['rmdir'] = RemoveDirectory,
	['cp'] = CopyCommand,
	['mv'] = MoveCommand,
	['rm'] = DeleteFileCommand,
	['touch'] = TouchCommand,
}

---@param Args table
function Init(Args)
	if #Args == 0 then
		print('Init args 0')
	end
	for index, arg in ipairs(Args) do
		local command = commands[arg]
		command(Args, index)
	end
end
