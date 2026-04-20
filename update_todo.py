with open('todo.txt', 'r') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if line.startswith(('1.', '2.', '3.', '4.', '5.')):
        new_lines.append('[x] ' + line)
    else:
        new_lines.append(line)

with open('todo.txt', 'w') as f:
    f.writelines(new_lines)
