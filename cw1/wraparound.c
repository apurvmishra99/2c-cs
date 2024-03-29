/***********************************************************************
* File       : <wraparound.c>
*
* Author     : <M.R. Siavash Katebzadeh>
*
* Description:
*
* Date       : 08/10/19
*
***********************************************************************/
// ==========================================================================
// 2D String Finder
// ==========================================================================
// Finds the matching words from dictionary in the 2D grid, including wrap-around

// Inf2C-CS Coursework 1. Task 6
// PROVIDED file, to be used as a skeleton.

// Instructor: Boris Grot
// TA: Siavash Katebzadeh
// 08 Oct 2019

#include <stdio.h>

// maximum size of each dimension
#define MAX_DIM_SIZE 32
// maximum number of words in dictionary file
#define MAX_DICTIONARY_WORDS 1000
// maximum size of each word in the dictionary
#define MAX_WORD_SIZE 10

int read_char() { return getchar(); }

int read_int()
{
    int i;
    scanf("%i", &i);
    return i;
}

void read_string(char *s, int size) { fgets(s, size, stdin); }

void print_char(int c) { putchar(c); }

void print_int(int i) { printf("%i", i); }

void print_string(char *s) { printf("%s", s); }

void output(char *string) { print_string(string); }

// dictionary file name
const char dictionary_file_name[] = "dictionary.txt";
// grid file name
const char grid_file_name[] = "2dgrid.txt";
// content of grid file
char grid[(MAX_DIM_SIZE + 1 /* for \n */) * MAX_DIM_SIZE + 1 /* for \0 */];
// content of dictionary file
char dictionary[MAX_DICTIONARY_WORDS * (MAX_WORD_SIZE + 1 /* for \n */) + 1 /* for \0 */];

///////////////////////////////////////////////////////////////////////////////
/////////////// Do not modify anything above
///////////////Put your global variables/functions here///////////////////////
int dictionary_idx[MAX_DICTIONARY_WORDS];
// number of words in the dictionary
int dict_num_words = 0;

void print_word(char *word)
{
    while (*word != '\n' && *word != '\0')
    {
        print_char(*word);
        word++;
    }
}

int countrows(char *string)
{
    int count = 0;
    while (*string != '\0')
    {
        if (*string == '\n')
        {
            count++;
        }
        string++;
    }
    return count;
}

int lenRows(char *string)
{
    int len = 0;
    while (*string != '\n')
    {
        len++;
        string++;
    }
    return len;
}

int containHorWrap(char *string, char *word, int len_row)
{
    while (1)
    {
        if (*word == '\n')
        {
            return 1;
        }
        else if (*string == '\n')
        {
            string -= (len_row);
        }
        else if (*string != *word)
        {
            return 0;
        }
        else
        {
            word++;
            string += 1;
        }
    }
    return 0;
}

int containVerWrap(char *string, char *word, int len_row, int len_cols)
{
    while (1)
    {
        int pos = string - grid;
        int y = pos % (len_row + 1);
        int x = pos / (len_row + 1);

        if (*word == '\n')
        {
            return 1;
        }
        else if (x == len_cols)
        {
            string = grid + y;
        }
        else if (*string != *word)
        {
            return 0;
        }
        else
        {
            string += len_row + 1;
            word++;
        }
    }
    return 0;
}

int containDiagWrap(char *string, char *word, int len_row, int len_cols)
{
    while (1)
    {
        int pos_string = string - grid;
        int x = pos_string / (len_row + 1);
        int y = pos_string % (len_row + 1);

        if (*word == '\n')
        {
            return 1;
        }
        else if (x == len_cols || y == len_row)
        {
        	if(*string == '\n')
        	{
        		return 0;
        	}
        	string -= (len_row+2); 
        }
        else if (*string != *word)
        {
            return 0;
        }
        else
        {
            string = string + len_row + 2;
            word++;
        }
    }
    return 0;
}

// this functions finds the first match in the grid
void strfind()
{
    int idx = 0;
    int grid_idx = 0;
    int rowCount = 0;
    char *word;
    int len_cols = countrows(grid);
    int len_row = lenRows(grid);
    int words_found = 0;

    while (grid[grid_idx] != '\0')
    {
        if (grid[grid_idx] == '\n')
        {
            ++rowCount;
        }
        for (idx = 0; idx < dict_num_words; idx++)
        {
            word = dictionary + dictionary_idx[idx];
            if (containHorWrap(grid + grid_idx, word, len_row))
            {
                print_int(rowCount);
                print_char(',');
                print_int(grid_idx % (len_row + 1));
                print_char(' ');
                print_char(72);
                print_char(' ');
                print_word(word);
                print_char('\n');
                words_found += 1;
            }
            if (containVerWrap(grid + grid_idx, word, len_row, len_cols))
            {
                print_int(rowCount);
                print_char(',');
                print_int(grid_idx % (len_row + 1));
                print_char(' ');
                print_char(86);
                print_char(' ');
                print_word(word);
                print_char('\n');
                words_found += 1;
            }
            if (containDiagWrap(grid + grid_idx, word, len_row, len_cols))
            {
                print_int(rowCount);
                print_char(',');
                print_int(grid_idx % (len_row + 1));
                print_char(' ');
                print_char(68);
                print_char(' ');
                print_word(word);
                print_char('\n');
                words_found += 1;
            }
        }
        grid_idx++;
    }
    if (words_found == 0)
    {
        print_string("-1\n");
    }
}

//---------------------------------------------------------------------------
// MAIN function
//---------------------------------------------------------------------------

int main(void)
{

    int dict_idx = 0;
    int start_idx = 0;

    /////////////Reading dictionary and grid files//////////////
    ///////////////Please DO NOT touch this part/////////////////
    int c_input;
    int idx = 0;

    // open grid file
    FILE *grid_file = fopen(grid_file_name, "r");
    // open dictionary file
    FILE *dictionary_file = fopen(dictionary_file_name, "r");

    // if opening the grid file failed
    if (grid_file == NULL)
    {
        print_string("Error in opening grid file.\n");
        return -1;
    }

    // if opening the dictionary file failed
    if (dictionary_file == NULL)
    {
        print_string("Error in opening dictionary file.\n");
        return -1;
    }
    // reading the grid file
    do
    {
        c_input = fgetc(grid_file);
        // indicates the the of file
        if (feof(grid_file))
        {
            grid[idx] = '\0';
            break;
        }
        grid[idx] = c_input;
        idx += 1;

    } while (1);

    // closing the grid file
    fclose(grid_file);
    idx = 0;

    // reading the dictionary file
    do
    {
        c_input = fgetc(dictionary_file);
        // indicates the end of file
        if (feof(dictionary_file))
        {
            dictionary[idx] = '\0';
            break;
        }
        dictionary[idx] = c_input;
        idx += 1;
    } while (1);

    // closing the dictionary file
    fclose(dictionary_file);
    //////////////////////////End of reading////////////////////////
    ///////////////You can add your code here!//////////////////////
    idx = 0;
    do
    {
        c_input = dictionary[idx];
        if (c_input == '\0')
        {
            break;
        }
        if (c_input == '\n')
        {
            dictionary_idx[dict_idx++] = start_idx;
            start_idx = idx + 1;
        }
        idx += 1;
    } while (1);

    dict_num_words = dict_idx;

    strfind();

    return 0;
}
