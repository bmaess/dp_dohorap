function digits = extractDigits(numbers, digitPosition)
    numberCount = length(numbers);
    digits = zeros(1,numberCount);
    for n = 1:numberCount
        digits(n) = extractDigit(numbers(n), digitPosition);
    end;
end