set -e

if [ "$CALLED_FROM_MASTER" ]
then
# This is the other build, called from the original instance
exit 0
fi

# Clean up prior to build
echo "Cleaning all builds."
find "${BUILD_ROOT}" -name "${EXECUTABLE_NAME}" -delete -print
