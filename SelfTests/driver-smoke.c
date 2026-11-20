// Exercise the built HAL plug-in directly; no installed driver, audio daemon or microphone required.
#include <CoreAudio/AudioServerPlugIn.h>
#include <CoreFoundation/CoreFoundation.h>
#include <dlfcn.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define CHECK(x) do { if (!(x)) { fprintf(stderr, "FAIL: %s (line %d)\n", #x, __LINE__); exit(1); } } while (0)
static OSStatus freshStorage(AudioServerPlugInHostRef host, CFStringRef key, CFPropertyListRef *value) {
    *value = NULL; // A fresh host has no persisted plug-in settings.
    return noErr;
}
static AudioServerPlugInDriverRef driver;
static void property(AudioObjectID object, AudioObjectPropertySelector selector, void *value, UInt32 size) {
    AudioObjectPropertyAddress address = {selector, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain};
    UInt32 actual = 0;
    CHECK((*driver)->GetPropertyData(driver, object, 0, &address, 0, NULL, size, &actual, value) == noErr);
    CHECK(actual == size);
}
static void stringProperty(AudioObjectID object, AudioObjectPropertySelector selector, const char *expected) {
    CFStringRef string = NULL;
    property(object, selector, &string, sizeof(string));
    char value[256]; CHECK(CFStringGetCString(string, value, sizeof(value), kCFStringEncodingUTF8));
    CHECK(strcmp(value, expected) == 0);
    CFRelease(string);
}
int main(int argc, char **argv) {
    CHECK(argc == 2);
    void *handle = dlopen(argv[1], RTLD_NOW | RTLD_LOCAL);
    if (!handle) { fprintf(stderr, "FAIL: dlopen: %s\n", dlerror()); return 1; }
    void *(*create)(CFAllocatorRef, CFUUIDRef) = dlsym(handle, "BlackHole_Create");
    CHECK(create != NULL);
    driver = create(kCFAllocatorDefault, kAudioServerPlugInTypeUUID); CHECK(driver != NULL);
    AudioServerPlugInHostInterface host = {.CopyFromStorage = freshStorage};
    CHECK((*driver)->Initialize(driver, &host) == noErr);
    stringProperty(1, kAudioPlugInPropertyResourceBundle, "");
    stringProperty(2, kAudioObjectPropertyName, "vRemoteDr Box");
    stringProperty(3, kAudioObjectPropertyName, "vRemoteDr 2ch");
    stringProperty(3, kAudioDevicePropertyDeviceUID, "vRemoteDr2ch_UID");
    UInt32 transport = 0; property(3, kAudioDevicePropertyTransportType, &transport, sizeof(transport));
    CHECK(transport == kAudioDeviceTransportTypeUSB);
    Float64 rate = 0; property(3, kAudioDevicePropertyNominalSampleRate, &rate, sizeof(rate)); CHECK(rate == 48000);
    AudioStreamBasicDescription format = {0}; property(4, kAudioStreamPropertyVirtualFormat, &format, sizeof(format));
    CHECK(format.mChannelsPerFrame == 2 && format.mBitsPerChannel == 32 && format.mSampleRate == 48000);
    CHECK((*driver)->StartIO(driver, 999, 1) != noErr);
    CHECK((*driver)->StartIO(driver, 3, 1) == noErr);
    const int frames = 512;
    Float32 output[frames * 2], input[frames * 2];
    for (int i = 0; i < frames * 2; ++i) output[i] = (Float32)((i % 97) - 48) / 128.0f;
    // Cover normal operation, a ring-buffer boundary, and repeated wrap-around (>40 seconds at 48kHz).
    for (int block = 0; block < 4000; ++block) {
        AudioServerPlugInIOCycleInfo cycle = {0};
        cycle.mInputTime.mSampleTime = cycle.mOutputTime.mSampleTime = 65408 + block * frames;
        CHECK((*driver)->DoIOOperation(driver, 3, 7, 1, kAudioServerPlugInIOOperationWriteMix, frames, &cycle, output, NULL) == noErr);
        memset(input, 0, sizeof(input));
        CHECK((*driver)->DoIOOperation(driver, 3, 4, 1, kAudioServerPlugInIOOperationReadInput, frames, &cycle, input, NULL) == noErr);
        CHECK(memcmp(input, output, sizeof(input)) == 0);
    }
    CHECK((*driver)->StopIO(driver, 3, 1) == noErr);
    puts("PASS: source-built HAL identity, format, invalid device rejection and 42 seconds of loopback samples including ring wrap");
    return 0;
}
