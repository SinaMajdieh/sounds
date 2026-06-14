class_name WavPcmDecoder

## Decodes integer PCM WAV formats into normalized float samples.

static func decode(data: PackedByteArray, format: WavFormat) -> PackedFloat32Array:
	var stride: int = format.bytes_per_sample * format.num_channels
	var frames: int = int(data.size() / float(stride))

	var samples: PackedFloat32Array = PackedFloat32Array()
	samples.resize(frames)

	var norm: float = _normalization_factor(format.bits_per_sample)

	for i: int in frames:
		var offset: int = i * stride
		var raw: float = _read_sample(data, offset, format.bytes_per_sample)
		samples[i] = raw * norm

	return samples


## Converts integer range into [-1.0, 1.0] float range.
##
## Example:
## 16-bit PCM max value = 32767
## So normalization factor = 1 / 32767
static func _normalization_factor(bits: int) -> float:
	match bits:
		8:  return 1.0 / 127.0
		16: return 1.0 / 32767.0
		24: return 1.0 / 8388607.0   # 2^23 - 1
		32: return 1.0 / 2147483647.0 # 2^31 - 1
		_:  return 1.0 / float((1 << (bits - 1)) - 1)


## Reads little-endian signed PCM sample.
static func _read_sample(data: PackedByteArray, offset: int, bytes: int) -> float:
	match bytes:
		1:
			# 8-bit PCM is unsigned [0,255], center is 128
			return float(data[offset]) - 128.0

		2:
			var v: int = int(data[offset]) | (int(data[offset + 1]) << 8)
			if v & 0x8000: v -= 0x10000
			return float(v)

		3:
			var v: int = int(data[offset]) \
				| (int(data[offset + 1]) << 8) \
				| (int(data[offset + 2]) << 16)
			if v & 0x800000: v -= 0x1000000
			return float(v)

		4:
			var v: int = int(data[offset]) \
				| (int(data[offset + 1]) << 8) \
				| (int(data[offset + 2]) << 16) \
				| (int(data[offset + 3]) << 24)
			return float(v)

	return 0.0
