#include <stdio.h>
#include "files.h"

void func3() {
  printf ("calling func2 from func3... ");
  func2();
  printf ("func3\n");
}