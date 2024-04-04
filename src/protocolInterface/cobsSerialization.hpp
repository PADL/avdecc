/* Copyright 2011, Jacques Fortier. All rights reserved.
 *
 * From https://github.com/jacquesf/COBS-Consistent-Overhead-Byte-Stuffing
 *
 * Redistribution and use in source and binary forms are permitted, with or without modification.
 */

#pragma once

#include <cstdint>
#include <cstddef>

namespace la
{
namespace avdecc
{
namespace protocol
{

/**
 * Delimiter byte to frame COBS encoded data
 */
#define COBS_DELIM_BYTE 0x00

/**
 * Number of 0x00 pairs for a packet
 */
#define COBS_ZERO_PAIR_NUM 2

/**
 * Macro to calculate the maximum number of COBS pad bytes with a given payload size 'n'
 * @note Do not use this macro to determine the overhead resulting from a COBS encoding. Use the return value from \ref cobs_encode instead
 */
#define _COBS_BUFFER_PAD(n) (((n + 254 - 1) & ~(254 - 1)) / 254)

/**
 * Decodes a COBS encoded message
 * @param input [in] pointer to the COBS encoded message
 * @param input_length [in] the length of the COBS encoded message
 * @param output [in] pointer to the decode buffer
 * @param output_length [in] length of the decode buffer
 * @return the number of bytes written to "output" if "input" was successfully
 * unstuffed, and 0 if there was an error unstuffing "input".
 */
std::size_t cobsDecode(const std::uint8_t* input, std::size_t input_length, std::uint8_t* output, std::size_t output_length);

/**
 * COBS encodes a message
 * @param input [in] pointer to the raw message
 * @param input_length [in] the length of the raw message
 * @param output [out] pointer to the output encode buffer
 * @return the number of bytes written to "output".
 */
std::size_t cobsEncode(const std::uint8_t* input, std::size_t input_length, std::uint8_t* output);

} // namespace protocol
} // namespace avdecc
} // namespace la
