# 2026-01-31T12:48:33.720868850
import vitis

client = vitis.create_client()
client.set_workspace(path="../sw/vitis")

platform = client.create_platform_component(name = "platform",hw_design = "$COMPONENT_LOCATION/../../../hw/export/system_wrapper.xsa",os = "standalone",cpu = "microblaze_0",domain_name = "standalone_microblaze_0",compiler = "gcc")

comp = client.create_app_component(name="app_component",platform = "$COMPONENT_LOCATION/../platform/export/platform/platform.xpfm",domain = "standalone_microblaze_0")

status = comp.import_files(from_loc="../sw", files=["src"], is_skip_copy_sources = False)

status = platform.build()

comp.build()

