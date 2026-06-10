# extends GutTest


# func _write_u16(arr: PackedByteArray, v: int):
# 	arr.append(v & 0xFF)
# 	arr.append((v >> 8) & 0xFF)


# func _write_u32(arr: PackedByteArray, v: int):
# 	arr.append(v & 0xFF)
# 	arr.append((v >> 8) & 0xFF)
# 	arr.append((v >> 16) & 0xFF)
# 	arr.append((v >> 24) & 0xFF)


# func _write_str(arr: PackedByteArray, s: String):
# 	for c in s.to_ascii_buffer():
# 		arr.append(c)


# func _create_wav(format: int, bits: int, channels: int, sample_bytes: PackedByteArray) -> PackedByteArray:
# 	var arr: PackedByteArray = PackedByteArray()

# 	var fmt_chunk_size : int = 16
# 	var data_size : int = sample_bytes.size()
# 	var riff_size : int = 4 + (8 + fmt_chunk_size) + (8 + data_size)

# 	_write_str(arr, "RIFF")
# 	_write_u32(arr, riff_size)
# 	_write_str(arr, "WAVE")

# 	# fmt chunk
# 	_write_str(arr, "fmt ")
# 	_write_u32(arr, fmt_chunk_size)

# 	_write_u16(arr, format)
# 	_write_u16(arr, channels)
# 	_write_u32(arr, 44100)

# 	var byte_rate: int = 44100 * channels * int(bits / 8.0)
# 	_write_u32(arr, byte_rate)

# 	var block_align: int = channels * int(bits / 8.0)
# 	_write_u16(arr, block_align)

# 	_write_u16(arr, bits)

# 	# data chunk
# 	_write_str(arr, "data")
# 	_write_u32(arr, data_size)

# 	for b in sample_bytes:
# 		arr.append(b)

# 	return arr

# func test_pcm_8bit():
# 	var samples : PackedByteArray = PackedByteArray([255])

# 	var wav : PackedByteArray = _create_wav(1, 8, 1, samples)

# 	var file : FileAccess = FileAccess.open("user://test8.wav", FileAccess.WRITE)
# 	file.store_buffer(wav)
# 	file.close()

# 	file = FileAccess.open("user://test8.wav", FileAccess.READ)

# 	var wav_signal : WavSignal = WavReader.read(file)

# 	assert_eq(wav_signal.samples.size(), 1)
# 	assert_almost_eq(wav_signal.samples[0], 1.0, 0.02)


# func test_pcm_16bit():
# 	var samples : PackedByteArray = PackedByteArray([0xFF, 0x7F])

# 	var wav : PackedByteArray = _create_wav(1, 16, 1, samples)

# 	var file : FileAccess = FileAccess.open("user://test16.wav", FileAccess.WRITE)
# 	file.store_buffer(wav)
# 	file.close()

# 	file = FileAccess.open("user://test16.wav", FileAccess.READ)

# 	var wav_signal : WavSignal = WavReader.read(file)

# 	assert_eq(wav_signal.samples.size(), 1)
# 	assert_almost_eq(wav_signal.samples[0], 1.0, 0.001)


# func test_pcm_24bit():
# 	var samples := PackedByteArray([0xFF,0xFF,0x7F])

# 	var wav := _create_wav(1, 24, 1, samples)

# 	var file := FileAccess.open("user://test24.wav", FileAccess.WRITE)
# 	file.store_buffer(wav)
# 	file.close()

# 	file = FileAccess.open("user://test24.wav", FileAccess.READ)

# 	var wav_signal := WavReader.read(file)

# 	assert_almost_eq(wav_signal.samples[0], 1.0, 0.001)


# func test_pcm_32bit():
# 	var samples := PackedByteArray([0xFF,0xFF,0xFF,0x7F])

# 	var wav := _create_wav(1, 32, 1, samples)

# 	var file := FileAccess.open("user://test32.wav", FileAccess.WRITE)
# 	file.store_buffer(wav)
# 	file.close()

# 	file = FileAccess.open("user://test32.wav", FileAccess.READ)

# 	var wav_signal := WavReader.read(file)

# 	assert_almost_eq(wav_signal.samples[0], 1.0, 0.001)


# func test_float32():
# 	var samples := PackedByteArray([0x00,0x00,0x80,0x3F])

# 	var wav := _create_wav(3, 32, 1, samples)

# 	var file := FileAccess.open("user://testf.wav", FileAccess.WRITE)
# 	file.store_buffer(wav)
# 	file.close()

# 	file = FileAccess.open("user://testf.wav", FileAccess.READ)

# 	var wav_signal := WavReader.read(file)

# 	assert_almost_eq(wav_signal.samples[0], 1.0, 0.0001)


# func test_stereo_to_mono():
# 	var samples := PackedByteArray([
# 		0xFF,0x7F,  # L = 32767
# 		0x00,0x00   # R = 0
# 	])

# 	var wav := _create_wav(1, 16, 2, samples)

# 	var file := FileAccess.open("user://test_stereo.wav", FileAccess.WRITE)
# 	file.store_buffer(wav)
# 	file.close()

# 	file = FileAccess.open("user://test_stereo.wav", FileAccess.READ)

# 	var wav_signal := WavReader.read(file)

# 	assert_almost_eq(wav_signal.samples[0], 0.5, 0.05)


# func test_invalid_header():
# 	var arr := PackedByteArray()
# 	_write_str(arr, "NOPE")

# 	var file := FileAccess.open("user://bad.wav", FileAccess.WRITE)
# 	file.store_buffer(arr)
# 	file.close()

# 	file = FileAccess.open("user://bad.wav", FileAccess.READ)

# 	var wav_signal := WavReader.read(file)

# 	assert_eq(wav_signal.samples.size(), 0)


# func test_missing_data_chunk():
# 	var arr := PackedByteArray()

# 	_write_str(arr, "RIFF")
# 	_write_u32(arr, 36)
# 	_write_str(arr, "WAVE")

# 	_write_str(arr, "fmt ")
# 	_write_u32(arr, 16)

# 	_write_u16(arr, 1)
# 	_write_u16(arr, 1)
# 	_write_u32(arr, 44100)

# 	_write_u32(arr, 88200)
# 	_write_u16(arr, 2)
# 	_write_u16(arr, 16)

# 	var file := FileAccess.open("user://nodata.wav", FileAccess.WRITE)
# 	file.store_buffer(arr)
# 	file.close()

# 	file = FileAccess.open("user://nodata.wav", FileAccess.READ)

# 	var wav_signal := WavReader.read(file)

# 	assert_eq(wav_signal.samples.size(), 0)
