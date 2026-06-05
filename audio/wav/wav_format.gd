class_name WavFormat extends Resource

## Represents parsed WAV format metadata from the "fmt " chunk.

var format_code: int
var num_channels: int
var sample_rate: int
var bits_per_sample: int
var bytes_per_sample: int

## Reads and parses the "fmt " chunk.
static func read_into(reader: FileAccess, offset: int) -> WavFormat:
	reader.seek(offset + 8) # skip chunk id + chunk size
	var fmt: WavFormat = WavFormat.new()

	fmt.format_code = reader.get_16()
	fmt.num_channels = reader.get_16()
	fmt.sample_rate = reader.get_32()

	# Skip:
	# 4 bytes -> byteRate
	# 2 bytes -> blockAlign
	reader.seek(reader.get_position() + 6)

	fmt.bits_per_sample = reader.get_16()
	fmt.bytes_per_sample = fmt.bits_per_sample >> 3  # divide by 8

	if fmt.num_channels <= 0:
		push_error("Invalid channel count")
		return null

	if fmt.bytes_per_sample not in [1, 2, 3, 4]:
		push_error("Unsupported bytes per sample")
		return null

	# WAVE_FORMAT_EXTENSIBLE stores real format after 8 extra bytes
	# Those 8 bytes are:
	# 2 -> validBitsPerSample
	# 4 -> channelMask
	# 2 -> first part of GUID (real format code)
	if fmt.format_code == WavConstants.WAV_FORMAT_EXTENSIBLE:
		reader.seek(reader.get_position() + 8)
		fmt.format_code = reader.get_16()
	
	return fmt
