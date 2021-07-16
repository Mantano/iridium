LOCAL_PATH := $(call my-dir)

#Prebuilt libraries
include $(CLEAR_VARS)
LOCAL_MODULE := liblcp

ARCH_PATH = $(TARGET_ARCH_ABI)

LOCAL_SRC_FILES := $(LOCAL_PATH)/lib/$(ARCH_PATH)/liblcp.so

include $(PREBUILT_SHARED_LIBRARY)

#c++_shared
include $(CLEAR_VARS)
LOCAL_MODULE := libmodc++_shared

LOCAL_SRC_FILES := $(LOCAL_PATH)/lib/$(ARCH_PATH)/libc++_shared.so

include $(PREBUILT_SHARED_LIBRARY)

#Main JNI library
include $(CLEAR_VARS)
LOCAL_MODULE := lcp_wrapper

LOCAL_CFLAGS += -DHAVE_PTHREADS
LOCAL_C_INCLUDES += $(LOCAL_PATH)/include
LOCAL_SHARED_LIBRARIES += liblcp
LOCAL_LDLIBS += -llog -landroid -ljnigraphics

LOCAL_SRC_FILES :=  $(LOCAL_PATH)/src/lcp_wrapper.cpp

include $(BUILD_SHARED_LIBRARY)
