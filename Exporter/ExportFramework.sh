#!/bin/sh
build_path="Builds/$(date '+%d-%m-%Y-%H-%M')"
target="Nomosi"
configuration="Release"

# clean up the build folder if already exists
rm -rf build_path

devices_base_path="${build_path}/${configuration}-iphoneos"
simulator_base_path="${build_path}/${configuration}-iphonesimulator"
universal_base_path="${build_path}/${configuration}-universal"
devices_framework_path="${devices_base_path}/${target}.framework"
simulator_framework_path="${simulator_base_path}/${target}.framework"
universal_framework_path="${universal_base_path}/${target}.framework"
mkdir -p "${build_path}"
mkdir -p "${universal_framework_path}"

#xcodebuild ENABLE_BITCODE=YES BITCODE_GENERATION_MODE=bitcode BUILD_DIR=${build_path} SWIFT_ENABLE_BATCH_MODE=NO > /dev/null -target ${target} -configuration ${configuration} -sdk iphoneos clean build ONLY_ACTIVE_ARCH=NO
#
#exit 0

echo "1/5 Building the target \"${target}\" with the configuration \"${configuration}\" for the simulator"
xcodebuild ENABLE_BITCODE=YES BITCODE_GENERATION_MODE=bitcode BUILD_DIR=${build_path} BUILD_LIBRARY_FOR_DISTRIBUTION=YES SWIFT_ENABLE_BATCH_MODE=NO > /dev/null -target ${target} -configuration ${configuration} -sdk iphonesimulator clean build

echo "2/5 Building the target \"${target}\" with the configuration \"${configuration}\" for the devices"
xcodebuild ENABLE_BITCODE=YES BITCODE_GENERATION_MODE=bitcode BUILD_DIR=${build_path} BUILD_LIBRARY_FOR_DISTRIBUTION=YES SWIFT_ENABLE_BATCH_MODE=NO > /dev/null -target ${target} -configuration ${configuration} -sdk iphoneos clean build ONLY_ACTIVE_ARCH=NO

cp -R "${build_path}/${configuration}-iphoneos/" "${universal_base_path}/"

simulator_module_dir="${simulator_framework_path}/Modules/${target}.swiftmodule/."
if [ -d "${simulator_module_dir}" ]; then
cp -R "${simulator_module_dir}" "${universal_framework_path}/Modules/${target}.swiftmodule"
fi

echo "3/5 Creating FAT framework in ${universal_base_path}"

lipo -create -output "${universal_framework_path}/${target}" "${simulator_framework_path}/${target}" "${devices_framework_path}/${target}"

echo "4/5 Injective dependecies in ${universal_base_path}"

cp -R "${universal_framework_path}" "${build_path}"
rm -rf "build"
rm -rf "${devices_base_path}"
rm -rf "${simulator_base_path}"
rm -rf "${universal_base_path}"

lipo -info "${build_path}/${target}.framework/${target}"

open "${build_path}"
