/* Copyright 2011, Jacques Fortier. All rights reserved.
 *
 * From https://github.com/jacquesf/COBS-Consistent-Overhead-Byte-Stuffing
 *
 * Redistribution and use in source and binary forms are permitted, with or without modification.
 */

#include "la/avdecc/internals/serialization.hpp"

#include "cobsSerialization.hpp"

namespace la
{
namespace avdecc
{
namespace protocol
{

/**
* COBS encodes a message
* @param input [in] pointer to the raw message
* @param input_length [in] the length of the raw message
* @param output [out] pointer to the output encode buffer
* @return the number of bytes written to "output".
*/
std::size_t cobsEncode(const std::uint8_t* input, std::size_t input_length, std::uint8_t* output)
{
	std::size_t read_index = 0;
	std::size_t write_index = 1;
	std::size_t code_index = 0;
	std::uint8_t code = 1;

	while (read_index < input_length)
	{
		if (input[read_index] == 0)
		{
			output[code_index] = code;
			code = 1;
			code_index = write_index++;
			read_index++;
		}
		else
		{
			output[write_index++] = input[read_index++];
			code++;
			if (code == 0xFF)
			{
				output[code_index] = code;
				code = 1;
				code_index = write_index++;
			}
		}
	}

	output[code_index] = code;

	return write_index;
}

template<size_t MaximumCobsSize>
std::size_t cobsEncode(Deserializer input, Serializer<MaximumCobsSize> output)
{
	std::size_t codeIndex = 0;
	std::uint8_t code = 1;
	auto inputData = reinterpret_cast<const uint8_t*>(input.data());

	while (input.remaining() > 0)
	{
		if (inputData[input.usedBytes()] == 0)
		{
			output[codeIndex] = code;
			code = 1;

			codeIndex = output.usedBytes();
			output.setPosition(output.usedBytes() + 1);
			input.setPosition(input.usedBytes() + 1);
		}
		else
		{
			output << input;
			code++;
			if (code == 0xFF)
			{
				output[codeIndex] = code;
				code = 1;
				codeIndex = output.usedBbytes();
			}
		}
	}

	output[codeIndex] = code;

	return output.usedBytes();
}

/**
* Decodes a COBS encoded message
* @param input [in] pointer to the COBS encoded message
* @param input_length [in] the length of the COBS encoded message
* @param output [in] pointer to the decode buffer
* @param output_length [in] length of the decode buffer
* @return the number of bytes written to "output" if "input" was successfully
* unstuffed, and 0 if there was an error unstuffing "input".
*/
std::size_t cobsDecode(const std::uint8_t* input, std::size_t input_length, std::uint8_t* output, std::size_t output_length)
{
	std::size_t read_index = 0;
	std::size_t write_index = 0;
	std::uint8_t code;
	std::uint8_t i;

	while (read_index < input_length)
	{
		code = input[read_index];

		if (read_index + code > input_length && code != 1)
		{
			return 0;
		}

		read_index++;

		for (i = 1; i < code; i++)
		{
			// check for overflow of the output buffer
			if (write_index == output_length)
			{
				return 0;
			}
			output[write_index++] = input[read_index++];
		}
		if (code != 0xFF && read_index != input_length)
		{
			// check for overflow of the output buffer
			if (write_index == output_length)
			{
				return 0;
			}
			output[write_index++] = '\0';
		}
	}

	return write_index;
}

template<size_t MaximumSize>
std::size_t cobsDecode(Deserializer input, Serializer<MaximumSize> output)
{
	std::uint8_t code;

	while (input.remaining() > 0)
	{
		input >> code;

		if (input.usedBytes() + code > input.size() && code != 1)
		{
			return 0;
		}

		for (auto i = 1; i < code; i++)
		{
			input >> output;
		}
		if (code != 0xFF && input.usedBytes() != input.size())
		{
			output << '\0';
		}
	}

	return output.usedBytes();
}

} // namespace protocol
} // namespace avdecc
} // namespace la
