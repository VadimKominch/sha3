from tkinter import *
from tkinter import messagebox

from sha3 import Sha3Block

def createWindow(sha3encoder): 	
    root = Tk() 
    root.title("Sha3 title") 
    root.geometry("800x300") 
    message = StringVar() 

    Label(root, text = "Введите строку:").grid(row=0)
    Label(root, text = "Хеш-значение равно:").grid(row=1)
    message_entry =	Entry(textvariable=message,width = 100) 
    answer = Entry(width = 100)
    message_entry.grid(row=0, column=1)
    answer.grid(row=1, column=1) 
    def calculateHash():
        hash_value = sha3encoder.sha3_256(message.get())
        #messagebox.showinfo("111",hash_value)
        answer.delete(0, 'end')
        answer.insert(0, hash_value)
    btn=Button(root,text="Calculate",command=calculateHash,height=1,width=7) 
    btn.grid(row=2) 
    root.mainloop() 
