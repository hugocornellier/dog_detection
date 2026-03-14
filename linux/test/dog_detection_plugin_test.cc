#include <flutter_linux/flutter_linux.h>
#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include "include/dog_detection/dog_detection_plugin.h"
#include "dog_detection_plugin_private.h"

namespace dog_detection {
namespace test {

TEST(DogDetectionPlugin, GetPlatformVersion) {
  g_autoptr(FlMethodResponse) response = get_platform_version();
  ASSERT_NE(response, nullptr);
  ASSERT_TRUE(FL_IS_METHOD_SUCCESS_RESPONSE(response));
  FlValue* result = fl_method_success_response_get_result(
      FL_METHOD_SUCCESS_RESPONSE(response));
  ASSERT_EQ(fl_value_get_type(result), FL_VALUE_TYPE_STRING);
  EXPECT_THAT(fl_value_get_string(result), testing::StartsWith("Linux "));
}

}  // namespace test
}  // namespace dog_detection
