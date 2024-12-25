#include <locale.h>
#include <stdio.h>

int main() {
    setlocale(LC_ALL, "en_US.UTF-8");
    printf("locale: %s\n", setlocale(LC_ALL, NULL));
    return 0;
}
