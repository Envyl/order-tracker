import uuid, os

root = r"D:\Jules\ios"
files = [
    "App/OrderTrackerApp.swift",
    "App/RootView.swift",
    "App/AppServices.swift",
    "Domain/Enums.swift",
    "Domain/Models.swift",
    "Persistence/SwiftDataModels.swift",
    "Persistence/PersistenceController.swift",
    "Persistence/ConnectionRepository.swift",
    "Persistence/OrderRepository.swift",
    "Security/KeychainSessionStore.swift",
    "Security/RedactingLog.swift",
    "Providers/ProviderAdapter.swift",
    "Providers/HTTPClient.swift",
    "Providers/ProviderFixtures.swift",
    "Providers/RefreshOrchestrator.swift",
    "Providers/ProviderRegistry.swift",
    "Providers/Wildberries/WildberriesAdapter.swift",
    "Providers/Wildberries/WildberriesStatusMapper.swift",
    "Providers/AliExpress/AliExpressAdapter.swift",
    "Providers/AliExpress/AliExpressStatusMapper.swift",
    "Providers/CDEK/CDEKAdapter.swift",
    "Providers/CDEK/CDEKStatusMapper.swift",
    "Features/Connections/ConnectionsView.swift",
    "Features/Connections/ConnectionsViewModel.swift",
    "Features/Connections/WildberriesConnectView.swift",
    "Features/Connections/AliExpressConnectView.swift",
    "Features/Connections/CDEKConnectView.swift",
    "Features/Orders/OrdersListView.swift",
    "Features/Orders/OrdersListViewModel.swift",
    "Features/Orders/OrderRowView.swift",
    "Features/Orders/OrderDetailView.swift",
    "Features/Orders/OrderDetailViewModel.swift",
    "Features/Orders/ProviderStatusBanner.swift",
    "App/Info.plist",
]


def nid():
    return uuid.uuid4().hex[:24].upper()


project_id = nid()
target_id = nid()
sources_phase = nid()
resources_phase = nid()
frameworks_phase = nid()
project_config_list = nid()
target_config_list = nid()
debug_proj = nid()
release_proj = nid()
debug_tgt = nid()
release_tgt = nid()
product_ref = nid()
main_group = nid()
products_group = nid()

groups = {
    "App": nid(),
    "Domain": nid(),
    "Persistence": nid(),
    "Security": nid(),
    "Providers": nid(),
    "Features": nid(),
}
providers_sub = {"Wildberries": nid(), "AliExpress": nid(), "CDEK": nid()}
features_sub = {"Connections": nid(), "Orders": nid()}

file_entries = []
build_files = []
for f in files:
    fid = nid()
    bfid = nid()
    name = os.path.basename(f)
    file_entries.append((fid, bfid, name, f))
    if f.endswith(".swift"):
        build_files.append((bfid, fid, name))


def group_children(prefix):
    kids = []
    for fid, bfid, name, fpath in file_entries:
        parent = os.path.dirname(fpath).replace("\\", "/")
        if parent == prefix:
            kids.append(f"\t\t\t\t{fid} /* {name} */,")
    return kids


lines = []
W = lines.append
W("// !$*UTF8*$!")
W("{")
W("\tarchiveVersion = 1;")
W("\tclasses = {};")
W("\tobjectVersion = 56;")
W("\tobjects = {")
W("")
W("/* Begin PBXBuildFile section */")
for bfid, fid, name in build_files:
    W(f"\t\t{bfid} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {fid} /* {name} */; }};")
W("/* End PBXBuildFile section */")
W("")
W("/* Begin PBXFileReference section */")
W(
    f"\t\t{product_ref} /* OrderTracker.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = OrderTracker.app; sourceTree = BUILT_PRODUCTS_DIR; }};"
)
for fid, bfid, name, fpath in file_entries:
    if fpath.endswith(".plist"):
        W(
            f"\t\t{fid} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = {name}; sourceTree = \"<group>\"; }};"
        )
    else:
        W(
            f"\t\t{fid} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {name}; sourceTree = \"<group>\"; }};"
        )
W("/* End PBXFileReference section */")
W("")
W("/* Begin PBXGroup section */")
W(f"\t\t{main_group} = {{")
W("\t\t\tisa = PBXGroup;")
W("\t\t\tchildren = (")
for gname, gid in groups.items():
    W(f"\t\t\t\t{gid} /* {gname} */,")
W(f"\t\t\t\t{products_group} /* Products */,")
W("\t\t\t);")
W('\t\t\tsourceTree = "<group>";')
W("\t\t};")
W(f"\t\t{products_group} /* Products */ = {{")
W("\t\t\tisa = PBXGroup;")
W("\t\t\tchildren = (")
W(f"\t\t\t\t{product_ref} /* OrderTracker.app */,")
W("\t\t\t);")
W("\t\t\tname = Products;")
W('\t\t\tsourceTree = "<group>";')
W("\t\t};")

for gname, gid in groups.items():
    W(f"\t\t{gid} /* {gname} */ = {{")
    W("\t\t\tisa = PBXGroup;")
    W("\t\t\tchildren = (")
    if gname == "Providers":
        for sn, sid in providers_sub.items():
            W(f"\t\t\t\t{sid} /* {sn} */,")
        for line in group_children("Providers"):
            W(line)
    elif gname == "Features":
        for sn, sid in features_sub.items():
            W(f"\t\t\t\t{sid} /* {sn} */,")
    else:
        for line in group_children(gname):
            W(line)
    W("\t\t\t);")
    W(f"\t\t\tpath = {gname};")
    W('\t\t\tsourceTree = "<group>";')
    W("\t\t};")

for sn, sid in providers_sub.items():
    W(f"\t\t{sid} /* {sn} */ = {{")
    W("\t\t\tisa = PBXGroup;")
    W("\t\t\tchildren = (")
    for line in group_children(f"Providers/{sn}"):
        W(line)
    W("\t\t\t);")
    W(f"\t\t\tpath = {sn};")
    W('\t\t\tsourceTree = "<group>";')
    W("\t\t};")

for sn, sid in features_sub.items():
    W(f"\t\t{sid} /* {sn} */ = {{")
    W("\t\t\tisa = PBXGroup;")
    W("\t\t\tchildren = (")
    for line in group_children(f"Features/{sn}"):
        W(line)
    W("\t\t\t);")
    W(f"\t\t\tpath = {sn};")
    W('\t\t\tsourceTree = "<group>";')
    W("\t\t};")

W("/* End PBXGroup section */")
W("")
W("/* Begin PBXNativeTarget section */")
W(f"\t\t{target_id} /* OrderTracker */ = {{")
W("\t\t\tisa = PBXNativeTarget;")
W(
    f'\t\t\tbuildConfigurationList = {target_config_list} /* Build configuration list for PBXNativeTarget "OrderTracker" */;'
)
W("\t\t\tbuildPhases = (")
W(f"\t\t\t\t{sources_phase} /* Sources */,")
W(f"\t\t\t\t{frameworks_phase} /* Frameworks */,")
W(f"\t\t\t\t{resources_phase} /* Resources */,")
W("\t\t\t);")
W("\t\t\tbuildRules = (")
W("\t\t\t);")
W("\t\t\tdependencies = (")
W("\t\t\t);")
W("\t\t\tname = OrderTracker;")
W("\t\t\tproductName = OrderTracker;")
W(f"\t\t\tproductReference = {product_ref} /* OrderTracker.app */;")
W('\t\t\tproductType = "com.apple.product-type.application";')
W("\t\t};")
W("/* End PBXNativeTarget section */")
W("")
W("/* Begin PBXProject section */")
W(f"\t\t{project_id} /* Project object */ = {{")
W("\t\t\tisa = PBXProject;")
W("\t\t\tattributes = {")
W("\t\t\t\tBuildIndependentTargetsInParallel = 1;")
W("\t\t\t\tLastSwiftUpdateCheck = 1500;")
W("\t\t\t\tLastUpgradeCheck = 1500;")
W("\t\t\t};")
W(
    f'\t\t\tbuildConfigurationList = {project_config_list} /* Build configuration list for PBXProject "OrderTracker" */;'
)
W('\t\t\tcompatibilityVersion = "Xcode 14.0";')
W("\t\t\tdevelopmentRegion = ru;")
W("\t\t\thasScannedForEncodings = 0;")
W("\t\t\tknownRegions = (")
W("\t\t\t\ten,")
W("\t\t\t\tru,")
W("\t\t\t\tBase,")
W("\t\t\t);")
W(f"\t\t\tmainGroup = {main_group};")
W(f"\t\t\tproductRefGroup = {products_group} /* Products */;")
W('\t\t\tprojectDirPath = "";')
W('\t\t\tprojectRoot = "";')
W("\t\t\ttargets = (")
W(f"\t\t\t\t{target_id} /* OrderTracker */,")
W("\t\t\t);")
W("\t\t};")
W("/* End PBXProject section */")
W("")
W("/* Begin PBXSourcesBuildPhase section */")
W(f"\t\t{sources_phase} /* Sources */ = {{")
W("\t\t\tisa = PBXSourcesBuildPhase;")
W("\t\t\tbuildActionMask = 2147483647;")
W("\t\t\tfiles = (")
for bfid, fid, name in build_files:
    W(f"\t\t\t\t{bfid} /* {name} in Sources */,")
W("\t\t\t);")
W("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
W("\t\t};")
W("/* End PBXSourcesBuildPhase section */")
W("")
W("/* Begin PBXFrameworksBuildPhase section */")
W(f"\t\t{frameworks_phase} /* Frameworks */ = {{")
W("\t\t\tisa = PBXFrameworksBuildPhase;")
W("\t\t\tbuildActionMask = 2147483647;")
W("\t\t\tfiles = (")
W("\t\t\t);")
W("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
W("\t\t};")
W("/* End PBXFrameworksBuildPhase section */")
W("")
W("/* Begin PBXResourcesBuildPhase section */")
W(f"\t\t{resources_phase} /* Resources */ = {{")
W("\t\t\tisa = PBXResourcesBuildPhase;")
W("\t\t\tbuildActionMask = 2147483647;")
W("\t\t\tfiles = (")
W("\t\t\t);")
W("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
W("\t\t};")
W("/* End PBXResourcesBuildPhase section */")
W("")
W("/* Begin XCBuildConfiguration section */")
for cfg_id, name in [(debug_proj, "Debug"), (release_proj, "Release")]:
    W(f"\t\t{cfg_id} /* {name} */ = {{")
    W("\t\t\tisa = XCBuildConfiguration;")
    W("\t\t\tbuildSettings = {")
    W("\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;")
    W("\t\t\t\tCLANG_ENABLE_MODULES = YES;")
    W("\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;")
    W("\t\t\t\tCOPY_PHASE_STRIP = NO;")
    W("\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;")
    W("\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;")
    W(f"\t\t\t\tONLY_ACTIVE_ARCH = {'YES' if name == 'Debug' else 'NO'};")
    W("\t\t\t\tSDKROOT = iphoneos;")
    W("\t\t\t\tSWIFT_VERSION = 5.0;")
    W("\t\t\t};")
    W(f"\t\t\tname = {name};")
    W("\t\t};")

for cfg_id, name in [(debug_tgt, "Debug"), (release_tgt, "Release")]:
    W(f"\t\t{cfg_id} /* {name} */ = {{")
    W("\t\t\tisa = XCBuildConfiguration;")
    W("\t\t\tbuildSettings = {")
    W("\t\t\t\tCODE_SIGN_STYLE = Automatic;")
    W("\t\t\t\tCURRENT_PROJECT_VERSION = 1;")
    W('\t\t\t\tDEVELOPMENT_TEAM = "";')
    W("\t\t\t\tENABLE_PREVIEWS = YES;")
    W("\t\t\t\tGENERATE_INFOPLIST_FILE = NO;")
    W("\t\t\t\tINFOPLIST_FILE = App/Info.plist;")
    W('\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = "Order Tracker";')
    W("\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (")
    W('\t\t\t\t\t"$(inherited)",')
    W('\t\t\t\t\t"@executable_path/Frameworks",')
    W("\t\t\t\t);")
    W("\t\t\t\tMARKETING_VERSION = 1.0;")
    W("\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.personal.ordertracker;")
    W('\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";')
    W('\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator";')
    W("\t\t\t\tSUPPORTS_MACCATALYST = NO;")
    W("\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;")
    W("\t\t\t\tSWIFT_VERSION = 5.0;")
    W("\t\t\t\tTARGETED_DEVICE_FAMILY = 1;")
    W("\t\t\t};")
    W(f"\t\t\tname = {name};")
    W("\t\t};")
W("/* End XCBuildConfiguration section */")
W("")
W("/* Begin XCConfigurationList section */")
W(
    f'\t\t{project_config_list} /* Build configuration list for PBXProject "OrderTracker" */ = {{'
)
W("\t\t\tisa = XCConfigurationList;")
W("\t\t\tbuildConfigurations = (")
W(f"\t\t\t\t{debug_proj} /* Debug */,")
W(f"\t\t\t\t{release_proj} /* Release */,")
W("\t\t\t);")
W("\t\t\tdefaultConfigurationIsVisible = 0;")
W("\t\t\tdefaultConfigurationName = Release;")
W("\t\t};")
W(
    f'\t\t{target_config_list} /* Build configuration list for PBXNativeTarget "OrderTracker" */ = {{'
)
W("\t\t\tisa = XCConfigurationList;")
W("\t\t\tbuildConfigurations = (")
W(f"\t\t\t\t{debug_tgt} /* Debug */,")
W(f"\t\t\t\t{release_tgt} /* Release */,")
W("\t\t\t);")
W("\t\t\tdefaultConfigurationIsVisible = 0;")
W("\t\t\tdefaultConfigurationName = Release;")
W("\t\t};")
W("/* End XCConfigurationList section */")
W("\t};")
W(f"\trootObject = {project_id} /* Project object */;")
W("}")

out = os.path.join(root, "OrderTracker.xcodeproj", "project.pbxproj")
os.makedirs(os.path.dirname(out), exist_ok=True)
with open(out, "w", encoding="utf-8") as fh:
    fh.write("\n".join(lines) + "\n")
print("wrote", out, "swift_files", len(build_files))
