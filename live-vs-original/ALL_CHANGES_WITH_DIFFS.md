# Live vs Original — vollständige Diff-Texte (PS2 / LibK / PAC3)

Erstellt: 2026-08-18T18:28:41Z

---
## `LibK__addon.json`
```diff
--- /dev/null	2026-07-26 21:39:19.787270199 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_libk-master/addon.json	2026-08-14 12:16:57.641469986 +0000
@@ -0,0 +1,6 @@
+{
+  "title": "LibK",
+  "type": "ServerContent",
+  "tags": ["fun"],
+  "ignore": ["*.md", ".git*", ".vscode/*", "*.psd"]
+}
```

---
## `LibK__lua_libk_3rdparty_glib_transfers_transfers.lua`
```diff
--- /tmp/tmp.43tZj6uoTj/lua/libk/3rdparty/glib/transfers/transfers.lua	2023-12-04 12:02:22.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_libk-master/lua/libk/3rdparty/glib/transfers/transfers.lua	2026-08-18 16:45:35.744547042 +0000
@@ -222,10 +222,14 @@
 			end
 		end
 
+		-- change by cookie9216
+		local activeByUser = {}
 		for _, outboundTransfer in pairs (GLib.Transfers.OutboundTransfers) do
 			if not outboundTransfer:IsDestinationValid () then
 				GLib.Transfers.OutboundTransfers [outboundTransfer:GetDestinationId () .. "/" .. outboundTransfer:GetId ()] = nil
-			else
+			elseif not activeByUser [outboundTransfer:GetDestinationId ()] then
+				-- change by cookie9216
+				activeByUser [outboundTransfer:GetDestinationId ()] = true
 				local outBuffer = GLib.StringOutBuffer ()
 
 				local packet = vnet.CreatePacket("glib_transfer")
```

---
## `LibK__lua_libk_client_cl_libk_baseView.lua`
```diff
--- /tmp/tmp.43tZj6uoTj/lua/libk/client/cl_libk_baseView.lua	2023-12-04 12:02:22.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_libk-master/lua/libk/client/cl_libk_baseView.lua	2026-08-18 16:45:35.737546379 +0000
@@ -131,7 +131,7 @@
 		packet:Table( {...} )
 	packet:AddServer( )
 	packet:Send( )
-	dp("send ", strAction)
+	-- change by cookie9216
 end
 
 function BaseView:controllerTransaction( strAction, ... )
@@ -148,7 +148,7 @@
 		packet:Table( { ... } )
 	packet:AddServer( )
 	packet:Send( )
-	dp("send ", strAction)
+	-- change by cookie9216
 	
 	return def:Promise( )
 end
```

---
## `LibK__lua_libk_server_sv_libk_model.lua`
```diff
--- /tmp/tmp.43tZj6uoTj/lua/libk/server/sv_libk_model.lua	2023-12-04 12:02:22.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_libk-master/lua/libk/server/sv_libk_model.lua	2026-08-18 16:45:35.768549315 +0000
@@ -5,6 +5,13 @@
 	if not DATABASES[db] then
 		KLogf( 2, "Odd Error in DB, invalid database %s", db )
 		debug.Trace( )
+		-- change by cookie9216
+		local def = Deferred and Deferred() or nil
+		if def and def.Reject then
+			def:Reject( -2, "Database " .. tostring( db ) .. " has not been initialized" )
+			return def:Promise()
+		end
+		return
 	end
 	return DATABASES[db].Query( ... )
 end
@@ -13,9 +20,13 @@
 	if not db or not str then
 		KLogf( 2, "Odd Error in DB Escape, connection dead? %s, %s", not db and "No DB" or "DB", not str and "NO String" or "String" )
 		debug.Trace( )
+		-- change by cookie9216
+		error( "LibK escape: missing database or string" )
 	end
 	if not DATABASES[db] then
 		KLogf( 2, "Odd Error in DB, invalid database %s", db )
+		-- change by cookie9216
+		error( "LibK escape: database has not been initialized: " .. tostring( db ) )
 	end
 	return DATABASES[db].SQLStr( str )
 end
@@ -69,7 +80,24 @@
 	end
 	local database = DATABASES[class.DB]
 	if not database then
-		return Promise.Reject( -2, "Database " .. class.DB .. " has not been initialized" )
+		-- change by cookie9216
+		local def = Deferred()
+		local timerName = "LibK_WaitDB_" .. tostring(class.name)
+		local tries = 0
+		timer.Create(timerName, 0.25, 40, function()
+			tries = tries + 1
+			if DATABASES[class.DB] then
+				timer.Remove(timerName)
+				initializeTable(class)
+					:Done(function(...) def:Resolve(...) end)
+					:Fail(function(...) def:Reject(...) end)
+			elseif tries >= 40 then
+				timer.Remove(timerName)
+				KLogf( 2, "Database %s was not initialized after waiting for model %s", tostring(class.DB), tostring(class.name) )
+				def:Reject(-2, "Database " .. class.DB .. " has not been initialized")
+			end
+		end)
+		return def:Promise()
 	end
 
 	local sqlStr, modelsRequired = class.static.getCreateTableStatement( DATABASES[class.DB].CONNECTED_TO_MYSQL )
@@ -195,6 +223,10 @@
 			class.static.model.fields[fieldname] == "time" then
 
 			local db = DATABASES[class.DB]
+			-- change by cookie9216
+			if not db then
+				return string.format( "`%s`.`%s` AS `%s.%s`", tableNameOverride, fieldname, alias, fieldname )
+			end
 			if db.CONNECTED_TO_MYSQL then
 				return string.format( "UNIX_TIMESTAMP( `%s`.`%s` ) AS `%s.%s`",
 					tableNameOverride,
```

---
## `LibK__lua_libk_server_sv_libk_player.lua`
```diff
--- /tmp/tmp.43tZj6uoTj/lua/libk/server/sv_libk_player.lua	2023-12-04 12:02:22.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_libk-master/lua/libk/server/sv_libk_player.lua	2026-08-18 16:45:35.767549220 +0000
@@ -33,22 +33,46 @@
 		ply:SetNWInt( "KPlayerId", dbPlayer.id )
 		hook.Call( "LibK_PlayerInitialSpawn", GAMEMODE, ply, dbPlayer )
 	end, function( errid, err )
+		if not IsValid( ply ) then return end
 		KLogf( 2, "[LibK] Error initializing player %s(%i: %s )", ply:Nick( ), errid, err )
 	end )
 end
 hook.Add( "PlayerInitialSpawn", "LibKJoinPlayer", LibK.playerInitialSpawn )
 
+-- change by cookie9216
+local function libkApplyPlayerName(ply, newName)
+	if not IsValid(ply) or not ply.dbPlayer then return end
+	if ply.libk_originalNick == newName then return end
+	KLogf( 4, "[LibK] Player %s changed name to %s", tostring(ply.libk_originalNick or ply:Nick()), tostring(newName) )
+	ply.dbPlayer.name = newName
+	ply.dbPlayer:save( )
+	:Fail( function( errid, err )
+		KLogf( 3, "[LibK] Error saving rename for %s(%i: %s)", tostring(ply.libk_originalNick), errid, err )
+	end )
+	ply.libk_originalNick = newName
+end
+
 function LibK.monitorNameChanges( )
 	for k, v in pairs( player.GetAll( ) ) do
-		if v:Nick( ) != v.libk_originalNick and v.dbPlayer then
-			KLogf( 4, "[LibK] Player %s changed name to %s", v.libk_originalNick, v:Nick( ) )
-			v.dbPlayer.name = v:Nick( )
-			v.dbPlayer:save( )
-			:Fail( function( errid, err )
-				KLogf( 3, "[LibK] Error saving rename for %s(%i: %s)", v.libk_originalNick, errid, err )
-			end )
-			v.libk_originalNick = v:Nick( )
-		end
+		libkApplyPlayerName(v, v:Nick())
 	end
 end
-hook.Add( "Think", "LibKMonitorNameChange", LibK.monitorNameChanges )
+
+local libkNameEventSeen = false
+gameevent.Listen("player_changename")
+hook.Add("player_changename", "LibKMonitorNameChange", function(data)
+	if not data then return end
+	libkNameEventSeen = true
+	local ply = player.GetByUserID and player.GetByUserID(data.userid) or nil
+	if not IsValid(ply) then return end
+	libkApplyPlayerName(ply, data.newname or ply:Nick())
+end)
+-- Slow fallback only until the engine name-change event has fired once.
+timer.Create("LibKMonitorNameChangeFallback", 15, 0, function()
+	if libkNameEventSeen then
+		timer.Remove("LibKMonitorNameChangeFallback")
+		return
+	end
+	if #player.GetAll() == 0 then return end
+	LibK.monitorNameChanges()
+end)
```

---
## `LibK__lua_libk_server_sv_libk_server.lua`
```diff
--- /tmp/tmp.43tZj6uoTj/lua/libk/server/sv_libk_server.lua	2023-12-04 12:02:22.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_libk-master/lua/libk/server/sv_libk_server.lua	2026-08-18 16:45:35.767549220 +0000
@@ -8,12 +8,18 @@
 --Used to ensure something runs after Initialize
 LibK.InitializePromise = Deferred( )
 hook.Add( "Initialize", "LibK_Initialize", function( )
-	LibK.InitializePromise:Resolve( )
+	-- change by cookie9216
+	if getPromiseState( LibK.InitializePromise ) == "pending" then
+		LibK.InitializePromise:Resolve( )
+	end
 end )
 
 LibK.InitPostEntityPromise = Deferred( )
 hook.Add( "InitPostEntity", "LibK_InitPostEntity", function( )
-	LibK.InitPostEntityPromise:Resolve( )
+	-- change by cookie9216
+	if getPromiseState( LibK.InitPostEntityPromise ) == "pending" then
+		LibK.InitPostEntityPromise:Resolve( )
+	end
 end )
 hook.Add( "OnReloaded", "LibK_InitPostEntity", function()
 	if getPromiseState(LibK.InitPostEntityPromise) == "pending" then
```

---
## `LibK__lua_libk_server_sv_permissionInterface.lua`
```diff
--- /tmp/tmp.43tZj6uoTj/lua/libk/server/sv_permissionInterface.lua	2023-12-04 12:02:22.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_libk-master/lua/libk/server/sv_permissionInterface.lua	2026-08-18 16:45:35.768549315 +0000
@@ -13,7 +13,8 @@
 	elseif ulx then
 		ulx.banid( admin, steam, time, reason )
 	elseif sam then
-		sam.player.ban_id( ply, time, reason, IsValid(admin) and admin:SteamID() )
+		-- change by cookie9216
+		sam.player.ban_id( steam, time, reason, IsValid(admin) and admin:SteamID() )
 	end
 end
 
@@ -43,7 +44,8 @@
 function PermissionInterface.printIfPermission( permission, fmtstring, ... )
 	local message = string.format( fmtstring, ... )
 	for k, v in pairs( player.GetAll( ) ) do
-		if PermissionInterface.query( permission, v ) then
+		-- change by cookie9216
+		if PermissionInterface.query( v, permission ) then
 			v:PrintMessage( HUD_PRINTTALK, message )
 		end
 	end
```

---
## `LibK__lua_libk_shared_sh_permissionInterface.lua`
```diff
--- /tmp/tmp.43tZj6uoTj/lua/libk/shared/sh_permissionInterface.lua	2023-12-04 12:02:22.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_libk-master/lua/libk/shared/sh_permissionInterface.lua	2026-08-18 16:45:35.769549410 +0000
@@ -52,7 +52,8 @@
 	local ranks = { } --internalName: string, title: string
 	if ULib then
 		for internalName, rankInfo in pairs( ULib.ucl.groups ) do
-			if v != ULib.ACCESS_ALL then
+			-- change by cookie9216
+			if internalName != ULib.ACCESS_ALL then
 				table.insert( ranks, { internalName = internalName, title = internalName } )
 			end
 		end
```

---
## `LibK__lua_libk_shared_sh_thirdparty.lua`
```diff
--- /tmp/tmp.43tZj6uoTj/lua/libk/shared/sh_thirdparty.lua	2023-12-04 12:02:22.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_libk-master/lua/libk/shared/sh_thirdparty.lua	2026-08-18 16:45:35.768549315 +0000
@@ -187,4 +187,4 @@
 LibK.loadThirdparty( "version", "kikito", "libk/3rdparty", "", "semver.lua" )
 AddCSLuaFile( "libk/3rdparty/semver.lua" )
 
-print("LibK uses vnet by vercas (Copyright 2014 Alexandru-Mihai Maftei), MIT licensed")
+-- change by cookie9216
```

---
## `PAC3__lua_pac3_core_client_base_part.lua`
```diff
--- /tmp/tmp.aoqOpC7GAY/lua/pac3/core/client/base_part.lua	2026-05-06 23:34:10.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_pac3-master/lua/pac3/core/client/base_part.lua	2026-08-18 16:45:35.774549884 +0000
@@ -13,6 +13,9 @@
 local NULL = NULL
 local table_insert = table.insert
 
+-- change by cookie9216
+local warn_unique_id_collisions = CreateClientConVar("pac_warn_unique_id_collisions", "0", true, false, "Print a message when PAC UniqueIDs collide")
+
 local BUILDER, PART = pac.PartTemplate()
 
 PART.ClassName = "base"
@@ -123,7 +126,10 @@
 		local existing = pac.GetPartFromUniqueID(self:GetPlayerOwnerId(), id)
 
 		if existing:IsValid() then
-			pac.Message(Color(255, 50, 50), "unique id collision between ", self, " and ", existing)
+			-- change by cookie9216
+			if warn_unique_id_collisions:GetBool() then
+				pac.Message(Color(255, 50, 50), "unique id collision between ", self, " and ", existing)
+			end
 			id = nil
 		end
 	end
```

---
## `PAC3__lua_pac3_core_client_init.lua`
```diff
--- /tmp/tmp.aoqOpC7GAY/lua/pac3/core/client/init.lua	2026-05-06 23:34:10.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_pac3-master/lua/pac3/core/client/init.lua	2026-08-18 16:45:35.774549884 +0000
@@ -45,6 +45,9 @@
 
 include("pac3/core/shared/init.lua")
 
+-- change by cookie9216
+include("security_client.lua")
+
 pac.urltex = include("pac3/libraries/urltex.lua")
 
 include("parts.lua")
```

---
## `PAC3__lua_pac3_core_client_integration_tools.lua`
```diff
--- /tmp/tmp.aoqOpC7GAY/lua/pac3/core/client/integration_tools.lua	2026-05-06 23:34:10.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_pac3-master/lua/pac3/core/client/integration_tools.lua	2026-08-18 16:45:35.776550073 +0000
@@ -6,18 +6,28 @@
 	local part_data = table.Copy(part_data)
 	base = base or tostring(part_data)
 
+	-- change by cookie9216
 	local function fixpart(part)
-		for key, val in pairs(part.self) do
-			if val ~= "" and (key == "UniqueID" or key:sub(-3) == "UID") then
-				part.self[key] = pac.Hash(base .. val)
+		if not part then return end
+		if istable(part.self) then
+			for key, val in pairs(part.self) do
+				if val ~= "" and (key == "UniqueID" or key:sub(-3) == "UID") then
+					part.self[key] = pac.Hash(base .. val)
+				end
 			end
 		end
-
-		for _, part in pairs(part.children) do
-			fixpart(part)
+		for _, child in pairs(part.children or {}) do
+			fixpart(child)
+		end
+		for key, child in pairs(part) do
+			if key ~= "self" and key ~= "children" and istable(child) then
+				fixpart(child)
+			end
 		end
 	end
 
+	fixpart(part_data)
+
 	return part_data
 end
 
```

---
## `PAC3__lua_pac3_core_client_part_pool.lua`
```diff
--- /tmp/tmp.aoqOpC7GAY/lua/pac3/core/client/part_pool.lua	2026-05-06 23:34:10.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_pac3-master/lua/pac3/core/client/part_pool.lua	2026-08-18 16:45:35.777550168 +0000
@@ -33,6 +33,16 @@
 	end)
 end
 
+-- change by cookie9216
+local function pac_ShouldHideRagdoll(rag)
+	if pac.Security and pac.Security.KeepTTTCorpsesVisible and pac.Security.KeepTTTCorpsesVisible() then
+		if pac.Security.IsTTTPlayerCorpse(rag) then
+			return false
+		end
+	end
+	return true
+end
+
 function pac.ForceRendering(b)
 	force_rendering = b
 	if b then
@@ -840,6 +850,8 @@
 					local rag = ply.pac_ragdoll
 
 					if IsValid(rag) and (ply.pac_death_hide_ragdoll or ply.pac_draw_player_on_death) then
+						-- change by cookie9216
+						if pac_ShouldHideRagdoll(rag) then
 						rag:SetRenderMode(RENDERMODE_TRANSALPHA)
 
 						local c = rag:GetColor()
@@ -854,6 +866,8 @@
 						if ply.pac_draw_player_on_death then
 							ply:DrawModel()
 						end
+						-- change by cookie9216
+						end
 					end
 
 					if radius < 32 then
```

---
## `PAC3__lua_pac3_core_client_parts_effect.lua`
```diff
--- /tmp/tmp.aoqOpC7GAY/lua/pac3/core/client/parts/effect.lua	2026-05-06 23:34:10.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_pac3-master/lua/pac3/core/client/parts/effect.lua	2026-08-18 16:45:35.781550547 +0000
@@ -77,6 +77,9 @@
 local alreadyServer = {}
 local function pac_request_precache(name)
 	if already[name] then return end
+	-- change by cookie9216
+	if (pac.EffectsBlackListLookup and pac.EffectsBlackListLookup[name])
+		or name == "impact_grass" or name == "impact_plastic" then return end
 	already[name] = true
 	PrecacheParticleSystem(name)
 	net.Start("pac_request_precache")
```

---
## `PAC3__lua_pac3_core_client_security_client.lua`
```diff
--- /dev/null	2026-07-26 21:39:19.787270199 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_pac3-master/lua/pac3/core/client/security_client.lua	2026-08-18 16:45:35.775549978 +0000
@@ -0,0 +1,57 @@
+-- change by cookie9216
+
+if not CLIENT then return end
+
+local lastDeny = 0
+
+local function denyMessage()
+	if CurTime() - lastDeny < 3 then return end
+	lastDeny = CurTime()
+	local privilege = pac.Security.GetString("Editor", "PrivilegeName", "pac3.open_editor")
+	local msg = pac.Security.Phrase("editor_restricted", LocalPlayer(), privilege)
+	if chat and chat.AddText then
+		chat.AddText(Color(255, 120, 120), "[PAC3] ", color_white, msg)
+	end
+end
+
+hook.Add("PrePACEditorOpen", "pac3_security_editor_acl", function(ply)
+	if pac.Security.PlayerCanOpenEditor(ply or LocalPlayer()) then
+		-- change by cookie9216
+		if not timer.Exists("pac3_security_editor_acl_close") then
+			timer.Create("pac3_security_editor_acl_close", 2, 0, function()
+				if not pac.Security.LimitsEnabled() then return end
+				if not pac.Security.GetBool("Editor", "RestrictOpen", true) then
+					timer.Remove("pac3_security_editor_acl_close")
+					return
+				end
+				if not pace or not pace.IsActive or not pace.IsActive() then
+					timer.Remove("pac3_security_editor_acl_close")
+					return
+				end
+				if pac.Security.PlayerCanOpenEditor(LocalPlayer()) then return end
+				if pace.CloseEditor then pace.CloseEditor() end
+				denyMessage()
+			end)
+		end
+		return
+	end
+	denyMessage()
+	return false
+end)
+
+hook.Add("CreateEntityRagdoll", "pac3_security_ttt_corpse", function(_, rag)
+	if not pac.Security.KeepTTTCorpsesVisible() then return end
+	timer.Simple(0, function()
+		if not IsValid(rag) then return end
+		if not pac.Security.IsTTTPlayerCorpse(rag) then return end
+		rag:SetNoDraw(false)
+		rag:DrawShadow(true)
+		local c = rag:GetColor()
+		if c.a ~= 255 then
+			c.a = 255
+			rag:SetColor(c)
+		end
+		rag:SetRenderMode(RENDERMODE_NORMAL)
+	end)
+end)
+
```

---
## `PAC3__lua_pac3_core_server_effects.lua`
```diff
--- /tmp/tmp.aoqOpC7GAY/lua/pac3/core/server/effects.lua	2026-05-06 23:34:10.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_pac3-master/lua/pac3/core/server/effects.lua	2026-08-18 16:45:35.797552062 +0000
@@ -7,8 +7,16 @@
 	"citadel_shockwave",
 	"choreo_launch_rocket_start",
 	"choreo_launch_rocket_jet",
+	-- change by cookie9216
+	"impact_grass",
+	"impact_plastic",
 }
 
+pac.EffectsBlackListLookup = {}
+for _, name in ipairs(pac.EffectsBlackList) do
+	pac.EffectsBlackListLookup[name] = true
+end
+
 if not pac_loaded_particle_effects then
 	pac_loaded_particle_effects = {}
 	local files = file.Find("particles/*.pcf", "GAME")
@@ -28,16 +36,21 @@
 util.AddNetworkString("pac_request_precache")
 
 function pac.PrecacheEffect(name)
+	-- change by cookie9216
+	if pac.EffectsBlackListLookup and pac.EffectsBlackListLookup[name] then return end
 	PrecacheParticleSystem(name)
 	net.Start("pac_effect_precached")
 	net.WriteString(name)
 	net.Broadcast()
 end
 
+-- change by cookie9216
 local queue = {}
 net.Receive("pac_request_precache", function(len, pl)
+	if not IsValid(pl) or not pl:IsPlayer() then return end
 	local name = net.ReadString()
-	if table.HasValue(pac.EffectsBlackList, name) then return end
+	if not isstring(name) or name == "" or #name > 128 then return end
+	if pac.EffectsBlackListLookup and pac.EffectsBlackListLookup[name] then return end
 
 	-- Each player gets a 50 length queue
 	local plqueue = queue[pl]
@@ -47,6 +60,10 @@
 		plqueue = {name}
 		queue[pl] = plqueue
 		local function processQueue()
+			if not IsValid(pl) then
+				queue[pl] = nil
+				return
+			end
 			if #plqueue == 0 then
 				queue[pl] = nil
 			else
@@ -57,3 +74,7 @@
 		processQueue()
 	end
 end)
+
+hook.Add("PlayerDisconnected", "pac3_precache_queue_cleanup", function(pl)
+	queue[pl] = nil
+end)
```

---
## `PAC3__lua_pac3_core_server_init.lua`
```diff
--- /tmp/tmp.aoqOpC7GAY/lua/pac3/core/server/init.lua	2026-05-06 23:34:10.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_pac3-master/lua/pac3/core/server/init.lua	2026-08-18 16:45:35.797552062 +0000
@@ -22,6 +22,10 @@
 
 include("pac3/core/shared/init.lua")
 
+-- change by cookie9216
+include("security_validate.lua")
+include("security_policy.lua")
+
 include("effects.lua")
 include("event.lua")
 include("net_messages.lua")
```

---
## `PAC3__lua_pac3_core_server_security_policy.lua`
```diff
--- /dev/null	2026-07-26 21:39:19.787270199 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_pac3-master/lua/pac3/core/server/security_policy.lua	2026-08-18 16:45:35.797552062 +0000
@@ -0,0 +1,153 @@
+-- change by cookie9216
+
+if not SERVER then return end
+
+local function set_cvar(name, value)
+	local cv = GetConVar(name)
+	if not cv then return end
+	local target = tostring(value)
+	if cv:GetString() ~= target then
+		cv:SetString(target)
+	end
+end
+
+local function clear_pac_movement(ply)
+	if not IsValid(ply) then return end
+	ply.pac_movement = nil
+	ply.scale_mass = 1
+	local phys = ply:GetPhysicsObject()
+	if IsValid(phys) then
+		phys:SetMass(85)
+	end
+end
+
+local function block_pac_movement_net()
+	if not pac.Security.LimitsEnabled() then return end
+	if not pac.Security.GetBool("Policy", "ForceDisableMovement", true) then return end
+
+	net.Receive("pac_modify_movement", function(_, ply)
+		if not IsValid(ply) or not ply:IsPlayer() then return end
+		clear_pac_movement(ply)
+		pac.Security.NotifyBlocked(ply, "movement_net", pac.Security.Phrase("movement_blocked", ply))
+	end)
+end
+
+local function apply_policy()
+	if not pac.Security.LimitsEnabled() then return end
+
+	if pac.Security.GetBool("Policy", "BlockPlayerModelRewrite", true) then
+		set_cvar("pac_modifier_model", 0)
+	end
+	if pac.Security.GetBool("Policy", "BlockPlayerResize", true) then
+		set_cvar("pac_modifier_size", 0)
+	end
+	if pac.Security.GetBool("URL", "BlockRemoteModelUrls", true) then
+		set_cvar("pac_allow_mdl", 0)
+		set_cvar("pac_allow_mdl_entity", 0)
+		set_cvar("sv_pac_webcontent_allow_no_content_length", 0)
+	end
+	if pac.Security.GetBool("Policy", "ForceDisablePropOutfits", true) then
+		set_cvar("pac_sv_prop_outfits", 0)
+	end
+
+	set_cvar("pac_submit_spam", 1)
+	set_cvar("pac_submit_limit", tostring(math.floor(pac.Security.GetNumber("Network", "MaxRequestsPerWindow", 8))))
+
+	if pac.Security.GetBool("Policy", "ForceDisableCombat", true) then
+		set_cvar("pac_to_contraption_allow", 0)
+		set_cvar("pac_sv_projectiles", 0)
+		set_cvar("pac_sv_projectile_allow_custom_collision_mesh", 0)
+		set_cvar("pac_sv_health_modifier", 0)
+		set_cvar("pac_sv_health_modifier_allow_maxhp", 0)
+		set_cvar("pac_sv_health_modifier_extra_bars", 0)
+		set_cvar("pac_sv_damage_zone", 0)
+		set_cvar("pac_sv_damage_zone_allow_dissolve", 0)
+		set_cvar("pac_sv_damage_zone_allow_ragdoll_hitparts", 0)
+		set_cvar("pac_sv_force", 0)
+		set_cvar("pac_sv_hitscan", 0)
+		set_cvar("pac_sv_lock", 0)
+		set_cvar("pac_sv_lock_teleport", 0)
+		set_cvar("pac_sv_lock_grab", 0)
+		set_cvar("pac_sv_lock_aim", 0)
+		set_cvar("pac_sv_lock_allow_grab_ply", 0)
+		set_cvar("pac_sv_lock_allow_grab_npc", 0)
+		set_cvar("pac_sv_lock_allow_grab_ent", 0)
+		set_cvar("pac_sv_nearest_life", 0)
+		set_cvar("pac_sv_nearest_life_allow_sampling_from_parts", 0)
+		set_cvar("pac_sv_nearest_life_allow_bones", 0)
+		set_cvar("pac_sv_nearest_life_allow_targeting_players", 0)
+		set_cvar("pac_sv_block_combat_features_on_next_restart", 2)
+		set_cvar("pac_sv_combat_whitelisting", 1)
+		set_cvar("pac_sv_combat_enforce_netrate", 250)
+		set_cvar("pac_sv_combat_enforce_netrate_buffersize", 8)
+		set_cvar("pac_sv_combat_distance_enforced", 1024)
+		set_cvar("pac_sv_combat_enforce_netrate_monitor_serverside", 0)
+	end
+
+	if pac.Security.GetBool("Policy", "ForceDisableMovement", true) then
+		set_cvar("pac_player_movement_allow_mass", 0)
+		set_cvar("pac_free_movement", 0)
+		block_pac_movement_net()
+	end
+end
+
+local function register_editor_privilege()
+	local privilege = pac.Security.GetString("Editor", "PrivilegeName", "pac3.open_editor")
+	if ULib and ULib.ucl and ULib.ucl.registerAccess then
+		ULib.ucl.registerAccess(privilege, ULib.ACCESS_SUPERADMIN, "Open the PAC3 editor.", "PAC3")
+	end
+	if CAMI and CAMI.RegisterPrivilege then
+		CAMI.RegisterPrivilege({
+			Name = privilege,
+			MinAccess = "superadmin",
+			Description = "Open the PAC3 editor.",
+		})
+	end
+end
+
+hook.Add("Initialize", "pac3_security_policy_init", function()
+	register_editor_privilege()
+	apply_policy()
+end)
+hook.Add("InitPostEntity", "pac3_security_policy_post", apply_policy)
+
+timer.Simple(0, apply_policy)
+timer.Simple(1, apply_policy)
+timer.Simple(5, apply_policy)
+
+hook.Add("PACMutateEntity", "pac3_security_block_mutations", function(owner, ent, class_name, ...)
+	if not pac.Security.LimitsEnabled() then return end
+	if not IsValid(owner) then return end
+
+	if class_name == "model" then
+		local path = ...
+		if pac.Security.GetBool("URL", "BlockRemoteModelUrls", true) and isstring(path) and string.find(path, "^https?://") then
+			pac.Security.NotifyBlocked(owner, "remote_model_url", pac.Security.Phrase("remote_model_url", owner))
+			return false
+		end
+		if pac.Security.GetBool("Policy", "BlockPlayerModelRewrite", true) and IsValid(ent) and ent:IsPlayer() then
+			pac.Security.NotifyBlocked(owner, "player_model_rewrite", pac.Security.Phrase("player_model_rewrite", owner))
+			return false
+		end
+	end
+
+	if class_name == "size" and pac.Security.GetBool("Policy", "BlockPlayerResize", true) and IsValid(ent) and ent:IsPlayer() then
+		pac.Security.NotifyBlocked(owner, "player_resize", pac.Security.Phrase("player_resize", owner))
+		return false
+	end
+end)
+
+hook.Add("PACCanPlayerModify", "pac3_security_foreign_entity", function(ply, ent)
+	if not pac.Security.LimitsEnabled() then return end
+	if not pac.Security.GetBool("Policy", "ForceDisablePropOutfits", true) then return end
+	if not IsValid(ply) or not IsValid(ent) then return false end
+	if ply == ent then return true end
+	return false
+end)
+
+hook.Add("PlayerSpawn", "pac3_security_clear_movement", function(ply)
+	if pac.Security.GetBool("Policy", "ForceDisableMovement", true) then
+		clear_pac_movement(ply)
+	end
+end)
+
```

---
## `PAC3__lua_pac3_core_server_security_validate.lua`
```diff
--- /dev/null	2026-07-26 21:39:19.787270199 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_pac3-master/lua/pac3/core/server/security_validate.lua	2026-08-18 16:45:35.798552157 +0000
@@ -0,0 +1,352 @@
+-- change by cookie9216
+
+if not SERVER then return end
+
+pac.Security = pac.Security or {}
+
+local wear_times = {}
+local validation_cache = {}
+local cache_count = 0
+local warned = {}
+
+local function cfg()
+	return pac.Security.Get()
+end
+
+local function phrase(owner, key, ...)
+	if pac.Security.Phrase then
+		return pac.Security.Phrase(key, owner, ...)
+	end
+	return key
+end
+
+
+local function notify_once(ply, key, msg)
+	if not pac.Security.GetBool("Policy", "NotifyBlocked", true) then return end
+	if not IsValid(ply) or not ply:IsPlayer() then return end
+	warned[ply] = warned[ply] or {}
+	local now = CurTime()
+	if (warned[ply][key] or 0) > now then return end
+	warned[ply][key] = now + 3
+	ply:ChatPrint("[PAC3] " .. tostring(msg))
+end
+
+local function log_blocked(ply, key, msg)
+	if not pac.Security.GetBool("Policy", "LogBlocked", true) then return end
+	if not IsValid(ply) then return end
+	warned[ply] = warned[ply] or {}
+	local now = CurTime()
+	local log_key = "log_" .. tostring(key or "generic")
+	if (warned[ply][log_key] or 0) > now then return end
+	warned[ply][log_key] = now + 8
+	MsgC(Color(255, 170, 90), "[PAC3] ", color_white,
+		string.format("Blocked (%s / %s): %s\n", ply:Nick() or "?", ply:SteamID() or "?", tostring(msg or "unknown")))
+end
+
+local function normalize_path(str)
+	if not isstring(str) then return "" end
+	str = string.gsub(str, "\\", "/")
+	str = string.lower(str)
+	return str
+end
+
+local function is_remote_or_invalid_path(str)
+	str = normalize_path(str)
+	if str == "" then return false end
+	if string.find(str, "https?://") then return true end
+	if string.find(str, "^data:") then return true end
+	if string.find(str, "^obj:") then return true end
+	if string.find(str, "^asset://") then return true end
+	if string.find(str, "^url:") then return true end
+	if string.find(str, "..", 1, true) then return true end
+	if string.find(str, "//", 1, true) then return true end
+	if string.find(str, "\n", 1, true) or string.find(str, "\r", 1, true) then return true end
+	return false
+end
+
+local function is_safe_model_path(str)
+	str = normalize_path(str)
+	if str == "" then return true end
+	if is_remote_or_invalid_path(str) then return false end
+	local maxLen = pac.Security.GetNumber("URL", "MaxLengthChars", 2048)
+	if #str > maxLen then return false end
+	if not string.find(str, "%.mdl$") then return false end
+	return string.find(str, "^models/") ~= nil
+end
+
+local function is_safe_material_path(str)
+	str = normalize_path(str)
+	if str == "" then return true end
+	if is_remote_or_invalid_path(str) then return false end
+	local maxLen = pac.Security.GetNumber("URL", "MaxLengthChars", 2048)
+	if #str > maxLen then return false end
+	return not string.find(str, "[:*?\"<>|]", 1)
+end
+
+local function split_semicolon_list(str)
+	if not isstring(str) or str == "" then return nil end
+	return string.Explode(";", str, false)
+end
+
+local function read_vec_component(vec, key, index, fallback)
+	if not istable(vec) then return fallback end
+	local val = vec[key]
+	if val == nil then val = vec[index] end
+	val = tonumber(val)
+	if val == nil then return fallback end
+	return val
+end
+
+local function validate_node(node, state, owner, depth)
+	if not istable(node) or not istable(node.self) then
+		return false, phrase(owner, "invalid_structure")
+	end
+
+	depth = depth or 1
+	state.max_depth_seen = math.max(state.max_depth_seen, depth)
+	if depth > state.max_depth then
+		return false, phrase(owner, "too_deep")
+	end
+
+	state.parts = state.parts + 1
+	if state.parts > state.max_parts then
+		return false, phrase(owner, "too_many_parts")
+	end
+
+	local class_name = string.lower(tostring(node.self.ClassName or ""))
+	if class_name == "" then
+		return false, phrase(owner, "missing_classname")
+	end
+
+	if pac.Security.IsBlockedPart(class_name) then
+		return false, phrase(owner, "part_disabled", class_name)
+	end
+
+	if state.restrict_to_safe_cosmetics and not pac.Security.IsSafePart(class_name) then
+		return false, phrase(owner, "part_not_safe", class_name)
+	end
+
+	local maxStr = pac.Security.GetNumber("Parts", "MaxStringLengthChars", 4096)
+
+	if class_name == "model" or class_name == "model2" then
+		state.model_parts = state.model_parts + 1
+		if state.model_parts > state.max_models then
+			return false, phrase(owner, "too_many_models")
+		end
+
+		if node.self.ForceObjUrl then
+			return false, phrase(owner, "obj_disabled")
+		end
+
+		if not is_safe_model_path(node.self.Model or "") then
+			return false, phrase(owner, "unsafe_model")
+		end
+
+		if not is_safe_material_path(node.self.Material or "") then
+			return false, phrase(owner, "unsafe_material")
+		end
+
+		local materials = split_semicolon_list(node.self.Materials)
+		if materials then
+			for _, mat in ipairs(materials) do
+				if mat ~= "" then
+					state.material_ops = state.material_ops + 1
+					if state.material_ops > state.max_material_ops then
+						return false, phrase(owner, "too_many_materials")
+					end
+					if not is_safe_material_path(mat) then
+						return false, phrase(owner, "unsafe_submaterial")
+					end
+				end
+			end
+		end
+
+		local model_modifiers = tostring(node.self.ModelModifiers or "")
+		if #model_modifiers > maxStr then
+			return false, phrase(owner, "modifier_too_long")
+		end
+		if model_modifiers ~= "" then
+			local lowered = string.lower(model_modifiers)
+			if string.find(lowered, "scale", 1, true) or string.find(lowered, "size", 1, true) then
+				if pac.Security.GetBool("Policy", "BlockPlayerResize", true) then
+					return false, phrase(owner, "scale_disabled")
+				end
+			end
+		end
+	elseif class_name == "material" or class_name == "submaterial" or string.sub(class_name, 1, 9) == "material_" then
+		state.material_ops = state.material_ops + 1
+		if state.material_ops > state.max_material_ops then
+			return false, phrase(owner, "too_many_materials")
+		end
+		if not is_safe_material_path(node.self.Material or "") then
+			return false, phrase(owner, "unsafe_material")
+		end
+	elseif class_name == "trail" or class_name == "trail2" then
+		state.trail_parts = state.trail_parts + 1
+		if state.trail_parts > state.max_trails then
+			return false, phrase(owner, "too_many_trails")
+		end
+		local trail_path = node.self.TrailPath or node.self.Material or ""
+		if not is_safe_material_path(trail_path) then
+			return false, phrase(owner, "unsafe_trail")
+		end
+		local start_size = tonumber(node.self.StartSize or 0) or 0
+		local end_size = tonumber(node.self.EndSize or 0) or 0
+		local maxSize = pac.Security.GetNumber("Parts", "TrailMaxSize", 48)
+		if start_size > maxSize or end_size > maxSize or start_size < 0 or end_size < 0 then
+			return false, phrase(owner, "trail_size")
+		end
+		local duration = tonumber(node.self.Duration or node.self.Length or 0) or 0
+		local maxDur = pac.Security.GetNumber("Parts", "TrailMaxDurationSeconds", 12)
+		if duration > maxDur or duration < 0 then
+			return false, phrase(owner, "trail_duration")
+		end
+	elseif class_name == "bodygroup" then
+		local idx = tonumber(node.self.ModelIndex or 0) or 0
+		local maxIdx = pac.Security.GetNumber("Parts", "BodygroupIndexMax", 64)
+		if idx < 0 or idx > maxIdx then
+			return false, phrase(owner, "bodygroup_index")
+		end
+		local bodygroup_name = tostring(node.self.BodyGroupName or "")
+		if #bodygroup_name > maxStr or bodygroup_name:find("\n", 1, true) or bodygroup_name:find("\r", 1, true) then
+			return false, phrase(owner, "bodygroup_name")
+		end
+	elseif class_name == "bone" then
+		state.bone_parts = (state.bone_parts or 0) + 1
+		if state.bone_parts > state.max_bones then
+			return false, phrase(owner, "too_many_bones")
+		end
+		local scale = node.self.Scale
+		if istable(scale) then
+			local x = read_vec_component(scale, "x", 1, 1)
+			local y = read_vec_component(scale, "y", 2, 1)
+			local z = read_vec_component(scale, "z", 3, 1)
+			local minS = pac.Security.GetNumber("Parts", "BoneScaleMin", 0.2)
+			local maxS = pac.Security.GetNumber("Parts", "BoneScaleMax", 3)
+			if x > maxS or y > maxS or z > maxS or x < minS or y < minS or z < minS then
+				return false, phrase(owner, "bone_scale")
+			end
+		end
+	end
+
+	local owner_name = tostring(node.self.OwnerName or "")
+	if owner_name ~= "" then
+		local numeric_owner = tonumber(owner_name)
+		if numeric_owner and IsValid(owner) and owner:EntIndex() ~= numeric_owner then
+			return false, phrase(owner, "foreign_entity")
+		end
+	end
+
+	if istable(node.children) then
+		for _, child in pairs(node.children) do
+			local ok, reason = validate_node(child, state, owner, depth + 1)
+			if ok == false then
+				return false, reason
+			end
+		end
+	end
+
+	return true
+end
+
+function pac.Security.ValidateOutfit(owner, data)
+	if not IsValid(owner) or not owner:IsPlayer() then
+		return false, phrase(owner, "invalid_owner")
+	end
+	if not istable(data) then
+		return false, phrase(owner, "invalid_data")
+	end
+	if not istable(data.part) then
+		return false, phrase(owner, "invalid_transfer")
+	end
+
+	if not pac.Security.LimitsEnabled() then
+		return true
+	end
+
+	local payload = util.TableToJSON(data) or ""
+	local max_bytes = pac.Security.GetNumber("Network", "MaxPayloadBytes", 262144)
+	if #payload > max_bytes then
+		return false, phrase(owner, "too_large")
+	end
+
+	local sid = owner:SteamID64() or "0"
+	local cache_key = sid .. ":" .. util.CRC(payload)
+	local cached = validation_cache[cache_key]
+	if cached then
+		if cached.expires > CurTime() then
+			return cached.ok, cached.reason
+		end
+		validation_cache[cache_key] = nil
+		cache_count = math.max(0, cache_count - 1)
+	end
+
+	local parts = cfg().Parts
+	local state = {
+		parts = 0,
+		model_parts = 0,
+		material_ops = 0,
+		trail_parts = 0,
+		bone_parts = 0,
+		max_depth_seen = 0,
+		max_parts = tonumber(parts.MaxPartsCount) or 64,
+		max_depth = tonumber(parts.MaxDepthCount) or 12,
+		max_models = tonumber(parts.MaxModelsCount) or 24,
+		max_material_ops = tonumber(parts.MaxMaterialOpsCount) or 48,
+		max_trails = tonumber(parts.MaxTrailsCount) or 6,
+		max_bones = tonumber(parts.MaxBonesCount) or 32,
+		restrict_to_safe_cosmetics = pac.Security.GetBool("Policy", "RestrictToSafeCosmetics", true),
+	}
+
+	local ok, reason = validate_node(data.part, state, owner, 1)
+
+	local ttl = pac.Security.GetNumber("Cache", "ValidationTtlSeconds", 45)
+	local maxEntries = pac.Security.GetNumber("Cache", "ValidationMaxEntries", 256)
+	if cache_count >= maxEntries then
+		validation_cache = {}
+		cache_count = 0
+	end
+	validation_cache[cache_key] = {
+		ok = ok,
+		reason = reason,
+		expires = CurTime() + ttl,
+	}
+	cache_count = cache_count + 1
+
+	return ok, reason
+end
+
+function pac.Security.CheckWearCooldown(owner)
+	if not pac.Security.LimitsEnabled() then
+		return true
+	end
+	if not IsValid(owner) then
+		return false, phrase(owner, "invalid_owner")
+	end
+	local now = CurTime()
+	local sid = owner:SteamID64() or owner:SteamID() or tostring(owner:EntIndex())
+	local cooldown = pac.Security.GetNumber("Network", "WearCooldownSeconds", 2)
+	if (wear_times[sid] or 0) + cooldown > now then
+		return false, phrase(owner, "wear_cooldown")
+	end
+	wear_times[sid] = now
+	return true
+end
+
+function pac.Security.NotifyBlocked(owner, key, msg)
+	notify_once(owner, key, msg)
+	log_blocked(owner, key, msg)
+end
+
+function pac.Security.ClearPlayerState(ply)
+	warned[ply] = nil
+	if IsValid(ply) then
+		local sid = ply:SteamID64() or ply:SteamID()
+		if sid then wear_times[sid] = nil end
+	end
+end
+
+hook.Add("PlayerDisconnected", "pac3_security_cleanup", function(ply)
+	pac.Security.ClearPlayerState(ply)
+end)
+
```

---
## `PAC3__lua_pac3_core_shared_http.lua`
```diff
--- /tmp/tmp.aoqOpC7GAY/lua/pac3/core/shared/http.lua	2026-05-06 23:34:10.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_pac3-master/lua/pac3/core/shared/http.lua	2026-08-18 16:45:35.800552347 +0000
@@ -172,6 +172,16 @@
 		return
 	end
 
+	-- change by cookie9216
+	if pac.Security and pac.Security.GetBool("URL", "Enabled", true) then
+		local maxLen = pac.Security.GetNumber("URL", "MaxLengthChars", 2048)
+		if url:len() > maxLen then
+			local msg = pac.Security.Phrase and pac.Security.Phrase("url_too_long") or "url length exceeds MaxLengthChars"
+			failcb(msg .. " (" .. tostring(maxLen) .. ")", true)
+			return
+		end
+	end
+
 	url = pac.FixUrl(url)
 
 	local limit = SV_LIMIT:GetInt()
```

---
## `PAC3__lua_pac3_core_shared_init.lua`
```diff
--- /tmp/tmp.aoqOpC7GAY/lua/pac3/core/shared/init.lua	2026-05-06 23:34:10.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_pac3-master/lua/pac3/core/shared/init.lua	2026-08-18 16:45:35.800552347 +0000
@@ -1,3 +1,6 @@
+-- change by cookie9216
+include("security.lua")
+
 include("util.lua")
 
 include("footsteps_fix.lua")
```

---
## `PAC3__lua_pac3_core_shared_security_config.lua`
```diff
--- /dev/null	2026-07-26 21:39:19.787270199 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_pac3-master/lua/pac3/core/shared/security_config.lua	2026-08-18 16:45:35.800552347 +0000
@@ -0,0 +1,147 @@
+-- change by cookie9216
+
+--[[
+	PAC3 security configuration.
+
+	Edit values here. The addon works without changes: every field has a
+	safe default, and invalid/missing values fall back instead of disabling
+	protection.
+
+	Structural checks (IsValid, types, table shape) cannot be turned off.
+	PAC3_SECURITY.Enabled only gates configurable limits and policy flags.
+]]
+
+PAC3_SECURITY = PAC3_SECURITY or {}
+
+-- Master switch for configurable limits and policy. Structural validation stays on.
+PAC3_SECURITY.Enabled = true
+
+PAC3_SECURITY.Network = {
+	Enabled = true,
+
+	-- Maximum accepted outfit payload in bytes (JSON of the submit table).
+	MaxPayloadBytes = 262144,
+
+	-- pac_submit rate limit window (matches original pac.RatelimitPlayer window).
+	MaxRequestsPerWindow = 8,
+	WindowSeconds = 5,
+
+	-- Minimum seconds between successful outfit apply attempts per player.
+	WearCooldownSeconds = 2,
+
+	-- Minimum net.ReadStream length in bits-equivalent bytes already gated by wear.lua (len < 64).
+	MinSubmitLength = 64,
+}
+
+PAC3_SECURITY.Parts = {
+	-- Recommended public-server defaults: tighter than unlimited original,
+	-- with headroom over the previous hardcoded 40-part live cap.
+	MaxPartsCount = 64,
+	MaxDepthCount = 12,
+	MaxModelsCount = 24,
+	MaxMaterialOpsCount = 48,
+	MaxTrailsCount = 6,
+	MaxBonesCount = 32,
+	MaxStringLengthChars = 4096,
+
+	TrailMaxSize = 48,
+	TrailMaxDurationSeconds = 12,
+	BoneScaleMin = 0.2,
+	BoneScaleMax = 3,
+	BodygroupIndexMax = 64,
+}
+
+PAC3_SECURITY.URL = {
+	Enabled = true,
+	MaxLengthChars = 2048,
+	BlockRemoteModelUrls = true,
+}
+
+PAC3_SECURITY.Policy = {
+	-- Default ON: public-server hardened policy. Set false to restore vanilla PAC3 combat/editor.
+	RestrictToSafeCosmetics = true,
+	BlockPlayerModelRewrite = true,
+	BlockPlayerResize = true,
+	ForceDisableCombat = true,
+	ForceDisableMovement = true,
+	ForceDisablePropOutfits = true,
+	NotifyBlocked = true,
+	LogBlocked = true,
+}
+
+PAC3_SECURITY.Editor = {
+	-- Default ON: only SuperAdmin or the configured privilege may open the editor.
+	-- Wear/submit of outfits is not blocked by this flag.
+	RestrictOpen = true,
+	PrivilegeName = "pac3.open_editor",
+	AllowSuperAdmin = true,
+}
+
+PAC3_SECURITY.Compatibility = {
+	-- Default ON, but only acts when TTT (or CORPSE) is detected.
+	KeepTTTCorpsesVisible = true,
+}
+
+-- Allowed part classes when RestrictToSafeCosmetics is true.
+-- material_* prefixes are also allowed at runtime.
+PAC3_SECURITY.SafeParts = {
+	group = true,
+	model = true,
+	model2 = true,
+	bone = true,
+	bodygroup = true,
+	material = true,
+	submaterial = true,
+	trail2 = true,
+}
+
+-- Explicitly rejected classes (also covered by the safe-list when restriction is on).
+PAC3_SECURITY.BlockedParts = {
+	animation = true,
+	beam = true,
+	camera = true,
+	censor = true,
+	clip = true,
+	command = true,
+	custom_animation = true,
+	damage_zone = true,
+	decal = true,
+	effect = true,
+	event = true,
+	faceposer = true,
+	flex = true,
+	fog = true,
+	force = true,
+	gesture = true,
+	halo = true,
+	health_modifier = true,
+	hitscan = true,
+	holdtype = true,
+	info = true,
+	interpolated_multibone = true,
+	jiggle = true,
+	light = true,
+	link = true,
+	lock = true,
+	motion_blur = true,
+	movement = true,
+	particles = true,
+	physics = true,
+	player_config = true,
+	poseparameter = true,
+	projected_texture = true,
+	projectile = true,
+	proxy = true,
+	script = true,
+	shake = true,
+	sound = true,
+	sprite = true,
+	sunbeams = true,
+	text = true,
+}
+
+PAC3_SECURITY.Cache = {
+	ValidationTtlSeconds = 45,
+	ValidationMaxEntries = 256,
+}
+
```

---
## `PAC3__lua_pac3_core_shared_security.lua`
```diff
--- /dev/null	2026-07-26 21:39:19.787270199 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_pac3-master/lua/pac3/core/shared/security.lua	2026-08-18 16:45:35.799552252 +0000
@@ -0,0 +1,420 @@
+-- change by cookie9216
+
+pac.Security = pac.Security or {}
+
+local DEFAULTS = {
+	Enabled = true,
+	Network = {
+		Enabled = true,
+		MaxPayloadBytes = 262144,
+		MaxRequestsPerWindow = 8,
+		WindowSeconds = 5,
+		WearCooldownSeconds = 2,
+		MinSubmitLength = 64,
+	},
+	Parts = {
+		MaxPartsCount = 64,
+		MaxDepthCount = 12,
+		MaxModelsCount = 24,
+		MaxMaterialOpsCount = 48,
+		MaxTrailsCount = 6,
+		MaxBonesCount = 32,
+		MaxStringLengthChars = 4096,
+		TrailMaxSize = 48,
+		TrailMaxDurationSeconds = 12,
+		BoneScaleMin = 0.2,
+		BoneScaleMax = 3,
+		BodygroupIndexMax = 64,
+	},
+	URL = {
+		Enabled = true,
+		MaxLengthChars = 2048,
+		BlockRemoteModelUrls = true,
+	},
+	Policy = {
+		RestrictToSafeCosmetics = true,
+		BlockPlayerModelRewrite = true,
+		BlockPlayerResize = true,
+		ForceDisableCombat = true,
+		ForceDisableMovement = true,
+		ForceDisablePropOutfits = true,
+		NotifyBlocked = true,
+		LogBlocked = true,
+	},
+	Editor = {
+		RestrictOpen = true,
+		PrivilegeName = "pac3.open_editor",
+		AllowSuperAdmin = true,
+	},
+	Compatibility = {
+		KeepTTTCorpsesVisible = true,
+	},
+	SafeParts = {
+		group = true,
+		model = true,
+		model2 = true,
+		bone = true,
+		bodygroup = true,
+		material = true,
+		submaterial = true,
+		trail2 = true,
+	},
+	BlockedParts = {},
+	Cache = {
+		ValidationTtlSeconds = 45,
+		ValidationMaxEntries = 256,
+	},
+}
+
+local LIMITS = {
+	Network = {
+		MaxPayloadBytes = {min = 8192, max = 8388608},
+		MaxRequestsPerWindow = {min = 1, max = 120},
+		WindowSeconds = {min = 1, max = 60},
+		WearCooldownSeconds = {min = 0.25, max = 30},
+		MinSubmitLength = {min = 16, max = 4096},
+	},
+	Parts = {
+		MaxPartsCount = {min = 8, max = 2048},
+		MaxDepthCount = {min = 2, max = 128},
+		MaxModelsCount = {min = 1, max = 512},
+		MaxMaterialOpsCount = {min = 1, max = 1024},
+		MaxTrailsCount = {min = 0, max = 64},
+		MaxBonesCount = {min = 0, max = 256},
+		MaxStringLengthChars = {min = 32, max = 65536},
+		TrailMaxSize = {min = 1, max = 256},
+		TrailMaxDurationSeconds = {min = 0.1, max = 60},
+		BoneScaleMin = {min = 0.01, max = 1},
+		BoneScaleMax = {min = 1, max = 16},
+		BodygroupIndexMax = {min = 1, max = 256},
+	},
+	URL = {
+		MaxLengthChars = {min = 64, max = 8192},
+	},
+	Cache = {
+		ValidationTtlSeconds = {min = 5, max = 300},
+		ValidationMaxEntries = {min = 16, max = 4096},
+	},
+}
+
+local function copyDefaults()
+	return table.Copy(DEFAULTS)
+end
+
+local function asBool(val, fallback)
+	if isbool(val) then return val end
+	if val == 1 or val == "1" or val == "true" then return true end
+	if val == 0 or val == "0" or val == "false" then return false end
+	return fallback
+end
+
+local function asNumber(val, fallback, minv, maxv)
+	local n = tonumber(val)
+	if n == nil or n ~= n then
+		return fallback
+	end
+	if minv and n < minv then n = minv end
+	if maxv and n > maxv then n = maxv end
+	return n
+end
+
+local function asString(val, fallback)
+	if isstring(val) and val ~= "" then return val end
+	return fallback
+end
+
+local function mergeSection(dst, src, defaults, limits)
+	if not istable(src) then
+		return
+	end
+	for key, def in pairs(defaults) do
+		local incoming = src[key]
+		if isbool(def) then
+			dst[key] = asBool(incoming, def)
+		elseif isnumber(def) then
+			local lim = limits and limits[key]
+			dst[key] = asNumber(incoming, def, lim and lim.min, lim and lim.max)
+		elseif isstring(def) then
+			dst[key] = asString(incoming, def)
+		elseif istable(def) then
+			if istable(incoming) then
+				dst[key] = incoming
+			end
+		end
+	end
+end
+
+local function loadConfigFile()
+	local compiled = CompileFile("pac3/core/shared/security_config.lua")
+	if not compiled then
+		return false
+	end
+	local ok = pcall(compiled)
+	return ok == true
+end
+
+local function validateAndApply()
+	local cfg = copyDefaults()
+	loadConfigFile()
+	local raw = PAC3_SECURITY
+	if istable(raw) then
+		cfg.Enabled = asBool(raw.Enabled, cfg.Enabled)
+		mergeSection(cfg.Network, raw.Network, DEFAULTS.Network, LIMITS.Network)
+		mergeSection(cfg.Parts, raw.Parts, DEFAULTS.Parts, LIMITS.Parts)
+		mergeSection(cfg.URL, raw.URL, DEFAULTS.URL, LIMITS.URL)
+		mergeSection(cfg.Policy, raw.Policy, DEFAULTS.Policy, nil)
+		mergeSection(cfg.Editor, raw.Editor, DEFAULTS.Editor, nil)
+		mergeSection(cfg.Compatibility, raw.Compatibility, DEFAULTS.Compatibility, nil)
+		mergeSection(cfg.Cache, raw.Cache, DEFAULTS.Cache, LIMITS.Cache)
+		if istable(raw.SafeParts) then
+			cfg.SafeParts = raw.SafeParts
+		end
+		if istable(raw.BlockedParts) then
+			cfg.BlockedParts = raw.BlockedParts
+		end
+	end
+
+	local cv = GetConVar("pac_security_enabled")
+	if cv then
+		cfg.Enabled = cv:GetBool()
+	end
+
+	PAC3_SECURITY = cfg
+	pac.Security._cfg = cfg
+end
+
+if SERVER then
+	CreateConVar("pac_security_enabled", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Enable PAC3 configurable security limits and policy (structural validation always stays on)")
+end
+
+validateAndApply()
+
+if SERVER then
+	cvars.AddChangeCallback("pac_security_enabled", function()
+		if pac.Security._cfg then
+			local cv = GetConVar("pac_security_enabled")
+			if cv then
+				pac.Security._cfg.Enabled = cv:GetBool()
+				if istable(PAC3_SECURITY) then
+					PAC3_SECURITY.Enabled = pac.Security._cfg.Enabled
+				end
+			end
+		end
+	end, "pac3_security_enabled")
+end
+
+function pac.Security.Get()
+	return pac.Security._cfg or PAC3_SECURITY or DEFAULTS
+end
+
+function pac.Security.LimitsEnabled()
+	local cfg = pac.Security.Get()
+	return cfg.Enabled ~= false
+end
+
+function pac.Security.GetBool(section, key, fallback)
+	local cfg = pac.Security.Get()
+	local grp = cfg[section]
+	if istable(grp) and grp[key] ~= nil then
+		return asBool(grp[key], fallback)
+	end
+	return fallback
+end
+
+function pac.Security.GetNumber(section, key, fallback)
+	local cfg = pac.Security.Get()
+	local grp = cfg[section]
+	if istable(grp) then
+		return asNumber(grp[key], fallback)
+	end
+	return fallback
+end
+
+function pac.Security.GetString(section, key, fallback)
+	local cfg = pac.Security.Get()
+	local grp = cfg[section]
+	if istable(grp) then
+		return asString(grp[key], fallback)
+	end
+	return fallback
+end
+
+function pac.Security.IsSafePart(className)
+	if not isstring(className) or className == "" then
+		return false
+	end
+	local cfg = pac.Security.Get()
+	if cfg.SafeParts and cfg.SafeParts[className] then
+		return true
+	end
+	if string.sub(className, 1, 9) == "material_" then
+		return true
+	end
+	return false
+end
+
+function pac.Security.IsBlockedPart(className)
+	local cfg = pac.Security.Get()
+	return istable(cfg.BlockedParts) and cfg.BlockedParts[className] == true
+end
+
+function pac.Security.PlayerCanOpenEditor(ply)
+	if not IsValid(ply) or not ply:IsPlayer() then
+		return false
+	end
+
+	if not pac.Security.LimitsEnabled() or not pac.Security.GetBool("Editor", "RestrictOpen", true) then
+		return true
+	end
+
+	if pac.Security.GetBool("Editor", "AllowSuperAdmin", true) and ply:IsSuperAdmin() then
+		return true
+	end
+
+	local privilege = pac.Security.GetString("Editor", "PrivilegeName", "pac3.open_editor")
+
+	if ULib and ULib.ucl and ULib.ucl.query and ULib.ucl.query(ply, privilege) then
+		return true
+	end
+
+	if CAMI and CAMI.PlayerHasAccess then
+		local allowed
+		CAMI.PlayerHasAccess(ply, privilege, function(ok)
+			allowed = ok and true or false
+		end)
+		if allowed then
+			return true
+		end
+	end
+
+	return false
+end
+
+function pac.Security.IsTTTActive()
+	if CORPSE then
+		return true
+	end
+	local gm = engine.ActiveGamemode and engine.ActiveGamemode() or ""
+	if isstring(gm) and string.find(string.lower(gm), "terrortown", 1, true) then
+		return true
+	end
+	return false
+end
+
+function pac.Security.KeepTTTCorpsesVisible()
+	return pac.Security.GetBool("Compatibility", "KeepTTTCorpsesVisible", true) and pac.Security.IsTTTActive()
+end
+
+function pac.Security.UseGerman(ply)
+	local lang = "en"
+	if CLIENT then
+		local cv = GetConVar("gmod_language")
+		if cv then
+			lang = cv:GetString() or "en"
+		end
+	elseif IsValid(ply) and ply.GetInfo then
+		lang = ply:GetInfo("gmod_language") or "en"
+	end
+	lang = string.lower(tostring(lang or "en"))
+	return lang == "de" or string.sub(lang, 1, 3) == "de-"
+end
+
+local PHRASES_EN = {
+	invalid_owner = "Invalid PAC owner.",
+	invalid_data = "Invalid PAC data.",
+	invalid_transfer = "Invalid PAC transfer.",
+	invalid_structure = "Invalid PAC data structure.",
+	too_deep = "Outfit nesting is too deep.",
+	too_many_parts = "Outfit has too many parts.",
+	missing_classname = "Part is missing ClassName.",
+	part_disabled = "Part type '%s' is disabled.",
+	part_not_safe = "Part type '%s' is not allowed for safe cosmetics.",
+	too_many_models = "Outfit has too many model parts.",
+	obj_disabled = "OBJ/remote models are disabled.",
+	unsafe_model = "Unsafe or remote model path.",
+	unsafe_material = "Unsafe material path.",
+	too_many_materials = "Too many material changes.",
+	unsafe_submaterial = "Unsafe submaterial path.",
+	modifier_too_long = "Model modifier string is too long.",
+	scale_disabled = "Model scale/size modifiers are disabled.",
+	too_many_trails = "Too many trail parts.",
+	unsafe_trail = "Unsafe trail material path.",
+	trail_size = "Trail size is outside the allowed range.",
+	trail_duration = "Trail duration is outside the allowed range.",
+	bodygroup_index = "Invalid bodygroup index.",
+	bodygroup_name = "Invalid bodygroup name.",
+	too_many_bones = "Too many bone parts.",
+	bone_scale = "Bone scale is outside the allowed range.",
+	foreign_entity = "Outfit cannot be applied to foreign entities.",
+	too_large = "Outfit is too large.",
+	wear_cooldown = "Outfit apply cooldown is active.",
+	url_too_long = "url length exceeds MaxLengthChars",
+	editor_restricted = "PAC3 editor is restricted. Required access: %s",
+	movement_blocked = "PAC3 movement changes are disabled.",
+	remote_model_url = "Remote model URLs are disabled.",
+	player_model_rewrite = "PAC3 player model changes are disabled.",
+	player_resize = "PAC3 player resizing is disabled.",
+}
+
+local PHRASES_DE = {
+	invalid_owner = "Ungültiger PAC-Besitzer.",
+	invalid_data = "Ungültige PAC-Daten.",
+	invalid_transfer = "Ungültige PAC-Übertragung.",
+	invalid_structure = "Ungültige PAC-Datenstruktur.",
+	too_deep = "Outfit zu tief verschachtelt.",
+	too_many_parts = "Outfit hat zu viele Teile.",
+	missing_classname = "Teil ohne ClassName erkannt.",
+	part_disabled = "Teiltyp '%s' ist deaktiviert.",
+	part_not_safe = "Teiltyp '%s' ist nicht für sichere Kosmetik freigegeben.",
+	too_many_models = "Outfit hat zu viele Model-Teile.",
+	obj_disabled = "OBJ-/Remote-Modelle sind deaktiviert.",
+	unsafe_model = "Unsicherer oder externer Model-Pfad erkannt.",
+	unsafe_material = "Unsicherer Material-Pfad erkannt.",
+	too_many_materials = "Zu viele Material-Änderungen im Outfit.",
+	unsafe_submaterial = "Unsicherer Submaterial-Pfad erkannt.",
+	modifier_too_long = "Model-Modifier-Text ist zu lang.",
+	scale_disabled = "Model-Scale/Size-Modifier sind deaktiviert.",
+	too_many_trails = "Zu viele Trail-Teile im Outfit.",
+	unsafe_trail = "Unsicherer Trail-Material-Pfad erkannt.",
+	trail_size = "Trail-Größe ist außerhalb des sicheren Bereichs.",
+	trail_duration = "Trail-Dauer ist außerhalb des sicheren Bereichs.",
+	bodygroup_index = "Ungültiger Bodygroup-Index erkannt.",
+	bodygroup_name = "Ungültiger Bodygroup-Name erkannt.",
+	too_many_bones = "Zu viele Bone-Teile im Outfit.",
+	bone_scale = "Bone-Skalierung ist außerhalb des erlaubten Bereichs.",
+	foreign_entity = "Outfit darf nicht auf fremde Entities angewendet werden.",
+	too_large = "Outfit ist zu groß.",
+	wear_cooldown = "Outfit-Cooldown aktiv.",
+	url_too_long = "URL-Länge überschreitet MaxLengthChars",
+	editor_restricted = "PAC3-Editor ist gesperrt. Erforderliches Recht: %s",
+	movement_blocked = "PAC3-Bewegungsänderungen sind deaktiviert.",
+	remote_model_url = "Remote-Model-URLs sind deaktiviert.",
+	player_model_rewrite = "Playermodel-Änderungen über PAC3 sind deaktiviert.",
+	player_resize = "Spieler-Skalierung über PAC3 ist deaktiviert.",
+}
+
+function pac.Security.Phrase(key, ply, ...)
+	local tableForLang = pac.Security.UseGerman(ply) and PHRASES_DE or PHRASES_EN
+	local msg = tableForLang[key] or PHRASES_EN[key] or tostring(key)
+	if select("#", ...) > 0 then
+		return string.format(msg, ...)
+	end
+	return msg
+end
+
+function pac.Security.IsTTTPlayerCorpse(rag)
+	if not IsValid(rag) or rag:GetClass() ~= "prop_ragdoll" then
+		return false
+	end
+	if CORPSE and CORPSE.GetPlayerNick then
+		local nick = CORPSE.GetPlayerNick(rag, false)
+		if nick and nick ~= false and nick ~= "" then
+			return true
+		end
+	end
+	if rag.GetNWString and rag:GetNWString("nick", "") ~= "" then
+		return true
+	end
+	return false
+end
+
```

---
## `PAC3__lua_pac3_editor_server_init.lua`
```diff
--- /tmp/tmp.aoqOpC7GAY/lua/pac3/editor/server/init.lua	2026-05-06 23:34:10.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_pac3-master/lua/pac3/editor/server/init.lua	2026-08-18 16:45:35.836555757 +0000
@@ -29,6 +29,15 @@
 		return false
 	end
 
+	-- change by cookie9216
+	local hookResult = hook.Run("PACCanPlayerModify", ply, ent)
+	if hookResult == false then
+		return false
+	end
+	if hookResult == true then
+		return true
+	end
+
 	if ply == ent then
 		return true
 	end
@@ -78,7 +87,14 @@
 	util.AddNetworkString("pac_in_editor")
 
 	net.Receive("pac_in_editor", function(_, ply)
-		ply:SetNW2Bool("pac_in_editor", net.ReadBit() == 1)
+		-- change by cookie9216
+		if not IsValid(ply) or not ply:IsPlayer() then return end
+		local want = net.ReadBit() == 1
+		if want and pac.Security and pac.Security.PlayerCanOpenEditor and not pac.Security.PlayerCanOpenEditor(ply) then
+			ply:SetNW2Bool("pac_in_editor", false)
+			return
+		end
+		ply:SetNW2Bool("pac_in_editor", want)
 	end)
 
 	util.AddNetworkString("pac_in_editor_posang")
```

---
## `PAC3__lua_pac3_editor_server_wear.lua`
```diff
--- /tmp/tmp.aoqOpC7GAY/lua/pac3/editor/server/wear.lua	2026-05-06 23:34:10.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_pac3-master/lua/pac3/editor/server/wear.lua	2026-08-18 16:45:35.836555757 +0000
@@ -124,6 +124,28 @@
 	local part = data.part
 	local owner = data.owner
 
+	-- change by cookie9216
+	if not IsValid(owner) or not owner:IsPlayer() then
+		return false, pac.Security.Phrase and pac.Security.Phrase("invalid_owner", owner) or "Invalid PAC owner."
+	end
+	if not istable(data) then
+		return false, pac.Security.Phrase and pac.Security.Phrase("invalid_data", owner) or "Invalid PAC data."
+	end
+	if pac.Security and pac.Security.CheckWearCooldown then
+		local cooldownOk, cooldownReason = pac.Security.CheckWearCooldown(owner)
+		if cooldownOk == false then
+			pac.Security.NotifyBlocked(owner, "wear_cooldown", cooldownReason)
+			return false, cooldownReason
+		end
+	end
+	if pac.Security and pac.Security.ValidateOutfit then
+		local validOk, validReason = pac.Security.ValidateOutfit(owner, data)
+		if validOk == false then
+			pac.Security.NotifyBlocked(owner, "unsafe_submission", validReason)
+			return false, validReason
+		end
+	end
+
 	-- last arg "true" is pac3 only in case you need to do your checking differently from pac2
 	local allowed, reason = hook.Run("PrePACConfigApply", owner, data, true)
 	if allowed == false then return allowed, reason end
@@ -382,7 +404,13 @@
 local pac_submit_limit = CreateConVar("pac_submit_limit", "30", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "pac_submit spam limit")
 
 pace.PCallNetReceive(net.Receive, "pac_submit", function(len, ply)
-	if len < 64 then return end
+	-- change by cookie9216
+	local minLen = 64
+	if pac.Security and pac.Security.GetNumber then
+		minLen = pac.Security.GetNumber("Network", "MinSubmitLength", 64)
+	end
+	if len < minLen then return end
+	if not IsValid(ply) or not ply:IsPlayer() then return end
 	if pac_submit_spam:GetBool() and not game.SinglePlayer() then
 		local allowed = pac.RatelimitPlayer( ply, "pac_submit", pac_submit_limit:GetInt(), 5, {"Player ", ply, " is spamming pac_submit!"} )
 		if not allowed then return end
```

---
## `PAC3__PAC3_SECURITY_CONFIG.md`
```diff
--- /dev/null	2026-07-26 21:39:19.787270199 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_pac3-master/PAC3_SECURITY_CONFIG.md	2026-08-17 19:00:26.769107186 +0000
@@ -0,0 +1,115 @@
+# PAC3 Security Config
+
+Source of truth: `lua/pac3/core/shared/security_config.lua`
+
+Structural checks (`IsValid`, types, table shape) always run. `PAC3_SECURITY.Enabled` and `pac_security_enabled` only gate configurable limits and policy.
+
+Invalid, missing, or out-of-range values fall back to the defaults below. Bad values never disable protection.
+
+## Enabled
+
+Type: boolean  
+Standard: true  
+
+Master switch for limits and policy. Structural validation stays on.
+
+Zu niedrig / false: combat, editor ACL, part caps, and cosmetic restriction turn off.  
+Zu hoch: n/a.
+
+## Network.MaxPayloadBytes
+
+Type: number (bytes)  
+Standard: 262144  
+
+Maximum JSON size of an accepted outfit submit.
+
+Zu niedrig: large legitimate outfits are rejected.  
+Zu hoch: memory and net load increase.
+
+## Network.MaxRequestsPerWindow
+
+Type: number (count)  
+Standard: 8  
+
+Applied to original `pac_submit_limit` when policy is enabled (window: `WindowSeconds`, default 5).
+
+## Network.WearCooldownSeconds
+
+Type: number (seconds)  
+Standard: 2  
+
+Minimum delay between outfit apply attempts per player. Floor 0.25.
+
+## Parts.MaxPartsCount
+
+Type: number (count)  
+Standard: 64  
+
+Recommended public-server default. Previous live hardcode was 40 (too tight for some cosmetic outfits). Original PAC3 had no cap.
+
+## Parts.MaxDepthCount
+
+Type: number (count)  
+Standard: 12  
+
+Maximum nesting depth of the part tree.
+
+## Parts.MaxModelsCount / MaxMaterialOpsCount / MaxTrailsCount / MaxBonesCount
+
+Type: number  
+Standard: 24 / 48 / 6 / 32  
+
+Per-outfit resource caps.
+
+## Parts.TrailMaxSize / TrailMaxDurationSeconds / BoneScaleMin / BoneScaleMax / BodygroupIndexMax
+
+Type: number  
+Standard: 48 / 12 / 0.2 / 3 / 64  
+
+Physical range clamps for trail and bone parts.
+
+## URL.MaxLengthChars
+
+Type: number (chars)  
+Standard: 2048  
+
+Maximum HTTP URL and path string length.
+
+## URL.BlockRemoteModelUrls
+
+Type: boolean  
+Standard: true  
+
+Blocks `http(s)://` model paths and related remote schemes.
+
+## Policy.RestrictToSafeCosmetics
+
+Type: boolean  
+Standard: true  
+
+Only `SafeParts` (plus `material_*`) are accepted when wearing.
+
+## Policy.BlockPlayerModelRewrite / BlockPlayerResize / ForceDisableCombat / ForceDisableMovement / ForceDisablePropOutfits
+
+Type: boolean  
+Standard: true  
+
+Public-server policy. Set false to restore the corresponding original PAC3 cvars/behavior.
+
+## Editor.RestrictOpen
+
+Type: boolean  
+Standard: true  
+
+Editor open requires SuperAdmin (if `AllowSuperAdmin`) or `Editor.PrivilegeName` (`pac3.open_editor`) via ULX/CAMI. Wear is not blocked.
+
+## Compatibility.KeepTTTCorpsesVisible
+
+Type: boolean  
+Standard: true  
+
+Only acts when TTT/`CORPSE` is detected. Skips PAC death-hide on player corpses.
+
+## Optional ConVar
+
+`pac_security_enabled` — same meaning as `PAC3_SECURITY.Enabled`. Do not add a ConVar per limit.
```

---
## `PS2__addon.json`
```diff
--- /dev/null	2026-07-26 21:39:19.787270199 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/addon.json	2026-08-14 12:16:57.643470175 +0000
@@ -0,0 +1,6 @@
+{
+  "title": "Pointshop 2",
+  "type": "ServerContent",
+  "tags": ["fun"],
+  "ignore": ["*.md", ".git*", ".vscode/*", "*.psd"]
+}
```

---
## `PS2__lua_kinv_client_cl_ditemscontainer.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/kinv/client/cl_ditemscontainer.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/kinv/client/cl_ditemscontainer.lua	2026-08-18 16:45:35.707543537 +0000
@@ -10,7 +10,7 @@
 end
 
 function PANEL:initSlots( amount )
-	dp( amount )
+	-- change by cookie9216
 	if self.initializedSlots then
 		for k, v in pairs( self:GetChildren( ) ) do
 			v:Remove( )
```

---
## `PS2__lua_kinv_client_cl_ditemslot.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/kinv/client/cl_ditemslot.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/kinv/client/cl_ditemslot.lua	2026-08-18 16:45:35.706543442 +0000
@@ -68,20 +68,27 @@
 end
 
 function PANEL:Paint( w, h )
-    surface.SetDrawColor( 50, 50, 50 )
-    surface.DrawRect( 0, 0, w, h )
+	-- change by cookie9216
+	if Pointshop2 and Pointshop2.DrawItemSlotBackground then
+		Pointshop2.DrawItemSlotBackground( self, w, h )
+	else
+		surface.SetDrawColor( 50, 50, 50 )
+		surface.DrawRect( 0, 0, w, h )
+		if self.Dragging then
+			surface.SetDrawColor( 40, 40, 40 )
+			surface.DrawRect( 0, 0, w, h )
+		end
+	end
 
-    if self.Dragging then
-        surface.SetDrawColor( 40, 40, 40 )
-        surface.DrawRect( 0, 0, w, h )
-    end
-
-    self.key = -1
-    for k, v in pairs( self:GetParent( ):GetChildren( ) ) do
-        if v == self then
-            self.key = k
-        end
-    end
+	self.key = -1
+	local parent = self:GetParent( )
+	if IsValid( parent ) then
+		for k, v in pairs( parent:GetChildren( ) ) do
+			if v == self then
+				self.key = k
+			end
+		end
+	end
 end
 
 --Called when item is removed externally
```

---
## `PS2__lua_kinv_client_cl_ditemstack.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/kinv/client/cl_ditemstack.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/kinv/client/cl_ditemstack.lua	2026-08-18 16:45:35.706543442 +0000
@@ -185,7 +185,30 @@
 
 function PANEL:Think( )
 	if not IsValid( self.icon ) and self.items[1] then
-		self.icon = self.items[1]:getCrashsafeIcon( )
+		-- change by cookie9216
+		local item = self.items[1]
+		local icon
+		if item.getCrashsafeIcon then
+			icon = item:getCrashsafeIcon( )
+		elseif item.getIcon then
+			icon = item:getIcon( )
+		end
+
+		if not IsValid( icon ) then
+			if not self._missingIconLogged then
+				self._missingIconLogged = true
+				local className = item.class and item.class.className or "unknown"
+				ErrorNoHalt( "[KInventory] Missing icon for item class: " .. tostring( className ) .. "\n" )
+			end
+			icon = vgui.Create( "DPanel" )
+			icon:SetSize( 64, 64 )
+			function icon:Paint( w, h )
+				surface.SetDrawColor( 40, 40, 40, 200 )
+				surface.DrawRect( 0, 0, w, h )
+			end
+		end
+
+		self.icon = icon
 		self.icon:SetParent( self )
 		self.icon.stackPanel = self
 		self.icon:SetDragParent( self )
```

---
## `PS2__lua_kinv_client_cl_item.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/kinv/client/cl_item.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/kinv/client/cl_item.lua	2026-08-18 16:45:35.705543347 +0000
@@ -23,6 +23,24 @@
 	return self.icon
 end
 
+-- change by cookie9216
+function Item:getCrashsafeIcon( )
+	local icon = self:getIcon( )
+	if IsValid( icon ) then
+		self.icon = icon
+		return icon
+	end
+
+	local placeholder = vgui.Create( "DPanel" )
+	placeholder:SetSize( 64, 64 )
+	function placeholder:Paint( w, h )
+		surface.SetDrawColor( 40, 40, 40, 200 )
+		surface.DrawRect( 0, 0, w, h )
+	end
+	self.icon = placeholder
+	return placeholder
+end
+
 function Item:getHoverPanel( )
 	local panel = vgui.Create( "DItemDescriptionPanel" )
 	panel:SetSize( 220, 100 )
```

---
## `PS2__lua_kinv_items_pointshop_sh_base_hat.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/kinv/items/pointshop/sh_base_hat.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/kinv/items/pointshop/sh_base_hat.lua	2026-08-18 16:45:35.708543632 +0000
@@ -12,6 +12,38 @@
 end
 
 if CLIENT then
+	-- change by cookie9216
+	local function rewriteOutfitUniqueIds(part, prefix, path)
+		if not istable(part) then return end
+		path = path or "root"
+		if istable(part.self) then
+			for key, val in pairs(part.self) do
+				if val ~= "" and (key == "UniqueID" or string.sub(key, -3) == "UID") then
+					part.self[key] = util.CRC(prefix .. ":" .. path .. ":" .. tostring(key) .. ":" .. tostring(val))
+				end
+			end
+		end
+		for childKey, child in pairs(part.children or {}) do
+			rewriteOutfitUniqueIds(child, prefix, path .. "." .. tostring(childKey))
+		end
+		for childKey, child in pairs(part) do
+			if childKey ~= "self" and childKey ~= "children" and istable(child) then
+				rewriteOutfitUniqueIds(child, prefix, path .. "." .. tostring(childKey))
+			end
+		end
+	end
+
+	function ITEM:BuildPACOutfitForOwner(ply, outfit, outfitId)
+		if not istable(outfit) then return nil end
+		local cloned = table.Copy(outfit)
+		local ownerKey = IsValid(ply) and tostring(ply:EntIndex()) or "unknown"
+		local itemKey = tostring(self.id or self.className or self.PrintName or "item")
+		local outfitKey = tostring(outfitId or "outfit")
+		local prefix = "ps2:" .. ownerKey .. ":" .. itemKey .. ":" .. outfitKey
+		rewriteOutfitUniqueIds(cloned, prefix)
+		return cloned
+	end
+
 	function ITEM:AttachOutfit( )
 		local ply = self:GetOwner( )
 		if not IsValid(ply) then
@@ -33,10 +65,18 @@
 			ply:SetShowPACPartsInEditor( false )
 		end
 
+		-- change by cookie9216
+		if self.attached then
+			self:RemoveOutfit( )
+		end
 		local outfit, id = self:getOutfitForModel( ply:GetModel() )
+		outfit = self:BuildPACOutfitForOwner(ply, outfit, id)
+		if not outfit then
+			return
+		end
 		self.outfit = outfit
 		self.model = ply:GetModel()
-		ply:AttachPACPart( outfit, ply )
+		ply:AttachPACPart( outfit, ply, true )
 		self.attached = true
 	end
 
@@ -44,26 +84,37 @@
 		self.attached = false
 
 		local ply = self:GetOwner()
-		if not ply.RemovePACPart then
+		-- change by cookie9216
+		if not IsValid(ply) or not ply.RemovePACPart then
+			self.outfit = nil
 			return
 		end
 
-		local outfit = self.outfit or self.class.getOutfitForModel( ply:GetModel() )
-		ply:RemovePACPart( outfit )
+		local outfit = self.outfit
+		if not istable(outfit) then
+			local rawOutfit, outfitId = self.class.getOutfitForModel( ply:GetModel() )
+			outfit = self:BuildPACOutfitForOwner(ply, rawOutfit, outfitId)
+		end
+		if istable(outfit) then
+			ply:RemovePACPart( outfit, true )
+		end
+		self.outfit = nil
 	end
 
 	-- Monitor Model Changes
 	function ITEM:Think( )
-		if not self.outfit or not self.model or not IsValid( self:GetOwner( ) ) then
+		-- change by cookie9216
+		if not IsValid( self:GetOwner( ) ) then
 			return
 		end
 
-		if self.model != self:GetOwner( ):GetModel( ) then
+		if self.outfit and self.model and self.model != self:GetOwner( ):GetModel( ) then
 			self:RemoveOutfit( )
 			self:AttachOutfit( )
 		end
 
 		local shouldShow = not ( hook.Run( "PS2_VisualsShouldShow", self:GetOwner( ) ) == false )
+			and not Pointshop2.ClientSettings.GetSetting( "BasicSettings.VisualsDisabled" )
 		if shouldShow != self.attached then
 			if shouldShow then
 				self:AttachOutfit( )
```

---
## `PS2__lua_kinv_items_pointshop_sh_base_playermodel.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/kinv/items/pointshop/sh_base_playermodel.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/kinv/items/pointshop/sh_base_playermodel.lua	2026-08-18 16:45:35.708543632 +0000
@@ -58,7 +58,7 @@
 
 function ITEM:OnHolster( )
 	local ply = self:GetOwner( )
-	dp("on holster", ply)
+	-- change by cookie9216
 	timer.Simple( 0, function( )
 		hook.Run( "PlayerSetModel", ply )
 		hook.Run( "PS2_DoUpdatePreviewModel" )
```

---
## `PS2__lua_kinv_shared_sh_0_kinventory.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/kinv/shared/sh_0_kinventory.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/kinv/shared/sh_0_kinventory.lua	2026-08-18 16:45:35.707543537 +0000
@@ -6,7 +6,7 @@
 function KInventory.RegisterItemClassMixin( className, mixin )
 	-- Class already loaded, apply mixin now
 	if KInventory.Items and KInventory.Items[className] then
-		print(KInventory.Items[className])
+		-- change by cookie9216
 		KInventory.ApplyMixin( KInventory.Items[className], mixin )
 	end
 
```

---
## `PS2__lua_ps2_client_cl_0_tilepaint.lua`
```diff
--- /dev/null	2026-07-26 21:39:19.787270199 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/ps2/client/cl_0_tilepaint.lua	2026-08-18 16:45:35.710543821 +0000
@@ -0,0 +1,147 @@
+-- change by cookie9216
+
+Pointshop2 = Pointshop2 or {}
+
+local TILE_MAT
+local PREVIEW_MAT
+
+local TILE_CANDIDATES = {
+	"itembg-ps2.png",
+	"itembg-ps2",
+	"pointshop2/itembg.png",
+	"item_bg",
+}
+
+local TILE_FALLBACK = Color(27, 27, 34, 255)
+local HOVER_OVERLAY = Color(80, 150, 255, 24)
+local HOVER_OUTLINE = Color(80, 150, 255, 82)
+local DRAG_OVERLAY = Color(8, 10, 16, 172)
+local POPUP_BACKDROP = Color(8, 10, 16, 235)
+local POPUP_PANEL = Color(27, 27, 34, 255)
+local POPUP_OUTLINE = Color(65, 65, 78, 255)
+
+local function normalizeMaterialPath(path)
+	if not isstring(path) or path == "" then return nil end
+	path = string.Trim(string.Replace(path, "\\", "/"))
+	path = string.TrimLeft(path, "/")
+	if string.StartWith(string.lower(path), "materials/") then
+		path = string.sub(path, 11)
+	end
+	return path
+end
+
+local function resolveMaterial(candidates)
+	local tried = {}
+	for _, raw in ipairs(candidates) do
+		local path = normalizeMaterialPath(raw)
+		if path and not tried[path] then
+			tried[path] = true
+			local mat = Material(path, "noclamp smooth")
+			if mat and not mat:IsError() then
+				return mat
+			end
+			local noPng = string.gsub(path, "%.png$", "")
+			if noPng ~= path and not tried[noPng] then
+				tried[noPng] = true
+				mat = Material(noPng, "noclamp smooth")
+				if mat and not mat:IsError() then
+					return mat
+				end
+			end
+		end
+	end
+end
+
+function Pointshop2.RefreshTileMaterials()
+	TILE_MAT = resolveMaterial(TILE_CANDIDATES)
+	PREVIEW_MAT = TILE_MAT
+end
+
+Pointshop2.RefreshTileMaterials()
+hook.Add("InitPostEntity", "PS2_RefreshTileMaterials", Pointshop2.RefreshTileMaterials)
+
+local function drawMat(mat, w, h)
+	if not mat then return false end
+	surface.SetMaterial(mat)
+	surface.SetDrawColor(255, 255, 255, 255)
+	surface.DrawTexturedRect(0, 0, w, h)
+	return true
+end
+
+function Pointshop2.IsTileHovered(pnl)
+	if not IsValid(pnl) then return false end
+	if pnl.Selected or pnl.Hovered or pnl.Dragging then return true end
+	if pnl.IsHoveredRecursive then return pnl:IsHoveredRecursive() end
+	if pnl.IsChildHovered then return pnl:IsChildHovered(2) end
+	return pnl:IsHovered()
+end
+
+function Pointshop2.DrawItemTileBackground(w, h, hovered)
+	if hovered and drawMat(PREVIEW_MAT, w, h) then
+		surface.SetDrawColor(HOVER_OUTLINE)
+		surface.DrawOutlinedRect(0, 0, w, h, 1)
+		return
+	end
+
+	if not drawMat(TILE_MAT, w, h) then
+		surface.SetDrawColor(TILE_FALLBACK)
+		surface.DrawRect(0, 0, w, h)
+	end
+
+	if hovered then
+		surface.SetDrawColor(HOVER_OVERLAY)
+		surface.DrawRect(0, 0, w, h)
+		surface.SetDrawColor(HOVER_OUTLINE)
+		surface.DrawOutlinedRect(0, 0, w, h, 1)
+	end
+end
+
+function Pointshop2.DrawPreviewBackground(w, h)
+	if not drawMat(PREVIEW_MAT, w, h) then
+		surface.SetDrawColor(POPUP_PANEL)
+		surface.DrawRect(0, 0, w, h)
+	end
+end
+
+function Pointshop2.DrawPopupPanelBackground(w, h)
+	surface.SetDrawColor(POPUP_PANEL)
+	surface.DrawRect(0, 0, w, h)
+	surface.SetDrawColor(POPUP_OUTLINE)
+	surface.DrawOutlinedRect(0, 0, w, h, 1)
+end
+
+function Pointshop2.AddPopupBackdrop(frame)
+	if not IsValid(frame) or IsValid(frame.__PS2Backdrop) then return end
+
+	local backdrop = vgui.Create("DPanel")
+	backdrop:SetSize(ScrW(), ScrH())
+	backdrop:SetPos(0, 0)
+	backdrop:SetMouseInputEnabled(false)
+	backdrop:SetKeyboardInputEnabled(false)
+	function backdrop:Paint(pw, ph)
+		surface.SetDrawColor(POPUP_BACKDROP)
+		surface.DrawRect(0, 0, pw, ph)
+	end
+
+	frame.__PS2Backdrop = backdrop
+	frame:MoveToFront()
+
+	local oldRemove = frame.OnRemove
+	function frame:OnRemove(...)
+		if IsValid(self.__PS2Backdrop) then
+			self.__PS2Backdrop:Remove()
+		end
+		if oldRemove then
+			return oldRemove(self, ...)
+		end
+	end
+end
+
+function Pointshop2.DrawItemSlotBackground(pnl, w, h)
+	Pointshop2.DrawItemTileBackground(w, h, Pointshop2.IsTileHovered(pnl))
+	if pnl.Dragging then
+		surface.SetDrawColor(DRAG_OVERLAY)
+		surface.DrawRect(0, 0, w, h)
+	end
+end
+
```

---
## `PS2__lua_ps2_client_cl_clientSettings.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/ps2/client/cl_clientSettings.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/ps2/client/cl_clientSettings.lua	2026-08-18 16:45:35.710543821 +0000
@@ -34,12 +34,42 @@
 }
 
 function Pointshop2.ClientSettings.SaveSettings( settings )
-	Pointshop2.ClientSettings.Settings = settings
-	file.Write( "pointshop2-settings.txt", util.TableToJSON( settings ) )
+	-- change by cookie9216
+	local function normalizeStoredValue( value )
+		if value == "true" then return true end
+		if value == "false" then return false end
+		return value
+	end
+
+	local copy = {}
+	if istable( settings ) then
+		for k, v in pairs( settings ) do
+			copy[k] = normalizeStoredValue( v )
+		end
+	end
+
+	Pointshop2.ClientSettings.Settings = copy
+	file.CreateDir( "pointshop2" )
+	local encoded = util.TableToJSON( copy, true )
+	if not encoded then
+		ErrorNoHalt( "[PS2] Failed to encode client settings.\n" )
+		return false
+	end
+	file.Write( "pointshop2/client_settings.json", encoded )
+	file.Write( "pointshop2-settings.txt", encoded )
+	return true
 end
 
 function Pointshop2.ClientSettings.LoadSettings( )
-	local settings = util.JSONToTable( file.Read( "pointshop2-settings.txt" ) or "{}" )
+	-- change by cookie9216
+	local raw = file.Read( "pointshop2/client_settings.json", "DATA" )
+		or file.Read( "pointshop2-settings.txt", "DATA" )
+		or "{}"
+	local settings = util.JSONToTable( raw ) or {}
+	for k, v in pairs( settings ) do
+		if v == "true" then settings[k] = true end
+		if v == "false" then settings[k] = false end
+	end
 	
 	Pointshop2.ClientSettings.Settings = {}
 	Pointshop2.recursiveSettingsInitialize( Pointshop2.ClientSettings.SettingsTable, settings, Pointshop2.ClientSettings.Settings )
@@ -49,7 +79,12 @@
 end
 
 function Pointshop2.ClientSettings.GetSetting( path )
-	return Pointshop2.ClientSettings.Settings[path]
+	-- change by cookie9216
+	local settings = Pointshop2.ClientSettings.Settings
+	if not istable( settings ) then
+		return nil
+	end
+	return settings[path]
 end
 
 hook.Add( "PS2_ClientSettingsUpdated", "UpdatePACConvars", function( )
```

---
## `PS2__lua_ps2_client_cl_dpointshopframe.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/ps2/client/cl_dpointshopframe.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/ps2/client/cl_dpointshopframe.lua	2026-08-18 16:45:24.158449729 +0000
@@ -2,7 +2,8 @@
 
 function PANEL:Init( )
 	self:SetSkin( Pointshop2.Config.DermaSkin )
-	self:SetSize( math.min( ScrW() - 10, 1255 ), math.min( ScrH( ) - 10, 768 ) )
+	-- change by cookie9216
+	self:SetSize( math.min( ScrW() - 10, 1480 ), math.min( ScrH( ) - 10, 940 ) )
 
 	self.topBar = vgui.Create( "DPanel", self )
 	self.topBar:Dock( TOP )
```

---
## `PS2__lua_ps2_client_cl_DPointshopSimpleItemIcon.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/ps2/client/cl_DPointshopSimpleItemIcon.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/ps2/client/cl_DPointshopSimpleItemIcon.lua	2026-08-18 16:45:35.710543821 +0000
@@ -16,21 +16,14 @@
 end
 
 function PANEL:Paint( w, h )
-	self.lbl:SetText( self.itemClass:GetPrintName( )[1] )
-	local persistenceFactor = ( isnumber( self.itemClass._persistenceId ) and self.itemClass._persistenceId or 0  )
-	self.value = util.CRC( self.itemClass:GetPrintName( ) )
-	math.randomseed( self.value * persistenceFactor )
-	for i = 0, 10 do math.random( ) end
-	
-	local comp1 = math.random( ) * 360
-	local comp2 = math.random( ) / 2 + 0.3
-	local color = HSVToColor( comp1, 1, comp2 )
-	
-	if self.Selected or self.Hovered or self:IsChildHovered( 2 ) then
-		draw.RoundedBox( 6, 0, 0, w, h, self:GetSkin( ).Highlight )
-		draw.RoundedBox( 6, 2, 2, w - 4, h - 4, color )
-	else
-		draw.RoundedBox( 6, 0, 0, w, h, color )
+	-- change by cookie9216
+	if Pointshop2 and Pointshop2.DrawItemTileBackground then
+		Pointshop2.DrawItemTileBackground( w, h, Pointshop2.IsTileHovered( self ) )
+	end
+	if IsValid( self.lbl ) and self.itemClass and self.itemClass.GetPrintName then
+		local txt = self.itemClass:GetPrintName( )
+		self.lbl:SetText( txt and txt[1] or "" )
+		self.lbl:SetTextColor( color_white )
 	end
 end
 
@@ -51,23 +44,14 @@
 
 
 function PANEL:Paint( w, h )
-	self.lbl:SetText( self.item:GetPrintName( )[1] )
-	local persistenceFactor = ( isnumber( self.itemClass._persistenceId ) and self.itemClass._persistenceId or 0  )
-	self.value = util.CRC( self.item:GetPrintName( ) )
-	math.randomseed( self.value * persistenceFactor )
-	for i = 0, 10 do math.random( ) end
-	
-	local comp1 = math.random( ) * 360
-	local comp2 = math.random( ) / 2 + 0.3
-	local color = HSVToColor( comp1, 1, comp2 )
-	surface.SetDrawColor( color )
-	surface.DrawRect( 0, 0, w, h ) 
-	do return end
-	if self.Selected or self.Hovered or self:IsChildHovered( 2 ) then
-		draw.RoundedBox( 6, 0, 0, w, h, self:GetSkin( ).Highlight )
-		draw.RoundedBox( 6, 2, 2, w - 4, h - 4, color )
-	else
-		draw.RoundedBox( 6, 0, 0, w, h, color )
+	-- change by cookie9216
+	if Pointshop2 and Pointshop2.DrawItemTileBackground then
+		Pointshop2.DrawItemTileBackground( w, h, Pointshop2.IsTileHovered( self ) )
+	end
+	if IsValid( self.lbl ) and self.item and self.item.GetPrintName then
+		local txt = self.item:GetPrintName( )
+		self.lbl:SetText( txt and txt[1] or "" )
+		self.lbl:SetTextColor( color_white )
 	end
 end
 
```

---
## `PS2__lua_ps2_client_cl_pointshop2view.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/ps2/client/cl_pointshop2view.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/ps2/client/cl_pointshop2view.lua	2026-08-18 16:45:35.711543916 +0000
@@ -460,12 +460,13 @@
 
 function Pointshop2View:RegenerateIcons( )
     for _, itemClass in pairs( Pointshop2:GetRegisteredItems( ) ) do
-        if not derma.Controls[itemClass:GetPointshopIconControl()] then
-            print(itemClass:GetPointshopIconControl())
+        -- change by cookie9216
+        local ctrlName = itemClass:GetPointshopIconControl()
+        if not derma.Controls[ctrlName] then
             continue
         end
 
-         if LibK.DermaInherits( itemClass:GetPointshopIconControl(), "DCsgoItemIcon" ) then
+        if LibK and LibK.DermaInherits and LibK.DermaInherits( ctrlName, "DCsgoItemIcon" ) then
             Pointshop2.RequestIcon( itemClass, true )
         end
     end
```

---
## `PS2__lua_ps2_client_icons_cl_dpointshopinventoryitemicon.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/ps2/client/icons/cl_dpointshopinventoryitemicon.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/ps2/client/icons/cl_dpointshopinventoryitemicon.lua	2026-08-18 16:45:35.713544105 +0000
@@ -67,6 +67,11 @@
 	self:Select( )
 end
 
-Derma_Hook( PANEL, "Paint", "Paint", "PointshopInvItemIcon" )
+function PANEL:Paint( w, h )
+	-- change by cookie9216
+	if Pointshop2 and Pointshop2.DrawItemTileBackground then
+		Pointshop2.DrawItemTileBackground( w, h, Pointshop2.IsTileHovered( self ) )
+	end
+end
 
 derma.DefineControl( "DPointshopInventoryItemIcon", "", PANEL, "DPanel" )
```

---
## `PS2__lua_ps2_client_icons_cl_dpointshopitemicon.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/ps2/client/icons/cl_dpointshopitemicon.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/ps2/client/icons/cl_dpointshopitemicon.lua	2026-08-18 16:45:35.712544011 +0000
@@ -157,10 +157,10 @@
 end
 
 function PANEL:Select( )
-	print("PANEL:Select()")
-    if self.noSelect then
-        return
-    end
+	-- change by cookie9216
+	if self.noSelect then
+		return
+	end
 
     self.Selected = true
     hook.Run( "PS2_ItemIconSelected", self, self.item or self.itemClass )
@@ -182,6 +182,11 @@
     return true
 end
 
-Derma_Hook( PANEL, "Paint", "Paint", "PointshopItemIcon" )
+function PANEL:Paint( w, h )
+	-- change by cookie9216
+	if Pointshop2 and Pointshop2.DrawItemTileBackground then
+		Pointshop2.DrawItemTileBackground( w, h, Pointshop2.IsTileHovered( self ) )
+	end
+end
 
 derma.DefineControl( "DPointshopItemIcon", "", PANEL, "DPanel" )
```

---
## `PS2__lua_ps2_client_notifications_cl_dpointfeed.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/ps2/client/notifications/cl_dpointfeed.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/ps2/client/notifications/cl_dpointfeed.lua	2026-08-18 16:45:35.720544768 +0000
@@ -17,8 +17,10 @@
 	self.totalScorePanel:Dock( RIGHT )
 	self.totalScorePanel:SetWide( 100 )
 	self.totalScorePanel:DockMargin( 15, 0, 0, 0 )
-	self.totalScorePanel:SetSkin( Pointshop2.Config.DermaSkin )
-	self.totalScorePanel:SetFont( self.totalScorePanel:GetSkin().TabFont )
+	self.totalScorePanel:SetSkin( Pointshop2.Config and Pointshop2.Config.DermaSkin or "Default" )
+	-- change by cookie9216
+	local feedSkin = self.totalScorePanel:GetSkin() or {}
+	self.totalScorePanel:SetFont( feedSkin.TabFont or feedSkin.TextFont or feedSkin.fontName or "DermaDefault" )
 	self.totalScorePanel:SetContentAlignment( 7 )
 	self.totalScorePanel:SetColor( color_white )
 	self.totalScorePanel:SetAlpha( 0 )
@@ -39,6 +41,8 @@
 end
 
 function PANEL:PointsAdded( points ) 
+	-- change by cookie9216
+	if not self.scoreAnim then return end
 	self.accumulatedPoints = self.accumulatedPoints + points
 	self.lastPointAdd = RealTime( )
 	self.totalScorePanel:SetText( self.accumulatedPoints )
@@ -56,6 +60,8 @@
 	
 	self:InvalidateLayout( )
 	
+	-- change by cookie9216
+	if not self.scoreAnim then return end
 	self.scoreAnim:Run( )
 	if self.lastPointAdd + 3 < RealTime( ) and #self.panels == 0 then
 		if not self.scoreAnim:Active( ) then
```

---
## `PS2__lua_ps2_client_notifications_cl_KNotificationPanel.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/ps2/client/notifications/cl_KNotificationPanel.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/ps2/client/notifications/cl_KNotificationPanel.lua	2026-08-18 16:45:35.720544768 +0000
@@ -1,7 +1,7 @@
 local PANEL = {}
 
 function PANEL:Init( )
-	self:SetSkin( Pointshop2.Config.DermaSkin )
+	self:SetSkin( Pointshop2.Config and Pointshop2.Config.DermaSkin or "Default" )
 	
 	self.iconContainer = vgui.Create( "DPanel", self )
 	self.iconContainer:DockMargin( 5, 5, 5, 5 )
@@ -13,7 +13,9 @@
 	self.icon:Dock( TOP )
 	
 	self.descriptionLabel = vgui.Create( "DMultilineLabel", self )
-	self.descriptionLabel.font = self:GetSkin( ).TextFont
+	-- change by cookie9216
+	local notifySkin = self:GetSkin( ) or {}
+	self.descriptionLabel.font = notifySkin.TextFont or notifySkin.fontName or "DermaDefault"
 	self.descriptionLabel:DockMargin( 5, 5, 5, 5 )
 	self.descriptionLabel:Dock( TOP )
 
```

---
## `PS2__lua_ps2_client_notifications_cl_KNotificationPanelManager.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/ps2/client/notifications/cl_KNotificationPanelManager.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/ps2/client/notifications/cl_KNotificationPanelManager.lua	2026-08-18 16:45:35.719544674 +0000
@@ -1,17 +1,22 @@
 local PANEL = {}
 
 function PANEL:Init( )
-	self:SetSkin( Pointshop2.Config.DermaSkin )
+	self:SetSkin( Pointshop2.Config and Pointshop2.Config.DermaSkin or "Default" )
 
 	self.notifications = {}
 	self.stackDirection = 8 --numpad arrows
 	self.notificationsWaiting = {} --queue
 	self.notifications = {}
 	
+	-- change by cookie9216
+	self.slideInDuration = 0.5
+	
 	self.lblTitle = vgui.Create( "DLabel", self )
 	self.lblTitle:DockMargin( 3, 3, 3, 3 )
 	self.lblTitle:Dock( TOP )
-	self.lblTitle:SetFont( self:GetSkin( ).TabFont )
+	-- change by cookie9216
+	local titleSkin = self:GetSkin( ) or {}
+	self.lblTitle:SetFont( titleSkin.TabFont or titleSkin.TextFont or titleSkin.fontName or "DermaDefault" )
 	self.lblTitle:SetText( " Pointshop 2" )
 	self.lblTitle:SetColor( color_white )
 	self.lblTitle:SizeToContents( )
@@ -19,7 +24,7 @@
 	
 	self.panelSlidingIn = false
 	self.slidingStarted = 0
-	self.slideInDuration = 0.5 --1/2 second
+	self.slideInDuration = self.slideInDuration or 0.5 --1/2 second
 	
 	--If no notifications are left, fade self out
 	self.fadedOut = false
@@ -110,7 +115,8 @@
 	end
 	
 	--Position the rest
-	local y = self.lblTitle:GetTall( ) + 3
+	-- change by cookie9216
+	local y = IsValid(self.lblTitle) and (self.lblTitle:GetTall() + 3) or 3
 	for k, notificationPanel in pairs( self.notifications ) do
 		if CurTime( ) > notificationPanel.slideOutStart then
 			if CurTime( ) > notificationPanel.slideOutStart + self.slideInDuration then
```

---
## `PS2__lua_ps2_client_tabs_inventory_tab_cl_dpointshopequipmentslot.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/ps2/client/tabs/inventory_tab/cl_dpointshopequipmentslot.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/ps2/client/tabs/inventory_tab/cl_dpointshopequipmentslot.lua	2026-08-18 16:45:35.719544674 +0000
@@ -182,5 +182,11 @@
 	return true
 end
 
-Derma_Hook( PANEL, "Paint", "Paint", "PointshopEquipmentSlot" )
+function PANEL:Paint( w, h )
+	-- change by cookie9216
+	if Pointshop2 and Pointshop2.DrawItemTileBackground then
+		Pointshop2.DrawItemTileBackground( w, h, Pointshop2.IsTileHovered( self ) )
+	end
+end
+
 derma.DefineControl( "DPointshopEquipmentSlot", "", PANEL, "DPanel" )
```

---
## `PS2__lua_ps2_client_tabs_inventory_tab_cl_dpointshopinventorypreviewpanel.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/ps2/client/tabs/inventory_tab/cl_dpointshopinventorypreviewpanel.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/ps2/client/tabs/inventory_tab/cl_dpointshopinventorypreviewpanel.lua	2026-08-18 16:45:35.719544674 +0000
@@ -9,8 +9,13 @@
 	if hook.Call( "PS2_InvPreviewPanelPaint", GAMEMODE, self ) == false then
 		return
 	end
-	
-	derma.SkinHook( "Paint", "InnerPanel", self, w, h )
+
+	-- change by cookie9216
+	if Pointshop2 and Pointshop2.DrawPreviewBackground then
+		Pointshop2.DrawPreviewBackground( w, h )
+	else
+		derma.SkinHook( "Paint", "InnerPanel", self, w, h )
+	end
 	
 	if ( !IsValid( self.Entity ) ) then return end
 	
```

---
## `PS2__lua_ps2_client_tabs_inventory_tab_cl_dpointshopplayerselect.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/ps2/client/tabs/inventory_tab/cl_dpointshopplayerselect.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/ps2/client/tabs/inventory_tab/cl_dpointshopplayerselect.lua	2026-08-18 16:45:35.718544579 +0000
@@ -39,6 +39,8 @@
 	end
 	
 	function panel.DoClick( )
+		-- change by cookie9216
+		if not IsValid( ply ) then return end
 		self:SelectPlayer( ply )
 	end
 	
@@ -51,11 +53,16 @@
 end
 
 function PANEL:SelectPlayer( ply )
+	-- change by cookie9216
+	if not IsValid( ply ) then
+		return
+	end
 	if IsValid( self.selectedPanel ) and ply == self.selectedPanel.player then
 		return 
 	end
 	
 	for k, v in pairs( self.playerLookup ) do
+		if not IsValid( v ) then continue end
 		local isSelected = v.player == ply
 		v.Selected = isSelected
 		if isSelected then
@@ -66,12 +73,17 @@
 end
 
 function PANEL:RemovePanelFor( ply )
-	if self.playerLookup[ply].Selected then
+	-- change by cookie9216
+	local panel = self.playerLookup[ply]
+	if not IsValid( panel ) then
+		self.playerLookup[ply] = nil
+		return
+	end
+	if panel.Selected then
 		self.selectedPanel = nil
-		self:OnChange( )
+		self:OnChange( nil )
 	end
-	
-	self.playerLookup[ply]:Remove( )
+	panel:Remove( )
 	self.playerLookup[ply] = nil
 	self.playersContainer:InvalidateLayout( )
 end
@@ -83,13 +95,22 @@
 			not table.HasValue( self.players, v.player ) 
 		then
 			v:Remove( )
-			self.playerLookup[v] = nil
+			-- change by cookie9216
+			if IsValid( v.player ) then
+				self.playerLookup[v.player] = nil
+			else
+				for ply, panel in pairs( self.playerLookup ) do
+					if panel == v or not IsValid( ply ) then
+						self.playerLookup[ply] = nil
+					end
+				end
+			end
 		end
 	end
 	
 	--Add added
 	for k, v in pairs( self.players ) do
-		if not IsValid( self.playerLookup[v] ) then
+		if IsValid( v ) and not IsValid( self.playerLookup[v] ) then
 			self:AddPlayer( v )
 		end
 	end
```

---
## `PS2__lua_ps2_client_tabs_inventory_tab_cl_z_DPointshopClientSettings.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/ps2/client/tabs/inventory_tab/cl_z_DPointshopClientSettings.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/ps2/client/tabs/inventory_tab/cl_z_DPointshopClientSettings.lua	2026-08-18 16:45:35.718544579 +0000
@@ -35,9 +35,34 @@
 	self.saveButton:PerformLayout( )
 	self.saveButton:Paint( 10, 10 )
 	function self.saveButton.DoClick( )
-		Pointshop2.ClientSettings.SaveSettings( self.actualSettings.settings )
+		-- change by cookie9216
+		local collected = self.actualSettings.CollectSettings
+			and self.actualSettings:CollectSettings()
+			or self.actualSettings.settings
+
+		local ok = Pointshop2.ClientSettings.SaveSettings( collected )
 		Pointshop2.ClientSettings.LoadSettings( )
-		Derma_Message( "Your settings have been saved. Some settings may require a reconnect to apply." )
+
+		if IsValid( self.actualSettings ) then
+			self.actualSettings:SetData( Pointshop2.ClientSettings.Settings )
+		end
+
+		local lang = GetConVar("gmod_language")
+		local german = lang and (string.lower(lang:GetString() or "en") == "de" or string.sub(string.lower(lang:GetString() or "en"), 1, 3) == "de-")
+		if ok == false then
+			Derma_Message(
+				german and "Einstellungen konnten nicht gespeichert werden." or "Your settings could not be saved.",
+				"Local Settings",
+				"OK"
+			)
+		else
+			Derma_Message(
+				german and "Einstellungen gespeichert. Manche Optionen greifen erst nach Reconnect."
+					or "Your settings have been saved. Some settings may require a reconnect to apply.",
+				"Local Settings",
+				"OK"
+			)
+		end
 	end
 
 	self.infoPanel = vgui.Create( "DInfoPanel", self.scroll )
```

---
## `PS2__lua_ps2_client_tabs_management_tab_cl_hoverpanel.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/ps2/client/tabs/management_tab/cl_hoverpanel.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/ps2/client/tabs/management_tab/cl_hoverpanel.lua	2026-08-18 16:45:35.714544200 +0000
@@ -201,5 +201,14 @@
     end
 end
 
-Derma_Hook( PANEL, "Paint", "Paint", "ItemDescriptionPanel" )
+function PANEL:Paint( w, h )
+	-- change by cookie9216
+	if Pointshop2 and Pointshop2.DrawPreviewBackground then
+		Pointshop2.DrawPreviewBackground( w, h )
+		surface.SetDrawColor( 65, 65, 78, 255 )
+		surface.DrawOutlinedRect( 0, 0, w, h, 1 )
+	end
+	derma.SkinHook( "Paint", "ItemDescriptionPanel", self, w, h )
+end
+
 vgui.Register( "DAdminHoverPanel", PANEL, "DPanel" )
\ No newline at end of file
```

---
## `PS2__lua_ps2_client_tabs_management_tab_create_item_cl_dcreateitembutton.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/ps2/client/tabs/management_tab/create_item/cl_dcreateitembutton.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/ps2/client/tabs/management_tab/create_item/cl_dcreateitembutton.lua	2026-08-18 16:45:35.714544200 +0000
@@ -5,6 +5,10 @@
 
 function PANEL:OnMousePressed( )
 	local creator = vgui.Create( self.itemInfo.creator )
+	-- change by cookie9216
+	if Pointshop2 and Pointshop2.AddPopupBackdrop then
+		Pointshop2.AddPopupBackdrop( creator )
+	end
 	creator:MakePopup( )
 	creator:SetItemBase( self.itemInfo.base )
 	creator:SetSkin( Pointshop2.Config.DermaSkin )
```

---
## `PS2__lua_ps2_client_tabs_management_tab_settings_cl_dsettingspanel.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/ps2/client/tabs/management_tab/settings/cl_dsettingspanel.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/ps2/client/tabs/management_tab/settings/cl_dsettingspanel.lua	2026-08-18 16:45:35.717544484 +0000
@@ -15,11 +15,14 @@
 end
 
 function PANEL:SetData( data )
-	self.settings = data
+	-- change by cookie9216
+	self.settings = istable(data) and data or {}
 	self:InitSettings( )
 end
 
 function PANEL:InitSettings( )
+	-- change by cookie9216
+	if not istable(self.settings) then return end
 	for path, value in pairs( self.settings ) do
 		if self.settingsLookup[path] then
 			self.settingsLookup[path]:SetValue( value )
@@ -31,6 +34,32 @@
 	self.settings[path] = value
 end
 
+-- change by cookie9216
+function PANEL:CollectSettings( )
+	local out = {}
+	if istable( self.settings ) then
+		for path, value in pairs( self.settings ) do
+			out[path] = value
+		end
+	end
+	for path, panel in pairs( self.settingsLookup or {} ) do
+		if not IsValid( panel ) then continue end
+		if IsValid( panel.container ) and IsValid( panel.container.checkbox ) then
+			out[path] = panel.container.checkbox:GetChecked() == true
+		elseif IsValid( panel.numberWang ) then
+			out[path] = tonumber( panel.numberWang:GetValue() ) or 0
+		elseif IsValid( panel.textEntry ) then
+			out[path] = panel.textEntry:GetValue()
+		elseif IsValid( panel.combobox ) then
+			out[path] = panel.combobox:GetSelected() or panel.combobox:GetValue()
+		elseif IsValid( panel.radiobox ) and panel.radiobox.GetSelectedOption then
+			local opt = panel.radiobox:GetSelectedOption()
+			if IsValid( opt ) then out[path] = opt:GetText() end
+		end
+	end
+	return out
+end
+
 function PANEL:AutoAddSettingsTable( tbl, settingListener )
 	settingListener = settingListener or self
 	
```

---
## `PS2__lua_ps2_client_tabs_management_tab_settings_cl_dsettingssection.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/ps2/client/tabs/management_tab/settings/cl_dsettingssection.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/ps2/client/tabs/management_tab/settings/cl_dsettingssection.lua	2026-08-18 16:45:35.717544484 +0000
@@ -161,7 +161,8 @@
 	
 	local settingPanel = self[creatorFn]( self, settingsPath, settingInfo )
 	self:AddSettingPanel( settingPanel )
-	if settingInfo.value then
+	-- change by cookie9216
+	if settingInfo.value ~= nil then
 		settingPanel:SetValue( settingInfo.value )
 	end
 	return settingPanel
```

---
## `PS2__lua_ps2_client_tabs_shop_tab_cl_dpointshopcategorypanel.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/ps2/client/tabs/shop_tab/cl_dpointshopcategorypanel.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/ps2/client/tabs/shop_tab/cl_dpointshopcategorypanel.lua	2026-08-18 16:45:35.718544579 +0000
@@ -99,4 +99,4 @@
 end
 
 derma.DefineControl( "DPointshopCategoryPanel", "", PANEL, "DPanel" )
-print("hi")
\ No newline at end of file
+-- change by cookie9216
```

---
## `PS2__lua_ps2_client_tabs_shop_tab_cl_dpointshoppreviewpanel.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/ps2/client/tabs/shop_tab/cl_dpointshoppreviewpanel.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/ps2/client/tabs/shop_tab/cl_dpointshoppreviewpanel.lua	2026-08-18 16:45:35.717544484 +0000
@@ -60,9 +60,13 @@
 	if hook.Call( "PS2_PreviewPanelPaint", GAMEMODE, self ) == false then
 		return
 	end
-	
-	
-	derma.SkinHook( "Paint", "InnerPanel", self, w, h )
+
+	-- change by cookie9216
+	if Pointshop2 and Pointshop2.DrawPreviewBackground then
+		Pointshop2.DrawPreviewBackground( w, h )
+	else
+		derma.SkinHook( "Paint", "InnerPanel", self, w, h )
+	end
 	
 	if ( !IsValid( self.Entity ) ) then return end
 	
```

---
## `PS2__lua_ps2_modules_pointshop2_item_factories_cl_DItemFactoryConfigurationFrame.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/ps2/modules/pointshop2/item_factories/cl_DItemFactoryConfigurationFrame.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/ps2/modules/pointshop2/item_factories/cl_DItemFactoryConfigurationFrame.lua	2026-08-18 16:45:35.734546094 +0000
@@ -57,4 +57,12 @@
 function PANEL:OnFinish( settings )
 end
 
+function PANEL:Paint( w, h )
+	-- change by cookie9216
+	if Pointshop2 and Pointshop2.DrawPopupPanelBackground then
+		Pointshop2.DrawPopupPanelBackground( w, h )
+		return true
+	end
+end
+
 vgui.Register( "DItemFactoryConfigurationFrame", PANEL, "DFrame" )
\ No newline at end of file
```

---
## `PS2__lua_ps2_server_sv_pointshopcontroller.lua`
```diff
--- /tmp/tmp.2S5MPfCRGI/lua/ps2/server/sv_pointshopcontroller.lua	2025-12-01 09:58:12.000000000 +0000
+++ /home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master/lua/ps2/server/sv_pointshopcontroller.lua	2026-08-18 16:45:35.722544958 +0000
@@ -291,38 +291,55 @@
     KLogf( 5, "[PS2] initPlayer(%s), modules loaded: %s", ply:Nick( ), getPromiseState( Pointshop2.ModuleItemsLoadedPromise ) )
     local controller = Pointshop2Controller:getInstance( )
 
+    -- change by cookie9216
+    local PS2_JOIN_RESOURCE_GAP = 0.75
+
     Pointshop2.DatabaseConnectedPromise:Fail( function( err )
         print("DB Faled", err)
-        if ply:IsAdmin( ) then
-            timer.Simple( 2, function( )
-                ply:PS2_DisplayError( "[CRITICAL][ADMIN ONLY] Your MySQL/Server configuration is faulty. (" .. err .. "). Please fix these errors. Other parts of your server can be affected by errors if this is not fixed.", 1000 )
-            end )
-        end
+        timer.Simple( 2, function( )
+            if not IsValid( ply ) or not ply:IsAdmin( ) then return end
+            ply:PS2_DisplayError( "[CRITICAL][ADMIN ONLY] Your MySQL/Server configuration is faulty. (" .. err .. "). Please fix these errors. Other parts of your server can be affected by errors if this is not fixed.", 1000 )
+        end )
     end )
 
-    Pointshop2.OutfitsLoadedPromise:Then( function( )
-        controller:SendInitialOutfitPackage( ply )
-    end )
-    Pointshop2.SettingsLoadedPromise:Then( function( )
-        controller:SendInitialSettingsPackage( ply )
-    end )
-    Pointshop2.ModuleItemsLoadedPromise:Then( function( )
-        controller:sendDynamicInfo( ply )
-        return WhenAllFinished{
-            ply.dynamicsReceivedPromise:Promise(),
-            controller:sendWallet( ply )
-        }
-    end ):Done( function( )
-        --TODO: Make a proper promise/transaction for this
+    local function afterDynamicsLoaded( )
         timer.Simple( 2, function( )
+            if not IsValid( ply ) then return end
             WhenAllFinished{ controller:initializeInventory( ply ),
                 controller:initializeSlots( ply ),
                 ply.outfitsReceivedPromise
             }:Done( function( )
+                if not IsValid( ply ) then return end
                 controller:sendActiveEquipmentTo( ply )
                 hook.Run("PS2_PlayerFullyLoaded", ply)
             end )
         end )
+    end
+
+    Pointshop2.ModuleItemsLoadedPromise:Then( function( )
+        if not IsValid( ply ) then return end
+        timer.Simple( PS2_JOIN_RESOURCE_GAP, function( )
+            if not IsValid( ply ) then return end
+            Pointshop2.OutfitsLoadedPromise:Then( function( )
+                if not IsValid( ply ) then return end
+                controller:SendInitialOutfitPackage( ply )
+            end )
+            timer.Simple( PS2_JOIN_RESOURCE_GAP, function( )
+                if not IsValid( ply ) then return end
+                Pointshop2.SettingsLoadedPromise:Then( function( )
+                    if not IsValid( ply ) then return end
+                    controller:SendInitialSettingsPackage( ply )
+                end )
+                timer.Simple( PS2_JOIN_RESOURCE_GAP, function( )
+                    if not IsValid( ply ) then return end
+                    controller:sendDynamicInfo( ply )
+                    return WhenAllFinished{
+                        ply.dynamicsReceivedPromise:Promise(),
+                        controller:sendWallet( ply )
+                    }:Done( afterDynamicsLoaded )
+                end )
+            end )
+        end )
     end )
 end
 
@@ -347,7 +364,7 @@
     KLogf( 5, "[PS2] Initializing player %s, modules loaded: %s", ply:Nick( ), getPromiseState( Pointshop2.ModuleItemsLoadedPromise ) )
     ply._initHandled = true
 
-    timer.Simple( 1, function( )
+    timer.Simple( 1.5, function( )
         if not IsValid( ply ) then
             KLogf( 4, "[PS2] Loading a player failed, possible disconnect" )
             return
@@ -364,7 +381,7 @@
         ply._initHandled = true
         KLogf( 5, "[PS2] Bootstrapping player %s, modules loaded: %s", ply:Nick( ), getPromiseState( Pointshop2.ModuleItemsLoadedPromise ) )
 
-        timer.Simple( 1, function( )
+        timer.Simple( 1.5, function( )
             if not IsValid( ply ) then
                 return
             end
@@ -703,6 +720,8 @@
         if string.len( ChatCommand ) > 0 then
             if string.sub( msg, 0, string.len( ChatCommand ) ) == ChatCommand then
                 self:startView( "Pointshop2View", "toggleMenu", ply )
+                -- change by cookie9216
+                return ""
             end
         end
     end )
```

