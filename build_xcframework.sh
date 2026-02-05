#!/bin/bash

# ================== 配置 ==================
ROOT_PATH=$(pwd)
# Framework 名称
SCHEME_NAME="First" # 替换为你的 Framework 的 Target 名称
OUTPUT_DIR="build"        # 输出目录
#PRODUCT_NAME="FSLib"
PRODUCT_NAME="First"
XCFRAMEWORK_NAME="$PRODUCT_NAME.xcframework"

# ================== 开始 ==================
echo "🚀 开始构建 $SCHEME_NAME 的 .xcframework..."

# 清理输出目录
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

SIMULATOR_PRODUCT_DIR="$OUTPUT_DIR/simulators"
mkdir -p "$SIMULATOR_PRODUCT_DIR"
DEVICE_PRODUCT_DIR="$OUTPUT_DIR/devices"
mkdir -p "$DEVICE_PRODUCT_DIR"

# ================== 编译 iOS Simulator Framework ==================
echo "🔨 构建 iOS Simulator 架构..."
# 功能：构建模拟器架构
# 参数1: scheme name
# 参数2: prelink_absolute_path
function archive_simulator {
    
    local scheme_name="$1"
    local prelink_path="$2"
    
    #****注意！！！*****#
    # FRAMEWORK_SEARCH_PATHS、PRELINK_LIBS需要使用绝对路径
    
    xcodebuild archive \
        -workspace "FSWorkspace.xcworkspace" \
        -scheme "$scheme_name" \
        -destination "generic/platform=iOS Simulator" \
        -archivePath "$OUTPUT_DIR/${scheme_name}_simulator.xcarchive" \
        -configuration Release \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        DEBUG_INFORMATION_FORMAT=dwarf-with-dsym \
        STRIP_INSTALLED_PRODUCT=NO \
        FRAMEWORK_SEARCH_PATHS="$ROOT_PATH/$SIMULATOR_PRODUCT_DIR" \
        GENERATE_PRELINK_OBJECT_FILE=YES \
        PRELINK_LIBS="${prelink_path}" \
        GCC_PREPROCESSOR_DEFINITIONS="USE_IDFA BBB" \
        || exit 1
    
    # 拷贝framework
    FROM_PATH="$OUTPUT_DIR/${scheme_name}_simulator.xcarchive/Products/Library/Frameworks/${scheme_name}.framework"
    cp -rv $FROM_PATH $SIMULATOR_PRODUCT_DIR
}

# 构建模拟器
archive_simulator "Second"
archive_simulator "First" "$ROOT_PATH/$SIMULATOR_PRODUCT_DIR/Second.framework/Second"

# ================== 编译 iOS Device Framework ==================
echo "🔨 构建 iOS Device 架构..."
# 功能：构建模拟器架构
# 参数1: scheme name
# 参数2: prelink_absolute_path
function archive_device {
    
    local scheme_name="$1"
    local prelink_path="$2"
    
    #****注意！！！*****#
    # FRAMEWORK_SEARCH_PATHS、PRELINK_LIBS需要使用绝对路径
    
    xcodebuild archive \
        -workspace "FSWorkspace.xcworkspace" \
        -scheme "$scheme_name" \
        -destination "generic/platform=iOS" \
        -archivePath "$OUTPUT_DIR/${scheme_name}_device.xcarchive" \
        -configuration Release \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        DEBUG_INFORMATION_FORMAT=dwarf-with-dsym \
        STRIP_INSTALLED_PRODUCT=NO \
        FRAMEWORK_SEARCH_PATHS="$ROOT_PATH/$SIMULATOR_PRODUCT_DIR" \
        GENERATE_PRELINK_OBJECT_FILE=YES \
        PRELINK_LIBS="\$(inherited) ${prelink_path}" \
        GCC_PREPROCESSOR_DEFINITIONS="USE_IDFA BBB" \
        || exit 1
    
    # 拷贝framework
    FROM_PATH="$OUTPUT_DIR/${scheme_name}_device.xcarchive/Products/Library/Frameworks/${scheme_name}.framework"
    cp -rv $FROM_PATH $DEVICE_PRODUCT_DIR
}

archive_device "Second"
archive_device "First" "$ROOT_PATH/$DEVICE_PRODUCT_DIR/Second.framework/Second"

#xcodebuild archive \
#  -scheme "Second" \
#  -destination "generic/platform=iOS" \
#  -archivePath "$OUTPUT_DIR/second_device.xcarchive" \
#  -configuration Release \
#  SKIP_INSTALL=NO \
#  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
#  DEBUG_INFORMATION_FORMAT=dwarf-with-dsym\
#  STRIP_INSTALLED_PRODUCT=NO \
#  || exit 1
#
#xcodebuild archive \
#  -scheme "$SCHEME_NAME" \
#  -destination "generic/platform=iOS" \
#  -archivePath "$OUTPUT_DIR/ios_device.xcarchive" \
#  -configuration Release \
#  SKIP_INSTALL=NO \
#  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
#  DEBUG_INFORMATION_FORMAT=dwarf-with-dsym\
#  STRIP_INSTALLED_PRODUCT=NO \
#  || exit 1

# ================== 合并为 XCFramework ==================
echo "🔗 合并为 .xcframework..."
xcodebuild -create-xcframework \
  -framework "$SIMULATOR_PRODUCT_DIR/First.framework" \
  -framework "$DEVICE_PRODUCT_DIR/First.framework" \
  -output "$OUTPUT_DIR/$XCFRAMEWORK_NAME" || exit 1

# ================== 完成 ==================
echo "✅ $XCFRAMEWORK_NAME 已生成！"
echo "输出路径：$OUTPUT_DIR/$XCFRAMEWORK_NAME"
