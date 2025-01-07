Workspace('Space-Attack')

Project('Space-Attack').group = 'Game'
IncludeDirs { 'Source/Engine', 'Source/Game' }
Files { 'Source/**.h', 'Source/**.cpp' }

Filter('Configurations:Debug')
Kind('ConsoleApp')
Optimize('Off')

Filter('Configurations:Release')
Kind('WindowedApp')
Optimize('On')

Filter('Platforms:Windows')
Defines { 'PLATFORM_WINDOWS' }

Filter('Platforms:Linux')
Defines { 'PLATFORM_LINUX' }

ShowState()
