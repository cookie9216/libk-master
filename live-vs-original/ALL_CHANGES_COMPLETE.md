# Live vs Original — PS2, LibK, PAC3

Erstellt: 2026-08-18T18:28:41Z

Nur **0020_ps2-master**, **0020_libk-master**, **0020_pac3-master**.  
Patches: [`diffs/`](diffs/)

## PS2

Original: `/home/cookie/github/ps2-master` @ `af60bf7` (Branch `upstream-original`)
Live: `/home/cookie/gmod/serverfiles/garrysmod/addons/0020_ps2-master`

GitHub Compare: siehe [README](README.md#github-compare)

### Geänderte Dateien

| Datei | Patch | +/− (Zeilen) | cookie9216 |
|---|---|---|---|
| `lua/kinv/client/cl_ditemscontainer.lua` | [patch](diffs/PS2__lua_kinv_client_cl_ditemscontainer.lua.patch) | +2 / −2 | ja |
| `lua/kinv/client/cl_ditemslot.lua` | [patch](diffs/PS2__lua_kinv_client_cl_ditemslot.lua.patch) | +21 / −14 | ja |
| `lua/kinv/client/cl_ditemstack.lua` | [patch](diffs/PS2__lua_kinv_client_cl_ditemstack.lua.patch) | +25 / −2 | ja |
| `lua/kinv/client/cl_item.lua` | [patch](diffs/PS2__lua_kinv_client_cl_item.lua.patch) | +19 / −1 | ja |
| `lua/kinv/items/pointshop/sh_base_hat.lua` | [patch](diffs/PS2__lua_kinv_items_pointshop_sh_base_hat.lua.patch) | +58 / −7 | ja |
| `lua/kinv/items/pointshop/sh_base_playermodel.lua` | [patch](diffs/PS2__lua_kinv_items_pointshop_sh_base_playermodel.lua.patch) | +2 / −2 | ja |
| `lua/kinv/shared/sh_0_kinventory.lua` | [patch](diffs/PS2__lua_kinv_shared_sh_0_kinventory.lua.patch) | +2 / −2 | ja |
| `lua/ps2/client/cl_clientSettings.lua` | [patch](diffs/PS2__lua_ps2_client_cl_clientSettings.lua.patch) | +40 / −5 | ja |
| `lua/ps2/client/cl_dpointshopframe.lua` | [patch](diffs/PS2__lua_ps2_client_cl_dpointshopframe.lua.patch) | +3 / −2 | ja |
| `lua/ps2/client/cl_DPointshopSimpleItemIcon.lua` | [patch](diffs/PS2__lua_ps2_client_cl_DPointshopSimpleItemIcon.lua.patch) | +17 / −33 | ja |
| `lua/ps2/client/cl_pointshop2view.lua` | [patch](diffs/PS2__lua_ps2_client_cl_pointshop2view.lua.patch) | +5 / −4 | ja |
| `lua/ps2/client/icons/cl_dpointshopinventoryitemicon.lua` | [patch](diffs/PS2__lua_ps2_client_icons_cl_dpointshopinventoryitemicon.lua.patch) | +7 / −2 | ja |
| `lua/ps2/client/icons/cl_dpointshopitemicon.lua` | [patch](diffs/PS2__lua_ps2_client_icons_cl_dpointshopitemicon.lua.patch) | +11 / −6 | ja |
| `lua/ps2/client/notifications/cl_dpointfeed.lua` | [patch](diffs/PS2__lua_ps2_client_notifications_cl_dpointfeed.lua.patch) | +9 / −3 | ja |
| `lua/ps2/client/notifications/cl_KNotificationPanel.lua` | [patch](diffs/PS2__lua_ps2_client_notifications_cl_KNotificationPanel.lua.patch) | +5 / −3 | ja |
| `lua/ps2/client/notifications/cl_KNotificationPanelManager.lua` | [patch](diffs/PS2__lua_ps2_client_notifications_cl_KNotificationPanelManager.lua.patch) | +11 / −5 | ja |
| `lua/ps2/client/tabs/inventory_tab/cl_dpointshopequipmentslot.lua` | [patch](diffs/PS2__lua_ps2_client_tabs_inventory_tab_cl_dpointshopequipmentslot.lua.patch) | +8 / −2 | ja |
| `lua/ps2/client/tabs/inventory_tab/cl_dpointshopinventorypreviewpanel.lua` | [patch](diffs/PS2__lua_ps2_client_tabs_inventory_tab_cl_dpointshopinventorypreviewpanel.lua.patch) | +8 / −3 | ja |
| `lua/ps2/client/tabs/inventory_tab/cl_dpointshopplayerselect.lua` | [patch](diffs/PS2__lua_ps2_client_tabs_inventory_tab_cl_dpointshopplayerselect.lua.patch) | +28 / −7 | ja |
| `lua/ps2/client/tabs/inventory_tab/cl_z_DPointshopClientSettings.lua` | [patch](diffs/PS2__lua_ps2_client_tabs_inventory_tab_cl_z_DPointshopClientSettings.lua.patch) | +28 / −3 | ja |
| `lua/ps2/client/tabs/management_tab/cl_hoverpanel.lua` | [patch](diffs/PS2__lua_ps2_client_tabs_management_tab_cl_hoverpanel.lua.patch) | +11 / −2 | ja |
| `lua/ps2/client/tabs/management_tab/create_item/cl_dcreateitembutton.lua` | [patch](diffs/PS2__lua_ps2_client_tabs_management_tab_create_item_cl_dcreateitembutton.lua.patch) | +5 / −1 | ja |
| `lua/ps2/client/tabs/management_tab/settings/cl_dsettingspanel.lua` | [patch](diffs/PS2__lua_ps2_client_tabs_management_tab_settings_cl_dsettingspanel.lua.patch) | +31 / −2 | ja |
| `lua/ps2/client/tabs/management_tab/settings/cl_dsettingssection.lua` | [patch](diffs/PS2__lua_ps2_client_tabs_management_tab_settings_cl_dsettingssection.lua.patch) | +3 / −2 | ja |
| `lua/ps2/client/tabs/shop_tab/cl_dpointshopcategorypanel.lua` | [patch](diffs/PS2__lua_ps2_client_tabs_shop_tab_cl_dpointshopcategorypanel.lua.patch) | +2 / −2 | ja |
| `lua/ps2/client/tabs/shop_tab/cl_dpointshoppreviewpanel.lua` | [patch](diffs/PS2__lua_ps2_client_tabs_shop_tab_cl_dpointshoppreviewpanel.lua.patch) | +8 / −4 | ja |
| `lua/ps2/modules/pointshop2/item_factories/cl_DItemFactoryConfigurationFrame.lua` | [patch](diffs/PS2__lua_ps2_modules_pointshop2_item_factories_cl_DItemFactoryConfigurationFrame.lua.patch) | +9 / −1 | ja |
| `lua/ps2/server/sv_pointshopcontroller.lua` | [patch](diffs/PS2__lua_ps2_server_sv_pointshopcontroller.lua.patch) | +41 / −22 | ja |

### Nur Live (neu)

- `addon.json` — [patch](diffs/PS2__addon.json.patch)
- `lua/ps2/client/cl_0_tilepaint.lua` — [patch](diffs/PS2__lua_ps2_client_cl_0_tilepaint.lua.patch)

### Nur Original (in Live fehlend)

- `changelog_footer_template.hbs`

**Zählung:** geändert=28, neu=2, fehlend=1

## LibK

Original: `/home/cookie/github/libk-master` @ `62b006d` (Branch `upstream-original`)
Live: `/home/cookie/gmod/serverfiles/garrysmod/addons/0020_libk-master`

GitHub Compare: siehe [README](README.md#github-compare)

### Geänderte Dateien

| Datei | Patch | +/− (Zeilen) | cookie9216 |
|---|---|---|---|
| `lua/libk/3rdparty/glib/transfers/transfers.lua` | [patch](diffs/LibK__lua_libk_3rdparty_glib_transfers_transfers.lua.patch) | +6 / −2 | ja |
| `lua/libk/client/cl_libk_baseView.lua` | [patch](diffs/LibK__lua_libk_client_cl_libk_baseView.lua.patch) | +3 / −3 | ja |
| `lua/libk/server/sv_libk_model.lua` | [patch](diffs/LibK__lua_libk_server_sv_libk_model.lua.patch) | +34 / −2 | ja |
| `lua/libk/server/sv_libk_player.lua` | [patch](diffs/LibK__lua_libk_server_sv_libk_player.lua.patch) | +35 / −11 | ja |
| `lua/libk/server/sv_libk_server.lua` | [patch](diffs/LibK__lua_libk_server_sv_libk_server.lua.patch) | +9 / −3 | ja |
| `lua/libk/server/sv_permissionInterface.lua` | [patch](diffs/LibK__lua_libk_server_sv_permissionInterface.lua.patch) | +5 / −3 | ja |
| `lua/libk/shared/sh_permissionInterface.lua` | [patch](diffs/LibK__lua_libk_shared_sh_permissionInterface.lua.patch) | +3 / −2 | ja |
| `lua/libk/shared/sh_thirdparty.lua` | [patch](diffs/LibK__lua_libk_shared_sh_thirdparty.lua.patch) | +2 / −2 | ja |

### Nur Live (neu)

- `addon.json` — [patch](diffs/LibK__addon.json.patch)

### Nur Original (in Live fehlend)


**Zählung:** geändert=8, neu=1, fehlend=0

## PAC3

Original: `/home/cookie/github/pac3-master` @ `e9109717` (Branch `upstream-original`)
Live: `/home/cookie/gmod/serverfiles/garrysmod/addons/0020_pac3-master`

GitHub Compare: siehe [README](README.md#github-compare)

### Geänderte Dateien

| Datei | Patch | +/− (Zeilen) | cookie9216 |
|---|---|---|---|
| `lua/pac3/core/client/base_part.lua` | [patch](diffs/PAC3__lua_pac3_core_client_base_part.lua.patch) | +8 / −2 | ja |
| `lua/pac3/core/client/init.lua` | [patch](diffs/PAC3__lua_pac3_core_client_init.lua.patch) | +4 / −1 | ja |
| `lua/pac3/core/client/integration_tools.lua` | [patch](diffs/PAC3__lua_pac3_core_client_integration_tools.lua.patch) | +17 / −7 | ja |
| `lua/pac3/core/client/part_pool.lua` | [patch](diffs/PAC3__lua_pac3_core_client_part_pool.lua.patch) | +15 / −1 | ja |
| `lua/pac3/core/client/parts/effect.lua` | [patch](diffs/PAC3__lua_pac3_core_client_parts_effect.lua.patch) | +4 / −1 | ja |
| `lua/pac3/core/server/effects.lua` | [patch](diffs/PAC3__lua_pac3_core_server_effects.lua.patch) | +23 / −2 | ja |
| `lua/pac3/core/server/init.lua` | [patch](diffs/PAC3__lua_pac3_core_server_init.lua.patch) | +5 / −1 | ja |
| `lua/pac3/core/shared/http.lua` | [patch](diffs/PAC3__lua_pac3_core_shared_http.lua.patch) | +11 / −1 | ja |
| `lua/pac3/core/shared/init.lua` | [patch](diffs/PAC3__lua_pac3_core_shared_init.lua.patch) | +4 / −1 | ja |
| `lua/pac3/editor/server/init.lua` | [patch](diffs/PAC3__lua_pac3_editor_server_init.lua.patch) | +18 / −2 | ja |
| `lua/pac3/editor/server/wear.lua` | [patch](diffs/PAC3__lua_pac3_editor_server_wear.lua.patch) | +30 / −2 | ja |

### Nur Live (neu)

- `lua/pac3/core/client/security_client.lua` — [patch](diffs/PAC3__lua_pac3_core_client_security_client.lua.patch)
- `lua/pac3/core/server/security_policy.lua` — [patch](diffs/PAC3__lua_pac3_core_server_security_policy.lua.patch)
- `lua/pac3/core/server/security_validate.lua` — [patch](diffs/PAC3__lua_pac3_core_server_security_validate.lua.patch)
- `lua/pac3/core/shared/security_config.lua` — [patch](diffs/PAC3__lua_pac3_core_shared_security_config.lua.patch)
- `lua/pac3/core/shared/security.lua` — [patch](diffs/PAC3__lua_pac3_core_shared_security.lua.patch)
- `PAC3_SECURITY_CONFIG.md` — [patch](diffs/PAC3__PAC3_SECURITY_CONFIG.md.patch)

### Nur Original (in Live fehlend)


**Zählung:** geändert=11, neu=6, fehlend=0

