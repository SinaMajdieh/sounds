class_name WavReader

## High-level API for reading WAV files.
## Orchestrates parsing and decoding.

static func read(reader: FileAccess) -> WavSignal:
	var chunks: Dictionary[String, int] = WavChunks.create_lookup(reader)

	if not WavChunks.validate_required(chunks):
		return WavSignal.new(PackedFloat32Array(), 0)

	var format: WavFormat = WavFormat.read_into(reader, chunks["fmt "])
	if format == null:
		return WavSignal.new(PackedFloat32Array(), 0)

	var data: PackedByteArray = WavChunks.read_data(reader, chunks["data"])
	if data.is_empty():
		return WavSignal.new(PackedFloat32Array(), 0)

	var samples: PackedFloat32Array = WavDecoder.decode_to_mono(data, format)

	return WavSignal.new(samples, format.sample_rate)
