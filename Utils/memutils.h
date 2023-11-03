//
//  memutils.h
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 10/13/23.
//

#ifndef memutils_h
#define memutils_h

static inline uint64_t alignUp(uint64_t n,uint32_t alignment)
{
    return((n + alignment -1) / alignment) * alignment;
}

#endif /* memutils_h */
