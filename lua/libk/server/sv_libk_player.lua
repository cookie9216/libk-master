--Give player their db id or create entry if they don't have one
function LibK.playerInitialSpawn( ply )
	LibK.Player.findByPlayer( ply )
	:Then( function( dbPlayer )
		if not IsValid( ply ) then
			-- Player disconnected during join, do nothing
			return
		end

		if dbPlayer then
			dbPlayer.name = ply:Nick( ) 
			dbPlayer.steam64 = ply:SteamID64( )
			return dbPlayer:save( )
		else
			local dbPlayer = LibK.Player:new( )
			dbPlayer.name = ply:Nick( )
			dbPlayer.player = ply
			dbPlayer.steam64 = ply:SteamID64( )
			dbPlayer.uid = ply:UniqueID( )
			return dbPlayer:save( )
		end
	end )
	:Then( function( dbPlayer )
		if not IsValid( ply ) then
			-- Player disconnected during join, do nothing
			return
		end

		KLogf( 4, "[LibK] Player %s(id %i)", ply:Nick( ), dbPlayer.id )
		ply.libk_originalNick = ply:Nick( )
		ply.dbPlayer = dbPlayer
		ply.kPlayerId = dbPlayer.id
		ply:SetNWInt( "KPlayerId", dbPlayer.id )
		hook.Call( "LibK_PlayerInitialSpawn", GAMEMODE, ply, dbPlayer )
	end, function( errid, err )
		if not IsValid( ply ) then return end
		KLogf( 2, "[LibK] Error initializing player %s(%i: %s )", ply:Nick( ), errid, err )
	end )
end
hook.Add( "PlayerInitialSpawn", "LibKJoinPlayer", LibK.playerInitialSpawn )

-- change by cookie9216
local function libkApplyPlayerName(ply, newName)
	if not IsValid(ply) or not ply.dbPlayer then return end
	if ply.libk_originalNick == newName then return end
	KLogf( 4, "[LibK] Player %s changed name to %s", tostring(ply.libk_originalNick or ply:Nick()), tostring(newName) )
	ply.dbPlayer.name = newName
	ply.dbPlayer:save( )
	:Fail( function( errid, err )
		KLogf( 3, "[LibK] Error saving rename for %s(%i: %s)", tostring(ply.libk_originalNick), errid, err )
	end )
	ply.libk_originalNick = newName
end

function LibK.monitorNameChanges( )
	for k, v in pairs( player.GetAll( ) ) do
		libkApplyPlayerName(v, v:Nick())
	end
end

local libkNameEventSeen = false
gameevent.Listen("player_changename")
hook.Add("player_changename", "LibKMonitorNameChange", function(data)
	if not data then return end
	libkNameEventSeen = true
	local ply = player.GetByUserID and player.GetByUserID(data.userid) or nil
	if not IsValid(ply) then return end
	libkApplyPlayerName(ply, data.newname or ply:Nick())
end)
-- Slow fallback only until the engine name-change event has fired once.
timer.Create("LibKMonitorNameChangeFallback", 15, 0, function()
	if libkNameEventSeen then
		timer.Remove("LibKMonitorNameChangeFallback")
		return
	end
	if #player.GetAll() == 0 then return end
	LibK.monitorNameChanges()
end)
