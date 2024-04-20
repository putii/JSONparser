function(doublyLinkedList_check_libfuzzer_support is_lib_fuzzer_supported) # refactored from name_var(wtf?) -> is_lib_fuzzer_supported
  set(LibFuzzerTestSource
      "
#include <cstdint>

extern \"C\" int LLVMFuzzerTestOneInput(const std::uint8_t *data, std::size_t size) {
  return 0;
}
    ")

  include(CheckCXXSourceCompiles)

  set(CMAKE_REQUIRED_FLAGS "-fsanitize=fuzzer")
  set(CMAKE_REQUIRED_LINK_OPTIONS "-fsanitize=fuzzer")
  check_cxx_source_compiles("${LibFuzzerTestSource}" ${is_lib_fuzzer_supported}) #[[ The result will be stored in the internal 
  cache variable specified by <is_lib_fuzzer_supported>, with a boolean true value for success and boolean false for failure]]

endfunction()
