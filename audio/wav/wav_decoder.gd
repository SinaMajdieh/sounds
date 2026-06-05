class_name WavDecoder

## Routes decoding to the appropriate decoder implementation.

static func decode_to_mono(data: PackedByteArray, format: WavFormat) -> PackedFloat32Array:
	match format.format_code:
		WavConstants.WAV_FORMAT_PCM:
			return WavPcmDecoder.decode(data, format)

		WavConstants.WAV_FORMAT_IEEE_FLOAT:
			return _decode_float(data, format)

		_:
			push_error("Unsupported WAV format: %d" % format.format_code)
			return PackedFloat32Array()


## Decodes IEEE float WAV (32-bit float samples).
static func _decode_float(data: PackedByteArray, format: WavFormat) -> PackedFloat32Array:
	var stride: int = format.bytes_per_sample * format.num_channels
	var frames: int = int(data.size() / float(stride))

	var samples: PackedFloat32Array = PackedFloat32Array()
	samples.resize(frames)

	var reader: StreamPeerBuffer = StreamPeerBuffer.new()
	reader.data_array = data

	for i: int in frames:
		var offset: int = i * stride
		reader.seek(offset)
		samples[i] = reader.get_float() # already normalized [-1, 1]

	return samples
