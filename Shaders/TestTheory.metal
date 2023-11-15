//
//  TestTheory.metal
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 11/14/23.
//

#include <metal_stdlib>
using namespace metal;

//Metal specification.

/*4. address space
 *address space attribute specify the region of memory from where buffer memory objects are allocated.
 1.device , 2.constant , 3.thread , 4.Thread Group. 5.threadgroup_imageblock ,6.ray_data,7.object_data.
 
 *All arguments to a graphics or kernel function that are a pointer or reference to a type needs to be declared with an address space attribute.
 
 *for graphics functions, an argument that is a pointer or reference to a type needs to be declared in the device or constant address space. For kernel functions, an argument that is a pointer or reference to a type needs to be declared in the device, threadgroup, threadgroup_imageblock, or constant address space.
 
 
 *5.Functions :
 
 *Make a function accessible to the Metal API by adding one of these function attributes at the start of a function, which makes it a qualified function. Kernel, vertex, and fragment functions can’t call one another without triggering a compilation error, but they may call other functions that use the [[visible]] attribute. They can also call functions with the [[intersection(...)]] attribute by calling intersect()
 */
