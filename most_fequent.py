# Implement your function below.
def is_rotation(list1, list2):
    if(len(list1) != len(list2)):
        return False
        
    i1 = 0
    i2 = 0

    item1 = list1[i1]
    item2 = list2[i2]

    while item1 != item2 and i2 < len(list2):
        i2 = i2 + 1
        item2 = list2[i2]

    if(i2 == len(list2)):
        return False
    elif(i2 == (len(list2) - 1)):
        i2 = 0
    else:
        i2 = i2 + 1
    
    i1 = i1 + 1
    
        
    while(item1 == item2 and i1 < len(list1)):
        item1 = list1[i1]
        item2 = list2[i2]

        i1 = i1 + 1

        if i2 == (len(list2) - 1):
            i2 = 0
        else:
            i2 = i2 + 1

    return i1 == len(list1)


# NOTE: The following input values will be used for testing your solution.
list1 = [1, 2, 3, 4, 5, 6, 7]
list2a = [4, 5, 6, 7, 8, 1, 2, 3]
print is_rotation(list1, list2a) #should return False.

list2b = [4, 5, 6, 7, 1, 2, 3]
print is_rotation(list1, list2b) #should return True.
list2c = [4, 5, 6, 9, 1, 2, 3]
# is_rotation(list1, list2c) should return False.
list2d = [4, 6, 5, 7, 1, 2, 3]
# is_rotation(list1, list2d) should return False.
list2e = [4, 5, 6, 7, 0, 2, 3]
# is_rotation(list1, list2e) should return False.
list2f = [1, 2, 3, 4, 5, 6, 7]
# is_rotation(list1, list2f) should return True.
