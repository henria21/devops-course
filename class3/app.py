import datetime

def greet(name):

    return f"Good by and fare well, Have a great day, {name}, time is {datetime.datetime.now()}!"


if __name__ == "__main__":
    user = "World"
    print(greet(user))
