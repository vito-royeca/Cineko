#!/bin/sh
set -e

echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

SWIFT_STDLIB_PATH="${DT_TOOLCHAIN_DIR}/usr/lib/swift/${PLATFORM_NAME}"

install_framework()
{
  if [ -r "${BUILT_PRODUCTS_DIR}/$1" ]; then
    local source="${BUILT_PRODUCTS_DIR}/$1"
  elif [ -r "${BUILT_PRODUCTS_DIR}/$(basename "$1")" ]; then
    local source="${BUILT_PRODUCTS_DIR}/$(basename "$1")"
  elif [ -r "$1" ]; then
    local source="$1"
  fi

  local destination="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

  if [ -L "${source}" ]; then
      echo "Symlinked..."
      source="$(readlink "${source}")"
  fi

  # use filter instead of exclude so missing patterns dont' throw errors
  echo "rsync -av --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" --filter \"- Headers\" --filter \"- PrivateHeaders\" --filter \"- Modules\" \"${source}\" \"${destination}\""
  rsync -av --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${source}" "${destination}"

  local basename
  basename="$(basename -s .framework "$1")"
  binary="${destination}/${basename}.framework/${basename}"
  if ! [ -r "$binary" ]; then
    binary="${destination}/${basename}"
  fi

  # Strip invalid architectures so "fat" simulator / device frameworks work on device
  if [[ "$(file "$binary")" == *"dynamically linked shared library"* ]]; then
    strip_invalid_archs "$binary"
  fi

  # Resign the code if required by the build settings to avoid unstable apps
  code_sign_if_enabled "${destination}/$(basename "$1")"

  # Embed linked Swift runtime libraries. No longer necessary as of Xcode 7.
  if [ "${XCODE_VERSION_MAJOR}" -lt 7 ]; then
    local swift_runtime_libs
    swift_runtime_libs=$(xcrun otool -LX "$binary" | grep --color=never @rpath/libswift | sed -E s/@rpath\\/\(.+dylib\).*/\\1/g | uniq -u  && exit ${PIPESTATUS[0]})
    for lib in $swift_runtime_libs; do
      echo "rsync -auv \"${SWIFT_STDLIB_PATH}/${lib}\" \"${destination}\""
      rsync -auv "${SWIFT_STDLIB_PATH}/${lib}" "${destination}"
      code_sign_if_enabled "${destination}/${lib}"
    done
  fi
}

# Signs a framework with the provided identity
code_sign_if_enabled() {
  if [ -n "${EXPANDED_CODE_SIGN_IDENTITY}" -a "${CODE_SIGNING_REQUIRED}" != "NO" -a "${CODE_SIGNING_ALLOWED}" != "NO" ]; then
    # Use the current code_sign_identitiy
    echo "Code Signing $1 with Identity ${EXPANDED_CODE_SIGN_IDENTITY_NAME}"
    echo "/usr/bin/codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} ${OTHER_CODE_SIGN_FLAGS} --preserve-metadata=identifier,entitlements \"$1\""
    /usr/bin/codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} ${OTHER_CODE_SIGN_FLAGS} --preserve-metadata=identifier,entitlements "$1"
  fi
}

# Strip invalid architectures
strip_invalid_archs() {
  binary="$1"
  # Get architectures for current file
  archs="$(lipo -info "$binary" | rev | cut -d ':' -f1 | rev)"
  stripped=""
  for arch in $archs; do
    if ! [[ "${VALID_ARCHS}" == *"$arch"* ]]; then
      # Strip non-valid architectures in-place
      lipo -remove "$arch" -output "$binary" "$binary" || exit 1
      stripped="$stripped $arch"
    fi
  done
  if [[ "$stripped" ]]; then
    echo "Stripped $binary of architectures:$stripped"
  fi
}


if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_framework "$BUILT_PRODUCTS_DIR/Colours-iOS9.0/Colours.framework"
  install_framework "$BUILT_PRODUCTS_DIR/DACircularProgress-iOS9.0/DACircularProgress.framework"
  install_framework "$BUILT_PRODUCTS_DIR/Eureka-iOS9.0/Eureka.framework"
  install_framework "$BUILT_PRODUCTS_DIR/IDMPhotoBrowser-iOS9.0/IDMPhotoBrowser.framework"
  install_framework "$BUILT_PRODUCTS_DIR/JJJUtils-iOS9.0/JJJUtils.framework"
  install_framework "$BUILT_PRODUCTS_DIR/KeychainAccess-iOS9.0/KeychainAccess.framework"
  install_framework "$BUILT_PRODUCTS_DIR/MBProgressHUD-iOS9.0/MBProgressHUD.framework"
  install_framework "$BUILT_PRODUCTS_DIR/MMDrawerController-iOS9.0/MMDrawerController.framework"
  install_framework "$BUILT_PRODUCTS_DIR/MMDrawerController+Storyboard-iOS9.0/MMDrawerController_Storyboard.framework"
  install_framework "$BUILT_PRODUCTS_DIR/SDWebImage-iOS9.0/SDWebImage.framework"
  install_framework "$BUILT_PRODUCTS_DIR/SimulatorStatusMagic-iOS9.0/SimulatorStatusMagic.framework"
  install_framework "$BUILT_PRODUCTS_DIR/pop-iOS9.0/pop.framework"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_framework "$BUILT_PRODUCTS_DIR/Colours-iOS9.0/Colours.framework"
  install_framework "$BUILT_PRODUCTS_DIR/DACircularProgress-iOS9.0/DACircularProgress.framework"
  install_framework "$BUILT_PRODUCTS_DIR/Eureka-iOS9.0/Eureka.framework"
  install_framework "$BUILT_PRODUCTS_DIR/IDMPhotoBrowser-iOS9.0/IDMPhotoBrowser.framework"
  install_framework "$BUILT_PRODUCTS_DIR/JJJUtils-iOS9.0/JJJUtils.framework"
  install_framework "$BUILT_PRODUCTS_DIR/KeychainAccess-iOS9.0/KeychainAccess.framework"
  install_framework "$BUILT_PRODUCTS_DIR/MBProgressHUD-iOS9.0/MBProgressHUD.framework"
  install_framework "$BUILT_PRODUCTS_DIR/MMDrawerController-iOS9.0/MMDrawerController.framework"
  install_framework "$BUILT_PRODUCTS_DIR/MMDrawerController+Storyboard-iOS9.0/MMDrawerController_Storyboard.framework"
  install_framework "$BUILT_PRODUCTS_DIR/SDWebImage-iOS9.0/SDWebImage.framework"
  install_framework "$BUILT_PRODUCTS_DIR/pop-iOS9.0/pop.framework"
fi
