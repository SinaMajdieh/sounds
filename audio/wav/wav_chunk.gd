class_name WavChunks

## Scans WAV RIFF structure and builds a lookup table of chunk_id -> file offset.

static func create_lookup(reader: FileAccess) -> Dictionary[String, int]:
	var riff_id: String = reader.get_buffer(4).get_string_from_ascii()
	var _file_size: int = reader.get_32()
	var wave_id: String = reader.get_buffer(4).get_string_from_ascii()

	if riff_id != "RIFF" or wave_id != "WAVE":
		push_error("Invalid WAV file header")
		return {}

	var lookup: Dictionary[String, int] = {}

	while reader.get_position() < reader.get_length():
		var offset: int = reader.get_position()
		var chunk_id: String = reader.get_buffer(4).get_string_from_ascii()
		var chunk_size: int = reader.get_32()

		lookup[chunk_id] = offset

		# WAV chunks are word-aligned (2 bytes).
		# If chunk_size is odd, a padding byte follows.
		var next_position: int = reader.get_position() + chunk_size
		if chunk_size % 2 == 1:
			next_position += 1

		reader.seek(next_position)

	return lookup


## Ensures required chunks exist.
static func validate_required(chunks: Dictionary[String, int]) -> bool:
	if not chunks.has("fmt "):
		push_error("WAV missing 'fmt ' chunk")
		return false

	if not chunks.has("data"):
		push_error("WAV missing 'data' chunk")
		return false

	return true


## Reads the raw audio data from the data chunk.
static func read_data(reader: FileAccess, offset: int) -> PackedByteArray:
	reader.seek(offset + 4) # skip "data" FourCC
	var size: int = reader.get_32()
	return reader.get_buffer(size)
