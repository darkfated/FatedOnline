FatedOnline = FatedOnline or {}

local FileCl = SERVER and AddCSLuaFile or include
local FileSv = SERVER and include or function() end
local FileSh = function( Important )
	AddCSLuaFile( Important )

	return include( Important )
end

FileSh( 'fated_online/config.lua' )
FileSv( 'fated_online/server.lua' )
FileCl( 'fated_online/client.lua' )
FileCl( 'fated_online/menu.lua' )
