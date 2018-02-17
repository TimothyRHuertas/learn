def combos_that_sum_to(numbers, amount):
	combos = []
	numbers_set = set(numbers) #remove duplicates

	for number in numbers_set:
		difference = amount - number
		array_without_number = numbers[:]
		array_without_number.remove(number)

		if(difference in array_without_number):
			combos.append([number, difference])
		else :
			combos_that_make_difference = combos_that_sum_to(array_without_number, difference)

			for combo in combos_that_make_difference:
				combos.append([number] + combo)


	return combos

answer = combos_that_sum_to([10, 5, 9, 6, 3, 3, 2, 2, 2], 15)
print len(answer)
print answer