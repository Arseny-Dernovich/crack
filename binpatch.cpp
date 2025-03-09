#include "My_features.h"
// #include "TXLib.h"

const long EXPECTED_HASH = 0x39BA;

void Modify_Byte_At_Offset (const char *file_name , long offset , unsigned char new_value);
long Calculate_Simple_Hash (const char *file_name);


int main (int argc , const char* argv[])
{
    // txCreateWindow(800 , 1000);

    // txPlayVideo (300 , 300 , 400 , 500 , "video_2025-03-03_22-15-01.mp4" , 0 , 7);

    if (argc == 1) {

        printf ("Введите название файла для бинарного патча");
        return 0;
    }


    const char* file_name = argv[1];

      long hash = Calculate_Simple_Hash (file_name);

    if (hash != EXPECTED_HASH) {

        printf("Ошибка: Хэш-сумма файла не совпадает! Ожидалось 0x%X, получено 0x%X\n", EXPECTED_HASH, hash);
        return 1;
    }

    long offset = 0x14;
    unsigned char new_value = 0x74;

    Modify_Byte_At_Offset (file_name , offset , new_value);
    return 0;
}


long Calculate_Simple_Hash (const char *file_name)
{
    FILE *file = fopen (file_name , "rb");
    if (!file) {
        perror ("Ошибка открытия файла");
        return 0;
    }

    long hash = 0;
    int byte = 0;

    while ((byte = fgetc (file)) != EOF) {
        hash = (hash + byte) % 0xFFFFFFFF;  // Суммируем байты, не выходя за 32 бита
    }

    fclose (file);
    return hash;
}


void Modify_Byte_At_Offset (const char *file_name , long offset , unsigned char new_value)
{
    FILE *file = fopen (file_name , "r + b");
    if (!file) {

        perror("Ошибка открытия файла");
        return;
    }

    if (fseek (file , offset , SEEK_SET) != 0) {

        perror ("Ошибка при перемещении указателя в файле");
        fclose (file);
        return;
    }

    fputc (new_value , file); // Записываем новый байт
    fclose (file);
    printf ("Байт на 0x%lX заменён в файле '%s'.\n" , offset , file_name);
}

