#! /bin/sh

set -e

SF_BUILD_PREFIX="xcrun xcodebuild -workspace ${PROJECT_NAME}.xcworkspace -configuration ${CONFIGURATION}"

echo "清理编译"
${SF_BUILD_PREFIX} -scheme ${PROJECT_NAME} -sdk iphoneos SYMROOT=${SYMROOT} clean
${SF_BUILD_PREFIX} -scheme ${PROJECT_NAME} -sdk iphonesimulator SYMROOT=${SYMROOT} clean

echo "构建 Pod 依赖"
${SF_BUILD_PREFIX} -scheme Pods-${PROJECT_NAME} -sdk iphoneos SYMROOT=${SYMROOT} build
${SF_BUILD_PREFIX} -scheme Pods-${PROJECT_NAME} -sdk iphonesimulator SYMROOT=${SYMROOT} build

echo "构建 Framework"
${SF_BUILD_PREFIX} -scheme ${PROJECT_NAME} -sdk iphoneos SYMROOT=${SYMROOT} build
${SF_BUILD_PREFIX} -scheme ${PROJECT_NAME} -sdk iphonesimulator SYMROOT=${SYMROOT} build

echo "合并"

CURRENTCONFIG_DEVICE_DIR="${SYMROOT}/${CONFIGURATION}-iphoneos"
CURRENTCONFIG_SIMULATOR_DIR="${SYMROOT}/${CONFIGURATION}-iphonesimulator"
CURRENTCONFIG_UNIVERSAL_DIR="${SYMROOT}/${CONFIGURATION}-universal"

SF_TARGET_NAME=${PROJECT_NAME}
SF_WRAPPER_NAME="${SF_TARGET_NAME}.framework"
SF_EXECUTABLE_PATH="${SF_WRAPPER_NAME}/${SF_TARGET_NAME}"

# 重建 universal 目录
rm -rf "${CURRENTCONFIG_UNIVERSAL_DIR}"
mkdir "${CURRENTCONFIG_UNIVERSAL_DIR}"

# 拷贝 framework 包
cp -R "${CURRENTCONFIG_DEVICE_DIR}/${SF_WRAPPER_NAME}" "${CURRENTCONFIG_UNIVERSAL_DIR}"

# 重建 universal 二进制文件
rm -f "${CURRENTCONFIG_UNIVERSAL_DIR}/${SF_EXECUTABLE_PATH}"
lipo -create -output "${CURRENTCONFIG_UNIVERSAL_DIR}/${SF_EXECUTABLE_PATH}"\
    "${CURRENTCONFIG_DEVICE_DIR}/${SF_EXECUTABLE_PATH}"\
    "${CURRENTCONFIG_SIMULATOR_DIR}/${SF_EXECUTABLE_PATH}"

# 拷贝输出到 Framework 目录
mkdir -p "${MBBuildOutput}"
rm -rf "${MBBuildOutput}/${SF_WRAPPER_NAME}"
cp -R "${CURRENTCONFIG_UNIVERSAL_DIR}/${SF_WRAPPER_NAME}" "${MBBuildOutput}"
#open "${MBBuildOutput}"
