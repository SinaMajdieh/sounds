extends GutTest

func test_descending() -> void:
    var frequencies: Array[FrequencyDataResource] = [
        FrequencyDataResource.Create(1, 3, 0),
        FrequencyDataResource.Create(2, 2, 0),
        FrequencyDataResource.Create(3, 1, 0),
    ]

    frequencies.sort_custom(
        func (a, b):
            if a.Frequency > b.Frequency:
                return true
            return false
    )
    print(frequencies)
    assert_eq(frequencies[0].Frequency, 3)