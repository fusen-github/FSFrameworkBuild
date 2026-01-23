#!/bin/bash
set -e # 任意命令执行失败则立即退出脚本

# ****注意****
# FRAMEWORK_SEARCH_PATHS 需要的是绝对路径(全路径)，不是相对路径

# ================== 配置项（根据实际工程调整） ==================
# 工程相关
WORKSPACE_NAME="FSWorkspace.xcworkspace"
SECOND_SCHEME="Second"       # Second 框架的 Scheme 名
FIRST_SCHEME="First"         # First 框架的 Scheme 名
SECOND_PRODUCT_NAME="Second" # Second 产物名称
FIRST_PRODUCT_NAME="First"   # First 产物名称

# 输出路径
OUTPUT_DIR="build_first_lib"
SIMULATOR_ARCHIVE_PATH="$OUTPUT_DIR/ios_simulator.xcarchive"
DEVICE_ARCHIVE_PATH="$OUTPUT_DIR/ios_device.xcarchive"
SECOND_SIMULATOR_ARCHIVE="$OUTPUT_DIR/second_simulator.xcarchive"
SECOND_DEVICE_ARCHIVE="$OUTPUT_DIR/second_device.xcarchive"
XCFRAMEWORK_OUTPUT="$OUTPUT_DIR/${FIRST_PRODUCT_NAME}.xcframework"

# ================== 初始化 ==================
echo "🚀 开始构建 First 静态库（依赖 Second）..."
# 清理旧产物
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# ================== 第一步：编译 Second 静态库（Simulator 架构） ==================
echo "🔨 编译 Second - iOS Simulator 架构..."
xcodebuild archive \
  -workspace "$WORKSPACE_NAME" \
  -scheme "$SECOND_SCHEME" \
  -destination "generic/platform=iOS Simulator" \
  -archivePath "$SECOND_SIMULATOR_ARCHIVE" \
  -configuration Release \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  DEBUG_INFORMATION_FORMAT=dwarf-with-dsym \
  STRIP_INSTALLED_PRODUCT=NO \
  ONLY_ACTIVE_ARCH=NO \
  BUILD_STATIC_LIBRARY=YES

# 获取 Second Simulator 产物路径
SECOND_SIMULATOR_FRAMEWORK_PATH="$SECOND_SIMULATOR_ARCHIVE/Products/Library/Frameworks/$SECOND_PRODUCT_NAME.framework"
echo "fs----$SECOND_SIMULATOR_FRAMEWORK_PATH"

# ================== 第二步：编译 First 静态库（Simulator 架构） ==================
echo "🔨 编译 First - iOS Simulator 架构..."
xcodebuild archive \
  -workspace "$WORKSPACE_NAME" \
  -scheme "$FIRST_SCHEME" \
  -destination "generic/platform=iOS Simulator" \
  -archivePath "$SIMULATOR_ARCHIVE_PATH" \
  -configuration Release \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  DEBUG_INFORMATION_FORMAT=dwarf-with-dsym \
  STRIP_INSTALLED_PRODUCT=NO \
  ONLY_ACTIVE_ARCH=NO \
  BUILD_STATIC_LIBRARY=YES \
  FRAMEWORK_SEARCH_PATHS="/Users/michaelli/Documents/study/ios/07-workspace/Libs"
#  FRAMEWORK_SEARCH_PATHS="$SECOND_SIMULATOR_FRAMEWORK_PATH"
#  HEADER_SEARCH_PATHS="$SECOND_SIMULATOR_FRAMEWORK_PATH/Headers"


echo "fs-end-------"
exit 0

# ================== 第三步：编译 Second 静态库（Device 架构） ==================
echo "🔨 编译 Second - iOS Device 架构..."
xcodebuild archive \
  -workspace "$WORKSPACE_NAME" \
  -scheme "$SECOND_SCHEME" \
  -destination "generic/platform=iOS" \
  -archivePath "$SECOND_DEVICE_ARCHIVE" \
  -configuration Release \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  DEBUG_INFORMATION_FORMAT=dwarf-with-dsym \
  STRIP_INSTALLED_PRODUCT=NO \
  ONLY_ACTIVE_ARCH=NO \
  BUILD_STATIC_LIBRARY=YES

# 获取 Second Device 产物路径
SECOND_DEVICE_FRAMEWORK_PATH="$SECOND_DEVICE_ARCHIVE/Products/Library/Frameworks/$SECOND_PRODUCT_NAME.framework"

# ================== 第四步：编译 First 静态库（Device 架构） ==================
echo "🔨 编译 First - iOS Device 架构..."
xcodebuild archive \
  -workspace "$WORKSPACE_NAME" \
  -scheme "$FIRST_SCHEME" \
  -destination "generic/platform=iOS" \
  -archivePath "$DEVICE_ARCHIVE_PATH" \
  -configuration Release \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  DEBUG_INFORMATION_FORMAT=dwarf-with-dsym \
  STRIP_INSTALLED_PRODUCT=NO \
  ONLY_ACTIVE_ARCH=NO \
  BUILD_STATIC_LIBRARY=YES \
  # 关键：指定 Device 端 Second 的路径
  FRAMEWORK_SEARCH_PATHS="$SECOND_DEVICE_FRAMEWORK_PATH" \
  HEADER_SEARCH_PATHS="$SECOND_DEVICE_FRAMEWORK_PATH/Headers"

# ================== 第五步：合并为 XCFramework（支持模拟器+真机） ==================
echo "🔗 合并 Simulator/Device 架构为 XCFramework..."
xcodebuild -create-xcframework \
  -framework "$SIMULATOR_ARCHIVE_PATH/Products/Library/Frameworks/$FIRST_PRODUCT_NAME.framework" \
  -framework "$DEVICE_ARCHIVE_PATH/Products/Library/Frameworks/$FIRST_PRODUCT_NAME.framework" \
  -output "$XCFRAMEWORK_OUTPUT"

# ================== 完成 ==================
echo -e "\n✅ 构建完成！"
echo "📦 First 静态库 XCFramework 路径：$XCFRAMEWORK_OUTPUT"
echo "📝 产物包含：iOS Simulator (arm64/x86_64) + iOS Device (arm64) 架构"
