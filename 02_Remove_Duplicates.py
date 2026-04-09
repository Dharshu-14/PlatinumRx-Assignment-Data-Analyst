def remove_duplicates(input_string):
    result = ""
    for char in input_string:
        if char not in result:
            result += char
    return result

print(remove_duplicates("success")) # Result: suces