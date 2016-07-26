# ra.oop
```
Fish = ra.oop.class(parentTable, {
	ctor = function(self, name, weight)
		self.name = name 
		self.weight = weight
		return self -- return self if construction succeeded, return nil if you want the client to get a nil value from constructing a class with bad data
	end,
	getName = function(self)
		return self.name
	end,
	getWeight = function(self)
		return self.weight
	end
})

myFish = Fish("bob", 123)
print(myFish:getWeight())
```

# FUNCTIONS 
 - ra.oop.class(optional[parent], meta) or ra.oop.class(meta) - returns the class meta table with an __call constructor for creating instances.
 - ra.oop.fast_class - same call semantics as ra.oop.class BUT if a baseclass is defined it will copy the methods over instead of using an __index proxy, this may make function calls to functions defined in the baseclass faster.