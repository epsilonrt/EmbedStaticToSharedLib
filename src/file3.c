#include <stdio.h>
#include "libfiles.h"

void func3() {
  printf ("calling func2 from func3\n");
  func2();
  printf ("func3\n");
}