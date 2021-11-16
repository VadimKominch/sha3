x,y = 1,0
l = []

for i in range(0,24):
    l.append((x,y))
    x_old,y_old = x,y
    x,y = y,(2*x_old+3*y_old)%5
    
    
length  = list(set(l))
print(len(length))