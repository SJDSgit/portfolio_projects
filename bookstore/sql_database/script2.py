import psycopg2

def create_table():
    conn=psycopg2.connect("dbname='database1' user='postgres' password='postgresqlpassword' host= 'localhost' port= '5432'")
    cur=conn.cursor()
    cur.execute("CREATE TABLE IF NOT EXISTS Fragrance_Inventory (Name TEXT, Quantity INTEGER, Price REAL)")
    conn.commit()
    conn.close()

def insert(n,q,p):
    conn=psycopg2.connect("dbname='database1' user='postgres' password='postgresqlpassword' host= 'localhost' port= '5432'")
    cur=conn.cursor()
    cur.execute("INSERT INTO Fragrance_Inventory VALUES(%s,%s,%s)",(n,q,p))
    conn.commit()
    conn.close()

def view():
    conn=psycopg2.connect("dbname='database1' user='postgres' password='postgresqlpassword' host= 'localhost' port= '5432'")
    cur=conn.cursor()
    cur.execute("SELECT * FROM Fragrance_Inventory")
    rows=cur.fetchall()
    conn.close()
    return rows

def delete(n):
    conn=psycopg2.connect("dbname='database1' user='postgres' password='postgresqlpassword' host= 'localhost' port= '5432'")
    cur=conn.cursor()
    cur.execute("DELETE FROM Fragrance_Inventory WHERE Name=%s",(n,))
    conn.commit()
    conn.close()

def update(p,q,n):
    conn=psycopg2.connect("dbname='database1' user='postgres' password='postgresqlpassword' host= 'localhost' port= '5432'")
    cur=conn.cursor()
    cur.execute("UPDATE Fragrance_Inventory SET Price=%s, Quantity=%s WHERE Name=%s",(p,q,n))
    conn.commit()
    conn.close()

# create_table() 

# update(329,1,"Park Avenue 'Voyage'")

# delete("Park Avenue 'Voyage'")

# insert("Brut Attraction",1,299)

print(view())