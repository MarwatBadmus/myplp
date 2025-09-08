

# Parent class
class Smartphone:
    def __init__(self, brand, model, battery_level=100):
        self.brand = brand
        self.model = model
        self.__battery_level = battery_level  # private attribute (encapsulation)

    def make_call(self, number):
        return f"{self.brand} {self.model} is calling {number} 📞"

    def charge(self, amount):
        self.__battery_level = min(100, self.__battery_level + amount)
        return f"Battery charged to {self.__battery_level}% 🔋"

    def get_battery(self):
        return f"Battery: {self.__battery_level}%"


# Child class (inheritance + polymorphism)
class GamingPhone(Smartphone):
    def __init__(self, brand, model, battery_level=100, cooling_system=True):
        super().__init__(brand, model, battery_level)
        self.cooling_system = cooling_system

    def play_game(self, game):
        return f"Playing {game} 🎮 on {self.brand} {self.model}"

    # Overriding charge() → polymorphism
    def charge(self, amount):
        return f"Fast charging enabled ⚡: {super().charge(amount)}"




class Animal:
    def move(self):
        raise NotImplementedError("Subclass must implement this method")

class Dog(Animal):
    def move(self):
        return "Running 🐕"

class Bird(Animal):
    def move(self):
        return "Flying 🦅"

class Fish(Animal):
    def move(self):
        return "Swimming 🐟"




if __name__ == "__main__":
    # Assignment 1 Test
    print("=== Assignment 1: Smartphone Example ===")
    phone1 = Smartphone("Apple", "iPhone 15")
    gaming1 = GamingPhone("Asus", "ROG Phone 7", 80)

    print(phone1.make_call("123-456-789"))
    print(phone1.get_battery())
    print(phone1.charge(10))

    print(gaming1.play_game("PUBG"))
    print(gaming1.charge(15))  # Overridden method

    print("\n=== Activity 2: Polymorphism Challenge ===")
    animals = [Dog(), Bird(), Fish()]
    for animal in animals:
        print(animal.move())