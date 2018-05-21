def locatePerson(personName, city,  country, state  = ""):
	phrase = personName + " lives in " + city + ", " + state + " " + country 
	return phrase 

#output = locatePerson("Arjun", "Washington D.C.", "USA")
#print(output)

def sandwichMaker(*toppings):
	for topping in toppings:
		print(topping.title()) 

sandwichMaker('chicken', 'lettuce', 'mayo')

def dictionEx(fn, ln, age):
	rish = {}
	rish["first_name"] = fn
	rish["last_name"] = ln
	rish["age"] = str(age)
	return rish 


print(dictionEx("Rish", "Nijhawan", 19))



