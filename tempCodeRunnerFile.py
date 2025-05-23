bar_width = 25
print("-------执行开始--------")
for percent in range(0, 101, 10):
    completed = int((percent / 100) * bar_width)
    remaining = bar_width - completed - 2
    if percent == 100:
        completed -= 1
        remaining += 1
    bar = "*" * completed + "->" + "." * remaining
    print("{:3d}%[{}]".format(percent, bar))
print("-------执行结束--------")