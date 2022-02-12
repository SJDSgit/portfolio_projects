import sqlite3

def create_table():
    conn=sqlite3.connect("lite.db")
    cur=conn.cursor()
    cur.execute("CREATE TABLE IF NOT EXISTS Fragrance_Inventory (Name TEXT, Quantity INTEGER, Price REAL)")
    conn.commit()
    conn.close()

def insert(n,q,p):
    conn=sqlite3.connect("lite.db")
    cur=conn.cursor()
    cur.execute("INSERT INTO Fragrance_Inventory VALUES(?,?,?)",(n,q,p))
    conn.commit()
    conn.close()

def view():
    conn=sqlite3.connect("lite.db")
    cur=conn.cursor()
    cur.execute("SELECT * FROM Fragrance_Inventory")
    rows=cur.fetchall()
    conn.close()
    return rows

def delete(n):
    conn=sqlite3.connect("lite.db")
    cur=conn.cursor()
    cur.execute("DELETE FROM Fragrance_Inventory WHERE Name=?",(n,))
    conn.commit()
    conn.close()

def update(p,q,n):
    conn=sqlite3.connect("lite.db")
    cur=conn.cursor()
    cur.execute("UPDATE Fragrance_Inventory SET Price=?, Quantity=? WHERE Name=?",(p,q,n))
    conn.commit()
    conn.close()

# create_table() 

# update(329,1,"Park Avenue 'Voyage'")

# delete("Park Avenue 'Voyage'")

# insert("Park Avenue 'Voyage'",1,300)

print(view())