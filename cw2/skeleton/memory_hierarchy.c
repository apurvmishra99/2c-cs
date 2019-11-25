/*************************************************************************************|
|   1. YOU ARE NOT ALLOWED TO SHARE/PUBLISH YOUR CODE (e.g., post on piazza or online)|
|   2. Fill main.c and memory_hierarchy.c files                                       |
|   3. Do not use any other .c files neither alter main.h or parser.h                 |
|   4. Do not include any other library files                                         |
|*************************************************************************************/
#include "mipssim.h"

/// @students: declare cache-related structures and variables here

#define ADDRESS_SIZE 32
#define CACHE_BLOCK_SIZE 16
int NUM_BLOCKS; // cache_size/CACHE_BLOCK_SIZE
int INDEX_BITS; // log2(NUM_BLOCKS)
int OFFSET_BITS; // log2(CACHE_BLOCK_SIZE)
int TAG_BITS; // ADDRESS_SIZE - INDEX_BITS - OFFSET_BITS


struct CACHE {
    int valid;
    uint32_t tag;
    int data[16];
} cache_var;

struct CACHE *SYS_CACHE;

void memory_state_init(struct architectural_state* arch_state_ptr) {
    arch_state_ptr->memory = (uint32_t *) malloc(sizeof(uint32_t) * MEMORY_WORD_NUM);
    memset(arch_state_ptr->memory, 0, sizeof(uint32_t) * MEMORY_WORD_NUM);
    if(cache_size == 0){
        // CACHE DISABLED
        memory_stats_init(arch_state_ptr, 0); // WARNING: we initialize for no cache 0
    }else {
        // CACHE ENABLED
        NUM_BLOCKS = cache_size/CACHE_BLOCK_SIZE; // cache_size/CACHE_BLOCK_SIZE
        INDEX_BITS = ceil(log2(NUM_BLOCKS)); // log2(NUM_BLOCKS)
        OFFSET_BITS = log2(CACHE_BLOCK_SIZE); // log2(CACHE_BLOCK_SIZE)
        TAG_BITS = ADDRESS_SIZE - INDEX_BITS - OFFSET_BITS; // ADDRESS_SIZE - INDEX_BITS - OFFSET_BITS

        arch_state_ptr->bits_for_cache_tag = TAG_BITS;

        SYS_CACHE = (struct CACHE *) calloc(NUM_BLOCKS, sizeof(cache_var));

        for(int i = 0; i < NUM_BLOCKS; i++)
        {
            SYS_CACHE[i].valid = 0;
            SYS_CACHE[i].tag = 0;
        }
        memory_stats_init(arch_state_ptr, TAG_BITS);
    }
}

void parse_memory(int address) {
    int byte_offset = get_piece_of_a_word(address, 0, OFFSET_BITS);
    int index_bits = get_piece_of_a_word(address, OFFSET_BITS, INDEX_BITS);
    int tag = get_piece_of_a_word(address, OFFSET_BITS+INDEX_BITS, TAG_BITS);
    int addr = 0xFFFFFFF0 & address;
}
// returns data on memory[address / 4]
int memory_read(int address){
    arch_state.mem_stats.lw_total++;
    check_address_is_word_aligned(address);

    if(cache_size == 0){
        // CACHE DISABLED
        return (int) arch_state.memory[address / 4];
    }else{
        // CACHE ENABLED
        int byte_offset = get_piece_of_a_word(address, 0, OFFSET_BITS) / 4;
        int index_bits = get_piece_of_a_word(address, OFFSET_BITS, INDEX_BITS);
        int tag = get_piece_of_a_word(address, OFFSET_BITS+INDEX_BITS, TAG_BITS);
        int addr = 0xFFFFFFF0 & address;

        if (SYS_CACHE[index_bits].valid == 1 && SYS_CACHE[index_bits].tag == tag)
        {
            printf("Cache hit\n");
            arch_state.mem_stats.lw_cache_hits += 1;
        }
        else
        {
            printf("Cache miss\n");
            SYS_CACHE[index_bits].valid = 1;
            SYS_CACHE[index_bits].tag = tag;
            for(int i = 0; i < CACHE_BLOCK_SIZE; i++) {
                SYS_CACHE[index_bits].data[i] = (int) arch_state.memory[(addr/4) + i];
            }
        }
        return SYS_CACHE[index_bits].data[byte_offset];
        /// @students: your implementation must properly increment: arch_state_ptr->mem_stats.lw_cache_hits
    }
    return 0;
}

// writes data on memory[address / 4]
void memory_write(int address, int write_data){
    arch_state.mem_stats.sw_total++;
    check_address_is_word_aligned(address);

    if(cache_size == 0){
        // CACHE DISABLED
        arch_state.memory[address / 4] = (uint32_t) write_data;
    }else{
        // CACHE ENABLED
        int byte_offset = get_piece_of_a_word(address, 0, OFFSET_BITS) / 4;
        int index_bits = get_piece_of_a_word(address, OFFSET_BITS, INDEX_BITS);
        int tag = get_piece_of_a_word(address, OFFSET_BITS+INDEX_BITS, TAG_BITS);
        int addr = 0xFFFFFFF0 & address;

        if (SYS_CACHE[index_bits].valid == 1 && SYS_CACHE[index_bits].tag == tag) {
            arch_state.mem_stats.sw_cache_hits += 1;
            for(int i = 0; i < CACHE_BLOCK_SIZE; i++) {
                SYS_CACHE[index_bits].data[i] = (int) arch_state.memory[(addr/4) + i];
            }
        }
        /// @students: your implementation must properly increment: arch_state_ptr->mem_stats.sw_cache_hits
    }
}
