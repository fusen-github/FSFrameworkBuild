#!/bin/bash

# ================== 配置 ==================
# Framework 名称
SCHEME_NAME="First" # 替换为你的 Framework 的 Target 名称
OUTPUT_DIR="build"        # 输出目录
#PRODUCT_NAME="FSLib"
PRODUCT_NAME="First"
XCFRAMEWORK_NAME="$PRODUCT_NAME.xcframework"
# 新增：Second 框架相关配置
SECOND_SCHEME="Second"
SECOND_PRODUCT_NAME="Second"

# ================== 开始 ==================
echo "🚀 开始构建 $SCHEME_NAME 的 .xcframework..."

# 清理输出目录
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# ================== 编译 iOS Simulator Framework ==================
echo "🔨 构建 iOS Simulator 架构..."

# 1. 编译 Second 框架（Simulator）
xcodebuild archive \
  -workspace "FSWorkspace.xcworkspace" \
  -scheme "$SECOND_SCHEME" \
  -destination "generic/platform=iOS Simulator" \
  -archivePath "$OUTPUT_DIR/second_simulator.xcarchive" \
  -configuration Release \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  DEBUG_INFORMATION_FORMAT=dwarf-with-dsym \
  STRIP_INSTALLED_PRODUCT=NO \
  || exit 1

# 定义 Second 框架路径（Simulator）
SECOND_SIMULATOR_PATH="$OUTPUT_DIR/second_simulator.xcarchive/Products/Library/Frameworks/$SECOND_PRODUCT_NAME.framework"

# 2. 编译 First 框架（Simulator）- 补充 HEADER_SEARCH_PATHS 暴露头文件
xcodebuild archive \
  -workspace "FSWorkspace.xcworkspace" \
  -scheme "$SCHEME_NAME" \
  -destination "generic/platform=iOS Simulator" \
  -archivePath "$OUTPUT_DIR/ios_simulator.xcarchive" \
  -configuration Release \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  DEBUG_INFORMATION_FORMAT=dwarf-with-dsym \
  STRIP_INSTALLED_PRODUCT=NO \
  # 关键：同时指定框架搜索路径 + 头文件搜索路径（指向 Second 框架的头文件目录）
  FRAMEWORK_SEARCH_PATHS="$SECOND_SIMULATOR_PATH" \
  HEADER_SEARCH_PATHS="$SECOND_SIMULATOR_PATH/Headers" \
  || exit 1

# ================== 编译 iOS Device Framework ==================
echo "🔨 构建 iOS Device 架构..."

# 1. 编译 Second 框架（Device）
xcodebuild archive \
  -workspace "FSWorkspace.xcworkspace" \ # 补充缺失的 workspace 参数
  -scheme "$SECOND_SCHEME" \
  -destination "generic/platform=iOS" \
  -archivePath "$OUTPUT_DIR/second_device.xcarchive" \
  -configuration Release \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  DEBUG_INFORMATION_FORMAT=dwarf-with-dsym \
  STRIP_INSTALLED_PRODUCT=NO \
  || exit 1

# 定义 Second 框架路径（Device）
SECOND_DEVICE_PATH="$OUTPUT_DIR/second_device.xcarchive/Products/Library/Frameworks/$SECOND_PRODUCT_NAME.framework"

# 2. 编译 First 框架（Device）- 补充 Second 框架的搜索路径
xcodebuild archive \
  -workspace "FSWorkspace.xcworkspace" \ # 补充缺失的 workspace 参数
  -scheme "$SCHEME_NAME" \
  -destination "generic/platform=iOS" \
  -archivePath "$OUTPUT_DIR/ios_device.xcarchive" \
  -configuration Release \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  DEBUG_INFORMATION_FORMAT=dwarf-with-dsym \
  STRIP_INSTALLED_PRODUCT=NO \
  # 关键：添加 Device 端的框架/头文件搜索路径
  FRAMEWORK_SEARCH_PATHS="$SECOND_DEVICE_PATH" \
  HEADER_SEARCH_PATHS="$SECOND_DEVICE_PATH/Headers" \
  || exit 1

# ================== 合并为 XCFramework ==================
echo "🔗 合并为 .xcframework..."
xcodebuild -create-xcframework \
  -framework "$OUTPUT_DIR/ios_simulator.xcarchive/Products/Library/Frameworks/$PRODUCT_NAME.framework" \
  -framework "$OUTPUT_DIR/ios_device.xcarchive/Products/Library/Frameworks/$PRODUCT_NAME.framework" \
  -output "$OUTPUT_DIR/$XCFRAMEWORK_NAME" || exit 1

# ================== 完成 ==================
echo "✅ $XCFRAMEWORK_NAME 已生成！"
echo "输出路径：$OUTPUT_DIR/$XCFRAMEWORK_NAME"