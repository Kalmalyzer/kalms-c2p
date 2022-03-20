#define ASSERT_ARRAY_EQ(reference, data, size)                                 \
  UTEST_SURPRESS_WARNING_BEGIN do {                                            \
    for (int i = 0; i < (size); i++) {                                         \
      if ((reference)[i] != (data)[i]) {                                       \
        UTEST_PRINTF("%s:%u: Failure\n", __FILE__, __LINE__);                  \
        UTEST_PRINTF("  Array differences at offset %d\n", i);                 \
        UTEST_PRINTF("  Expected : %d\n", (reference[i]));                     \
        UTEST_PRINTF("    Actual : %d\n", (data[i]));                          \
        *utest_result = 1;                                                     \
        return;                                                                \
      }                                                                        \
    }                                                                          \
  }                                                                            \
  while (0)                                                                    \
  UTEST_SURPRESS_WARNING_END
