#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

// Implement the mac to check against the hardware implementation
uint32_t c_mac (uint32_t m, uint8_t w, uint8_t x) {
   uint32_t mac = m;
   uint32_t w_int, x_int;
   w_int = (unsigned int) w;
   x_int = (unsigned int) x;
   mac += w_int * x_int;
   return (mac);
}

#if 0
void main (void) {
   uint8_t w[8];
   uint8_t x[8];
   int i=0;
   uint32_t mac = 0;

   for (i=0; i<8; i++) {
      w[i] = i+16;
      x[i] = i*2;
   }
   mac = c_dot_product (w, x);
   printf ("w = [");
   for (i=0; i<8; i++) printf ("%d ", w[i]);
   printf ("]\n");
   printf ("x = [");
   for (i=0; i<8; i++) printf ("%d ", x[i]);
   printf ("]\n");
   printf ("mac = %d\n", mac);
}
#endif
